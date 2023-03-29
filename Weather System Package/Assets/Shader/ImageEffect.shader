Shader "Shayders/ImageEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

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
                float4 vertex : SV_POSITION;
                float3 viewVector : TEXCOORD1;
            };

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
                o.uv = v.uv;
                float3 viewVector = mul(unity_CameraInvProjection, float4(v.uv * 2 - 1, 0, -1));
                o.viewVector = mul(unity_CameraToWorld, float4(viewVector, 0));
                return o;
            }

            sampler2D _MainTex;

            fixed4 frag(v2f i) : SV_Target
            {
                //fixed4 col = tex2D(_MainTex, i.uv);
                // just invert the colors
                //col.rgb = 1 - col.rgb;

                float4 col = float4(i.uv.x, i.uv.y, 0, 1);

                return col;

                float3 rayOrigin = _WorldSpaceCameraPos;
                float3 rayDirection = float3(i.uv, 1.0);

                //return raymarching(rayOrigin, rayDirection);
            }
            ENDCG
        }
    }
}
