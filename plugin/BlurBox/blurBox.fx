texture screenSource;
float intensity = 1;
float brightness = 1;

sampler2D Sampler0 = sampler_state{
    Texture  = screenSource;
    AddressU = Mirror;
    AddressV  = Mirror;
};

float4 BlurFunction( float2 tex : TEXCOORD0, float4 diffuse : COLOR0 ) : COLOR0{
    float4 Color = 0;
    float2 dx = ddx(tex);
    float2 dy = ddy(tex);
    float2 dd = float2(length(float2(dx.x,dy.x)),length(float2(dx.y,dy.y)));
#ifdef MACRO_IsHorizontal
    for(float i = -MACRO_Level; i <= MACRO_Level; i++)
        Color += tex2D(Sampler0,float2(tex.x+i*intensity*dd.x,tex.y))*(1-abs(i/MACRO_Level))/MACRO_Level*brightness;
#else
    for(float i = -MACRO_Level; i <= MACRO_Level; i++)
        Color += tex2D(Sampler0,float2(tex.x,tex.y+i*intensity*dd.y))*(1-abs(i/MACRO_Level))/MACRO_Level*brightness;
#endif
    return Color*diffuse;
}

technique fxBlur{
    pass P0{
        PixelShader = compile ps_2_a BlurFunction();
    }
}