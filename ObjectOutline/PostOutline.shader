Shader "Custom/Post Outline"
{
    Properties
    {
        _MainTex("Main Texture",2D)="black"{}
        _SceneTex("Scene Texture",2D)="black"{}
        _Width("Width", int) = 20
        _Strength("Strength", Float) = 2.0
        _OutlineColor("OutlineColor", Color) = (0, 1, 1, 1)
    }
    SubShader 
    {
        Pass 
        {
            CGPROGRAM
     
            sampler2D _MainTex;
            int _Width;
            float _Strength;
            float4 _OutlineColor;
 
            //<SamplerName>_TexelSize is a float2 that says how much screen space a texel occupies.
            float2 _MainTex_TexelSize;
 
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
             
            struct v2f 
            {
                float4 pos : SV_POSITION;
                float2 uvs : TEXCOORD0;
            };
            
            v2f vert (appdata_base v) 
            {
                v2f o;
                 
                //Despite the fact that we are only drawing a quad to the screen, Unity requires us to multiply vertices by our MVP matrix, presumably to keep things working when inexperienced people try copying code from other shaders.
                o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
                 
                //Also, we need to fix the UVs to match our screen space coordinates. There is a Unity define for this that should normally be used.
                o.uvs = o.pos.xy / 2 + 0.5;
                 
                return o;
            }
             
            half frag(v2f i) : COLOR 
            {
                //arbitrary number of iterations for now
                int NumberOfIterations=_Width;
 
                //split texel size into smaller words
                float TX_x=_MainTex_TexelSize.x;
 
                //and a final intensity that increments based on surrounding intensities.
                float ColorIntensityInRadius;
 
                //for every iteration we need to do horizontally
                for(int k=0;k<NumberOfIterations;k+=1)
                {
                    //increase our output color by the pixels in the area
                    ColorIntensityInRadius+=tex2D(
                                                    _MainTex, 
                                                    i.uvs.xy+float2
                                                                (
                                                                    (k-NumberOfIterations/2)*TX_x,
                                                                    0
                                                                )
                                                    ).r/NumberOfIterations;
                }
 
                //output some intensity of teal
                return ColorIntensityInRadius;
            }
             
            ENDCG
 
        }
        //end pass    
         
        GrabPass{}
         
        Pass 
        {
            CGPROGRAM
 
            sampler2D _MainTex;
            sampler2D _SceneTex;
            int _Width;
            float _Strength;
            float4 _OutlineColor;
             
            //we need to declare a sampler2D by the name of "_GrabTexture" that Unity can write to during GrabPass{}
            sampler2D _GrabTexture;
 
            //<SamplerName>_TexelSize is a float2 that says how much screen space a texel occupies.
            float2 _GrabTexture_TexelSize;
 
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
             
            struct v2f 
            {
                float4 pos : SV_POSITION;
                float2 uvs : TEXCOORD0;
            };
             
            v2f vert (appdata_base v) 
            {
                v2f o;
                
                //Despite the fact that we are only drawing a quad to the screen, Unity requires us to multiply vertices by our MVP matrix, presumably to keep things working when inexperienced people try copying code from other shaders.
                o.pos=mul(UNITY_MATRIX_MVP,v.vertex);
 
                //Also, we need to fix the UVs to match our screen space coordinates. There is a Unity define for this that should normally be used.
                o.uvs = o.pos.xy / 2 + 0.5;
                 
                return o;
            }
             
             
            half4 frag(v2f i) : COLOR 
            {
            
                //return tex2D(_GrabTexture, i.uvs.xy);
                //arbitrary number of iterations for now
                
                int NumberOfIterations=_Width;
 
                //split texel size into smaller words
                float TX_y=_GrabTexture_TexelSize.y;
 
                //and a final intensity that increments based on surrounding intensities.
                half ColorIntensityInRadius=0;
 
                //if something already exists underneath the fragment (in the original texture), discard the fragment.
                if(tex2D(_MainTex,i.uvs.xy).r > 0)
                {
                    return tex2D(_SceneTex,float2(i.uvs.x, i.uvs.y));
                    //discard;
                }
 
                //for every iteration we need to do vertically
                [unroll(100)]
                for(int j = 0; j < NumberOfIterations; j += 1)
                {
                    //increase our output color by the pixels in the area
                    ColorIntensityInRadius+= tex2D(
                                                    _GrabTexture, 
                                                    float2(i.uvs.x,i.uvs.y)+float2
                                                                                    (
                                                                                        0,
                                                                                        (j-NumberOfIterations/2)*TX_y
                                                                                    )
                                                    ).r/NumberOfIterations;
                }
 
                //this is alpha blending, but we can't use HW blending unless we make a third pass, so this is probably cheaper.
                half4 outcolor=ColorIntensityInRadius*_OutlineColor.rgba * _Strength+(1-ColorIntensityInRadius)*tex2D(_SceneTex,i.uvs.xy);
                return outcolor;
            }
             
            ENDCG
 
        }
        //end pass    
    }
    //end subshader
}
//end shader