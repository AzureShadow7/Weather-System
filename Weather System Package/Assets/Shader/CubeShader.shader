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
            #define STEPS 1000
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
                float3 wPos : TEXCOORD1;    // World position
            };

            /*sampler2D _MainTex;
            float4 _MainTex_ST;*/

            float distance(float3 p, float3 _Centre) {
                float sum = 0.;
                    /*(p.x - _Centre.x) * (p.x - _Centre.x) +
                    (p.y - _Centre.y) * (p.y - _Centre.y) +
                    (p.z - _Centre.z) * (p.z - _Centre.z);*/
                //sum = sqrt(sum);
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

            fixed4 raymarch(float3 position, float3 direction)
            {
                //int STEPS = 100;
                for (int i = 0; i < STEPS; i++)
                {
                    if (sphereHit(position))
                        return fixed4(1., 0., 1., 1.); // Pink

                    position += direction * STEP_SIZE;
                }
                return fixed4(1., 0., 0., 1.); // Red
            }

            v2f vert(appdata_full v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {

                float3 worldPosition = i.wPos;
                float3 viewDirection = normalize(i.wPos - _WorldSpaceCameraPos);
                return  raymarch(worldPosition, viewDirection);
            }
            ENDCG
        }
    }
}
