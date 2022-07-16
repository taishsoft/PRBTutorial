Shader "PBRLearn/LQPBR"
{
    Properties
    {
       _Color("Color",Color) = (1, 1, 1, 1)
       _Albedo("Albedo", 2D) = "white" {}
       _MetalMap("MetalMap", 2D) = "white" {}
       _Metallic("Metallic", Range(0.01, 1)) = 0.5
       _Roughness("Roughness", Range(0.01, 0.99)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags {"LightMode" = "CustomLit"}
           
            HLSLPROGRAM
            #pragma vertex VertLitpass
            #pragma fragment FragLitpass
            #include "LQPBR.hlsl"
            ENDHLSL
        }
    }
}