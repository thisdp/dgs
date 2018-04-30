function dgsCreateImage(x,y,sx,sy,img,relative,parent,color)
	assert(tonumber(x),"Bad argument @dgsCreateImage at argument 1, expect number got "..type(x))
	assert(tonumber(y),"Bad argument @dgsCreateImage at argument 2, expect number got "..type(y))
	assert(tonumber(sx),"Bad argument @dgsCreateImage at argument 3, expect number got "..type(sx))
	assert(tonumber(sy),"Bad argument @dgsCreateImage at argument 4, expect number got "..type(sy))
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"Bad argument @dgsCreateImage at argument 7, expect dgs-dxgui got "..dgsGetType(parent))
	end
	local image = createElement("dgs-dximage")
	dgsSetType(image,"dgs-dximage")
	local texture = img
	if type(img) == "string" then
		texture = dxCreateTexture(img)
		if not isElement(texture) then return false end
	end
	dgsSetData(image,"image",texture)
	dgsSetData(image,"color",color or tocolor(255,255,255,255))
	dgsSetData(image,"sideColor",tocolor(255,255,255,255))
	dgsSetData(image,"sideState","in") --in/out/center
	dgsSetData(image,"sideSize",0)
	dgsSetData(image,"rotationCenter",{0,0}) --0~1
	dgsSetData(image,"rotation",0) --0~360
	if isElement(parent) then
		dgsSetParent(image,parent)
	else
		table.insert(CenterFatherTable,image)
	end
	insertResourceDxGUI(sourceResource,image)
	triggerEvent("onDgsPreCreate",image)
	calculateGuiPositionSize(image,x,y,relative or false,sx,sy,relative or false,true)
	local mx,my = false,false
	if isElement(texture) and not getElementType(texture) == "shader" then
		mx,my = dxGetMaterialSize(texture)
	end
	dgsSetData(image,"imagesize",{mx,my})
	dgsSetData(image,"imagepos",{0,0})
	triggerEvent("onDgsCreate",image)
	return image
end

function dgsImageGetImage(gui)
	assert(dgsGetType(gui) == "dgs-dximage","Bad argument @dgsImageGetImage at argument 1, expect dgs-dximage got "..(dgsGetType(gui) or type(gui)))
	return dgsElementData[gui].image
end

function dgsImageSetImage(gui,img)
	assert(dgsGetType(gui) == "dgs-dximage","Bad argument @dgsImageSetImage at argument 1, expect dgs-dximage got "..(dgsGetType(gui) or type(gui)))
	return dgsSetData(gui,"image",img)
end

function dgsImageSetImageSize(gui,sx,sy)
	assert(dgsGetType(gui) == "dgs-dximage","Bad argument @dgsImageSetImageSize at argument 1, expect dgs-dximage got "..(dgsGetType(gui) or type(gui)))
	local texture = dgsGetData(gui,"image")
	local mx,my = dxGetMaterialSize(texture)
	sx = tonumber(sx) or mx
	sy = tonumber(sy) or my
	return dgsSetData(gui,"imagesize",{sx,sy})
end

function dgsImageGetImageSize(gui)
	assert(dgsGetType(gui) == "dgs-dximage","Bad argument @dgsImageGetImageSize at argument 1, expect dgs-dximage got "..(dgsGetType(gui) or type(gui)))
	return dgsElementData[gui].imagesize[1],dgsElementData[gui].imagesize[2]
end

function dgsImageSetImagePosition(gui,x,y)
	assert(dgsGetType(gui) == "dgs-dximage","Bad argument @dgsImageSetImagePosition at argument 1, expect dgs-dximage got "..(dgsGetType(gui) or type(gui)))
	x = tonumber(x) or 0
	y = tonumber(y) or 0
	return dgsSetData(gui,"imagepos",{x,y})
end

function dgsImageGetImagePosition(gui,x,y)
	assert(dgsGetType(gui) == "dgs-dximage","Bad argument @dgsImageGetImagePosition at argument 1, expect dgs-dximage got "..(dgsGetType(gui) or type(gui)))
	return dgsElementData[gui].imagepos[1],dgsElementData[gui].imagepos[2]
end