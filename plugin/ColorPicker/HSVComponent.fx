bool vertical = false;
float3 HSV = float3(0,0,0);
float3 defHSV = float3(0,1,1);
float3 HSV_Chg = float3(0,0,0);
float3 StaticMode = float3(1,1,1);


float4 HSV2RGB(float4 HSVA)
{
	HSVA.x*=6;
	float chroma = HSVA.z * HSVA.y;
	float interm = chroma * (1 - abs(HSVA.x % 2.0 - 1));
	float shift = HSVA.z - chroma;
	if (HSVA.x < 1 ) return float4(shift + chroma, shift + interm, shift + 0, HSVA.a);
	if (HSVA.x < 2 ) return float4(shift + interm, shift + chroma, shift + 0, HSVA.a);
	if (HSVA.x < 3 ) return float4(shift + 0, shift + chroma, shift + interm, HSVA.a);
	if (HSVA.x < 4 ) return float4(shift + 0, shift + interm, shift + chroma, HSVA.a);
	if (HSVA.x < 5 ) return float4(shift + interm, shift + 0, shift + chroma, HSVA.a);
	return float4(shift + chroma, shift + 0, shift + interm, HSVA.a);
}


float4 HSVComponent(float2 tex : TEXCOORD0) : COLOR0
{
	float kValue = tex[!vertical];
	float3 nHSV = HSV*StaticMode+defHSV*(1-StaticMode);
	float3 hsv = HSV_Chg*kValue+nHSV*(1-HSV_Chg);
	float4 color = HSV2RGB(float4(hsv.x,hsv.y,hsv.z,1));
	return color;
}

technique DGSHSV
{
	pass P0
	{
		PixelShader = compile ps_2_0 HSVComponent();
	}
}
