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
function dgsCreateGridList(x,y,sx,sy,relative,parent,columnHeight,bgColor,columnTextColor,columnColor,rownorc,rowhovc,rowselc,bgImage,columnImage,rownori,rowhovi,rowseli)
	assert(tonumber(x),"Bad argument @dgsCreateGridList at argument 1, expect number got "..type(x))
	assert(tonumber(y),"Bad argument @dgsCreateGridList at argument 2, expect number got "..type(y))
	assert(tonumber(sx),"Bad argument @dgsCreateGridList at argument 3, expect number got "..type(sx))
	assert(tonumber(sy),"Bad argument @dgsCreateGridList at argument 4, expect number got "..type(sy))
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"Bad argument @dgsCreateGridList at argument 6, expect dgs-dxgui got "..dgsGetType(parent))
	end
	local gridlist = createElement("dgs-dxgridlist")
	local _x = dgsIsDxElement(parent) and dgsSetParent(gridlist,parent,true,true) or table.insert(CenterFatherTable,gridlist)
	dgsSetType(gridlist,"dgs-dxgridlist")
	dgsSetData(gridlist,"renderBuffer",{})
	dgsSetData(gridlist,"bgImage",bgImage or dgsCreateTextureFromStyle(styleSettings.gridlist.bgImage))
	dgsSetData(gridlist,"bgColor",bgColor or styleSettings.gridlist.bgColor)
	dgsSetData(gridlist,"columnImage",columnImage or dgsCreateTextureFromStyle(styleSettings.gridlist.columnImage))
	dgsSetData(gridlist,"columnColor",columnColor or styleSettings.gridlist.columnColor)
	dgsSetData(gridlist,"columnTextColor",columnTextColor or styleSettings.gridlist.columnTextColor)
	dgsSetData(gridlist,"columnTextSize",styleSettings.gridlist.columnTextSize)
	dgsSetData(gridlist,"columnOffset",styleSettings.gridlist.columnOffset)
	dgsSetData(gridlist,"columnData",{})
	dgsSetData(gridlist,"columnMoveOffset",0)
	dgsSetData(gridlist,"columnRelative",true)
	dgsSetData(gridlist,"columnShadow",false)
	local columnHeight = tonumber(columnHeight) or styleSettings.gridlist.columnHeight
	dgsSetData(gridlist,"columnHeight",columnHeight,true)
	dgsSetData(gridlist,"selectedColumn",-1)
	local rownorc = rownorc or styleSettings.gridlist.rowColor[1]
	local rowhovc = rowhovc or styleSettings.gridlist.rowColor[2]
	local rowselc = rowselc or styleSettings.gridlist.rowColor[3]
	dgsSetData(gridlist,"rowColor",{rownorc,rowhovc,rowselc})	--Normal/Hover/Selected
	local rownori = rownori or dgsCreateTextureFromStyle(styleSettings.gridlist.rowImage[1])
	local rowhovi = rowhovi or dgsCreateTextureFromStyle(styleSettings.gridlist.rowImage[2])
	local rowseli = rowseli or dgsCreateTextureFromStyle(styleSettings.gridlist.rowImage[3])
	dgsSetData(gridlist,"rowImage",{rownori,rowhovi,rowseli})	--Normal/Hover/Selected
	dgsSetData(gridlist,"rowData",{})
	dgsSetData(gridlist,"rowTextSize",styleSettings.gridlist.rowTextSize)
	dgsSetData(gridlist,"rowTextColor",styleSettings.gridlist.rowTextColor)
	dgsSetData(gridlist,"rowTextPosOffset",{0,0})
	dgsSetData(gridlist,"columnTextPosOffset",{0,0})
	dgsSetData(gridlist,"rowShadow",false)
	dgsSetData(gridlist,"rowMoveOffset",0,true)
	dgsSetData(gridlist,"rowHeight",styleSettings.gridlist.rowHeight)
	dgsGridListSetSortFunction(gridlist,sortFunctions_upper)
	dgsElementData[gridlist].nextRenderSort = false
	dgsSetData(gridlist,"sortEnabled",true)
	dgsSetData(gridlist,"autoSort",true)
	dgsSetData(gridlist,"sortColumn",false)
	dgsSetData(gridlist,"sectionColumnOffset",styleSettings.gridlist.sectionColumnOffset)
	dgsSetData(gridlist,"defaultColumnOffset",styleSettings.gridlist.defaultColumnOffset)
	dgsSetData(gridlist,"backgroundOffset",styleSettings.gridlist.backgroundOffset)
	local scbThick = styleSettings.gridlist.scrollBarThick
	dgsSetData(gridlist,"scrollBarThick",scbThick,true)
	dgsSetData(gridlist,"font",systemFont)
	dgsSetData(gridlist,"sectionFont",systemFont)
	dgsSetData(gridlist,"colorcoded",false)
	dgsSetData(gridlist,"selectionMode",1)
	dgsSetData(gridlist,"multiSelection",false)
	dgsSetData(gridlist,"mode",false,true)
	dgsSetData(gridlist,"clip",true)
	dgsSetData(gridlist,"leading",0,true)
	dgsSetData(gridlist,"preSelect",{})
	dgsSetData(gridlist,"rowSelect",{})
	dgsSetData(gridlist,"itemClick",{})
	dgsSetData(gridlist,"mouseSelectButton",{true,false,false})
	dgsSetData(gridlist,"enableNavigation",true)
	dgsSetData(gridlist,"lastSelectedItem",{1,1})
	dgsSetData(gridlist,"scrollBarState",{nil,nil})
	dgsSetData(gridlist,"mouseWheelScrollBar",false) --false:vertical; true:horizontal
	dgsSetData(gridlist,"scrollFloor",{false,false}) --move offset ->int or float
	dgsSetData(gridlist,"scrollSize",60)	--60 pixels
	dgsAttachToTranslation(gridlist,resourceTranslation[sourceResource or getThisResource()])
	dgsSetData(gridlist,"configNextFrame",false)
	calculateGuiPositionSize(gridlist,x,y,relative or false,sx,sy,relative or false,true)
	local aSize = dgsElementData[gridlist].absSize
	local abx,aby = aSize[1],aSize[2]
	local columnRender = dxCreateRenderTarget(abx,columnHeight,true)
	if not isElement(columnRender) and abx*columnHeight ~= 0 then
		local videoMemory = dxGetStatus().VideoMemoryFreeForMTA
		outputDebugString("Failed to create render target for column of dgs-dxgridlist [Expected:"..(0.0000076*abx*columnHeight).."MB/Free:"..videoMemory.."MB]",2)
	end
	local rowRender = dxCreateRenderTarget(abx,aby-columnHeight-scbThick,true)
	if not isElement(rowRender) and abx*(aby-columnHeight-scbThick) ~= 0 then
		local videoMemory = dxGetStatus().VideoMemoryFreeForMTA
		outputDebugString("Failed to create render target for row of dgs-dxgridlist [Expected:"..(0.0000076*abx*(aby-columnHeight-scbThick)).."MB/Free:"..videoMemory.."MB]",2)
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
	addEventHandler("onDgsElementScroll",scrollbar1,checkGLScrollBar,false)
	addEventHandler("onDgsElementScroll",scrollbar2,checkGLScrollBar,false)
	dgsSetData(gridlist,"scrollbars",{scrollbar1,scrollbar2})
	dgsSetData(gridlist,"FromTo",{1,0})
	triggerEvent("onDgsCreate",gridlist,sourceResource)
	return gridlist
end

function dgsGridListSetSelectionMode(gridlist,mode)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListSetSelectionMode at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	if mode == 1 or mode == 2 or mode == 3 then
		return dgsSetData(gridlist,"selectionMode",mode)
	end
	return false
end

function dgsGridListGetSelectionMode(gridlist)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListGetSelectionMode at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	return dgsElementData[gridlist].selectionMode
end

function dgsGridListSetMultiSelectionEnabled(gridlist,multiSelection)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListSetMultiSelectionEnabled at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	return dgsSetData(gridlist,"multiSelection",multiSelection and true or false)
end

function dgsGridListGetMultiSelectionEnabled(gridlist)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListGetMultiSelectionEnabled at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	return dgsElementData[gridlist].multiSelection
end

function dgsGridListGetNavigationEnabled(gridlist,state)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListGetNavigationEnabled at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	return dgsElementData[gridlist].enableNavigation
end

function dgsGridListSetNavigationEnabled(gridlist)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListSetNavigationEnabled at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	return dgsSetData(grid,"enableNavigation",state)
end
-----------------------------Sort
function sortFunctions_upper(...)
	local arg = {...}
	local column = dgsElementData[self].sortColumn
	return arg[1][column][1] < arg[2][column][1]
end

function sortFunctions_lower(...)
	local arg = {...}
	local column = dgsElementData[self].sortColumn
	return arg[1][column][1] > arg[2][column][1]
end

function dgsGridListSetSortFunction(gridlist,str)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListSetSortFunction at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	local fnc
	if type(str) == "string" then
		fnc = loadstring(str)
		assert(fnc,"Bad Argument @'dgsGridListSetSortFunction' at argument 1, failed to load the function.")
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
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListSetAutoSortEnabled at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	local state = state and true or false
	return dgsSetData(gridlist,"autoSort",state)
end

function dgsGridListGetAutoSortEnabled(gridlist)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListGetAutoSortEnabled at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	return dgsElementData[gridlist].autoSort
end

function dgsGridListSetSortEnabled(gridlist,state)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListSetSortEnabled at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	local state = state and true or false
	return dgsSetData(gridlist,"sortEnabled",state)
end

function dgsGridListGetSortEnabled(gridlist)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListGetSortEnabled at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	return dgsElementData[gridlist].sortEnabled
end

function dgsGridListSetSortColumn(gridlist,sortColumn)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListSetSortColumn at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
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
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListGetSortColumn at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	return dgsElementData[gridlist].sortColumn
end

function dgsGridListSort(gridlist,sortColumn)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListSort at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	local sortColumn = tonumber(sortColumn) or dgsElementData[gridlist].sortColumn
	if sortColumn then
		local rowData = dgsElementData[gridlist].rowData
		local sortFunction = dgsElementData[gridlist].sortFunction
		table.sort(rowData,sortFunction)
		dgsElementData[gridlist].rowData = rowData
		return true
	end
	return false
end

function dgsGridListGetEnterColumn(gridlist)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListGetEnterColumn at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	return dgsElementData[gridlist].selectedColumn
end
-----------------------------Column
--[[
	columnData Struct:
	  1																2																N
	  column1														column2															columnN
	{{text1,Width,AllWidthFront,Alignment,color,colorcoded,sizex,sizey,font},	{text1,Width,AllWidthFront,alignment,color,colorcoded,sizex,sizey,font},	{text1,Width,AllWidthFront,alignment,color,colorcoded,sizex,sizey,font}, ...}

]]

function dgsGridListAddColumn(gridlist,name,len,pos,alignment)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListAddColumn at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(len) == "number","Bad argument @dgsGridListAddColumn at argument 2, expect number got "..dgsGetType(len))
	local eleData = dgsElementData[gridlist]
	local columnData = eleData.columnData
	local columnDataCount = #columnData
	pos = tonumber(pos) or columnDataCount+1
	if pos > columnDataCount+1 then
		pos = columnDataCount+1
	end
	local aSize = eleData.absSize
	local sx,sy = aSize[1],aSize[2]
	local scrollBarThick = eleData.scrollBarThick
	local multiplier = eleData.columnRelative and sx-scrollBarThick or 1
	local oldLen = 0
	if columnDataCount > 0 then
		oldLen = columnData[columnDataCount][3]+columnData[columnDataCount][2]
	end
	local columnTable = {}
	if type(name) == "table" then
		columnTable._translationText = name
		name = dgsTranslate(gridlist,name,sourceResource)
	end
	columnTable[1] = tostring(name)
	columnTable[2] = len
	columnTable[3] = oldLen
	columnTable[4] = alignment or "left"
	table.insert(columnData,pos,columnTable)
	local columnTextSize = eleData.columnTextSize
	local columnTextColor = eleData.columnTextColor
	local colorcoded = eleData.colorcoded
	for i=pos+1,columnDataCount+1 do
		columnData[i] = {columnData[i][1],columnData[i][2],dgsGridListGetColumnAllWidth(gridlist,i-1),columnData[i][4],columnTextColor,colorcoded,columnTextSize[1],columnTextSize[2],eleData.font}
	end
	dgsSetData(gridlist,"columnData",columnData)
	local rowData = dgsElementData[gridlist].rowData
	local rowTxtColor = eleData.rowTextColor
	local colorcoded = eleData.colorcoded
	local scale = eleData.rowTextSize
	local font = eleData.font
	for i=1,#rowData do
		rowData[i][pos]= {"",rowTxtColor,colorcoded,scale[1],scale[2],font}
	end
	dgsSetData(gridlist,"configNextFrame",true)
	return pos
end

function dgsGridListSetColumnFont(gridlist,pos,font,affectRow)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListSetColumnFont at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(pos) == "number","Bad argument @dgsGridListSetColumnFont at argument 2, expect number got "..dgsGetType(pos))
	assert(fontDxHave[font] or dgsGetType(font) == "dx-font","Bad argument @dgsGridListSetColumnFont at argument 3, invaild font (Type:"..dgsGetType(font)..",Value:"..tostring(font)..")")
	local eleData = dgsElementData[gridlist]
	local columnData = eleData.columnData
	if #columnData == 0 then return end
	assert(pos >= 1 and pos <= #columnData, "Bad argument @dgsGridListSetColumnFont at argument 2, Out Of Range [1,"..#columnData.."]")
	columnData[pos][9] = font
	if affectRow then
		local rowData = eleData.rowData
		for i=1,#rowData do
			rowData[i][pos][6] = font
		end
	end
	return true
end

function dgsGridListGetColumnFont(gridlist,pos)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListGetColumnFont at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(pos) == "number","Bad argument @dgsGridListGetColumnFont at argument 2, expect number got "..dgsGetType(pos))
	local eleData = dgsElementData[gridlist]
	local columnData = eleData.columnData
	if #columnData == 0 then return end
	assert(pos >= 1 and pos <= #columnData, "Bad argument @dgsGridListSetColumnFont at argument 2, Out Of Range [1,"..#columnData.."]")
	return columnData[pos][9]
end

function dgsGridListGetColumnTextSize()
	--todo
end

function dgsGridListSetColumnTextSize()
	--todo
end

function dgsGridListSetItemFont()

end

function dgsGridListSetItemTextSize()
	--todo
end

function dgsGridListGetItemTextSize()
	--todo
end

function dgsGridListSetColumnRelative(gridlist,relative,transformColumn)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListSetColumnRelative at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(relative) == "boolean","Bad argument @dgsGridListSetColumnRelative at argument 2, expect bool got "..type(relative))
	local relative = relative and true or false
	local transformColumn = transformColumn == false and true or false
	dgsSetData(gridlist,"columnRelative",relative)
	if transformColumn then
		local columnData = dgsElementData[gridlist].columnData
		local w,h = dgsGetSize(v,false)
		if relative then
			for k,v in ipairs(columnData) do
				columnData[k][2] = columnData[k][2]/w
				columnData[k][3] = columnData[k][3]/w
			end
		else
			for k,v in ipairs(columnData) do
				columnData[k][2] = columnData[k][2]*w
				columnData[k][3] = columnData[k][3]*w
			end
		end
	end
	return true
end

function dgsGridListSetColumnTitle(gridlist,column,name)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListSetColumnTitle at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(column) == "number","Bad argument @dgsGridListSetColumnTitle at argument 2, expect number got "..type(column))
	local columnData = dgsElementData[gridlist].columnData
	if columnData[column] then
		if type(name) == "table" then
			columnData[column]._translationText = name
			name = dgsTranslate(gridlist,name,sourceResource)
		else
			columnData[column]._translationText = nil
		end
		columnData[column][1] = name
		dgsSetData(gridlist,"columnData",columnData)
	end
end

function dgsGridListGetColumnTitle(gridlist,column)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListGetColumnTitle at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(column) == "number","Bad argument @dgsGridListGetColumnTitle at argument 2, expect number got "..type(column))
	local columnData = dgsElementData[gridlist].columnData
	return columnData[column][1]
end

function dgsGridListGetColumnRelative(gridlist)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListGetColumnRelative at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	return dgsElementData[gridlist].columnRelative
end

function dgsGridListGetColumnCount(gridlist)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListGetColumnCount at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	return #(dgsElementData[gridlist].columnData or {})
end

function dgsGridListRemoveColumn(gridlist,pos)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListRemoveColumn at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(pos) == "number","Bad argument @dgsGridListRemoveColumn at argument 2, expect number got "..dgsGetType(pos))
	local columnData = dgsElementData[gridlist].columnData
	assert(columnData[pos],"Bad argument @dgsGridListRemoveColumn at argument 2, column index is out of range [max "..#columnData..", got "..pos.."]")
	local oldLen = columnData[pos][3]
	table.remove(columnData,pos)
	local lastColumnLen = 0
	for k,v in ipairs(columnData) do
		if k >= pos then
			columnData[k][3] = v[3]-oldLen
			lastColumnLen = columnData[k][3]+columnData[k][2]
		end
	end
	local sx,sy = dgsElementData[gridlist].absSize[1],dgsElementData[gridlist].absSize[2]
	local scrollbars = dgsElementData[gridlist].scrollbars
	local scrollBarThick = dgsElementData[gridlist].scrollBarThick
	if lastColumnLen > (sx-scrollBarThick) then
		dgsSetVisible(scrollbars[2],true)
	else
		dgsSetVisible(scrollbars[2],false)
	end
	dgsSetData(scrollbars[2],"length",{(sx-scrollBarThick)/lastColumnLen,true})
	dgsSetData(scrollbars[2],"position",dgsElementData[scrollbars[2]].position)
	return true
end

function dgsGridListSetColumnWidth(gridlist,pos,width,relative)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListSetColumnWidth at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(pos) == "number","Bad argument @dgsGridListSetColumnWidth at argument 2, expect number got "..dgsGetType(pos))
	assert(type(width) == "number","Bad argument @dgsGridListSetColumnWidth at argument 3, expect number got "..dgsGetType(width))
	local columnData = dgsElementData[gridlist].columnData
	assert(columnData[pos],"Bad argument @dgsGridListSetColumnWidth at argument 2, column index is out of range [max "..#columnData..", got "..pos.."]")
	local rlt = dgsElementData[gridlist].columnRelative
	relative = relative == nil and dgsElementData[gridlist].columnRelative or false
	local scbThick = dgsElementData[gridlist].scrollBarThick
	local columnSize = dgsElementData[gridlist].absSize[1]-scbThick
	if rlt then
		if not relative then
			width = width/columnSize
		end
	else
		if relative then
			width = width*columnSize
		end
	end
	local differ = width-columnData[pos][2]
	columnData[pos][2] = width
	local lastColumnLen = 0
	for k,v in ipairs(columnData) do
		if k > pos then
			columnData[k][3] = v[3]+differ
			lastColumnLen = columnData[k][3]+columnData[k][2]
		end
	end
	local sx,sy = dgsElementData[gridlist].absSize[1],dgsElementData[gridlist].absSize[2]
	local scrollbars = dgsElementData[gridlist].scrollbars
	if lastColumnLen > (sx-scbThick) then
		dgsSetVisible(scrollbars[2],true)
	else
		dgsSetVisible(scrollbars[2],false)
	end
	dgsSetData(scrollbars[2],"length",{(sx-scbThick)/lastColumnLen,true})
	dgsSetData(scrollbars[2],"position",dgsElementData[scrollbars[2]].position)
	return true
end

function dgsGridListAutoSizeColumn(gridlist,pos)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListSetColumnWidth at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(pos) == "number","Bad argument @dgsGridListSetColumnWidth at argument 2, expect number got "..dgsGetType(pos))
	local columnData = dgsElementData[gridlist].columnData
	assert(columnData[pos],"Bad argument @dgsGridListSetColumnWidth at argument 2, column index is out of range [min 1, max "..#columnData..", got "..pos.."]")
	local text = dgsGridListGetColumnTitle(gridlist,pos)
	local textSizeX = columnData[pos][7]
	local font = columnData[pos][9]
	local wid = dxGetTextWidth(text,textSizeX,font)
	dgsGridListSetColumnWidth(gridlist,pos,wid,false)
	return true
end

--[[
mode Fast(true)/Slow(false)
--]]
function dgsGridListGetColumnAllWidth(gridlist,pos,relative,mode)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListGetColumnAllWidth at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(pos) == "number","Bad argument @dgsGridListGetColumnAllWidth at argument 2, expect number got "..dgsGetType(pos))
	local columnData = dgsElementData[gridlist].columnData
	local scbThick = dgsElementData[gridlist].scrollBarThick
	local columnSize = dgsElementData[gridlist].absSize[1]-scbThick
	local rlt = dgsElementData[gridlist].columnRelative
	if pos > 0 then
		if mode then
			local data = columnData[pos][3]+columnData[pos][2]
			if relative then
				return rlt and data or data/columnSize
			else
				return rlt and data*columnSize or data
			end
		else
			local dataLength = 0
			for k,v in ipairs(columnData) do
				dataLength = dataLength + v[2]
				if k == pos then
					if relative then
						return rlt and dataLength or dataLength/columnSize
					else
						return rlt and dataLength*columnSize or dataLength
					end
				end
			end
		end
	elseif pos == 0 then
		local dataLength = 0
		if relative then
			return rlt and dataLength or dataLength/columnSize
		else
			return rlt and dataLength*columnSize or dataLength
		end
	end
	return false
end

function dgsGridListGetColumnWidth(gridlist,pos,relative)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListGetColumnWidth at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(pos) == "number","Bad argument @dgsGridListGetColumnWidth at argument 2, expect number got "..dgsGetType(pos))
	local columnData = dgsElementData[gridlist].columnData
	if pos > 0 and pos <= #columnData then
		local scbThick = dgsElementData[gridlist].scrollBarThick
		local columnSize = dgsElementData[gridlist].absSize[1]-scbThick
		local rlt = dgsElementData[gridlist].columnRelative
		local data = columnData[pos][2]
		if relative then
			return rlt and data or data/columnSize
		else
			return rlt and data*columnSize or data
		end
	end
	return false
end

function dgsGridListSetItemData(gridlist,row,column,data)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListSetItemData at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(row) == "number","Bad argument @dgsGridListSetItemData at argument 2, expect number got "..dgsGetType(row))
	assert(type(column) == "number","Bad argument @dgsGridListSetItemData at argument 3, expect number got "..dgsGetType(column))
	local rowData = dgsElementData[gridlist].rowData
	if row > 0 and row <= #rowData then
		local columnData = dgsElementData[gridlist].columnData
		if column > 0 and column <= #columnData then
			rowData[row][column][-1] = data
			return true
		end
	end
	return false
end

function dgsGridListGetItemData(gridlist,row,column)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListGetItemData at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(row) == "number","Bad argument @dgsGridListGetItemData at argument 2, expect number got "..dgsGetType(row))
	assert(type(column) == "number","Bad argument @dgsGridListGetItemData at argument 3, expect number got "..dgsGetType(column))
	local rowData = dgsElementData[gridlist].rowData
	if row > 0 and row <= #rowData then
		local columnData = dgsElementData[gridlist].columnData
		if column > 0 and column <= #columnData then
			return rowData[row][column][-1]
		end
	end
	return false
end

-----------------------------Row
--[[
	rowData Struct:
		-4					-3							-2				-1				0								1																													2																													...
		columnOffset		bgImage						selectable		clickable		bgColor							column1																												column2																												...
{
	{	columnOffset,		{normal,hovering,selected},	true/false,		true/false,		{normal,hovering,selected},	{text,color,colorcoded,scalex,scaley,font,{image,color,imagex,imagey,imagew,imageh},unselectable,unclickable},		{text,color,colorcoded,scalex,scaley,font,{image,color,imagex,imagey,imagew,imageh},unselectable,unclickable},		...		},
	{	columnOffset,		{normal,hovering,selected},	true/false,		true/false,		{normal,hovering,selected},	{text,color,colorcoded,scalex,scaley,font,{image,color,imagex,imagey,imagew,imageh},unselectable,unclickable},		{text,color,colorcoded,scalex,scaley,font,{image,color,imagex,imagey,imagew,imageh},unselectable,unclickable},		...		},
	{	columnOffset,		{normal,hovering,selected},	true/false,		true/false,		{normal,hovering,selected},	{text,color,colorcoded,scalex,scaley,font,{image,color,imagex,imagey,imagew,imageh},unselectable,unclickable},		{text,color,colorcoded,scalex,scaley,font,{image,color,imagex,imagey,imagew,imageh},unselectable,unclickable},		...		},
	{	columnOffset,		{normal,hovering,selected},	true/false,		true/false,		{normal,hovering,selected},	{text,color,colorcoded,scalex,scaley,font,{image,color,imagex,imagey,imagew,imageh},unselectable,unclickable},		{text,color,colorcoded,scalex,scaley,font,{image,color,imagex,imagey,imagew,imageh},unselectable,unclickable},		...		},
	{	the same as preview table																																													},
}

	table[i](i<=0) isn't counted in #table
]]


function dgsGridListAddRow(gridlist,row,...)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListAddRow at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	local eleData = dgsElementData[gridlist]
	local columnData = eleData.columnData
	assert(#columnData > 0 ,"Bad argument @dgsGridListAddRow, no columns in the grid list")
	local rowData = eleData.rowData
	local rowLength = 0
	row = tonumber(row) or #rowData+1
	local rowTable = {}
	local args = {...}
	rowTable[-4] = eleData.defaultColumnOffset
	rowTable[-3] = eleData.rowImage
	rowTable[-2] = true
	rowTable[-1] = true
	rowTable[0] = eleData.rowColor
	local rowTxtColor = eleData.rowTextColor
	local colorcoded = eleData.colorcoded
	local scale = eleData.rowTextSize
	local font = eleData.font
	for i=1,#eleData.columnData do
		local text = args[i]
		rowTable[i] = {}
		if type(text) == "table" then
			rowTable[i]._translationText = text
			text = dgsTranslate(gridlist,text,sourceResource)
		end
		rowTable[i][1] = tostring(text or "")
		rowTable[i][2] = rowTxtColor
		rowTable[i][3] = colorcoded
		rowTable[i][4] = scale[1]
		rowTable[i][5] = scale[2]
		rowTable[i][6] = font
	end
	table.insert(rowData,row,rowTable)
 	local scrollbars = dgsElementData[gridlist].scrollbars
	local aSize = dgsElementData[gridlist].absSize
	local sx,sy = aSize[1],aSize[2]
	local scbThick = dgsElementData[gridlist].scrollBarThick
	local columnHeight = dgsElementData[gridlist].columnHeight
	dgsSetData(gridlist,"configNextFrame",true)
	return row
end

function dgsGridListInsertRowAfter(gridlist,row,...)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListInsertRowAfter at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	local eleData = dgsElementData[gridlist]
	local columnData = eleData.columnData
	assert(#columnData > 0 ,"Bad argument @dgsGridListInsertRowAfter, no columns in the grid list")
	return dgsGridListAddRow(gridlist,row+1,...)
end

function dgsGridListSetItemClickable(gridlist,row,column,state)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListSetItemClickable at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(row) == "number","Bad argument @dgsGridListSetItemClickable at argument 2, expect number got "..dgsGetType(row))
	assert(type(column) == "number","Bad argument @dgsGridListSetItemClickable at argument 3, expect number got "..dgsGetType(column))
	row,column = row-row%1,column-column%1
	assert(row >= 1,"Bad argument @dgsGridListSetItemClickable at argument 2, expect number >= 1 got "..row)
	assert(column >= 1 or column <= -5,"Bad argument @dgsGridListSetItemClickable at argument 3, expect a number >= 1 got "..column)
	local rowData = dgsElementData[gridlist].rowData
	assert(rowData[row],"Bad argument @dgsGridListSetItemClickable at argument 2, row "..row.." doesn't exist")
	rowData[row][column][9] = not state or nil
	return true
end

function dgsGridListSetItemSelectable(gridlist,row,column,state)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListSetItemSelectable at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(row) == "number","Bad argument @dgsGridListSetItemSelectable at argument 2, expect number got "..dgsGetType(row))
	assert(type(column) == "number","Bad argument @dgsGridListSetItemSelectable at argument 3, expect number got "..dgsGetType(column))
	row,column = row-row%1,column-column%1
	assert(row >= 1,"Bad argument @dgsGridListSetItemSelectable at argument 2, expect number >= 1 got "..row)
	assert(column >= 1 or column <= -5,"Bad argument @dgsGridListSetItemSelectable at argument 3, expect a number >= 1 got "..column)
	local rowData = dgsElementData[gridlist].rowData
	assert(rowData[row],"Bad argument @dgsGridListSetItemSelectable at argument 2, row "..row.." doesn't exist")
	rowData[row][column][8] = not state or nil
	return true
end

function dgsGridListGetItemClickable(gridlist,row,column,state)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListGetItemClickable at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(row) == "number","Bad argument @dgsGridListGetItemClickable at argument 2, expect number got "..dgsGetType(row))
	assert(type(column) == "number","Bad argument @dgsGridListGetItemClickable at argument 3, expect number got "..dgsGetType(column))
	row,column = row-row%1,column-column%1
	assert(row >= 1,"Bad argument @dgsGridListGetItemClickable at argument 2, expect number >= 1 got "..row)
	assert(column >= 1 or column <= -5,"Bad argument @dgsGridListGetItemClickable at argument 3, expect a number >= 1 got "..column)
	local rowData = dgsElementData[gridlist].rowData
	assert(rowData[row],"Bad argument @dgsGridListGetItemClickable at argument 2, row "..row.." doesn't exist")
	return not (rowData[row][column][9] and true or false)
end

function dgsGridListGetItemSelectable(gridlist,row,column,state)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListGetItemSelectable at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(row) == "number","Bad argument @dgsGridListGetItemSelectable at argument 2, expect number got "..dgsGetType(row))
	assert(type(column) == "number","Bad argument @dgsGridListGetItemSelectable at argument 3, expect number got "..dgsGetType(column))
	row,column = row-row%1,column-column%1
	assert(row >= 1,"Bad argument @dgsGridListGetItemSelectable at argument 2, expect number >= 1 got "..row)
	assert(column >= 1 or column <= -5,"Bad argument @dgsGridListGetItemSelectable at argument 3, expect a number >= 1 got "..column)
	local rowData = dgsElementData[gridlist].rowData
	assert(rowData[row],"Bad argument @dgsGridListGetItemSelectable at argument 2, row "..row.." doesn't exist")
	return not (rowData[row][column][8] and true or false)
end

function dgsGridListSetRowBackGroundColor(gridlist,row,norcolor,selcolor,clicolor)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListSetRowBackGroundColor at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(row) == "number","Bad argument @dgsGridListSetRowBackGroundColor at argument 2, expect number got "..dgsGetType(row))
	local rowData = dgsElementData[gridlist].rowData
	if rowData[row] then
		rowData[row][0] = {norcolor or 255,selcolor or 255,clicolor or 255}
		return true
	end
	return false
end

function dgsGridListGetRowBackGroundColor(gridlist,row)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListGetRowBackGroundColor at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(row) == "number","Bad argument @dgsGridListGetRowBackGroundColor at argument 2, expect number got "..dgsGetType(row))
	local rowData = dgsElementData[gridlist].rowData
	if rowData[row] then
		return unpack(rowData[row][0] or {})
	end
	return false
end

function dgsGridListRemoveRow(gridlist,row)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListRemoveRow at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(row) == "number","Bad argument @dgsGridListRemoveRow at argument 2, expect number got "..dgsGetType(row))
	local rowData = dgsElementData[gridlist].rowData
	row = tonumber(row) or #rowData
	if row == 0 or row > #rowData then
		return false
	end
	table.remove(rowData,row)
	dgsSetData(gridlist,"configNextFrame",true)
	return true
end

function dgsGridListClearRow(gridlist,notResetSelected,notResetScrollBar)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListClearRow at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
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

function dgsGridListClearColumn(gridlist,notResetSelected,notResetScrollBar)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListClearColumn at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
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

function dgsGridListClear(gridlist,clearRow,clearColumn)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListClear at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	clearRow = clearRow ~= false
	clearColumn = clearColumn and true or false
 	if clearRow then
		dgsGridListClearRow(gridlist)
	elseif clearColumn then
		dgsGridListClearColumn(gridlist)
	end
	return true
end

function dgsGridListGetRowCount(gridlist)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListGetRowCount at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	return #dgsElementData[gridlist].rowData
end

function dgsGridListSetItemImage(gridlist,row,column,image,color,offx,offy,w,h)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListSetItemImage at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(row) == "number","Bad argument @dgsGridListSetItemImage at argument 2, expect number got "..dgsGetType(row))
	assert(type(column) == "number","Bad argument @dgsGridListSetItemImage at argument 3, expect number got "..dgsGetType(column))
	local rowData = dgsElementData[gridlist].rowData
	if rowData[row] and rowData[row][column] then
		local imageData = rowData[row][column][7] or {}
		local image = image or imageData[1] or _
		local color = color or imageData[2] or white
		local offx = offx or imageData[3] or 0
		local offy = offy or imageData[4] or 0
		local w,h = w or imageData[5] or dgsGridListGetColumnWidth(gridlist,column,false),h or imageData[6] or dgsElementData[gridlist].rowHeight
		imageData[1] = image
		imageData[2] = color
		imageData[3] = offx
		imageData[4] = offy
		imageData[5] = w
		imageData[6] = h
		rowData[row][column][7] = imageData
		return true
	end
	return false
end

function dgsGridListRemoveItemImage(gridlist,row,column)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListRemoveItemImage at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(row) == "number","Bad argument @dgsGridListRemoveItemImage at argument 2, expect number got "..dgsGetType(row))
	assert(type(column) == "number","Bad argument @dgsGridListRemoveItemImage at argument 3, expect number got "..dgsGetType(column))
	local rowData = dgsElementData[gridlist].rowData
	if rowData[row] and rowData[row][column] then
		rowData[row][column][7] = nil
		return true
	end
	return false
end

function dgsGridListGetItemImage(gridlist,row,column)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListGetItemImage at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(row) == "number","Bad argument @dgsGridListGetItemImage at argument 2, expect number got "..dgsGetType(row))
	assert(type(column) == "number","Bad argument @dgsGridListGetItemImage at argument 3, expect number got "..dgsGetType(column))
	local rowData = dgsElementData[gridlist].rowData
	if rowData[row] and rowData[row][column] then
		local imageData = rowData[row][column][7] or {}
		return unpack(rowData[row][column][7] or {})
	end
	return false
end

function dgsGridListSetItemText(gridlist,row,column,text,isSection)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListSetItemText at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(row) == "number","Bad argument @dgsGridListSetItemText at argument 2, expect number got "..type(row))
	assert(type(column) == "number","Bad argument @dgsGridListSetItemText at argument 3, expect number got "..type(column))
	row,column = row-row%1,column-column%1
	assert(row >= 1,"Bad argument @dgsGridListSetItemText at argument 2, expect number >= 1 got "..row)
	assert(column >= 1 or column <= -5,"Bad argument @dgsGridListSetItemText at argument 3, expect a number >= 1 got "..column)
	local rowData = dgsElementData[gridlist].rowData
	assert(rowData[row],"Bad argument @dgsGridListSetItemText at argument 2, row "..row.." doesn't exist")
	if column <= -5 then
		rowData[row][column] = text
		return true
	elseif rowData[row][column] then
		if type(text) == "table" then
			rowData[row][column]._translationText = text
			text = dgsTranslate(gridlist,text,sourceResource)
		else
			rowData[row][column]._translationText = nil
		end
		rowData[row][column][1] = tostring(text)
		if isSection then
			dgsGridListSetRowAsSection(gridlist,row,true)
		end
		return true
	end
	return false
end

function dgsGridListSetRowAsSection(gridlist,row,enabled,enableMouseClickAndSelect)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListSetRowAsSection at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(row) == "number","Bad argument @dgsGridListSetRowAsSection at argument 2, expect number got "..type(row))
	local rowData = dgsElementData[gridlist].rowData
	if rowData[row] then
		if enabled then
			rowData[row][-4] = dgsElementData[gridlist].sectionColumnOffset
			if not enableMouseClickAndSelect then
				rowData[row][-2] = false
				rowData[row][-1] = false
			else
				rowData[row][-2] = true
				rowData[row][-1] = true
			end
		else
			rowData[row][-4] = dgsElementData[gridlist].defaultColumnOffset
			rowData[row][-2] = true
			rowData[row][-1] = true
		end
		rowData[row][-5] = enabled and true or false --Enable Section Mode
		return dgsSetData(gridlist,"rowData",rowData)
	end
	return false
end

function dgsGridListGetItemText(gridlist,row,column)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListGetItemText at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(row) == "number","Bad argument @dgsGridListGetItemText at argument 2, expect number got "..type(row))
	assert(type(column) == "number","Bad argument @dgsGridListGetItemText at argument 3, expect number got "..type(column))
	row,column = row-row%1,column-column%1
	assert(row >= 1,"Bad argument @dgsGridListGetItemText at argument 2, expect number >= 1 got "..row)
	assert(column >= 1 or column <= -5,"Bad argument @dgsGridListGetItemText at argument 3, expect a number >= 1 got "..column)
	local rowData = dgsElementData[gridlist].rowData
	assert(rowData[row],"Bad argument @dgsGridListGetItemText at argument 2, row "..row.." doesn't exist")
	return rowData[row][column][1],rowData[row][column][7]
end

function dgsGridListGetSelectedItem(gridlist)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListGetSelectedItem at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	local row,data = next(dgsElementData[gridlist].rowSelect or {})
	local column,bool = next(data or {})
	return row or -1,column or -1
end

function dgsGridListUpdateRowMoveOffset(gridlist,rowMoveOffset)
	local DataTab = dgsElementData[gridlist]
	local rowMoveOffset = rowMoveOffset or DataTab.rowMoveOffset
	local rowHeight = DataTab.rowHeight
	local leading = DataTab.leading
	local rowHeightLeadingTemp = rowHeight + leading
	local scbThick = DataTab.scrollBarThick
	local scrollbars = DataTab.scrollbars
	local scbThickH = dgsElementData[ scrollbars[2] ].visible and scbThick or 0
	local w,h = DataTab.absSize[1],DataTab.absSize[2]
	local columnHeight = DataTab.columnHeight
	local rowData = DataTab.rowData
	local rowCount = #rowData
	if DataTab.mode then
		local temp1 = rowMoveOffset/rowHeightLeadingTemp
		local whichRowToStart = -(temp1-temp1%1)+1
		local temp2 = (h-columnHeight-scbThickH+rowHeight)/rowHeightLeadingTemp
		local whichRowToEnd = whichRowToStart+(temp2-temp2%1)-2
		DataTab.FromTo = {whichRowToStart > 0 and whichRowToStart or 1,whichRowToEnd <= rowCount and whichRowToEnd or rowCount}
	else
		local temp1 = (rowMoveOffset+rowHeight)/rowHeightLeadingTemp
		local whichRowToStart = -(temp1-temp1%1)+1
		local temp2 = (h-columnHeight-scbThickH+rowHeight*2)/rowHeightLeadingTemp
		local whichRowToEnd = whichRowToStart+(temp2-temp2%1)-1
		DataTab.FromTo = {whichRowToStart > 0 and whichRowToStart or 1,whichRowToEnd <= rowCount and whichRowToEnd or rowCount}
	end
end

function dgsGridListScrollTo(gridlist,row,column)
	if row then
		local rowData = dgsElementData[gridlist].rowData
		local rowCounts = #rowData
		if row >=1 and row <= #rowData then
			local rowHeight = dgsElementData[gridlist].rowHeight
			local leading = dgsElementData[gridlist].leading
			local rowHeightLeadingTemp = rowHeight+leading
			local fromTo = dgsElementData[gridlist].FromTo
			local scrollBars = dgsElementData[gridlist].scrollbars
			local sy = dgsElementData[gridlist].absSize[2]
			local scbThick = dgsElementData[gridlist].scrollBarThick
			local columnHeight = dgsElementData[gridlist].columnHeight
			local scbThickH = dgsElementData[scrollBars[2]].visible and scbThick or 0
			local gridListRange = sy-scbThickH-columnHeight
			if row <= fromTo[1] then
				local scrollPos = ((row-2)*rowHeightLeadingTemp+rowHeight+leading)/(rowCounts*rowHeightLeadingTemp-gridListRange)*100
				dgsGridListSetScrollPosition(gridlist,scrollPos)
			elseif row > fromTo[2] then
				local scrollPos = ((row-1)*rowHeightLeadingTemp+rowHeight-gridListRange)/(rowCounts*rowHeightLeadingTemp-gridListRange)*100
				dgsGridListSetScrollPosition(gridlist,scrollPos)
			end
		end
	end
	if column then
	--todo
	end
end

function dgsGridListGetSelectedItems(gridlist,isOrigin)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListGetSelectedItem at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	local items = dgsElementData[gridlist].rowSelect
	if isOrigin then return items end
	local selectionMode = dgsElementData[gridlist].selectionMode
	local columndata = dgsElementData[gridlist].columnData
	local rowData = dgsElementData[gridlist].rowData
	local newSelectTable = {}
	local cnt = 0
	if not next(items) then return {} end
	if selectionMode == 1 then
		for row,val in pairs(items) do
			for col=1,#columndata do
				cnt = cnt+1
				newSelectTable[cnt] = {row=row,column=col}
			end
		end
		return newSelectTable
	elseif selectionMode == 2 then
		for row=1,#rowData do
			for col,val in pairs(items[1]) do
				cnt = cnt+1
				newSelectTable[cnt] = {row=row,column=col}
			end
		end
		return newSelectTable
	elseif selectionMode == 3 then
		for row,val in pairs(items) do
			for col,_ in pairs(val) do
				cnt = cnt+1
				newSelectTable[cnt] = {row=row,column=col}
			end
		end
		return newSelectTable
	end
	return {}
end

function dgsGridListSetSelectedItems(gridlist,tab,isOrigin)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListSetSelectedItems at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(tab) == "table","Bad argument @dgsGridListSetSelectedItems at argument 2, expect table got "..type(tab))
	local originSel
	if not isOrigin then
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

function dgsGridListGetSelectedCount(gridlist,inRow,inColumn)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListGetSelectedCount at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	local inRow,inColumn = inRow or -1,inColumn or -1
	assert(type(inRow) == "number" and inRow == -1 or inRow >= 1,"Bad argument @dgsGridListGetSelectedCount at argument 2, expect a number -1 or 1 ~ RowCount, got "..tostring(inRow).." ("..type(inRow)..")")
	assert(type(inColumn) == "number" and inColumn == -1 or inColumn >= 1,"Bad argument @dgsGridListGetSelectedCount at argument 3, expect a number -1 or 1 ~ ColumnCount, got "..tostring(inColumn).." ("..type(inColumn)..")")
	local selectedItems = dgsGridListGetSelectedItems(gridlist)
	if inRow == -1 then
		if inColumn == -1 then
			return #selectedItems
		else
			local cnt = 0
			for i=1,#selectedItems do
				if selectedItems[i].column == inColumn then
					cnt = cnt + 1
				end
			end
			return cnt
		end
	else
		if inColumn == -1 then
			local cnt = 0
			for i=1,#selectedItems do
				if selectedItems[i].row == inRow then
					cnt = cnt + 1
				end
			end
			return cnt
		else
			for i=1,#selectedItems do
				if selectedItems[i].row == inRow and selectedItems[i].column == inColumn then
					return 1
				end
			end
			return 0
		end
	end
end

function dgsGridListSetSelectedItem(gridlist,row,column,scrollTo,isOrigin)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListSetSelectedItem at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	if row == -1 or row > 0 then
		local rowData = dgsElementData[gridlist].rowData
		local columndata = dgsElementData[gridlist].columnData
		local row = row <= #rowData and row or #rowData
		local column = column or -1
		local column = column <= #columndata and column or #columndata
		local old1,old2
		if dgsElementData[gridlist].multiSelection then
			old1 = dgsElementData[gridlist].rowSelect
		else
			data = dgsElementData[gridlist].rowSelect
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
		local selectionMode = dgsElementData[gridlist].selectionMode
		if selectionMode == 1 then
			assert(type(row) == "number","Bad argument @dgsGridListSetSelectedItem at argument 2, expect number got "..type(row))
			tab = {[row]={}}
			tab[row][1] = true
			dgsSetData(gridlist,"rowSelect",tab)
		elseif selectionMode == 2 then
			assert(type(column) == "number","Bad argument @dgsGridListSetSelectedItem at argument 3, expect number got "..type(column))
			local tab = {}
			tab[1] = {[column]=true}
			dgsSetData(gridlist,"rowSelect",tab)
		elseif selectionMode == 3 then
			assert(type(row) == "number","Bad argument @dgsGridListSetSelectedItem at argument 2, expect number got "..type(row))
			assert(type(column) == "number","Bad argument @dgsGridListSetSelectedItem at argument 3, expect number got "..type(column))
			dgsSetData(gridlist,"rowSelect",{[row]={[column]=true}})
		end
		if dgsElementData[gridlist].multiSelection then
			triggerEvent("onDgsGridListSelect",gridlist,row,column,old1)
		else
			triggerEvent("onDgsGridListSelect",gridlist,row or -1,column or -1,old1 or -1,old2 or -1)
		end
		dgsElementData[gridlist].itemClick = {row,column}
		if scrollTo then
			dgsGridListScrollTo(gridlist,row,column)
		end
		return true
	end
	return false
end

addEventHandler("onDgsGridListSelect",resourceRoot,function(rowOrTable,column,oldRowOrTable,oldColumn)
	local lastSelected = dgsElementData[source].lastSelectedItem
	if type(rowOrTable) == "table" then
		local row,columns = next(rowOrTable)
		if row then
			local column = next(columns)
			dgsSetData(source,"lastSelectedItem",{row,column})
		end
	else
		dgsSetData(source,"lastSelectedItem",{rowOrTable == -1 and lastSelected[1] or rowOrTable,column == -1 and lastSelected[2] or column})
	end
end)

function dgsGridListSelectItem(gridlist,row,column,state)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListSelectItem at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	local selectedItem = dgsElementData[gridlist].rowSelect
	local rowData = dgsElementData[gridlist].rowData
	local columnData = dgsElementData[gridlist].rowData
	if rowData[row] and rowData[row][column] then
		if not dgsElementData[gridlist].multiSelection then
			selectedItem = {}
		end
		local selectionMode = dgsElementData[gridlist].selectionMode
		if selectionMode == 1 then
			selectedItem[row] = selectedItem[row] or {}
			selectedItem[row][1] = state or nil
			if not next(selectedItem[row]) then
				selectedItem[row] = nil
			end
		elseif selectionMode == 2 then
			selectedItem[1] = selectedItem[1] or {}
			selectedItem[1][column] = state or nil
			if not next(selectedItem[1]) then
				selectedItem[1] = nil
			end
		elseif selectionMode == 3 then
			selectedItem[row] = selectedItem[row] or {}
			selectedItem[row][column] = state or nil
			if not next(selectedItem[row]) then
				selectedItem[row] = nil
			end
		end
		triggerEvent("onDgsGridListSelect",gridlist,row,column)
		dgsElementData[gridlist].rowSelect = selectedItem
		return true
	end
	return false
end

function dgsGridListItemIsSelected(gridlist,row,column)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListItemIsSelected at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	local selectedItem = dgsElementData[gridlist].rowSelect
	local rowData = dgsElementData[gridlist].rowData
	if rowData[row] and rowData[row][column] then
		local selectionMode = dgsElementData[gridlist].selectionMode
		if selectionMode == 1 then
			selectedItem[row] = selectedItem[row] or {}
			return selectedItem[row][1] and true or false
		elseif selectionMode == 2 then
			selectedItem[1] = selectedItem[1] or {}
			return selectedItem[1][column] and true or false
		elseif selectionMode == 3 then
			selectedItem[row] = selectedItem[row] or {}
			return selectedItem[row][column] and true or false
		end
	end
	return false
end

function dgsGridListSetItemColor(gridlist,row,column,r,g,b,a)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListSetItemColor at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(row) == "number","Bad argument @dgsGridListSetItemColor at argument 2, expect number got "..type(row))
	assert(type(row) == "number","Bad argument @dgsGridListSetItemColor at argument 2, expect number got "..type(row))
	assert(type(row) == "number","Bad argument @dgsGridListSetItemColor at argument 2, expect number got "..type(row))
	assert(type(row) == "number","Bad argument @dgsGridListSetItemColor at argument 2, expect number got "..type(row))
	local rowData = dgsElementData[gridlist]["rowData"]
	if r and g and b then
		assert(type(r) == "number","Bad argument @dgsGridListSetItemColor at argument 3, expect number got "..type(r))
		assert(type(g) == "number","Bad argument @dgsGridListSetItemColor at argument 4, expect number got "..type(g))
		assert(type(b) == "number","Bad argument @dgsGridListSetItemColor at argument 5, expect number got "..type(b))
		color = tocolor(r,g,b,a or 255)
	elseif r and (not g and not b and not a) then
		assert(type(r) == "number","Bad argument @dgsGridListSetItemColor at argument 3, expect number got "..type(r))
		color = r
	end
	if rowData then
		if row > 0 and row <= #rowData then
			local columnID = #dgsElementData[gridlist]["columnData"]
			if type(column) == "number" then
				if column > 0 and column <= columnID then
					rowData[row][column][2] = color
				end
			else
				for i=1,columnID do
					rowData[row][i][2] = color
				end
			end
			return true
		end
	end
	return false
end

function dgsGridListGetItemColor(gridlist,row,column,notSplitColor)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListGetItemColor at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(row) == "number","Bad argument @dgsGridListGetItemColor at argument 2, expect number got "..type(row))
	assert(type(column) == "number","Bad argument @dgsGridListGetItemColor at argument 3, expect number got "..type(column))
	local rowData = dgsElementData[gridlist].rowData
	if row > 0 and row <= #rowData then
		local columnID = #dgsElementData[gridlist]["columnData"]
		if column > 0 and column <= columnID then
			return notSplitColor and rowData[row][column][2] or fromcolor(rowData[row][column][2])
		end
	end
end

function dgsGridListGetRowBackGroundImage(gridlist,row)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListGetRowBackGroundImage at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(row) == "number","Bad argument @dgsGridListGetRowBackGroundImage at argument 2, expect number got "..type(row))
	local rowData = dgsElementData[gridlist].rowData
	return unpack(rowData[row][-3])
end

function dgsGridListSetRowBackGroundImage(gridlist,row,norimage,selimage,cliimage)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListSetRowBackGroundImage at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(row) == "number","Bad argument @dgsGridListSetRowBackGroundImage at argument 2, expect number got "..type(row))
	if norimage then
		assert(type(norimage) == "string" or isElement(norimage) and getElementType(norimage) == "texture","Bad argument @dgsGridListSetRowBackGroundImage at argument 3, expect string/texture got "..tostring(isElement(norimage) or type(norimage)))
	end
	if selimage then
		assert(type(selimage) == "string" or isElement(selimage) and getElementType(selimage) == "texture","Bad argument @dgsGridListSetRowBackGroundImage at argument 4, expect string/texture got "..tostring(isElement(selimage) or type(selimage)))
	end
	if cliimage then
		assert(type(cliimage) == "string" or isElement(cliimage) and getElementType(cliimage) == "texture","Bad argument @dgsGridListSetRowBackGroundImage at argument 5, expect string/texture got "..tostring(isElement(cliimage) or type(cliimage)))
	end
	local rowData = dgsElementData[gridlist].rowData
	rowData[row][-3] = {norimage,selimage,cliimage}
	return dgsSetData(gridlist,"rowData",rowData)
end

function checkGLScrollBar(scb,new,old)
	local parent = dgsGetParent(source)
	if dgsGetType(parent) == "dgs-dxgridlist" then
		local scrollbars = dgsElementData[parent].scrollbars
		local sx,sy = dgsElementData[parent].absSize[1],dgsElementData[parent].absSize[2]
		local scbThick = dgsElementData[parent].scrollBarThick
		if source == scrollbars[1] then
			local scbThickH = dgsElementData[scrollbars[2]].visible and scbThick or 0
			local rowLength = #dgsElementData[parent].rowData*(dgsElementData[parent].rowHeight+dgsElementData[parent].leading)
			local temp = -new*(rowLength-sy+scbThickH+dgsElementData[parent].columnHeight)/100
			if temp <= 0 then
				local temp = dgsElementData[parent].scrollFloor[1] and math.floor(temp) or temp 
				dgsSetData(parent,"rowMoveOffset",temp)
			end
			triggerEvent("onDgsElementScroll",parent,source,new,old)
		elseif source == scrollbars[2] then
			local scbThickV = dgsElementData[scrollbars[1]].visible and scbThick or 0
			local columnCount =  dgsGridListGetColumnCount(parent)
			local columnWidth = dgsGridListGetColumnAllWidth(parent,columnCount)
			local columnOffset = dgsElementData[parent].columnOffset
			local temp = -new*(columnWidth-sx+scbThickV+columnOffset)/100
			if temp <= 0 then
				local temp = dgsElementData[parent].scrollFloor[2] and math.floor(temp) or temp
				dgsSetData(parent,"columnMoveOffset",temp)
			end
			triggerEvent("onDgsElementScroll",parent,source,new,old)
		end
	end
end

function configGridList(source)
	local scrollbar = dgsElementData[source].scrollbars
	local sx,sy = dgsElementData[source].absSize[1],dgsElementData[source].absSize[2]
	local columnHeight = dgsElementData[source].columnHeight
	local rowHeight = dgsElementData[source].rowHeight
	local scbThick = dgsElementData[source].scrollBarThick
	local columnCount =  dgsGridListGetColumnCount(source)
	local columnWidth = dgsGridListGetColumnAllWidth(source,columnCount,false,true)
	local rowLength = #dgsElementData[source].rowData*(rowHeight+dgsElementData[source].leading)
	local scbX,scbY = sx-scbThick,sy-scbThick
	local oriScbStateV,oriScbStateH = dgsElementData[scrollbar[1]].visible,dgsElementData[scrollbar[2]].visible
	local scbStateV,scbStateH
	if columnWidth > sx then
		scbStateH = true
	elseif columnWidth < sx-scbThick then
		scbStateH = false
	end
	if rowLength > sy-columnHeight then
		scbStateV = true
	elseif rowLength < sy-columnHeight-scbThick then
		scbStateV = false
	end
	if scbStateH == nil then
		scbStateH = scbStateV
	end
	if scbStateV == nil then
		scbStateV = scbStateH
	end
	local forceState = dgsElementData[source].scrollBarState
	if forceState[1] ~= nil then
		scbStateV = forceState[1]
	end
	if forceState[2] ~= nil then
		scbStateH = forceState[2]
	end
	local scbThickV,scbThickH = scbStateV and scbThick or 0,scbStateH and scbThick or 0
	local relSizX,relSizY = sx-scbThickV,sy-scbThickH
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
	dgsSetData(source,"rowMoveOffset",-scroll1*(rowLength-rowShowRange)/100)
	
	local higLen = 1-(rowLength-rowShowRange)/rowLength
	higLen = higLen >= 0.95 and 0.95 or higLen
	dgsSetData(scrollbar[1],"length",{higLen,true})
	local verticalScrollSize = dgsElementData[source].scrollSize/(rowLength-rowShowRange)
	dgsSetData(scrollbar[1],"multiplier",{verticalScrollSize,true})
	
	local widLen = 1-(columnWidth-columnShowRange)/columnWidth
	widLen = widLen >= 0.95 and 0.95 or widLen
	dgsSetData(scrollbar[2],"length",{widLen,true})
	local horizontalScrollSize = dgsElementData[source].scrollSize*5/(columnWidth-columnShowRange)
	dgsSetData(scrollbar[2],"multiplier",{horizontalScrollSize,true})

	local rentarg = dgsElementData[source].renderTarget
	if rentarg then
		if isElement(rentarg[1]) then
			destroyElement(rentarg[1])
		end
		if isElement(rentarg[2]) then
			destroyElement(rentarg[2])
		end
		if not dgsElementData[source].mode then
			local columnRender = dxCreateRenderTarget(relSizX,columnHeight,true)
			if not isElement(columnRender) then
				local videoMemory = dxGetStatus().VideoMemoryFreeForMTA
				outputDebugString("Failed to create render target for column of dgs-dxgridlist [Expected:"..(0.0000076*relSizX*columnHeight).."MB/Free:"..videoMemory.."MB]",2)
			end
			local rowRender = dxCreateRenderTarget(relSizX,rowShowRange,true)
			if not isElement(rowRender) then
				local videoMemory = dxGetStatus().VideoMemoryFreeForMTA
				outputDebugString("Failed to create render target for row of dgs-dxgridlist [Expected:"..(0.0000076*relSizX*rowShowRange).."MB/Free:"..videoMemory.."MB]",2)
			end
			dgsSetData(source,"renderTarget",{columnRender,rowRender})
		end
	end
	dgsGridListUpdateRowMoveOffset(source)
	dgsSetData(source,"configNextFrame",false)
end

function dgsGridListResetScrollBarPosition(gridlist,vertical,horizontal)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListResetScrollBarPosition at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
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
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListGetScrollBar at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	return dgsElementData[gridlist].scrollbars
end

function dgsGridListSetScrollPosition(gridlist,vertical,horizontal)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListSetScrollPosition at at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(not vertical or (type(vertical) == "number" and vertical>= 0 and vertical <= 100),"Bad argument @dgsGridListSetScrollPosition at at argument 2, expect nil/none/number ranges from 0 to 100 got "..dgsGetType(vertical).."("..tostring(vertical)..")")
	assert(not horizontal or (type(horizontal) == "number" and horizontal>= 0 and horizontal <= 100),"Bad argument @dgsGridListSetScrollPosition at at argument 3,  expect nil/none/number ranges from 0 to 100 got "..dgsGetType(horizontal).."("..tostring(horizontal)..")")
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

function dgsGridListGetScrollPosition(gridlist)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListGetScrollPosition at at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	local scb = dgsElementData[gridlist].scrollbars
	return dgsScrollBarGetScrollPosition(scb[1]),dgsScrollBarGetScrollPosition(scb[2])
end

--Make compatibility for GUI
function dgsGridListGetHorizontalScrollPosition(gridlist)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListGetHorizontalScrollPosition at at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	local scb = dgsElementData[gridlist].scrollbars
	return dgsScrollBarGetScrollPosition(scb[2])
end

function dgsGridListSetHorizontalScrollPosition(gridlist,horizontal)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListSetHorizontalScrollPosition at at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(horizontal) == "number" and horizontal>= 0 and horizontal <= 100,"Bad argument @dgsGridListSetHorizontalScrollPosition at at argument 3, expect number ranges from 0 to 100 got "..dgsGetType(horizontal).."("..tostring(horizontal)..")")
	local scb = dgsElementData[gridlist].scrollbars
	return dgsScrollBarSetScrollPosition(scb[2],horizontal)
end

function dgsGridListGetVerticalScrollPosition(gridlist)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListGetVerticalScrollPosition at at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	local scb = dgsElementData[gridlist].scrollbars
	return dgsScrollBarGetScrollPosition(scb[1])
end

function dgsGridListSetVerticalScrollPosition(gridlist,vertical)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListSetVerticalScrollPosition at at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(vertical) == "number" and vertical>= 0 and vertical <= 100,"Bad argument @dgsGridListSetVerticalScrollPosition at at argument 2, expect number ranges from 0 to 100 got "..dgsGetType(vertical).."("..tostring(vertical)..")")
	local scb = dgsElementData[gridlist].scrollbars
	return dgsScrollBarSetScrollPosition(scb[1],vertical)
end
