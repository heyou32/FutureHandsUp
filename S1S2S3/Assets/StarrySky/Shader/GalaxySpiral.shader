Shader "Starry Sky/Galaxy Spiral" {
	Properties {
		_Resolution       ("Resolution", Vector) = (100, 100, 0, 0)
		_Speed            ("Speed", Range(-4, 4)) = 0.1
		_Whirl            ("Whirl", Float) = 14
		[IntRange]_ArmNum ("Arm Count", Range(1, 20)) = 5
		_ArmLength        ("Arm Length", Range(1, 8)) = 2.2
		_Color            ("Color", Color) = (1, 1, 1, 1)
	}
	CGINCLUDE
		#include "UnityCG.cginc"
		half4 _Resolution, _Color;
		half _Speed, _Whirl, _ArmNum, _ArmLength;

		half4 frag (v2f_img input) : SV_TARGET
		{
			half2 uv = input.uv - 0.5;
			uv.x *= _Resolution.x / _Resolution.y;
			uv = half2((atan2(uv.x, uv.y)) - _Time.y * _Speed, sqrt(uv.x * uv.x + uv.y * uv.y));
			float g = pow(1.0 - uv.y, 10.0) * 10.0;
			half3 col = (sin((uv.x + pow(uv.y, 0.2)*_Whirl) * _ArmNum)).xxx + g - uv.y * _ArmLength;
			half c = col / 5.0;
			return half4(c * _Color.rgb, c);
		}
	ENDCG
	SubShader {
		Tags { "RenderType" = "Transparent" "IgnoreProjector" = "True" "Queue" = "Transparent" }
		Cull Off
		Blend SrcAlpha OneMinusSrcAlpha
		Pass {
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			ENDCG
		}
	}
	FallBack Off
}