dgsLogLuaMemory()
dgsRegisterType("dgs-dxbutton","dgsBasic","dgsType2D")
dgsRegisterProperties("dgs-dxbutton",{
	alignment = 			{	{ PArg.String, PArg.String }	},
	clickOffset = 			{	{ PArg.Number, PArg.Number }	},
	clickType = 			{	PArg.Number	},
	clip = 					{	PArg.Bool	},
	color =					{	{ PArg.Color, PArg.Color, PArg.Color }	},
	colorCoded = 			{	PArg.Bool	},
	colorTransitionPeriod = {	PArg.Number	},
	font = 					{	PArg.Font+PArg.String	},
	iconColor = 			{	PArg.Color, { PArg.Color, PArg.Color, PArg.Color }	},
	iconImage = 			{	PArg.Nil+PArg.Material, { PArg.Nil+PArg.Material, PArg.Nil+PArg.Material, PArg.Nil+PArg.Material }	},
	iconOffset = 			{	{ PArg.Number, PArg.Number, PArg.Bool+PArg.Nil }	},
	iconRelative = 			{	PArg.Bool	},
	iconAlignment = 		{	{ PArg.String+PArg.Nil, PArg.String+PArg.Nil }	},
	iconSize = 				{	{ PArg.Number, PArg.Number, PArg.String+PArg.Bool }	},
	image = 				{	PArg.Nil+PArg.Material, { PArg.Nil+PArg.Material, PArg.Nil+PArg.Material, PArg.Nil+PArg.Material }	},
	shadow = 				{	{ PArg.Number, PArg.Number, PArg.Color, PArg.Number+PArg.Bool+PArg.Nil, PArg.Font+PArg.Nil }, PArg.Nil	},
	subPixelPositioning = 	{	PArg.Bool	},
	text = 					{	PArg.Text	},
	textColor = 			{	PArg.Color, { PArg.Color, PArg.Color, PArg.Color }	},
	textOffset = 			{	{ PArg.Number, PArg.Number, PArg.Bool }	},
	textSize = 				{	{ PArg.Number, PArg.Number }	},
	wordBreak = 			{	PArg.Bool	},
})

--Dx Functions
local dxDrawImage = dxDrawImage
local dxDrawImageSection = dxDrawImageSection
local dgsDrawText = dgsDrawText
local dxGetFontHeight = dxGetFontHeight
local dxGetTextWidth = dxGetTextWidth
--DGS Functions
local dgsSetType = dgsSetType
local dgsSetParent = dgsSetParent
local dgsGetType = dgsGetType
local dgsSetData = dgsSetData
local applyColorAlpha = applyColorAlpha
local dgsAttachToTranslation = dgsAttachToTranslation
local dgsAttachToAutoDestroy = dgsAttachToAutoDestroy
local calculateGuiPositionSize = calculateGuiPositionSize
local dgsCreateTextureFromStyle = dgsCreateTextureFromStyle
--Utilities
local dgsTriggerEvent = dgsTriggerEvent
local createElement = createElement
local assert = assert
local tonumber = tonumber
local type = type

function dgsCreateButton(...)
	local sRes = sourceResource or resource
	local x,y,w,h,text,relative,parent,textColor,scaleX,scaleY,normalImage,hoveringImage,clickedImage,normalColor,hoveringColor,clickedColor
	if select("#",...) == 1 and type(select(1,...)) == "table" then
		local argTable = ...
		x = argTable.x or argTable[1]
		y = argTable.y or argTable[2]
		w = argTable.width or argTable.w or argTable[3]
		h = argTable.height or argTable.h or argTable[4]
		text = argTable.text or argTable.txt or argTable[5]
		relative = argTable.relative or argTable.rlt or argTable[6]
		parent = argTable.parent or argTable.p or argTable[7]
		textColor = argTable.textColor or argTable[8]
		scaleX = argTable.scaleX or argTable[9]
		scaleY = argTable.scaleY or argTable[10]
		normalImage = argTable.normalImage or argTable[11]
		hoveringImage = argTable.hoveringImage or argTable[12]
		clickedImage = argTable.clickedImage or argTable[13]
		normalColor = argTable.normalColor or argTable[14]
		hoveringColor = argTable.hoveringColor or argTable[15]
		clickedColor = argTable.clickedColor or argTable[16]
	else
		x,y,w,h,text,relative,parent,textColor,scaleX,scaleY,normalImage,hoveringImage,clickedImage,normalColor,hoveringColor,clickedColor = ...
	end
	if not(type(x) == "number") then error(dgsGenAsrt(x,"dgsCreateButton",1,"number")) end
	if not(type(y) == "number") then error(dgsGenAsrt(y,"dgsCreateButton",2,"number")) end
	if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsCreateButton",3,"number")) end
	if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsCreateButton",4,"number")) end
	local button = createElement("dgs-dxbutton")
	dgsSetType(button,"dgs-dxbutton")
	
	local res = sRes ~= resource and sRes or "global"
	local style = styleManager.styles[res]
	local using = style.using
	style = style.loaded[using]
	local systemFont = style.systemFontElement
	style = style.button
	
	local normalColor = normalColor or style.color[1]
	local hoveringColor = hoveringColor or style.color[2]
	local clickedColor = clickedColor or style.color[3]
	local normalImage = normalImage or dgsCreateTextureFromStyle(using,res,style.image[1])
	local hoveringImage = hoveringImage or dgsCreateTextureFromStyle(using,res,style.image[2]) or normalImage
	local clickedImage = clickedImage or dgsCreateTextureFromStyle(using,res,style.image[3]) or normalImage
	local textSizeX,textSizeY = tonumber(scaleX) or style.textSize[1], tonumber(scaleY) or style.textSize[2]
	dgsElementData[button] = {
		alignment = {"center","center"},
		clickOffset = {0,0},
		clickType = 1;	--1:LMB;2:Wheel;3:RM,
		clip = nil,
		colorTransitionPeriod = 0, --ms
		color = {normalColor, hoveringColor, clickedColor},
		colorCoded = nil,
		font = style.font or systemFont,
		iconColor = 0xFFFFFFFF,
		iconAlignment = {"left","center"},
		iconImage = nil,
		iconRelative = true,	--true for text, false for button
		iconOffset = {0,0,false},-- Can be false/true
		iconSize = {1,1,"text"}, -- Can be false/true/"text"
		--iconShadow = {},
		imageTransformTime = 0, --ms
		image = {normalImage, hoveringImage, clickedImage},
		--shadow = {},
		textColor = tonumber(textColor) or style.textColor,
		textOffset = {0,0,false},
		textSize = {textSizeX, textSizeY},
		wordBreak = nil,
		renderBuffer = {
			lastState = 0,
		},
	}
	dgsSetParent(button,parent,true,true)
	dgsAttachToTranslation(button,resourceTranslation[sRes])
	if type(text) == "table" then
		dgsElementData[button]._translation_text = text
		dgsSetData(button,"text",text)
	else
		dgsSetData(button,"text",tostring(text or ""))
	end
	calculateGuiPositionSize(button,x,y,relative or false,w,h,relative or false,true)
	onDGSElementCreate(button,sRes)
	return button
end

function dgsButtonGetTextExtent(button)
	if dgsGetType(button) ~= "dgs-dxbutton" then error(dgsGenAsrt(button,"dgsButtonGetTextExtent",1,"dgs-dxbutton")) end
	local eleData = dgsElementData[button]
	local font = eleData.font or systemFont
	local textSizeX = eleData.textSize[1]
	local text = eleData.text
	local colorCoded = eleData.colorCoded
	return dxGetTextWidth(text,textSizeX,font,colorCoded)
end

function dgsButtonGetFontHeight(button)
	if dgsGetType(button) ~= "dgs-dxbutton" then error(dgsGenAsrt(button,"dgsButtonGetFontHeight",1,"dgs-dxbutton")) end
	local font = dgsElementData[button].font or systemFont
	local textSizeY = dgsElementData[button].textSize[2]
	return dxGetFontHeight(textSizeY,font)
end

function dgsButtonGetTextSize(button)
	if dgsGetType(button) ~= "dgs-dxbutton" then error(dgsGenAsrt(button,"dgsButtonGetTextSize",1,"dgs-dxbutton")) end
	local eleData = dgsElementData[button]
	local font = eleData.font or systemFont
	local textSizeX = eleData.textSize[1]
	local textSizeY = eleData.textSize[2]
	local absSize = eleData.absSize
	local text = eleData.text
	local colorCoded = eleData.colorCoded
	local wordBreak = eleData.wordBreak
    return dxGetTextSize(text,absSize[1],textSizeX,textSizeY,font,wordBreak,colorCoded)
end

function dgsButtonSubmitForm()
	local formAssembly = dgsElementData[source].formAssembly
	local texts = {}
	for key,ele in pairs(formAssembly) do
		if isElement(ele) then
			texts[key] = dgsGetText(ele)
		else
			texts[key] = false
		end
	end
	dgsTriggerEvent("onDgsFormSubmit",source,texts)
end

function dgsButtonMakeForm(button,forms)
	if dgsGetType(button) ~= "dgs-dxbutton" then error(dgsGenAsrt(button,"dgsButtonMakeForm",1,"dgs-dxbutton")) end
	for key,ele in pairs(forms) do
		local dgsType = dgsGetType(ele)
		if not (dgsType == "dgs-dxedit" or dgsType == "dgs-dxmemo") then error(dgsGenAsrt(ele,"dgsButtonMakeForm",2,"dgs-dxedit/dgs-dxmemo","at")) end
	end
	dgsSetData(button,"formAssembly",forms)
	dgsAddEventHandler("onDgsMouseClickUp",button,"dgsButtonSubmitForm",false)
end

function dgsButtonRemoveForm(button)
	if dgsGetType(button) ~= "dgs-dxbutton" then error(dgsGenAsrt(button,"dgsButtonRemoveForm",1,"dgs-dxbutton")) end
	dgsSetData(button,"formAssembly",nil)
	dgsRemoveEventHandler("onDgsMouseClickUp",button,"dgsButtonSubmitForm",false)
end
--function dgsButtonSetIconImage()
--function dgsButtonSetIconColor()
----------------------------------------------------------------
-----------------------PropertyListener-------------------------
----------------------------------------------------------------
dgsOnPropertyChange["dgs-dxbutton"] = {
	color = function(dgsEle,key,value,oldValue)
		local eleData = dgsElementData[dgsEle]
		if eleData.colorTransitionPeriod <= 0 then return end
		local renderBuffer = eleData.renderBuffer
		local context = renderBuffer.startContext
		if context then
			local colorFrom = type(value) ~= "table" and value or value[context[1] or eleData.currentState or 1]
			local colorTo = type(value) ~= "table" and value or value[context[2] or eleData.currentState or 1]
			renderBuffer.startColor = interpolateColor(colorFrom,colorTo,renderBuffer.currentProgress)
		end
	end,
	textColor = function(dgsEle,key,value,oldValue)
		local eleData = dgsElementData[dgsEle]
		if eleData.colorTransitionPeriod <= 0 then return end
		local renderBuffer = eleData.renderBuffer
		local context = renderBuffer.startContext
		if context then
			local colorFrom = type(value) ~= "table" and value or value[context[1] or eleData.currentState or 1]
			local colorTo = type(value) ~= "table" and value or value[context[2] or eleData.currentState or 1]
			renderBuffer.startTextColor = interpolateColor(colorFrom,colorTo,renderBuffer.currentProgress)
		end
	end,
}
----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxbutton"] = function(source,x,y,w,h,mx,my,cx,cy,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt)
	local renderBuffer = eleData.renderBuffer
	local color = eleData.color
	local image = eleData.image
	local textColor = eleData.textColor
	local buttonState = 1
	if MouseData.entered == source then
		buttonState = 2
		if eleData.clickType == 1 then
			if MouseData.click.left == source then
				buttonState = 3
			end
		elseif eleData.clickType == 2 then
			if MouseData.click.right == source then
				buttonState = 3
			end
		else
			if MouseData.click.left == source or MouseData.click.right == source then
				buttonState = 3
			end
		end
	end
	if eleData.lastState ~= buttonState then
		eleData.lastState = eleData.currentState
		eleData.lastStateTick = getTickCount()
	end
	if eleData.currentState ~= buttonState then
		eleData.currentState = buttonState
		eleData.currentStateTick = getTickCount()
		if not renderBuffer.startContext then renderBuffer.startContext = {} end
		renderBuffer.startContext[1] = eleData.lastState
		renderBuffer.startContext[2] = eleData.currentState
		renderBuffer.startColor = renderBuffer.currentColor or (type(color) ~= "table" and color or color[eleData.lastState])
		renderBuffer.startTextColor = renderBuffer.currentTextColor or (type(textColor) ~= "table" and textColor or textColor[eleData.lastState])
	end
	local bgColor = type(color) ~= "table" and color or color[buttonState] 
	local bgImage = type(image) ~= "table" and image or image[buttonState]
	local textColor = type(textColor) ~= "table" and textColor or (textColor[buttonState] or textColor[1])
	local finalcolor
	if not enabledInherited and not enabledSelf then
		if type(eleData.disabledColor) == "number" then
			finalcolor = applyColorAlpha(eleData.disabledColor,parentAlpha)
		elseif eleData.disabledColor == true then
			local r,g,b,a = fromcolor(bgColor)
			local average = (r+g+b)/3*eleData.disabledColorPercent
			finalcolor = tocolor(average,average,average,a*parentAlpha)
		else
			local targetColor = bgColor
			if eleData.colorTransitionPeriod > 0 then
				renderBuffer.currentColor = interpolateColor(renderBuffer.startColor or targetColor,targetColor,(getTickCount()-eleData.currentStateTick)/eleData.colorTransitionPeriod)
				finalcolor = applyColorAlpha(renderBuffer.currentColor,parentAlpha)
			else
				finalcolor = applyColorAlpha(targetColor,parentAlpha)
			end
		end
	else
		local targetColor = bgColor
		local targetTextColor = textColor
		if eleData.colorTransitionPeriod > 0 and getTickCount()-eleData.currentStateTick <= eleData.colorTransitionPeriod then
			local progress = (getTickCount()-eleData.currentStateTick)/eleData.colorTransitionPeriod
			renderBuffer.currentColor = interpolateColor(renderBuffer.startColor or targetColor,targetColor,progress)
			renderBuffer.currentTextColor = interpolateColor(renderBuffer.startTextColor or targetTextColor,targetTextColor,progress)
			renderBuffer.currentProgress = progress
			textColor = renderBuffer.currentTextColor
			finalcolor = applyColorAlpha(renderBuffer.currentColor,parentAlpha)
		else
			renderBuffer.currentProgress = 1
			renderBuffer.currentColor = targetColor
			finalcolor = applyColorAlpha(targetColor,parentAlpha)
		end
	end
	------------------------------------
	if eleData.functionRunBefore then
		local fnc = eleData.functions
		if type(fnc) == "table" then
			fnc[1](unpack(fnc[2]))
		end
	end
	------------------------------------
	if finalcolor/0x1000000%256 >= 1 then	--Optimise when alpha = 0
		dxDrawImage(x,y,w,h,bgImage,0,0,0,finalcolor,isPostGUI,rndtgt)
	end
	local text = eleData.text
	local textSizeX,textSizeY = eleData.textSize[1],eleData.textSize[2] or eleData.textSize[1]
	
	local res = eleData.resource or "global"
	local style = styleManager.styles[res]
	local using = style.using
	style = style.loaded[style.using]
	local systemFont = style.systemFontElement
	
	local wordBreak = eleData.wordBreak
	local font = eleData.font or systemFont
	local colorCoded = eleData.colorCoded
	local textOffset = eleData.textOffset
	local txtoffsetsX = textOffset[3] and textOffset[1]*w or textOffset[1]
	local txtoffsetsY = textOffset[3] and textOffset[2]*h or textOffset[2]
	local alignment = eleData.alignment
	local iconImage = eleData.iconImage
	if iconImage then
		local iconColor = eleData.iconColor
		local iconShadow = eleData.iconShadow
		local iconSize = eleData.iconSize
		local fontWidth = dxGetTextSize(text,w,textSizeX,textSizeY,font,wordBreak,colorCoded)
		local fontHeight = dxGetFontHeight(txtSizeY,font)
		local iconHeight,iconWidth = iconSize[2],iconSize[1]
		if iconSize[3] == "text" then
			iconWidth,iconHeight = fontHeight*iconSize[1],fontHeight*iconSize[2]
		elseif iconSize[3] == true then
			iconWidth,iconHeight = w*iconSize[1],h*iconSize[2]
		end
		local posX,posY = 0,0
		local iconOffset = eleData.iconOffset
		local iconAlignment = eleData.iconAlignment
		if eleData.iconRelative then
			posX,posY = txtoffsetsX,txtoffsetsY
			if iconAlignment[1] == "left" then
				if alignment[1] == "left" then
					posX = posX-iconWidth
				elseif alignment[1] == "right" then
					posX = posX+w-fontWidth-iconWidth
				else
					posX = posX+w/2-fontWidth/2-iconWidth
				end
			elseif iconAlignment[1] == "right" then
				if alignment[1] == "left" then
					posX = posX+fontWidth
				elseif alignment[1] == "right" then
					posX = posX+w
				else
					posX = posX+w/2+fontWidth/2
				end
			elseif iconAlignment[1] == "center" then
				if alignment[1] == "left" then
					posX = posX+fontWidth/2-iconWidth/2
				elseif alignment[1] == "right" then
					posX = posX+w-fontWidth/2-iconWidth/2
				else
					posX = posX+w/2-iconWidth/2
				end
			end
			if iconAlignment[2] == "top" then
				if alignment[2] == "top" then
					posY = posY-iconHeight
				elseif alignment[2] == "bottom" then
					posY = posY+h-fontHeight-iconHeight
				else
					posY = posY+h/2-fontHeight/2-iconHeight
				end
			elseif iconAlignment[2] == "bottom" then
				if alignment[2] == "top" then
					posY = posY+fontHeight
				elseif alignment[2] == "bottom" then
					posY = posY+h
				else
					posY = posY+h/2+fontHeight/2
				end
			elseif iconAlignment[2] == "center" then
				if alignment[2] == "top" then
					posY = posY+fontHeight/2-iconHeight/2
				elseif alignment[2] == "bottom" then
					posY = posY+h-fontHeight/2-iconHeight/2
				else
					posY = posY+h/2-iconHeight/2
				end
			end
		else
			if iconAlignment[1] == "right" then
				posX = posX+w-iconWidth
			elseif iconAlignment[1] == "center" then
				posX = posX+w/2-iconWidth/2
			end
			if iconAlignment[2] == "bottom" then
				posY = posY+h-iconHeight
			elseif iconAlignment[2] == "center" then
				posY = posY+h/2-iconHeight/2
			end
		end
		if type(iconOffset) == "table" then
			posX = posX+(iconOffset[3] and w*iconOffset[1] or iconOffset[1])
			posY = posY+(iconOffset[3] and h*iconOffset[2] or iconOffset[2])
		else
			posX = posX+iconOffset
			posY = posY+iconOffset
		end
		posX,posY = posX+x,posY+y
		iconImage = type(iconImage) ~= "table" and iconImage or iconImage[buttonState]
		iconColor = type(iconColor) ~= "table" and iconColor or iconColor[buttonState]
		if iconImage then
			if iconShadow then
				local shadowoffx,shadowoffy,shadowc,shadowIsOutline = iconShadow[1],iconShadow[2],iconShadow[3],iconShadow[4]
				if shadowoffx and shadowoffy and shadowc then
					local shadowc = applyColorAlpha(shadowc,parentAlpha)
					dxDrawImage(posX+shadowoffx,posY+shadowoffy,iconWidth,iconHeight,iconImage,0,0,0,shadowc,isPostGUI,rndtgt)
					if shadowIsOutline then
						dxDrawImage(posX-shadowoffx,posY+shadowoffy,iconWidth,iconHeight,iconImage,0,0,0,shadowc,isPostGUI,rndtgt)
						dxDrawImage(posX-shadowoffx,posY-shadowoffy,iconWidth,iconHeight,iconImage,0,0,0,shadowc,isPostGUI,rndtgt)
						dxDrawImage(posX+shadowoffx,posY-shadowoffy,iconWidth,iconHeight,iconImage,0,0,0,shadowc,isPostGUI,rndtgt)
					end
				end
			end
			dxDrawImage(posX,posY,iconWidth,iconHeight,iconImage,0,0,0,applyColorAlpha(iconColor,parentAlpha),isPostGUI,rndtgt)
		end
	end

	if #text ~= 0 then
		local clip = eleData.clip
		if buttonState == 3 then
			txtoffsetsX,txtoffsetsY = txtoffsetsX+eleData.clickOffset[1],txtoffsetsY+eleData.clickOffset[2]
		end
		local textX,textY = x+txtoffsetsX,y+txtoffsetsY
		local shadow = eleData.shadow
		local shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont
		if shadow then
			shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont = shadow[1],shadow[2],shadow[3],shadow[4],shadow[5]
			shadowColor = applyColorAlpha(shadowColor or white,parentAlpha)
		end
		
		dgsDrawText(text,textX,textY,textX+w,textY+h,applyColorAlpha(textColor,parentAlpha),textSizeX,textSizeY,font,alignment[1],alignment[2],clip,wordBreak,isPostGUI,colorCoded,subPixelPos,0,0,0,0,shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont)
	end

	return rndtgt,false,mx,my,0,0
end