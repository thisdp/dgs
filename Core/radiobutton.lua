dgsLogLuaMemory()
dgsRegisterType("dgs-dxradiobutton","dgsBasic","dgsType2D")
dgsRegisterProperties("dgs-dxradiobutton",{
	alignment = 		{	{ PArg.String, PArg.String }	},
	buttonSize = 		{	{ PArg.Number, PArg.Number+PArg.Nil, PArg.Bool }	},
	clip = 				{	PArg.Bool	},  
	colorChecked = 		{	{ PArg.Color, PArg.Color, PArg.Color }	},
	colorCoded = 		{	PArg.Bool	},
	colorUnchecked = 	{	{ PArg.Color, PArg.Color, PArg.Color }	},
	font = 				{	PArg.Font+PArg.String	},
	imageChecked = 		{	{ PArg.Nil+PArg.Material, PArg.Nil+PArg.Material, PArg.Nil+PArg.Material }	},
	imageUnchecked = 	{	{ PArg.Nil+PArg.Material, PArg.Nil+PArg.Material, PArg.Nil+PArg.Material }	},
	shadow = 			{	{ PArg.Number, PArg.Number, PArg.Color, PArg.Number+PArg.Bool+PArg.Nil, PArg.Font+PArg.Nil }, PArg.Nil	},
	text = 				{	PArg.Text	}, 
	textColor = 		{	PArg.Color	},
	textPadding = 		{	{ PArg.Number, PArg.Bool }	},
	textOffset = 		{	PArg.Nil, { PArg.Number, PArg.Number, PArg.Bool }, {	{ PArg.Number, PArg.Number, PArg.Bool }, { PArg.Number, PArg.Number, PArg.Bool }, { PArg.Number, PArg.Number, PArg.Bool }	}	},
	textSize = 			{	{ PArg.Number,PArg.Number }	},
	wordBreak = 		{	PArg.Bool	},
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
local dgsIsType = dgsIsType
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

function dgsCreateRadioButton(...)
	local sRes = sourceResource or resource
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
			
	local res = sRes ~= resource and sRes or "global"
	local style = styleManager.styles[res]
	local using = style.using
	style = style.loaded[using]
	local systemFont = style.systemFontElement
	
	style = style.radiobutton
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
	local textSizeX,textSizeY = tonumber(scaleX) or style.textSize[1], tonumber(scaleY) or style.textSize[2]
	dgsElementData[rb] = {
		renderBuffer = {},
		imageUnchecked = {nImageF,hImageF,cImageF},
		colorUnchecked = {nColorF,hColorF,cColorF},
		imageChecked = {nImageT,hImageT,cImageT},
		colorChecked = {nColorT,hColorT,cColorT},
		rbParent = dgsIsType(parent) and parent or resourceRoot,
		text = tostring(text or ""),
		textColor = textColor or style.textColor,
		textSize = {textSizeX,textSizeY},
		textPadding = style.textPadding,
		buttonSize = style.buttonSize,
		shadow = {},
		font = style.font or systemFont,
		textOffset = nil,
		clip = nil,
		wordBreak = nil,
		colorCoded = nil,
		buttonPosition = "left",
		alignment = {"left","center"},
	}
	dgsSetParent(rb,parent,true,true)
	dgsAttachToTranslation(rb,resourceTranslation[sRes])
	if type(text) == "table" then
		dgsElementData[rb]._translation_text = text
		dgsElementData[rb].text = dgsTranslate(rb,text,sRes)
	end
	calculateGuiPositionSize(rb,x,y,relative or false,w,h,relative or false,true)
	onDGSElementCreate(rb,sRes)
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
				dgsTriggerEvent("onDgsRadioButtonChange",_rb,false)
			end
			dgsTriggerEvent("onDgsRadioButtonChange",rb,true)
		end
		return true
	else
		dgsSetData(parent,"RadioButton",false)
		dgsTriggerEvent("onDgsRadioButtonChange",rb,false)
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
	local imageUnchecked,imageChecked = eleData.imageUnchecked,eleData.imageChecked
	local colorUnchecked,colorChecked = eleData.colorUnchecked,eleData.colorChecked
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
		image,color = imageChecked,colorChecked
	else
		image,color = imageUnchecked,colorUnchecked
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