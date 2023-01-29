dgsLogLuaMemory()
dgsRegisterType("dgs-dxscrollbar","dgsBasic","dgsType2D")
dgsRegisterProperties("dgs-dxscrollbar",{
	arrowWidth = 				{	{ PArg.Number,PArg.Bool }	},
	arrowColor = 				{	{ PArg.Color, PArg.Color, PArg.Color }	},
	arrowImage = 				{	PArg.Material+PArg.Nil	},
	bgColor = 					{	PArg.Color+PArg.Nil		},
	bgImage = 					{	PArg.Material+PArg.Nil	},
	cursorColor = 				{	{ PArg.Color, PArg.Color, PArg.Color }	},
	cursorImage = 				{	PArg.Material+PArg.Nil	},
	cursorWidth = 				{	{ PArg.Number,PArg.Bool }	},
	grades = 					{	PArg.Number	},
	imageRotation = 			{	{	{ PArg.Number, PArg.Number,PArg.Number }, { PArg.Number, PArg.Number, PArg.Number }	}	},
	length = 					{	{ PArg.Number, PArg.Bool }	},
	locked = 					{	PArg.Bool	},
	map = 						{	{ PArg.Number,PArg.Number }	},
	multiplier = 				{	{ PArg.Number,PArg.Bool }	},
	scrollPosition = 			{	PArg.Number	},
	scrollArrow = 				{	PArg.Bool	},
	troughClickAction = 		{	PArg.String	},
	troughColor = 				{	{ PArg.Color,PArg.Color }	},
	troughWidth = 				{	{ PArg.Number,PArg.Bool }	},
	troughImage = 				{	PArg.Nil+PArg.Material, { PArg.Nil+PArg.Material, PArg.Nil+PArg.Material }	},
	troughImageSectionMode = 	{	PArg.Bool	},
	wheelReversed = 			{	PArg.Bool	},
	isHorizontal = 				{	PArg.Bool	},
})
--Dx Functions
local dxDrawLine = dxDrawLine
local dxDrawImage = dxDrawImage
--DGS Functions
local dgsSetType = dgsSetType
local dgsGetType = dgsGetType
local dgsSetParent = dgsSetParent
local dgsSetData = dgsSetData
local applyColorAlpha = applyColorAlpha
local calculateGuiPositionSize = calculateGuiPositionSize
local dgsCreateTextureFromStyle = dgsCreateTextureFromStyle
--Utilities
local dgsTriggerEvent = dgsTriggerEvent
local createElement = createElement
local isElement = isElement
local assert = assert
local tonumber = tonumber
local tostring = tostring
local type = type
local mathFloor = math.floor
local mathAbs = math.abs
local mathClamp = math.clamp

function dgsCreateScrollBar(...)
	local sRes = sourceResource or resource
	
	local x,y,w,h,isHorizontal,relative,parent,arrowImage,troughImage,cursorImage,nColorA,hColorA,cColorA,troughColor,nColorC,hColorC,cColorC
	if select("#",...) == 1 and type(select(1,...)) == "table" then
		local argTable = ...
		x = argTable.x or argTable[1]
		y = argTable.y or argTable[2]
		w = argTable.w or argTable.width or argTable[3]
		h = argTable.h or argTable.height or argTable[4]
		isHorizontal = argTable.isHorizontal or argTable.horizontal or argTable[5]
		relative = argTable.rlt or argTable.relative or argTable[6]
		parent = argTable.p or argTable.parent or argTable[7]
		arrowImage = argTable.arrowImage or argTable[8]
		troughImage = argTable.troughImage or argTable[9]
		cursorImage = argTable.cursorImage or argTable[10]
		nColorA = argTable.normalArrowColor or argTable.nColorA or argTable[11]
		hColorA = argTable.hoveringArrowColor or argTable[12]
		cColorA = argTable.clickedArrowColor or argTable[13]
		troughColor = argTable.troughColor or argTable[14]
		nColorC = argTable.normalCursorColor or argTable[15]
		hColorC = argTable.hoveringCursorColor or argTable[16]
		cColorC = argTable.clickedCursorColor or argTable[17]
	else
		x,y,w,h,isHorizontal,relative,parent,arrowImage,troughImage,cursorImage,nColorA,hColorA,cColorA,troughColor,nColorC,hColorC,cColorC = ...
	end
	if not(type(x) == "number") then error(dgsGenAsrt(x,"dgsCreateScrollBar",1,"number")) end
	if not(type(y) == "number") then error(dgsGenAsrt(y,"dgsCreateScrollBar",2,"number")) end
	if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsCreateScrollBar",3,"number")) end
	if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsCreateScrollBar",4,"number")) end
	local isHorizontal = isHorizontal or false
	local scrollbar = createElement("dgs-dxscrollbar")
	dgsSetType(scrollbar,"dgs-dxscrollbar")
				
	local res = sRes ~= resource and sRes or "global"
	local style = styleManager.styles[res]
	local using = style.using
	style = style.loaded[using]
	
	style = style.scrollbar
	local arrowImage = arrowImage or dgsCreateTextureFromStyle(using,res,style.arrowImage)
	local cursorImage = cursorImage or dgsCreateTextureFromStyle(using,res,style.cursorImage)
	if not troughImage then
		troughImage = isHorizontal and style.troughImageHorizontal or style.troughImage
		if troughImage and type(troughImage) == "table" then
			if type(troughImage[1]) == "table" then
				troughImage = {dgsCreateTextureFromStyle(using,res,troughImage[1]),dgsCreateTextureFromStyle(using,res,troughImage[2])}
			else
				troughImage = dgsCreateTextureFromStyle(using,res,troughImage)
			end
		end
	end
	dgsElementData[scrollbar] = {
		arrowBgColor = style.arrowBgColor or false,
		arrowColor = {nColorA or style.arrowColor[1],hColorA or style.arrowColor[2],cColorA or style.arrowColor[3]},
		arrowImage = arrowImage,
		arrowWidth = style.arrowWidth or style.cursorWidth or {1,true},
		currentGrade = 0,
		cursorColor = {nColorC or style.cursorColor[1],hColorC or style.cursorColor[2],cColorC or style.cursorColor[3]},
		cursorImage = cursorImage,
		cursorWidth = style.cursorWidth or {1,true},
		grades = -1,
		imageRotation = style.imageRotation,
		isHorizontal = isHorizontal; --vertical or horizonta,
		length = {30,false},
		locked = false,
		map = {0,100},
		minLength = 5,
		multiplier = {1,false},
		scrollPosition = 0,
		scrollArrow = style.scrollArrow,
		bgImage = nil,
		bgColor = nil,
		troughColor = troughColor or style.troughColor,
		troughImageSectionMode = false,
		troughImage = troughImage,
		troughClickAction = "none",
		troughWidth = style.troughWidth or style.cursorWidth or {1,true},
		wheelReversed = false,
		renderBuffer = {
			tempCursorColor = {},
			tempArrowColor = {},
			tempArrowBgColor = {},
			tempTroughColor = {},
			colorImageIndex = {},
		}
	}
	dgsSetParent(scrollbar,parent,true,true)
	calculateGuiPositionSize(scrollbar,x,y,relative or false,w,h,relative or false,true)
	onDGSElementCreate(scrollbar,sRes)
	return scrollbar
end

function dgsScrollBarSetScrollPosition(scrollbar,pos,isGrade,isAbsolute)
	if dgsGetType(scrollbar) ~= "dgs-dxscrollbar" then error(dgsGenAsrt(scrollbar,"dgsScrollBarSetScrollPosition",1,"dgs-dxscrollbar")) end
	if not(type(pos) == "number") then error(dgsGenAsrt(pos,"dgsScrollBarSetScrollPosition",2,"number")) end
	local grades = dgsElementData[scrollbar].grades
	if grades and grades > 0 then
		pos = isGrade and pos/grades*100 or pos
	end
	local scaler = dgsElementData[scrollbar].map
	if not isAbsolute then
		pos = (pos-scaler[1])/(scaler[2]-scaler[1])*100
	end
	if pos < 0 then pos = 0 end
	if pos > 100 then pos = 100 end
	dgsSetData(scrollbar,"moveType","fast")
	return dgsSetData(scrollbar,"scrollPosition",pos)
end

function dgsScrollBarGetScrollPosition(scrollbar,isGrade,isAbsolute)
	if dgsGetType(scrollbar) ~= "dgs-dxscrollbar" then error(dgsGenAsrt(scrollbar,"dgsScrollBarGetScrollPosition",1,"dgs-dxscrollbar")) end
	local pos = dgsElementData[scrollbar].scrollPosition
	local scaler = dgsElementData[scrollbar].map
	if not isAbsolute then
		pos = pos/100*(scaler[2]-scaler[1])+scaler[1]
	end
	if isGrade then
		local grades = dgsElementData[scrollbar].grades
		if not grades or grades <= 0 then return pos end
		pos = mathFloor(pos/100*grades+0.5)
	end
	return pos
end

function dgsScrollBarSetLocked(scrollbar,state)
	if dgsGetType(scrollbar) ~= "dgs-dxscrollbar" then error(dgsGenAsrt(scrollbar,"dgsScrollBarSetLocked",1,"dgs-dxscrollbar")) end
	local state = state and true or false
	return dgsSetData(scrollbar,"locked",state)
end

function dgsScrollBarGetLocked(scrollbar)
	if dgsGetType(scrollbar) ~= "dgs-dxscrollbar" then error(dgsGenAsrt(scrollbar,"dgsScrollBarGetLocked",1,"dgs-dxscrollbar")) end
	return dgsElementData[scrollbar].locked
end

function dgsScrollBarSetGrades(scrollbar,grades,remainMultipler)
	if dgsGetType(scrollbar) ~= "dgs-dxscrollbar" then error(dgsGenAsrt(scrollbar,"dgsScrollBarSetGrades",1,"dgs-dxscrollbar")) end
	if grades and type(grades) ~= "number" then error(dgsGenAsrt(grades,"dgsScrollBarSetGrades",2,"number")) end
	if not remainMultipler then
		dgsSetData(scrollbar,"multiplier",{1/grades,true})
	end
	return dgsSetData(scrollbar,"grades",grades)
end

function dgsScrollBarGetGrades(scrollbar)
	if dgsGetType(scrollbar) ~= "dgs-dxscrollbar" then error(dgsGenAsrt(scrollbar,"dgsScrollBarGetGrades",1,"dgs-dxscrollbar")) end
	return dgsElementData[scrollbar].grades
end

function scrollScrollBar(scrollbar,button,speed)
	local eleData = dgsElementData[scrollbar]
	local multiplier,rltPos = eleData.multiplier[1],eleData.multiplier[2]
	local slotRange
	local w,h = eleData.absSize[1],eleData.absSize[2]
	local isHorizontal = eleData.isHorizontal
	local arrowWid = eleData.arrowWidth
	local scrollArrow = eleData.scrollArrow
	if isHorizontal then
		slotRange = w-(scrollArrow and (arrowWid[2] and h*arrowWid[1] or arrowWid[1]) or 0)*2
	else
		slotRange = h-(scrollArrow and (arrowWid[2] and w*arrowWid[1] or arrowWid[1]) or 0)*2
	end
	local pos = dgsElementData[scrollbar].scrollPosition
	local wheelReversed = dgsElementData[scrollbar].wheelReversed and -1 or 1
	local offsetPos = (rltPos and multiplier*slotRange or multiplier)/slotRange*100*(speed or 1)
	local gpos = button and pos+offsetPos*wheelReversed or pos-offsetPos*wheelReversed
	dgsSetData(scrollbar,"scrollPosition",mathClamp(gpos,0,100))
end

function dgsScrollBarSetCursorLength(scrollbar,length,relative)
	if dgsGetType(scrollbar) ~= "dgs-dxscrollbar" then error(dgsGenAsrt(scrollbar,"dgsScrollBarSetCursorLength",1,"dgs-dxscrollbar")) end
	if not(type(length) == "number") then error(dgsGenAsrt(length,"dgsScrollBarSetCursorLength",2,"number")) end
	return dgsSetData(scrollbar,"length",{tonumber(length),relative or false})
end

function dgsScrollBarGetCursorLength(scrollbar,relative)
	if dgsGetType(scrollbar) ~= "dgs-dxscrollbar" then error(dgsGenAsrt(scrollbar,"dgsScrollBarGetCursorLength",1,"dgs-dxscrollbar")) end
	local relative = relative or false
	local eleData = dgsElementData[scrollbar]
	local slotRange
	local scrollArrow = eleData.scrollArrow
	local w,h = eleData.absSize[1],eleData.absSize[2]
	local arrowWid = eleData.arrowWidth
	local isHorizontal = eleData.isHorizontal
	if isHorizontal then
		slotRange = w-(scrollArrow and (arrowWid[2] and h*arrowWid[1] or arrowWid[1]) or 0)*2
	else
		slotRange = h-(scrollArrow and (arrowWid[2] and w*arrowWid[1] or arrowWid[1]) or 0)*2
	end
	local multiplier = eleData.multiplier[2] and eleData.multiplier[1]*slotRange or eleData.multiplier[1]
	return relative and multiplier/slotRange or multiplier
end

function dgsScrollBarSetCursorWidth(scrollbar,width,relative)
	if dgsGetType(scrollbar) ~= "dgs-dxscrollbar" then error(dgsGenAsrt(scrollbar,"dgsScrollBarSetCursorWidth",1,"dgs-dxscrollbar")) end
	if not(type(width) == "number") then error(dgsGenAsrt(width,"dgsScrollBarSetCursorWidth",2,"number")) end
	return dgsSetData(scrollbar,"cursorWidth",{width,relative or false})
end

function dgsScrollBarGetCursorWidth(scrollbar,relative)
	if dgsGetType(scrollbar) ~= "dgs-dxscrollbar" then error(dgsGenAsrt(scrollbar,"dgsScrollBarGetCursorWidth",1,"dgs-dxscrollbar")) end
	if not(type(width) == "number") then error(dgsGenAsrt(width,"dgsScrollBarGetCursorWidth",2,"number")) end
	local relative = relative or false
	local eleData = dgsElementData[scrollbar]
	local w,h = eleData.absSize[1],eleData.absSize[2]
	local cursorWidth = eleData.cursorWidth
	if relative == cursorWidth[1] then
		return cursorWidth[0]
	else
		local isHorizontal = eleData.isHorizontal
		local absCursorWid = cursorWidth[1] and cursorWidth[0]*(isHorizontal and w or h) or cursorWidth[0]
		return relative and absCursorWid*(isHorizontal and w or h) or absCursorWid
	end
end


function dgsScrollBarSetTroughWidth(scrollbar,width,relative)
	if dgsGetType(scrollbar) ~= "dgs-dxscrollbar" then error(dgsGenAsrt(scrollbar,"dgsScrollBarSetTroughWidth",1,"dgs-dxscrollbar")) end
	if not(type(width) == "number") then error(dgsGenAsrt(width,"dgsScrollBarSetTroughWidth",2,"number")) end
	return dgsSetData(scrollbar,"troughWidth",{width,relative or false})
end

function dgsScrollBarGetTroughWidth(scrollbar,relative)
	if dgsGetType(scrollbar) ~= "dgs-dxscrollbar" then error(dgsGenAsrt(scrollbar,"dgsScrollBarGetTroughWidth",1,"dgs-dxscrollbar")) end
	local relative = relative or false
	local eleData = dgsElementData[scrollbar]
	local w,h = eleData.absSize[1],eleData.absSize[2]
	local troughWidth = eleData.troughWidth
	if relative == troughWidth[1] then
		return troughWidth[0]
	else
		local isHorizontal = eleData.isHorizontal
		local absTroughWid = troughWidth[1] and troughWidth[0]*(isHorizontal and w or h) or troughWidth[0]
		return relative and absTroughWid*(isHorizontal and w or h) or absTroughWid
	end
end

function dgsScrollBarSetArrowSize(scrollbar,size,relative)
	if dgsGetType(scrollbar) ~= "dgs-dxscrollbar" then error(dgsGenAsrt(scrollbar,"dgsScrollBarSetArrowSize",1,"dgs-dxscrollbar")) end
	if not(type(size) == "number") then error(dgsGenAsrt(size,"dgsScrollBarSetArrowSize",2,"number")) end
	return dgsSetData(scrollbar,"arrowWidth",{size,relative or false})
end

function dgsScrollBarGetArrowSize(scrollbar,relative)
	if dgsGetType(scrollbar) ~= "dgs-dxscrollbar" then error(dgsGenAsrt(scrollbar,"dgsScrollBarGetArrowSize",1,"dgs-dxscrollbar")) end
	local relative = relative or false
	local eleData = dgsElementData[scrollbar]
	local w,h = eleData.absSize[1],eleData.absSize[2]
	local arrowWidth = eleData.arrowWidth
	if relative == arrowWidth[1] then
		return arrowWidth[0]
	else
		local isHorizontal = eleData.isHorizontal
		local absArrowSize = arrowWidth[1] and arrowWidth[0]*(isHorizontal and w or h) or arrowWidth[0]
		return relative and absArrowSize*(isHorizontal and w or h) or absArrowSize
	end
end

local allowedClickAction = { none=1, step=2, jump=3 }
function dgsScrollBarSetTroughClickAction(scrollbar,action)
	if dgsGetType(scrollbar) ~= "dgs-dxscrollbar" then error(dgsGenAsrt(scrollbar,"dgsScrollBarSetTroughClickAction",1,"dgs-dxscrollbar")) end
	if not(allowedClickAction[action]) then error(dgsGenAsrt(action,"dgsScrollBarSetTroughClickAction",2,"number","1/2/3")) end
	return dgsSetData(scrollbar,"troughClickAction",action)
end

function dgsScrollBarGetTroughClickAction(scb)
	if dgsGetType(scrollbar) ~= "dgs-dxscrollbar" then error(dgsGenAsrt(scrollbar,"dgsScrollBarGetTroughClickAction",1,"dgs-dxscrollbar")) end
	return dgsElementData[scrollbar].troughClickAction or "none"
end

----------------------------------------------------------------
-----------------------PropertyListener-------------------------
----------------------------------------------------------------
dgsOnPropertyChange["dgs-dxscrollbar"] = {
	length = function(dgsEle,key,value,oldValue)
		local absSize = dgsElementData[dgsEle].absSize
		local w,h = absSize[1],absSize[2]
		local isHorizontal = dgsElementData[dgsEle].isHorizontal
		if (value[2] and value[1]*(isHorizontal and w-h*2 or h-w*2) or value[1]) < dgsElementData[dgsEle].minLength then
			dgsElementData[dgsEle].length = {dgsElementData[dgsEle].minLength,false}
		end
	end,
	scrollPosition = function(dgsEle,key,value,oldValue)
		if oldValue then
			if not dgsElementData[dgsEle].locked then
				local grades = dgsElementData[dgsEle].grades
				local scaler = dgsElementData[dgsEle].map
				local nValue,oValue = value,oldValue
				if grades and grades > 0 then
					nValue,oValue = nValue/100*grades+0.5,oValue/100*grades+0.5
					nValue,oValue = nValue-nValue%1,oValue-oValue%1
					dgsSetData(dgsEle,"currentGrade",nValue)
					dgsElementData[dgsEle][key] = nValue/grades*100
				else
					dgsElementData[dgsEle][key] = nValue
				end
				dgsTriggerEvent("onDgsElementScroll",dgsEle,dgsEle,dgsElementData[dgsEle][key],oldValue,nValue,oValue)
			else
				dgsElementData[dgsEle][key] = oldValue
			end
		end
	end,
	grades = function(dgsEle,key,value,oldValue)
		if value then
			local currentGrade = dgsElementData[dgsEle].scrollPosition/100*value+0.5
			dgsSetData(dgsEle,"currentGrade",currentGrade-currentGrade%1)
		else
			dgsSetData(dgsEle,"currentGrade",false)
		end
	end,
}
----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxscrollbar"] = function(source,x,y,w,h,mx,my,cx,cy,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt)
	if MouseData.hit == source and MouseData.focused == source then
		MouseData.topScrollable = source
	end
	local isHorizontal = eleData.isHorizontal
	local image = eleData.image or {}
	local arrowImage = eleData.arrowImage or image[1]
	local cursorImage = eleData.cursorImage or image[2]
	local troughImage = eleData.troughImage or image[3]
	local tempTroughImage_1,tempTroughImage_2
	if type(troughImage) == "table" then
		tempTroughImage_1,tempTroughImage_2 = troughImage[1],troughImage[2]
	else
		tempTroughImage_1,tempTroughImage_2 = troughImage,troughImage
	end

	local pos = eleData.scrollPosition
	local length,lrlt = eleData.length[1],eleData.length[2]
	local cursorColor = eleData.cursorColor
	local arrowColor = eleData.arrowColor
	local arrowBgColor = eleData.arrowBgColor
	local renderBuffer = eleData.renderBuffer
	local tempCursorColor = renderBuffer.tempCursorColor
	tempCursorColor[1] = applyColorAlpha(cursorColor[1],parentAlpha)
	tempCursorColor[2] = applyColorAlpha(cursorColor[2],parentAlpha)
	tempCursorColor[3] = applyColorAlpha(cursorColor[3],parentAlpha)

	local tempArrowColor = renderBuffer.tempArrowColor
	tempArrowColor[1] = applyColorAlpha(arrowColor[1],parentAlpha)
	tempArrowColor[2] = applyColorAlpha(arrowColor[2],parentAlpha)
	tempArrowColor[3] = applyColorAlpha(arrowColor[3],parentAlpha)


	local tempArrowBgColor = renderBuffer.tempArrowBgColor
	tempArrowBgColor[1] = applyColorAlpha(arrowBgColor[1],parentAlpha)
	tempArrowBgColor[2] = applyColorAlpha(arrowBgColor[2],parentAlpha)
	tempArrowBgColor[3] = applyColorAlpha(arrowBgColor[3],parentAlpha)

	local tempTroughColor = renderBuffer.tempTroughColor
	if type(eleData.troughColor) == "table" then
		tempTroughColor[1] = applyColorAlpha(eleData.troughColor[1],parentAlpha)
		tempTroughColor[2] = applyColorAlpha(eleData.troughColor[2],parentAlpha)
	else
		tempTroughColor[1] = applyColorAlpha(eleData.troughColor,parentAlpha)
		tempTroughColor[2] = applyColorAlpha(eleData.troughColor,parentAlpha)
	end

	local colorImageIndex = renderBuffer.colorImageIndex
	colorImageIndex[1] = 1
	colorImageIndex[2] = 1
	colorImageIndex[3] = 1
	colorImageIndex[4] = 1
	colorImageIndex[5] = 1

	local slotRange
	local scrollArrow = eleData.scrollArrow
	local cursorWidth,troughWidth,arrowWidth = eleData.cursorWidth,eleData.troughWidth,eleData.arrowWidth
	local imgRot = eleData.imageRotation
	local troughPadding,cursorPadding,arrowPadding
	
	if isHorizontal then
		troughWidth = troughWidth[2] and troughWidth[1]*h or troughWidth[1]
		cursorWidth = cursorWidth[2] and cursorWidth[1]*h or cursorWidth[1]
		troughPadding = (h-troughWidth)/2
		cursorPadding = (h-cursorWidth)/2
		if not scrollArrow then
			arrowWidth = 0
			arrowPadding = 0
		else
			arrowWidth = arrowWidth[2] and arrowWidth[1]*h or arrowWidth[1]
			arrowPadding = (h-arrowWidth)/2
		end
		slotRange = w-arrowWidth*2
	else
		troughWidth = troughWidth[2] and troughWidth[1]*w or troughWidth[1]
		cursorWidth = cursorWidth[2] and cursorWidth[1]*w or cursorWidth[1]
		troughPadding = (w-troughWidth)/2
		cursorPadding = (w-cursorWidth)/2
		if not scrollArrow then
			arrowWidth = 0
			arrowPadding = 0
		else
			arrowWidth = arrowWidth[2] and arrowWidth[1]*w or arrowWidth[1]
			arrowPadding = (w-arrowWidth)/2
		end
		slotRange = h-arrowWidth*2
	end
	local cursorRange = lrlt and length*slotRange or (length <= slotRange and length or 0)
	local csRange = slotRange-cursorRange
	if MouseData.entered == source then
		local preEnterData = false
		local preEnterPos = false
		local mxRlt,myRlt = mx-cx,my-cy
		if isHorizontal then
			if myRlt >= 0 and myRlt <= h then
				if mxRlt >= 0 and mxRlt <= arrowWidth then				--Left Arrow
					if mathAbs(h/2-myRlt) <= arrowWidth then preEnterData = 1 end
				elseif mxRlt < arrowWidth+pos*0.01*csRange then			--Left Trough
					if mathAbs(h/2-myRlt) <= troughWidth then preEnterData = 2 end
				elseif mxRlt >= arrowWidth+pos*0.01*csRange and mxRlt <= arrowWidth+pos*0.01*csRange+cursorRange then
					if mathAbs(h/2-myRlt) <= cursorWidth then preEnterData = 3 end
				elseif mxRlt < w-arrowWidth then						--Right Trough
					if mathAbs(h/2-myRlt) <= troughWidth then preEnterData = 4 end
				elseif mxRlt >= w-arrowWidth and mxRlt <= w then		--Right Arrow
					if mathAbs(h/2-myRlt) <= arrowWidth then preEnterData = 5 end
				end
				preEnterPos = (mxRlt-arrowWidth)/(w-arrowWidth*2)
			end
		else
			if mxRlt >= 0 and mxRlt <= w then
				if myRlt >= 0 and myRlt <= arrowWidth then				--Up Arrow
					if mathAbs(w/2-mxRlt) <= arrowWidth then preEnterData = 1 end
				elseif myRlt < arrowWidth+pos*0.01*csRange then			--Up Trough
					if mathAbs(w/2-mxRlt) <= troughWidth then preEnterData = 2 end
				elseif myRlt >= arrowWidth+pos*0.01*csRange and myRlt <= arrowWidth+pos*0.01*csRange+cursorRange then
					if mathAbs(w/2-mxRlt) <= cursorWidth then preEnterData = 3 end
				elseif myRlt < h-arrowWidth then						--Down Trough
					if mathAbs(w/2-mxRlt) <= troughWidth then preEnterData = 4 end
				elseif myRlt >= h-arrowWidth and myRlt <= h then		--Down Arrow
					if mathAbs(w/2-mxRlt) <= arrowWidth then preEnterData = 5 end
				end
				preEnterPos = (myRlt-arrowWidth-cursorRange/2)/csRange
			end
		end
		if not MouseData.scbClickData then
			MouseData.scbEnterData = preEnterData
			MouseData.scbEnterRltPos = preEnterPos
			if MouseData.scbEnterData then
				colorImageIndex[MouseData.scbEnterData] = 2
			end
		else
			if MouseData.click.left == source then
				colorImageIndex[MouseData.scbClickData] = 3
				if MouseData.scbClickData == 3 then
					local scrollPosition = 0
					local mvx,mvy = MouseData.MoveScroll[1],MouseData.MoveScroll[2]
					local ax,ay = dgsGetPosition(source,false)
					if csRange ~= 0 then
						if isHorizontal then
							local gx = (mx-mvx-ax)/csRange
							scrollPosition = (gx < 0 and 0) or (gx > 1 and 1) or gx
						else
							local gy = (my-mvy-ay)/csRange
							scrollPosition = (gy < 0 and 0) or (gy > 1 and 1) or gy
						end
					end
					dgsSetData(source,"moveType","fast")
					dgsSetData(source,"scrollPosition",scrollPosition*100)
				end
			else
				colorImageIndex[MouseData.scbClickData] = 2
			end
		end
	end
	if isHorizontal then
		local cursorCenter = pos*0.01*csRange+cursorRange/2
		local troughPart1_1,troughPart1_2 = x+arrowWidth,cursorCenter
		local troughPart2_1,troughPart2_2 = x+arrowWidth+cursorCenter,w-2*arrowWidth-cursorCenter
		local imgRotHorz = imgRot[1]
		if eleData.bgColor then
			local bgColor = applyColorAlpha(eleData.bgColor,parentAlpha)
			dxDrawImage(x,y,w,h,eleData.bgImage,imgRotHorz[3],0,0,bgColor,isPostGUI,rndtgt)
		end
		if eleData.troughImageSectionMode then
			local sx,sy = dxGetMaterialSize(tempTroughImage_1)
			if not sx or not sy then sx,sy = 0,0 end
			local percent = cursorCenter/slotRange
			dxDrawImageSection(troughPart1_1,y+troughPadding,troughPart1_2,troughWidth,0,0,sx*percent,sy,tempTroughImage_1,imgRotHorz[3],0,0,tempTroughColor[1],isPostGUI,rndtgt)
		else
			dxDrawImage(troughPart1_1,y+troughPadding,troughPart1_2,troughWidth,tempTroughImage_1,imgRotHorz[3],0,0,tempTroughColor[1],isPostGUI,rndtgt)
		end
		if eleData.troughImageSectionMode then
			local sx,sy = dxGetMaterialSize(tempTroughImage_2)
			if not sx or not sy then sx,sy = 0,0 end
			local percent = cursorCenter/slotRange
			dxDrawImageSection(troughPart2_1,y+troughPadding,troughPart2_2,troughWidth,sx*percent,0,sx*(1-percent),sy,tempTroughImage_2,imgRotHorz[3],0,0,tempTroughColor[2],isPostGUI,rndtgt)
		else
			dxDrawImage(troughPart2_1,y+troughPadding,troughPart2_2,troughWidth,tempTroughImage_2,imgRotHorz[3],0,0,tempTroughColor[2],isPostGUI,rndtgt)
		end
		if scrollArrow then
			if tempArrowBgColor then
				dxDrawRectangle(x,y+arrowPadding,arrowWidth,arrowWidth,tempArrowBgColor[colorImageIndex[1]],isPostGUI)
				dxDrawRectangle(x+w-arrowWidth,y+arrowPadding,arrowWidth,arrowWidth,tempArrowBgColor[colorImageIndex[5]],isPostGUI)
			end
			dxDrawImage(x,y+arrowPadding,arrowWidth,arrowWidth,arrowImage,imgRotHorz[1],0,0,tempArrowColor[colorImageIndex[1]],isPostGUI,rndtgt)
			dxDrawImage(x+w-arrowWidth,y+arrowPadding,arrowWidth,arrowWidth,arrowImage,imgRotHorz[1]+180,0,0,tempArrowColor[colorImageIndex[5]],isPostGUI,rndtgt)
		end
		dxDrawImage(x+arrowWidth+pos*0.01*csRange,y+cursorPadding,cursorRange,cursorWidth,cursorImage,imgRotHorz[2],0,0,tempCursorColor[colorImageIndex[3]],isPostGUI,rndtgt)
	else
		local cursorCenter = pos*0.01*csRange+cursorRange/2
		local troughPart1_1,troughPart1_2 = y+arrowWidth,cursorCenter
		local troughPart2_1,troughPart2_2 = y+arrowWidth+cursorCenter,h-2*arrowWidth-cursorCenter
		local imgRotVert = imgRot[2]
		if eleData.bgColor then
			local bgColor = applyColorAlpha(eleData.bgColor,parentAlpha)
			dxDrawImage(x,y,w,h,eleData.bgImage,imgRotVert[3],0,0,bgColor,isPostGUI,rndtgt)
		end
		if eleData.troughImageSectionMode then
			local sx,sy = dxGetMaterialSize(tempTroughImage_1)
			if not sx or not sy then sx,sy = 0,0 end
			local percent = cursorCenter/slotRange
			dxDrawImageSection(x+troughPadding,troughPart1_1,troughWidth,troughPart1_2,0,0,sx,sy*percent,tempTroughImage_1,imgRotVert[3],0,0,tempTroughColor[1],isPostGUI,rndtgt)
		else
			dxDrawImage(x+troughPadding,troughPart1_1,troughWidth,troughPart1_2,tempTroughImage_1,imgRotVert[3],0,0,tempTroughColor[1],isPostGUI,rndtgt)
		end
		if eleData.troughImageSectionMode then
			local sx,sy = dxGetMaterialSize(tempTroughImage_2)
			if not sx or not sy then sx,sy = 0,0 end
			local percent = cursorCenter/slotRange
			dxDrawImageSection(x+troughPadding,troughPart2_1,troughWidth,troughPart2_2,0,sy*percent,sx,sy*(1-percent),tempTroughImage_2,imgRotVert[3],0,0,tempTroughColor[2],isPostGUI,rndtgt)
		else
			dxDrawImage(x+troughPadding,troughPart2_1,troughWidth,troughPart2_2,tempTroughImage_2,imgRotVert[3],0,0,tempTroughColor[2],isPostGUI,rndtgt)
		end
		if scrollArrow then
			if tempArrowBgColor then
				dxDrawRectangle(x+arrowPadding,y,arrowWidth,arrowWidth,tempArrowBgColor[colorImageIndex[1]],isPostGUI)
				dxDrawRectangle(x+arrowPadding,y+h-arrowWidth,arrowWidth,arrowWidth,tempArrowBgColor[colorImageIndex[5]],isPostGUI)
			end
			dxDrawImage(x+arrowPadding,y,arrowWidth,arrowWidth,arrowImage,imgRotVert[1],0,0,tempArrowColor[colorImageIndex[1]],isPostGUI,rndtgt)
			dxDrawImage(x+arrowPadding,y+h-arrowWidth,arrowWidth,arrowWidth,arrowImage,imgRotVert[1]+180,0,0,tempArrowColor[colorImageIndex[5]],isPostGUI,rndtgt)
		end
		dxDrawImage(x+cursorPadding,y+arrowWidth+pos*0.01*csRange,cursorWidth,cursorRange,cursorImage,imgRotVert[2],0,0,tempCursorColor[colorImageIndex[3]],isPostGUI,rndtgt)
	end
	return rndtgt,false,mx,my,0,0
end