Shader "Custom/PS1"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color Base", Color) = (1,1,1,1)
        
        _Ka ("Ambient", Color) = (0.4, 0.4, 0.4, 1.0)
        _Kd ("Diffuse", Color) = (0.8, 0.8, 0.8, 1.0)
        _Ks ("Specular", Color) = (0.5, 0.5, 0.5, 1.0)
        _Shininess ("Shininess", Range(1, 128)) = 32.0
        
        _VertexSnapAmount ("Vertex Snap Amount", Range(0, 1)) = 0.05
        _AffineMapping ("Affine Texture Mapping", Range(0, 1)) = 1.0
        _ColorDepth ("Color Depth (bits)", Range(1, 32)) = 5
        _PixelSize ("Pixel Size", Range(1, 10)) = 4
        _Dithering ("Dithering Intensity", Range(0, 1)) = 0.5
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" }
        
        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode"="UniversalForward" }
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            
            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };
            
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                nointerpolation float3 color : COLOR0;
                float2 uv : TEXCOORD0;
                float4 screenPos : TEXCOORD1;
                nointerpolation float depth : TEXCOORD2;
            };
            
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            
            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float4 _Color;
                float4 _Ka;
                float4 _Kd;
                float4 _Ks;
                float _Shininess;
                float _VertexSnapAmount;
                float _AffineMapping;
                float _ColorDepth;
                float _PixelSize;
                float _Dithering;
            CBUFFER_END
            
            static const float4x4 bayerMatrix = float4x4(
                0, 8, 2, 10,
                12, 4, 14, 6,
                3, 11, 1, 9,
                15, 7, 13, 5
            );
            
            float GetBayerValue(float2 screenPos)
            {
                int2 p = int2(screenPos) & 3;
                return bayerMatrix[p.y][p.x] / 16.0;
            }
            
            float3 PhongShading(float3 N, float3 L, float3 V, Light light)
            {
                float3 ambient = _Ka.rgb * light.color * 2.0;
                float NdotL = max(0, dot(N, L));
                float3 diffuse = NdotL * _Kd.rgb * light.color;
                
                float3 H = normalize(L + V);
                float spec = pow(max(dot(N, H), 0), _Shininess);
                float3 specular = spec * _Ks.rgb * light.color;
                
                return ambient + diffuse + specular;
            }
            
            float4 SnapToGrid(float4 pos, float amount)
            {
                float4 p = pos;
                p.xyz /= p.w;
                float grid = amount * 100;
                p.xy = floor(p.xy * grid) / grid;
                p.xyz *= pos.w;
                return p;
            }
            
            Varyings vert(Attributes input)
            {
                Varyings output;
                
                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS);
                
                output.positionCS = vertexInput.positionCS;
                output.depth = output.positionCS.w;
                
                if (_VertexSnapAmount > 0)
                    output.positionCS = SnapToGrid(output.positionCS, _VertexSnapAmount);
                
                output.screenPos = ComputeScreenPos(output.positionCS);
                
                output.uv = TRANSFORM_TEX(input.uv, _MainTex);
                output.uv *= lerp(1.0, output.depth, _AffineMapping);
                
                float3 N = normalize(normalInput.normalWS);
                float3 V = normalize(GetWorldSpaceViewDir(vertexInput.positionWS));
                
                // Luz base ambiente
                float3 lighting = _Ka.rgb * 0.5;
                
                //LUZ DIRECCIONAL PRINCIPAL
                Light mainLight = GetMainLight();
                lighting += PhongShading(N, normalize(mainLight.direction), V, mainLight);
                
                output.color = lighting;
                
                return output;
            }
            
            half4 frag(Varyings input) : SV_Target
            {
                float2 screenUV = input.screenPos.xy / input.screenPos.w;
                float2 uv = input.uv / lerp(1.0, input.depth, _AffineMapping);
                
                // Pixeles
                float2 texel = max(fwidth(uv) * _PixelSize, 0.0001);
                uv = floor(uv / texel) * texel;
                
                float4 tex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
                float3 color = tex.rgb * input.color * _Color.rgb;
                
                // Dithering y cuantizacion
                float d = GetBayerValue(screenUV * _ScreenParams.xy);
                float levels = pow(2, _ColorDepth);
                color += (d - 0.5) * _Dithering / levels;
                color = floor(color * levels) / levels;
                
                return half4(color, tex.a * _Color.a);
            }
            ENDHLSL
        }
    }
    
    FallBack "Diffuse"
}