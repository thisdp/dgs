--Dx Functions
local dxDrawLine = dxDrawLine
local dxDrawImage = dxDrawImageExt
local dxDrawRectangle = dxDrawRectangle
--
local getScreenFromWorldPosition = getScreenFromWorldPosition
local assert = assert
local type = type
local tableInsert = table.insert

function dgsCreate3DImage(...)
	local x,y,z,img,color,width,height,maxDistance
	if select("#",...) == 1 and type(select(1,...)) == "table" then
		local argTable = ...
		x = argTable.x or argTable[1]
		y = argTable.y or argTable[2]
		z = argTable.z or argTable[3]
		img = argTable.image or argTable.img or argTable[4]
		color = argTable.color or argTable[5]
		width = argTable.width or argTable[6]
		height = argTable.height or argTable[7]
		maxDistance = argTable.maxDistance or argTable[8]
	else
		x,y,z,img,color,width,height,maxDistances = ...
	end

	if not(type(x) == "number") then error(dgsGenAsrt(x,"dgsCreate3DImage",1,"number")) end
	if not(type(y) == "number") then error(dgsGenAsrt(y,"dgsCreate3DImage",2,"number")) end
	if not(type(z) == "number") then error(dgsGenAsrt(z,"dgsCreate3DImage",3,"number")) end
	local image3d = createElement("dgs-dx3dimage")
	tableInsert(dgsScreen3DTable,image3d)
	dgsSetType(image3d,"dgs-dx3dimage")
	dgsElementData[image3d] = {
		renderBuffer = {},
		position = {x,y,z},
		imageSize = {width or 1,height or 1},
		fixImageSize = false,
		color = color or 0xFFFFFFFF,
		maxDistance = maxDistance or 80,
		fadeDistance = maxDistance or 80,
		dimension = -1,
		interior = -1,
		canBeBlocked = false,
		subPixelPositioning = true,
		UVPos = {},
		UVSize = {},
		rotation = 0,
		rotationCenter = {0,0},
		materialInfo = {},
	}
	dgsElementData[image3d].image = type(img) == "string" and dgsImageCreateTextureExternal(image3d,sourceResource,img) or img
	triggerEvent("onDgsCreate",image3d,sourceResource)
	return image3d
end

function dgs3DImageGetImage(image)
	if not(dgsGetType(image) == "dgs-dx3dimage") then error(dgsGenAsrt(image,"dgs3DImageGetImage",1,"dgs-dx3dimage")) end
	return dgsElementData[image].image
end

function dgs3DImageSetImage(image,imgTex)
	if not(dgsGetType(image) == "dgs-dx3dimage") then error(dgsGenAsrt(image,"dgs3DImageSetImage",1,"dgs-dx3dimage")) end
	return dgsSetData(image,"image",imgTex)
end

function dgs3DImageSetSize(image,w,h)
	if not(dgsGetType(image) == "dgs-dx3dimage") then error(dgsGenAsrt(image,"dgs3DImageSetSize",1,"dgs-dx3dimage")) end
	if not(type(w) == "number") then error(dgsGenAsrt(w,"dgs3DImageSetSize",2,"number")) end
	if not(type(h) == "number") then error(dgsGenAsrt(h,"dgs3DImageSetSize",3,"number")) end
	return dgsSetData(image,"imageSize",{w,h})
end

function dgs3DImageGetSize(image)
	if not(dgsGetType(image) == "dgs-dx3dimage") then error(dgsGenAsrt(image,"dgs3DImageGetSize",1,"dgs-dx3dimage")) end
	local size = dgsElementData[image].imageSize
	return size[1],size[2]
end

function dgs3DImageGetDimension(image)
	if not(dgsGetType(image) == "dgs-dx3dimage") then error(dgsGenAsrt(image,"dgs3DImageGetDimension",1,"dgs-dx3dimage")) end
	return dgsElementData[image].dimension or -1
end

function dgs3DImageSetDimension(image,dimension)
	if not(dgsGetType(image) == "dgs-dx3dimage") then error(dgsGenAsrt(image,"dgs3DImageSetDimension",1,"dgs-dx3dimage")) end
	local inRange = dimension >= -1 and dimension <= 65535
	if not(type(dimension) == "number" and inRange) then error(dgsGenAsrt(dimension,"dgs3DImageSetDimension",2,"number","-1~65535",inRange and "Out Of Range")) end
	return dgsSetData(image,"dimension",dimension-dimension%1)
end

function dgs3DImageGetInterior(image)
	if not(dgsGetType(image) == "dgs-dx3dimage") then error(dgsGenAsrt(image,"dgs3DImageGetInterior",1,"dgs-dx3dimage")) end
	return dgsElementData[image].interior or -1
end

function dgs3DImageSetInterior(image,interior)
	if not(dgsGetType(image) == "dgs-dx3dimage") then error(dgsGenAsrt(image,"dgs3DImageSetInterior",1,"dgs-dx3dimage")) end
	local inRange = interior >= -1
	if not(type(interior) == "number" and inRange) then error(dgsGenAsrt(interior,"dgs3DImageSetInterior",2,"number","-1~+∞",inRange and "Out Of Range")) end
	return dgsSetData(image,"interior",interior-interior%1)
end

function dgs3DImageAttachToElement(image,element,offX,offY,offZ)
	if not(dgsGetType(image) == "dgs-dx3dimage") then error(dgsGenAsrt(image,"dgs3DImageAttachToElement",1,"dgs-dx3dimage")) end
	if not(isElement(element)) then error(dgsGenAsrt(element,"dgs3DImageAttachToElement",2,"element")) end
	local offX,offY,offZ = offX or 0,offY or 0,offZ or 0
	return dgsSetData(image,"attachTo",{element,offX,offY,offZ})
end

function dgs3DImageIsAttached(image)
	if not(dgsGetType(image) == "dgs-dx3dimage") then error(dgsGenAsrt(image,"dgs3DImageIsAttached",1,"dgs-dx3dimage")) end
	return dgsElementData[image].attachTo
end

function dgs3DImageDetachFromElement(image)
	if not(dgsGetType(image) == "dgs-dx3dimage") then error(dgsGenAsrt(image,"dgs3DImageDetachFromElement",1,"dgs-dx3dimage")) end
	return dgsSetData(image,"attachTo",false)
end

function dgs3DImageSetAttachedOffsets(image,offX,offY,offZ)
	if not(dgsGetType(image) == "dgs-dx3dimage") then error(dgsGenAsrt(image,"dgs3DImageSetAttachedOffsets",1,"dgs-dx3dimage")) end
	local attachTable = dgsElementData[image].attachTo
	if attachTable then
		local offX,offY,offZ = offX or attachTable[2],offY or attachTable[3],offZ or attachTable[4]
		return dgsSetData(image,"attachTo",{attachTable[1],offX,offY,offZ})
	end
	return false
end

function dgs3DImageGetAttachedOffsets(image,offX,offY,offZ)
	if not(dgsGetType(image) == "dgs-dx3dimage") then error(dgsGenAsrt(image,"dgs3DImageGetAttachedOffsets",1,"dgs-dx3dimage")) end
	local attachTable = dgsElementData[image].attachTo
	if attachTable then
		local offX,offY,offZ = attachTable[2],attachTable[3],attachTable[4]
		return offX,offY,offZ
	end
	return false
end

function dgs3DImageSetPosition(image,x,y,z)
	if not(dgsGetType(image) == "dgs-dx3dimage") then error(dgsGenAsrt(image,"dgs3DImageSetPosition",1,"dgs-dx3dimage")) end
	if not(type(x) == "number") then error(dgsGenAsrt(x,"dgs3DImageSetPosition",2,"number")) end
	if not(type(y) == "number") then error(dgsGenAsrt(y,"dgs3DImageSetPosition",3,"number")) end
	if not(type(z) == "number") then error(dgsGenAsrt(z,"dgs3DImageSetPosition",4,"number")) end
	return dgsSetData(image,"position",{x,y,z})
end

function dgs3DImageGetPosition(image)
	if not(dgsGetType(image) == "dgs-dx3dimage") then error(dgsGenAsrt(image,"dgs3DImageGetPosition",1,"dgs-dx3dimage")) end
	local pos = dgsElementData[image].position
	return pos[1],pos[2],pos[3]
end

function dgs3DImageSetUVSize(image,sx,sy,relative)
	if dgsGetType(image) ~= "dgs-dx3dimage" then error(dgsGenAsrt(image,"dgs3DImageSetUVSize",1,"dgs-dx3dimage")) end
	return dgsSetData(image,"UVSize",{sx,sy,relative})
end

function dgs3DImageGetUVSize(image,relative)
	if dgsGetType(image) ~= "dgs-dx3dimage" then error(dgsGenAsrt(image,"dgs3DImageGetUVSize",1,"dgs-dx3dimage")) end
	local texture = dgsElementData[image].image
	if isElement(texture) and getElementType(texture) ~= "shader" then
		local UVSize = dgsElementData[image].UVSize or {1,1,true}
		local mx,my = dxGetMaterialSize(texture)
		local sizeU,sizeV = UVSize[1],UVSize[2]
		if UVSize[3] and not relative then
			sizeU,sizeV = sizeU*mx,sizeV*my
		elseif not UVSize[3] and relative then
			sizeU,sizeV = sizeU/mx,sizeV/my
		end
		return sizeU,sizeV
	end
	return false
end

function dgs3DImageSetUVPosition(image,x,y,relative)
	if dgsGetType(image) ~= "dgs-dx3dimage" then error(dgsGenAsrt(image,"dgs3DImageSetUVPosition",1,"dgs-dx3dimage")) end
	return dgsSetData(image,"UVPos",{x,y,relative})
end

function dgs3DImageGetUVPosition(image,relative)
	if dgsGetType(image) ~= "dgs-dx3dimage" then error(dgsGenAsrt(image,"dgs3DImageGetUVPosition",1,"dgs-dx3dimage")) end
	local texture = dgsElementData[image].image
	if isElement(texture) and getElementType(texture) ~= "shader" then
		local UVPos = dgsElementData[image].UVPos or {0,0,true}
		local mx,my = dxGetMaterialSize(texture)
		local posU,posV = UVPos[1],UVPos[2]
		if UVPos[3] and not relative then
			posU,posV = posU*mx,posV*my
		elseif not UVPos[3] and relative then
			posU,posV = posU/mx,posV/my
		end
		return posU,posV
	end
	return false
end

function dgs3DImageGetNativeSize(image)
	if dgsGetType(image) ~= "dgs-dx3dimage" then error(dgsGenAsrt(image,"dgs3DImageGetNativeSize",1,"dgs-dx3dimage")) end
	if isElement(dgsElementData[image].image) then
		return dxGetMaterialSize(image)
	end
	return false
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
dgsRenderer["dgs-dx3dimage"] = function(source,x,y,w,h,mx,my,cx,cy,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt)
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
						local rotOffx,rotOffy = eleData.rotationCenter[1],eleData.rotationCenter[2]
						local rot = eleData.rotation or 0
						local materialInfo = eleData.materialInfo
						local uvPx,uvPy,uvSx,uvSy
						if materialInfo[0] ~= image then	--is latest?
							materialInfo[0] = image	--Update if not
							materialInfo[1],materialInfo[2] = dxGetMaterialSize(image)
						end
						local uvPos = eleData.UVPos
						local px,py,pRlt = uvPos[1],uvPos[2],uvPos[3]
						if px and py then
							uvPx = pRlt and px*materialInfo[1] or px
							uvPy = pRlt and py*materialInfo[2] or py
							local uvSize = eleData.UVSize
							local sx,sy,sRlt = uvSize[1] or 1,uvSize[2] or 1,uvSize[3] or true
							uvSx = pRlt and sx*materialInfo[1] or sx
							uvSy = sRlt and sy*materialInfo[2] or sy
						end
						if uvPx then
							if shadowoffx and shadowoffy and shadowc then
								local shadowc = applyColorAlpha(shadowc,parentAlpha)
								dxDrawImageSection(x+shadowoffx,y+shadowoffy,w,h,uvPx,uvPy,uvSx,uvSy,image,rot,rotOffx,rotOffy,shadowc,isPostGUI,rndtgt)
								if shadowIsOutline then
									dxDrawImageSection(x-shadowoffx,y+shadowoffy,w,h,uvPx,uvPy,uvSx,uvSy,image,rot,rotOffx,rotOffy,shadowc,isPostGUI,rndtgt)
									dxDrawImageSection(x-shadowoffx,y-shadowoffy,w,h,uvPx,uvPy,uvSx,uvSy,image,rot,rotOffx,rotOffy,shadowc,isPostGUI,rndtgt)
									dxDrawImageSection(x+shadowoffx,y-shadowoffy,w,h,uvPx,uvPy,uvSx,uvSy,image,rot,rotOffx,rotOffy,shadowc,isPostGUI,rndtgt)
								end
							end
							dxDrawImageSection(x,y,w,h,uvPx,uvPy,uvSx,uvSy,image,rot,rotOffy,rotOffy,colors,isPostGUI,rndtgt)
						else
							if shadowoffx and shadowoffy and shadowc then
								local shadowc = applyColorAlpha(shadowc,parentAlpha)
								dxDrawImage(x+shadowoffx,y+shadowoffy,w,h,image,rot,rotOffx,rotOffy,shadowc,isPostGUI,rndtgt)
								if shadowIsOutline then
									dxDrawImage(x-shadowoffx,y+shadowoffy,w,h,image,rot,rotOffx,rotOffy,shadowc,isPostGUI,rndtgt)
									dxDrawImage(x-shadowoffx,y-shadowoffy,w,h,image,rot,rotOffx,rotOffy,shadowc,isPostGUI,rndtgt)
									dxDrawImage(x+shadowoffx,y-shadowoffy,w,h,image,rot,rotOffx,rotOffy,shadowc,isPostGUI,rndtgt)
								end
							end
							dxDrawImage(x,y,w,h,image,rot,rotOffx,rotOffy,colors,isPostGUI,rndtgt)
						end
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
	return rndtgt,true,mx,my,0,0
end