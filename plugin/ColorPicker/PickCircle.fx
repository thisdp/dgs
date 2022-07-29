float radius = 0.35;
float radiusSize = 0.15;
float borderSoft = 0.01;
float color = float4(1,1,1,1);

float4 circle(float2 tex:TEXCOORD0,float4 __color:COLOR0):COLOR0{
	float nBorderSoft = borderSoft*sqrt(length(ddx(tex))*length(ddy(tex)))*100;
	float4 _color = color;
	float dis = distance(tex,0.5);
	float halfBorderSoft = borderSoft*0.5;
	_color.a *= 1-(abs(dis-radius)+nBorderSoft-radiusSize)/nBorderSoft;
	_color.a = clamp(_color.a,0,1)*__color.a;
	return _color;
}

technique RepTexture{
	pass P0{
		SeparateAlphaBlendEnable = true;
		SrcBlendAlpha = One;
		DestBlendAlpha = InvSrcAlpha;
		PixelShader = compile ps_2_a circle();
	}
}
