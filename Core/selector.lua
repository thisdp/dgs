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
	{text,alignment,color,colorcoded,sizex,sizey,font,translationTest,data,imageData},
	{text,alignment,color,colorcoded,sizex,sizey,font,translationTest,data,imageData},
	{text,alignment,color,colorcoded,sizex,sizey,font,translationTest,data,imageData},
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
		itemTextSize = {textSizeX or style.itemTextSize[1],textSizeY or textSizeX or style.itemTextSize[2]},
		clip = false,
		selectorText = {style.selectorText[1],style.selectorText[2]},
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
		--scrollChangeCount = 1,
		enableScroll = true,
		placeHolder = "-",
		alignment = {"center","center"},
		itemData = {},
		subPixelPositioning = false,
		shadow = {shadowoffsetx,shadowoffsety,shadowcolor},
		font = style.font or systemFont,
		select = -1,
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
		nil, -- item image
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
	local i = i-i%1
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
	triggerEvent("onDgsSelectorSelect",selector,i,prev)
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
	local i = i-i%1
	return retTransOrig and iData[i][8] or iData[i][1]
end

function dgsSelectorSetItemText(selector,i,text)
	if dgsGetType(selector) ~= "dgs-dxselector" then error(dgsGenAsrt(selector,"dgsSelectorSetItemText",1,"dgs-dxselector")) end
	local iData = dgsElementData[selector].itemData
	local iLen = #iData
	local iIsNum = type(i) == "number"
	local iNInRange = iIsNum and not (i>=1 and i<=iLen)
	if not (iIsNum and not iNInRange) then error(dgsGenAsrt(i,"dgsSelectorSetItemText",2,"number","1~"..iLen,iNInRange and "Out Of Range")) end
	local i = i-i%1
	if type(text) == "table" then
		_text = text
		text = dgsTranslate(selector,text,sourceResource)
	end
	iData[i][1] = tostring(text)
	iData[i][8] = _text
	return true
end

function dgsSelectorSetItemData(selector,i,...)
	if dgsGetType(selector) ~= "dgs-dxselector" then error(dgsGenAsrt(selector,"dgsSelectorSetItemData",1,"dgs-dxselector")) end
	local iData = dgsElementData[selector].itemData
	local iLen = #iData
	local iIsNum = type(i) == "number"
	local iNInRange = iIsNum and not (i>=1 and i<=iLen)
	if not (iIsNum and not iNInRange) then error(dgsGenAsrt(i,"dgsSelectorSetItemData",2,"number","1~"..iLen,iNInRange and "Out Of Range")) end
	local i = i-i%1
	iData[i][9] = iData[i][9] or {}
	if select("#",...) == 2 then
		local key,data = ...
		iData[i][9][key] = data
	else
		local data = ...
		iData[i][9]["_DGSI_NOKEY"] = data
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
	local i = i-i%1
	if select("#",...) == 0 then
		return iData[i][9] and iData[i][9]["_DGSI_NOKEY"] or false
	else
		return iData[i][9] and iData[i][9][key] or false
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
	local i = i-i%1
	iData[i][3] = color
	return true
end

function dgsSelectorGetItemColor(selector,i,color)
	if dgsGetType(selector) ~= "dgs-dxselector" then error(dgsGenAsrt(selector,"dgsSelectorGetItemColor",1,"dgs-dxselector")) end
	local iData = dgsElementData[selector].itemData
	local iLen = #iData
	local iIsNum = type(i) == "number"
	local iNInRange = iIsNum and not (i>=1 and i<=iLen)
	if not (iIsNum and not iNInRange) then error(dgsGenAsrt(i,"dgsSelectorGetItemColor",2,"number","1~"..iLen,iNInRange and "Out Of Range")) end
	local i = i-i%1
	return iData[i][3]
end

function dgsSelectorSetItemFont(selector,i,font)
	if dgsGetType(selector) ~= "dgs-dxselector" then error(dgsGenAsrt(selector,"dgsSelectorSetItemFont",1,"dgs-dxselector")) end
	local iData = dgsElementData[selector].itemData
	local iLen = #iData
	local iIsNum = type(i) == "number"
	local iNInRange = iIsNum and not (i>=1 and i<=iLen)
	if not (iIsNum and not iNInRange) then error(dgsGenAsrt(i,"dgsSelectorSetItemFont",2,"number","1~"..iLen,iNInRange and "Out Of Range")) end
	if not (fontBuiltIn[font] or dgsGetType(font) == "dx-font") then error(dgsGenAsrt(font,"dgsSelectorSetItemFont",3,"dx-font/string",_,"invalid font")) end
	local i = i-i%1
	iData[i][7] = font
	return true
end

function dgsSelectorGetItemFont(selector,i,font)
	if dgsGetType(selector) ~= "dgs-dxselector" then error(dgsGenAsrt(selector,"dgsSelectorGetItemFont",1,"dgs-dxselector")) end
	local iData = dgsElementData[selector].itemData
	local iLen = #iData
	local iIsNum = type(i) == "number"
	local iNInRange = iIsNum and not (i>=1 and i<=iLen)
	if not (iIsNum and not iNInRange) then error(dgsGenAsrt(i,"dgsSelectorGetItemFont",2,"number","1~"..iLen,iNInRange and "Out Of Range")) end
	local i = i-i%1
	return iData[i][7]
end

function dgsSelectorSetItemTextSize(selector,i,sizeX,sizeY)
	if dgsGetType(selector) ~= "dgs-dxselector" then error(dgsGenAsrt(selector,"dgsSelectorSetItemTextSize",1,"dgs-dxselector")) end
	local iData = dgsElementData[selector].itemData
	local iLen = #iData
	local iIsNum = type(i) == "number"
	local iNInRange = iIsNum and not (i>=1 and i<=iLen)
	if not (iIsNum and not iNInRange) then error(dgsGenAsrt(i,"dgsSelectorSetItemTextSize",2,"number","1~"..iLen,iNInRange and "Out Of Range")) end
	if not (type(sizeX) == "number") then error(dgsGenAsrt(sizeX,"dgsSelectorSetItemTextSize",3,"number")) end
	local i = i-i%1
	iData[i][5] = sizeX
	iData[i][6] = sizeY or sizeX
	return true
end

function dgsSelectorGetItemTextSize(selector,i)
	if dgsGetType(selector) ~= "dgs-dxselector" then error(dgsGenAsrt(selector,"dgsSelectorGetItemTextSize",1,"dgs-dxselector")) end
	local iData = dgsElementData[selector].itemData
	local iLen = #iData
	local iIsNum = type(i) == "number"
	local iNInRange = iIsNum and not (i>=1 and i<=iLen)
	if not (iIsNum and not iNInRange) then error(dgsGenAsrt(i,"dgsSelectorGetItemTextSize",2,"number","1~"..iLen,iNInRange and "Out Of Range")) end
	local i = i-i%1
	return iData[i][5],iData[i][6]
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
	local i = i-i%1
	iData[i][2] = {alignX,alignY}
	return true
end

function dgsSelectorGetItemAlignment(selector,i)
	if dgsGetType(selector) ~= "dgs-dxselector" then error(dgsGenAsrt(selector,"dgsSelectorGetItemAlignment",1,"dgs-dxselector")) end
	local iData = dgsElementData[selector].itemData
	local iLen = #iData
	local iIsNum = type(i) == "number"
	local iNInRange = iIsNum and not (i>=1 and i<=iLen)
	if not (iIsNum and not iNInRange) then error(dgsGenAsrt(i,"dgsSelectorGetItemAlignment",2,"number","1~"..iLen,iNInRange and "Out Of Range")) end
	local i = i-i%1
	return unpack(iData[i][2])
end

function dgsSelectorSetItemImage(selector,i,image,color,offx,offy,w,h,relative)
	if dgsGetType(selector) ~= "dgs-dxselector" then error(dgsGenAsrt(selector,"dgsSelectorSetItemImage",1,"dgs-dxselector")) end
	local iData = dgsElementData[selector].itemData
	local iLen = #iData
	local iIsNum = type(i) == "number"
	local iNInRange = iIsNum and not (i>=1 and i<=iLen)
	if not (iIsNum and not iNInRange) then error(dgsGenAsrt(i,"dgsSelectorSetItemImage",2,"number","1~"..iLen,iNInRange and "Out Of Range")) end
	local i = i-i%1
	local imageData,size = iData[i][10] or {},dgsElementData[selector].absSize
	imageData[1] = image or imageData[1]
	imageData[2] = color or imageData[2] or white
	imageData[3] = offx or imageData[3] or 0
	imageData[4] = offy or imageData[4] or 0
	imageData[5] = w or imageData[5] or relative and 1 or size[1]
	imageData[6] = h or imageData[6] or relative and 1 or size[2]
	imageData[7] = relative or false
	iData[i][10] = imageData
end

function dgsSelectorGetItemImage(selector,i)
	if dgsGetType(selector) ~= "dgs-dxselector" then error(dgsGenAsrt(selector,"dgsSelectorGetItemImage",1,"dgs-dxselector")) end
	local iData = dgsElementData[selector].itemData
	local iLen = #iData
	local iIsNum = type(i) == "number"
	local iNInRange = iIsNum and not (i>=1 and i<=iLen)
	if not (iIsNum and not iNInRange) then error(dgsGenAsrt(i,"dgsSelectorGetItemImage",2,"number","1~"..iLen,iNInRange and "Out Of Range")) end
	local i = i-i%1
	return unpack(iData[i][9] or {})
end

function dgsSelectorRemoveItemImage(selector,i)
	if dgsGetType(selector) ~= "dgs-dxselector" then error(dgsGenAsrt(selector,"dgsSelectorRemoveItemImage",1,"dgs-dxselector")) end
	local iData = dgsElementData[selector].itemData
	local iLen = #iData
	local iIsNum = type(i) == "number"
	local iNInRange = iIsNum and not (i>=1 and i<=iLen)
	if not (iIsNum and not iNInRange) then error(dgsGenAsrt(i,"dgsSelectorRemoveItemImage",2,"number","1~"..iLen,iNInRange and "Out Of Range")) end
	local i = i-i%1
	iData[i][9] = nil
	return true
end

----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxselector"] = function(source,x,y,w,h,mx,my,cx,cy,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt)
	if MouseData.hit == source and MouseData.focused == source then
		MouseData.topScrollable = source
	end
	local itemData = eleData.itemData
	local selector = eleData.selectorText
	local alignment = eleData.alignment
	local font = eleData.font
	local colorcoded = eleData.colorcoded
	local placeHolder = eleData.placeHolder
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
	if MouseData.entered == source then
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
			dxDrawImage(x,selectorStartY,selectorSizeX,selectorSizeY,selectorImageLeft,0,0,0,applyColorAlpha(selectorImageColorLeft,parentAlpha),isPostGUI,rndtgt)
		else
			dxDrawRectangle(x,selectorStartY,selectorSizeX,selectorSizeY,applyColorAlpha(selectorImageColorLeft,parentAlpha),isPostGUI)
		end
	end
	if selectorImageColorRight then
		if selectorImageRight then
			dxDrawImage(x+w-selectorSizeX,selectorStartY,selectorSizeX,selectorSizeY,selectorImageRight,0,0,0,applyColorAlpha(selectorImageColorRight,parentAlpha),isPostGUI,rndtgt)
		else
			dxDrawRectangle(x+w-selectorSizeX,selectorStartY,selectorSizeX,selectorSizeY,applyColorAlpha(selectorImageColorRight,parentAlpha),isPostGUI)
		end
	end
	local renderItem = itemData[eleData.select]
	if eleData.select ~= -1 and renderItem then
		local imageData = renderItem[10]
		if imageData then
			local imageX = x+(imageData[7] and imageData[3]*w or imageData[3])
			local imageY = y+(imageData[7] and imageData[4]*h or imageData[4])
			local imageW = imageData[7] and imageData[5]*w or imageData[5]
			local imageH = imageData[7] and imageData[6]*h or imageData[6]
			if isElement(imageData[1]) then
				dxDrawImage(imageX,imageY,imageW,imageH,imageData[1],0,0,0,applyColorAlpha(imageData[2],parentAlpha),isPostGUI)
			else
				dxDrawRectangle(imageX,imageY,imageW,imageH,applyColorAlpha(imageData[2],parentAlpha),isPostGUI)
			end
		end
		local itemTextColor = type(renderItem[3]) == "table" and renderItem[3][selectorTextColors[2]] or renderItem[3]
		dxDrawText(renderItem[1],x+selectorSizeX,y,x+w-selectorSizeX,y+h,applyColorAlpha(itemTextColor,parentAlpha),renderItem[5],renderItem[6],renderItem[7],renderItem[2][1],renderItem[2][2],false,false,isPostGUI,renderItem[4])
	else
		local itemTextColor = type(itemTextColorDef) == "table" and itemTextColorDef[selectorTextColors[2]] or itemTextColorDef
		dxDrawText(placeHolder,x+selectorSizeX,y,x+w-selectorSizeX,y+h,applyColorAlpha(itemTextColor,parentAlpha),itemTextSizeDef[1],itemTextSizeDef[2],font,alignment[1],alignment[2],false,false,isPostGUI,colorcoded)
	end
	dxDrawText(selector[1],x,selectorStartY,x+selectorSizeX,selectorEndY,applyColorAlpha(selectorTextColorLeft,parentAlpha),selectorTextSize[1],selectorTextSize[2],font,alignment[1],alignment[2],false,false,isPostGUI,colorcoded)
	dxDrawText(selector[2],x+w-selectorSizeX,selectorStartY,x+w,selectorEndY,applyColorAlpha(selectorTextColorRight,parentAlpha),selectorTextSize[1],selectorTextSize[2],font,alignment[1],alignment[2],false,false,isPostGUI,colorcoded)
	return rndtgt,false,mx,my,0,0
end