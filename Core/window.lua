--Dx Functions
local dxDrawLine = dxDrawLine
local dxDrawImage = dxDrawImageExt
local dxDrawImageSection = dxDrawImageSectionExt
local dxDrawText = dxDrawText
local dxGetFontHeight = dxGetFontHeight
local dxDrawRectangle = dxDrawRectangle
local dxSetShaderValue = dxSetShaderValue
local dxGetPixelsSize = dxGetPixelsSize
local dxGetPixelColor = dxGetPixelColor
local dxSetRenderTarget = dxSetRenderTarget
local dxGetTextWidth = dxGetTextWidth
local dxSetBlendMode = dxSetBlendMode
--
local tonumber = tonumber
local assert = assert
local type = type
local tonumber = tonumber

function dgsCreateWindow(x,y,sx,sy,text,relative,textColor,titleHeight,titleImage,titleColor,image,color,borderSize,noCloseButton)
	local xCheck,yCheck,wCheck,hCheck = type (x) == "number",type(y) == "number",type(sx) == "number",type(sy) == "number"
	if not xCheck then assert(false,"Bad argument @dgsCreateWindow at argument 1, expect number got "..type(x)) end
	if not yCheck then assert(false,"Bad argument @dgsCreateWindow at argument 2, expect number got "..type(y)) end
	if not wCheck then assert(false,"Bad argument @dgsCreateWindow at argument 3, expect number got "..type(sx)) end
	if not hCheck then assert(false,"Bad argument @dgsCreateWindow at argument 4, expect number got "..type(sy)) end
	local window = createElement("dgs-dxwindow")
	dgsSetType(window,"dgs-dxwindow")
	dgsSetParent(window,nil,true,true)
	local style = styleSettings.window
	local textSizeX,textSizeY = tonumber(scalex) or style.textSize[1], tonumber(scaley) or style.textSize[2]
	dgsElementData[window] = {
		renderBuffer = {},
		titleImage = titleImage or dgsCreateTextureFromStyle(style.titleImage),
		textColor = tonumber(textColor) or style.textColor,
		titleColorBlur = tonumber(titleColor) or style.titleColorBlur,
		titleColor = tonumber(titleColor) or style.titleColor,
		image = image or dgsCreateTextureFromStyle(style.image),
		color = tonumber(color) or style.color,
		textSize = {textSizeX,textSizeY},
		titleHeight = tonumber(titleHeight) or style.titleHeight,
		borderSize = tonumber(borderSize) or style.borderSize,
		ignoreTitle = false,
		colorcoded = false,
		movable = true,
		sizable = true,
		clip = true,
		wordbreak = false,
		alignment = {"center","center"},
		movetyp = false; --false only title;true are al,
		font = style.font or systemFont,
		minSize = {60,60},
		maxSize = {20000,20000},
	}
	dgsAttachToTranslation(window,resourceTranslation[sourceResource or getThisResource()])
	if type(text) == "table" then
		dgsElementData[window]._translationText = text
		dgsSetData(window,"text",text)
	else
		dgsSetData(window,"text",tostring(text))
	end
	calculateGuiPositionSize(window,x,y,relative,sx,sy,relative,true)
	triggerEvent("onDgsCreate",window,sourceResource)
	local createCloseButton = true
	if noCloseButton == nil then
		createCloseButton = style.closeButton
	elseif noCloseButton then
		createCloseButton = false
	end
	if createCloseButton then
		local buttonOff = dgsCreateButton(40,0,40,24,style.closeButtonText,false,window,_,_,_,_,_,_,style.closeButtonColor[1],style.closeButtonColor[2],style.closeButtonColor[3],true)
		addEventHandler("onDgsMouseClickUp",buttonOff,function(button)
			if button == "left" then
				local window = dgsGetParent(source)
				if isElement(window) then
					dgsCloseWindow(window)
				end
			end
		end,false)
		dgsElementData[window].closeButtonSize = {40,24,false}
		dgsElementData[window].closeButton = buttonOff
		dgsElementData[buttonOff].lor = "right"
		dgsElementData[buttonOff].font = "default-bold"
		dgsElementData[buttonOff].alignment = {"center","center"}
		dgsElementData[buttonOff].ignoreParentTitle = true
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
	assert(type(w) == "number","Bad argument @dgsWindowSetCloseButtonSize at argument 2, expect number got "..type(w))
	assert(type(h) == "number","Bad argument @dgsWindowSetCloseButtonSize at argument 3, expect number got "..type(h))
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
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxwindow"] = function(source,x,y,w,h,mx,my,cx,cy,enabled,eleData,parentAlpha,isPostGUI,rndtgt)
	local img = eleData.image
	local color = applyColorAlpha(eleData.color,parentAlpha)
	local titimg,titleColor,titsize = eleData.titleImage,eleData.isFocused and eleData.titleColor or (eleData.titleColorBlur or eleData.titleColor),eleData.titleHeight
	titleColor = applyColorAlpha(titleColor,parentAlpha)
	if img then
		dxDrawImage(x,y+titsize,w,h-titsize,img,0,0,0,color,isPostGUI,rndtgt)
	else
		dxDrawRectangle(x,y+titsize,w,h-titsize,color,isPostGUI)
	end
	if titimg then
		dxDrawImage(x,y,w,titsize,titimg,0,0,0,titleColor,isPostGUI,rndtgt)
	else
		dxDrawRectangle(x,y,w,titsize,titleColor,isPostGUI)
	end
	local alignment = eleData.alignment
	local font = eleData.font or systemFont
	local textColor = applyColorAlpha(eleData.textColor,parentAlpha)
	local txtSizX,txtSizY = eleData.textSize[1],eleData.textSize[2] or eleData.textSize[1]
	local clip,wordbreak,colorcoded = eleData.clip,eleData.wordbreak,eleData.colorcoded
	local text = eleData.text
	local shadow = eleData.shadow
	if shadow then
		local shadowoffx,shadowoffy,shadowc,shadowIsOutline = shadow[1],shadow[2],shadow[3],shadow[4]
		local textX,textY = x,y
		if shadowoffx and shadowoffy and shadowc then
			local shadowText = colorcoded and text:gsub('#%x%x%x%x%x%x','') or text
			local shadowc = applyColorAlpha(shadowc,parentAlpha)
			dxDrawText(shadowText,textX+shadowoffx,textY+shadowoffy,textX+w+shadowoffx,textY+titsize+shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,isPostGUI)
			if shadowIsOutline then
				dxDrawText(shadowText,textX-shadowoffx,textY+shadowoffy,textX+w-shadowoffx,textY+titsize+shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,isPostGUI)
				dxDrawText(shadowText,textX-shadowoffx,textY-shadowoffy,textX+w-shadowoffx,textY+titsize-shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,isPostGUI)
				dxDrawText(shadowText,textX+shadowoffx,textY-shadowoffy,textX+w+shadowoffx,textY+titsize-shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,isPostGUI)
			end
		end
	end
	dxDrawText(text,x,y,x+w,y+titsize,textColor,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,isPostGUI,eleData.colorcoded)
	return rndtgt
end