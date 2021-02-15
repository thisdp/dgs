bool vertical = false;
float3 HSV = float3(0,0,0);
float3 defHSV = float3(0,1,1);
float3 HSV_Chg = float3(0,0,0);
float3 StaticMode = float3(1,1,1);
bool isReversed = false;

float3 HSV2RGB(float3 HSV){
	HSV.x*=6;
	float chroma = HSV.z*HSV.y;
	float interm = chroma*(1-abs(HSV.x%2.0-1));
	float shift = HSV.z-chroma;
	if(HSV.x<1) return float3(shift+chroma,shift+interm,shift);
	if(HSV.x<2) return float3(shift+interm,shift+chroma,shift);
	if(HSV.x<3) return float3(shift,shift+chroma,shift+interm);
	if(HSV.x<4) return float3(shift,shift+interm,shift+chroma);
	if(HSV.x<5) return float3(shift+interm,shift,shift+chroma);
	return float3(shift+chroma,shift,shift+interm);
}

float4 HSVComponent(float2 tex:TEXCOORD0,float4 color:COLOR0):COLOR0{
	float kValue = tex[!vertical];
	kValue = isReversed?(1-kValue):kValue;
	float3 nHSV = HSV*StaticMode+defHSV*(1-StaticMode);
	float3 hsv = HSV_Chg*kValue+nHSV*(1-HSV_Chg);
	color.rgb = HSV2RGB(hsv);
	return color;
}

technique DGSHSV{
	pass P0{
		PixelShader = compile ps_2_0 HSVComponent();
	}
}
