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
local getScreenFromWorldPosition = getScreenFromWorldPosition
local assert = assert
local type = type
local tableInsert = table.insert

function dgsCreate3DImage(x,y,z,img,color,sizeX,sizeY,maxDistance,colorcoded)
	local xCheck,yCheck,zCheck = type(x) == "number",type(y) == "number",type(z) == "number"
	if not xCheck then assert(false,"Bad argument @dgsCreate3DImage at argument 1, expect a number got "..type(x)) end
	if not yCheck then assert(false,"Bad argument @dgsCreate3DImage at argument 2, expect a number got "..type(y)) end
	if not zCheck then assert(false,"Bad argument @dgsCreate3DImage at argument 3, expect a number got "..type(z)) end
	local image3d = createElement("dgs-dx3dimage")
	tableInsert(dx3DImageTable,image3d)
	dgsSetType(image3d,"dgs-dx3dimage")
	dgsElementData[image3d] = {
		renderBuffer = {},
		position = {x,y,z},
		imageSize = {sizeX or 1,sizeY or 1},
		fixImageSize = false,
		color = color or 0xFFFFFFFF,
		colorcoded = colorcoded or false,
		maxDistance = maxDistance or 80,
		fadeDistance = maxDistance or 80,
		dimension = -1,
		interior = -1,
		image = img,
		canBeBlocked = false,
		subPixelPositioning = true,
	}
	triggerEvent("onDgsCreate",image3d,sourceResource)
	return image3d
end

function dgs3DImageGetImage(image)
	assert(dgsGetType(image) == "dgs-dx3dimage","Bad argument @dgs3DImageGetImage at argument 1, expect a dgs-dx3dimage got "..dgsGetType(image))
	return dgsElementData[image].image
end

function dgs3DImageSetImage(image,imgTex)
	assert(dgsGetType(image) == "dgs-dx3dimage","Bad argument @dgs3DImageSetImage at argument 1, expect a dgs-dx3dimage got "..dgsGetType(image))
	return dgsSetData(image,"image",imgTex)
end

function dgs3DImageSetSize(image,w,h)
	assert(dgsGetType(image) == "dgs-dx3dimage","Bad argument @dgs3DImageSetSize at argument 1, expect a dgs-dx3dimage got "..dgsGetType(image))
	assert(type(w) == "number","Bad argument @dgs3DImageSetSize at argument 2, expect a number got "..type(w))
	assert(type(h) == "number","Bad argument @dgs3DImageSetSize at argument 3, expect a number got "..type(h))
	return dgsSetData(image,"imageSize",{w,h})
end

function dgs3DImageGetSize(image)
	assert(dgsGetType(image) == "dgs-dx3dimage","Bad argument @dgs3DImageGetSize at argument 1, expect a dgs-dx3dimage got "..dgsGetType(image))
	local size = dgsElementData[image].imageSize
	return size[1],size[2]
end

function dgs3DImageGetDimension(image)
	assert(dgsGetType(image) == "dgs-dx3dimage","Bad argument @dgs3DImageGetDimension at argument 1, expect a dgs-dx3dimage got "..dgsGetType(image))
	return dgsElementData[image].dimension or -1
end

function dgs3DImageSetDimension(image,dimension)
	assert(dgsGetType(image) == "dgs-dx3dimage","Bad argument @dgs3DImageSetDimension at argument 1, expect a dgs-dx3dimage got "..dgsGetType(image))
	assert(type(dimension) == "number","Bad argument @dgs3DImageSetDimension at argument 2, expect a number got "..type(dimension))
	assert(dimension >= -1 and dimension <= 65535,"Bad argument @dgs3DImageSetDimension at argument 2, out of range [0~65535] got "..dimension)
	return dgsSetData(image,"dimension",dimension-dimension%1)
end

function dgs3DImageGetInterior(image)
	assert(dgsGetType(image) == "dgs-dx3dimage","Bad argument @dgs3DImageGetInterior at argument 1, expect a dgs-dx3dimage got "..dgsGetType(image))
	return dgsElementData[image].interior or -1
end

function dgs3DImageSetInterior(image,interior)
	assert(dgsGetType(image) == "dgs-dx3dimage","Bad argument @dgs3DImageSetInterior at argument 1, expect a dgs-dx3dimage got "..dgsGetType(image))
	assert(type(interior) == "number","Bad argument @dgs3DImageSetInterior at argument 2, expect a number got "..type(interior))
	assert(interior >= -1,"Bad argument @dgs3DImageSetInterior at argument 2, out of range [ -1 ~ +∞ ] got "..interior)
	return dgsSetData(image,"interior",interior-interior%1)
end

function dgs3DImageAttachToElement(image,element,offX,offY,offZ)
	assert(dgsGetType(image) == "dgs-dx3dimage","Bad argument @dgs3DImageAttachToElement at argument 1, expect a dgs-dx3dimage got "..dgsGetType(image))
	assert(isElement(element),"Bad argument @dgs3DImageAttachToElement at argument 2, expect an element got "..dgsGetType(element))
	local offX,offY,offZ = offX or 0,offY or 0,offZ or 0
	return dgsSetData(image,"attachTo",{element,offX,offY,offZ})
end

function dgs3DImageIsAttached(image)
	assert(dgsGetType(image) == "dgs-dx3dimage","Bad argument @dgs3DImageIsAttached at argument 1, expect a dgs-dx3dimage got "..dgsGetType(image))
	return dgsElementData[image].attachTo
end

function dgs3DImageDetachFromElement(image)
	assert(dgsGetType(image) == "dgs-dx3dimage","Bad argument @dgs3DImageDetachFromElement at argument 1, expect a dgs-dx3dimage got "..dgsGetType(image))
	return dgsSetData(image,"attachTo",false)
end

function dgs3DImageSetAttachedOffsets(image,offX,offY,offZ)
	assert(dgsGetType(image) == "dgs-dx3dimage","Bad argument @dgs3DImageSetAttachedOffsets at argument 1, expect a dgs-dx3dimage got "..dgsGetType(image))
	local attachTable = dgsElementData[image].attachTo
	if attachTable then
		local offX,offY,offZ = offX or attachTable[2],offY or attachTable[3],offZ or attachTable[4]
		return dgsSetData(image,"attachTo",{attachTable[1],offX,offY,offZ})
	end
	return false
end

function dgs3DImageGetAttachedOffsets(image,offX,offY,offZ)
	assert(dgsGetType(image) == "dgs-dx3dimage","Bad argument @dgs3DImageGetAttachedOffsets at argument 1, expect a dgs-dx3dimage got "..dgsGetType(image))
	local attachTable = dgsElementData[image].attachTo
	if attachTable then
		local offX,offY,offZ = attachTable[2],attachTable[3],attachTable[4]
		return offX,offY,offZ
	end
	return false
end

function dgs3DImageSetPosition(image,x,y,z)
	assert(dgsGetType(image) == "dgs-dx3dimage","Bad argument @dgs3DImageSetPosition at argument 1, expect a dgs-dx3dimage got "..dgsGetType(image))
	assert(type(x) == "number","Bad argument @dgs3DImageSetPosition at argument 2, expect a number got "..type(x))
	assert(type(y) == "number","Bad argument @dgs3DImageSetPosition at argument 3, expect a number got "..type(y))
	assert(type(z) == "number","Bad argument @dgs3DImageSetPosition at argument 4, expect a number got "..type(z))
	return dgsSetData(image,"position",{x,y,z})
end

function dgs3DImageGetPosition(image)
	assert(dgsGetType(image) == "dgs-dx3dimage","Bad argument @dgs3DImageGetPosition at argument 1, expect a dgs-dx3dimage got "..dgsGetType(image))
	local pos = dgsElementData[image].position
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
dgsRenderer["dgs-dx3dimage"] = function(source,x,y,w,h,mx,my,cx,cy,enabled,eleData,parentAlpha,isPostGUI,rndtgt)
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
			local imageSizeX,imageSizeY = eleData.imageSize[1],eleData.imageSize[2]
			local fadeDistance = eleData.fadeDistance
			local image = eleData.image
			if (not canBeBlocked or (canBeBlocked and isLineOfSightClear(wx, wy, wz, camX, camY, camZ, canBeBlocked.checkBuildings, canBeBlocked.checkVehicles, canBeBlocked.checkPeds, canBeBlocked.checkObjects, canBeBlocked.checkDummies, canBeBlocked.seeThroughStuff,canBeBlocked.ignoreSomeObjectsForCamera))) then
				local fadeMulti = 1
				if maxDistance > fadeDistance and distance >= fadeDistance then
					fadeMulti = 1-(distance-fadeDistance)/(maxDistance-fadeDistance)
				end
				local x,y = getScreenFromWorldPosition(wx,wy,wz,0.5)
				if x and y then
					local x,y = x-x%1,y-y%1
					if eleData.fixImageSize then
						distance = 50
					end
					local antiDistance = 1/distance
					local w = imageSizeX/distance*50
					local h = imageSizeY/distance*50
					local color = applyColorAlpha(eleData.color,parentAlpha*fadeMulti)
					local x,y=x-w*0.5,y-h*0.5
					if image then
						dxDrawImage(x,y,w,h,image,0,0,0,color)
					else
						dxDrawRectangle(x,y,w,h,color)
					end
					------------------------------------OutLine
					local outlineData = eleData.outline
					if outlineData then
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
	return rndtgt,true
end