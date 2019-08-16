Shader "CookbookShaders/Chapter05/LitSphere" 
{
	Properties 
	{
		_MainTint ("Diffuse Tint", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_NormalMap ("Normal Map", 2D) = "bump" {}
	}
	
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Unlit vertex:vert
        #pragma target 3.0

		sampler2D _MainTex;
		sampler2D _NormalMap;
		float4 _MainTint;
		
		inline fixed4 LightingUnlit (SurfaceOutput s, fixed3 lightDir, fixed atten)
		{
			fixed4 c = fixed4(1,1,1,1);
			c.rgb = c * s.Albedo;
			c.a = s.Alpha;
			return c;
		}

		struct Input 
		{
			float2 uv_MainTex;
			float2 uv_NormalMap;
			float3 tan1;
			float3 tan2;
		};
		
        void vert (inout appdata_full v, out Input o) 
        {
            UNITY_INITIALIZE_OUTPUT(Input,o);
          
            TANGENT_SPACE_ROTATION; 
            o.tan1 = mul(rotation, UNITY_MATRIX_IT_MV[0].xyz);
            o.tan2 = mul(rotation, UNITY_MATRIX_IT_MV[1].xyz);

            //	等价于以下的代码
            
            //	原书并没有给出这一步的解释，我这里补充一下。这个shader的精髓就在于它是像投影一样。全然平铺在Sphere上的。
            // 	我们能够想象它的本质。就是在Eye Space中，依据顶点法线在X和Y轴上的投影作为UV坐标，对纹理进行採样。
            o.tan1 = mul(rotation, mul(float3(1.0f, 0.0, 0.0f), (float3x3)UNITY_MATRIX_IT_MV));
			o.tan2 = mul(rotation, mul(float3(0.0f, 1.0, 0.0f), (float3x3)UNITY_MATRIX_IT_MV));
          	
        }

		void surf (Input IN, inout SurfaceOutput o) 
		{
			float3 normals = UnpackNormal(tex2D(_NormalMap, IN.uv_NormalMap));
			o.Normal = normals;

			float2 litSphereUV;
			litSphereUV.x = dot(IN.tan1, o.Normal);
			litSphereUV.y = dot(IN.tan2, o.Normal);
		
			half4 c = tex2D (_MainTex, litSphereUV*0.5+0.5);
			o.Albedo = c.rgb * _MainTint;
			o.Alpha = c.a;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
