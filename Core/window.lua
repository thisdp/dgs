dgsLogLuaMemory()
dgsRegisterType("dgs-dxwindow","dgsBasic","dgsType2D")
dgsRegisterProperties("dgs-dxwindow",{
	alignment = 			{	{ PArg.String,PArg.String }	},
	borderSize = 			{	PArg.Number	},
	clip = 					{	PArg.Bool	},
	color = 				{	PArg.Color	},
	colorCoded = 			{	PArg.Bool	},
	font = 					{	PArg.Font+PArg.String	},
	ignoreTitle = 			{	PArg.Bool	},
	image = 				{	PArg.Material+PArg.Nil	},
	minSize = 				{	{ PArg.Number,PArg.Number }	},
	movable = 				{	PArg.Bool	},
	closeButtonEnabled = 	{	PArg.Bool	},
	sizable = 				{	PArg.Bool	},
	shadow = 				{	{ PArg.Number, PArg.Number, PArg.Color, PArg.Bool+PArg.Nil }, PArg.Nil	},
	text = 					{	PArg.Text	},
	textOffset =			{	{ PArg.Number, PArg.Number, PArg.Bool+PArg.Nil }, PArg.Nil },
	textColor = 			{	PArg.Color	},
	textSize = 				{	{ PArg.Number,PArg.Number }	},
	titleColor = 			{	PArg.Color	},
	titleColorBlur = 		{	PArg.Color	},
	titleHeight = 			{	PArg.Number	},
	titleImage = 			{	PArg.Material+PArg.Nil	},
	wordBreak = 			{	PArg.Bool	},
})
--[[
dgsRegisterPropertyDefaultValue("dgs-dxwindow",{
	alignment = 			{ "center", "center" },
	clip = 					true,
	colorCoded = 			false,
	ignoreTitle = 			false,
	minSize = 				{ 60, 60 },
	movable = 				true,
	sizable = 				true,
	textOffset =			nil,
	titleColor = 			{	PArg.Color	},
	titleColorBlur = 		{	PArg.Color	},
	titleHeight = 			{	PArg.Number	},
	titleImage = 			{	PArg.Material+PArg.Nil	},
	wordBreak = 			{	PArg.Bool	},
})
]]
--Dx Functions
local dxDrawImage = dxDrawImage
local dgsDrawText = dgsDrawText
local dxDrawRectangle = dxDrawRectangle
--
local dgsTriggerEvent = dgsTriggerEvent
local isElement = isElement
local createElement = createElement
local addEventHandler = addEventHandler
local dgsSetType = dgsSetType
local dgsSetParent = dgsSetParent
local dgsSetData = dgsSetData
local dgsAttachToTranslation = dgsAttachToTranslation
local dgsTranslate = dgsTranslate
local calculateGuiPositionSize = calculateGuiPositionSize
local tonumber = tonumber
local assert = assert
local type = type
local applyColorAlpha = applyColorAlpha

function dgsCreateWindow(...)
	local sRes = sourceResource or resource
	local x,y,w,h,text,relative,textColor,titleHeight,titleImage,titleColor,image,color,borderSize,noCloseButton
	if select("#",...) == 1 and type(select(1,...)) == "table" then
		local argTable = ...
		x = argTable.x or argTable[1]
		y = argTable.y or argTable[2]
		w = argTable.width or argTable.w or argTable[3]
		h = argTable.height or argTable.h or argTable[4]
		text = argTable.text or argTable.txt or argTable[5]
		relative = argTable.relative or argTable.rlt or argTable[6]
		textColor = argTable.textColor or argTable[7]
		titleHeight = argTable.titleHeight or argTable[8]
		titleImage = argTable.titleImage or argTable[9]
		titleColor = argTable.titleColor or argTable[10]
		image = argTable.img or argTable.image or argTable[11]
		color = argTable.color or argTable[12]
		borderSize = argTable.borderSize or argTable[13]
		noCloseButton = argTable.noCloseButton or argTable[14]
	else
		x,y,w,h,text,relative,textColor,titleHeight,titleImage,titleColor,image,color,borderSize,noCloseButton = ...
	end
	if not(type(x) == "number") then error(dgsGenAsrt(x,"dgsCreateWindow",1,"number")) end
	if not(type(y) == "number") then error(dgsGenAsrt(y,"dgsCreateWindow",2,"number")) end
	if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsCreateWindow",3,"number")) end
	if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsCreateWindow",4,"number")) end
	local window = createElement("dgs-dxwindow")
	dgsSetType(window,"dgs-dxwindow")
	
	local res = sRes ~= resource and sRes or "global"
	local style = styleManager.styles[res]
	local using = style.using
	style = style.loaded[using]
	
	local systemFont = style.systemFontElement

	style = style.window
	dgsElementData[window] = {
		renderBuffer = {},
		titleImage = titleImage or dgsCreateTextureFromStyle(using,res,style.titleImage),
		textColor = tonumber(textColor) or style.textColor,
		titleColorBlur = tonumber(titleColor) or style.titleColorBlur,
		titleColor = tonumber(titleColor) or style.titleColor,
		image = image or dgsCreateTextureFromStyle(using,res,style.image),
		color = tonumber(color) or style.color,
		textSize = style.textSize,
		textOffset = nil,	--nil if don't set
		titleHeight = tonumber(titleHeight) or style.titleHeight,
		borderSize = tonumber(borderSize) or style.borderSize,
		ignoreTitle = false,
		colorCoded = false,
		movable = true,
		sizable = true,
		clip = true,
		wordBreak = false,
		alignment = {"center","center"},
		font = style.font or systemFont,
		minSize = {60,60},
	}
	dgsSetParent(window,nil,true,true)
	dgsAttachToTranslation(window,resourceTranslation[sRes])
	if type(text) == "table" then
		dgsElementData[window]._translation_text = text
		dgsSetData(window,"text",text)
	else
		dgsSetData(window,"text",tostring(text or ""))
	end
	calculateGuiPositionSize(window,x,y,relative,w,h,relative,true)
	
	local createCloseButton = true
	if noCloseButton == nil then
		createCloseButton = style.closeButton
	elseif noCloseButton then
		createCloseButton = false
	end
	if createCloseButton then
		local closeIconTexture = nil

		if style.closeIconImage and type(style.closeIconImage) == "table" then
			closeIconTexture = dgsCreateTextureFromStyle(using,res,style.closeIconImage)
		end
		
		local closeBtn = dgsCreateButton(0,0,40,24,"",false,window,_,_,_,_,_,_,style.closeButtonColor[1],style.closeButtonColor[2],style.closeButtonColor[3],true)
		dgsAddEventHandler("onDgsMouseClickUp",closeBtn,"closeWindowWhenCloseButtonClicked",false)

		if closeIconTexture then
			local closeIconImg = dgsCreateImage(0,0,16,16,closeIconTexture,false,closeBtn)
			dgsSetEnabled(closeIconImg, false)
			dgsSetPositionAlignment(closeIconImg,"center","center")
			dgsElementData[window].closeIconImageSize = {16,16}
			dgsElementData[window].closeIconImage = closeIconImg
			dgsElementData[window].closeIconTexture = closeIconTexture
		else
			dgsElementData[window].closeButtonText = style.closeButtonText
			dgsSetText(closeBtn, style.closeButtonText)
		end

		dgsElementData[window].closeButtonSize = {40,24,false}
		dgsElementData[window].closeButton = closeBtn
		dgsSetPositionAlignment(closeBtn,"right")
		dgsElementData[closeBtn].font = "default-bold"
		dgsElementData[closeBtn].alignment = {"center","center"}
		dgsElementData[closeBtn].ignoreParentTitle = true
	end
	dgsElementData[window].closeButtonEnabled = createCloseButton
	onDGSElementCreate(window,sRes)
	return window
end

function closeWindowWhenCloseButtonClicked(button)
	if button == "left" then
		local window = dgsGetParent(source)
		if isElement(window) then dgsCloseWindow(window) end
	end
end

function dgsWindowSetCloseButtonEnabled(window,bool)
	if not(dgsGetType(window) == "dgs-dxwindow") then error(dgsGenAsrt(window,"dgsWindowSetCloseButtonEnabled",1,"dgs-dxwindow")) end
	local closeButton = dgsElementData[window].closeButton
	local closeButtonEnabled = dgsElementData[window].closeButtonEnabled
	if bool then
		if not isElement(closeButton) then
			local cbSize = dgsElementData[window].closeButtonSize
			local closeBtn = dgsCreateButton(0,0,cbSize[1],cbSize[2],"",cbSize[3],window,_,_,_,_,_,_,tocolor(200,50,50,255),tocolor(250,20,20,255),tocolor(150,50,50,255),true)
			dgsAddEventHandler("onDgsMouseClickUp",closeBtn,"closeWindowWhenCloseButtonClicked",false)
			
			if isElement(dgsElementData[window].closeIconTexture) then
				local closeIconImageSize = dgsElementData[window].closeIconImageSize
				local closeIconImg = dgsCreateImage(0,0,closeIconImageSize[1],closeIconImageSize[2],dgsElementData[window].closeIconTexture,false,closeBtn)
				dgsSetEnabled(closeIconImg, false)
				dgsSetPositionAlignment(closeIconImg,"center","center")
			else
				dgsSetText(closeBtn, dgsElementData[window].closeButtonText)
			end

			dgsSetData(window,"closeButton",closeBtn)
			dgsSetData(closeBtn,"alignment",{"center","center"})
			dgsSetData(closeBtn,"ignoreParentTitle",true)
			dgsSetPositionAlignment(closeBtn,"right")
			return true
		end
	else
		if isElement(closeButton) then
			local closeIconImage = dgsElementData[window].closeIconImage

			if isElement(closeIconImage) then
				destroyElement(closeIconImage)
				dgsSetData(window,"closeIconImage",nil)
			end

			destroyElement(closeButton)
			dgsSetData(window,"closeButton",nil)
			return true
		end
	end
	dgsElementData[window].closeButtonEnabled = bool
	return false
end

function dgsWindowGetCloseButtonEnabled(window)
	if not(dgsGetType(window) == "dgs-dxwindow") then error(dgsGenAsrt(window,"dgsWindowGetCloseButtonEnabled",1,"dgs-dxwindow")) end
	return isElement(dgsElementData[window].closeButton)
end

function dgsWindowSetSizable(window,bool)
	if not(dgsGetType(window) == "dgs-dxwindow") then error(dgsGenAsrt(window,"dgsWindowSetSizable",1,"dgs-dxwindow")) end
	return dgsSetData(window,"sizable",bool and true or false)
end

function dgsWindowGetSizable(window)
	if not(dgsGetType(window) == "dgs-dxwindow") then error(dgsGenAsrt(window,"dgsWindowGetSizable",1,"dgs-dxwindow")) end
	return dgsElementData[window].sizable
end

function dgsWindowGetCloseButton(window)
	if not(dgsGetType(window) == "dgs-dxwindow") then error(dgsGenAsrt(window,"dgsWindowGetCloseButton",1,"dgs-dxwindow")) end
	local closeButton = dgsElementData[window].closeButton
	if isElement(closeButton) then
		return closeButton
	end
	return false
end

function dgsWindowSetMovable(window,bool)
	if not(dgsGetType(window) == "dgs-dxwindow") then error(dgsGenAsrt(window,"dgsWindowSetMovable",1,"dgs-dxwindow")) end
	return dgsSetData(window,"movable",bool and true or false)
end

function dgsWindowGetMovable(window)
	if not(dgsGetType(window) == "dgs-dxwindow") then error(dgsGenAsrt(window,"dgsWindowGetMovable",1,"dgs-dxwindow")) end
	return dgsElementData[window].movable
end

function dgsWindowSetCloseButtonSize(window,w,h,relative)
	if not(dgsGetType(window) == "dgs-dxwindow") then error(dgsGenAsrt(window,"dgsWindowSetCloseButtonSize",1,"dgs-dxwindow")) end
	if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsWindowSetCloseButtonSize",2,"number")) end
	if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsWindowSetCloseButtonSize",3,"number")) end
	local closeButton = dgsElementData[window].closeButton
	if isElement(closeButton) then
		dgsSetData(window,"closeButtonSize",{w,h,relative and true or false})
		return dgsSetSize(closeButton,w,h,relative and true or false)
	end
	return false
end

function dgsWindowGetCloseButtonSize(window,relative)
	if not(dgsGetType(window) == "dgs-dxwindow") then error(dgsGenAsrt(window,"dgsWindowGetCloseButtonSize",1,"dgs-dxwindow")) end
	local closeButton = dgsElementData[window].closeButton
	if isElement(closeButton) then
		return dgsGetSize(closeButton,relative and true or false)
	end
	return false
end

function dgsCloseWindow(window)
	if not(dgsGetType(window) == "dgs-dxwindow") then error(dgsGenAsrt(window,"dgsCloseWindow",1,"dgs-dxwindow")) end
	if dgsElementData[window]._DGSI_isClosing then return false end
	dgsSetData(window,"_DGSI_isClosing",true)
	dgsTriggerEvent("onDgsWindowClose",window)
	if not wasEventCancelled() then
		return destroyElement(window)
	end
	dgsSetData(window,"_DGSI_isClosing",nil)
	return false
end

function dgsWindowSetHorizontalAlign(window,align)
	if dgsGetType(window) ~= "dgs-dxwindow" then error(dgsGenAsrt(window,"dgsWindowGetColor",1,"dgs-dxwindow")) end
	if not HorizontalAlign[align] then error(dgsGenAsrt(align,"dgsWindowSetHorizontalAlign",2,"string","left/center/right")) end
	local alignment = dgsElementData[window].alignment
	return dgsSetData(window,"alignment",{align,alignment[2]})
end

function dgsWindowSetVerticalAlign(window,align)
	if dgsGetType(window) ~= "dgs-dxwindow" then error(dgsGenAsrt(window,"dgsWindowSetVerticalAlign",1,"dgs-dxwindow")) end
	if not VerticalAlign[align] then error(dgsGenAsrt(align,"dgsWindowSetVerticalAlign",2,"string","top/center/bottom")) end
	local alignment = dgsElementData[window].alignment
	return dgsSetData(window,"alignment",{alignment[1],align})
end

function dgsWindowGetHorizontalAlign(window)
	if dgsGetType(window) ~= "dgs-dxwindow" then error(dgsGenAsrt(window,"dgsWindowGetHorizontalAlign",1,"dgs-dxwindow")) end
	local alignment = dgsElementData[window].alignment
	return alignment[1]
end

function dgsWindowGetVerticalAlign(window)
	if dgsGetType(window) ~= "dgs-dxwindow" then error(dgsGenAsrt(window,"dgsWindowGetVerticalAlign",1,"dgs-dxwindow")) end
	local alignment = dgsElementData[window].alignment
	return alignment[2]
end

function dgsWindowGetTextExtent(window)
	if dgsGetType(window) ~= "dgs-dxwindow" then error(dgsGenAsrt(window,"dgsWindowGetTextExtent",1,"dgs-dxwindow")) end
	local eleData = dgsElementData[window]
	local font = eleData.font or systemFont
	local textSizeX = eleData.textSize[1]
	local text = eleData.text
	local colorCoded = eleData.colorCoded
	return dxGetTextWidth(text,textSizeX,font,colorCoded)
end

function dgsWindowGetFontHeight(window)
	if dgsGetType(window) ~= "dgs-dxwindow" then error(dgsGenAsrt(window,"dgsWindowGetFontHeight",1,"dgs-dxwindow")) end
	local font = dgsElementData[window].font or systemFont
	local textSizeY = dgsElementData[window].textSize[2]
	return dxGetFontHeight(textSizeY,font)
end

function dgsWindowGetTextSize(window)
	if dgsGetType(window) ~= "dgs-dxwindow" then error(dgsGenAsrt(window,"dgsWindowGetTextSize",1,"dgs-dxwindow")) end
	local eleData = dgsElementData[window]
	local font = eleData.font or systemFont
	local textSizeX = eleData.textSize[1]
	local textSizeY = eleData.textSize[2]
	local absSize = eleData.absSize
	local text = eleData.text
	local colorCoded = eleData.colorCoded
	local wordBreak = eleData.wordBreak
    return dxGetTextSize(text,absSize[1],textSizeX,textSizeY,font,wordBreak,colorCoded)
end

----------------------------------------------------------------
-----------------------PropertyListener-------------------------
----------------------------------------------------------------
dgsOnPropertyChange["dgs-dxwindow"] = {
	closeButtonEnabled = function(dgsEle,key,value,oldValue)
		dgsWindowSetCloseButtonEnabled(dgsEle,value)
	end,
}
----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxwindow"] = function(source,x,y,w,h,mx,my,cx,cy,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt)
	local img = eleData.image
	local color = applyColorAlpha(eleData.color,parentAlpha)
	local titimg,titleColor,titsize = eleData.titleImage,eleData.isFocused and eleData.titleColor or (eleData.titleColorBlur or eleData.titleColor),eleData.titleHeight
	titleColor = applyColorAlpha(titleColor,parentAlpha)
	dxDrawImage(x,y+titsize,w,h-titsize,img,0,0,0,color,isPostGUI,rndtgt)
	dxDrawImage(x,y,w,titsize,titimg,0,0,0,titleColor,isPostGUI,rndtgt)
	local alignment = eleData.alignment

	local style = styleManager.styles[eleData.resource or "global"]
	style = style.loaded[style.using]
	local systemFont = style.systemFontElement

	local font = eleData.font or systemFont
	local textColor = applyColorAlpha(eleData.textColor,parentAlpha)
	local txtSizX,txtSizY = eleData.textSize[1],eleData.textSize[2] or eleData.textSize[1]
	local textOffset = eleData.textOffset
	if textOffset then
		x = x+(textOffset[3] and textOffset[1]*w or textOffset[1])
		y = y+(textOffset[3] and textOffset[2]*h or textOffset[2])
	end
	local clip,wordBreak,colorCoded = eleData.clip,eleData.wordBreak,eleData.colorCoded
	local text = eleData.text
	local shadow = eleData.shadow
	local shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont
	if shadow then
		shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont = shadow[1],shadow[2],shadow[3],shadow[4],shadow[5]
		shadowColor = applyColorAlpha(shadowColor or white,parentAlpha)
	end
	dgsDrawText(text,x,y,x+w,y+titsize,textColor,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordBreak,isPostGUI,colorCoded,subPixelPos,0,0,0,0,shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont)
	return rndtgt,false,mx,my,0,0
end