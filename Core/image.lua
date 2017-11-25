function dgsDxCreateImage(x,y,sx,sy,img,relative,parent,color)
	assert(tonumber(x),"@dgsDxCreateImage argument 1,expect number got "..type(x))
	assert(tonumber(y),"@dgsDxCreateImage argument 2,expect number got "..type(y))
	assert(tonumber(sx),"@dgsDxCreateImage argument 3,expect number got "..type(sx))
	assert(tonumber(sy),"@dgsDxCreateImage argument 4,expect number got "..type(sy))
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"@dgsDxCreateImage argument 7,expect dgs-dxgui got "..dgsGetType(parent))
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
	assert(dgsGetType(gui) == "dgs-dximage","@dgsDxImageGetImage argument 1,expect dgs-dximage got "..(dgsGetType(gui) or type(gui)))
	return dgsElementData[gui].image
end

function dgsDxImageSetImage(gui,img)
	assert(dgsGetType(gui) == "dgs-dximage","@dgsDxImageSetImage argument 1,expect dgs-dximage got "..(dgsGetType(gui) or type(gui)))
	return dgsSetData(gui,"image",img)
end

function dgsDxImageSetImageSize(gui,sx,sy)
	assert(dgsGetType(gui) == "dgs-dximage","@dgsDxImageSetImageSize argument 1,expect dgs-dximage got "..(dgsGetType(gui) or type(gui)))
	local texture = dgsSetData(gui,"image")
	local mx,my = dxGetMaterialSize(texture)
	sx = tonumber(sx) or mx
	sy = tonumber(sy) or my
	return dgsSetData(gui,"imagesize",{sx,sy})
end

function dgsDxImageGetImageSize(gui)
	assert(dgsGetType(gui) == "dgs-dximage","@dgsDxImageGetImageSize argument 1,expect dgs-dximage got "..(dgsGetType(gui) or type(gui)))
	return dgsElementData[gui].imagesize[1],dgsElementData[gui].imagesize[2]
end

function dgsDxImageSetImagePosition(gui,x,y)
	assert(dgsGetType(gui) == "dgs-dximage","@dgsDxImageSetImagePosition argument 1,expect dgs-dximage got "..(dgsGetType(gui) or type(gui)))
	x = tonumber(x) or 0
	y = tonumber(y) or 0
	return dgsSetData(gui,"imagepos",{x,y})
end

function dgsDxImageGetImagePosition(gui,x,y)
	assert(dgsGetType(gui) == "dgs-dximage","@dgsDxImageGetImagePosition argument 1,expect dgs-dximage got "..(dgsGetType(gui) or type(gui)))
	return dgsElementData[gui].imagepos[1],dgsElementData[gui].imagepos[2]
end