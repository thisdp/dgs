local remoteImagePlaceHolder
remoteImageQueue = {}
remoteImageDefaultImages = {
	unloadedTex = DGSBuiltInTex.transParent_1x1,
	loadingTex = DGSBuiltInTex.transParent_1x1,
	failedTex = DGSBuiltInTex.transParent_1x1,
}
--[[
	loadState:
		0 = unloaded
		1 = loading
		2 = loaded
		3 = failed
]]
function dgsCreateRemoteImage(website)
	local remoteImage = dxCreateShader(remoteImagePlaceHolder)
	dgsSetData(remoteImage,"asPlugin","dgs-dxremoteimage")
	addEventHandler("onClientElementDestroy",remoteImage,function()
		if isElement(dgsElementData[source].textureRef) then
			destroyElement(dgsElementData[source].textureRef)
		end
	end,false)
	dgsSetData(remoteImage,"defaultImages",table.shallowCopy(remoteImageDefaultImages))
	dgsSetData(remoteImage,"loadState",0)	--unloaded
	dgsSetData(remoteImage,"textureRef",false)
	dxSetShaderValue(remoteImage,"textureRef",dgsElementData[remoteImage].defaultImages.unloadedTex) --Change image when state changes
	if website then
		dgsRemoteImageRequest(remoteImage,website)
	end
	triggerEvent("onDgsPluginCreate",remoteImage,sourceResource)
	return remoteImage
end

function dgsRemoteImageRequest(remoteImage,website,forceReload)
	assert(dgsGetPluginType(remoteImage) == "dgs-dxremoteimage","Bad argument @dgsRemoteImageRequest at argument 1, expect dgs-dxremoteimage got "..dgsGetPluginType(website))
	assert(type(website) == "string","Bad argument @dgsRemoteImageRequest at argument 2, expect string got "..dgsGetType(website))
	local loadState = dgsElementData[remoteImage].loadState
	if loadState == 1 then	--make sure it is not loading
		if not forceReload then
			return false
		end
		dgsRemoteImageAbort(remoteImage)	--if forceReload then aborted automatically
	end
	dgsSetData(remoteImage,"loadState",1)	--loading
	dgsSetData(remoteImage,"url",{website})
	local index = math.seekEmpty(remoteImageQueue)
	remoteImageQueue[index] = remoteImage
	dgsSetData(remoteImage,"queueIndex",index)
	return triggerServerEvent("DGSI_RequestRemoteImage",resourceRoot,website,index)
end

function dgsRemoteImageAbort(remoteImage)
	assert(dgsGetPluginType(remoteImage) == "dgs-dxremoteimage","Bad argument @dgsRemoteImageAbort at argument 1, expect dgs-dxremoteimage got "..dgsGetPluginType(website))
	local queueIndex = dgsElementData[remoteImage].queueIndex
	remoteImageQueue[queueIndex] = "aborted"
end

function dgsRemoteImageGetTexture(remoteImage)
	return dgsElementData[remoteImage].textureRef
end

function dgsGetRemoteImageLoadState(remoteImage)
	assert(dgsGetPluginType(remoteImage) == "dgs-dxremoteimage","Bad argument @dgsGetRemoteImageLoadState at argument 1, expect dgs-dxremoteimage "..dgsGetPluginType(remoteImage))
	return dgsElementData[remoteImage].loadState
end

addEventHandler("DGSI_ReceiveRemoteImage",resourceRoot,function(data,response,index)
	local remoteImage = remoteImageQueue[index]
	remoteImageQueue[index] = nil
	if isElement(remoteImage) then
		if response.success then
			local texture = dxCreateTexture(data)
			dgsSetData(texture,"DGSContainer",remoteImage)
			addEventHandler("onClientElementDestroy",texture,function()
				local remoteImage = dgsElementData[texture].DGSContainer
				if isElement(remoteImage) then
					dgsSetData(remoteImage,"textureRef",false)
					dgsSetData(remoteImage,"loadState",0)	--Unload
					if isElement(dgsElementData[remoteImage].defaultImages.unloadedTex) then
						dxSetShaderValue(remoteImage,"textureRef",dgsElementData[remoteImage].defaultImages.unloadedTex)  --Change image when state changes
					end
				end
			end,false)
			dgsSetData(remoteImage,"loadState",2)	--Successful
			dgsSetData(remoteImage,"textureRef",texture)
			dxSetShaderValue(remoteImage,"textureRef",texture)
		else
			dgsSetData(remoteImage,"loadState",0)	--Failed
			if isElement(dgsElementData[remoteImage].defaultImages.unloadedTex) then
				dxSetShaderValue(remoteImage,"textureRef",dgsElementData[remoteImage].defaultImages.unloadedTex)  --Change image when state changes
			end
		end
		triggerEvent("onDgsRemoteImageLoad",remoteImage,response)
	end
end)

--------------Shader
remoteImagePlaceHolder = [[
texture textureRef;

technique remoteImage {
	Pass P0 {
		Texture[0] = textureRef;
	}
}
]]
