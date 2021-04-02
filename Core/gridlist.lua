local loadstring = loadstring
--Dx Functions
local dxDrawImage = dxDrawImageExt
local dxDrawText = dxDrawText
local dxDrawRectangle = dxDrawRectangle
local dxSetRenderTarget = dxSetRenderTarget
local dxGetTextWidth = dxGetTextWidth
local dxSetBlendMode = dxSetBlendMode
local dxCreateRenderTarget = dxCreateRenderTarget
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
local triggerEvent = triggerEvent
local createElement = createElement
local assert = assert
local tonumber = tonumber
local loadstring = loadstring
local type = type
local setmetatable = setmetatable
local setfenv = setfenv
local mathLerp = math.lerp
local tableSort = table.sort
local tableInsert = table.insert
local tableRemove = table.remove
local tableRemoveItemFromArray = table.removeItemFromArray
local utf8Len = utf8.len
sortFunctions = {}
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
	local style = styleSettings.gridlist
	local relative = relative or false
	local scbThick = style.scrollBarThick
	local columnHeight = tonumber(columnHeight) or style.columnHeight
	local cColorR = cColorR or style.rowColor[1]
	local hColorR = hColorR or style.rowColor[2]
	local sColorR = sColorR or style.rowColor[3]
	local nImageR = nImageR or dgsCreateTextureFromStyle(style.rowImage[1])
	local hImageR = hImageR or dgsCreateTextureFromStyle(style.rowImage[2])
	local sImageR = sImageR or dgsCreateTextureFromStyle(style.rowImage[3])
	local gridlist = createElement("dgs-dxgridlist")
	dgsSetType(gridlist,"dgs-dxgridlist")
	dgsSetParent(gridlist,parent,true,true)
	dgsElementData[gridlist] = {
		autoSort = true,
		backgroundOffset = style.backgroundOffset,
		bgImage = bgImage or dgsCreateTextureFromStyle(style.bgImage),
		bgColor = bgColor or style.bgColor,
		colorcoded = false,
		clip = true,
		columnColor = columnColor or style.columnColor,
		columnData = {},
		columnHeight = columnHeight,
		columnImage = columnImage or dgsCreateTextureFromStyle(style.columnImage),
		columnMoveOffset = 0,
		columnMoveOffsetTemp = 0,
		columnTextColor = columnTextColor or style.columnTextColor,
		columnTextPosOffset = {0,0},
		columnTextSize = style.columnTextSize,
		columnOffset = style.columnOffset,
		columnRelative = true,
		columnShadow = false,
		defaultColumnOffset = style.defaultColumnOffset,
		enableNavigation = true,
		font = style.font or systemFont,
		guiCompat = false,
		itemClick = {},
		lastSelectedItem = {1,1},
		leading = 0,
		mode = false,
		mouseSelectButton = {true,false,false},
		moveHardness = {0.1,0.9},
		moveType = 0,	--0 for wheel, 1 For scroll bar
		multiSelection = false,
		nextRenderSort = false,
		preSelect = {-1,-1},
		preSelectLastFrame = {-1,-1},
		rowColor = {cColorR,hColorR,sColorR},	--Normal/Hover/Selected
		rowData = {},
		rowHeight = style.rowHeight,
		rowImage = {nImageR,hImageR,sImageR},	--Normal/Hover/Selected
		rowMoveOffset = 0,
		rowMoveOffsetTemp = 0,
		rowTextSize = style.rowTextSize,
		rowTextColor = style.rowTextColor,
		rowTextPosOffset = {0,0},
		rowSelect = {},
		rowShadow = false,
		scrollBarThick = scbThick,
		scrollBarLength = {},
		scrollBarState = {nil,nil},
		scrollFloor = {false,false},--move offset ->int or float
		scrollSize = 60,			--60 pixels
		sectionColumnOffset = style.sectionColumnOffset,
		sectionFont = systemFont,
		selectedColumn = -1,
		selectionMode = 1,
		sortColumn = false,
		sortEnabled = true,
		defaultSortFunctions = {"greaterUpper","greaterLower"},
		renderBuffer = {
			columnEndPos = {},
			columnPos = {},
			textBuffer = {},
			elementBuffer = {},
		},
	}
	dgsGridListSetSortFunction(gridlist,sortFunctions_upper)
	dgsAttachToTranslation(gridlist,resourceTranslation[sourceResource or resource])
	dgsElementData[gridlist].configNextFrame = false
	calculateGuiPositionSize(gridlist,x,y,relative,w,h,relative,true)
	local aSize = dgsElementData[gridlist].absSize
	local abx,aby = aSize[1],aSize[2]
	local columnRender,rowRender
	if abx*columnHeight ~= 0 then
		columnRender,err = dxCreateRenderTarget(abx,columnHeight,true,gridlist,sourceResource)
		if columnRender ~= false then
			dgsAttachToAutoDestroy(columnRender,gridlist,-1)
		else
			outputDebugString(err,2)
		end
	end
	if abx*(aby-columnHeight-scbThick) ~= 0 then
		rowRender,err = dxCreateRenderTarget(abx,aby-columnHeight-scbThick,true,gridlist,sourceResource)
		if rowRender ~= false then
			dgsAttachToAutoDestroy(rowRender,gridlist,-2)
		else
			outputDebugString(err,2)
		end
	end
	dgsSetData(gridlist,"renderTarget",{columnRender,rowRender})
	local scrollbar1 = dgsCreateScrollBar(abx-scbThick,0,scbThick,aby-scbThick,false,false,gridlist)
	dgsSetData(scrollbar1,"attachedToParent",gridlist)
	local scrollbar2 = dgsCreateScrollBar(0,aby-scbThick,abx-scbThick,scbThick,true,false,gridlist)
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
	triggerEvent("onDgsCreate",gridlist,sourceResource)
	return gridlist
end

function checkGridListScrollBar(scb,new,old)
	local gridlist = dgsGetParent(source)
	if dgsGetType(gridlist) == "dgs-dxgridlist" then
		local eleData = dgsElementData[gridlist]
		local scrollbars = eleData.scrollbars
		local sx,sy = eleData.absSize[1],eleData.absSize[2]
		local scbThick = eleData.scrollBarThick
		if source == scrollbars[1] then
			local scbThickH = dgsElementData[scrollbars[2]].visible and scbThick or 0
			local rowLength = #eleData.rowData*(eleData.rowHeight+eleData.leading)
			local temp = -new*(rowLength-sy+scbThickH+eleData.columnHeight)/100
			if temp <= 0 then
				local temp = eleData.scrollFloor[1] and temp-temp%1 or temp
				dgsSetData(gridlist,"rowMoveOffset",temp)
			end
			triggerEvent("onDgsElementScroll",gridlist,source,new,old)
		elseif source == scrollbars[2] then
			local scbThickV = dgsElementData[scrollbars[1]].visible and scbThick or 0
			local columnWidth = dgsGridListGetColumnAllWidth(gridlist,#eleData.columnData)
			local columnOffset = eleData.columnOffset
			local temp = -new*(columnWidth-sx+scbThickV+columnOffset)/100
			if temp <= 0 then
				local temp = eleData.scrollFloor[2] and temp-temp%1 or temp
				dgsSetData(gridlist,"columnMoveOffset",temp)
			end
			triggerEvent("onDgsElementScroll",gridlist,source,new,old)
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

function dgsGridListGetNavigationEnabled(gridlist,state)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetNavigationEnabled",1,"dgs-dxgridlist")) end
	return dgsElementData[gridlist].enableNavigation
end

function dgsGridListSetNavigationEnabled(gridlist)
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
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsAttachToGridList",3,"number","1~"..rLen,rNInRange and "Out Of Range")) end
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsAttachToGridList",4,"number","1~"..cLen,cNInRange and "Out Of Range")) end
	local c,r = c-c%1,r-r%1
	if rData[r][c] then
		dgsDetachElements(element)
		dgsSetParent(element,gridlist)
		rData[r][c][10] = rData[r][c][10] or {}
		tableInsert(rData[r][c][10],element)
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
		rData[r][c][10] = rData[r][c][10] or {}
		tableRemoveItemFromArray(rData[r][c][10],element)
	end
	return dgsSetData(element,"attachedToGridList",nil)
end
-----------------------------Sort
sortFunctions.greaterUpper = function(...)
	local arg = {...}
	local column = dgsElementData[self].sortColumn
	return arg[1][column][1] < arg[2][column][1]
end

sortFunctions.greaterLower = function(...)
	local arg = {...}
	local column = dgsElementData[self].sortColumn
	return arg[1][column][1] > arg[2][column][1]
end

sortFunctions.numGreaterUpper = function(...)
	local arg = {...}
	local column = dgsElementData[self].sortColumn
	local a = tonumber(arg[1][column][1]) or arg[1][column][1]
	local b = tonumber(arg[2][column][1]) or arg[2][column][1]
	return a < b
end

sortFunctions.numGreaterLower = function(...)
	local arg = {...}
	local column = dgsElementData[self].sortColumn
	local a = tonumber(arg[1][column][1]) or arg[1][column][1]
	local b = tonumber(arg[2][column][1]) or arg[2][column][1]
	return a > b
end

sortFunctions.longerUpper = function(...)
	local arg = {...}
	local column = dgsElementData[self].sortColumn
	return utf8Len(arg[1][column][1]) < utf8Len(arg[2][column][1])
end

sortFunctions.longerLower = function(...)
	local arg = {...}
	local column = dgsElementData[self].sortColumn
	return utf8Len(arg[1][column][1]) > utf8Len(arg[2][column][1])
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
		if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListScrollTo",2,"number","1~"..rLen,rNInRange and "Out Of Range")) end
		local scb = eleData.scrollbars[2]
		local rHeight = eleData.rowHeight
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
		if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListScrollTo",3,"number","1~"..cLen,cNInRange and "Out Of Range")) end
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
end

-----------------------------Column
--[[
	columnData Struct:
	  1																2																N
	  column1														column2															columnN
	{{text1,Width,AllWidthFront,Alignment,color,colorcoded,sizex,sizey,font},	{text1,Width,AllWidthFront,alignment,color,colorcoded,sizex,sizey,font},	{text1,Width,AllWidthFront,alignment,color,colorcoded,sizex,sizey,font}, ...}

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
		oldLen = cData[cLen][3]+cData[cLen][2]
	end
	if type(name) == "table" then
		_name = name
		name = dgsTranslate(gridlist,name,sourceResource)
	end
	tableInsert(cData,c,{
		tostring(name),
		len,
		oldLen,
		HorizontalAlign[alignment] or "left",
		_translationText = _name,
	})
	local cTextSize = eleData.columnTextSize
	local cTextColor = eleData.columnTextColor
	local colorcoded = eleData.colorcoded
	local font = eleData.font
	for i=c+1,cLen+1 do
		cData[i] = {
			cData[i][1],
			cData[i][2],
			dgsGridListGetColumnAllWidth(gridlist,i-1),
			cData[i][4],
			cTextColor,
			colorcoded,
			cTextSize[1],
			cTextSize[2],
			font,
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
			colorcoded,
			scale[1],
			scale[2],
			font,
		}
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
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListSetColumnFont",2,"number","1~"..cLen, cNInRange and "Out Of Range")) end
	local c = c-c%1
	if not (fontBuiltIn[font] or dgsGetType(font) == "dx-font") then error(dgsGenAsrt(font,"dgsGridListSetColumnFont",3,"dx-font/string",_,"invalid font")) end
	cData[c][9] = font
	if affectRow then
		local rData = eleData.rowData
		for i=1,#rData do
			rData[i][c][6] = font
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
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListGetColumnFont",2,"number","1~"..cLen, cNInRange and "Out Of Range")) end
	local c = c-c%1
	return cData[c][9]	--Font
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
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListSetColumnAlignment",2,"number","1~"..cLen, cNInRange and "Out Of Range")) end
	local c = c-c%1
	cData[c][4] = align
	if affectRow then
		local rData = eleData.rowData
		for i=1,#rData do
			rData[i][c][11] = nil	--Follow Column Alignment
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
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListGetColumnAlignment",2,"number","1~"..cLen, cNInRange and "Out Of Range")) end
	local c = c-c%1
	return cData[c][4]	--Alignment
end

function dgsGridListGetColumnTextSize(gridlist,c)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetColumnTextSize",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData = eleData.columnData
	local cLen = #cData
	if cLen == 0 then return false end
	local cIsNum = type(c) == "number"
	local cNInRange = cIsNum and not (c>=1 and c<=cLen)
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListGetColumnTextSize",2,"number","1~"..cLen, cNInRange and "Out Of Range")) end
	local c = c-c%1
	return cData[c][7],cData[c][8]
end

function dgsGridListSetColumnTextSize(gridlist,c,sizeX,sizeY)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetColumnTextSize",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData = eleData.columnData
	local cLen = #cData
	if cLen == 0 then return false end
	local cIsNum = type(c) == "number"
	local cNInRange = cIsNum and not (c>=1 and c<=cLen)
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListSetColumnTextSize",2,"number","1~"..cLen, cNInRange and "Out Of Range")) end
	local c = c-c%1
	if not (type(sizeX) == "number") then error(dgsGenAsrt(sizeX,"dgsGridListSetColumnTextSize",3,"number")) end
	cData[c][7] = sizeX
	cData[c][8] = sizeY or sizeX
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
				cData[k][2] = cData[k][2]/w
				cData[k][3] = cData[k][3]/w
			end
		else
			for k,v in ipairs(cData) do
				cData[k][2] = cData[k][2]*w
				cData[k][3] = cData[k][3]*w
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
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListSetColumnTitle",2,"number","1~"..cLen, cNInRange and "Out Of Range")) end
	local c = c-c%1
	if cData[c] then
		if type(name) == "table" then
			cData[c]._translationText = name
			name = dgsTranslate(gridlist,name,sourceResource)
		else
			cData[c]._translationText = nil
		end
		cData[c][1] = name
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
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListGetColumnTitle",2,"number","1~"..cLen, cNInRange and "Out Of Range")) end
	local c = c-c%1
	return columnData[c][1]
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
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListRemoveColumn",2,"number","1~"..cLen, cNInRange and "Out Of Range")) end
	local c = c-c%1
	local oldLen = cData[c][3]
	tableRemove(cData,c)
	local lastColumnLen = 0
	for i=1,cLen do
		if i >= c then
			cData[i][3] = cData[i][3]-oldLen
			lastColumnLen = cData[i][3]+cData[i][2]
		end
	end
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
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListSetColumnWidth",2,"number","1~"..cLen,cNInRange and "Out Of Range")) end
	local c = c-c%1
	if not (type(width) == "number") then error(dgsGenAsrt(c,"dgsGridListSetColumnWidth",3,"number")) end
	local rlt = eleData.columnRelative
	relative = relative == nil and rlt or false
	local scbThick = eleData.scrollBarThick
	local columnSize = eleData.absSize[1]-scbThick
	if rlt then
		width = relative and width or width/columnSize
	else
		width = relative and width*columnSize or width
	end
	local differ = width-cData[c][2]
	cData[c][2] = width
	local lastColumnLen = 0
	for i=1,cLen do
		if i > c then
			cData[i][3] = cData[i][3]+differ
			lastColumnLen = cData[i][3]+cData[i][2]
		end
	end
	dgsElementData[gridlist].configNextFrame = true
	return true
end

function dgsGridListAutoSizeColumn(gridlist,c,additionalLength,relative)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListAutoSizeColumn",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData = eleData.columnData
	local cLen = #cData
	if cLen == 0 then return false end
	local cIsNum = type(c) == "number"
	local cNInRange = cIsNum and not (c>=1 and c<=cLen)
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListAutoSizeColumn",2,"number","1~"..cLen,cNInRange and "Out Of Range")) end
	local c = c-c%1
	if not (additionalLength == nil or type(additionalLength) == "number") then error(dgsGenAsrt(c,"dgsGridListAutoSizeColumn",3,"number")) end
	if not additionalLength then relative = false end
	local font = cData[c][9] or eleData.font
	local wid = dxGetTextWidth(columnData[c][1],cData[c][7],font)
	local wid = wid+(relative and additionalLength*wid or (additionalLength or 0)+wid)
	return dgsGridListSetColumnWidth(gridlist,c,wid,false)
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
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListGetColumnAllWidth",2,"number","0~"..cLen,cNInRange and "Out Of Range")) end
	local c = c-c%1
	local columnSize = eleData.absSize[1]-eleData.scrollBarThick
	local rlt = eleData.columnRelative
	if mode then
		local data = cData[c][3]+cData[c][2]
		if relative then
			return rlt and data or data/columnSize
		else
			return rlt and data*columnSize or data
		end
	else
		local dataLength = 0
		for i=1,cLen do
			dataLength = dataLength + cData[i][2]
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
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListGetColumnWidth",2,"number","1~"..cLen,cNInRange and "Out Of Range")) end
	local c = c-c%1
	local columnSize = eleData.absSize[1]-eleData.scrollBarThick
	local rlt = eleData.columnRelative
	local data = cData[c][2]
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
		dgsSetData(scrollbars[2],"length",{0,true})
		dgsSetData(scrollbars[2],"position",0)
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
		-4					-3							-2				-1				0							1																																																														2																																	...
		columnOffset		bgImage						hoverable		selectable		bgColor						column1																																																													column2																																...
{
	{	columnOffset,		{normal,hovering,selected},	true/false,		true/false,		{normal,hovering,selected},	{text,color,colorcoded,scalex,scaley,font,{image,color,imagex,imagey,imagew,imageh,relative},unhoverable,unselectable,attachedElement,alignment,{textOffsetX,textOffsetY,relative},{bgColorNormal,bgColorHovering,bgColorSelected},{bgImageNormal,bgImageHovering,bgImageSelected}},		{text,color,colorcoded,scalex,scaley,font,{image,color,imagex,imagey,imagew,imageh,relative},unhoverable,unselectable,attachedElement,alignment,{textOffsetX,textOffsetY,relative},{bgColorNormal,bgColorHovering,bgColorSelected},{bgImageNormal,bgImageHovering,bgImageSelected}},		...		},
	{	columnOffset,		{normal,hovering,selected},	true/false,		true/false,		{normal,hovering,selected},	{text,color,colorcoded,scalex,scaley,font,{image,color,imagex,imagey,imagew,imageh,relative},unhoverable,unselectable,attachedElement,alignment,{textOffsetX,textOffsetY,relative},{bgColorNormal,bgColorHovering,bgColorSelected},{bgImageNormal,bgImageHovering,bgImageSelected}},		{text,color,colorcoded,scalex,scaley,font,{image,color,imagex,imagey,imagew,imageh,relative},unhoverable,unselectable,attachedElement,alignment,{textOffsetX,textOffsetY,relative},{bgColorNormal,bgColorHovering,bgColorSelected},{bgImageNormal,bgImageHovering,bgImageSelected}},		...		},
	{	the same as preview table																																																																																						},
}

	table[i](i<=0) isn't counted in #table
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
		[-4] = eleData.defaultColumnOffset,
		[-3] = eleData.rowImage,
		[-2] = true,
		[-1] = true,
		[0] = eleData.rowColor,
	}
	local rTextColor = eleData.rowTextColor
	local colorcoded = eleData.colorcoded
	local scale = eleData.rowTextSize
	for i=1,cLen do
		local text,_text = args[i]
		if type(text) == "table" then
			_text = text
			text = dgsTranslate(gridlist,text,sourceResource)
		end
		rowTable[i] = {
			_translationText=_text,
			tostring(text or ""),
			rTextColor,
			colorcoded,
			scale[1],
			scale[2],
			font,
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
				[-4] = eleData.defaultColumnOffset,
				[-3] = eleData.rowImage,
				[-2] = true,
				[-1] = true,
				[0] = eleData.rowColor,
			}
			local rTextColor = eleData.rowTextColor
			local colorcoded = eleData.colorcoded
			local scale = eleData.rowTextSize
			for col=1,cLen do
				local text,_text = t[i][col]
				if type(text) == "table" then
					_text = text
					text = dgsTranslate(gridlist,text,sourceResource)
				end
				rowTable[col] = {
					_translationText=_text,
					tostring(text or ""),
					rTextColor,
					colorcoded,
					scale[1],
					scale[2],
					font,
				}
			end
			tableInsert(rowData,r+i,rowTable)
		end
	end
	dgsElementData[gridlist].configNextFrame = true
	return true
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
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListGetRowSelectable",2,"number","1~"..rLen, rNInRange and "Out Of Range")) end
	local r = r-r%1
	return rData[r] and rData[r][-1] or false
end

function dgsGridListSetRowSelectable(gridlist,r,state)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetRowSelectable",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local rData = eleData.rowData
	local rLen = #rData
	if rLen == 0 then return false end
	local rIsNum = type(r) == "number"
	local rNInRange = rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListSetRowSelectable",2,"number","1~"..rLen, rNInRange and "Out Of Range")) end
	local r = r-r%1
	if rData[r] then
		rData[r][-1] = state and true or false
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
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListGetRowHoverable",2,"number","1~"..rLen, rNInRange and "Out Of Range")) end
	local r = r-r%1
	return rData[r] and rData[r][-2] or false
end

function dgsGridListSetRowHoverable(gridlist,r,state)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetRowHoverable",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local rData = eleData.rowData
	local rLen = #rData
	if rLen == 0 then return false end
	local rIsNum = type(r) == "number"
	local rNInRange = rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListSetRowHoverable",2,"number","1~"..rLen, rNInRange and "Out Of Range")) end
	local r = r-r%1
	if rData[r] then
		rData[r][-2] = state and true or false
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
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListGetRowBackGroundColor",2,"number","1~"..rLen, rNInRange and "Out Of Range")) end
	local r = r-r%1
	if rData[r][0] then
		return rData[r][0][1],rData[r][0][2],rData[r][0][3]
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
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListSetRowBackGroundColor",2,"number","1~"..rLen, rNInRange and "Out Of Range")) end
	local r = r-r%1
	rData[r][0] = {nClr or white,sClr or nClr,cClr or nClr}
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
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListGetRowBackGroundImage",2,"number","1~"..rLen, rNInRange and "Out Of Range")) end
	local r = r-r%1
	if rData[r][-3] then
		return rData[r][-3][1],rData[r][-3][2],rData[r][-3][3]
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
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListSetRowBackGroundImage",2,"number","1~"..rLen, rNInRange and "Out Of Range")) end
	local r = r-r%1
	if nImg ~= nil then
		local imgType = dgsGetType(nImg)
		if not (imgType == "texture" or imgType == "shader") then error(dgsGenAsrt(nImg,"dgsGridListSetRowBackGroundImage",3,"material")) end
	end
	if sImg ~= nil then
		local imgType = dgsGetType(sImg)
		if not (imgType == "texture" or imgType == "shader") then error(dgsGenAsrt(sImg,"dgsGridListSetRowBackGroundImage",4,"material")) end
	end
	if cImg ~= nil then
		local imgType = dgsGetType(cImg)
		if not (imgType == "texture" or imgType == "shader") then error(dgsGenAsrt(cImg,"dgsGridListSetRowBackGroundImage",5,"material")) end
	end
	rData[r][-3] = {nImg,sImg,cImg}
	return true
end

function dgsGridListSetRowAsSection(gridlist,r,enabled,enableMouseClickAndSelect)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetRowAsSection",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local rData = eleData.rowData
	local rLen = #rData
	if rLen == 0 then return false end
	local rIsNum = type(r) == "number"
	local rNInRange = rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListSetRowAsSection",2,"number","1~"..rLen, rNInRange and "Out Of Range")) end
	local r = r-r%1
	if enabled then
		rData[r][-4] = eleData.sectionColumnOffset
		if not enableMouseClickAndSelect then
			rData[r][-2] = false
			rData[r][-1] = false
		else
			rData[r][-2] = true
			rData[r][-1] = true
		end
	else
		rData[r][-4] = eleData.defaultColumnOffset
		rData[r][-2] = true
		rData[r][-1] = true
	end
	rData[r][-5] = enabled and true or false --Enable Section Mode
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
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListRemoveRow",2,"number","1~"..rLen, rNInRange and "Out Of Range")) end
	local r = r-r%1
	tableRemove(rData,r)
	dgsElementData[gridlist].configNextFrame = true
	return true
end

function dgsGridListClearRow(gridlist,notResetSelected,notResetScrollBar)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListClearRow",1,"dgs-dxgridlist")) end
 	local scrollbars = dgsElementData[gridlist].scrollbars
	if not notResetScrollBar then
		dgsSetData(scrollbars[1],"length",{0,true})
		dgsSetData(scrollbars[1],"position",0)
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
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListSetItemData",2,"number","1~"..rLen,rNInRange and "Out Of Range")) end
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListSetItemData",3,"number","1~"..cLen,cNInRange and "Out Of Range")) end
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
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListGetItemData",2,"number","1~"..rLen,rNInRange and "Out Of Range")) end
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListGetItemData",3,"number","1~"..cLen,cNInRange and "Out Of Range")) end
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
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListSetItemFont",2,"number","1~"..rLen,rNInRange and "Out Of Range")) end
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListSetItemFont",3,"number","1~"..cLen,cNInRange and "Out Of Range")) end
	if not (fontBuiltIn[font] or dgsGetType(font) == "dx-font") then error(dgsGenAsrt(font,"dgsGridListSetItemFont",4,"dx-font/string",_,"invalid font")) end
	local c,r = c-c%1,r-r%1
	if rData[r][c] then
		rData[r][c][6] = font
		return true
	end
	return false
end

function dgsGridListGetItemFont(gridlist,r,c)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetItemFont",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cIsNum,rIsNum = type(c) == "number",type(r) == "number"
	local cNInRange,rNInRange = cIsNum and not (c>=1 and c<=cLen),rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListGetItemFont",2,"number","1~"..rLen,rNInRange and "Out Of Range")) end
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListGetItemFont",3,"number","1~"..cLen,cNInRange and "Out Of Range")) end
	local c,r = c-c%1,r-r%1
	if rData[r][c] then
		return rData[r][c][6]
	end
	return false
end

function dgsGridListSetItemTextSize(gridlist,r,c,sizeX,sizeY)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetItemTextSize",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cIsNum,rIsNum = type(c) == "number",type(r) == "number"
	local cNInRange,rNInRange = cIsNum and not (c>=1 and c<=cLen),rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListSetItemTextSize",2,"number","1~"..rLen,rNInRange and "Out Of Range")) end
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListSetItemTextSize",3,"number","1~"..cLen,cNInRange and "Out Of Range")) end
	if not (type(sizeX) == "number") then error(dgsGenAsrt(sizeX,"dgsGridListSetItemTextSize",4,"number")) end
	local c,r = c-c%1,r-r%1
	if rData[r][c] then
		rData[r][c][4] = sizeX
		rData[r][c][5] = sizeY or sizeX
		return true
	end
	return false
end

function dgsGridListGetItemTextSize(gridlist,r,c)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetItemTextSize",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cIsNum,rIsNum = type(c) == "number",type(r) == "number"
	local cNInRange,rNInRange = cIsNum and not (c>=1 and c<=cLen),rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListGetItemTextSize",2,"number","1~"..rLen,rNInRange and "Out Of Range")) end
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListGetItemTextSize",3,"number","1~"..cLen,cNInRange and "Out Of Range")) end
	local c,r = c-c%1,r-r%1
	if rData[r][c] then
		return rData[r][c][4],rData[r][c][5]
	end
	return false
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
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListSetItemAlignment",2,"number","1~"..rLen,rNInRange and "Out Of Range")) end
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListSetItemAlignment",3,"number","1~"..cLen,cNInRange and "Out Of Range")) end
	local c,r = c-c%1,r-r%1
	rData[r][c][11] = align
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
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListGetItemAlignment",2,"number","1~"..rLen,rNInRange and "Out Of Range")) end
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListGetItemAlignment",3,"number","1~"..cLen,cNInRange and "Out Of Range")) end
	local c,r = c-c%1,r-r%1
	return rData[r][c][11] or cData[c][4]	--Alignment
end

function dgsGridListSetItemSelectable(gridlist,r,c,state)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetItemSelectable",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cIsNum,rIsNum = type(c) == "number",type(r) == "number"
	local cNInRange,rNInRange = cIsNum and not (c>=1 and c<=cLen),rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListSetItemSelectable",2,"number","1~"..rLen,rNInRange and "Out Of Range")) end
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListSetItemSelectable",3,"number","1~"..cLen,cNInRange and "Out Of Range")) end
	local c,r = c-c%1,r-r%1
	if rData[r] then
		rData[r][c][9] = not state or nil
		return true
	end
	return false
end

function dgsGridListGetItemSelectable(gridlist,r,c)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetItemSelectable",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cIsNum,rIsNum = type(c) == "number",type(r) == "number"
	local cNInRange,rNInRange = cIsNum and not (c>=1 and c<=cLen),rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListGetItemSelectable",2,"number","1~"..rLen,rNInRange and "Out Of Range")) end
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListGetItemSelectable",3,"number","1~"..cLen,cNInRange and "Out Of Range")) end
	local c,r = c-c%1,r-r%1
	if rData[r] then
		return rData[r][c][9] == false
	end
	return false
end

function dgsGridListSetItemHoverable(gridlist,r,c,state)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetItemHoverable",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cIsNum,rIsNum = type(c) == "number",type(r) == "number"
	local cNInRange,rNInRange = cIsNum and not (c>=1 and c<=cLen),rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListSetItemHoverable",2,"number","1~"..rLen,rNInRange and "Out Of Range")) end
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListSetItemHoverable",3,"number","1~"..cLen,cNInRange and "Out Of Range")) end
	local c,r = c-c%1,r-r%1
	if rData[r][c] then
		rData[r][c][8] = not state
		return true
	end
	return false
end

function dgsGridListGetItemHoverable(gridlist,r,c)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetItemHoverable",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cIsNum,rIsNum = type(c) == "number",type(r) == "number"
	local cNInRange,rNInRange = cIsNum and not (c>=1 and c<=cLen),rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListGetItemHoverable",2,"number","1~"..rLen,rNInRange and "Out Of Range")) end
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListGetItemHoverable",3,"number","1~"..cLen,cNInRange and "Out Of Range")) end
	local c,r = c-c%1,r-r%1
	if rData[r][c] then
		return rData[r][c][8] == false
	end
	return false
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
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListSetItemImage",2,"number","1~"..rLen,rNInRange and "Out Of Range")) end
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListSetItemImage",3,"number","1~"..cLen,cNInRange and "Out Of Range")) end
	local c,r = c-c%1,r-r%1
	if rData[r][c] then
		local imageData = rData[r][c][7] or {}
		imageData[1] = image or imageData[1] or nil
		imageData[2] = color or imageData[2] or white
		imageData[3] = offx or imageData[3] or 0
		imageData[4] = offy or imageData[4] or 0
		imageData[5] = w or imageData[5] or relative and 1 or dgsGridListGetColumnWidth(gridlist,c,false)
		imageData[6] = h or imageData[6] or relative and 1 or eleData.rowHeight
		imageData[7] = relative or false
		rData[r][c][7] = imageData
		return true
	end
	return false
end

function dgsGridListRemoveItemImage(gridlist,r,c)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListRemoveItemImage",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cIsNum,rIsNum = type(c) == "number",type(r) == "number"
	local cNInRange,rNInRange = cIsNum and not (c>=1 and c<=cLen),rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListRemoveItemImage",2,"number","1~"..rLen,rNInRange and "Out Of Range")) end
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListRemoveItemImage",3,"number","1~"..cLen,cNInRange and "Out Of Range")) end
	local c,r = c-c%1,r-r%1
	if rData[r][c] then
		rData[r][c][7] = nil
		return true
	end
	return false
end

function dgsGridListGetItemImage(gridlist,r,c)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetItemImage",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cIsNum,rIsNum = type(c) == "number",type(r) == "number"
	local cNInRange,rNInRange = cIsNum and not (c>=1 and c<=cLen),rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListGetItemImage",2,"number","1~"..rLen,rNInRange and "Out Of Range")) end
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListGetItemImage",3,"number","1~"..cLen,cNInRange and "Out Of Range")) end
	local c,r = c-c%1,r-r%1
	if rData[r][c] then
		return unpack(rData[r][c][7] or {})
	end
	return false
end

function dgsGridListSetItemText(gridlist,r,c,text,isSection)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetItemText",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cIsNum,rIsNum = type(c) == "number",type(r) == "number"
	local cNInRange,rNInRange = cIsNum and not (c>=1 and c<=cLen),rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListSetItemText",2,"number","1~"..rLen,rNInRange and "Out Of Range")) end
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListSetItemText",3,"number","1~"..cLen,cNInRange and "Out Of Range")) end
	local c,r = c-c%1,r-r%1
	if rData[r][c] then
		if type(text) == "table" then
			rData[r][c]._translationText = text
			text = dgsTranslate(gridlist,text,sourceResource)
		else
			rData[r][c]._translationText = nil
		end
		rData[r][c][1] = tostring(text)
		if isSection then
			dgsGridListSetRowAsSection(gridlist,r,true)
		end
		return true
	end
	return false
end

function dgsGridListGetItemText(gridlist,r,c)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetItemText",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cIsNum,rIsNum = type(c) == "number",type(r) == "number"
	local cNInRange,rNInRange = cIsNum and not (c>=1 and c<=cLen),rIsNum and not (r>=1 and r<=rLen)
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListGetItemText",2,"number","1~"..rLen,rNInRange and "Out Of Range")) end
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListGetItemText",3,"number","1~"..cLen,cNInRange and "Out Of Range")) end
	local c,r = c-c%1,r-r%1
	if rData[r][c] then
		return rData[r][c][1]
	end
	return false
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
	triggerEvent("onDgsGridListSelect",gridlist,tab,_)
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
	if not (rIsNum and not rNInRange) then error(dgsGenAsrt(r,"dgsGridListGetSelectedCount",2,"number","-1,1~"..rLen,rNInRange and "Out Of Range")) end
	if not (cIsNum and not cNInRange) then error(dgsGenAsrt(c,"dgsGridListGetSelectedCount",3,"number","-1,1~"..cLen,cNInRange and "Out Of Range")) end
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
	if rNInRange then error(dgsGenAsrt(r,"dgsGridListSetSelectedItem",2,"number","-1,1~"..rLen,rNInRange and "Out Of Range")) end
	if cNInRange then error(dgsGenAsrt(c,"dgsGridListSetSelectedItem",3,"number","-1,1~"..cLen,cNInRange and "Out Of Range")) end
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
		triggerEvent("onDgsGridListSelect",gridlist,r,c,old1)
	else
		triggerEvent("onDgsGridListSelect",gridlist,r,c,old1 or -1,old2 or -1)
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
	if rNInRange then error(dgsGenAsrt(r,"dgsGridListSelectItem",2,"number","1~"..rLen,rNInRange and "Out Of Range")) end
	if cNInRange then error(dgsGenAsrt(c,"dgsGridListSelectItem",3,"number","1~"..cLen,cNInRange and "Out Of Range")) end
	local c,r = c-c%1,r-r%1
	local selectedItem = eleData.rowSelect
	if rData[r][c] then
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
		triggerEvent("onDgsGridListSelect",gridlist,r,c)
		eleData.rowSelect = selectedItem
		return true
	end
	return false
end

function dgsGridListItemIsSelected(gridlist,r,c)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListItemIsSelected",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cNInRange,rNInRange = not (c>=1 and c<=cLen),not (r>=1 and r<=rLen)
	if rNInRange then error(dgsGenAsrt(r,"dgsGridListItemIsSelected",2,"number","1~"..rLen,rNInRange and "Out Of Range")) end
	if cNInRange then error(dgsGenAsrt(c,"dgsGridListItemIsSelected",3,"number","1~"..cLen,cNInRange and "Out Of Range")) end
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
	if rNInRange then error(dgsGenAsrt(r,"dgsGridListSetItemTextOffset",2,"number","-1,1~"..rLen,rNInRange and "Out Of Range")) end
	if cNInRange then error(dgsGenAsrt(c,"dgsGridListSetItemTextOffset",3,"number","-1,1~"..cLen,cNInRange and "Out Of Range")) end
	local c,r = c-c%1,r-r%1
	--Deal with the color
	if r == -1 then
		if c == -1 then
			for i=1,rLen do
				for j=1,cLen do
					rData[i][j][12] = offsetX and {offsetX,offsetY,relative} or nil
				end
			end
		else
			for i=1,rLen do
				rData[i][c][12] = offsetX and {offsetX,offsetY,relative} or nil
			end
		end
	else
		if c == -1 then
			for j=1,cLen do
				rData[r][j][12] = offsetX and {offsetX,offsetY,relative} or nil
			end
		else
			rData[r][c][12] = offsetX and {offsetX,offsetY,relative} or nil
		end
	end
	return false
end

function dgsGridListGetItemTextOffset(gridlist,r,c)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetItemTextOffset",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cNInRange,rNInRange = not (c>=1 and c<=cLen),not (r>=1 and r<=rLen)
	if rNInRange then error(dgsGenAsrt(r,"dgsGridListGetItemTextOffset",2,"number","1~"..rLen,rNInRange and "Out Of Range")) end
	if cNInRange then error(dgsGenAsrt(c,"dgsGridListGetItemTextOffset",3,"number","1~"..cLen,cNInRange and "Out Of Range")) end
	local c,r = c-c%1,r-r%1
	return rData[r][c][12][1],rData[r][c][12][2],rData[r][c][12][3]
end

function dgsGridListSetItemColor(gridlist,r,c,...)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetItemColor",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cNInRange,rNInRange = not (c>=1 and c<=cLen or c == -1),not (r>=1 and r<=rLen or r == -1)
	if rNInRange then error(dgsGenAsrt(r,"dgsGridListSetItemColor",2,"number","-1,1~"..rLen,rNInRange and "Out Of Range")) end
	if cNInRange then error(dgsGenAsrt(c,"dgsGridListSetItemColor",3,"number","-1,1~"..cLen,cNInRange and "Out Of Range")) end
	local c,r = c-c%1,r-r%1
	--Deal with the color
	local colors
	local argLen = select("#",...)
	local args = {...}
	if argLen == 0 then
		error(dgsGenAsrt(args[1],"dgsGridListSetItemColor",2,"table/number"))
	elseif argLen == 1 and type(args[1]) == "table" then
		colors = args[1]
	elseif argLen >= 3 then
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
					rData[i][j][2] = {colors[1],colors[2],colors[3]}
				end
			end
		else
			for i=1,rLen do
				rData[i][c][2] = {colors[1],colors[2],colors[3]}
			end
		end
	else
		if c == -1 then
			for j=1,cLen do
				rData[r][j][2] = {colors[1],colors[2],colors[3]}
			end
		else
			rData[r][c][2] = {colors[1],colors[2],colors[3]}
		end
	end
	return false
end

function dgsGridListGetItemColor(gridlist,r,c,notSplitColor)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListGetItemColor",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cNInRange,rNInRange = not (c>=1 and c<=cLen),not (r>=1 and r<=rLen)
	if rNInRange then error(dgsGenAsrt(r,"dgsGridListGetItemColor",2,"number","1~"..rLen,rNInRange and "Out Of Range")) end
	if cNInRange then error(dgsGenAsrt(c,"dgsGridListGetItemColor",3,"number","1~"..cLen,cNInRange and "Out Of Range")) end
	local c,r = c-c%1,r-r%1
	if notSplitColor then
		return unpack(rData[r][c][2])
	else
		return fromColor(rData[r][c][2][1]),fromColor(rData[r][c][2][2]),fromColor(rData[r][c][2][3])
	end
end

function dgsGridListSetItemBackGroundColor(gridlist,r,c,...)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetItemBackGroundColor",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cNInRange,rNInRange = not (c>=1 and c<=cLen or c == -1),not (r>=1 and r<=rLen or r == -1)
	if rNInRange then error(dgsGenAsrt(r,"dgsGridListSetItemBackGroundColor",2,"number","-1,1~"..rLen,rNInRange and "Out Of Range")) end
	if cNInRange then error(dgsGenAsrt(c,"dgsGridListSetItemBackGroundColor",3,"number","-1,1~"..cLen,cNInRange and "Out Of Range")) end
	local c,r = c-c%1,r-r%1
	--Deal with the color
	local colors
	local argLen = select("#",...)
	local args = {...}
	if argLen == 0 then
		error(dgsGenAsrt(args[1],"dgsGridListSetItemBackGroundColor",2,"table/number"))
	elseif argLen == 1 and type(args[1]) == "table" then
		colors = args[1]
	elseif argLen >= 3 then
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
					rData[i][j][13] = {colors[1],colors[2],colors[3]}
				end
			end
		else
			for i=1,rLen do
				rData[i][c][13] = {colors[1],colors[2],colors[3]}
			end
		end
	else
		if c == -1 then
			for j=1,cLen do
				rData[r][j][13] = {colors[1],colors[2],colors[3]}
			end
		else
			rData[r][c][13] = {colors[1],colors[2],colors[3]}
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
	if rNInRange then error(dgsGenAsrt(r,"dgsGridListGetItemBackGroundColor",2,"number","1~"..rLen,rNInRange and "Out Of Range")) end
	if cNInRange then error(dgsGenAsrt(c,"dgsGridListGetItemBackGroundColor",3,"number","1~"..cLen,cNInRange and "Out Of Range")) end
	local c,r = c-c%1,r-r%1
	if rData[r][c][13] then
		if notSplitColor then
			return rData[r][c][13][1],rData[r][c][13][2],rData[r][c][13][3]
		else
			return fromColor(rData[r][c][13][1]),fromColor(rData[r][c][13][2]),fromColor(rData[r][c][13][3])
		end
	elseif rData[r][0] then
		return rData[r][0][1],rData[r][0][2],rData[r][0][3]
	end
	return false,false,false
end

function dgsGridListSetItemBackGroundImage(gridlist,r,c,nImg,sImg,cImg)
	if dgsGetType(gridlist) ~= "dgs-dxgridlist" then error(dgsGenAsrt(gridlist,"dgsGridListSetItemBackGroundImage",1,"dgs-dxgridlist")) end
	local eleData = dgsElementData[gridlist]
	local cData,rData = eleData.columnData,eleData.rowData
	local cLen,rLen = #cData,#rData
	if cLen == 0 or rLen == 0 then return false end
	local cNInRange,rNInRange = not (c>=1 and c<=cLen or c == -1),not (r>=1 and r<=rLen or r == -1)
	if rNInRange then error(dgsGenAsrt(r,"dgsGridListSetItemBackGroundImage",2,"number","-1,1~"..rLen,rNInRange and "Out Of Range")) end
	if cNInRange then error(dgsGenAsrt(c,"dgsGridListSetItemBackGroundImage",3,"number","-1,1~"..cLen,cNInRange and "Out Of Range")) end
	local c,r = c-c%1,r-r%1

	if nImg ~= nil then
		local imgType = dgsGetType(nImg)
		if not (imgType == "texture" or imgType == "shader") then error(dgsGenAsrt(nImg,"dgsGridListSetItemBackGroundImage",4,"material")) end
	end
	if sImg ~= nil then
		local imgType = dgsGetType(sImg)
		if not (imgType == "texture" or imgType == "shader") then error(dgsGenAsrt(sImg,"dgsGridListSetItemBackGroundImage",5,"material")) end
	end
	if cImg ~= nil then
		local imgType = dgsGetType(cImg)
		if not (imgType == "texture" or imgType == "shader") then error(dgsGenAsrt(cImg,"dgsGridListSetItemBackGroundImage",6,"material")) end
	end
	if r == -1 then
		if c == -1 then
			for i=1,rLen do
				for j=1,cLen do
					rData[i][j][14] = {nImg,sImg,cImg}
				end
			end
		else
			for i=1,rLen do
				rData[i][c][14] = {nImg,sImg,cImg}
			end
		end
	else
		if c == -1 then
			for j=1,cLen do
				rData[r][j][14] = {nImg,sImg,cImg}
			end
		else
			rData[r][c][14] = {nImg,sImg,cImg}
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
	if rNInRange then error(dgsGenAsrt(r,"dgsGridListGetItemBackGroundImage",2,"number","1~"..rLen,rNInRange and "Out Of Range")) end
	if cNInRange then error(dgsGenAsrt(c,"dgsGridListGetItemBackGroundImage",3,"number","1~"..cLen,cNInRange and "Out Of Range")) end
	local c,r = c-c%1,r-r%1
	if rData[r][c][14] then
		return rData[r][c][14][1],rData[r][c][14][2],rData[r][c][14][3]
	elseif rData[r][-3] then
		return rData[r][-3][1],rData[r][-3][2],rData[r][-3][3]
	end
	return false,false,false
end

function dgsGridListUpdateRowMoveOffset(gridlist,rowMoveOffset)
	local eleData = dgsElementData[gridlist]
	local rowMoveOffset = rowMoveOffset or eleData.rowMoveOffsetTemp
	local rowHeight = eleData.rowHeight
	local rowHeightLeadingTemp = rowHeight + eleData.leading
	local scrollbar = eleData.scrollbars[2]
	local scbThickH = dgsElementData[scrollbar].visible and eleData.scrollBarThick or 0
	local h = eleData.absSize[2]
	local columnHeight = eleData.columnHeight
	local rowCount = #eleData.rowData
	if eleData.mode then
		local temp1 = rowMoveOffset/rowHeightLeadingTemp
		local whichRowToStart = -(temp1-temp1%1)+1
		local temp2 = (h-columnHeight-scbThickH+rowHeight)/rowHeightLeadingTemp
		local whichRowToEnd = whichRowToStart+(temp2-temp2%1)-2
		eleData.FromTo = {whichRowToStart > 0 and whichRowToStart or 1,whichRowToEnd <= rowCount and whichRowToEnd or rowCount}
	else
		local temp1 = (rowMoveOffset+rowHeight)/rowHeightLeadingTemp
		local whichRowToStart = -(temp1-temp1%1)+1
		local temp2 = (h-columnHeight-scbThickH+rowHeight*2)/rowHeightLeadingTemp
		local whichRowToEnd = whichRowToStart+(temp2-temp2%1)-1
		eleData.FromTo = {whichRowToStart > 0 and whichRowToStart or 1,whichRowToEnd <= rowCount and whichRowToEnd or rowCount}
	end
end

function configGridList(gridlist)
	local eleData = dgsElementData[gridlist]
	local scrollbar = eleData.scrollbars
	local w,h = eleData.absSize[1],eleData.absSize[2]
	local columnHeight,rowHeight,leading = eleData.columnHeight,eleData.rowHeight,eleData.leading
	local scbThick = eleData.scrollBarThick
	local columnWidth = dgsGridListGetColumnAllWidth(gridlist,#eleData.columnData,false,true)
	local rowLength = #eleData.rowData*(rowHeight+leading)
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
	if scbStateH and scbStateH ~= oriScbStateH then
		dgsSetData(scrollbar[2],"position",0)
	end
	if scbStateV and scbStateV ~= oriScbStateV  then
		dgsSetData(scrollbar[1],"position",0)
	end
	dgsSetVisible(scrollbar[1],scbStateV and true or false)
	dgsSetVisible(scrollbar[2],scbStateH and true or false)
	dgsSetPosition(scrollbar[1],scbX,0,false)
	dgsSetPosition(scrollbar[2],0,scbY,false)
	dgsSetSize(scrollbar[1],scbThick,relSizY,false)
	dgsSetSize(scrollbar[2],relSizX,scbThick,false)
	local scroll1 = dgsElementData[scrollbar[1]].position
	local scroll2 = dgsElementData[scrollbar[2]].position
	dgsSetData(gridlist,"rowMoveOffset",-scroll1*(rowLength-rowShowRange)/100)

	local scbLengthVrt = eleData.scrollBarLength[1]
	local higLen = 1-(rowLength-rowShowRange)/rowLength
	higLen = higLen >= 0.95 and 0.95 or higLen
	dgsSetData(scrollbar[1],"length",scbLengthVrt or {higLen,true})
	local verticalScrollSize = eleData.scrollSize/(rowLength-rowShowRange)
	dgsSetData(scrollbar[1],"multiplier",{verticalScrollSize,true})

	local scbLengthHoz = dgsElementData[gridlist].scrollBarLength[2]
	local widLen = 1-(columnWidth-columnShowRange)/columnWidth
	widLen = widLen >= 0.95 and 0.95 or widLen
	dgsSetData(scrollbar[2],"length",scbLengthHoz or {widLen,true})
	local horizontalScrollSize = eleData.scrollSize*5/(columnWidth-columnShowRange)
	dgsSetData(scrollbar[2],"multiplier",{horizontalScrollSize,true})

	local rentarg = eleData.renderTarget
	local res = eleData.resource
	if rentarg then
		if isElement(rentarg[1]) then destroyElement(rentarg[1]) end
		if isElement(rentarg[2]) then destroyElement(rentarg[2]) end
		if not eleData.mode then
			local columnRender,rowRender
			if relSizX*columnHeight ~= 0 then
				columnRender,err = dxCreateRenderTarget(relSizX,columnHeight,true,gridlist,res)
				if columnRender ~= false then
					dgsAttachToAutoDestroy(columnRender,gridlist,-1)
				else
					outputDebugString(err,2)
				end
			end
			if relSizX*rowShowRange ~= 0 then
				rowRender,err = dxCreateRenderTarget(relSizX,rowShowRange,true,gridlist,res)
				if rowRender ~= false then
					dgsAttachToAutoDestroy(rowRender,gridlist,-2)
				else
					outputDebugString(err,2)
				end
			end
			dgsSetData(gridlist,"renderTarget",{columnRender,rowRender})
		end
	end
	dgsGridListUpdateRowMoveOffset(gridlist)
	eleData.configNextFrame = false
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
	local font = eleData.font or systemFont
	local columnHeight = eleData.columnHeight
	dxSetBlendMode(rndtgt and "modulate_add" or "blend")
	if bgImage then
		dxDrawImage(x,y+columnHeight,w,h-columnHeight,bgImage,0,0,0,bgColor,isPostGUI,rndtgt)
	else
		dxDrawRectangle(x,y+columnHeight,w,h-columnHeight,bgColor,isPostGUI)
	end
	if columnImage then
		dxDrawImage(x,y,w,columnHeight,columnImage,0,0,0,columnColor,isPostGUI,rndtgt)
	else
		dxDrawRectangle(x,y,w,columnHeight,columnColor,isPostGUI)
	end
	local columnData,rowData = eleData.columnData,eleData.rowData
	local columnCount,rowCount = #columnData,#rowData
	local sortColumn = eleData.sortColumn
	if sortColumn and columnData[sortColumn] then
		if eleData.nextRenderSort then
			dgsGridListSort(source)
			eleData.nextRenderSort = false
		end
	end
	local columnTextColor = eleData.columnTextColor
	local columnRelt = eleData.columnRelative
	local rowHeight = eleData.rowHeight
	local rowTextPosOffset = eleData.rowTextPosOffset
	local columnTextPosOffset = eleData.columnTextPosOffset
	local leading = eleData.leading
	local scbThick = eleData.scrollBarThick
	local scrollbars = eleData.scrollbars
	local scb1,scb2 = scrollbars[1],scrollbars[2]
	local scbThickV,scbThickH = dgsElementData[scb1].visible and scbThick or 0,dgsElementData[scb2].visible and scbThick or 0
	local colorcoded = eleData.colorcoded
	local shadow = eleData.rowShadow
	local rowHeightLeadingTemp = rowHeight+leading
	--Smooth Row
	local _rowMoveOffset = eleData.rowMoveOffset
	local rowMoveOffset = _rowMoveOffset
	if eleData.rowMoveOffsetTemp ~= _rowMoveOffset then
		local rowMoveHardness = dgsElementData[scb1].moveType == "slow" and eleData.moveHardness[1] or eleData.moveHardness[2]
		eleData.rowMoveOffsetTemp = mathLerp(rowMoveHardness,eleData.rowMoveOffsetTemp,_rowMoveOffset)
		local rMoveOffset = eleData.rowMoveOffsetTemp-eleData.rowMoveOffsetTemp%1
		dgsGridListUpdateRowMoveOffset(source)
		if rMoveOffset-eleData.rowMoveOffsetTemp <= 0.5 and rMoveOffset-eleData.rowMoveOffsetTemp >= -0.5 then
			eleData.rowMoveOffsetTemp = rMoveOffset
		end
		rowMoveOffset = rMoveOffset
	end
	--Smooth Column
	local _columnMoveOffset = eleData.columnMoveOffset
	local columnMoveOffset = _columnMoveOffset
	if eleData.columnMoveOffsetTemp ~= _columnMoveOffset then
		local columnMoveHardness  = dgsElementData[scb2].moveType == "slow" and eleData.moveHardness[1] or eleData.moveHardness[2]
		eleData.columnMoveOffsetTemp = mathLerp(columnMoveHardness,eleData.columnMoveOffsetTemp,_columnMoveOffset)
		local cMoveOffset = eleData.columnMoveOffsetTemp-eleData.columnMoveOffsetTemp%1
		if cMoveOffset-eleData.columnMoveOffsetTemp <= 0.5 and cMoveOffset-eleData.columnMoveOffsetTemp >= -0.5 then
			eleData.columnMoveOffsetTemp = cMoveOffset
		end
		columnMoveOffset = cMoveOffset
	end
	--
	local columnOffset = eleData.columnOffset
	local rowTextSx,rowTextSy = eleData.rowTextSize[1],eleData.rowTextSize[2] or eleData.rowTextSize[1]
	local columnTextSx,columnTextSy = eleData.columnTextSize[1],eleData.columnTextSize[2] or eleData.columnTextSize[1]
	local selectionMode = eleData.selectionMode
	local clip = eleData.clip
	local mouseInsideGridList = mx >= cx and mx <= cx+w and my >= cy and my <= cy+h-scbThickH
	local mouseInsideColumn = mouseInsideGridList and my <= cy+columnHeight
	local mouseInsideRow = mouseInsideGridList and my > cy+columnHeight
	local defaultSortFunctions = eleData.defaultSortFunctions
	eleData.selectedColumn = -1
	local sortIcon = eleData.sortFunction == sortFunctions[defaultSortFunctions[1]] and "▼" or (eleData.sortFunction == sortFunctions[defaultSortFunctions[2]] and "▲") or nil
	local sortColumn = eleData.sortColumn
	local backgroundOffset = eleData.backgroundOffset

	local renderBuffer = eleData.renderBuffer
	local columnPos = renderBuffer.columnPos
	local columnEndPos = renderBuffer.columnEndPos

	if not eleData.mode then
		local renderTarget = eleData.renderTarget
		local isDraw1,isDraw2 = isElement(renderTarget[1]),isElement(renderTarget[2])
		dxSetRenderTarget(renderTarget[1],true)
			dxSetBlendMode("modulate_add")
			local multiplier = columnRelt and (w-scbThickV) or 1
			local tempColumnOffset = columnMoveOffset+columnOffset
			local mouseColumnPos = mx-cx
			local mouseSelectColumn = -1
			local cPosStart,cPosEnd
			for id = 1,#columnData do
				local data = columnData[id]
				local _columnTextColor = data[5] or columnTextColor
				local _columnTextColorCoded = data[6] or colorcoded
				local _columnTextSx,_columnTextSy = data[7] or columnTextSx,data[8] or columnTextSy
				local _columnFont = data[9] or font
				local tempCpos = data[3]*multiplier
				local _tempStartx = tempCpos+tempColumnOffset
				local _tempEndx = _tempStartx+data[2]*multiplier
				if _tempStartx <= w and _tempEndx >= 0 then
					columnPos[id],columnEndPos[id] = tempCpos,_tempEndx
					cPosStart,cPosEnd = cPosStart or id,id
					if isDraw1 then
						local _tempStartx = eleData.PixelInt and _tempStartx-_tempStartx%1 or _tempStartx
						local textPosL = _tempStartx+columnTextPosOffset[1]
						local textPosT = columnTextPosOffset[2]
						local textPosR = _tempEndx+columnTextPosOffset[1]
						local textPosB = columnHeight+columnTextPosOffset[2]
						if sortColumn == id and sortIcon then
							local iconWidth = dxGetTextWidth(sortIcon,_columnTextSx*0.8,_columnFont)
							local iconTextPosL = textPosL-iconWidth
							local iconTextPosR = textPosR-iconWidth
							if eleData.columnShadow then
								dxDrawText(sortIcon,iconTextPosL,textPosT,iconTextPosR,textPosB,black,_columnTextSx*0.8,_columnTextSy*0.8,_columnFont,"left","center",clip,false,false,false,true)
							end
							dxDrawText(sortIcon,iconTextPosL-1,textPosT,iconTextPosR-1,textPosB,_columnTextColor,_columnTextSx*0.8,_columnTextSy*0.8,_columnFont,"left","center",clip,false,false,false,true)
						end
						if eleData.columnShadow then
							dxDrawText(data[1],textPosL+1,textPosT+1,textPosR+1,textPosB+1,black,_columnTextSx,_columnTextSy,_columnFont,data[4],"center",clip,false,false,false,true)
						end
						dxDrawText(data[1],textPosL,textPosT,textPosR,textPosB,_columnTextColor,_columnTextSx,_columnTextSy,_columnFont,data[4],"center",clip,false,false,_columnTextColorCoded,true)
					end
					if mouseInsideGridList and mouseSelectColumn == -1 then
						if mouseColumnPos >= _tempStartx and mouseColumnPos <= _tempEndx then
							mouseSelectColumn = id
						end
					end
				end
			end
		dxSetRenderTarget(renderTarget[2],true)
			local preSelectLastFrame = eleData.preSelectLastFrame
			local preSelect = eleData.preSelect
			if MouseData.enteredGridList[1] == source then		-------PreSelect
				if mouseInsideRow then
					local toffset = (eleData.FromTo[1]*rowHeightLeadingTemp)+rowMoveOffset
					local tempID = (my-cy-columnHeight-toffset)/rowHeightLeadingTemp
					local sid = (tempID-tempID%1)+eleData.FromTo[1]+1
					if sid >= 1 and sid <= rowCount and my-cy-columnHeight < sid*rowHeight+(sid-1)*leading+rowMoveOffset then
						eleData.oPreSelect = sid
						if rowData[sid][-2] ~= false then
							preSelect[1],preSelect[2] = sid,mouseSelectColumn
						else
							preSelect[1],preSelect[2] = -1,mouseSelectColumn
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
			else
				preSelect[1],preSelect[2] = -1,-1
			end
			local preSelect = eleData.preSelect
			if preSelectLastFrame[1] ~= preSelect[1] or preSelectLastFrame[2] ~= preSelect[2] then
				triggerEvent("onDgsGridListHover",source,preSelect[1],preSelect[2],preSelectLastFrame[1],preSelectLastFrame[2])
				preSelectLastFrame[1],preSelectLastFrame[2] = preSelect[1],preSelect[2]
			end
			local Select = eleData.rowSelect
			local sectionFont = eleData.sectionFont or font
			local textBufferCnt = 0
			local elementBuffer = renderBuffer.elementBuffer
			local textBuffer = renderBuffer.textBuffer
			for i=eleData.FromTo[1],eleData.FromTo[2] do
				elementBuffer[i] = elementBuffer[i] or {}
				local lc_rowData = rowData[i]
				local image,columnOffset,isSection,color = lc_rowData[-3] or eleData.rowImage,lc_rowData[-4] or eleData.columnOffset,lc_rowData[-5],lc_rowData[0] or eleData.rowColor
				if isDraw2 then
					local rowpos = i*rowHeight+rowMoveOffset+(i-1)*leading
					local rowpos_1 = rowpos-rowHeight
					local _x,_y,_sx,_sy = tempColumnOffset+columnOffset,rowpos_1,sW,rowpos
					if eleData.PixelInt then
						_x,_y,_sx,_sy = _x-_x%1,_y-_y%1,_sx-_sx%1,_sy-_sy%1
					end

					if not cPosStart or not cPosEnd then break end
					dxSetBlendMode("modulate_add")
					for id = cPosStart,cPosEnd do
						local currentRowData = lc_rowData[id]
						local text = currentRowData[1]
						local _txtFont = isSection and sectionFont or (currentRowData[6] or font)
						local _txtScalex = currentRowData[4] or rowTextSx
						local _txtScaley = currentRowData[5] or rowTextSy
						local alignment = currentRowData[11] or columnData[id][4]
						local itemBGColor,itemBGImage = currentRowData[13] or color,currentRowData[14] or image
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
						local offset = columnPos[id]
						local _x = _x+offset
						local _sx = columnEndPos[id]
						local columnWidth = columnData[id][2]*multiplier
						local _bgX = _x
						local backgroundWidth = columnWidth
						if id == 1 then
							_bgX = _x+backgroundOffset
							backgroundWidth = columnWidth-backgroundOffset
						elseif backgroundWidth+_x >= w or columnCount == id then
							backgroundWidth = w-_x
						end
						local itemUsingBGColor,itemUsingBGImage = itemBGColor[rowState] or color[rowState],itemBGImage[rowState] or image[rowState]
						if itemUsingBGImage then
							dxDrawImage(_bgX,_y,backgroundWidth,rowHeight,itemUsingBGImage,0,0,0,itemUsingBGColor)
						else
							dxDrawRectangle(_bgX,_y,backgroundWidth,rowHeight,itemUsingBGColor)
						end
						elementBuffer[i][id] = elementBuffer[i][id] or {}
						local currentElementBuffer = elementBuffer[i][id]
						currentElementBuffer[1] = currentRowData[10]
						currentElementBuffer[2] = _x
						currentElementBuffer[3] = _y
						if text then
							local colorcoded = currentRowData[3] == nil and colorcoded or currentRowData[3]
							if currentRowData[7] then
								local imageData = currentRowData[7]
								local imagex = _x+(imageData[7] and imageData[3]*columnWidth or imageData[3])
								local imagey = _y+(imageData[7] and imageData[4]*rowHeight or imageData[4])
								local imagew = imageData[7] and imageData[5]*columnWidth or imageData[5]
								local imageh = imageData[7] and imageData[6]*rowHeight or imageData[6]
								if isElement(imageData[1]) then
									dxDrawImage(imagex,imagey,imagew,imageh,imageData[1],0,0,0,imageData[2])
								else
									dxDrawRectangle(imagex,imagey,imagew,imageh,imageData[2])
								end
							end
							local textXS,textYS,textXE,textYE = _x,_y,_sx,_sy
							if currentRowData[12] then
								local itemTextOffsetX = currentRowData[12][3] and columnWidth*currentRowData[12][1] or currentRowData[12][1]
								local itemTextOffsetY = currentRowData[12][3] and rowHeight*currentRowData[12][2] or currentRowData[12][2]
								textXS,textYS,textXE,textYE = textXS+itemTextOffsetX,textYS+itemTextOffsetY,textXE+itemTextOffsetX,textYE+itemTextOffsetY
							end
							textBufferCnt = textBufferCnt+1
							textBuffer[textBufferCnt] = textBuffer[textBufferCnt] or {}
							local currentTextBuffer = textBuffer[textBufferCnt]
							currentTextBuffer[1] = currentRowData[1]	--Text
							currentTextBuffer[2] = textXS-textXS%1			--startX
							currentTextBuffer[3] = textYS-textYS%1			--startY
							currentTextBuffer[4] = textXE-textXE%1			--endX
							currentTextBuffer[5] = textYE-textYE%1			--endY
							currentTextBuffer[6] = type(currentRowData[2]) == "table" and currentRowData[2][rowState] or currentRowData[2]
							currentTextBuffer[7] = _txtScalex
							currentTextBuffer[8] = _txtScaley
							currentTextBuffer[9] = _txtFont
							currentTextBuffer[10] = clip
							currentTextBuffer[11] = colorcoded
							currentTextBuffer[12] = alignment
						end
					end
				end
			end
			for a=1,textBufferCnt do
				local line = textBuffer[a]
				local text = line[1]
				local psx,psy,pex,pey = line[2]+rowTextPosOffset[1],line[3]+rowTextPosOffset[2],line[4]+rowTextPosOffset[1],line[5]+rowTextPosOffset[2]
				local clr,tSclx,tScly,tFnt,tClip,tClrCode,tHozAlign = line[6],line[7],line[8],line[9],line[10],line[11],line[12]
				if shadow then
					if tClrCode then
						text = text:gsub("#%x%x%x%x%x%x","") or text
					end
					dxDrawText(text,psx+shadow[1],psy+shadow[2],pex+shadow[1],pey+shadow[2],shadow[3],tSclx,tScly,tFnt,tHozAlign,"center",tClip,false,false,false,true)
				end
				dxDrawText(line[1],psx,psy,pex,pey,clr,tSclx,tScly,tFnt,tHozAlign,"center",tClip,false,false,tClrCode,true)
			end
			if not eleData.hitoutofparent then
				if MouseData.hit ~= source then
					enabledInherited = false
				end
			end
			local preHitElement = MouseData.hit
			for i=eleData.FromTo[1],eleData.FromTo[2] do
				for id = cPosStart,cPosEnd do
					local item = elementBuffer[i][id]
					if item and item[1] then
						local offx,offy = item[2],item[3]
						for a=1,#item[1] do
							renderGUI(item[1][a],mx,my,enabledInherited,enabledSelf,renderTarget[2],0,0,xNRT,yNRT+columnHeight,offx,offy,parentAlpha,visible,checkElement)
						end
					end
				end
			end
			if preHitElement == source then	--For grid list preselect
				MouseData.enteredGridList[2] = source
			end
		dxSetRenderTarget(rndtgt)
		dxSetBlendMode("modulate_add")
		if isDraw2 then
			dxDrawImage(x,y+columnHeight,w-scbThickV,h-columnHeight-scbThickH,renderTarget[2],0,0,0,tocolor(255,255,255,255*parentAlpha),isPostGUI)
		end
		if isDraw1 then
			dxDrawImage(x,y,w-scbThickV,columnHeight,renderTarget[1],0,0,0,tocolor(255,255,255,255*parentAlpha),isPostGUI)
		end
	elseif columnCount >= 1 then
		local whichColumnToStart,whichColumnToEnd = -1,-1
		local _rowMoveOffset = (1-eleData.FromTo[1])*rowHeightLeadingTemp
		local cpos = {}
		local multiplier = columnRelt and (w-scbThickV) or 1
		local ypcolumn = cy+columnHeight
		local _y,_sx = ypcolumn+_rowMoveOffset,cx+w-scbThickV
		local column_x = columnOffset
		local allColumnWidth = columnData[columnCount][2]+columnData[columnCount][3]
		local scrollbar = eleData.scrollbars[2]
		local scrollPos = dgsElementData[scrollbar].position*0.01
		local mouseSelectColumn = -1
		local does = false
		for id = 1,#columnData do
			local data = columnData[id]
			cpos[id] = data[3]*multiplier
			if (data[3]+data[2])*multiplier-columnOffset >= scrollPos*allColumnWidth*multiplier then
				if (data[3]+data[2])*multiplier-scrollPos*allColumnWidth*multiplier <= w-scbThickV then
					whichColumnToStart = whichColumnToStart ~= -1 and whichColumnToStart or id
					whichColumnToEnd = whichColumnToEnd <= whichColumnToStart and whichColumnToStart or id
					whichColumnToEnd = id
					does = true
				end
			end
		end
		if not does then
			whichColumnToStart,whichColumnToEnd = columnCount,columnCount
		end
		column_x = cx-cpos[whichColumnToStart]+columnOffset
		dxSetBlendMode(rndtgt and "modulate_add" or "blend")
		for i=whichColumnToStart,whichColumnToEnd or columnCount do
			local data = columnData[i]
			local _columnTextColor = data[5] or columnTextColor
			local _columnTextColorCoded = data[6] or colorcoded
			local _columnTextSx,_columnTextSy = data[7] or columnTextSx,data[8] or columnTextSy
			local _columnFont = data[9] or font
			local column_sx = column_x+cpos[i]+data[2]*multiplier-scbThickV
			local posx = column_x+cpos[i]
			local tPosX = posx-posx%1
			local textPosL = tPosX+columnTextPosOffset[1]
			local textPosT = cy+columnTextPosOffset[2]
			local textPosR = column_sx+columnTextPosOffset[1]
			local textPosB = ypcolumn+columnTextPosOffset[2]
			if sortColumn == i and sortIcon then
				local iconWidth = dxGetTextWidth(sortIcon,_columnTextSx*0.8,_columnFont)
				local iconTextPosL = textPosL-iconWidth
				local iconTextPosR = textPosR-iconWidth
				if eleData.columnShadow then
					dxDrawText(sortIcon,iconTextPosL,textPosT,iconTextPosR,textPosB,black,_columnTextSx*0.8,_columnTextSy*0.8,_columnFont,"left","center",clip,false,isPostGUI,false,true)
				end
				dxDrawText(sortIcon,iconTextPosL-1,textPosT,iconTextPosR-1,textPosB,_columnTextColor,_columnTextSx*0.8,_columnTextSy*0.8,_columnFont,"left","center",clip,false,isPostGUI,false,true)
			end
			if eleData.columnShadow then
				dxDrawText(data[1],textPosL+1,textPos+1,textPosR+1,textPosB+1,black,_columnTextSx,_columnTextSy,_columnFont,data[4],"center",clip,false,isPostGUI,false,true)
			end
			dxDrawText(data[1],textPosL,textPosT,textPosR,textPosB,_columnTextColor,_columnTextSx,_columnTextSy,_columnFont,data[4],"center",clip,false,isPostGUI,false,true)
			if mouseInsideGridList and mouseSelectColumn == -1 then
				backgroundWidth = data[2]*multiplier
				if backgroundWidth+posx-x >= w or whichColumnToEnd == i then
					backgroundWidth = w-posx+x
				end
				local _tempStartx = posx
				local _tempEndx = _tempStartx+backgroundWidth
				if mx >= _tempStartx and mx <= _tempEndx then
					mouseSelectColumn = i
				end
			end
		end
		local preSelectLastFrame = eleData.preSelectLastFrame
		local preSelect = eleData.preSelect
		if MouseData.entered == source then		-------PreSelect
			if mouseInsideRow then
				local tempID = (my-cy-columnHeight)/rowHeightLeadingTemp-1
				sid = (tempID-tempID%1)+eleData.FromTo[1]+1
				if sid >= 1 and sid <= rowCount and my-cy-columnHeight < sid*rowHeight+(sid-1)*leading+_rowMoveOffset then
					eleData.oPreSelect = sid
					if rowData[sid][-2] ~= false then
						preSelect[1],preSelect[2] = sid,mouseSelectColumn
					else
						preSelect[1],preSelect[2] = -1,mouseSelectColumn
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
		else
			preSelect[1],preSelect[2] = -1,-1
		end
		local preSelect = eleData.preSelect
		if preSelectLastFrame[1] ~= preSelect[1] or preSelectLastFrame[2] ~= preSelect[2] then
			triggerEvent("onDgsGridListHover",source,preSelect[1],preSelect[2],preSelectLastFrame[1],preSelectLastFrame[2])
			preSelectLastFrame[1],preSelectLastFrame[2] = preSelect[1],preSelect[2]
		end
		local Select = eleData.rowSelect
		local sectionFont = eleData.sectionFont or font
		local textBuffer = {}
		local textBufferCnt = 1
		for i=eleData.FromTo[1],eleData.FromTo[2] do
			local lc_rowData = rowData[i]
			local image = lc_rowData[-3]
			local color = lc_rowData[0]
			local columnOffset = lc_rowData[-4]
			local isSection = lc_rowData[-5]
			local rowpos = i*rowHeight+(i-1)*leading
			local _x,_y,_sx,_sy = column_x+columnOffset,_y+rowpos-rowHeight,_sx,_y+rowpos
			if eleData.PixelInt then
				_x,_y,_sx,_sy = _x-_x%1,_y-_y%1,_sx-_sx%1,_sy-_sy%1
			end
			for id=whichColumnToStart,whichColumnToEnd do
				local currentRowData = lc_rowData[id]
				local text = currentRowData[1]
				local _txtFont = isSection and sectionFont or (currentRowData[6] or font)
				local _txtScalex = currentRowData[4] or rowTextSx
				local _txtScaley = currentRowData[5] or rowTextSy
				local alignment = currentRowData[11] or columnData[id][4]
				local itemBGColor,itemBGImage = currentRowData[13] or color,currentRowData[14] or image
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
				local offset = cpos[id]
				local _x = _x+offset
				local _sx = (cpos[id+1] or (columnData[id][2])*multiplier)+_x
				local columnWidth = columnData[id][2]*multiplier
				local _bgX = _x
				if id == 1 then
					_bgX = _x+backgroundOffset
					columnWidth = columnWidth-backgroundOffset
				elseif columnWidth+_x-x >= w or whichColumnToEnd == id then
					columnWidth = w-_x+x-scbThickV
				end
				local itemUsingBGColor,itemUsingBGImage = itemBGColor[rowState] or color[rowState],itemBGImage[rowState] or image[rowState]
				if itemUsingBGImage then
					dxDrawImage(_bgX,_y,columnWidth,rowHeight,itemUsingBGImage,0,0,0,itemUsingBGColor,isPostGUI,rndtgt)
				else
					dxDrawRectangle(_bgX,_y,columnWidth,rowHeight,itemUsingBGColor,isPostGUI)
				end
				if text ~= "" then
					local colorcoded = currentRowData[3] == nil and colorcoded or currentRowData[3]
					if currentRowData[7] then
						local imageData = currentRowData[7]
						if isElement(imageData[1]) then
							dxDrawImage(_x+imageData[3],_y+imageData[4],imageData[5],imageData[6],imageData[1],0,0,0,imageData[2],rndtgt)
						else
							dxDrawRectangle(_x+imageData[3],_y+imageData[4],imageData[5],imageData[6],imageData[2])
						end
					end
					local textXS,textYS,textXE,textYE = _x,_y,_sx,_sy
					if currentRowData[12] then
						local itemTextOffsetX = currentRowData[12][3] and columnWidth*currentRowData[12][1] or currentRowData[12][1]
						local itemTextOffsetY = currentRowData[12][3] and rowHeight*currentRowData[12][2] or currentRowData[12][2]
						textXS,textYS,textXE,textYE = textXS+itemTextOffsetX,textYS+itemTextOffsetY,textXE+itemTextOffsetX,textYE+itemTextOffsetY
					end
					local color = type(currentRowData[2]) == "table" and currentRowData[2] or {currentRowData[2],currentRowData[2],currentRowData[2]}
					textBuffer[textBufferCnt] = {
						currentRowData[1],	--Text
						textXS-textXS%1,			--startX
						textYS-textYS%1,			--startY
						textXE-textXE%1,			--endX
						textYE-textYE%1,			--endY
						color[rowState],
						_txtScalex,
						_txtScaley,
						_txtFont,
						clip,
						colorcoded,
						alignment,
					}
					textBufferCnt = textBufferCnt+1
				end
			end
		end
		for i=1,#textBuffer do
			local line = textBuffer[i]
			local text = line[1]
			local psx,psy,pex,pey = line[2]+rowTextPosOffset[1],line[3]+rowTextPosOffset[2],line[4]+rowTextPosOffset[1],line[5]+rowTextPosOffset[2]
			local clr,tSclx,tScly,tFnt,tClip,tClrCode,tHozAlign = line[6],line[7],line[8],line[9],line[10],line[11],line[12]
			if shadow then
				if tClrCode then
					text = text:gsub("#%x%x%x%x%x%x","") or text
				end
				dxDrawText(text,psx+shadow[1],psy+shadow[2],pex+shadow[1],pey+shadow[2],shadow[3],tSclx,tScly,tFnt,tHozAlign,"center",tClip,false,isPostGUI,false,true)
			end
			dxDrawText(line[1],psx,psy,pex,pey,clr,tSclx,tScly,tFnt,tHozAlign,"center",tClip,false,isPostGUI,tClrCode,true)
		end
		if MouseData.hit == source then	--For grid list preselect
			MouseData.enteredGridList[2] = source
		end
	end
	dxSetBlendMode(rndtgt and "modulate_add" or "blend")
	return rndtgt,false,mx,my,0,0
end