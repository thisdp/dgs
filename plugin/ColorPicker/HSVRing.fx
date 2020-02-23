float borderSoft = 0.02;
float radiusSize = 0.05;
float radius = 0.45;

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

float4 myShader(float2 tex : TEXCOORD0, float4 _color : COLOR0) : COLOR0
{
	float2 dxy = float2(length(ddx(tex)),length(ddy(tex)));
	float nBorderSoft = borderSoft*sqrt(dxy.x*dxy.y)*100;
	float2 newTex = tex-0.5;
	float _radius = length(newTex);
	float angle = degrees(atan2(newTex.y,newTex.x))/360;
	float4 color = HSL2RGB(float4(angle,1,0.5,1));
	color.a = 1-(abs(_radius-radius)+nBorderSoft-radiusSize)/nBorderSoft;
	color.a = clamp(color.a,0,1)*_color.a;
	return color;
}

technique RepTexture
{
	pass P0
	{
		PixelShader = compile ps_2_a myShader();
	}
}
