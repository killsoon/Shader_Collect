Shader "Tut/Shadow/PlanarShadow_Chaos" {
    Properties{
        _Intensity("atten",range(1,16))=1
    }
    SubShader {
        Tags{ "LightMode" = "ForwardBase"
        "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" 
    }
    pass {
        Cull Front
        Blend SrcAlpha OneMinusSrcAlpha
        Offset -1,-1
        Stencil{
            Ref 1           //参考值为1，stencilBuffer值默认为0  
            Comp Greater    //stencil比较方式是大于
            Pass replace    //通过的处理是替换，就是拿1替换buffer 的值  
            Fail Keep       //深度检测和模板检测双失败的处理是保持
            ZFail keep      //深度检测失败的处理是保持
        }
        CGPROGRAM
        #pragma vertex vert 
        #pragma fragment frag
        #include "UnityCG.cginc"
        float4x4 _World2Ground;
        float4x4 _Ground2World;
        float _Intensity;
        struct v2f{
            float4 pos:SV_POSITION;
            float atten:TEXCOORD0;
        };
        v2f vert(float4 vertex: POSITION)
        {
            v2f o;
            float3 litDir;
            litDir=normalize(WorldSpaceLightDir(vertex));  
            litDir=mul(_World2Ground,float4(litDir,0)).xyz;
            float4 vt;
            vt= mul(unity_ObjectToWorld, vertex);
            vt=mul(_World2Ground,vt);
            vt.xz=vt.xz-(vt.y/litDir.y)*litDir.xz;
            vt.y=0;
            vt=mul(_Ground2World,vt);//back to world
            vt=mul(unity_WorldToObject,vt);
            o.pos=UnityObjectToClipPos(vt);
            o.atten=length(vt)/_Intensity;
            return o;
        }
        float4 frag(v2f i) : COLOR 
        {
            return float4(0,0,0, smoothstep(1, 0, i.atten / 2));
        }
        ENDCG 
        }//
   }
}