Shader "Starry Sky/Starry Galaxy" {
	Properties {
		_Param1 ("Nebula Layer 1", Range(-1, 1.5)) = 0.5
		_Param2 ("Nebula Layer 2", Range(-1, 1.5)) = 0.5
		_Param3 ("Nebula Layer 3", Range(-1, 1.5)) = 0.5
		_Param4 ("Nebula Layer 4", Range(0, 1)) = 0.5
//		_MoveSpeed ("Move Speed", Vector) = (0, 0, 0, 0)
		_Star ("Star", Float) = 40
	}
	SubShader {
		Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalRenderPipeline" "IgnoreProjector" = "True" }
		Pass {
			HLSLPROGRAM
			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x
			#pragma target 2.0

			//--------------------------------------
			// GPU Instancing
			#pragma multi_compile_instancing

			#pragma vertex LitPassVertex
			#pragma fragment LitPassFragment

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

			struct Attributes
			{
				float4 positionOS   : POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				float4 screenPos  : TEXCOORD0;
			};
			Varyings LitPassVertex (Attributes input)
			{
				VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
				Varyings o;
				o.positionCS = vertexInput.positionCS;
				o.screenPos = ComputeScreenPos(vertexInput.positionCS);
				return o;
			}
			#define FLT_MIN 1.175494351e-38

			float field (in float3 p , float s)
			{
				float strength = 7.0 + 0.03 * log(1.e-6 + frac(sin(_Time.y) * 4373.11));
				float accum = s / 4.0;
				float prev = 0;
				float tw = 0;
				for (int i = 0; i < 26; ++i)
				{
					float mag = dot(p , p);
					p = abs(p) / mag + float3 (-0.5 , -0.4 , -1.5);
					float w = exp(-float(i) / 7.0);
					accum += w * exp(-strength * pow(abs(mag - prev) , 2.2));
					tw += w;
					prev = mag;
				}
				return max(0, 5.0 * accum / tw - 0.7);
			}
			float field2 (in float3 p , float s)
			{
				float strength = 7.0 + 0.03 * log(1.e-6 + frac(sin(_Time.y) * 4373.11));
				float accum = s / 4.0;
				float prev = 0.0;
				float tw = 0.0;
				for (int i = 0; i < 18; ++i)
				{
					float mag = dot(p , p);
					p = abs(p) / mag + float3 (-0.5 , -0.4 , -1.5);
					float w = exp(-float(i) / 7.0);
					accum += w * exp(-strength * pow(abs(mag - prev) , 2.2));
					tw += w;
					prev = mag;
				}
				return max(0, 5.0 * accum / tw - 0.7);
			}
			float3 nrand3 (float2 co)
			{
				float3 a = frac(cos(co.x * 8.3e-3 + co.y) * float3(1.3e5, 4.7e5, 2.9e5));
				float3 b = frac(sin(co.x * 0.3e-3 + co.y) * float3(8.1e5, 1.0e5, 0.1e5));
				return lerp(a, b, 0.5);
			}

			half _Param1, _Param2, _Param3, _Param4, _Star;
//			half3 _MoveSpeed;

			half4 LitPassFragment (Varyings input) : SV_Target
			{
				float2 fragCoord = ((input.screenPos.xy) / (input.screenPos.w + FLT_MIN)) * _ScreenParams.xy;
				float2 uv = 2.0 * fragCoord.xy / _ScreenParams.xy - 1.0;
				float2 uvs = uv * _ScreenParams.xy / max(_ScreenParams.x , _ScreenParams.y);
				float3 p = float3(uvs / 4.0, 0) + float3(1.0, -1.3 , 0);

				float3 move = float3(sin(_Time.y / 16.0) , sin(_Time.y / 12.0) , sin(_Time.y / 128.0));
				p += 0.2 * move;
//				p += 0.2*_MoveSpeed * _Time.y;

				float freqs[4];
				freqs[0] = _Param1;
				freqs[1] = _Param2;
				freqs[2] = _Param3;
				freqs[3] = _Param4;

				float t = field(p , freqs[2]);
				float v = (1.0 - exp((abs(uv.x) - 1.0) * 6.0)) * (1.0 - exp((abs(uv.y) - 1.0) * 6.0));

				// second Layer
				float3 p2 = float3(uvs / (4.0 + sin(_Time.y * 0.11) * 0.2 + 0.2 + sin(_Time.y * 0.15) * 0.3 + 0.4) , 1.5) + float3(2.0, -1.3, -1.0);
				p2 += 0.25 * move;
				float t2 = field2(p2 , freqs[3]);
				float4 c2 = lerp(0.4, 1.0, v) * float4 (1.3 * t2 * t2 * t2 , 1.8 * t2 * t2 , t2 * freqs[0] , t2);

				// first star layer
				float2 seed = p.xy * 2.0;
				seed = floor(seed * _ScreenParams.x);
				float f = pow(nrand3(seed).y, _Star);
				float4 starcolor = f;

				// second star layer
				float2 seed2 = p2.xy * 2.0;
				seed2 = floor(seed2 * _ScreenParams.x);
				f = pow(nrand3(seed2).y, _Star);
				starcolor += f;

				half4 c = lerp(freqs[3] - 0.3, 1.0, v) * float4(1.5 * freqs[2] * t * t * t, 1.2 * freqs[1] * t * t, freqs[3] * t, 1.0) + c2 + starcolor;
				return c - 0.1;
			}
			ENDHLSL
		}
	}
	FallBack Off
}