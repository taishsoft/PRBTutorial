#ifndef CUSTOM_COMMON_INPUT_INCLUDED
#define CUSTOM_COMMON_INPUT_INCLUDED

//Unity内置变量
float4x4 unity_MatrixVP;
float3 _WorldSpaceCameraPos;

CBUFFER_START(UnityPerDraw)
float4x4 unity_ObjectToWorld;
float4x4 unity_WorldToObject;
CBUFFER_END

#define TRANSFORM_TEX(tex, name) ((tex.xy) * name##_ST.xy + name##_ST.zw)

#define PI 3.1415926
static float RCP_PI = rcp(PI);

#endif