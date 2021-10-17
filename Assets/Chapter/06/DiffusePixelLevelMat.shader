Shader "Custom/DiffusePixelLevelMat"
{
    Properties
    {
        //漫反射颜色
        _DiffuseColor("Color",Color)=(1,1,1,1)
    }
    SubShader
    {
        Pass
        {
            //正向渲染
            Tags{ "LightMode"="ForwardBase" }
            CGPROGRAM//------------------CG语言开始-------------------
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Lighting.cginc"

            float4 _DiffuseColor;
            struct appdata
            {
                float4 vertex : POSITION;
                //顶点法线
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                //世界空间下的顶点法线
                fixed3 worldNormal : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //通过矩阵运算，得到世界空间下的顶点法线
                o.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3  worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                //使用兰伯特光照模型公式
                fixed3 diffuse = _LightColor0.rgb * _DiffuseColor.rgb *
                    saturate(dot(worldNormal,worldLightDir));
                fixed3 color = diffuse + ambient;
                return fixed4(color,1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
