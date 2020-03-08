function dgsCreateArrowList(x,y,sx,sy,relative,parent,itemHeight,itemTextColor,scalex,scaley,bgColor,bgImage,idefcolor,ihovcolor,idefimage,ihovimage)
	assert(tonumber(x),"Bad argument @dgsCreateArrowList at argument 1, expect number got "..type(x))
	assert(tonumber(y),"Bad argument @dgsCreateArrowList at argument 2, expect number got "..type(y))
	assert(tonumber(sx),"Bad argument @dgsCreateArrowList at argument 3, expect number got "..type(sx))
	assert(tonumber(sy),"Bad argument @dgsCreateArrowList at argument 4, expect number got "..type(sy))
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"Bad argument @dgsCreateGridList at argument 6, expect dgs-dxgui got "..dgsGetType(parent))
	end
	local arrowlist = createElement("dgs-dxarrowlist")
	local _x = dgsIsDxElement(parent) and dgsSetParent(arrowlist,parent,true,true) or table.insert(CenterFatherTable,arrowlist)
	dgsSetType(arrowlist,"dgs-dxarrowlist")
	dgsSetData(arrowlist,"renderBuffer",{})
	dgsSetData(arrowlist,"mode",false)
	dgsSetData(arrowlist,"font",styleSettings.arrowlist.font or systemFont)
	dgsSetData(arrowlist,"bgColor",styleSettings.arrowlist.bgColor)
	dgsSetData(arrowlist,"bgImage",bgImage or dgsCreateTextureFromStyle(styleSettings.arrowlist.bgImage0))
	local scbThick = styleSettings.arrowlist.scrollBarThick
	dgsSetData(arrowlist,"scrollBarThick",scbThick,true)
	dgsSetData(arrowlist,"itemData",{})
	dgsSetData(arrowlist,"leading",styleSettings.arrowlist.leading)
	dgsSetData(arrowlist,"itemHeight",itemHeight or styleSettings.arrowlist.itemHeight)
	dgsSetData(arrowlist,"itemColor",{idefcolor or styleSettings.arrowlist.itemColor[1],ihovcolor or styleSettings.arrowlist.itemColor[2]})
	dgsSetData(arrowlist,"itemImage",{idefimage,ihovimage})
	dgsSetData(arrowlist,"itemMoveOffset",0)
	dgsSetData(arrowlist,"itemTextShadow",nil)
	dgsSetData(arrowlist,"itemTextColor",itemTextColor or styleSettings.arrowlist.itemTextColor)
	local textSizeX,textSizeY = tonumber(scalex) or styleSettings.arrowlist.itemTextSize[1], tonumber(scaley) or styleSettings.arrowlist.itemTextSize[2]
	dgsSetData(arrowlist,"itemTextSize",{textSizeX,textSizeY})
	dgsSetData(arrowlist,"itemTextOffset",styleSettings.arrowlist.itemTextOffset)
	dgsSetData(arrowlist,"itemTextAlignment","left")
	dgsSetData(arrowlist,"selectorAlignment","right")
	dgsSetData(arrowlist,"selectorWidth",nil)	--Auto Config [Text Width]
	dgsSetData(arrowlist,"selectorDistance",styleSettings.arrowlist.selectorDistance)	-- <(Distance)Text(Distance)>
	dgsSetData(arrowlist,"selectorOffset",styleSettings.arrowlist.selectorOffset)
	dgsSetData(arrowlist,"selectorShadow",nil)
	dgsSetData(arrowlist,"selectorSize",styleSettings.arrowlist.selectorSize)
	dgsSetData(arrowlist,"selectorTextColor",styleSettings.arrowlist.selectorTextColor)
	dgsSetData(arrowlist,"selectorColor",styleSettings.arrowlist.selectorColor)
	dgsSetData(arrowlist,"scrollSize",60)	--60 pixels
	dgsAttachToTranslation(arrowlist,resourceTranslation[sourceResource or getThisResource()])
	dgsAttachToTranslation(arrowlist,resourceTranslation[sourceResource or getThisResource()])
	dgsSetData(arrowlist,"configNextFrame",false)
	calculateGuiPositionSize(arrowlist,x,y,relative,sx,sy,relative,true)
	local aSize = dgsElementData[arrowlist].absSize
	local abx,aby = aSize[1],aSize[2]
	local rndtgt = dxCreateRenderTarget(abx,aby,true)
	if not isElement(rndtgt) then
		local videoMemory = dxGetStatus().VideoMemoryFreeForMTA
		outputDebugString("Failed to create render target for dgs-dxarrowlist [Expected:"..(0.0000076*abx*aby).."MB/Free:"..videoMemory.."MB]",2)
	end
	local scrollbar = dgsCreateScrollBar(abx-scbThick,0,scbThick,aby,false,false,arrowlist)
	dgsSetData(arrowlist,"renderTarget",rndtgt)
	dgsSetData(scrollbar,"length",{0,true})
	addEventHandler("onDgsElementScroll",scrollbar,checkALScrollBar,false)
	dgsSetData(arrowlist,"scrollbar",scrollbar)
	dgsSetVisible(scrollbar,false)
	triggerEvent("onDgsCreate",arrowlist,sourceResource)
	return arrowlist
end

--[[
Item Data Structure:
itemData = {
	 1	  2           3         4    5              6               7
	{text,range start,range end,step,translateTable,currentSelected,configTable},
	{text,range start,range end,step,translateTable,currentSelected,configTable},
	{text,range start,range end,step,translateTable,currentSelected,configTable},
	{text,range start,range end,step,translateTable,currentSelected,configTable},
	...
}

translateTable = {
	[1] = text1,
	[2] = text2,
	[3] = text3,
	...
}


]]
function dgsArrowListAddItem(arrowlist,text,rangeStart,rangeEnd,step,translationTable,pos)
	assert(dgsGetType(arrowlist) == "dgs-dxarrowlist","Bad argument @dgsArrowListAddItem at argument 1, expect dgs-dxarrowlist got "..dgsGetType(arrowlist))
	assert(tonumber(rangeStart),"Bad argument @dgsArrowListAddItem at argument 3, expect number got "..type(rangeStart))
	assert(tonumber(rangeEnd),"Bad argument @dgsArrowListAddItem at argument 4, expect number got "..type(rangeEnd))
	step = tonumber(step) or 1
	assert(step > 0,"Bad argument @dgsArrowListAddItem at argument 5, expect number got "..type(rangeEnd))
	local eleData = dgsElementData[arrowlist]
	local itemData = eleData.itemData
	local itemCount = #itemData+1
	-------------Config Table
	local configTable = {
		[1] = eleData.itemColor,
		[2] = eleData.itemImage,
		[3] = eleData.itemTextColor,
		[4] = eleData.itemTextSize,
		[5] = eleData.font,		--item text font
		[6] = eleData.itemTextAlignment,
		[7] = eleData.itemTextOffset,
		[8] = eleData.itemTextShadow, -- include < and >
		
		[9] = eleData.selectorColor,	-- < and > only
		[10] = eleData.selectorSize,	-- exclude < and >
		[11] = eleData.font,		--selector font ( exclude < and > )
		[12] = eleData.selectorAlignment,  -- include < and >
		[13] = eleData.selectorOffset,  -- include < and >
		[14] = eleData.selectorWidth,
		[15] = eleData.selectorShadow, -- exclude < and > 
		[16] = eleData.selectorDistance,
		[17] = eleData.selectorTextColor,
	}
	-------------
	local tab = {}
	local size = eleData.absSize
	if type(text) == "table" then
		tab._translationText = text
		text = dgsTranslate(arrowlist,text,sourceResource)
	end
	tab[1] = tostring(text)
	tab[2] = rangeStart
	tab[3] = rangeEnd
	tab[4] = step
	tab[5] = translationTable
	tab[6] = rangeStart			--Current Selected
	tab[7] = configTable
	table.insert(itemData,pos or itemCount,tab)
	dgsSetData(arrowlist,"configNextFrame",true)
	return pos or itemCount
end

function dgsArrowListRemoveItem(arrowlist,index)
	assert(dgsGetType(arrowlist) == "dgs-dxarrowlist","Bad argument @dgsArrowListRemoveItem at argument 1, expect dgs-dxarrowlist got "..dgsGetType(arrowlist))
	assert(tonumber(index),"Bad argument @dgsArrowListRemoveItem at argument 2, expect number got "..type(index))
	local itemData = dgsElementData[arrowlist].itemData
	if itemData and itemData[index] then
		table.remove(itemData,index)
		return true
	end
	dgsSetData(arrowlist,"configNextFrame",true)
	return false
end

function dgsArrowListSetItemText(arrowlist,index,text)
	assert(dgsGetType(arrowlist) == "dgs-dxarrowlist","Bad argument @dgsArrowListSetItemText at argument 1, expect dgs-dxarrowlist got "..dgsGetType(arrowlist))
	assert(tonumber(index),"Bad argument @dgsArrowListSetItemText at argument 2, expect number got "..type(index))
	local itemData = dgsElementData[arrowlist].itemData
	if itemData and itemData[index] then
		if type(text) == "table" then
			itemData[index]._translationText = text
			text = dgsTranslate(arrowlist,text,sourceResource)
		else
			itemData[index]._translationText = nil
		end
		itemData[index][1] = text
		return true
	end
	return false
end

function dgsArrowListGetItemText(arrowlist,index)
	assert(dgsGetType(arrowlist) == "dgs-dxarrowlist","Bad argument @dgsArrowListGetItemText at argument 1, expect dgs-dxarrowlist got "..dgsGetType(arrowlist))
	assert(tonumber(index),"Bad argument @dgsArrowListGetItemText at argument 2, expect number got "..type(index))
	local itemData = dgsElementData[arrowlist].itemData
	if itemData and itemData[index] then
		return itemData[index][1]
	end
	return false
end

function dgsArrowListGetItemValue(arrowlist,index)
	assert(dgsGetType(arrowlist) == "dgs-dxarrowlist","Bad argument @dgsArrowListGetItemValue at argument 1, expect dgs-dxarrowlist got "..dgsGetType(arrowlist))
	assert(tonumber(index),"Bad argument @dgsArrowListGetItemValue at argument 2, expect number got "..type(index))
	local itemData = dgsElementData[arrowlist].itemData
	if itemData and itemData[index] then
		return itemData[index][6]
	end
	return false
end

function dgsArrowListSetItemValue(arrowlist,index,value)
	assert(dgsGetType(arrowlist) == "dgs-dxarrowlist","Bad argument @dgsArrowListSetItemValue at argument 1, expect dgs-dxarrowlist got "..dgsGetType(arrowlist))
	assert(tonumber(index),"Bad argument @dgsArrowListSetItemValue at argument 2, expect number got "..type(index))
	assert(tonumber(value),"Bad argument @dgsArrowListSetItemValue at argument 3, expect number got "..type(value))
	local itemData = dgsElementData[arrowlist].itemData
	if itemData and itemData[index] then
		itemData[index][6] = value
	end
	return false
end

function dgsArrowListGetItemRange(arrowlist,index)
	assert(dgsGetType(arrowlist) == "dgs-dxarrowlist","Bad argument @dgsArrowListGetItemRange at argument 1, expect dgs-dxarrowlist got "..dgsGetType(arrowlist))
	assert(tonumber(index),"Bad argument @dgsArrowListGetItemRange at argument 2, expect number got "..type(index))
	local itemData = dgsElementData[arrowlist].itemData
	if itemData and itemData[index] then
		return itemData[index][2],itemData[index][3]
	end
	return false
end

function dgsArrowListSetItemRange(arrowlist,index,rangeStart,rangeEnd)
	assert(dgsGetType(arrowlist) == "dgs-dxarrowlist","Bad argument @dgsArrowListSetItemRange at argument 1, expect dgs-dxarrowlist got "..dgsGetType(arrowlist))
	assert(tonumber(index),"Bad argument @dgsArrowListSetItemRange at argument 2, expect number got "..type(index))
	assert(tonumber(rangeStart),"Bad argument @dgsArrowListSetItemRange at argument 3, expect number got "..type(rangeStart))
	assert(tonumber(rangeEnd),"Bad argument @dgsArrowListSetItemRange at argument 4, expect number got "..type(rangeEnd))
	assert(rangeStart <= rangeEnd,"Bad argument @dgsArrowListSetItemRange at argument 3 and 4, range start should be less than or equal to range end, got rangeStart:"..rangeStart..",rangeEnd:"..rangeEnd)
	local itemData = dgsElementData[arrowlist].itemData
	if itemData and itemData[index] then
		itemData[index][2] = rangeStart
		itemData[index][3] = rangeEnd
		return true
	end
	return false
end

function dgsArrowListGetItemTranslationTable(arrowlist,index)
	assert(dgsGetType(arrowlist) == "dgs-dxarrowlist","Bad argument @dgsArrowListGetItemTranslationTable at argument 1, expect dgs-dxarrowlist got "..dgsGetType(arrowlist))
	assert(tonumber(index),"Bad argument @dgsArrowListGetItemTranslationTable at argument 2, expect number got "..type(index))
	local itemData = dgsElementData[arrowlist].itemData
	if itemData and itemData[index] then
		return itemData[index][5]
	end
	return false
end

function dgsArrowListSetItemTranslationTable(arrowlist,index,translationTable)
	assert(dgsGetType(arrowlist) == "dgs-dxarrowlist","Bad argument @dgsArrowListSetItemTranslationTable at argument 1, expect dgs-dxarrowlist got "..dgsGetType(arrowlist))
	assert(tonumber(index),"Bad argument @dgsArrowListSetItemTranslationTable at argument 2, expect number got "..type(index))
	assert(type(translationTable) == "table","Bad argument @dgsArrowListSetItemTranslationTable at argument 3, expect table got "..type(translationTable))
	local itemData = dgsElementData[arrowlist].itemData
	if itemData and itemData[index] then
		itemData[index][5] = translationTable
		return true
	end
	return false
end

function dgsArrowListSetItemStep(arrowlist,index,step)
	assert(dgsGetType(arrowlist) == "dgs-dxarrowlist","Bad argument @dgsArrowListSetItemStep at argument 1, expect dgs-dxarrowlist got "..dgsGetType(arrowlist))
	assert(tonumber(index),"Bad argument @dgsArrowListSetItemStep at argument 2, expect number got "..type(index))
	assert(tonumber(step),"Bad argument @dgsArrowListSetItemStep at argument 3, expect number got "..type(step))
	assert(step >= 0,"Bad argument @dgsArrowListSetItemStep at argument 3, step should be greater than or equal to 0, got "..step)
	local itemData = dgsElementData[arrowlist].itemData
	if itemData and itemData[index] then
		itemData[index][4] = step
	end
	return false
end

function dgsArrowListGetItemStep(arrowlist,index)
	assert(dgsGetType(arrowlist) == "dgs-dxarrowlist","Bad argument @dgsArrowListGetItemStep at argument 1, expect dgs-dxarrowlist got "..dgsGetType(arrowlist))
	assert(tonumber(index),"Bad argument @dgsArrowListGetItemStep at argument 2, expect number got "..type(index))
	local itemData = dgsElementData[arrowlist].itemData
	if itemData and itemData[index] then
		return itemData[index][4]
	end
	return false
end

function dgsArrowListGetItemTranslatedValue(arrowlist,index)
	assert(dgsGetType(arrowlist) == "dgs-dxarrowlist","Bad argument @dgsArrowListGetItemTranslatedValue at argument 1, expect dgs-dxarrowlist got "..dgsGetType(arrowlist))
	assert(tonumber(index),"Bad argument @dgsArrowListGetItemTranslatedValue at argument 2, expect number got "..type(index))
	local itemData = dgsElementData[arrowlist].itemData
	if itemData and itemData[index] then
		local translationTable = itemData[index][5]
		return translationTable[ itemData[index][6] ] or itemData[index][6]
	end
	return false
end

function dgsArrowListClear(arrowlist)
	assert(dgsGetType(arrowlist)=="dgs-dxarrowlist","Bad argument @dgsArrowListClear at argument 1, expect dgs-dxarrowlist got "..dgsGetType(arrowlist))
	dgsSetData(arrowlist,"itemData",{})
	dgsSetData(arrowlist,"configNextFrame",true)
end

function checkALScrollBar(scb,new,old)
	local parent = dgsGetParent(source)
	if dgsGetType(parent) == "dgs-dxarrowlist" then
		local scrollBar = dgsElementData[parent].scrollbar
		local sx,sy = dgsElementData[parent].absSize[1],dgsElementData[parent].absSize[2]
		if source == scrollBar then
			local itemCount = #dgsElementData[parent].itemData
			local itemLength = itemCount*dgsElementData[parent].itemHeight+(itemCount-1)*dgsElementData[parent].leading
			local temp = -new*(itemLength-sy)/100
			local temp = dgsElementData[parent].scrollFloor and math.floor(temp) or temp 
			dgsSetData(parent,"itemMoveOffset",temp)
		end
	end
end

function configArrowList(arrowlist)
	local size = dgsElementData[arrowlist].absSize
	local itemHeight = dgsElementData[arrowlist].itemHeight
	local itemCount = #dgsElementData[arrowlist].itemData
	local leading = dgsElementData[arrowlist].leading
	local itemLength = (itemHeight+leading)*itemCount
	local scrollbar = dgsElementData[arrowlist].scrollbar
	local scrollBarVisible = itemLength-leading > size[2]
	dgsSetVisible(scrollbar,scrollBarVisible)
	local scbThick = scrollBarVisible and dgsElementData[arrowlist].scrollBarThick or 0
	local rendertarget = dgsElementData[arrowlist].renderTarget
	if isElement(rendertarget) then
		destroyElement(rendertarget)
	end
	local rendertarget = dxCreateRenderTarget(size[1]-scbThick,size[2],true)
	if not isElement(rendertarget) then
		local videoMemory = dxGetStatus().VideoMemoryFreeForMTA
		outputDebugString("Failed to create render target for dgs-dxarrowlist [Expected:"..(0.0000076*(size[1]-scbThick)*size[2]).."MB/Free:"..videoMemory.."MB]",2)
	end

	dgsSetData(arrowlist,"renderTarget",rendertarget)
	dgsSetPosition(scrollbar,size[1]-dgsElementData[arrowlist].scrollBarThick,0,false)
	dgsSetSize(scrollbar,scbThick,size[2],false)
		
	local higLen = 1-(itemLength-size[2])/itemLength
	higLen = higLen >= 0.95 and 0.95 or higLen
	dgsSetData(scrollbar,"length",{higLen,true})
	local verticalScrollSize = dgsElementData[arrowlist].scrollSize/(itemLength-size[2])
	dgsSetData(scrollbar,"multiplier",{verticalScrollSize,true})
	
end
