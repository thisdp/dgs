function dgsCreateLabel(x,y,sx,sy,text,relative,parent,textColor,scalex,scaley,shadowoffsetx,shadowoffsety,shadowcolor,right,bottom)
	assert(tonumber(x),"Bad argument @dgsCreateLabel at argument 1, expect number got "..type(x))
	assert(tonumber(y),"Bad argument @dgsCreateLabel at argument 2, expect number got "..type(y))
	assert(tonumber(sx),"Bad argument @dgsCreateLabel at argument 3, expect number got "..type(sx))
	assert(tonumber(sy),"Bad argument @dgsCreateLabel at argument 4, expect number got "..type(sy))
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"Bad argument @dgsCreateLabel at argument 7, expect dgs-dxgui got "..dgsGetType(parent))
	end
	local label = createElement("dgs-dxlabel")
	local _ = dgsIsDxElement(parent) and dgsSetParent(label,parent,true,true) or table.insert(CenterFatherTable,1,label)
	dgsSetType(label,"dgs-dxlabel")
	dgsSetData(label,"renderBuffer",{})
	dgsSetData(label,"textColor",textColor or styleSettings.label.textColor)
	dgsAttachToTranslation(label,resourceTranslation[sourceResource or getThisResource()])
	if type(text) == "table" then
		dgsElementData[label]._translationText = text
		text = dgsTranslate(label,text,sourceResource)
	end
	dgsSetData(label,"text",tostring(text))
	local textSizeX,textSizeY = tonumber(scalex) or styleSettings.label.textSize[1], tonumber(scaley) or styleSettings.label.textSize[2]
	dgsSetData(label,"textSize",{textSizeX,textSizeY})
	dgsSetData(label,"clip",false)
	dgsSetData(label,"wordbreak",false)
	dgsSetData(label,"colorcoded",false)
	dgsSetData(label,"shadow",{shadowoffsetx,shadowoffsety,shadowcolor})
	dgsSetData(label,"rightbottom",{right or "left",bottom or "top"})
	dgsSetData(label,"font",systemFont)
	insertResourceDxGUI(sourceResource,label)
	calculateGuiPositionSize(label,x,y,relative or false,sx,sy,relative or false,true)
	triggerEvent("onDgsCreate",label)
	return label
end

function dgsLabelSetColor(label,r,g,b,a)
	assert(dgsGetType(label) == "dgs-dxlabel","Bad argument @dgsLabelSetColor at argument 1, except a dgs-dxlabel got "..dgsGetType(label))
	if tonumber(r) and g == true then
		return dgsSetData(label,"textColor",r)
	else
		local _r,_g,_b,_a = fromcolor(dgsElementData[label].textColor)
		return dgsSetData(label,"textColor",tocolor(r or _r,g or _g,b or _b,a or _a))
	end
end

function dgsLabelGetColor(label,notSplit)
	assert(dgsGetType(label) == "dgs-dxlabel","Bad argument @dgsLabelGetColor at argument 1, except a dgs-dxlabel got "..dgsGetType(label))
	return notSplit and dgsElementData[label].textColor or fromcolor(dgsElementData[label].textColor)
end

local HorizontalAlign = {
	left = true,
	center = true,
	right = true,
}

local VerticalAlign = {
	top = true,
	center = true,
	bottom = true,
}

function dgsLabelSetHorizontalAlign(label,align)
	assert(dgsGetType(label) == "dgs-dxlabel","Bad argument @dgsLabelSetHorizontalAlign at argument 1, except a dgs-dxlabel got "..dgsGetType(label))
	assert(HorizontalAlign[align],"Bad argument @dgsLabelSetHorizontalAlign at argument 2, except a string [left/center/right], got"..tostring(align))
	local rightbottom = dgsElementData[label].rightbottom
	return dgsSetData(label,"rightbottom",{align,rightbottom[2]})
end

function dgsLabelSetVerticalAlign(label,align)
	assert(dgsGetType(label) == "dgs-dxlabel","Bad argument @dgsLabelSetVerticalAlign at argument 1, except a dgs-dxlabel got "..dgsGetType(label))
	assert(VerticalAlign[align],"Bad argument @dgsLabelSetVerticalAlign at argument 2, except a string [top/center/bottom], got"..tostring(align))
	local rightbottom = dgsElementData[label].rightbottom
	return dgsSetData(label,"rightbottom",{rightbottom[1],align})
end

function dgsLabelGetHorizontalAlign(label)
	assert(dgsGetType(label) == "dgs-dxlabel","Bad argument @dgsLabelGetHorizontalAlign at argument 1, except a dgs-dxlabel got "..dgsGetType(label))
	local rightbottom = dgsElementData[label].rightbottom
	return rightbottom[1]
end

function dgsLabelGetVerticalAlign(label)
	assert(dgsGetType(label) == "dgs-dxlabel","Bad argument @dgsLabelGetVerticalAlign at argument 1, except a dgs-dxlabel got "..dgsGetType(label))
	local rightbottom = dgsElementData[label].rightbottom
	return rightbottom[2]
end

function dgsLabelGetTextExtent ( label )
	assert(dgsGetType(label) == "dgs-dxlabel","Bad argument @dgsLabelGetTextExtent at argument 1, except a dgs-dxlabel got "..dgsGetType(label))
	local font = dgsElementData[label].font or systemFont
	local textSizeX = dgsElementData[label].textSize[1]
	local text = dgsElementData[label].text
	local colorcoded = dgsElementData[label].colorcoded
	return dxGetTextWidth(text,textSizeX,font.colorcoded)
end
