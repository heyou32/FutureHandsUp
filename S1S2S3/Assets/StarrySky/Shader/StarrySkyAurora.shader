Shader "Starry Sky/Starry Sky Aurora" {
	Properties {
		_AuroraIntensity    ("Aurora Intensity", Range(0, 2)) = 0.75
		_AuroraTopIntensity ("Aurora Top Intensity", Range(1, 3)) = 2
	}
	CGINCLUDE
		#include "UnityCG.cginc"
		float _AuroraIntensity, _AuroraTopIntensity;

		float rand (half2 uv)
		{
			const float a = 12.9898;
			const float b = 78.233;
			const float c = 43758.5453;
			float dt = dot(uv, half2(a, b));
			float sn = fmod(dt, 3.1415);
			return frac(sin(sn) * c);
		}
		void draw_stars (inout half4 color, half2 uv)
		{
			float t = sin(_Time.y * 10.0 * rand(-uv)) * 0.5 + 0.5;
			color += smoothstep(0.98, 1.0, rand(uv)) * t;
		}
		#define nsin(x) (sin(x) * 0.5 + 0.5)
		void draw_auroras (inout half4 color, half2 uv)
		{
			const half4 aurora_color_a = half4(0.0, 1.2, 0.5, 1.0);
			const half4 aurora_color_b = half4(0.0, 0.4, 0.6, 1.0);

			float t = nsin(-_Time.y + uv.x * 100.0) * 0.075 + nsin(_Time.y + uv.x * distance(uv.x, 0.5) * 100.0) * 0.1 - 0.5;
			t = 1.0 - smoothstep(uv.y - 4.0, uv.y * _AuroraTopIntensity, t);

			half4 c = lerp(aurora_color_a, aurora_color_b, clamp(1.0 - uv.y * t, 0.0, 1.0));
			c += c * c;
			color += c * t * (t + 0.5) * _AuroraIntensity;
		}
		half4 frag (v2f_img input) : SV_TARGET
		{
			half2 uv = input.uv;
			half4 c = 0.0;
			draw_auroras(c, uv);
			draw_stars(c, uv);
			return c;
		}
	ENDCG
	SubShader {
		Cull Off
		Pass {
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			ENDCG
		}
	}
	FallBack Off
}