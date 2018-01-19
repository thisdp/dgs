function dgsCreateLabel(x,y,sx,sy,text,relative,parent,textcolor,scalex,scaley,shadowoffsetx,shadowoffsety,shadowcolor,right,bottom)
	assert(tonumber(x),"Bad argument @dgsCreateLabel at argument 1, expect number got "..type(x))
	assert(tonumber(y),"Bad argument @dgsCreateLabel at argument 2, expect number got "..type(y))
	assert(tonumber(sx),"Bad argument @dgsCreateLabel at argument 3, expect number got "..type(sx))
	assert(tonumber(sy),"Bad argument @dgsCreateLabel at argument 4, expect number got "..type(sy))
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"Bad argument @dgsCreateLabel at argument 7, expect dgs-dxgui got "..dgsGetType(parent))
	end
	local label = createElement("dgs-dxlabel")
	local _ = dgsIsDxElement(parent) and dgsSetParent(label,parent,true) or table.insert(MaxFatherTable,1,label)
	dgsSetType(label,"dgs-dxlabel")
	dgsSetData(label,"text",tostring(text))
	dgsSetData(label,"textcolor",textcolor or tocolor(255,255,255,255))
	dgsSetData(label,"textsize",{scalex or 1,scaley or 1})
	dgsSetData(label,"clip",false)
	dgsSetData(label,"wordbreak",false)
	dgsSetData(label,"colorcoded",false)
	dgsSetData(label,"shadow",{shadowoffsetx,shadowoffsety,shadowcolor})
	dgsSetData(label,"rightbottom",{right or "left",bottom or "top"})
	dgsSetData(label,"font",systemFont)
	insertResourceDxGUI(sourceResource,label)
	triggerEvent("onDgsPreCreate",label)
	calculateGuiPositionSize(label,x,y,relative or false,sx,sy,relative or false,true)
	triggerEvent("onDgsCreate",label)
	return label
end

function dgsLabelSetColor(label,r,g,b,a)
	assert(dgsGetType(label) == "dgs-dxlabel","Bad argument @dgsLabelSetColor at at argument 1, except a dgs-dxlabel got "..(dgsGetType(label) or type(label)))
	if tonumber(r) and g == true then
		return dgsSetData(label,"textcolor",r)
	else
		local _r,_g,_b,_a = fromcolor(dgsElementData[label].textcolor)
		return dgsSetData(label,"textcolor",tocolor(r or _r,g or _g,b or _b,a or _a))
	end
end

function dgsLabelGetColor(label,notSplit)
	assert(dgsGetType(label) == "dgs-dxlabel","Bad argument @dgsLabelGetColor at at argument 1, except a dgs-dxlabel got "..(dgsGetType(label) or type(label)))
	return notSplit and dgsElementData[label].textcolor or fromcolor(dgsElementData[label].textcolor)
end

local HorizontalAlign = {}
HorizontalAlign.left = true
HorizontalAlign.center = true
HorizontalAlign.right = true
local VerticalAlign = {}
VerticalAlign.top = true
VerticalAlign.center = true
VerticalAlign.bottom = true

function dgsLabelSetHorizontalAlign(label,align)
	assert(dgsGetType(label) == "dgs-dxlabel","Bad argument @dgsLabelSetHorizontalAlign at at argument 1, except a dgs-dxlabel got "..(dgsGetType(label) or type(label)))
	assert(HorizontalAlign[align],"Bad argument @dgsLabelSetHorizontalAlign at at argument 2, except a string [left/center/right], got"..tostring(align))
	local rightbottom = dgsElementData[label].rightbottom
	return dgsSetData(label,"rightbottom",{align,rightbottom[2]})
end

function dgsLabelSetVerticalAlign(label,align)
	assert(dgsGetType(label) == "dgs-dxlabel","Bad argument @dgsLabelSetVerticalAlign at at argument 1, except a dgs-dxlabel got "..(dgsGetType(label) or type(label)))
	assert(VerticalAlign[align],"Bad argument @dgsLabelSetVerticalAlign at at argument 2, except a string [top/center/bottom], got"..tostring(align))
	local rightbottom = dgsElementData[label].rightbottom
	return dgsSetData(label,"rightbottom",{rightbottom[1],align})
end

function dgsLabelGetHorizontalAlign(label)
	assert(dgsGetType(label) == "dgs-dxlabel","Bad argument @dgsLabelGetHorizontalAlign at at argument 1, except a dgs-dxlabel got "..(dgsGetType(label) or type(label)))
	local rightbottom = dgsElementData[label].rightbottom
	return rightbottom[1]
end

function dgsLabelGetVerticalAlign(label)
	assert(dgsGetType(label) == "dgs-dxlabel","Bad argument @dgsLabelGetVerticalAlign at at argument 1, except a dgs-dxlabel got "..(dgsGetType(label) or type(label)))
	local rightbottom = dgsElementData[label].rightbottom
	return rightbottom[2]
end