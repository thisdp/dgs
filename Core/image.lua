--Dx Functions
local dxDrawImage = dxDrawImageExt
local dxDrawImageSection = dxDrawImageSectionExt
local dxDrawRectangle = dxDrawRectangle
local dxGetMaterialSize = dxGetMaterialSize
local dxCreateTexture = dxCreateTexture
--DGS Functions
local dgsSetType = dgsSetType
local dgsGetType = dgsGetType
local dgsSetParent = dgsSetParent
local dgsSetData = dgsSetData
local applyColorAlpha = applyColorAlpha
local dgsAttachToAutoDestroy = dgsAttachToAutoDestroy
local calculateGuiPositionSize = calculateGuiPositionSize
--Utilities
local isElement = isElement
local getElementType = getElementType
local triggerEvent = triggerEvent
local createElement = createElement
local assert = assert
local tonumber = tonumber
local type = type

function dgsCreateImage(...)
	local x,y,w,h,img,relative,parent,color
	if select("#",...) == 1 and type(select(1,...)) == "table" then
		local argTable = ...
		x = argTable.x or argTable[1]
		y = argTable.y or argTable[2]
		w = argTable.width or argTable.w or argTable[3]
		h = argTable.height or argTable.h or argTable[4]
		img = argTable.image or argTable.img or argTable[5]
		relative = argTable.relative or argTable.rlt or argTable[6]
		parent = argTable.parent or argTable.p or argTable[7]
		color = arg.Table.color or argTable[8]
	else
		x,y,w,h,img,relative,parent,color = ...
	end
	if not(type(x) == "number") then error(dgsGenAsrt(x,"dgsCreateImage",1,"number")) end
	if not(type(y) == "number") then error(dgsGenAsrt(y,"dgsCreateImage",2,"number")) end
	if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsCreateImage",3,"number")) end
	if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsCreateImage",4,"number")) end
	local image = createElement("dgs-dximage")
	dgsSetType(image,"dgs-dximage")
	dgsSetParent(image,parent,true,true)
	dgsElementData[image] = {
		UVSize = {},
		UVPos = {},
		materialInfo = {},
		color = color or 0xFFFFFFFF,
		rotationCenter = {0,0}, -- 0~1
		rotation = 0, -- 0~360
		shadow = {},
	}
	dgsElementData[image].image = type(img) == "string" and dgsImageCreateTextureExternal(image,sourceResource,img) or img
	calculateGuiPositionSize(image,x,y,relative or false,w,h,relative or false,true)
	triggerEvent("onDgsCreate",image,sourceResource)
	return image
end

function dgsImageGetImage(image)
	if dgsGetType(image) ~= "dgs-dximage" then error(dgsGenAsrt(image,"dgsImageGetImage",1,"dgs-dximage")) end
	return dgsElementData[image].image
end

function dgsImageSetImage(image,img)
	if dgsGetType(image) ~= "dgs-dximage" then error(dgsGenAsrt(image,"dgsImageSetImage",1,"dgs-dximage")) end
	local texture = dgsElementData[image].image
	if isElement(texture) and dgsElementData[texture] then
		if dgsElementData[texture].parent == image then
			destroyElement(texture)
		end
	end
	texture = img
	if type(texture) == "string" then
		texture,textureExists = dgsImageCreateTextureExternal(image,sourceResource,texture)
		if not textureExists then return false end
	end
	local materialInfo = dgsElementData[image].materialInfo
	materialInfo[0] = texture
	if isElement(texture) then
		materialInfo[1],materialInfo[2] = dxGetMaterialSize(texture)
	else
		materialInfo[0] = nil
	end
	return dgsSetData(image,"image",texture)
end

function dgsImageCreateTextureExternal(image,res,img)
	if res then
		img = img:gsub("\\","/")
		if not img:find(":") then
			img = ":"..getResourceName(res).."/"..img
			img = img:gsub("//","/") or img
		end
	end
	local texture = dxCreateTexture(img)
	if isElement(texture) then
		dgsElementData[texture] = {parent=image}
		dgsAttachToAutoDestroy(texture,image)
		return texture,true
	end
	return false
end

function dgsImageSetUVSize(image,sx,sy,relative)
	if dgsGetType(image) ~= "dgs-dximage" then error(dgsGenAsrt(image,"dgsImageSetUVSize",1,"dgs-dximage")) end
	return dgsSetData(image,"UVSize",{sx,sy,relative})
end

function dgsImageGetUVSize(image,relative)
	if dgsGetType(image) ~= "dgs-dximage" then error(dgsGenAsrt(image,"dgsImageGetUVSize",1,"dgs-dximage")) end
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

function dgsImageSetUVPosition(image,x,y,relative)
	if dgsGetType(image) ~= "dgs-dximage" then error(dgsGenAsrt(image,"dgsImageSetUVPosition",1,"dgs-dximage")) end
	return dgsSetData(image,"UVPos",{x,y,relative})
end

function dgsImageGetUVPosition(image,relative)
	if dgsGetType(image) ~= "dgs-dximage" then error(dgsGenAsrt(image,"dgsImageGetUVPosition",1,"dgs-dximage")) end
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

function dgsImageGetNativeSize(image)
	if dgsGetType(image) ~= "dgs-dximage" then error(dgsGenAsrt(image,"dgsImageGetNativeSize",1,"dgs-dximage")) end
	if isElement(dgsElementData[image].image) then
		return dxGetMaterialSize(image)
	end
	return false
end

----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dximage"] = function(source,x,y,w,h,mx,my,cx,cy,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt)
	local colors,imgs = eleData.color,eleData.image
	colors = applyColorAlpha(colors,parentAlpha)
	if isElement(imgs) then
		local rotOffx,rotOffy = eleData.rotationCenter[1],eleData.rotationCenter[2]
		local rot = eleData.rotation or 0
		local shadow = eleData.shadow
		local shadowoffx,shadowoffy,shadowc,shadowIsOutline
		if shadow then
			shadowoffx,shadowoffy,shadowc,shadowIsOutline = shadow[1],shadow[2],shadow[3],shadow[4]
		end
		local materialInfo = eleData.materialInfo
		local uvPx,uvPy,uvSx,uvSy
		if materialInfo[0] ~= imgs then	--is latest?
			materialInfo[0] = imgs	--Update if not
			materialInfo[1],materialInfo[2] = dxGetMaterialSize(imgs)
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
				dxDrawImageSection(x+shadowoffx,y+shadowoffy,w,h,uvPx,uvPy,uvSx,uvSy,imgs,rot,rotOffx,rotOffy,shadowc,isPostGUI,rndtgt)
				if shadowIsOutline then
					dxDrawImageSection(x-shadowoffx,y+shadowoffy,w,h,uvPx,uvPy,uvSx,uvSy,imgs,rot,rotOffx,rotOffy,shadowc,isPostGUI,rndtgt)
					dxDrawImageSection(x-shadowoffx,y-shadowoffy,w,h,uvPx,uvPy,uvSx,uvSy,imgs,rot,rotOffx,rotOffy,shadowc,isPostGUI,rndtgt)
					dxDrawImageSection(x+shadowoffx,y-shadowoffy,w,h,uvPx,uvPy,uvSx,uvSy,imgs,rot,rotOffx,rotOffy,shadowc,isPostGUI,rndtgt)
				end
			end
			dxDrawImageSection(x,y,w,h,uvPx,uvPy,uvSx,uvSy,imgs,rot,rotOffy,rotOffy,colors,isPostGUI,rndtgt)
		else
			if shadowoffx and shadowoffy and shadowc then
				local shadowc = applyColorAlpha(shadowc,parentAlpha)
				dxDrawImage(x+shadowoffx,y+shadowoffy,w,h,imgs,rot,rotOffx,rotOffy,shadowc,isPostGUI,rndtgt)
				if shadowIsOutline then
					dxDrawImage(x-shadowoffx,y+shadowoffy,w,h,imgs,rot,rotOffx,rotOffy,shadowc,isPostGUI,rndtgt)
					dxDrawImage(x-shadowoffx,y-shadowoffy,w,h,imgs,rot,rotOffx,rotOffy,shadowc,isPostGUI,rndtgt)
					dxDrawImage(x+shadowoffx,y-shadowoffy,w,h,imgs,rot,rotOffx,rotOffy,shadowc,isPostGUI,rndtgt)
				end
			end
			dxDrawImage(x,y,w,h,imgs,rot,rotOffx,rotOffy,colors,isPostGUI,rndtgt)
		end
	else
		dxDrawRectangle(x,y,w,h,colors,isPostGUI)
	end
	return rndtgt,false,mx,my,0,0
end