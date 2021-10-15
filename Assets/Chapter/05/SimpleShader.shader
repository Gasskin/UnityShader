
Shader "Custom/Chapter 5/Simple Shader"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include <UnityShaderUtilities.cginc>

            float4 vert(float4 v : POSITION):SV_POSITION{
                return UnityObjectToClipPos(v);
            }

            fixed4 frag():SV_Target{
                return fixed4(1,1,1,1);
            }
            
            ENDCG
        }
    }
    FallBack "Diffuse"
}
