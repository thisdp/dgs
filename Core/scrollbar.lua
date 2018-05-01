scrollBarSettings = {}
scrollBarSettings.arrow = "image/scrollbar/scrollbar_arrow.png"

function dgsCreateScrollBar(x,y,sx,sy,voh,relative,parent,img1,imgmid,imgcursor,colorn1,colornmid,colorncursor,colore1,colorecursor,colorc1,colorccursor)
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"Bad argument @dgsCreateScrollBar at argument 7, expect dgs-dxgui got "..dgsGetType(parent))
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
		table.insert(CenterFatherTable,scrollbar)
	end
	triggerEvent("onDgsPreCreate",scrollbar)
	calculateGuiPositionSize(scrollbar,x,y,relative or false,sx,sy,relative or false,true)
	triggerEvent("onDgsCreate",scrollbar)
	return scrollbar
end

function dgsScrollBarSetScrollPosition(scrollbar,pos)
	assert(dgsGetType(scrollbar) == "dgs-dxscrollbar","Bad argument @dgsSetScrollBarPosition at argument at 1, expect dgs-dxscrollbar got "..dgsGetType(scrollbar))
	assert(type(pos) == "number","Bad argument @dgsSetScrollBarPosition at argument at 2, expect number got "..type(pos))
	dgsSetData(scrollbar,"position",pos)
end

function dgsScrollBarGetScrollPosition(scrollbar)
	assert(dgsGetType(scrollbar) == "dgs-dxscrollbar","Bad argument @dgsGetScrollBarPosition at argument at 1, expect dgs-dxscrollbar got "..dgsGetType(scrollbar))
	return dgsElementData[scrollbar].position
end

function scrollScrollBar(scrollbar,button)
	local length,lrlt = dgsElementData[scrollbar].length[1],dgsElementData[scrollbar].length[2]
	local scrollMultiplier,rltPos = dgsElementData[scrollbar].scrollmultiplier[1],dgsElementData[scrollbar].scrollmultiplier[2]
	local pos = dgsElementData[scrollbar].position
	local offsetPos = (rltPos and scrollMultiplier*cursorRange*0.01 or scrollMultiplier)
	local gpos = button and pos+offsetPos or pos-offsetPos
	dgsSetData(scrollbar,"position",math.restrict(0,100,gpos))
end