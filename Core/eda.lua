function dgsCreateEDA(x,y,sx,sy,relative,parent)
	assert(type(x) == "number","Bad argument @dgsCreateEDA at argument 1, expect number got "..type(x))
	assert(type(y) == "number","Bad argument @dgsCreateEDA at argument 2, expect number got "..type(y))
	assert(type(sx) == "number","Bad argument @dgsCreateEDA at argument 3, expect number got "..type(sx))
	assert(type(sy) == "number","Bad argument @dgsCreateEDA at argument 4, expect number got "..type(sy))
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"@dgsCreateEDA argument 5,expect dgs-dxgui got "..dgsGetType(parent))
	end
	local eda = createElement("dgs-dxeda")
	local _x = dgsIsDxElement(parent) and dgsSetParent(eda,parent,true,true) or table.insert(CenterFatherTable,1,eda)
	dgsSetType(eda,"dgs-dxeda")
	dgsSetData(eda,"renderBuffer",{})
	insertResourceDxGUI(sourceResource,eda)
	calculateGuiPositionSize(eda,x,y,relative or false,sx,sy,relative or false,true)
	triggerEvent("onDgsCreate",eda)
	return eda
end

function dgsEDASetDebugModeEnabled(eda,debug)
	assert(dgsGetType(eda) == "dgs-dxeda","Bad argument @dgsEDASetDebugModeEnabled at argument 1, expect dgs-dxeda got "..dgsGetType(eda))
	if not debug then
		if isElement(dgsElementData[v].debugShader) then
			destroyElement(dgsElementData[v].debugShader)
			dgsElementData[v].debugShader = nil
		end
	end
	dgsSetData(eda,"debug",debug and debug or false)
	return true
end

function dgsEDAGetDebugModeEnabled(eda)
	assert(dgsGetType(eda) == "dgs-dxeda","Bad argument @dgsEDAGetDebugModeEnabled at argument 1, expect dgs-dxeda got "..dgsGetType(eda))
	return dgsElementData[eda].debug
end

function dgsCheckRadius(eda,mx,my)
	if mx and my then
		local x,y = dgsGetPosition(eda,false,true)
		local size = dgsElementData[eda].absSize
		if ((mx-x-size[1]/2)/size[1]*2)^2+((my-y-size[2]/2)/size[2]*2)^2 <= 1 then
			return true
		end
	end
	return false
end
