Shader "Starry Sky/Starry Sky" {
	Properties {
		_Resolution         ("Resolution", Vector) = (0, 0, 0, 0)
		_FrequencyVariation ("Frequency Variation", Range(0.5, 1.0)) = 1.3
		_Origin             ("Origin", Vector) = (0, 0, 0, 0)
		_Sparsity           ("Sparsity", Range(0.1, 1.0)) = 0.5
		_Brightness         ("Brightness", Range(0.001, 0.008)) = 0.0018
		_DistFading         ("Distance Fading", Range(0.1, 1.0)) = 0.68
		_StepSize           ("Step Size", Range(0.1, 1.0)) = 0.2
		_Zoom               ("Zoom", Range(1, 16)) = 8
		_Offset             ("Offset", Vector) = (0, 0, 0, 0)
	}
	CGINCLUDE
		#include "UnityCG.cginc"
		#define I 8
		#define J 20
		float4 _Resolution, _Origin, _Offset;
		float _FrequencyVariation, _Sparsity, _Brightness, _DistFading, _StepSize, _Zoom;

		float4 frag (v2f_img input) : SV_TARGET
		{
			float2 uv = input.uv * (1.0 / _Resolution.xy) - 0.5;
			uv.y *= _Resolution.y * (1.0 / _Resolution.x);

			float3 dir = float3(uv * _Zoom, 1.0);
			dir.xy += _Offset.xy;

			float s = 0.1;
			float fade = 0.01;
			float3 final = 0.0;
			for (int i = 0; i < I; ++i)
			{
				float3 p = _Origin.xyz + dir * (s * 0.5);
				float3 vfreq = _FrequencyVariation.xxx;
				float3 vfreq2x = (_FrequencyVariation * 2.0).xxx;
				p = abs(vfreq - fmod(p, vfreq2x));
 
				float prevlen = 0.0;
				float a = 0.0;
				for (int j = 0; j < J; ++j)
				{
					p = abs(p);
					p = p * (1.0 / dot(p, p)) - _Sparsity;
					float len = length(p);
					a += abs(len - prevlen);
					prevlen = len;
				}

				a *= a * a;
				final += (float3(s, s*s, s*s*s) * a * _Brightness + 1.0) * fade;
				fade *= _DistFading;
				s += _StepSize;
			}

			return float4(final, 1.0);
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