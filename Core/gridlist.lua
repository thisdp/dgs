dgsLogLuaMemory()
dgsRegisterType("dgs-dxgridlist","dgsBasic","dgsType2D")
dgsRegisterProperties('dgs-dxgridlist',{
	autoSort = 				{	PArg.Bool	},
	backgroundOffset = 		{	PArg.Number	},
	bgColor = 				{	PArg.Color	},
	bgImage = 				{	PArg.Number	},
	clip = 					{	PArg.Bool 	},
	columnColor = 			{	PArg.Color	},
	columnHeight = 			{	PArg.Number	},
	columnImage = 			{	PArg.Material	},
	columnOffset = 			{	PArg.Number	},
	columnRelative = 		{	PArg.Bool	},
	columnShadow = 			{	{ PArg.Number, PArg.Number, PArg.Color, PArg.Number+PArg.Bool+PArg.Nil, PArg.Font+PArg.Nil }, PArg.Nil	},
	columnTextColor = 		{	PArg.Color	},
	columnTextPosOffset = 	{	{ PArg.Number, PArg.Number }	},
	columnTextSize = 		{	{ PArg.Number, PArg.Number }	},
	columnWordBreak = 		{	PArg.Bool	},
	colorCoded = 			{	PArg.Bool	},
	defaultColumnOffset = 	{	PArg.Number	},
	defaultSortFunctions = 	{	{ PArg.String, PArg.String }	},
	defaultSortIcons = 		{	{ PArg.String, PArg.String }	},
	enableNavigation = 		{	PArg.Bool	},
	font = 					{	PArg.Font+PArg.String	},
	leading = 				{	PArg.Number	},
	multiSelection = 		{	PArg.Bool	},
	mouseSelectButton = 	{	{ PArg.Bool, PArg.Bool, PArg.Bool }	},
	moveHardness = 			{	{ PArg.Number, PArg.Number }	},
	rowColorTemplate =		{	PArg.Table },
	rowColor = 				{	{ PArg.Color, PArg.Color,PArg.Color }	},
	rowHeight = 			{	PArg.Number	},
	rowImage = 				{	{ PArg.Material, PArg.Material, PArg.Material }	},
	rowMoveOffset= 			{	PArg.Number	},
	rowShadow = 			{	{ PArg.Number, PArg.Number, PArg.Color, PArg.Number+PArg.Bool+PArg.Nil, PArg.Font+PArg.Nil }, PArg.Nil	},
	rowTextColor = 			{	{ PArg.Color, PArg.Color,PArg.Color }, PArg.Color	},
	rowTextPosOffset = 		{	{ PArg.Number, PArg.Number }	},
	rowTextSize = 			{	{ PArg.Number, PArg.Number }	},
	rowWordBreak = 			{	PArg.Bool	},
	rowImageStyle = 		{	PArg.Nil+PArg.Number },
	scrollBarState = 		{	{ PArg.Bool+PArg.Nil, PArg.Bool+PArg.Nil }	},
	scrollBarThick = 		{	PArg.Number	},
	scrollBarLength = 		{	{ { PArg.Number, PArg.Bool }, { PArg.Number, PArg.Bool } }, { PArg.Nil, PArg.Nil }	},
	scrollSize = 			{	PArg.Number	},
	sectionColumnOffset = 	{	PArg.Number	},
	sectionFont = 			{	PArg.Font+PArg.String	},
	selectionMode = 		{	PArg.Number	},
	selectedColumn = 		{	PArg.Number	},
	sortColumn = 			{	PArg.Number+PArg.Nil	},
	sortEnabled = 			{	PArg.Bool	},
})
--[[Grid List Index]]
glCol_text = 1
glCol_width = 2
glCol_widthSum = 3
glCol_textAlignment = 4
glCol_textColor = 5
glCol_textColorCoded = 6
glCol_textScaleX = 7
glCol_textScaleY = 8
glCol_textFont = 9

glRow_isSection = -5
glRow_identity = -4
glRow_bgImage = -3
glRow_hoverable = -2
glRow_selectable = -1
glRow_bgColor = 0

glItem_text = 1
glItem_textColor = 2
glItem_textColorCoded = 3
glItem_textScaleX = 4
glItem_textScaleY = 5
glItem_textFont = 6
glItem_image = 7
glItem_hoverable = 8
glItem_selectable = 9
glItem_attachedElement = 10
glItem_textAlignment = 11
glItem_textOffset = 12
glItem_bgColor = 13
glItem_bgImage = 14
glItem_isSection = 15
glItem_columnOffset = 16

glItemImage_image = 1
glItemImage_imageColor = 2
glItemImage_imageX = 3
glItemImage_imageY = 4
glItemImage_imageW = 5
glItemImage_imageH = 6
glItemImage_imageRelative = 7

--
local loadstring = loadstring
--Dx Functions
local dxDrawImage = dxDrawImage
local dgsDrawText = dgsDrawText
local dxSetRenderTarget = dxSetRenderTarget
local dxGetTextWidth = dxGetTextWidth
local dxSetBlendMode = dxSetBlendMode
local dgsCreateRenderTarget = dgsCreateRenderTarget
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
local dgsTriggerEvent = dgsTriggerEvent
local createElement = createElement
local tonumber = tonumber
local loadstring = loadstring
local type = type
local mathLerp = math.lerp
local tableSort = table.sort
local tableInsert = table.insert
local tableRemove = table.remove
local tableRemoveItemFromArray = table.removeItemFromArray
local utf8Len = utf8.len
gridlistSortFunctions = {}
self = false
mouseButtonOrder = {
	left=1,
	middle=2,
	right=3,
}
--[[
Selection Mode
1-> Row Selection
2-> Column Selection
3-> Cell Selection
]]
function dgsCreateGridList(...)
	local sRes = sourceResource or resource
	local x,y,w,h,relative,parent,columnHeight,bgColor,columnTextColor,columnColor,cColorR,hColorR,sColorR,bgImage,columnImage,nImageR,hImageR,sImageR
	if select("#",...) == 1 and type(select(1,...)) == "table" then
		local argTable = ...
		x = argTable.x or argTable[1]
		y = argTable.y or argTable[2]
		w = argTable.width or argTable.w or argTable[3]
		h = argTable.height or argTable.h or argTable[4]
		relative = argTable.relative or argTable.rlt or argTable[5]
		parent = argTable.parent or argTable.p or argTable[6]
		columnHeight = argTable.columnHeight or argTable[7]
		bgColor = argTable.bgColor or argTable[8]
		columnTextColor = argTable.columnTextColor or argTable[9]
		columnColor = argTable.columnColor or argTable[10]
		cColorR = argTable.normalRowColor or argTable.cColorR or argTable[11]
		hColorR = argTable.hoveringRowColor or argTable.hColorR or argTable[12]
		sColorR = argTable.selectedRowColor or argTable.sColorR or argTable[13]
		bgImage = argTable.bgImage or argTable[14]
		columnImage = argTable.columnImage or argTable[15]
		nImageR = argTable.normalRowImage or argTable.nImageR or argTable[16]
		hImageR = argTable.hoveringRowImage or argTable.hImageR or argTable[17]
		sImageR = argTable.selectedRowImage or argTable.sImageR or argTable[18]
	else
		x,y,w,h,relative,parent,columnHeight,bgColor,columnTextColor,columnColor,cColorR,hColorR,sColorR,bgImage,columnImage,nImageR,hImageR,sImageR = ...
	end
	if not(type(x) == "number") then error(dgsGenAsrt(x,"dgsCreateGridList",1,"number")) end
	if not(type(y) == "number") then error(dgsGenAsrt(y,"dgsCreateGridList",2,"number")) end
	if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsCreateGridList",3,"number")) end
	if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsCreateGridList",4,"number")) end
					
	local res = sRes ~= resource and sRes or "global"
	local style = styleManager.styles[res]
	local using = style.using
	style = style.loaded[using]
	local systemFont = style.systemFontElement
	
	style = style.gridlist
	local relative = relative or false
	local scbThick = style.scrollBarThick
	local columnHeight = tonumber(columnHeight) or style.columnHeight
	local cColorR = cColorR or style.rowColor[1]
	local hColorR = hColorR or style.rowColor[2]
	local sColorR = sColorR or style.rowColor[3]
	local nImageR = nImageR or dgsCreateTextureFromStyle(using,res,style.rowImage[1])
	local hImageR = hImageR or dgsCreateTextureFromStyle(using,res,style.rowImage[2]) or nImageR
	local sImageR = sImageR or dgsCreateTextureFromStyle(using,res,style.rowImage[3]) or nImageR
	local gridlist = createElement("dgs-dxgridlist")
	dgsSetType(gridlist,"dgs-dxgridlist")
	dgsElementData[gridlist] = {
		autoSort = true,
		backgroundOffset = style.backgroundOffset,
		bgImage = bgImage or dgsCreateTextureFromStyle(using,res,style.bgImage),
		bgColor = bgColor or style.bgColor,
		colorCoded = false,
		clip = true,
		columnWordBreak = nil,
		columnColor = columnColor or style.columnColor,
		columnData = {},
		columnHeight = columnHeight,
		columnImage = columnImage or dgsCreateTextureFromStyle(using,res,style.columnImage),
		columnMoveOffset = 0,
		columnMoveOffsetTemp = 0,
		columnTextColor = columnTextColor or style.columnTextColor,
		columnTextPosOffset = {0,0},
		columnTextSize = style.columnTextSize,
		columnOffset = style.columnOffset,
		columnRelative = true,
		columnShadow = nil,
		defaultColumnOffset = style.defaultColumnOffset,
		enableNavigation = true,
		font = style.font or systemFont,
		guiCompat = false,
		itemClick = {},
		lastSelectedItem = {1,1},
		leading = 0,
		mouseSelectButton = {true,false,false},
		moveHardness = {0.1,0.9},
		moveType = 0,	--0 for wheel, 1 For scroll bar
		multiSelection = false,
		nextRenderSort = false,
		preSelect = {-1,-1},
		preSelectLastFrame = {-1,-1},
		rowColor = {cColorR,hColorR,sColorR},	--Normal/Hover/Selected
		rowData = {},
		rowHeight = style.rowHeight,	--_RowHeight
		rowImage = {nImageR,hImageR,sImageR},	--Normal/Hover/Selected
		rowMoveOffset = 0,
		rowMoveOffsetTemp = 0,
		rowTextSize = style.rowTextSize,
		rowTextColor = style.rowTextColor,
		rowTextPosOffset = {0,0},
		rowSelect = {},
		rowShadow = nil,
		rowWordBreak = nil,
		rowShowUnclippedOnly = false,
		scrollBarThick = scbThick,
		scrollBarLength = {},
		scrollBarState = {nil,nil},
		scrollFloor = {false,false},--move offset ->int or float
		scrollSize = 60,			--60 pixels
		scrollBarCoverColumn = true,
		sectionColumnOffset = style.sectionColumnOffset,
		sectionFont = systemFont,
		selectedColumn = -1,
		selectionMode = 1,
		sortColumn = nil,
		sortEnabled = true,
		defaultSortFunctions = {"greaterLower","greaterUpper"},
		defaultSortIcons = {"▲","▼"},
		renderBuffer = {
			columnEndPos = {},
			columnPos = {},
			textBuffer = {},
			elementBuffer = {},
		},
	}
	dgsSetParent(gridlist,parent,true,true)
	dgsAttachToTranslation(gridlist,resourceTranslation[sRes or resource])
	dgsElementData[gridlist].configNextFrame = false
	calculateGuiPositionSize(gridlist,x,y,relative,w,h,relative,true)
	local absSize = dgsElementData[gridlist].absSize
	local scrollbar1 = dgsCreateScrollBar(absSize[1]-scbThick,0,scbThick,absSize[2]-scbThick,false,false,gridlist)
	dgsSetData(scrollbar1,"attachedToParent",gridlist)
	local scrollbar2 = dgsCreateScrollBar(0,absSize[2]-scbThick,absSize[1]-scbThick,scbThick,true,false,gridlist)
	dgsSetData(scrollbar2,"attachedToParent",gridlist)
	dgsSetVisible(scrollbar1,false)
	dgsSetVisible(scrollbar2,false)
	dgsSetData(scrollbar1,"length",{0,true})
	dgsSetData(scrollbar2,"length",{0,true})
	dgsSetData(scrollbar1,"multiplier",{1,false})
	dgsSetData(scrollbar2,"multiplier",{1,false})
	dgsSetData(scrollbar1,"minLength",10)
	dgsSetData(scrollbar2,"minLength",10)
	dgsAddEventHandler("onDgsElementScroll",scrollbar1,"checkGridListScrollBar",false)
	dgsAddEventHandler("onDgsElementScroll",scrollbar2,"checkGridListScrollBar",false)
	dgsSetData(gridlist,"scrollbars",{scrollbar1,scrollbar2})
	dgsSetData(gridlist,"FromTo",{1,0})
	dgsAddEventHandler("onDgsGridListSelect",gridlist,"dgsGridListCheckSelect",false)
	onDGSElementCreate(gridlist,sRes)
	dgsGridListRecreateRenderTarget(gridlist,true)
	return gridlist
end

function dgsGridListRecreateRenderTarget(gridlist,lateAlloc)
	local eleData = dgsElementData[gridlist]
	if isElement(eleData.columnRT) then destroyElement(eleData.columnRT) end
	if isElement(eleData.rowRT) then destroyElement(eleData.rowRT) end
	dgsSetData(gridlist,"columnRT",nil)
	dgsSetData(gridlist,"rowRT",nil)
	if lateAlloc then
		dgsSetData(gridlist,"retrieveRT",true)
	else
		local res = eleData.resource
		local columnRT,rowRT
		local w,h = eleData.absSize[1],eleData.absSize[2]
		local columnHeight = eleData.columnHeight
		local scbThick = eleData.scrollBarThick
		local scrollbar = eleData.scrollbars
		local scbThickV,scbThickH = dgsElementData[scrollbar[1]].visible and scbThick or 0,dgsElementData[scrollbar[2]].visible and scbThick or 0
		local relSizX,relSizY = w-scbThickV,h-scbThickH
		local rowShowRange = relSizY-columnHeight
		if relSizX*columnHeight ~= 0 then
			columnRT,err = dgsCreateRenderTarget(relSizX,columnHeight,true,gridlist,res)
			if columnRT ~= false then
				dgsAttachToAutoDestroy(columnRT,gridlist,-1)
			else
				outputDebugString(err,2)
			end
		end
		if relSizX*rowShowRange ~= 0 then
			rowRT,err = dgsCreateRenderTarget(relSizX,rowShowRange,true,gridlist,res)
			if rowRT ~= false then
				dgsAttachToAutoDestroy(rowRT,gridlist,-3)
			else
				outputDebugString(err,2)
			end
		end
		dgsSetData(gridlist,"columnRT",columnRT)
		dgsSetData(gridlist,"rowRT",rowRT)
		dgsSetData(gridlist,"retrieveRT",nil)
	end
end

function checkGridListScrollBar(scb,new,old)
	local gridlist = dgsGetParent(source)
	if dgsGetType(gridlist) == "dgs-dxgridlist" then
		local eleData = dgsElementData[gridlist]
		local scrollbars = eleData.scrollbars
		local scbThick = eleData.scrollBarThick
		if source == scrollbars[1] then
			local scbThickH = dgsElementData[scrollbars[2]].visible and scbThick or 0
			local rowLength = #eleData.rowData*(eleData.rowHeight+eleData.leading)--_RowHeight
			local temp = -new*(rowLength-eleData.absSize[2]+scbThickH+eleData.columnHeight)/100
			if temp <= 0 then
				local temp = eleData.scrollFloor[1] and temp-temp%1 or temp
				dgsSetData(gridlist,"rowMoveOffset",temp)
			end
			dgsTriggerEvent("onDgsElementScroll",gridlist,source,new,old)
		elseif source == scrollbars[2] then
			local scbThickV = dgsElementData[scrollbars[1]].visible and scbThick or 0
			local columnWidth = dgsGridListGetColumnAllWidth(gridlist,#eleData.columnData)
			local columnOffset = eleData.columnOffset
			local temp = -new*(columnWidth-eleData.absSize[1]+scbThickV+columnOffset)/100
			if temp <= 0 then
				local temp = eleData.scrollFloor[2] and temp-temp%1 or temp
				dgsSetData(gridlist,"columnMoveOffset",temp)
			end
			dgsTriggerEvent("onDgsElementScroll",gridlist,source,new,old)
		end
	end
end

function dgsGridListCheckSelect(rowOrTable,c,oldRowOrTable,oldColumn)
	local lastSelected = dgsElementData[source].lastSelectedItem
	if type(rowOrTable) == "table" then
		local r,c = next(rowOrTable)
		if r then
			local c = next(c)
			dgsSetData(source,"lastSelectedItem",{r,c})
		end
	else
		dgsSetData(source,"lastSelectedItem",{rowOrTable == -1 and lastSelected[1] or rowOrTable,c == -1 and lastSelected[2] or c})
	end
end

function dgsGridListSetSelectionMode(gridlist,mode)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetSelectionMode",1,"dgs-dxgridlist")) end
	if mode == 1 or mode == 2 or mode == 3 then
		return dgsSetData(gridlist,"selectionMode",mode)
	end
	return false
end

function dgsGridListGetSelectionMode(gridlist)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetSelectionMode",1,"dgs-dxgridlist")) end
	return dgsElementData[gridlist].selectionMode
end

function dgsGridListSetMultiSelectionEnabled(gridlist,multiSelection)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetMultiSelectionEnabled",1,"dgs-dxgridlist")) end
	return dgsSetData(gridlist,"multiSelection",multiSelection and true or false)
end

function dgsGridListGetMultiSelectionEnabled(gridlist)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetMultiSelectionEnabled",1,"dgs-dxgridlist")) end
	return dgsElementData[gridlist].multiSelection
end

function dgsGridListGetNavigationEnabled(gridlist)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetNavigationEnabled",1,"dgs-dxgridlist")) end
	return dgsElementData[gridlist].enableNavigation
end

function dgsGridListSetNavigationEnabled(gridlist,state)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetNavigationEnabled",1,"dgs-dxgridlist")) end
	return dgsSetData(gridlist,"enableNavigation",state)
end

function dgsGridListResetScrollBarPosition(gridlist,vertical,horizontal)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListResetScrollBarPosition",1,"dgs-dxgridlist")) end
	local scrollbars = dgsElementData[gridlist].scrollbars
	if not vertical then
		dgsScrollBarSetScrollPosition(scrollbars[1],0)
	end
	if not horizontal then
		dgsScrollBarSetScrollPosition(scrollbars[2],0)
	end
	return true
end

function dgsGridListGetScrollBar(gridlist)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetScrollBar",1,"dgs-dxgridlist")) end
	return dgsElementData[gridlist].scrollbars
end

function dgsGridListGetScrollPosition(gridlist)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetScrollPosition",1,"dgs-dxgridlist")) end
	local scb = dgsElementData[gridlist].scrollbars
	return dgsScrollBarGetScrollPosition(scb[1]),dgsScrollBarGetScrollPosition(scb[2])
end

function dgsGridListSetScrollPosition(gridlist,vertical,horizontal)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetScrollPosition",1,"dgs-dxgridlist")) end
	if vertical and not (type(vertical) == "number" and vertical>= 0 and vertical <= 100) then error(dgsGenAsrt(vertical,"dgsGridListSetScrollPosition",2,"nil/number","0~100")) end
	if horizontal and not (type(horizontal) == "number" and horizontal>= 0 and horizontal <= 100) then error(dgsGenAsrt(horizontal,"dgsGridListSetScrollPosition",3,"nil/number","0~100")) end
	local scb = dgsElementData[gridlist].scrollbars
	local state1,state2 = true,true
	if vertical then
		state1 = dgsScrollBarSetScrollPosition(scb[1],vertical)
	end
	if horizontal then
		state2 = dgsScrollBarSetScrollPosition(scb[2],horizontal)
	end
	return state1 and state2
end

--Make compatibility for GUI
function dgsGridListGetHorizontalScrollPosition(gridlist)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetHorizontalScrollPosition",1,"dgs-dxgridlist")) end
	local scb = dgsElementData[gridlist].scrollbars
	return dgsScrollBarGetScrollPosition(scb[2])
end

function dgsGridListSetHorizontalScrollPosition(gridlist,horizontal)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetHorizontalScrollPosition",1,"dgs-dxgridlist")) end
	if not (type(horizontal) == "number" and horizontal>= 0 and horizontal <= 100) then error(dgsGenAsrt(horizontal,"dgsGridListSetHorizontalScrollPosition",2,"nil/number","0~100")) end
	local scb = dgsElementData[gridlist].scrollbars
	return dgsScrollBarSetScrollPosition(scb[2],horizontal)
end

function dgsGridListGetVerticalScrollPosition(gridlist)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetVerticalScrollPosition",1,"dgs-dxgridlist")) end
	local scb = dgsElementData[gridlist].scrollbars
	return dgsScrollBarGetScrollPosition(scb[1])
end

function dgsGridListSetVerticalScrollPosition(gridlist,vertical)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetVerticalScrollPosition",1,"dgs-dxgridlist")) end
	if not (type(vertical) == "number" and vertical>= 0 and vertical <= 100) then error(dgsGenAsrt(vertical,"dgsGridListSetVerticalScrollPosition",2,"nil/number","0~100")) end
	local scb = dgsElementData[gridlist].scrollbars
	return dgsScrollBarSetScrollPosition(scb[1],vertical)
end

function dgsAttachToGridList(element,gridlist,r,c)
	if not isElement(element) then error(dgsGenAsrt(element,"dgsAttachToGridList",1,"element")) end
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsAttachToGridList",2,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cIsNum,rIsNum = type(c) == "number",type(r) == "number"
	local cNInRange,rNInRange = cIsNum and not (c>=1 and c<=cLen),rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsAttachToGridList",3,"number","1~"..rLen,rNInRange and "row out of range")) end
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsAttachToGridList",4,"number","1~"..cLen,cNInRange and "column out of range")) end
	local c,r = c-c%1,r-r%1
	if rData[r][c] then
		dgsDetachElements(element)
		dgsSetParent(element,gridlist)
		rData[r][c][glItem_attachedElement] = rData[r][c][glItem_attachedElement] or {}
		tableInsert(rData[r][c][glItem_attachedElement],element)
		return dgsSetData(element,"attachedToGridList",{gridlist,r,c})
	end
	return false
end

function dgsGetAttachedGridList(element)
	if not isElement(element) then error(dgsGenAsrt(element,"dgsGetAttachedGridList",1,"element")) end
	local attachData = dgsElementData[element].attachedToGridList
	if attachData then
		return attachData[1],attachData[2],attachData[3]
	end
	return false,false,false
end

function dgsDetachFromGridList(element)
	if not isElement(element) then error(dgsGenAsrt(element,"dgsDetachFromGridList",1,"element")) end
	local attachData = dgsElementData[element].attachedToGridList
	if not attachData then return false end
	local gridlist,r,c = attachData[1],attachData[2],attachData[3]
	local rData = dgsElementData[gridlist].rowData
	if rData[r] and rData[r][c] then
		rData[r][c][glItem_attachedElement] = rData[r][c][glItem_attachedElement] or {}
		tableRemoveItemFromArray(rData[r][c][glItem_attachedElement],element)
	end
	return dgsSetData(element,"attachedToGridList",nil)
end
-----------------------------Sort
gridlistSortFunctions.greaterUpper = function(...)
	local a,b = ...
	local column = dgsElementData[self].sortColumn
	return a[column][glItem_text] < b[column][glItem_text]
end

gridlistSortFunctions.greaterLower = function(...)
	local a,b = ...
	local column = dgsElementData[self].sortColumn
	return a[column][glItem_text] > b[column][glItem_text]
end

gridlistSortFunctions.numGreaterUpperNumFirst = function(...)
	local a,b = ...
	local column = dgsElementData[self].sortColumn
	local a = tonumber(a[column][glItem_text]) or a[column][glItem_text]
	local b = tonumber(b[column][glItem_text]) or b[column][glItem_text]
	local aType = type(a)
	local bType = type(b)
	if aType == "string" and bType == "number" then
		return false
	elseif aType == "number" and bType == "string" then
		return true
	end
	return a < b
end

gridlistSortFunctions.numGreaterLowerNumFirst = function(...)
	local a,b = ...
	local column = dgsElementData[self].sortColumn
	local a = tonumber(a[column][glItem_text]) or a[column][glItem_text]
	local b = tonumber(b[column][glItem_text]) or b[column][glItem_text]
	local aType = type(a)
	local bType = type(b)
	if aType == "string" and bType == "number" then
		return true
	elseif aType == "number" and bType == "string" then
		return false
	end
	return a > b
end

gridlistSortFunctions.numGreaterUpper = gridlistSortFunctions.numGreaterUpperNumFirst 
gridlistSortFunctions.numGreaterLower = gridlistSortFunctions.numGreaterLowerNumFirst 

gridlistSortFunctions.numGreaterUpperStrFirst = function(...)
	local a,b = ...
	local column = dgsElementData[self].sortColumn
	local a = tonumber(a[column][glItem_text]) or a[column][glItem_text]
	local b = tonumber(b[column][glItem_text]) or b[column][glItem_text]
	local aType = type(a)
	local bType = type(b)
	if aType == "string" and bType == "number" then
		return true
	elseif aType == "number" and bType == "string" then
		return false
	end
	return a < b
end

gridlistSortFunctions.numGreaterLowerStrFirst = function(...)
	local a,b = ...
	local column = dgsElementData[self].sortColumn
	local a = tonumber(a[column][glItem_text]) or a[column][glItem_text]
	local b = tonumber(b[column][glItem_text]) or b[column][glItem_text]
	local aType = type(a)
	local bType = type(b)
	if aType == "string" and bType == "number" then
		return false
	elseif aType == "number" and bType == "string" then
		return true
	end
	return a > b
end

gridlistSortFunctions.longerUpper = function(...)
	local a,b = ...
	local column = dgsElementData[self].sortColumn
	return utf8Len(a[column][glItem_text]) < utf8Len(b[column][glItem_text])
end

gridlistSortFunctions.longerLower = function(...)
	local a,b = ...
	local column = dgsElementData[self].sortColumn
	return utf8Len(a[column][glItem_text]) > utf8Len(b[column][glItem_text])
end

function dgsGridListSetSortFunction(gridlist,str)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetSortFunction",1,"dgs-dxgridlist")) end
	local fnc,err
	if type(str) == "string" then
		fnc,err = loadstring(str)
		if not fnc then error("Bad Argument @'dgsGridListSetSortFunction' at argument 1, failed to load the function:\n"..err) end
		local newfenv = {}
		setmetatable(newfenv, {__index = _G})
		newfenv.self = gridlist
		newfenv.dgsElementData = dgsElementData
		setfenv(fnc,newfenv)
	elseif type(str) == "function" then
		fnc = str
		local newfenv = {}
		setmetatable(newfenv, {__index = _G})
		newfenv.self = gridlist
		newfenv.dgsElementData = dgsElementData
		setfenv(fnc,newfenv)
	end
	if dgsElementData[gridlist].autoSort then
		dgsElementData[gridlist].nextRenderSort = true
	end
	return dgsSetData(gridlist,"sortFunction",fnc)
end

function dgsGridListSetAutoSortEnabled(gridlist,state)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetAutoSortEnabled",1,"dgs-dxgridlist")) end
	local state = state and true or false
	return dgsSetData(gridlist,"autoSort",state)
end

function dgsGridListGetAutoSortEnabled(gridlist)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetAutoSortEnabled",1,"dgs-dxgridlist")) end
	return dgsElementData[gridlist].autoSort
end

function dgsGridListSetSortEnabled(gridlist,state)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetSortEnabled",1,"dgs-dxgridlist")) end
	local state = state and true or false
	return dgsSetData(gridlist,"sortEnabled",state)
end

function dgsGridListGetSortEnabled(gridlist)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetSortEnabled",1,"dgs-dxgridlist")) end
	return dgsElementData[gridlist].sortEnabled
end

function dgsGridListSetSortColumn(gridlist,sortColumn)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetSortColumn",1,"dgs-dxgridlist")) end
	local columnData = dgsElementData[gridlist].columnData
	if columnData then
		if dgsElementData[gridlist].autoSort then
			dgsElementData[gridlist].nextRenderSort = true
		end
		return dgsSetData(gridlist,"sortColumn",sortColumn)
	end
	return false
end

function dgsGridListGetSortColumn(gridlist)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetSortColumn",1,"dgs-dxgridlist")) end
	return dgsElementData[gridlist].sortColumn
end

function dgsGridListSort(gridlist,sortColumn)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSort",1,"dgs-dxgridlist")) end
	local sortColumn = tonumber(sortColumn) or dgsElementData[gridlist].sortColumn
	if sortColumn then
		local rowData = dgsElementData[gridlist].rowData
		local sortFunction = dgsElementData[gridlist].sortFunction
		tableSort(rowData,sortFunction)
		dgsElementData[gridlist].rowData = rowData
		return true
	end
	return false
end

function dgsGridListScrollTo(gridlist,r,c,smoothMove)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListScrollTo",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	if eleData.configNextFrame then configGridList(gridlist) end
	if r then
		local rData = eleData.rowData
		local rLen = #rData
		if rLen == 0 then return false end
		local rIsNum = type(r) == "number"
		local rNInRange = rIsNum and not (r>=1 and r<=rLen)
		if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListScrollTo",2,"number","1~"..rLen,rNInRange and "row out of range")) end
		local scb = eleData.scrollbars[2]
		local rHeight = eleData.rowHeight--_RowHeight
		local leading = eleData.leading
		local rHeightLeadingTemp = rHeight+leading
		local sy = eleData.absSize[2]
		local columnHeight = eleData.columnHeight
		local scbThickH = dgsElementData[scb].visible and eleData.scrollBarThick or 0
		local gridListRange = sy-scbThickH-columnHeight
		local rMoveOffset = eleData.rowMoveOffset
		local rBeforeHeight = (r-1)*rHeightLeadingTemp
		local rFullHeight = rBeforeHeight+rHeight
		if rBeforeHeight+rMoveOffset < 0 then
			local scrollPos = rBeforeHeight/(rLen*rHeightLeadingTemp-gridListRange)*100
			dgsGridListSetScrollPosition(gridlist,scrollPos)
		elseif rFullHeight+rMoveOffset > gridListRange then
			local scrollPos = (rFullHeight-gridListRange)/(rLen*rHeightLeadingTemp-gridListRange)*100
			dgsGridListSetScrollPosition(gridlist,scrollPos)
		end
	end
	if c then
		local cData = eleData.columnData
		local cLen = #cData
		if cLen == 0 then return false end
		local cIsNum = type(c) == "number"
		local cNInrange = cIsNum and not (c>=1 and c<=cLen)
		if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListScrollTo",3,"number","1~"..cLen,cNInRange and "column out of range")) end
		local scb = eleData.scrollbars[1]
		local sx = eleData.absSize[1]
		local cOffset = eleData.columnOffset
		local scbThickV = dgsElementData[scb].visible and eleData.scrollBarThick or 0
		local gridListRange = sx-scbThickV
		local cMoveOffset = eleData.columnMoveOffset
		local cFullWidth = dgsGridListGetColumnAllWidth(gridlist,c,false)
		local cBeforeWidth = cFullWidth-dgsGridListGetColumnWidth(gridlist,c,false)
		local allWidth = dgsGridListGetColumnAllWidth(gridlist,cLen)
		if cBeforeWidth+cMoveOffset+cOffset < 0 then
			local scrollPos = cBeforeWidth/(allWidth-gridListRange)*100
			dgsGridListSetScrollPosition(gridlist,_,scrollPos)
		elseif cFullWidth+cMoveOffset+cOffset > sx then
			local scrollPos = (cFullWidth-gridListRange)/(allWidth-gridListRange)*100
			dgsGridListSetScrollPosition(gridlist,_,scrollPos)
		end
	end
	return true
end

-----------------------------Column
--[[
columnData Struct:
	{
		text,
		width,
		widthSum,
		alignment,
		color,
		colorCoded,
		scaleX,
		scaleY,
		font
	},
	{
		text,
		width,
		widthSum,
		alignment,
		color,
		colorCoded,
		scaleX,
		scaleY,
		font
	},
]]
function dgsGridListAddColumn(gridlist,name,len,c,alignment)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListAddColumn",1,"dgs-dxgridlist")) end
	if not (type(len) == "number") then error(dgsGenAsrt(len,"dgsGridListAddColumn",3,"number")) end
	local eleData = dgsElementData[gridlist]
	local cData = eleData.columnData
	local cLen = #cData
	local _name
	c = tonumber(c) or cLen+1
	c = c > cLen+1 and cLen+1 or c
	local aSize = eleData.absSize
	local sx,sy = aSize[1],aSize[2]
	local scrollBarThick = eleData.scrollBarThick
	local multiplier = eleData.columnRelative and sx-scrollBarThick or 1
	local oldLen = 0
	if cLen > 0 then
		oldLen = cData[cLen][glCol_widthSum]+cData[cLen][glCol_width]
	end
	if type(name) == "table" then
		_name = name
		name = dgsTranslate(gridlist,name,sourceResource)
	end
	tableInsert(cData,c,{
		tostring(name or ""),
		len,
		oldLen,
		HorizontalAlign[alignment] or "left",
		_translation_text = _name,
	})
	local cTextSize = eleData.columnTextSize
	local cTextColor = eleData.columnTextColor
	local colorCoded = eleData.colorCoded
	for i=c+1,cLen+1 do
		cData[i] = {
			cData[i][glCol_text],
			cData[i][glCol_width],
			dgsGridListGetColumnAllWidth(gridlist,i-1),
			cData[i][glCol_textAlignment],
			cTextColor,
			colorCoded,
			cTextSize[1],
			cTextSize[2],
			nil, --Font
		}
	end
	dgsSetData(gridlist,"columnData",cData)
	local rData = eleData.rowData
	local rTextColor = eleData.rTextColor
	local scale = eleData.rowTextSize
	
	for i=1,#rData do
		rData[i][c]= {
			"",
			rTextColor,
			colorCoded,
			scale[1],
			scale[2],
			font,
		}
		if rData[r][glRow_isSection] then
			rData[r][c][glItem_isSection] = true
		end
	end
	eleData.configNextFrame = true
	return c
end

function dgsGridListSetColumnFont(gridlist,c,font,affectRow)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetColumnFont",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData = eleData.columnData
	local cLen = #cData
	if cLen == 0 then return false end
	local cIsNum = type(c) == "number"
	local cNInRange = cIsNum and not (c>=1 and c<=cLen)
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListSetColumnFont",2,"number","1~"..cLen, cNInRange and "column out of range")) end
	local c = c-c%1
	if not (fontBuiltIn[font] or dgsGetType(font) == "dx-font") then error(dgsGenAsrt(font,"dgsGridListSetColumnFont",3,"dx-font/string",_,"invalid font")) end
	--Multilingual
	if type(font) == "table" then
		cData[c]._translation_font = font
		font = dgsGetTranslationFont(gridlist,font,sourceResource)
	else
		cData[c]._translation_font = nil
	end
	cData[c][glCol_textFont] = font
	if affectRow then
		local rData = eleData.rowData
		for r=1,#rData do
			--Multilingual
			if type(font) == "table" then
				rData[r][c]._translation_font = font
				font = dgsGetTranslationFont(gridlist,font,sourceResource)
			else
				rData[r][c]._translation_font = nil
			end

			rData[r][c][glItem_textFont] = font
		end
	end
	return true
end

function dgsGridListGetColumnFont(gridlist,c)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetColumnFont",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData = eleData.columnData
	local cLen = #cData
	if cLen == 0 then return false end
	local cIsNum = type(c) == "number"
	local cNInRange = cIsNum and not (c>=1 and c<=cLen)
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListGetColumnFont",2,"number","1~"..cLen, cNInRange and "column out of range")) end
	local c = c-c%1
	return cData[c][glCol_textFont]	--Font
end

function dgsGridListSetColumnAlignment(gridlist,c,align,affectRow)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetColumnAlignment",1,"dgs-dxgridlist")) end
	if not HorizontalAlign[align] then error(dgsGenAsrt(align,"dgsGridListSetColumnAlignment",3,"string","left/center/right")) end
	local eleData = dgsElementData[gridlist]
	local cData = eleData.columnData
	local cLen = #cData
	if cLen == 0 then return false end
	local cIsNum = type(c) == "number"
	local cNInRange = cIsNum and not (c>=1 and c<=cLen)
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListSetColumnAlignment",2,"number","1~"..cLen, cNInRange and "column out of range")) end
	local c = c-c%1
	cData[c][glCol_textAlignment] = align
	if affectRow then
		local rData = eleData.rowData
		for i=1,#rData do
			rData[i][c][glItem_textAlignment] = nil	--Follow Column Alignment
		end
	end
	return true
end

function dgsGridListGetColumnAlignment(gridlist,c)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetColumnAlignment",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData = eleData.columnData
	local cLen = #cData
	if cLen == 0 then return false end
	local cIsNum = type(c) == "number"
	local cNInRange = cIsNum and not (c>=1 and c<=cLen)
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListGetColumnAlignment",2,"number","1~"..cLen, cNInRange and "column out of range")) end
	local c = c-c%1
	return cData[c][glCol_textAlignment]	--Alignment
end

function dgsGridListGetColumnTextSize(gridlist,c)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetColumnTextSize",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData = eleData.columnData
	local cLen = #cData
	if cLen == 0 then return false end
	local cIsNum = type(c) == "number"
	local cNInRange = cIsNum and not (c>=1 and c<=cLen)
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListGetColumnTextSize",2,"number","1~"..cLen, cNInRange and "column out of range")) end
	local c = c-c%1
	return cData[c][glCol_textScaleX],cData[c][glCol_textScaleY]
end

function dgsGridListSetColumnTextSize(gridlist,c,sizeX,sizeY)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetColumnTextSize",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData = eleData.columnData
	local cLen = #cData
	if cLen == 0 then return false end
	local cIsNum = type(c) == "number"
	local cNInRange = cIsNum and not (c>=1 and c<=cLen)
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListSetColumnTextSize",2,"number","1~"..cLen, cNInRange and "column out of range")) end
	local c = c-c%1
	if not (type(sizeX) == "number") then error(dgsGenAsrt(sizeX,"dgsGridListSetColumnTextSize",3,"number")) end
	cData[c][glCol_textScaleX] = sizeX
	cData[c][glCol_textScaleY] = sizeY or sizeX
	return true
end

function dgsGridListSetColumnRelative(gridlist,relative,transformColumn)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetColumnRelative",1,"dgs-dxgridlist")) end
	if not (type(relative) == "boolean") then error(dgsGenAsrt(relative,"dgsGridListSetColumnRelative",2,"bool")) end
	local relative = relative and true or false
	local transformColumn = transformColumn == false and true or false
	dgsSetData(gridlist,"columnRelative",relative)
	if transformColumn then
		local cData = dgsElementData[gridlist].columnData
		local w,h = dgsGetSize(v,false)
		if relative then
			for k,v in ipairs(cData) do
				cData[k][glCol_width] = cData[k][glCol_width]/w
				cData[k][glCol_widthSum] = cData[k][glCol_widthSum]/w
			end
		else
			for k,v in ipairs(cData) do
				cData[k][glCol_width] = cData[k][glCol_width]*w
				cData[k][glCol_widthSum] = cData[k][glCol_widthSum]*w
			end
		end
	end
	return true
end

function dgsGridListSetColumnTitle(gridlist,c,name)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetColumnTitle",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData = eleData.columnData
	local cLen = #cData
	if cLen == 0 then return false end
	local cIsNum = type(c) == "number"
	local cNInRange = cIsNum and not (c>=1 and c<=cLen)
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListSetColumnTitle",2,"number","1~"..cLen, cNInRange and "column out of range")) end
	local c = c-c%1
	if cData[c] then
		if type(name) == "table" then
			cData[c]._translation_text = name
			name = dgsTranslate(gridlist,name,sourceResource)
		else
			cData[c]._translation_text = nil
		end
		cData[c][glCol_text] = name
		dgsSetData(gridlist,"columnData",cData)
	end
end

function dgsGridListGetColumnTitle(gridlist,c)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetColumnTitle",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData = eleData.columnData
	local cLen = #cData
	if cLen == 0 then return false end
	local cIsNum = type(c) == "number"
	local cNInRange = cIsNum and not (c>=1 and c<=cLen)
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListGetColumnTitle",2,"number","1~"..cLen, cNInRange and "column out of range")) end
	local c = c-c%1
	return cData[c][glCol_text]
end

function dgsGridListSetColumnTextColor(gridlist,c,...)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetColumnTextColor",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData = eleData.columnData
	local cLen = #cData
	if cLen == 0 then return false end
	local cIsNum = type(c) == "number"
	local cNInRange = cIsNum and not (c>=1 and c<=cLen)
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListSetColumnTextColor",2,"number","1~"..cLen, cNInRange and "column out of range")) end
	c = c-c%1
	local color
	local args = {...}
	if not (type(#args > 0 and args[1]) == "number") then error(dgsGenAsrt(args[1],"dgsGridListSetColumnTextColor",3,"number")) end
	if #args == 1 then 
		color = args[1]
	else
		if not (type(args[2]) == "number") then error(dgsGenAsrt(args[2],"dgsGridListSetColumnTextColor",4,"number")) end
		if not (type(args[3]) == "number") then error(dgsGenAsrt(args[3],"dgsGridListSetColumnTextColor",5,"number")) end
		if not (not args[4] or type(args[4]) == "number") then error(dgsGenAsrt(args[4],"dgsGridListSetColumnTextColor",6,"nil/number")) end
		color = tocolor(args[1],args[2],args[3],args[4])
	end
	cData[c][glCol_textColor] = color
	return true
end

function dgsGridListGetColumnTextColor(gridlist,c,notSplitColor)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetColumnTextColor",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData = eleData.columnData
	local cLen = #cData
	if cLen == 0 then return false end
	local cIsNum = type(c) == "number"
	local cNInRange = cIsNum and not (c>=1 and c<=cLen)
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListGetColumnTextColor",2,"number","1~"..cLen, cNInRange and "column out of range")) end
	c = c-c%1
	local color = cData[c][glCol_textColor]
	if notSplitColor then
		return color
	else
		return fromcolor(color)
	end
end

function dgsGridListGetColumnRelative(gridlist)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetColumnRelative",1,"dgs-dxgridlist")) end
	return dgsElementData[gridlist].columnRelative
end

function dgsGridListGetColumnCount(gridlist)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetColumnCount",1,"dgs-dxgridlist")) end
	return #(dgsElementData[gridlist].columnData or {})
end

function dgsGridListRemoveColumn(gridlist,c)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListRemoveColumn",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData = eleData.columnData
	local cLen = #cData
	if cLen == 0 then return false end
	local cIsNum = type(c) == "number"
	local cNInRange = cIsNum and not (c>=1 and c<=cLen)
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListRemoveColumn",2,"number","1~"..cLen, cNInRange and "column out of range")) end
	local c = c-c%1
	local oldLen = cData[c][glCol_widthSum]
	local lastColumnLen = 0
	for i=1,cLen do
		if i >= c then
			cData[i][glCol_widthSum] = cData[i][glCol_widthSum]-oldLen
			lastColumnLen = cData[i][glCol_widthSum]+cData[i][glCol_width]
		end
	end
	dgsGridListSelectItem(gridlist,1,c,false)	--unselect this column
	tableRemove(cData,c)
	dgsElementData[gridlist].configNextFrame = true
	return true
end

function dgsGridListSetColumnHeight(gridlist,columnHeight)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetColumnHeight",1,"dgs-dxgridlist")) end
	if not (type(columnHeight) == "number" and columnHeight >= 0) then error(dgsGenAsrt(columnHeight,"dgsGridListSetColumnHeight",2,"number","≥0")) end
	return dgsSetData(gridlist,"columnHeight",columnHeight)
end

function dgsGridListGetColumnHeight(gridlist)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetColumnHeight",1,"dgs-dxgridlist")) end
	return dgsElementData[gridlist].columnHeight
end

function dgsGridListSetColumnWidth(gridlist,c,width,relative)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetColumnWidth",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData = eleData.columnData
	local cLen = #cData
	if cLen == 0 then return false end
	local cIsNum = type(c) == "number"
	local cNInRange = cIsNum and not (c>=1 and c<=cLen)
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListSetColumnWidth",2,"number","1~"..cLen,cNInRange and "column out of range")) end
	local c = c-c%1
	if not (type(width) == "number") then error(dgsGenAsrt(c,"dgsGridListSetColumnWidth",3,"number")) end
	local rlt = eleData.columnRelative
	if relative == nil then
		relative = rlt
	else
		relative = relative and true or false
	end
	local scbThick = eleData.scrollBarThick
	local columnSize = eleData.absSize[1]-scbThick
	if rlt then
		width = relative and width or width/columnSize
	else
		width = relative and width*columnSize or width
	end
	local differ = width-cData[c][glCol_width]
	cData[c][glCol_width] = width
	local lastColumnLen = 0
	for i=1,cLen do
		if i > c then
			cData[i][glCol_widthSum] = cData[i][glCol_widthSum]+differ
			lastColumnLen = cData[i][glCol_widthSum]+cData[i][glCol_width]
		end
	end
	dgsElementData[gridlist].configNextFrame = true
	return true
end

function dgsGridListAutoSizeColumn(gridlist,c,additionalLength,relative,isByItem)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListAutoSizeColumn",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData = eleData.columnData
	local cLen = #cData
	if cLen == 0 then return false end
	local cIsNum = type(c) == "number"
	local cNInRange = cIsNum and not (c>=1 and c<=cLen)
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListAutoSizeColumn",2,"number","1~"..cLen,cNInRange and "column out of range")) end
	local c = c-c%1
	if not (additionalLength == nil or type(additionalLength) == "number") then error(dgsGenAsrt(c,"dgsGridListAutoSizeColumn",3,"number")) end
	if not additionalLength then relative = false end
	if isByItem then
		local rData = eleData.rowData
		local maxWidth = 0
		local colorCoded = eleData.colorCoded
		local font = eleData.font
		local sectionFont = eleData.sectionFont or font
		local columnSize = eleData.absSize[1]-eleData.scrollBarThick
		for i=1,#rData do
			local colorCoded = rData[i][c][glItem_textColorCoded] == nil and colorCoded or rData[i][c][glItem_textColorCoded]
			local rowFont = rData[i][glRow_isSection] and (rData[i][c][glItem_textFont] or sectionFont) or (rData[i][c][glItem_textFont] or eleData.rowFont or eleData.columnFont or font)
			local wid = dxGetTextWidth(rData[i][c][glItem_text],rData[i][c][glItem_textScaleX],rowFont,colorCoded)
			if maxWidth < wid then
				maxWidth = wid
			end
		end
		local maxWidth = maxWidth+(relative and additionalLength*columnSize or (additionalLength or 0))
		return dgsGridListSetColumnWidth(gridlist,c,maxWidth,false)
	else
		local font = cData[c][glCol_textFont] or eleData.columnFont or eleData.font
		local wid = dxGetTextWidth(cData[c][glCol_text],cData[c][glCol_textScaleX],font)
		local wid = wid+(relative and additionalLength*wid or (additionalLength or 0))
		return dgsGridListSetColumnWidth(gridlist,c,wid,false)
	end
end

--[[
mode Fast(true)/Slow(false)
--]]
function dgsGridListGetColumnAllWidth(gridlist,c,relative,mode)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetColumnAllWidth",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData = eleData.columnData
	local cLen = #cData
	if cLen == 0 then return 0 end
	local cIsNum = type(c) == "number"
	local cNInRange = cIsNum and not (c>=1 and c<=cLen)
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListGetColumnAllWidth",2,"number","0~"..cLen,cNInRange and "column out of range")) end
	local c = c-c%1
	local columnSize = eleData.absSize[1]-eleData.scrollBarThick
	local rlt = eleData.columnRelative
	if mode then
		local data = cData[c][glCol_widthSum]+cData[c][glCol_width]
		if relative then
			return rlt and data or data/columnSize
		else
			return rlt and data*columnSize or data
		end
	else
		local dataLength = 0
		for i=1,cLen do
			dataLength = dataLength + cData[i][glCol_width]
			if i == c then
				if relative then
					return rlt and dataLength or dataLength/columnSize
				else
					return rlt and dataLength*columnSize or dataLength
				end
			end
		end
	end
	return false
end

function dgsGridListGetColumnWidth(gridlist,c,relative)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetColumnWidth",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData = eleData.columnData
	local cLen = #cData
	if cLen == 0 then return false end
	local cIsNum = type(c) == "number"
	local cNInRange = cIsNum and not (c>=1 and c<=cLen)
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListGetColumnWidth",2,"number","1~"..cLen,cNInRange and "column out of range")) end
	local c = c-c%1
	local columnSize = eleData.absSize[1]-eleData.scrollBarThick
	local rlt = eleData.columnRelative
	local data = cData[c][glCol_width]
	if relative then
		return rlt and data or data/columnSize
	else
		return rlt and data*columnSize or data
	end
end

function dgsGridListGetEnterColumn(gridlist)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetEnterColumn",1,"dgs-dxgridlist")) end
	return dgsElementData[gridlist].selectedColumn
end

function dgsGridListClearColumn(gridlist,notResetSelected,notResetScrollBar)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListClearColumn",1,"dgs-dxgridlist")) end
 	local scrollbars = dgsElementData[gridlist].scrollbars
	local rowData = dgsElementData[gridlist].rowData
	if not notResetScrollBar then
		dgsSetData(gridlist,"columnMoveOffset",0)
		dgsSetData(gridlist,"columnMoveOffsetTemp",0)
		dgsSetData(scrollbars[2],"length",{0,true})
		dgsSetData(scrollbars[2],"scrollPosition",0)
		dgsSetVisible(scrollbars[2],false)
	end
	if not notResetSelected then
		 dgsGridListSetSelectedItem(gridlist,-1)
	end
	for i=1,#rowData do
		for a=1,#rowData[i] do
			rowData[i][a] = nil
		end
	end
	dgsSetData(gridlist,"columnData",{})
	dgsSetData(gridlist,"rowData",rowData)
	configGridList(gridlist)
	return true
end

-----------------------------Row
--[[
rowData Struct:
{
	/*Row Settings*/
	[-5] = identity,              --Identity
	[-3] = {                      --Background Image
			normalImage,
			hoveringImage,
			selectedImage,
		},
	[-2] = true/false,            --Hoverable
	[-1] = true/false,            --Selectable
	[0] = {                       --Background Color
		normalColor,
		hoveringColor,
		selectedColor,
	},
	/*Column 1 Data*/
	[1] = {
		text,
		color,
		colorCoded,
		scaleX,
		scaleY,
		font,
		{                         --Row Image
			image,
			color,
			imageX,
			imageY,
			imageW,
			imageH,
			relative,
		},
		hoverDisabled,
		selectDisabled,
		attachedElement,
		alignment,
		{                         --Text Offset
			textOffsetX,
			textOffsetY,
			relative,
		},
		{                         --Item Background Color
			bgColorNormal,
			bgColorHovering,
			bgColorSelected,
		},
		{                         --Item Background Image
			bgImageNormal,
			bgImageHovering,
			bgImageSelected,
		},
		isSection
		columnOffset,          --Column Offset
	},
	/*Column 2 Data*/
	[2] = {
		text,
		color,
		colorCoded,
		scaleX,
		scaleY,
		font,
		{                         --Row Image
			image,
			color,
			imageX,
			imageY,
			imageW,
			imageH,
			relative,
		},
		hoverDisabled,
		selectDisabled,
		attachedElement,
		alignment,
		{                         --Text Offset
			textOffsetX,
			textOffsetY,
			relative,
		},
		{                         --Item Background Color
			bgColorNormal,
			bgColorHovering,
			bgColorSelected,
		},
		{                         --Item Background Image
			bgImageNormal,
			bgImageHovering,
			bgImageSelected,
		},
		isSection
	},
}
]]

function dgsGridListAddRow(gridlist,r,...)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListAddRow",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData = eleData.columnData
	local cLen = #cData
	if not (cLen > 0) then error("Bad argument @dgsGridListAddRow, no columns in the grid list") end
	local args = {...}
	local rData = eleData.rowData
	r = tonumber(r) or #rData+1
	local rowTable = {
		[glRow_bgImage] = eleData.rowImage,
		[glRow_hoverable] = true,
		[glRow_selectable] = true,
		[glRow_bgColor] = eleData.rowColor,
	}
	local rTextColor = eleData.rowTextColor
	local colorCoded = eleData.colorCoded
	local scale = eleData.rowTextSize
	for i=1,cLen do
		local text,_text = args[i]
		if type(text) == "table" then
			_text = text
			text = dgsTranslate(gridlist,text,sourceResource)
		end
		rowTable[i] = {
			_translation_text=_text,
			tostring(text or ""),
			rTextColor,
			colorCoded,
			scale[1],
			scale[2],
			nil, --Font
		}
	end
	tableInsert(rData,r,rowTable)
	eleData.configNextFrame = true
	return r
end

function dgsGridListInsertRowAfter(gridlist,r,...)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListInsertRowAfter",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData = eleData.columnData
	assert(#cData > 0 ,"Bad argument @dgsGridListInsertRowAfter, no columns in the grid list")
	return dgsGridListAddRow(gridlist,r+1,...)
end

function dgsGridListAddRows(gridlist,r,t,isRawData)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListAddRows",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData = eleData.columnData
	local cLen = #cData
	if not (cLen > 0) then error("Bad argument @dgsGridListAddRows, no columns in the grid list") end
	if not (type(t) == "table") then error(dgsGenAsrt(t,"dgsGridListAddRows",3,"table")) end
	local rowData = eleData.rowData
	r = tonumber(r) or #rowData
	if isRawData then
		for i=1,#t do
			tableInsert(rowData,r+i,t[i])	--This will skip language check
		end
	else
		for i=1,#t do
			local rowTable = {
				[glRow_bgImage] = eleData.rowImage,
				[glRow_hoverable] = true,
				[glRow_selectable] = true,
				[glRow_bgColor] = eleData.rowColor,
			}
			local rTextColor = eleData.rowTextColor
			local colorCoded = eleData.colorCoded
			local scale = eleData.rowTextSize
			for col=1,cLen do
				local text,_text = t[i][col]
				if type(text) == "table" then
					_text = text
					text = dgsTranslate(gridlist,text,sourceResource)
				end
				rowTable[col] = {
					_translation_text=_text,
					tostring(text or ""),
					rTextColor,
					colorCoded,
					scale[1],
					scale[2],
					nil,	--Font
				}
			end
			tableInsert(rowData,r+i,rowTable)
		end
	end
	dgsElementData[gridlist].configNextFrame = true
	return true
end

function dgsGridListSetRowID(gridlist,r,id)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetRowID",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local rData = eleData.rowData
	local rLen = #rData
	if rLen == 0 then return false end
	local rIsNum = type(r) == "number"
	local rNInRange = rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListSetRowID",2,"number","1~"..rLen, rNInRange and "row out of range")) end
	local r = r-r%1
	if rData[r] then
		rData[r][glRow_identity] = id
		return true
	end
	return false
end

function dgsGridListGetRowID(gridlist,r)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetRowID",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local rData = eleData.rowData
	local rLen = #rData
	if rLen == 0 then return false end
	local rIsNum = type(r) == "number"
	local rNInRange = rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListGetRowID",2,"number","1~"..rLen, rNInRange and "row out of range")) end
	local r = r-r%1
	if rData[r] then
		return rData[r][glRow_identity]
	end
	return false
end

function dgsGridListFindRowByID(gridlist,id,position)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListFindRowByID",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local rData = eleData.rowData
	position = position or 0
	for i=1,#rData do
		if id == rData[i][glRow_identity] then
			if position == 0 then
				return i
			end
			position = position-1
		end
	end
	return false
end

function dgsGridListGetRowCount(gridlist)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetRowCount",1,"dgs-dxgridlist")) end
	return #dgsElementData[gridlist].rowData
end

function dgsGridListGetRowSelectable(gridlist,r)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetRowSelectable",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local rData = eleData.rowData
	local rLen = #rData
	if rLen == 0 then return false end
	local rIsNum = type(r) == "number"
	local rNInRange = rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListGetRowSelectable",2,"number","1~"..rLen, rNInRange and "row out of range")) end
	local r = r-r%1
	return rData[r] and rData[r][glRow_selectable] or false
end

function dgsGridListSetRowSelectable(gridlist,r,state)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetRowSelectable",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local rData = eleData.rowData
	local rLen = #rData
	if rLen == 0 then return false end
	local rIsNum = type(r) == "number"
	local rNInRange = rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListSetRowSelectable",2,"number","1~"..rLen, rNInRange and "row out of range")) end
	local r = r-r%1
	if rData[r] then
		rData[r][glRow_selectable] = state and true or false
		return true
	end
	return false
end

function dgsGridListGetRowHoverable(gridlist,r)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetRowHoverable",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local rData = eleData.rowData
	local rLen = #rData
	if rLen == 0 then return false end
	local rIsNum = type(r) == "number"
	local rNInRange = rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListGetRowHoverable",2,"number","1~"..rLen, rNInRange and "row out of range")) end
	local r = r-r%1
	return rData[r] and rData[r][glRow_hoverable] or false
end

function dgsGridListSetRowHoverable(gridlist,r,state)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetRowHoverable",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local rData = eleData.rowData
	local rLen = #rData
	if rLen == 0 then return false end
	local rIsNum = type(r) == "number"
	local rNInRange = rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListSetRowHoverable",2,"number","1~"..rLen, rNInRange and "row out of range")) end
	local r = r-r%1
	if rData[r] then
		rData[r][glRow_hoverable] = state and true or false
		return true
	end
	return false
end

function dgsGridListGetRowBackGroundColor(gridlist,r)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetRowBackGroundColor",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local rData = eleData.rowData
	local rLen = #rData
	if rLen == 0 then return false end
	local rIsNum = type(r) == "number"
	local rNInRange = rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListGetRowBackGroundColor",2,"number","1~"..rLen, rNInRange and "row out of range")) end
	local r = r-r%1
	if rData[r][glRow_bgColor] then
		return rData[r][glRow_bgColor][1],rData[r][glRow_bgColor][2],rData[r][glRow_bgColor][3]
	end
	return false,false,false
end

function dgsGridListSetRowBackGroundColor(gridlist,r,nClr,sClr,cClr)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetRowBackGroundColor",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local rData = eleData.rowData
	local rLen = #rData
	if rLen == 0 then return false end
	local rIsNum = type(r) == "number"
	local rNInRange = rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListSetRowBackGroundColor",2,"number","1~"..rLen, rNInRange and "row out of range")) end
	local r = r-r%1
	rData[r][glRow_bgColor] = {nClr or white,sClr or nClr,cClr or nClr}
	return true
end

function dgsGridListGetRowBackGroundImage(gridlist,r)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetRowBackGroundImage",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local rData = eleData.rowData
	local rLen = #rData
	if rLen == 0 then return false end
	local rIsNum = type(r) == "number"
	local rNInRange = rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListGetRowBackGroundImage",2,"number","1~"..rLen, rNInRange and "row out of range")) end
	local r = r-r%1
	if rData[r][glRow_bgImage] then
		return rData[r][glRow_bgImage][1],rData[r][glRow_bgImage][2],rData[r][glRow_bgImage][3]
	end
	return false,false,false
end

function dgsGridListSetRowBackGroundImage(gridlist,r,nImg,sImg,cImg)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetRowBackGroundImage",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local rData = eleData.rowData
	local rLen = #rData
	if rLen == 0 then return false end
	local rIsNum = type(r) == "number"
	local rNInRange = rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListSetRowBackGroundImage",2,"number","1~"..rLen, rNInRange and "row out of range")) end
	local r = r-r%1
	if nImg ~= nil then
		if not isMaterial(nImg) then error(dgsGenAsrt(nImg,"dgsGridListSetRowBackGroundImage",3,"material")) end
	end
	if sImg ~= nil then
		if not isMaterial(sImg) then error(dgsGenAsrt(sImg,"dgsGridListSetRowBackGroundImage",4,"material")) end
	end
	if cImg ~= nil then
		if not isMaterial(cImg) then error(dgsGenAsrt(cImg,"dgsGridListSetRowBackGroundImage",5,"material")) end
	end
	rData[r][glRow_bgImage] = {nImg,sImg,cImg}
	return true
end

function dgsGridListSetRowAsSection(gridlist,r,enabled,enableMouseClickAndSelect)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetRowAsSection",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData = eleData.columnData
	local rData = eleData.rowData
	local cLen = #cData
	local rLen = #rData
	if rLen == 0 then return false end
	local rIsNum = type(r) == "number"
	local rNInRange = rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListSetRowAsSection",2,"number","1~"..rLen, rNInRange and "row out of range")) end
	local r = r-r%1
	if enabled then
		if not enableMouseClickAndSelect then
			rData[r][glRow_hoverable] = false
			rData[r][glRow_selectable] = false
		else
			rData[r][glRow_hoverable] = true
			rData[r][glRow_selectable] = true
		end
	else
		rData[r][glRow_hoverable] = true
		rData[r][glRow_selectable] = true
	end
	rData[r][glRow_isSection] = enable and true or nil
	for c = 1,cLen do
		rData[r][c][glItem_isSection] = enabled and true or nil
	end
	return true
end

function dgsGridListRemoveRow(gridlist,r)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListRemoveRow",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local rData = eleData.rowData
	local rLen = #rData
	if rLen == 0 then return false end
	local rIsNum = type(r) == "number"
	local rNInRange = rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListRemoveRow",2,"number","1~"..rLen, rNInRange and "row out of range")) end
	local r = r-r%1
	dgsGridListSelectItem(gridlist,r,1,false)	--unselect this row
	tableRemove(rData,r)
	dgsElementData[gridlist].configNextFrame = true
	return true
end

function dgsGridListClearRow(gridlist,notResetSelected,notResetScrollBar)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListClearRow",1,"dgs-dxgridlist")) end
 	local scrollbars = dgsElementData[gridlist].scrollbars
	if not notResetScrollBar then
		dgsSetData(gridlist,"rowMoveOffset",0)
		dgsSetData(gridlist,"rowMoveOffsetTemp",0)
		dgsSetData(scrollbars[1],"length",{0,true})
		dgsSetData(scrollbars[1],"scrollPosition",0)
		dgsSetVisible(scrollbars[1],false)
	end
	if not notResetSelected then
		 dgsGridListSetSelectedItem(gridlist,-1)
	end
	dgsSetData(gridlist,"rowData",{})
	configGridList(gridlist)
	return true
end

-----------------------------Item
function dgsGridListSetItemData(gridlist,r,c,data,...)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetItemData",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cIsNum,rIsNum = type(c) == "number",type(r) == "number"
	local cNInRange,rNInRange = cIsNum and not (c>=1 and c<=cLen),rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListSetItemData",2,"number","1~"..rLen,rNInRange and "row out of range")) end
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListSetItemData",3,"number","1~"..cLen,cNInRange and "column out of range")) end
	local c,r = c-c%1,r-r%1
	if select("#",...) == 0 then
		rData[r][c][-1] = data
		return true
	else
		rData[r][c][-2] = rData[r][c][-2] or {}
		rData[r][c][-2][data] = ...
		return true
	end
	return false
end

function dgsGridListGetItemData(gridlist,r,c,key)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetItemData",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cIsNum,rIsNum = type(c) == "number",type(r) == "number"
	local cNInRange,rNInRange = cIsNum and not (c>=1 and c<=cLen),rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListGetItemData",2,"number","1~"..rLen,rNInRange and "row out of range")) end
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListGetItemData",3,"number","1~"..cLen,cNInRange and "column out of range")) end
	local c,r = c-c%1,r-r%1
	if not key then
		return rData[r][c][-1]
	else
		return (rData[r][c][-2] or {})[key] or false
	end
	return false
end

function dgsGridListSetItemFont(gridlist,r,c,font)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetItemFont",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cIsNum,rIsNum = type(c) == "number",type(r) == "number"
	local cNInRange,rNInRange = cIsNum and not (c>=1 and c<=cLen),rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListSetItemFont",2,"number","1~"..rLen,rNInRange and "row out of range")) end
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListSetItemFont",3,"number","1~"..cLen,cNInRange and "column out of range")) end
	local fontType = dgsGetType(font) 
	if not (fontBuiltIn[font] or fontType == "dx-font" or fontType == "table") then error(dgsGenAsrt(font,"dgsGridListSetItemFont",4,"dx-font/string/table",_,"invalid font")) end
	local c,r = c-c%1,r-r%1
	if not rData[r][c] then return false end
	--Multilingual
	if type(font) == "table" then
		rData[r][c]._translation_font = font
		font = dgsGetTranslationFont(gridlist,font,sourceResource)
	else
		rData[r][c]._translation_font = nil
	end
	
	rData[r][c][glItem_textFont] = font
	return true
end

function dgsGridListGetItemFont(gridlist,r,c)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetItemFont",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cIsNum,rIsNum = type(c) == "number",type(r) == "number"
	local cNInRange,rNInRange = cIsNum and not (c>=1 and c<=cLen),rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListGetItemFont",2,"number","1~"..rLen,rNInRange and "row out of range")) end
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListGetItemFont",3,"number","1~"..cLen,cNInRange and "column out of range")) end
	local c,r = c-c%1,r-r%1
	if not rData[r][c] then return false end
	return rData[r][c][glItem_textFont]
end

function dgsGridListSetItemTextSize(gridlist,r,c,sizeX,sizeY)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetItemTextSize",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cIsNum,rIsNum = type(c) == "number",type(r) == "number"
	local cNInRange,rNInRange = cIsNum and not (c>=1 and c<=cLen),rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListSetItemTextSize",2,"number","1~"..rLen,rNInRange and "row out of range")) end
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListSetItemTextSize",3,"number","1~"..cLen,cNInRange and "column out of range")) end
	if not (type(sizeX) == "number") then error(dgsGenAsrt(sizeX,"dgsGridListSetItemTextSize",4,"number")) end
	local c,r = c-c%1,r-r%1
	if not rData[r][c] then return false end
	rData[r][c][glItem_textScaleX] = sizeX
	rData[r][c][glItem_textScaleY] = sizeY or sizeX
	return true
end

function dgsGridListGetItemTextSize(gridlist,r,c)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetItemTextSize",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cIsNum,rIsNum = type(c) == "number",type(r) == "number"
	local cNInRange,rNInRange = cIsNum and not (c>=1 and c<=cLen),rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListGetItemTextSize",2,"number","1~"..rLen,rNInRange and "row out of range")) end
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListGetItemTextSize",3,"number","1~"..cLen,cNInRange and "column out of range")) end
	local c,r = c-c%1,r-r%1
	if not rData[r][c] then return false end
	return rData[r][c][glItem_textScaleX],rData[r][c][glItem_textScaleY]
end

function dgsGridListSetItemAlignment(gridlist,r,c,align)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetItemAlignment",1,"dgs-dxgridlist")) end
	if not (align == nil or HorizontalAlign[align]) then error(dgsGenAsrt(align,"dgsGridListSetItemAlignment",4,"nil/string","left/center/right")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cIsNum,rIsNum = type(c) == "number",type(r) == "number"
	local cNInRange,rNInRange = cIsNum and not (c>=1 and c<=cLen),rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListSetItemAlignment",2,"number","1~"..rLen,rNInRange and "row out of range")) end
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListSetItemAlignment",3,"number","1~"..cLen,cNInRange and "column out of range")) end
	local c,r = c-c%1,r-r%1
	rData[r][c][glItem_textAlignment] = align
	return true
end

function dgsGridListGetItemAlignment(gridlist,r,c)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetItemAlignment",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cIsNum,rIsNum = type(c) == "number",type(r) == "number"
	local cNInRange,rNInRange = cIsNum and not (c>=1 and c<=cLen),rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListGetItemAlignment",2,"number","1~"..rLen,rNInRange and "row out of range")) end
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListGetItemAlignment",3,"number","1~"..cLen,cNInRange and "column out of range")) end
	local c,r = c-c%1,r-r%1
	return rData[r][c][glItem_textAlignment] or cData[c][glCol_textAlignment]	--Alignment
end

function dgsGridListSetItemSelectable(gridlist,r,c,state)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetItemSelectable",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cIsNum,rIsNum = type(c) == "number",type(r) == "number"
	local cNInRange,rNInRange = cIsNum and not (c>=1 and c<=cLen),rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListSetItemSelectable",2,"number","1~"..rLen,rNInRange and "row out of range")) end
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListSetItemSelectable",3,"number","1~"..cLen,cNInRange and "column out of range")) end
	local c,r = c-c%1,r-r%1
	if not rData[r][c] then return false end
	rData[r][c][glItem_selectable] = state
	return true
end

function dgsGridListGetItemSelectable(gridlist,r,c)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetItemSelectable",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cIsNum,rIsNum = type(c) == "number",type(r) == "number"
	local cNInRange,rNInRange = cIsNum and not (c>=1 and c<=cLen),rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListGetItemSelectable",2,"number","1~"..rLen,rNInRange and "row out of range")) end
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListGetItemSelectable",3,"number","1~"..cLen,cNInRange and "column out of range")) end
	local c,r = c-c%1,r-r%1
	if not rData[r][c] then return false end
	return rData[r][c][glItem_selectable] == nil and rData[r][glRow_selectable] or rData[r][c][glItem_selectable]
end

function dgsGridListSetItemHoverable(gridlist,r,c,state)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetItemHoverable",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cIsNum,rIsNum = type(c) == "number",type(r) == "number"
	local cNInRange,rNInRange = cIsNum and not (c>=1 and c<=cLen),rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListSetItemHoverable",2,"number","1~"..rLen,rNInRange and "row out of range")) end
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListSetItemHoverable",3,"number","1~"..cLen,cNInRange and "column out of range")) end
	local c,r = c-c%1,r-r%1
	if not rData[r][c] then return false end
	rData[r][c][glItem_hoverable] = state
	return true
end

function dgsGridListGetItemHoverable(gridlist,r,c)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetItemHoverable",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cIsNum,rIsNum = type(c) == "number",type(r) == "number"
	local cNInRange,rNInRange = cIsNum and not (c>=1 and c<=cLen),rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListGetItemHoverable",2,"number","1~"..rLen,rNInRange and "row out of range")) end
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListGetItemHoverable",3,"number","1~"..cLen,cNInRange and "column out of range")) end
	local c,r = c-c%1,r-r%1
	if not rData[r][c] then return false end
	return rData[r][c][glItem_hoverable] == nil and rData[r][glRow_hoverable] or rData[r][c][glItem_hoverable]
end

function dgsGridListClear(gridlist,clearRow,clearColumn)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListClear",1,"dgs-dxgridlist")) end
	clearRow = clearRow ~= false
	clearColumn = clearColumn and true or false
 	if clearRow then
		dgsGridListClearRow(gridlist)
	end
	if clearColumn then
		dgsGridListClearColumn(gridlist)
	end
	return true
end

function dgsGridListSetItemImage(gridlist,r,c,image,color,offx,offy,w,h,relative)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetItemImage",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cIsNum,rIsNum = type(c) == "number",type(r) == "number"
	local cNInRange,rNInRange = cIsNum and not (c>=1 and c<=cLen),rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListSetItemImage",2,"number","1~"..rLen,rNInRange and "row out of range")) end
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListSetItemImage",3,"number","1~"..cLen,cNInRange and "column out of range")) end
	local c,r = c-c%1,r-r%1
	if not rData[r][c] then return false end
	local imageData = rData[r][c][glItem_image] or {}
	imageData[1] = image or imageData[1] or nil
	imageData[2] = color or imageData[2] or white
	imageData[3] = offx or imageData[3] or 0
	imageData[4] = offy or imageData[4] or 0
	imageData[5] = w or imageData[5] or relative and 1 or dgsGridListGetColumnWidth(gridlist,c,false)
	imageData[6] = h or imageData[6] or relative and 1 or eleData.rowHeight--_RowHeight
	imageData[7] = relative or false
	rData[r][c][glItem_image] = imageData
	return true
end

function dgsGridListRemoveItemImage(gridlist,r,c)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListRemoveItemImage",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cIsNum,rIsNum = type(c) == "number",type(r) == "number"
	local cNInRange,rNInRange = cIsNum and not (c>=1 and c<=cLen),rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListRemoveItemImage",2,"number","1~"..rLen,rNInRange and "row out of range")) end
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListRemoveItemImage",3,"number","1~"..cLen,cNInRange and "column out of range")) end
	local c,r = c-c%1,r-r%1
	if not rData[r][c] then return false end
	rData[r][c][glItem_image] = nil
	return true
end

function dgsGridListGetItemImage(gridlist,r,c)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetItemImage",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cIsNum,rIsNum = type(c) == "number",type(r) == "number"
	local cNInRange,rNInRange = cIsNum and not (c>=1 and c<=cLen),rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListGetItemImage",2,"number","1~"..rLen,rNInRange and "row out of range")) end
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListGetItemImage",3,"number","1~"..cLen,cNInRange and "column out of range")) end
	local c,r = c-c%1,r-r%1
	if not rData[r][c] then return false end
	return unpack(rData[r][c][glItem_image] or {})
end

function dgsGridListSetItemAsSection(gridlist,r,c,enabled)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetItemAsSection",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cIsNum,rIsNum = type(c) == "number",type(r) == "number"
	local cNInRange,rNInRange = cIsNum and not (c>=1 and c<=cLen),rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListSetItemAsSection",2,"number","1~"..rLen,rNInRange and "row out of range")) end
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListSetItemAsSection",3,"number","1~"..cLen,cNInRange and "column out of range")) end
	local c,r = c-c%1,r-r%1
	if enabled then
		if not enableMouseClickAndSelect then
			rData[r][c][glItem_hoverable] = false
			rData[r][c][glItem_selectable] = false
		else
			rData[r][c][glItem_hoverable] = nil
			rData[r][c][glItem_selectable] = nil
		end
	else
		rData[r][c][glItem_hoverable] = nil
		rData[r][c][glItem_selectable] = nil
	end
	rData[r][c][glItem_isSection] = enabled and true or nil --Enable Section Mode
	return true
end

function dgsGridListSetItemText(gridlist,r,c,text,isSection)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetItemText",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cIsNum,rIsNum = type(c) == "number",type(r) == "number"
	local cNInRange,rNInRange = cIsNum and not (c>=1 and c<=cLen),rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListSetItemText",2,"number","1~"..rLen,rNInRange and "row out of range")) end
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListSetItemText",3,"number","1~"..cLen,cNInRange and "column out of range")) end
	local c,r = c-c%1,r-r%1
	if not rData[r][c] then return false end
	if type(text) == "table" then
		rData[r][c]._translation_text = text
		text = dgsTranslate(gridlist,text,sourceResource)
	else
		rData[r][c]._translation_text = nil
	end
	rData[r][c][glItem_text] = tostring(text or "")
	if isSection then
		dgsGridListSetItemAsSection(gridlist,r,c,true)
	end
	if dgsElementData[gridlist].autoSort then
		dgsElementData[gridlist].nextRenderSort = true
	end
	return true
end

function dgsGridListGetItemText(gridlist,r,c)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetItemText",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cIsNum,rIsNum = type(c) == "number",type(r) == "number"
	local cNInRange,rNInRange = cIsNum and not (c>=1 and c<=cLen),rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListGetItemText",2,"number","1~"..rLen,rNInRange and "row out of range")) end
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListGetItemText",3,"number","1~"..cLen,cNInRange and "column out of range")) end
	local c,r = c-c%1,r-r%1
	if not rData[r][c] then return false end
	return rData[r][c][glItem_text]
end

function dgsGridListGetSelectedItem(gridlist)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetSelectedItem",1,"dgs-dxgridlist")) end
	local r,data = next(dgsElementData[gridlist].rowSelect or {})
	local c,bool = next(data or {})
	return r or -1,c or -1
end

function dgsGridListGetPreselectedItem(gridlist)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetPreselectedItem",1,"dgs-dxgridlist")) end
	local preSelect = dgsElementData[gridlist].preSelect or {}
	return preSelect[1] or -1,preSelect[2] or -1
end

function dgsGridListGetSelectedItems(gridlist,isOrigin)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetSelectedItems",1,"dgs-dxgridlist")) end
	local items = dgsElementData[gridlist].rowSelect
	if isOrigin then return items end
	local selectionMode = dgsElementData[gridlist].selectionMode
	local columndata = dgsElementData[gridlist].columnData
	local rowData = dgsElementData[gridlist].rowData
	local newSelectTable = {}
	local cnt = 0
	if not next(items) then return {} end
	if selectionMode == 1 then
		for r,val in pairs(items) do
			for c=1,#columndata do
				cnt = cnt+1
				newSelectTable[cnt] = {row=r,column=c}
			end
		end
		return newSelectTable
	elseif selectionMode == 2 then
		for r=1,#rowData do
			for c,val in pairs(items[1]) do
				cnt = cnt+1
				newSelectTable[cnt] = {row=r,column=c}
			end
		end
		return newSelectTable
	elseif selectionMode == 3 then
		for r,val in pairs(items) do
			for c,_ in pairs(val) do
				cnt = cnt+1
				newSelectTable[cnt] = {row=r,column=c}
			end
		end
		return newSelectTable
	end
	return {}
end

function dgsGridListSetSelectedItems(gridlist,tab,isOrigin)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetSelectedItems",1,"dgs-dxgridlist")) end
	if not (type(tab) == "table") then error(dgsGenAsrt(tab,"dgsGridListSetSelectedItems",2,"table")) end
	local originSel
	if isOrigin == true then
		originSel = {}
		local selectionMode = dgsElementData[gridlist].selectionMode
		if selectionMode == 1 then
			for k,v in ipairs(tab) do
				originSel[v.row] = {true}
			end
		elseif selectionMode == 2 then
			originSel[1] = {}
			for k,v in ipairs(tab) do
				originSel[1][v.column] = true
			end
		elseif selectionMode == 3 then
			for k,v in ipairs(tab) do
				originSel[v.row] = originSel[v.row] or {}
				originSel[v.row][v.column] = true
			end
		end
	end
	dgsSetData(gridlist,"rowSelect",originSel or tab)
	dgsTriggerEvent("onDgsGridListSelect",gridlist,tab,_)
	return true
end

function dgsGridListGetSelectedCount(gridlist,r,c)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetSelectedCount",1,"dgs-dxgridlist")) end
	local r,c = r or -1,c or -1
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cIsNum,rIsNum = type(c) == "number",type(r) == "number"
	local cNInRange,rNInRange = cIsNum and not (c>=1 and c<=cLen or c == -1),rIsNum and not (r>=1 and r<=rLen or r == -1)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListGetSelectedCount",2,"number","-1,1~"..rLen,rNInRange and "row out of range")) end
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListGetSelectedCount",3,"number","-1,1~"..cLen,cNInRange and "column out of range")) end
	local c,r = c-c%1,r-r%1
	local selectedItems = dgsGridListGetSelectedItems(gridlist)
	if r == -1 then
		if c == -1 then
			return #selectedItems
		else
			local cnt = 0
			for i=1,#selectedItems do
				if selectedItems[i].column == c then
					cnt = cnt + 1
				end
			end
			return cnt
		end
	else
		if c == -1 then
			local cnt = 0
			for i=1,#selectedItems do
				if selectedItems[i].row == r then
					cnt = cnt + 1
				end
			end
			return cnt
		else
			for i=1,#selectedItems do
				if selectedItems[i].row == r and selectedItems[i].column == c then
					return 1
				end
			end
			return 0
		end
	end
end

function dgsGridListSetSelectedItem(gridlist,r,c,scrollTo,isOrigin)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetSelectedItem",1,"dgs-dxgridlist")) end
	local r,c = r or -1,c or -1
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cNInRange,rNInRange = not (c>=1 and c<=cLen or c == -1),not (r>=1 and r<=rLen or r == -1)
	if rNInRange then error(dgsGenAsrt(r,"dgsGridListSetSelectedItem",2,"number","-1,1~"..rLen,rNInRange and "row out of range")) end
	if cNInRange then error(dgsGenAsrt(c,"dgsGridListSetSelectedItem",3,"number","-1,1~"..cLen,cNInRange and "column out of range")) end
	local c,r = c-c%1,r-r%1
	local old1,old2
	if eleData.multiSelection then
		old1 = eleData.rowSelect
	else
		data = eleData.rowSelect
		if not next(data) then
			old1 = -1
			old2 = -1
		else
			for k,v in pairs(data) do
				old1 = k
				old2 = v
				break
			end
		end
	end
	local selectionMode = eleData.selectionMode
	if selectionMode == 1 then
		tab = {[r]={}}
		tab[r][1] = true
		dgsSetData(gridlist,"rowSelect",tab)
	elseif selectionMode == 2 then
		local tab = {}
		tab[1] = {[c]=true}
		dgsSetData(gridlist,"rowSelect",tab)
	elseif selectionMode == 3 then
		if r == -1 then r = old1 or r end
		if c == -1 then c = old2 or c end
		dgsSetData(gridlist,"rowSelect",{[r]={[c]=true}})
	end
	eleData.itemClick = {r,c}
	if eleData.multiSelection then
		dgsTriggerEvent("onDgsGridListSelect",gridlist,r,c,old1)
	else
		dgsTriggerEvent("onDgsGridListSelect",gridlist,r,c,old1 or -1,old2 or -1)
	end
	if scrollTo then
		dgsGridListScrollTo(gridlist,r,c)
	end
	return true
end

function dgsGridListSelectItem(gridlist,r,c,state)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSelectItem",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cNInRange,rNInRange = not (c>=1 and c<=cLen),not (r>=1 and r<=rLen)
	if rNInRange then error(dgsGenAsrt(r,"dgsGridListSelectItem",2,"number","1~"..rLen,rNInRange and "row out of range")) end
	if cNInRange then error(dgsGenAsrt(c,"dgsGridListSelectItem",3,"number","1~"..cLen,cNInRange and "column out of range")) end
	local c,r = c-c%1,r-r%1
	local selectedItem = eleData.rowSelect
	if not rData[r][c] then return false end
	if not eleData.multiSelection then
		selectedItem = {}
	end
	local selectionMode = eleData.selectionMode
	if selectionMode == 1 then
		selectedItem[r] = selectedItem[r] or {}
		selectedItem[r][1] = state or nil
		if not next(selectedItem[r]) then
			selectedItem[r] = nil
		end
	elseif selectionMode == 2 then
		selectedItem[1] = selectedItem[1] or {}
		selectedItem[1][c] = state or nil
		if not next(selectedItem[1]) then
			selectedItem[1] = nil
		end
	elseif selectionMode == 3 then
		selectedItem[r] = selectedItem[r] or {}
		selectedItem[r][c] = state or nil
		if not next(selectedItem[r]) then
			selectedItem[r] = nil
		end
	end
	dgsTriggerEvent("onDgsGridListSelect",gridlist,r,c)
	eleData.rowSelect = selectedItem
	return true
end

function dgsGridListItemIsSelected(gridlist,r,c)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListItemIsSelected",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cNInRange,rNInRange = not (c>=1 and c<=cLen),not (r>=1 and r<=rLen)
	if rNInRange then error(dgsGenAsrt(r,"dgsGridListItemIsSelected",2,"number","1~"..rLen,rNInRange and "row out of range")) end
	if cNInRange then error(dgsGenAsrt(c,"dgsGridListItemIsSelected",3,"number","1~"..cLen,cNInRange and "column out of range")) end
	local c,r = c-c%1,r-r%1
	local selectedItem = eleData.rowSelect
	if rData[r][c] then
		local selectionMode = eleData.selectionMode
		if selectionMode == 1 then
			selectedItem[r] = selectedItem[r] or {}
			return selectedItem[r][1] and true or false
		elseif selectionMode == 2 then
			selectedItem[1] = selectedItem[1] or {}
			return selectedItem[1][c] and true or false
		elseif selectionMode == 3 then
			selectedItem[r] = selectedItem[r] or {}
			return selectedItem[r][c] and true or false
		end
	end
	return false
end

function dgsGridListSetItemTextOffset(gridlist,r,c,offsetX,offsetY,relative)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetItemTextOffset",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cNInRange,rNInRange = not (c>=1 and c<=cLen or c == -1),not (r>=1 and r<=rLen or r == -1)
	if rNInRange then error(dgsGenAsrt(r,"dgsGridListSetItemTextOffset",2,"number","-1,1~"..rLen,rNInRange and "row out of range")) end
	if cNInRange then error(dgsGenAsrt(c,"dgsGridListSetItemTextOffset",3,"number","-1,1~"..cLen,cNInRange and "column out of range")) end
	local c,r = c-c%1,r-r%1
	if r == -1 then
		if c == -1 then
			for i=1,rLen do
				for j=1,cLen do
					rData[i][j][glItem_textOffset] = offsetX and {offsetX,offsetY,relative} or nil
				end
			end
		else
			for i=1,rLen do
				rData[i][c][glItem_textOffset] = offsetX and {offsetX,offsetY,relative} or nil
			end
		end
	else
		if c == -1 then
			for j=1,cLen do
				rData[r][j][glItem_textOffset] = offsetX and {offsetX,offsetY,relative} or nil
			end
		else
			rData[r][c][glItem_textOffset] = offsetX and {offsetX,offsetY,relative} or nil
		end
	end
	return true
end

function dgsGridListGetItemTextOffset(gridlist,r,c)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetItemTextOffset",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cNInRange,rNInRange = not (c>=1 and c<=cLen),not (r>=1 and r<=rLen)
	if rNInRange then error(dgsGenAsrt(r,"dgsGridListGetItemTextOffset",2,"number","1~"..rLen,rNInRange and "row out of range")) end
	if cNInRange then error(dgsGenAsrt(c,"dgsGridListGetItemTextOffset",3,"number","1~"..cLen,cNInRange and "column out of range")) end
	local c,r = c-c%1,r-r%1
	return rData[r][c][glItem_textOffset][1],rData[r][c][glItem_textOffset][2],rData[r][c][glItem_textOffset][3]
end

function dgsGridListSetItemColor(gridlist,r,c,...)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetItemColor",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cNInRange,rNInRange = not (c>=1 and c<=cLen or c == -1),not (r>=1 and r<=rLen or r == -1)
	if rNInRange then error(dgsGenAsrt(r,"dgsGridListSetItemColor",2,"number","-1,1~"..rLen,rNInRange and "row out of range")) end
	if cNInRange then error(dgsGenAsrt(c,"dgsGridListSetItemColor",3,"number","-1,1~"..cLen,cNInRange and "column out of range")) end
	local c,r = c-c%1,r-r%1
	--Deal with the color
	local colors
	local args = {...}
	if #args == 0 then
		error(dgsGenAsrt(args[1],"dgsGridListSetItemColor",2,"table/number"))
	elseif #args == 1 then
		if type(args[1]) == "table" then
			colors = {args[1][1],args[1][2] or args[1][1],args[1][3] or args[1][1]}
		else
			colors = {args[1],args[1],args[1]}
		end
	elseif #args >= 3 then
		if not (type(args[1]) == "number") then error(dgsGenAsrt(args[1],"dgsGridListSetItemColor",2,"number")) end
		if not (type(args[2]) == "number") then error(dgsGenAsrt(args[2],"dgsGridListSetItemColor",3,"number")) end
		if not (type(args[3]) == "number") then error(dgsGenAsrt(args[3],"dgsGridListSetItemColor",4,"number")) end
		if not (not args[4] or type(args[4]) == "number") then error(dgsGenAsrt(args[4],"dgsGridListSetItemColor",5,"nil/number")) end
		local clr = tocolor(...)
		colors = {clr,clr,clr}
	end
	if r == -1 then
		if c == -1 then
			for i=1,rLen do
				for j=1,cLen do
					rData[i][j][glItem_textColor] = {colors[1],colors[2],colors[3]}
				end
			end
		else
			for i=1,rLen do
				rData[i][c][glItem_textColor] = {colors[1],colors[2],colors[3]}
			end
		end
	else
		if c == -1 then
			for j=1,cLen do
				rData[r][j][glItem_textColor] = {colors[1],colors[2],colors[3]}
			end
		else
			rData[r][c][glItem_textColor] = {colors[1],colors[2],colors[3]}
		end
	end
	return true
end

function dgsGridListGetItemColor(gridlist,r,c,notSplitColor)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetItemColor",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cNInRange,rNInRange = not (c>=1 and c<=cLen),not (r>=1 and r<=rLen)
	if rNInRange then error(dgsGenAsrt(r,"dgsGridListGetItemColor",2,"number","1~"..rLen,rNInRange and "row out of range")) end
	if cNInRange then error(dgsGenAsrt(c,"dgsGridListGetItemColor",3,"number","1~"..cLen,cNInRange and "column out of range")) end
	local c,r = c-c%1,r-r%1
	if notSplitColor then
		return rData[r][c][glItem_textColor][1],rData[r][c][glItem_textColor][2],rData[r][c][glItem_textColor][3]
	else
		local dR,dG,dB,dA = fromColor(rData[r][c][glItem_textColor][1])
		local hR,hG,hB,hA = fromColor(rData[r][c][glItem_textColor][2])
		local cR,cG,cB,cA = fromColor(rData[r][c][glItem_textColor][3])
		return dR,dG,dB,dA,hR,hG,hB,hA,cR,cG,cB,cA
	end
end

function dgsGridListSetItemBackGroundColorTemplate(gridlist,template,applyToAll)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetItemBackGroundColorTemplate",1,"dgs-dxgridlist")) end
	if not template then return dgsSetData(gridlist,"itemColorTemplate",nil) end
	if type(template) ~= "table" then error(dgsGenAsrt(template,"dgsGridListSetItemBackGroundColorTemplate",2,"table/nil")) end
	if #template == 0 then error(dgsGenAsrt(template,"dgsGridListSetItemBackGroundColorTemplate",2,"table","{{colors,...},...}","Bad Format")) end
	if applyToAll then
		local eleData = dgsElementData[gridlist]
		local cData,rData = eleData.columnData,eleData.rowData
		local cLen,rLen = #cData,#rData
		for i=1,rLen do
			for j=1,cLen do
				rData[i][j][glItem_bgColor] = nil
			end
		end
	end
	dgsSetData(gridlist,"itemColorTemplate",template)
end

function dgsGridListSetItemBackGroundColor(gridlist,r,c,...)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetItemBackGroundColor",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cNInRange,rNInRange = not (c>=1 and c<=cLen or c == -1),not (r>=1 and r<=rLen or r == -1)
	if rNInRange then error(dgsGenAsrt(r,"dgsGridListSetItemBackGroundColor",2,"number","-1,1~"..rLen,rNInRange and "row out of range")) end
	if cNInRange then error(dgsGenAsrt(c,"dgsGridListSetItemBackGroundColor",3,"number","-1,1~"..cLen,cNInRange and "column out of range")) end
	local c,r = c-c%1,r-r%1
	--Deal with the color
	local colors
	local args = {...}
	if #args == 0 then
		error(dgsGenAsrt(args[1],"dgsGridListSetItemBackGroundColor",2,"table/number"))
	elseif #args == 1 and type(args[1]) == "table" then
		colors = args[1]
	elseif #args >= 3 then
		if not (type(args[1]) == "number") then error(dgsGenAsrt(args[1],"dgsGridListSetItemBackGroundColor",2,"number")) end
		if not (type(args[2]) == "number") then error(dgsGenAsrt(args[2],"dgsGridListSetItemBackGroundColor",3,"number")) end
		if not (type(args[3]) == "number") then error(dgsGenAsrt(args[3],"dgsGridListSetItemBackGroundColor",4,"number")) end
		if not (not args[4] or type(args[4]) == "number") then error(dgsGenAsrt(args[4],"dgsGridListSetItemBackGroundColor",5,"nil/number")) end
		local clr = tocolor(...)
		colors = {clr,clr,clr}
	end
	if r == -1 then
		if c == -1 then
			for i=1,rLen do
				for j=1,cLen do
					rData[i][j][glItem_bgColor] = {colors[1],colors[2],colors[3]}
				end
			end
		else
			for i=1,rLen do
				rData[i][c][glItem_bgColor] = {colors[1],colors[2],colors[3]}
			end
		end
	else
		if c == -1 then
			for j=1,cLen do
				rData[r][j][glItem_bgColor] = {colors[1],colors[2],colors[3]}
			end
		else
			rData[r][c][glItem_bgColor] = {colors[1],colors[2],colors[3]}
		end
	end
	return false
end

function dgsGridListGetItemBackGroundColor(gridlist,r,c,notSplitColor)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetItemBackGroundColor",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cNInRange,rNInRange = not (c>=1 and c<=cLen),not (r>=1 and r<=rLen)
	if rNInRange then error(dgsGenAsrt(r,"dgsGridListGetItemBackGroundColor",2,"number","1~"..rLen,rNInRange and "row out of range")) end
	if cNInRange then error(dgsGenAsrt(c,"dgsGridListGetItemBackGroundColor",3,"number","1~"..cLen,cNInRange and "column out of range")) end
	local c,r = c-c%1,r-r%1
	local item = rData[r][c]
	local defColor,hovColor,cliColor
	if item[glItem_bgColor] then
		defColor = item[glItem_bgColor][1]
		hovColor = item[glItem_bgColor][2]
		cliColor = item[glItem_bgColor][3]
	elseif rData[r][glRow_bgColor] then
		defColor = rData[r][glRow_bgColor][1]
		hovColor = rData[r][glRow_bgColor][2]
		cliColor = rData[r][glRow_bgColor][3]
	else
		return false,false,false
	end
	if notSplitColor then
		return defColor,hovColor,cliColor
	else
		local dR,dG,dB,dA = fromColor(defColor)
		local hR,hG,hB,hA = fromColor(hovColor)
		local cR,cG,cB,cA = fromColor(cliColor)
		return dR,dG,dB,dA,hR,hG,hB,hA,cR,cG,cB,cA
	end
end

function dgsGridListSetItemBackGroundImage(gridlist,r,c,nImg,sImg,cImg)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetItemBackGroundImage",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cNInRange,rNInRange = not (c>=1 and c<=cLen or c == -1),not (r>=1 and r<=rLen or r == -1)
	if rNInRange then error(dgsGenAsrt(r,"dgsGridListSetItemBackGroundImage",2,"number","-1,1~"..rLen,rNInRange and "row out of range")) end
	if cNInRange then error(dgsGenAsrt(c,"dgsGridListSetItemBackGroundImage",3,"number","-1,1~"..cLen,cNInRange and "column out of range")) end
	local c,r = c-c%1,r-r%1

	if nImg ~= nil then
		if not isMaterial(nImg) then error(dgsGenAsrt(nImg,"dgsGridListSetItemBackGroundImage",4,"material")) end
	end
	if sImg ~= nil then
		if not isMaterial(sImg) then error(dgsGenAsrt(sImg,"dgsGridListSetItemBackGroundImage",5,"material")) end
	end
	if cImg ~= nil then
		if not isMaterial(cImg) then error(dgsGenAsrt(cImg,"dgsGridListSetItemBackGroundImage",6,"material")) end
	end
	if r == -1 then
		if c == -1 then
			for i=1,rLen do
				for j=1,cLen do
					rData[i][j][glItem_bgImage] = {nImg,sImg,cImg}
				end
			end
		else
			for i=1,rLen do
				rData[i][c][glItem_bgImage] = {nImg,sImg,cImg}
			end
		end
	else
		if c == -1 then
			for j=1,cLen do
				rData[r][j][glItem_bgImage] = {nImg,sImg,cImg}
			end
		else
			rData[r][c][glItem_bgImage] = {nImg,sImg,cImg}
		end
	end
	return false
end

function dgsGridListGetItemBackGroundImage(gridlist,r,c)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetItemBackGroundImage",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cNInRange,rNInRange = not (c>=1 and c<=cLen),not (r>=1 and r<=rLen)
	if rNInRange then error(dgsGenAsrt(r,"dgsGridListGetItemBackGroundImage",2,"number","1~"..rLen,rNInRange and "row out of range")) end
	if cNInRange then error(dgsGenAsrt(c,"dgsGridListGetItemBackGroundImage",3,"number","1~"..cLen,cNInRange and "column out of range")) end
	local c,r = c-c%1,r-r%1
	if rData[r][c][glItem_bgImage] then
		return rData[r][c][glItem_bgImage][1],rData[r][c][glItem_bgImage][2],rData[r][c][glItem_bgImage][3]
	elseif rData[r][glRow_bgImage] then
		return rData[r][glRow_bgImage][1],rData[r][glRow_bgImage][2],rData[r][glRow_bgImage][3]
	end
	return false,false,false
end

function dgsGridListUpdateRowMoveOffset(gridlist,rowMoveOffset)
	local eleData = dgsElementData[gridlist]
	local rowMoveOffset = tonumber(rowMoveOffset) or eleData.rowMoveOffsetTemp
	local rowHeight = eleData.rowHeight--_RowHeight
	local rowHeightLeadingTemp = rowHeight + eleData.leading--_RowHeight
	local scrollbar = eleData.scrollbars[2]
	local scbThickH = dgsElementData[scrollbar].visible and eleData.scrollBarThick or 0
	local h = eleData.absSize[2]
	local columnHeight = eleData.columnHeight
	local rowCount = #eleData.rowData
	local whichRowToStart,whichRowToEnd
	if eleData.rowShowUnclippedOnly then
		local temp1 = rowMoveOffset/rowHeightLeadingTemp
		whichRowToStart = -(temp1-temp1%1)+1
		local temp2 = (h-columnHeight-scbThickH)/rowHeightLeadingTemp--_RowHeight
		whichRowToEnd = whichRowToStart+temp2-temp2%1-1
	else
		local temp1 = rowMoveOffset/rowHeightLeadingTemp
		whichRowToStart = -(temp1-temp1%1)
		local temp2 = (-rowMoveOffset+h-columnHeight-scbThickH)/rowHeightLeadingTemp--_RowHeight
		whichRowToEnd = temp2-temp2%1+1
	end
	eleData.FromTo = {whichRowToStart > 0 and whichRowToStart or 1,whichRowToEnd <= rowCount and whichRowToEnd or rowCount}
end

function configGridList(gridlist)
	local eleData = dgsElementData[gridlist]
	local scrollbar = eleData.scrollbars
	local w,h = eleData.absSize[1],eleData.absSize[2]
	local columnHeight,rowHeight,leading = eleData.columnHeight,eleData.rowHeight,eleData.leading--_RowHeight
	local scbThick = eleData.scrollBarThick
	local columnWidth = dgsGridListGetColumnAllWidth(gridlist,#eleData.columnData,false,true)
	local rowLength = #eleData.rowData*(rowHeight+leading)--_RowHeight
	local scbX,scbY = w-scbThick,h-scbThick
	local oriScbStateV,oriScbStateH = dgsElementData[scrollbar[1]].visible,dgsElementData[scrollbar[2]].visible
	local scbStateV,scbStateH
	if columnWidth > w then
		scbStateH = true
	elseif columnWidth < w-scbThick then
		scbStateH = false
	end
	if rowLength > h-columnHeight then
		scbStateV = true
	elseif rowLength < h-columnHeight-scbThick then
		scbStateV = false
	end
	if scbStateH == nil then scbStateH = scbStateV end
	if scbStateV == nil then scbStateV = scbStateH end
	local forceState = eleData.scrollBarState
	if forceState[1] ~= nil then scbStateV = forceState[1] end
	if forceState[2] ~= nil then scbStateH = forceState[2] end
	local scbThickV,scbThickH = scbStateV and scbThick or 0,scbStateH and scbThick or 0
	local relSizX,relSizY = w-scbThickV,h-scbThickH
	local rowShowRange = relSizY-columnHeight
	local columnShowRange = relSizX
	--if scbStateH and scbStateH ~= oriScbStateH then
		--dgsSetData(scrollbar[2],"scrollPosition",0)
	--end
	--if scbStateV and scbStateV ~= oriScbStateV  then
		--dgsSetData(scrollbar[1],"scrollPosition",0)
	--end
	dgsSetVisible(scrollbar[1],scbStateV and true or false)
	dgsSetVisible(scrollbar[2],scbStateH and true or false)
	
	local scb1Y,scb1H = 0,relSizY
	if not dgsElementData[gridlist].scrollBarCoverColumn then
		scb1Y,scb1H = scb1Y+columnHeight,scb1H-columnHeight
	end
	dgsSetPosition(scrollbar[1],scbX,scb1Y,false)
	dgsSetPosition(scrollbar[2],0,scbY,false)
	dgsSetSize(scrollbar[1],scbThick,scb1H,false)
	dgsSetSize(scrollbar[2],relSizX,scbThick,false)
	local scroll1 = dgsElementData[scrollbar[1]].scrollPosition
	local scroll2 = dgsElementData[scrollbar[2]].scrollPosition
	dgsSetData(gridlist,"rowMoveOffset",-scroll1*(rowLength-rowShowRange)/100)

	local scbLengthVrt = eleData.scrollBarLength[1]
	local higLen = 1-(rowLength-rowShowRange)/rowLength
	higLen = higLen >= 0.95 and 0.95 or higLen
	dgsSetData(scrollbar[1],"length",scbLengthVrt or {higLen,true})
	local verticalScrollSize = eleData.scrollSize/(rowLength-rowShowRange)
	dgsSetData(scrollbar[1],"multiplier",{verticalScrollSize,true})
	dgsSetData(scrollbar[1],"moveType","sync")

	local scbLengthHoz = dgsElementData[gridlist].scrollBarLength[2]
	local widLen = 1-(columnWidth-columnShowRange)/columnWidth
	widLen = widLen >= 0.95 and 0.95 or widLen
	dgsSetData(scrollbar[2],"length",scbLengthHoz or {widLen,true})
	local horizontalScrollSize = eleData.scrollSize*5/(columnWidth-columnShowRange)
	dgsSetData(scrollbar[2],"multiplier",{horizontalScrollSize,true})
	dgsSetData(scrollbar[2],"moveType","sync")
	dgsGridListRecreateRenderTarget(gridlist,true)
	dgsGridListUpdateRowMoveOffset(gridlist)
	eleData.configNextFrame = false
end

----------------------------------------------------------------
-----------------------PropertyListener-------------------------
----------------------------------------------------------------
dgsOnPropertyChange["dgs-dxgridlist"] = {
	columnHeight = configGridList,
	scrollBarThick = configGridList,
	scrollBarState = configGridList,
	leading = configGridList,
	scrollBarCoverColumn = configGridList,
	rowData = function(dgsEle,key,value,oldValue)
		if dgsElementData[dgsEle].autoSort then
			dgsElementData[dgsEle].nextRenderSort = true
		end
	end,
	rowMoveOffset = dgsGridListUpdateRowMoveOffset,
	defaultSortFunctions = function(dgsEle,key,value,oldValue)
		local sortFunction = dgsElementData[dgsEle].sortFunction
		local oldDefSortFnc = oldValue
		local oldUpperSortFnc = gridlistSortFunctions[oldDefSortFnc[1]]
		local oldLowerSortFnc = gridlistSortFunctions[oldDefSortFnc[2]]
		local defSortFnc = dgsElementData[dgsEle].defaultSortFunctions
		local upperSortFnc = gridlistSortFunctions[defSortFnc[1]]
		local lowerSortFnc = gridlistSortFunctions[defSortFnc[2]]
		local oldSort = sortFunction == oldLowerSortFnc and lowerSortFnc or upperSortFnc
	end,
}

----------------------------------------------------------------
---------------------Translation Updater------------------------
----------------------------------------------------------------
dgsOnTranslationUpdate["dgs-dxgridlist"] = function(dgsEle,key,value)
	local columnData = dgsElementData[dgsEle].columnData
	for cIndex=1,#columnData do
		local text = columnData[cIndex]._translation_text
		if text then
			if key then text[key] = value end
			columnData[cIndex][glCol_text] = dgsTranslate(dgsEle,text,sourceResource)
		end
		local font = columnData[cIndex]._translation_font
		if font then
			columnData[cIndex][glCol_textFont] = dgsGetTranslationFont(dgsEle,font,sourceResource)
		end
	end
	dgsSetData(dgsEle,"columnData",columnData)
	local rowData = dgsElementData[dgsEle].rowData
	for rID=1,#rowData do
		for cID=1,#rowData[rID] do
			local text = rowData[rID][cID]._translation_text
			if text then
				if key then text[key] = value end
				rowData[rID][cID][glItem_text] = dgsTranslate(dgsEle,text,sourceResource)
			end
			local font = rowData[rID][cID]._translation_font
			if font then
				rowData[rID][cID][glItem_textFont] = dgsGetTranslationFont(dgsEle,font,sourceResource)
			end
		end
	end
	dgsSetData(dgsEle,"rowData",rowData)
end

----------------------------------------------------------------
-----------------------VisibilityManage-------------------------
----------------------------------------------------------------
dgsOnVisibilityChange["dgs-dxgridlist"] = function(dgsElement,selfVisibility,inheritVisibility)
	if not selfVisibility or not inheritVisibility then
		dgsGridListRecreateRenderTarget(dgsElement,true)
	end
end
----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxgridlist"] = function(source,x,y,w,h,mx,my,cx,cy,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt,xRT,yRT,xNRT,yNRT,OffsetX,OffsetY,visible)
	if eleData.configNextFrame then configGridList(source) end
	local scrollbar = eleData.scrollbars
	if MouseData.hit == source then
		MouseData.topScrollable = source
	end
	local bgColor,bgImage = applyColorAlpha(eleData.bgColor,parentAlpha),eleData.bgImage
	local columnColor,columnImage = applyColorAlpha(eleData.columnColor,parentAlpha),eleData.columnImage
	
	local res = eleData.resource or "global"
	local style = styleManager.styles[res]
	local using = style.using
	style = style.loaded[using]
	local systemFont = style.systemFontElement

	local font = eleData.font or systemFont
	local columnHeight = eleData.columnHeight
	local columnData,rowData = eleData.columnData,eleData.rowData
	local columnCount,rowCount = #columnData,#rowData
	local columnTextColor = eleData.columnTextColor
	local columnWordBreak = eleData.columnWordBreak
	local rowHeight = eleData.rowHeight--_RowHeight
	local rowTextPosOffset = eleData.rowTextPosOffset
	local rowWordBreak = eleData.rowWordBreak
	local rowColor = eleData.rowColor
	local itemColorTemplate = eleData.itemColorTemplate
	local rowImage = eleData.rowImage
	local columnTextPosOffset = eleData.columnTextPosOffset
	local leading = eleData.leading
	local scbThick = eleData.scrollBarThick
	local scrollbars = eleData.scrollbars
	local scb1,scb2 = scrollbars[1],scrollbars[2]
	local scbThickV,scbThickH = dgsElementData[scb1].visible and scbThick or 0,dgsElementData[scb2].visible and scbThick or 0
	local viewWidth,viewHeight = w-scbThickV,h-scbThickH
	local colorCoded = eleData.colorCoded
	local rowShadow = eleData.rowShadow
	local rowHeightLeadingTemp = rowHeight+leading--_RowHeight
	--Smooth Row
	local _rowMoveOffset = eleData.rowMoveOffset
	local rowMoveOffset = _rowMoveOffset
	if eleData.rowMoveOffsetTemp ~= _rowMoveOffset then
		local mHardness = 1
		local moveType = dgsElementData[scb1].moveType
		if moveType == "slow" then
			mHardness = eleData.moveHardness[1]
		elseif moveType == "fast" then
			mHardness = eleData.moveHardness[2]
		end
		eleData.rowMoveOffsetTemp = mathLerp(mHardness,eleData.rowMoveOffsetTemp,_rowMoveOffset)
		local rMoveOffset = eleData.rowMoveOffsetTemp-eleData.rowMoveOffsetTemp%1
		if _rowMoveOffset-eleData.rowMoveOffsetTemp <= 0.5 and _rowMoveOffset-eleData.rowMoveOffsetTemp >= -0.5 then
			eleData.rowMoveOffsetTemp = _rowMoveOffset
			dgsElementData[scb1].moveType = "sync"
		end
		dgsGridListUpdateRowMoveOffset(source)
		rowMoveOffset = rMoveOffset
	end
	if eleData.rowShowUnclippedOnly then
		rowMoveOffset = (1-eleData.FromTo[1])*rowHeightLeadingTemp--_RowHeight
	end
	--Smooth Column
	local _columnMoveOffset = eleData.columnMoveOffset
	local columnMoveOffset = _columnMoveOffset
	if eleData.columnMoveOffsetTemp ~= _columnMoveOffset then
		local mHardness = 1
		local moveType = dgsElementData[scb2].moveType
		if moveType == "slow" then
			mHardness = eleData.moveHardness[1]
		elseif moveType == "fast" then
			mHardness = eleData.moveHardness[2]
		end
		eleData.columnMoveOffsetTemp = mathLerp(mHardness,eleData.columnMoveOffsetTemp,_columnMoveOffset)
		local cMoveOffset = eleData.columnMoveOffsetTemp-eleData.columnMoveOffsetTemp%1
		if _columnMoveOffset-eleData.columnMoveOffsetTemp <= 0.5 and _columnMoveOffset-eleData.columnMoveOffsetTemp >= -0.5 then
			eleData.columnMoveOffsetTemp = _columnMoveOffset
			dgsElementData[scb2].moveType = "sync"
		end
		columnMoveOffset = cMoveOffset
	end
	--
	local columnOffset = eleData.columnOffset
	local rowTextSx,rowTextSy = eleData.rowTextSize[1],eleData.rowTextSize[2] or eleData.rowTextSize[1]
	local columnTextSx,columnTextSy = eleData.columnTextSize[1],eleData.columnTextSize[2] or eleData.columnTextSize[1]
	local selectionMode = eleData.selectionMode
	local clip = eleData.clip
	local mouseInsideGridList = false
	if mx and my then
		mouseInsideGridList = mx >= cx and mx <= cx+w and my >= cy and my <= cy+viewHeight
	end
	local mouseInsideColumn = mouseInsideGridList and my <= cy+columnHeight
	local mouseInsideRow = mouseInsideGridList and my > cy+columnHeight
	local mouseColumnPos = mouseInsideGridList and mx-cx
	eleData.selectedColumn = -1
	local defaultSortFunctions,sortIcon
	local sortColumn = eleData.sortColumn
	if eleData.sortEnabled then
		defaultSortFunctions = eleData.defaultSortFunctions
		sortIcon = eleData.sortFunction == gridlistSortFunctions[defaultSortFunctions[1]] and eleData.defaultSortIcons[1] or (eleData.sortFunction == gridlistSortFunctions[defaultSortFunctions[2]] and eleData.defaultSortIcons[2]) or nil
	end
	if sortColumn and columnData[sortColumn] then
		if eleData.nextRenderSort then
			dgsGridListSort(source)
			eleData.nextRenderSort = false
		end
	end
	local backgroundOffset = eleData.backgroundOffset

	local renderBuffer = eleData.renderBuffer
	local columnPos = renderBuffer.columnPos
	local columnEndPos = renderBuffer.columnEndPos
	local columnShadow = eleData.columnShadow
	local shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont
	if eleData.retrieveRT then
		dgsGridListRecreateRenderTarget(source)
	end
	dxSetRenderTarget(eleData.columnRT,true)
	dxSetBlendMode("modulate_add")
	local multiplier = eleData.columnRelative and viewWidth or 1
	local tempColumnOffset = columnMoveOffset+columnOffset
	local mouseSelectColumn = -1
	local cPosStart,cPosEnd
	if columnShadow then
		shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont = columnShadow[1],columnShadow[2],applyColorAlpha(columnShadow[3],parentAlpha),columnShadow[4],columnShadow[5]
	end
	for id = 1,#columnData do
		local cCol = columnData[id]
		local cTextColor = applyColorAlpha(cCol[glCol_textColor] or columnTextColor,parentAlpha)
		local cTextColorCoded = cCol[glCol_textColorCoded] or colorCoded
		local cTextScaleX,cTextScaleY = cCol[glCol_textScaleX] or columnTextSx,cCol[glCol_textScaleY] or columnTextSy
		local cTextFont = cCol[glCol_textFont] or eleData.columnFont or font
		local tempCpos = cCol[glCol_widthSum]*multiplier
		local _tempStartx = tempCpos+tempColumnOffset
		local _tempEndx = _tempStartx+cCol[glCol_width]*multiplier
		if _tempStartx <= w and _tempEndx >= 0 then
			columnPos[id],columnEndPos[id] = tempCpos,_tempEndx
			cPosStart,cPosEnd = cPosStart or id,id
			if eleData.columnRT then
				local _tempStartx = eleData.PixelInt and _tempStartx-_tempStartx%1 or _tempStartx
				local textPosL = _tempStartx+columnTextPosOffset[1]
				local textPosT = columnTextPosOffset[2]
				local textPosR = _tempEndx+columnTextPosOffset[1]
				local textPosB = columnHeight+columnTextPosOffset[2]
				if sortColumn == id and sortIcon then
					local iconWidth = dxGetTextWidth(sortIcon,cTextScaleX*0.8,cTextFont)
					local iconTextPosL = textPosL-iconWidth
					local iconTextPosR = textPosR-iconWidth
					dgsDrawText(sortIcon,iconTextPosL-1,textPosT,iconTextPosR-1,textPosB,cTextColor,cTextScaleX*0.8,cTextScaleY*0.8,cTextFont,"left","center",clip,columnWordBreak,false,false,false,0,0,0,0,shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont)
				end
				dgsDrawText(cCol[glCol_text],textPosL,textPosT,textPosR,textPosB,cTextColor,cTextScaleX,cTextScaleY,cTextFont,cCol[glCol_textAlignment],"center",clip,columnWordBreak,false,cTextColorCoded,false,0,0,0,0,shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont)
			end
			if mouseInsideGridList and mouseSelectColumn == -1 then
				if mouseColumnPos >= _tempStartx and mouseColumnPos <= _tempEndx then
					mouseSelectColumn = id
				end
			end
		end
	end
	local preSelectLastFrame = eleData.preSelectLastFrame
	local preSelect = eleData.preSelect
	if mouseInsideRow then
		local toffset = (eleData.FromTo[1]*rowHeightLeadingTemp)+rowMoveOffset--_RowHeight
		local tempID = (my-cy-columnHeight-toffset)/rowHeightLeadingTemp--_RowHeight
		local sid = (tempID-tempID%1)+eleData.FromTo[1]+1
		if sid >= 1 and sid <= rowCount and my-cy-columnHeight < sid*rowHeight+(sid-1)*leading+rowMoveOffset then--_RowHeight
			eleData.oPreSelect = sid
			local rowAllowHover = rowData[sid][glRow_hoverable] ~= false
			local itemAllowHover = true
			if mouseSelectColumn ~= -1 then
				itemAllowHover = (rowData[sid][mouseSelectColumn][glItem_hoverable] == nil and rowAllowHover) or rowData[sid][mouseSelectColumn][glItem_hoverable]
			end
			if itemAllowHover then
				preSelect[1],preSelect[2] = sid,mouseSelectColumn
			elseif rowAllowHover then
				preSelect[1],preSelect[2] = sid,-1
			else
				preSelect[1],preSelect[2] = -1,-1
			end
		else
			preSelect[1],preSelect[2] = -1,mouseSelectColumn
		end
	elseif mouseInsideColumn then
		eleData.selectedColumn = mouseSelectColumn
		preSelect[1],preSelect[2] = -1,mouseSelectColumn
	else
		preSelect[1],preSelect[2] = -1,-1
	end
	local preSelect = eleData.preSelect
	if preSelectLastFrame[1] ~= preSelect[1] or preSelectLastFrame[2] ~= preSelect[2] then
		dgsTriggerEvent("onDgsGridListHover",source,preSelect[1],preSelect[2],preSelectLastFrame[1],preSelectLastFrame[2])
		preSelectLastFrame[1],preSelectLastFrame[2] = preSelect[1],preSelect[2]
	end
	local Select = eleData.rowSelect
	local sectionFont = eleData.sectionFont or font
	local textBufferCnt = 0
	local elementBuffer = renderBuffer.elementBuffer
	local textBuffer = renderBuffer.textBuffer
	local sectionColumnOffset = eleData.sectionColumnOffset
	local defaultColumnOffset = eleData.defaultColumnOffset
	if eleData.rowRT then
		dxSetRenderTarget(eleData.rowRT,true)
		dxSetBlendMode("blend")
		if cPosStart and cPosEnd then
			for i=eleData.FromTo[1],eleData.FromTo[2] do
				if not elementBuffer[i] then elementBuffer[i] = {} end
				local cRow = rowData[i]
				local image = cRow[glRow_bgImage] or rowImage
				local isSection = cRow[glRow_isSection]
				local color = cRow[glRow_bgColor] or rowColor
				local rowpos = i*rowHeight+rowMoveOffset+(i-1)*leading--_RowHeight
				local rowpos_1 = rowpos-rowHeight--_RowHeight
				local _x,_y,_sx,_sy = tempColumnOffset,rowpos_1,sW,rowpos
				for id = cPosStart,cPosEnd do
					local cItem = cRow[id]
					local text = cItem[glItem_text]
					local isSection = cItem[glItem_isSection] == nil and isSection or cItem[glItem_isSection]
					local columnOffset = (isSection and sectionColumnOffset or cItem[glItem_columnOffset] or 0)
					local _txtFont = isSection and (cItem[glItem_textFont] or sectionFont) or (cItem[glItem_textFont] or eleData.rowFont or eleData.columnFont or font)
					local _txtScalex = cItem[glItem_textScaleX] or rowTextSx
					local _txtScaley = cItem[glItem_textScaleY] or rowTextSy
					local alignment = cItem[glItem_textAlignment] or columnData[id][glCol_textAlignment]
					
					local itemBGColor,itemBGImage = cItem[glItem_bgColor],cItem[glItem_bgImage] or image
					if not itemBGColor then
						if itemColorTemplate then
							local iCTRows = #itemColorTemplate or 0
							local iCTRow = ((i-1)%iCTRows)+1
							local iCTColumns = #itemColorTemplate[iCTRow] or 0
							local iCTColumn = ((id-1)%iCTColumns)+1
							itemBGColor = itemColorTemplate[iCTRow][iCTColumn]
						else
							itemBGColor = color
						end
					end
					local rowState = 1
					if selectionMode == 1 then
						if i == preSelect[1] then
							rowState = 2
						end
						if Select[i] and Select[i][1] then
							rowState = 3
						end
					elseif selectionMode == 2 then
						if id == preSelect[2] then
							rowState = 2
						end
						if Select[1] and Select[1][id] then
							rowState = 3
						end
					elseif selectionMode == 3 then
						if i == preSelect[1] and id == preSelect[2] then
							rowState = 2
						end
						if Select[i] and Select[i][id] then
							rowState = 3
						end
					end
					local _x = _x+columnPos[id]
					local _sx = columnEndPos[id]
					local columnWidth = columnData[id][glCol_width]*multiplier
					local _bgX = _x
					local backgroundWidth = columnWidth
					if id == 1 then
						_bgX = _x+backgroundOffset
						backgroundWidth = columnWidth-backgroundOffset
					end
					local itemUsingBGColor,itemUsingBGImage = applyColorAlpha(itemBGColor[rowState] or color[rowState],parentAlpha),itemBGImage[rowState] or image[rowState]
					if itemUsingBGImage then
						if not eleData.rowImageStyle or eleData.rowImageStyle == 1 then
							dxDrawImage(_bgX,_y,backgroundWidth,rowHeight,itemUsingBGImage,0,0,0,itemUsingBGColor)--_RowHeight
						elseif eleData.rowImageStyle == 2 then
							local columnWidth = dgsGridListGetColumnAllWidth(source,#eleData.columnData)
							if viewWidth > columnWidth then
								columnWidth = viewWidth+backgroundOffset
							end
							if id == columnCount and _bgX+backgroundWidth <= viewWidth then
								backgroundWidth = viewWidth-_bgX
							end
							local imageType = dgsGetType(itemUsingBGImage)
							local materialWidth,materialHeight = backgroundWidth,rowHeight
							if imageType == "texture" or imageType == "svg" then
								materialWidth,materialHeight = dxGetMaterialSize(itemUsingBGImage)
							end
							dxDrawImageSection(_bgX,_y,backgroundWidth,rowHeight,-materialWidth*(columnMoveOffset-_bgX)/(columnWidth-backgroundOffset),0,materialWidth*backgroundWidth/(columnWidth-backgroundOffset),materialHeight,itemUsingBGImage,0,0,0,itemUsingBGColor)--_RowHeight
						elseif eleData.rowImageStyle == 3 then
							if _bgX+backgroundWidth >= viewWidth then
								backgroundWidth = viewWidth-_bgX
							elseif id == columnCount and _bgX+backgroundWidth <= viewWidth then
								backgroundWidth = viewWidth-_bgX
							end
							local imageType = dgsGetType(itemUsingBGImage)
							local materialWidth,materialHeight = backgroundWidth,rowHeight
							if imageType == "texture" or imageType == "svg" then
								materialWidth,materialHeight = dxGetMaterialSize(itemUsingBGImage)
							end
							dxDrawImageSection(_bgX,_y,backgroundWidth,rowHeight,materialWidth*_bgX/viewWidth,0,materialWidth*backgroundWidth/viewWidth,materialHeight,itemUsingBGImage,0,0,0,itemUsingBGColor)--_RowHeight
						end
					else
						dxDrawImage(_bgX,_y,backgroundWidth,rowHeight,itemUsingBGImage,0,0,0,itemUsingBGColor)--_RowHeight
					end
					elementBuffer[i][id] = elementBuffer[i][id] or {}
					local eBuffer = elementBuffer[i][id]
					eBuffer[1] = cItem[glItem_attachedElement]
					eBuffer[2] = _x
					eBuffer[3] = _y
					if text then
						local colorCoded = cItem[glItem_textColorCoded] == nil and colorCoded or cItem[glItem_textColorCoded]
						if cItem[glItem_image] then
							local imageData = cItem[glItem_image]
							local imagex = _x+(imageData[7] and imageData[3]*columnWidth or imageData[3])
							local imagey = _y+(imageData[7] and imageData[4]*rowHeight or imageData[4])--_RowHeight
							local imagew = imageData[7] and imageData[5]*columnWidth or imageData[5]
							local imageh = imageData[7] and imageData[6]*rowHeight or imageData[6]--_RowHeight
							dxDrawImage(imagex,imagey,imagew,imageh,imageData[1],0,0,0,imageData[2])
						end
						local textXS,textYS,textXE,textYE = _x+columnOffset,_y,_sx,_sy
						if cItem[glItem_textOffset] then
							local itemTextOffsetX = cItem[glItem_textOffset][3] and columnWidth*cItem[glItem_textOffset][1] or cItem[glItem_textOffset][1]
							local itemTextOffsetY = cItem[glItem_textOffset][3] and rowHeight*cItem[glItem_textOffset][2] or cItem[glItem_textOffset][2]--_RowHeight
							textXS,textYS,textXE,textYE = textXS+itemTextOffsetX,textYS+itemTextOffsetY,textXE+itemTextOffsetX,textYE+itemTextOffsetY
						end
						textBufferCnt = textBufferCnt+1
						if not textBuffer[textBufferCnt] then textBuffer[textBufferCnt] = {} end
						local tBuffer = textBuffer[textBufferCnt]
						tBuffer[1] = cItem[1]	--Text
						tBuffer[2] = textXS-textXS%1			--startX
						tBuffer[3] = textYS-textYS%1			--startY
						tBuffer[4] = textXE-textXE%1			--endX
						tBuffer[5] = textYE-textYE%1			--endY
						tBuffer[6] = applyColorAlpha(type(cItem[glItem_textColor]) == "table" and cItem[glItem_textColor][rowState] or cItem[glItem_textColor],parentAlpha)
						tBuffer[7] = _txtScalex
						tBuffer[8] = _txtScaley
						tBuffer[9] = _txtFont
						tBuffer[10] = colorCoded
						tBuffer[11] = alignment
					end
				end
			end
		end
		dxSetBlendMode("modulate_add")
		if rowShadow then
			shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont = rowShadow[1],rowShadow[2],applyColorAlpha(rowShadow[3],parentAlpha),rowShadow[4],rowShadow[5]
		end
		for a=1,textBufferCnt do
			local line = textBuffer[a]
			local text = line[1]
			local psx,psy,pex,pey = line[2]+rowTextPosOffset[1],line[3]+rowTextPosOffset[2],line[4]+rowTextPosOffset[1],line[5]+rowTextPosOffset[2]
			local clr,tSclx,tScly,tFnt,tClrCode,tHozAlign = line[6],line[7],line[8],line[9],line[10],line[11]
			dgsDrawText(line[1],psx,psy,pex,pey,clr,tSclx,tScly,tFnt,tHozAlign,"center",clip,rowWordBreak,false,tClrCode,true,0,0,0,0,shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont)
		end
		
		if not eleData.childOutsideHit then
			if MouseData.hit ~= source then
				enabledInherited = false
			end
		end
		if cPosStart and cPosEnd then
			for i=eleData.FromTo[2],eleData.FromTo[1],-1 do
				for id = cPosStart,cPosEnd do
					local item = elementBuffer[i][id]
					if item and item[1] then
						local offx,offy = item[2],item[3]
						for a=1,#item[1] do
							renderGUI(item[1][a],mx,my,enabledInherited,enabledSelf,eleData.rowRT,0,0,xNRT,yNRT+columnHeight,offx,offy,parentAlpha,visible)
						end
					end
				end
			end
		end
	end
	dxSetBlendMode(rndtgt and "modulate_add" or "blend")
	dxSetRenderTarget(rndtgt)
	dxDrawImage(x,y+columnHeight,w,h-columnHeight,bgImage,0,0,0,bgColor,isPostGUI,rndtgt)
	dxDrawImage(x,y,w,columnHeight,columnImage,0,0,0,columnColor,isPostGUI,rndtgt)
	dxSetBlendMode(rndtgt and "modulate_add" or "add")
	if eleData.rowRT then
		dxDrawImage(x,y+columnHeight,viewWidth,viewHeight-columnHeight,eleData.rowRT,0,0,0,white,isPostGUI)
	end
	if eleData.columnRT then
		dxDrawImage(x,y,viewWidth,columnHeight,eleData.columnRT,0,0,0,white,isPostGUI)
	end
	dxSetBlendMode(rndtgt and "modulate_add" or "blend")
	return rndtgt,false,mx,my,0,0
end

----------------------------------------------------------------
-------------------------Children Renderer----------------------
----------------------------------------------------------------
dgsChildRenderer["dgs-dxgridlist"] = function(children,mx,my,enabledInherited,enabledSelf,rndtgt,xRT,yRT,xNRT,yNRT,OffsetX,OffsetY,parentAlpha)
	for i=1,#children do
		local child = children[i]
		if not dgsElementData[child].attachedToGridList then
			renderGUI(child,mx,my,enabledInherited,enabledSelf,rndtgt,xRT,yRT,xNRT,yNRT,OffsetX,OffsetY,parentAlpha)
		end
	end
end