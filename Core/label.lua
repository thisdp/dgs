function dgsDxCreateLabel(x,y,sx,sy,text,relative,parent,textcolor,scalex,scaley,shadowoffsetx,shadowoffsety,shadowcolor,right,bottom)
	assert(tonumber(x),"@dgsDxCreateLabel argument 1,expect number got "..type(x))
	assert(tonumber(y),"@dgsDxCreateLabel argument 2,expect number got "..type(y))
	assert(tonumber(sx),"@dgsDxCreateLabel argument 3,expect number got "..type(sx))
	assert(tonumber(sy),"@dgsDxCreateLabel argument 4,expect number got "..type(sy))
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"@dgsDxCreateLabel argument 7,expect dgs-dxgui got "..dgsGetType(parent))
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
	triggerEvent("onClientDgsDxGUIPreCreate",label)
	calculateGuiPositionSize(label,x,y,relative or false,sx,sy,relative or false,true)
	triggerEvent("onClientDgsDxGUICreate",label)
	return label
end

function dgsDxLabelSetColor(label,r,g,b,a)
	assert(dgsGetType(label) == "dgs-dxlabel","@dgsDxLabelSetColor at argument 1, except a dgs-dxlabel got "..(dgsGetType(label) or type(label)))
	if tonumber(r) and g == true then
		return dgsSetData(label,"textcolor",r)
	else
		local _r,_g,_b,_a = fromcolor(dgsElementData[label].textcolor)
		return dgsSetData(label,"textcolor",tocolor(r or _r,g or _g,b or _b,a or _a))
	end
end

function dgsDxLabelGetColor(label,notSplit)
	assert(dgsGetType(label) == "dgs-dxlabel","@dgsDxLabelGetColor at argument 1, except a dgs-dxlabel got "..(dgsGetType(label) or type(label)))
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

function dgsDxLabelSetHorizontalAlign(label,align)
	assert(dgsGetType(label) == "dgs-dxlabel","@dgsDxLabelSetHorizontalAlign at argument 1, except a dgs-dxlabel got "..(dgsGetType(label) or type(label)))
	assert(HorizontalAlign[align],"@dgsDxLabelSetHorizontalAlign at argument 2, except a string [left/center/right], got"..tostring(align))
	local rightbottom = dgsElementData[label].rightbottom
	return dgsSetData(label,"rightbottom",{align,rightbottom[2]})
end

function dgsDxLabelSetVerticalAlign(label,align)
	assert(dgsGetType(label) == "dgs-dxlabel","@dgsDxLabelSetVerticalAlign at argument 1, except a dgs-dxlabel got "..(dgsGetType(label) or type(label)))
	assert(VerticalAlign[align],"@dgsDxLabelSetVerticalAlign at argument 2, except a string [top/center/bottom], got"..tostring(align))
	local rightbottom = dgsElementData[label].rightbottom
	return dgsSetData(label,"rightbottom",{rightbottom[1],align})
end

function dgsDxLabelGetHorizontalAlign(label)
	assert(dgsGetType(label) == "dgs-dxlabel","@dgsDxLabelGetHorizontalAlign at argument 1, except a dgs-dxlabel got "..(dgsGetType(label) or type(label)))
	local rightbottom = dgsElementData[label].rightbottom
	return rightbottom[1]
end

function dgsDxLabelGetVerticalAlign(label)
	assert(dgsGetType(label) == "dgs-dxlabel","@dgsDxLabelGetVerticalAlign at argument 1, except a dgs-dxlabel got "..(dgsGetType(label) or type(label)))
	local rightbottom = dgsElementData[label].rightbottom
	return rightbottom[2]
end