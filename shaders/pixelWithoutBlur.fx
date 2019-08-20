#include "mta-helper.fx"

texture gTexture;

SamplerState mySampler
{
	Texture = gTexture;
};

float4 myPixelShader ( float2 tex : TEXCOORD0 ) : COLOR0
{
	float4 color = tex2D(mySampler,tex);
	return color;
};

technique TexReplace
{
	pass P1
	{
		PixelShader = compile ps_2_0 myPixelShader();
	}
}


