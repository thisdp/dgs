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
	local x,y,w,h,text,state,relative,parent,textColor,scaleX,scaleY,norimg_f,hovimg_f,cliimg_f,norcolor_f,hovcolor_f,clicolor_f,norimg_t,hovimg_t,cliimg_t,norcolor_t,hovcolor_t,clicolor_t,norimg_i,hovimg_i,cliimg_i,norcolor_i,hovcolor_i,clicolor_i
	if select("#",...) == 1 and type(select(1,...)) == "table" then
		local argTable = ...
		x = argTable.x or argTable[1]
		y = argTable.y or argTable[2]
		w = argTable.w or argTable.width or argTable[3]
		h = argTable.h or argTable.height or argTable[4]
		text = argTable.txt or argTable.text or argTable[5]
		state = argTable.state or argTable[6]
		relative = argTable.rlt or argTable.relative or argTable[7]
		parent = argTable.p or argTable.parent or argTable[8]
		textColor = argTable.textColor or argTable[9]
		scaleX = argTable.scaleX or argTable[10]
		scaleY = argTable.scaleY or argTable[11]
		norimg_f = argTable.norimg_f or argTable[12]
		hovimg_f = argTable.hovimg_f or argTable[13]
		cliimg_f = argTable.cliimg_f or argTable[14]
		norcolor_f = argTable.norcolor_f or argTable[15]
		hovcolor_f = argTable.hovcolor_f or argTable[16]
		clicolor_f = argTable.clicolor_f or argTable[17]
		norimg_t = argTable.norimg_t or argTable[18]
		hovimg_t = argTable.hovimg_t or argTable[19]
		cliimg_t = argTable.cliimg_t or argTable[20]
		norcolor_t = argTable.norcolor_t or argTable[21]
		hovcolor_t = argTable.hovcolor_t or argTable[22]
		clicolor_t = argTable.clicolor_t or argTable[23]
		norimg_i = argTable.norimg_i or argTable[24]
		hovimg_i = argTable.hovimg_i or argTable[25]
		cliimg_i = argTable.cliimg_i or argTable[26]
		norcolor_i = argTable.norcolor_i or argTable[27]
		hovcolor_i = argTable.hovcolor_i or argTable[28]
		clicolor_i = argTable.clicolor_i or argTable[29]
	else
		x,y,w,h,text,state,relative,parent,textColor,scaleX,scaleY,norimg_f,hovimg_f,cliimg_f,norcolor_f,hovcolor_f,clicolor_f,norimg_t,hovimg_t,cliimg_t,norcolor_t,hovcolor_t,clicolor_t,norimg_i,hovimg_i,cliimg_i,norcolor_i,hovcolor_i,clicolor_i = ...
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
	norimg_f = norimg_f or dgsCreateTextureFromStyle(imageUnchecked[1])
	hovimg_f = hovimg_f or dgsCreateTextureFromStyle(imageUnchecked[2])
	cliimg_f = cliimg_f or dgsCreateTextureFromStyle(imageUnchecked[3])
	local colorUnchecked = style.color_f
	norcolor_f = norcolor_f or colorUnchecked[1]
	hovcolor_f = hovcolor_f or colorUnchecked[2]
	clicolor_f = clicolor_f or colorUnchecked[3]

	local imageChecked = style.image_t
	norimg_t = norimg_t or dgsCreateTextureFromStyle(imageChecked[1])
	hovimg_t = hovimg_t or dgsCreateTextureFromStyle(imageChecked[2])
	cliimg_t = cliimg_t or dgsCreateTextureFromStyle(imageChecked[3])
	local colorChecked = style.color_t
	norcolor_t = norcolor_t or colorChecked[1]
	hovcolor_t = hovcolor_t or colorChecked[2]
	clicolor_t = clicolor_t or colorChecked[3]

	local imageIndeterminate = style.image_i
	norimg_i = norimg_i or dgsCreateTextureFromStyle(imageIndeterminate[1])
	hovimg_i = hovimg_i or dgsCreateTextureFromStyle(imageIndeterminate[2])
	cliimg_i = cliimg_i or dgsCreateTextureFromStyle(imageIndeterminate[3])
	local colorIndeterminate = style.color_i
	norcolor_i = norcolor_i or colorIndeterminate[1]
	hovcolor_i = hovcolor_i or colorIndeterminate[2]
	clicolor_i = clicolor_i or colorIndeterminate[3]
	local textSizeX,textSizeY = tonumber(scaleX) or style.textSize[1], tonumber(scaleY) or style.textSize[2]
	dgsElementData[cb] = {
		image_i = {norimg_i,hovimg_i,cliimg_i},
		image_t = {norimg_t,hovimg_t,cliimg_t},
		image_f = {norimg_f,hovimg_f,cliimg_f},
		color_i = {norcolor_i,hovcolor_i,clicolor_i},
		color_t = {norcolor_t,hovcolor_t,clicolor_t},
		color_f = {norcolor_f,hovcolor_f,clicolor_f},
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
	triggerEvent("onDgsCreate",cb,sourceResource)
	return cb
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

addEventHandler("onDgsCheckBoxChange",resourceRoot,function(state)
	if not wasEventCancelled() then
		dgsSetData(source,"state",state)
	end
end)

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
	if MouseData.enter == source then
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
	return rndtgt
end