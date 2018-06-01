function dgsCreateDetectArea(x,y,sx,sy,strfnc,relative,parent,color)
	assert(tonumber(x),"Bad argument @dgsCreateDetectArea at argument 1, expect number got "..type(x))
	assert(tonumber(y),"Bad argument @dgsCreateDetectArea at argument 2, expect number got "..type(y))
	assert(tonumber(sx),"Bad argument @dgsCreateDetectArea at argument 3, expect number got "..type(sx))
	assert(tonumber(sy),"Bad argument @dgsCreateDetectArea at argument 4, expect number got "..type(sy))
	assert(tonumber(strfnc),"Bad argument @dgsCreateDetectArea at argument 5, expect string got "..type(strfnc))
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"Bad argument @dgsCreateDetectArea at argument 7, expect dgs-dxgui got "..dgsGetType(parent))
	end
	local detectarea = createElement("dgs-dxdetectarea")
	dgsSetType(detectarea,"dgs-dxdetectarea")
	if isElement(parent) then
		dgsSetParent(detectarea,parent)
	else
		table.insert(CenterFatherTable,detectarea)
	end
	insertResourceDxGUI(sourceResource,detectarea)
	triggerEvent("onDgsPreCreate",detectarea)
	calculateGuiPositionSize(detectarea,x,y,relative or false,sx,sy,relative or false,true)
	triggerEvent("onDgsCreate",detectarea)
	return detectarea
end