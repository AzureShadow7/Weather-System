Shader "Unlit/Raymarching-Shader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        /*Tags { "RenderType"="Opaque" }
        LOD 100*/

        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            #define STEPS 20
            #define STEP_SIZE 0.1;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                //UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 viewVector : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float sphereDistance(float3 p, float3 centre, float radius)
            {
                return length(p - centre) - radius;
            }

            fixed4 raymarching(float3 rayOrigin, float3 rayDir)
            {
                float totalDistanceTravelled = 0.0;
                float minHitDistance = 0.001;
                float maxTraceDistance = 1000.0;

                for (int i = 0; i < STEPS; ++i)
                {
                    float3 currentPos = rayOrigin + totalDistanceTravelled * rayDir;

                    float distanceToClosest = sphereDistance(currentPos, float3(0.0, 0.0, 0.0), 1.0);

                    if (distanceToClosest < minHitDistance)
                    {
                        return fixed4(0.0, 1.0, 0.0, 1.0); //green
                    }

                    if (totalDistanceTravelled > maxTraceDistance)
                    {
                        break;
                    }

                    totalDistanceTravelled += distanceToClosest;
                }

                return fixed4(0.1, 0.0, 0.0, 1.0); //red
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //UNITY_TRANSFER_FOG(o,o.vertex);

                float3 viewVector = mul(unity_CameraInvProjection, float4(v.uv * 2 - 1, 0, -1));
                o.viewVector = mul(unity_CameraToWorld, float4(viewVector, 0));

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //// sample the texture
                //fixed4 col = tex2D(_MainTex, i.uv);
                //// apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
                //return col;

                //CREATING RAYS
                float3 rayOrigin = _WorldSpaceCameraPos;
                float3 rayDirection = float3(i.uv, 1.0);

                return raymarching(rayOrigin, rayDirection);
            }
            ENDCG
        }
    }
}
