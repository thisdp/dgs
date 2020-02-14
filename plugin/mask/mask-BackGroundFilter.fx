texture sourceTexture;
float3 filterRGB = 0;
float filterRange = 0.05;
bool isPixelated = false;

SamplerState sourceSampler
{
	Texture = sourceTexture;
	MinFilter = 2;
	MagFilter = 2;
	MipFilter = 2;
	AddressU = Wrap;
	AddressV = Wrap;
};


SamplerState sourceSamplerPixelated
{
	Texture = sourceTexture;
	MinFilter = 1;
	MagFilter = 1;
	MipFilter = 1;
	AddressU = Wrap;
	AddressV = Wrap;
};

float4 maskBGFilter(float2 tex:TEXCOORD0,float4 _color:COLOR0):COLOR0
{
	float4 sampledTexture = isPixelated?tex2D(sourceSamplerPixelated,tex):tex2D(sourceSampler,tex);
	float diffRGB = distance(sampledTexture.rgb,filterRGB);
	sampledTexture.a *= (diffRGB-filterRange)/filterRange;
	return sampledTexture*_color;
}

technique maskTech
{
	pass P0
	{
		PixelShader = compile ps_2_0 maskBGFilter();
	}
}