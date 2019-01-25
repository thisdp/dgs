float antiAliased = 0.02;
float radius = 0;
float2 circlePos = float2(0.5,0.5);
float4 baseColor = float4(0.5,0.5,0.5,1);
float4 focusColor = float4(0,0.4,0.8,1);
float2 UVPos = float2(0,0);
float2 UVSize = float2(1,1);
float ratio = 2;

float4 myShader(float2 tex : TEXCOORD0) : COLOR0
{
	float2 UVScaler = UVPos+float2(tex.x*UVSize.x,tex.y*UVSize.y);
	float4 color = focusColor;
	float2 texPosScaler = float2((tex.x-circlePos.x)*ratio,(tex.y-circlePos.y));
	float dis = texPosScaler.x*texPosScaler.x+texPosScaler.y*texPosScaler.y;
	color = focusColor+(baseColor-focusColor)*clamp((dis-radius+antiAliased)/antiAliased/radius,0,1);
	return color;
}

technique DrawCircle
{
	pass P0
	{
		PixelShader = compile ps_2_0 myShader();
	}
}
