float4 hslColor;

float Hue_2_RGB(float v1,float v2,float vH)
{
	if (vH < 0)
	{
		vH = vH+1;
	}
	if (vH > 1)
	{
		vH = vH-1;
	}
	if (vH*6 < 1)
	{
		return v1+(v2-v1)*6*vH;
	}
	if (vH*2 < 1)
	{
		return v2;
	}
	if (vH*3 < 2)
	{
		return v1+(v2-v1)*(float(2)/float(3)-vH)*6;
	}
	return v1;
}

float4 hslTorgb(float4 hsl)
{
	float4 RGBA = float4(hsl.b,hsl.b,hsl.b,hsl.a);
	if (hsl.g != 0)
	{
		float var_2 = 0;
		if (hsl.b < 0.5)
		{
			var_2 = hsl.b*(1+hsl.g);
		}
		else
		{
			var_2 = hsl.b+hsl.g-hsl.g*hsl.b;
		}
		float var_1 = 2*hsl.b-var_2;
		float oPt = float(1)/float(3);
		RGBA.r = Hue_2_RGB(var_1,var_2,hsl.r+oPt);
		RGBA.g = Hue_2_RGB(var_1,var_2,hsl.r);
		RGBA.b = Hue_2_RGB(var_1,var_2,hsl.r-oPt);
	}
	return RGBA;
}

float4 myShader(float2 tex : TEXCOORD0) : COLOR0
{
	float4 temp = float4(hslColor.r,hslColor.g,1-tex.y,hslColor.a);
	float4 color = hslTorgb(temp);
	return color;
}

technique RepTexture
{
	pass P0
	{
		PixelShader = compile ps_2_0 myShader();
	}
}
