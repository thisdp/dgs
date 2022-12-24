dgsLogLuaMemory()
dgsRegisterPluginType("dgs-dxcircle")

function requestCircleShader()
	local f = fileOpen("plugin/BasicShape/circle.fx")
	local str = fileRead(f,fileGetSize(f))
	fileClose(f)
	return str
end

function dgsCreateCircle(outsideRadius,insideRadius,angle,color,texture)
	local circle = dxCreateShader(requestCircleShader())
	if not circle then return false end
	dgsSetData(circle,"asPlugin","dgs-dxcircle")
	dgsCircleSetColorOverwritten(circle,true)
	dgsCircleSetRadius(circle,outsideRadius or 0.5,insideRadius or 0.2)
	dgsCircleSetTexture(circle,texture)
	dgsCircleSetColor(circle,color or tocolor(255,255,255,255))
	dgsCircleSetAngle(circle,angle or 360)
	dgsTriggerEvent("onDgsPluginCreate",circle,sourceResource)
	return circle
end

function dgsCircleSetRadius(circle,outsideRadius,insideRadius)
	if not(dgsGetPluginType(circle) == "dgs-dxcircle") then error(dgsGenAsrt(circle,"dgsCircleSetOutsideRadius",1,"plugin dgs-dxcircle")) end
	local outside,inside = outsideRadius or dgsElementData[circle].outsideRadius,insideRadius or dgsElementData[circle].insideRadius
	dxSetShaderValue(circle,"outsideRadius",outside)
	dxSetShaderValue(circle,"insideRadius",inside)
	return dgsSetData(circle,"outsideRadius",outside) and dgsSetData(circle,"insideRadius",inside) 
end

function dgsCircleGetRadius(circle)
	if not(dgsGetPluginType(circle) == "dgs-dxcircle") then error(dgsGenAsrt(circle,"dgsCircleGetRadius",1,"plugin dgs-dxcircle")) end
	return dgsElementData[circle].outsideRadius,dgsElementData[circle].insideRadius
end

function dgsCircleSetTexture(circle,texture)
	if not(dgsGetPluginType(circle) == "dgs-dxcircle") then error(dgsGenAsrt(circle,"dgsCircleSetTexture",1,"plugin dgs-dxcircle")) end
	if isElement(texture) then
		if not(isMaterial(texture) == "texture") then error(dgsGenAsrt(dgsCircleSetTexture,"dgsCreateMask",1,"texture")) end
		dxSetShaderValue(circle,"textureLoad",true)
		dxSetShaderValue(circle,"sourceTexture",texture)
		dgsSetData(circle,"sourceTexture",texture)
	else
		dxSetShaderValue(circle,"textureLoad",false)
		dxSetShaderValue(circle,"sourceTexture",0)
		dgsSetData(circle,"sourceTexture",nil)
	end
	return true
end

function dgsCircleGetTexture(circle)
	if not(dgsGetPluginType(circle) == "dgs-dxcircle") then error(dgsGenAsrt(circle,"dgsCircleGetTexture",1,"plugin dgs-dxcircle")) end
	return dgsElementData[circle].sourceTexture
end

function dgsCircleSetTextureRotation(circle,rot,rotCenterX,rotCenterY)
	if not(dgsGetPluginType(circle) == "dgs-dxcircle") then error(dgsGenAsrt(circle,"dgsCircleSetTextureRotation",1,"plugin dgs-dxcircle")) end
	if not(type(rot) == "number") then error(dgsGenAsrt(rot,"dgsCircleSetTextureRotation",2,"number")) end
	local rotCenter = dgsElementData[circle].textureRotCenter
	if not rotCenter then
		rotCenterX = rotCenterX or 0
		rotCenterY = rotCenterY or 0
	else
		rotCenterX = rotCenterX or rotCenter[1]
		rotCenterY = rotCenterY or rotCenter[2]
	end
	dxSetShaderValue(circle,"textureRot",rot)
	dxSetShaderValue(circle,"textureRotCenter",{rotCenterX,rotCenterY})
	dgsSetData(circle,"textureRot",rot)
	dgsSetData(circle,"textureRotCenter",{rotCenterX,rotCenterY})
	return true
end

function dgsCircleGetTextureRotation(circle)
	if not(dgsGetPluginType(circle) == "dgs-dxcircle") then error(dgsGenAsrt(circle,"dgsCircleGetTextureRotation",1,"plugin dgs-dxcircle")) end
	local rot = dgsElementData[circle].textureRot or 0
	local rotCenter = dgsElementData[circle].textureRotCenter
	if not rotCenter then
		return rot,0,0
	end
	return rot,rotCenter[1],rotCenter[2]
end

function dgsCircleSetColor(circle,color)
	if not(dgsGetPluginType(circle) == "dgs-dxcircle") then error(dgsGenAsrt(circle,"dgsCircleSetColor",1,"plugin dgs-dxcircle")) end
	if not(type(color) == "number") then error(dgsGenAsrt(color,"dgsCircleSetColor",2,"number")) end
	dxSetShaderValue(circle,"color",fromcolor(color,true))
	return dgsSetData(circle,"color",color)
end

function dgsCircleGetColor(circle)
	if not(dgsGetPluginType(circle) == "dgs-dxcircle") then error(dgsGenAsrt(circle,"dgsCircleGetColor",1,"plugin dgs-dxcircle")) end
	return dgsElementData[circle].color
end

function dgsCircleSetColorOverwritten(circle,colorOverwritten)
	if not(dgsGetPluginType(circle) == "dgs-dxcircle") then error(dgsGenAsrt(circle,"dgsCircleSetColorOverwritten",1,"plugin dgs-dxcircle")) end
	if not(type(colorOverwritten) == "boolean") then error(dgsGenAsrt(colorOverwritten,"dgsCircleSetColorOverwritten",2,"boolean")) end
	dxSetShaderValue(circle,"colorOverwritten",colorOverwritten)
	return dgsSetData(circle,"colorOverwritten",colorOverwritten)
end

function dgsCircleGetColorOverwritten(circle)
	if not(dgsGetPluginType(circle) == "dgs-dxcircle") then error(dgsGenAsrt(circle,"dgsCircleGetColorOverwritten",1,"plugin dgs-dxcircle")) end
	return dgsElementData[circle].colorOverwritten
end

function dgsCircleSetDirection(circle,direction) --true:anticlockwise; false:clockwise
	if not(dgsGetPluginType(circle) == "dgs-dxcircle") then error(dgsGenAsrt(circle,"dgsCircleSetDirection",1,"plugin dgs-dxcircle")) end
	if not(type(direction) == "boolean") then error(dgsGenAsrt(direction,"dgsCircleSetDirection",2,"boolean")) end
	dxSetShaderValue(circle,"direction",direction and 1 or 0)
	return dgsSetData(circle,"direction",direction and 1 or 0)
end

function dgsCircleGetDirection(circle)
	if not(dgsGetPluginType(circle) == "dgs-dxcircle") then error(dgsGenAsrt(circle,"dgsCircleGetDirection",1,"plugin dgs-dxcircle")) end
	return dgsElementData[circle].direction == 1
end

function dgsCircleSetAngle(circle,angle)
	if not(dgsGetPluginType(circle) == "dgs-dxcircle") then error(dgsGenAsrt(circle,"dgsCircleSetAngle",1,"plugin dgs-dxcircle")) end
	if not(type(angle) == "number") then error(dgsGenAsrt(angle,"dgsCircleSetAngle",2,"number")) end
	dxSetShaderValue(circle,"angle",angle/180*math.pi)
	return dgsSetData(circle,"angle",angle/180*math.pi)
end

function dgsCircleGetAngle(circle)
	if not(dgsGetPluginType(circle) == "dgs-dxcircle") then error(dgsGenAsrt(circle,"dgsCircleGetAngle",1,"plugin dgs-dxcircle")) end
	return dgsElementData[circle].angle*180/math.pi
end