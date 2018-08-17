texture gTexture;

sampler mySampler = sampler_state
{
	Texture = gTexture;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
	AddressU = Wrap;
	AddressV = Wrap;
};

struct PS_INPUT
{
	float2 base : TEXCOORD0;
	float4 diffuse : COLOR0;
};

struct PS_OUTPUT
{
	vector color : COLOR0;
};

PS_OUTPUT myShader (PS_INPUT input)
{
	PS_OUTPUT PS = (PS_OUTPUT)0;
	vector color = tex2D(mySampler,input.base);
	PS.color = color-input.diffuse;
	return PS;
};

technique TexReplace
{
	pass P0
	{
		PixelShader = compile ps_2_0 myShader();
	}
}