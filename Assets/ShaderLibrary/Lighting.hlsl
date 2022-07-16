#ifndef CUSTOM_LIGHTING_INCLUDED
#define CUSTOM_LIGHTING_INCLUDED

#include "CommonInput.hlsl"


half4 SampleSH9(float3 normalWS)
{
    float4 SHCoefficients[9] =
    {
//        float4(0.362900, 0.725464, 1.169736, 3.544921),
//float4(0.165027, 0.186175, 0.208289, 0.000000),
//float4(-0.023774, 0.194598, 0.739864, 0.000000),
//float4(0.027626, 0.026818, 0.030290, 0.009399),
//float4(0.091269, 0.120028, 0.100931, 0.000000),
//float4(0.064432, 0.094926, 0.082192, 0.000000),
//float4(-0.229041, -0.369822, -0.353421, 0.015537),
//float4(0.027535, 0.032141, 0.027392, 0.000000),
//float4(-0.143243, -0.159878, -0.115496, 0.008920)

        float4(0.302530, 0.259531, 0.235033, 3.544921),
        float4(-0.038835, -0.039388, -0.040695, 0.000000),
        float4(-0.026369, -0.012100, -0.012399, 0.000000),
        float4(-0.151382, -0.137018, -0.128331, 0.009399),
        float4(0.013492, 0.015854, 0.017712, 0.000000),
        float4(-0.003879, -0.008172, -0.007177, 0.000000),
        float4(0.031031, 0.031704, 0.035607, 0.015537),
        float4(-0.021719, -0.028778, -0.028867, 0.000000),
        float4(0.086761, 0.078513, 0.072939, 0.008920)
    };

    float3 d = float3(normalWS.x, normalWS.z, normalWS.y);
    half4 color =
        SHCoefficients[0] * GetY00(d) +
        SHCoefficients[1] * GetY1n1(d) +
        SHCoefficients[2] * GetY10(d) +
        SHCoefficients[3] * GetY1p1(d) +
        SHCoefficients[4] * GetY2n2(d) +
        SHCoefficients[5] * GetY2n1(d) +
        SHCoefficients[6] * GetY20(d) +
        SHCoefficients[7] * GetY2p1(d) +
        SHCoefficients[8] * GetY2p2(d);

    return color;
}

#endif