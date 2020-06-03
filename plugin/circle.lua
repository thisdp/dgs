local shader = [[
#define PI 3.1415926
float borderSoft = 0.02;
float angStart = 0;
float angEnd = 0.2*PI;
float direction = true; //anticlockwise
float radius = 0.5;

float4 circleShader(float2 tex:TEXCOORD0,float4 color:COLOR0):COLOR0{
	float sinStart = sin(angStart);
	float cosStart = cos(angStart);
	float angle = atan2(0.5-tex.y,tex.x-0.5);
	float sinAng = sin(angle);
	float radi = distance(tex,0.5);
	float4 _color = 0;
	if(radi<radius)
		if(direction){
			if(sinAng>sinStart&&sinAng<sinEnd){
				_color=color;
			}
		}else{
			if(sinAng<sinStart&&sinAng>sinEnd){
				_color=color;
			}
		}
	return _color;
}
	
technique circleTechnique{
	pass p0{
		PixelShader = compile ps_2_0 circleShader();
	}
}	
]]

function dgsCreateCircle()
	local circle = dxCreateShader(shader)
	return circle
end