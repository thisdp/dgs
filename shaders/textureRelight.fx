#include "mta-helper.fx"

texture gTexture;

SamplerState mySampler
{
	Texture = gTexture;
};

struct VSInput
{
	float4 Position : POSITION0;
	float4 Diffuse : COLOR0;
	float2 TexCoord : TEXCOORD0;
};

struct PSInput
{
	float4 Position : POSITION0;
	float4 Diffuse : COLOR0;
	float2 TexCoord : TEXCOORD0;
};

PSInput myVertexShader (VSInput VS)
{
	PSInput PS = (PSInput)0;
	float4 pos = VS.Position;
	PS.TexCoord = VS.TexCoord;
	PS.Position=mul(pos,gWorldViewProjection);
	PS.Diffuse = VS.Diffuse;
	return PS;
}

float4 myPixelShader (PSInput input) : COLOR0
{
	float4 color = tex2D(mySampler,input.TexCoord);
	return color*input.Diffuse;
};

technique TexReplace
{
	pass P0
	{
		VertexShader = compile vs_2_0 myVertexShader();
		PixelShader = compile ps_2_0 myPixelShader();
	}
}


