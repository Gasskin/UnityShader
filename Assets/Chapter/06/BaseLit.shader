Shader "Custom/BaseLit"
{
    Properties
    {
        _BaseColor("自发光颜色",Color) = (1,1,1,1)
        _Base("自发光系数",Range(0,1))=0.01
        _Diffuse("漫反射系数",Range(0,1))=1
        _Specular("高光系数1",Range(0,1))=1
        _Gloss("高光系数2",float)=1
    }
    SubShader
    {
        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            
            #include "Lighting.cginc"

            
            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed3 worldNormal : TEXTURE0;
                fixed3 worldPos : TEXTURE1;
            };

            fixed4 _BaseColor;
            float _Base;
            float _Diffuse;
            float _Specular;
            float _Gloss;

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                // 环境光
                fixed4 environment = UNITY_LIGHTMODEL_AMBIENT;
                // 自发光
                fixed4 base = _Base*_BaseColor;
                // 漫反射
                fixed3 worldLight = normalize(_WorldSpaceLightPos0);
                fixed3 diffuse = _LightColor0 * _Diffuse * saturate(dot(i.worldNormal,worldLight));
                // 高光
                fixed3  viewDir = normalize(_WorldSpaceCameraPos-i.worldPos);
                fixed3 halfDir = normalize(_WorldSpaceLightPos0+viewDir);
                fixed3 specular = _LightColor0*_Specular*pow(max(0,dot(i.worldNormal,halfDir)),_Gloss);                
                
                return fixed4(environment.xyz+base.xyz+diffuse+specular,1.0);
            }
            
            ENDCG
        }
    }
    FallBack "Diffuse"
}
