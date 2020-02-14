bool vertical = false;
float3 HSL = float3(0,0,0);
float3 HSL_Chg = float3(0,0,0);
float3 defHSL = float3(0,1,0.5);
float3 StaticMode = float3(1,1,1);
bool isReversed = false;

float HUE2RGB(float v1,float v2,float vH)
{
	if (vH < 0)
		vH = vH+1;
	if (vH > 1)
		vH = vH-1;
	if (vH*6 < 1)
		return v1+(v2-v1)*6*vH;
	if (vH*2 < 1)
		return v2;
	if (vH*3 < 2)
		return v1+(v2-v1)*(float(2)/float(3)-vH)*6;
	return v1;
}

float3 HSL2RGB(float3 hsl)
{
	float3 RGB = float3(hsl.b,hsl.b,hsl.b);
	if (hsl.g != 0)
	{
		float var_2 = 0;
		if (hsl.b < 0.5)
			var_2 = hsl.b+hsl.g*hsl.b;
		else
			var_2 = hsl.b+hsl.g-hsl.g*hsl.b;
		float var_1 = 2*hsl.b-var_2;
		float oPt = float(1)/float(3);
		RGB.r = HUE2RGB(var_1,var_2,hsl.r+oPt);
		RGB.g = HUE2RGB(var_1,var_2,hsl.r);
		RGB.b = HUE2RGB(var_1,var_2,hsl.r-oPt);
	}
	return RGB;
}

float4 HSLComponent(float2 tex : TEXCOORD0, float4 color : COLOR0) : COLOR0
{
	float kValue = tex[!vertical];
	kValue = isReversed?(1-kValue):kValue;
	float3 nHSL = HSL*StaticMode+defHSL*(1-StaticMode);
	float3 hsl = HSL_Chg*kValue+nHSL*(1-HSL_Chg);
	color.rgb = HSL2RGB(float3(hsl.x,hsl.y,hsl.z));
	return color;
}

technique DGSHSL
{
	pass P0
	{
		PixelShader = compile ps_2_0 HSLComponent();
	}
}
