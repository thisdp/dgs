dgsLogLuaMemory()
dgsRegisterPluginType("dgs-dxquad")

local mathClamp = math.clamp

function requestQuadShader()
	local f = fileOpen("plugin/BasicShape/quadrilateral.fx")
	local str = fileRead(f,fileGetSize(f))
	fileClose(f)
	return str
end

function dgsCreateQuad(points,color,texture)
	local quad = dxCreateShader(requestQuadShader())
	if not quad then return false end
	dxSetShaderValue(quad,"vertices",points)
	dxSetShaderValue(quad,"sourceTexture",DGSBuiltInTex.white_1x1)
	dgsSetData(quad,"asPlugin","dgs-dxquad")
	dgsQuadSetColorOverwritten(quad,true)
	dgsQuadSetTexture(quad,texture)
	dgsQuadSetColor(quad,color or tocolor(255,255,255,255))
	dgsQuadSetRotation(quad,0)
	dgsTriggerEvent("onDgsPluginCreate",quad,sourceResource)
	return quad
end

function dgsQuadSetTexture(quad,texture)
	if not(dgsGetPluginType(quad) == "dgs-dxquad") then error(dgsGenAsrt(quad,"dgsQuadSetTexture",1,"plugin dgs-dxquad")) end
	if isElement(texture) then
		if not(isMaterial(texture) == "texture") then error(dgsGenAsrt(dgsQuadSetTexture,"dgsQuadSetTexture",1,"texture")) end
		dxSetShaderValue(quad,"sourceTexture",texture)
		dgsSetData(quad,"sourceTexture",texture)
	else
		dxSetShaderValue(quad,"sourceTexture",DGSBuiltInTex.white_1x1)
		dgsSetData(quad,"sourceTexture",nil)
	end
	return true
end

function dgsQuadGetTexture(quad)
	if not(dgsGetPluginType(quad) == "dgs-dxquad") then error(dgsGenAsrt(quad,"dgsQuadGetTexture",1,"plugin dgs-dxquad")) end
	return dgsElementData[quad].sourceTexture
end

function dgsQuadSetTextureRotation(quad,rot,rotCenterX,rotCenterY)
	if not(dgsGetPluginType(quad) == "dgs-dxquad") then error(dgsGenAsrt(quad,"dgsQuadSetTextureRotation",1,"plugin dgs-dxquad")) end
	if not(type(rot) == "number") then error(dgsGenAsrt(rot,"dgsQuadSetTextureRotation",2,"number")) end
	local rotCenter = dgsElementData[quad].textureRotCenter
	if not rotCenter then
		rotCenterX = rotCenterX or 0
		rotCenterY = rotCenterY or 0
	else
		rotCenterX = rotCenterX or rotCenter[1]
		rotCenterY = rotCenterY or rotCenter[2]
	end
	dxSetShaderValue(quad,"textureRot",rot)
	dxSetShaderValue(quad,"textureRotCenter",{rotCenterX,rotCenterY})
	dgsSetData(quad,"textureRot",rot)
	dgsSetData(quad,"textureRotCenter",{rotCenterX,rotCenterY})
	return true
end

function dgsQuadGetTextureRotation(quad)
	if not(dgsGetPluginType(quad) == "dgs-dxquad") then error(dgsGenAsrt(quad,"dgsQuadGetTextureRotation",1,"plugin dgs-dxquad")) end
	local rot = dgsElementData[quad].textureRot or 0
	local rotCenter = dgsElementData[quad].textureRotCenter
	if not rotCenter then
		return rot,0,0
	end
	return rot,rotCenter[1],rotCenter[2]
end

function dgsQuadSetColor(quad,color)
	if not(dgsGetPluginType(quad) == "dgs-dxquad") then error(dgsGenAsrt(quad,"dgsQuadSetColor",1,"plugin dgs-dxquad")) end
	if not(type(color) == "number") then error(dgsGenAsrt(color,"dgsQuadSetColor",2,"number")) end
	dxSetShaderValue(quad,"color",fromcolor(color,true))
	return dgsSetData(quad,"color",color)
end

function dgsQuadGetColor(quad)
	if not(dgsGetPluginType(quad) == "dgs-dxquad") then error(dgsGenAsrt(quad,"dgsQuadGetColor",1,"plugin dgs-dxquad")) end
	return dgsElementData[quad].color
end

function dgsQuadSetColorOverwritten(quad,colorOverwritten)
	if not(dgsGetPluginType(quad) == "dgs-dxquad") then error(dgsGenAsrt(quad,"dgsQuadSetColorOverwritten",1,"plugin dgs-dxquad")) end
	if not(type(colorOverwritten) == "boolean") then error(dgsGenAsrt(colorOverwritten,"dgsQuadSetColorOverwritten",2,"boolean")) end
	dxSetShaderValue(quad,"colorOverwritten",colorOverwritten)
	return dgsSetData(quad,"colorOverwritten",colorOverwritten)
end

function dgsQuadGetColorOverwritten(quad)
	if not(dgsGetPluginType(quad) == "dgs-dxquad") then error(dgsGenAsrt(quad,"dgsQuadGetColorOverwritten",1,"plugin dgs-dxquad")) end
	return dgsElementData[quad].colorOverwritten
end

function dgsQuadSetRotation(quad,rot)
	if not(dgsGetPluginType(quad) == "dgs-dxquad") then error(dgsGenAsrt(quad,"dgsQuadSetRotation",1,"plugin dgs-dxquad")) end
	if not(type(rot) == "number") then error(dgsGenAsrt(rot,"dgsQuadSetRotation",2,"number")) end
	dxSetShaderValue(quad,"rotation",rot)
	return dgsSetData(quad,"rotation",rot)
end

function dgsQuadGetRotation(quad)
	if not(dgsGetPluginType(quad) == "dgs-dxquad") then error(dgsGenAsrt(quad,"dgsQuadGetRotation",1,"plugin dgs-dxquad")) end
	return dgsElementData[quad].rotation
end