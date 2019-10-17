dgsPluginTable = {}

addEventHandler("onDgsPluginCreate",resourceRoot,function(theResource)
	ChildrenTable[source] = ChildrenTable[source] or {}
	insertResource(theResource,source)
	local typ = dgsElementData[source].asPlugin
	dgsPluginTable[typ] = dgsPluginTable[typ] or {}
	table.insert(dgsPluginTable[typ],source)
end)

addEventHandler("onDgsDestroy",resourceRoot,function()
	local typ = dgsElementData[source].asPlugin
	if typ then
		local id = table.find(dgsPluginTable[typ] or {},source)
		if id then
			table.remove(dgsPluginTable[typ],id)
		end
		if typ == "dgs-dxblurbox" then
			if not(next(dgsPluginTable[typ])) and isElement(BlurBoxGlobalScreenSource) then
				destroyElement(BlurBoxGlobalScreenSource)
			end
		end
	end
end)