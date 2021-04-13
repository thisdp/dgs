local loadstring = loadstring
focusBrowser()
------------Copyrights thisdp's DirectX Graphical User Interface System
--Speed Up
local mathAbs = math.abs
local mathFloor = math.floor
local mathCeil = math.ceil
local mathMin = math.min
local mathMax = math.max
local mathClamp = math.restrict
local mathLerp = math.lerp
local tocolor = tocolor
--Dx Functions
local dxDrawLine = dxDrawLine
local dxDrawImage = dxDrawImageExt
local dxDrawImageSection = dxDrawImageSectionExt
local dxDrawText = dxDrawText
local dxDrawRectangle = dxDrawRectangle
local dxGetPixelsSize = dxGetPixelsSize
local dxGetPixelColor = dxGetPixelColor
local dxSetRenderTarget = dxSetRenderTarget
local dxSetBlendMode = dxSetBlendMode
--
local utf8Len = utf8.len
local tableInsert = table.insert
local tableRemove = table.remove
local tableCount = table.count
local tableRemoveItemFromArray = table.removeItemFromArray
local applyColorAlpha = applyColorAlpha
local getCursorPosition = getCursorPosition
local triggerEvent = triggerEvent
local unpack = unpack
local tostring = tostring
local tonumber = tonumber
local type = type
local isElement = isElement
local _getElementID = getElementID
local getElementID = function(ele) return isElement(ele) and _getElementID(ele) or tostring(ele) end
----
fontSize = {}
self,renderArguments = false,{}
dgsRenderInfo = {
	frames = 0,
}
dgsRenderSetting = {
	postGUI = nil,
	renderPriority = "normal",
}
dgsRenderer = {}
dgs3DRenderer = {}
dgsCollider = {
	default = function(source,mx,my,x,y,w,h)
		if mx >= x and mx <= x+w and my >= y and my <= y+h then
			return source
		end
	end,
	["dgs-dxcombobox-Box"] = function(source,mx,my,x,y,w,h)
		local eleData = dgsElementData[source]
		local combo = eleData.myCombo
		local DataTab = dgsElementData[combo]
		local itemData = DataTab.itemData
		local itemDataCount = #itemData
		local itemHeight = DataTab.itemHeight
		local height = itemDataCount*itemHeight
		h = height > h and h or height
		if mx >= x and mx <= x+w and my >= y and my <= y+h then
			return source
		end
	end,
}
for i=1,#dgsType do
	dgsCollider[dgsType[i]] = dgsCollider[dgsType[i]] or dgsCollider.default
end

function dgsGetRenderSetting(name) return dgsRenderSetting[name] end

function dgsSetRenderSetting(name,value)
	if name == "renderPriority" then
		assert(type(value)=="string","Bad Argument @dgsSetRenderSetting at argument 2, expected a string got "..dgsGetType(value))
		removeEventHandler("onClientRender",root,dgsCoreRender)
		local success = addEventHandler("onClientRender",root,dgsCoreRender,false,value)
		if not success then
			addEventHandler("onClientRender",root,dgsCoreRender,false,dgsRenderSetting.renderPriority)
		end
		assert(success,"Bad Argument @dgsSetRenderSetting at argument 2, failed to set the priority")
	end
	dgsRenderSetting[name] = value
	return true
end
-----------------------------dx-GUI
MouseData = {
	focused = false,
	hit = false,
	entered = false,
	left = false,
	enteredGridList = {},
	--2D Position
	cursorPosScr = {[0]=false},
	cursorPosWld = {[0]=false},
	cursorPos = {[0]=false},
	--3D Coordinate
	cursorPos3D = {},
	clickPosition = {
		left={[0]=false,0,0},
		middle={[0]=false,0,0},
		right={[0]=false,0,0},
	},
	
	scbEnterData = false,
	scbEnterRltPos = false,
	topScrollable = false,
	lastPos = {-1,-1},
	hitData3D = {[0]=false},
	hitData2D = {[0]=false},
	lock3DInterface = false,
	cursorType = false,
	Scale = {},
	Move = {},
	MoveScale = {},
	MoveScroll = {},
	cursorColor = 0xFFFFFFFF,
	EditMemoCursor = false,
	EditMemoTimer = setTimer(function()
		local dgsType = dgsGetType(MouseData.focused)
		if dgsType == "dgs-dxedit" or dgsType == "dgs-dxmemo" then
			MouseData.EditMemoCursor = not MouseData.EditMemoCursor
		end
	end,500,0)
}

function dgsCoreRender()
	dgsRenderInfo.frames = dgsRenderInfo.frames+1
	dgsRenderInfo.frameStartScreen = getTickCount()
	dgsRenderInfo.rendering = 0
	triggerEvent("onDgsPreRender",resourceRoot)
	local bottomTableSize = #BottomFatherTable
	local centerTableSize = #CenterFatherTable
	local topTableSize = #TopFatherTable
	local dgsWorld3DTableSize = #dgsWorld3DTable
	local dgsScreen3DTableSize = #dgsScreen3DTable
	MouseData.cursorPos3D[0] = false
	local mx,my = -1000,-1000
	local cursorShowing = dgsGetCursorVisible()
	if cursorShowing then
		mx,my = dgsGetCursorPosition()
		MouseData.cursorPosScr[0],MouseData.cursorPosScr[1],MouseData.cursorPosScr[2] = true,mx,my
		MouseData.cursorPosWld[0],MouseData.cursorPosWld[1],MouseData.cursorPosWld[2] = true,mx,my
		MouseData.cursorPos3D[0],MouseData.cursorPos3D[1],MouseData.cursorPos3D[2],MouseData.cursorPos3D[3] = true,getWorldFromScreenPosition(mx,my,1)
	else
		MouseData.MoveScroll[0] = false
		MouseData.scbClickData = false
		MouseData.selectorClickData = false
		MouseData.lock3DInterface = false
		MouseData.clickl = false
		MouseData.clickr = false
		MouseData.clickm = false
		MouseData.Scale[0] = false
		MouseData.Move[0] = false
		MouseData.MoveScale[0] = false
		MouseData.cursorPosWld[0] = false
		MouseData.cursorPosScr[0] = false
	end
	if isElement(BlurBoxGlobalScreenSource) then
		dxUpdateScreenSource(BlurBoxGlobalScreenSource,true)
	end
	MouseData.cursorPos[1],MouseData.cursorPos[2] = mx,my
	MouseData.hit = false
	if bottomTableSize+centerTableSize+topTableSize+dgsWorld3DTableSize+dgsScreen3DTableSize ~= 0 then
		dxSetRenderTarget()
		MouseData.hitData3D[0] = false
		MouseData.hitData2D[0] = false
		MouseData.topScrollable = false
		local dimension = getElementDimension(localPlayer)
		local interior = getCameraInterior()
		MouseData.WithinElements = {}
		for i=1,dgsWorld3DTableSize do
			local v = dgsWorld3DTable[i]
			local eleData = dgsElementData[v]
			if (eleData.dimension == -1 or eleData.dimension == dimension) and (eleData.interior == -1 or eleData.interior == interior) then
				dxSetBlendMode(eleData.blendMode)
				renderGUI(v,mx,my,eleData.enabled,eleData.enabled,eleData.renderTarget_parent,0,0,0,0,0,0,1,eleData.visible,MouseData.clickl)
			end
		end
		dxSetBlendMode("blend")
		dxSetRenderTarget()
		for i=1,dgsScreen3DTableSize do
			local v = dgsScreen3DTable[i]
			local eleData = dgsElementData[v]
			if (eleData.dimension == -1 or eleData.dimension == dimension) and (eleData.interior == -1 or eleData.interior == interior) then
				renderGUI(v,mx,my,eleData.enabled,eleData.enabled,nil,0,0,0,0,0,0,1,eleData.visible)
			end
		end

		local hit3D = MouseData.hit
		MouseData.hit = false

		for i=1,bottomTableSize do
			local v = BottomFatherTable[i]
			local eleData = dgsElementData[v]
			renderGUI(v,mx,my,eleData.enabled,eleData.enabled,nil,0,0,0,0,0,0,1,eleData.visible)
		end
		for i=1,centerTableSize do
			local v = CenterFatherTable[i]
			local eleData = dgsElementData[v]
			local enabled = eleData.enabled
			renderGUI(v,mx,my,enabled,enabled,nil,0,0,0,0,0,0,1,eleData.visible)
		end
		for i=1,topTableSize do
			local v = TopFatherTable[i]
			local eleData = dgsElementData[v]
			renderGUI(v,mx,my,eleData.enabled,eleData.enabled,nil,0,0,0,0,0,0,1,eleData.visible)
		end
		local hit2D = MouseData.hit
		if hit2D then
			MouseData.cursorPos = dgsElementData[hit2D].cursorPosition
		elseif hit3D then
			MouseData.cursorPos = dgsElementData[hit3D].cursorPosition
		end
		MouseData.hit = hit2D or hit3D 
		dxSetRenderTarget()
		if not cursorShowing then
			MouseData.hit = false
			MouseData.Move[0] = false
			MouseData.Scale[0] = false
			MouseData.MoveScale[0] = false
			MouseData.MoveScroll[0] = false
			MouseData.scbClickData = false
			MouseData.selectorClickData = false
			MouseData.lock3DInterface = false
			MouseData.clickl = false
			MouseData.clickr = false
			MouseData.clickm = false
			MouseData.cursorPosWld[0] = false
			MouseData.cursorPosScr[0] = false
		end
		triggerEvent("onDgsRender",resourceRoot)
		MouseData.enteredGridList[1] = MouseData.enteredGridList[2]
		if KeyHolder.repeatKey then
			local tick = getTickCount()
			if tick-KeyHolder.repeatStartTick >= KeyHolder.repeatDuration then
				KeyHolder.repeatStartTick = tick
				if getKeyState(KeyHolder.lastKey) then
					onClientKeyTriggered(KeyHolder.lastKey)
				else
					KeyHolder = {}
				end
			end
		end
		if MouseHolder.repeatKey then
			local tick = getTickCount()
			if tick-MouseHolder.repeatStartTick >= MouseHolder.repeatDuration then
				MouseHolder.repeatStartTick = tick
				if getKeyState(MouseHolder.lastKey) and isElement(MouseHolder.element) then
					onClientMouseTriggered(MouseHolder.lastKey)
				else
					MouseHolder = {}
				end
			end
		end
	end
	dgsCheckHit(MouseData.hit,cursorShowing)
	----Drag Drop
	if dgsDragDropBoard[0] then
		local preview = dgsDragDropBoard.preview
		local align = dgsDragDropBoard.pewviewAlignment
		local alignHoz,alignVrt = align and align[1] or "center", align and align[2] or "center"
		local previewOffsetX,previewOffsetY = dgsDragDropBoard.previewOffsetX or 0,dgsDragDropBoard.previewOffsetY or 0
		local posX,posY = mx+previewOffsetX,my+previewOffsetY
		local previewWidth,previewHeight = dgsDragDropBoard.previewWidth or 20,dgsDragDropBoard.previewHeight or 20
		if alignHoz == "right" then
			posX = posX-previewWidth
		elseif alignHoz == "center" then
			posX = posX-previewWidth/2
		end
		if alignVrt == "bottom" then
			posY = posY-previewHeight
		elseif alignVrt == "center" then
			posY = posY-previewHeight/2
		end
		if preview then
			dxDrawImage(posX,posY,previewWidth,previewHeight,preview,0,0,0,dgsDragDropBoard.previewColor or 0xAAFFFFFF,true)
		else
			dxDrawRectangle(posX,posY,previewWidth,previewHeight,dgsDragDropBoard.previewColor or 0xAAFFFFFF,true)
		end
	end
	----Debug stuff
	dgsRenderInfo.frameEndScreen = getTickCount()
	if debugMode then
		dgsRenderInfo.frameRenderTimeScreen = dgsRenderInfo.frameEndScreen-dgsRenderInfo.frameStartScreen
		dgsRenderInfo.frameRenderTime3D = (dgsRenderInfo.frameEnd3D or getTickCount())-(dgsRenderInfo.frameStart3D or getTickCount())
		dgsRenderInfo.frameRenderTimeTotal = dgsRenderInfo.frameRenderTimeScreen+dgsRenderInfo.frameRenderTime3D
		if isElement(MouseData.hit) and debugMode >= 2 then
			local highlight = MouseData.hit
			if dgsElementType[MouseData.hit] == "dgs-dxtab" then
				highlight = dgsElementData[highlight].parent
			end
			if dgsGetType(highlight) ~= "dgs-dx3dinterface" and dgsGetType(highlight) ~= "dgs-dx3dtext" then
				local absX,absY = dgsGetPosition(highlight,false)
				local rltX,rltY = dgsGetPosition(highlight,true)
				local absW,absH = dgsGetSize(highlight,false)
				local rltW,rltH = dgsGetSize(highlight,true)
				dxDrawText("ABS X: "..absX , sW*0.5-99,11,sW,sH,black)
				dxDrawText("ABS Y: "..absY , sW*0.5-99,26,sW,sH,black)
				dxDrawText("RLT X: "..rltX , sW*0.5-99,41,sW,sH,black)
				dxDrawText("RLT Y: "..rltY , sW*0.5-99,56,sW,sH,black)
				dxDrawText("ABS W: "..absW , sW*0.5-99,71,sW,sH,black)
				dxDrawText("ABS H: "..absH , sW*0.5-99,86,sW,sH,black)
				dxDrawText("RLT W: "..rltW , sW*0.5-99,101,sW,sH,black)
				dxDrawText("RLT H: "..rltH , sW*0.5-99,116,sW,sH,black)
				dxDrawText("ABS X: "..absX , sW*0.5-100,10)
				dxDrawText("ABS Y: "..absY , sW*0.5-100,25)
				dxDrawText("RLT X: "..rltX , sW*0.5-100,40)
				dxDrawText("RLT Y: "..rltY , sW*0.5-100,55)
				dxDrawText("ABS W: "..absW , sW*0.5-100,70)
				dxDrawText("ABS H: "..absH , sW*0.5-100,85)
				dxDrawText("RLT W: "..rltW , sW*0.5-100,100)
				dxDrawText("RLT H: "..rltH , sW*0.5-100,115)

				local sideColor = tocolor(dgsHSVToRGB(getTickCount()%3600/10,100,50))
				local sideSize = math.sin(getTickCount()/500%2*math.pi)*2+4
				local hSideSize = sideSize*0.5
				local debugData = dgsElementData[highlight].debugData
				if debugData then
					local x,y,w,h = debugData[5],debugData[6],absW,absH
					dxDrawLine(x-sideSize,y-hSideSize,x+w+sideSize,y-hSideSize,sideColor,sideSize,isPostGUI)
					dxDrawLine(x-hSideSize,y,x-hSideSize,y+h,sideColor,sideSize,isPostGUI)
					dxDrawLine(x+w+hSideSize,y,x+w+hSideSize,y+h,sideColor,sideSize,isPostGUI)
					dxDrawLine(x-sideSize,y+h+hSideSize,x+w+sideSize,y+h+hSideSize,sideColor,sideSize,isPostGUI)
				end
			end
			local parent = MouseData.hit
			dxDrawText("Parent List:", sW*0.5+91,11,sW,sH,black)
			dxDrawText("Parent List:", sW*0.5+90,10)
			dxDrawText("DGS Root("..tostring(resourceRoot)..")", sW*0.5+100,26,sW,sH,black)
			dxDrawText("DGS Root("..tostring(resourceRoot)..")", sW*0.5+99,25)
			local parents = {}
			while(parent) do
				tableInsert(parents,1,parent)
				parent = dgsGetParent(parent)
			end
			for i=1,#parents do
				local p = parents[i]
				local debugStr = ""
				if debugMode == 3 then
					local debugTrace = dgsElementData[p].debugTrace
					if debugTrace then
						debugStr = debugTrace.file..":"..debugTrace.line
					else
						debugStr = "untraceable"
					end
				end
				dxDrawText("↑"..dgsGetPluginType(p).."("..tostring(p)..") "..debugStr, sW*0.5+101,26+i*15,sW,sH,black)
				dxDrawText("↑"..dgsGetPluginType(p).."("..tostring(p)..") "..debugStr, sW*0.5+100,25+i*15)
			end
		end
		local version = getElementData(resourceRoot,"Version") or "?"
		local freeMemory = " | Free VMemory: "..(dxGetStatus().VideoMemoryFreeForMTA).." MB" or "N/A"
		dxDrawText("Thisdp's Dx Lib(DGS)",6,sH*0.4-129,sW,sH,black)
		dxDrawText("Thisdp's Dx Lib(DGS)",5,sH*0.4-130)
		dxDrawText("Version: "..version..freeMemory,6,sH*0.4-114,sW,sH,black)
		dxDrawText("Version: "..version..freeMemory,5,sH*0.4-115)
		local renderTimeStr = dgsRenderInfo.frameRenderTimeTotal.."ms-"..dgsRenderInfo.frameRenderTimeScreen.."ms-"..dgsRenderInfo.frameRenderTime3D.."ms"
		dxDrawText("Render Time(All-2D-3D): "..renderTimeStr,11,sH*0.4-99,sW,sH,black)
		local tickColor
		if dgsRenderInfo.frameRenderTimeTotal <= 8 then
			tickColor = green
		elseif dgsRenderInfo.frameRenderTimeTotal <= 20 then
			tickColor = yellow
		else
			tickColor = red
		end
		dxDrawText("Render Time(All-2D-3D): "..renderTimeStr,10,sH*0.4-100,_,_,tickColor)
		local Focused = MouseData.focused and dgsGetPluginType(MouseData.focused).."("..getElementID(MouseData.focused)..")" or "None"
		local enterStr = MouseData.hit and dgsGetPluginType(MouseData.hit).." ("..getElementID(MouseData.hit)..")" or "None"
		local leftStr = MouseData.clickl and dgsGetPluginType(MouseData.clickl).." ("..getElementID(MouseData.clickl)..")" or "None"
		local rightStr = MouseData.clickr and dgsGetPluginType(MouseData.clickr).." ("..getElementID(MouseData.clickr)..")" or "None"
		dxDrawText("Focused: "..Focused,6,sH*0.4-84,sW,sH,black)
		dxDrawText("Focused: "..Focused,5,sH*0.4-85)
		dxDrawText("Enter: "..enterStr,11,sH*0.4-69,sW,sH,black)
		dxDrawText("Enter: "..enterStr,10,sH*0.4-70)
		dxDrawText("Click:",11,sH*0.4-54,sW,sH,black)
		dxDrawText("Click:",10,sH*0.4-55)
		dxDrawText("  Left: "..leftStr,11,sH*0.4-39,sW,sH,black)
		dxDrawText("  Left: "..leftStr,10,sH*0.4-40)
		dxDrawText("  Right: "..rightStr,11,sH*0.4-24,sW,sH,black)
		dxDrawText("  Right: "..rightStr,10,sH*0.4-25)
		dgsRenderInfo.created = 0
		for i=1,#dgsType do
			local value = dgsType[i]
			local elements = #getElementsByType(value)
			dgsRenderInfo.created = dgsRenderInfo.created+elements
			local x = 15
			if value == "dgs-dxtab" or value == "dgs-dxcombobox-Box" then
				x = 30
			end
			dxDrawText(value.." : "..elements,x+1,sH*0.4+15*i+6,sW,sH,black)
			dxDrawText(value.." : "..elements,x,sH*0.4+15*i+5)
		end
		dxDrawText("Rendering: "..dgsRenderInfo.rendering,11,sH*0.4-9,sW,sH,black)
		dxDrawText("Rendering: "..dgsRenderInfo.rendering,10,sH*0.4-10,sW,sH,green)
		dxDrawText("Created: "..dgsRenderInfo.created,11,sH*0.4+6,sW,sH,black)
		dxDrawText("Created: "..dgsRenderInfo.created,10,sH*0.4+5,sW,sH,yellow)
		local anim = tableCount(animGUIList)
		local move = tableCount(moveGUIList)
		local size = tableCount(sizeGUIList)
		local alp = tableCount(alphaGUIList)
		dgsRenderInfo.runningAnimation = anim+move+size+alp
		dxDrawText("Running Animation("..dgsRenderInfo.runningAnimation.."):",301,sH*0.4-114,sW,sH,black)
		dxDrawText("Running Animation("..dgsRenderInfo.runningAnimation.."):",300,sH*0.4-115)

		dxDrawText("Anim:"..anim,301,sH*0.4-99,sW,sH,black)
		dxDrawText("Anim:"..anim,300,sH*0.4-100)
		dxDrawText("Move:"..move,301,sH*0.4-84,sW,sH,black)
		dxDrawText("Move:"..move,300,sH*0.4-85)
		dxDrawText("Size:"..size,301,sH*0.4-69,sW,sH,black)
		dxDrawText("Size:"..size,300,sH*0.4-70)
		dxDrawText("Alpha:"..alp,301,sH*0.4-54,sW,sH,black)
		dxDrawText("Alpha:"..alp,300,sH*0.4-55)
		ResCount = 0
		for ka,va in pairs(boundResource) do
			if type(ka) == "userdata" and va then
				local resDGSCnt = tableCount(va)
				if resDGSCnt ~= 0 then
					ResCount = ResCount +1
					dxDrawText(getResourceName(ka).." : "..resDGSCnt,301,sH*0.4+15*(ResCount+1)+1,sW,sH,black)
					dxDrawText(getResourceName(ka).." : "..resDGSCnt,300,sH*0.4+15*(ResCount+1))
				end
			end
		end
		dxDrawText("Resource Elements("..ResCount.."):",301,sH*0.4+16,sW,sH,black)
		dxDrawText("Resource Elements("..ResCount.."):",300,sH*0.4+15)
	end
end

function renderGUI(source,mx,my,enabledInherited,enabledSelf,rndtgt,xRT,yRT,xNRT,yNRT,OffsetX,OffsetY,parentAlpha,visibleInherited,checkElement)
	local isElementInside = false
	local eleData = dgsElementData[source]
	local enabledInherited,enabledSelf = enabledInherited and eleData.enabled,eleData.enabled
	local visible = eleData.visible
	if visible and visibleInherited and isElement(source) then
		local eleType = dgsElementType[source]
		if eleType == "dgs-dxscrollbar" then
			local attachedToParent = eleData.attachedToParent
			if isElement(attachedToParent) and dgsElementData[attachedToParent] then
				if not dgsElementData[attachedToParent].visible then return end
				parentAlpha = parentAlpha*dgsElementData[attachedToParent].alpha
			end
		end
		local rndtgt = isElement(rndtgt) and rndtgt or false
		local globalBlendMode = rndtgt and "modulate_add" or "blend"
		dxSetBlendMode(globalBlendMode)
		if debugMode then dgsRenderInfo.rendering = dgsRenderInfo.rendering+1 end
		local parent,children,parentAlpha = FatherTable[source],ChildrenTable[source],(eleData.alpha or 1)*parentAlpha
		local eleTypeP,eleDataP
		if parent then
			eleTypeP,eleDataP = dgsElementType[parent],dgsElementData[parent]
		end
		dxSetRenderTarget(rndtgt)
		--Side Processing
		local PosX,PosY,w,h = 0,0,0,0
		if eleTypeP == "dgs-dxwindow" then
			PosY = (not eleDataP.ignoreTitle and not eleData.ignoreParentTitle) and PosY+(eleDataP.titleHeight or 0) or PosY
		elseif eleTypeP == "dgs-dxtab" then
			local gpEleData = dgsElementData[FatherTable[parent]]
			local gpSize = gpEleData.absSize
			local tabHeight = gpEleData.tabHeight[2] and gpEleData.tabHeight[1]*gpSize[2] or gpEleData.tabHeight[1]
			PosY = PosY+tabHeight
			w,h = gpSize[1],gpSize[2]-tabHeight
		end
		if eleType ~= "dgs-dxtab" then
			local absX,absY,absW,absH
			local absPos = eleData.absPos
			local absSize = eleData.absSize
			if not absPos then absX,absY = 0,0 else absX,absY = absPos[1],absPos[2] end
			if not absSize then absW,absH = 0,0 else absW,absH = absSize[1],absSize[2] end
			PosX,PosY = PosX+absX,PosY+absY
			w,h = absW,absH
		end
		local eleAlign = eleData.positionAlignment
		if eleAlign[1] == "right" then	--Horizontal
			local pWidth = parent and eleDataP.absSize[1] or sW
			PosX = pWidth-PosX-eleData.absSize[1]
		elseif eleAlign[1] == "center" then
			local pWidth = parent and eleDataP.absSize[1] or sW
			PosX = PosX+pWidth/2-eleData.absSize[1]/2
		end
		if eleAlign[2] == "bottom" then --Vertical
			local pHeight = parent and eleDataP.absSize[2] or sH
			PosY = pHeight-PosY-eleData.absSize[2]
		elseif eleAlign[2] == "center" then
			local pHeight = parent and eleDataP.absSize[2] or sH
			PosY = PosY+pHeight/2-eleData.absSize[2]/2
		end
		local x,y = PosX+OffsetX,PosY+OffsetY
		OffsetX,OffsetY = 0,0
		xRT,yRT,xNRT,yNRT = xRT+x,yRT+y,xNRT+x,yNRT+y
		local isPostGUI = not debugMode and (not rndtgt) and (dgsRenderSetting.postGUI == nil and eleData.postGUI) or dgsRenderSetting.postGUI
		if eleDataP and eleDataP.renderTarget_parent == rndtgt and rndtgt then xRT,yRT = x,y end
		self = source
		renderArguments[1] = xRT
		renderArguments[2] = yRT
		renderArguments[3] = w
		renderArguments[4] = h
		renderArguments[5] = xNRT
		renderArguments[6] = yNRT
		if xRT and yRT then
			------------------------------------
			if eleData.functionRunBefore then
				local fnc = eleData.functions
				if type(fnc) == "table" and fnc[1] then
					fnc[1](unpack(fnc[2]))
				end
			end
			------------------------------------
			if eleData.PixelInt then xRT,yRT,w,h = xRT-xRT%1,yRT-yRT%1,w-w%1,h-h%1 end
			------------------------------------Main Renderer
			local _mx,_my,rt,disableOutline
			local daDebugColor,daDebugTexture = 0xFFFFFF,nil
			local dgsRendererFunction = dgsRenderer[eleType]
			if dgsRendererFunction then
				local _hitElement
				if enabledInherited and mx and eleType ~= "dgs-dxdetectarea" then
					local collider = eleData.dgsCollider
					if collider and dgsElementType[collider] == "dgs-dxdetectarea" then
						local daEleData = dgsElementData[collider]
						local checkPixel = daEleData.checkFunction
						if checkPixel then
							local _mx,_my = (mx-xRT)/w,(my-yNRT)/h
							if _mx > 0 and _my > 0 and _mx <= 1 and _my <= 1 then
								if type(checkPixel) == "function" then
									local checkFnc = daEleData.checkFunction
									if checkFnc((mx-xRT)/w,(my-yNRT)/h,mx,my) then
										MouseData.hit = source
										daDebugColor = 0xFF0000
									end
								else
									local px,py = dxGetPixelsSize(checkPixel)
									local pixX,pixY = _mx*px,_my*py
									local r,g,b = dxGetPixelColor(checkPixel,pixX-1,pixY-1)
									local gray = ((r or 0)+(g or 0)+(b or 0))/3
									if gray >= 128 then
										MouseData.hit = source
										daDebugColor = 0xFF0000
									end
								end
							end
							daDebugTexture = daEleData.debugTexture
							daDebugColor = daEleData.debugModeAlpha*0x1000000+daDebugColor
						end
					else
						MouseData.hit = dgsCollider[eleType](source,mx,my,xNRT,yNRT,w,h) or MouseData.hit
					end
					if eleType == "dgs-dxgridlist" then
						_hitElement = MouseData.hit
					end
					if MouseData.hit == source then	--For grid list preselect
						MouseData.enteredGridList[2] = false
					end
				end
				rt,disableOutline,_mx,_my,offx,offy = dgsRendererFunction(source,xRT,yRT,w,h,mx,my,xNRT,yNRT,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt,xRT,yRT,xNRT,yNRT,OffsetX,OffsetY,visible)
				mx,my = _mx or mx,_my or my
				if MouseData.hit then
					if _hitElement and _hitElement ~= MouseData.hit then
						local scbThickV = dgsElementData[ eleData.scrollbars[1] ].visible and eleData.scrollBarThick or 0
						local scbThickH = dgsElementData[ eleData.scrollbars[2] ].visible and eleData.scrollBarThick or 0
						if mx > xNRT+w-scbThickH or my > yNRT+h-scbThickV then
							MouseData.hit = source
						end
					end
					MouseData.WithinElements[MouseData.hit] = true
					if MouseData.hit == source then
						eleData.cursorPosition[0] = dgsRenderInfo.frames
						eleData.cursorPosition[1],eleData.cursorPosition[2] = mx,my
					end
				end
				if debugMode then
					dgsElementData[source].debugData = {xRT,yNRT,w,h,xNRT,yNRT}
					if daDebugTexture then
						dxDrawImage(xRT,yNRT,w,h,daDebugTexture,0,0,0,daDebugColor,isPostGUI)
					end
				end
				rndtgt = rt or rndtgt
				OffsetX,OffsetY = offx or OffsetX,offy or OffsetY
			end
			------------------------------------
			if not eleData.functionRunBefore then
				local fnc = eleData.functions
				if type(fnc) == "table" then
					fnc[1](unpack(fnc[2]))
				end
			end
			------------------------------------OutLine
			if not disableOutline then
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					local hSideSize = sideSize*0.5
					sideColor = applyColorAlpha(sideColor,parentAlpha)
					local side = outlineData[1]
					if side == "in" then
						dxDrawLine(xRT,yRT+hSideSize,xRT+w,yRT+hSideSize,sideColor,sideSize,isPostGUI)
						dxDrawLine(xRT+hSideSize,yRT,xRT+hSideSize,yRT+h,sideColor,sideSize,isPostGUI)
						dxDrawLine(xRT+w-hSideSize,yRT,xRT+w-hSideSize,yRT+h,sideColor,sideSize,isPostGUI)
						dxDrawLine(xRT,yRT+h-hSideSize,xRT+w,yRT+h-hSideSize,sideColor,sideSize,isPostGUI)
					elseif side == "center" then
						dxDrawLine(xRT-hSideSize,yRT,xRT+w+hSideSize,yRT,sideColor,sideSize,isPostGUI)
						dxDrawLine(xRT,yRT+hSideSize,xRT,yRT+h-hSideSize,sideColor,sideSize,isPostGUI)
						dxDrawLine(xRT+w,yRT+hSideSize,xRT+w,yRT+h-hSideSize,sideColor,sideSize,isPostGUI)
						dxDrawLine(xRT-hSideSize,yRT+h,xRT+w+hSideSize,yRT+h,sideColor,sideSize,isPostGUI)
					elseif side == "out" then
						dxDrawLine(xRT-sideSize,yRT-hSideSize,xRT+w+sideSize,yRT-hSideSize,sideColor,sideSize,isPostGUI)
						dxDrawLine(xRT-hSideSize,yRT,xRT-hSideSize,yRT+h,sideColor,sideSize,isPostGUI)
						dxDrawLine(xRT+w+hSideSize,yRT,xRT+w+hSideSize,yRT+h,sideColor,sideSize,isPostGUI)
						dxDrawLine(xRT-sideSize,yRT+h+hSideSize,xRT+w+sideSize,yRT+h+hSideSize,sideColor,sideSize,isPostGUI)
					end
				end
			else
				visible = false
			end
			------------------------------------
		else
			visible = false
		end
		local oldMouseIn = eleData.rndTmp_mouseIn or false
		local newMouseIn = MouseData.hit and true or false
		if eleData.enableFullEnterLeaveCheck then
			if oldMouseIn ~= newMouseIn then
				eleData.rndTmp_mouseIn = newMouseIn
				triggerEvent("onDgsElement"..(newMouseIn and "Enter" or "Leave"),source)
			end
		end
		if eleData.renderEventCall then
			triggerEvent("onDgsElementRender",source,xRT,yNRT,w,h)
		end
		if not eleData.hitoutofparent then
			if MouseData.hit ~= source then
				enabledInherited = false
			end
		end
		local childrenCnt = children and #children or 0
		if childrenCnt ~= 0 then
			if eleType == "dgs-dxtabpanel" then
				for i=1,childrenCnt do
					local child = children[i]
					if dgsElementType[child] ~= "dgs-dxtab" then
						isElementInside = renderGUI(child,mx,my,enabledInherited,enabledSelf,rndtgt,xRT,yRT,xNRT,yNRT,OffsetX,OffsetY,parentAlpha,visible,checkElement) or isElementInside
					end
				end
			elseif eleType == "dgs-dxgridlist" then
				for i=1,childrenCnt do
					local child = children[i]
					if not dgsElementData[child].attachedToGridList then
						isElementInside = renderGUI(child,mx,my,enabledInherited,enabledSelf,rndtgt,xRT,yRT,xNRT,yNRT,OffsetX,OffsetY,parentAlpha,visible,checkElement) or isElementInside
					end
				end
			else
				for i=1,childrenCnt do
					isElementInside = renderGUI(children[i],mx,my,enabledInherited,enabledSelf,rndtgt,xRT,yRT,xNRT,yNRT,OffsetX,OffsetY,parentAlpha,visible,checkElement) or isElementInside
				end
			end
		end
		dxSetBlendMode("blend")
	end
	return isElementInside or source == checkElement
end
addEventHandler("onClientRender",root,dgsCoreRender,false,dgsRenderSetting.renderPriority)

function dgsCore3DRender()
	dgsRenderInfo.frameStart3D = getTickCount()
	local rendering3D = 0
	local created3D = #dgsWorld3DTable
	for i=1,created3D do
		local ele = dgsWorld3DTable[i]
		local dgsType = dgsElementType[ele]
		if dgs3DRenderer[dgsType] then
			if dgs3DRenderer[dgsType](ele) then
				rendering3D = rendering3D+1
			end
		end
	end
	dgsRenderInfo.rendering3D = rendering3D
	dgsRenderInfo.created3D = created3D
	dgsRenderInfo.frameEnd3D = getTickCount()
end
addEventHandler("onClientPreRender",root,dgsCore3DRender)

addEventHandler("onClientKey",root,function(button,state)
	if button == "mouse_wheel_up" or button == "mouse_wheel_down" then
		if isElement(MouseData.entered) then
			triggerEvent("onDgsMouseWheel",MouseData.entered,button == "mouse_wheel_down" and -1 or 1)
		end
		local scroll = button == "mouse_wheel_down" and 1 or -1
		local enteredElement = MouseData.topScrollable or MouseData.entered
		local dgsType = dgsGetType(enteredElement)
		if dgsGetType(enteredElement) == "dgs-dxscrollbar" then
			local scrollbar = enteredElement
			dgsSetData(scrollbar,"moveType","slow")
			scrollScrollBar(scrollbar,button == "mouse_wheel_down" or false)
		elseif dgsType == "dgs-dxgridlist" then
			local scrollbar
			local gridlist = enteredElement
			local scrollbar1,scrollbar2 = dgsElementData[gridlist].scrollbars[1],dgsElementData[gridlist].scrollbars[2]
			local visibleScb1,visibleScb2 = dgsGetVisible(scrollbar1),dgsGetVisible(scrollbar2)
			if visibleScb1 then
				scrollbar = scrollbar1
			elseif visibleScb2 and not visibleScb1 then
				scrollbar = scrollbar2
			end
			if scrollbar then
				dgsSetData(scrollbar,"moveType","slow")
				scrollScrollBar(scrollbar,button == "mouse_wheel_down" or false)
			end
		elseif dgsType == "dgs-dxmemo" then
			local memo = enteredElement
			local scrollbar = dgsElementData[memo].scrollbars[1]
			if dgsGetVisible(scrollbar) then
				dgsSetData(scrollbar,"moveType","slow")
				scrollScrollBar(scrollbar,button == "mouse_wheel_down" or false)
			end
		elseif dgsType == "dgs-dxscrollpane" then
			local scrollpane = enteredElement
			local eleData = dgsElementData[scrollpane]
			local scrollbar
			local scrollbar1,scrollbar2 = dgsElementData[scrollpane].scrollbars[1],dgsElementData[scrollpane].scrollbars[2]
			local visibleScb1,visibleScb2 = dgsGetVisible(scrollbar1),dgsGetVisible(scrollbar2)
			if visibleScb1 then
				scrollbar = scrollbar1
			elseif visibleScb2 and not visibleScb1 then
				scrollbar = scrollbar2
			end
			if scrollbar then
				dgsSetData(scrollbar,"moveType","slow")
				scrollScrollBar(scrollbar,button == "mouse_wheel_down" or false)
			end
		elseif dgsType == "dgs-dxscalepane" then
			local scalepane = enteredElement
			local eleData = dgsElementData[scalepane]
			if getKeyState("lalt") then
				local scale = eleData.scale
				local scaleMultipler = eleData.scaleMultipler
				local maxScale = eleData.maxScale
				local minScale = eleData.minScale
				local newScaleX,newScaleY
				if button == "mouse_wheel_down" then
					newScaleX = scale[1]-scaleMultipler*scale[1]
					newScaleY = scale[2]-scaleMultipler*scale[2]
					if newScaleX <= minScale[1] or newScaleY <= minScale[2] then
						if newScaleX <= minScale[1] then
							newScaleX = minScale[1]
							newScaleY = scale[2]/scale[1]*newScaleX
						else
							newScaleY = minScale[2]
							newScaleX = scale[1]/scale[2]*newScaleY
						end
					end
					if scale[1] > 1 and newScaleX < 1 then
						newScaleX = 1
						newScaleY = scale[2]/scale[1]*newScaleX
					elseif scale[2] > 1 and newScaleY < 1 then
						newScaleY = 1
						newScaleX = scale[1]/scale[2]*newScaleY
					end
				else
					newScaleX = scale[1]+scaleMultipler*scale[1]
					newScaleY = scale[2]+scaleMultipler*scale[2]
					if newScaleX >= maxScale[1] or newScaleY >= maxScale[2] then
						if newScaleX >= maxScale[1] then
							newScaleX = maxScale[1]
							newScaleY = scale[2]/scale[1]*newScaleX
						else
							newScaleY = maxScale[2]
							newScaleX = scale[1]/scale[2]*newScaleY
						end
					end
					if scale[1] < 1 and newScaleX > 1 then
						newScaleX = 1
						newScaleY = scale[2]/scale[1]*newScaleX
					elseif scale[2] < 1 and newScaleY > 1 then
						newScaleY = 1
						newScaleX = scale[1]/scale[2]*newScaleY
					end
				end
				dgsSetData(scalepane,"scale",{newScaleX,newScaleY})
			else
				local scrollbar
				local scrollbar1,scrollbar2 = dgsElementData[scalepane].scrollbars[1],dgsElementData[scalepane].scrollbars[2]
				local visibleScb1,visibleScb2 = dgsGetVisible(scrollbar1),dgsGetVisible(scrollbar2)
				if visibleScb1 then
					scrollbar = scrollbar1
				elseif visibleScb2 and not visibleScb1 then
					scrollbar = scrollbar2
				end
				if scrollbar then
					dgsSetData(scrollbar,"moveType","slow")
					scrollScrollBar(scrollbar,button == "mouse_wheel_down" or false)
				end
			end
		elseif dgsType == "dgs-dxtabpanel" or dgsType == "dgs-dxtab" then
			local tabpanel = enteredElement
			if dgsType == "dgs-dxtab" then
				tabpanel = dgsElementData[tabpanel].parent
			end
			local width = dgsTabPanelGetWidth(tabpanel)
			local eleData = dgsElementData[tabpanel]
			local w,h = eleData.absSize[1],eleData.absSize[2]
			if width > w then
				local mx,my = dgsGetCursorPosition()
				mx,my = (mx or -1)*sW,(my or -1)*sH
				local _,y = dgsGetPosition(tabpanel,false,true)
				local height = eleData.tabHeight[2] and eleData.tabHeight[1]*h or eleData.tabHeight[1]
				if my < y+height then
					local speed = eleData.scrollSpeed[2] and eleData.scrollSpeed[1] or eleData.scrollSpeed[1]/width
					local orgoff = eleData.showPos
					orgoff = mathClamp(orgoff+scroll*speed,0,1)
					dgsSetData(tabpanel,"showPos",orgoff)
				end
			end
		elseif dgsType == "dgs-dxcombobox-Box" then
			local comboBox = enteredElement
			local combo = dgsElementData[comboBox].myCombo
			local scrollbar = dgsElementData[combo].scrollbar
			if dgsGetVisible(scrollbar) then
				dgsSetData(scrollbar,"moveType","slow")
				scrollScrollBar(scrollbar,button == "mouse_wheel_down" or false)
			end
		elseif dgsType == "dgs-dxselector" then
			local selector = enteredElement
			if dgsElementData[selector].enableScroll and MouseData.focused == selector then
				local itemData = dgsElementData[selector].itemData
				local itemCount = #itemData
				local currentItem = dgsElementData[selector].select
				dgsSelectorSetSelectedItem(selector,mathFloor(mathClamp(currentItem+(button == "mouse_wheel_down" and -1 or 1),1,itemCount)))
			end
		end
	elseif state then
		local dgsType = dgsGetType(MouseData.focused)
		if dgsType == "dgs-dxmemo" or dgsType == "dgs-dxedit" then
			if not button:find("mouse") then
				local typingSound = dgsElementData[MouseData.focused].typingSound
				if typingSound then
					playSound(typingSound)
				end
			end
		end
	end
	onClientKeyCheck(button,state)
end)

KeyHolder = {}
function onClientKeyCheck(button,state)
	if state and button:sub(1,5) ~= "mouse" then
		if isTimer(KeyHolder.Timer) then killTimer(KeyHolder.Timer) end
		KeyHolder = {}
		KeyHolder.lastKey = button
		KeyHolder.Timer = setTimer(function()
			if not getKeyState(KeyHolder.lastKey) then
				KeyHolder = {}
				return
			end
			KeyHolder.repeatKey = true
			KeyHolder.repeatStartTick = getTickCount()
			KeyHolder.repeatDuration = 25
		end,400,1)
		if onClientKeyTriggered(button) then
			cancelEvent()
		end
	end
end

function onClientKeyTriggered(button)
	local makeEventCancelled = false
	local eleData = dgsElementData[MouseData.focused]
	if dgsGetType(MouseData.focused) == "dgs-dxedit" then
		local edit = MouseData.focused
		local text = eleData.text
		local shift = getKeyState("lshift") or getKeyState("rshift")
		local ctrl = getKeyState("lctrl") or getKeyState("rctrl")
		if button == "arrow_l" then
			if ctrl then
				local cpos = eleData.caretPos
				local text = eleData.text
				local f,b = dgsSearchFullWordType(text,cpos,-1)
				dgsEditMoveCaret(edit,f-cpos,shift)
			else
				dgsEditMoveCaret(edit,-1,shift)
			end
		elseif button == "arrow_r" then
			if ctrl then
				local cpos = eleData.caretPos
				local text = eleData.text
				local f,b = dgsSearchFullWordType(text,cpos,1)
				dgsEditMoveCaret(edit,b-cpos,shift)
			else
				dgsEditMoveCaret(edit,1,shift)
			end
		elseif button == "arrow_u" then
			local cmd = eleData.mycmd
			if dgsGetPluginType(cmd) == "dgs-dxcmd" then
				local int = dgsElementData[cmd].cmdCurrentHistory+1
				local history = dgsElementData[cmd].cmdHistory
				if history[int] then
					dgsSetData(cmd,"cmdCurrentHistory",int)
					dgsSetText(edit,history[int])
					dgsEditSetCaretPosition(edit,#history[int])
				end
			end
		elseif button == "arrow_d" then
			local cmd = eleData.mycmd
			if dgsGetPluginType(cmd) == "dgs-dxcmd" then
				local int = dgsElementData[cmd].cmdCurrentHistory-1
				local history = dgsElementData[cmd].cmdHistory
				if history[int] then
					dgsSetData(cmd,"cmdCurrentHistory",int)
					dgsSetText(edit,history[int])
					dgsEditSetCaretPosition(edit,#history[int])
				end
			end
		elseif button == "home" then
			dgsEditSetCaretPosition(edit,0,shift)
		elseif button == "end" then
			dgsEditSetCaretPosition(edit,#text,shift)
		elseif button == "delete" then
			if not eleData.readOnly then
				local cpos,spos = eleData.caretPos,eleData.selectFrom
				if cpos ~= spos then
					dgsEditDeleteText(edit,cpos,spos)
					eleData.selectFrom = eleData.caretPos
				else
					if ctrl then
						local text = eleData.text
						local f,b = dgsSearchFullWordType(text,cpos,1)
						dgsEditDeleteText(edit,cpos,b)
					else
						dgsEditDeleteText(edit,cpos,cpos+1)
					end
				end
			end
		elseif button == "backspace" then
			if not eleData.readOnly then
				local cpos,spos = eleData.caretPos,eleData.selectFrom
				if cpos ~= spos then
					dgsEditDeleteText(edit,cpos,spos)
					eleData.selectFrom = eleData.caretPos
				else
					if ctrl then
						local text = eleData.text
						local f,b = dgsSearchFullWordType(text,cpos,-1)
						dgsEditDeleteText(edit,f,cpos)
					else
						dgsEditDeleteText(edit,cpos-1,cpos)
					end
				end
			end
		elseif button == "c" or button == "x" and ctrl then
			if eleData.allowCopy then
				local cpos,spos = eleData.caretPos,eleData.selectFrom
				if cpos ~= spos then
					local deleteText = button == "x" and not eleData.readOnly
					local theText = dgsEditGetPartOfText(edit,cpos,spos,deleteText)
					setClipboard(theText)
				end
			end
		elseif button == "z" and ctrl then
			dgsEditDoOpposite(edit,true)
		elseif button == "y" and ctrl then
			dgsEditDoOpposite(edit,false)
		elseif button == "tab" then
			makeEventCancelled = true
			local autoCompleteShow = eleData.autoCompleteShow
			if autoCompleteShow then
				dgsSetText(edit,autoCompleteShow[1])
			else
				triggerEvent("onDgsEditPreSwitch",edit)
			end
		elseif button == "a" and ctrl then
			dgsSetData(edit,"caretPos",0)
			local text = eleData.text
			dgsSetData(edit,"selectFrom",utf8Len(text))
		end
	elseif dgsGetType(MouseData.focused) == "dgs-dxmemo" then
		local memo = MouseData.focused
		local shift = getKeyState("lshift") or getKeyState("rshift")
		local ctrl = getKeyState("lctrl") or getKeyState("rctrl")
		local isWordWrap = eleData.wordWrap
		if button == "arrow_l" then
			if ctrl then
				local textTable = dgsElementData[memo].text
				local cpos = dgsElementData[memo].caretPos
				local index,line = cpos[1],cpos[2]
				local text = textTable[line][0]
				local f,b,cType = dgsSearchFullWordType(text,index,-1)
				if index == 0 or (f == 0 and cType == 0) then
					index = index+1
				end
				dgsMemoMoveCaret(memo,f-index,0,shift)
			else
				dgsMemoMoveCaret(memo,-1,0,shift)
			end
		elseif button == "arrow_r" then
			if ctrl then
				local textTable = dgsElementData[memo].text
				local cpos = dgsElementData[memo].caretPos
				local index,line = cpos[1],cpos[2]
				local text = textTable[line][0]
				local f,b = dgsSearchFullWordType(text,index,1)
				if index == utf8Len(text) then
					index = index-1
					local nextLine = textTable[line+1]
					if nextLine then
						local nextLineText = nextLine[0]
						local _f,_b = dgsSearchFullWordType(nextLineText,0,1)
						b = b+_b
					end
				end
				dgsMemoMoveCaret(memo,b-index,0,shift)
			else
				dgsMemoMoveCaret(memo,1,0,shift)
			end
		elseif button == "arrow_u" then
			dgsMemoMoveCaret(memo,0,-1,shift,true)
		elseif button == "arrow_d" then
			dgsMemoMoveCaret(memo,0,1,shift,true)
		elseif button == "home" then
			if isWordWrap then
				local text = eleData.text
				local index,line = eleData.caretPos[1],eleData.caretPos[2]
				local weakLineIndex,weakLine = dgsMemoFindWeakLineInStrongLine(text[line],index)
				local currentPos = utf8Len(text[line][0],1,index)-utf8Len(text[line][1][weakLine][0],1,weakLineIndex)
				dgsMemoSetCaretPosition(memo,currentPos,ctrl and 1,shift)
			else
				dgsMemoSetCaretPosition(memo,0,ctrl and 1,shift)
			end
		elseif button == "end" then
			local text = eleData.text
			local index,line = eleData.caretPos[1],eleData.caretPos[2]
			if isWordWrap then
				local weakLineIndex,weakLine = dgsMemoFindWeakLineInStrongLine(eleData.text[line],index,true)
				local currentPos = utf8Len(eleData.text[line][0],1,index)-utf8Len(text[line][1][weakLine][0],1,weakLineIndex)+eleData.text[line][1][weakLine][3]
				dgsMemoSetCaretPosition(memo,currentPos,ctrl and #text,shift,not ctrl and true)
			else
				dgsMemoSetCaretPosition(memo,utf8Len(text[line][0] or ""),ctrl and #text,shift)
			end
		elseif button == "delete" then
			if not eleData.readOnly then
				local cpos,spos = eleData.caretPos,eleData.selectFrom
				if cpos[1] ~= spos[1] or cpos[2] ~= spos[2] then
					dgsMemoDeleteText(memo,cpos[1],cpos[2],spos[1],spos[2])
					eleData.selectFrom = eleData.caretPos
				elseif ctrl then
					local textTable = dgsElementData[memo].text
					local index,line = cpos[1],cpos[2]
					local text = textTable[line][0]
					if index == utf8Len(text) then
						local tIndex,tLine = dgsMemoSeekPosition(eleData.text,cpos[1]+1,cpos[2])
						dgsMemoDeleteText(memo,cpos[1],cpos[2],tIndex,tLine)
					else
						local f,b = dgsSearchFullWordType(text,index,1)
						local tIndex,tLine = dgsMemoSeekPosition(eleData.text,b,cpos[2])
						dgsMemoDeleteText(memo,cpos[1],cpos[2],tIndex,tLine)
					end
				else
					local tIndex,tLine = dgsMemoSeekPosition(eleData.text,cpos[1]+1,cpos[2])
					dgsMemoDeleteText(memo,cpos[1],cpos[2],tIndex,tLine)
				end
			end
		elseif button == "backspace" then
			if not eleData.readOnly then
				local cpos,spos = eleData.caretPos,eleData.selectFrom
				if cpos[1] ~= spos[1] or cpos[2] ~= spos[2] then
					dgsMemoDeleteText(memo,cpos[1],cpos[2],spos[1],spos[2])
					eleData.selectFrom = eleData.caretPos
				elseif ctrl then
					local textTable = dgsElementData[memo].text
					local index,line = cpos[1],cpos[2]
					local text = textTable[line][0]
					if index == 0 then
						local tIndex,tLine = dgsMemoSeekPosition(eleData.text,cpos[1]-1,cpos[2])
						dgsMemoDeleteText(memo,cpos[1],cpos[2],tIndex,tLine)
					else
						local f,b = dgsSearchFullWordType(text,index,-1)
						local tIndex,tLine = dgsMemoSeekPosition(eleData.text,f,cpos[2])
						dgsMemoDeleteText(memo,tIndex,tLine,cpos[1],cpos[2])
					end
				else
					local tIndex,tLine = dgsMemoSeekPosition(eleData.text,cpos[1]-1,cpos[2])
					dgsMemoDeleteText(memo,tIndex,tLine,cpos[1],cpos[2])
				end
			end
		elseif button == "c" or button == "x" and ctrl then
			if eleData.allowCopy then
				local cpos,spos = eleData.caretPos,eleData.selectFrom
				if not(cpos[1] == spos[1] and cpos[2] == spos[2]) then
					local deleteText = button == "x" and not eleData.readOnly
					local theText = dgsMemoGetPartOfText(memo,cpos[1],cpos[2],spos[1],spos[2],deleteText)
					setClipboard(theText)
				end
			end
		elseif button == "a" and ctrl then
			dgsMemoSetSelectedArea(memo,0,1,"all")
		end
	elseif dgsGetType(MouseData.focused) == "dgs-dxgridlist" then
		local gridlist = MouseData.focused
		if eleData.enableNavigation then
			if button == "arrow_u" then
				if eleData.selectionMode ~= 2 then
					local lastSelected = eleData.lastSelectedItem
					local nextSelected = lastSelected[1]-1 <= 1 and 1 or lastSelected[1]-1
					while(true) do
						if dgsGridListGetRowSelectable(gridlist,nextSelected) then
							dgsGridListSetSelectedItem(gridlist,nextSelected,lastSelected[2],true)
							break
						else
							nextSelected = nextSelected-1
							if nextSelected-1 < 1 then break end
						end
					end
				end
			elseif button == "arrow_d" then
				if eleData.selectionMode ~= 2 then
					local lastSelected = eleData.lastSelectedItem
					local rLen = #eleData.rowData
					local nextSelected = lastSelected[1]+1 >= rLen and rLen or lastSelected[1]+1
					while(true) do
						if dgsGridListGetRowSelectable(gridlist,nextSelected) then
							dgsGridListSetSelectedItem(gridlist,nextSelected,lastSelected[2],true)
							break
						else
							nextSelected = nextSelected+1
							if nextSelected+1 > rLen then
								break
							end
						end
					end
					dgsGridListSetSelectedItem(gridlist,nextSelected,lastSelected[2],true)
				end
			elseif button == "arrow_l" then
				if eleData.selectionMode ~= 1 then
					local lastSelected = eleData.lastSelectedItem
					local nextSelected = lastSelected[2]-1
					dgsGridListSetSelectedItem(gridlist,lastSelected[1],nextSelected <= 1 and 1 or nextSelected,true)
				end
			elseif button == "arrow_r" then
				if eleData.selectionMode ~= 1 then
					local lastSelected = eleData.lastSelectedItem
					local nextSelected = lastSelected[2]+1
					local cLen = #eleData.columnData
					dgsGridListSetSelectedItem(gridlist,lastSelected[1],nextSelected >= cLen and cLen or nextSelected,true)
				end
			end
		end
	end
	return makeEventCancelled
end

function dgsCheckHit(hits,cursorShowing)
	local enteredElementType = dgsGetType(MouseData.entered)
	local mx,my = MouseData.cursorPos[1],MouseData.cursorPos[2]
	if not isElement(MouseData.clickl) or not (dgsGetType(MouseData.clickl) == "dgs-dxscrollbar" and MouseData.scbClickData == 3) then
		if MouseData.entered ~= hits then
			if isElement(MouseData.entered) then
				if enteredElementType == "dgs-dxgridlist" then
					local preSelect = dgsElementData[MouseData.entered]
					preSelect[1],preSelect[2] = -1,-1
					dgsSetData(MouseData.entered,"preSelect",preSelect)
				end
				triggerEvent("onDgsMouseLeave",MouseData.entered,mx,my,hits)
			end
			if isElement(hits) then
				triggerEvent("onDgsMouseEnter",hits,mx,my,MouseData.entered)
			end
			MouseData.left = MouseData.entered
			MouseData.entered = hits
		end
	end
	if dgsElementType[hits] == "dgs-dxtab" then
		local parent = dgsElementData[hits].parent
		dgsElementData[parent].preSelect = dgsElementData[parent].rndPreSelect
	end
	if isElement(hits) then
		if MouseData.lastPos[1] ~= mx or MouseData.lastPos[2] ~= my then
			triggerEvent("onDgsMouseMove",hits,mx,my)
		end
	end
	if isElement(MouseData.clickl) then
		if MouseData.lastPos[1] ~= mx or MouseData.lastPos[2] ~= my then
			triggerEvent("onDgsMouseDrag",MouseData.clickl,mx,my)
			if MouseData.clickPosition.left[0] then
				if ((MouseData.clickPosition.left[1]-mx)^2+(MouseData.clickPosition.left[2]-my)^2)^0.5 > 10 then
					triggerEvent("onDgsDrag",MouseData.clickl)
					if not wasEventCancelled() then
						if dgsElementData[MouseData.clickl].dragHandler then
							dgsSendDragNDropData(unpack(dgsElementData[MouseData.clickl].dragHandler))
						end
					end
				end
			end
		end
		if MouseData.Move[0] then
			local posX,posY = 0,0
			local parent = FatherTable[MouseData.clickl]
			if parent then
				posX,posY = getParentLocation(parent)
				if dgsElementType[parent] == "dgs-dxwindow" then
					if not dgsElementData[MouseData.clickl].ignoreParentTitle and not dgsElementData[parent].ignoreTitle then
						posY = posY + (dgsElementData[parent].titleHeight or 0)
					end
				elseif dgsElementType[parent] == "dgs-dxtab" then
					local tabpanel = dgsElementData[parent].parent
					local size = dgsElementData[tabpanel].absSize[2]
					local height = dgsElementData[tabpanel].tabHeight[2] and dgsElementData[tabpanel].tabHeight[1]*size or dgsElementData[tabpanel].tabHeight[1]
					posY = posY + height
				end
			end
			local posX,posY = mx-MouseData.Move[1]-posX,my-MouseData.Move[2]-posY
			local absPos = dgsElementData[MouseData.clickl].absPos
			if absPos[1] ~= posX or absPos[2] ~= posY then
				calculateGuiPositionSize(MouseData.clickl,posX,posY,false)
			end
		end
		if MouseData.Scale[0] then
			local posX,posY = dgsGetPosition(MouseData.clickl,false,true)
			local addPosX,addPosY = 0,0
			local parent = FatherTable[MouseData.clickl]
			if parent then
				addPosX,addPosY = getParentLocation(parent)
				if dgsElementType[parent] == "dgs-dxwindow" then
					if not dgsElementData[MouseData.clickl].ignoreParentTitle and not dgsElementData[parent].ignoreTitle then
						addPosY = addPosY + (dgsElementData[parent].titleHeight or 0)
					end
				elseif dgsElementType[parent] == "dgs-dxtab" then
					local tabpanel = dgsElementData[parent].parent
					local size = dgsElementData[tabpanel].absSize[2]
					local height = dgsElementData[tabpanel].tabHeight[2] and dgsElementData[tabpanel].tabHeight[1]*size or dgsElementData[tabpanel].tabHeight[1]
					addPosY = addPosY + height
				end
			end
			local absPos = dgsElementData[MouseData.clickl].absPos
			local absSize = dgsElementData[MouseData.clickl].absSize
			local sizeW,sizeH = absSize[1],absSize[2]
			local endr = posX + sizeW
			local endd = posY + sizeH
			local minSize = dgsElementData[MouseData.clickl].minSize
			local minSizeX,minSizeY = minSize and minSize[1] or 10,minSize and minSize[2] or 10
			if MouseData.Scale[5] == 1 then
				local old = posX
				sizeW = sizeW-(mx-MouseData.Scale[1]-old)
				if sizeW < minSizeX then
					sizeW = minSizeX
					posX = endr-sizeW
				else
					posX = mx-MouseData.Scale[1]
				end
			end
			if MouseData.Scale[5] == 3 then
				sizeW = (mx-posX-MouseData.Scale[3])
				if sizeW < minSizeX then
					sizeW = minSizeX
				end
			end
			if MouseData.Scale[6] == 2 then
				local old = posY
				sizeH = sizeH-(my-MouseData.Scale[2]-old)
				if sizeH < minSizeY then
					sizeH = minSizeY
					posY = endd-sizeH
				else
					posY = my-MouseData.Scale[2]
				end
			end
			if MouseData.Scale[6] == 4 then
				sizeH = my-posY-MouseData.Scale[4]
				if sizeH < minSizeY then
					sizeH = minSizeY
				end
			end
			local posX,posY = posX-addPosX,posY-addPosY
			if posX+posY-absPos[1]-absPos[2] ~= 0 or sizeW+sizeH-absSize[1]-absSize[2] ~= 0 then
				calculateGuiPositionSize(MouseData.clickl,posX,posY,false,sizeW,sizeH,false)
			end
		else
			MouseData.lastPos[1] = -1
			MouseData.lastPos[2] = -1
		end
		if not getKeyState("mouse1") then
			MouseData.clickl = false
			MouseData.scbClickData = false
			MouseData.selectorClickData = false
			MouseData.Move[0] = false
			MouseData.Scale[0] = false
			MouseData.lock3DInterface = false
		end
		if not getKeyState("mouse2") then
			MouseData.clickr = false
		end
	else
		MouseData.lastPos[1] = nil
		MouseData.lastPos[2] = nil
	end
	if isElement(MouseData.topScrollable) then
		if MouseData.MoveScale[0] then
			local scalepane = MouseData.topScrollable
			if dgsGetType(scalepane) == "dgs-dxscalepane" then
				--Check is in scale pane
				local eleData = dgsElementData[scalepane]
				local scale = eleData.scale
				local scrollbar = eleData.scrollbars
				local scbThick = eleData.scrollBarThick
				local x,y = dgsGetPosition(scalepane,false,true)
				local w,h = eleData.absSize[1],eleData.absSize[2]
				local xthick = dgsElementData[scrollbar[1]].visible and scbThick or 0
				local ythick = dgsElementData[scrollbar[2]].visible and scbThick or 0
				local resolution = eleData.resolution
				local relSizX,relSizY = (w-xthick)/scale[1],(h-ythick)/scale[2]
				local xScroll = dgsElementData[scrollbar[2]].position*0.01
				local yScroll = dgsElementData[scrollbar[1]].position*0.01
				local renderOffsetX = -(resolution[1]-relSizX)*xScroll
				local renderOffsetY = -(resolution[2]-relSizY)*yScroll
				
				local posX,posY = mx+renderOffsetX-x-MouseData.MoveScale[1],my+renderOffsetY-y-MouseData.MoveScale[2]
				local xScr = -posX/(resolution[1]-relSizX)
				local yScr = -posY/(resolution[2]-relSizY)
				dgsScrollBarSetScrollPosition(scrollbar[2],mathClamp(xScr,0,1)*100)
				dgsScrollBarSetScrollPosition(scrollbar[1],mathClamp(yScr,0,1)*100)
			end
		end
	end
	MouseData.lastPos[1] = mx
	MouseData.lastPos[2] = my
	if not isElement(MouseData.clickl) then
		local _cursorType = "arrow"
		if MouseData.entered then
			local eleData = dgsElementData[MouseData.entered]
			local sizeData = eleData.sizeHandlerData
			if sizeData or enteredElementType == "dgs-dxwindow" then
				if eleData.sizable then
					local x,y = dgsGetPosition(MouseData.entered,false,true)
					local w,h = eleData.absSize[1],eleData.absSize[2]
					local offsetx,offsety = mx-x,my-y
					local left,right,top,bottom
					if enteredElementType == "dgs-dxwindow" then
						local borderSize = eleData.borderSize
						left,right,top,bottom = borderSize,borderSize,borderSize,borderSize
					else
						local leftRel,rightRel,topRel,bottomRel = sizeData[5],sizeData[6],sizeData[7],sizeData[8]
						left = leftRel and sizeData[1]*w or sizeData[1]
						right = rightRel and sizeData[2]*h or sizeData[2]
						top = topRel and sizeData[3]*w or sizeData[3]
						bottom = bottomRel and sizeData[4]*h or sizeData[4]
					end
					local offL,offT,offR,offB,horzState,vertState = mx-x,my-y,mx-x-w,my-y-h
					if mathAbs(offL) < left then
						horzState = 1
					elseif mathAbs(offR) < right then
						horzState = 3
					end
					if mathAbs(offT) < top then
						vertState = 2
					elseif mathAbs(offB) < bottom then
						vertState = 4
					end
					if horzState and vertState then --Horizontal Stretch
						if horzState == vertState-1 then
							_cursorType = "sizing_nwse"
						else
							_cursorType = "sizing_nesw"
						end
					elseif horzState then
						_cursorType = "sizing_ew"
					elseif vertState then
						_cursorType = "sizing_ns"
					end
				end
			elseif enteredElementType == "dgs-dxmemo" or enteredElementType == "dgs-dxedit" then
				_cursorType = "text"
			end
		end
		if _cursorType == "arrow" then
			_cursorType = guiGetCursorType()
		end
		if _cursorType ~= MouseData.cursorType then
			triggerEvent("onDgsCursorTypeChange",root,_cursorType,MouseData.cursorType)
			MouseData.cursorType = _cursorType
		end
	end
	if CursorData.enabled then
		local cData = CursorData[MouseData.cursorType]
		if cData then
			local image = cData[1]
			if image and not isElement(image) then
				CursorData[MouseData.cursorType] = nil
				cData = nil
			end
			if cursorShowing then
				local color = CursorData.color
				local cursorSize = CursorData.size

				local rotation = cData[2]
				local rotCenter = cData[3]
				local offset = cData[4]
				local scale = cData[5]
				local materialSize = cData[6]
				local cursorW,cursorH = materialSize[1]/materialSize[2]*cursorSize*scale,cursorSize*scale
				local cursorScrX,cursorScrY = dgsGetCursorPosition(_,false,true)
				local cursorX,cursorY = cursorScrX+offset[1]*cursorW,cursorScrY+offset[2]*cursorH
				setCursorAlpha(0)
				_dxDrawImage(cursorX,cursorY,cursorW,cursorH,image,rotation,rotCenter[1],rotCenter[2],color,true)
			else
				setCursorAlpha(255)
			end
		else
			setCursorAlpha(255)
		end
	end
end

function onClientMouseTriggered()
	if MouseHolder.element == MouseData.entered then
		local dgsType = dgsGetType(MouseHolder.element)
		if dgsType == "dgs-dxscrollbar" then
			if MouseData.scbEnterData then
				MouseData.scbClickData = MouseData.scbEnterData
			end
			local scrollbar = MouseHolder.element
			if MouseData.scbEnterData == 1 or MouseData.scbEnterData == 5 then
				if dgsElementData[scrollbar].scrollArrow then
					scrollScrollBar(scrollbar,MouseData.scbClickData == 5)
					dgsSetData(scrollbar,"moveType","slow")
				end
			elseif MouseData.scbEnterData == 2 or MouseData.scbEnterData == 4 then
				local troughClickAction = dgsElementData[scrollbar].troughClickAction
				dgsSetData(scrollbar,"moveType","fast")
				if troughClickAction == "step" then
					scrollScrollBar(scrollbar,MouseData.scbClickData == 4,2)
				elseif troughClickAction == "jump" then
					dgsSetProperty(scrollbar,"position",mathClamp(MouseData.scbEnterRltPos,0,1)*100)
				end
			end
		elseif dgsType == "dgs-dxselector" then
			local selector = MouseHolder.element
			if MouseData.selectorEnterData then
				MouseData.selectorClickData = MouseData.selectorEnterData
			end
			local scrollbar = MouseHolder.element
			if MouseData.selectorEnterData == 1 then
				local itemData = dgsElementData[selector].itemData
				local itemCount = #itemData
				local currentItem = dgsElementData[selector].select
				if currentItem ~= -1 then
					local offsetItem = 1
					if MouseHolder.notIsFirst then
						dgsElementData[selector].quickLeapState = mathLerp(0.1,dgsElementData[selector].quickLeapState,dgsElementData[selector].quickLeap)
						offsetItem = dgsElementData[selector].quickLeapState*itemCount
					else
						dgsElementData[selector].quickLeapState = 0
					end
					dgsSelectorSetSelectedItem(selector,mathCeil(mathClamp(currentItem-offsetItem,1,itemCount)))
				end
			elseif MouseData.selectorEnterData == 3 then
				local itemData = dgsElementData[selector].itemData
				local itemCount = #itemData
				local currentItem = dgsElementData[selector].select
				if currentItem ~= -1 then
					local offsetItem = 1
					if MouseHolder.notIsFirst then
						dgsElementData[selector].quickLeapState = mathLerp(0.1,dgsElementData[selector].quickLeapState,dgsElementData[selector].quickLeap)
						offsetItem = dgsElementData[selector].quickLeapState*itemCount
					else
						dgsElementData[selector].quickLeapState = 0
					end
					dgsSelectorSetSelectedItem(selector,mathFloor(mathClamp(currentItem+offsetItem,1,itemCount)))
				end
			end
		end
	end
	MouseHolder.notIsFirst = true
end

MouseHolder = {}
MouseKeyConverter = {left="mouse1",right="mouse2",middle="mouse3"}
MouseKeySupports = {["dgs-dxscrollbar"] = true,["dgs-dxselector"] = true}
function onDGSMouseCheck(button,state)
	local button = MouseKeyConverter[button]
	if state == "down" then
		if MouseKeySupports[dgsGetType(source)] then
			if not MouseHolder.lastKey then
				if isTimer(MouseHolder.Timer) then killTimer(MouseHolder.Timer) end
				MouseHolder = {
					element = source,
					lastKey = button,
				}
				MouseHolder.Timer = setTimer(function()
					if not getKeyState(MouseHolder.lastKey) or not isElement(MouseHolder.element) then
						MouseHolder = {}
						return
					end
					MouseHolder.repeatKey = true
					MouseHolder.repeatStartTick = getTickCount()
					MouseHolder.repeatDuration = 25
				end,500,1)
				onClientMouseTriggered(button)
			end
		end
	elseif MouseHolder.lastKey == button then
		if isTimer(MouseHolder.Timer) then killTimer(MouseHolder.Timer) end
		MouseHolder = {}
	end
end
addEventHandler("onDgsMouseClick",root,onDGSMouseCheck)

function dgsCleanElement(source)
	local isAlive = isElement(source)
	local parent = FatherTable[source] or root
	local dgsType = dgsElementType[source]
	if dgsType then
		local eleData = dgsElementData[source] or {}
		if isAlive then triggerEvent("onDgsDestroy",source) end
		local isAttachedToGridList = eleData.attachedToGridList
		if isAttachedToGridList and isAlive then dgsDetachFromGridList(source) end
		local child = ChildrenTable[source] or {}
		for i=1,#child do
			if isElement(child[1]) then destroyElement(child[1]) end
		end
		local autoDestroyList = eleData.autoDestroyList
		if autoDestroyList then
			for i=-10,#autoDestroyList do	--From -10, to reserve dynamic space
				local ele = autoDestroyList[i]
				if ele and isElement(ele) then
					destroyElement(ele)
				end
			end
		end
		if dgsType == "dgs-dxedit" then
			blurEditMemo()
		elseif dgsType == "dgs-dxmemo" then
			blurEditMemo()
		elseif dgsType == "dgs-dxtabpanel" then
			local tabs = eleData.tabs
			if tabs then
				for i=1,#tabs do
					destroyElement(tabs[i])
				end
			end
		elseif dgsType == "dgs-dxtab" then
			local isRemove = eleData.isRemove
			if not isRemove then
				local tabpanel = eleData.parent
				if dgsGetType(tabpanel) == "dgs-dxtabpanel" then
					local wid = eleData.width
					local w = dgsElementData[tabpanel].absSize[1]
					local tabs = dgsElementData[tabpanel].tabs
					local tabPadding = dgsElementData[tabpanel].tabPadding
					local sidesize = tabPadding[2] and tabPadding[1]*w or tabPadding[1]
					local tabGapSize = dgsElementData[tabpanel].tabGapSize
					local gapSize = tabGapSize[2] and tabGapSize[1]*w or tabGapSize[1]
					dgsSetData(tabpanel,"tabLengthAll",dgsElementData[tabpanel].tabLengthAll-wid-sidesize*2-gapSize*mathMin(#tabs,1))
					local id = eleData.id
					for i=id,#tabs do
						dgsElementData[tabs[i]].id = dgsElementData[tabs[i]].id-1
					end
					tableRemove(tabs,id)
				end
			end
		elseif dgsType == "dgs-dximage" then
			local image = eleData.image
			if isElement(image) then
				if dgsElementData[image] and dgsElementData[image].parent == image then
					destroyElement(image)
				end
			end
		elseif dgsType == "shader" then
			if eleData.asPlugin == "dgs-dxblurbox" then
				blurboxShaders = blurboxShaders-1
				if blurboxShaders == 0 and isElement(BlurBoxGlobalScreenSource) then
					destroyElement(BlurBoxGlobalScreenSource)
					BlurBoxGlobalScreenSource = nil
				end
			end
		end
		ChildrenTable[source] = nil
		if animGUIList[source] then if isAlive then dgsStopAniming(source) else animGUIList[source] = nil end end
		if moveGUIList[source] then if isAlive then dgsStopMoving(source) else moveGUIList[source] = nil end end
		if sizeGUIList[source] then if isAlive then dgsStopSizing(source) else sizeGUIList[source] = nil end end
		if alphaGUIList[source] then if isAlive then dgsStopAlphaing(source) else alphaGUIList[source] = nil end end
		if dgsWorld3DType[dgsType] then
			tableRemoveItemFromArray(dgsWorld3DTable,source)
		elseif dgsScreen3DType[dgsType] then
			tableRemoveItemFromArray(dgsScreen3DTable,source)
		else
			local parent = FatherTable[source]
			if not parent then
				local layer = eleData.alwaysOn or "center"
				if layer == "bottom" then
					tableRemoveItemFromArray(BottomFatherTable,source)
				elseif layer == "center" then
					tableRemoveItemFromArray(CenterFatherTable,source)
				elseif layer == "top" then
					tableRemoveItemFromArray(TopFatherTable,source)
				end
			else
				if ChildrenTable[parent] then
					tableRemoveItemFromArray(ChildrenTable[parent],source)
				end
				FatherTable[source] = nil
			end
		end
		if eleData._translationText then
			tableRemoveItemFromArray(LanguageTranslationAttach,source)
		end
	end
	local tresource = dgsElementData[source].resource
	if tresource and boundResource[tresource] then
		boundResource[tresource][source] = nil
	end
	dgsElementData[source] = nil
	dgsElementType[source] = nil
end

addEventHandler("onClientElementDestroy",root,function()
	if dgsElementData[source] then
		dgsCleanElement(source)
	end
end,true,"low")

function checkMove(source)
	local eleData = dgsElementData[source]
	local moveData = eleData.moveHandlerData
	if moveData then
		local x,y = dgsGetPosition(source,false,true)
		local w,h = eleData.absSize[1],eleData.absSize[2]
		local offsetx,offsety = MouseData.cursorPos[1]-x,MouseData.cursorPos[2]-y
		local xRel,yRel,wRel,hRel = moveData[5],moveData[6],moveData[7],moveData[8]
		local chx = xRel and moveData[1]*w or moveData[1]
		local chy = yRel and moveData[2]*h or moveData[2]
		local chw = wRel and moveData[3]*w or moveData[3]
		local chh = hRel and moveData[4]*h or moveData[4]
		if not (offsetx >= chx and offsetx <= chx+chw and offsety >= chy and offsety <= chy+chh) then
			return
		end
		MouseData.Move[0] = true
		MouseData.Move[1] = offsetx
		MouseData.Move[2] = offsety
		triggerEvent("onDgsElementMove",source,offsetx,offsety)
	elseif dgsGetType(source) == "dgs-dxwindow" then
		local x,y = dgsGetPosition(source,false,true)
		local w,h = eleData.absSize[1],eleData.absSize[2]
		local offsetx,offsety = MouseData.cursorPos[1]-x,MouseData.cursorPos[2]-y
		local moveData = eleData.moveHandlerData
		local movable = eleData.movable
		if not movable then return end
		local titsize = eleData.moveType and h or eleData.titleHeight
		if offsety > titsize then return end
		MouseData.Move[0] = true
		MouseData.Move[1] = offsetx
		MouseData.Move[2] = offsety
		triggerEvent("onDgsElementMove",source,offsetx,offsety)
	end
end

function checkScrollBar(source,py,sd)
	local x,y = dgsElementData[source].absPos[1],dgsElementData[source].absPos[2]
	local offsetx,offsety = MouseData.cursorPos[1]-x,MouseData.cursorPos[2]-y
	MouseData.MoveScroll[0] = true
	MouseData.MoveScroll[1] = sd and offsetx-py or offsetx
	MouseData.MoveScroll[2] = sd and offsety or offsety-py
end

function checkScale(source)
	local eleData = dgsElementData[source]
	local sizeData = eleData.sizeHandlerData
	if sizeData then
		local x,y = dgsGetPosition(source,false,true)
		local w,h = eleData.absSize[1],eleData.absSize[2]
		local offsetx,offsety = MouseData.cursorPos[1]-x,MouseData.cursorPos[2]-y
		local leftRel,rightRel,topRel,bottomRel = sizeData[5],sizeData[6],sizeData[7],sizeData[8]
		local left = leftRel and sizeData[1]*w or sizeData[1]
		local right = rightRel and sizeData[2]*h or sizeData[2]
		local top = topRel and sizeData[3]*w or sizeData[3]
		local bottom = bottomRel and sizeData[4]*h or sizeData[4]

		local offL,offT,offR,offB,horzState,vertState = offsetx,offsety,offsetx-w,offsety-h
		if mathAbs(offL) < left then
			horzState = 1
		elseif mathAbs(offR) < right then
			horzState = 3
		end
		if mathAbs(offT) < top then
			vertState = 2
		elseif mathAbs(offB) < bottom then
			vertState = 4
		end
		if not horzState and not vertState then
			MouseData.Scale[0] = false
			return false
		end
		MouseData.Scale[0] = true
		MouseData.Scale[1] = offL
		MouseData.Scale[2] = offT
		MouseData.Scale[3] = offR
		MouseData.Scale[4] = offB
		MouseData.Scale[5] = horzState
		MouseData.Scale[6] = vertState
		triggerEvent("onDgsElementSize",source,offL,offT)
		return true
	elseif dgsGetType(source) == "dgs-dxwindow" then
		local x,y = dgsGetPosition(source,false,true)
		local w,h = eleData.absSize[1],eleData.absSize[2]
		local sizable = eleData.sizable
		if not sizable then return false end
		local borderSize = eleData.borderSize

		local offsetx,offsety = MouseData.cursorPos[1]-x,MouseData.cursorPos[2]-y
		local offL,offT,offR,offB,horzState,vertState = offsetx,offsety,offsetx-w,offsety-h
		if mathAbs(offL) < borderSize then
			horzState = 1
		elseif mathAbs(offR) < borderSize then
			horzState = 3
		end
		if mathAbs(offT) < borderSize then
			vertState = 2
		elseif mathAbs(offB) < borderSize then
			vertState = 4
		end
		if not horzState and not vertState then
			MouseData.Scale[0] = false
			return false
		end
		MouseData.Scale[0] = true
		MouseData.Scale[1] = offL
		MouseData.Scale[2] = offT
		MouseData.Scale[3] = offR
		MouseData.Scale[4] = offB
		MouseData.Scale[5] = horzState
		MouseData.Scale[6] = vertState
		triggerEvent("onDgsElementSize",source,offL,offT)
		return true
	end
	return false
end

multiClick = {
	Interval = 250;
	left = {up = {0,false,false},down = {0,false,false}},
	right = {up = {0,false,false},down = {0,false,false}},
	middle = {up = {0,false,false},down = {0,false,false}},
}

GirdListDoubleClick = {}
GirdListDoubleClick.down = false
GirdListDoubleClick.up = false

addEventHandler("onClientClick",root,function(button,state,x,y)
	local guiele = dgsGetMouseEnterGUI()
	local mouseX,mouseY = MouseData.cursorPos[0] and MouseData.cursorPos[1] or x,MouseData.cursorPos[0] and MouseData.cursorPos[2] or y
	if isElement(guiele) then
		local eleData = dgsElementData[guiele]
		local isCoolingDown = false
		local clickCoolDown = eleData.clickCoolDown
		if clickCoolDown then
			local clickTick = getTickCount()
			local lastClickTick = eleData.lastClickTick or {}
			lastClickTick[button] = lastClickTick[button] or {}
			lastClickTick[button][state] = lastClickTick[button][state] or 0
			local lClickTick = tonumber(lastClickTick[button][state]) or 0
			isCoolingDown = getTickCount()-lClickTick <= clickCoolDown
			if not isCoolingDown then
				lastClickTick[button][state] = clickTick
			end
			eleData.lastClickTick = lastClickTick
		end

		if not isElement(guiele) then return end
		if state == "up" then
			if button == "left" then
				if MouseData.clickl == guiele then
					triggerEvent("onDgsMousePreClick",guiele,button,state,mouseX,mouseY,isCoolingDown)
				end
			elseif button == "right" then
				if MouseData.clickr == guiele then
					triggerEvent("onDgsMousePreClick",guiele,button,state,mouseX,mouseY,isCoolingDown)
				end
			else
				triggerEvent("onDgsMousePreClick",guiele,button,state,mouseX,mouseY,isCoolingDown)
			end
		else
			triggerEvent("onDgsMousePreClick",guiele,button,state,mouseX,mouseY,isCoolingDown)
		end
		if not isElement(guiele) then return end
		if wasEventCancelled() then return end

		local guitype = dgsGetType(guiele)
		if guitype == "dgs-dxbrowser" then
			focusBrowser(guiele)
		else
			focusBrowser()
		end
		local parent = dgsGetParent(guiele)
		if guitype == "dgs-dxswitchbutton" then
			if eleData.clickState == state and eleData.clickButton == button then
				dgsSetData(guiele,"state", not eleData.state)
			end
		end
		if state == "down" then
			dgsBringToFront(guiele,button)
			if guitype == "dgs-dxscrollpane" or guitype == "dgs-dxscalepane" then
				local scrollbar = eleData.scrollbars
				dgsBringToFront(scrollbar[1],"left",_,true)
				dgsBringToFront(scrollbar[2],"left",_,true)
			end
			if button == "left" then
				if not checkScale(guiele) then
					checkMove(guiele)
				end
				if guitype == "dgs-dxscrollbar" then
					local scrollArrow = eleData.scrollArrow
					local x,y = dgsGetPosition(guiele,false,true)
					local w,h = dgsGetSize(guiele,false)
					local isHorizontal = eleData.isHorizontal
					local length,lrlt = eleData.length[1],eleData.length[2]
					local slotRange
					local arrowWid = eleData.arrowWidth
					if isHorizontal then
						slotRange = w-(scrollArrow and (arrowWid[2] and h*arrowWid[1] or arrowWid[1])*2 or 0)
					else
						slotRange = h-(scrollArrow and (arrowWid[2] and w*arrowWid[1] or arrowWid[1])*2 or 0)
					end
					local cursorRange = (lrlt and length*slotRange) or (length <= slotRange and length or slotRange*0.01)
					checkScrollBar(guiele,eleData.position*0.01*(slotRange-cursorRange),isHorizontal)
				elseif guitype == "dgs-dxradiobutton" then
					dgsRadioButtonSetSelected(guiele,true)
				elseif guitype == "dgs-dxcheckbox" then
					dgsCheckBoxSetSelected(guiele,not eleData.state)
				elseif guitype == "dgs-dxcombobox-Box" then
					local combobox = eleData.myCombo
					local comboEleData = dgsElementData[combobox]
					local preSelect = comboEleData.preSelect
					local oldSelect = comboEleData.select
					comboEleData.select = preSelect
					local captionEdit = comboEleData.captionEdit
					if isElement(captionEdit) then
						local selection = comboEleData.select
						local itemData = comboEleData.itemData
						dgsSetText(captionEdit,itemData[selection] and itemData[selection][1] or "")
					end
					if comboEleData.autoHideAfterSelected then
						dgsSetData(combobox,"listState",-1)
					end
					triggerEvent("onDgsComboBoxSelect",combobox,preSelect,oldSelect)
				elseif guitype == "dgs-dxtab" then
					local tabpanel = eleData.parent
					dgsBringToFront(tabpanel)
					if dgsElementData[tabpanel]["preSelect"] ~= -1 then
						dgsSetData(tabpanel,"selected",dgsElementData[tabpanel]["preSelect"])
					end
				elseif guitype == "dgs-dxcombobox" then
					dgsSetData(guiele,"listState",eleData.listState == 1 and -1 or 1)
				elseif guitype == "dgs-dxselector" then

				end
			elseif button == "middle" then
				if dgsGetType(MouseData.topScrollable) == "dgs-dxscalepane" then
					dgsScalePaneCheckMove(MouseData.topScrollable)
				end
			end
			if guitype == "dgs-dxgridlist" then
				local clickButton = eleData.mouseSelectButton
				local isSelectButtonEnabled = clickButton[mouseButtonOrder[button]]
				if isSelectButtonEnabled then
					local oPreSelect = eleData.oPreSelect
					local rowData = eleData.rowData
					----Sort
					if eleData.sortEnabled then
						local column = eleData.selectedColumn
						if column and column >= 1 then
							local sortFunction = eleData.sortFunction
							local defSortFnc = eleData.defaultSortFunctions
							local upperSortFnc = sortFunctions[defSortFnc[1]]
							local lowerSortFnc = sortFunctions[defSortFnc[2]]
							local targetfunction = (sortFunction == upperSortFnc or eleData.sortColumn ~= column) and lowerSortFnc or upperSortFnc
							dgsGridListSetSortFunction(guiele,targetfunction)
							dgsGridListSetSortColumn(guiele,column)
						end
					end
					--------
					if oPreSelect and rowData[oPreSelect] and rowData[oPreSelect][-1] ~= false then
						local selectionMode = eleData.selectionMode
						local multiSelection = eleData.multiSelection
						local preSelect = eleData.preSelect
						local clicked = eleData.itemClick
						local shift,ctrl = getKeyState("lshift") or getKeyState("rshift"),getKeyState("lctrl") or getKeyState("rctrl")
						if #preSelect == 2 then
							if selectionMode == 1 then
								if multiSelection then
									if ctrl then
										dgsGridListSelectItem(guiele,preSelect[1],1,not dgsGridListItemIsSelected(guiele,preSelect[1],1))
									elseif shift then
										if clicked and #clicked == 2 then
											dgsGridListSetSelectedItem(guiele,-1,-1)
											local startRow,endRow = mathMin(clicked[1],preSelect[1]),mathMax(clicked[1],preSelect[1])
											for row = startRow,endRow do
												dgsGridListSelectItem(guiele,row,1,true)
											end
											eleData.itemClick = clicked
										end
									else
										dgsGridListSetSelectedItem(guiele,preSelect[1],preSelect[2])
										eleData.itemClick = preSelect
									end
								else
									dgsGridListSetSelectedItem(guiele,preSelect[1],preSelect[2])
									eleData.itemClick = preSelect
								end
							elseif selectionMode == 2 then
								if multiSelection then
									if ctrl then
										dgsGridListSelectItem(guiele,preSelect[1],preSelect[2],not dgsGridListItemIsSelected(guiele,1,preSelect[2]))
									elseif shift then
										if clicked and #clicked == 2 then
											dgsGridListSetSelectedItem(guiele,-1,-1)
											local startColumn,endColumn = mathMin(clicked[2],preSelect[2]),mathMax(clicked[2],preSelect[2])
											for column = startColumn, endColumn do
												dgsGridListSelectItem(guiele,preSelect[1],column,true)
											end
											eleData.itemClick = clicked
										end
									else
										dgsGridListSetSelectedItem(guiele,preSelect[1],preSelect[2])
										eleData.itemClick = preSelect
									end
								else
									dgsGridListSetSelectedItem(guiele,preSelect[1],preSelect[2])
									eleData.itemClick = preSelect
								end
							elseif selectionMode == 3 then
								if multiSelection then
									if ctrl then
										dgsGridListSelectItem(guiele,preSelect[1],preSelect[2],not dgsGridListItemIsSelected(guiele,preSelect[1],preSelect[2]))
									elseif shift then
										if clicked and #clicked == 2 then
											dgsGridListSetSelectedItem(guiele,-1,-1)
											local startRow,endRow = mathMin(clicked[1],preSelect[1]),mathMax(clicked[1],preSelect[1])
											local startColumn,endColumn = mathMin(clicked[2],preSelect[2]),mathMax(clicked[2],preSelect[2])
											for row = startRow,endRow do
												for column = startColumn, endColumn do
													dgsGridListSelectItem(guiele,row,column,true)
												end
											end
											eleData.itemClick = clicked
										end
									else
										dgsGridListSetSelectedItem(guiele,preSelect[1],preSelect[2])
										eleData.itemClick = preSelect
									end
								else
									dgsGridListSetSelectedItem(guiele,preSelect[1],preSelect[2])
									eleData.itemClick = preSelect
								end
							end
						end
					end
				end
			end
		end
		if not isElement(guiele) then return end
		if GirdListDoubleClick[state] and isTimer(GirdListDoubleClick[state].timer) then
			local clicked = eleData.itemClick
			local selectionMode = eleData.selectionMode
			if dgsGetType(guiele) == "dgs-dxgridlist" and GirdListDoubleClick[state].gridlist == guiele and GirdListDoubleClick[state].but == button then
				local pass = true
				if selectionMode == 1 then
					if GirdListDoubleClick[state].item ~= clicked[1] then
						pass = false
					end
				elseif selectionMode == 2 then
					if GirdListDoubleClick[state].column ~= clicked[2] then
						pass = false
					end
				elseif selectionMode == 3 then
					if GirdListDoubleClick[state].item ~= clicked[1] or GirdListDoubleClick[state].column ~= clicked[2] then
						pass = false
					end
				end
				if pass then
					triggerEvent("onDgsGridListItemDoubleClick",guiele,GirdListDoubleClick[state].but,state,clicked[1],clicked[2])
				end
			end
			killTimer(GirdListDoubleClick[state].timer)
			GirdListDoubleClick[state] = {}
		else
			if GirdListDoubleClick[state] then
				if isTimer(GirdListDoubleClick[state].timer) then
					killTimer(GirdListDoubleClick[state].timer)
				end
			end
			if dgsGetType(guiele) == "dgs-dxgridlist" then
				local clicked = eleData.itemClick
				if clicked[1] ~= -1 and clicked[2] ~= -1 then
					GirdListDoubleClick[state] = {}
					GirdListDoubleClick[state].item,GirdListDoubleClick[state].column = clicked[1],clicked[2]
					GirdListDoubleClick[state].gridlist = guiele
					GirdListDoubleClick[state].but = button
					GirdListDoubleClick[state].timer = setTimer(function()
						GirdListDoubleClick[state].gridlist = false
					end,multiClick.Interval,1)
				end
			end
		end

		if not isElement(guiele) then return end
		if state == "up" then
			if button == "left" then
				if MouseData.clickl == guiele then
					triggerEvent("onDgsMouseClick",guiele,button,state,mouseX,mouseY,isCoolingDown)
				end
			elseif button == "right" then
				if MouseData.clickr == guiele then
					triggerEvent("onDgsMouseClick",guiele,button,state,mouseX,mouseY,isCoolingDown)
				end
			else
				triggerEvent("onDgsMouseClick",guiele,button,state,mouseX,mouseY,isCoolingDown)
			end
		else
			triggerEvent("onDgsMouseClick",guiele,button,state,mouseX,mouseY,isCoolingDown)
		end
		if not isElement(guiele) then return end
		if state == "down" then
			triggerEvent("onDgsMouseDown",guiele,button,mouseX,mouseY,isCoolingDown)
		elseif state == "up" then
			triggerEvent("onDgsMouseUp",guiele,button,mouseX,mouseY,isCoolingDown)
		end
		if not isElement(guiele) then return end
		if isTimer(multiClick[button][state][3]) then killTimer(multiClick[button][state][3]) end
		if multiClick[button][state][1] == 0 then multiClick[button][state][2] = guiele end
		if multiClick[button][state][2] == guiele then
			multiClick[button][state][1] = multiClick[button][state][1]+1
			if multiClick[button][state][1] == 2 then
				triggerEvent("onDgsMouseDoubleClick",guiele,button,state,mouseX,mouseY)
			end
			triggerEvent("onDgsMouseMultiClick",guiele,button,state,mouseX,mouseY,multiClick[button][state][1])
			multiClick[button][state][3] = setTimer(function(button,state)
				multiClick[button][state] = {0,false,false}
			end,multiClick.Interval,1,button,state)
		else
			multiClick[button][state] = {0,false,false}
		end
		if not isElement(guiele) then return end

	elseif state == "down" then
		if dgsType == "dgs-dxedit" or dgsType == "dgs-dxmemo" then
			blurEditMemo()
		end
		if isElement(MouseData.focused) then
			triggerEvent("onDgsBlur",MouseData.focused,false)
		end
	end
	if state == "up" then
		if button == "left" then
			MouseData.clickl = false
			MouseData.lock3DInterface = false
			MouseData.MoveScroll[0] = false
			
			if dgsDragDropBoard[0] then
				local data = dgsRetrieveDragNDropData()
				if isElement(guiele) and dgsElementData[guiele].dropHandler then
					triggerEvent("onDgsDrop",guiele,data)
				end
			end
		elseif button == "right" then
			MouseData.clickr = false
		end
		MouseData.Move[0] = false
		MouseData.MoveScale[0] = false
		MouseData.Scale[0] = false
		MouseData.scbClickData = nil
		MouseData.selectorClickData = nil
	end
	if state == "down" then
		if isElement(guiele) then
			MouseData.clickPosition[button][0] = true
			local posX,posY = dgsGetPosition(guiele,false,true)
			MouseData.clickPosition[button][1] = mouseX
			MouseData.clickPosition[button][2] = mouseY
		end
	else
		MouseData.clickPosition[button][0] = false
	end
end)

addEventHandler("onDgsPositionChange",root,function(oldx,oldy)
	local parent = dgsGetParent(source)
	if isElement(parent) and dgsGetType(parent) == "dgs-dxscrollpane" then
		resizeScrollPane(parent,source)
	end
	local children = ChildrenTable[source] or {}
	local childrenCnt = #children
	for k=1,childrenCnt do
		local child = children[k]
		local relt = dgsElementData[child].relative
		if relt then
			local relativePos = relt[1]
			local x,y = dgsElementData[child].absPos[1],dgsElementData[child].absPos[2]
			if relativePos then
				x,y = dgsElementData[child].rltPos[1],dgsElementData[child].rltPos[2]
			end
			calculateGuiPositionSize(child,x,y,relativePos)
		end
	end
	local attachedBy = dgsElementData[source].attachedBy
	if attachedBy then
		local absx,absy = dgsGetPosition(source,false,true)
		local absw,absh = dgsElementData[source].absSize[1],dgsElementData[source].absSize[2]
		for i=1,#attachedBy do
			local attachSource = attachedBy[i]
			local attachedTable = dgsElementData[attachSource].attachedTo
			local relativePos = attachedTable[4]
			local offsetX,offsetY = relativePos and (absx+absw*attachedTable[2])/sW or attachedTable[2]+absx, relativePos and (absy+absh*attachedTable[3])/sH or attachedTable[3]+absy
			calculateGuiPositionSize(attachSource,offsetX,offsetY,relativePos)
		end
	end
end)

addEventHandler("onDgsSizeChange",root,function(oldSizeAbsx,oldSizeAbsy)
	local children = ChildrenTable[source] or {}
	local childrenCnt = #children
	for k=1,childrenCnt do
		local child = children[k]
		if dgsElementType[child] ~= "dgs-dxtab" then
			local relt = dgsElementData[child].relative
			local relativePos,relativeSize = relt[1],relt[2]
			local x,y,sx,sy
			if relativePos then
				x,y = dgsElementData[child].rltPos[1],dgsElementData[child].rltPos[2]
			end
			if relativeSize then
				sx,sy = dgsElementData[child].rltSize[1],dgsElementData[child].rltSize[2]
			end
			calculateGuiPositionSize(child,x,y,relativePos,sx,sy,relativeSize)
		end
	end
	local typ = dgsGetType(source)
	local absSize = dgsElementData[source].absSize
	if absSize[1] ~= oldSizeAbsx or absSize[2] ~= oldSizeAbsy then
		if typ == "dgs-dxgridlist" then
			configGridList(source)
		elseif typ == "dgs-dxedit" then
			configEdit(source)
		elseif typ == "dgs-dxscrollpane" then
			configScrollPane(source)
		elseif typ == "dgs-dxtabpanel" then
			configTabPanel(source)
		elseif typ == "dgs-dxcombobox-Box" then
			configComboBox(dgsElementData[source].myCombo)
		elseif typ == "dgs-dxmemo" then
			dgsSetData(source,"configNextFrame",true)
		end
		local parent = dgsGetParent(source)
		if isElement(parent) then
			if dgsGetType(parent) == "dgs-dxscrollpane" then
				resizeScrollPane(source,parent)
			end
		end
	end
	local attachedBy = dgsElementData[source].attachedBy
	if attachedBy then
		local absw,absh = dgsElementData[source].absSize[1],dgsElementData[source].absSize[2]
		for i=1,#attachedBy do
			local attachSource = attachedBy[i]
			local attachedTable = dgsElementData[attachSource].attachedTo
			local sizeRlt = attachedTable[7]
			local offsetW,offsetH = attachedTable[5],attachedTable[6]
			offsetW,offsetH = sizeRlt and absw*offsetW or offsetW, sizeRlt and absh*offsetH or offsetH
			offsetW,offsetH = sizeRlt and offsetW/sW or offsetW,sizeRlt and offsetH/sH or offsetH
			calculateGuiPositionSize(attachSource,_,_,_,offsetW,offsetH,sizeRlt)
		end
	end
end)