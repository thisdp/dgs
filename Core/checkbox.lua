dgsLogLuaMemory()
dgsRegisterType("dgs-dxcheckbox","dgsBasic","dgsType2D")
dgsRegisterProperties("dgs-dxcheckbox",{
	alignment = 			{	{ PArg.String, PArg.String }	},
	buttonSize = 			{	{ PArg.Number, PArg.Number+PArg.Nil, PArg.Bool }	},
	clip = 					{	PArg.Bool	},
	colorChecked =			{	{ PArg.Color, PArg.Color, PArg.Color }	},
	colorCoded = 			{	PArg.Bool	},
	colorIndeterminate =	{	{ PArg.Color, PArg.Color, PArg.Color }	},
	colorUnchecked =		{	{ PArg.Color, PArg.Color, PArg.Color }	},
	font = 					{	PArg.Font+PArg.String	},
	imageChecked =			{	{ PArg.Nil+PArg.Material, PArg.Nil+PArg.Material, PArg.Nil+PArg.Material }	},
	imageIndeterminate =	{	{ PArg.Nil+PArg.Material, PArg.Nil+PArg.Material, PArg.Nil+PArg.Material }	},
	imageUnchecked =		{	{ PArg.Nil+PArg.Material, PArg.Nil+PArg.Material, PArg.Nil+PArg.Material }	},
	shadow = 				{	{ PArg.Number, PArg.Number, PArg.Color, PArg.Bool+PArg.Nil, PArg.Font+PArg.Nil }, PArg.Nil	},
	state = 				{	PArg.Bool	},
	text = 					{	PArg.Text	},
	textColor = 			{	PArg.Color	},
	textPadding = 			{	{ PArg.Number, PArg.Bool }	},
	textOffset = 			{	PArg.Nil, { PArg.Number, PArg.Number, PArg.Bool }, {	{ PArg.Number, PArg.Number, PArg.Bool }, { PArg.Number, PArg.Number, PArg.Bool }, { PArg.Number, PArg.Number, PArg.Bool }	}	},
	textSize = 				{	{ PArg.Number, PArg.Number }	},
	wordBreak = 			{	PArg.Bool	},
})
--Dx Functions
local dxDrawImage = dxDrawImage
local dgsDrawText = dgsDrawText
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
local dgsTriggerEvent = dgsTriggerEvent
local createElement = createElement
local assert = assert
local type = type
local tostring = tostring
local tonumber = tonumber

--CheckBox State : true->checked; false->unchecked; nil->indeterminate;
function dgsCreateCheckBox(...)
	local sRes = sourceResource or resource
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
	if not(type(state) == "boolean") then error(dgsGenAsrt(state,"dgsCreateCheckBox",6,"boolean")) end
	local cb = createElement("dgs-dxcheckbox")
	dgsSetType(cb,"dgs-dxcheckbox")
	
	local res = sRes ~= resource and sRes or "global"
	local style = styleManager.styles[res]
	local using = style.using
	style = style.loaded[using]
	local systemFont = style.systemFontElement
	
	style = style.checkbox
	local imageUnchecked = style.imageUnchecked
	nImageF = nImageF or dgsCreateTextureFromStyle(using,res,imageUnchecked[1])
	hImageF = hImageF or dgsCreateTextureFromStyle(using,res,imageUnchecked[2]) or nImageF
	cImageF = cImageF or dgsCreateTextureFromStyle(using,res,imageUnchecked[3]) or nImageF
	local colorUnchecked = style.colorUnchecked
	nColorF = nColorF or colorUnchecked[1]
	hColorF = hColorF or colorUnchecked[2]
	cColorF = cColorF or colorUnchecked[3]

	local imageChecked = style.imageChecked
	nImageT = nImageT or dgsCreateTextureFromStyle(using,res,imageChecked[1])
	hImageT = hImageT or dgsCreateTextureFromStyle(using,res,imageChecked[2]) or nImageT
	cImageT = cImageT or dgsCreateTextureFromStyle(using,res,imageChecked[3]) or nImageT
	local colorChecked = style.colorChecked
	nColorT = nColorT or colorChecked[1]
	hColorT = hColorT or colorChecked[2]
	cColorT = cColorT or colorChecked[3]

	local imageIndeterminate = style.imageIndeterminate
	nImageN = nImageN or dgsCreateTextureFromStyle(using,res,imageIndeterminate[1])
	hImageN = hImageN or dgsCreateTextureFromStyle(using,res,imageIndeterminate[2]) or nImageN
	cImageN = cImageN or dgsCreateTextureFromStyle(using,res,imageIndeterminate[3]) or nImageN
	local colorIndeterminate = style.colorIndeterminate
	nColorN = nColorN or colorIndeterminate[1]
	hColorN = hColorN or colorIndeterminate[2]
	cColorN = cColorN or colorIndeterminate[3]
	local textSizeX,textSizeY = tonumber(scaleX) or style.textSize[1], tonumber(scaleY) or style.textSize[2]
	dgsElementData[cb] = {
		imageIndeterminate = {nImageN,hImageN,cImageN},
		imageChecked = {nImageT,hImageT,cImageT},
		imageUnchecked = {nImageF,hImageF,cImageF},
		colorIndeterminate = {nColorN,hColorN,cColorN},
		colorChecked = {nColorT,hColorT,cColorT},
		colorUnchecked = {nColorF,hColorF,cColorF},
		cbParent = dgsIsType(parent) and parent or resourceRoot,
		textColor = textColor or style.textColor,
		textSize = {textSizeX,textSizeY},
		textPadding = style.textPadding or {2,false},
		textOffset = nil,
		buttonSize = style.buttonSize,
		font = style.font or systemFont,
		shadow = nil,
		clip = nil,
		wordBreak = nil,
		colorCoded = nil,
		state = state,
		buttonPosition = "left",
		alignment = {"left","center"},
	}
	dgsSetParent(cb,parent,true,true)
	dgsAttachToTranslation(cb,resourceTranslation[sRes])
	if type(text) == "table" then
		dgsElementData[cb]._translation_text = text
		dgsSetData(cb,"text",text)
	else
		dgsSetData(cb,"text",tostring(text or ""))
	end
	calculateGuiPositionSize(cb,x,y,relative or false,w,h,relative or false,true)
	dgsAddEventHandler("onDgsCheckBoxChange",cb,"dgsCheckBoxCheckState",false)
	onDGSElementCreate(cb,sRes)
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
		dgsTriggerEvent("onDgsCheckBoxChange",cb,state,oldState)
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
	local imageUnchecked,imageChecked,imageIndeterminate = eleData.imageUnchecked,eleData.imageChecked,eleData.imageIndeterminate
	local colorUnchecked,colorChecked,colorIndeterminate = eleData.colorUnchecked,eleData.colorChecked,eleData.colorIndeterminate
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
		image,color = imageChecked,colorChecked
	elseif eleData.state == false then
		image,color = imageUnchecked,colorUnchecked
	else
		image,color = imageIndeterminate,colorIndeterminate
	end
	local colorimgid = 1
	if MouseData.entered == source then
		colorimgid = 2
		if eleData.clickType == 1 then
			if MouseData.click.left == source then
				colorimgid = 3
			end
		elseif eleData.clickType == 2 then
			if MouseData.click.right == source then
				colorimgid = 3
			end
		else
			if MouseData.click.left == source or MouseData.click.right == source then
				colorimgid = 3
			end
		end
	end
	local finalcolor
	if not enabledInherited and not enabledSelf then
		if type(eleData.disabledColor) == "number" then
			finalcolor = applyColorAlpha(eleData.disabledColor,parentAlpha)
		elseif eleData.disabledColor == true then
			local r,g,b,a = fromcolor(color[1])
			local average = (r+g+b)/3*eleData.disabledColorPercent
			finalcolor = tocolor(average,average,average,a*parentAlpha)
		else
			finalcolor = color[colorimgid]
		end
	else
		finalcolor = applyColorAlpha(color[colorimgid],parentAlpha)
	end
	
	local res = eleData.resource or "global"
	local style = styleManager.styles[res]
	style = style.loaded[style.using]
	local systemFont = style.systemFontElement
	
	local font = eleData.font or systemFont
	local txtSizX,txtSizY = eleData.textSize[1],eleData.textSize[2] or eleData.textSize[1]
	local clip = eleData.clip
	local wordBreak = eleData.wordBreak
	local _textPadding = eleData.textPadding
	local text = eleData.text
	local textPadding = _textPadding[2] and _textPadding[1]*w or _textPadding[1]
	local colorCoded = eleData.colorCoded
	local alignment = eleData.alignment
	local textOffset = eleData.textOffset
	local offsetX,offsetY = 0,0
	if textOffset then
		local item = textOffset[colorimgid]
		if type(item) == "table" then
			offsetX,offsetY = item[3] and item[1]*w or item[1],item[3] and item[2]*h or item[2]
		else
			offsetX,offsetY = textOffset[3] and textOffset[1]*w or textOffset[1],textOffset[3] and textOffset[2]*h or textOffset[2]
		end
	end
	local shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont
	local shadow = eleData.shadow
	if shadow then
		shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont = shadow[1],shadow[2],shadow[3],shadow[4],shadow[5]
		shadowColor = applyColorAlpha(shadowColor or white,parentAlpha)
	end
	if eleData.buttonPosition == "right" then	--right
		dxDrawImage(x+w-buttonSizeX,y+h*0.5-buttonSizeY*0.5,buttonSizeX,buttonSizeY,image[colorimgid],0,0,0,finalcolor,isPostGUI,rndtgt)
		dgsDrawText(text,x+offsetX,y+offsetY,x+w+offsetX-buttonSizeX-textPadding,y+h+offsetY,applyColorAlpha(eleData.textColor,parentAlpha),txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordBreak,isPostGUI,colorCoded,subPixelPos,0,0,0,0,shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont)
	else	--left by default
		local px = x+buttonSizeX+textPadding
		if eleData.PixelInt then px = px-px%1 end
		dxDrawImage(x,y+h*0.5-buttonSizeY*0.5,buttonSizeX,buttonSizeY,image[colorimgid],0,0,0,finalcolor,isPostGUI,rndtgt)
		dgsDrawText(text,px+offsetX,y+offsetY,px+w+offsetX,y+h+offsetY,applyColorAlpha(eleData.textColor,parentAlpha),txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordBreak,isPostGUI,colorCoded,subPixelPos,0,0,0,0,shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont)
	end
	return rndtgt,false,mx,my,0,0
end