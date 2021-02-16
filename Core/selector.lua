--Dx Functions
local dxDrawImage = dxDrawImageExt
local dxDrawText = dxDrawText
local dxDrawRectangle = dxDrawRectangle
--DGS Functions
local dgsSetType = dgsSetType
local dgsGetType = dgsGetType
local dgsSetParent = dgsSetParent
local dgsSetData = dgsSetData
local applyColorAlpha = applyColorAlpha
local dgsTranslate = dgsTranslate
local calculateGuiPositionSize = calculateGuiPositionSize
--Utilities
local triggerEvent = triggerEvent
local createElement = createElement
local assert = assert
local tonumber = tonumber
local type = type
local tableInsert = table.insert
local tableRemove = table.remove
local mathClamp = math.restrict
--[[
Selector Data Structure:
{
	{text,alignment,color,colorcoded,sizex,sizey,font},
	{text,alignment,color,colorcoded,sizex,sizey,font},
	{text,alignment,color,colorcoded,sizex,sizey,font},
}
]]
function dgsCreateSelector(...)
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
	dgsSetParent(selector,parent,true,true)
	local style = styleSettings.selector
	local textSizeX,textSizeY = tonumber(scaleX),tonumber(scaleY)
	dgsElementData[selector] = {
		itemTextColor = tonumber(textColor or style.itemTextColor),
		itemTextSize = {textSizeX,textSizeY or style.itemTextSize[2]},
		clip = false,
		selectorText = {textSizeX or style.selectorText[1],textSizeY or style.selectorText[2]},
		selectorTextSize = style.selectorTextSize,
		selectorTextColor = style.selectorTextColor,
		selectorSize = {nil,1,true},
		selectorImageColorLeft = style.selectorImageColorLeft,
		selectorImageLeft = style.selectorImageLeft,
		selectorImageColorRight = style.selectorImageColorRight,
		selectorImageRight = style.selectorImageRight,
		colorcoded = false,
		quickLeap = 0.02,
		quickLeapState = 0,
		quickLeapTick = 0,
		scrollChangeCount = 1,
		enableScroll = true,
		defaultText = "-",
		alignment = {"center","center"},
		itemData = {},
		subPixelPositioning = false,
		shadow = {shadowoffsetx,shadowoffsety,shadowcolor},
		font = style.font or systemFont,
		selectedItem = -1,
	}
	calculateGuiPositionSize(selector,x,y,relative or false,w,h,relative or false,true)
	triggerEvent("onDgsCreate",selector,sourceResource)
	return selector
end

function dgsSelectorAddItem(selector,text,pos)
	if dgsGetType(selector) ~= "dgs-dxselector" then error(dgsGenAsrt(selector,"dgsSelectorAddItem",1,"dgs-dxselector")) end
	local eleData = dgsElementData[selector]
	local alignment = eleData.alignment
	local itemTextColor = eleData.itemTextColor
	local itemTextSize = eleData.itemTextSize
	local colorcoded = eleData.colorcoded
	local font = eleData.font
	local itemData = eleData.itemData
	local pos = tonumber(pos) or #itemData+1

	if type(text) == "table" then
		_text = text
		text = dgsTranslate(selector,text,sourceResource)
	end
	tableInsert(itemData,pos,{
		tostring(text or ""),
		alignment,
		itemTextColor,
		colorcoded,
		itemTextSize[1],
		itemTextSize[2],
		font,
		_translationText=_text,
		{}, --item data
	})
	if eleData.selectedItem == -1 then
		eleData.selectedItem = 1
	end
	return pos
end

function dgsSelectorRemoveItem(selector,i)
	if dgsGetType(selector) ~= "dgs-dxselector" then error(dgsGenAsrt(selector,"dgsSelectorRemoveItem",1,"dgs-dxselector")) end
	if not(type(i) == "number") then error(dgsGenAsrt(i,"dgsSelectorRemoveItem",2,"number")) end
	local iData = dgsElementData[selector].itemData
	if iData[i] then
		tableRemove(iData,i)
		dgsElementData[selector].selectedItem = #iData >= 1 and mathClamp(dgsElementData[selector].selectedItem,1,#iData) or -1
	end
	return false
end

function dgsSelectorSetSelectedItem(selector,i)
	if dgsGetType(selector) ~= "dgs-dxselector" then error(dgsGenAsrt(selector,"dgsSelectorSetSelectedItem",1,"dgs-dxselector")) end
	if not(type(i) == "number") then error(dgsGenAsrt(i,"dgsSelectorSetSelectedItem",2,"number")) end
	local prev = dgsElementData[selector].selectedItem
	dgsSetData(selector,"selectedItem",i)
	triggerEvent("onDgsSelectorSelect",selector,i,prev)
	return true
end

function dgsSelectorGetSelectedItem(selector)
	if dgsGetType(selector) ~= "dgs-dxselector" then error(dgsGenAsrt(selector,"dgsSelectorGetSelectedItem",1,"dgs-dxselector")) end
	return dgsElementData[selector].selectedItem
end

function dgsSelectorGetItemText(selector,i,retTransOrig)
	if dgsGetType(selector) ~= "dgs-dxselector" then error(dgsGenAsrt(selector,"dgsSelectorGetItemText",1,"dgs-dxselector")) end
	if not(type(i) == "number") then error(dgsGenAsrt(i,"dgsSelectorGetItemText",2,"number")) end
	local iData = dgsElementData[selector].itemData
	if iData[i] then
		return retTransOrig and iData[8] or iData[1]
	end
	return false
end

function dgsSelectorSetItemText(selector,i,text)
	if dgsGetType(selector) ~= "dgs-dxselector" then error(dgsGenAsrt(selector,"dgsSelectorSetItemText",1,"dgs-dxselector")) end
	if not(type(i) == "number") then error(dgsGenAsrt(i,"dgsSelectorSetItemText",2,"number")) end
	local iData = dgsElementData[selector].itemData
	if iData[i] then
		if type(text) == "table" then
			_text = text
			text = dgsTranslate(selector,text,sourceResource)
		end
		iData[i][1] = tostring(text)
		iData[i][8] = _text
		return true
	end
	return false
end

function dgsSelectorSetItemData(selector,i,key,data)
	if dgsGetType(selector) ~= "dgs-dxselector" then error(dgsGenAsrt(selector,"dgsSelectorSetItemData",1,"dgs-dxselector")) end
	if not(type(i) == "number") then error(dgsGenAsrt(i,"dgsSelectorSetItemData",2,"number")) end
	local iData = dgsElementData[selector].itemData
	if iData[i] then
		iData[i][9] = iData[i][9] or {}
		iData[i][9][key] = data
		return true
	end
	return false
end

function dgsSelectorGetItemData(selector,i,key)
	if dgsGetType(selector) ~= "dgs-dxselector" then error(dgsGenAsrt(selector,"dgsSelectorGetItemData",1,"dgs-dxselector")) end
	if not(type(i) == "number") then error(dgsGenAsrt(i,"dgsSelectorGetItemData",2,"number")) end
	local iData = dgsElementData[selector].itemData
	if iData[i] then
		iData[i][9] = iData[i][9] or {}
		return iData[i][9][key]
	end
	return false
end

----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxselector"] = function(source,x,y,w,h,mx,my,cx,cy,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt)
	if MouseData.hit == source and MouseData.nowShow == source then
		MouseData.topScrollable = source
	end
	local itemData = eleData.itemData
	local selector = eleData.selectorText
	local alignment = eleData.alignment
	local font = eleData.font
	local colorcoded = eleData.colorcoded
	local defaultText = eleData.defaultText
	local itemTextColorDef = eleData.itemTextColor
	local selectorSize = eleData.selectorSize
	local selectorTextColor = eleData.selectorTextColor
	local itemTextSizeDef = eleData.itemTextSize
	local selectorTextSize = eleData.selectorTextSize
	local selectorSizeX,selectorSizeY
	if selectorSize[1] then
		selectorSizeX = selectorSize[1]*(selectorSize[3] and w or 1)
	end
	if selectorSize[2] then
		selectorSizeY = selectorSize[2]*(selectorSize[3] and h or 1)
	end
	selectorSizeX,selectorSizeY = selectorSizeX or selectorSizeY,selectorSizeY or selectorSizeX
	local selectorStartY = y+(h-selectorSizeY)/2
	local selectorEndY = selectorStartY+selectorSizeY

	local preEnterData = false
	local selectorTextColors = {1,1,1}
	if MouseData.enter == source then
		if my >= selectorStartY and my <= selectorEndY then
			if mx >= cx and mx <= cx+selectorSizeX then				--Left Arrow
				preEnterData = 1
			elseif mx >= cx+w-selectorSizeX and mx <= cx+w then		--Right Arrow
				preEnterData = 3
			else
				preEnterData = 2
			end
		end
		if not MouseData.selectorClickData then
			MouseData.selectorEnterData = preEnterData
			if MouseData.selectorEnterData then
				selectorTextColors[preEnterData] = 2
			end
		else
			if MouseData.clickl == source then
				selectorTextColors[MouseData.selectorClickData] = 3
			else
				selectorTextColors[MouseData.selectorClickData] = 2
			end
		end
	end
	local selectorTextColorLeft = selectorTextColor[selectorTextColors[1]]
	local selectorTextColorRight = selectorTextColor[selectorTextColors[3]]

	local selectorImageLeft = eleData.selectorImageLeft[selectorTextColors[1]]
	local selectorImageRight = eleData.selectorImageRight[selectorTextColors[3]]
	local selectorImageColorLeft = eleData.selectorImageColorLeft[selectorTextColors[1]]
	local selectorImageColorRight = eleData.selectorImageColorRight[selectorTextColors[3]]

	if selectorImageColorLeft then
		if selectorImageLeft then
			dxDrawImage(x,selectorStartY,selectorSizeX,selectorSizeY,selectorImageLeft,0,0,0,selectorImageColorLeft,isPostGUI,rndtgt)
		else
			dxDrawRectangle(x,selectorStartY,selectorSizeX,selectorSizeY,selectorImageColorLeft,isPostGUI)
		end
	end
	if selectorImageColorRight then
		if selectorImageRight then
			dxDrawImage(x+w-selectorSizeX,selectorStartY,selectorSizeX,selectorSizeY,selectorImageRight,0,0,0,selectorImageColorRight,isPostGUI,rndtgt)
		else
			dxDrawRectangle(x+w-selectorSizeX,selectorStartY,selectorSizeX,selectorSizeY,selectorImageColorRight,isPostGUI)
		end
	end
	local renderItem = itemData[eleData.selectedItem]
	if eleData.selectedItem ~= -1 and renderItem then
		local itemTextColor = type(renderItem[3]) == "table" and renderItem[3][selectorTextColors[2]] or renderItem[3]
		dxDrawText(renderItem[1],x+selectorSizeX,y,x+w-selectorSizeX,y+h,itemTextColor,renderItem[5],renderItem[6],renderItem[7],renderItem[2][1],renderItem[2][2],false,false,isPostGUI,renderItem[4])
	else
		local itemTextColor = type(itemTextColorDef) == "table" and itemTextColorDef[selectorTextColors[2]] or itemTextColorDef
		dxDrawText(defaultText,x+selectorSizeX,y,x+w-selectorSizeX,y+h,itemTextColor,itemTextSizeDef[1],itemTextSizeDef[2],font,alignment[1],alignment[2],false,false,isPostGUI,colorcoded)
	end
	dxDrawText(selector[1],x,selectorStartY,x+selectorSizeX,selectorEndY,selectorTextColorLeft,selectorTextSize[1],selectorTextSize[2],font,alignment[1],alignment[2],false,false,isPostGUI,colorcoded)
	dxDrawText(selector[2],x+w-selectorSizeX,selectorStartY,x+w,selectorEndY,selectorTextColorRight,selectorTextSize[1],selectorTextSize[2],font,alignment[1],alignment[2],false,false,isPostGUI,colorcoded)
	return rndtgt
end