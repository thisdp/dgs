dgsLogLuaMemory()
dgsRegisterPluginType("dgs-dxpastehandler")
GlobalPasteHandler = false

function dgsPasteHandlerSetEnabled(state)
	if not state and isElement(GlobalPasteHandler) then
		return destroyElement(GlobalPasteHandler)
	elseif state and not isElement(GlobalPasteHandler) then
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

		dgsTriggerEvent("onDgsPluginCreate",GlobalPasteHandler,sourceResource)

		addEventHandler("DGSI_Paste",GlobalPasteHandler,function(data,theType)
			if theType == "file" then
				local result = base64Decode(split(data,",")[2])
				return dgsTriggerEvent("onDgsPaste",resourceRoot,result,theType)
			elseif theType == "string" then
				return dgsTriggerEvent("onDgsPaste",resourceRoot,data,theType)
			end
		end)
	end
	return true
end

function dgsPasteHandlerSetFocused(state)
	if state then
		if isElement(GlobalPasteHandler) then
			return focusBrowser(GlobalPasteHandler)
		end
	else
		if isElement(GlobalPasteHandler) and isBrowserFocused(GlobalPasteHandler) then
			return focusBrowser()
		end
	end
	return false
end

function dgsPasteHandlerIsFocused()
	return isElement(GlobalPasteHandler) and isBrowserFocused(GlobalPasteHandler)
end

function dgsPasteHandlerIsEnabled()
	return isElement(GlobalPasteHandler)
end