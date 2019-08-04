texture background;
float4 color = float4(1,1,1,1);
bool textureLoad;
float radius = 0.5;
float borderSoft = 0.009;
bool colorOverwritten = true;

SamplerState tSampler
{
	Texture = background;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
	AddressU = Wrap;
	AddressV = Wrap;
};

float4 rndRect(float2 tex: TEXCOORD0, float4 _color : COLOR0):COLOR0
{
	float4 result;
	if(textureLoad)
		result = tex2D(tSampler,tex)*color;
	else
		result = color;
	float a = ddx(tex.x)/ddy(tex.y);
	float2 nTex = tex;
	nTex.x /= a;
	float2 center = float2(0.5/a,0.5);
	float2 fixedPos = abs(nTex-center);
	float nRadius = radius/2;
	float2 corner = center-float2(nRadius,nRadius);
	if(fixedPos.x-corner.x >= 0 && fixedPos.y-corner.y >= 0)
	{
		if(distance(fixedPos,corner) > nRadius-borderSoft)
			result.a *= 1-(distance(fixedPos,corner)-nRadius+borderSoft)/borderSoft;
	}
	else
	{
		if(fixedPos.x-corner.x > nRadius-borderSoft)
			result.a *= 1-(fixedPos.x-corner.x-nRadius+borderSoft)/borderSoft;
		else if(fixedPos.y-corner.y > nRadius-borderSoft)
			result.a *= 1-(fixedPos.y-corner.y-nRadius+borderSoft)/borderSoft;
	}
	result = clamp(result,0,1);
	result.rgb *= colorOverwritten ? 1 : _color.rgb;
	result.a *= _color.a;
	return result;
	
}

technique rndRectTech
{
	pass P0
	{
		PixelShader = compile ps_2_a rndRect();
	}
}