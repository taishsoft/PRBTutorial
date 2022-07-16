#ifndef CUSTOM_SPACE_TRANSFORM_INCLUDED
#define CUSTOM_SPACE_TRANSFORM_INCLUDED

#include "CommonInput.hlsl"

#define UNITY_MATRIX_M     unity_ObjectToWorld
#define UNITY_MATRIX_I_M   unity_WorldToObject
#define UNITY_MATRIX_VP    unity_MatrixVP

//模型空间到世界空间
float3 TransformObjectToWorld(float3 positionOS)
{
    return mul(UNITY_MATRIX_M, float4(positionOS, 1.0)).xyz;
}

//世界空间到裁剪空间
float4 TransformWorldToHClip(float3 positionWS)
{
    return mul(UNITY_MATRIX_VP, float4(positionWS, 1.0));
}

//法线转换到世界空间，注意要乘以逆转置矩阵
float3 TransformObjectToWorldNormal(float3 normalOS, bool doNormalize = true)
{
    float3 normalWS = mul(normalOS, (float3x3)UNITY_MATRIX_I_M);
    if (doNormalize)
        return normalize(normalWS);

    return normalWS;
}

#endif