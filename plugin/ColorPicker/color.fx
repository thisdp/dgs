float borderSoft = 0.005;

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

float4 PS(float2 tex : TEXCOORD0) : COLOR0
{
	float2 newTex = tex*2-1;
	float deg = degrees(atan2(newTex.y,newTex.x))+60;
	if(deg < 0)
		deg += 360;
	if(deg > 360)
		deg -= 360;
	float4 color = 0;
	float2 theVector;
	if(deg < 90 || deg >= 330)
		theVector = float2(0.21650635,-0.125);
	else if(deg < 210)
		theVector = float2(0,0.25);
	else if(deg < 330)
		theVector = float2(-0.21650635,-0.125);
	float theVectorLen = length(theVector);
	float res = abs(dot(newTex,theVector))/theVectorLen-theVectorLen-0.25050927;
	float theBorder = borderSoft*0.5;
	if (res-theBorder < 0)
		color = HSL2RGB(float4(1,1-tex.y/0.75,tex.x/0.8660254-0.0669873/0.8660254,1-(res+theBorder)/borderSoft));
    return color;
}


technique RepTexture
{
	pass P0
	{
		PixelShader = compile ps_2_a PS();
	}
}
