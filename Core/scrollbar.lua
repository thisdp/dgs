scrollBarSettings = {}
scrollBarSettings.arrow = "image/scrollbar/scrollbar_arrow.png"

function dgsDxCreateScrollBar(x,y,sx,sy,voh,relative,parent,img1,imgmid,imgcursor,colorn1,colornmid,colorncursor,colore1,colorecursor,colorc1,colorccursor)
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"@dgsDxCreateScrollBar argument 7,expect dgs-dxgui got "..dgsGetType(parent))
	end
	local scrollbar = createElement("dgs-dxscrollbar")
	dgsSetType(scrollbar,"dgs-dxscrollbar")
	dgsSetData(scrollbar,"imgs",{img1 or scrollBarSettings.arrow,imgcursor,imgmid})
	dgsSetData(scrollbar,"colorn",{colorn1 or schemeColor.scrollbar.colorn[1],colorncursor or schemeColor.scrollbar.colorn[2],colornmid or schemeColor.scrollbar.colorn[3]})
	dgsSetData(scrollbar,"colore",{colore1 or schemeColor.scrollbar.colore[1],colorecursor or schemeColor.scrollbar.colore[2]})
	dgsSetData(scrollbar,"colorc",{colorc1 or schemeColor.scrollbar.colorc[1],colorccursor or schemeColor.scrollbar.colorc[2]})
	dgsSetData(scrollbar,"voh",voh or false)
	dgsSetData(scrollbar,"position",0)
	dgsSetData(scrollbar,"length",{30,false},true)
	dgsSetData(scrollbar,"multiplier",{1,false})
	dgsSetData(scrollbar,"scrollmultiplier",{5,false})
	dgsSetData(scrollbar,"scrollArrow",true)
	if isElement(parent) then
		dgsSetParent(scrollbar,parent)
	else
		table.insert(MaxFatherTable,scrollbar)
	end
	triggerEvent("onClientDgsDxGUIPreCreate",scrollbar)
	calculateGuiPositionSize(scrollbar,x,y,relative or false,sx,sy,relative or false,true)
	triggerEvent("onClientDgsDxGUICreate",scrollbar)
	return scrollbar
end

function dgsDxScrollBarSetScrollBarPosition(scrollbar,pos)
	assert(dgsGetType(scrollbar) == "dgs-dxscrollbar","@dgsDxSetScrollBarPosition argument at 1,expect dgs-dxscrollbar got "..tostring(dgsGetType(scrollbar) or type(scrollbar)))
	assert(type(pos) == "number","@dgsDxSetScrollBarPosition argument at 2,expect number got "..type(pos))
	dgsSetData(scrollbar,"position",pos)
end

function dgsDxScrollBarGetScrollBarPosition(scrollbar)
	assert(dgsGetType(scrollbar) == "dgs-dxscrollbar","@dgsDxGetScrollBarPosition argument at 1,expect dgs-dxscrollbar got "..tostring(dgsGetType(scrollbar) or type(scrollbar)))
	return dgsGetData(scrollbar,"position")
end

function dgsDxScrollBarSetColor(scrollbar,colorn1,colorncursor,colornmid,colore1,colorecursor,colorc1,colorccursor)
	assert(dgsGetType(scrollbar) == "dgs-dxscrollbar","@dgsDxScrollBarSetColor argument at 1,expect dgs-dxscrollbar got "..tostring(dgsGetType(scrollbar) or type(scrollbar)))
	local colorn = dgsGetData(scrollbar,"colorn")
	local colore = dgsGetData(scrollbar,"colore")
	local colorc = dgsGetData(scrollbar,"colorc")
	colorn[1] = colorn1 or colorn[1]
	colorn[2] = colorncursor or colorn[2]
	colorn[3] = colornmid or colorn[3]
	colore[1] = colore1 or colore[1]
	colore[2] = colorecursor or colore[2]
	colorc[1] = colorc1 or colorc[1]
	colorc[2] = colorccursor or colorc[2]
	return true
end