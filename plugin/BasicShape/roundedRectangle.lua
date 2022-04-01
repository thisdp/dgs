dgsRegisterPluginType("dgs-dxroundrectangle")

function requestRoundRectangleShader(withoutFilled)
	local f = fileOpen(withoutFilled and "plugin/BasicShape/roundedRectangleFrame.fx" or "plugin/BasicShape/roundedRectangle.fx")
	local str = fileRead(f,fileGetSize(f))
	fileClose(f)
	return str
end

function Old_dgsCreateRoundRect(radius,color,texture,relative)
	assert(dgsGetType(radius) == "number","Bad argument @dgsCreateRoundRect at argument 1, expect number got "..dgsGetType(radius))
	local shader = dxCreateShader(requestRoundRectangleShader())
	local color = color or tocolor(255,255,255,255)
	dgsSetData(shader,"asPlugin","dgs-dxroundrectangle")
	dgsRoundRectSetColorOverwritten(shader,true)
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
dgsLogLuaMemory()