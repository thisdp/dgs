float HUE2RGB(float v1,float v2,float vH){
	if (vH < 0) vH = vH+1;
	if (vH > 1) vH = vH-1;
	if (vH*6 < 1) return v1+(v2-v1)*6*vH;
	if (vH*2 < 1) return v2;
	if (vH*3 < 2) return v1+(v2-v1)*(2.0f/3.0f-vH)*6;
	return v1;
}

float3 HSL2RGB(float3 hsl){
	float3 RGB = float3(hsl.b,hsl.b,hsl.b);
	if (hsl.g != 0){
		float var_2 = hsl.b+hsl.g*(hsl.b<0.5?hsl.b:(1-hsl.b));
		float var_1 = 2*hsl.b-var_2;
		float oPt = 1.0f/3.0f;
		RGB.r = HUE2RGB(var_1,var_2,hsl.r+oPt);
		RGB.g = HUE2RGB(var_1,var_2,hsl.r);
		RGB.b = HUE2RGB(var_1,var_2,hsl.r-oPt);
	}
	return RGB;
}

float4 myShader(float2 tex:TEXCOORD0,float4 color:COLOR0):COLOR0{
	color.rgb = HSL2RGB(float3(tex.x,1-tex.y,0.5));
	return color;
}

technique RepTexture{
	pass P0	{
		PixelShader = compile ps_2_0 myShader();
	}
}
