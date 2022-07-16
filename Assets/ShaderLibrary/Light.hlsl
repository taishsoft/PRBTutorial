#ifndef CUSTOM_LIGHT_INCLUDED
#define CUSTOM_LIGHT_INCLUDED

CBUFFER_START(_CustomLight)
	float4 _DirectionalLightColor;
	float4 _DirectionalLightDirection;
CBUFFER_END

struct Light
{
	float3 color;
	float3 direction;
};

Light GetDirectionalLight()
{
	Light light;
	light.color = _DirectionalLightColor.rgb;
	light.direction = _DirectionalLightDirection.xyz;
	return light;
}

#endif