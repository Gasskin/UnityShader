Shader "Custom/BaseLit"
{
    Properties
    {
        _Diffuse("漫反射颜色",Color)=(1,1,1,1)
        _Specular("高光颜色",Color)=(1,1,1,1)
        _Gloss("高光系数",float)=1
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
                float3 worldNormal : TEXTURE0;
                float3 worldPos : TEXTURE1;
            };

            float4 _Diffuse;
            float4 _Specular;
            float _Gloss;

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));

                
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                
                fixed3 diffuse = _LightColor0.xyz*_Diffuse*max(0,dot(worldNormal,worldLight));

                fixed3 viewdir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 halfdir = normalize(worldLight+viewdir);
                fixed3 specular = _LightColor0.xyz*_Specular.xyz*pow(max(0,dot(worldNormal,halfdir)),_Gloss);

                return fixed4(ambient+diffuse+specular,1); 
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
