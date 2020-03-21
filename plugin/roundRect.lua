local roundRectShader

function dgsCreateRoundRect(radius,color,texture,relative)
	assert(dgsGetType(radius) == "number","Bad argument @dgsCreateRoundRect at argument 1, expect number got "..dgsGetType(radius))
	local shader = dxCreateShader(roundRectShader)
	local color = color or tocolor(255,255,255,255)
	dgsSetData(shader,"asPlugin","dgs-dxroundrectangle")
	dgsSetData(shader,"radius",radius)
	dgsSetData(shader,"color",color)
	dgsSetData(shader,"colorOverwritten",true)
	dgsRoundRectSetRadius(shader,radius,relative)
	dgsRoundRectSetTexture(shader,texture)
	dgsRoundRectSetColor(shader,color)
	triggerEvent("onDgsPluginCreate",shader,sourceResource)
	return shader
end

function dgsRoundRectSetTexture(rectShader,texture)
	assert(dgsElementData[rectShader].asPlugin == "dgs-dxroundrectangle","Bad argument @dgsRoundRectSetTexture at argument 1, expect dgs-dxroundrectangle got "..dgsGetType(rectShader))
	if isElement(texture) then
		dxSetShaderValue(rectShader,"textureLoad",true)
		dxSetShaderValue(rectShader,"sourceTexture",texture)
	else
		dxSetShaderValue(rectShader,"textureLoad",false)
		dxSetShaderValue(rectShader,"sourceTexture",0)
	end
	return true
end

function dgsRoundRectSetRadius(rectShader,radius,relative)
	assert(dgsElementData[rectShader].asPlugin == "dgs-dxroundrectangle","Bad argument @dgsRoundRectSetRadius at argument 1, expect dgs-dxroundrectangle got "..dgsGetType(rectShader))
	assert(dgsGetType(radius) == "number","Bad argument @dgsRoundRectSetRadius at argument 2, expect number got "..dgsGetType(radius))
	dxSetShaderValue(rectShader,"radius",radius)
	dxSetShaderValue(rectShader,"isRelative",relative and true or false)
	dgsSetData(rectShader,"radius",radius)
	dgsSetData(rectShader,"isRelative",relative and true or false)
	return true
end

function dgsRoundRectGetRadius(rectShader)
	assert(dgsElementData[rectShader].asPlugin == "dgs-dxroundrectangle","Bad argument @dgsRoundRectGetRadius at argument 1, expect dgs-dxroundrectangle got "..dgsGetType(rectShader))
	return dgsElementData[rectShader].radius
end

function dgsRoundRectSetColor(rectShader,color)
	assert(dgsElementData[rectShader].asPlugin == "dgs-dxroundrectangle","Bad argument @dgsRoundRectSetColor at argument 1, expect dgs-dxroundrectangle got "..dgsGetType(rectShader))
	assert(dgsGetType(color) == "number","Bad argument @dgsRoundRectSetColor at argument 2, expect number got "..dgsGetType(color))
	dxSetShaderValue(rectShader,"color",{fromcolor(color,true,true)})
	dgsSetData(rectShader,"color",color)
	return true
end

function dgsRoundRectGetColor(rectShader)
	assert(dgsElementData[rectShader].asPlugin == "dgs-dxroundrectangle","Bad argument @dgsRoundRectGetColor at argument 1, expect dgs-dxroundrectangle got "..dgsGetType(rectShader))
	return dgsElementData[rectShader].color
end

function dgsRoundRectGetColorOverwritten(rectShader)
	assert(dgsElementData[rectShader].asPlugin == "dgs-dxroundrectangle","Bad argument @dgsRoundRectGetColorOverwritten at argument 1, expect dgs-dxroundrectangle got "..dgsGetType(rectShader))
	return dgsElementData[rectShader].colorOverwritten
end

function dgsRoundRectSetColorOverwritten(rectShader,colorOverwritten)
	assert(dgsElementData[rectShader].asPlugin == "dgs-dxroundrectangle","Bad argument @dgsRoundRectSetColorOverwritten at argument 1, expect dgs-dxroundrectangle got "..dgsGetType(rectShader))
	dgsSetData(rectShader,"colorOverwritten",colorOverwritten)
	dxSetShaderValue(rectShader,"colorOverwritten",colorOverwritten)
end

----------------Shader
roundRectShader = [[
texture sourceTexture;
float4 color = float4(1,1,1,1);
bool textureLoad;
bool isRelative = false;
float radius = 0.2;
float borderSoft = 0.01;
bool colorOverwritten = true;

SamplerState tSampler
{
	Texture = sourceTexture;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
	AddressU = Wrap;
	AddressV = Wrap;
};

float4 rndRect(float2 tex: TEXCOORD0, float4 _color : COLOR0):COLOR0
{
	float4 result;
	if(textureLoad)
		result = tex2D(tSampler,tex)*color;
	else
		result = color;
		
	float dx = length(ddx(tex));
	float dy = length(ddy(tex));
	float a = dx/dy;
	float2 nTex = tex;
	float2 center;
	float nRadius = radius/2;
	float aA = borderSoft;
	if(a<=1)
	{
		nTex.x /= a;
		center = float2(0.5/a,0.5);
		aA *= dy*100;
		if(!isRelative)
			nRadius = radius*dy;
	}
	else
	{
		nTex.y *= a;
		a = 1/a;
		center = float2(0.5,0.5/a);
		aA *= dx*100;
		if(!isRelative)
			nRadius = radius*dx;
	}
	float2 fixedPos = abs(nTex-center);
	float2 corner = center-float2(nRadius,nRadius);
	if(fixedPos.x-corner.x >= 0 && fixedPos.y-corner.y >= 0)
	{
		if(distance(fixedPos,corner) > nRadius-aA)
			result.a *= 1-(distance(fixedPos,corner)-nRadius+aA)/aA;
	}
	else
	{
		if(fixedPos.x-corner.x > nRadius-aA)
			result.a *= 1-(fixedPos.x-corner.x-nRadius+aA)/aA;
		else if(fixedPos.y-corner.y > nRadius-aA)
			result.a *= 1-(fixedPos.y-corner.y-nRadius+aA)/aA;
	}
	result = clamp(result,0,1);
	if(!colorOverwritten)
		result.rgb = _color.rgb;
	result.a *= _color.a;
	return result;
	
}

technique rndRectTech
{
	pass P0
	{
		PixelShader = compile ps_2_a rndRect();
	}
}
]]