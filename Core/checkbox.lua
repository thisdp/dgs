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

--CheckBox State : true->checked; false->unchecked; nil->indeterminate;
function dgsCreateCheckBox(...)
	local x,y,w,h,text,state,relative,parent,textColor,scaleX,scaleY,nImageF,hImageF,cImageF,nColorF,hColorF,cColorF,nImageT,hImageT,cImageT,nColorT,hColorT,cColorT,nImageN,hImageN,cImageN,nColorN,hColorN,cColorN
	if select("#",...) == 1 and type(select(1,...)) == "table" then
		local argTable = ...
		x = argTable.x or argTable[1]
		y = argTable.y or argTable[2]
		w = argTable.width or argTable.w or argTable[3]
		h = argTable.height or argTable.h or argTable[4]
		text = argTable.text or argTable.txt or argTable[5]
		state = argTable.state or argTable[6]
		relative = argTable.relative or argTable.rlt or argTable[7]
		parent = argTable.parent or argTable.p or argTable[8]
		textColor = argTable.textColor or argTable[9]
		scaleX = argTable.scaleX or argTable[10]
		scaleY = argTable.scaleY or argTable[11]
		nImageF = argTable.normalUncheckedImage or argTable.nImageF or argTable[12]
		hImageF = argTable.hoveringUncheckedImage or argTable.hImageF or argTable[13]
		cImageF = argTable.clickedUnCheckedImage or argTable.cImageF or argTable[14]
		nColorF = argTable.normalUnCheckedColor or argTable.nColorF or argTable[15]
		hColorF = argTable.hoveringUnCheckedColor or argTable.hColorF or argTable[16]
		cColorF = argTable.clickedUnCheckedColor or argTable.cColorF or argTable[17]
		nImageT = argTable.normalCheckedImage or argTable.nImageT or argTable[18]
		hImageT = argTable.hoveringCheckedImage or argTable.hImageT or argTable[19]
		cImageT = argTable.clickedCheckedImage or argTable.cImageT or argTable[20]
		nColorT = argTable.normalCheckedColor or argTable.nColorT or argTable[21]
		hColorT = argTable.hoveringCheckedColor or argTable.hColorT or argTable[22]
		cColorT = argTable.clickedCheckedColor or argTable.cColorT or argTable[23]
		nImageN = argTable.normalIndeterminateImage or argTable.nImageN or argTable[24]
		hImageN = argTable.hoveringIndeterminateImage or argTable.hImageN or argTable[25]
		cImageN = argTable.clickedIndeterminateImage or argTable.cImageN or argTable[26]
		nColorN = argTable.normalIndeterminateColor or argTable.nColorN or argTable[27]
		hColorN = argTable.hoveringIndeterminateColor or argTable.hColorN or argTable[28]
		cColorN = argTable.clickedIndeterminateColor or argTable.cColorN or argTable[29]
	else
		x,y,w,h,text,state,relative,parent,textColor,scaleX,scaleY,nImageF,hImageF,cImageF,nColorF,hColorF,cColorF,nImageT,hImageT,cImageT,nColorT,hColorT,cColorT,nImageN,hImageN,cImageN,nColorN,hColorN,cColorN = ...
	end
	if not(type(x) == "number") then error(dgsGenAsrt(x,"dgsCreateCheckBox",1,"number")) end
	if not(type(y) == "number") then error(dgsGenAsrt(y,"dgsCreateCheckBox",2,"number")) end
	if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsCreateCheckBox",3,"number")) end
	if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsCreateCheckBox",4,"number")) end
	if not(type(state) == "boolean") then error(dgsGenAsrt(h,"dgsCreateCheckBox",6,"boolean")) end
	local cb = createElement("dgs-dxcheckbox")
	dgsSetType(cb,"dgs-dxcheckbox")
	dgsSetParent(cb,parent,true,true)
	local style = styleSettings.checkbox

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

	local imageIndeterminate = style.image_i
	nImageN = nImageN or dgsCreateTextureFromStyle(imageIndeterminate[1])
	hImageN = hImageN or dgsCreateTextureFromStyle(imageIndeterminate[2])
	cImageN = cImageN or dgsCreateTextureFromStyle(imageIndeterminate[3])
	local colorIndeterminate = style.color_i
	nColorN = nColorN or colorIndeterminate[1]
	hColorN = hColorN or colorIndeterminate[2]
	cColorN = cColorN or colorIndeterminate[3]
	local textSizeX,textSizeY = tonumber(scaleX) or style.textSize[1], tonumber(scaleY) or style.textSize[2]
	dgsElementData[cb] = {
		image_i = {nImageN,hImageN,cImageN},
		image_t = {nImageT,hImageT,cImageT},
		image_f = {nImageF,hImageF,cImageF},
		color_i = {nColorN,hColorN,cColorN},
		color_t = {nColorT,hColorT,cColorT},
		color_f = {nColorF,hColorF,cColorF},
		cbParent = dgsIsType(parent) and parent or resourceRoot,
		textColor = textColor or style.textColor,
		textSize = {textSizeX,textSizeY},
		textPadding = style.textPadding or {2,false},
		buttonSize = style.buttonSize,
		shadow = {_,_,_},
		font = style.font or systemFont,
		clip = false,
		wordbreak = false,
		colorcoded = false,
		state = state,
		alignment = {"left","center"},
	}

	dgsAttachToTranslation(cb,resourceTranslation[sourceResource or resource])
	if type(text) == "table" then
		dgsElementData[cb]._translationText = text
		dgsSetData(cb,"text",text)
	else
		dgsSetData(cb,"text",tostring(text))
	end
	calculateGuiPositionSize(cb,x,y,relative or false,w,h,relative or false,true)
	dgsAddEventHandler("onDgsCheckBoxChange",cb,"dgsCheckBoxCheckState",false)
	triggerEvent("onDgsCreate",cb,sourceResource)
	return cb
end

function dgsCheckBoxCheckState(state)
	if not wasEventCancelled() then
		dgsSetData(source,"state",state)
	end
end

function dgsCheckBoxGetSelected(cb)
	if not dgsIsType(cb,"dgs-dxcheckbox") then error(dgsGenAsrt(cb,"dgsCheckBoxGetSelected",1,"dgs-dxcheckbox")) end
	return dgsElementData[cb].state
end

function dgsCheckBoxSetSelected(cb,state)
	if not dgsIsType(cb,"dgs-dxcheckbox") then error(dgsGenAsrt(cb,"dgsCheckBoxSetSelected",1,"dgs-dxcheckbox")) end
	if not (type(state) == "boolean") then error(dgsGenAsrt(cb,"dgsCheckBoxSetSelected",2,"boolean")) end
	local oldState = dgsElementData[cb].state
	if state ~= oldState then
		triggerEvent("onDgsCheckBoxChange",cb,state,oldState)
	end
	return true
end

function dgsCheckBoxSetHorizontalAlign(cb,align)
	if not dgsIsType(cb,"dgs-dxcheckbox") then error(dgsGenAsrt(cb,"dgsCheckBoxSetHorizontalAlign",1,"dgs-dxcheckbox")) end
	if not HorizontalAlign[align] then error(dgsGenAsrt(align,"dgsCheckBoxSetHorizontalAlign",2,"string","left/center/right")) end
	return dgsSetData(cb,"alignment",{align,dgsElementData[cb].alignment[2]})
end

function dgsCheckBoxSetVerticalAlign(cb,align)
	if not dgsIsType(cb,"dgs-dxcheckbox") then error(dgsGenAsrt(cb,"dgsCheckBoxSetVerticalAlign",1,"dgs-dxcheckbox")) end
	if not VerticalAlign[align] then error(dgsGenAsrt(align,"dgsCheckBoxSetVerticalAlign",2,"string","top/center/bottom")) end
	return dgsSetData(cb,"alignment",{dgsElementData[cb].alignment[1],align})
end

function dgsCheckBoxGetHorizontalAlign(cb)
	if not dgsIsType(cb,"dgs-dxcheckbox") then error(dgsGenAsrt(cb,"dgsCheckBoxGetHorizontalAlign",1,"dgs-dxcheckbox")) end
	return dgsElementData[cb].alignment[1]
end

function dgsCheckBoxGetVerticalAlign(cb)
	if not dgsIsType(cb,"dgs-dxcheckbox") then error(dgsGenAsrt(cb,"dgsCheckBoxGetVerticalAlign",1,"dgs-dxcheckbox")) end
	return dgsElementData[cb].alignment[2]
end

----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxcheckbox"] = function(source,x,y,w,h,mx,my,cx,cy,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt)
	local image_f,image_t,image_i = eleData.image_f,eleData.image_t,eleData.image_i
	local color_f,color_t,color_i = eleData.color_f,eleData.color_t,eleData.color_i
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
	if eleData.state == true then
		image,color = image_t,color_t
	elseif eleData.state == false then
		image,color = image_f,color_f
	else
		image,color = image_i,color_i
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
	local textPadding = _textPadding[2] and _textPadding[1]*w or _textPadding[1]
	local text = eleData.text
	local colorcoded = eleData.colorcoded
	local alignment = eleData.alignment
	local px = x+buttonSizeX+textPadding
	if eleData.PixelInt then px = px-px%1 end
	local shadow = eleData.shadow
	if shadow then
		local shadowoffx,shadowoffy,shadowc,shadowIsOutline = shadow[1],shadow[2],shadow[3],shadow[4]
		local textX,textY = px,y
		if shadowoffx and shadowoffy and shadowc then
			local shadowc = applyColorAlpha(shadowc,parentAlpha)
			local shadowText = colorcoded and text:gsub('#%x%x%x%x%x%x','') or text
			dxDrawText(shadowText,textX+shadowoffx,textY+shadowoffy,textX+w+shadowoffx,textY+h+shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,isPostGUI)
			if shadowIsOutline then
				dxDrawText(shadowText,textX-shadowoffx,textY+shadowoffy,textX+w-shadowoffx,textY+h+shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,isPostGUI)
				dxDrawText(shadowText,textX-shadowoffx,textY-shadowoffy,textX+w-shadowoffx,textY+h-shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,isPostGUI)
				dxDrawText(shadowText,textX+shadowoffx,textY-shadowoffy,textX+w+shadowoffx,textY+h-shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,isPostGUI)
			end
		end
	end
	dxDrawText(text,px,y,px+w-1,y+h-1,applyColorAlpha(eleData.textColor,parentAlpha),txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,isPostGUI,colorcoded)
	return rndtgt,false,mx,my,0,0
end