function dgsCreateExternal(externalType,externalRef,renderEvent)
	local external = createElement("dgs-dxexternal")
	table.insert(CenterFatherTable,external)
	dgsSetType(external,"dgs-dxexternal")
	dgsSetData(external,"externalType",externalType)
	dgsSetData(external,"externalRef",externalRef)
	dgsSetData(external,"externalRenderer",renderEvent)
	addEvent(renderEvent,true)
	calculateGuiPositionSize(external,0,0,false,0,0,false,true)
	triggerEvent("onDgsCreate",external,sourceResource)
	return external
end
