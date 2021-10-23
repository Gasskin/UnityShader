Shader "Custom/NormalMapTangent"
{
    Properties
    {
        _MainTex("MainTexture",2D)="white"{}
        _BumpMap("BumpMap",2D)="bump"{}
        _BumpScale("BumpScale",Range(-2,2))=1
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
            sampler2D _BumpMap;
            float _BumpScale;
            float4 _BumpMap_ST;
            fixed4 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
                float4 texcoord:TEXCOORD0;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float4 uv:TEXCOORD0;
                float3 lightDir:TEXCOORD1;
                float3 viewDir:TEXCOORD2;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.texcoord.xy*_MainTex_ST.xy+_MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy*_BumpMap_ST.xy+_BumpMap_ST.zw;
                
                // TANGENT_SPACE_ROTATION;
                float3 binormal = cross(normalize(v.tangent.xyz),v.normal)*v.tangent.w;
                float3x3 rotation = float3x3(v.tangent.xyz,binormal,v.normal);
                o.lightDir = mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;
                o.viewDir = mul(rotation,ObjSpaceViewDir(v.vertex)).xyz;

                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                fixed3 tangentLightDir = normalize(i.lightDir);
                fixed3 tangentViewDir = normalize(i.viewDir);
                fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap,i.uv.zw));
                tangentNormal.xy*=_BumpScale;
                tangentNormal.z=sqrt(1.0-saturate(dot(tangentNormal.xy,tangentNormal.xy)));

                // 环境色
                fixed3 ambient = tex2D(_MainTex,i.uv.xy).rgb*UNITY_LIGHTMODEL_AMBIENT.rgb;
                // 漫反射
                fixed3 albedo = tex2D(_MainTex,i.uv).xyz ;
                fixed3 diffuse = _LightColor0.xyz*albedo*max(0,dot(tangentNormal,tangentLightDir));
                // 高光
                fixed3 halfdir = normalize(tangentLightDir+tangentViewDir);
                fixed3 specular = _LightColor0.xyz*_Specular.xyz*pow(max(0,dot(tangentNormal,halfdir)),_Gloss);

                return fixed4(ambient+diffuse+specular,1);
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}
