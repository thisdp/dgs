texture screenSource;

sampler2D Sampler0 = sampler_state
{
    Texture         = screenSource;
    MinFilter       = Linear;
    MagFilter       = Linear;
    MipFilter       = Linear;
    AddressU        = Mirror;
    AddressV        = Mirror;
};

float4 PixelShaderFunction(float2 tex : TEXCOORD0, float4 diffuse : COLOR0 ) : COLOR0
{
    float4 Color = 0;
    float4 Texel = tex2D(Sampler0,tex);
    for(int i = -5; i <= 5; i++)
		for(int j = -5; j <= 5; j++)
			Color += tex2D(Sampler0,tex+float2(i*ddx(tex.x),j*ddy(tex.y))) *(1.0/121.0);
    return Color*diffuse;
}

technique fxBlur
{
    pass P0
    {
        PixelShader  = compile ps_2_a PixelShaderFunction();
    }
}

