function dgsDxCreateImage(x,y,sx,sy,img,relative,parent,color)
	assert(tonumber(x),"Bad argument @dgsDxCreateImage at argument 1, expect number got "..type(x))
	assert(tonumber(y),"Bad argument @dgsDxCreateImage at argument 2, expect number got "..type(y))
	assert(tonumber(sx),"Bad argument @dgsDxCreateImage at argument 3, expect number got "..type(sx))
	assert(tonumber(sy),"Bad argument @dgsDxCreateImage at argument 4, expect number got "..type(sy))
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"Bad argument @dgsDxCreateImage at argument 7, expect dgs-dxgui got "..dgsGetType(parent))
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
		table.insert(MaxFatherTable,image)
	end
	insertResourceDxGUI(sourceResource,image)
	triggerEvent("onClientDgsDxGUIPreCreate",image)
	calculateGuiPositionSize(image,x,y,relative or false,sx,sy,relative or false,true)
	local mx,my = false,false
	if isElement(texture) and not getElementType(texture) == "shader" then
		mx,my = dxGetMaterialSize(texture)
	end
	dgsSetData(image,"imagesize",{mx,my})
	dgsSetData(image,"imagepos",{0,0})
	triggerEvent("onClientDgsDxGUICreate",image)
	return image
end

function dgsDxImageGetImage(gui)
	assert(dgsGetType(gui) == "dgs-dximage","Bad argument @dgsDxImageGetImage at argument 1, expect dgs-dximage got "..(dgsGetType(gui) or type(gui)))
	return dgsElementData[gui].image
end

function dgsDxImageSetImage(gui,img)
	assert(dgsGetType(gui) == "dgs-dximage","Bad argument @dgsDxImageSetImage at argument 1, expect dgs-dximage got "..(dgsGetType(gui) or type(gui)))
	return dgsSetData(gui,"image",img)
end

function dgsDxImageSetImageSize(gui,sx,sy)
	assert(dgsGetType(gui) == "dgs-dximage","Bad argument @dgsDxImageSetImageSize at argument 1, expect dgs-dximage got "..(dgsGetType(gui) or type(gui)))
	local texture = dgsSetData(gui,"image")
	local mx,my = dxGetMaterialSize(texture)
	sx = tonumber(sx) or mx
	sy = tonumber(sy) or my
	return dgsSetData(gui,"imagesize",{sx,sy})
end

function dgsDxImageGetImageSize(gui)
	assert(dgsGetType(gui) == "dgs-dximage","Bad argument @dgsDxImageGetImageSize at argument 1, expect dgs-dximage got "..(dgsGetType(gui) or type(gui)))
	return dgsElementData[gui].imagesize[1],dgsElementData[gui].imagesize[2]
end

function dgsDxImageSetImagePosition(gui,x,y)
	assert(dgsGetType(gui) == "dgs-dximage","Bad argument @dgsDxImageSetImagePosition at argument 1, expect dgs-dximage got "..(dgsGetType(gui) or type(gui)))
	x = tonumber(x) or 0
	y = tonumber(y) or 0
	return dgsSetData(gui,"imagepos",{x,y})
end

function dgsDxImageGetImagePosition(gui,x,y)
	assert(dgsGetType(gui) == "dgs-dximage","Bad argument @dgsDxImageGetImagePosition at argument 1, expect dgs-dximage got "..(dgsGetType(gui) or type(gui)))
	return dgsElementData[gui].imagepos[1],dgsElementData[gui].imagepos[2]
end