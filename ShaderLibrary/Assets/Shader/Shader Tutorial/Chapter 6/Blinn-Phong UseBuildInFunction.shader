Shader "Shader Tutorial/Chapter 6/Blinn-Phong UseBuildInFuction"
{
	Properties
	{
		_Diffuse ("Diffuse", Color) = (1,1,1,1)
		_Specular ("Specular", Color) = (1,1,1,1)
		_Gloss ("Gloss",Range(8.0,256)) = 20
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
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
			};

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				//o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				//使用内置函数
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos=mul(unity_ObjectToWorld,v.vertex).xyz;
				return o;
			}
			
			//在面片之间对顶点法线进行插值的技术被称为 Phong 着色(Phong Shading)，也被称为Phong 插值或法线插值着色技术。
			//注意，这里与 Phong 光照模型 是不同的概念。
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 ambient  = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 worldNormal = normalize(i.worldNormal);
				//fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				//fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);

				//使用内置函数
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				

				fixed3 diffuse = _LightColor0.rgb*_Diffuse.rgb*saturate(dot(worldNormal,worldLightDir));

				// Phong 光照模型
				// fixed3 reflectDir = normalize(reflect(-worldLightDir,worldNormal));
				
				// Blinn-Phong 光照模型
				// 改用半角向量进行计算，避免 Phong 的缺陷 (观察方向和反射方向的夹角就可能大于90度会产生误差)
				fixed3 halfDir = normalize(worldLightDir+viewDir);

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(worldNormal,halfDir)), _Gloss);

				fixed3 color = ambient + diffuse + specular;
				
				return fixed4(color,1.0);
			}
			ENDCG
		}
	}
	FallBack "Specular"
}
