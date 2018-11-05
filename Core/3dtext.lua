function dgsCreate3DText(x,y,z,text,color,font,sizeX,sizeY,maxDistance,colorcode)
	assert(tonumber(x),"Bad argument @dgsCreate3DText at argument 1, expect a number got "..type(x))
	assert(tonumber(y),"Bad argument @dgsCreate3DText at argument 2, expect a number got "..type(y))
	assert(tonumber(y),"Bad argument @dgsCreate3DText at argument 3, expect a number got "..type(z))
	local text3d = createElement("dgs-dx3dtext")
	table.insert(dx3DTextTable,text3d)
	dgsSetType(text3d,"dgs-dx3dtext")
	dgsSetData(text3d,"renderBuffer",{})
	dgsSetData(text3d,"position",{x,y,z})
	dgsSetData(text3d,"textSize",{sizeX or 1,sizeY or 1})
	dgsSetData(text3d,"font",font or systemFont)
	dgsSetData(text3d,"color",color or tocolor(255,255,255,255))
	dgsSetData(text3d,"maxDistance",distance or 80)
	dgsSetData(text3d,"fadeDistance",distance or 80)
	dgsSetData(text3d,"dimension",-1)
	dgsSetData(text3d,"interior",-1)
	dgsAttachToTranslation(text3d,resourceTranslation[sourceResource or getThisResource()])
	if type(text) == "table" then
		dgsElementData[text3d]._translationText = text
		text = dgsTranslate(text3d,text,sourceResource)
	end
	dgsSetData(text3d,"text",tostring(text))
	dgsSetData(text3d,"colorcode",colorcode or false)
	insertResourceDxGUI(sourceResource,text3d)
	triggerEvent("onDgsCreate",text3d)
	return text3d
end

function dgs3DTextGetDimension(text3d)
	assert(dgsGetType(text3d) == "dgs-dx3dtext","Bad argument @dgs3DTextGetDimension at argument 1, expect a dgs-dx3dtext got "..dgsGetType(text3d))
	return dgsElementData[text3d].dimension or -1
end

function dgs3DTextSetDimension(text3d,dimension)
	assert(dgsGetType(text3d) == "dgs-dx3dtext","Bad argument @dgs3DTextSetDimension at argument 1, expect a dgs-dx3dtext got "..dgsGetType(text3d))
	assert(tonumber(dimension),"Bad argument @dgs3DTextSetDimension at argument 2, expect a number got "..type(dimension))
	assert(dimension >= -1 and dimension <= 65535,"Bad argument @dgs3DTextSetDimension at argument 2, out of range [0~65535] got "..dimension)
	return dimension-dimension%1
end

function dgs3DTextGetInterior(text)
	assert(dgsGetType(text) == "dgs-dx3dtext","Bad argument @dgs3DTextGetInterior at argument 1, expect a dgs-dx3dtext got "..dgsGetType(text))
	return dgsElementData[text].interior or -1
end

function dgs3DTextSetInterior(text,interior)
	assert(dgsGetType(text) == "dgs-dx3dtext","Bad argument @dgs3DTextSetInterior at argument 1, expect a dgs-dx3dtext got "..dgsGetType(text))
	assert(tonumber(interior),"Bad argument @dgs3DTextSetInterior at argument 2, expect a number got "..type(interior))
	assert(interior >= -1,"Bad argument @dgs3DTextSetInterior at argument 2, out of range [ -1 ~ +∞ ] got "..interior)
	return interior-interior%1
end

function dgs3DTextAttachToElement(text,element,offX,offY,offZ)
	assert(dgsGetType(text) == "dgs-dx3dtext","Bad argument @dgs3DTextAttachToElement at argument 1, expect a dgs-dx3dtext got "..dgsGetType(text))
	assert(isElement(element),"Bad argument @dgs3DTextAttachToElement at argument 2, expect an element got "..dgsGetType(element))
	local offX,offY,offZ = offX or 0,offY or 0,offZ or 0
	return dgsSetData(text,"attachTo",{element,offX,offY,offZ})
end

function dgs3DTextIsAttached(text)
	assert(dgsGetType(text) == "dgs-dx3dtext","Bad argument @dgs3DTextIsAttached at argument 1, expect a dgs-dx3dtext got "..dgsGetType(text))
	return dgsElementData[text].attachTo
end

function dgs3DTextDetachFromElement(text)
	assert(dgsGetType(text) == "dgs-dx3dtext","Bad argument @dgs3DTextDetachFromElement at argument 1, expect a dgs-dx3dtext got "..dgsGetType(text))
	return dgsSetData(text,"attachTo",false)
end

function dgs3DTextSetAttachedOffsets(text,offX,offY,offZ)
	assert(dgsGetType(text) == "dgs-dx3dtext","Bad argument @dgs3DTextSetAttachedOffsets at argument 1, expect a dgs-dx3dtext got "..dgsGetType(text))
	local attachTable = dgsElementData[text].attachTo
	if attachTable then
		local offX,offY,offZ = offX or attachTable[2],offY or attachTable[3],offZ or attachTable[4]
		return dgsSetData(text,"attachTo",{attachTable[1],offX,offY,offZ})
	end
	return false
end

function dgs3DTextGetAttachedOffsets(text,offX,offY,offZ)
	assert(dgsGetType(text) == "dgs-dx3dtext","Bad argument @dgs3DTextGetAttachedOffsets at argument 1, expect a dgs-dx3dtext got "..dgsGetType(text))
	local attachTable = dgsElementData[text].attachTo
	if attachTable then
		local offX,offY,offZ = attachTable[2],attachTable[3],attachTable[4]
		return offX,offY,offZ
	end
	return false
end
