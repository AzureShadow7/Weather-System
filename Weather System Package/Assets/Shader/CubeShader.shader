// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/CubeShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Radius ("Radius", float) = 2
        _Centre ("Centre", Vector) = (0.,0.,0.)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #define STEPS 100
            #define STEP_SIZE 0.01

            float3 _Centre = float3(0.,0.,0.);
            float _Radius = 2.;
            

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f 
            {
                float4 pos : SV_POSITION;    // Clip space
                //float3 wPos : TEXCOORD1;    // World position
                float2 uv : TEXCOORD0;
                float3 viewVector : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float distance(float3 p, float3 _Centre) {
                float sum = 
                    (p.x - _Centre.x) * (p.x + _Centre.x) +
                    (p.y - _Centre.y) * (p.y + _Centre.y) +
                    (p.z - _Centre.z) * (p.z + _Centre.z);
                sum = sqrt(sum);
                return sum;
            }

            float sphereDistance(float3 p)
            {
                return distance(p, _Centre) - _Radius;
            }

            bool sphereHit(float3 p)
            {
                return distance(p, _Centre) < _Radius;
            }

            float DensityFunction(float sdf)
            {
                return max(-sdf, 0);
            }

            //fixed4 raymarch(float3 position, float3 direction)
            //{
            //    //int STEPS = 100;
            //    for (int i = 0; i < STEPS; i++)
            //    {
            //        if (sphereHit(position))
            //            return fixed4(0., 1., 0., 1.); // Green

            //        position += direction * STEP_SIZE;
            //    }
            //    return fixed4(1., 0., 0., 1.); // Red
            //}

            float4 Raymarch(float3 rayStart, float3 rayDir)
            {
                // Scattering in RGB, transmission in A
                float4 intScattTrans = float4(0, 0, 0, 1);

                // Current distance along ray
                float t = 0;

                UNITY_LOOP
                    for (int i = 0; i < STEPS; i++)

                    {
                        // Current ray position
                        float3 rayPos = rayStart + rayDir * t;

                        // Evaluate our signed distance field at the current ray position
                        float sdf = sphereDistance(rayPos);

                        // Only evaluate the cloud color if we're inside the volume
                        if (sdf < 0)

                        {
                            half extinction = DensityFunction(sdf);
                            half transmittance = exp(-extinction * STEP_SIZE);

                            // Get the luminance for the current ray position
                            half3 luminance = Luminance(rayPos);

                            // Integrate scattering
                            half3 integScatt = luminance - luminance * transmittance;
                            intScattTrans.rgb += integScatt * intScattTrans.a;
                            intScattTrans.a *= transmittance;

                            // Opaque check
                            if (intScattTrans.a < 0.003)

                            {
                                intScattTrans.a = 0.0;
                                break;
                            }
                        }

                        // March forward; step size depends on if we're inside the volume or not
                        t += sdf < 0 ? STEP_SIZE : max(sdf, STEP_SIZE);

                    }

                return float4(intScattTrans.rgb, 1 - intScattTrans.a);
            }

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //uvs *= 2; //multiplication -> tiling
                //uvs.x += 0.5; //addition -> offset

                //o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                float3 viewVector = mul(unity_CameraInvProjection, float4(v.uv * 2 - 1, 0, -1));
                o.viewVector = mul(unity_CameraToWorld, float4(viewVector, 0));
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //PREVIOUS CODE
                //float3 worldPosition = i.wPos;
                //float3 viewDirection = normalize(i.wPos - _WorldSpaceCameraPos);

                //CREATING RAYS
                float3 rayPos = _WorldSpaceCameraPos;
                float viewLength = length(i.viewVector);
                float3 rayDir = i.viewVector / viewLength;

                //SAMPLING A TEXTURE
                float2 uvs = i.uv;
                
                //return fixed4(uvs, 0, 1);
                fixed4 textureColour = tex2D(_MainTex, uvs);

                return Raymarch(rayPos, rayDir);
                //return textureColour;
                //return  Raymarch(worldPosition, viewDirection);
            }
            ENDCG
        }
    }
}
