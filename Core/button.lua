--Dx Functions
local dxDrawImage = dxDrawImageExt
local dxDrawImageSection = dxDrawImageSectionExt
local dxDrawText = dxDrawText
local dxGetFontHeight = dxGetFontHeight
local dxDrawRectangle = dxDrawRectangle
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
local triggerEvent = triggerEvent
local createElement = createElement
local assert = assert
local tonumber = tonumber
local type = type

function dgsCreateButton(...)
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
	dgsSetParent(button,parent,true,true)
	local style = styleSettings.button
	local normalColor = normalColor or style.color[1]
	local hoveringColor = hoveringColor or style.color[2]
	local clickedColor = clickedColor or style.color[3]
	local normalImage = normalImage or dgsCreateTextureFromStyle(style.image[1])
	local hoveringImage = hoveringImage or dgsCreateTextureFromStyle(style.image[2])
	local clickedImage = clickedImage or dgsCreateTextureFromStyle(style.image[3])
	local textSizeX,textSizeY = tonumber(scaleX) or style.textSize[1], tonumber(scaleY) or style.textSize[2]
	dgsElementData[button] = {
		alignment = {"center","center"},
		clickOffset = {0,0},
		clickType = 1;	--1:LMB;2:Wheel;3:RM,
		clip = false,
		color = {normalColor, hoveringColor, clickedColor},
		colorcoded = false,
		font = style.font or systemFont,
		iconColor = 0xFFFFFFFF,
		iconDirection = "left",
		iconImage = nil,
		iconOffset = {0,0},
		iconSize = {1,1,"text"}; -- Can be false/true/"text"
		iconShadow = {},
		image = {normalImage, hoveringImage, clickedImage},
		shadow = {},
		textColor = tonumber(textColor) or style.textColor,
		textOffset = {0,0,false},
		textSize = {textSizeX, textSizeY},
		wordbreak = false,

		renderBuffer = {},
	}
	dgsAttachToTranslation(button,resourceTranslation[sourceResource or resource])
	if type(text) == "table" then
		dgsElementData[button]._translationText = text
		dgsSetData(button,"text",text)
	else
		dgsSetData(button,"text",tostring(text))
	end
	calculateGuiPositionSize(button,x,y,relative or false,w,h,relative or false,true)
	triggerEvent("onDgsCreate",button,sourceResource)
	return button
end

--function dgsButtonSetIconImage()
--function dgsButtonSetIconColor()
----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxbutton"] = function(source,x,y,w,h,mx,my,cx,cy,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt)
	local colors,imgs = eleData.color,eleData.image
	local buttonState = 1
	if MouseData.entered == source then
		buttonState = 2
		if eleData.clickType == 1 then
			if MouseData.clickl == source then
				buttonState = 3
			end
		elseif eleData.clickType == 2 then
			if MouseData.clickr == source then
				buttonState = 3
			end
		else
			if MouseData.clickl == source or MouseData.clickr == source then
				buttonState = 3
			end
		end
	end
	local finalcolor
	if not enabledInherited and not enabledSelf then
		if type(eleData.disabledColor) == "number" then
			finalcolor = applyColorAlpha(eleData.disabledColor,parentAlpha)
		elseif eleData.disabledColor == true then
			local r,g,b,a = fromcolor(colors[1],true)
			local average = (r+g+b)/3*eleData.disabledColorPercent
			finalcolor = tocolor(average,average,average,a*parentAlpha)
		else
			finalcolor = colors[buttonState]
		end
	else
		finalcolor = applyColorAlpha(colors[buttonState],parentAlpha)
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
		if imgs[buttonState] then
			dxDrawImage(x,y,w,h,imgs[buttonState],0,0,0,finalcolor,isPostGUI,rndtgt)
		else
			dxDrawRectangle(x,y,w,h,finalcolor,isPostGUI)
		end
	end
	local text = eleData.text
	local txtSizX,txtSizY = eleData.textSize[1],eleData.textSize[2] or eleData.textSize[1]
	local font = eleData.font or systemFont
	local colorcoded = eleData.colorcoded
	local textOffset = eleData.textOffset
	local txtoffsetsX = textOffset[3] and textOffset[1]*w or textOffset[1]
	local txtoffsetsY = textOffset[3] and textOffset[2]*h or textOffset[2]
	local alignment = eleData.alignment

	local iconImage = eleData.iconImage
	if iconImage then
		local iconColor = eleData.iconColor
		local iconShadow = eleData.iconShadow
		iconImage = type(iconImage) == "table" and iconImage or {iconImage,iconImage,iconImage}
		iconColor = type(iconColor) == "table" and iconColor or {iconColor,iconColor,iconColor}
		local iconSize = eleData.iconSize
		local fontHeight = dxGetFontHeight(txtSizY,font)
		local fontWidth = dxGetTextWidth(text,txtSizX,font,colorcoded)
		local iconHeight,iconWidth = iconSize[2],iconSize[1]
		if iconSize[3] == "text" then
			iconWidth,iconHeight = fontHeight*iconSize[1],fontHeight*iconSize[2]
		elseif iconSize[3] == true then
			iconWidth,iconHeight = w*iconSize[1],h*iconSize[2]
		end
		local posX,posY = txtoffsetsX,txtoffsetsY
		local iconOffset = eleData.iconOffset
		if type(iconOffset) == "table" then
			if eleData.iconDirection == "left" then
				if alignment[1] == "left" then
					posX = posX-iconWidth
				elseif alignment[1] == "right" then
					posX = posX+w-fontWidth-iconWidth
				else
					posX = posX+w/2-fontWidth/2-iconWidth
				end
			elseif eleData.iconDirection == "right" then
				if alignment[1] == "left" then
					posX = posX+fontWidth
				elseif alignment[1] == "right" then
					posX = posX+w
				else
					posX = posX+w/2+fontWidth/2
				end
			end
			if alignment[2] == "top" then
				posY = posY
			elseif alignment[2] == "bottom" then
				posY = posY+h-fontHeight
			else
				posY = posY+(h-iconHeight)/2
			end
			posX = posX+iconOffset[1]
			posY = posY+iconOffset[2]
		else
			if eleData.iconDirection == "left" then
				if alignment[1] == "left" then
					posX = posX-iconWidth-iconOffset
				elseif alignment[1] == "right" then
					posX = posX+w-fontWidth-iconWidth-iconOffset
				else
					posX = posX+w/2-fontWidth/2-iconWidth-iconOffset
				end
			elseif eleData.iconDirection == "right" then
				if alignment[1] == "left" then
					posX = posX+fontWidth+iconOffset
				elseif alignment[1] == "right" then
					posX = posX+w+iconOffset
				else
					posX = posX+w/2+fontWidth/2+iconOffset
				end
			end
			if alignment[2] == "top" then
				posY = posY-iconOffset
			elseif alignment[2] == "bottom" then
				posY = posY+h-fontHeight+iconOffset
			else
				posY = posY+(h-iconHeight)/2+iconOffset
			end
		end
		posX,posY = posX+x,posY+y
		if iconImage[buttonState] then
			local shadowoffx,shadowoffy,shadowc,shadowIsOutline = iconShadow[1],iconShadow[2],iconShadow[3],iconShadow[4]
			if shadowoffx and shadowoffy and shadowc then
				local shadowc = applyColorAlpha(shadowc,parentAlpha)
				dxDrawImage(posX+shadowoffx,posY+shadowoffy,iconWidth,iconHeight,iconImage[buttonState],0,0,0,shadowc,isPostGUI,rndtgt)
				if shadowIsOutline then
					dxDrawImage(posX-shadowoffx,posY+shadowoffy,iconWidth,iconHeight,iconImage[buttonState],0,0,0,shadowc,isPostGUI,rndtgt)
					dxDrawImage(posX-shadowoffx,posY-shadowoffy,iconWidth,iconHeight,iconImage[buttonState],0,0,0,shadowc,isPostGUI,rndtgt)
					dxDrawImage(posX+shadowoffx,posY-shadowoffy,iconWidth,iconHeight,iconImage[buttonState],0,0,0,shadowc,isPostGUI,rndtgt)
				end
			end
			dxDrawImage(posX,posY,iconWidth,iconHeight,iconImage[buttonState],0,0,0,applyColorAlpha(iconColor[buttonState],parentAlpha),isPostGUI,rndtgt)
		end
	end

	if #text ~= 0 then
		local clip = eleData.clip
		local wordbreak = eleData.wordbreak
		if buttonState == 3 then
			txtoffsetsX,txtoffsetsY = txtoffsetsX+eleData.clickOffset[1],txtoffsetsY+eleData.clickOffset[2]
		end
		local textX,textY = x+txtoffsetsX,y+txtoffsetsY
		local shadow = eleData.shadow
		if shadow then
			local shadowoffx,shadowoffy,shadowc,shadowIsOutline = shadow[1],shadow[2],shadow[3],shadow[4]
			if shadowoffx and shadowoffy and shadowc then
				local shadowText = colorcoded and text:gsub('#%x%x%x%x%x%x','') or text
				local shadowc = applyColorAlpha(shadowc,parentAlpha)
				dxDrawText(shadowText,textX+shadowoffx,textY+shadowoffy,textX+w+shadowoffx,textY+h+shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,isPostGUI)
				if shadowIsOutline then
					dxDrawText(shadowText,textX-shadowoffx,textY+shadowoffy,textX+w-shadowoffx,textY+h+shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,isPostGUI)
					dxDrawText(shadowText,textX-shadowoffx,textY-shadowoffy,textX+w-shadowoffx,textY+h-shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,isPostGUI)
					dxDrawText(shadowText,textX+shadowoffx,textY-shadowoffy,textX+w+shadowoffx,textY+h-shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,isPostGUI)
				end
			end
		end
		local textColor = eleData.textColor
		if type(textColor) == "table" then
			textColor = textColor[buttonState] or textColor[1]
		end
		dxDrawText(text,textX,textY,textX+w-1,textY+h-1,applyColorAlpha(textColor,parentAlpha),txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,isPostGUI,colorcoded)
	end

	return rndtgt,false,mx,my,0,0
end