#ifndef LQPBR_INCLUDED
#define LQPBR_INCLUDED

#include "HLSLSupport.cginc"

#include "../ShaderLibrary/Light.hlsl"
#include "../ShaderLibrary/SpaceTransform.hlsl"
#include "../ShaderLibrary/BRDF.hlsl"
#include "../ShaderLibrary/Lighting.hlsl"

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
UNITY_DECLARE_TEX2D(_BRDFLUT);

samplerCUBE _IBLSpec;

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

	//间接光漫反射，实现方式：SH
	//由于环境光没有固定的入射方向，因此使用法向量来代替半角向量进行计算
	half NoV = saturate(dot(normalWS, viewDir));
	half3 indirectColor = 0;
	half3 indirectDiffuse = SampleSH9(normalWS) * RCP_PI * albedo * _Color;
	half3 ks = FresnelTerm_Roughness(brdfData.f0, NoV, brdfData.roughness);
	half3 kd = (1 - ks) * (1 - brdfData.metallic);
	indirectColor += kd * indirectDiffuse;

	//ibl镜面反射
	float3 reflectDir = reflect(-viewDir, normalWS);

	half mip = PerceptualRoughnessToMipmapLevel(brdfData.perceptualRoughness);
	float3 prefilteredColor = texCUBElod(_IBLSpec, float4(reflectDir, mip)).rgb;

	//float3 prefilteredColor = texCUBElod(_IBLSpec, float4(reflectDir, brdfData.perceptualRoughness * 12)).rgb;
	float4 scaleBias = UNITY_SAMPLE_TEX2D(_BRDFLUT, float2(NoV, brdfData.perceptualRoughness));
	half3 indirectSpec = BRDFIBLSpec(brdfData, scaleBias.xy) * prefilteredColor;
	indirectColor += indirectSpec;

	color += indirectColor;

	return half4(color, 1);
}

#endif