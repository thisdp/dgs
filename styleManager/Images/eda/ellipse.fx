float4 tcolor = float4(1,1,1,1);
float2 ab = float2(0.5,0.5);
float atali = 0.1;
float4 myShader(float2 tex : TEXCOORD0) : COLOR0
{
	float4 color = tcolor;
	float dis = pow((tex.x-0.5)/ab.x,2)+pow((tex.y-0.5)/ab.y,2);
	if(dis > 1)
		color = 0;
	return color;
}

technique DrawCircle
{
	pass P0
	{
		PixelShader = compile ps_2_0 myShader();
	}
}
