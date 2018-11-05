function dgsCreateProgressBar(x,y,sx,sy,relative,parent,bgImage,bgColor,indicatorImage,indicatorColor,indicatorMode)
	assert(tonumber(x),"Bad argument @dgsCreateProgressBar at argument 1, expect number got "..type(x))
	assert(tonumber(y),"Bad argument @dgsCreateProgressBar at argument 2, expect number got "..type(y))
	assert(tonumber(sx),"Bad argument @dgsCreateProgressBar at argument 3, expect number got "..type(sx))
	assert(tonumber(sy),"Bad argument @dgsCreateProgressBar at argument 4, expect number got "..type(sy))
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"Bad argument @dgsCreateProgressBar at argument 6, expect dgs-dxgui got "..dgsGetType(parent))
	end
	if isElement(bgImage) then
		local imgtyp = getElementType(bgImage)
		assert(imgtyp == "texture" or imgtyp == "shader","Bad argument @dgsCreateProgressBar at argument 7, expect texture got "..getElementType(bgImage))
	end
	if isElement(indicatorImage) then
		local imgtyp = getElementType(indicatorImage)
		assert(imgtyp == "texture" or imgtyp == "shader","Bad argument @dgsCreateProgressBar at argument 9, expect texture got "..getElementType(indicatorImage))
	end
	local progressbar = createElement("dgs-dxprogressbar")
	local _ = dgsIsDxElement(parent) and dgsSetParent(progressbar,parent,true,true) or table.insert(CenterFatherTable,1,progressbar)
	dgsSetType(progressbar,"dgs-dxprogressbar")
	dgsSetData(progressbar,"renderBuffer",{})
	dgsSetData(progressbar,"bgColor",bgColor or styleSettings.progressbar.bgColor)
	dgsSetData(progressbar,"indicatorColor",indicatorColor or styleSettings.progressbar.indicatorColor)
	dgsSetData(progressbar,"bgImage",bgImage or dgsCreateTextureFromStyle(styleSettings.progressbar.bgImage))
	dgsSetData(progressbar,"indicatorImage",indicatorImage or dgsCreateTextureFromStyle(styleSettings.progressbar.indicatorImage))
	dgsSetData(progressbar,"indicatorMode",indicatorMode and true or false)
	dgsSetData(progressbar,"padding",styleSettings.progressbar.padding)
	dgsSetData(progressbar,"progress",0)
	insertResourceDxGUI(sourceResource,progressbar)
	calculateGuiPositionSize(progressbar,x,y,relative or false,sx,sy,relative or false,true)
	local mx,my = false,false
	if isElement(indicatorImage) then
		mx,my = dxGetMaterialSize(indicatorImage)
	end
	dgsSetData(progressbar,"indicatorUVSize",{mx,my})
	triggerEvent("onDgsCreate",progressbar)
	return progressbar
end

function dgsProgressBarGetProgress(gui)
	assert(dgsGetType(gui) == "dgs-dxprogressbar","Bad argument @dgsProgressBarGetProgress at argument 1, expect dgs-dxprogressbar got "..(dgsGetType(gui) or type(gui)))
	return dgsElementData[gui].progress
end

function dgsProgressBarSetProgress(gui,progress)
	assert(dgsGetType(gui) == "dgs-dxprogressbar","Bad argument @dgsProgressBarSetProgress at argument 1, expect dgs-dxprogressbar got "..(dgsGetType(gui) or type(gui)))
	if progress < 0 then progress = 0 end
	if progress > 100 then progress = 100 end
	if dgsElementData[gui].progress ~= progress then
		dgsSetData(gui,"progress",progress)
	end
	return true
end

function dgsProgressBarSetMode(gui,mode)
	assert(dgsGetType(gui) == "dgs-dxprogressbar","Bad argument @dgsProgressBarSetindicatorMode at argument 1, expect dgs-dxprogressbar got "..(dgsGetType(gui) or type(gui)))
	return dgsSetData(gui,"indicatorMode",mode and true or false)
end

function dgsProgressBarGetMode(gui)
	assert(dgsGetType(gui) == "dgs-dxprogressbar","Bad argument @dgsProgressBarSetindicatorMode at argument 1, expect dgs-dxprogressbar got "..(dgsGetType(gui) or type(gui)))
	return dgsElementData[gui].indicatorMode
end
