float radius = 0.4;
float width = 0.1;
float borderSoft = 0.05;
float color = float4(1,1,1,1);

float4 circle(float2 tex : TEXCOORD0, float4 __color : COLOR0) : COLOR0
{
	float4 _color = color;
	float dis = distance(tex,0.5);
	float halfBorderSoft = borderSoft*0.5;
	_color.a *= (width-abs(dis-radius))/borderSoft;
	_color.a = clamp(_color.a,0,1)*__color.a;
	return _color;
}

technique RepTexture
{
	pass P0
	{
		PixelShader = compile ps_2_0 circle();
	}
}
