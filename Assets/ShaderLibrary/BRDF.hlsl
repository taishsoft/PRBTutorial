#ifndef CUSTOM_BRDF_INCLUDED
#define CUSTOM_BRDF_INCLUDED

#define kDieletricSpec half4(0.04, 0.04, 0.04, 1.0 - 0.04) //standard dielectric reflectivity coef at incident angle (= 4%)
#define INV_PI 0.31830989161357

struct BRDFData
{
	half perceptualRoughness;	//感性粗糙度
	half metallic;				//金属度
	half3 albedo;				//反照率
	half roughness;				//粗糙度=perceptualRoughness^2
	half roughness2;			//roughness^2
	half f0;					//菲涅尔f0
};

half PerceptualRoughnessToRoughness(half perceptualRoughness)
{
	return perceptualRoughness * perceptualRoughness;
}

//初始化BRDF数据，这里直接参考了URP中的部分代码
void InitializeBRDFData(half3 albedo, half metallic, half roughness, out BRDFData outBRDFData)
{
	outBRDFData.perceptualRoughness = roughness;
	outBRDFData.metallic = metallic;
	outBRDFData.albedo = albedo;
	outBRDFData.roughness = PerceptualRoughnessToRoughness(roughness);
	outBRDFData.roughness2 = outBRDFData.roughness * outBRDFData.roughness;
	outBRDFData.f0 = lerp(kDieletricSpec.rgb, albedo, metallic);
}

//使用Trowbridge-Reitz法线分布函数
half DistributionTerm(half NoH, half roughness)
{
	half a2 = roughness * roughness;
	half nh2 = NoH * NoH;
	half d = nh2 * (a2 - 1) + 1.00001f;
	return a2 / (d * d);	//pi的优化
	//return a2 * INV_PI / (d * d);
}

//几何遮蔽，使用UE的方案Schlick-GGX，基于Schlick近似，k = a/2，a = (roughness + 1)^2 / 4
//即k = (roughness + 1)^2 / 8
//分子的nl和nv可以和公式中分母约掉，这里暂不优化处理
half GeometryTerm(half roughness, half NoL, half NoV)
{
	half k = pow(roughness + 1, 2) / 8;
	half G1 = NoL / lerp(NoL, 1, k);
	half G2 = NoV / lerp(NoV, 1, k);
	half G = G1 * G2;
	return G;
}

//菲涅尔项使用Schlick
half3 FresnelTerm(half3 f0, half VoH)
{
	return f0 + (1 - f0) * pow(1 - VoH, 5);
}

//计算直接光BRDF部分（漫反射 + 镜面反射）
half3 DirectBRDF(BRDFData brdfData, half3 normalWS, half3 lightDirectionWS, half3 viewDirectionWS)
{
	half3 halfDir = normalize(lightDirectionWS + viewDirectionWS);
	half NoH = max(saturate(dot(normalWS, halfDir)), 0.000001);
	half LoH = max(saturate(dot(lightDirectionWS, halfDir)), 0.000001);
	half NoL = max(saturate(dot(normalWS, lightDirectionWS)), 0.000001);//防止除0
	half NoV = max(saturate(dot(normalWS, viewDirectionWS)), 0.000001);
	half VoH = max(saturate(dot(viewDirectionWS, halfDir)), 0.000001);

	half D = DistributionTerm(NoH, brdfData.roughness);
	half G = GeometryTerm(brdfData.roughness, NoL, NoV);
	half3 F = FresnelTerm(brdfData.f0, VoH);

	//这里NoL会有0的情况发生，所以上面对NoL进行了max
	half3 specularTerm = (D * G * F) / (NoV * NoL * 4);
	half3 ks = F;
	half3 kd = (1 - ks) * (1 - brdfData.metallic);

	return kd * brdfData.albedo + specularTerm;//pi的优化
	//return kd * INV_PI * brdfData.albedo + specularTerm;
}

#endif