dgsLogLuaMemory()
dgsRegisterPluginType("dgs-dxroundrectangle")

function dgsCreateRoundRect(radius,relative,color,texture,colorOverwritten,borderOnlyOrColor,borderThicknessHorizontal,borderThicknessVertical)
	local radType = dgsGetType(radius)
	if not(radType == "number" or radType == "table") then error(dgsGenAsrt(radius,"dgsCreateRoundRect",1,"number/table")) end
	local shader = dxCreateShader("plugin/BasicShape/roundedRectangle.fx")
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
		color,texture,colorOverwritten,borderOnlyOrColor,borderThicknessHorizontal,borderThicknessVertical = relative,color,texture,colorOverwritten,borderOnlyOrColor,borderThicknessHorizontal
		dgsRoundRectSetRadius(shader,radius)
	end
	if not shader then return false end
	color = color or tocolor(255,255,255,255)
	if type(borderOnlyOrColor) == "number" then
		dgsRoundRectSetBorderThickness(shader,borderThicknessHorizontal or 0.2,borderThicknessVertical or borderThicknessHorizontal or 0.2)
		dgsRoundRectSetColor(shader,color,borderOnlyOrColor)
	else
		dgsSetData(shader,"borderOnly",borderOnlyOrColor)
		if borderOnlyOrColor then
			dgsRoundRectSetBorderThickness(shader,borderThicknessHorizontal or 0.2,borderThicknessVertical or borderThicknessHorizontal or 0.2)
			dgsRoundRectSetColor(shader,color,color)
		else
			dgsRoundRectSetBorderThickness(shader,0,0)
			dgsRoundRectSetColor(shader,color,color)
		end
	end
	dgsRoundRectSetColorOverwritten(shader,colorOverwritten ~= false)
	dgsRoundRectSetTexture(shader,texture)
	dgsTriggerEvent("onDgsPluginCreate",shader,sourceResource)
	return shader
end

function dgsRoundRectSetTexture(rectShader,texture)
	if not(dgsGetPluginType(rectShader) == "dgs-dxroundrectangle") then error(dgsGenAsrt(rectShader,"dgsRoundRectSetTexture",1,"plugin dgs-dxroundrectangle")) end
	if isElement(texture) then
		if not(isMaterial(texture) == "texture") then error(dgsGenAsrt(dgsCircleSetTexture,"dgsRoundRectSetTexture",1,"texture")) end
		dxSetShaderValue(rectShader,"textureLoad",true)
		dxSetShaderValue(rectShader,"sourceTexture",texture)
		dgsSetData(rectShader,"sourceTexture",texture)
	else
		dxSetShaderValue(rectShader,"textureLoad",false)
		dxSetShaderValue(rectShader,"sourceTexture",0)
		dgsSetData(rectShader,"sourceTexture",nil)
	end
	return true
end

function dgsRoundRectGetTexture(rectShader)
	if not(dgsGetPluginType(rectShader) == "dgs-dxroundrectangle") then error(dgsGenAsrt(rectShader,"dgsRoundRectGetTexture",1,"plugin dgs-dxroundrectangle")) end
	return dgsElementData[rectShader].sourceTexture
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

function dgsRoundRectSetColor(rectShader,color,secondColor)
	if not(dgsGetPluginType(rectShader) == "dgs-dxroundrectangle") then error(dgsGenAsrt(rectShader,"dgsRoundRectSetColor",1,"plugin dgs-dxroundrectangle")) end
	if not(dgsGetType(color) == "number") then error(dgsGenAsrt(color,"dgsRoundRectSetColor",2,"number")) end
	if not(dgsGetType(secondColor) == "number" or not secondColor) then error(dgsGenAsrt(color,"dgsRoundRectSetColor",3,"number/nil")) end
	local borderOnly = dgsElementData[rectShader].borderOnly
	if borderOnly then
		local r,g,b,a = fromcolor(color,true)
		dxSetShaderValue(rectShader,"borderColor",r,g,b,a)
		dgsSetData(rectShader,"borderColor",color)
		dxSetShaderValue(rectShader,"color",r,g,b,0)
		dgsSetData(rectShader,"color",tocolor(r,g,b,0))
	else
		if secondColor then
			dxSetShaderValue(rectShader,"borderColor",fromcolor(secondColor,true))
			dxSetShaderValue(rectShader,"color",fromcolor(color,true))
			dgsSetData(rectShader,"borderColor",secondColor)
			dgsSetData(rectShader,"color",color)
		else
			dxSetShaderValue(rectShader,"borderColor",fromcolor(color,true))
			dgsSetData(rectShader,"borderColor",color)
			dxSetShaderValue(rectShader,"color",fromcolor(color,true))
			dgsSetData(rectShader,"color",color)
		end
	end
	return true
end

function dgsRoundRectGetColor(rectShader)
	if not(dgsGetPluginType(rectShader) == "dgs-dxroundrectangle") then error(dgsGenAsrt(rectShader,"dgsRoundRectGetColor",1,"plugin dgs-dxroundrectangle")) end
	return dgsElementData[rectShader].color,dgsElementData[rectShader].borderColor
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
	if not(dgsGetType(horizontal) == "number") then error(dgsGenAsrt(horizontal,"dgsRoundRectSetBorderThickness",2,"number")) end
	dgsSetData(rectShader,"borderThickness",{horizontal,vertical})
	dxSetShaderValue(rectShader,"borderThickness",{horizontal,vertical})
	return true
end

function dgsRoundRectGetBorderThickness(rectShader)
	if not(dgsGetPluginType(rectShader) == "dgs-dxroundrectangle") then error(dgsGenAsrt(rectShader,"dgsRoundRectGetBorderThickness",1,"plugin dgs-dxroundrectangle")) end
	return dgsElementData[rectShader].borderThickness[1],dgsElementData[rectShader].borderThickness[2]
end

function dgsRoundRectGetBorderOnly(rectShader)
	if not(dgsGetPluginType(rectShader) == "dgs-dxroundrectangle") then error(dgsGenAsrt(rectShader,"dgsRoundRectGetBorderOnly",1,"plugin dgs-dxroundrectangle")) end
	return dgsElementData[rectShader].borderOnly
end