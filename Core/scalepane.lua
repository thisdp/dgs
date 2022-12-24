dgsLogLuaMemory()
dgsRegisterType("dgs-dxscalepane","dgsBasic","dgsType2D")
--Dx Functions
local dxDrawImage = dxDrawImage
local dxDrawImageSection = dxDrawImageSection
local dxDrawRectangle = dxDrawRectangle
local dxSetShaderValue = dxSetShaderValue
local dxSetRenderTarget = dxSetRenderTarget
local dxSetBlendMode = dxSetBlendMode
local dgsCreateRenderTarget = dgsCreateRenderTarget
--DGS Functions
local dgsSetType = dgsSetType
local dgsGetType = dgsGetType
local dgsSetParent = dgsSetParent
local dgsSetData = dgsSetData
local applyColorAlpha = applyColorAlpha
local dgsTranslate = dgsTranslate
local dgsAttachToTranslation = dgsAttachToTranslation
local dgsAttachToAutoDestroy = dgsAttachToAutoDestroy
local calculateGuiPositionSize = calculateGuiPositionSize
local dgsCreateTextureFromStyle = dgsCreateTextureFromStyle
--Utilities
local dgsTriggerEvent = dgsTriggerEvent
local addEventHandler = addEventHandler
local createElement = createElement
local isElement = isElement
local assert = assert
local tonumber = tonumber
local tostring = tostring
local tocolor = tocolor
local type = type
local mathLerp = math.lerp
local mathClamp = math.clamp

function dgsCreateScalePane(...)
	local sRes = sourceResource or resource
	local x,y,w,h,relative,parent
	if select("#",...) == 1 and type(select(1,...)) == "table" then
		local argTable = ...
		x = argTable.x or argTable[1]
		y = argTable.y or argTable[2]
		w = argTable.width or argTable.w or argTable[3]
		h = argTable.height or argTable.h or argTable[4]
		relative = argTable.relative or argTable.rlt or argTable[5]
		parent = argTable.parent or argTable.p or argTable[6]
		resolX = argTable.resolutionX or argTable.resolX or argTable.resX or argTable[7]
		resolY = argTable.resolutionY or argTable.resolY or argTable.resY or argTable[8]
	else
		x,y,w,h,relative,parent,resolX,resolY = ...
	end
	if not(type(x) == "number") then error(dgsGenAsrt(x,"dgsCreateScalePane",1,"number")) end
	if not(type(y) == "number") then error(dgsGenAsrt(y,"dgsCreateScalePane",2,"number")) end
	if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsCreateScalePane",3,"number")) end
	if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsCreateScalePane",4,"number")) end
	local scalepane = createElement("dgs-dxscalepane")
	dgsSetType(scalepane,"dgs-dxscalepane")
	
	local res = sRes ~= resource and sRes or "global"
	local style = styleManager.styles[res]
	local using = style.using
	style = style.loaded[using]
	
	style = style.scalepane
	local scbThick = style.scrollBarThick
	dgsElementData[scalepane] = {
		renderBuffer = {},
		scrollBarThick = scbThick,
		scrollBarAlignment = {"right","bottom"},
		scrollBarState = {nil,nil}, --true: force on; false: force off; nil: auto
		scrollBarLength = {},
		horizontalMoveOffsetTemp = 0,
		verticalMoveOffsetTemp = 0,
		moveHardness = {0.1,0.9},
		scale = {1,1},
		scalable = true,
		scaleMultipler = 0.2,
		maxScale = {32,32},
		minScale = {0.1,0.1},
		configNextFrame = false,
		bgColor = false,
		bgImage = false,
		sourceTexture = false,
	}
	dgsSetParent(scalepane,parent,true,true)
	calculateGuiPositionSize(scalepane,x,y,relative or false,w,h,relative or false,true)
	local sx,sy = dgsElementData[scalepane].absSize[1],dgsElementData[scalepane].absSize[2]
	local x,y = dgsElementData[scalepane].absPos[1],dgsElementData[scalepane].absPos[2]
	dgsElementData[scalepane].resolution = {resolX or sx,resolY or sy}
	
	local titleOffset = 0
	if isElement(parent) then
		if not dgsElementData[scalepane].ignoreParentTitle and not dgsElementData[parent].ignoreTitle then
			titleOffset = dgsElementData[parent].titleHeight or 0
		end
	end
	local scrollbar1 = dgsCreateScrollBar(x+sx-scbThick,y-titleOffset,scbThick,sy-scbThick,false,false,parent)
	local scrollbar2 = dgsCreateScrollBar(x,y+sy-scbThick-titleOffset,sx-scbThick,scbThick,true,false,parent)
	dgsAttachToAutoDestroy(scrollbar1,scalepane,-2)
	dgsAttachToAutoDestroy(scrollbar2,scalepane,-3)
	dgsSetVisible(scrollbar1,false)
	dgsSetVisible(scrollbar2,false)
	dgsSetData(scalepane,"scrollSize",60)	--60 pixels
	dgsSetData(scalepane,"scrollbars",{scrollbar1,scrollbar2})
	dgsSetData(scrollbar1,"attachedToParent",scalepane)
	dgsSetData(scrollbar2,"attachedToParent",scalepane)
	dgsSetData(scrollbar1,"childOutsideHit",true)
	dgsSetData(scrollbar2,"childOutsideHit",true)
	dgsSetData(scrollbar1,"scrollType","Vertical")
	dgsSetData(scrollbar2,"scrollType","Horizontal")
	dgsSetData(scrollbar1,"length",{0,true})
	dgsSetData(scrollbar2,"length",{0,true})
	dgsSetData(scrollbar1,"multiplier",{1,true})
	dgsSetData(scrollbar2,"multiplier",{1,true})
	dgsSetData(scrollbar1,"minLength",10)
	dgsSetData(scrollbar2,"minLength",10)
	dgsAddEventHandler("onDgsElementScroll",scrollbar1,"checkScalePaneScrollBar",false)
	dgsAddEventHandler("onDgsElementScroll",scrollbar2,"checkScalePaneScrollBar",false)
	configScalePane(scalepane)
	onDGSElementCreate(scalepane,sRes)
	dgsScalePaneRecreateRenderTarget(scalepane,true)
	return scalepane
end

function dgsScalePaneRecreateRenderTarget(scalepane,lateAlloc)
	local eleData = dgsElementData[scalepane]
	if isElement(eleData.mainRT) then destroyElement(eleData.mainRT) end
	if lateAlloc then
		dgsSetData(scalepane,"retrieveRT",true)
	else
		local resolution = dgsElementData[scalepane].resolution
		local mainRT,err = dgsCreateRenderTarget(resolution[1],resolution[2],true,scalepane)
		if mainRT ~= false then
			dxSetTextureEdge(mainRT,"border",tocolor(0,0,0,0))
			dgsAttachToAutoDestroy(mainRT,scalepane,-1)
		else
			outputDebugString(err,2)
		end
		dgsSetData(scalepane,"mainRT",mainRT)
		dgsSetData(scalepane,"retrieveRT",nil)
	end
end

function checkScalePaneScrollBar(scb,new,old)
	local parent = dgsElementData[source].attachedToParent
	if dgsGetType(parent) == "dgs-dxscalepane" then
		local scrollbars = dgsElementData[parent].scrollbars
		if source == scrollbars[1] or source == scrollbars[2] then
			dgsTriggerEvent("onDgsElementScroll",parent,source,new,old)
		end
	end
end

function configScalePane(scalepane)
	local eleData = dgsElementData[scalepane]
	local scrollbar = eleData.scrollbars
	local pos,size = eleData.absPos,eleData.absSize
	local x,y,sx,sy = pos[1],pos[2],size[1],size[2]
	local scbThick = eleData.scrollBarThick
	local resolution = eleData.resolution
	local scale = eleData.scale
	local scaleBoundingX,scaleBoundingY = resolution[1]*scale[1],resolution[2]*scale[2]
	local oriScbStateV,oriScbStateH = dgsElementData[scrollbar[1]].visible,dgsElementData[scrollbar[2]].visible
	local scbStateV,scbStateH
	if scaleBoundingX > sx then
		scbStateH = true
	elseif scaleBoundingX < sx-scbThick then
		scbStateH = false
	end
	if scaleBoundingY > sy then
		scbStateV = true
	elseif scaleBoundingY < sy-scbThick then
		scbStateV = false
	end
	if scbStateH == nil then
		scbStateH = scbStateV
	end
	if scbStateV == nil then
		scbStateV = scbStateH
	end
	local forceState = eleData.scrollBarState
	if forceState[1] ~= nil then
		scbStateV = forceState[1]
	end
	if forceState[2] ~= nil then
		scbStateH = forceState[2]
	end
	local scbThickV,scbThickH = scbStateV and scbThick or 0,scbStateH and scbThick or 0
	local relSizX,relSizY = sx-scbThickV,sy-scbThickH

	dgsSetVisible(scrollbar[1],scbStateV and true or false)
	dgsSetVisible(scrollbar[2],scbStateH and true or false)
	dgsElementData[scrollbar[1]].ignoreParentTitle = eleData.ignoreParentTitle
	dgsElementData[scrollbar[2]].ignoreParentTitle = eleData.ignoreParentTitle
	dgsSetPosition(scrollbar[1],x+sx-scbThick,y,false)
	dgsSetPosition(scrollbar[2],x,y+sy-scbThick,false)
	dgsSetSize(scrollbar[1],scbThick,relSizY,false)
	dgsSetSize(scrollbar[2],relSizX,scbThick,false)
	local scroll1 = dgsElementData[scrollbar[1]].scrollPosition
	local scroll2 = dgsElementData[scrollbar[2]].scrollPosition
	local lengthVertical = relSizY/scaleBoundingY
	local lengthHorizontal = relSizX/scaleBoundingX
	lengthVertical = lengthVertical < 1 and lengthVertical or 1
	lengthHorizontal = lengthHorizontal < 1 and lengthHorizontal or 1
	dgsSetEnabled(scrollbar[1],lengthVertical ~= 1 and true or false)
	dgsSetEnabled(scrollbar[2],lengthHorizontal  ~= 1 and true or false)

	local scbLengthVrt = eleData.scrollBarLength[1]
	local higLen = 1-(scaleBoundingY-relSizY)/scaleBoundingY
	higLen = higLen >= 0.95 and 0.95 or higLen
	length = scbLengthVrt or {higLen,true}
	dgsSetData(scrollbar[1],"length",length)
	local verticalScrollSize = eleData.scrollSize/(scaleBoundingY-relSizY)
	dgsSetData(scrollbar[1],"multiplier",{verticalScrollSize,true})

	local scbLengthHoz = eleData.scrollBarLength[2]
	local widLen = 1-(scaleBoundingX-relSizX)/scaleBoundingX
	widLen = widLen >= 0.95 and 0.95 or widLen
	local length = scbLengthHoz or {widLen,true}
	dgsSetData(scrollbar[2],"length",length)
	local horizontalScrollSize = eleData.scrollSize*5/(scaleBoundingX-relSizX)
	dgsSetData(scrollbar[2],"multiplier",{horizontalScrollSize,true})
	dgsSetData(scalepane,"configNextFrame",false)
end

function dgsScalePaneCheckMove(scalepane)
	local eleData = dgsElementData[scalepane]
	local scrollbar = eleData.scrollbars
	local scbThick = eleData.scrollBarThick
	local x,y = dgsGetPosition(scalepane,false,true)
	local w,h = eleData.absSize[1],eleData.absSize[2]
	local xthick = dgsElementData[scrollbar[1]].visible and scbThick or 0
	local ythick = dgsElementData[scrollbar[2]].visible and scbThick or 0
	local scale = eleData.scale
	local resolution = eleData.resolution
	local relSizX,relSizY = w-xthick,h-ythick
	local mx,my = dgsGetCursorPosition()
	local xScroll = eleData.horizontalMoveOffsetTemp
	local yScroll = eleData.verticalMoveOffsetTemp
	local renderOffsetX = -(resolution[1]-relSizX/scale[1])*xScroll
	local renderOffsetY = -(resolution[2]-relSizY/scale[2])*yScroll
	local moveData = eleData.moveOffsetData
	MouseData.MoveScale[0] = true
	MouseData.MoveScale[1] = MouseData.cursorPos[1]-x	--OffsetX
	MouseData.MoveScale[2] = MouseData.cursorPos[2]-y	--OffsetY
	MouseData.MoveScale[3] = renderOffsetX		--rendering OffsetX
	MouseData.MoveScale[4] = renderOffsetY		--rendering OffsetY
end

function dgsScalePaneGetScrollBar(scalepane)
	if not dgsIsType(scalepane,"dgs-dxscalepane") then error(dgsGenAsrt(scalepane,"dgsScalePaneGetScrollBar",1,"dgs-dxscalepane")) end
	return dgsElementData[scalepane].scrollbars
end

function dgsScalePaneSetScrollPosition(scalepane,vertical,horizontal)
	if not dgsIsType(scalepane,"dgs-dxscalepane") then error(dgsGenAsrt(scalepane,"dgsScalePaneSetScrollPosition",1,"dgs-dxscalepane")) end
	if vertical and not (type(vertical) == "number" and vertical>= 0 and vertical <= 100) then error(dgsGenAsrt(vertical,"dgsScalePaneSetScrollPosition",2,"nil/number","0~100")) end
	if horizontal and not (type(horizontal) == "number" and horizontal>= 0 and horizontal <= 100) then error(dgsGenAsrt(horizontal,"dgsScalePaneSetScrollPosition",3,"nil/number","0~100")) end
	local scb = dgsElementData[scalepane].scrollbars
	local state1,state2 = true,true
	if vertical then
		state1 = dgsScrollBarSetScrollPosition(scb[1],vertical)
	end
	if horizontal then
		state2 = dgsScrollBarSetScrollPosition(scb[2],horizontal)
	end
	return state1 and state2
end

function dgsScalePaneGetViewOffset(scalepane)
	if not dgsIsType(scalepane,"dgs-dxscalepane") then error(dgsGenAsrt(scalepane,"dgsScalePaneGetViewOffset",1,"dgs-dxscalepane")) end

	return OffsetX,OffsetY
end

function dgsScalePaneSetViewOffset(scalepane,x,y)
	if not dgsIsType(scalepane,"dgs-dxscalepane") then error(dgsGenAsrt(scalepane,"dgsScalePaneSetViewOffset",1,"dgs-dxscalepane")) end

	return true
end

--Make compatibility for GUI
function dgsScalePaneGetHorizontalScrollPosition(scalepane)
	if not dgsIsType(scalepane,"dgs-dxscalepane") then error(dgsGenAsrt(scalepane,"dgsScalePaneGetHorizontalScrollPosition",1,"dgs-dxscalepane")) end
	local scb = dgsElementData[scalepane].scrollbars
	return dgsScrollBarGetScrollPosition(scb[2])
end

function dgsScalePaneSetHorizontalScrollPosition(scalepane,horizontal)
	if not dgsIsType(scalepane,"dgs-dxscalepane") then error(dgsGenAsrt(scalepane,"dgsScalePaneSetHorizontalScrollPosition",1,"dgs-dxscalepane")) end
	if horizontal and not (type(horizontal) == "number" and horizontal>= 0 and horizontal <= 100) then error(dgsGenAsrt(horizontal,"dgsScalePaneSetHorizontalScrollPosition",3,"nil/number","0~100")) end
	local scb = dgsElementData[scalepane].scrollbars
	return dgsScrollBarSetScrollPosition(scb[2],horizontal)
end

function dgsScalePaneGetVerticalScrollPosition(scalepane)
	if not dgsIsType(scalepane,"dgs-dxscalepane") then error(dgsGenAsrt(scalepane,"dgsScalePaneGetVerticalScrollPosition",1,"dgs-dxscalepane")) end
	local scb = dgsElementData[scalepane].scrollbars
	return dgsScrollBarGetScrollPosition(scb[1])
end

function dgsScalePaneSetVerticalScrollPosition(scalepane,vertical)
	if not dgsIsType(scalepane,"dgs-dxscalepane") then error(dgsGenAsrt(scalepane,"dgsScalePaneSetVerticalScrollPosition",1,"dgs-dxscalepane")) end
	if vertical and not (type(vertical) == "number" and vertical>= 0 and vertical <= 100) then error(dgsGenAsrt(vertical,"dgsScalePaneSetVerticalScrollPosition",2,"nil/number","0~100")) end
	local scb = dgsElementData[scalepane].scrollbars
	return dgsScrollBarSetScrollPosition(scb[1],vertical)
end

function dgsScalePaneGetScrollPosition(scalepane)
	if not dgsIsType(scalepane,"dgs-dxscalepane") then error(dgsGenAsrt(scalepane,"dgsScalePaneGetScrollPosition",1,"dgs-dxscalepane")) end
	local scb = dgsElementData[scalepane].scrollbars
	return dgsScrollBarGetScrollPosition(scb[1]),dgsScrollBarGetScrollPosition(scb[2])
end

function dgsScalePaneSetScrollBarState(scalepane,vertical,horizontal)
	if not dgsIsType(scalepane,"dgs-dxscalepane") then error(dgsGenAsrt(scalepane,"dgsScalePaneSetScrollBarState",1,"dgs-dxscalepane")) end
	dgsSetData(scalepane,"scrollBarState",{vertical,horizontal},true)
	dgsSetData(scalepane,"configNextFrame",true)
	return true
end

function dgsScalePaneGetScrollBarState(scalepane)
	if not dgsIsType(scalepane,"dgs-dxscalepane") then error(dgsGenAsrt(scalepane,"dgsScalePaneSetScrollBarState",1,"dgs-dxscalepane")) end
	return dgsElementData[scalepane].scrollBarState[1],dgsElementData[scalepane].scrollBarState[2]
end

----------------------------------------------------------------
-----------------------PropertyListener-------------------------
----------------------------------------------------------------
dgsOnPropertyChange["dgs-dxscalepane"] = {
	scrollBarThick = configScalePane,
	scrollBarState = configScalePane,
	scrollBarOffset = configScalePane,
	scrollBarLength = configScalePane,
	scale = configScalePane,
}

----------------------------------------------------------------
-----------------------VisibilityManage-------------------------
----------------------------------------------------------------
dgsOnVisibilityChange["dgs-dxscalepane"] = function(dgsElement,selfVisibility,inheritVisibility)
	if not selfVisibility or not inheritVisibility then
		dgsScalePaneRecreateRenderTarget(dgsElement,true)
	end
end
----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxscalepane"] = function(source,x,y,w,h,mx,my,cx,cy,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt,xRT,yRT,xNRT,yNRT)
	if MouseData.hit == source then
		MouseData.topScrollable = source
	end
	if eleData.configNextFrame then
		configScalePane(source)
	end
	if eleData.retrieveRT then
		dgsScalePaneRecreateRenderTarget(source)
	end
	local scrollbar = eleData.scrollbars
	local scbThick = eleData.scrollBarThick
	local xthick = dgsElementData[scrollbar[1]].visible and scbThick or 0
	local ythick = dgsElementData[scrollbar[2]].visible and scbThick or 0
	local scale = eleData.scale
	local resolution = eleData.resolution
	local relSizX,relSizY = w-xthick,h-ythick
	local resolX,resolY = resolution[1],resolution[2]
	
	local _xScroll = dgsElementData[scrollbar[2]].scrollPosition*0.01
	local _yScroll = dgsElementData[scrollbar[1]].scrollPosition*0.01
	local xMoveHardness = dgsElementData[ scrollbar[2] ].moveType == "slow" and eleData.moveHardness[1] or eleData.moveHardness[2]
	local yMoveHardness = dgsElementData[ scrollbar[1] ].moveType == "slow" and eleData.moveHardness[1] or eleData.moveHardness[2]
	local xScroll = mathLerp(xMoveHardness,eleData.horizontalMoveOffsetTemp,_xScroll)
	local yScroll = mathLerp(yMoveHardness,eleData.verticalMoveOffsetTemp,_yScroll)
	eleData.horizontalMoveOffsetTemp = xScroll
	eleData.verticalMoveOffsetTemp = yScroll
	OffsetX = -(resolution[1]-relSizX/scale[1])*xScroll
	OffsetY = -(resolution[2]-relSizY/scale[2])*yScroll
	------------------------------------
	if eleData.functionRunBefore then
		local fnc = eleData.functions
		if type(fnc) == "table" then
			fnc[1](unpack(fnc[2]))
		end
	end
	------------------------------------
	local newRndTgt = eleData.mainRT
	if newRndTgt then
		dxSetRenderTarget(rndtgt)
		dxSetBlendMode("add")
		local filter = eleData.filter
		local drawTarget = newRndTgt
		if filter then
			if type(filter) == "table" and isElement(filter[1]) then
				if eleData.sourceTexture ~= newRndTgt then
					dxSetShaderValue(filter[1],"sourceTexture",newRndTgt)
					eleData.sourceTexture = newRndTgt
				end
				dxSetShaderTransform(filter[1],filter[2],filter[3],filter[4],filter[5],filter[6],filter[7],filter[8],filter[9],filter[10],filter[11])
				drawTarget = filter[1]
			elseif isElement(filter) then
				if eleData.sourceTexture ~= newRndTgt then
					dxSetShaderValue(filter,"sourceTexture",newRndTgt)
					dxSetShaderValue(filter,"textureLoad",true)
					eleData.sourceTexture = newRndTgt
				end
				drawTarget = filter
			end
		else
			eleData.sourceTexture = false
		end
		dxDrawImageSection(x,y,relSizX,relSizY,-OffsetX,-OffsetY,relSizX/scale[1],relSizY/scale[2],drawTarget,0,0,0,tocolor(255,255,255,255*parentAlpha),isPostGUI)
		if MouseData.hit == source then
			mx = (mx-xNRT)/scale[1]-OffsetX+xNRT
			my = (my-yNRT)/scale[2]-OffsetY+yNRT
		end
	end
	dxSetRenderTarget(newRndTgt,true)
	
	if newRndTgt then
		local bgColor = eleData.bgColor
		if eleData.bgImage then
			bgColor = bgColor or 0xFFFFFFFF
			dxSetBlendMode("blend")
			dxDrawImage(0,0,resolution[1],resolution[2],eleData.bgImage,0,0,0,tocolor(255,255,255,255*parentAlpha))
			bgColor = applyColorAlpha(bgColor,parentAlpha)
		elseif eleData.bgColor then
			bgColor = applyColorAlpha(bgColor,parentAlpha)
			dxSetBlendMode("modulate_add")
			dxDrawRectangle(0,0,resolution[1],resolution[2],bgColor)
		end
	end
	rndtgt = newRndTgt
	return rndtgt,false,mx,my,0,0
end