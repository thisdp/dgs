dgsLogLuaMemory()
dgsRegisterPluginType("dgs-dxgradient")

function dgsCreateGradient(colorFrom,colorTo,rotation)
	assert(type(colorFrom) == "number","Bad argument @dgsCreateGradient at argument 1, expect number got "..type(color1))
	assert(type(colorTo) == "number","Bad argument @dgsCreateGradient at argument 2, expect number got "..type(color2))
	local rotation = rotation or 0
	local shader = dxCreateShader("plugin/gradient/gradient.fx")
	dgsSetData(shader,"asPlugin","dgs-dxgradient")
	dgsSetData(shader,"colorFrom",colorFrom)
	dgsSetData(shader,"colorTo",colorTo)
	dgsSetData(shader,"rotation",rotation)
	dxSetShaderValue(shader,"colorFrom",fromcolor(colorFrom,true))
	dxSetShaderValue(shader,"colorTo",fromcolor(colorTo,true))
	dxSetShaderValue(shader,"rotation",rotation)
	dgsTriggerEvent("onDgsPluginCreate",shader,sourceResource)
	return shader 
end

function dgsGradientSetColor(gradShader,colorFrom,colorTo)
	assert(dgsGetPluginType(gradShader) == "dgs-dxgradient","Bad argument @dgsGradientSetColor at argument 1, expect dgs-dxgradient got "..type(gradShader))
	assert(type(colorFrom) == "number","Bad argument @dgsGetGradientColor at argument 2, expect number got "..type(color1))
	assert(type(color2) == "number","Bad argument @dgsGetGradientColor at argument 3, expect number got "..type(color2))
	dgsSetData(gradShader,"colorFrom",colorFrom)
	dgsSetData(gradShader,"colorTo",colorTo)
	dxSetShaderValue(gradShader,"colorFrom",fromcolor(colorFrom,true))
	dxSetShaderValue(gradShader,"colorTo",fromcolor(colorTo,true))
	return true 
end

function dgsGradientGetColor(gradShader,rotation)
	assert(dgsGetPluginType(gradShader) == "dgs-dxgradient","Bad argument @dgsGradientGetColors at argument 1, expect dgs-dxgradient got "..type(gradShader))
	return dgsElementData[gradientShader].colorFrom,dgsElementData[gradientShader].colorTo
end

function dgsGradientSetRotation(gradShader,rotation)
	assert(dgsGetPluginType(gradShader) == "dgs-dxgradient","Bad argument @dgsGradientSetRotation at argument 1, expect dgs-dxgradient got "..type(gradShader))
	dgsSetData(gradShader,"rotation",rotation)
	dxSetShaderValue(gradShader,"rotation",rotation)
	return true 
end

function dgsGradientGetRotation(gradShader)
	assert(dgsGetPluginType(gradShader) == "dgs-dxgradient","Bad argument @dgsGradientGetRotation at argument 1, expect dgs-dxgradient got "..type(gradShader))
	return dgsElementData[gradientShader].rotation
end

function dgsGradientSetTexture(gradShader,texture)
	if not(dgsGetPluginType(gradShader) == "dgs-dxgradient") then error(dgsGenAsrt(gradShader,"dgsGradientSetTexture",1,"plugin dgs-dxgradient")) end
	if isElement(texture) then
		dxSetShaderValue(gradShader,"textureLoad",true)
		dxSetShaderValue(gradShader,"sourceTexture",texture)
		dgsSetData(gradShader,"sourceTexture",texture)
	else
		dxSetShaderValue(gradShader,"textureLoad",false)
		dxSetShaderValue(gradShader,"sourceTexture",0)
		dgsSetData(gradShader,"sourceTexture",nil)
	end
	return true
end

function dgsGradientGetTexture(gradShader)
	if not(dgsGetPluginType(gradShader) == "dgs-dxgradient") then error(dgsGenAsrt(gradShader,"dgsGradientGetTexture",1,"plugin dgs-dxgradient")) end
	return dgsElementData[gradShader].sourceTexture
end

function dgsGradientGetColorOverwritten(gradShader)
	if not(dgsGetPluginType(gradShader) == "dgs-dxgradient") then error(dgsGenAsrt(gradShader,"dgsGradientGetColorOverwritten",1,"plugin dgs-dxgradient")) end
	return dgsElementData[gradShader].colorOverwritten
end

function dgsGradientSetColorOverwritten(gradShader,colorOverwritten)
	if not(dgsGetPluginType(gradShader) == "dgs-dxgradient") then error(dgsGenAsrt(gradShader,"dgsGradientSetColorOverwritten",1,"plugin dgs-dxgradient")) end
	dxSetShaderValue(gradShader,"colorOverwritten",colorOverwritten)
	return dgsSetData(gradShader,"colorOverwritten",colorOverwritten)
end