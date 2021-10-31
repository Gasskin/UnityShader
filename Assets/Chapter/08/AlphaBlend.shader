Shader "Custom/AlphaBend"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" { }
        _AlphaScale ("Alpha Scale", Range(0, 1)) = 0.5
    }
    SubShader
    {
        // 忽略投影，队列和渲染类型都是透明类型
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
        pass
        {
            ZWrite On
            ColorMask 0
        }
        pass
        {
            Tags { "LightMode" = "ForwardBase" }
            
            // 关闭深度写入，设置混合
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _AlphaScale;
            struct a2v
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
                float4 texcoord: TEXCOORD0;
            };
            
            struct v2f
            {
                float4 pos: SV_POSITION;
                float3 worldNormal: TEXCOORD0;
                float3 worldPos: TEXCOORD1;
                float2 uv: TEXCOORD2;
            };
            
            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                
                return o;
            }
            
            fixed4 frag(v2f i): SV_TARGET
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));
                
                fixed4 texColor = tex2D(_MainTex, i.uv);
                
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * texColor.rgb;
                fixed3 diffuse = _LightColor0.rgb * texColor.rgb * max(0, dot(worldNormal, worldLight));
                
                return fixed4(ambient + diffuse, texColor.a * _AlphaScale);
            }
            
            ENDCG
            
        }
    }
    FallBack "Transparent/VertexLit"
}