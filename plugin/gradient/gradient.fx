bool textureLoad = false;
bool textureRotated = false;
texture sourceTexture;
float rotation = 0;
float4 colorFrom = float4(1,1,1,1);
float4 colorTo = float4(1,1,1,1);
bool colorOverwritten = true;
#define PI 3.1415926535897932384626433832795

SamplerState tSampler{
	Texture = sourceTexture;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
};

float4 gradientShader(float2 tex:TEXCOORD0,float4 color:COLOR0):COLOR0{
	float4 result = textureLoad?tex2D(tSampler,textureRotated?tex.yx:tex)*color:color;
	float rad = rotation/180*PI;
	float rotSin = sin(rad);
	float rotCos = cos(rad);
	tex -= 0.5;
	float2 kValue = float2(tex.x*rotCos-tex.y*rotSin,tex.x*rotSin+tex.y*rotCos)+0.5;
	float4 colorCalculated = colorFrom+(colorTo-colorFrom)*(kValue.x);
	result.rgb = colorOverwritten?colorCalculated.rgb:(colorCalculated.rgb*result.rgb);
	result.a *= colorCalculated.a;
	return result;
}

technique Gradient{
	pass P0{
		SeparateAlphaBlendEnable = true;
		SrcBlendAlpha = One;
		DestBlendAlpha = InvSrcAlpha;
		PixelShader = compile ps_2_0 gradientShader();
	}
}