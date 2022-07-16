Shader "PBRLearn/LQUnlit"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
		Pass
		{
			Tags {"LightMode" = "CustomUnLit"}

			HLSLPROGRAM
			#pragma target 3.5
			#pragma vertex UnlitPassVertex
			#pragma fragment UnlitPassFragment
			#include "LQUnlitPass.hlsl"
			ENDHLSL
		}
    }
}