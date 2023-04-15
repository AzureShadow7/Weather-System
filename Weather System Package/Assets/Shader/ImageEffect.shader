Shader "Shayders/ImageEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        //centre ("_centre", Vector) = (0.0, -4.0, 0.0)
        //p ("position", Vector) = (0.0, 0.0, 0.0)
        _time("time", float) = 0.7
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always
        Tags {"Queue" = "Transparent" "RenderType" = "Transparent"}
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #define STEPS 100
            #define STEP_SIZE 0.1;
            #define OCTAVES 3

            uniform float GlobalTime;

            float time;//= GlobalTime + 0.7;

            float3 sunDir;

            float3 sundir;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 viewVector : TEXCOORD1;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                float3 viewVector = mul(unity_CameraInvProjection, float4(v.uv * 2 - 1, 0, -1));
                o.viewVector = mul(unity_CameraToWorld, float4(viewVector, 0));
                return o;
            }


            float sphereDistance(float3 p, float3 centre, float radius)
            {
                return length(p - centre) - radius;
            }

            float shapeBlend(float shape1, float shape2, float a)
            {
                return a * shape1 + (1 - a) * shape2;
            }

            /*float shapeSMin(float a, float b, float k = 32)
            {
                float res = exp(-k * a)
            }*/

            

            float hash(float3 p)
            {
                p = frac(p * 0.3183099 + .1);
                p *= 17.0;
                return frac(p.x * p.y * p.z * (p.x + p.y + p.z));
            }

            float noise(in float3 x)
            {
                x *= 2;
                //#ifdef noise3D_glsl
                //	return snoise(x * 0.25); //enable: slower but more "fractal"
                //#endif
                float3 p = floor(x);
                float3 f = frac(x);
                f = f * f * (3.0 - 2.0 * f);

                return lerp(lerp(lerp(hash(p + float3(0, 0, 0)),
                    hash(p + float3(1, 0, 0)), f.x),
                    lerp(hash(p + float3(0, 1, 0)),
                        hash(p + float3(1, 1, 0)), f.x), f.y),
                    lerp(lerp(hash(p + float3(0, 0, 1)),
                        hash(p + float3(1, 0, 1)), f.x),
                        lerp(hash(p + float3(0, 1, 1)),
                            hash(p + float3(1, 1, 1)), f.x), f.y), f.z);
            }

            float fbm(float3 p, const int octaves)
            {
                float f = 0.0;
                float weight = 0.5;
                for (int i = 0; i < octaves; ++i)
                {
                    f += weight * noise(p);
                    weight *= 0.5;
                    p *= 2.0;
                }
                return f;
            }

            float densityFunc(const float3 p)
            {
                float3 q = p;
                q += float3(0.0, 0.10, 1.0) * time; // step 1 clouds move
                float f = fbm(q, OCTAVES);
                return clamp(2 * f - p.y - 1, 0.0, 1.0);
            }

            float3 lighting(const float3 pos, const float cloudDensity
                , const float3 backgroundColor, const float pathLength)
            {
                float densityLightDir = densityFunc(pos + 0.3 * sundir); // sample in light dir
               float gradientLightDir = clamp(cloudDensity - densityLightDir, 0.0, 1.0);

                float3 litColor = float3(0.91, 0.98, 1.0) + float3(1.0, 0.6, 0.3) * 2.0 * gradientLightDir;
                 float3 cloudAlbedo = lerp(float3(1.0, 0.95, 0.8), float3(0.25, 0.3, 0.35), cloudDensity);

                const float extinction = 0.0003;
                float transmittance = exp(-extinction * pathLength);
                return lerp(backgroundColor, cloudAlbedo * litColor, transmittance);
            }

            float map_the_world(float3 p)
            {
                float displacement = sin(5.0 * p.x) * sin(5.0 * p.y) * sin(5.0 * p.z) * 0.25;
                float sphere_0 = sphereDistance(p, float3(0.0, 0.0, 0.0), 1.0);
                float sphere_1 = sphereDistance(p, float3(0.0, 1.0, 0.0), 2.0);

                //shapes[0] = sphere_0;
                //shapes[1] = sphere_1;

                float _sphere1 = sphere_0 + displacement;
                float _sphere2 = sphere_1 + displacement;

                float d;

                d = shapeBlend(_sphere1, _sphere2, (_SinTime[2] + 1.0) / 2.0);

                //return min(sphere_0, sphere_1) + displacement;
                return d;
            }

            float3 calculate_normal(float3 p)
            {
                const float3 small_step = float3(0.001, 0.0, 0.0);

                float gradient_x = map_the_world(p + small_step.xyy) - map_the_world(p - small_step.xyy);
                float gradient_y = map_the_world(p + small_step.yxy) - map_the_world(p - small_step.yxy);
                float gradient_z = map_the_world(p + small_step.yyx) - map_the_world(p - small_step.yyx);

                float3 normal = float3(gradient_x, gradient_y, gradient_z);
                return normalize(normal);
            }

            float4 raymarchClouds(float3 rayOrigin, float3 rayDir, const float3 backgroundColor)
            {
                float4 sum = float4(0.0, 0.0, 0.0, 0.0);
                float t = 0.1;
                for (int i = 0; i < STEPS; ++i)
                {
                    float3 pos = rayOrigin + t * rayDir;

                    if (0.99 < sum.a) break; //break if opaque

                    float cloudDensity = densityFunc(pos);

                    if (0.01 < cloudDensity) // if not empty -> light and accumulate 
                    {
                        float3 colorRGB = lighting(pos, cloudDensity, backgroundColor, t);
                        float alpha = cloudDensity * 0.4;
                        float4 color = float4(colorRGB * alpha, alpha);
                        sum += color * (1.0 - sum.a); //blend-in new color contribution
                    }
                    t += max(0.05, 0.02 * t); //step size at least 0.05, increase t with each step
                }
                return clamp(sum, 0.0, 1.0);
            }

            fixed4 raymarching(float3 rayOrigin, float3 rayDir, const float3 backgroundCol)
            {
                // background sky
                float sun = clamp(dot(sundir, rayDir), 0.0, 1.0);
                float3 backgroundSky = float3(0.7, 0.79, 0.83)
                    - rayDir.y * 0.2 * float3(1.0, 0.5, 1.0)
                    + 0.2 * float3(1.0, 0.6, 0.1) * pow(sun, 8.0);



                fixed4 sum = (0.0, 0.0, 0.0, 0.0);
                float totalDistanceTravelled = 0.0;
                float t = 1.0;
                float absorption = 100.0;
                float3 light_direction = normalize(float3(1.0, 2.0, 0.0));
                float3 p = rayOrigin;
                const int sampleLightCount = 10;

                float zMax = 40.0;
                float zstep = zMax / STEPS; 

                float minHitDistance = 0.001;
                float maxTraceDistance = 1000.0;

                for (int i = 0; i < STEPS; i++)
                {
                    float3 currentPos = rayOrigin + totalDistanceTravelled * rayDir;

                    float distanceToClosest = map_the_world(currentPos); //sphereDistance(currentPos, float3(0.0, 0.0, 0.0), 1.0);

                    /*if (0.99 < sum.a) break;

                    float density = scene(p)*/

                    if (distanceToClosest < minHitDistance)
                    {
                        //return fixed4(0.0, 1.0, 0.0, 1.0); //green hit something
                        float3 normal = calculate_normal(currentPos);
                        float3 light_position = float3(5.0, 2.0, 5.0); // position of light
                        float3 direction_to_light = normalize(currentPos - light_position);
                        float diffuse_intensity = max(0.0, dot(normal, direction_to_light));

                        // clouds
                        float4 res = raymarchClouds(rayOrigin, rayDir, backgroundSky);
                        float3 col = backgroundSky * (1.0 - res.a) + res.rgb; // blend clouds with sky

                        // add sun glare
                        col += 0.2 * float3(1.0, 0.4, 0.2) * pow(sun, 3.0);

                        return float4(col,0.0);

                        //return fixed4(0.0, 0.0, 1.0, 0.0) * diffuse_intensity;
                    }

                    if (totalDistanceTravelled > maxTraceDistance)
                    {
                        break;
                    }

                    totalDistanceTravelled += distanceToClosest;


                    totalDistanceTravelled += max(0.05, 0.02 * totalDistanceTravelled);
                }

                return fixed4(0.0, 0.0, 0.0, 0.0); //black hit nothing

                //return clamp(sum, 0.0, 1.0);
            }

            sampler2D _MainTex;
            float4 o_colour;

            fixed4 frag(v2f i) : SV_Target
            {
                //fixed4 col = tex2D(_MainTex, i.uv);
                 //just invert the colors
               //col.rgb = 1 - col.rgb;

                sunDir = normalize(float3(sin(time), 0.0, cos(time)));

                //float4 col = float4(i.uv.x, i.uv.y, 0, 1);
                //float3 col = tex2D(_MainTex, i.uv);

                //return col;
                float2 uv = i.uv.xy * 2.0 - 1.0;

                float3 rayOrigin = _WorldSpaceCameraPos;
                //float3 rayOrigin = (0.0, 0.0, 0.0);
                float3 rayDirection = float3(uv, 1.0);

                float sun = clamp(dot(sunDir, rayDirection), 0.0, 1.0);
                float3 backgroundSky = float3(0.07, 0.79, 0.83) - rayDirection.y * 0.2 * float3(1.0, 0.5, 1.0) + 0.2 * float3(1.0, 0.6, 0.1) * pow(sun, 0.8);

                //float3 shaded_colour = raymarching(rayOrigin, rayDirection);
                //o_colour = float4(shaded_colour, 1.0);

                float4 res = raymarchClouds(rayOrigin, rayDirection, backgroundSky);
                float3 col = backgroundSky * 1.0 - res.a + res.rgb;

                col += 0.2 * float3(1.0, 0.4, 0.2) * pow(sun, 3.0);

                //return o_colour;
                return res;
            }
            ENDCG
        }
    }
}
