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

function dgsGetType(dgsGUI)
	if isElement(dgsGUI) then
		return tostring(dgsElementType[dgsGUI] or getElementType(dgsGUI))
	else
		local theType = type(dgsGUI)
		if theType == "userdata" then
			if dgsElementType[dgsGUI] then
				return "garbage (destroyed)"
			end
		end
		return theType
	end
end

function dgsGetPluginType(dgsGUI)
	return dgsGUI and (dgsElementData[dgsGUI] and dgsElementData[dgsGUI].asPlugin or false) or dgsGetType(dgsGUI)
end

function dgsSetType(dgsGUI,myType)
	if isElement(dgsGUI) and type(myType) == "string" then
		dgsElementType[dgsGUI] = myType
		return true
	end
	return false
end

function dgsIsDxElement(element)
	return isElement(element) and ((dgsElementType[element] or (dgsElementData[element] and dgsElementData[element].asPlugin) or ""):sub(1,6) == "dgs-dx")
end

function dgsIsMaterialElement(ele)
	if isElement(ele) then
		local eleType = getElementType(ele)
		return eleType == "shader" or eleType == "texture"
	end
	return type(ele)
end