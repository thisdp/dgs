function dgsDxCreateEDA(x,y,sx,sy,relative,parent)
	assert(type(x) == "number","Bad argument @dgsDxCreateEDA at argument 1, expect number got "..type(x))
	assert(type(y) == "number","Bad argument @dgsDxCreateEDA at argument 2, expect number got "..type(y))
	assert(type(sx) == "number","Bad argument @dgsDxCreateEDA at argument 3, expect number got "..type(sx))
	assert(type(sy) == "number","Bad argument @dgsDxCreateEDA at argument 4, expect number got "..type(sy))
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"@dgsDxCreateEDA argument 5,expect dgs-dxgui got "..dgsGetType(parent))
	end
	local eda = createElement("dgs-dxeda")
	dgsSetType(eda,"dgs-dxeda")
	if isElement(parent) then
		dgsSetParent(eda,parent)
	else
		table.insert(MaxFatherTable,eda)
	end
	insertResourceDxGUI(sourceResource,eda)
	triggerEvent("onClientDgsDxGUIPreCreate",eda)
	calculateGuiPositionSize(eda,x,y,relative or false,sx,sy,relative or false,true)
	triggerEvent("onClientDgsDxGUICreate",eda)
	return eda
end

function dgsDxEDASetDebugModeEnabled(eda,debug)
	assert(dgsGetType(eda) == "dgs-dxeda","Bad argument @dgsDxEDASetDebugModeEnabled at argument 1, expect dgs-dxeda got "..dgsGetType(eda))
	if not debug then
		if isElement(dgsElementData[v].debugShader) then
			destroyElement(dgsElementData[v].debugShader)
			dgsElementData[v].debugShader = nil
		end
	end
	dgsSetData(eda,"debug",debug and debug or false)
	return true
end

function dgsDxEDAGetDebugModeEnabled(eda)
	assert(dgsGetType(eda) == "dgs-dxeda","Bad argument @dgsDxEDAGetDebugModeEnabled at argument 1, expect dgs-dxeda got "..dgsGetType(eda))
	return dgsElementData[eda].debug
end

function dgsDxCheckRadius(eda,mx,my)
	if mx and my then
		local x,y = dgsGetPosition(eda,false,true)
		local size = dgsElementData[eda].absSize
		if ((mx-x-size[1]/2)/size[1]*2)^2+((my-y-size[2]/2)/size[2]*2)^2 <= 1 then
			return true
		end
	end
	return false
end
