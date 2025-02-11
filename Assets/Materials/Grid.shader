Shader "URP/Custom/Grid" {
    Properties {
        _LineColor ("Line Color", Color) = (1,1,1,0.5)
        _BaseColor ("Base Color", Color) = (0,0,0,0.1)
        _Spacing ("Spacing", Float) = 1
        _LineWidth ("Line Width", Range(0,1)) = 0.1
        _NumSteps ("Steps", Range(1,8)) = 1
        _StepFade ("Step Fade", Range(0,1)) = 0.1
        _Radius ("Radius", Range(0,1)) = 5
        _Fade ("Fade", Range(0,1)) = 1

        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

        _MainTex ("Main Texture", 2D) = "white" {}
    }

    SubShader {
        Tags {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
        }
        LOD 200

        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off
        ZWrite Off

        Pass {
            Name "GridPass"
            HLSLPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 _LineColor;
            float4 _BaseColor;
            float _Spacing;
            float _LineWidth;
            float _Radius;
            float _Fade;
            float _NumSteps;
            float _StepFade;

            float _Glossiness;
            float _Metallic;

            Varyings vert(Attributes IN) {
                Varyings OUT;
                OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                return OUT;
            }

            // float Remap(float value, float inMin, float inMax, float outMin, float outMax) {
            //     return saturate((value - inMin) / (inMax - inMin)) * (outMax - outMin) + outMin;
            // }

            half4 frag(Varyings IN) : SV_Target {
                float2 relXY = abs(float2(IN.uv.x - 0.5, IN.uv.y - 0.5));
                float dist = length(relXY);

                // Clip outside the radius
                clip(_Radius - dist);

                float4 col = _BaseColor;


                // Grid Lines with Step Scaling
                int numSteps = pow(2, _NumSteps - 1);
                int stepIndex = 0;

                for (int i = 1; i <= numSteps; i *= 2) {
                    float spacing = _Spacing / i;
                    float lineWidth = _LineWidth;
                    float2 modUV = fmod(relXY.xy, spacing) / spacing;

                    if (modUV.x < lineWidth / 2 || modUV.y < lineWidth / 2 || 
                        modUV.x > 1 - lineWidth / 2 || modUV.y > 1 - lineWidth / 2) {
                        col = _LineColor;
                        col.a -= stepIndex * _StepFade;
                        break;
                    }
                    stepIndex++;
                }

                // Edge Fade
                if (_Fade > 0) {
                    float fadeRadius = _Radius - _Fade;
                    col.a *= clamp(1-dist*_Fade*10, 0, 1);
                }

                
                return col;
            }
            ENDHLSL
        }
    }
}
