dgsLogLuaMemory()
dgsRegisterType("dgs-dxscrollpane","dgsBasic","dgsType2D")
dgsRegisterProperties("dgs-dxscrollpane",{
	bgColor = 			{	PArg.Color	},
	bgImage = 			{	PArg.Material+PArg.Nil	},
	moveHardness = 		{	{ PArg.Number, PArg.Number }	},
	basePointOffset = 	{	{ PArg.Number, PArg.Number, PArg.Bool }	},
	minViewSize = 		{	{ PArg.Number, PArg.Number, PArg.Bool }	},
	scrollBarThick = 	{	PArg.Number	},
	scrollBarState = 	{	{ PArg.Bool+PArg.Nil, PArg.Bool+PArg.Nil }	},
	scrollBarLength = 	{	{ { PArg.Number, PArg.Bool }, { PArg.Number, PArg.Bool } }, { PArg.Nil, PArg.Nil }	},
})
--Dx Functions
local dxDrawImage = dxDrawImage
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
local mathAbs = math.abs
local mathCeil = math.ceil
local mathMin = math.min
local mathMax = math.max

function dgsCreateScrollPane(...)
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
	else
		x,y,w,h,relative,parent = ...
	end
	if not(type(x) == "number") then error(dgsGenAsrt(x,"dgsCreateScrollPane",1,"number")) end
	if not(type(y) == "number") then error(dgsGenAsrt(y,"dgsCreateScrollPane",2,"number")) end
	if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsCreateScrollPane",3,"number")) end
	if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsCreateScrollPane",4,"number")) end
	local scrollpane = createElement("dgs-dxscrollpane")
	dgsSetType(scrollpane,"dgs-dxscrollpane")
	
	local res = sRes ~= resource and sRes or "global"
	local style = styleManager.styles[res]
	local using = style.using
	style = style.loaded[using]
	
	style = style.scrollpane
	local scbThick = style.scrollBarThick
	dgsElementData[scrollpane] = {
		renderBuffer = {},
		scrollBarThick = scbThick,
		scrollBarAlignment = {"right","bottom"},
		scrollBarState = {nil,nil}, --true: force on; false: force off; nil: auto
		scrollBarLength = {},
		maxChildSize = {0,0},
		horizontalMoveOffset = 0,
		verticalMoveOffset = 0,
		horizontalMoveOffsetRelative = 0,
		verticalMoveOffsetRelative = 0,
		moveHardness = {0.1,0.9},
		basePointOffset = {0,0,true},
		padding = {0,0,true},
		minViewSize = {0,0,true},
		--childSizeRef = {{},{}}, --Horizontal,Vertical //to optimize
		configNextFrame = false,
		bgColor = false,
		bgImage = false,
		sourceTexture = false,
	}
	dgsSetParent(scrollpane,parent,true,true)
	calculateGuiPositionSize(scrollpane,x,y,relative or false,w,h,relative or false,true)
	local sx,sy = dgsElementData[scrollpane].absSize[1],dgsElementData[scrollpane].absSize[2]
	local x,y = dgsElementData[scrollpane].absPos[1],dgsElementData[scrollpane].absPos[2]
	local titleOffset = 0
	if isElement(parent) then
		if not dgsElementData[scrollpane].ignoreParentTitle and not dgsElementData[parent].ignoreTitle then
			titleOffset = dgsElementData[parent].titleHeight or 0
		end
	end
	local scrollbar1 = dgsCreateScrollBar(x+sx-scbThick,y-titleOffset,scbThick,sy-scbThick,false,false,parent)
	local scrollbar2 = dgsCreateScrollBar(x,y+sy-scbThick-titleOffset,sx-scbThick,scbThick,true,false,parent)
	dgsAttachToAutoDestroy(scrollbar1,scrollpane,-2)
	dgsAttachToAutoDestroy(scrollbar2,scrollpane,-3)
	dgsSetVisible(scrollbar1,false)
	dgsSetVisible(scrollbar2,false)
	dgsSetData(scrollpane,"scrollSize",60)	--60 pixels
	dgsSetData(scrollpane,"scrollbars",{scrollbar1,scrollbar2})
	dgsSetData(scrollbar1,"attachedToParent",scrollpane)
	dgsSetData(scrollbar2,"attachedToParent",scrollpane)
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
	dgsAddEventHandler("onDgsElementScroll",scrollbar1,"checkScrollPaneScrollBar",false)
	dgsAddEventHandler("onDgsElementScroll",scrollbar2,"checkScrollPaneScrollBar",false)
	onDGSElementCreate(scrollpane,sRes)
	dgsScrollPaneRecreateRenderTarget(scrollpane,true)
	return scrollpane
end

function dgsScrollPaneRecreateRenderTarget(scrollpane,lateAlloc)
	local eleData = dgsElementData[scrollpane]
	if isElement(eleData.mainRT) then destroyElement(eleData.mainRT) end
	if lateAlloc then
		dgsSetData(scrollpane,"retrieveRT",true)
	else
		local absSize = eleData.absSize
		local scrollbar = eleData.scrollbars
		local scbThick = eleData.scrollBarThick
		local scbThickV,scbThickH = dgsElementData[scrollbar[1]].visible and scbThick or 0,dgsElementData[scrollbar[2]].visible and scbThick or 0
		local mainRT,err = dgsCreateRenderTarget(absSize[1]-scbThickV,absSize[2]-scbThickH,true,scrollpane)
		if mainRT ~= false then
			dgsAttachToAutoDestroy(mainRT,scrollpane,-1)
		else
			outputDebugString(err,2)
		end
		dgsSetData(scrollpane,"mainRT",mainRT)
		dgsSetData(scrollpane,"retrieveRT",nil)
	end
end

function checkScrollPaneScrollBar(scb,new,old)
	local parent = dgsElementData[source].attachedToParent
	if dgsGetType(parent) == "dgs-dxscrollpane" then
		local scrollbars = dgsElementData[parent].scrollbars
		if source == scrollbars[1] or source == scrollbars[2] then
			dgsTriggerEvent("onDgsElementScroll",parent,source,new,old)
		end
	end
end

addEventHandler("onDgsCreate",root,function()
	local parent = dgsGetParent(source)
	if isElement(parent) and dgsGetType(parent) == "dgs-dxscrollpane" then
		local eleData = dgsElementData[source]
		local relativePos,relativeSize = eleData.relative[1],eleData.relative[2]
		local x,y,sx,sy
		if relativePos then
			x,y = eleData.rltPos[1],eleData.rltPos[2]
		end
		if relativeSize then
			sx,sy = eleData.rltSize[1],eleData.rltSize[2]
		end
		calculateGuiPositionSize(source,x,y,relativePos or _,sx,sy,relativeSize or _)
		resizeScrollPane(parent,source)
	end
end)

addEventHandler("onDgsDestroy",root,function()
	local parent = dgsGetParent(source)
	if isElement(parent) and dgsGetType(parent) == "dgs-dxscrollpane" then
		local eleData = dgsElementData[source]
		local pos,size = eleData.absPos,eleData.absSize
		local x,y,sx,sy = pos[1],pos[2],size[1],size[2]
		local maxSize = dgsElementData[parent].maxChildSize
		local tempx,tempy = x+sx,y+sy
		local ntempx,ntempy
		if maxSize[1]-10 <= tempx then
			ntempx = 0
			for k,v in ipairs(dgsGetChildren(parent)) do
				if v ~= source then
					local pos = dgsElementData[v].absPos
					local size = dgsElementData[v].absSize
					ntempx = ntempx > pos[1]+size[1] and ntempx or pos[1]+size[1]
				end
			end
		end
		if maxSize[2]-10 <= tempy then
			ntempy = 0
			for k,v in ipairs(dgsGetChildren(parent)) do
				if v ~= source then
					local pos = dgsElementData[v].absPos
					local size = dgsElementData[v].absSize
					ntempy = ntempy > pos[2]+size[2] and ntempy or pos[2]+size[2]
				end
			end
		end
		dgsSetData(parent,"maxChildSize",{ntempx or maxSize[1],ntempy or maxSize[2]})
		dgsSetData(parent,"configNextFrame",true)
	end
end)

function configScrollPane(scrollpane)
	local eleData = dgsElementData[scrollpane]
	local scrollbar = eleData.scrollbars
	local pos,size = eleData.absPos,eleData.absSize
	local x,y,sx,sy = pos[1],pos[2],size[1],size[2]
	local scbThick = eleData.scrollBarThick
	local mViewSize = eleData.minViewSize
	local mViewSizeW = mViewSize[3] and mViewSize[1]*sx or mViewSize[1]
	local mViewSizeH = mViewSize[3] and mViewSize[2]*sy or mViewSize[2]
	local paddingX = eleData.padding[3] and eleData.padding[1]*sx or eleData.padding[1]
	local paddingY = eleData.padding[3] and eleData.padding[2]*sy or eleData.padding[2]
	local childBoundingW = math.max(eleData.maxChildSize[1],mViewSizeW)+paddingX*2
	local childBoundingH = math.max(eleData.maxChildSize[2],mViewSizeH)+paddingY*2
	local oriScbStateV,oriScbStateH = dgsElementData[scrollbar[1]].visible,dgsElementData[scrollbar[2]].visible
	local scbStateV,scbStateH
	if childBoundingW > sx then
		scbStateH = true
	elseif childBoundingW < sx-scbThick then
		scbStateH = false
	end
	if childBoundingH > sy then
		scbStateV = true
	elseif childBoundingH < sy-scbThick then
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
	--[[if scbStateH and scbStateH ~= oriScbStateH then
		dgsSetData(scrollbar[2],"scrollPosition",0)
	end
	if scbStateV and scbStateV ~= oriScbStateV then
		dgsSetData(scrollbar[1],"scrollPosition",0)
	end]]
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
	local lengthVertical = relSizY/childBoundingH
	local lengthHorizontal = relSizX/childBoundingW
	lengthVertical = lengthVertical < 1 and lengthVertical or 1
	lengthHorizontal = lengthHorizontal < 1 and lengthHorizontal or 1
	dgsSetEnabled(scrollbar[1],lengthVertical ~= 1 and true or false)	--todo
	dgsSetEnabled(scrollbar[2],lengthHorizontal  ~= 1 and true or false)

	local scbLengthVrt = eleData.scrollBarLength[1]
	local higLen = 1-(childBoundingH-relSizY)/childBoundingH
	higLen = higLen >= 0.95 and 0.95 or higLen
	length = scbLengthVrt or {higLen,true}
	dgsSetData(scrollbar[1],"length",length)
	local verticalScrollSize = eleData.scrollSize/(childBoundingH-relSizY)
	dgsSetData(scrollbar[1],"multiplier",{verticalScrollSize,true})
	dgsSetData(scrollbar[1],"moveType","sync")

	local scbLengthHoz = eleData.scrollBarLength[2]
	local widLen = 1-(childBoundingW-relSizX)/childBoundingW
	widLen = widLen >= 0.95 and 0.95 or widLen
	local length = scbLengthHoz or {widLen,true}
	dgsSetData(scrollbar[2],"length",length)
	local horizontalScrollSize = eleData.scrollSize*5/(childBoundingW-relSizX)
	dgsSetData(scrollbar[2],"multiplier",{horizontalScrollSize,true})
	dgsSetData(scrollbar[2],"moveType","sync")
	dgsSetData(scrollpane,"configNextFrame",false)
	dgsScrollPaneRecreateRenderTarget(scrollpane,true)
end

function resizeScrollPane(scrollpane,source) --Need optimize
	local abspos = dgsElementData[source].absPos
	local abssize = dgsElementData[source].absSize
	if abspos and abssize then
		local x,y,sx,sy = abspos[1],abspos[2],abssize[1],abssize[2]
		local maxSize = dgsElementData[scrollpane].maxChildSize
		local ntempx,ntempy = 0,0
		local children = dgsElementData[scrollpane].children or {}
		local childrenCnt = #children
		for k=1,#children do
			local child = children[k]
			local pos = dgsElementData[child].absPos
			local size = dgsElementData[child].absSize
			ntempx = ntempx > pos[1]+size[1] and ntempx or pos[1]+size[1]
			ntempy = ntempy > pos[2]+size[2] and ntempy or pos[2]+size[2]
		end
		dgsSetData(scrollpane,"maxChildSize",{ntempx or maxSize[1],ntempy or maxSize[2]})
	end
	dgsSetData(scrollpane,"configNextFrame",true)
end

function dgsScrollPaneGetScrollBar(scrollpane)
	if not dgsIsType(scrollpane,"dgs-dxscrollpane") then error(dgsGenAsrt(scrollpane,"dgsScrollPaneGetScrollBar",1,"dgs-dxscrollpane")) end
	return dgsElementData[scrollpane].scrollbars
end

function dgsScrollPaneSetScrollPosition(scrollpane,vertical,horizontal)
	if not dgsIsType(scrollpane,"dgs-dxscrollpane") then error(dgsGenAsrt(scrollpane,"dgsScrollPaneSetScrollPosition",1,"dgs-dxscrollpane")) end
	if vertical and not (type(vertical) == "number" and vertical>= 0 and vertical <= 100) then error(dgsGenAsrt(vertical,"dgsScrollPaneSetScrollPosition",2,"nil/number","0~100")) end
	if horizontal and not (type(horizontal) == "number" and horizontal>= 0 and horizontal <= 100) then error(dgsGenAsrt(horizontal,"dgsScrollPaneSetScrollPosition",3,"nil/number","0~100")) end
	local scb = dgsElementData[scrollpane].scrollbars
	local state1,state2 = true,true
	if vertical then
		state1 = dgsScrollBarSetScrollPosition(scb[1],vertical)
	end
	if horizontal then
		state2 = dgsScrollBarSetScrollPosition(scb[2],horizontal)
	end
	return state1 and state2
end

function dgsScrollPaneGetViewOffset(scrollpane)
	if not dgsIsType(scrollpane,"dgs-dxscrollpane") then error(dgsGenAsrt(scrollpane,"dgsScrollPaneGetViewOffset",1,"dgs-dxscrollpane")) end
	local eleData = dgsElementData[scrollpane]
	local size = eleData.absSize
	local scrollbar = eleData.scrollbars
	local scbThick = eleData.scrollBarThick
	local mViewSize = eleData.minViewSize
	local mViewSizeW = mViewSize[3] and mViewSize[1]*size[1] or mViewSize[1]
	local mViewSizeH = mViewSize[3] and mViewSize[2]*size[2] or mViewSize[2]
	local childBoundingW = math.max(eleData.maxChildSize[1],mViewSizeW)
	local childBoundingH = math.max(eleData.maxChildSize[2],mViewSizeH)
	local OffsetX = -(size[1]-childBoundingW-(dgsElementData[scrollbar[1]].visible and scbThick or 0))*dgsElementData[scrollbar[1]].scrollPosition*0.01
	local OffsetY = -(size[2]-childBoundingH-(dgsElementData[scrollbar[2]].visible and scbThick or 0))*dgsElementData[scrollbar[2]].scrollPosition*0.01
	if OffsetX < 0 then
		OffsetX = 0
	end
	if OffsetY < 0 then
		OffsetY = 0
	end
	return OffsetX,OffsetY
end

function dgsScrollPaneSetViewOffset(scrollpane,x,y)
	if not dgsIsType(scrollpane,"dgs-dxscrollpane") then error(dgsGenAsrt(scrollpane,"dgsScrollPaneSetViewOffset",1,"dgs-dxscrollpane")) end
	local eleData = dgsElementData[scrollpane]
	local size = eleData.absSize
	local scrollbar = eleData.scrollbars
	local scbThick = eleData.scrollBarThick
	local mViewSize = eleData.minViewSize
	if type(x) == "number" then
		local mViewSizeW = mViewSize[3] and mViewSize[1]*size[1] or mViewSize[1]
		local childBoundingW = math.max(eleData.maxChildSize[1],mViewSizeW)
		local pos1 = x*100/(childBoundingW-size[1]-(dgsElementData[scrollbar[1]].visible and scbThick or 0))
		dgsScrollBarSetScrollPosition(scrollbar[2],mathClamp(pos1,0,100))
	end
	if type(y) == "number" then		local mViewSizeH = mViewSize[3] and mViewSize[2]*size[2] or mViewSize[2]
		local childBoundingH = math.max(eleData.maxChildSize[2],mViewSizeH)

		local pos2 = y*100/(childBoundingH-size[2]-(dgsElementData[scrollbar[2]].visible and scbThick or 0))
		dgsScrollBarSetScrollPosition(scrollbar[1],mathClamp(pos2,0,100))
	end
	return true
end

--Make compatibility for GUI
function dgsScrollPaneGetHorizontalScrollPosition(scrollpane)
	if not dgsIsType(scrollpane,"dgs-dxscrollpane") then error(dgsGenAsrt(scrollpane,"dgsScrollPaneGetHorizontalScrollPosition",1,"dgs-dxscrollpane")) end
	local scb = dgsElementData[scrollpane].scrollbars
	return dgsScrollBarGetScrollPosition(scb[2])
end

function dgsScrollPaneSetHorizontalScrollPosition(scrollpane,horizontal)
	if not dgsIsType(scrollpane,"dgs-dxscrollpane") then error(dgsGenAsrt(scrollpane,"dgsScrollPaneSetHorizontalScrollPosition",1,"dgs-dxscrollpane")) end
	if horizontal and not (type(horizontal) == "number" and horizontal>= 0 and horizontal <= 100) then error(dgsGenAsrt(horizontal,"dgsScrollPaneSetHorizontalScrollPosition",3,"nil/number","0~100")) end
	local scb = dgsElementData[scrollpane].scrollbars
	return dgsScrollBarSetScrollPosition(scb[2],horizontal)
end

function dgsScrollPaneGetVerticalScrollPosition(scrollpane)
	if not dgsIsType(scrollpane,"dgs-dxscrollpane") then error(dgsGenAsrt(scrollpane,"dgsScrollPaneGetVerticalScrollPosition",1,"dgs-dxscrollpane")) end
	local scb = dgsElementData[scrollpane].scrollbars
	return dgsScrollBarGetScrollPosition(scb[1])
end

function dgsScrollPaneSetVerticalScrollPosition(scrollpane,vertical)
	if not dgsIsType(scrollpane,"dgs-dxscrollpane") then error(dgsGenAsrt(scrollpane,"dgsScrollPaneSetVerticalScrollPosition",1,"dgs-dxscrollpane")) end
	if vertical and not (type(vertical) == "number" and vertical>= 0 and vertical <= 100) then error(dgsGenAsrt(vertical,"dgsScrollPaneSetVerticalScrollPosition",2,"nil/number","0~100")) end
	local scb = dgsElementData[scrollpane].scrollbars
	return dgsScrollBarSetScrollPosition(scb[1],vertical)
end

function dgsScrollPaneGetScrollPosition(scrollpane)
	if not dgsIsType(scrollpane,"dgs-dxscrollpane") then error(dgsGenAsrt(scrollpane,"dgsScrollPaneGetScrollPosition",1,"dgs-dxscrollpane")) end
	local scb = dgsElementData[scrollpane].scrollbars
	return dgsScrollBarGetScrollPosition(scb[1]),dgsScrollBarGetScrollPosition(scb[2])
end

function dgsScrollPaneSetScrollBarState(scrollpane,vertical,horizontal)
	if not dgsIsType(scrollpane,"dgs-dxscrollpane") then error(dgsGenAsrt(scrollpane,"dgsScrollPaneSetScrollBarState",1,"dgs-dxscrollpane")) end
	dgsSetData(scrollpane,"scrollBarState",{vertical,horizontal},true)
	dgsSetData(scrollpane,"configNextFrame",true)
	return true
end

function dgsScrollPaneGetScrollBarState(scrollpane)
	if not dgsIsType(scrollpane,"dgs-dxscrollpane") then error(dgsGenAsrt(scrollpane,"dgsScrollPaneSetScrollBarState",1,"dgs-dxscrollpane")) end
	return dgsElementData[scrollpane].scrollBarState[1],dgsElementData[scrollpane].scrollBarState[2]
end

----------------------------------------------------------------
-----------------------PropertyListener-------------------------
----------------------------------------------------------------
dgsOnPropertyChange["dgs-dxscrollpane"] = {
	scrollBarThick = configScrollPane,
	scrollBarState = configScrollPane,
	scrollBarOffset = configScrollPane,
	scrollBarLength = configScrollPane,
	ignoreParentTitle = function(dgsEle,key,value,oldValue)
		configPosSize(dgsEle,false,true)
		configScrollPane(dgsEle)
	end,
	ignoreTitle = function(dgsEle,key,value,oldValue)
		local children = dgsGetChildren(dgsEle)
		for i=1,#children do
			if not dgsElementData[children[i]].ignoreParentTitle then
				configPosSize(children[i],false,true)
				configScrollPane(children[i])
			end
		end
	end,
}

----------------------------------------------------------------
-----------------------VisibilityManage-------------------------
----------------------------------------------------------------
dgsOnVisibilityChange["dgs-dxscrollpane"] = function(dgsElement,selfVisibility,inheritVisibility)
	if not selfVisibility or not inheritVisibility then
		dgsScrollPaneRecreateRenderTarget(dgsElement,true)
	end
end
----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxscrollpane"] = function(source,x,y,w,h,mx,my,cx,cy,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt,xRT,yRT,xNRT,yNRT,OffsetX,OffsetY,visible)
	if MouseData.hit == source then
		MouseData.topScrollable = source
	end
	if eleData.configNextFrame then
		configScrollPane(source)
	end
	if eleData.retrieveRT then
		dgsScrollPaneRecreateRenderTarget(source)
	end
	local bgColor = eleData.bgColor
	local scrollbar = eleData.scrollbars
	local scbThick = eleData.scrollBarThick
	local xthick = dgsElementData[scrollbar[1]].visible and scbThick or 0
	local ythick = dgsElementData[scrollbar[2]].visible and scbThick or 0
	local mViewSize = eleData.minViewSize
	local mViewSizeW = mViewSize[3] and mViewSize[1]*w or mViewSize[1]
	local mViewSizeH = mViewSize[3] and mViewSize[2]*h or mViewSize[2]
	local childBoundingW = math.max(eleData.maxChildSize[1],mViewSizeW)
	local childBoundingH = math.max(eleData.maxChildSize[2],mViewSizeH)
	local paddingX = eleData.padding[3] and eleData.padding[1]*w or eleData.padding[1]
	local paddingY = eleData.padding[3] and eleData.padding[2]*h or eleData.padding[2]
	local relSizX,relSizY = w-xthick,h-ythick
	local maxX,maxY = childBoundingW-relSizX+paddingX*2,childBoundingH-relSizY+paddingY*2
	maxX,maxY = maxX > 0 and maxX or 0,maxY > 0 and maxY or 0
	
	local _OffsetX = -maxX*dgsElementData[ scrollbar[2] ].scrollPosition*0.01
	local OffsetX = eleData.horizontalMoveOffset
	if eleData.horizontalMoveOffset ~= _OffsetX then
		local mHardness = 1
		local moveType = dgsElementData[ scrollbar[2] ].moveType
		if moveType == "slow" then
			mHardness = eleData.moveHardness[1]
		elseif moveType == "fast" then
			mHardness = eleData.moveHardness[2]
		end
		OffsetX = mathLerp(mHardness,OffsetX,_OffsetX)
		if _OffsetX-OffsetX <= 0.5 and _OffsetX-OffsetX >= -0.5 then
			OffsetX = _OffsetX
			dgsElementData[ scrollbar[2] ].moveType = "sync"
		end
		if OffsetX >= 0 then OffsetX = 0 end
		eleData.horizontalMoveOffset = OffsetX
		eleData.horizontalMoveOffsetRelative = -OffsetX/maxX
		OffsetX = OffsetX-OffsetX%1
	end
	local _OffsetY = -maxY*dgsElementData[ scrollbar[1] ].scrollPosition*0.01
	local OffsetY = eleData.verticalMoveOffset
	if eleData.verticalMoveOffset ~= _OffsetY then
		local mHardness = 1
		local moveType = dgsElementData[ scrollbar[1] ].moveType
		if moveType == "slow" then
			mHardness = eleData.moveHardness[1]
		elseif moveType == "fast" then
			mHardness = eleData.moveHardness[2]
		end
		OffsetY = mathLerp(mHardness,OffsetY,_OffsetY)
		if _OffsetY-OffsetY <= 0.5 and _OffsetY-OffsetY >= -0.5 then
			OffsetY = _OffsetY
			dgsElementData[ scrollbar[1] ].moveType = "sync"
		end
		if OffsetY >= 0 then OffsetY = 0 end
		eleData.verticalMoveOffset = OffsetY
		eleData.verticalMoveOffsetRelative = -OffsetY/maxY
		OffsetY = OffsetY-OffsetY%1
	end
	
	local basePointOffset = eleData.basePointOffset
	OffsetX = OffsetX+(basePointOffset[3] and basePointOffset[1]*w or basePointOffset[1])+paddingX
	OffsetY = OffsetY+(basePointOffset[3] and basePointOffset[2]*h or basePointOffset[2])+paddingY
	------------------------------------
	if eleData.functionRunBefore then
		local fnc = eleData.functions
		if type(fnc) == "table" then
			fnc[1](unpack(fnc[2]))
		end
	end
	------------------------------------
	local newRndTgt = eleData.mainRT
	local drawTarget
	if newRndTgt then
		local filter = eleData.filter
		drawTarget = newRndTgt
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
	end
	dxSetRenderTarget(newRndTgt,true)
	local children = eleData.children
	if not eleData.childOutsideHit then
		if MouseData.hit ~= source then
			enabledInherited = false
		end
	end
	local scrollPaneStartX = -OffsetX
	local scrollPaneStartY = -OffsetY
	local scrollPaneEndX = scrollPaneStartX+w
	local scrollPaneEndY = scrollPaneStartY+h
	for i=1, #children do
		local child = children[i]
		local childAbsPos = dgsElementData[child].absPos
		local childAbsSize = dgsElementData[child].absSize
		local childMinX, childMinY, childMaxX, childMaxY = childAbsPos[1],childAbsPos[2], childAbsPos[1] + childAbsSize[1], childAbsPos[2] + childAbsSize[2]
		if (scrollPaneEndX > childMinX) and (scrollPaneStartX < childMaxX) and (scrollPaneEndY > childMinY) and (scrollPaneStartY < childMaxY) then
			renderGUI(child,mx,my,enabledInherited,enabledSelf,newRndTgt,0,0,xNRT,yNRT,OffsetX,OffsetY,parentAlpha,visible)
		end
	end
	dxSetRenderTarget(rndtgt)
	dxSetBlendMode(rndtgt and "modulate_add" or "blend")
	if bgColor then
		bgColor = bgColor or 0xFFFFFFFF
		local color = applyColorAlpha(bgColor,parentAlpha)
		dxDrawImage(x,y,relSizX,relSizY,eleData.bgImage,0,0,0,color,isPostGUI,rndtgt)
		bgColor = applyColorAlpha(bgColor,parentAlpha)
	end
	if drawTarget then
		dxSetBlendMode(rndtgt and "modulate_add" or "add")
		dxDrawImage(x,y,relSizX,relSizY,drawTarget,0,0,0,white,isPostGUI)
	end
	return rndtgt,false,mx,my,OffsetX,OffsetY
end

----------------------------------------------------------------
-------------------------Children Renderer----------------------
----------------------------------------------------------------
dgsChildRenderer["dgs-dxscrollpane"] = false	--Disable children renderer
