function dgsDxCreateGridList(x,y,sx,sy,relative,parent,columnHeight,bgcolor,columntextcolor,columncolor,rowdefc,rowhovc,rowselc,img,columnimage,rowdefi,rowhovi,rowseli)
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"@dgsDxCreateGridList argument 6,expect dgs-dxgui got "..dgsGetType(parent))
	end
	local gridlist = createElement("dgs-dxgridlist")
	insertResourceDxGUI(sourceResource,gridlist)
	dgsSetType(scrollbar,"dgs-dxgridlist")
	dgsSetData(gridlist,"columnHeight",tonumber(columnHeight) or 20,true)
	dgsSetData(gridlist,"bgimage",img)
	dgsSetData(gridlist,"bgcolor",bgcolor or tocolor(210,210,210,255))
	dgsSetData(gridlist,"columnimage",columnimage)
	dgsSetData(gridlist,"columncolor",columncolor or tocolor(220,220,220,255))
	dgsSetData(gridlist,"columntextcolor",columntextcolor or tocolor(0,0,0,255))
	dgsSetData(gridlist,"columntextsize",{1,1})
	dgsSetData(gridlist,"rowcolor",{rowdefc or tocolor(200,200,200,255),rowhovc or tocolor(150,150,150,255),rowselc or tocolor(0,170,242,255)})
	dgsSetData(gridlist,"rowimage",{rowdefi,rowhovi,rowseli})
	dgsSetData(gridlist,"columnData",{})
	dgsSetData(gridlist,"rowData",{})
	dgsSetData(gridlist,"rowtextsize",{1,1})
	dgsSetData(gridlist,"rowtextcolor",tocolor(0,0,0,255))
	dgsSetData(gridlist,"columnRelative",true)
	dgsSetData(gridlist,"columnMoveOffset",0)
	dgsSetData(gridlist,"sectionColumnOffset",-10)
	dgsSetData(gridlist,"defaultColumnOffset",0)
	--dgsSetData(gridlist,"rowAsSection",{})
	dgsSetData(gridlist,"font",systemFont)
	dgsSetData(gridlist,"sectionFont",systemFont)
	dgsSetData(gridlist,"columnShadow",false)
	dgsSetData(gridlist,"scrollBarThick",20,true)
	dgsSetData(gridlist,"rowHeight",15)
	dgsSetData(gridlist,"colorcoded",false)
	dgsSetData(gridlist,"mode",false,true)
	dgsSetData(gridlist,"rowShadow",false)
	dgsSetData(gridlist,"rowMoveOffset",0)
	dgsSetData(gridlist,"preSelect",-1)
	dgsSetData(gridlist,"select",-1)
	dgsSetData(gridlist,"scrollFloor",{false,false}) --move offset ->int or float
	if isElement(parent) then
		dgsSetParent(gridlist,parent)
	else
		table.insert(MaxFatherTable,gridlist)
	end
	triggerEvent("onClientDgsDxGUIPreCreate",gridlist)
	calculateGuiPositionSize(gridlist,x,y,relative or false,sx,sy,relative or false,true)
	local abx,aby = unpack(dgsElementData[gridlist].absSize)
	local columnRender = dxCreateRenderTarget(abx,columnHeight or 20,true)
	local rowRender = dxCreateRenderTarget(abx,aby-(columnHeight or 20)-20,true)
	dgsSetData(gridlist,"renderTarget",{columnRender,rowRender})
	local scrollbar1 = dgsDxCreateScrollBar(abx-20,0,20,aby-20,false,false,gridlist)
	local scrollbar2 = dgsDxCreateScrollBar(0,aby-20,abx-20,20,true,false,gridlist)
	dgsDxGUISetVisible(scrollbar1,false)
	dgsDxGUISetVisible(scrollbar2,false)
	dgsSetData(scrollbar1,"length",{0,true})
	dgsSetData(scrollbar2,"length",{0,true})
	dgsSetData(gridlist,"scrollbars",{scrollbar1,scrollbar2})
	triggerEvent("onClientDgsDxGUICreate",gridlist)
	return gridlist
end
-----------------------------Column
--[[
	columnData Struct:
	  1									2									N
	  column1							column2								columnN
	{{text1,AllLengthFront,Length},		{text1,AllLengthFront,Length},		{textN,AllLengthFront,Length}, ...}

]]

function dgsDxGridListSetColumnRelative(gridlist,relative,transformColumn)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","@dgsDxGridListSetColumnRelative at argument 1,expect dgs-dxgridlist got "..dgsGetType(gridlist))
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

function dgsDxGridListSetColumnTitle(gridlist,column,name)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","@dgsDxGridListSetColumnTitle at argument 1,expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(column) == "number","@dgsDxGridListSetColumnTitle at argument 2,expect number got "..type(column))
	local columnData = dgsElementData[gridlist].columnData
	if columnData[column] then
		columnData[column][1] = name
		dgsSetData(gridlist,"columnData",columnData)
	end
end

function dgsDxGridListGetColumnTitle(gridlist,column)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","@dgsDxGridListGetColumnTitle at argument 1,expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(column) == "number","@dgsDxGridListGetColumnTitle at argument 2,expect number got "..type(column))
	local columnData = dgsElementData[gridlist].columnData
	return columnData[column][1]
end

function dgsDxGridListGetColumnRelative(gridlist)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","@dgsDxGridListGetColumnRelative at argument 1,expect dgs-dxgridlist got "..dgsGetType(gridlist))
	return dgsElementData[gridlist].columnRelative
end

function dgsDxGridListAddColumn(gridlist,name,len,pos)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","@dgsDxGridListAddColumn at argument 1,expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(len) == "number","@dgsDxGridListAddColumn at argument 2,expect number got "..dgsGetType(len))
	local columnData = dgsElementData[gridlist].columnData
	pos = tonumber(pos) or #columnData+1
	if pos > #columnData+1 then
		pos = #columnData+1
	end
	local sx,sy = unpack(dgsElementData[gridlist].absSize)
	local scrollBarThick = dgsElementData[gridlist].scrollBarThick
	local multiplier = dgsElementData[gridlist].columnRelative and sx-scrollBarThick or 1
	local oldLen = 10/multiplier
	if #columnData > 0 then
		oldLen = columnData[#columnData][3]+columnData[#columnData][2]
	end
	table.insert(columnData,pos,{name,len,oldLen})

	for i=pos+1,#columnData do
		columnData[i] = {columnData[i][1],columnData[i][2],dgsDxGridListGetColumnAllLength(gridlist,i-1)}
	end
	dgsSetData(gridlist,"columnData",columnData)
	oldLen = multiplier*oldLen
	local columnLen = multiplier*len+oldLen
	local scrollbars = dgsElementData[gridlist].scrollbars
	if columnLen > (sx-scrollBarThick) then
		dgsDxGUISetVisible(scrollbars[2],true)
	else
		dgsDxGUISetVisible(scrollbars[2],false)
	end
	dgsSetData(scrollbars[2],"length",{(sx-scrollBarThick)/columnLen,true})
	local rowData = dgsElementData[gridlist].rowData
	for i=1,#rowData do
		rowData[i][pos] = {"",tocolor(0,0,0,255)}
	end
	return pos
end

function dgsDxGridListGetColumnCount(gridlist)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","@dgsDxGridListGetColumnCount at argument 1,expect dgs-dxgridlist got "..dgsGetType(gridlist))
	return #(dgsElementData[gridlist].columnData or {})
end

function dgsDxGridListRemoveColumn(gridlist,pos)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","@dgsDxGridListRemoveColumn at argument 1,expect dgs-dxgridlist got "..dgsGetType(gridlist))
	local columnData = dgsElementData[gridlist].columnData
	local oldLen = columnData[pos][3]
	table.remove(columnData,pos)
	local lastColumnLen = 10
	for k,v in ipairs(columnData) do
		if k >= pos then
			columnData[k] = v[2]-oldLen
			lastColumnLen = columnData[k]
		end
	end
	local sx,sy = unpack(dgsElementData[gridlist].absSize)
	local scrollbars = dgsElementData[gridlist].scrollbars
	local scrollBarThick = dgsElementData[gridlist].scrollBarThick
	if lastColumnLen > (sx-scrollBarThick) then
		dgsDxGUISetVisible(scrollbars[2],true)
	else
		dgsDxGUISetVisible(scrollbars[2],false)
	end
	dgsSetData(scrollbars[2],"length",{(sx-scrollBarThick)/columnData[pos][2],true})
	dgsSetData(scrollbars[2],"position",dgsElementData[scrollbars[2]].position)
	return true
end

--[[
mode Fast(true)/Slow(false)
--]]
function dgsDxGridListGetColumnAllLength(gridlist,pos,relative,mode)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","@dgsDxGridListGetColumnAllLength at argument 1,expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(pos) == "number","@dgsDxGridListGetColumnAllLength at argument 2,expect number got "..dgsGetType(pos))
	local columnData = dgsElementData[gridlist].columnData
	local scbThick = dgsElementData[gridlist].scrollBarThick
	local columnSize = unpack(dgsElementData[gridlist].absSize)
	columnSize = columnSize-scbThick
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
			local dataLength = rlt and 10/columnSize or 10
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
		local dataLength = rlt and 10/columnSize or 10
		if relative then
			return rlt and dataLength or dataLength/columnSize
		else
			return rlt and dataLength*columnSize or dataLength
		end
	end
	return false
end

function dgsDxGridListGetColumnLength(gridlist,pos)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","@dgsDxGridListGetColumnLength at argument 1,expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(pos) == "number","@dgsDxGridListGetColumnLength at argument 2,expect number got "..dgsGetType(pos))
	local columnData = dgsElementData[gridlist].columnData
	if pos > 0 and pos <= #columnData then
		return columnData[pos][2]
	end
	return false
end

function dgsDxGridListSetItemData(gridlist,row,column,data)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","@dgsDxGridListSetItemData at argument 1,expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(row) == "number","@dgsDxGridListSetItemData at argument 2,expect number got "..dgsGetType(row))
	assert(type(column) == "number","@dgsDxGridListSetItemData at argument 3,expect number got "..dgsGetType(column))
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

function dgsDxGridListGetItemData(gridlist,row,column)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","@dgsDxGridListGetItemData at argument 1,expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(row) == "number","@dgsDxGridListGetItemData at argument 2,expect number got "..dgsGetType(row))
	assert(type(column) == "number","@dgsDxGridListGetItemData at argument 3,expect number got "..dgsGetType(column))
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
		-4					-3				-2				-1				0								1										2										...
		columnOffset		bgImage			selectable		clickable		bgColor							column1									column2									...
{
	{	columnOffset,		{def,hov,sel},	true/false,		true/false,		{default,hovering,selected},	{text,color,font,scalex,scaley},		{text,color,font,scalex,scaley},		...		},
	{	columnOffset,		{def,hov,sel},	true/false,		true/false,		{default,hovering,selected},	{text,color,font,scalex,scaley},		{text,color,font,scalex,scaley},		...		},
	{	columnOffset,		{def,hov,sel},	true/false,		true/false,		{default,hovering,selected},	{text,color,font,scalex,scaley},		{text,color,font,scalex,scaley},		...		},
	{	columnOffset,		{def,hov,sel},	true/false,		true/false,		{default,hovering,selected},	{text,color,font,scalex,scaley},		{text,color,font,scalex,scaley},		...		},
	{	the same as preview table																										},
}

	table[i](i<=0) isn't counted in #table
]]


function dgsDxGridListAddRow(gridlist,pos)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","@dgsDxGridListAddRow at argument 1,expect dgs-dxgridlist got "..dgsGetType(gridlist))
	local rowData = dgsElementData[gridlist].rowData
	local rowLength = 0
	pos = pos or #rowData+1
	local rowTable = {}
	rowTable[-4] = dgsElementData[gridlist].defaultColumnOffset
	rowTable[-3] = {}
	rowTable[-2] = true
	rowTable[-1] = true
	rowTable[0] = dgsElementData[gridlist].rowcolor
	for i=1,#dgsElementData[gridlist].columnData do
		rowTable[i] = {"",dgsElementData[gridlist].rowtextcolor}
	end
	table.insert(rowData,pos,rowTable)
 	local scrollbars = dgsElementData[gridlist].scrollbars
	local sx,sy = unpack(dgsElementData[gridlist].absSize)
	local scbThick = dgsElementData[gridlist].scrollBarThick
	local columnHeight = dgsElementData[gridlist].columnHeight
	if pos*dgsElementData[gridlist].rowHeight > (sy-scbThick-columnHeight) then
		dgsDxGUISetVisible(scrollbars[1],true)
	else
		dgsDxGUISetVisible(scrollbars[1],false)
	end
	dgsSetData(scrollbars[1],"length",{(sy-scbThick-columnHeight)/((pos+1)*dgsElementData[gridlist].rowHeight),true})
	return pos
end

function dgsDxGridListSetRowColor(gridlist,row,colordef,colorsel,colorcli)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","@dgsDxGridListSetRowColor at argument 1,expect dgs-dxgridlist got "..dgsGetType(gridlist))
	local rowData = dgsElementData[gridlist].rowData
	if rowData[row] then
		rowData[row][0] = {colordef or 255,colorsel or 255,colorcli or 255}
		return true
	end
	return false
end

function dgsDxGridListGetRowColor(gridlist,pos)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","@dgsDxGridListGetRowColor at argument 1,expect dgs-dxgridlist got "..dgsGetType(gridlist))
	local rowData = dgsElementData[gridlist].rowData
	return rowData[pos] and unpack(rowData[pos][0]) or false
end

function dgsDxGridListRemoveRow(gridlist,pos)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","@dgsDxGridListRemoveRow at argument 1,expect dgs-dxgridlist got "..dgsGetType(gridlist))
	local rowData = dgsElementData[gridlist].rowData
	pos = tonumber(pos) or #rowData
	if pos == 0 or  pos > #rowData then
		return false
	end
	table.remove(rowData,pos)
 	local scrollbars = dgsElementData[gridlist].scrollbars
	local sx,sy = unpack(dgsElementData[gridlist].absSize)
	local scbThick = dgsElementData[gridlist].scrollBarThick
	if (pos-1)*dgsElementData[gridlist].rowHeight > (sy-scbThick-dgsElementData[gridlist].columnHeight) then
		dgsDxGUISetVisible(scrollbars[1],true)
	else
		dgsDxGUISetVisible(scrollbars[1],false)
	end
	dgsSetData(scrollbars[1],"length",{(sy-scbThick-dgsElementData[gridlist].columnHeight)/((pos+1)*dgsElementData[gridlist].rowHeight),true})
	dgsSetData(scrollbars[2],"length",dgsElementData[scrollbars[2]].length)
	return true
end

function dgsDxGridListClearRow(gridlist,notresetSelected)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","@dgsDxGridListClearRow at argument 1,expect dgs-dxgridlist got "..dgsGetType(gridlist))
	local rowData = dgsElementData[gridlist].rowData
 	local scrollbars = dgsElementData[gridlist].scrollbars
	dgsSetData(scrollbars[1],"length",{0,true})
	dgsSetData(scrollbars[1],"position",0)
	dgsDxGUISetVisible(scrollbars[1],false)
	if not notresetSelected then
		 dgsDxGridListSetSelectedItem(gridlist,-1)
	end
	return table.remove(rowData) and dgsSetData(gridlist,"rowData",{})
end

function dgsDxGridListGetRowCount(gridlist)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","@dgsDxGridListGetRowCount at argument 1,expect dgs-dxgridlist got "..dgsGetType(gridlist))
	return #dgsElementData[gridlist].rowData
end

function dgsDxGridListSetItemText(gridlist,row,column,text,develop)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","@dgsDxGridListSetItemText at argument 1,expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(row) == "number","@dgsDxGridListSetItemText at argument 2,expect number got "..type(row))
	assert(type(column) == "number","@dgsDxGridListSetItemText at argument 3,expect number got "..type(column))
	assert(column >= 1 or develop,"@dgsDxGridListSetItemText at argument 3,expect a number >= 1 got "..tostring(row))
	local rowData = dgsElementData[gridlist].rowData
	if column < 1 then
		rowData[row][column] = tostring(text)
	else
		rowData[row][column][1] = tostring(text)
	end
	return dgsSetData(gridlist,"rowData",rowData)
end

function dgsDxGridListSetRowAsSection(gridlist,row,enabled,enableMouseClickAndSelect)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","@dgsDxGridListSetRowAsSection at argument 1,expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(row) == "number","@dgsDxGridListSetRowAsSection at argument 2,expect number got "..type(row))
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

function dgsDxGridListGetItemText(gridlist,row,column)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","@dgsDxGridListGetItemText at argument 1,expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(row) == "number","@dgsDxGridListGetItemText at argument 2,expect number got "..type(row))
	assert(type(column) == "number","@dgsDxGridListGetItemText at argument 3,expect number got "..type(column))
	local rowData = dgsElementData[gridlist].rowData
	return rowData[row][column][1]
end

function dgsDxGridListGetSelectedItem(gridlist)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","@dgsDxGridListGetSelectedItem at argument 1,expect dgs-dxgridlist got "..dgsGetType(gridlist))
	return dgsElementData[gridlist].select
end

function dgsDxGridListSetSelectedItem(gridlist,item)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","@dgsDxGridListSetSelectedItem at argument 1,expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(item) == "number","@dgsDxGridListSetSelectedItem at argument 2,expect number got "..type(item))
	if item == -1 or item > 0 then
		dgsSetData(gridlist,"select",item <= #dgsElementData[gridlist].rowData and item or #dgsElementData[gridlist].rowData)
		triggerEvent("onClientDgsDxGridListSelect",gridlist,dgsElementData[gridlist].select,item)
		return true
	end
	return false
end

function dgsDxGridListSetItemColor(gridlist,row,column,color)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","@dgsDxGridListSetItemColor at argument 1,expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(row) == "number","@dgsDxGridListSetItemColor at argument 2,expect number got "..type(row))
	local rowData = dgsElementData[gridlist]["rowData"]
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

function dgsDxGridListGetItemColor(gridlist,row,column)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","@dgsDxGridListGetItemColor at argument 1,expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(row) == "number","@dgsDxGridListGetItemColor at argument 2,expect number got "..type(row))
	assert(type(column) == "number","@dgsDxGridListGetItemColor at argument 3,expect number got "..type(column))
	local rowData = dgsElementData[gridlist].rowData
	return rowData[row][column][2]
end

function dgsDxGridListGetItemBackGroundImage(gridlist,row)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","@dgsDxGridListGetItemBackGroundImage at argument 1,expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(row) == "number","@dgsDxGridListGetItemBackGroundImage at argument 2,expect number got "..type(row))
	local rowData = dgsElementData[gridlist].rowData
	return unpack(rowData[row][-3])
end

function dgsDxGridListSetItemBackGroundImage(gridlist,row,defimage,selimage,cliimage)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","@dgsDxGridListSetItemBackGroundImage at argument 1,expect dgs-dxgridlist got "..dgsGetType(gridlist))
	assert(type(row) == "number","@dgsDxGridListSetItemBackGroundImage at argument 2,expect number got "..type(row))
	if defimage then
		assert(type(defimage) == "string" or isElement(defimage) and getElementType(defimage) == "texture","@dgsDxGridListSetItemBackGroundImage at argument 3,expect string/texture got "..tostring(isElement(defimage) or type(defimage)))
	end
	if selimage then
		assert(type(selimage) == "string" or isElement(selimage) and getElementType(selimage) == "texture","@dgsDxGridListSetItemBackGroundImage at argument 4,expect string/texture got "..tostring(isElement(selimage) or type(selimage)))
	end
	if cliimage then
		assert(type(cliimage) == "string" or isElement(cliimage) and getElementType(cliimage) == "texture","@dgsDxGridListSetItemBackGroundImage at argument 5,expect string/texture got "..tostring(isElement(cliimage) or type(cliimage)))
	end
	local rowData = dgsElementData[gridlist].rowData
	rowData[row][-3] = {defimage,selimage,cliimage}
	return dgsSetData(gridlist,"rowData",rowData)
end

addEventHandler("onClientDgsDxScrollBarScrollPositionChange",root,function(new,old)
	local parent = dgsGetParent(source)
	if dgsGetType(parent) == "dgs-dxgridlist" then
		local scrollBars = dgsElementData[parent].scrollbars
		local sx,sy = unpack(dgsElementData[parent].absSize)
		if source == scrollBars[1] then
			local rowLength = #dgsElementData[parent].rowData*dgsElementData[parent].rowHeight
			local temp = -new*(rowLength-(sy-dgsElementData[parent].scrollBarThick-dgsElementData[parent].columnHeight))/100
			local temp = dgsElementData[parent].scrollFloor[1] and math.floor(temp) or temp 
			dgsSetData(parent,"rowMoveOffset",temp)
		elseif source == scrollBars[2] then
			local columnCount =  dgsDxGridListGetColumnCount(parent)
			local columnLength = dgsDxGridListGetColumnAllLength(parent,columnCount)
			local temp = -new*(columnLength-sx+dgsElementData[parent].scrollBarThick+10)/100
			local temp = dgsElementData[parent].scrollFloor[2] and math.floor(temp) or temp
			dgsSetData(parent,"columnMoveOffset",temp)
		end
	end
end)

function configGridList(source)
	local scrollbar = dgsElementData[source].scrollbars
	local sx,sy = unpack(dgsElementData[source].absSize)
	local columnHeight = dgsElementData[source].columnHeight
	local rowHeight = dgsElementData[source].rowHeight
	local scbThick = dgsElementData[source].scrollBarThick
	local relSizX,relSizY = sx-scbThick,sy-scbThick
	if scrollbar then
		dgsSetPosition(scrollbar[1],relSizX,0,false)
		dgsSetPosition(scrollbar[2],0,relSizY,false)
		dgsSetSize(scrollbar[1],scbThick,relSizY,false)
		dgsSetSize(scrollbar[2],relSizX,scbThick,false)
		local maxColumn = dgsDxGridListGetColumnCount(source)
		local columnData = dgsElementData[source].columnData
		local columnCount =  dgsDxGridListGetColumnCount(source)
		local columnLength = dgsDxGridListGetColumnAllLength(source,columnCount,false,true)
		if columnLength > relSizX then
			dgsDxGUISetVisible(scrollbar[2],true)
		else
			dgsDxGUISetVisible(scrollbar[2],false)
			dgsSetData(scrollbar[2],"position",0)
		end
		local rowLength = #dgsElementData[source].rowData*rowHeight
		local rowShowRange = relSizY-columnHeight
		if rowLength > rowShowRange then
			dgsDxGUISetVisible(scrollbar[1],true)
		else
			dgsDxGUISetVisible(scrollbar[1],false)
			dgsSetData(scrollbar[1],"position",0)
		end
		local scroll1 = dgsElementData[scrollbar[1]].position
		local scroll2 = dgsElementData[scrollbar[2]].position
		dgsSetData(source,"rowMoveOffset",-scroll1*(rowLength-relSizY+columnHeight)/100)
		dgsSetData(scrollbar[1],"length",{rowShowRange/rowLength,true})
		dgsSetData(scrollbar[2],"length",{relSizX/(columnLength+scbThick),true})
	end
	local rentarg = dgsElementData[source].renderTarget
	if rentarg then
		if isElement(rentarg[1]) then
			destroyElement(rentarg[1])
		end
		if isElement(rentarg[2]) then
			destroyElement(rentarg[2])
		end
		if not dgsElementData[source].mode then
			local columnRender = dxCreateRenderTarget(relSizX+scbThick,columnHeight,true)
			local rowRender = dxCreateRenderTarget(relSizX+scbThick,relSizY-columnHeight,true)
			dgsSetData(source,"renderTarget",{columnRender,rowRender})
		end
	end
end

function dgsDxGridListResetScrollBarPosition(gridlist)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","@dgsDxGridListGetScrollBar at argument 1,expect dgs-dxgridlist got "..dgsGetType(gridlist))
	local scrollbars = dgsElementData[gridlist].scrollbars
	dgsDxScrollBarSetScrollBarPosition(scrollbars[1],0)
	dgsDxScrollBarSetScrollBarPosition(scrollbars[2],0)
	return true
end

function dgsDxGridListGetScrollBar(gridlist)
	assert(dgsGetType(gridlist) == "dgs-dxgridlist","@dgsDxGridListGetScrollBar at argument 1,expect dgs-dxgridlist got "..dgsGetType(gridlist))
	return dgsElementData[gridlist].scrollbars
end