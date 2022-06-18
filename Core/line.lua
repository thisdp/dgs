dgsLogLuaMemory()
dgsRegisterType("dgs-dxline","dgsBasic","dgsType2D")
dgsRegisterProperties("dgs-dxline",{
	color = 				{	PArg.Color		},
	lineWidth = 			{	PArg.Number		},
})
--Dx Functions
local dxDrawLine = dxDrawLine
--
local assert = assert
local type = type
local tableInsert = table.insert
local tableRemove = table.remove

function dgsCreateLine(...)
	local sRes = sourceResource or resource
	local x,y,w,h,relative,parent,lineWidth,color
	if select("#",...) == 1 and type(select(1,...)) == "table" then
		local argTable = ...
		x = argTable.x or argTable[1]
		y = argTable.y or argTable[2]
		w = argTable.width or argTable.w or argTable[3]
		h = argTable.height or argTable.h or argTable[4]
		relative = argTable.relative or argTable.rlt or argTable[5]
		parent = argTable.parent or argTable.p or argTable[6]
		lineWidth = argTable.lineWidth or argTable.lwid or argTable.lw or argTable[7]
		color = argTable.color or argTable[8]
	else
		x,y,w,h,relative,parent,lineWidth,color = ...
	end
	if not(type(x) == "number") then error(dgsGenAsrt(x,"dgsCreateLine",1,"number")) end
	if not(type(y) == "number") then error(dgsGenAsrt(y,"dgsCreateLine",2,"number")) end
	if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsCreateLine",3,"number")) end
	if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsCreateLine",4,"number")) end
	local line = createElement("dgs-dxline")
	dgsSetType(line,"dgs-dxline")
	dgsElementData[line] = {
		color = color or 0xFFFFFFFF,
		lineWidth = lineWidth or 1,
		lineData = {},
	}
	dgsSetParent(line,parent,true,true)
	calculateGuiPositionSize(line,x,y,relative or false,w,h,relative or false,true)
	onDGSElementCreate(line,sRes)
	return line
end

--[[
Line Data Structure:
If StartXY don't exist, will use last endXY or center
{
	{	startX,	startY,	endX,	endY,	width,	color, relative	},
	{	startX,	startY,	endX,	endY,	width,	color, relative	},
}
]]
function dgsLineAddItem(line,sx,sy,ex,ey,width,color,isRelative)
	if not(dgsGetType(line) == "dgs-dxline") then error(dgsGenAsrt(line,"dgsLineAddItem",1,"dgs-dxline")) end
	if sx or sy then
		if not(type(sx) == "number") then error(dgsGenAsrt(sx,"dgsLineAddItem",2,"number")) end
		if not(type(sy) == "number") then error(dgsGenAsrt(sy,"dgsLineAddItem",3,"number")) end
	end
	if not(type(ex) == "number") then error(dgsGenAsrt(ex,"dgsLineAddItem",4,"number")) end
	if not(type(ey) == "number") then error(dgsGenAsrt(ey,"dgsLineAddItem",5,"number")) end
	local lData = dgsElementData[line].lineData
	local lIndex = #lData+1
	lData[lIndex] = {
		sx,sy,ex,ey,width or lData.lineWidth,color or lData.color,isRelative or false
	}
	return lIndex
end

function dgsLineRemoveItem(line,index)
	if not(dgsGetType(line) == "dgs-dxline") then error(dgsGenAsrt(line,"dgsLineRemoveItem",1,"dgs-dxline")) end
	local lData = dgsElementData[line].lineData
	local inRange = index >= 1 and index <= #lData
	if not(type(index) == "number" and inRange) then error(dgsGenAsrt(index,"dgsLineRemoveItem",2,"number","1~"..(#lData),inRange and "Out Of Range")) end
	tableRemove(lData,index)
	return true
end

function dgsLineSetItemPosition(line,index,sx,sy,ex,ey,isRelative)
	if not(dgsGetType(line) == "dgs-dxline") then error(dgsGenAsrt(line,"dgsLineSetItemPosition",1,"dgs-dxline")) end
	local lData = dgsElementData[line].lineData
	local inRange = index >= 1 and index <= #lData
	if not(type(index) == "number" and inRange) then error(dgsGenAsrt(index,"dgsLineSetItemPosition",2,"number","1~"..(#lData),inRange and "Out Of Range")) end
	local ilData = lData[index]
	if sx or sy then
		if not(type(sx) == "number") then error(dgsGenAsrt(sx,"dgsLineSetItemPosition",3,"number")) end
		if not(type(sy) == "number") then error(dgsGenAsrt(sy,"dgsLineSetItemPosition",4,"number")) end
	end
	if not(type(ex) == "number") then error(dgsGenAsrt(ex,"dgsLineSetItemPosition",5,"number")) end
	if not(type(ey) == "number") then error(dgsGenAsrt(ey,"dgsLineSetItemPosition",6,"number")) end
	ilData[1],ilData[2],ilData[3],ilData[4],ilData[7] = sx,sy,ex,ey,isRelative and true or false
	return true
end

function dgsLineGetItemPosition(line,index)
	if not(dgsGetType(line) == "dgs-dxline") then error(dgsGenAsrt(line,"dgsLineGetItemPosition",1,"dgs-dxline")) end
	local lData = dgsElementData[line].lineData
	local inRange = index >= 1 and index <= #lData
	if not(type(index) == "number" and inRange) then error(dgsGenAsrt(index,"dgsLineGetItemPosition",2,"number","1~"..(#lData),inRange and "Out Of Range")) end
	local ilData = lData[index]
	return ilData[1],ilData[2],ilData[3],ilData[4],ilData[7]
end

function dgsLineSetItemWidth(line,index,width)
	if not(dgsGetType(line) == "dgs-dxline") then error(dgsGenAsrt(line,"dgsLineSetItemWidth",1,"dgs-dxline")) end
	local lData = dgsElementData[line].lineData
	local inRange = index >= 1 and index <= #lData
	if not(type(index) == "number" and inRange) then error(dgsGenAsrt(index,"dgsLineSetItemWidth",2,"number","1~"..(#lData),inRange and "Out Of Range")) end
	if not(not width or type(width) == "number") then error(dgsGenAsrt(width,"dgsLineSetItemWidth",3,"nil/number")) end
	lData[index][5] = width
	return true
end

function dgsLineGetItemWidth(line,index)
	if not(dgsGetType(line) == "dgs-dxline") then error(dgsGenAsrt(line,"dgsLineGetItemWidth",1,"dgs-dxline")) end
	local lData = dgsElementData[line].lineData
	local inRange = index >= 1 and index <= #lData
	if not(type(index) == "number" and inRange) then error(dgsGenAsrt(index,"dgsLineGetItemWidth",2,"number","1~"..(#lData),inRange and "Out Of Range")) end
	local ilData = lData[index]
	return ilData[5]
end

function dgsLineSetItemColor(line,index,color)
	if not(dgsGetType(line) == "dgs-dxline") then error(dgsGenAsrt(line,"dgsLineSetItemColor",1,"dgs-dxline")) end
	local lData = dgsElementData[line].lineData
	local inRange = index >= 1 and index <= #lData
	if not(type(index) == "number" and inRange) then error(dgsGenAsrt(index,"dgsLineSetItemColor",2,"number","1~"..(#lData),inRange and "Out Of Range")) end
	if not(not color or type(color) == "number") then error(dgsGenAsrt(color,"dgsLineSetItemColor",3,"nil/number")) end
	lData[index][6] = color
	return true
end

function dgsLineGetItemColor(line,index)
	if not(dgsGetType(line) == "dgs-dxline") then error(dgsGenAsrt(line,"dgsLineGetItemColor",1,"dgs-dxline")) end
	local lData = dgsElementData[line].lineData
	local inRange = index >= 1 and index <= #lData
	if not(type(index) == "number" and inRange) then error(dgsGenAsrt(index,"dgsLineGetItemColor",2,"number","1~"..(#lData),inRange and "Out Of Range")) end
	local ilData = lData[index]
	return ilData[6]
end

----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxline"] = function(source,x,y,w,h,mx,my,cx,cy,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt)
	local eleData = dgsElementData[source]
	local width = eleData.lineWidth
	local color = eleData.color
	local line = eleData.line
	local lData = eleData.lineData
	local lastex,lastey,lastRlt
	for i=1,#lData do
		local lineItem = lData[i]
		local startX,startY,endX,endY = 0,0,lineItem[3],lineItem[4]
		local lw = lineItem[5] or width
		local c = lineItem[6] or color
		local isRelative = lineItem[7]
		local startIsRelative = true
		if lineItem[1] then
			startX,startY = lineItem[1],lineItem[2]
			startIsRelative = isRelative
		elseif i ~= 1 then
			startX,startY = lastex,lastey
			startIsRelative = lastRlt
		end
		lastex,lastey,lastRlt = endX,endY,isRelative
		if startIsRelative then
			startX,startY = startX*w,startY*h
		end
		if isRelative then
			endX,endY = endX*w,endY*h
		end
		dxDrawLine(startX+x,startY+y,endX+x,endY+y,applyColorAlpha(c,parentAlpha),lw,isPostGUI)
	end
	return rndtgt,false,mx,my,0,0
end