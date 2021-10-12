Shader "Starry Sky/Starry Sky Star Field" {
	Properties {
		_SpeedOfDepth              ("Speed Of Depth", Range(0, 1)) = 0.0162
		_SpeedOfHorizontalMovement ("Speed Of Movement", Range(0, 1)) = 0.05
		_SpeedOfBlink              ("Speed Of Blink", Range(1, 16)) = 3.0
		_Scale                     ("Scale", Range(1, 100)) = 20
		_Brightness                ("Brightness", Range(0.01, 0.1)) = 0.025
		_Color                     ("Color", Color) = (0.9, 0.59, 0.9, 1.0)
	}
	CGINCLUDE
		#include "UnityCG.cginc"
		float _AuroraIntensity;

		#define NUM_LAYERS 6.0
		#define TAU 6.28318
		#define PI 3.141592

		half _SpeedOfDepth, _SpeedOfHorizontalMovement, _SpeedOfBlink, _Scale, _Brightness;
		half3 _Color;

		float2x2 Rot (float a)
		{
			float s = sin(a), c = cos(a);
			return float2x2(c, -s, s, c);
		}
		float Hash21 (float2 p)
		{
			p = frac(p * float2(123.34, 456.21));
			p += dot(p, p + 45.32);
			return frac(p.x * p.y);
		}
		float Star (float2 uv, float flare)
		{
			float d = length(uv);
			float m = _Brightness / d;
			float rays = max(0.0, 1.0 - abs(uv.x * uv.y * 1000.0));
			m += (rays * flare) * 2.0;
			m *= smoothstep(1.0, 0.2, d);
			return m;
		}
		float3 StarLayer (float2 uv)
		{
			float3 col = 0.0;
			float2 gv = frac(uv) - 0.5;
			float2 id = floor(uv);
			for (int y=-1;y<=1;y++)
			{
				for(int x=-1; x<=1; x++)
				{
					float2 offs = float2(x, y);
					float n = Hash21(id + offs);
					float size = frac(n * 45.32);
					float star = Star(gv-offs-float2(n, frac(n*34.))+.5, smoothstep(.8,.9,size)*.46);
					float3 color = sin(float3(0.2, 0.3, 0.9) * frac(n * 2345.2) * TAU) * 0.25 + 0.75;
					color = color * float3(_Color.r, _Color.g, _Color.b + size);
					star *= sin(_Time.y * _SpeedOfBlink + n * TAU) * 0.25 + 0.5;
					col += star * size * color;
				}
			}
			return col;
		}
		half4 frag (v2f_img input) : SV_TARGET
		{
			float2 fragCoord = input.uv * _ScreenParams.xy;
			float2 uv = (fragCoord - 0.5 * _ScreenParams.xy) / _ScreenParams.y;
			float t = _Time.y * _SpeedOfDepth;
			uv = mul(uv, Rot(t));

			half3 col = 0.0;
			for (float i=0; i<1; i+=1.0/NUM_LAYERS)
			{
				float depth = frac(i + t);
				float scale = lerp(_Scale, 0.5, depth);
				float fade = depth * smoothstep(1.0, 0.9, depth);
				col += StarLayer(uv * scale + i * 453.2 - _Time.y * _SpeedOfHorizontalMovement) * fade;
			}
			return half4(col, 1.0);
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