// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/BallVolume_Shader"
{
    Properties
    {
        _RayMarchSteps ("RayMarch Steps", Int) = 512
        _StepSize ("Step Size", Float) = 0.1
        _ObjectColor ("Color", Color) = (0.1, 0.1, 0.1, 1.0)
        _Center ("Sphere Center", Vector) = (0, 0, 0, 0)
        _Radius ("Sphere Radius", Float) = 1
        _FakeLight ("Fake Light", Color) = (0.2, 0.1, 0.0, 1.0)
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

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float3 vertexWorld : TEXCOORD1;
                float4 pos : SV_POSITION;
            };

            int _RayMarchSteps;
            float _StepSize;
            float4 _ObjectColor;
            float4 _Center;
            float _Radius;
            fixed4 _FakeLight;

            bool sphereHit(float3 position)
            {
                return distance(position, _Center.xyz) < _Radius;
            }

            float3 raymarchHitSphere(float3 position, float3 direction)
            {
                int i = 0;
                while (i < _RayMarchSteps) 
                {
                    float3 stepT = i * _StepSize;
                    position = position + stepT * direction;
                    if (sphereHit(position)) 
                    {
                        return position;
                    }
                    i++;
                }
                return float3(0.0, 0.0, 0.0);
            }

            fixed4 applySimpleLight(float3 worldPosition, float3 lightPosition)
            {
                float3 fromCenterToSurface = normalize(worldPosition - _Center);
                float3 lightDir = -normalize(_Center - lightPosition);
                return clamp(dot(fromCenterToSurface, lightDir), 0.0, 1.0) * _FakeLight;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.vertexWorld = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 viewDirection = normalize(i.vertexWorld - _WorldSpaceCameraPos);
                fixed4 col = fixed4(0, 0, 0, 0);
                float3 hitPosition = raymarchHitSphere(i.vertexWorld, viewDirection);
                if (distance(hitPosition, float3(0, 0, 0) > 0))
                {
                    col = _ObjectColor + applySimpleLight(hitPosition, _WorldSpaceLightPos0);
                }
                return col;
            }
            ENDCG
        }
    }
}
