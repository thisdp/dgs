float4 _color = float4(1,1,1,1);
float4 ocolor = float4(1,0,0,1);
float width = float(0.3); //Half
float height = float(-0.2); //Half
float linewidth = float(0.04);
float nodogteethwidth = float(0.08);

float4 myShader (float2 tex : TEXCOORD0 ) : COLOR0
{
	float4 color = 0;
	if(width!=0)
	{
		float2 p1 = float2(width,-height);
		float2 p2 = float2(0,height);
		float2 center = float2(abs(0.5-tex.x),0.5-tex.y);
		float k = (p1.y-p2.y)/(p1.x-p2.x);
		float b = -k*p2.x+p2.y;
		float b2 = 1/k*p1.x+p1.y;
		float dis = abs(k*center.x-center.y+b)/sqrt(pow(k,2)+1);
		float signs = 1;
		if (height>0)
			signs = -1;
		float pos;
		if(k!=0)
			pos = signs*(-1/k*center.x-center.y+b2)/sqrt(pow(1/k,2)+1);
		else
			pos = -center.x+width;
		if(pos > 0)
		{
			if(dis < linewidth)
				color = _color;
			else
			{
				if(dis < linewidth+nodogteethwidth)
				{
					float percent = (1-(dis-linewidth)/nodogteethwidth);
					color = _color+(ocolor-_color)*(1-percent);
					color.a *= percent;
				}
			}
		}else{
			float cdis = distance(center,p1);
			if(cdis < linewidth)
				color = _color;
			else
			{
				if(cdis < linewidth+nodogteethwidth)
				{
					float percent = (1-(cdis-linewidth)/nodogteethwidth);
					color = _color+(ocolor-_color)*(1-percent);
					color.a *= percent;
				}
			}
		}
	}
	return color;
}

technique NoDogTeeth
	{
		Pass P0
		{
			PixelShader = compile ps_2_0 myShader();
		}
	}