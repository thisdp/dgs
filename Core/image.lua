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
local tonumber = tonumber
local assert = assert
local tableInsert = table.insert

function dgsCreateImage(x,y,w,h,img,relative,parent,color)
	local __x,__y,__w,__h = tonumber(x),tonumber(y),tonumber(w),tonumber(h)
	if not __x then assert(false,"Bad argument @dgsCreateImage at argument 1, expect number got "..type(x)) end
	if not __y then assert(false,"Bad argument @dgsCreateImage at argument 2, expect number got "..type(y)) end
	if not __w then assert(false,"Bad argument @dgsCreateImage at argument 3, expect number got "..type(w)) end
	if not __h then assert(false,"Bad argument @dgsCreateImage at argument 4, expect number got "..type(h)) end
	if parent then
		if not dgsIsDxElement(parent) then assert(false,"Bad argument @dgsCreateImage at argument 7, expect dgs-dxgui got "..dgsGetType(parent)) end
	end
	local image = createElement("dgs-dximage")
	dgsSetData(image,"renderBuffer",{
		UVSize = {},
		UVPos = {},
	})
	dgsSetType(image,"dgs-dximage")
	local texture = img
	if img and type(img) == "string" then
		texture,textureExists = dgsImageCreateTextureExternal(image,sourceResource,texture)
		if not isElement(texture) then return false end
	end
	dgsSetData(image,"image",texture)
	dgsSetData(image,"color",color or 0xFFFFFFFF)
	dgsSetData(image,"rotationCenter",{0,0}) --0~1
	dgsSetData(image,"rotation",0) --0~360
	local _ = parent and dgsSetParent(image,parent,true,true) or tableInsert(CenterFatherTable,image)
	calculateGuiPositionSize(image,__x,__y,relative or false,__w,__h,relative or false,true)
	triggerEvent("onDgsCreate",image,sourceResource)
	return image
end

function dgsImageGetImage(gui)
	assert(dgsGetType(gui) == "dgs-dximage","Bad argument @dgsImageGetImage at argument 1, expect dgs-dximage got "..dgsGetType(gui))
	return dgsElementData[gui].image
end

function dgsImageSetImage(gui,img)
	assert(dgsGetType(gui) == "dgs-dximage","Bad argument @dgsImageSetImage at argument 1, expect dgs-dximage got "..dgsGetType(gui))
	local texture = dgsElementData[gui].image
	if isElement(texture) and dgsElementData[texture] then
		if dgsElementData[texture].parent == gui then
			destroyElement(texture)
		end
	end
	texture = img
	if type(texture) == "string" then
		texture,textureExists = dgsImageCreateTextureExternal(gui,sourceResource,texture)
		if not textureExists then return false end
	end
	return dgsSetData(gui,"image",texture)
end

function dgsImageCreateTextureExternal(gui,res,img)
	if res then
		img = string.gsub(img,"\\","/")
		if not string.find(img,":") then
			img = ":"..getResourceName(res).."/"..img
			img = string.gsub(img,"//","/") or img
		end
	end
	texture = dxCreateTexture(img)
	if isElement(texture) then
		dgsElementData[texture] = {parent=image}
		dgsAttachToAutoDestroy(texture,gui)
		return texture,true
	end
	return false
end

function dgsImageSetUVSize(gui,sx,sy,relative)
	assert(dgsGetType(gui) == "dgs-dximage","Bad argument @dgsImageSetUVSize at argument 1, expect dgs-dximage got "..dgsGetType(gui))
	return dgsSetData(gui,"UVSize",{sx,sy,relative})
end

function dgsImageGetUVSize(gui,relative)
	assert(dgsGetType(gui) == "dgs-dximage","Bad argument @dgsImageGetUVSize at argument 1, expect dgs-dximage got "..dgsGetType(gui))
	local texture = dgsElementData[gui].image
	if isElement(texture) and getElementType(texture) ~= "shader" then
		local UVSize = dgsElementData[gui].UVSize
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

function dgsImageSetUVPosition(gui,x,y,relative)
	assert(dgsGetType(gui) == "dgs-dximage","Bad argument @dgsImageSetUVPosition at argument 1, expect dgs-dximage got "..dgsGetType(gui))
	return dgsSetData(gui,"UVPos",{x,y,relative})
end

function dgsImageGetUVPosition(gui,relative)
	assert(dgsGetType(gui) == "dgs-dximage","Bad argument @dgsImageGetUVPosition at argument 1, expect dgs-dximage got "..dgsGetType(gui))
	local texture = dgsElementData[gui].image
	if isElement(texture) and getElementType(texture) ~= "shader" then
		local UVPos = dgsElementData[gui].UVPos
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

function dgsImageGetNativeSize(gui)
	assert(dgsGetType(gui) == "dgs-dximage","Bad argument @dgsImageGetNativeSize at argument 1, expect dgs-dximage got "..dgsGetType(gui))
	if isElement(dgsElementData[gui].image) then
		return dxGetMaterialSize(gui)
	end
	return false
end

----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dximage"] = function(source,x,y,w,h,mx,my,cx,cy,enabled,eleData,parentAlpha,isPostGUI,rndtgt)
	local colors,imgs = eleData.color,eleData.image
	colors = applyColorAlpha(colors,parentAlpha)
	if imgs then
		local uvPos,uvSize = eleData.renderBuffer.UVPos or {},eleData.renderBuffer.UVSize or {}
		local sx,sy,px,py = uvSize[1],uvSize[2],uvPos[1],uvPos[2]
		local rotOffx,rotOffy = eleData.rotationCenter[1],eleData.rotationCenter[2]
		local rot = eleData.rotation or 0
		if not sx or not sy or not px or not py then
			dxDrawImage(x,y,w,h,imgs,rot,rotOffx,rotOffy,colors,isPostGUI)
		else
			dxDrawImageSection(x,y,w,h,px,py,sx,sy,imgs,rot,rotOffy,rotOffy,colors,isPostGUI)
		end
	else
		dxDrawRectangle(x,y,w,h,colors,isPostGUI)
	end
	if enabled[1] and mx then
		if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
			MouseData.hit = source
		end
	end
	return rndtgt
end
----------------------------------------------------------------
-------------------------OOP Class------------------------------
----------------------------------------------------------------
dgsOOP["dgs-dximage"] = [[
	setImage = dgsOOP.genOOPFnc("dgsImageSetImage",true),
	getImage = dgsOOP.genOOPFnc("dgsImageGetImage"),
	setUVSize = dgsOOP.genOOPFnc("dgsImageSetUVSize",true),
	getUVSize = dgsOOP.genOOPFnc("dgsImageGetUVSize"),
	setUVPosition = dgsOOP.genOOPFnc("dgsImageSetUVPosition",true),
	getUVPosition = dgsOOP.genOOPFnc("dgsImageGetUVPosition"),
]]