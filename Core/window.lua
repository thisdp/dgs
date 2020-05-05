function dgsCreateWindow(x,y,sx,sy,text,relative,textColor,titleHeight,titleImage,titleColor,image,color,borderSize,noCloseButton)
	assert(tonumber(x),"Bad argument @dgsCreateWindow at argument 1, expect number got "..type(x))
	assert(tonumber(y),"Bad argument @dgsCreateWindow at argument 2, expect number got "..type(y))
	assert(tonumber(sx),"Bad argument @dgsCreateWindow at argument 3, expect number got "..type(sx))
	assert(tonumber(sy),"Bad argument @dgsCreateWindow at argument 4, expect number got "..type(sy))
	local window = createElement("dgs-dxwindow")
	table.insert(CenterFatherTable,window)
	dgsSetType(window,"dgs-dxwindow")
	dgsSetData(window,"renderBuffer",{})
	dgsSetData(window,"titleImage",titleImage or dgsCreateTextureFromStyle(styleSettings.window.titleImage))
	dgsSetData(window,"textColor",tonumber(textColor) or styleSettings.window.textColor)
	dgsSetData(window,"titleColorBlur",tonumber(titleColor) or styleSettings.window.titleColorBlur)
	dgsSetData(window,"titleColor",tonumber(titleColor) or styleSettings.window.titleColor)
	dgsSetData(window,"image",image or dgsCreateTextureFromStyle(styleSettings.window.image))
	dgsSetData(window,"color",tonumber(color) or styleSettings.window.color)
	dgsAttachToTranslation(window,resourceTranslation[sourceResource or getThisResource()])
	if type(text) == "table" then
		dgsElementData[window]._translationText = text
		dgsSetData(window,"text",text)
	else
		dgsSetData(window,"text",tostring(text))
	end
	local textSizeX,textSizeY = tonumber(scalex) or styleSettings.window.textSize[1], tonumber(scaley) or styleSettings.window.textSize[2]
	dgsSetData(window,"textSize",{textSizeX,textSizeY})
	dgsSetData(window,"titleHeight",tonumber(titleHeight) or styleSettings.window.titleHeight)
	dgsSetData(window,"borderSize",tonumber(borderSize) or styleSettings.window.borderSize)
	dgsSetData(window,"ignoreTitle",false,true)
	dgsSetData(window,"colorcoded",false)
	dgsSetData(window,"movable",true)
	dgsSetData(window,"sizable",true)
	dgsSetData(window,"clip",true)
	dgsSetData(window,"wordbreak",false)
	dgsSetData(window,"alignment",{"center","center"})
	dgsSetData(window,"movetyp",false) --false only title;true are all
	dgsSetData(window,"font",styleSettings.window.font or systemFont)
	dgsSetData(window,"minSize",{60,60})
	dgsSetData(window,"maxSize",{20000,20000})
	calculateGuiPositionSize(window,x,y,relative,sx,sy,relative,true)
	triggerEvent("onDgsCreate",window,sourceResource)
	local createCloseButton = true
	if noCloseButton == nil then
		createCloseButton = styleSettings.window.closeButton
	elseif noCloseButton then
		createCloseButton = false
	end
	if createCloseButton then
		local buttonOff = dgsCreateButton(40,0,40,24,styleSettings.window.closeButtonText,false,window,_,_,_,_,_,_,styleSettings.window.closeButtonColor[1],styleSettings.window.closeButtonColor[2],styleSettings.window.closeButtonColor[3],true)
		addEventHandler("onDgsMouseClickUp",buttonOff,function(button)
			if button == "left" then
				local window = dgsGetParent(source)
				if isElement(window) then
					dgsCloseWindow(window)
				end
			end
		end,false)
		dgsSetData(window,"closeButtonSize",{40,24,false})
		dgsSetData(window,"closeButton",buttonOff)
		dgsSetSide(buttonOff,"right",false)
		dgsSetData(buttonOff,"ignoreParentTitle",true,true)
		dgsSetData(buttonOff,"font","default-bold")
		dgsSetData(buttonOff,"alignment",{"center","center"})
		dgsSetPosition(buttonOff,40,0,false)
	end
	return window
end

function dgsWindowSetCloseButtonEnabled(window,bool)
	assert(dgsGetType(window) == "dgs-dxwindow","Bad argument @dgsWindowSetCloseButtonEnabled at at argument 1, expect dgs-dxwindow got "..dgsGetType(window))
	local closeButton = dgsElementData[window].closeButton
	if bool then
		if not isElement(closeButton) then
			local cbSize = dgsElementData[window].closeButtonSize
			local buttonOff = dgsCreateButton(40,0,cbSize[1],cbSize[2],"×",cbSize[3],window,_,_,_,_,_,_,tocolor(200,50,50,255),tocolor(250,20,20,255),tocolor(150,50,50,255),true)
			dgsSetData(window,"closeButton",buttonOff)
			dgsSetData(buttonOff,"ignoreParentTitle",true)
			dgsSetSide(buttonOff,"right",false)
			return true
		end
	else
		if isElement(closeButton) then
			destroyElement(closeButton)
			dgsSetData(window,"closeButton",nil)
			return true
		end
	end
	return false
end

function dgsWindowGetCloseButtonEnabled(window)
	assert(dgsGetType(window) == "dgs-dxwindow","Bad argument @dgsWindowGetCloseButtonEnabled at at argument 1, expect dgs-dxwindow got "..dgsGetType(window))
	return isElement(dgsElementData[window].closeButton)
end

function dgsWindowSetSizable(window,bool)
	assert(dgsGetType(window) == "dgs-dxwindow","Bad argument @dgsWindowSetSizable at at argument 1, expect dgs-dxwindow got "..dgsGetType(window))
	return dgsSetData(window,"sizable",bool and true or false)
end

function dgsWindowGetSizable(window)
	assert(dgsGetType(window) == "dgs-dxwindow","Bad argument @dgsWindowGetSizable at at argument 1, expect dgs-dxwindow got "..dgsGetType(window))
	return dgsElementData[window].sizable
end

function dgsWindowGetCloseButton(window)
	assert(dgsGetType(window) == "dgs-dxwindow","Bad argument @dgsWindowGetCloseButton at at argument 1, expect dgs-dxwindow got "..dgsGetType(window))
	if dgsWindowGetCloseButtonEnabled(window) then
		return dgsElementData[window].closeButton
	end
end

function dgsWindowSetMovable(window,bool)
	assert(dgsGetType(window) == "dgs-dxwindow","Bad argument @dgsWindowSetMovable at at argument 1, expect dgs-dxwindow got "..dgsGetType(window))
	return dgsSetData(window,"movable",bool and true or false)
end

function dgsWindowGetMovable(window)
	assert(dgsGetType(window) == "dgs-dxwindow","Bad argument @dgsWindowGetMovable at at argument 1, expect dgs-dxwindow got "..dgsGetType(window))
	return dgsElementData[window].movable
end

function dgsWindowSetCloseButtonSize(window,w,h,relative)
	assert(dgsGetType(window) == "dgs-dxwindow","Bad argument @dgsWindowSetCloseButtonSize at at argument 1, expect dgs-dxwindow got "..dgsGetType(window))
	assert(tonumber(w),"Bad argument @dgsWindowSetCloseButtonSize at argument 2, expect number got "..type(w))
	assert(tonumber(h),"Bad argument @dgsWindowSetCloseButtonSize at argument 3, expect number got "..type(h))
	local closeButton = dgsElementData[window].closeButton
	if isElement(closeButton) then
		dgsSetData(window,"closeButtonSize",{w,h,relative and true or false})
		return dgsSetSize(closeButton,w,h,relative and true or false)
	end
	return false
end

function dgsWindowGetCloseButtonSize(window,relative)
	assert(dgsGetType(window) == "dgs-dxwindow","Bad argument @dgsWindowGetCloseButtonSize at at argument 1, expect dgs-dxwindow got "..dgsGetType(window))
	local closeButton = dgsElementData[window].closeButton
	if isElement(closeButton) then
		return dgsGetSize(closeButton,relative and true or false)
	end
	return false
end

function dgsCloseWindow(window)
	assert(dgsGetType(window) == "dgs-dxwindow","Bad argument @dgsCloseWindow at at argument 1, expect dgs-dxwindow got "..dgsGetType(window))
	triggerEvent("onDgsWindowClose",window)
	local canceled = wasEventCancelled()
	if not canceled then
		return destroyElement(window)
	end
	return false
end

----------------------------------------------------------------
-------------------------OOP Class------------------------------
----------------------------------------------------------------
dgsOOP["dgs-dxwindow"] = [[
	setSizable = dgsOOP.genOOPFnc("dgsWindowSetSizable",true),
	setMovable = dgsOOP.genOOPFnc("dgsWindowSetMovable",true),
	getSizable = dgsOOP.genOOPFnc("dgsWindowGetSizable"),
	getMovable = dgsOOP.genOOPFnc("dgsWindowGetMovable"),
	close = dgsOOP.genOOPFnc("dgsCloseWindow"),
	setCloseButtonEnabled = dgsOOP.genOOPFnc("dgsWindowSetCloseButtonEnabled",true),
	getCloseButtonEnabled = dgsOOP.genOOPFnc("dgsWindowGetCloseButtonEnabled"),
	setCloseButtonSize = dgsOOP.genOOPFnc("dgsWindowSetCloseButtonSize",true),
	getCloseButtonSize = dgsOOP.genOOPFnc("dgsWindowGetCloseButtonSize"),
	getCloseButton = dgsOOP.genOOPFnc("dgsWindowGetCloseButton"),
]]