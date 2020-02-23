float borderSoft = 0.02;
float radius = 0.2;
float thickness = 0.02;
float2 progress = float2(0,0.1);
float4 indicatorColor = float4(0,1,1,1);
float PI2 = 6.283185;

float4 blend(float4 c1, float4 c2)
{
	float alp = c1.a+c2.a-c1.a*c2.a;
	float3 color = (c1.rgb*c1.a*(1.0-c2.a)+c2.rgb*c2.a)/alp;
	return float4(color,alp);
}

float4 myShader(float2 tex : TEXCOORD0, float4 color : COLOR0 ) : COLOR0
{
	float2 dxy = float2(length(ddx(tex)),length(ddy(tex)));
	float nBorderSoft = borderSoft*sqrt(dxy.x*dxy.y)*100;
	float4 bgColor = color;
	float4 inColor = 0;
	float2 texFixed = tex-0.5;
	float dis = abs(length(texFixed)-radius);
	float delta = clamp(1-(dis-thickness+nBorderSoft)/nBorderSoft,0,1);
	bgColor.a *= delta;
	float2 progressFixed = progress*PI2;
	float angle = atan2(tex.y-0.5,0.5-tex.x)+0.5*PI2;
	bool tmp1 = angle > progressFixed.x;
	bool tmp2 = angle < progressFixed.y;
	float dis_ = distance(float2(cos(progressFixed.x),-sin(progressFixed.x))*radius,texFixed);
	float4 Color1,Color2;
	if(dis_<=thickness)
	{
		float tmpDelta = clamp(1-(dis_-thickness+nBorderSoft)/nBorderSoft,0,1);
		Color1 = indicatorColor;
		inColor = indicatorColor;
		Color1.a *= tmpDelta;
	}
	dis_ = distance(float2(cos(progressFixed.y),-sin(progressFixed.y))*radius,texFixed);
	if(dis_<=thickness)
	{
		float tmpDelta = clamp(1-(dis_-thickness+nBorderSoft)/nBorderSoft,0,1);
		Color2 = indicatorColor;
		inColor = indicatorColor;
		Color2.a *= tmpDelta;
	}
	inColor.a = max(Color1.a,Color2.a);
	if(progress.x>=progress.y)
	{
		if(tmp1+tmp2)
		{
			inColor = indicatorColor;
			inColor.a *= delta;
		}
	}else{
		if(tmp1*tmp2)
		{
			inColor = indicatorColor;
			inColor.a *= delta;
		}
	}
	return blend(bgColor,inColor);
}

technique DrawCircle
{
	pass P0
	{
		PixelShader = compile ps_2_a myShader();
	}
}
