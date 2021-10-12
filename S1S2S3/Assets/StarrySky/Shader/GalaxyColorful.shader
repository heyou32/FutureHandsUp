Shader "Starry Sky/Galaxy Colorful" {
	Properties {
		_SpeedOfColorChange1 ("Color Modify Speed 1", Range(0, 6)) = 0.2
		_SpeedOfColorChange2 ("Color Modify Speed 2", Range(0, 6)) = 0.3
		_Colorful            ("Colorful", Range(0.1, 0.9)) = 0.7
	}
	CGINCLUDE
		#include "UnityCG.cginc"
		half _SpeedOfColorChange1, _SpeedOfColorChange2, _Colorful;

		half4 frag (v2f_img input) : SV_TARGET
		{
			half2 uv = input.uv - 0.5;
			float t = _Time.y * 0.1 + ((0.25 + 0.05 * sin(_Time.y * 0.1)) / (length(uv.xy) + 0.07)) * 2.2;
			float si = sin(t);
			float co = cos(t);
			half2x2 ma = half2x2(co, si, -si, co);

			float v1, v2, v3;
			v1 = v2 = v3 = 0.0;

			float s = 0.0;
			for (int i = 0; i < 90; i++)
			{
				half3 p = s * half3(uv, 0.0);
				p.xy = mul(p.xy, ma);
				p += half3(0.22, 0.3, s - 1.5 - sin(_Time.y * 0.13) * 0.1);
				for (int i = 0; i < 8; i++)
					p = abs(p) / dot(p,p) - 0.659;
				v1 += dot(p, p) * 0.0015 * (1.8 + sin(length(uv.xy * 13.0) + 0.5 - _Time.y * _SpeedOfColorChange1));
				v2 += dot(p, p) * 0.0013 * (1.5 + sin(length(uv.xy * 14.5) + 1.2 - _Time.y * _SpeedOfColorChange2));
				v3 += length(p.xy * 10.0) * 0.0003;
				s  += 0.035;
			}
			float len = length(uv);
			v1 *= smoothstep(_Colorful, 0.0, len);
			v2 *= smoothstep(0.5, 0.0, len);
			v3 *= smoothstep(0.9, 0.0, len);

			half3 col = half3(v3 * (1.5 + sin(_Time.y * 0.2) * 0.4),
				(v1 + v3) * 0.3, v2) + smoothstep(0.2, 0.0, len) * 0.85 + smoothstep(0.0, 0.6, v3) * 0.3;

			float dist = distance(input.uv, 0.5);
			float f = 1.0 - smoothstep(0.1, 0.5, dist);

			return half4(min(pow(abs(col), 1.2), 1.0), f);
		}
	ENDCG
	SubShader {
		Tags { "RenderType" = "Transparent" "IgnoreProjector" = "True" "Queue" = "Transparent-1" }
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