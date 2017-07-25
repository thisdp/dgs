function dgsDxCreateWindow(x,y,sx,sy,title,relative,titnamecolor,titsize,titimg,titcolor,bgimg,bgcolor,sidesize,nooffbutton)
	assert(tonumber(x),"@dgsDxCreateWindow argument 1,expect number got "..type(x))
	assert(tonumber(y),"@dgsDxCreateWindow argument 2,expect number got "..type(y))
	assert(tonumber(sx),"@dgsDxCreateWindow argument 3,expect number got "..type(sx))
	assert(tonumber(sy),"@dgsDxCreateWindow argument 4,expect number got "..type(sy))
	local window = createElement("dgs-dxwindow")
	dgsSetType(window,"dgs-dxwindow")
	table.insert(MaxFatherTable,window)
	dgsSetData(window,"titimage",titimg)
	dgsSetData(window,"titnamecolor",tonumber(titnamecolor) or tocolor(255,255,255,255))
	dgsSetData(window,"titcolor",tonumber(titcolor) or tocolor(20,20,20,200))
	dgsSetData(window,"image",bgimg)
	dgsSetData(window,"color",tonumber(bgcolor) or tocolor(20,20,20,150))
	dgsSetData(window,"text",tostring(title) or "")
	dgsSetData(window,"titlesize",tonumber(titsize) or 25)
	dgsSetData(window,"sidesize",tonumber(sidesize) or 5)
	dgsSetData(window,"sizable",true)
	dgsSetData(window,"movable",true)
	dgsSetData(window,"movetyp",false) --false only title;true are all
	dgsSetData(window,"font",msyh)
	dgsSetData(window,"minSize",{60,60})
	dgsSetData(window,"maxSize",{20000,20000})
	insertResourceDxGUI(sourceResource,window)
	triggerEvent("onClientDgsDxGuiPreCreate",window)
	calculateGuiPositionSize(window,x,y,relative,sx,sy,relative,true)
	triggerEvent("onClientDgsDxGuiCreate",window)
	if not nooffbutton then
		local relat = relative and sW or 1
		local buttonOff = dgsDxCreateButton(30,0,25,20,"×",false,window,_,_,_,_,_,_,tocolor(200,50,50,255),tocolor(250,20,20,255),tocolor(150,50,50,255),true)
		dgsSetData(window,"closeButton",buttonOff)
		dgsDxGUISetSide(buttonOff,"right",false)
		dgsSetData(buttonOff,"withoutTitle",false)
		dgsSetPosition(buttonOff,30,0,false)
	end
	return window
end

function dgsDxWindowSetSizable(window,bool)
	if dgsGetType(window) == "dgs-dxwindow" then
		dgsSetData(window,"sizable",(bool and true) or false)
		return true
	end
	return false
end

function dgsDxWindowSetMovable(window,bool)
	if dgsGetType(window) == "dgs-dxwindow" then
		dgsSetData(window,"movable",(bool and true) or false)
		return true
	end
	return false
end

function dgsDxGUICloseWindow(window)
    assert(dgsGetType(window) == "dgs-dxwindow","@dgsDxGUICloseWindow at argument 1,expect dgs-dxwindow got "..(dgsGetType(window) or getElementType(window) or type(window)))
    triggerEvent("onClientDgsDxWindowClose",window)
	if not wasEventCancelled() then
		return destroyElement(window)
	end
	return false
end