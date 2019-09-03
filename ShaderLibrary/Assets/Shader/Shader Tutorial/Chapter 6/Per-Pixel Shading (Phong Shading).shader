Shader "Shader Tutorial/Chapter 6/Per-Pixel Shading (Phong Shading)"
{
	Properties
	{
		_Diffuse ("Diffuse", Color)=(1,1,1,1)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Tags{"LightMode"="ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				fixed3 worldNormal : TEXCOORD0;
			};

			fixed4 _Diffuse;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				return o;
			}
			
			//在面片之间对顶点法线进行插值的技术被称为 Phong 着色(Phong Shading)，也被称为Phong 插值或法线插值着色技术。
			//注意，这里与 Phong 光照模型 是不同的概念。
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 ambient  = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

				fixed3 diffuse = _LightColor0.rgb*_Diffuse.rgb*saturate(dot(worldNormal,worldLightDir));
				fixed3 color = ambient + diffuse;
				
				return fixed4(color,1.0);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
