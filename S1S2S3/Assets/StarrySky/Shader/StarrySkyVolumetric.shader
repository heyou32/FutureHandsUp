Shader "Starry Sky/Starry Sky Volumetric" {
	Properties {
		_Speed ("Speed", Range(0, 0.2)) = 0.01
		_Tile ("Tile", Range(0.1, 1)) = 0.85
		_Zoom ("Zoom", Range(0.1, 2)) = 0.8
		_Move ("Move", Vector) = (0, 0, 0, 0)
	}
	CGINCLUDE
		#include "UnityCG.cginc"

		#define formuparam 0.53

		#define volsteps 20
		#define stepsize 0.1

		#define brightness 0.0015
		#define darkmatter 0.3
		#define distfading 0.73
		#define saturation 0.85

		float _Speed, _Tile, _Zoom;
		float3 _Move;

		float4 frag (v2f_img input) : SV_TARGET
		{
			half2 uv = input.uv - 0.5;
			uv.y *= _ScreenParams.y / _ScreenParams.x;
			half3 dir = half3(uv * _Zoom, 1.0);
			float time = _Time.y * _Speed + 0.25;

			half3 from = half3(1.0, 0.5, 0.5);
			half3 move = half3(-_Move.x, -_Move.y, _Move.z);
			from += move * time; //half3(time * 2.0, time, -2.0);

			float s = 0.1, fade = 1.0;
			half3 v = 0.0;
			for (int r = 0; r < volsteps; r++)
			{
				half3 p = from + s * dir * 0.5;
				p = abs(_Tile.xxx - fmod(p, (_Tile * 2.0).xxx));
				float pa, a = pa = 0.0;
				for (int i = 0; i < 17; i++)
				{
					p = abs(p) / dot(p, p) - formuparam; // the magic formula
					a += abs(length(p) - pa); // absolute sum of average change
					pa = length(p);
				}
				float dm = max(0.0, darkmatter - a * a * 0.001); //dark matter
				a *= a * a; // add contrast
				if (r > 6) fade *= 1.0 - dm; // dark matter, don't render near

				v += fade;
				v += half3(s, s*s, s*s*s*s) * a * brightness * fade; // coloring based on distance
				fade *= distfading;  // distance fading
				s += stepsize;
			}
			v = lerp(length(v).xxx, v, saturation); //color adjust
			return half4(v * 0.01, 1.0);
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