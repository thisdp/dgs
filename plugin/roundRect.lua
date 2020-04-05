local roundRectShader

function Old_dgsCreateRoundRect(radius,color,texture,relative)
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

function dgsCreateRoundRect(radius,relative,color,texture,colorOverwritten)
	local radType = dgsGetType(radius)
	assert(radType == "number" or radType == "table","Bad argument @dgsCreateRoundRect at argument 1, expect number/table got "..dgsGetType(radius))
	if not getElementData(localPlayer,"DGS-DEBUG-C") then
		if type(relative) == "number" and radType ~= "table" then
			outputDebugString("Deprecated argument usage @dgsCreateRoundRect, run it again with command /debugdgs c",2)
			return Old_dgsCreateRoundRect(radius,relative,color,texture)
		end
	end
	if type(radius) ~= "table" then
		assert(dgsGetType(relative) == "boolean","Bad argument @dgsCreateRoundRect at argument 2, expect boolean got "..dgsGetType(relative))
		local shader = dxCreateShader(roundRectShader)
		local color = color or tocolor(255,255,255,255)
		dgsSetData(shader,"asPlugin","dgs-dxroundrectangle")
		dgsSetData(shader,"color",color)
		dgsRoundRectSetColorOverwritten(shader,colorOverwritten ~= false)
		dgsRoundRectSetRadius(shader,radius,relative)
		dgsRoundRectSetTexture(shader,texture)
		dgsRoundRectSetColor(shader,color)
		triggerEvent("onDgsPluginCreate",shader,sourceResource)
		return shader
	else
		for i=1,4 do
			radius[i] = radius[i] or {0,true}
			radius[i][1] = tonumber(radius[i][1] or 0)
			radius[i][2] = radius[i][2] ~= false
		end
		local color,texture,colorOverwritten = relative,color,texture
		local shader = dxCreateShader(roundRectShader)
		local color = color or tocolor(255,255,255,255)
		dgsSetData(shader,"asPlugin","dgs-dxroundrectangle")
		dgsSetData(shader,"color",color)
		dgsRoundRectSetColorOverwritten(shader,colorOverwritten ~= false)
		dgsRoundRectSetRadius(shader,radius)
		dgsRoundRectSetTexture(shader,texture)
		dgsRoundRectSetColor(shader,color)
		triggerEvent("onDgsPluginCreate",shader,sourceResource)
		return shader
	end
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
	local radType = dgsGetType(radius)
	assert(radType == "number" or radType == "table","Bad argument @dgsRoundRectSetRadius at argument 2, expect number/table got "..dgsGetType(radius))
	if type(radius) ~= "table" then
		local relative = relative ~= false
			print(radius,relative)
		dxSetShaderValue(rectShader,"radius",{radius,radius,radius,radius})
		dxSetShaderValue(rectShader,"isRelative",{relative and 1 or 0,relative and 1 or 0,relative and 1 or 0,relative and 1 or 0})
		dgsSetData(rectShader,"radius",{{radius,relative},{radius,relative},{radius,relative},{radius,relative}})
	else
		local oldRadius = dgsElementData[rectShader].radius
		local _ra,_re = {},{}
		for i=1,4 do
			radius[i] = radius[i] or oldRadius[i]
			radius[i][1] = tonumber(radius[i][1]) or 0
			radius[i][2] = radius[i][2] ~= false
			_ra[i] = radius[i][1]
			_re[i] = radius[i][2] and 1 or 0
		end
		dxSetShaderValue(rectShader,"radius",_ra)
		dxSetShaderValue(rectShader,"isRelative",_re)
		dgsSetData(rectShader,"radius",radius)
	end
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
float4 isRelative = 1;
float4 radius = 5;
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

float4 rndRect(float2 tex: TEXCOORD0, float4 _color : COLOR0):COLOR0{
	float4 result = textureLoad?tex2D(tSampler,tex)*color:color;
	float2 dd = float2(length(ddx(tex)),length(ddy(tex)));
	float a = dd.x/dd.y;
	float2 nTex = tex;
	float2 center = float2(0.5/(a<=1?a:1),0.5/(a>=1?a:1));
	float4 nRadius;
	float aA = borderSoft*100;
	float2 fixedPos = nTex-center;
	float2 fPos,corner;
	if(a<=1){
		nTex.x /= a;
		aA *= dd.y;
		nRadius = float4(isRelative.x==1?radius.x/2:radius.x*dd.y,isRelative.y==1?radius.y/2:radius.y*dd.y,isRelative.z==1?radius.z/2:radius.z*dd.y,isRelative.w==1?radius.w/2:radius.w*dd.y);
	}
	else{
		nTex.y *= a;
		a = 1/a;
		aA *= dd.x;
		nRadius = float4(isRelative.x==1?radius.x/2:radius.x*dd.x,isRelative.y==1?radius.y/2:radius.y*dd.x,isRelative.z==1?radius.z/2:radius.z*dd.x,isRelative.w==1?radius.w/2:radius.w*dd.x);
	}
	//LTCorner
	corner = center-nRadius.x;
	fPos = -fixedPos;
	if(fPos.x >= corner.x && fPos.y >= corner.y)
	{
		if(distance(fPos,corner) > nRadius.x-aA)
			result.a *= 1-(distance(fPos,corner)-nRadius.x+aA)/aA;
	}
	//RTCorner
	corner = center-nRadius.y;
	fPos = float2(fixedPos.x,-fixedPos.y);
	if(fPos.x >= corner.x && fPos.y >= corner.y)
	{
		if(distance(fPos,corner) > nRadius.y-aA)
			result.a *= 1-(distance(fPos,corner)-nRadius.y+aA)/aA;
	}
	//RBCorner
	corner = center-nRadius.z;
	fPos = float2(fixedPos.x,fixedPos.y);
	if(fPos.x >= corner.x && fPos.y >= corner.y)
	{
		if(distance(fPos,corner) > nRadius.z-aA)
			result.a *= 1-(distance(fPos,corner)-nRadius.z+aA)/aA;
	}
	//LBCorner
	corner = center-nRadius.w;
	fPos = float2(-fixedPos.x,fixedPos.y);
	if(fPos.x >= corner.x && fPos.y >= corner.y)
	{
		if(distance(fPos,corner) > nRadius.w-aA)
			result.a *= 1-(distance(fPos,corner)-nRadius.w+aA)/aA;
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
--[[
roundRectShader = [
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
]
]]