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

//==============直角坐标系下的3阶球谐函数============//
//l = 0,m = 0
float GetY00(float3 xyz)
{
    return 0.5 * sqrt(RCP_PI);
}

//l = 1,m = 0
float GetY10(float3 p)
{
    return 0.5 * sqrt(3 * RCP_PI) * p.z;
}

//l = 1,m = 1
float GetY1p1(float3 p)
{
    return 0.5 * sqrt(3 * RCP_PI) * p.x;
}

//l = 1,m = -1
float GetY1n1(float3 p)
{
    return 0.5 * sqrt(3 * RCP_PI) * p.y;
}

//l = 2, m = 0
float GetY20(float3 p)
{
    return 0.25 * sqrt(5 * RCP_PI) * (2 * p.z * p.z - p.x * p.x - p.y * p.y);
}

//l = 2, m = 1
float GetY2p1(float3 p)
{
    return 0.5 * sqrt(15 * RCP_PI) * p.z * p.x;
}

//l = 2, m = -1
float GetY2n1(float3 p)
{
    return 0.5 * sqrt(15 * RCP_PI) * p.z * p.y;
}

//l = 2, m = 2
float GetY2p2(float3 p)
{
    return 0.25 * sqrt(15 * RCP_PI) * (p.x * p.x - p.y * p.y);
}

//l = 2, m = -2
float GetY2n2(float3 p)
{
    return 0.5 * sqrt(15 * RCP_PI) * p.x * p.y;
}

#endif