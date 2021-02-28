function requestRoundRectangleShader(withoutFilled)
	local woF = not withoutFilled and ""
	return
[[
texture sourceTexture;
float4 color = float4(1,1,1,1);
bool textureLoad = false;
bool textureRotated = false;
float4 isRelative = 1;
float4 radius = 0.2;
float borderSoft = 0.01;
bool colorOverwritten = true;
]]..(woF or [[
float2 borderThickness = float2(0.2,0.2);
float radiusMultipler = 0.95;
]])..[[

SamplerState tSampler{
	Texture = sourceTexture;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
};

float4 rndRect(float2 tex: TEXCOORD0, float4 _color : COLOR0):COLOR0{
	float4 result = textureLoad?tex2D(tSampler,textureRotated?tex.yx:tex)*color:color;
	float alp = 1;
	float2 tex_bk = tex;
	float2 dx = ddx(tex);
	float2 dy = ddy(tex);
	float2 dd = float2(length(float2(dx.x,dy.x)),length(float2(dx.y,dy.y)));
	float a = dd.x/dd.y;
	float2 center = 0.5*float2(1/(a<=1?a:1),a<=1?1:a);
	float4 nRadius;
	float aA = borderSoft*100;
	if(a<=1){
		tex.x /= a;
		aA *= dd.y;
		nRadius = float4(isRelative.x==1?radius.x/2:radius.x*dd.y,isRelative.y==1?radius.y/2:radius.y*dd.y,isRelative.z==1?radius.z/2:radius.z*dd.y,isRelative.w==1?radius.w/2:radius.w*dd.y);
	}else{
		tex.y *= a;
		aA *= dd.x;
		nRadius = float4(isRelative.x==1?radius.x/2:radius.x*dd.x,isRelative.y==1?radius.y/2:radius.y*dd.x,isRelative.z==1?radius.z/2:radius.z*dd.x,isRelative.w==1?radius.w/2:radius.w*dd.x);
	}

	float2 fixedPos = tex-center;
	float2 corner[] = {center-nRadius.x,center-nRadius.y,center-nRadius.z,center-nRadius.w};
	//LTCorner
	if(-fixedPos.x >= corner[0].x && -fixedPos.y >= corner[0].y){
		float dis = distance(-fixedPos,corner[0]);
		alp = 1-(dis-nRadius.x+aA)/aA;
	}
	//RTCorner
	if(fixedPos.x >= corner[1].x && -fixedPos.y >= corner[1].y){
		float dis = distance(float2(fixedPos.x,-fixedPos.y),corner[1]);
		alp = 1-(dis-nRadius.y+aA)/aA;
	}
	//RBCorner
	if(fixedPos.x >= corner[2].x && fixedPos.y >= corner[2].y){
		float dis = distance(float2(fixedPos.x,fixedPos.y),corner[2]);
		alp = 1-(dis-nRadius.z+aA)/aA;
	}
	//LBCorner
	if(-fixedPos.x >= corner[3].x && fixedPos.y >= corner[3].y){
		float dis = distance(float2(-fixedPos.x,fixedPos.y),corner[3]);
		alp = 1-(dis-nRadius.w+aA)/aA;
	}
	if (fixedPos.y <= 0 && -fixedPos.x <= corner[0].x && fixedPos.x <= corner[1].x && (nRadius[0] || nRadius[1])){
		alp = (fixedPos.y+center.y)/aA;
	}else if (fixedPos.y >= 0 && -fixedPos.x <= corner[3].x && fixedPos.x <= corner[2].x && (nRadius[2] || nRadius[3])){
		alp = (-fixedPos.y+center.y)/aA;
	}else if (fixedPos.x <= 0 && -fixedPos.y <= corner[0].y && fixedPos.y <= corner[3].y && (nRadius[0] || nRadius[3])){
		alp = (fixedPos.x+center.x)/aA;
	}else if (fixedPos.x >= 0 && -fixedPos.y <= corner[1].y && fixedPos.y <= corner[2].y && (nRadius[1] || nRadius[2])){
		alp = (-fixedPos.x+center.x)/aA;
	}
	alp = clamp(alp,0,1);
	]]..(woF or [[
	float2 newborderThickness = borderThickness*dd*100;
	tex_bk = tex_bk+tex_bk*newborderThickness;
	dx = ddx(tex_bk);
	dy = ddy(tex_bk);
	dd = float2(length(float2(dx.x,dy.x)),length(float2(dx.y,dy.y)));
	a = dd.x/dd.y;
	center = 0.5*float2(1/(a<=1?a:1),a<=1?1:a);
	aA = borderSoft*100;
	if(a<=1){
		tex_bk.x /= a;
		aA *= dd.y;
		nRadius = float4(isRelative.x==1?radius.x/2:radius.x*dd.y,isRelative.y==1?radius.y/2:radius.y*dd.y,isRelative.z==1?radius.z/2:radius.z*dd.y,isRelative.w==1?radius.w/2:radius.w*dd.y);
	}
	else{
		tex_bk.y *= a;
		aA *= dd.x;
		nRadius = float4(isRelative.x==1?radius.x/2:radius.x*dd.x,isRelative.y==1?radius.y/2:radius.y*dd.x,isRelative.z==1?radius.z/2:radius.z*dd.x,isRelative.w==1?radius.w/2:radius.w*dd.x);
	}
	fixedPos = (tex_bk-center*(newborderThickness+1));
	float4 nRadiusHalf = nRadius*radiusMultipler;
	corner[0] = center-nRadiusHalf.x;
	corner[1] = center-nRadiusHalf.y;
	corner[2] = center-nRadiusHalf.z;
	corner[3] = center-nRadiusHalf.w;
	//LTCorner
	float nAlp = 0;
	if(-fixedPos.x >= corner[0].x && -fixedPos.y >= corner[0].y){
		float dis = distance(-fixedPos,corner[0]);
		nAlp = (dis-nRadiusHalf.x+aA)/aA;
	}
	//RTCorner
	if(fixedPos.x >= corner[1].x && -fixedPos.y >= corner[1].y){
		float dis = distance(float2(fixedPos.x,-fixedPos.y),corner[1]);
		nAlp = (dis-nRadiusHalf.y+aA)/aA;
	}
	//RBCorner
	if(fixedPos.x >= corner[2].x && fixedPos.y >= corner[2].y){
		float dis = distance(float2(fixedPos.x,fixedPos.y),corner[2]);
		nAlp = (dis-nRadiusHalf.z+aA)/aA;
	}
	//LBCorner
	if(-fixedPos.x >= corner[3].x && fixedPos.y >= corner[3].y){
		float dis = distance(float2(-fixedPos.x,fixedPos.y),corner[3]);
		nAlp = (dis-nRadiusHalf.w+aA)/aA;
	}
	if (fixedPos.y <= 0 && -fixedPos.x <= corner[0].x && fixedPos.x <= corner[1].x && (nRadiusHalf[0] || nRadiusHalf[1])){
		nAlp = 1-(fixedPos.y+center.y)/aA;
	}else if (fixedPos.y >= 0 && -fixedPos.x <= corner[3].x && fixedPos.x <= corner[2].x && (nRadiusHalf[2] || nRadiusHalf[3])){
		nAlp = 1-(-fixedPos.y+center.y)/aA;
	}else if (fixedPos.x <= 0 && -fixedPos.y <= corner[0].y && fixedPos.y <= corner[3].y && (nRadiusHalf[0] || nRadiusHalf[3])){
		nAlp = 1-(fixedPos.x+center.x)/aA;
	}else if (fixedPos.x >= 0 && -fixedPos.y <= corner[1].y && fixedPos.y <= corner[2].y && (nRadiusHalf[1] || nRadiusHalf[2])){
		nAlp = 1-(-fixedPos.x+center.x)/aA;
	}
	alp *= clamp(nAlp,0,1);
	]])..[[
	result.rgb = colorOverwritten?result.rgb:_color.rgb;
	result.a *= _color.a*alp;
	return result;
}

technique rndRectTech{
	pass P0{
		PixelShader = compile ps_2_a rndRect();
	}
}
]]
end

function Old_dgsCreateRoundRect(radius,color,texture,relative)
	assert(dgsGetType(radius) == "number","Bad argument @dgsCreateRoundRect at argument 1, expect number got "..dgsGetType(radius))
	local shader = dxCreateShader(requestRoundRectangleShader())
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

function dgsCreateRoundRect(radius,relative,color,texture,colorOverwritten,borderOnly,borderThicknessHorizontal,borderThicknessVertical)
	local radType = dgsGetType(radius)
	if not(radType == "number" or radType == "table") then error(dgsGenAsrt(radius,"dgsCreateRoundRect",1,"number/table")) end
	if not getElementData(localPlayer,"DGS-DEBUG-C") then
		if type(relative) == "number" and radType ~= "table" then
			outputDebugString("Deprecated argument usage @dgsCreateRoundRect, run it again with command /debugdgs c",2)
			return Old_dgsCreateRoundRect(radius,relative,color,texture)
		end
	end
	local shader = dxCreateShader(requestRoundRectangleShader(borderOnly))
	dgsSetData(shader,"asPlugin","dgs-dxroundrectangle")
	if type(radius) ~= "table" then
		local rlt = dgsGetType(relative) == "boolean"
		if not rlt then destroyElement(shader) end
		if not(rlt) then error(dgsGenAsrt(relative,"dgsCreateRoundRect",2,"boolean")) end
		dgsRoundRectSetRadius(shader,radius,relative)
	else
		for i=1,4 do
			radius[i] = radius[i] or {0,true}
			radius[i][1] = tonumber(radius[i][1] or 0)
			radius[i][2] = radius[i][2] ~= false
		end
		color,texture,colorOverwritten,borderOnly,borderThicknessHorizontal,borderThicknessVertical = relative,color,texture,colorOverwritten,borderOnly,borderThicknessHorizontal
		dgsRoundRectSetRadius(shader,radius)
	end
	if not shader then return false end
	color = color or tocolor(255,255,255,255)
	dgsSetData(shader,"borderOnly",borderOnly)
	if borderOnly then
		dgsRoundRectSetBorderThickness(shader,borderThicknessHorizontal or 0.2,borderThicknessVertical or borderThicknessHorizontal or 0.2)
	end
	dgsRoundRectSetColorOverwritten(shader,colorOverwritten ~= false)
	dgsRoundRectSetTexture(shader,texture)
	dgsRoundRectSetColor(shader,color)
	triggerEvent("onDgsPluginCreate",shader,sourceResource)
	return shader
end

function dgsRoundRectSetTexture(rectShader,texture)
	if not(dgsGetPluginType(rectShader) == "dgs-dxroundrectangle") then error(dgsGenAsrt(rectShader,"dgsRoundRectSetTexture",1,"plugin dgs-dxroundrectangle")) end
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
	if not(dgsGetPluginType(rectShader) == "dgs-dxroundrectangle") then error(dgsGenAsrt(rectShader,"dgsRoundRectSetRadius",1,"plugin dgs-dxroundrectangle")) end
	local radType = dgsGetType(radius)
	if not(radType == "number" or radType == "table") then error(dgsGenAsrt(radius,"dgsRoundRectSetRadius",2,"number/table")) end
	if radType ~= "table" then
		local relative = relative ~= false
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
	if not(dgsGetPluginType(rectShader) == "dgs-dxroundrectangle") then error(dgsGenAsrt(rectShader,"dgsRoundRectGetRadius",1,"plugin dgs-dxroundrectangle")) end
	return dgsElementData[rectShader].radius
end

function dgsRoundRectSetColor(rectShader,color)
	if not(dgsGetPluginType(rectShader) == "dgs-dxroundrectangle") then error(dgsGenAsrt(rectShader,"dgsRoundRectSetColor",1,"plugin dgs-dxroundrectangle")) end
	if not(dgsGetType(color) == "number") then error(dgsGenAsrt(color,"dgsRoundRectSetColor",2,"number")) end
	dxSetShaderValue(rectShader,"color",{fromcolor(color,true,true)})
	dgsSetData(rectShader,"color",color)
	return true
end

function dgsRoundRectGetColor(rectShader)
	if not(dgsGetPluginType(rectShader) == "dgs-dxroundrectangle") then error(dgsGenAsrt(rectShader,"dgsRoundRectGetColor",1,"plugin dgs-dxroundrectangle")) end
	return dgsElementData[rectShader].color
end

function dgsRoundRectGetColorOverwritten(rectShader)
	if not(dgsGetPluginType(rectShader) == "dgs-dxroundrectangle") then error(dgsGenAsrt(rectShader,"dgsRoundRectGetColorOverwritten",1,"plugin dgs-dxroundrectangle")) end
	return dgsElementData[rectShader].colorOverwritten
end

function dgsRoundRectSetColorOverwritten(rectShader,colorOverwritten)
	if not(dgsGetPluginType(rectShader) == "dgs-dxroundrectangle") then error(dgsGenAsrt(rectShader,"dgsRoundRectSetColorOverwritten",1,"plugin dgs-dxroundrectangle")) end
	dxSetShaderValue(rectShader,"colorOverwritten",colorOverwritten)
	return dgsSetData(rectShader,"colorOverwritten",colorOverwritten)
end

function dgsRoundRectSetBorderThickness(rectShader,horizontal,vertical)
	vertical = vertical or horizontal
	if not(dgsGetPluginType(rectShader) == "dgs-dxroundrectangle") then error(dgsGenAsrt(rectShader,"dgsRoundRectSetBorderThickness",1,"plugin dgs-dxroundrectangle")) end
	if not(dgsElementData[rectShader].borderOnly) then error(dgsGenAsrt(rectShader,"dgsRoundRectSetBorderThickness",1,_,_,_,"this round rectangle isn't created with 'border'")) end
	if not(dgsGetType(horizontal) == "number") then error(dgsGenAsrt(horizontal,"dgsRoundRectSetBorderThickness",2,"number")) end
	if dgsElementData[rectShader].borderOnly then
		dgsSetData(rectShader,"borderThickness",{horizontal,vertical})
		dxSetShaderValue(rectShader,"borderThickness",{horizontal,vertical})
		return true
	end
	return false
end

function dgsRoundRectGetBorderThickness(rectShader)
	if not(dgsGetPluginType(rectShader) == "dgs-dxroundrectangle") then error(dgsGenAsrt(rectShader,"dgsRoundRectGetBorderThickness",1,"plugin dgs-dxroundrectangle")) end
	if dgsElementData[rectShader].borderOnly then
		return dgsElementData[rectShader].borderThickness[1],dgsElementData[rectShader].borderThickness[2]
	end
	return false
end

function dgsRoundRectGetBorderOnly(rectShader)
	if not(dgsGetPluginType(rectShader) == "dgs-dxroundrectangle") then error(dgsGenAsrt(rectShader,"dgsRoundRectGetBorderOnly",1,"plugin dgs-dxroundrectangle")) end
	return dgsElementData[rectShader].borderOnly
end