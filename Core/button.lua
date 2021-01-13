--Dx Functions
local dxDrawImage = dxDrawImageExt
local dxDrawImageSection = dxDrawImageSectionExt
local dxDrawText = dxDrawText
local dxGetFontHeight = dxGetFontHeight
local dxDrawRectangle = dxDrawRectangle
local dxGetTextWidth = dxGetTextWidth
local _dxDrawImage = _dxDrawImage
local _dxDrawImageSection = _dxDrawImageSection
--

function dgsCreateButton(x,y,w,h,text,relative,parent,textColor,scalex,scaley,norimg,selimg,cliimg,norcolor,hovcolor,clicolor)
	local __x,__y,__w,__h = tonumber(x),tonumber(y),tonumber(w),tonumber(h)
	if not __x then assert(false,"Bad argument @dgsCreateButton at argument 1, expect number got "..type(x)) end
	if not __y then assert(false,"Bad argument @dgsCreateButton at argument 2, expect number got "..type(y)) end
	if not __w then assert(false,"Bad argument @dgsCreateButton at argument 3, expect number got "..type(w)) end
	if not __h then assert(false,"Bad argument @dgsCreateButton at argument 4, expect number got "..type(h)) end
	local button = createElement("dgs-dxbutton")
	dgsSetType(button,"dgs-dxbutton")
	dgsSetParent(button,parent,true,true)
	local norcolor = norcolor or styleSettings.button.color[1]
	local hovcolor = hovcolor or styleSettings.button.color[2]
	local clicolor = clicolor or styleSettings.button.color[3]
	local norimg = norimg or dgsCreateTextureFromStyle(styleSettings.button.image[1])
	local hovimg = selimg or dgsCreateTextureFromStyle(styleSettings.button.image[2])
	local cliimg = cliimg or dgsCreateTextureFromStyle(styleSettings.button.image[3])
	local textSizeX,textSizeY = tonumber(scalex) or styleSettings.button.textSize[1], tonumber(scaley) or styleSettings.button.textSize[2]
	dgsElementData[button] = {
		alignment = {"center","center"};
		clickOffset = {0,0};
		clickType = 1;	--1:LMB;2:Wheel;3:RMB
		clip = false;
		color = {norcolor, hovcolor, clicolor};
		colorcoded = false;
		font = styleSettings.button.font or systemFont;
		iconColor = tocolor(255,255,255,255);
		iconDirection = "left";
		iconImage = nil;
		iconOffset = 5;
		iconSize = {1,1,true}; -- Text's font height
		image = {norimg, hovimg, cliimg};
		shadow = {};
		textColor = tonumber(textColor) or styleSettings.button.textColor;
		textOffset = {0,0,false};
		textSize = {textSizeX, textSizeY};
		wordbreak = false;
	}
	dgsAttachToTranslation(button,resourceTranslation[sourceResource or getThisResource()])
	if type(text) == "table" then
		dgsElementData[button]._translationText = text
		dgsSetData(button,"text",text)
	else
		dgsSetData(button,"text",tostring(text))
	end
	calculateGuiPositionSize(button,__x,__y,relative or false,__w,__h,relative or false,true)
	triggerEvent("onDgsCreate",button,sourceResource)
	return button
end

--function dgsButtonSetIconImage()
--function dgsButtonSetIconColor()
----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxbutton"] = function(source,x,y,w,h,mx,my,cx,cy,enabled,eleData,parentAlpha,isPostGUI,rndtgt)
	local colors,imgs = eleData.color,eleData.image
	local buttonState = 1
	if MouseData.enter == source then
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
	if not enabled[1] and not enabled[2] then
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
	if imgs[buttonState] then
		dxDrawImage(x,y,w,h,imgs[buttonState],0,0,0,finalcolor,isPostGUI,rndtgt)
	else
		dxDrawRectangle(x,y,w,h,finalcolor,isPostGUI)
	end
	local text = eleData.text
	local txtSizX,txtSizY = eleData.textSize[1],eleData.textSize[2] or eleData.textSize[1]
	local font = eleData.font or systemFont
	local colorcoded = eleData.colorcoded
	local textOffset = eleData.textOffset
	local txtoffsetsX = textOffset[3] and textOffset[1]*w or textOffset[1]
	local txtoffsetsY = textOffset[3] and textOffset[2]*h or textOffset[2]
	local alignment = eleData.alignment
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
	local iconImage = eleData.iconImage
	if iconImage then
		local iconColor = eleData.iconColor
		iconImage = type(iconImage) == "table" and iconImage or {iconImage,iconImage,iconImage}
		iconColor = type(iconColor) == "table" and iconColor or {iconColor,iconColor,iconColor}
		local iconSize = eleData.iconSize
		local fontHeight = dxGetFontHeight(txtSizY,font)
		local fontWidth = dxGetTextWidth(text,txtSizX,font,colorcoded)
		local iconHeight = iconSize[3] and fontHeight*iconSize[2] or iconSize[2]
		local posY = txtoffsetsY
		local iconWidth = iconSize[3] and fontHeight*iconSize[1] or iconSize[1]
		local posX = txtoffsetsX
		local iconOffset = eleData.iconOffset
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
			posY = posY
		elseif alignment[2] == "bottom" then
			posY = posY+h-fontHeight
		else
			posY = posY+(h-iconHeight)/2
		end
		posX,posY = posX+x,posY+y
		if iconImage[buttonState] then
			dxDrawImage(posX,posY,iconWidth,iconHeight,iconImage[buttonState],0,0,0,applyColorAlpha(iconColor[buttonState],parentAlpha),isPostGUI,rndtgt)
		end
	end
	return rndtgt
end