texture background;
float4 color = float4(1,1,1,1);
bool textureLoad;
bool isRelative = false;
float radius = 0.2;
float borderSoft = 0.01;
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
		
	float dx = length(ddx(tex));
	float dy = length(ddy(tex));
	float a = dx/dy;
	float2 nTex = tex;
	float2 center;
	float nRadius = radius/2;
	float aA = borderSoft;
	if(a<=1)
	{
		nTex.x /= a;
		center = float2(0.5/a,0.5);
		aA *= dy*100;
		if(!isRelative)
			nRadius = radius*dy;
	}
	else
	{
		nTex.y *= a;
		a = 1/a;
		center = float2(0.5,0.5/a);
		aA *= dx*100;
		if(!isRelative)
			nRadius = radius*dx;
	}
	float2 fixedPos = abs(nTex-center);
	float2 corner = center-float2(nRadius,nRadius);
	if(fixedPos.x-corner.x >= 0 && fixedPos.y-corner.y >= 0)
	{
		if(distance(fixedPos,corner) > nRadius-aA)
			result.a *= 1-(distance(fixedPos,corner)-nRadius+aA)/aA;
	}
	else
	{
		if(fixedPos.x-corner.x > nRadius-aA)
			result.a *= 1-(fixedPos.x-corner.x-nRadius+aA)/aA;
		else if(fixedPos.y-corner.y > nRadius-aA)
			result.a *= 1-(fixedPos.y-corner.y-nRadius+aA)/aA;
	}
	result = clamp(result,0,1);
	if(!colorOverwritten)
		result.rgb = _color.rgb;
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