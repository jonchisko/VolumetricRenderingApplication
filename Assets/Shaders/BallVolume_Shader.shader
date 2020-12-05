// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/BallVolume_Shader"
{
    Properties
    {
        _ObjectColor ("Color", Color) = (0.1, 0.1, 0.1, 1.0)
        _Gloss ("Gloss", Color) = (1.0, 1.0, 1.0, 1.0)
        _SpecularPower ("Spec Power", Range(0.001, 10)) = 0.1
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

            #define MIN_DISTANCE 0.001
            #define STEPS 1024

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

            fixed4 _ObjectColor;
            fixed4 _Gloss;
            float4 _Center;
            float _Radius;
            float _SpecularPower;
            fixed4 _FakeLight;

            float sphereSFD(float3 position)
            {
                return distance(position, _Center.xyz) - _Radius;
            }

            float3 raymarchHitSphere(float3 position, float3 direction)
            {
                int i = 0;
                while (i < STEPS)
                {
                    float sfd = sphereSFD(position);
                    if (sfd <= MIN_DISTANCE) 
                    {
                        return position;
                    }
                    position = position + sfd * direction;
                    i++;
                }
                return float3(0.0, 0.0, 0.0);
            }

            fixed4 applySimpleLight(float3 worldPosition, float3 lightPosition, float3 viewDirection)
            {
                float3 fromCenterToSurface = normalize(worldPosition - _Center);
                float3 lightDir = -normalize(worldPosition - lightPosition);
                float3 h = (lightDir - viewDirection ) / 2;
                return _ObjectColor + clamp(dot(fromCenterToSurface, lightDir), 0.0, 1.0) * _FakeLight + pow(dot(h, fromCenterToSurface), _SpecularPower) *_Gloss;
            }

            fixed4 rayMarch(float3 vertexWorld, float3 viewDirection)
            {
                fixed4 col = fixed4(0, 0, 0, 0);
                float3 hitPosition = raymarchHitSphere(vertexWorld, viewDirection);
                if (distance(hitPosition, float3(0, 0, 0) > 0))
                {
                    col = applySimpleLight(hitPosition, _WorldSpaceLightPos0, viewDirection);
                }
                return col;
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
                return rayMarch(i.vertexWorld, viewDirection);
            }
            ENDCG
        }
    }
}
