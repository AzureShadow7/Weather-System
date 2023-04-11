Shader "Shayders/ImageEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        //centre ("_centre", Vector) = (0.0, -4.0, 0.0)
        p ("position", Vector) = (0.0, 0.0, 0.0)
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
            #define STEPS 32
            #define STEP_SIZE 0.1;

            //float _x, _y, _z;
            //float3 p = float3 (0.0, 0.0, 0.0);
            //float centre = float3 (0.0, -4.0, 0.0);

            //float shapes[2];

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

            fixed4 raymarching(float3 rayOrigin, float3 rayDir)
            {
                float totalDistanceTravelled = 0.0;
                float minHitDistance = 0.001;
                float maxTraceDistance = 1000.0;

                for (int i = 0; i < STEPS; ++i)
                {
                    float3 currentPos = rayOrigin + totalDistanceTravelled * rayDir;

                    float distanceToClosest = map_the_world(currentPos); //sphereDistance(currentPos, float3(0.0, 0.0, 0.0), 1.0);

                    if (distanceToClosest < minHitDistance)
                    {
                        //return fixed4(0.0, 1.0, 0.0, 1.0); //green hit something
                        float3 normal = calculate_normal(currentPos);
                        float3 light_position = float3(5.0, 2.0, 5.0); // position of light
                        float3 direction_to_light = normalize(currentPos - light_position);
                        float diffuse_intensity = max(0.0, dot(normal, direction_to_light));
    

                        return fixed4(0.0, 0.0, 1.0, 0.0) * diffuse_intensity;
                    }

                    if (totalDistanceTravelled > maxTraceDistance)
                    {
                        break;
                    }

                    totalDistanceTravelled += distanceToClosest;
                }


                return fixed4(0.0, 0.0, 0.0, 0.0); //black hit nothing
            }

            sampler2D _MainTex;
            float4 o_colour;

            fixed4 frag(v2f i) : SV_Target
            {
                //fixed4 col = tex2D(_MainTex, i.uv);
                 //just invert the colors
               //col.rgb = 1 - col.rgb;

                float4 col = float4(i.uv.x, i.uv.y, 0, 1);
                //float3 col = tex2D(_MainTex, i.uv);

                //return col;
                float2 uv = i.uv.xy * 2.0 - 1.0;

                float3 rayOrigin = _WorldSpaceCameraPos;
                //float3 rayOrigin = (0.0, 0.0, 0.0);
                float3 rayDirection = float3(uv, 1.0);

                float3 shaded_colour = raymarching(rayOrigin, rayDirection);
                o_colour = float4(shaded_colour, 1.0);

                return o_colour;
            }
            ENDCG
        }
    }
}
