--Dx Functions
local dxDrawImage = dxDrawImageExt
local dxDrawText = dxDrawText
local dxDrawRectangle = dxDrawRectangle
--DGS Functions
local dgsSetType = dgsSetType
local dgsGetType = dgsGetType
local dgsSetData = dgsSetData
local dgsSetParent = dgsSetParent
local applyColorAlpha = applyColorAlpha
local dgsTranslate = dgsTranslate
local dgsIsType = dgsIsType
local dgsAttachToTranslation = dgsAttachToTranslation
local dgsAttachToAutoDestroy = dgsAttachToAutoDestroy
local calculateGuiPositionSize = calculateGuiPositionSize
local dgsCreateTextureFromStyle = dgsCreateTextureFromStyle
--Utilities
local triggerEvent = triggerEvent
local createElement = createElement
local assert = assert
local type = type
local tostring = tostring
local tonumber = tonumber

function dgsCreateRadioButton(...)
	local x,y,w,h,text,relative,parent,textColor,scaleX,scaleY,nImageF,hImageF,cImageF,nColorF,hColorF,cColorF,nImageT,hImageT,cImageT,nColorT,hColorT,cColorT
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
		nImageF = argTable.normalUncheckedImage or argTable.nImageF or argTable[11]
		hImageF = argTable.hoveringUncheckedImage or argTable.hImageF or argTable[12]
		cImageF = argTable.clickedUnCheckedImage or argTable.cImageF or argTable[13]
		nColorF = argTable.normalUnCheckedColor or argTable.nColorF or argTable[14]
		hColorF = argTable.hoveringUnCheckedColor or argTable.hColorF or argTable[15]
		cColorF = argTable.clickedUnCheckedColor or argTable.cColorF or argTable[16]
		nImageT = argTable.normalCheckedImage or argTable.nImageT or argTable[17]
		hImageT = argTable.hoveringCheckedImage or argTable.hImageT or argTable[18]
		cImageT = argTable.clickedCheckedImage or argTable.cImageT or argTable[19]
		nColorT = argTable.normalCheckedColor or argTable.nColorT or argTable[20]
		hColorT = argTable.hoveringCheckedColor or argTable.hColorT or argTable[21]
		cColorT = argTable.clickedCheckedColor or argTable.cColorT or argTable[22]

	else
		x,y,w,h,text,relative,parent,textColor,scalex,scaley,nImageF,hImageF,cImageF,nColorF,hColorF,cColorF,nImageT,hImageT,cImageT,nColorT,hColorT,cColorT = ...
	end
	if not(type(x) == "number") then error(dgsGenAsrt(x,"dgsCreateRadioButton",1,"number")) end
	if not(type(y) == "number") then error(dgsGenAsrt(y,"dgsCreateRadioButton",2,"number")) end
	if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsCreateRadioButton",3,"number")) end
	if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsCreateRadioButton",4,"number")) end
	local rb = createElement("dgs-dxradiobutton")
	dgsSetType(rb,"dgs-dxradiobutton")
	dgsSetParent(rb,parent,true,true)
	local style = styleSettings.radiobutton
	local imageUnchecked = style.image_f
	nImageF = nImageF or dgsCreateTextureFromStyle(imageUnchecked[1])
	hImageF = hImageF or dgsCreateTextureFromStyle(imageUnchecked[2])
	cImageF = cImageF or dgsCreateTextureFromStyle(imageUnchecked[3])
	local colorUnchecked = style.color_f
	nColorF = nColorF or colorUnchecked[1]
	hColorF = hColorF or colorUnchecked[2]
	cColorF = cColorF or colorUnchecked[3]
	local imageChecked = style.image_t
	nImageT = nImageT or dgsCreateTextureFromStyle(imageChecked[1])
	hImageT = hImageT or dgsCreateTextureFromStyle(imageChecked[2])
	cImageT = cImageT or dgsCreateTextureFromStyle(imageChecked[3])
	local colorChecked = style.color_t
	nColorT = nColorT or colorChecked[1]
	hColorT = hColorT or colorChecked[2]
	cColorT = cColorT or colorChecked[3]
	local textSizeX,textSizeY = tonumber(scalex) or style.textSize[1], tonumber(scaley) or style.textSize[2]
	dgsElementData[rb] = {
		renderBuffer = {},
		image_f = {nImageF,hImageF,cImageF},
		color_f = {nColorF,hColorF,cColorF},
		image_t = {nImageT,hImageT,cImageT},
		color_t = {nColorT,hColorT,cColorT},
		rbParent = dgsIsType(parent) and parent or resourceRoot,
		text = tostring(text),
		textColor = textColor or style.textColor,
		textSize = {textSizeX,textSizeY},
		textPadding = style.textPadding,
		buttonSize = style.buttonSize,
		shadow = {},
		font = style.font or systemFont,
		clip = false,
		wordbreak = false,
		colorcoded = false,
		alignment = {left,"center"},
	}
	dgsAttachToTranslation(rb,resourceTranslation[sourceResource or resource])
	if type(text) == "table" then
		dgsElementData[rb]._translationText = text
		dgsElementData[rb].text = dgsTranslate(rb,text,sourceResource)
	end
	calculateGuiPositionSize(rb,x,y,relative or false,w,h,relative or false,true)
	triggerEvent("onDgsCreate",rb,sourceResource)
	return rb
end

function dgsRadioButtonGetSelected(rb)
	if dgsGetType(rb) ~= "dgs-dxradiobutton" then error(dgsGenAsrt(rb,"dgsRadioButtonGetSelected",1,"dgs-dxradiobutton")) end
	local _parent = dgsGetParent(rb)
	local parent = dgsIsType(_parent) and _parent or resourceRoot
	return dgsGetData(parent,"RadioButton") == rb
end

function dgsRadioButtonSetSelected(rb,state)
	if dgsGetType(rb) ~= "dgs-dxradiobutton" then error(dgsGenAsrt(rb,"dgsRadioButtonSetSelected",1,"dgs-dxradiobutton")) end
	state = state and true or false
	local _parent = dgsGetParent(rb)
	local parent = dgsIsType(_parent) and _parent or resourceRoot
	local _rb = dgsGetData(parent,"RadioButton")
	if state then
		if rb ~= _rb then
			dgsSetData(parent,"RadioButton",rb)
			if dgsIsType(_rb) then
				triggerEvent("onDgsRadioButtonChange",_rb,false)
			end
			triggerEvent("onDgsRadioButtonChange",rb,true)
		end
		return true
	else
		dgsSetData(parent,"RadioButton",false)
		triggerEvent("onDgsRadioButtonChange",rb,false)
		return true
	end
end

function dgsRadioButtonSetHorizontalAlign(rb,align)
	if dgsGetType(rb) ~= "dgs-dxradiobutton" then error(dgsGenAsrt(rb,"dgsRadioButtonSetHorizontalAlign",1,"dgs-dxradiobutton")) end
	if not HorizontalAlign[align] then error(dgsGenAsrt(align,"dgsRadioButtonSetHorizontalAlign",2,"string","left/center/right")) end
	local alignment = dgsElementData[rb].alignment
	return dgsSetData(rb,"alignment",{align,alignment[2]})
end

function dgsRadioButtonSetVerticalAlign(rb,align)
	if dgsGetType(rb) ~= "dgs-dxradiobutton" then error(dgsGenAsrt(rb,"dgsRadioButtonSetVerticalAlign",1,"dgs-dxradiobutton")) end
	if not VerticalAlign[align] then error(dgsGenAsrt(align,"dgsRadioButtonSetVerticalAlign",2,"string","top/center/bottom")) end
	local alignment = dgsElementData[rb].alignment
	return dgsSetData(rb,"alignment",{alignment[1],align})
end

function dgsRadioButtonGetHorizontalAlign(rb)
	if dgsGetType(rb) ~= "dgs-dxradiobutton" then error(dgsGenAsrt(rb,"dgsRadioButtonGetHorizontalAlign",1,"dgs-dxradiobutton")) end
	return dgsElementData[rb].alignment[1]
end

function dgsRadioButtonGetVerticalAlign(rb)
	if dgsGetType(rb) ~= "dgs-dxradiobutton" then error(dgsGenAsrt(rb,"dgsRadioButtonGetVerticalAlign",1,"dgs-dxradiobutton")) end
	return dgsElementData[rb].alignment[2]
end

----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxradiobutton"] = function(source,x,y,w,h,mx,my,cx,cy,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt)
	local image_f,image_t = eleData.image_f,eleData.image_t
	local color_f,color_t = eleData.color_f,eleData.color_t
	local rbParent = eleData.rbParent
	local image,color
	local _buttonSize = eleData.buttonSize
	local buttonSizeX,buttonSizeY
	if tonumber(_buttonSize[2]) then
		buttonSizeX = _buttonSize[3] and _buttonSize[1]*w or _buttonSize[1]
		buttonSizeY = _buttonSize[3] and _buttonSize[2]*h or _buttonSize[2]
	else
		buttonSizeX = _buttonSize[2] and _buttonSize[1]*h or _buttonSize[1]
		buttonSizeY = buttonSizeX
	end
	if dgsElementData[rbParent].RadioButton == source then
		image,color = image_t,color_t
	else
		image,color = image_f,color_f
	end
	local colorimgid = 1
	if MouseData.entered == source then
		colorimgid = 2
		if eleData.clickType == 1 then
			if MouseData.clickl == source then
				colorimgid = 3
			end
		elseif eleData.clickType == 2 then
			if MouseData.clickr == source then
				colorimgid = 3
			end
		else
			if MouseData.clickl == source or MouseData.clickr == source then
				colorimgid = 3
			end
		end
	end
	local finalcolor
	if not enabledInherited and not enabledSelf then
		if type(eleData.disabledColor) == "number" then
			finalcolor = applyColorAlpha(eleData.disabledColor,parentAlpha)
		elseif eleData.disabledColor == true then
			local r,g,b,a = fromcolor(color[1],true)
			local average = (r+g+b)/3*eleData.disabledColorPercent
			finalcolor = tocolor(average,average,average,a*parentAlpha)
		else
			finalcolor = color[colorimgid]
		end
	else
		finalcolor = applyColorAlpha(color[colorimgid],parentAlpha)
	end
	if image[colorimgid] then
		dxDrawImage(x,y+h*0.5-buttonSizeY*0.5,buttonSizeX,buttonSizeY,image[colorimgid],0,0,0,finalcolor,isPostGUI,rndtgt)
	else
		dxDrawRectangle(x,y+h*0.5-buttonSizeY*0.5,buttonSizeX,buttonSizeY,finalcolor,isPostGUI)
	end
	local font = eleData.font or systemFont
	local txtSizX,txtSizY = eleData.textSize[1],eleData.textSize[2] or eleData.textSize[1]
	local clip = eleData.clip
	local wordbreak = eleData.wordbreak
	local _textPadding = eleData.textPadding
	local text = eleData.text
	local textPadding = _textPadding[2] and _textPadding[1]*w or _textPadding[1]
	local colorcoded = eleData.colorcoded
	local alignment = eleData.alignment
	local px = x+buttonSizeX+textPadding
	if eleData.PixelInt then px = px-px%1 end
	local shadow = eleData.shadow
	if shadow then
		local shadowoffx,shadowoffy,shadowc,shadowIsOutline = shadow[1],shadow[2],shadow[3],shadow[4]
		local textX,textY = px,y
		if shadowoffx and shadowoffy and shadowc then
			shadowc = applyColorAlpha(shadowc,parentAlpha)
			local shadowText = colorcoded and text:gsub('#%x%x%x%x%x%x','') or text
			dxDrawText(shadowText,textX+shadowoffx,textY+shadowoffy,textX+w+shadowoffx,textY+h+shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,isPostGUI)
			if shadowIsOutline then
				dxDrawText(shadowText,textX-shadowoffx,textY+shadowoffy,textX+w-shadowoffx,textY+h+shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,isPostGUI)
				dxDrawText(shadowText,textX-shadowoffx,textY-shadowoffy,textX+w-shadowoffx,textY+h-shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,isPostGUI)
				dxDrawText(shadowText,textX+shadowoffx,textY-shadowoffy,textX+w+shadowoffx,textY+h-shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,isPostGUI)
			end
		end
	end
	dxDrawText(eleData.text,px,y,px+w-1,y+h-1,applyColorAlpha(eleData.textColor,parentAlpha),txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,isPostGUI,colorcoded)
	return rndtgt,false,mx,my,0,0
end