--Dx Functions
local dxDrawLine = dxDrawLine
local dxDrawImage = dxDrawImageExt
local dxDrawImageSection = dxDrawImageSectionExt
local dxDrawText = dxDrawText
local dxGetFontHeight = dxGetFontHeight
local dxDrawRectangle = dxDrawRectangle
local dxSetShaderValue = dxSetShaderValue
local dxGetPixelsSize = dxGetPixelsSize
local dxGetPixelColor = dxGetPixelColor
local dxSetRenderTarget = dxSetRenderTarget
local dxGetTextWidth = dxGetTextWidth
local dxSetBlendMode = dxSetBlendMode
--
local mathAbs = math.abs
local mathClamp = math.restrict

function dgsCreateScrollBar(x,y,sx,sy,isHorizontal,relative,parent,arrowImage,troughImage,cursorImage,arrowColorNormal,troughColor,cursorColorNormal,arrowColorHover,cursorColorHover,arrowColorClick,cursorColorClick)
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"Bad argument @dgsCreateScrollBar at argument 7, expect dgs-dxgui got "..dgsGetType(parent))
	end
	assert(type(x) == "number","Bad argument @dgsCreateScrollBar at argument 1, expect number got "..type(x))
	assert(type(y) == "number","Bad argument @dgsCreateScrollBar at argument 2, expect number got "..type(y))
	assert(type(sx) == "number","Bad argument @dgsCreateScrollBar at argument 3, expect number got "..type(sx))
	assert(type(sy) == "number","Bad argument @dgsCreateScrollBar at argument 4, expect number got "..type(sy))
	local isHorizontal = isHorizontal or false
	local scrollbar = createElement("dgs-dxscrollbar")
	local _ = dgsIsDxElement(parent) and dgsSetParent(scrollbar,parent,true,true) or table.insert(CenterFatherTable,scrollbar)
	dgsSetType(scrollbar,"dgs-dxscrollbar")
	dgsSetData(scrollbar,"renderBuffer",{})
	local deprecatedImage = styleSettings.scrollbar.image or {}
	local arrowImage = arrowImage or dgsCreateTextureFromStyle(styleSettings.scrollbar.arrowImage) or dgsCreateTextureFromStyle(deprecatedImage[1])
	local cursorImage = cursorImage or dgsCreateTextureFromStyle(styleSettings.scrollbar.cursorImage) or dgsCreateTextureFromStyle(deprecatedImage[2])
	if not troughImage then
		troughImage = isHorizontal and styleSettings.scrollbar.troughImageHorizontal or styleSettings.scrollbar.troughImage
		if troughImage and type(troughImage) == "table" then
			if type(troughImage[1]) == "table" then
				troughImage = {dgsCreateTextureFromStyle(troughImage[1]),dgsCreateTextureFromStyle(troughImage[2])}
			else
				troughImage = dgsCreateTextureFromStyle(troughImage)
			end
		end
	end
	dgsSetData(scrollbar,"imageRotation",styleSettings.scrollbar.imageRotation)
	dgsSetData(scrollbar,"arrowColor",{arrowColorNormal or styleSettings.scrollbar.arrowColor[1],arrowColorHover or styleSettings.scrollbar.arrowColor[2],arrowColorClick or styleSettings.scrollbar.arrowColor[3]})
	dgsSetData(scrollbar,"cursorColor",{cursorColorNormal or styleSettings.scrollbar.cursorColor[1],cursorColorHover or styleSettings.scrollbar.cursorColor[2],cursorColorClick or styleSettings.scrollbar.cursorColor[3]})
	dgsSetData(scrollbar,"troughColor",troughColor or styleSettings.scrollbar.troughColor)
	dgsSetData(scrollbar,"arrowImage",arrowImage)
	dgsSetData(scrollbar,"cursorImage",cursorImage)
	dgsSetData(scrollbar,"troughImage",troughImage)
	dgsSetData(scrollbar,"troughClickAction","none")
	dgsSetData(scrollbar,"wheelReversed",false)
	dgsSetData(scrollbar,"arrowBgColor",styleSettings.scrollbar.arrowBgColor or false)
	dgsSetData(scrollbar,"isHorizontal",isHorizontal) --vertical or horizontal
	dgsSetData(scrollbar,"position",0)
	dgsSetData(scrollbar,"minLength",5)
	dgsSetData(scrollbar,"length",{30,false},true)
	dgsSetData(scrollbar,"multiplier",{1,false})
	dgsSetData(scrollbar,"scrollArrow",styleSettings.scrollbar.scrollArrow)
	dgsSetData(scrollbar,"locked",false)
	dgsSetData(scrollbar,"grades",false)
	dgsSetData(scrollbar,"map",{0,100})
	dgsSetData(scrollbar,"currentGrade",0)
	dgsSetData(scrollbar,"cursorWidth",styleSettings.scrollbar.cursorWidth or {1,true})
	dgsSetData(scrollbar,"troughWidth",styleSettings.scrollbar.troughWidth or styleSettings.scrollbar.cursorWidth or {1,true})
	dgsSetData(scrollbar,"arrowWidth",styleSettings.scrollbar.arrowWidth or styleSettings.scrollbar.cursorWidth or {1,true})
	calculateGuiPositionSize(scrollbar,x,y,relative or false,sx,sy,relative or false,true)
	triggerEvent("onDgsCreate",scrollbar,sourceResource)
	return scrollbar
end

function dgsScrollBarSetScrollPosition(scrollbar,pos,isGrade,isAbsolute)
	assert(dgsGetType(scrollbar) == "dgs-dxscrollbar","Bad argument @dgsScrollBarSetScrollPosition at argument at 1, expect dgs-dxscrollbar got "..dgsGetType(scrollbar))
	assert(type(pos) == "number","Bad argument @dgsScrollBarSetScrollPosition at argument at 2, expect number got "..type(pos))
	if isGrade then
		local grades = dgsElementData[scrollbar].grades
		pos = pos/grades*100
	end
	local scaler = dgsElementData[scrollbar].map
	if pos < 0 then pos = 0 end
	if pos > 100 then pos = 100 end
	if not isAbsolute then
		pos = (pos-scaler[1])/(scaler[2]-scaler[1])*100
	end
	if pos < 0 then pos = 0 end
	if pos > 100 then pos = 100 end
	return dgsSetData(scrollbar,"position",pos)
end

function dgsScrollBarGetScrollPosition(scrollbar,isGrade,isAbsolute)
	assert(dgsGetType(scrollbar) == "dgs-dxscrollbar","Bad argument @dgsScrollBarGetScrollPosition at argument at 1, expect dgs-dxscrollbar got "..dgsGetType(scrollbar))
	local pos = dgsElementData[scrollbar].position
	local scaler = dgsElementData[scrollbar].map
	if not isAbsolute then
		pos = pos/100*(scaler[2]-scaler[1])+scaler[1]
	end
	if isGrade then
		local grades = dgsElementData[scrollbar].grades
		if not grades then return pos end
		pos = math.floor(pos/100*grades+0.5)
	end
	return pos
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
	if not remainMultipler then
		return dgsSetData(scrollbar,"multiplier",{1/grades,true})
	end
	return dgsSetData(scrollbar,"grades",grades)
end

function dgsScrollBarGetGrades(scrollbar)
	assert(dgsGetType(scrollbar) == "dgs-dxscrollbar","Bad argument @dgsScrollBarGetGrades at argument at 1, expect dgs-dxscrollbar got "..dgsGetType(scrollbar))
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
	local pos = dgsElementData[scrollbar].position
	local wheelReversed = dgsElementData[scrollbar].wheelReversed and -1 or 1
	local offsetPos = (rltPos and multiplier*slotRange or multiplier)/slotRange*100*(speed or 1)
	local gpos = button and pos+offsetPos*wheelReversed or pos-offsetPos*wheelReversed
	dgsSetData(scrollbar,"position",mathClamp(gpos,0,100))
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
	if isHorizontal then
		slotRange = w-(scrollArrow and (arrowWid[2] and h*arrowWid[1] or arrowWid[1]) or 0)*2
	else
		slotRange = h-(scrollArrow and (arrowWid[2] and w*arrowWid[1] or arrowWid[1]) or 0)*2
	end
	local multiplier = eleData.multiplier[2] and eleData.multiplier[1]*slotRange or eleData.multiplier[1]
	return relative and multiplier/slotRange or multiplier
end

----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxscrollbar"] = function(source,x,y,w,h,mx,my,cx,cy,enabled,eleData,parentAlpha,isPostGUI,rndtgt)
	local isHorizontal = eleData.isHorizontal
	local image = eleData.image or {}
	local arrowImage = eleData.arrowImage or image[1]
	local cursorImage = eleData.cursorImage or image[2]
	local troughImage = eleData.troughImage or image[3]
	if type(troughImage) ~= "table" then
		troughImage = {troughImage,troughImage}
	end
	local pos = eleData.position
	local length,lrlt = eleData.length[1],eleData.length[2]
	local cursorColor = eleData.cursorColor
	local arrowColor = eleData.arrowColor
	local troughColor = type(eleData.troughColor) == "table" and eleData.troughColor or {eleData.troughColor,eleData.troughColor}
	local arrowBgColor = eleData.arrowBgColor
	local tempCursorColor = {applyColorAlpha(cursorColor[1],parentAlpha),applyColorAlpha(cursorColor[2],parentAlpha),applyColorAlpha(cursorColor[3],parentAlpha)}
	local tempArrowColor = {applyColorAlpha(arrowColor[1],parentAlpha),applyColorAlpha(arrowColor[2],parentAlpha),applyColorAlpha(arrowColor[3],parentAlpha)}
	local tempArrowBgColor = {applyColorAlpha(arrowBgColor[1],parentAlpha),applyColorAlpha(arrowBgColor[2],parentAlpha),applyColorAlpha(arrowBgColor[3],parentAlpha)}
	local tempTroughColor = {applyColorAlpha(troughColor[1],parentAlpha),applyColorAlpha(troughColor[2],parentAlpha)}
	local colorImageIndex = {1,1,1,1,1}
	local slotRange
	local scrollArrow =  eleData.scrollArrow
	local cursorWidth = eleData.cursorWidth
	local troughWidth = eleData.troughWidth
	local arrowWidth = eleData.arrowWidth
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
	if MouseData.enter == source then
		local preEnterData = false
		local preEnterPos = false
		if isHorizontal then
			if my >= cy and my <= cy+h then
				if mx >= cx and mx <= cx+arrowWidth then				--Left Arrow
					if mathAbs(cy+h/2-my) <= arrowWidth then preEnterData = 1 end
				elseif mx < cx+arrowWidth+pos*0.01*csRange then			--Left Trough
					if mathAbs(cy+h/2-my) <= troughWidth then preEnterData = 2 end
				elseif mx >= cx+arrowWidth+pos*0.01*csRange and mx <= cx+arrowWidth+pos*0.01*csRange+cursorRange then
					if mathAbs(cy+h/2-my) <= cursorWidth then preEnterData = 3 end
				elseif mx < cx+w-arrowWidth then						--Right Trough
					if mathAbs(cy+h/2-my) <= troughWidth then preEnterData = 4 end
				elseif mx >= cx+w-arrowWidth and mx <= cx+w then		--Right Arrow
					if mathAbs(cy+h/2-my) <= arrowWidth then preEnterData = 5 end
				end
				preEnterPos = (mx-cx-arrowWidth)/(w-arrowWidth*2)
			end
		else
			if mx >= cx and mx <= cx+w then
				if my >= cy and my <= cy+arrowWidth then				--Up Arrow
					if mathAbs(cx+w/2-mx) <= arrowWidth then preEnterData = 1 end
				elseif my < cy+arrowWidth+pos*0.01*csRange then			--Up Trough
					if mathAbs(cx+w/2-mx) <= troughWidth then preEnterData = 2 end
				elseif my >= cy+arrowWidth+pos*0.01*csRange and my <= cy+arrowWidth+pos*0.01*csRange+cursorRange then
					if mathAbs(cx+w/2-mx) <= cursorWidth then preEnterData = 3 end
				elseif my < cy+h-arrowWidth then						--Down Trough
					if mathAbs(cx+w/2-mx) <= troughWidth then preEnterData = 4 end
				elseif my >= cy+h-arrowWidth and my <= cy+h then		--Down Arrow
					if mathAbs(cx+w/2-mx) <= arrowWidth then preEnterData = 5 end
				end
				preEnterPos = (my-cy-arrowWidth-cursorRange/2)/csRange
			end
		end
		if not MouseData.scbClickData then
			MouseData.scbEnterData = preEnterData
			scbEnterRltPos = preEnterPos
			if MouseData.scbEnterData then
				colorImageIndex[MouseData.scbEnterData] = 2
			end
		else
			if MouseData.clickl == source then
				colorImageIndex[MouseData.scbClickData] = 3
				if MouseData.scbClickData == 3 then
					local position = 0
					local mvx,mvy = MouseData.MoveScroll[1],MouseData.MoveScroll[2]
					local ax,ay = dgsGetPosition(source,false)
					if csRange ~= 0 then
						if isHorizontal then
							local gx = (mx-mvx-ax)/csRange
							position = (gx < 0 and 0) or (gx > 1 and 1) or gx
						else
							local gy = (my-mvy-ay)/csRange
							position = (gy < 0 and 0) or (gy > 1 and 1) or gy
						end
					end
					dgsSetData(source,"position",position*100)
				end
			else
				colorImageIndex[MouseData.scbClickData] = 2
			end
		end
	end
	if isHorizontal then
		local cursorCenter = pos*0.01*csRange+cursorRange/2
		local troughPart1 = {x+arrowWidth,cursorCenter}
		local troughPart2 = {x+arrowWidth+cursorCenter,w-2*arrowWidth-cursorCenter}
		local imgRotVert = imgRot[2]
		local __ = troughImage[1] and dxDrawImage(troughPart1[1],y+troughPadding,troughPart1[2],troughWidth,troughImage[1],imgRotVert[3],0,0,tempTroughColor[1],isPostGUI) or dxDrawRectangle(troughPart1[1],y+troughPadding,troughPart1[2],troughWidth,tempTroughColor[1],isPostGUI)
		local __ = troughImage[2] and dxDrawImage(troughPart2[1],y+troughPadding,troughPart2[2],troughWidth,troughImage[2],imgRotVert[3],0,0,tempTroughColor[2],isPostGUI) or dxDrawRectangle(troughPart2[1],y+troughPadding,troughPart2[2],troughWidth,tempTroughColor[2],isPostGUI)
		if scrollArrow then
			if tempArrowBgColor then
				dxDrawRectangle(x,y+arrowPadding,arrowWidth,arrowWidth,tempArrowBgColor[colorImageIndex[1]],isPostGUI)
				dxDrawRectangle(x+w-arrowWidth,y+arrowPadding,arrowWidth,arrowWidth,tempArrowBgColor[colorImageIndex[5]],isPostGUI)
			end
			dxDrawImage(x,y+arrowPadding,arrowWidth,arrowWidth,arrowImage,imgRotVert[1],0,0,tempArrowColor[colorImageIndex[1]],isPostGUI)
			dxDrawImage(x+w-arrowWidth,y+arrowPadding,arrowWidth,arrowWidth,arrowImage,imgRotVert[1]+180,0,0,tempArrowColor[colorImageIndex[5]],isPostGUI)
		end
		if cursorImage then
			dxDrawImage(x+arrowWidth+pos*0.01*csRange,y+cursorPadding,cursorRange,cursorWidth,cursorImage,imgRotVert[2],0,0,tempCursorColor[colorImageIndex[3]],isPostGUI)
		else
			dxDrawRectangle(x+arrowWidth+pos*0.01*csRange,y+cursorPadding,cursorRange,cursorWidth,tempCursorColor[colorImageIndex[3]],isPostGUI)
		end
	else
		local cursorCenter = pos*0.01*csRange+cursorRange/2
		local troughPart1 = {y+arrowWidth,cursorCenter}
		local troughPart2 = {y+arrowWidth+cursorCenter,h-2*arrowWidth-cursorCenter}
		local imgRotHorz = imgRot[1]
		local __ = troughImage[1] and dxDrawImage(x+troughPadding,troughPart1[1],troughWidth,troughPart1[2],troughImage[1],imgRotHorz[3],0,0,tempTroughColor[1],isPostGUI) or dxDrawRectangle(x+troughPadding,troughPart1[1],troughWidth,troughPart1[2],tempTroughColor[1],isPostGUI)
		local __ = troughImage[2] and dxDrawImage(x+troughPadding,troughPart2[1],troughWidth,troughPart2[2],troughImage[2],imgRotHorz[3],0,0,tempTroughColor[2],isPostGUI) or dxDrawRectangle(x+troughPadding,troughPart2[1],troughWidth,troughPart2[2],tempTroughColor[2],isPostGUI)
		if scrollArrow then
			if tempArrowBgColor then
				dxDrawRectangle(x+arrowPadding,y,arrowWidth,arrowWidth,tempArrowBgColor[colorImageIndex[1]],isPostGUI)
				dxDrawRectangle(x+arrowPadding,y+h-arrowWidth,arrowWidth,arrowWidth,tempArrowBgColor[colorImageIndex[5]],isPostGUI)
			end
			dxDrawImage(x+arrowPadding,y,arrowWidth,arrowWidth,arrowImage,imgRotHorz[1],0,0,tempArrowColor[colorImageIndex[1]],isPostGUI)
			dxDrawImage(x+arrowPadding,y+h-arrowWidth,arrowWidth,arrowWidth,arrowImage,imgRotHorz[1]+180,0,0,tempArrowColor[colorImageIndex[5]],isPostGUI)
		end
		if cursorImage then
			dxDrawImage(x+cursorPadding,y+arrowWidth+pos*0.01*csRange,cursorWidth,cursorRange,cursorImage,imgRotHorz[2],0,0,tempCursorColor[colorImageIndex[3]],isPostGUI)
		else
			dxDrawRectangle(x+cursorPadding,y+arrowWidth+pos*0.01*csRange,cursorWidth,cursorRange,tempCursorColor[colorImageIndex[3]],isPostGUI)
		end
	end
	if enabled[1] and mx then
		if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
			MouseData.hit = source
		end
	end
	return rndtgt
end
----------------------------------------------------------------
-------------------------OOP Class------------------------------
----------------------------------------------------------------
dgsOOP["dgs-dxscrollbar"] = [[
	setScrollPosition = dgsOOP.genOOPFnc("dgsScrollBarSetScrollPosition",true),
	getScrollPosition = dgsOOP.genOOPFnc("dgsScrollBarGetScrollPosition"),
	setCursorLength = dgsOOP.genOOPFnc("dgsScrollBarSetCursorLength",true),
	getCursorLength = dgsOOP.genOOPFnc("dgsScrollBarGetCursorLength"),
	setLocked = dgsOOP.genOOPFnc("dgsScrollBarSetLocked",true),
	getLocked = dgsOOP.genOOPFnc("dgsScrollBarGetLocked"),
	setGrades = dgsOOP.genOOPFnc("dgsScrollBarSetGrades",true),
	getGrades = dgsOOP.genOOPFnc("dgsScrollBarGetGrades"),
]]