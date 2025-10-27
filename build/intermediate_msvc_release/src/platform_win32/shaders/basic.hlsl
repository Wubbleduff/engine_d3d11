
// fxc.exe /nologo /T vs_5_0 /E vs /O3 /WX /Zpc /Ges /Fh src\platform_win32\shaders\basic_vshader.h /Vn basic_vshader /Qstrip_reflect /Qstrip_debug /Qstrip_priv src\platform_win32\shaders\basic.hlsl
// fxc.exe /nologo /T ps_5_0 /E ps /O3 /WX /Zpc /Ges /Fh src\platform_win32\shaders\basic_pshader.h /Vn basic_pshader /Qstrip_reflect /Qstrip_debug /Qstrip_priv src\platform_win32\shaders\basic.hlsl

struct VS_INPUT
{
     float3 pos : POSITION0;
     float3 normal : NORMAL0;
     float2 tex_coord : TEXCOORD0;
     float4 instance_xform0 : POSITION1;
     float4 instance_xform1 : POSITION2;
     float4 instance_xform2 : POSITION3;
     float4 instance_color : COLOR0;
};

struct PS_INPUT
{
    float4 pos   : SV_POSITION;
    float3 normal : NORMAL;
    float4 color : COLOR0;
};

cbuffer cbuffer0 : register(b0)
{
    float4x4 utransform;
}

PS_INPUT vs(VS_INPUT input)
{
    PS_INPUT output;
    float4 res = float4(
        dot(float4(input.pos, 1.0f), input.instance_xform0),
        dot(float4(input.pos, 1.0f), input.instance_xform1),
        dot(float4(input.pos, 1.0f), input.instance_xform2),
        1.0f);
    output.pos = mul(utransform, res);
    output.normal = input.normal;
    output.color = input.instance_color;
    return output;
}

float4 ps(PS_INPUT input) : SV_TARGET
{
    float3 result = float3(0.0f, 0.0f, 0.0f);
    
    float3 basis_r = float3(1.0f, 0.0f, 0.0f);
    float3 basis_g = float3(0.0f, 1.0f, 0.0f);
    float3 basis_b = float3(0.0f, 0.0f, 1.0f);
    
    float3 basis_inv_r = float3(0.0f, 1.0f, 1.0f);
    float3 basis_inv_g = float3(1.0f, 0.0f, 1.0f);
    float3 basis_inv_b = float3(1.0f, 1.0f, 0.0f);
    
    result += input.normal.x >= 0.0f ? input.normal.x * basis_r : -input.normal.x * basis_inv_r;
    result += input.normal.y >= 0.0f ? input.normal.y * basis_g : -input.normal.y * basis_inv_g;
    result += input.normal.z >= 0.0f ? input.normal.z * basis_b : -input.normal.z * basis_inv_b;

    return float4(result, 1.0f);
}
