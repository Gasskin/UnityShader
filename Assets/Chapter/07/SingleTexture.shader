Shader "Custom/SingleTexture"
{
    Properties
    {
        _MainTex("MainTexture",2D)="white"{}
        _Specular("Specular",Color)=(1,1,1,1)
        _Gloss("Gloss",Range(8,256))=8
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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float2 texcoord:TEXCOORD0;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float3 worldNormal:TEXCOORD0;
                float3 worldPos:TEXCOORD1;
                float2 uv:TEXCOORD2;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                o.uv = v.texcoord*_MainTex_ST.xy+_MainTex_ST.zw;
                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));

                // 漫反射
                fixed3 albedo = tex2D(_MainTex,i.uv).xyz ;
                fixed3 diffuse = _LightColor0.xyz*albedo*max(0,dot(worldNormal,worldLight));
                // 环境色
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;
                // 高光
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
