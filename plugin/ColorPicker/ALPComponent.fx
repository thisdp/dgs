float items = 2;
float4 currentColor = float4(1,0,0,1);
bool vertical = false;
bool isReversed = false;

float4 alpChannel(float2 otex:TEXCOORD0,float4 color:COLOR0):COLOR0{
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
	return color;
}

technique RepTexture{
	pass P0{
		PixelShader = compile ps_2_a alpChannel();
	}
}
