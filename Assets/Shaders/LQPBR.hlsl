#ifndef LQPBR_INCLUDED
#define LQPBR_INCLUDED

#include "HLSLSupport.cginc"

#include "../ShaderLibrary/Light.hlsl"
#include "../ShaderLibrary/SpaceTransform.hlsl"
#include "../ShaderLibrary/BRDF.hlsl"

struct Attributes
{
	float3 positionOS : POSITION;
	float3 normalOS : NORMAL;
	float2 baseUV : TEXCOORD0;
};

struct Varyings
{
	float2 baseUV : TEXCOORD0;
	float4 positionCS : SV_POSITION;
	float3 positionWS : VAR_POSITION;
	float3 normalWS : VAR_NORMAL;
};

UNITY_DECLARE_TEX2D(_Albedo);
UNITY_DECLARE_TEX2D(_MetalMap);

CBUFFER_START(UnityPerMaterial)
half4 _Color;
float _Metallic;
float _Roughness;
float4 _Albedo_ST;
CBUFFER_END

Varyings VertLitpass(Attributes input)
{
	Varyings output;

	output.positionWS = TransformObjectToWorld(input.positionOS);
	output.positionCS = TransformWorldToHClip(output.positionWS);
	output.normalWS = TransformObjectToWorldNormal(input.normalOS);
	output.baseUV = TRANSFORM_TEX(input.baseUV, _Albedo);

	return output;
}

half4 FragLitpass(Varyings input) : SV_Target
{
	half4 albedo = UNITY_SAMPLE_TEX2D(_Albedo, input.baseUV);
	half4 metallicInfo = UNITY_SAMPLE_TEX2D(_MetalMap, input.baseUV);

	half3 normalWS = normalize(input.normalWS);
	half3 positionWS = input.positionWS;
	half3 viewDir = normalize(_WorldSpaceCameraPos - positionWS);

	//直接光
	half roughness = 1 - metallicInfo.a * (1 - _Roughness);//MetalMap的alpha通道保存的是光滑度
	BRDFData brdfData;
	InitializeBRDFData((albedo* _Color).rgb, metallicInfo.r* _Metallic, roughness, brdfData);
	Light light = GetDirectionalLight();
	half NoL = saturate(dot(normalWS, light.direction));
	half3 irradiance = NoL * light.color;//pi的优化
	//half3 irradiance = PI * NoL * light.color;
	half3 color = DirectBRDF(brdfData, normalWS, light.direction, viewDir) * irradiance;

	return half4(color, 1);
}

#endif