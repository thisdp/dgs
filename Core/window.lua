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
	dgsSetData(window,"titleColor",tonumber(titleColor) or styleSettings.window.titleColor)
	dgsSetData(window,"image",image or dgsCreateTextureFromStyle(styleSettings.window.image))
	dgsSetData(window,"color",tonumber(color) or styleSettings.window.color)
	dgsAttachToTranslation(window,resourceTranslation[sourceResource or getThisResource()])
	if type(text) == "table" then
		dgsElementData[window]._translationText = text
		text = dgsTranslate(window,text,sourceResource)
	end
	dgsSetData(window,"text",text or "")
	local textSizeX,textSizeY = tonumber(scalex) or styleSettings.window.textSize[1], tonumber(scaley) or styleSettings.window.textSize[2]
	dgsSetData(window,"textSize",{textSizeX,textSizeY})
	dgsSetData(window,"titleHeight",tonumber(titleHeight) or styleSettings.window.titleHeight)
	dgsSetData(window,"borderSize",tonumber(borderSize) or styleSettings.window.borderSize)
	dgsSetData(window,"ignoreTitle",false)
	dgsSetData(window,"colorcoded",false)
	dgsSetData(window,"movable",true)
	dgsSetData(window,"sizable",true)
	dgsSetData(window,"clip",true)
	dgsSetData(window,"wordbreak",false)
	dgsSetData(window,"rightbottom",{"center","center"})
	dgsSetData(window,"movetyp",false) --false only title;true are all
	dgsSetData(window,"font",systemFont)
	dgsSetData(window,"minSize",{60,60})
	dgsSetData(window,"maxSize",{20000,20000})
	insertResourceDxGUI(sourceResource,window)
	calculateGuiPositionSize(window,x,y,relative,sx,sy,relative,true)
	triggerEvent("onDgsCreate",window)
	if not noCloseButton then
		local buttonOff = dgsCreateButton(40,0,40,24,styleSettings.window.closeButtonText,false,window,_,_,_,_,_,_,styleSettings.window.closeButtonColor[1],styleSettings.window.closeButtonColor[2],styleSettings.window.closeButtonColor[3],true)
		dgsSetData(window,"closeButton",buttonOff)
		dgsSetSide(buttonOff,"right",false)
		dgsSetData(buttonOff,"ignoreParentTitle",true)
		dgsSetData(buttonOff,"font","default-bold")
		dgsSetData(buttonOff,"rightbottom",{"center","center"})
		dgsSetPosition(buttonOff,40,0,false)
	end
	return window
end

function dgsWindowSetCloseButtonEnabled(window,bool)
	assert(dgsGetType(window) == "dgs-dxwindow","Bad argument @dgsWindowSetCloseButtonEnabled at at argument 1, expect dgs-dxwindow got "..dgsGetType(window))
	local closeButton = dgsElementData[window].closeButton
	if bool then
		if not isElement(closeButton) then
			local buttonOff = dgsCreateButton(30,0,25,20,"×",false,window,_,_,_,_,_,_,tocolor(200,50,50,255),tocolor(250,20,20,255),tocolor(150,50,50,255),true)
			dgsSetData(window,"closeButton",buttonOff)
			dgsSetSide(buttonOff,"right",false)
			dgsSetData(buttonOff,"ignoreParentTitle",true)
			dgsSetPosition(buttonOff,30,0,false)
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
	if dgsGetType(window) == "dgs-dxwindow" then
		dgsSetData(window,"sizable",(bool and true) or false)
		return true
	end
	return false
end

function dgsWindowGetCloseButton(window)
	assert(dgsGetType(window) == "dgs-dxwindow","Bad argument @dgsWindowGetCloseButton at at argument 1, expect dgs-dxwindow got "..dgsGetType(window))
	if dgsWindowGetCloseButtonEnabled(window) then
		return dgsElementData[window].closeButton
	end
end

function dgsWindowSetMovable(window,bool)
	assert(dgsGetType(window) == "dgs-dxwindow","Bad argument @dgsWindowSetMovable at at argument 1, expect dgs-dxwindow got "..dgsGetType(window))
    if dgsGetType(window) == "dgs-dxwindow" then
		dgsSetData(window,"movable",(bool and true) or false)
		return true
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
