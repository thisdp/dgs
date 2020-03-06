masks = {
	circle="plugin/mask/mask-Circle.fx",
	backgroundFilter="plugin/mask/mask-BackGroundFilter.fx",
}

function dgsCreateMask(texture1,texture2,settings)
	settings = settings or {}
	assert(dgsGetType(texture1) == "texture","Bad argument @dgsCreateMask at argument 1, expect texture "..dgsGetType(texture1))
	local tex2Type = dgsGetType(texture2)
	local maskResult
	if tex2Type == "string" then
		assert(masks[texture2],"Bad argument @dgsCreateMask at argument 2, mask type "..texture2.." is not supported")
		maskResult = dxCreateShader(masks[texture2])
		dgsSetData(maskResult,"sourceTexture",texture1)
		dxSetShaderValue(maskResult,"sourceTexture",texture1)
		for k,v in pairs(settings) do
			dxSetShaderValue(maskResult,k,v)
			dgsSetData(maskResult,k,v)
		end
		dgsSetData(maskResult,"asPlugin","dgs-dxmask")
		triggerEvent("onDgsPluginCreate",maskResult,sourceResource)
	elseif tex2Type == "texture" then
		maskResult = dxCreateShader("plugin/mask/maskTexture.fx")
		dgsSetData(maskResult,"sourceTexture",texture1)
		dxSetShaderValue(maskResult,"sourceTexture",texture1)
		dgsSetData(maskResult,"maskTexture",texture2)
		dxSetShaderValue(maskResult,"maskTexture",texture2)
		dgsSetData(maskResult,"asPlugin","dgs-dxmask")
		triggerEvent("onDgsPluginCreate",maskResult,sourceResource)
	elseif tex2Type == "shader" then
		maskResult = texture2
		for k,v in pairs(settings) do
			dxSetShaderValue(maskResult,k,v)
			dgsSetData(maskResult,k,v)
		end
		dgsSetData(maskResult,"asPlugin","dgs-dxmask")
		triggerEvent("onDgsPluginCreate",maskResult)
	end
	return maskResult
end

function dgsMaskSetTexture(mask,texture)
	assert(dgsGetPluginType(mask) == "dgs-dxmask","Bad argument @dgsMaskSetTexture at argument 1, expect dgs-dxmask "..dgsGetPluginType(mask))
	dxSetShaderValue(mask,"sourceTexture",texture)
	return dgsSetData(mask,"sourceTexture",texture)
end

function dgsMaskGetTexture(mask)
	assert(dgsGetPluginType(mask) == "dgs-dxmask","Bad argument @dgsMaskGetTexture at argument 1, expect dgs-dxmask "..dgsGetPluginType(mask))
	return dgsElementData[mask].sourceTexture
end

function dgsMaskGetSetting(mask,settingName)
	assert(dgsGetPluginType(mask) == "dgs-dxmask","Bad argument @dgsMaskGetSetting at argument 1, expect dgs-dxmask "..dgsGetPluginType(mask))
	return dgsElementData[mask][settingName]
end

function dgsMaskSetSetting(mask,settingName,value)
	assert(dgsGetPluginType(mask) == "dgs-dxmask","Bad argument @dgsMaskSetSetting at argument 1, expect dgs-dxmask "..dgsGetPluginType(mask))
	dgsSetData(mask,settingName,value)
	assert(dxSetShaderValue(mask,settingName,value),"Bad argument @dgsMaskSetSetting, failed to call dxSetShaderValue")
	return true
end

function dgsMaskCenterTexturePosition(dgsMask,w,h)
	assert(dgsGetPluginType(dgsMask) == "dgs-dxmask","Bad argument @dgsMaskCenterTexturePosition at argument 1, expect dgs-dxmask got "..dgsGetPluginType(dgsMask))
	local ratio = w/h
	local scaleW,scaleH = (ratio>1 and ratio or 1),(1/ratio>1 and 1/ratio or 1)
	dgsMaskSetSetting(dgsMask,"offset",{scaleW/2-0.5,scaleH/2-0.5,1})
end

function dgsMaskAdaptTextureSize(dgsMask,w,h)
	assert(dgsGetPluginType(dgsMask) == "dgs-dxmask","Bad argument @dgsMaskAdaptTextureSize at argument 1, expect dgs-dxmask got "..dgsGetPluginType(dgsMask))
	local ratio = w/h
	local scaleW,scaleH = (ratio>1 and ratio or 1),(1/ratio>1 and 1/ratio or 1)
	dgsMaskSetSetting(dgsMask,"scale",{scaleW,scaleH,1})
end
