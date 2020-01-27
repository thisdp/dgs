

float4 poop(float2 tex:TEXCOORD0,float4 color:COLOR0):COLOR0
{
	color.r = 
	return color;
}

technique nSlice
{
	pass p0
	{
		PixelShader = compile ps_2_0 poop();
	}
}