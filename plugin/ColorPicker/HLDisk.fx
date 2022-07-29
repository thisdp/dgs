#define PIx2 6.2831852
float borderSoft = 0.01;
float radius = 0.5;

float HUE2RGB(float v1,float v2,float vH){
	if (vH < 0) vH = vH+6;
	else if (vH > 6) vH = vH-6;
	if (vH < 1) return v1+(v2-v1)*vH;
	if (vH < 3) return v2;
	if (vH < 4) return v1+(v2-v1)*(4-vH);
	return v1;
}

float3 HSL2RGB(float3 hsl){
	float3 RGB = float3(hsl.b,hsl.b,hsl.b);
	if (hsl.g != 0){
		float var_2 = hsl.b+hsl.g*(hsl.b<0.5?hsl.b:(1-hsl.b));
		float var_1 = 2*hsl.b-var_2;
		float r = hsl.r*6.0;
		RGB.r = HUE2RGB(var_1,var_2,r+2.0);
		RGB.g = HUE2RGB(var_1,var_2,r);
		RGB.b = HUE2RGB(var_1,var_2,r-2.0);
	}
	return RGB;
}

float4 myShader(float2 tex:TEXCOORD0,float4 color:COLOR0):COLOR0{
	float nBorderSoft = borderSoft*sqrt(length(ddx(tex))*length(ddy(tex)))*100;
	float2 newTex = tex-0.5;
	float _radius = length(newTex);
	float angle = atan2(newTex.y,newTex.x)/PIx2;
	color.rgb = HSL2RGB(float3(angle,1,1-_radius));
	color.a *= clamp(1-(_radius-radius+nBorderSoft)/nBorderSoft,0,1);
	return color;
}

technique RepTexture{
	pass P0{
		SeparateAlphaBlendEnable = true;
		SrcBlendAlpha = One;
		DestBlendAlpha = InvSrcAlpha;
		PixelShader = compile ps_2_a myShader();
	}
}
