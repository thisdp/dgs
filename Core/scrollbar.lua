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
	dgsSetData(scrollbar,"imageRotation",{{0,0,0},{270,270,270}})	--{Horizontal},{Vertical}
	dgsSetData(scrollbar,"arrowColor",{arrowColorNormal or styleSettings.scrollbar.arrowColor[1],arrowColorHover or styleSettings.scrollbar.arrowColor[2],arrowColorClick or styleSettings.scrollbar.arrowColor[3]})
	dgsSetData(scrollbar,"cursorColor",{cursorColorNormal or styleSettings.scrollbar.cursorColor[1],cursorColorHover or styleSettings.scrollbar.cursorColor[2],cursorColorClick or styleSettings.scrollbar.cursorColor[3]})
	dgsSetData(scrollbar,"troughColor",troughColor or styleSettings.scrollbar.troughColor)
	dgsSetData(scrollbar,"arrowBgColor",styleSettings.scrollbar.arrowBgColor or false)
	dgsSetData(scrollbar,"voh",voh or false) --vertical or horizontal
	dgsSetData(scrollbar,"position",0)
	dgsSetData(scrollbar,"length",{30,false},true)
	dgsSetData(scrollbar,"multiplier",{1,false})
	dgsSetData(scrollbar,"scrollArrow",styleSettings.scrollbar.scrollArrow)
	dgsSetData(scrollbar,"locked",false)
	dgsSetData(scrollbar,"grades",false)
	dgsSetData(scrollbar,"currentGrade",0)
	dgsSetData(scrollbar,"cursorWidth",styleSettings.scrollbar.cursorWidth or {1,true})
	dgsSetData(scrollbar,"troughWidth",styleSettings.scrollbar.troughWidth or styleSettings.scrollbar.cursorWidth or {1,true})
	dgsSetData(scrollbar,"arrowWidth",styleSettings.scrollbar.arrowWidth or styleSettings.scrollbar.cursorWidth or {1,true})
	calculateGuiPositionSize(scrollbar,x,y,relative or false,sx,sy,relative or false,true)
	triggerEvent("onDgsCreate",scrollbar,sourceResource)
	return scrollbar
end

function dgsScrollBarSetScrollPosition(scrollbar,pos,isGrade)
	assert(dgsGetType(scrollbar) == "dgs-dxscrollbar","Bad argument @dgsScrollBarSetScrollPosition at argument at 1, expect dgs-dxscrollbar got "..dgsGetType(scrollbar))
	assert(type(pos) == "number","Bad argument @dgsScrollBarSetScrollPosition at argument at 2, expect number got "..type(pos))
	if isGrade then
		local grades = dgsElementData[scrollbar].grades
		local newPos = pos/grades*100
		dgsSetData(scrollbar,"position",newPos)
	else
		dgsSetData(scrollbar,"position",pos)
	end
end

function dgsScrollBarGetScrollPosition(scrollbar,isGrade)
	assert(dgsGetType(scrollbar) == "dgs-dxscrollbar","Bad argument @dgsScrollBarGetScrollPosition at argument at 1, expect dgs-dxscrollbar got "..dgsGetType(scrollbar))
	if isGrade then
		local pos = dgsElementData[scrollbar].position
		local grades = dgsElementData[scrollbar].grades
		if not grades then return pos end
		return math.floor(pos/100*grades+0.5)
	else
		return dgsElementData[scrollbar].position
	end
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

function dgsScrollBarSetGrades(scrollbar,grades,remainMultipler)
	assert(dgsGetType(scrollbar) == "dgs-dxscrollbar","Bad argument @dgsScrollBarSetGrades at argument at 1, expect dgs-dxscrollbar got "..dgsGetType(scrollbar))
	assert(not grades or type(grades) == "number","Bad argument @dgsScrollBarSetGrades at argument at 2, expect false or a number got "..dgsGetType(grades))
	dgsSetData(scrollbar,"grades",grades)
	if not remainMultipler then
		dgsSetData(scrollbar,"multiplier",{1/grades,true})
	end
end

function dgsScrollBarGetGrades(scrollbar)
	assert(dgsGetType(scrollbar) == "dgs-dxscrollbar","Bad argument @dgsScrollBarGetGrades at argument at 1, expect dgs-dxscrollbar got "..dgsGetType(scrollbar))
	return dgsElementData[scrollbar].grades
end

function scrollScrollBar(scrollbar,button)
	local eleData = dgsElementData[scrollbar]
	local multiplier,rltPos = eleData.multiplier[1],eleData.multiplier[2]
	local slotRange
	local scrollArrow = eleData.scrollArrow
	local arrowPos = 0
	local w,h = eleData.absSize[1],eleData.absSize[2]
	local voh = eleData.voh
	local arrowWid = eleData.arrowWidth
	if voh then
		if scrollArrow then
			arrowPos = arrowWid[2] and h*arrowWid[1] or arrowWid[1]
		end
			slotRange = w-arrowPos*2
	else
		if scrollArrow then
			arrowPos = arrowWid[2] and w*arrowWid[1] or arrowWid[1]
		end
		slotRange = h-arrowPos*2
	end
	local pos = dgsElementData[scrollbar].position
	local offsetPos = (rltPos and multiplier*slotRange or multiplier)/(slotRange)*100
	local gpos = button and pos+offsetPos or pos-offsetPos
	dgsSetData(scrollbar,"position",math.restrict(gpos,0,100))
end

function dgsScrollBarSetCursorLength(scrollbar,size,relative)
	assert(dgsGetType(scrollbar) == "dgs-dxscrollbar","Bad argument @dgsScrollBarSetCursorLength at argument at 1, expect dgs-dxscrollbar got "..dgsGetType(scrollbar))
	return dgsSetData(scrollbar,"length",{size,relative or false})
end

function dgsScrollBarGetCursorLength(scrollbar,relative)
	assert(dgsGetType(scrollbar) == "dgs-dxscrollbar","Bad argument @dgsScrollBarGetCursorLength at argument at 1, expect dgs-dxscrollbar got "..dgsGetType(scrollbar))
	local relative = relative or false
	local eleData = dgsElementData[scrollbar]
	local slotRange
	local scrollArrow = eleData.scrollArrow
	local arrowPos = 0
	local w,h = eleData.absSize[1],eleData.absSize[2]
	local arrowWid = eleData.arrowWidth
	if voh then
		if scrollArrow then
			arrowPos = arrowWid[2] and h*arrowWid[1] or arrowWid[1]
		end
		slotRange = w-arrowPos*2
	else
		if scrollArrow then
			arrowPos = arrowWid[2] and w*arrowWid[1] or arrowWid[1]
		end
		slotRange = h-arrowPos*2
	end
	local multiplier = eleData.multiplier[2] and eleData.multiplier[1]*slotRange or eleData.multiplier[1]
	return relative and multiplier/slotRange or multiplier
end
--[[
function dgsScrollBarSyncWith(scrollbar1,scrollbar2)
	assert(dgsGetType(scrollbar1) == "dgs-dxscrollbar","Bad argument @dgsScrollBarSyncWith at argument at 1, expect dgs-dxscrollbar got "..dgsGetType(scrollbar1))
	assert(dgsGetType(scrollbar2) == "dgs-dxscrollbar","Bad argument @dgsScrollBarSyncWith at argument at 2, expect dgs-dxscrollbar got "..dgsGetType(scrollbar2))
	local function sync()
		if dgsElementData[me].position ~= dgsElementData[he].position then
			dgsSetData(he,
		end
	end
	dgsElementData[scrollbar1].he = scrollbar2
	dgsElementData[scrollbar2].he = scrollbar1
	addEventHandler("onDgsScrollBarScroll",scrollbar1,sync,false)
	addEventHandler("onDgsScrollBarScroll",scrollbar2,sync,false)
end

function dgsScrollBarDesyncFrom(scrollbar1,scrollbar2)
	assert(dgsGetType(scrollbar1) == "dgs-dxscrollbar","Bad argument @dgsScrollBarDesyncFrom at argument at 1, expect dgs-dxscrollbar got "..dgsGetType(scrollbar1))
end]]