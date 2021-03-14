local circleShader = [[
#define PI 3.1415926
float borderSoft = 0.01;
float angEnd = 1.1*PI;
float direction = true; //anticlockwise
float radius = 0.5;

float4 circleShader(float2 tex:TEXCOORD0,float4 color:COLOR0):COLOR0{
	float2 dxy = float2(length(ddx(tex)),length(ddy(tex)));
	float nBorderSoft = borderSoft*sqrt(dxy.x*dxy.y)*100;
	float xDistance = 0.5-tex.x,yDistance = 0.5-tex.y;
	float angle = atan2(yDistance,xDistance);
	float kEveryPixel = yDistance/xDistance;
	float ang = PI-angEnd;
	float k = tan(ang);
	float dis1 = abs(k*xDistance-yDistance)/sqrt(pow(k,2)+1);
	float dis2 = abs(yDistance);
	
	float radi = distance(tex,0.5);
	color.a = 0;
	if(direction){
		if(angle>ang){
			color.a = 1;
		}
	}
	color.a *= clamp((dis1-nBorderSoft)/nBorderSoft,0,1);
	color.a *= clamp((dis2-nBorderSoft)/nBorderSoft,0,1);
	color.a *= clamp((1-distance(tex,0.5)-radius-nBorderSoft)/nBorderSoft,0,1);
	return color;
}

technique circleTechnique{
	pass p0{
		PixelShader = compile ps_2_a circleShader();
	}
}
]]

function dgsCreateCircle()
	local circle = dxCreateShader(circleShader)
	return circle
end


--dgsCreateImage(300,300,400,400,dgsCreateCircle(),false)