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
	local _x = dgsIsDxElement(parent) and dgsSetParent(detectarea,parent,true) or table.insert(CenterFatherTable,1,detectarea)
	insertResourceDxGUI(sourceResource,detectarea)
	calculateGuiPositionSize(detectarea,x,y,relative or false,sx,sy,relative or false,true)
	triggerEvent("onDgsCreate",detectarea)
	return detectarea
end