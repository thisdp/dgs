dgsLogLuaMemory()
dgsRegisterPluginType("dgs-dxmask")
masks = {
	circle="plugin/mask/mask-Circle.fx",
	backgroundFilter="plugin/mask/mask-BackGroundFilter.fx",
	colorInverter="plugin/mask/mask-ColorInverter.fx",
}

function dgsCreateMask(texture1,texture2,settings)
	settings = settings or {}
	local tex1Type = dgsGetType(texture1)
	if not(isMaterial(texture1) == "texture") then error(dgsGenAsrt(texture1,"dgsCreateMask",1,"texture")) end
	local tex2Type = dgsGetType(texture2)
	local maskResult
	if tex2Type == "string" then
		if not(masks[texture2]) then error(dgsGenAsrt(texture2,"dgsCreateMask",2,"texture",_,_,"unsupported type")) end
		maskResult = dxCreateShader(masks[texture2])
		dgsSetData(maskResult,"sourceTexture",texture1)
		dxSetShaderValue(maskResult,"sourceTexture",texture1)
		for k,v in pairs(settings) do
			dxSetShaderValue(maskResult,k,v)
			dgsSetData(maskResult,k,v)
		end
		dgsSetData(maskResult,"asPlugin","dgs-dxmask")
		dgsTriggerEvent("onDgsPluginCreate",maskResult,sourceResource)
	elseif tex2Type == "texture" or tex2Type == "svg" then
		maskResult = dxCreateShader("plugin/mask/maskTexture.fx")
		dgsSetData(maskResult,"sourceTexture",texture1)
		dxSetShaderValue(maskResult,"sourceTexture",texture1)
		dgsSetData(maskResult,"maskTexture",texture2)
		dxSetShaderValue(maskResult,"maskTexture",texture2)
		dgsSetData(maskResult,"asPlugin","dgs-dxmask")
		dgsTriggerEvent("onDgsPluginCreate",maskResult,sourceResource)
	elseif tex2Type == "shader" then
		maskResult = texture2
		for k,v in pairs(settings) do
			dxSetShaderValue(maskResult,k,v)
			dgsSetData(maskResult,k,v)
		end
		dgsSetData(maskResult,"asPlugin","dgs-dxmask")
		dgsTriggerEvent("onDgsPluginCreate",maskResult)
	end
	return maskResult
end

function dgsMaskSetTexture(mask,texture)
	if not(dgsGetPluginType(mask) == "dgs-dxmask") then error(dgsGenAsrt(mask,"dgsMaskSetTexture",1,"dgs-dxmask")) end
	dxSetShaderValue(mask,"sourceTexture",texture)
	return dgsSetData(mask,"sourceTexture",texture)
end

function dgsMaskGetTexture(mask)
	if not(dgsGetPluginType(mask) == "dgs-dxmask") then error(dgsGenAsrt(mask,"dgsMaskGetTexture",1,"dgs-dxmask")) end
	return dgsElementData[mask].sourceTexture
end

function dgsMaskGetSetting(mask,settingName)
	if not(dgsGetPluginType(mask) == "dgs-dxmask") then error(dgsGenAsrt(mask,"dgsMaskGetSetting",1,"dgs-dxmask")) end
	return dgsElementData[mask][settingName]
end

function dgsMaskSetSetting(mask,settingName,value)
	if not(dgsGetPluginType(mask) == "dgs-dxmask") then error(dgsGenAsrt(mask,"dgsMaskSetSetting",1,"dgs-dxmask")) end
	dgsSetData(mask,settingName,value)
	dxSetShaderValue(mask,settingName,value)
	return true
end

function dgsMaskCenterTexturePosition(mask,w,h)
	if not(dgsGetPluginType(mask) == "dgs-dxmask") then error(dgsGenAsrt(mask,"dgsMaskCenterTexturePosition",1,"dgs-dxmask")) end
	local ratio = w/h
	local scaleW,scaleH = (ratio>1 and ratio or 1),(1/ratio>1 and 1/ratio or 1)
	dgsMaskSetSetting(mask,"offset",{scaleW/2-0.5,scaleH/2-0.5,1})
end

function dgsMaskAdaptTextureSize(mask,w,h)
	if not(dgsGetPluginType(mask) == "dgs-dxmask") then error(dgsGenAsrt(mask,"dgsMaskAdaptTextureSize",1,"dgs-dxmask")) end
	local ratio = w/h
	local scaleW,scaleH = (ratio>1 and ratio or 1),(1/ratio>1 and 1/ratio or 1)
	dgsMaskSetSetting(mask,"scale",{scaleW,scaleH,1})
end
