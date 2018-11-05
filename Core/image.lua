function dgsCreateImage(x,y,sx,sy,img,relative,parent,color)
	assert(tonumber(x),"Bad argument @dgsCreateImage at argument 1, expect number got "..type(x))
	assert(tonumber(y),"Bad argument @dgsCreateImage at argument 2, expect number got "..type(y))
	assert(tonumber(sx),"Bad argument @dgsCreateImage at argument 3, expect number got "..type(sx))
	assert(tonumber(sy),"Bad argument @dgsCreateImage at argument 4, expect number got "..type(sy))
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"Bad argument @dgsCreateImage at argument 7, expect dgs-dxgui got "..dgsGetType(parent))
	end
	local image = createElement("dgs-dximage")
	dgsSetData(image,"renderBuffer",{})
	dgsElementData[image].renderBuffer.UVSize = {}
	dgsElementData[image].renderBuffer.UVPos = {}
	dgsSetType(image,"dgs-dximage")
	local texture = img
	if type(img) == "string" then
		texture = dxCreateTexture(img)
		if not isElement(texture) then return false end
	end
	dgsSetData(image,"image",texture)
	dgsSetData(image,"color",color or tocolor(255,255,255,255))
	dgsSetData(image,"rotationCenter",{0,0}) --0~1
	dgsSetData(image,"rotation",0) --0~360
	local _x = dgsIsDxElement(parent) and dgsSetParent(image,parent,true,true) or table.insert(CenterFatherTable,1,image)
	insertResourceDxGUI(sourceResource,image)
	calculateGuiPositionSize(image,x,y,relative or false,sx,sy,relative or false,true)
	triggerEvent("onDgsCreate",image)
	return image
end

function dgsImageGetImage(gui)
	assert(dgsGetType(gui) == "dgs-dximage","Bad argument @dgsImageGetImage at argument 1, expect dgs-dximage got "..dgsGetType(gui))
	return dgsElementData[gui].image
end

function dgsImageSetImage(gui,img)
	assert(dgsGetType(gui) == "dgs-dximage","Bad argument @dgsImageSetImage at argument 1, expect dgs-dximage got "..dgsGetType(gui))
	return dgsSetData(gui,"image",img)
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