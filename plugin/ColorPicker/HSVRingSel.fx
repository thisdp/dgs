#define PI 3.1415926
float borderSoft = 0.02;
float Hue = 1;
float sqrt3 = sqrt(float(3));

float4 HSV2RGB(float4 HSVA){
	HSVA.x*=6;
	float chroma = HSVA.z*HSVA.y;
	float interm = chroma*(1-abs(HSVA.x%2.0-1));
	float shift = HSVA.z-chroma;
	if (HSVA.x<1) return float4(shift+chroma,shift+interm,shift,HSVA.a);
	if (HSVA.x<2) return float4(shift+interm,shift+chroma,shift,HSVA.a);
	if (HSVA.x<3) return float4(shift,shift+chroma,shift+interm,HSVA.a);
	if (HSVA.x<4) return float4(shift,shift+interm,shift+chroma,HSVA.a);
	if (HSVA.x<5) return float4(shift+interm,shift,shift+chroma,HSVA.a);
	return float4(shift+chroma,shift,shift+interm,HSVA.a);
}

float4 PS(float2 tex:TEXCOORD0,float4 _color:COLOR0):COLOR0{
	float2 dxy = float2(length(ddx(tex)),length(ddy(tex)));
	float nBorderSoft = borderSoft*sqrt(dxy.x*dxy.y)*100;
	float2 newTex = tex*2-1;
	float rot = (Hue+0.5)*PI*2;
	float2 transi = float2(cos(rot+PI*0.5),sin(rot+PI*0.5));
	float2 transj = float2(cos(rot),sin(rot));
	newTex = float2(newTex.x*transi.x+newTex.y*transj.x,newTex.x*transi.y+newTex.y*transj.y);
	float deg = degrees(atan2(newTex.y,newTex.x))+60;
	if(deg<0) deg += 360;
	if(deg>360) deg -= 360;
	float4 color = 0;
	float2 theVector;
	if(deg<90||deg>=330) theVector = float2(0.21650635,-0.125);
	else if(deg<210) theVector = float2(0,0.25);
	else if(deg<330) theVector = float2(-0.21650635,-0.125);
	float theVectorLen = length(theVector);
	float res = abs(dot(newTex,theVector))/theVectorLen-theVectorLen-0.25050927;
	color = HSV2RGB(float4(Hue,(1-2*newTex.y)/(sqrt3*(-newTex.x)-newTex.y+2),(sqrt3*(-newTex.x)-newTex.y+2)/3,1-(res+nBorderSoft)/nBorderSoft));
	color.a = clamp(color.a,0,1)*_color.a;
    return color;
}

technique RepTexture{
	pass P0{
		SeparateAlphaBlendEnable = true;
		SrcBlendAlpha = One;
		DestBlendAlpha = InvSrcAlpha;
		PixelShader = compile ps_2_a PS();
	}
}
