dgsPluginTable = {}

addEventHandler("onDgsPluginCreate",resourceRoot,function(theResource)
	ChildrenTable[source] = ChildrenTable[source] or {}
	insertResource(theResource,source)
	local typ = dgsElementData[source].asPlugin
	dgsPluginTable[typ] = dgsPluginTable[typ] or {}
	table.insert(dgsPluginTable[typ],source)
	addEventHandler("onDgsDestroy",source,function()
		local id = table.find(dgsPluginTable[typ],source)
		if id then
			table.remove(dgsPluginTable[typ],id)
		end
		if typ == "dgs-dxblurbox" then
			if not(next(dgsPluginTable[typ])) and isElement(BlurBoxGlobalScreenSource) then
				destroyElement(BlurBoxGlobalScreenSource)
			end
		end
	end,false)
end)