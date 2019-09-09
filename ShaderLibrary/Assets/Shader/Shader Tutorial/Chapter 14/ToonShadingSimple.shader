Shader "Custom/ToonShadingSimple"
{
	Properties
	{
		[Header(Main)]
		_MainTex ("Texture", 2D) = "white" {}
		_Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_RimColor ("RimColor", Color) = (1.0, 1.0, 1.0, 1.0)
		_ShadowThreshold ("ShadowThreshold", Range(-1.0, 1.0)) = 0.2
		_ShadowBrightness ("ShadowBrightness", Range(0.0, 1.0)) = 0.6
		_RimThreshold ("RimThreshold", Range(0.0, 1.0)) = 0.35
		_RimPower ("RimPower", Range(0.0, 16)) = 4.0

	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Cull Back
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				UNITY_FOG_COORDS(3)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			fixed4 _RimColor;
			fixed _ShadowThreshold;
			fixed _ShadowBrightness;
			fixed _RimThreshold;
			half _RimPower;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal); //法线 N
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos)); //光照方向 L
				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos)); //视角方向 V

				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv); 
				fixed diffValue = dot(worldNormal, worldLightDir);
				fixed diffStep = step(_ShadowThreshold, diffValue);
				fixed4 light = _LightColor0 * 0.5 + 0.5;
				fixed4 diffuse = light * col * (diffStep + (1 - diffStep) * _ShadowBrightness) * _Color;
				fixed rimValue = pow(1 - dot(worldNormal, worldViewDir), _RimPower);
				fixed rimStep = step(_RimThreshold, rimValue);
				fixed4 rim = light * rimStep * 0.5 * diffStep * _RimColor;
				
				fixed4 final = diffuse + rim;

				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, final);
				
				return  final;
			}
			ENDCG
		}
	}
}
