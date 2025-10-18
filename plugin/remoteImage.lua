dgsLogLuaMemory()
dgsRegisterPluginType("dgs-dxremoteimage")
local remoteImagePlaceHolder
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
		dgsRemoteImageAbort(remoteImage)
		local textureRef = dgsElementData[source].textureRef
		if not isElement(textureRef) then return end
		if textureRef ~= remoteImageDefaultImages.unloadedTex and textureRef ~= remoteImageDefaultImages.loadingTex and textureRef ~= remoteImageDefaultImages.failedTex then
			destroyElement(textureRef)
		end
	end,false)
	dgsSetData(remoteImage,"defaultImages",table.shallowCopy(remoteImageDefaultImages))
	dgsSetData(remoteImage,"loadState",0)	--unloaded
	--dgsSetData(remoteImage,"keepTexture",false)
	dgsSetData(remoteImage,"textureRef",dgsElementData[remoteImage].defaultImages.unloadedTex)
	dxSetShaderValue(remoteImage,"textureRef",dgsElementData[remoteImage].defaultImages.unloadedTex) --Change image when state changes
	if website then
		dgsRemoteImageRequest(remoteImage,website)
	end
	dgsTriggerEvent("onDgsPluginCreate",remoteImage,sourceResource)
	return remoteImage
end

function dgsRemoteImageRequest(remoteImage,website,forceReload)
	if not(dgsGetPluginType(remoteImage) == "dgs-dxremoteimage") then error(dgsGenAsrt(remoteImage,"dgsRemoteImageRequest",1,"plugin dgs-dxremoteimage")) end
	if not(type(website) == "string") then error(dgsGenAsrt(remoteImage,"dgsRemoteImageRequest",2,"string")) end
	local loadState = dgsElementData[remoteImage].loadState
	if loadState == 1 then	--make sure it is not loading
		if not forceReload then
			return false
		end
		dgsRemoteImageAbort(remoteImage)	--if forceReload then aborted automatically
	end
	dgsSetData(remoteImage,"loadState",1)	--loading
	local host = parseHostFromURL(website)
	if isBrowserDomainBlocked(host) then	 --Blocked
		requestBrowserDomains({host},false,function(accepted, newDomains)
			if accepted then 
				dgsRemoteImageDoRequest(remoteImage,website)
			else
				dgsSetData(remoteImage,"loadState",3)	--Failed
				if isElement(dgsElementData[remoteImage].defaultImages.failedTex) then
					dxSetShaderValue(remoteImage,"textureRef",dgsElementData[remoteImage].defaultImages.failedTex)  --Change image when state changes
				end
			end
		end)
	else
		dgsRemoteImageDoRequest(remoteImage,website)
	end
end

function dgsRemoteImageDoRequest(remoteImage,website)
	if not(dgsGetPluginType(remoteImage) == "dgs-dxremoteimage") then error(dgsGenAsrt(remoteImage,"dgsRemoteImageDoRequest",1,"plugin dgs-dxremoteimage")) end
	if not(type(website) == "string") then error(dgsGenAsrt(remoteImage,"dgsRemoteImageDoRequest",2,"string")) end
	local frHandler = fetchRemote(website,{
		["queueName"] = tostring(remoteImage),	--Use unique queue
	},function(data,response)
		dgsOnRemoteImageReceive(remoteImage,data,response)
	end)
	dgsSetData(remoteImage,"fetchRemoteHandler",frHandler)
end

function dgsRemoteImageAbort(remoteImage)
	if not(dgsGetPluginType(remoteImage) == "dgs-dxremoteimage") then error(dgsGenAsrt(remoteImage,"dgsRemoteImageAbort",1,"plugin dgs-dxremoteimage")) end
	local fetchRemoteHandler = dgsElementData[remoteImage].fetchRemoteHandler
	if not fetchRemoteHandler then return true end
	local index = table.find(getRemoteRequests(),fetchRemoteHandler)
	dgsElementData[remoteImage].fetchRemoteHandler = nil	-- Already Done
	if not index then return true end
	abortRemoteRequest(fetchRemoteHandler)
end

function dgsRemoteImageGetTexture(remoteImage)
	return dgsElementData[remoteImage].textureRef
end

function dgsGetRemoteImageLoadState(remoteImage)
	if not(dgsGetPluginType(remoteImage) == "dgs-dxremoteimage") then error(dgsGenAsrt(remoteImage,"dgsGetRemoteImageLoadState",1,"plugin dgs-dxremoteimage")) end
	return dgsElementData[remoteImage].loadState
end

function dgsOnRemoteImageReceive(remoteImage,data,response)
	if not isElement(remoteImage) then return end
	local textureRef = dgsElementData[remoteImage].textureRef
	if isElement(textureRef) and not dgsElementData[remoteImage].keepTexture then
		if textureRef ~= remoteImageDefaultImages.unloadedTex and textureRef ~= remoteImageDefaultImages.loadingTex and textureRef ~= remoteImageDefaultImages.failedTex then
			destroyElement(textureRef)
		end
	end
	if response.success then
		local texture = dxCreateTexture(data)
		dgsSetData(texture,"DGSContainer",remoteImage)
		addEventHandler("onClientElementDestroy",texture,function()
			remoteImage = dgsElementData[texture].DGSContainer
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
	dgsTriggerEvent("onDgsRemoteImageLoad",remoteImage,response)
end

--------------Shader
remoteImagePlaceHolder = [[
texture textureRef;
technique remoteImage{
	Pass P0{
		Texture[0] = textureRef;
	}
}]]