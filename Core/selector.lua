--Dx Functions
local dxDrawLine = dxDrawLine
local dxDrawImage = dxDrawImageExt
local dxDrawImageSection = dxDrawImageSectionExt
local dxDrawText = dxDrawText
local dxGetFontHeight = dxGetFontHeight
local dxDrawRectangle = dxDrawRectangle
local dxSetShaderValue = dxSetShaderValue
local dxGetPixelsSize = dxGetPixelsSize
local dxGetPixelColor = dxGetPixelColor
local dxSetRenderTarget = dxSetRenderTarget
local dxGetTextWidth = dxGetTextWidth
local dxSetBlendMode = dxSetBlendMode
--
local tableInsert = table.insert
--[[
Selector Data Structure:
{
	{text,alignment,color,colorcoded,sizex,sizey,font},
	{text,alignment,color,colorcoded,sizex,sizey,font},
	{text,alignment,color,colorcoded,sizex,sizey,font},
}
]]
function dgsCreateSelector(x,y,sx,sy,relative,parent,textColor,scalex,scaley,shadowoffsetx,shadowoffsety,shadowcolor)
	assert(type(x) == "number","Bad argument @dgsCreateSelector at argument 1, expect number got "..type(x))
	assert(type(y) == "number","Bad argument @dgsCreateSelector at argument 2, expect number got "..type(y))
	assert(type(sx) == "number","Bad argument @dgsCreateSelector at argument 3, expect number got "..type(sx))
	assert(type(sy) == "number","Bad argument @dgsCreateSelector at argument 4, expect number got "..type(sy))
	local selector = createElement("dgs-dxselector")
	dgsSetType(selector,"dgs-dxselector")
	dgsSetParent(selector,parent,true,true)
	local textSizeX,textSizeY = tonumber(scalex),tonumber(scaley)
	dgsSetData(selector,"itemTextColor",textColor or styleSettings.selector.itemTextColor)
	dgsSetData(selector,"itemTextSize",{textSizeX or styleSettings.selector.itemTextSize[1],textSizeY or styleSettings.selector.itemTextSize[2]})
	dgsSetData(selector,"clip",false)
	dgsSetData(selector,"selectorText",{textSizeX or styleSettings.selector.selectorText[1],textSizeY or styleSettings.selector.selectorText[2]})
	dgsSetData(selector,"selectorTextSize",styleSettings.selector.selectorTextSize)
	dgsSetData(selector,"selectorTextColor",styleSettings.selector.selectorTextColor)
	dgsSetData(selector,"selectorSize",{nil,1,true})
	dgsSetData(selector,"selectorImageColorLeft",styleSettings.selector.selectorImageColorLeft)
	dgsSetData(selector,"selectorImageLeft",styleSettings.selector.selectorImageLeft)
	dgsSetData(selector,"selectorImageColorRight",styleSettings.selector.selectorImageColorRight)
	dgsSetData(selector,"selectorImageRight",styleSettings.selector.selectorImageRight)
	dgsSetData(selector,"colorcoded",false)

	dgsSetData(selector,"quickLeap",0.02)
	dgsSetData(selector,"quickLeapState",0)
	dgsSetData(selector,"quickLeapTick",0)
	dgsSetData(selector,"scrollChangeCount",1)

	dgsSetData(selector,"enableScroll",true)
	dgsSetData(selector,"defaultText","-")
	dgsSetData(selector,"alignment",{"center","center"})
	dgsSetData(selector,"itemData",{})
	dgsSetData(selector,"subPixelPositioning",false)
	dgsSetData(selector,"shadow",{shadowoffsetx,shadowoffsety,shadowcolor})
	dgsSetData(selector,"font",styleSettings.selector.font or systemFont)
	dgsSetData(selector,"selectedItem",-1)
	calculateGuiPositionSize(selector,x,y,relative or false,sx,sy,relative or false,true)
	triggerEvent("onDgsCreate",selector,sourceResource)
	return selector
end

function dgsSelectorAddItem(selector,text,pos)
	assert(dgsGetType(selector) == "dgs-dxselector","Bad argument @dgsSelectorAddItem at argument 1, expect dgs-dxselector got "..dgsGetType(selector))
	local alignment = dgsElementData[selector].alignment
	local itemTextColor = dgsElementData[selector].itemTextColor
	local itemTextSize = dgsElementData[selector].itemTextSize
	local colorcoded = dgsElementData[selector].colorcoded
	local font = dgsElementData[selector].font
	local itemData = dgsElementData[selector].itemData
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
	if dgsElementData[selector].selectedItem == -1 then
		dgsElementData[selector].selectedItem = 1
	end
	return pos
end

function dgsSelectorRemoveItem(selector,item)
	assert(dgsGetType(selector) == "dgs-dxselector","Bad argument @dgsSelectorAddItem at argument 1, expect dgs-dxselector got "..dgsGetType(selector))
	assert(type(item) == "number","Bad argument @dgsSelectorAddItem at argument 2, expect number got "..type(item))
	local itemData = dgsElementData[selector].itemData
	if itemData[item] then
		tableRemove(itemData,pos)
		dgsElementData[selector].selectedItem = #itemData >= 1 and math.restrict(dgsElementData[selector].selectedItem,1,#itemData) or -1
	end
	return false
end

function dgsSelectorSetSelectedItem(selector,item)
	assert(dgsGetType(selector) == "dgs-dxselector","Bad argument @dgsSelectorSetSelectedItem at argument 1, expect dgs-dxselector got "..dgsGetType(selector))
	assert(type(item) == "number","Bad argument @dgsSelectorSetSelectedItem at argument 2, expect number got "..type(item))
	local prev = dgsElementData[selector].selectedItem
	dgsSetData(selector,"selectedItem",item)
	triggerEvent("onDgsSelectorSelect",selector,item,prev)
	return true
end

function dgsSelectorGetSelectedItem(selector)
	assert(dgsGetType(selector) == "dgs-dxselector","Bad argument @dgsSelectorGetSelectedItem at argument 1, expect dgs-dxselector got "..dgsGetType(selector))
	return dgsElementData[selector].selectedItem
end

function dgsSelectorGetItemText(selector,item,retTransOrig)
	assert(dgsGetType(selector) == "dgs-dxselector","Bad argument @dgsSelectorGetItemText at argument 1, expect dgs-dxselector got "..dgsGetType(selector))
	assert(type(item) == "number","Bad argument @dgsSelectorGetItemText at argument 2, expect number got "..type(item))
	local itemData = dgsElementData[selector].itemData
	if itemData[item] then
		return retTransOrig and itemData[8] or itemData[1]
	end
	return false
end

function dgsSelectorSetItemText(selector,item,text)
	assert(dgsGetType(selector) == "dgs-dxselector","Bad argument @dgsSelectorSetItemText at argument 1, expect dgs-dxselector got "..dgsGetType(selector))
	assert(type(item) == "number","Bad argument @dgsSelectorSetItemText at argument 2, expect number got "..type(item))
	local itemData = dgsElementData[selector].itemData
	if itemData[item] then
		if type(text) == "table" then
			_text = text
			text = dgsTranslate(selector,text,sourceResource)
		end
		itemData[item][1] = tostring(text)
		itemData[item][8] = _text
		return true
	end
	return false
end

function dgsSelectorSetItemData(selector,item,key,data)
	assert(dgsGetType(selector) == "dgs-dxselector","Bad argument @dgsSelectorSetItemData at argument 1, expect dgs-dxselector got "..dgsGetType(selector))
	assert(type(item) == "number","Bad argument @dgsSelectorSetItemData at argument 2, expect number got "..type(item))
	local itemData = dgsElementData[selector].itemData
	if itemData[item] then
		itemData[item][9] = itemData[item][9] or {}
		itemData[item][9][key] = data
		return true
	end
	return false
end

function dgsSelectorGetItemData(selector,item,key)
	assert(dgsGetType(selector) == "dgs-dxselector","Bad argument @dgsSelectorGetItemData at argument 1, expect dgs-dxselector got "..dgsGetType(selector))
	assert(type(item) == "number","Bad argument @dgsSelectorGetItemData at argument 2, expect number got "..type(item))
	if itemData[item] then
		itemData[item][9] = itemData[item][9] or {}
		return itemData[item][9][key]
	end
	return false
end

----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxselector"] = function(source,x,y,w,h,mx,my,cx,cy,enabled,eleData,parentAlpha,isPostGUI,rndtgt)
	local itemData = eleData.itemData
	local itemCount = #itemData
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
			dxDrawImage(x,selectorStartY,selectorSizeX,selectorSizeY,selectorImageLeft,0,0,0,selectorImageColorLeft,isPostGUI)
		else
			dxDrawRectangle(x,selectorStartY,selectorSizeX,selectorSizeY,selectorImageColorLeft,isPostGUI)
		end
	end
	if selectorImageColorRight then
		if selectorImageRight then
			dxDrawImage(x+w-selectorSizeX,selectorStartY,selectorSizeX,selectorSizeY,selectorImageRight,0,0,0,selectorImageColorRight,isPostGUI)
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