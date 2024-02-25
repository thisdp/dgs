dgsLogLuaMemory()
dgsRegisterType("dgs-dxselector","dgsBasic","dgsType2D")
dgsRegisterProperties("dgs-dxselector",{
	alignment = 				{	{ PArg.String,PArg.String }	},
	clip = 						{	PArg.Bool	},
	colorCoded = 				{	PArg.Bool	},
	enableScroll = 				{	PArg.Bool	},
	font = 						{	PArg.Font+PArg. String	},
	isHorizontal = 				{	PArg.Bool	},
	isReversed = 				{	PArg.Bool	},
	itemTextColor = 			{	PArg.Color	},
	itemTextSize = 				{	{ PArg.Number, PArg.Number }	},
	placeHolder = 				{	PArg.String	},
	select = 					{	PArg.Number	},
	selectorImageColorLeft = 	{	{ PArg.Color, PArg.Color, PArg.Color }	},
	selectorImageLeft = 		{	{ PArg.Material+PArg.Nil, PArg.Material+PArg.Nil, PArg.Material+PArg.Nil }	},
	selectorImageColorRight = 	{	{ PArg.Color, PArg.Color, PArg.Color }	},
	selectorImageRight = 		{	{ PArg.Material+PArg.Nil, PArg.Material+PArg.Nil, PArg.Material+PArg.Nil }	},
	selectorSize = 				{	{ PArg.Number, PArg.Number, PArg.Bool }	},
	selectorText = 				{	{ PArg.String, PArg.String }	},
	selectorTextColor = 		{	{ PArg.Color, PArg.Color, PArg.Color }	},
	selectorTextSize = 			{	{ PArg.Number, PArg.Number }	},
	shadow = 					{	{ PArg.Number, PArg.Number, PArg.Color, PArg.Bool+PArg.Nil }, PArg.Nil	},
	subPixelPositioning = 		{	PArg.Bool	},
	text = 						{	PArg.Text	},
	textColor = 				{	PArg.Color	},
	textSize = 					{	{ PArg.Number,PArg.Number }	},
})
--Dx Functions
local dxDrawImage = dxDrawImage
local dgsDrawText = dgsDrawText
--DGS Functions
local dgsSetType = dgsSetType
local dgsGetType = dgsGetType
local dgsSetParent = dgsSetParent
local dgsSetData = dgsSetData
local applyColorAlpha = applyColorAlpha
local dgsTranslate = dgsTranslate
local calculateGuiPositionSize = calculateGuiPositionSize
--Utilities
local dgsTriggerEvent = dgsTriggerEvent
local createElement = createElement
local assert = assert
local tonumber = tonumber
local type = type
local tableInsert = table.insert
local tableRemove = table.remove
local mathClamp = math.clamp
--[[
Selector Data Structure:
{
	{text,alignment,color,colorCoded,sizex,sizey,font,data,imageData},
	{text,alignment,color,colorCoded,sizex,sizey,font,data,imageData},
	{text,alignment,color,colorCoded,sizex,sizey,font,data,imageData},
}
]]

--[[Selector Index]]
Selector_itemText = 1
Selector_itemAlignment = 2
Selector_itemTextColor = 3
Selector_itemColorCoded = 4
Selector_itemTextScaleX = 5
Selector_itemTextScaleY = 6
Selector_itemFont = 7
Selector_itemData = 8
Selector_itemImage = 9

function dgsCreateSelector(...)
	local sRes = sourceResource or resource
	local x,y,w,h,relative,parent,textColor,scaleX,scaleY,shadowoffsetx,shadowoffsety,shadowcolor
	if select("#",...) == 1 and type(select(1,...)) == "table" then
		local argTable = ...
		x = argTable.x or argTable[1]
		y = argTable.y or argTable[2]
		w = argTable.width or argTable.w or argTable[3]
		h = argTable.height or argTable.h or argTable[4]
		relative = argTable.relative or argTable.rlt or argTable[5]
		parent = argTable.parent or argTable.p or argTable[6]
		textColor = argTable.textColor or argTable[7]
		scaleX = argTable.scaleX or argTable[8]
		scaleY = argTable.scaleY or argTable[9]
		shadowoffsetx = argTable.shadowOffsetX or argTable[10]
		shadowoffsety = argTable.shadowOffsetY or argTable[11]
		shadowcolor = argTable.shadowColor or argTable[12]
	else
		x,y,w,h,relative,parent,textColor,scaleX,scaleY,shadowoffsetx,shadowoffsety,shadowcolor = ...
	end
	if not(type(x) == "number") then error(dgsGenAsrt(x,"dgsCreateSelector",1,"number")) end
	if not(type(y) == "number") then error(dgsGenAsrt(y,"dgsCreateSelector",2,"number")) end
	if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsCreateSelector",3,"number")) end
	if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsCreateSelector",4,"number")) end
	local selector = createElement("dgs-dxselector")
	dgsSetType(selector,"dgs-dxselector")

	local res = sRes ~= resource and sRes or "global"
	local style = styleManager.styles[res]
	local using = style.using
	style = style.loaded[using]

	local sStyle = style.selector
	local textSizeX,textSizeY = tonumber(scaleX),tonumber(scaleY)
	dgsElementData[selector] = {
		itemTextColor = tonumber(textColor or sStyle.itemTextColor),
		itemTextSize = {textSizeX or sStyle.itemTextSize[1],textSizeY or textSizeX or sStyle.itemTextSize[2]},
		clip = false,
		selectorText = {sStyle.selectorText[1],sStyle.selectorText[2]},
		selectorTextSize = sStyle.selectorTextSize,
		selectorTextColor = sStyle.selectorTextColor,
		selectorSize = {nil,1,true},
		selectorImageColorLeft = sStyle.selectorImageColorLeft,
		selectorImageLeft = sStyle.selectorImageLeft,
		selectorImageColorRight = sStyle.selectorImageColorRight,
		selectorImageRight = sStyle.selectorImageRight,
		colorCoded = false,
		quickLeap = 0.02,
		quickLeapState = 0,
		quickLeapTick = 0,
		--scrollChangeCount = 1,
		enableScroll = true,
		placeHolder = "-",
		alignment = {"center","center"},
		isHorizontal = true,
		isReversed = false,
		itemData = {},
		subPixelPositioning = false,
		shadow = {shadowoffsetx,shadowoffsety,shadowcolor},
		select = -1,
	}
	dgsSetParent(selector,parent,true,true)
	calculateGuiPositionSize(selector,x,y,relative or false,w,h,relative or false,true)
	dgsApplyGeneralProperties(selector,sRes)
	onDGSElementCreate(selector,sRes)
	return selector
end

function dgsSelectorAddItem(selector,text,pos)
	if dgsGetType(selector) ~= "dgs-dxselector" then error(dgsGenAsrt(selector,"dgsSelectorAddItem",1,"dgs-dxselector")) end
	local eleData = dgsElementData[selector]
	local alignment = eleData.alignment
	local itemTextColor = eleData.itemTextColor
	local itemTextSize = eleData.itemTextSize
	local colorCoded = eleData.colorCoded
	local itemData = eleData.itemData
	pos = tonumber(pos) or #itemData+1

	if type(text) == "table" then
		_text = text
		text = dgsTranslate(selector,text,sourceResource)
	end
	tableInsert(itemData,pos,{
		[Selector_itemText] = tostring(text or ""),
		[Selector_itemAlignment] = alignment,
		[Selector_itemTextColor] = itemTextColor,
		[Selector_itemColorCoded] = colorCoded,
		[Selector_itemTextScaleX] = itemTextSize[1],
		[Selector_itemTextScaleY] = itemTextSize[2],
		[Selector_itemFont] = nil,	-- font
		[Selector_itemData] = {}, --item data
		[Selector_itemImage] = nil, -- item image
		_translation_text=_text,
	})
	if eleData.select == -1 then
		eleData.select = 1
	end
	return pos
end

function dgsSelectorRemoveItem(selector,i)
	if dgsGetType(selector) ~= "dgs-dxselector" then error(dgsGenAsrt(selector,"dgsSelectorRemoveItem",1,"dgs-dxselector")) end
	local iData = dgsElementData[selector].itemData
	local iLen = #iData
	local iIsNum = type(i) == "number"
	local iNInRange = iIsNum and not (i>=1 and i<=iLen)
	if not (iIsNum and not iNInRange) then error(dgsGenAsrt(i,"dgsSelectorRemoveItem",2,"number","1~"..iLen,iNInRange and "Out Of Range")) end
	i = i-i%1
	tableRemove(iData,i)
	dgsElementData[selector].select = #iData >= 1 and mathClamp(dgsElementData[selector].select,1,#iData) or -1
	return true
end

function dgsSelectorClear(selector)
	if dgsGetType(selector) ~= "dgs-dxselector" then error(dgsGenAsrt(selector,"dgsSelectorClear",1,"dgs-dxselector")) end
	dgsElementData[selector].itemData = {}
	dgsElementData[selector].select = -1
	return true
end

function dgsSelectorSetSelectedItem(selector,i)
	if dgsGetType(selector) ~= "dgs-dxselector" then error(dgsGenAsrt(selector,"dgsSelectorSetSelectedItem",1,"dgs-dxselector")) end
	if not(type(i) == "number") then error(dgsGenAsrt(i,"dgsSelectorSetSelectedItem",2,"number")) end
	local prev = dgsElementData[selector].select
	dgsSetData(selector,"select",i)
	dgsTriggerEvent("onDgsSelectorSelect",selector,i,prev)
	return true
end

function dgsSelectorGetSelectedItem(selector)
	if dgsGetType(selector) ~= "dgs-dxselector" then error(dgsGenAsrt(selector,"dgsSelectorGetSelectedItem",1,"dgs-dxselector")) end
	return dgsElementData[selector].select
end

function dgsSelectorGetItemText(selector,i,retTransOrig)
	if dgsGetType(selector) ~= "dgs-dxselector" then error(dgsGenAsrt(selector,"dgsSelectorGetItemText",1,"dgs-dxselector")) end
	local iData = dgsElementData[selector].itemData
	local iLen = #iData
	local iIsNum = type(i) == "number"
	local iNInRange = iIsNum and not (i>=1 and i<=iLen)
	if not (iIsNum and not iNInRange) then error(dgsGenAsrt(i,"dgsSelectorGetItemText",2,"number","1~"..iLen,iNInRange and "Out Of Range")) end
	i = i-i%1
	return retTransOrig and iData[i]._translation_text or iData[i][Selector_itemText]
end

function dgsSelectorSetItemText(selector,i,text)
	if dgsGetType(selector) ~= "dgs-dxselector" then error(dgsGenAsrt(selector,"dgsSelectorSetItemText",1,"dgs-dxselector")) end
	local iData = dgsElementData[selector].itemData
	local iLen = #iData
	local iIsNum = type(i) == "number"
	local iNInRange = iIsNum and not (i>=1 and i<=iLen)
	if not (iIsNum and not iNInRange) then error(dgsGenAsrt(i,"dgsSelectorSetItemText",2,"number","1~"..iLen,iNInRange and "Out Of Range")) end
	i = i-i%1
	if type(text) == "table" then
		_text = text
		text = dgsTranslate(selector,text,sourceResource)
	end
	iData[i][Selector_itemText] = tostring(text or "")
	iData[i]._translation_text = _text
	return true
end

function dgsSelectorSetItemData(selector,i,...)
	if dgsGetType(selector) ~= "dgs-dxselector" then error(dgsGenAsrt(selector,"dgsSelectorSetItemData",1,"dgs-dxselector")) end
	local iData = dgsElementData[selector].itemData
	local iLen = #iData
	local iIsNum = type(i) == "number"
	local iNInRange = iIsNum and not (i>=1 and i<=iLen)
	if not (iIsNum and not iNInRange) then error(dgsGenAsrt(i,"dgsSelectorSetItemData",2,"number","1~"..iLen,iNInRange and "Out Of Range")) end
	i = i-i%1
	iData[i][Selector_itemData] = iData[i][Selector_itemData] or {}
	if select("#",...) == 2 then
		local key,data = ...
		iData[i][Selector_itemData][key] = data
	else
		local data = ...
		iData[i][Selector_itemData]["_DGSI_NOKEY"] = data
	end
	return true
end

function dgsSelectorGetItemData(selector,i,...)
	if dgsGetType(selector) ~= "dgs-dxselector" then error(dgsGenAsrt(selector,"dgsSelectorGetItemData",1,"dgs-dxselector")) end
	local iData = dgsElementData[selector].itemData
	local iLen = #iData
	local iIsNum = type(i) == "number"
	local iNInRange = iIsNum and not (i>=1 and i<=iLen)
	if not (iIsNum and not iNInRange) then error(dgsGenAsrt(i,"dgsSelectorGetItemData",2,"number","1~"..iLen,iNInRange and "Out Of Range")) end
	i = i-i%1
	if select("#",...) == 0 then
		return iData[i][Selector_itemData] and iData[i][Selector_itemData]["_DGSI_NOKEY"] or false
	else
		return iData[i][Selector_itemData] and iData[i][Selector_itemData][key] or false
	end
end

function dgsSelectorSetItemColor(selector,i,color)
	if dgsGetType(selector) ~= "dgs-dxselector" then error(dgsGenAsrt(selector,"dgsSelectorSetItemColor",1,"dgs-dxselector")) end
	local iData = dgsElementData[selector].itemData
	local iLen = #iData
	local iIsNum = type(i) == "number"
	local iNInRange = iIsNum and not (i>=1 and i<=iLen)
	if not (iIsNum and not iNInRange) then error(dgsGenAsrt(i,"dgsSelectorSetItemColor",2,"number","1~"..iLen,iNInRange and "Out Of Range")) end
	if not (type(color) == "number") then error(dgsGenAsrt(args[3],"dgsSelectorSetItemColor",3,"number")) end
	i = i-i%1
	iData[i][Selector_itemTextColor] = color
	return true
end

function dgsSelectorGetItemColor(selector,i,color)
	if dgsGetType(selector) ~= "dgs-dxselector" then error(dgsGenAsrt(selector,"dgsSelectorGetItemColor",1,"dgs-dxselector")) end
	local iData = dgsElementData[selector].itemData
	local iLen = #iData
	local iIsNum = type(i) == "number"
	local iNInRange = iIsNum and not (i>=1 and i<=iLen)
	if not (iIsNum and not iNInRange) then error(dgsGenAsrt(i,"dgsSelectorGetItemColor",2,"number","1~"..iLen,iNInRange and "Out Of Range")) end
	i = i-i%1
	return iData[i][Selector_itemTextColor]
end

function dgsSelectorSetItemFont(selector,i,font)
	if dgsGetType(selector) ~= "dgs-dxselector" then error(dgsGenAsrt(selector,"dgsSelectorSetItemFont",1,"dgs-dxselector")) end
	local iData = dgsElementData[selector].itemData
	local iLen = #iData
	local iIsNum = type(i) == "number"
	local iNInRange = iIsNum and not (i>=1 and i<=iLen)
	if not (iIsNum and not iNInRange) then error(dgsGenAsrt(i,"dgsSelectorSetItemFont",2,"number","1~"..iLen,iNInRange and "Out Of Range")) end
	if not (fontBuiltIn[font] or dgsGetType(font) == "dx-font") then error(dgsGenAsrt(font,"dgsSelectorSetItemFont",3,"dx-font/string",_,"invalid font")) end
	i = i-i%1
	iData[i][Selector_itemFont] = font
	return true
end

function dgsSelectorGetItemFont(selector,i,font)
	if dgsGetType(selector) ~= "dgs-dxselector" then error(dgsGenAsrt(selector,"dgsSelectorGetItemFont",1,"dgs-dxselector")) end
	local iData = dgsElementData[selector].itemData
	local iLen = #iData
	local iIsNum = type(i) == "number"
	local iNInRange = iIsNum and not (i>=1 and i<=iLen)
	if not (iIsNum and not iNInRange) then error(dgsGenAsrt(i,"dgsSelectorGetItemFont",2,"number","1~"..iLen,iNInRange and "Out Of Range")) end
	i = i-i%1
	return iData[i][Selector_itemFont]
end

function dgsSelectorSetItemTextSize(selector,i,sizeX,sizeY)
	if dgsGetType(selector) ~= "dgs-dxselector" then error(dgsGenAsrt(selector,"dgsSelectorSetItemTextSize",1,"dgs-dxselector")) end
	local iData = dgsElementData[selector].itemData
	local iLen = #iData
	local iIsNum = type(i) == "number"
	local iNInRange = iIsNum and not (i>=1 and i<=iLen)
	if not (iIsNum and not iNInRange) then error(dgsGenAsrt(i,"dgsSelectorSetItemTextSize",2,"number","1~"..iLen,iNInRange and "Out Of Range")) end
	if not (type(sizeX) == "number") then error(dgsGenAsrt(sizeX,"dgsSelectorSetItemTextSize",3,"number")) end
	i = i-i%1
	iData[i][Selector_itemTextScaleX] = sizeX
	iData[i][Selector_itemTextScaleY] = sizeY or sizeX
	return true
end

function dgsSelectorGetItemTextSize(selector,i)
	if dgsGetType(selector) ~= "dgs-dxselector" then error(dgsGenAsrt(selector,"dgsSelectorGetItemTextSize",1,"dgs-dxselector")) end
	local iData = dgsElementData[selector].itemData
	local iLen = #iData
	local iIsNum = type(i) == "number"
	local iNInRange = iIsNum and not (i>=1 and i<=iLen)
	if not (iIsNum and not iNInRange) then error(dgsGenAsrt(i,"dgsSelectorGetItemTextSize",2,"number","1~"..iLen,iNInRange and "Out Of Range")) end
	i = i-i%1
	return iData[i][Selector_itemTextScaleX],iData[i][Selector_itemTextScaleY]
end

function dgsSelectorSetItemAlignment(selector,i,alignX,alignY)
	if dgsGetType(selector) ~= "dgs-dxselector" then error(dgsGenAsrt(selector,"dgsSelectorSetItemAlignment",1,"dgs-dxselector")) end
	local iData = dgsElementData[selector].itemData
	local iLen = #iData
	local iIsNum = type(i) == "number"
	local iNInRange = iIsNum and not (i>=1 and i<=iLen)
	if not (iIsNum and not iNInRange) then error(dgsGenAsrt(i,"dgsSelectorSetItemAlignment",2,"number","1~"..iLen,iNInRange and "Out Of Range")) end
	if not (alignX == nil or HorizontalAlign[alignX]) then error(dgsGenAsrt(alignX,"dgsSelectorSetItemAlignment",3,"string","left/center/right")) end
	if not (alignY == nil or VerticalAlign[alignY]) then error(dgsGenAsrt(alignY,"dgsSelectorSetItemAlignment",4,"string","top/center/bottom")) end
	i = i-i%1
	iData[i][Selector_itemAlignment] = {alignX,alignY}
	return true
end

function dgsSelectorGetItemAlignment(selector,i)
	if dgsGetType(selector) ~= "dgs-dxselector" then error(dgsGenAsrt(selector,"dgsSelectorGetItemAlignment",1,"dgs-dxselector")) end
	local iData = dgsElementData[selector].itemData
	local iLen = #iData
	local iIsNum = type(i) == "number"
	local iNInRange = iIsNum and not (i>=1 and i<=iLen)
	if not (iIsNum and not iNInRange) then error(dgsGenAsrt(i,"dgsSelectorGetItemAlignment",2,"number","1~"..iLen,iNInRange and "Out Of Range")) end
	i = i-i%1
	return unpack(iData[i][Selector_itemAlignment])
end

function dgsSelectorSetItemImage(selector,i,image,color,offx,offy,w,h,relative)
	if dgsGetType(selector) ~= "dgs-dxselector" then error(dgsGenAsrt(selector,"dgsSelectorSetItemImage",1,"dgs-dxselector")) end
	local iData = dgsElementData[selector].itemData
	local iLen = #iData
	local iIsNum = type(i) == "number"
	local iNInRange = iIsNum and not (i>=1 and i<=iLen)
	if not (iIsNum and not iNInRange) then error(dgsGenAsrt(i,"dgsSelectorSetItemImage",2,"number","1~"..iLen,iNInRange and "Out Of Range")) end
	i = i-i%1
	local imageData,size = iData[i][10] or {},dgsElementData[selector].absSize
	imageData[1] = image or imageData[1]
	imageData[2] = color or imageData[2] or white
	imageData[3] = offx or imageData[3] or 0
	imageData[4] = offy or imageData[4] or 0
	imageData[5] = w or imageData[5] or relative and 1 or size[1]
	imageData[6] = h or imageData[6] or relative and 1 or size[2]
	imageData[7] = relative or false
	iData[i][Selector_itemImage] = imageData
end

function dgsSelectorGetItemImage(selector,i)
	if dgsGetType(selector) ~= "dgs-dxselector" then error(dgsGenAsrt(selector,"dgsSelectorGetItemImage",1,"dgs-dxselector")) end
	local iData = dgsElementData[selector].itemData
	local iLen = #iData
	local iIsNum = type(i) == "number"
	local iNInRange = iIsNum and not (i>=1 and i<=iLen)
	if not (iIsNum and not iNInRange) then error(dgsGenAsrt(i,"dgsSelectorGetItemImage",2,"number","1~"..iLen,iNInRange and "Out Of Range")) end
	i = i-i%1
	return unpack(iData[i][Selector_itemImage] or {})
end

function dgsSelectorRemoveItemImage(selector,i)
	if dgsGetType(selector) ~= "dgs-dxselector" then error(dgsGenAsrt(selector,"dgsSelectorRemoveItemImage",1,"dgs-dxselector")) end
	local iData = dgsElementData[selector].itemData
	local iLen = #iData
	local iIsNum = type(i) == "number"
	local iNInRange = iIsNum and not (i>=1 and i<=iLen)
	if not (iIsNum and not iNInRange) then error(dgsGenAsrt(i,"dgsSelectorRemoveItemImage",2,"number","1~"..iLen,iNInRange and "Out Of Range")) end
	i = i-i%1
	iData[i][Selector_itemImage] = nil
	return true
end
----------------------------------------------------------------
---------------------OnMouseScrollAction------------------------
----------------------------------------------------------------
dgsOnMouseScrollAction["dgs-dxselector"] = function(dgsEle,isWheelDown)
	if dgsElementData[dgsEle].enableScroll then
		if MouseData.focused ~= dgsEle then 
			dgsFocus(dgsEle)
		end
		local itemData = dgsElementData[dgsEle].itemData
		local currentItem = dgsElementData[dgsEle].select
		local isReversed = dgsElementData[dgsEle].isReversed
		local itemCount = #itemData
		local itemIndex = currentItem+(isWheelDown and 1 or -1)*(isReversed and -1 or 1)
		itemIndex = dgsElementData[dgsEle].circularNavigation and (itemIndex < 1 and itemCount or itemIndex > itemCount and 1) or mathClamp(itemIndex-itemIndex%1,1,itemCount)
		dgsSelectorSetSelectedItem(dgsEle,itemIndex)
	end
end

----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxselector"] = function(source,x,y,w,h,mx,my,cx,cy,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt)
	if MouseData.hit == source and eleData.enableScroll then
		MouseData.topScrollable = source
	end

	local style = styleManager.styles[eleData.resource or "global"]
	style = style.loaded[style.using]
	local font = eleData.font or style.selector.font or style.systemFontElement

	local itemData = eleData.itemData
	local selector = eleData.selectorText
	local alignment = eleData.alignment
	local colorCoded = eleData.colorCoded
	local placeHolder = eleData.placeHolder
	local itemTextColorDef = eleData.itemTextColor
	local selectorSize = eleData.selectorSize
	local selectorTextColor = eleData.selectorTextColor
	local itemTextSizeDef = eleData.itemTextSize
	local selectorTextSize = eleData.selectorTextSize
	local isHorizontal = eleData.isHorizontal
	local isReversed = eleData.isReversed
	local selectorSizeX,selectorSizeY
	local selectMinBound,selectMaxBound
	if isHorizontal then
		if selectorSize[1] then
			selectorSizeX = selectorSize[1]*(selectorSize[3] and w or 1)
		end
		if selectorSize[2] then
			selectorSizeY = selectorSize[2]*(selectorSize[3] and h or 1)
		end
		selectorSizeX,selectorSizeY = selectorSizeX or selectorSizeY,selectorSizeY or selectorSizeX
		selectMinBound = (h-selectorSizeY)/2
		selectMaxBound = selectMinBound+selectorSizeY

	else
		if selectorSize[1] then
			selectorSizeX = selectorSize[1]*(selectorSize[3] and h or 1)
		end
		if selectorSize[2] then
			selectorSizeY = selectorSize[2]*(selectorSize[3] and w or 1)
		end
		selectorSizeX,selectorSizeY = selectorSizeX or selectorSizeY,selectorSizeY or selectorSizeX
		selectMinBound = (w-selectorSizeX)/2
		selectMaxBound = selectMinBound+selectorSizeX
	end

	local preEnterData = false
	local selectorTextColors = {1,1,1}
	if MouseData.entered == source then
		if isHorizontal then
			if my-cy >= selectMinBound and my-cy <= selectMaxBound then
				if mx-cx >= 0 and mx-cx <= selectorSizeX then				--Left Arrow
					preEnterData = isReversed and 3 or 1
				elseif mx-cx >= w-selectorSizeX and mx-cx <= w then		--Right Arrow
					preEnterData = isReversed and 1 or 3
				else
					preEnterData = 2
				end
			end
		else
			if mx-cx >= selectMinBound and mx-cx <= selectMaxBound then
				if my-cy >= 0 and my-cy <= selectorSizeX then				--Top Arrow
					preEnterData = isReversed and 3 or 1
				elseif my-cy >= h-selectorSizeX and my-cy <= h then		--Bottom Arrow
					preEnterData = isReversed and 1 or 3
				else
					preEnterData = 2
				end
			end
		end
		if not MouseData.selectorClickData then
			MouseData.selectorEnterData = preEnterData
			if MouseData.selectorEnterData then
				selectorTextColors[preEnterData] = 2
			end
		else
			local mouseButtons = eleData.mouseButtons
			local canLeftClick,canRightClick,canMiddleClick = true
			if mouseButtons then
				canLeftClick,canRightClick,canMiddleClick = mouseButtons[1],mouseButtons[2],mouseButtons[3]
			end
			if (canLeftClick and MouseData.click.left == source) or (canRightClick and MouseData.click.right == source) or (canMiddleClick and MouseData.click.middle == source) then
				selectorTextColors[MouseData.selectorClickData] = 3
			else
				selectorTextColors[MouseData.selectorClickData] = 2
			end
		end
	end

	local renderItem = itemData[eleData.select]
	if eleData.select ~= -1 and renderItem then
		local imageData = renderItem[Selector_itemImage]
		if imageData then
			local imageX = x+(imageData[7] and imageData[3]*w or imageData[3])
			local imageY = y+(imageData[7] and imageData[4]*h or imageData[4])
			local imageW = imageData[7] and imageData[5]*w or imageData[5]
			local imageH = imageData[7] and imageData[6]*h or imageData[6]
			dxDrawImage(imageX,imageY,imageW,imageH,imageData[1],0,0,0,applyColorAlpha(imageData[2],parentAlpha),isPostGUI)
		end
		local itemTextColor = type(renderItem[Selector_itemTextColor]) == "table" and renderItem[Selector_itemTextColor][selectorTextColors[2]] or renderItem[Selector_itemTextColor]
		local itemFont = renderItem[Selector_itemFont] or font
		local itemAlignment = renderItem[Selector_itemAlignment]
		local itemColorCoded = renderItem[Selector_itemColorCoded] == nil and colorCoded or renderItem[Selector_itemColorCoded]
		dgsDrawText(renderItem[Selector_itemText],x+selectorSizeX,y,x+w-selectorSizeX,y+h,applyColorAlpha(itemTextColor,parentAlpha),renderItem[Selector_itemTextScaleX],renderItem[Selector_itemTextScaleY],itemFont,itemAlignment[1],itemAlignment[2],false,false,isPostGUI,itemColorCoded)
	else
		local itemTextColor = type(itemTextColorDef) == "table" and itemTextColorDef[selectorTextColors[2]] or itemTextColorDef
		dgsDrawText(placeHolder,x+selectorSizeX,y,x+w-selectorSizeX,y+h,applyColorAlpha(itemTextColor,parentAlpha),itemTextSizeDef[1],itemTextSizeDef[2],font,alignment[1],alignment[2],false,false,isPostGUI,colorCoded)
	end

	local selectorTextColorLeft = selectorTextColor[selectorTextColors[1]]
	local selectorTextColorRight = selectorTextColor[selectorTextColors[3]]
	local selectorImageLeft = eleData.selectorImageLeft[selectorTextColors[1]]
	local selectorImageRight = eleData.selectorImageRight[selectorTextColors[3]]
	local selectorImageColorLeft = eleData.selectorImageColorLeft[selectorTextColors[1]]
	local selectorImageColorRight = eleData.selectorImageColorRight[selectorTextColors[3]]
	local selectorTextLeft = selector[1]
	local selectorTextRight = selector[2]
	if isReversed then
		selectorTextColorLeft,selectorTextColorRight = selectorTextColorRight,selectorTextColorLeft
		selectorImageLeft,selectorImageRight = selectorImageRight,selectorImageLeft
		selectorImageColorLeft,selectorImageColorRight = selectorImageColorRight,selectorImageColorLeft
		selectorTextLeft,selectorTextRight = selectorTextRight,selectorTextLeft
	end

	if isHorizontal then
		local selectorStart = y+selectMinBound
		local selectorEnd = selectorStart+selectorSizeY
		if selectorImageColorLeft then
			dxDrawImage(x,selectorStart,selectorSizeX,selectorSizeY,selectorImageLeft,0,0,0,applyColorAlpha(selectorImageColorLeft,parentAlpha),isPostGUI,rndtgt)
		end
		if selectorImageColorRight then
			dxDrawImage(x+w-selectorSizeX,selectorStart,selectorSizeX,selectorSizeY,selectorImageRight,0,0,0,applyColorAlpha(selectorImageColorRight,parentAlpha),isPostGUI,rndtgt)
		end
		dgsDrawText(selectorTextLeft,x,selectorStart,x+selectorSizeX,selectorEnd,applyColorAlpha(selectorTextColorLeft,parentAlpha),selectorTextSize[1],selectorTextSize[2],font,alignment[1],alignment[2],false,false,isPostGUI,colorCoded)
		dgsDrawText(selectorTextRight,x+w-selectorSizeX,selectorStart,x+w,selectorEnd,applyColorAlpha(selectorTextColorRight,parentAlpha),selectorTextSize[1],selectorTextSize[2],font,alignment[1],alignment[2],false,false,isPostGUI,colorCoded)
	else
		local selectorStart = x+selectMinBound
		local selectorEnd = selectorStart+selectorSizeX
		if selectorImageColorLeft then
			dxDrawImage(selectorStart,y,selectorSizeX,selectorSizeY,selectorImageLeft,0,0,0,applyColorAlpha(selectorImageColorLeft,parentAlpha),isPostGUI,rndtgt)
		end
		if selectorImageColorRight then
			dxDrawImage(selectorStart,y+h-selectorSizeY,selectorSizeX,selectorSizeY,selectorImageRight,0,0,0,applyColorAlpha(selectorImageColorRight,parentAlpha),isPostGUI,rndtgt)
		end
		dgsDrawText(selectorTextLeft,selectorStart,y,selectorEnd,y+selectorSizeY,applyColorAlpha(selectorTextColorLeft,parentAlpha),selectorTextSize[1],selectorTextSize[2],font,alignment[1],alignment[2],false,false,isPostGUI,colorCoded)
		dgsDrawText(selectorTextRight,selectorStart,y+h-selectorSizeY,selectorEnd,y+h,applyColorAlpha(selectorTextColorRight,parentAlpha),selectorTextSize[1],selectorTextSize[2],font,alignment[1],alignment[2],false,false,isPostGUI,colorCoded)
	end
	return rndtgt,false,mx,my,0,0
end