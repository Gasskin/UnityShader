// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/AlphaTest"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" { }
        _CutOff ("CutOff", Range(0, 1)) = 0.5
    }
    SubShader
    {
        // 渲染队列：透明度测试
        // RenderType将Shader归入提前定义的组中，即TransparentCutout
        // IgnoreProjector=true，忽略投影
        Tags { "Queue" = "AlphaTest" "IgnoreProjector" = "True" "RenderType" = "TransparentCutout" }
        
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Lighting.cginc"
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _CutOff;
            
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
                
                // clip(texColor - _CutOff);
                if (texColor.a < _CutOff)
                    discard;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * texColor.rgb;
                fixed3 diffuse = _LightColor0.rgb * texColor.rgb * max(0, dot(worldNormal, worldLight));
                
                return fixed4(ambient + diffuse, 1);
            }
            
            
            ENDCG
            
        }
    }
}