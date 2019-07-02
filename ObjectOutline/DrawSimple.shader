//Shader "Custom/DrawSimple"
//{
//    SubShader 
//    {
//        ZWrite Off
//        ZTest Always
//        Lighting Off
//        Pass
//        {
//            CGPROGRAM
//            #pragma vertex VShader
//            #pragma fragment FShader
 
//            struct VertexToFragment
//            {
//                float4 pos:POSITION;
//            };
 
//            //just get the position correct
//            VertexToFragment VShader(VertexToFragment i)
//            {
//                VertexToFragment o;
//                o.pos = mul(UNITY_MATRIX_MVP,i.pos);
//                return o;
//            }
 
//            //return white
//            half4 FShader():COLOR0
//            {
//                return half4(1,1,1,1);
//            }
 
//            ENDCG
//        }
//    }
//}

Shader "Custom/DrawSimple"
{
    SubShader 
    {
        ZWrite Off
        ZTest Always
        Lighting Off
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
 
            struct v2f
            {
                float4 pos:SV_POSITION;
            };
 
            //just get the position correct
            v2f vert(appdata_full v)
            {
                v2f o;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                return o;
            }
 
            //return white
            fixed4 frag():COLOR0
            {
                return fixed4(1,1,1,1);
            }
 
            ENDCG
        }
    }
}