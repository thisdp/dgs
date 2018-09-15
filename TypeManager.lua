dgsElementType = {}
dgsType = {
	"dgs-dx3dinterface",
	"dgs-dx3dtext",
	"dgs-dxarrowlist",
	"dgs-dxbutton",
	"dgs-dxcmd",
	"dgs-dxedit",
	"dgs-dxmemo",
	"dgs-dxeda",
	"dgs-dxdetectarea",
	"dgs-dxgridlist",
	"dgs-dximage",
	"dgs-dxradiobutton",
	"dgs-dxcheckbox",
	"dgs-dxlabel",
	"dgs-dxscrollbar",
	"dgs-dxscrollpane",
	"dgs-dxswitchbutton",
	"dgs-dxwindow",
	"dgs-dxprogressbar",
	"dgs-dxtabpanel",
	"dgs-dxtab",
	"dgs-dxcombobox",
	"dgs-dxcombobox-Box",
	"dgs-dxbrowser",
}

function dgsGetType(dgsGUI)
	if isElement(dgsGUI) then
		return tostring(dgsElementType[dgsGUI] or getElementType(dgsGUI))
	else
		return type(dgsGUI)
	end
end

function dgsSetType(dgsGUI,myType)
	if isElement(dgsGUI) and type(myType) == "string" then
		dgsElementType[dgsGUI] = myType
		return true
	end
	return false
end

function dgsIsDxElement(element)
	return (dgsElementType[element] or ""):sub(1,6) == "dgs-dx"
end