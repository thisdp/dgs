float antiAliased = 0.005;
float radius = 0.2;
float thickness = 0.02;
float2 progress = float2(0,0.1);
float4 indicatorColor = float4(0,1,1,1);
float PI2 = 6.2831853071795864769;

float4 myShader(float2 tex : TEXCOORD0, float4 color : COLOR0 ) : COLOR0
{
	float2 progressFixed = progress*PI2;
	float2 texFixed = tex-0.5;
	float dis = abs(length(texFixed)-radius);
	float angle = atan2(tex.y-0.5,0.5-tex.x)+0.5*PI2;
	float4 colorDiff = indicatorColor-color;
	float4 color_ = color;
	float delta = clamp(1-(dis-thickness+antiAliased)/antiAliased,0,1);
	int a = 0;
	bool tmp1 = angle > progressFixed.x;
	bool tmp2 = angle < progressFixed.y;
	if(progress.x>=progress.y)
	{
		color.rgb += colorDiff.rgb*delta*(tmp1+tmp2);
		a += tmp1+tmp2;
	}else{
		color.rgb += colorDiff.rgb*delta*(tmp1*tmp2);
		a += tmp1*tmp2;
	}
	color.a *= delta;
	float dis_ = distance(float2(cos(progressFixed.x),-sin(progressFixed.x))*radius,texFixed);
	float3 colorDiff2 = indicatorColor.rgb-color.rgb;
	if(dis_<=thickness)
	{
		color.rgb += colorDiff2.rgb*clamp(1-(dis_-thickness+antiAliased)/antiAliased,0,1);
		a +=1;
	}
	dis_ = distance(float2(cos(progressFixed.y),-sin(progressFixed.y))*radius,texFixed);
	colorDiff2 = indicatorColor.rgb-color.rgb;
	if(dis_<=thickness)
	{
		color.rgb += colorDiff2.rgb*clamp(1-(dis_-thickness+antiAliased)/antiAliased,0,1);
		a +=1;
	}
	if (a >= 2)
		if (abs(dis-thickness) <= antiAliased)
		{
			float3 x = color_.rgb+colorDiff.rgb*delta;
			if(length(x-color_.rgb)<length(color.rgb-color_.rgb))
				color.rgb = x;
		}	
	return color;
}

technique DrawCircle
{
	pass P0
	{
		PixelShader = compile ps_2_a myShader();
	}
}
