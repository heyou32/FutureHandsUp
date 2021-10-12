Shader "Starry Sky/Starry Sky Object" {
	Properties {
		_MainTex ("Texture", 2D) = "white" {}
		_Zoom ("Zoom", Float) = 1
		_Speed ("Speed", Float) = 1
	}
	SubShader {
		Cull Off
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			sampler2D _MainTex;
			half _Zoom, _Speed;

			float4 vert (appdata_base v) : SV_POSITION
			{
				return UnityObjectToClipPos(v.vertex);
			}
			fixed4 frag (float4 i : VPOS) : SV_Target
			{
				return tex2D(_MainTex, float2((i.xy/ _ScreenParams.xy) + float2(_CosTime.x * _Speed, _SinTime.x * _Speed) / _Zoom));
//				return tex2D(_MainTex, i.xy / _ScreenParams.xy);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}