--Dx Functions
local dxDrawLine3D = dxDrawLine3D
--
local getRotationMatrix = getRotationMatrix
local getPositionFromOffsetByRotMat = getPositionFromOffsetByRotMat
local assert = assert
local type = type
local tableInsert = table.insert
local tableRemove = table.remove

function dgsCreate3DLine(...)
	local x,y,z,color,width,maxDistance
	if select("#",...) == 1 and type(select(1,...)) == "table" then
		local argTable = ...
		x = argTable.x or argTable[1]
		y = argTable.y or argTable[2]
		z = argTable.z or argTable[3]
		rx = argTable.rx or argTable[4]
		ry = argTable.ry or argTable[5]
		rz = argTable.rz or argTable[6]
		width = argTable.width or argTable[7]
		color = argTable.color or argTable[8]
		maxDistance = argTable.maxDistance or argTable[9]
	else
		x,y,z,rx,ry,rz,width,color,maxDistance = ...
	end
	if not(type(x) == "number") then error(dgsGenAsrt(x,"dgsCreate3DLine",1,"number")) end
	if not(type(y) == "number") then error(dgsGenAsrt(y,"dgsCreate3DLine",2,"number")) end
	if not(type(z) == "number") then error(dgsGenAsrt(z,"dgsCreate3DLine",3,"number")) end
	local line3d = createElement("dgs-dx3dline")
	tableInsert(dgsWorld3DTable,line3d)
	dgsSetType(line3d,"dgs-dx3dline")
	dgsElementData[line3d] = {
		position = {x,y,z},
		rotation = {rx or 0,ry or 0,rz or 0},
		color = color or 0xFFFFFFFF,
		maxDistance = maxDistance or 80,
		fadeDistance = maxDistance or 80,
		dimension = -1,
		interior = -1,
		width = width or 1,
		lineData = {},
	}
	triggerEvent("onDgsCreate",line3d,sourceResource)
	return line3d
end

--[[
Line Data Structure:
If StartXYZ don't exist, will use last endXYZ or center
{
	{	startX,	startY,	startZ,	endX,	endY,	endZ,	width,	color,	},
	{	startX,	startY,	startZ,	endX,	endY,	endZ,	width,	color,	},
}
]]
function dgs3DLineAddItem(line,sx,sy,sz,ex,ey,ez,width,color,isRelative)
	if not(dgsGetType(line) == "dgs-dx3dline") then error(dgsGenAsrt(line,"dgs3DLineAddItem",1,"dgs-dx3dline")) end
	if sx or sy or sz then
		if not(type(sx) == "number") then error(dgsGenAsrt(sx,"dgs3DLineAddItem",2,"number")) end
		if not(type(sy) == "number") then error(dgsGenAsrt(sy,"dgs3DLineAddItem",3,"number")) end
		if not(type(sz) == "number") then error(dgsGenAsrt(sz,"dgs3DLineAddItem",4,"number")) end
	end
	if not(type(ex) == "number") then error(dgsGenAsrt(ex,"dgs3DLineAddItem",5,"number")) end
	if not(type(ey) == "number") then error(dgsGenAsrt(ey,"dgs3DLineAddItem",6,"number")) end
	if not(type(ez) == "number") then error(dgsGenAsrt(ez,"dgs3DLineAddItem",7,"number")) end
	local lData = dgsElementData[line].lineData
	local lIndex = #lData+1
	lData[lIndex] = {
		sx,sy,sz,ex,ey,ez,width or lData.width,color or lData.color,isRelative or false
	}
	return lIndex
end

function dgs3DLineRemoveItem(line,index)
	if not(dgsGetType(line) == "dgs-dx3dline") then error(dgsGenAsrt(line,"dgs3DLineRemoveItem",1,"dgs-dx3dline")) end
	local lData = dgsElementData[line].lineData
	local inRange = index >= 1 and index <= #lData
	if not(type(index) == "number" and inRange) then error(dgsGenAsrt(index,"dgs3DLineRemoveItem",2,"number","1~"..(#lData),inRange and "Out Of Range")) end
	tableRemove(lData,index)
	return true
end

function dgs3DLineSetItemPosition(line,index,sx,sy,sz,ex,ey,ez)
	if not(dgsGetType(line) == "dgs-dx3dline") then error(dgsGenAsrt(line,"dgs3DLineSetItemPosition",1,"dgs-dx3dline")) end
	local lData = dgsElementData[line].lineData
	local inRange = index >= 1 and index <= #lData
	if not(type(index) == "number" and inRange) then error(dgsGenAsrt(index,"dgs3DLineSetItemPosition",2,"number","1~"..(#lData),inRange and "Out Of Range")) end
	local ilData = lData[index]
	if sx or sy or sz then
		if not(type(sx) == "number") then error(dgsGenAsrt(sx,"dgs3DLineSetItemPosition",3,"number")) end
		if not(type(sy) == "number") then error(dgsGenAsrt(sy,"dgs3DLineSetItemPosition",4,"number")) end
		if not(type(sz) == "number") then error(dgsGenAsrt(sz,"dgs3DLineSetItemPosition",5,"number")) end
	end
	if not(type(ex) == "number") then error(dgsGenAsrt(ex,"dgs3DLineSetItemPosition",6,"number")) end
	if not(type(ey) == "number") then error(dgsGenAsrt(ey,"dgs3DLineSetItemPosition",7,"number")) end
	if not(type(ez) == "number") then error(dgsGenAsrt(ez,"dgs3DLineSetItemPosition",8,"number")) end
	ilData[1],ilData[2],ilData[3],ilData[4],ilData[5],ilData[6] = sx,sy,sz,ex,ey,ez
	return true
end

function dgs3DLineGetItemPosition(line,index)
	if not(dgsGetType(line) == "dgs-dx3dline") then error(dgsGenAsrt(line,"dgs3DLineGetItemPosition",1,"dgs-dx3dline")) end
	local lData = dgsElementData[line].lineData
	local inRange = index >= 1 and index <= #lData
	if not(type(index) == "number" and inRange) then error(dgsGenAsrt(index,"dgs3DLineGetItemPosition",2,"number","1~"..(#lData),inRange and "Out Of Range")) end
	local ilData = lData[index]
	return ilData[1],ilData[2],ilData[3],ilData[4],ilData[5],ilData[6]
end

function dgs3DLineSetItemWidth(line,index,width)
	if not(dgsGetType(line) == "dgs-dx3dline") then error(dgsGenAsrt(line,"dgs3DLineSetItemWidth",1,"dgs-dx3dline")) end
	local lData = dgsElementData[line].lineData
	local inRange = index >= 1 and index <= #lData
	if not(type(index) == "number" and inRange) then error(dgsGenAsrt(index,"dgs3DLineSetItemWidth",2,"number","1~"..(#lData),inRange and "Out Of Range")) end
	if not(not width or type(width) == "number") then error(dgsGenAsrt(width,"dgs3DLineSetItemWidth",3,"nil/number")) end
	lData[index][7] = width
	return true
end

function dgs3DLineGetItemWidth(line,index)
	if not(dgsGetType(line) == "dgs-dx3dline") then error(dgsGenAsrt(line,"dgs3DLineGetItemWidth",1,"dgs-dx3dline")) end
	local lData = dgsElementData[line].lineData
	local inRange = index >= 1 and index <= #lData
	if not(type(index) == "number" and inRange) then error(dgsGenAsrt(index,"dgs3DLineGetItemWidth",2,"number","1~"..(#lData),inRange and "Out Of Range")) end
	local ilData = lData[index]
	return ilData[7]
end

function dgs3DLineSetItemColor(line,index,color)
	if not(dgsGetType(line) == "dgs-dx3dline") then error(dgsGenAsrt(line,"dgs3DLineSetItemColor",1,"dgs-dx3dline")) end
	local lData = dgsElementData[line].lineData
	local inRange = index >= 1 and index <= #lData
	if not(type(index) == "number" and inRange) then error(dgsGenAsrt(index,"dgs3DLineSetItemColor",2,"number","1~"..(#lData),inRange and "Out Of Range")) end
	if not(not color or type(color) == "number") then error(dgsGenAsrt(color,"dgs3DLineSetItemColor",3,"nil/number")) end
	lData[index][8] = color
	return true
end

function dgs3DLineGetItemColor(line,index)
	if not(dgsGetType(line) == "dgs-dx3dline") then error(dgsGenAsrt(line,"dgs3DLineGetItemColor",1,"dgs-dx3dline")) end
	local lData = dgsElementData[line].lineData
	local inRange = index >= 1 and index <= #lData
	if not(type(index) == "number" and inRange) then error(dgsGenAsrt(index,"dgs3DLineGetItemColor",2,"number","1~"..(#lData),inRange and "Out Of Range")) end
	local ilData = lData[index]
	return ilData[8]
end

function dgs3DLineGetDimension(line)
	if not(dgsGetType(line) == "dgs-dx3dline") then error(dgsGenAsrt(line,"dgs3DLineGetDimension",1,"dgs-dx3dline")) end
	return dgsElementData[line].dimension or -1
end

function dgs3DLineSetDimension(line,dimension)
	if not(dgsGetType(line) == "dgs-dx3dline") then error(dgsGenAsrt(line,"dgs3DLineSetDimension",1,"dgs-dx3dline")) end
	local inRange = dimension >= -1 and dimension <= 65535
	if not(type(dimension) == "number" and inRange) then error(dgsGenAsrt(dimension,"dgs3DLineSetDimension",2,"number","-1~65535",inRange and "Out Of Range")) end
	return dgsSetData(line,"dimension",dimension-dimension%1)
end

function dgs3DLineGetInterior(line)
	if not(dgsGetType(line) == "dgs-dx3dline") then error(dgsGenAsrt(line,"dgs3DLineGetInterior",1,"dgs-dx3dline")) end
	return dgsElementData[line].interior or -1
end

function dgs3DLineSetInterior(line,interior)
	if not(dgsGetType(line) == "dgs-dx3dline") then error(dgsGenAsrt(line,"dgs3DLineSetInterior",1,"dgs-dx3dline")) end
	local inRange = interior >= -1
	if not(type(interior) == "number" and inRange) then error(dgsGenAsrt(interior,"dgs3DLineSetInterior",2,"number","-1~+∞",inRange and "Out Of Range")) end
	return dgsSetData(line,"interior",interior-interior%1)
end

function dgs3DLineAttachToElement(line,element,offX,offY,offZ,offRX,offRY,offRZ)
	if not(dgsGetType(line) == "dgs-dx3dline") then error(dgsGenAsrt(line,"dgs3DLineAttachToElement",1,"dgs-dx3dline")) end
	if not(isElement(element)) then error(dgsGenAsrt(element,"dgs3DLineAttachToElement",2,"element")) end
	local offX,offY,offZ = offX or 0,offY or 0,offZ or 0
	return dgsSetData(line,"attachTo",{element,offX,offY,offZ,offRX,offRY,offRZ})
end

function dgs3DLineIsAttached(line)
	if not(dgsGetType(line) == "dgs-dx3dline") then error(dgsGenAsrt(line,"dgs3DLineIsAttached",1,"dgs-dx3dline")) end
	return dgsElementData[line].attachTo
end

function dgs3DLineDetachFromElement(line)
	if not(dgsGetType(line) == "dgs-dx3dline") then error(dgsGenAsrt(line,"dgs3DLineDetachFromElement",1,"dgs-dx3dline")) end
	return dgsSetData(line,"attachTo",false)
end

function dgs3DLineSetAttachedOffsets(line,offX,offY,offZ,offRX,offRY,offRZ)
	if not(dgsGetType(line) == "dgs-dx3dline") then error(dgsGenAsrt(line,"dgs3DLineSetAttachedOffsets",1,"dgs-dx3dline")) end
	local attachTable = dgsElementData[line].attachTo
	if attachTable then
		local offX,offY,offZ = offX or attachTable[2],offY or attachTable[3],offZ or attachTable[4]
		local offRX,offRY,offRZ = offRX or attachTable[5],offRY or attachTable[6],offRZ or attachTable[7]
		return dgsSetData(line,"attachTo",{attachTable[1],offX,offY,offZ,offRX,offRY,offRZ})
	end
	return false
end

function dgs3DLineGetAttachedOffsets(line,offX,offY,offZ,offRX,offRY,offRZ)
	if not(dgsGetType(line) == "dgs-dx3dline") then error(dgsGenAsrt(line,"dgs3DLineGetAttachedOffsets",1,"dgs-dx3dline")) end
	local attachTable = dgsElementData[line].attachTo
	if attachTable then
		return attachTable[2],attachTable[3],attachTable[4],attachTable[5],attachTable[6],attachTable[7]
	end
	return false
end

function dgs3DLineSetPosition(line,x,y,z)
	if not(dgsGetType(line) == "dgs-dx3dline") then error(dgsGenAsrt(line,"dgs3DLineSetPosition",1,"dgs-dx3dline")) end
	if not(type(x) == "number") then error(dgsGenAsrt(x,"dgs3DLineSetPosition",2,"number")) end
	if not(type(y) == "number") then error(dgsGenAsrt(y,"dgs3DLineSetPosition",3,"number")) end
	if not(type(z) == "number") then error(dgsGenAsrt(z,"dgs3DLineSetPosition",4,"number")) end
	return dgsSetData(line,"position",{x,y,z})
end

function dgs3DLineGetPosition(line)
	if not(dgsGetType(line) == "dgs-dx3dline") then error(dgsGenAsrt(line,"dgs3DLineGetPosition",1,"dgs-dx3dline")) end
	local pos = dgsElementData[line].position
	return pos[1],pos[2],pos[3]
end

function dgs3DLineSetRotation(line,rx,ry,rz)
	if not(dgsGetType(line) == "dgs-dx3dline") then error(dgsGenAsrt(line,"dgs3DLineSetRotation",1,"dgs-dx3dline")) end
	if not(type(rx) == "number") then error(dgsGenAsrt(rx,"dgs3DLineSetRotation",2,"number")) end
	if not(type(ry) == "number") then error(dgsGenAsrt(ry,"dgs3DLineSetRotation",3,"number")) end
	if not(type(rz) == "number") then error(dgsGenAsrt(rz,"dgs3DLineSetRotation",4,"number")) end
	return dgsSetData(line,"rotation",{rx,ry,rz})
end

function dgs3DLineGetRotation(line)
	if not(dgsGetType(line) == "dgs-dx3dline") then error(dgsGenAsrt(line,"dgs3DLineGetRotation",1,"dgs-dx3dline")) end
	local rot = dgsElementData[line].rotation
	return rot[1],rot[2],rot[3]
end

----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------

dgsRenderer["dgs-dx3dline"] = function(source,x,y,w,h,mx,my,cx,cy,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt)
	return rndtgt,true,mx,my,0,0
end

dgs3DRenderer["dgs-dx3dline"] = function(source)
	local eleData = dgsElementData[source]
	local attachTable = eleData.attachTo
	local posTable = eleData.position
	local rotTable = eleData.rotation
	local wx,wy,wz = posTable[1],posTable[2],posTable[3]
	local wrx,wry,wrz
	local width = eleData.width
	local color = eleData.color
	local isRender = true
	if attachTable then
		if isElement(attachTable[1]) then
			if isElementStreamedIn(attachTable[1]) then
				wx,wy,wz = getPositionFromElementOffset(attachTable[1],attachTable[2],attachTable[3],attachTable[4])
				local offrx,offry,offrz = attachTable[5] or 0,attachTable[6] or 0,attachTable[7] or 0
				wrx,wry,wrz = getElementRotation(attachTable[1])
				wrx,wry,wrz = wrx+offrx,wry+offry,wrz+offrz

				eleData.position[1] = wx
				eleData.position[2] = wy
				eleData.position[3] = wz

				eleData.rotation[1] = wrx
				eleData.rotation[2] = wry
				eleData.rotation[3] = wrz

			else
				isRender = false
			end
		else
			eleData.attachTo = false
		end
	end
	if isRender then
		local camX,camY,camZ = getCameraMatrix()
		local maxDistance = eleData.maxDistance
		local distance = ((wx-camX)^2+(wy-camY)^2+(wz-camZ)^2)^0.5
		if distance <= maxDistance and distance > 0 then
			local fadeDistance = eleData.fadeDistance
			local line = eleData.line
			local fadeMulti = 1
			if maxDistance > fadeDistance and distance >= fadeDistance then
				fadeMulti = 1-(distance-fadeDistance)/(maxDistance-fadeDistance)
			end
			local lData = eleData.lineData
			local m11,m12,m13,m21,m22,m23,m31,m32,m33 = getRotationMatrix(wrx,wry,wrz)
			local lastex,lastey,lastez,lastRlt
			for i=1,#lData do
				local lineItem = lData[i]
				local startX,startY,startZ,endX,endY,endZ = 0,0,0,lineItem[4],lineItem[5],lineItem[6]
				local w = lineItem[7] or width
				local c = lineItem[8] or color
				local isRelative = lineItem[9]
				local startIsRelative = true
				if lineItem[1] then
					startX,startY,startZ = lineItem[1],lineItem[2],lineItem[3]
					startIsRelative = isRelative
				elseif i ~= 1 then
					startX,startY,startZ = lastex,lastey,lastez
					startIsRelative = lastRlt
				end
				lastex,lastey,lastez,lastRlt = endX,endY,endZ,isRelative
				if startIsRelative then
					startX,startY,startZ = startX*m11+startY*m21+startZ*m31+wx,startX*m12+startY*m22+startZ*m32+wy,startX*m13+startY*m23+startZ*m33+wz
				end
				if isRelative then
					endX,endY,endZ = endX*m11+endY*m21+endZ*m31+wx,endX*m12+endY*m22+endZ*m32+wy,endX*m13+endY*m23+endZ*m33+wz
				end
				dxDrawLine3D(startX,startY,startZ,endX,endY,endZ,applyColorAlpha(c,fadeMulti),w)
			end
			return true
		end
	end
end