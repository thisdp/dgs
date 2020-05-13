function dgsCreateExternal(externalType,externalRef,renderEvent)
	local external = createElement("dgs-dxexternal")
	table.insert(CenterFatherTable,external)
	dgsSetType(external,"dgs-dxexternal")
	dgsSetData(external,"externalType",externalType)
	dgsSetData(external,"externalRef",externalRef)
	dgsSetData(external,"externalRenderer",renderEvent)
	dgsSetData(external,"externalFunction",{})
	addEvent(renderEvent,true)
	calculateGuiPositionSize(external,0,0,false,0,0,false,true)
	triggerEvent("onDgsCreate",external,sourceResource)
	return external
end

function dgsExternalSetFunctions(external,tab)
	local fncTable = {}
	for k,v in pairs(tab) do
		local fnc,err = loadstring(v)
		assert(fnc,"Bad argument @dgsExternalSetFunctions at argument 2, Failed to load "..k..": "..err)
		fncTable[k] = fnc
	end
	return true
end

----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxexternal"] = function(source,x,y,w,h,mx,my,cx,cy,enabled,eleData,parentAlpha,isPostGUI,rndtgt)
	local renderEvent = eleData.externalRenderer
	if renderEvent then
		triggerEvent(renderEvent,source)
	end
	return rndtgt
end