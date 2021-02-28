GlobalPasteHandler = false

function dgsEnablePasteHandler()
	if not isElement(GlobalPasteHandler) then
		GlobalPasteHandler = createBrowser(1,1,true,true)
		dgsSetData(GlobalPasteHandler,"asPlugin","dgs-dxpastehandler")
		dgsSetData(GlobalPasteHandler,"isReady",false)
		addEventHandler("onClientBrowserCreated",GlobalPasteHandler,function()
			loadBrowserURL(GlobalPasteHandler,"http://mta/local/plugin/pasteHandler/pasteHandler.html")
		end,false)
		addEventHandler("onClientBrowserDocumentReady",GlobalPasteHandler,function()
			dgsSetData(GlobalPasteHandler,"isReady",true)
		--setDevelopmentMode(true,true)
		--toggleBrowserDevTools(GlobalPasteHandler,true)
		--focusBrowser(GlobalPasteHandler)
		end,false)

		triggerEvent("onDgsPluginCreate",GlobalPasteHandler,sourceResource)

		addEventHandler("DGSI_Paste",GlobalPasteHandler,function(data,theType)
			if theType == "file" then
				local result = base64Decode(split(data,",")[2])
				local texture = dxCreateTexture(result)
				if texture then
					return triggerEvent("onDgsPaste",resourceRoot,texture,theType)
				end
				triggerEvent("onDgsPaste",resourceRoot,result,theType)
			elseif theType == "string" then
				triggerEvent("onDgsPaste",resourceRoot,data,theType)
			end
		end)
		return true
	end
	return false
end

function dgsFocusPasteHandler()
	if isElement(GlobalPasteHandler) then
		focusBrowser(GlobalPasteHandler)
	end
end

function dgsIsPasteHandlerFocused()
	return isElement(GlobalPasteHandler) and isBrowserFocused(GlobalPasteHandler)
end

function dgsBlurPasteHandler()
	if isElement(GlobalPasteHandler) and isBrowserFocused(GlobalPasteHandler) then
		return focusBrowser()
	end
	return false
end

function dgsDisablePasteHandler()
	if isElement(GlobalPasteHandler) then
		return destroyElement(GlobalPasteHandler)
	end
	return false
end

function dgsIsPasteHandlerEnabled()
	return isElement(GlobalPasteHandler)
end