texture screenSource;
float intensity = 1.0f; // 模糊强度
float brightness = 1.0f; // 亮度

sampler2D Sampler0 = sampler_state{
    Texture  = (screenSource);
    AddressU = Mirror;
    AddressV = Mirror;
};

float4 BlurFunction(float2 tex : TEXCOORD0, float4 diffuse : COLOR0) : COLOR0 {
    float4 color = float4(0.0f, 0.0f, 0.0f, 0.0f);
    float2 dx = ddx(tex);
    float2 dy = ddy(tex);
    float2 dd = float2(length(float2(dx.x, dy.x)), length(float2(dx.y, dy.y)));

    float weight = 0;
    float4 sampled = 0;
    for (float i = -MACRO_Level; i <= MACRO_Level; i++) {
#ifdef MACRO_IsHorizontal
        sampled = tex2D(Sampler0, float2(tex.x + i * intensity * dd.x, tex.y));
#else
        sampled = tex2D(Sampler0, float2(tex.x, tex.y + i * intensity * dd.y));
#endif
        weight = (1.0f - abs(i / MACRO_Level)) / MACRO_Level * brightness * sampled.a;
        color.rgb += sampled.rgb * weight;
        color.a += weight;
    }
    color.rgb /= color.a;
    return color * diffuse;
}

technique fxBlur {
    pass P0 {
        PixelShader = compile ps_2_a BlurFunction();
    }
}