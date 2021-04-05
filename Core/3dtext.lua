--Dx Functions
local dxDrawLine = dxDrawLine
local dxDrawText = dxDrawText
local dxGetFontHeight = dxGetFontHeight
local dxGetTextWidth = dxGetTextWidth
--
local getScreenFromWorldPosition = getScreenFromWorldPosition
local assert = assert
local type = type
local tableInsert = table.insert

function dgsCreate3DText(...)
	local x,y,z,text,color,font,sizeX,sizeY,maxDistance,colorcoded
	if select("#",...) == 1 and type(select(1,...)) == "table" then
		local argTable = ...
		x = argTable.x or argTable[1]
		y = argTable.y or argTable[2]
		z = argTable.z or argTable[3]
		text = argTable.txt or argTable.text or argTable[4]
		color = argTable.color or argTable[5]
		font = argTable.font or argTable[6]
		scaleX = argTable.scaleX or argTable[7]
		scaleX = argTable.scaleY or argTable[8]
		maxDistance = argTable.maxDistance or argTable[9]
		colorcoded = argTable.colorcoded or argTable[10]
	else
		x,y,z,text,color,font,scaleX,scaleY,maxDistance,colorcoded = ...
	end
	if not(type(x) == "number") then error(dgsGenAsrt(x,"dgsCreate3DText",1,"number")) end
	if not(type(y) == "number") then error(dgsGenAsrt(y,"dgsCreate3DText",2,"number")) end
	if not(type(z) == "number") then error(dgsGenAsrt(z,"dgsCreate3DText",3,"number")) end
	local text3d = createElement("dgs-dx3dtext")
	tableInsert(dgsScreen3DTable,text3d)
	dgsSetType(text3d,"dgs-dx3dtext")
	dgsElementData[text3d] = {
		renderBuffer = {},
		position = {x,y,z},
		textSize = {scaleX or 1,scaleY or 1},
		fixTextSize = false,
		font = font or styleSettings.text3D.font or systemFont,
		color = color or 0xFFFFFFFF,
		colorcoded = colorcoded or false,
		maxDistance = maxDistance or 80,
		fadeDistance = maxDistance or 80,
		dimension = -1,
		interior = -1,
		canBeBlocked = false,
		subPixelPositioning = true,
	}
	dgsAttachToTranslation(text3d,resourceTranslation[sourceResource or getThisResource()])
	if type(text) == "table" then
		dgsElementData[text3d]._translationText = text
		dgsSetData(text3d,"text",text)
	else
		dgsSetData(text3d,"text",tostring(text))
	end
	triggerEvent("onDgsCreate",text3d,sourceResource)
	return text3d
end

function dgs3DTextGetDimension(text)
	if not(dgsGetType(text) == "dgs-dx3dtext") then error(dgsGenAsrt(text,"dgs3DTextGetDimension",1,"dgs-dx3dtext")) end
	return dgsElementData[text].dimension or -1
end

function dgs3DTextSetDimension(text,dimension)
	if not(dgsGetType(text) == "dgs-dx3dtext") then error(dgsGenAsrt(text,"dgs3DTextSetDimension",1,"dgs-dx3dtext")) end
	local inRange = dimension >= -1 and dimension <= 65535
	if not(type(dimension) == "number" and inRange) then error(dgsGenAsrt(dimension,"dgs3DTextSetDimension",2,"number","-1~65535",inRange and "Out Of Range")) end
	return dgsSetData(text,"dimension",dimension-dimension%1)
end

function dgs3DTextGetInterior(text)
	if not(dgsGetType(text) == "dgs-dx3dtext") then error(dgsGenAsrt(text,"dgs3DTextGetInterior",1,"dgs-dx3dtext")) end
	return dgsElementData[text].interior or -1
end

function dgs3DTextSetInterior(text,interior)
	if not(dgsGetType(text) == "dgs-dx3dtext") then error(dgsGenAsrt(text,"dgs3DTextSetInterior",1,"dgs-dx3dtext")) end
	local inRange = interior >= -1
	if not(type(interior) == "number" and inRange) then error(dgsGenAsrt(interior,"dgs3DTextSetInterior",2,"number","-1~+∞",inRange and "Out Of Range")) end
	return dgsSetData(text,"interior",interior-interior%1)
end

function dgs3DTextAttachToElement(text,element,offX,offY,offZ)
	if not(dgsGetType(text) == "dgs-dx3dtext") then error(dgsGenAsrt(text,"dgs3DTextAttachToElement",1,"dgs-dx3dtext")) end
	if not isElement(element) then error(dgsGenAsrt(element,"dgs3DTextAttachToElement",2,"element")) end
	local offX,offY,offZ = offX or 0,offY or 0,offZ or 0
	return dgsSetData(text,"attachTo",{element,offX,offY,offZ})
end

function dgs3DTextIsAttached(text)
	if not(dgsGetType(text) == "dgs-dx3dtext") then error(dgsGenAsrt(text,"dgs3DTextIsAttached",1,"dgs-dx3dtext")) end
	return dgsElementData[text].attachTo
end

function dgs3DTextDetachFromElement(text)
	if not(dgsGetType(text) == "dgs-dx3dtext") then error(dgsGenAsrt(text,"dgs3DTextDetachFromElement",1,"dgs-dx3dtext")) end
	return dgsSetData(text,"attachTo",false)
end

function dgs3DTextSetAttachedOffsets(text,offX,offY,offZ)
	if not(dgsGetType(text) == "dgs-dx3dtext") then error(dgsGenAsrt(text,"dgs3DTextSetAttachedOffsets",1,"dgs-dx3dtext")) end
	local attachTable = dgsElementData[text].attachTo
	if attachTable then
		local offX,offY,offZ = offX or attachTable[2],offY or attachTable[3],offZ or attachTable[4]
		return dgsSetData(text,"attachTo",{attachTable[1],offX,offY,offZ})
	end
	return false
end

function dgs3DTextGetAttachedOffsets(text,offX,offY,offZ)
	if not(dgsGetType(text) == "dgs-dx3dtext") then error(dgsGenAsrt(text,"dgs3DTextGetAttachedOffsets",1,"dgs-dx3dtext")) end
	local attachTable = dgsElementData[text].attachTo
	if attachTable then
		local offX,offY,offZ = attachTable[2],attachTable[3],attachTable[4]
		return offX,offY,offZ
	end
	return false
end

function dgs3DTextSetPosition(text,x,y,z)
	if not(dgsGetType(text) == "dgs-dx3dtext") then error(dgsGenAsrt(text,"dgs3DTextSetPosition",1,"dgs-dx3dtext")) end
	if not(type(x) == "number") then error(dgsGenAsrt(x,"dgs3DTextSetPosition",2,"number")) end
	if not(type(y) == "number") then error(dgsGenAsrt(y,"dgs3DTextSetPosition",3,"number")) end
	if not(type(z) == "number") then error(dgsGenAsrt(z,"dgs3DTextSetPosition",4,"number")) end
	return dgsSetData(text,"position",{x,y,z})
end

function dgs3DTextGetPosition(text)
	if not(dgsGetType(text) == "dgs-dx3dtext") then error(dgsGenAsrt(text,"dgs3DTextGetPosition",1,"dgs-dx3dtext")) end
	local pos = dgsElementData[text].position
	return pos[1],pos[2],pos[3]
end

----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------

local g_canBeBlocked = {
	checkBuildings = true,
	checkVehicles = true,
	checkPeds = true,
	checkObjects = true,
	checkDummies = true,
	seeThroughStuff = false,
	ignoreSomeObjectsForCamera = false,
}
dgsRenderer["dgs-dx3dtext"] = function(source,x,y,w,h,mx,my,cx,cy,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt)
	local attachTable = eleData.attachTo
	local posTable = eleData.position
	local wx,wy,wz = posTable[1],posTable[2],posTable[3]
	local isRender = true
	if attachTable then
		if isElement(attachTable[1]) then
			if isElementStreamedIn(attachTable[1]) then
				wx,wy,wz = getPositionFromElementOffset(attachTable[1],attachTable[2],attachTable[3],attachTable[4])
				eleData.position = {wx,wy,wz}
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
			local canBeBlocked = eleData.canBeBlocked
			if canBeBlocked then
				if canBeBlocked == true then
					canBeBlocked = g_canBeBlocked
				end
				if canBeBlocked.checkBuildings == nil then canBeBlocked.checkBuildings = g_canBeBlocked.checkBuildings end
				if canBeBlocked.checkVehicles == nil then canBeBlocked.checkVehicles = g_canBeBlocked.checkVehicles end
				if canBeBlocked.checkPeds == nil then canBeBlocked.checkPeds = g_canBeBlocked.checkPeds end
				if canBeBlocked.checkObjects == nil then canBeBlocked.checkObjects = g_canBeBlocked.checkObjects end
				if canBeBlocked.checkDummies == nil then canBeBlocked.checkDummies = g_canBeBlocked.checkDummies end
				if canBeBlocked.seeThroughStuff == nil then canBeBlocked.seeThroughStuff = g_canBeBlocked.seeThroughStuff end
				if canBeBlocked.ignoreSomeObjectsForCamera == nil then canBeBlocked.ignoreSomeObjectsForCamera = g_canBeBlocked.ignoreSomeObjectsForCamera end
			end
			local textSizeX,textSizeY = eleData.textSize[1],eleData.textSize[2]
			local colorcoded = eleData.colorcoded
			local fadeDistance = eleData.fadeDistance
			local text = eleData.text
			local font = eleData.font or systemFont
			local subPixelPositioning = eleData.subPixelPositioning
			if (not canBeBlocked or (canBeBlocked and isLineOfSightClear(wx, wy, wz, camX, camY, camZ, canBeBlocked.checkBuildings, canBeBlocked.checkVehicles, canBeBlocked.checkPeds, canBeBlocked.checkObjects, canBeBlocked.checkDummies, canBeBlocked.seeThroughStuff,canBeBlocked.ignoreSomeObjectsForCamera))) then
				local fadeMulti = 1
				if maxDistance > fadeDistance and distance >= fadeDistance then
					fadeMulti = 1-(distance-fadeDistance)/(maxDistance-fadeDistance)
				end
				local x,y = getScreenFromWorldPosition(wx,wy,wz,0.5)
				if x and y then
					local x,y = x-x%1,y-y%1
					if eleData.fixTextSize then
						distance = 50
					end
					local antiDistance = 1/distance
					local sizeX = textSizeX*textSizeX/distance*50
					local sizeY = textSizeY*textSizeY/distance*50
					local color = applyColorAlpha(eleData.color,parentAlpha*fadeMulti)
					local shadow = eleData.shadow
					if shadow then
						local shadowoffx,shadowoffy,shadowc,shadowIsOutline = shadow[1],shadow[2],shadow[3],shadow[4]
						if shadowoffx and shadowoffy and shadowc then
							local shadowText = text
							if colorcoded then
								shadowText = text:gsub('#%x%x%x%x%x%x','').."\n"
							end
							local shadowc = applyColorAlpha(shadowc,parentAlpha*fadeMulti)
							local shadowoffx,shadowoffy = shadowoffx*antiDistance*50,shadowoffy*antiDistance*50
							dxDrawText(shadowText,x+shadowoffx,y+shadowoffy,_,_,shadowc,sizeX,sizeY,font,"center","center",false,false,false,false,subPixelPositioning)
							if shadowIsOutline then
								dxDrawText(shadowText,x-shadowoffx,y+shadowoffy,_,_,shadowc,sizeX,sizeY,font,"center","center",false,false,false,false,subPixelPositioning)
								dxDrawText(shadowText,x-shadowoffx,y-shadowoffy,_,_,shadowc,sizeX,sizeY,font,"center","center",false,false,false,false,subPixelPositioning)
								dxDrawText(shadowText,x+shadowoffx,y-shadowoffy,_,_,shadowc,sizeX,sizeY,font,"center","center",false,false,false,false,subPixelPositioning)
							end
						end
					end
					dxDrawText(text,x,y,x,y,color,sizeX,sizeY,font,"center","center",false,false,false,colorcoded,subPixelPositioning)
					------------------------------------OutLine
					local outlineData = eleData.outline
					if outlineData then
						local shadowText = colorcoded and text:gsub('#%x%x%x%x%x%x','') or text
						local w,h = dxGetTextWidth(shadowText,sizeX,font),dxGetFontHeight(sizeY,font)
						local x,y=x-w*0.5,y-h*0.5
						local sideColor = outlineData[3]
						local sideSize = outlineData[2]*antiDistance*25
						local hSideSize = sideSize*0.5
						sideColor = applyColorAlpha(sideColor,parentAlpha*fadeMulti)
						local side = outlineData[1]
						if side == "in" then
							dxDrawLine(x,y+hSideSize,x+w,y+hSideSize,sideColor,sideSize)
							dxDrawLine(x+hSideSize,y,x+hSideSize,y+h,sideColor,sideSize)
							dxDrawLine(x+w-hSideSize,y,x+w-hSideSize,y+h,sideColor,sideSize)
							dxDrawLine(x,y+h-hSideSize,x+w,y+h-hSideSize,sideColor,sideSize)
						elseif side == "center" then
							dxDrawLine(x-hSideSize,y,x+w+hSideSize,y,sideColor,sideSize)
							dxDrawLine(x,y+hSideSize,x,y+h-hSideSize,sideColor,sideSize)
							dxDrawLine(x+w,y+hSideSize,x+w,y+h-hSideSize,sideColor,sideSize)
							dxDrawLine(x-hSideSize,y+h,x+w+hSideSize,y+h,sideColor,sideSize)
						elseif side == "out" then
							dxDrawLine(x-sideSize,y-hSideSize,x+w+sideSize,y-hSideSize,sideColor,sideSize)
							dxDrawLine(x-hSideSize,y,x-hSideSize,y+h,sideColor,sideSize)
							dxDrawLine(x+w+hSideSize,y,x+w+hSideSize,y+h,sideColor,sideSize)
							dxDrawLine(x-sideSize,y+h+hSideSize,x+w+sideSize,y+h+hSideSize,sideColor,sideSize)
						end
					end
				end
			end
		end
	end
	return rndtgt,true,mx,my
end