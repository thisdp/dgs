dgsElementType = {}
dgsType = {
	"dgs-dx3dinterface",
	"dgs-dx3dtext",
	"dgs-dxbutton",
	"dgs-dxedit",
	"dgs-dxexternal",
	"dgs-dxmemo",
	"dgs-dxdetectarea",
	"dgs-dxgridlist",
	"dgs-dximage",
	"dgs-dxradiobutton",
	"dgs-dxcheckbox",
	"dgs-dxlabel",
	"dgs-dxscrollbar",
	"dgs-dxscrollpane",
	"dgs-dxselector",
	"dgs-dxswitchbutton",
	"dgs-dxwindow",
	"dgs-dxprogressbar",
	"dgs-dxtabpanel",
	"dgs-dxtab",
	"dgs-dxcombobox",
	"dgs-dxcombobox-Box",
	"dgs-dxcustomrenderer",
	"dgs-dxbrowser",
}

function dgsGetType(dgsEle)
	if isElement(dgsEle) then return tostring(dgsElementType[dgsEle] or getElementType(dgsEle)) end
	local theType = type(dgsEle)
	if theType == "userdata" and dgsElementType[dgsEle] then return "garbage (destroyed)" end
	return theType
end

function dgsIsDxElement(dgsEle) return isElement(dgsEle) and ((dgsElementType[dgsEle] or (dgsElementData[dgsEle] and dgsElementData[dgsEle].asPlugin) or ""):sub(1,6) == "dgs-dx") end
function dgsGetPluginType(dgsEle) return dgsEle and (dgsElementData[dgsEle] and dgsElementData[dgsEle].asPlugin or false) or dgsGetType(dgsEle) end

function dgsSetType(dgsEle,myType)
	if isElement(dgsEle) and type(myType) == "string" then
		dgsElementType[dgsEle] = myType
		return true
	end
	return false
end

function dgsIsMaterialElement(ele)
	if isElement(ele) then
		local eleType = getElementType(ele)
		return eleType == "shader" or eleType == "texture"
	end
	return false
end