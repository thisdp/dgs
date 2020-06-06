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
local lerp = math.lerp
local tostring = tostring
local assert = assert
local type = type
local tableInsert = table.insert
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
	local _x = dgsIsDxElement(parent) and dgsSetParent(gridlist,parent,true,true) or tableInsert(CenterFatherTable,gridlist)
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
	dgsSetData(gridlist,"columnMoveOffsetTemp",0)
	dgsSetData(gridlist,"columnRelative",true)
	dgsSetData(gridlist,"columnShadow",false)
	dgsSetData(gridlist,"guiCompat",false)
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
	dgsSetData(gridlist,"rowMoveOffsetTemp",0)
	dgsSetData(gridlist,"moveHardness",0.1,true)
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
	dgsSetData(gridlist,"font",styleSettings.gridlist.font or systemFont)
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
	dgsSetData(gridlist,"scrollBarLength",{},true)
	dgsAttachToTranslation(gridlist,resourceTranslation[sourceResource or getThisResource()])
	dgsSetData(gridlist,"configNextFrame",false)
	calculateGuiPositionSize(gridlist,x,y,relative or false,sx,sy,relative or false,true)
	local aSize = dgsElementData[gridlist].absSize
	local abx,aby = aSize[1],aSize[2]
	local columnRender,rowRender
	if abx*columnHeight ~= 0 then
		columnRender,err = dxCreateRenderTarget(abx,columnHeight,true,gridlist)
		if columnRender ~= false then
			dgsAttachToAutoDestroy(columnRender,gridlist,-1)
		else
			outputDebugString(err)
		end
	end
	if abx*(aby-columnHeight-scbThick) ~= 0 then
		rowRender,err = dxCreateRenderTarget(abx,aby-columnHeight-scbThick,true,gridlist)
		if rowRender ~= false then
			dgsAttachToAutoDestroy(rowRender,gridlist,-2)
		else
			outputDebugString(err)
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
	if not (dgsGetType(gridlist) == "dgs-dxgridlist") then assert(false,"Bad argument @dgsGridListAddColumn at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist)) end
	if not (type(len) == "number") then assert(false,"Bad argument @dgsGridListAddColumn at argument 3, expect number got "..dgsGetType(len)) end
	local eleData = dgsElementData[gridlist]
	local columnData = eleData.columnData
	local columnDataCount = #columnData
	local _name
	pos = tonumber(pos) or columnDataCount+1
	pos = pos > columnDataCount+1 and columnDataCount+1 or pos
	local aSize = eleData.absSize
	local sx,sy = aSize[1],aSize[2]
	local scrollBarThick = eleData.scrollBarThick
	local multiplier = eleData.columnRelative and sx-scrollBarThick or 1
	local oldLen = 0
	if columnDataCount > 0 then
		oldLen = columnData[columnDataCount][3]+columnData[columnDataCount][2]
	end
	if type(name) == "table" then
		_name = name
		name = dgsTranslate(gridlist,name,sourceResource)
	end
	local columnTable = {
		tostring(name),
		len,
		oldLen,
		alignment or "left",
		_translationText = _name,
	}
	tableInsert(columnData,pos,columnTable)
	local columnTextSize = eleData.columnTextSize
	local columnTextColor = eleData.columnTextColor
	local colorcoded = eleData.colorcoded
	for i=pos+1,columnDataCount+1 do
		columnData[i] = {
			columnData[i][1],
			columnData[i][2],
			dgsGridListGetColumnAllWidth(gridlist,i-1),
			columnData[i][4],
			columnTextColor,
			colorcoded,
			columnTextSize[1],
			columnTextSize[2],
			eleData.font,
		}
	end
	dgsSetData(gridlist,"columnData",columnData)
	local rowData = dgsElementData[gridlist].rowData
	local rowTxtColor = eleData.rowTextColor
	local colorcoded = eleData.colorcoded
	local scale = eleData.rowTextSize
	local font = eleData.font
	for i=1,#rowData do
		rowData[i][pos]= {
			"",
			rowTxtColor,
			colorcoded,
			scale[1],
			scale[2],
			font,
		}
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
	dgsSetVisible(scrollbars[2],lastColumnLen > (sx-scrollBarThick))
	dgsSetData(scrollbars[2],"length",{(sx-scrollBarThick)/lastColumnLen,true})
	dgsSetData(scrollbars[2],"position",dgsElementData[scrollbars[2]].position)
	return true
end

function dgsGridListSetColumnHeight(gridlist,columnHeight)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListSetColumnHeight at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(columnHeight) == "number" and columnHeight>= 0,"Bad argument @dgsGridListSetColumnHeight at argument 2, expect number >= 0 got "..tostring(columnHeight).."("..dgsGetType(columnHeight)..")")
	dgsSetData(gridlist,"columnHeight",columnHeight)
end

function dgsGridListGetColumnHeight(gridlist)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListSetColumnHeight at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	return dgsElementData[gridlist].columnHeight
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

function dgsGridListAutoSizeColumn(gridlist,pos,additionalLength,relative)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListSetColumnWidth at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(pos) == "number","Bad argument @dgsGridListSetColumnWidth at argument 2, expect number got "..dgsGetType(pos))
	local columnData = dgsElementData[gridlist].columnData
	assert(columnData[pos],"Bad argument @dgsGridListSetColumnWidth at argument 2, column index is out of range [min 1, max "..#columnData..", got "..pos.."]")
	local text = dgsGridListGetColumnTitle(gridlist,pos)
	local textSizeX = columnData[pos][7]
	local font = columnData[pos][9] or dgsElementData[gridlist].font
	local wid = dxGetTextWidth(text,textSizeX,font)
	local wid = wid+(relative and additionalLength*wid or additionalLength)
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
		-4					-3							-2				-1				0								1																																2																																	...
		columnOffset		bgImage						hoverable		selectable		bgColor							column1																															column2																																...
{
	{	columnOffset,		{normal,hovering,selected},	true/false,		true/false,		{normal,hovering,selected},	{text,color,colorcoded,scalex,scaley,font,{image,color,imagex,imagey,imagew,imageh},unhoverable,unselectable,attachedElement},		{text,color,colorcoded,scalex,scaley,font,{image,color,imagex,imagey,imagew,imageh},unhoverable,unselectable,attachedElement	},		...		},
	{	columnOffset,		{normal,hovering,selected},	true/false,		true/false,		{normal,hovering,selected},	{text,color,colorcoded,scalex,scaley,font,{image,color,imagex,imagey,imagew,imageh},unhoverable,unselectable,attachedElement},		{text,color,colorcoded,scalex,scaley,font,{image,color,imagex,imagey,imagew,imageh},unhoverable,unselectable,attachedElement	},		...		},
	{	columnOffset,		{normal,hovering,selected},	true/false,		true/false,		{normal,hovering,selected},	{text,color,colorcoded,scalex,scaley,font,{image,color,imagex,imagey,imagew,imageh},unhoverable,unselectable,attachedElement},		{text,color,colorcoded,scalex,scaley,font,{image,color,imagex,imagey,imagew,imageh},unhoverable,unselectable,attachedElement	},		...		},
	{	the same as preview table																																																																																						},
}

	table[i](i<=0) isn't counted in #table
]]

function dgsGridListAddRow(gridlist,row,...)
	if not (dgsGetType(gridlist) == "dgs-dxgridlist") then assert(false,"Bad argument @dgsGridListAddRow at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist)) end
	local eleData = dgsElementData[gridlist]
	local columnData = eleData.columnData
	if not (#columnData > 0) then assert(false,"Bad argument @dgsGridListAddRow, no columns in the grid list") end
	local args = {...}
	local rowData = eleData.rowData
	local rowLength = 0
	row = tonumber(row) or #rowData+1
	local rowTable = {
		[-4] = eleData.defaultColumnOffset,
		[-3] = eleData.rowImage,
		[-2] = true,
		[-1] = true,
		[0] = eleData.rowColor,
	}
	local rowTxtColor = eleData.rowTextColor
	local colorcoded = eleData.colorcoded
	local scale = eleData.rowTextSize
	local font = eleData.font
	for i=1,#eleData.columnData do
		local text,_text = args[i]
		if type(text) == "table" then
			_text = text
			text = dgsTranslate(gridlist,text,sourceResource)
		end
		rowTable[i] = {
			tostring(text or ""),
			rowTxtColor,
			colorcoded,
			scale[1],
			scale[2],
			font,
			_translationText=_text,
		}
	end
	tableInsert(rowData,row,rowTable)
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

function dgsGridListGetRowSelectable(gridlist,row)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListGetRowSelectable at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(row) == "number","Bad argument @dgsGridListGetRowSelectable at argument 2, expect number got "..dgsGetType(row))
	row = row-row%1
	assert(row >= 1,"Bad argument @dgsGridListGetRowSelectable at argument 2, expect number >= 1 got "..row)
	local rowData = dgsElementData[gridlist].rowData
	if rowData[row] then
		return rowData[row][-1]
	end
	return false
end

function dgsGridListSetRowSelectable(gridlist,row,state)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListSetRowSelectable at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(row) == "number","Bad argument @dgsGridListSetRowSelectable at argument 2, expect number got "..dgsGetType(row))
	row = row-row%1
	assert(row >= 1,"Bad argument @dgsGridListSetRowSelectable at argument 2, expect number >= 1 got "..row)
	local rowData = dgsElementData[gridlist].rowData
	if rowData[row] then
		rowData[row][-1] = state and true or false
		return true
	end
	return false
end

function dgsGridListGetRowHoverable(gridlist,row)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListGetRowHoverable at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(row) == "number","Bad argument @dgsGridListGetRowHoverable at argument 2, expect number got "..dgsGetType(row))
	row = row-row%1
	assert(row >= 1,"Bad argument @dgsGridListGetRowSelectable at argument 2, expect number >= 1 got "..row)
	local rowData = dgsElementData[gridlist].rowData
	if rowData[row] then
		return rowData[row][-2]
	end
	return false
end

function dgsGridListSetRowHoverable(gridlist,row,state)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListSetRowHoverable at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(row) == "number","Bad argument @dgsGridListSetRowHoverable at argument 2, expect number got "..dgsGetType(row))
	row = row-row%1
	assert(row >= 1,"Bad argument @dgsGridListSetRowHoverable at argument 2, expect number >= 1 got "..row)
	local rowData = dgsElementData[gridlist].rowData
	if rowData[row] then
		rowData[row][-2] = state and true or false
		return true
	end
	return false
end

function dgsGridListSetItemSelectable(gridlist,row,column,state)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListSetItemSelectable at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(row) == "number","Bad argument @dgsGridListSetItemSelectable at argument 2, expect number got "..dgsGetType(row))
	assert(type(column) == "number","Bad argument @dgsGridListSetItemSelectable at argument 3, expect number got "..dgsGetType(column))
	row,column = row-row%1,column-column%1
	assert(row >= 1,"Bad argument @dgsGridListSetItemSelectable at argument 2, expect number >= 1 got "..row)
	assert(column >= 1 or column <= -5,"Bad argument @dgsGridListSetItemSelectable at argument 3, expect a number >= 1 got "..column)
	local rowData = dgsElementData[gridlist].rowData
	if rowData[row] then
		rowData[row][column][9] = not state or nil
		return true
	end
	return false
end

function dgsGridListSetItemHoverable(gridlist,row,column,state)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListSetItemHoverable at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(row) == "number","Bad argument @dgsGridListSetItemHoverable at argument 2, expect number got "..dgsGetType(row))
	assert(type(column) == "number","Bad argument @dgsGridListSetItemHoverable at argument 3, expect number got "..dgsGetType(column))
	row,column = row-row%1,column-column%1
	assert(row >= 1,"Bad argument @dgsGridListSetItemHoverable at argument 2, expect number >= 1 got "..row)
	assert(column >= 1 or column <= -5,"Bad argument @dgsGridListSetItemHoverable at argument 3, expect a number >= 1 got "..column)
	local rowData = dgsElementData[gridlist].rowData
	if rowData[row] then
		rowData[row][column][8] = not state or nil
		return true
	end
	return false
end

function dgsGridListGetItemSelectable(gridlist,row,column)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListGetItemSelectable at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(row) == "number","Bad argument @dgsGridListGetItemSelectable at argument 2, expect number got "..dgsGetType(row))
	assert(type(column) == "number","Bad argument @dgsGridListGetItemSelectable at argument 3, expect number got "..dgsGetType(column))
	row,column = row-row%1,column-column%1
	assert(row >= 1,"Bad argument @dgsGridListGetItemSelectable at argument 2, expect number >= 1 got "..row)
	assert(column >= 1 or column <= -5,"Bad argument @dgsGridListGetItemSelectable at argument 3, expect a number >= 1 got "..column)
	local rowData = dgsElementData[gridlist].rowData
	if rowData[row] then
		return not (rowData[row][column][9] and true or false)
	end
	return false
end

function dgsGridListGetItemHoverable(gridlist,row,column)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListGetItemHoverable at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(row) == "number","Bad argument @dgsGridListGetItemHoverable at argument 2, expect number got "..dgsGetType(row))
	assert(type(column) == "number","Bad argument @dgsGridListGetItemHoverable at argument 3, expect number got "..dgsGetType(column))
	row,column = row-row%1,column-column%1
	assert(row >= 1,"Bad argument @dgsGridListGetItemHoverable at argument 2, expect number >= 1 got "..row)
	assert(column >= 1 or column <= -5,"Bad argument @dgsGridListGetItemHoverable at argument 3, expect a number >= 1 got "..column)
	local rowData = dgsElementData[gridlist].rowData
	if rowData[row] then
		return not (rowData[row][column][8] and true or false)
	end
	return false
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
	end
	if clearColumn then
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
		imageData[1] = image or imageData[1] or nil
		imageData[2] = color or imageData[2] or white
		imageData[3] = offx or imageData[3] or 0
		imageData[4] = offy or imageData[4] or 0
		imageData[5] = w or imageData[5] or dgsGridListGetColumnWidth(gridlist,column,false)
		imageData[6] = h or imageData[6] or dgsElementData[gridlist].rowHeight
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
	if not (dgsGetType(gridlist) == "dgs-dxgridlist") then assert(false,"Bad argument @dgsGridListSetItemText at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist)) end
	if not (type(row) == "number") then assert(false,"Bad argument @dgsGridListSetItemText at argument 2, expect number got "..type(row)) end
	if not (type(column) == "number") then assert(false,"Bad argument @dgsGridListSetItemText at argument 3, expect number got "..type(column)) end
	row,column = row-row%1,column-column%1
	if not (row >= 1) then assert(false,"Bad argument @dgsGridListSetItemText at argument 2, expect number >= 1 got "..row) end
	if not (column >= 1) and not (column <=-5) then assert(false,"Bad argument @dgsGridListSetItemText at argument 3, expect a number >= 1 got "..column) end
	local rowData = dgsElementData[gridlist].rowData
	if rowData[row] then
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
	if row == -1 then return false end
	assert(row >= 1,"Bad argument @dgsGridListGetItemText at argument 2, expect number >= 1 got "..row)
	assert(column >= 1 or column <= -5,"Bad argument @dgsGridListGetItemText at argument 3, expect a number >= 1 got "..column)
	local rowData = dgsElementData[gridlist].rowData
	if rowData[row] then
		return rowData[row][column][1],rowData[row][column][7]
	end
	return false
end

function dgsGridListGetSelectedItem(gridlist)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","Bad argument @dgsGridListGetSelectedItem at argument 1, expect dgs-dxgridlist got "..dgsGetType(gridlist))
	local row,data = next(dgsElementData[gridlist].rowSelect or {})
	local column,bool = next(data or {})
	return row or -1,column or -1
end

function dgsGridListUpdateRowMoveOffset(gridlist,rowMoveOffset)
	local eleData = dgsElementData[gridlist]
	local rowMoveOffset = rowMoveOffset or eleData.rowMoveOffsetTemp
	local rowHeight = eleData.rowHeight
	local leading = eleData.leading
	local rowHeightLeadingTemp = rowHeight + leading
	local scbThick = eleData.scrollBarThick
	local scrollbars = eleData.scrollbars
	local scbThickH = dgsElementData[ scrollbars[2] ].visible and scbThick or 0
	local w,h = eleData.absSize[1],eleData.absSize[2]
	local columnHeight = eleData.columnHeight
	local rowData = eleData.rowData
	local rowCount = #rowData
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
				local scrollPos = ((row-1)*rowHeightLeadingTemp)/(rowCounts*rowHeightLeadingTemp-gridListRange)*100
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
	if not (type(row) == "number") then assert(false,"Bad argument @dgsGridListSetRowBackGroundImage at argument 2, expect number got "..type(row)) end
	if norimage ~= nil then
		local imgType = dgsGetType(norimage)
		if not (imgType == "texture" or imgType == "shader") then assert(false,"Bad argument @dgsGridListSetRowBackGroundImage at argument 3, expect material got "..dgsGetType(norimage)) end
	end
	if selimage ~= nil then
		local imgType = dgsGetType(selimage)
		if not (imgType == "texture" or imgType == "shader") then assert(false,"Bad argument @dgsGridListSetRowBackGroundImage at argument 4, expect material got "..dgsGetType(selimage)) end
	end
	if cliimage ~= nil then
		local imgType = dgsGetType(cliimage)
		if not (imgType == "texture" or imgType == "shader") then assert(false,"Bad argument @dgsGridListSetRowBackGroundImage at argument 5, expect material got "..dgsGetType(norimage)) end
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
				local temp = dgsElementData[parent].scrollFloor[1] and temp-temp%1 or temp 
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
				local temp = dgsElementData[parent].scrollFloor[2] and temp-temp%1 or temp
				dgsSetData(parent,"columnMoveOffset",temp)
			end
			triggerEvent("onDgsElementScroll",parent,source,new,old)
		end
	end
end

function configGridList(gridlist)
	local scrollbar = dgsElementData[gridlist].scrollbars
	local sx,sy = dgsElementData[gridlist].absSize[1],dgsElementData[gridlist].absSize[2]
	local columnHeight = dgsElementData[gridlist].columnHeight
	local rowHeight = dgsElementData[gridlist].rowHeight
	local scbThick = dgsElementData[gridlist].scrollBarThick
	local columnCount =  dgsGridListGetColumnCount(gridlist)
	local columnWidth = dgsGridListGetColumnAllWidth(gridlist,columnCount,false,true)
	local rowLength = #dgsElementData[gridlist].rowData*(rowHeight+dgsElementData[gridlist].leading)
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
	local forceState = dgsElementData[gridlist].scrollBarState
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
	dgsSetData(gridlist,"rowMoveOffset",-scroll1*(rowLength-rowShowRange)/100)
	
	local scbLengthVrt = dgsElementData[gridlist].scrollBarLength[1]
	local higLen = 1-(rowLength-rowShowRange)/rowLength
	higLen = higLen >= 0.95 and 0.95 or higLen
	dgsSetData(scrollbar[1],"length",scbLengthVrt or {higLen,true})
	local verticalScrollSize = dgsElementData[gridlist].scrollSize/(rowLength-rowShowRange)
	dgsSetData(scrollbar[1],"multiplier",{verticalScrollSize,true})
	
	local scbLengthHoz = dgsElementData[gridlist].scrollBarLength[2]
	local widLen = 1-(columnWidth-columnShowRange)/columnWidth
	widLen = widLen >= 0.95 and 0.95 or widLen
	dgsSetData(scrollbar[2],"length",scbLengthHoz or {widLen,true})
	local horizontalScrollSize = dgsElementData[gridlist].scrollSize*5/(columnWidth-columnShowRange)
	dgsSetData(scrollbar[2],"multiplier",{horizontalScrollSize,true})

	local rentarg = dgsElementData[gridlist].renderTarget
	if rentarg then
		if isElement(rentarg[1]) then destroyElement(rentarg[1]) end
		if isElement(rentarg[2]) then destroyElement(rentarg[2]) end
		if not dgsElementData[gridlist].mode then
			local columnRender,rowRender
			if relSizX*columnHeight ~= 0 then
				columnRender,err = dxCreateRenderTarget(relSizX,columnHeight,true,gridlist)
				if columnRender ~= false then
					dgsAttachToAutoDestroy(columnRender,gridlist,-1)
				else
					outputDebugString(err)
				end
			end
			if relSizX*rowShowRange ~= 0 then
				rowRender,err = dxCreateRenderTarget(relSizX,rowShowRange,true,gridlist)
				if rowRender ~= false then
					dgsAttachToAutoDestroy(rowRender,gridlist,-2)
				else
					outputDebugString(err)
				end
			end
			dgsSetData(gridlist,"renderTarget",{columnRender,rowRender})
		end
	end
	dgsGridListUpdateRowMoveOffset(gridlist)
	dgsSetData(gridlist,"configNextFrame",false)
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

function dgsAttachToGridList(element,gridlist,row,column)
	assert(dgsIsDxElement(element),"Bad argument @dgsAttachToGridList at argument 1, expect dgs-dxgui got "..dgsGetType(element))
	if not (dgsGetType(gridlist) == "dgs-dxgridlist") then assert(false,"Bad argument @dgsAttachToGridList at argument 2, expect dgs-dxgridlist got "..dgsGetType(gridlist)) end
	if not (type(row) == "number") then assert(false,"Bad argument @dgsAttachToGridList at argument 3, expect number got "..type(row)) end
	if not (type(column) == "number") then assert(false,"Bad argument @dgsAttachToGridList at argument 4, expect number got "..type(column)) end
	row,column = row-row%1,column-column%1
	if not (row >= 1) then assert(false,"Bad argument @dgsAttachToGridList at argument 3, expect number >= 1 got "..row) end
	if not (column >= 1) then assert(false,"Bad argument @dgsAttachToGridList at argument 4, expect a number >= 1 got "..column) end
	dgsDetachElements(element)
	dgsSetParent(element,gridlist)
	local rowData = dgsElementData[gridlist].rowData
	if rowData[row] then
		if rowData[row][column] then
			rowData[row][column][10] = rowData[row][column][10] or {}
			table.insert(rowData[row][column][10],element)
		end
	end
	return dgsSetData(element,"attachedToGridList",{gridlist,row,column})
end

function dgsGetAttachedGridList(element)
	local attachData = dgsElementData[element].attachedToGridList
	if attachData then
		return attachData[1],attachData[2],attachData[3]
	end
	return false
end

function dgsDetachFromGridList(element)
	assert(dgsIsDxElement(element),"Bad argument @dgsAttachToGridList at argument 1, expect dgs-dxgui got "..dgsGetType(element))
	local attachData = dgsElementData[element].attachedToGridList
	if not attachData then return false end
	local gridlist = attachData[1]
	local row = attachData[2]
	local column = attachData[3]
	local rowData = dgsElementData[gridlist].rowData
	if rowData[row] then
		if rowData[row][column] then
			rowData[row][column][10] = rowData[row][column][10] or {}
			table.removeItemFromArray(rowData[row][column][10],element)
		end
	end
	return dgsSetData(element,"attachedToGridList",nil)
end
----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxgridlist"] = function(source,x,y,w,h,mx,my,cx,cy,enabled,eleData,parentAlpha,isPostGUI,rndtgt,position,OffsetX,OffsetY,visible)
	if eleData.configNextFrame then
		configGridList(source)
	end
	local bgColor,bgImage = applyColorAlpha(eleData.bgColor,parentAlpha),eleData.bgImage
	local columnColor,columnImage = applyColorAlpha(eleData.columnColor,parentAlpha),eleData.columnImage
	local font = eleData.font or systemFont
	local columnHeight = eleData.columnHeight
	if MouseData.enter == source then
		colorimgid = 2
		if MouseData.clickl == source then
			colorimgid = 3
		end
		MouseData.enterData = false
	end
	dxSetBlendMode(rndtgt and "modulate_add" or "blend")
	if bgImage then
		dxDrawImage(x,y+columnHeight,w,h-columnHeight,bgImage,0,0,0,bgColor,isPostGUI)
	else
		dxDrawRectangle(x,y+columnHeight,w,h-columnHeight,bgColor,isPostGUI)
	end
	if columnImage then
		dxDrawImage(x,y,w,columnHeight,columnImage,0,0,0,columnColor,isPostGUI)
	else
		dxDrawRectangle(x,y,w,columnHeight,columnColor,isPostGUI)
	end
	local columnData,rowData = eleData.columnData,eleData.rowData
	local columnCount,rowCount = #columnData,#rowData
	local sortColumn = eleData.sortColumn
	if sortColumn and columnData[sortColumn] then
		if eleData.nextRenderSort then
			dgsGridListSort(source)
			dgsElementData[source].nextRenderSort = false
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
	local scbThickV,scbThickH = dgsElementData[ scrollbars[1] ].visible and scbThick or 0,dgsElementData[ scrollbars[2] ].visible and scbThick or 0
	local colorcoded = eleData.colorcoded
	local shadow = eleData.rowShadow
	local rowHeightLeadingTemp = rowHeight+leading
	--Smooth Row
	local _rowMoveOffset = eleData.rowMoveOffset
	eleData.rowMoveOffsetTemp = lerp(eleData.moveHardness,eleData.rowMoveOffsetTemp,_rowMoveOffset)
	local rowMoveOffset = eleData.rowMoveOffsetTemp-eleData.rowMoveOffsetTemp%1
	if (rowMoveOffset~=_rowMoveOffset) then
		dgsGridListUpdateRowMoveOffset(source)
	end
	--Smooth Column
	local _columnMoveOffset = eleData.columnMoveOffset
	eleData.columnMoveOffsetTemp = lerp(eleData.moveHardness,eleData.columnMoveOffsetTemp,_columnMoveOffset)
	local columnMoveOffset = eleData.columnMoveOffsetTemp-eleData.columnMoveOffsetTemp%1
	--
	local columnOffset = eleData.columnOffset
	local rowTextSx,rowTextSy = eleData.rowTextSize[1],eleData.rowTextSize[2] or eleData.rowTextSize[1]
	local columnTextSx,columnTextSy = eleData.columnTextSize[1],eleData.columnTextSize[2] or eleData.columnTextSize[1]
	local selectionMode = eleData.selectionMode
	local clip = eleData.clip
	local mouseInsideGridList = mx >= cx and mx <= cx+w and my >= cy and my <= cy+h-scbThickH
	local mouseInsideColumn = mouseInsideGridList and my <= cy+columnHeight
	local mouseInsideRow = mouseInsideGridList and my > cy+columnHeight
	eleData.selectedColumn = -1
	local sortIcon = eleData.sortFunction == sortFunctions_lower and "▼" or (eleData.sortFunction == sortFunctions_upper and "▲") or nil
	local sortColumn = eleData.sortColumn
	local backgroundOffset = eleData.backgroundOffset
	local beforeHit = MouseData.hit
	if not eleData.mode then
		local renderTarget = eleData.renderTarget
		local isDraw1,isDraw2 = isElement(renderTarget[1]),isElement(renderTarget[2])
		dxSetRenderTarget(renderTarget[1],true)
		dxSetBlendMode("modulate_add")
			local cpos = {}
			local cend = {}
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
					cpos[id] = tempCpos
					cend[id] = _tempEndx
					cPosStart = cPosStart or id
					cPosEnd = id
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
			local preSelectLastFrame = eleData.preSelect
			if MouseData.enter == source then		-------PreSelect
				if mouseInsideRow then
					local toffset = (eleData.FromTo[1]*rowHeightLeadingTemp)+rowMoveOffset
					local tempID = (my-cy-columnHeight-toffset)/rowHeightLeadingTemp
					local sid = (tempID-tempID%1)+eleData.FromTo[1]+1
					if sid >= 1 and sid <= rowCount and my-cy-columnHeight < sid*rowHeight+(sid-1)*leading+rowMoveOffset then
						eleData.oPreSelect = sid
						if rowData[sid][-2] ~= false then
							eleData.preSelect = {sid,mouseSelectColumn}
						else
							eleData.preSelect = {-1,mouseSelectColumn}
						end
						MouseData.enterData = true
					else
						eleData.preSelect = {-1,mouseSelectColumn}
					end
				elseif mouseInsideColumn then
					eleData.selectedColumn = mouseSelectColumn
					eleData.preSelect = {}
				else
					eleData.preSelect = {-1,-1}
				end
			end
			local preSelect = eleData.preSelect
			if preSelectLastFrame[1] ~= preSelect[1] or preSelectLastFrame[2] ~= preSelect[2] then
				triggerEvent("onDgsGridListHover",source,preSelect[1],preSelect[2],preSelectLastFrame[1],preSelectLastFrame[2])
			end
			local Select = eleData.rowSelect
			local sectionFont = eleData.sectionFont or font
			local dgsElementBuffer = {}
			for i=eleData.FromTo[1],eleData.FromTo[2] do
				dgsElementBuffer[i] = {}
				local lc_rowData = rowData[i]
				local image,columnOffset,isSection,color = lc_rowData[-3] or eleData.rowImage,lc_rowData[-4] or eleData.columnOffset,lc_rowData[-5],lc_rowData[0] or eleData.rowColor
				if isDraw2 then
					local rowpos = i*rowHeight+rowMoveOffset+(i-1)*leading
					local rowpos_1 = rowpos-rowHeight
					local _x,_y,_sx,_sy = tempColumnOffset+columnOffset,rowpos_1,sW,rowpos
					if eleData.PixelInt then
						_x,_y,_sx,_sy = _x-_x%1,_y-_y%1,_sx-_sx%1,_sy-_sy%1
					end
					local textBuffer = {}
					local textBufferCnt = 1
					
					if not cPosStart or not cPosEnd then break end
					dxSetBlendMode("modulate_add")
					for id = cPosStart,cPosEnd do
						local currentRowData = lc_rowData[id]
						local text = currentRowData[1]
						local _txtFont = isSection and sectionFont or (currentRowData[6] or font)
						local _txtScalex = currentRowData[4] or rowTextSx
						local _txtScaley = currentRowData[5] or rowTextSy
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
						local _sx = cend[id]
						local _backgroundWidth = columnData[id][2]*multiplier
						local _bgX = _x
						local backgroundWidth = _backgroundWidth
						if id == 1 then
							_bgX = _x+backgroundOffset
							backgroundWidth = _backgroundWidth-backgroundOffset
						elseif backgroundWidth+_x-x >= w or columnCount == id then
							backgroundWidth = w-_x+x
						end
						if #image > 0 then
							dxDrawImage(_bgX,_y,backgroundWidth,rowHeight,image[rowState],0,0,0,color[rowState])
						else
							dxDrawRectangle(_bgX,_y,backgroundWidth,rowHeight,color[rowState])
						end
						dgsElementBuffer[i][id] = {currentRowData[10],_x,_y}
						if text then
							local colorcoded = currentRowData[3] == nil and colorcoded or currentRowData[3]
							if currentRowData[7] then
								local imageData = currentRowData[7]
								if isElement(imageData[1]) then
									dxDrawImage(_x+imageData[3],_y+imageData[4],imageData[5],imageData[6],imageData[1],0,0,0,imageData[2])
								else
									dxDrawRectangle(_x+imageData[3],_y+imageData[4],imageData[5],imageData[6],imageData[2])
								end
							end
							textBuffer[textBufferCnt] = {currentRowData[1],_x-_x%1,_sx-_sx%1,currentRowData[2],_txtScalex,_txtScaley,_txtFont,clip,colorcoded,columnData[id][4]}
							textBufferCnt = textBufferCnt + 1
						end
					end
					local textBuffers = #textBuffer
					for a=1,textBuffers do
						local line = textBuffer[a]
						local colorcoded = line[9]
						local text = line[1]
						if shadow then
							if colorcoded then
								text = text:gsub("#%x%x%x%x%x%x","") or text
							end
							dxDrawText(text,line[2]+shadow[1]+rowTextPosOffset[1],_y+shadow[2]+rowTextPosOffset[2],line[3]+shadow[1]+rowTextPosOffset[1],_sy+shadow[2]+rowTextPosOffset[2],shadow[3],line[5],line[6],line[7],line[10],"center",line[8],false,false,false,true)
						end
						dxDrawText(line[1],line[2]+rowTextPosOffset[1],_y+rowTextPosOffset[2],line[3]+rowTextPosOffset[1],_sy+rowTextPosOffset[2],line[4],line[5],line[6],line[7],line[10],"center",line[8],false,false,colorcoded,true)
					end
				end
			end
			for rowIndex,row in pairs(dgsElementBuffer) do
				for columnIndex,items in pairs(row) do
					local offx = items[2]
					local offy = items[3]
					for a=1,#(items[1] or {}) do
						renderGUI(items[1][a],mx,my,enabled,renderTarget[2],{0,0,position[3],position[4]+columnHeight},offx,offy,parentAlpha,visible,checkElement)
					end
				end
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
		if MouseData.enter == source then		-------PreSelect
			if mouseInsideRow then
				local tempID = (my-cy-columnHeight)/rowHeightLeadingTemp-1
				sid = (tempID-tempID%1)+eleData.FromTo[1]+1
				if sid >= 1 and sid <= rowCount and my-cy-columnHeight < sid*rowHeight+(sid-1)*leading+_rowMoveOffset then
					eleData.oPreSelect = sid
					if rowData[sid][-2] ~= false then
						eleData.preSelect = {sid,mouseSelectColumn}
					else
						eleData.preSelect = {-1,mouseSelectColumn}
					end
					MouseData.enterData = true
				else
					eleData.preSelect = {-1,mouseSelectColumn}
				end
			elseif mouseInsideColumn then
				eleData.selectedColumn = mouseSelectColumn
				eleData.preSelect = {}
			else
				eleData.preSelect = {-1,-1}
			end
		end
		local preSelect = eleData.preSelect
		local Select = eleData.rowSelect
		local sectionFont = eleData.sectionFont or font
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
			local textBuffer = {}
			local textBufferCnt = 1
			for id=whichColumnToStart,whichColumnToEnd do
				local currentRowData = lc_rowData[id]
				local text = currentRowData[1]
				local _txtFont = isSection and sectionFont or (currentRowData[6] or font)
				local _txtScalex = currentRowData[4] or rowTextSx
				local _txtScaley = currentRowData[5] or rowTextSy
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
				local _sx = cpos[id+1] or (columnData[id][2])*multiplier
				local backgroundWidth = columnData[id][2]*multiplier
				local _bgX = _x
				if id == 1 then
					_bgX = _x+backgroundOffset
					backgroundWidth = backgroundWidth-backgroundOffset
				elseif backgroundWidth+_x-x >= w or whichColumnToEnd == id then
					backgroundWidth = w-_x+x-scbThickV
				end
				if #image > 0 then
					dxDrawImage(_bgX,_y,backgroundWidth,rowHeight,image[rowState],0,0,0,color[rowState],isPostGUI)
				else
					dxDrawRectangle(_bgX,_y,backgroundWidth,rowHeight,color[rowState],isPostGUI)
				end
				if text ~= "" then
					local colorcoded = currentRowData[3] == nil and colorcoded or currentRowData[3]
					if currentRowData[7] then
						local imageData = currentRowData[7]
						if isElement(imageData[1]) then
							dxDrawImage(_x+imageData[3],_y+imageData[4],imageData[5],imageData[6],imageData[1],0,0,0,imageData[2])
						else
							dxDrawRectangle(_x+imageData[3],_y+imageData[4],imageData[5],imageData[6],imageData[2])
						end
					end
					textBuffer[textBufferCnt] = {currentRowData[1],_x,_sx+_x,currentRowData[2],_txtScalex,_txtScaley,_txtFont,clip,colorcoded,columnData[id][4]}
					textBufferCnt = textBufferCnt+1
				end
			end
			for i=1,#textBuffer do
				local line = textBuffer[i]
				local colorcoded = line[9]
				local text = line[1]
				if shadow then
					if colorcoded then
						text = text:gsub("#%x%x%x%x%x%x","") or text
					end
					dxDrawText(text,line[2]+shadow[1]+rowTextPosOffset[1],_y+shadow[2]+rowTextPosOffset[2],line[3]+shadow[1]+rowTextPosOffset[1],_sy+shadow[2]+rowTextPosOffset[2],shadow[3],line[5],line[6],line[7],line[10],"center",line[8],false,isPostGUI,false,true)
				end
				dxDrawText(line[1],line[2]+rowTextPosOffset[1],_y+rowTextPosOffset[2],line[3]+rowTextPosOffset[1],_sy+rowTextPosOffset[2],line[4],line[5],line[6],line[7],line[10],"center",line[8],false,isPostGUI,colorcoded,true)
			end
		end
	end
	dxSetBlendMode(rndtgt and "modulate_add" or "blend")
	if enabled then
		if beforeHit == MouseData.hit then
			if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
				MouseData.hit = source
			end
		end
	end
	return rndtgt
end

----------------------------------------------------------------
--------------------------OOP Class-----------------------------
----------------------------------------------------------------
dgsOOP["dgs-dxgridlist"] = [[
	getScrollBar = dgsOOP.genOOPFnc("dgsGridListGetScrollBar"),
	setScrollPosition = dgsOOP.genOOPFnc("dgsGridListSetScrollPosition",true),
	getScrollPosition = dgsOOP.genOOPFnc("dgsGridListGetScrollPosition"),
	setHorizontalScrollPosition = dgsOOP.genOOPFnc("dgsGridListSetHorizontalScrollPosition",true),
	getHorizontalScrollPosition = dgsOOP.genOOPFnc("dgsGridListGetHorizontalScrollPosition"),
	setVerticalScrollPosition = dgsOOP.genOOPFnc("dgsGridListSetVerticalScrollPosition",true),
	getVerticalScrollPosition = dgsOOP.genOOPFnc("dgsGridListGetVerticalScrollPosition"),
	resetScrollBarPosition = dgsOOP.genOOPFnc("dgsGridListResetScrollBarPosition",true),
	setColumnRelative = dgsOOP.genOOPFnc("dgsGridListSetColumnRelative",true),
	getColumnRelative = dgsOOP.genOOPFnc("dgsGridListGetColumnRelative"),
	addColumn = dgsOOP.genOOPFnc("dgsGridListAddColumn"),
	getColumnCount = dgsOOP.genOOPFnc("dgsGridListGetColumnCount"),
	removeColumn = dgsOOP.genOOPFnc("dgsGridListRemoveColumn",true),
	getColumnAllWidth = dgsOOP.genOOPFnc("dgsGridListGetColumnAllWidth"),
	getColumnHeight = dgsOOP.genOOPFnc("dgsGridListGetColumnHeight"),
	setColumnHeight = dgsOOP.genOOPFnc("dgsGridListSetColumnHeight",true),
	getColumnWidth = dgsOOP.genOOPFnc("dgsGridListGetColumnWidth"),
	setColumnWidth = dgsOOP.genOOPFnc("dgsGridListSetColumnWidth",true),
	autoSizeColumn = dgsOOP.genOOPFnc("dgsGridListAutoSizeColumn",true),
	getColumnTitle = dgsOOP.genOOPFnc("dgsGridListGetColumnTitle"),
	setColumnTitle = dgsOOP.genOOPFnc("dgsGridListSetColumnTitle",true),
	getColumnFont = dgsOOP.genOOPFnc("dgsGridListGetColumnFont"),
	setColumnFont = dgsOOP.genOOPFnc("dgsGridListSetColumnFont",true),
	addRow = dgsOOP.genOOPFnc("dgsGridListAddRow"),
	insertRowAfter = dgsOOP.genOOPFnc("dgsGridListInsertRowAfter"),
	removeRow = dgsOOP.genOOPFnc("dgsGridListRemoveRow",true),
	clearRow = dgsOOP.genOOPFnc("dgsGridListClearRow",true),
	clearColumn = dgsOOP.genOOPFnc("dgsGridListClearColumn",true),
	clear = dgsOOP.genOOPFnc("dgsGridListClear",true),
	getRowCount = dgsOOP.genOOPFnc("dgsGridListGetRowCount"),
	setItemText = dgsOOP.genOOPFnc("dgsGridListSetItemText",true),
	getItemText = dgsOOP.genOOPFnc("dgsGridListGetItemText"),
	getSelectedItem = dgsOOP.genOOPFnc("dgsGridListGetSelectedItem"),
	setSelectedItem = dgsOOP.genOOPFnc("dgsGridListSetSelectedItem",true),
	setItemColor = dgsOOP.genOOPFnc("dgsGridListSetItemColor",true),
	getItemColor = dgsOOP.genOOPFnc("dgsGridListGetItemColor"),
	setItemData = dgsOOP.genOOPFnc("dgsGridListSetItemData",true),
	getItemData = dgsOOP.genOOPFnc("dgsGridListGetItemData"),
	setItemImage = dgsOOP.genOOPFnc("dgsGridListSetItemImage",true),
	getItemImage = dgsOOP.genOOPFnc("dgsGridListGetItemImage"),
	removeItemImage = dgsOOP.genOOPFnc("dgsGridListRemoveItemImage",true),
	getRowBackGroundImage = dgsOOP.genOOPFnc("dgsGridListGetRowBackGroundImage"),
	setRowBackGroundImage = dgsOOP.genOOPFnc("dgsGridListSetRowBackGroundImage",true),
	getRowBackGroundColor = dgsOOP.genOOPFnc("dgsGridListGetRowBackGroundColor"),
	setRowBackGroundColor = dgsOOP.genOOPFnc("dgsGridListSetRowBackGroundColor",true),
	setRowAsSection = dgsOOP.genOOPFnc("dgsGridListSetRowAsSection",true),
	selectItem = dgsOOP.genOOPFnc("dgsGridListSelectItem",true),
	itemIsSelected = dgsOOP.genOOPFnc("dgsGridListItemIsSelected"),
	setMultiSelectionEnabled = dgsOOP.genOOPFnc("dgsGridListSetMultiSelectionEnabled",true),
	getMultiSelectionEnabled = dgsOOP.genOOPFnc("dgsGridListGetMultiSelectionEnabled"),
	setSelectionMode = dgsOOP.genOOPFnc("dgsGridListSetSelectionMode",true),
	getSelectionMode = dgsOOP.genOOPFnc("dgsGridListGetSelectionMode"),
	setSelectedItems = dgsOOP.genOOPFnc("dgsGridListSetSelectedItems",true),
	getSelectedItems = dgsOOP.genOOPFnc("dgsGridListGetSelectedItems"),
	getSelectedCount = dgsOOP.genOOPFnc("dgsGridListGetSelectedCount"),
	setSortFunction = dgsOOP.genOOPFnc("dgsGridListSetSortFunction",true),
	setAutoSortEnabled = dgsOOP.genOOPFnc("dgsGridListSetAutoSortEnabled",true),
	getAutoSortEnabled = dgsOOP.genOOPFnc("dgsGridListGetAutoSortEnabled"),
	setSortEnabled = dgsOOP.genOOPFnc("dgsGridListSetSortEnabled",true),
	getSortEnabled = dgsOOP.genOOPFnc("dgsGridListGetSortEnabled"),
	setSortColumn = dgsOOP.genOOPFnc("dgsGridListSetSortColumn",true),
	getSortColumn = dgsOOP.genOOPFnc("dgsGridListGetSortColumn"),
	getEnterColumn = dgsOOP.genOOPFnc("dgsGridListGetEnterColumn"),
	sort = dgsOOP.genOOPFnc("dgsGridListSort",true),
	setNavigationEnabled = dgsOOP.genOOPFnc("dgsGridListSetNavigationEnabled",true),
	getNavigationEnabled = dgsOOP.genOOPFnc("dgsGridListGetNavigationEnabled"),
]]