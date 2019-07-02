function dgsCreateScrollBar(x,y,sx,sy,voh,relative,parent,arrowImage,troughImage,cursorImage,arrowColorNormal,troughColor,cursorColorNormal,arrowColorHover,cursorColorHover,arrowColorClick,cursorColorClick)
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"Bad argument @dgsCreateScrollBar at argument 7, expect dgs-dxgui got "..dgsGetType(parent))
	end
	assert(type(x) == "number","Bad argument @dgsCreateScrollBar at argument 1, expect number got "..type(x))
	assert(type(y) == "number","Bad argument @dgsCreateScrollBar at argument 2, expect number got "..type(y))
	assert(type(sx) == "number","Bad argument @dgsCreateScrollBar at argument 3, expect number got "..type(sx))
	assert(type(sy) == "number","Bad argument @dgsCreateScrollBar at argument 4, expect number got "..type(sy))
	local scrollbar = createElement("dgs-dxscrollbar")
	local _ = dgsIsDxElement(parent) and dgsSetParent(scrollbar,parent,true,true) or table.insert(CenterFatherTable,scrollbar)
	dgsSetType(scrollbar,"dgs-dxscrollbar")
	dgsSetData(scrollbar,"renderBuffer",{})
	local arrowImage = arrowImage or dgsCreateTextureFromStyle(styleSettings.scrollbar.image[1])
	local cursorImage = cursorImage or dgsCreateTextureFromStyle(styleSettings.scrollbar.image[2])
	local troughImage = troughImage or dgsCreateTextureFromStyle(styleSettings.scrollbar.image[3])
	dgsSetData(scrollbar,"image",{arrowImage,cursorImage,troughImage})
	dgsSetData(scrollbar,"arrowColor",{arrowColorNormal or styleSettings.scrollbar.arrowColor[1],arrowColorHover or styleSettings.scrollbar.arrowColor[2],arrowColorClick or styleSettings.scrollbar.arrowColor[3]})
	dgsSetData(scrollbar,"cursorColor",{cursorColorNormal or styleSettings.scrollbar.cursorColor[1],cursorColorHover or styleSettings.scrollbar.cursorColor[2],cursorColorClick or styleSettings.scrollbar.cursorColor[3]})
	dgsSetData(scrollbar,"troughColor",troughColor or styleSettings.scrollbar.troughColor)
	dgsSetData(scrollbar,"voh",voh or false) --vertical or horizontal
	dgsSetData(scrollbar,"position",0)
	dgsSetData(scrollbar,"length",{30,false},true)
	dgsSetData(scrollbar,"multiplier",{1,false})
	dgsSetData(scrollbar,"scrollArrow",true)
	dgsSetData(scrollbar,"locked",false)
	calculateGuiPositionSize(scrollbar,x,y,relative or false,sx,sy,relative or false,true)
	triggerEvent("onDgsCreate",scrollbar,sourceResource)
	return scrollbar
end

function dgsScrollBarSetScrollPosition(scrollbar,pos)
	assert(dgsGetType(scrollbar) == "dgs-dxscrollbar","Bad argument @dgsScrollBarSetScrollPosition at argument at 1, expect dgs-dxscrollbar got "..dgsGetType(scrollbar))
	assert(type(pos) == "number","Bad argument @dgsScrollBarSetScrollPosition at argument at 2, expect number got "..type(pos))
	dgsSetData(scrollbar,"position",pos)
end

function dgsScrollBarGetScrollPosition(scrollbar)
	assert(dgsGetType(scrollbar) == "dgs-dxscrollbar","Bad argument @dgsScrollBarGetScrollPosition at argument at 1, expect dgs-dxscrollbar got "..dgsGetType(scrollbar))
	return dgsElementData[scrollbar].position
end

function dgsScrollBarSetLocked(scrollbar,state)
	assert(dgsGetType(scrollbar) == "dgs-dxscrollbar","Bad argument @dgsScrollBarSetLocked at argument at 1, expect dgs-dxscrollbar got "..dgsGetType(scrollbar))
	local state = state and true or false
	return dgsSetData(scrollbar,"locked",state)
end

function dgsScrollBarGetLocked(scrollbar)
	assert(dgsGetType(scrollbar) == "dgs-dxscrollbar","Bad argument @dgsScrollBarGetLocked at argument at 1, expect dgs-dxscrollbar got "..dgsGetType(scrollbar))
	return dgsElementData[scrollbar].locked
end

function scrollScrollBar(scrollbar,button)
	local eleData = dgsElementData[scrollbar]
	local multiplier,rltPos = eleData.multiplier[1],eleData.multiplier[2]
	local slotRange
	local scrollArrow = eleData.scrollArrow
	local arrowPos = 0
	local w,h = eleData.absSize[1],eleData.absSize[2]
	local voh = eleData.voh
	if voh then
		if scrollArrow then
			arrowPos = h
		end
		slotRange = w-arrowPos*2
	else
		if scrollArrow then
			arrowPos = w
		end
		slotRange = h-arrowPos*2
	end
	local pos = dgsElementData[scrollbar].position
	local offsetPos = (rltPos and multiplier*slotRange or multiplier)/(slotRange)*100
	local gpos = button and pos+offsetPos or pos-offsetPos
	dgsSetData(scrollbar,"position",math.restrict(gpos,0,100))
end

function dgsScrollBarSetScrollSize(scrollbar,size,relative)
	assert(dgsGetType(scrollbar) == "dgs-dxscrollbar","Bad argument @dgsScrollBarSetScrollSize at argument at 1, expect dgs-dxscrollbar got "..dgsGetType(scrollbar))
	return dgsSetData(scrollbar,"length",{size,relative or false})
end

function dgsScrollBarGetScrollSize(scrollbar,relative)
	assert(dgsGetType(scrollbar) == "dgs-dxscrollbar","Bad argument @dgsScrollBarGetScrollSize at argument at 1, expect dgs-dxscrollbar got "..dgsGetType(scrollbar))
	local relative = relative or false
	local eleData = dgsElementData[scrollbar]
	local slotRange
	local scrollArrow = eleData.scrollArrow
	local arrowPos = 0
	local w,h = eleData.absSize[1],eleData.absSize[2]
	if voh then
		if scrollArrow then
			arrowPos = h
		end
		slotRange = w-arrowPos*2
	else
		if scrollArrow then
			arrowPos = w
		end
		slotRange = h-arrowPos*2
	end
	local multiplier = eleData.multiplier[2] and eleData.multiplier[1]*slotRange or eleData.multiplier[1]
	return relative and multiplier/slotRange or multiplier
end
