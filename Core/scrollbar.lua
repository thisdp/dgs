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
local assert = assert
local type = type

function dgsCreateScrollBar(x,y,sx,sy,isHorizontal,relative,parent,arrowImage,troughImage,cursorImage,arrowColorNormal,troughColor,cursorColorNormal,arrowColorHover,cursorColorHover,arrowColorClick,cursorColorClick)
	local xCheck,yCheck,wCheck,hCheck = type (x) == "number",type(y) == "number",type(sx) == "number",type(sy) == "number"
	if not xCheck then assert(false,"Bad argument @dgsCreateScrollBar at argument 1, expect number got "..type(x)) end
	if not yCheck then assert(false,"Bad argument @dgsCreateScrollBar at argument 2, expect number got "..type(y)) end
	if not wCheck then assert(false,"Bad argument @dgsCreateScrollBar at argument 3, expect number got "..type(sx)) end
	if not hCheck then assert(false,"Bad argument @dgsCreateScrollBar at argument 4, expect number got "..type(sy)) end
	local isHorizontal = isHorizontal or false
	local scrollbar = createElement("dgs-dxscrollbar")
	dgsSetType(scrollbar,"dgs-dxscrollbar")
	dgsSetParent(scrollbar,parent,true,true)
	local style = styleSettings.scrollbar
	local deprecatedImage = style.image or {}
	local arrowImage = arrowImage or dgsCreateTextureFromStyle(style.arrowImage) or dgsCreateTextureFromStyle(deprecatedImage[1])
	local cursorImage = cursorImage or dgsCreateTextureFromStyle(style.cursorImage) or dgsCreateTextureFromStyle(deprecatedImage[2])
	if not troughImage then
		troughImage = isHorizontal and style.troughImageHorizontal or style.troughImage
		if troughImage and type(troughImage) == "table" then
			if type(troughImage[1]) == "table" then
				troughImage = {dgsCreateTextureFromStyle(troughImage[1]),dgsCreateTextureFromStyle(troughImage[2])}
			else
				troughImage = dgsCreateTextureFromStyle(troughImage)
			end
		end
	end
	dgsElementData[scrollbar] = {
		renderBuffer = {},
		arrowBgColor = style.arrowBgColor or false,
		arrowColor = {arrowColorNormal or style.arrowColor[1],arrowColorHover or style.arrowColor[2],arrowColorClick or style.arrowColor[3]},
		arrowImage = arrowImage,
		arrowWidth = style.arrowWidth or style.cursorWidth or {1,true},
		currentGrade = 0,
		cursorColor = {cursorColorNormal or style.cursorColor[1],cursorColorHover or style.cursorColor[2],cursorColorClick or style.cursorColor[3]},
		cursorImage = cursorImage,
		cursorWidth = style.cursorWidth or {1,true},
		grades = false,
		imageRotation = style.imageRotation,
		isHorizontal = isHorizontal; --vertical or horizonta,
		length = {30,false},
		locked = false,
		map = {0,100},
		minLength = 5,
		multiplier = {1,false},
		position = 0,
		scrollArrow = style.scrollArrow,
		troughColor = troughColor or style.troughColor,
		troughImage = troughImage,
		troughClickAction = "none",
		troughWidth = style.troughWidth or style.cursorWidth or {1,true},
		wheelReversed = false,
	}
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
	dgsSetData(scrollbar,"moveType","fast")
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
		dgsSetData(scrollbar,"multiplier",{1/grades,true})
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

function dgsScrollBarSetCursorLength(scrollbar,length,relative)
	assert(dgsGetType(scrollbar) == "dgs-dxscrollbar","Bad argument @dgsScrollBarSetCursorLength at argument at 1, expect dgs-dxscrollbar got "..dgsGetType(scrollbar))
	assert(tonumber(length),"Bad argument @dgsScrollBarSetCursorLength at argument at 2, expect dgs-dxscrollbar got "..dgsGetType(length))
	return dgsSetData(scrollbar,"length",{tonumber(length),relative or false})
end

function dgsScrollBarGetCursorLength(scrollbar,relative)
	assert(dgsGetType(scrollbar) == "dgs-dxscrollbar","Bad argument @dgsScrollBarGetCursorLength at argument at 1, expect dgs-dxscrollbar got "..dgsGetType(scrollbar))
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
	assert(dgsGetType(scrollbar) == "dgs-dxscrollbar","Bad argument @dgsScrollBarSetCursorWidth at argument at 1, expect dgs-dxscrollbar got "..dgsGetType(scrollbar))
	assert(tonumber(width),"Bad argument @dgsScrollBarSetCursorWidth at argument at 2, expect dgs-dxscrollbar got "..dgsGetType(width))
	return dgsSetData(scrollbar,"cursorWidth",{width,relative or false})
end

function dgsScrollBarGetCursorWidth(scrollbar,relative)
	assert(dgsGetType(scrollbar) == "dgs-dxscrollbar","Bad argument @dgsScrollBarGetCursorWidth at argument at 1, expect dgs-dxscrollbar got "..dgsGetType(scrollbar))
	assert(tonumber(width),"Bad argument @dgsScrollBarGetCursorWidth at argument at 2, expect dgs-dxscrollbar got "..dgsGetType(width))
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
	assert(dgsGetType(scrollbar) == "dgs-dxscrollbar","Bad argument @dgsScrollBarSetTroughWidth at argument at 1, expect dgs-dxscrollbar got "..dgsGetType(scrollbar))
	assert(tonumber(width),"Bad argument @dgsScrollBarSetTroughWidth at argument at 2, expect dgs-dxscrollbar got "..dgsGetType(width))
	return dgsSetData(scrollbar,"troughWidth",{width,relative or false})
end

function dgsScrollBarGetTroughWidth(scrollbar,relative)
	assert(dgsGetType(scrollbar) == "dgs-dxscrollbar","Bad argument @dgsScrollBarGetTroughWidth at argument at 1, expect dgs-dxscrollbar got "..dgsGetType(scrollbar))
	assert(tonumber(width),"Bad argument @dgsScrollBarGetTroughWidth at argument at 2, expect dgs-dxscrollbar got "..dgsGetType(width))
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
	assert(dgsGetType(scrollbar) == "dgs-dxscrollbar","Bad argument @dgsScrollBarSetArrowSize at argument at 1, expect dgs-dxscrollbar got "..dgsGetType(scrollbar))
	assert(tonumber(size),"Bad argument @dgsScrollBarSetArrowSize at argument at 2, expect dgs-dxscrollbar got "..dgsGetType(size))
	return dgsSetData(scrollbar,"arrowWidth",{size,relative or false})
end

function dgsScrollBarGetArrowSize(scrollbar,relative)
	assert(dgsGetType(scrollbar) == "dgs-dxscrollbar","Bad argument @dgsScrollBarGetArrowSize at argument at 1, expect dgs-dxscrollbar got "..dgsGetType(scrollbar))
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
	assert(dgsGetType(scrollbar) == "dgs-dxscrollbar","Bad argument @dgsScrollBarSetTroughClickAction at argument at 1, expect dgs-dxscrollbar got "..dgsGetType(scrollbar))
	assert(allowedClickAction[action],"Bad argument @dgsScrollBarSetTroughClickAction at argument at 2, expect a string (none/step/jump) got "..tostring(action))
	return dgsSetData(scrollbar,"troughClickAction",action)
end

function dgsScrollBarGetTroughClickAction(scb)
	assert(dgsGetType(scrollbar) == "dgs-dxscrollbar","Bad argument @dgsScrollBarGetTroughClickAction at argument at 1, expect dgs-dxscrollbar got "..dgsGetType(scrollbar))
	return dgsElementData[scrollbar].troughClickAction or "none"
end


--[[
function dgsScrollBarSetCursorWidth(scrollbar,width,relative)
	assert(dgsGetType(scrollbar) == "dgs-dxscrollbar","Bad argument @dgsScrollBarSetCursorWidth at argument at 1, expect dgs-dxscrollbar got "..dgsGetType(scrollbar))

	return relative and multiplier/slotRange or multiplier
end

function dgsScrollBarGetCursorWidth(scrollbar,width,relative)
	assert(dgsGetType(scrollbar) == "dgs-dxscrollbar","Bad argument @dgsScrollBarSetCursorWidth at argument at 1, expect dgs-dxscrollbar got "..dgsGetType(scrollbar))

	return relative and multiplier/slotRange or multiplier
end
]]
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
					dgsSetData(source,"moveType","fast")
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
		local __ = troughImage[1] and dxDrawImage(troughPart1[1],y+troughPadding,troughPart1[2],troughWidth,troughImage[1],imgRotVert[3],0,0,tempTroughColor[1],isPostGUI) or dxDrawRectangle(troughPart1[1],y+troughPadding,troughPart1[2],troughWidth,tempTroughColor[1],isPostGUI,rndtgt)
		local __ = troughImage[2] and dxDrawImage(troughPart2[1],y+troughPadding,troughPart2[2],troughWidth,troughImage[2],imgRotVert[3],0,0,tempTroughColor[2],isPostGUI) or dxDrawRectangle(troughPart2[1],y+troughPadding,troughPart2[2],troughWidth,tempTroughColor[2],isPostGUI,rndtgt)
		if scrollArrow then
			if tempArrowBgColor then
				dxDrawRectangle(x,y+arrowPadding,arrowWidth,arrowWidth,tempArrowBgColor[colorImageIndex[1]],isPostGUI)
				dxDrawRectangle(x+w-arrowWidth,y+arrowPadding,arrowWidth,arrowWidth,tempArrowBgColor[colorImageIndex[5]],isPostGUI)
			end
			dxDrawImage(x,y+arrowPadding,arrowWidth,arrowWidth,arrowImage,imgRotVert[1],0,0,tempArrowColor[colorImageIndex[1]],isPostGUI,rndtgt)
			dxDrawImage(x+w-arrowWidth,y+arrowPadding,arrowWidth,arrowWidth,arrowImage,imgRotVert[1]+180,0,0,tempArrowColor[colorImageIndex[5]],isPostGUI,rndtgt)
		end
		if cursorImage then
			dxDrawImage(x+arrowWidth+pos*0.01*csRange,y+cursorPadding,cursorRange,cursorWidth,cursorImage,imgRotVert[2],0,0,tempCursorColor[colorImageIndex[3]],isPostGUI,rndtgt)
		else
			dxDrawRectangle(x+arrowWidth+pos*0.01*csRange,y+cursorPadding,cursorRange,cursorWidth,tempCursorColor[colorImageIndex[3]],isPostGUI)
		end
	else
		local cursorCenter = pos*0.01*csRange+cursorRange/2
		local troughPart1 = {y+arrowWidth,cursorCenter}
		local troughPart2 = {y+arrowWidth+cursorCenter,h-2*arrowWidth-cursorCenter}
		local imgRotHorz = imgRot[1]
		local __ = troughImage[1] and dxDrawImage(x+troughPadding,troughPart1[1],troughWidth,troughPart1[2],troughImage[1],imgRotHorz[3],0,0,tempTroughColor[1],isPostGUI) or dxDrawRectangle(x+troughPadding,troughPart1[1],troughWidth,troughPart1[2],tempTroughColor[1],isPostGUI,rndtgt)
		local __ = troughImage[2] and dxDrawImage(x+troughPadding,troughPart2[1],troughWidth,troughPart2[2],troughImage[2],imgRotHorz[3],0,0,tempTroughColor[2],isPostGUI) or dxDrawRectangle(x+troughPadding,troughPart2[1],troughWidth,troughPart2[2],tempTroughColor[2],isPostGUI,rndtgt)
		if scrollArrow then
			if tempArrowBgColor then
				dxDrawRectangle(x+arrowPadding,y,arrowWidth,arrowWidth,tempArrowBgColor[colorImageIndex[1]],isPostGUI)
				dxDrawRectangle(x+arrowPadding,y+h-arrowWidth,arrowWidth,arrowWidth,tempArrowBgColor[colorImageIndex[5]],isPostGUI)
			end
			dxDrawImage(x+arrowPadding,y,arrowWidth,arrowWidth,arrowImage,imgRotHorz[1],0,0,tempArrowColor[colorImageIndex[1]],isPostGUI,rndtgt)
			dxDrawImage(x+arrowPadding,y+h-arrowWidth,arrowWidth,arrowWidth,arrowImage,imgRotHorz[1]+180,0,0,tempArrowColor[colorImageIndex[5]],isPostGUI,rndtgt)
		end
		if cursorImage then
			dxDrawImage(x+cursorPadding,y+arrowWidth+pos*0.01*csRange,cursorWidth,cursorRange,cursorImage,imgRotHorz[2],0,0,tempCursorColor[colorImageIndex[3]],isPostGUI,rndtgt)
		else
			dxDrawRectangle(x+cursorPadding,y+arrowWidth+pos*0.01*csRange,cursorWidth,cursorRange,tempCursorColor[colorImageIndex[3]],isPostGUI)
		end
	end
	return rndtgt
end