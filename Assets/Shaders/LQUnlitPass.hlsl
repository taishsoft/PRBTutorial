#ifndef CUSTOM_UNLIT_PASS_INCLUDED
#define CUSTOM_UNLIT_PASS_INCLUDED

#include "HLSLSupport.cginc"
#include "../ShaderLibrary/SpaceTransform.hlsl"

UNITY_DECLARE_TEX2D(_MainTex);

CBUFFER_START(UnityPerMaterial)
float4 _Color;
float4 _MainTex_ST;
CBUFFER_END

struct Attributes
{
	float3 positionOS : POSITION;
	float2 baseUV : TEXCOORD0;
};

struct Varyings
{
	float4 positionCS : SV_POSITION;
	float2 baseUV : VAR_BASE_UV;
};

Varyings UnlitPassVertex(Attributes input)
{
	Varyings output;
	float3 positionWS = TransformObjectToWorld(input.positionOS);
	output.positionCS = TransformWorldToHClip(positionWS);
	output.baseUV = TRANSFORM_TEX(input.baseUV, _MainTex);
	return output;
}

float4 UnlitPassFragment(Varyings input) : SV_TARGET
{
	float4 baseMap = UNITY_SAMPLE_TEX2D(_MainTex, input.baseUV);
	float4 base = baseMap * _Color;
	return base;
}

#endif