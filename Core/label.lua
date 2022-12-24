dgsLogLuaMemory()
dgsRegisterType("dgs-dxlabel","dgsBasic","dgsType2D")
dgsRegisterProperties("dgs-dxlabel",{
	alignment = 			{	{ PArg.String, PArg.String }	},
	clip = 					{	PArg.Bool	},
	colorCoded = 			{	PArg.Bool	},
	font = 					{	PArg.Font+PArg.String	},
	rotation = 				{	PArg.Number	},
	rotationCenter = 		{	{ PArg.Number, PArg.Number }	},
	shadow = 				{	{ PArg.Number, PArg.Number, PArg.Color, PArg.Number+PArg.Bool+PArg.Nil, PArg.Font+PArg.Nil }, PArg.Nil	},
	subPixelPositioning = 	{	PArg.Bool	},
	text = 					{	PArg.Text	},
	textColor = 			{	PArg.Color	},
	textOffset = 			{	{ PArg.Number, PArg.Number, PArg.Bool }	},
	textSize = 				{	{ PArg.Number, PArg.Number }	},
	wordBreak = 			{	PArg.Bool	},
})

--Dx Functions
local dgsDrawText = dgsDrawText
local dxGetFontHeight = dxGetFontHeight
local dxGetTextWidth = dxGetTextWidth
--DGS Functions
local dgsSetType = dgsSetType
local dgsGetType = dgsGetType
local dgsSetParent = dgsSetParent
local dgsSetData = dgsSetData
local applyColorAlpha = applyColorAlpha
local dgsTranslate = dgsTranslate
local dgsAttachToTranslation = dgsAttachToTranslation
local dgsAttachToAutoDestroy = dgsAttachToAutoDestroy
local calculateGuiPositionSize = calculateGuiPositionSize
local dgsCreateTextureFromStyle = dgsCreateTextureFromStyle
--Utilities
local createElement = createElement
local assert = assert
local tonumber = tonumber
local type = type

function dgsCreateLabel(...)
	local sRes = sourceResource or resource
	local x,y,w,h,text,relative,parent,textColor,scaleX,scaleY,shadowOffsetX,shadowOffsetY,shadowColor,hAlign,vAlign
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
		shadowOffsetX = argTable.shadowOffsetX or argTable[11]
		shadowOffsetY = argTable.shadowOffsetY or argTable[12]
		shadowColor = argTable.shadowColor or argTable[13]
		hAlign = argTable.hAlign or argTable.horizontalAlign or argTable.horizontalAlignment or argTable[14]
		vAlign = argTable.vAlign or argTable.verticalAlign or argTable.verticalAlignment or argTable[15]
	else
		x,y,w,h,text,relative,parent,textColor,scaleX,scaleY,shadowOffsetX,shadowOffsetY,shadowColor,hAlign,vAlign = ...
	end
	if not(type(x) == "number") then error(dgsGenAsrt(x,"dgsCreateLabel",1,"number")) end
	if not(type(y) == "number") then error(dgsGenAsrt(y,"dgsCreateLabel",2,"number")) end
	if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsCreateLabel",3,"number")) end
	if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsCreateLabel",4,"number")) end
	local label = createElement("dgs-dxlabel")
	dgsSetType(label,"dgs-dxlabel")
	
	local res = sRes ~= resource and sRes or "global"
	local style = styleManager.styles[res]
	local using = style.using
	style = style.loaded[using]
	local systemFont = style.systemFontElement
	
	style = style.label
	local textSizeX,textSizeY = tonumber(scaleX) or style.textSize[1], tonumber(scaleY) or style.textSize[2]
	dgsElementData[label] = {
		alignment = {hAlign or "left",vAlign or "top"},
		font = style.font or systemFont,
		rotation = 0,
		rotationCenter = {0, 0},
		shadow = nil,
		subPixelPositioning = nil,
		textColor = textColor or style.textColor,
		textSize = {textSizeX,textSizeY},
		textOffset = {0,0,false},
		clip = nil,
		colorCoded = nil,
		wordBreak = nil,
	}
	dgsSetParent(label,parent,true,true)
	dgsAttachToTranslation(label,resourceTranslation[sRes])
	if type(text) == "table" then
		dgsElementData[label]._translation_text = text
		dgsSetData(label,"text",text)
	else
		dgsSetData(label,"text",tostring(text or ""))
	end
	calculateGuiPositionSize(label,x,y,relative or false,w,h,relative or false,true)
	onDGSElementCreate(label,sRes)
	return label
end

function dgsLabelSetColor(label,r,g,b,a)
	if dgsGetType(label) ~= "dgs-dxlabel" then error(dgsGenAsrt(label,"dgsLabelSetColor",1,"dgs-dxlabel")) end
	if tonumber(r) and g == true then
		return dgsSetData(label,"textColor",r)
	else
		local _r,_g,_b,_a = fromcolor(dgsElementData[label].textColor)
		return dgsSetData(label,"textColor",tocolor(r or _r,g or _g,b or _b,a or _a))
	end
end

function dgsLabelGetColor(label,notSplit)
	if dgsGetType(label) ~= "dgs-dxlabel" then error(dgsGenAsrt(label,"dgsLabelGetColor",1,"dgs-dxlabel")) end
	local textColor = dgsElementData[label].textColor
	return notSplit and textColor or fromcolor(textColor)
end

function dgsLabelSetHorizontalAlign(label,align,wordbreak)
	if dgsGetType(label) ~= "dgs-dxlabel" then error(dgsGenAsrt(label,"dgsLabelGetColor",1,"dgs-dxlabel")) end
	if not HorizontalAlign[align] then error(dgsGenAsrt(align,"dgsLabelSetHorizontalAlign",2,"string","left/center/right")) end
	dgsSetData(label,"wordBreak",wordbreak)
	local alignment = dgsElementData[label].alignment
	return dgsSetData(label,"alignment",{align,alignment[2]})
end

function dgsLabelSetVerticalAlign(label,align,wordbreak)
	if dgsGetType(label) ~= "dgs-dxlabel" then error(dgsGenAsrt(label,"dgsLabelSetVerticalAlign",1,"dgs-dxlabel")) end
	if not VerticalAlign[align] then error(dgsGenAsrt(align,"dgsLabelSetVerticalAlign",2,"string","top/center/bottom")) end
	dgsSetData(label,"wordBreak",wordbreak)
	local alignment = dgsElementData[label].alignment
	return dgsSetData(label,"alignment",{alignment[1],align})
end

function dgsLabelGetHorizontalAlign(label)
	if dgsGetType(label) ~= "dgs-dxlabel" then error(dgsGenAsrt(label,"dgsLabelGetHorizontalAlign",1,"dgs-dxlabel")) end
	local alignment = dgsElementData[label].alignment
	return alignment[1]
end

function dgsLabelGetVerticalAlign(label)
	if dgsGetType(label) ~= "dgs-dxlabel" then error(dgsGenAsrt(label,"dgsLabelGetVerticalAlign",1,"dgs-dxlabel")) end
	local alignment = dgsElementData[label].alignment
	return alignment[2]
end

function dgsLabelGetTextExtent(label)
	if dgsGetType(label) ~= "dgs-dxlabel" then error(dgsGenAsrt(label,"dgsLabelGetTextExtent",1,"dgs-dxlabel")) end
	local eleData = dgsElementData[label]
	local font = eleData.font or systemFont
	local textSizeX = eleData.textSize[1]
	local text = eleData.text
	local colorCoded = eleData.colorCoded
	return dxGetTextWidth(text,textSizeX,font,colorCoded)
end

function dgsLabelGetFontHeight(label)
	if dgsGetType(label) ~= "dgs-dxlabel" then error(dgsGenAsrt(label,"dgsLabelGetFontHeight",1,"dgs-dxlabel")) end
	local font = dgsElementData[label].font or systemFont
	local textSizeY = dgsElementData[label].textSize[2]
	return dxGetFontHeight(textSizeY,font)
end

function dgsLabelGetTextSize(label)
	if dgsGetType(label) ~= "dgs-dxlabel" then error(dgsGenAsrt(label,"dgsLabelGetTextSize",1,"dgs-dxlabel")) end
	local eleData = dgsElementData[label]
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
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxlabel"] = function(source,x,y,w,h,mx,my,cx,cy,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt)
	local alignment = eleData.alignment
	local textColor = applyColorAlpha(eleData.textColor,parentAlpha)
	local font = eleData.font or systemFont
	local clip = eleData.clip
	local wordBreak = eleData.wordBreak
	local text = eleData.text
	local txtSizX,txtSizY = eleData.textSize[1],eleData.textSize[2]
	local colorCoded = eleData.colorCoded
	local textOffset = eleData.textOffset
	if textOffset then
		x = x + (textOffset[3] and textOffset[1]*w or textOffset[1])
		y = y + (textOffset[3] and textOffset[2]*h or textOffset[2])
	end
	local shadow = eleData.shadow
	local subPixelPos = eleData.subPixelPositioning
	local rotation = eleData.rotation
	local rotationCenter = eleData.rotationCenter
	local shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont
	if shadow then
		shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont = shadow[1],shadow[2],shadow[3],shadow[4],shadow[5]
		shadowColor = applyColorAlpha(shadowColor or white,parentAlpha)
	end
	dgsDrawText(text,x,y,x+w,y+h,textColor,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordBreak,isPostGUI,colorCoded,subPixelPos,rotation,x+rotationCenter[1],y+rotationCenter[2],0,shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont)
	return rndtgt,false,mx,my,0,0
end