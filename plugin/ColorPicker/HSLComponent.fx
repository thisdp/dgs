bool vertical = false;
float3 HSL = float3(0,0,0);
float3 HSL_Chg = float3(0,0,0);
float3 defHSL = float3(0,1,0.5);
float3 StaticMode = float3(1,1,1);
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

float4 HSL2RGB(float4 hsl)
{
	float4 RGBA = float4(hsl.b,hsl.b,hsl.b,hsl.a);
	if (hsl.g != 0)
	{
		float var_2 = 0;
		if (hsl.b < 0.5)
			var_2 = hsl.b+hsl.g*hsl.b;
		else
			var_2 = hsl.b+hsl.g-hsl.g*hsl.b;
		float var_1 = 2*hsl.b-var_2;
		float oPt = float(1)/float(3);
		RGBA.r = HUE2RGB(var_1,var_2,hsl.r+oPt);
		RGBA.g = HUE2RGB(var_1,var_2,hsl.r);
		RGBA.b = HUE2RGB(var_1,var_2,hsl.r-oPt);
	}
	return RGBA;
}

float4 HSLComponent(float2 tex : TEXCOORD0) : COLOR0
{
	float kValue = tex[!vertical];
	float3 nHSL = HSL*StaticMode+defHSL*(1-StaticMode);
	float3 hsl = HSL_Chg*kValue+nHSL*(1-HSL_Chg);
	float4 color = HSL2RGB(float4(hsl.x,hsl.y,hsl.z,1));
	return color;
}

technique DGSHSL
{
	pass P0
	{
		PixelShader = compile ps_2_0 HSLComponent();
	}
}
