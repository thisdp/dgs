function dgsCreateDetectArea(x,y,sx,sy,relative,parent)
	assert(tonumber(x),"Bad argument @dgsCreateDetectArea at argument 1, expect number got "..type(x))
	assert(tonumber(y),"Bad argument @dgsCreateDetectArea at argument 2, expect number got "..type(y))
	assert(tonumber(sx),"Bad argument @dgsCreateDetectArea at argument 3, expect number got "..type(sx))
	assert(tonumber(sy),"Bad argument @dgsCreateDetectArea at argument 4, expect number got "..type(sy))
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"Bad argument @dgsCreateDetectArea at argument 7, expect dgs-dxgui got "..dgsGetType(parent))
	end
	local detectarea = createElement("dgs-dxdetectarea")
	local _x = dgsIsDxElement(parent) and dgsSetParent(detectarea,parent,true,true) or table.insert(CenterFatherTable,1,detectarea)
	dgsSetType(detectarea,"dgs-dxdetectarea")
	dgsSetData(detectarea,"renderBuffer",{})
	dgsSetData(detectarea,"checkFunction",dgsDetectAreaDefaultFunction)
	dgsSetData(detectarea,"debug",false)
	insertResourceDxGUI(sourceResource,detectarea)
	triggerEvent("onDgsPreCreate",detectarea)
	calculateGuiPositionSize(detectarea,x,y,relative or false,sx,sy,relative or false,true)
	triggerEvent("onDgsCreate",detectarea)
	return detectarea
end

detectAreaPreDefine = [[
	local args = {...}
	local mxRlt,myRlt,mxAbs,myAbs = args[1],args[2],args[3],args[4]
]]

function dgsDetectAreaDefaultFunction(mxRlt,myRlt,mxAbs,myAbs)
	return true
end

function dgsDetectAreaSetFunction(detectarea,fncStr)
	assert(dgsGetType(detectarea) == "dgs-dxdetectarea","Bad argument @dgsDetectAreaSetFunction at argument 1, except dgs-dxdetectarea got "..dgsGetType(detectarea))
	assert(type(fncStr) == "string" or (isElement(fncStr) and getElementType(fncStr) == "texture"),"Bad argument @dgsDetectAreaSetFunction at argument 2, expect string/texture got "..dgsGetType(fncStr))
	if type(fncStr) == "string" then
		local fnc = loadstring(detectAreaPreDefine..fncStr)
		assert(type(fnc) == "function","Bad argument @dgsDetectAreaSetFunction at argument 2, failed to load function")
		dgsSetData(detectarea,"checkFunction",fnc)
		dgsSetData(detectarea,"checkFunctionImage",nil)
		return true
	else
		local pixels = dxGetTexturePixels(fncStr)
		dgsSetData(detectarea,"checkFunction",pixels)
		dgsSetData(detectarea,"checkFunctionImage",fncStr)
		return true
	end
end