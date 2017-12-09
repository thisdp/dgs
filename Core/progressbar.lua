function dgsDxCreateProgressBar(x,y,sx,sy,relative,parent,bgimg,bgcolor,barimg,barcolor,barmode)
	assert(tonumber(x),"Bad argument @dgsDxCreateProgressBar at argument 1, expect number got "..type(x))
	assert(tonumber(y),"Bad argument @dgsDxCreateProgressBar at argument 2, expect number got "..type(y))
	assert(tonumber(sx),"Bad argument @dgsDxCreateProgressBar at argument 3, expect number got "..type(sx))
	assert(tonumber(sy),"Bad argument @dgsDxCreateProgressBar at argument 4, expect number got "..type(sy))
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"Bad argument @dgsDxCreateProgressBar at argument 6, expect dgs-dxgui got "..dgsGetType(parent))
	end
	if isElement(bgimg) then
		local imgtyp = getElementType(bgimg)
		assert(imgtyp == "texture" or imgtyp == "shader","Bad argument @dgsDxCreateProgressBar at argument 7, expect texture got "..getElementType(bgimg))
	end
	if isElement(barimg) then
		local imgtyp = getElementType(barimg)
		assert(imgtyp == "texture" or imgtyp == "shader","Bad argument @dgsDxCreateProgressBar at argument 9, expect texture got "..getElementType(barimg))
	end
	local progressbar = createElement("dgs-dxprogressbar")
	dgsSetType(progressbar,"dgs-dxprogressbar")
	dgsSetData(progressbar,"bgcolor",bgcolor or schemeColor.progressbar.bgcolor)
	dgsSetData(progressbar,"barcolor",barcolor or schemeColor.progressbar.barcolor)
	dgsSetData(progressbar,"bgimg",bgimg)
	dgsSetData(progressbar,"barimg",barimg)
	dgsSetData(progressbar,"barmode",barmode and true or false)
	dgsSetData(progressbar,"udspace",{5,false})
	dgsSetData(progressbar,"lrspace",{5,false})
	dgsSetData(progressbar,"progress",0)
	if isElement(parent) then
		dgsSetParent(progressbar,parent)
	else
		table.insert(MaxFatherTable,progressbar)
	end
	insertResourceDxGUI(sourceResource,progressbar)
	triggerEvent("onClientDgsDxGUIPreCreate",progressbar)
	calculateGuiPositionSize(progressbar,x,y,relative or false,sx,sy,relative or false,true)
	local mx,my = false,false
	if isElement(barimg) then
		mx,my = dxGetMaterialSize(barimg)
	end
	dgsSetData(progressbar,"barsize",{mx,my})
	triggerEvent("onClientDgsDxGUICreate",progressbar)
	return progressbar
end

function dgsDxProgressBarGetProgress(gui)
	assert(dgsGetType(gui) == "dgs-dxprogressbar","Bad argument @dgsDxProgressBarGetProgress at argument 1, expect dgs-dxprogressbar got "..(dgsGetType(gui) or type(gui)))
	return dgsElementData[gui].progress
end

function dgsDxProgressBarSetProgress(gui,progress)
	assert(dgsGetType(gui) == "dgs-dxprogressbar","Bad argument @dgsDxProgressBarSetProgress at argument 1, expect dgs-dxprogressbar got "..(dgsGetType(gui) or type(gui)))
	if progress < 0 then progress = 0 end
	if progress > 100 then progress = 100 end
	if dgsElementData[gui].progress ~= progress then
		dgsSetData(gui,"progress",progress)
	end
	return true
end

function dgsDxProgressBarSetMode(gui,mode)
	assert(dgsGetType(gui) == "dgs-dxprogressbar","Bad argument @dgsDxProgressBarSetBarMode at argument 1, expect dgs-dxprogressbar got "..(dgsGetType(gui) or type(gui)))
	return dgsSetData(gui,"barmode",mode and true or false)
end

function dgsDxProgressBarGetMode(gui)
	assert(dgsGetType(gui) == "dgs-dxprogressbar","Bad argument @dgsDxProgressBarSetBarMode at argument 1, expect dgs-dxprogressbar got "..(dgsGetType(gui) or type(gui)))
	return dgsElementData[gui].barmode
end

function dgsDxProgressBarGetUpDownDistance(gui,forcerelative)
	assert(dgsGetType(gui) == "dgs-dxprogressbar","Bad argument @dgsDxProgressBarGetUpDownDistance at argument 1, expect dgs-dxprogressbar got "..(dgsGetType(gui) or type(gui)))
	if forcerelative == false then
		local value = dgsElementData[gui].udspace[1]
		if dgsElementData[gui].udspace[2] == true then
			local sy = dgsElementData[gui].absSize[2]
			value = sy*value
		end
		return value
	elseif forcerelative == true then
		local value = dgsElementData[gui].udspace[1]
		if dgsElementData[gui].udspace[2] == false then
			local sy = dgsElementData[gui].absSize[2]
			value = value/sy
		end
		return value
	else
		return dgsElementData[gui].udspace[1],dgsElementData[gui].udspace[2]
	end
end

function dgsDxProgressBarGetLeftRightDistance(gui,forcerelative)
	assert(dgsGetType(gui) == "dgs-dxprogressbar","Bad argument @dgsDxProgressBarGetLeftRightDistance at argument 1, expect dgs-dxprogressbar got "..(dgsGetType(gui) or type(gui)))
	if forcerelative == false then
		local value = dgsElementData[gui].lrspace[1]
		if dgsElementData[gui].lrspace[2] == true then
			local sy = dgsElementData[gui].absSize[1]
			value = sy*value
		end
		return value
	elseif forcerelative == true then
		local value = dgsElementData[gui].lrspace[1]
		if dgsElementData[gui].lrspace[2] == false then
			local sy = dgsElementData[gui].absSize[1]
			value = value/sy
		end
		return value
	else
		return dgsElementData[gui].lrspace[1],dgsElementData[gui].lrspace[2]
	end
end

function dgsDxProgressBarSetUpDownDistance(gui,value,relative)
	assert(dgsGetType(gui) == "dgs-dxprogressbar","Bad argument @dgsDxProgressBarSetUpDownDistance at argument 1, expect dgs-dxprogressbar got "..(dgsGetType(gui) or type(gui)))
	assert(type(value) == "number","Bad argument @dgsDxProgressBarSetUpDownDistance at argument 2, expect number got "..type(value))
	assert(type(relative) == "boolean","Bad argument @dgsDxProgressBarSetUpDownDistance at argument 3, expect boolean got "..type(relative))
	return dgsSetData(gui,"udspace",{value,relative})
end

function dgsDxProgressBarSetLeftRightDistance(gui,value,relative)
	assert(dgsGetType(gui) == "dgs-dxprogressbar","Bad argument @dgsDxProgressBarSetLeftRightDistance at argument 1, expect dgs-dxprogressbar got "..(dgsGetType(gui) or type(gui)))
	assert(type(value) == "number","Bad argument @dgsDxProgressBarSetLeftRightDistance at argument 2, expect number got "..type(value))
	assert(type(relative) == "boolean","Bad argument @dgsDxProgressBarSetLeftRightDistance at argument 3, expect boolean got "..type(relative))
	return dgsSetData(gui,"lrspace",{value,relative})
end
