float items = 2;
float4 currentColor = float4(1,0,0,1);
bool vertical = false;
bool isReversed = false;
bool useMaskTexture = false;
texture maskTexture;

SamplerState maskSampler{
	Texture = maskTexture;
};

float4 AlphaComponent(float2 otex:TEXCOORD0,float4 color:COLOR0):COLOR0{
	float dxdy = ddx(otex.x)/ddy(otex.y);
	float2 ddxddy = float2(dxdy,1/dxdy);
	float _x = otex[vertical];
	float _y = otex[!vertical];
	float2 tex = float2(_x,_y);
	tex *= items;
	tex.y *= ddxddy[vertical];
	color.rgb = floor(tex.x)%2 +floor(tex.y)%2 == 1;
	_y = isReversed?(1-_y):_y;
	float4 newColor = color*(1-_y)+currentColor*_y;
	color.rgb = newColor.rgb;
	float3 _maskRGB = tex2D(maskSampler,tex).rgb;
	color.a *= useMaskTexture?((_maskRGB.r+_maskRGB.g+_maskRGB.b)/3):1;
	return color;
}

float4 ComponentMask(float2 tex,float4 color){
	float3 _maskRGB = tex2D(maskSampler,tex).rgb;
	color.a *= (_maskRGB.r+_maskRGB.g+_maskRGB.b)/3;
	return color;
}

float4 Main(float2 tex:TEXCOORD0,float4 color:COLOR0):COLOR0{
	color = AlphaComponent(tex,color);
	if(useMaskTexture)
		color = ComponentMask(tex,color);
	return color;
}

technique RepTexture{
	pass P0{
		SeparateAlphaBlendEnable = true;
		SrcBlendAlpha = One;
		DestBlendAlpha = InvSrcAlpha;
		PixelShader = compile ps_2_a Main();
	}
}
