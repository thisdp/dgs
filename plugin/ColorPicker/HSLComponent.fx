bool vertical = false;
float3 HSL = float3(0,0,0);
float3 HSL_Chg = float3(0,0,0);
float3 defHSL = float3(0,1,0.5);
float3 StaticMode = float3(1,1,1);
bool isReversed = false;
bool useMaskTexture = false;
texture maskTexture;

SamplerState maskSampler{
	Texture = maskTexture;
};

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

float4 HSLComponent(float2 tex,float4 color){
	float kValue = tex[!vertical];
	kValue = isReversed?(1-kValue):kValue;
	float3 nHSL = HSL*StaticMode+defHSL*(1-StaticMode);
	float3 hsl = HSL_Chg*kValue+nHSL*(1-HSL_Chg);
	color.rgb = HSL2RGB(float3(hsl.x,hsl.y,hsl.z));
	return color;
}

float4 ComponentMask(float2 tex,float4 color){
	float3 _maskRGB = tex2D(maskSampler,tex).rgb;
	color.a *= (_maskRGB.r+_maskRGB.g+_maskRGB.b)/3;
	return color;
}

float4 Main(float2 tex:TEXCOORD0,float4 color:COLOR0):COLOR0{
	color = HSLComponent(tex,color);
	if(useMaskTexture)
		color = ComponentMask(tex,color);
	return color;
}

technique DGSHSL{
	pass P0{
		SeparateAlphaBlendEnable = true;
		SrcBlendAlpha = One;
		DestBlendAlpha = InvSrcAlpha;
		PixelShader = compile ps_2_0 Main();
	}
}