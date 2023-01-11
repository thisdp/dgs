dgsLogLuaMemory()
dgsRegisterType("dgs-dx3dimage","dgsBasic","dgsType3D","dgsTypeScreen3D")
dgsRegisterProperties("dgs-dx3dimage",{
	canBeBlocked = 			{	PArg.Bool, {
											checkBuildings = PArg.Nil+PArg.Bool,
											checkVehicles = PArg.Nil+PArg.Bool,
											checkPeds = PArg.Nil+PArg.Bool,
											checkObjects = PArg.Nil+PArg.Bool,
											checkDummies = PArg.Nil+PArg.Bool,
											seeThroughStuff = PArg.Nil+PArg.Bool,
											ignoreSomeObjectsForCamera = PArg.Nil+PArg.Bool,
											}
							},
	color = 				{	PArg.Color		},
	dimension = 			{	PArg.Number		},
	fadeDistance = 			{	PArg.Number		},
	fixImageSize = 			{	PArg.Bool		},
	imageSize = 			{	{ PArg.Number, PArg.Number }	},
	interior = 				{	PArg.Number		},
	maxDistance = 			{	PArg.Number		},
	position = 				{	{ PArg.Number, PArg.Number, PArg.Number }	},
	rotation = 				{	PArg.Number		},
	rotationCenter = 		{	{ PArg.Number, PArg.Number }	},
	subPixelPositioning = 	{	PArg.Bool		},
	UVPos = 				{	{ PArg.Number, PArg.Number }	},
	UVSize = 				{	{ PArg.Number, PArg.Number }	},
})

--Dx Functions
local dxDrawLine = dxDrawLine
local dxDrawImage = dxDrawImage
local dxDrawImageSection = dxDrawImageSection
local dxDrawRectangle = dxDrawRectangle
--
local getScreenFromWorldPosition = getScreenFromWorldPosition
local assert = assert
local type = type
local tableInsert = table.insert

function dgsCreate3DImage(...)
	local sRes = sourceResource or resource
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
		isOnScreen = false,
		isBlocked = false,
		materialInfo = {},
	}
	dgsElementData[image3d].image = type(img) == "string" and dgsImageCreateTextureExternal(image3d,sRes,img) or img
	onDGSElementCreate(image3d,sRes)
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

function dgs3DImageSetUVSize(image,sx,sy,relative)
	if dgsGetType(image) ~= "dgs-dx3dimage" then error(dgsGenAsrt(image,"dgs3DImageSetUVSize",1,"dgs-dx3dimage")) end
	return dgsSetData(image,"UVSize",{sx,sy,relative})
end

function dgs3DImageGetUVSize(image,relative)
	if dgsGetType(image) ~= "dgs-dx3dimage" then error(dgsGenAsrt(image,"dgs3DImageGetUVSize",1,"dgs-dx3dimage")) end
	local texture = dgsElementData[image].image
	local imageType = dgsGetType(texture)
	if imageType == "texture" or imageType == "svg" then
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
	local imageType = dgsGetType(texture)
	if imageType == "texture" or imageType == "svg" then
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
	local texture = dgsElementData[image].image
	local imageType = dgsGetType(texture)
	if imageType == "texture" or imageType == "svg" then
		return dxGetMaterialSize(texture)
	end
	return false
end

----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------

dgsRenderer["dgs-dx3dimage"] = function(source,x,y,w,h,mx,my,cx,cy,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt)
	local attachTable = eleData.attachTo
	local posTable = eleData.position
	local wx,wy,wz = posTable[1],posTable[2],posTable[3]
	local isRender = true
	if attachTable then
		if isElement(attachTable[1]) then
			if isElementStreamedIn(attachTable[1]) then
				wx,wy,wz = getPositionFromElementOffset(attachTable[1],attachTable[2],attachTable[3],attachTable[4])
				posTable[1],posTable[2],posTable[3] = wx,wy,wz
			else
				isRender = false
			end
		else
			eleData.attachTo = false
		end
	end
	if isRender then
		local maxDistance = eleData.maxDistance
		local camX,camY,camZ = cameraPos[1],cameraPos[2],cameraPos[3]
		local dx,dy,dz = camX-wx,camY-wy,camZ-wz
		local distance = (dx*dx+dy*dy+dz*dz)^0.5
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
			eleData.isBlocked = (not canBeBlocked or (canBeBlocked and isLineOfSightClear(wx, wy, wz, camX, camY, camZ, canBeBlocked.checkBuildings, canBeBlocked.checkVehicles, canBeBlocked.checkPeds, canBeBlocked.checkObjects, canBeBlocked.checkDummies, canBeBlocked.seeThroughStuff,canBeBlocked.ignoreSomeObjectsForCamera)))
			if eleData.isBlocked then
				local fadeMulti = 1
				if maxDistance > fadeDistance and distance >= fadeDistance then
					fadeMulti = 1-(distance-fadeDistance)/(maxDistance-fadeDistance)
				end
				local x,y = getScreenFromWorldPosition(wx,wy,wz,0.5)
				eleData.isOnScreen = x and y
				if eleData.isOnScreen then
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
							local imageType = dgsGetType(image)
							if imageType ~= "texture" and imageType ~= "svg" then
								materialInfo[1],materialInfo[2] = 1,1
							else
								materialInfo[1],materialInfo[2] = dxGetMaterialSize(image)
							end
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
							dxDrawImageSection(x,y,w,h,uvPx,uvPy,uvSx,uvSy,image,rot,rotOffy,rotOffy,color,isPostGUI,rndtgt)
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
							dxDrawImage(x,y,w,h,image,rot,rotOffx,rotOffy,color,isPostGUI,rndtgt)
						end
					else
						dxDrawRectangle(x,y,w,h,color,isPostGUI)
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
							if outlineData[6] ~= false then
								dxDrawLine(x,y+hSideSize,x+w,y+hSideSize,sideColor,sideSize,isPostGUI)
							end
							if outlineData[4] ~= false then
								dxDrawLine(x+hSideSize,y,x+hSideSize,y+h,sideColor,sideSize,isPostGUI)
							end
							if outlineData[5] ~= false then
								dxDrawLine(x+w-hSideSize,y,x+w-hSideSize,y+h,sideColor,sideSize,isPostGUI)
							end
							if outlineData[7] ~= false then
								dxDrawLine(x,y+h-hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,isPostGUI)
							end
						elseif side == "center" then
							if outlineData[6] ~= false then
								dxDrawLine(x-hSideSize,y,x+w+hSideSize,y,sideColor,sideSize,isPostGUI)
							end
							if outlineData[4] ~= false then
								dxDrawLine(x,y+hSideSize,x,y+h-hSideSize,sideColor,sideSize,isPostGUI)
							end
							if outlineData[5] ~= false then
								dxDrawLine(x+w,y+hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,isPostGUI)
							end
							if outlineData[7] ~= false then
								dxDrawLine(x-hSideSize,y+h,x+w+hSideSize,y+h,sideColor,sideSize,isPostGUI)
							end
						elseif side == "out" then
							if outlineData[6] ~= false then
								dxDrawLine(x-sideSize,y-hSideSize,x+w+sideSize,y-hSideSize,sideColor,sideSize,isPostGUI)
							end
							if outlineData[4] ~= false then
								dxDrawLine(x-hSideSize,y,x-hSideSize,y+h,sideColor,sideSize,isPostGUI)
							end
							if outlineData[5] ~= false then
								dxDrawLine(x+w+hSideSize,y,x+w+hSideSize,y+h,sideColor,sideSize,isPostGUI)
							end
							if outlineData[7] ~= false then
								dxDrawLine(x-sideSize,y+h+hSideSize,x+w+sideSize,y+h+hSideSize,sideColor,sideSize,isPostGUI)
							end
						end
					end
				end
			else
				eleData.isOnScreen = false
			end
		end
	end
	return rndtgt,true,mx,my,0,0
end
