dgsLogLuaMemory()
local loadstring = loadstring
focusBrowser()
------------Copyrights thisdp's DirectX Graphical User Interface System
--Speed Up
local mathAbs = math.abs
local mathFloor = math.floor
local mathCeil = math.ceil
local mathMin = math.min
local mathMax = math.max
local mathClamp = math.clamp
local mathLerp = math.lerp
local tocolor = tocolor
--Dx Functions
local dxDrawLine = dxDrawLine
local dxDrawImage = dxDrawImage
local dxDrawImageSection = dxDrawImageSection
local dgsDrawText = dgsDrawText
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
local dgsTriggerEvent = dgsTriggerEvent
local insertResource = insertResource
local dgsAddEventHandler = dgsAddEventHandler
local unpack = unpack
local tostring = tostring
local tonumber = tonumber
local type = type
local isElement = isElement
local _getElementID = getElementID
local getElementID = function(ele) return isElement(ele) and _getElementID(ele) or tostring(ele) end
----
self,renderArguments = false,{}
----
if not getColorFilter then	--For old MTA version
	function getColorFilter()
		return 255,255,255,255,127,255,255,127
	end
end
----
function dgsGetRenderSetting(name) return dgsRenderSetting[name] end

function dgsSetRenderSetting(name,value)
	if name == "renderPriority" then
		if type(value) == "number" then
			if value > 0 then
				value = "normal+"..value
			elseif value < 0 then
				value = "normal"..value
			else
				value = "normal"
			end
		end
		assert(type(value)=="string","Bad Argument @dgsSetRenderSetting at argument 2, expected a string/number got "..dgsGetType(value))
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
	focusedChain = {},
	focused = false,
	hit = false,
	entered = false,
	left = false,
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
	click = {
		left = false,
		right = false,
		middle = false,
	},
	scbEnterData = false,
	scbEnterDataDynamic = false,
	scbEnterRltPos = false,
	topScrollable = false,
	lastPos = {-1,-1},
	visibleLastFrame = false,
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

--Render
function dgsAddToBackEndRenderList(dgsEle)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsAddToBackEndRenderList",1,"dgs-dxelement")) end
	local pluginType = dgsGetPluginType(dgsEle)
	local dgsType = dgsGetType(dgsEle)
	if not(dgsBackEndRenderer[pluginType] or dgsBackEndRenderer[dgsType]) then error(dgsGenAsrt(dgsEle,"dgsAddToBackEndRenderList",1,_,_,_,"Type "..pluginType.." ("..dgsType..") doesn't have back-end renderer")) end
	local id = table.find(BackEndTable,dgsEle)
	if not id then
		BackEndTable[#BackEndTable+1] = dgsEle
	end
	return true
end

function dgsRemoveFromBackEndRenderList(dgsEle)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsRemoveFromBackEndRenderList",1,"dgs-dxelement")) end
	local id = table.find(BackEndTable,dgsEle)
	if id then
		table.remove(BackEndTable,id)
	end
	return true
end

addEventHandler("onClientRestore",root,function()
	dgsRenderInfo.RTRestoreNeed = true	--RT is not working when minimized, force to restore the draw result is needed.
end)

cameraPos = {0,0,0}
colorFilter = {127,127,127}
function dgsCoreRender()
	dgsRenderInfo.frames = dgsRenderInfo.frames+1
	dgsRenderInfo.frameStartScreen = getTickCount()
	dgsRenderInfo.rendering = 0
	local frameStart3DOnScreen,frameEnd3DOnScreen = 0,0
	MouseData.cursorPos3D[0] = false
	local mx,my
	local cursorShowing = dgsGetCursorVisible()
	if cursorShowing then
		mx,my = dgsGetCursorPosition(_,_,true)
		MouseData.cursorPosScr[0],MouseData.cursorPosScr[1],MouseData.cursorPosScr[2] = true,mx,my
		MouseData.cursorPosWld[0],MouseData.cursorPosWld[1],MouseData.cursorPosWld[2] = true,mx,my
		MouseData.cursorPos3D[0],MouseData.cursorPos3D[1],MouseData.cursorPos3D[2],MouseData.cursorPos3D[3] = true,getWorldFromScreenPosition(mx,my,1)
	end
	if MouseData.visibleLastFrame ~= cursorShowing then
		if not cursorShowing then
			MouseData.MoveScroll[0] = false
			MouseData.scbClickData = false
			MouseData.selectorClickData = false
			MouseData.lock3DInterface = false
			MouseData.click.left = false
			MouseData.click.right = false
			MouseData.click.middle = false
			MouseData.Scale[0] = false
			MouseData.Move[0] = false
			MouseData.Move[3] = nil
			MouseData.MoveScale[0] = false
			MouseData.cursorPosWld[0] = false
			MouseData.cursorPosScr[0] = false
			MouseData.cursorPos[0] = false
			MouseData.entered = false
		end
		MouseData.visibleLastFrame = cursorShowing
	end
	if isElement(BlurBoxGlobalScreenSource) then
		dxUpdateScreenSource(BlurBoxGlobalScreenSource,true)
	end
	if isElement(GlobalScreenSource) then
		dxUpdateScreenSource(GlobalScreenSource,true)
	end
	MouseData.cursorPos[1],MouseData.cursorPos[2] = mx,my
	MouseData.hit = false
	MouseData.hitDebug = false
	if #BottomRootTable+#CenterRootTable+#TopRootTable+#BackEndTable+#dgsWorld3DTable+#dgsScreen3DTable ~= 0 then
		local preBlendMode = dxGetBlendMode()
		--Animation Processing
		onAnimQueueProcess()
		----
		dxSetRenderTarget()
		--Back-End Renderer
		for i=1,#BackEndTable do
			local v = BackEndTable[i]
			local eleData = dgsElementData[v]
			local asPlugin = eleData.asPlugin
			local eleType = dgsElementType[v]
			dxSetBlendMode(eleData.blendMode)
			local dgsRendererFunction = dgsBackEndRenderer[asPlugin or eleType]
			if dgsRendererFunction then
				dgsRendererFunction(v)
			end
		end
		dxSetBlendMode(preBlendMode)
		--
		frameStart3DOnScreen = getTickCount()
		MouseData.hitData3D[0] = false
		MouseData.topScrollable = false
		local dimension = getElementDimension(localPlayer)
		local interior = getCameraInterior()
		MouseData.WithinElements = {}
		if #dgsWorld3DTable+#dgsScreen3DTable ~= 0 then
			cameraPos[1],cameraPos[2],cameraPos[3] = getCameraMatrix()
		end
		for i=1,#dgsWorld3DTable do
			local v = dgsWorld3DTable[i]
			local eleData = dgsElementData[v]
			local selfDimen = eleData.dimension
			if (selfDimen == -1 or selfDimen == dimension) and (eleData.interior == -1 or eleData.interior == interior) then
				dxSetBlendMode(eleData.blendMode)
				renderGUI(v,mx,my,eleData.enabled,eleData.enabled,eleData.mainRT,0,0,0,0,0,0,1,MouseData.click.left)
			end
		end
		dxSetBlendMode(preBlendMode)
		dxSetRenderTarget()
		for i=1,#dgsScreen3DTable do
			local v = dgsScreen3DTable[i]
			local eleData = dgsElementData[v]
			local selfDimen = eleData.dimension
			if (selfDimen == -1 or selfDimen == dimension) and (eleData.interior == -1 or eleData.interior == interior) then
				renderGUI(v,mx,my,eleData.enabled,eleData.enabled,nil,0,0,0,0,0,0,1)
			end
		end

		local hit3D = MouseData.hit
		MouseData.hit = false
		frameEnd3DOnScreen = getTickCount()

		MouseData.hitData2D[0] = false
		for i=1,#BottomRootTable do
			local v = BottomRootTable[i]
			local eleData = dgsElementData[v]
			renderGUI(v,mx,my,eleData.enabled,eleData.enabled,nil,0,0,0,0,0,0,1)
		end
		for i=1,#CenterRootTable do
			local v = CenterRootTable[i]
			local eleData = dgsElementData[v]
			local enabled = eleData.enabled
			renderGUI(v,mx,my,enabled,enabled,nil,0,0,0,0,0,0,1)
		end
		for i=1,#TopRootTable do
			local v = TopRootTable[i]
			local eleData = dgsElementData[v]
			renderGUI(v,mx,my,eleData.enabled,eleData.enabled,nil,0,0,0,0,0,0,1)
		end
		local hit2D = MouseData.hit

		if isElement(hit2D) then
			MouseData.cursorPos[0] = true
			MouseData.cursorPos[1] = dgsElementData[hit2D].cursorPosition[1]
			MouseData.cursorPos[2] = dgsElementData[hit2D].cursorPosition[2]
			MouseData.hitData2D[0] = true
			MouseData.hitData2D[1] = MouseData.cursorPos[1]
			MouseData.hitData2D[2] = MouseData.cursorPos[2]
			MouseData.hitData2D[3] = hit2D
		elseif isElement(hit3D) then
			MouseData.cursorPos[0] = true
			MouseData.cursorPos[1] = dgsElementData[hit3D].cursorPosition[1]
			MouseData.cursorPos[2] = dgsElementData[hit3D].cursorPosition[2]
		else
			hit2D = nil
			hit3D = nil
		end
		MouseData.hit = hit2D or hit3D
		dxSetRenderTarget()
		dgsTriggerEvent("onDgsRender",resourceRoot)
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
		dgsCheckHit(MouseData.hit,cursorShowing)
		----Drag Drop
		if dgsDragDropBoard[0] then
			local preview = dgsDragDropBoard.preview
			local align = dgsDragDropBoard.previewAlignment
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
		dgsRenderInfo.RTRestoreNeed = false
	end
	----Debug stuff
	dgsRenderInfo.frameEndScreen = getTickCount()
	if debugMode then
		dgsRenderInfo.frameRenderTimeScreen = dgsRenderInfo.frameEndScreen-dgsRenderInfo.frameStartScreen-(frameEnd3DOnScreen-frameStart3DOnScreen)
		dgsRenderInfo.frameRenderTime3D = (dgsRenderInfo.frameEnd3D or getTickCount())-(dgsRenderInfo.frameStart3D or getTickCount())+(frameEnd3DOnScreen-frameStart3DOnScreen)
		dgsRenderInfo.frameRenderTimeTotal = dgsRenderInfo.frameRenderTimeScreen+dgsRenderInfo.frameRenderTime3D
		local debugHitElement = checkDisabledElement and MouseData.hitDebug or MouseData.hit
		if isElement(debugHitElement) and debugMode >= 2 then
			local highlight = debugHitElement
			if dgsElementType[debugHitElement] == "dgs-dxtab" then
				highlight = dgsElementData[highlight].parent
			end
			if dgsGetType(highlight) ~= "dgs-dx3dinterface" and dgsGetType(highlight) ~= "dgs-dx3dtext" then
				local absX,absY = dgsGetPosition(highlight,false)
				local rltX,rltY = dgsGetPosition(highlight,true)
				local absW,absH = dgsGetSize(highlight,false)
				local rltW,rltH = dgsGetSize(highlight,true)
				dgsDrawText("ABS X: "..absX , sW*0.5-100,10,sW,sH,white,1,1,"default","left","top",false,false,true,true,false,0,0,0,0,1,1,black)
				dgsDrawText("ABS Y: "..absY , sW*0.5-100,25,sW,sH,white,1,1,"default","left","top",false,false,true,true,false,0,0,0,0,1,1,black)
				dgsDrawText("RLT X: "..rltX , sW*0.5-100,40,sW,sH,white,1,1,"default","left","top",false,false,true,true,false,0,0,0,0,1,1,black)
				dgsDrawText("RLT Y: "..rltY , sW*0.5-100,55,sW,sH,white,1,1,"default","left","top",false,false,true,true,false,0,0,0,0,1,1,black)
				dgsDrawText("ABS W: "..absW , sW*0.5-100,70,sW,sH,white,1,1,"default","left","top",false,false,true,true,false,0,0,0,0,1,1,black)
				dgsDrawText("ABS H: "..absH , sW*0.5-100,85,sW,sH,white,1,1,"default","left","top",false,false,true,true,false,0,0,0,0,1,1,black)
				dgsDrawText("RLT W: "..rltW , sW*0.5-100,100,sW,sH,white,1,1,"default","left","top",false,false,true,true,false,0,0,0,0,1,1,black)
				dgsDrawText("RLT H: "..rltH , sW*0.5-100,115,sW,sH,white,1,1,"default","left","top",false,false,true,true,false,0,0,0,0,1,1,black)
				local debugData = dgsElementData[highlight].debugData
				if debugData then
					local sideColor = tocolor(dgsHSVToRGB(getTickCount()%3600/10,100,50))
					local sideSize = math.sin(getTickCount()/500%2*math.pi)*2+4
					local hSideSize = sideSize*0.5
					local x,y,w,h = debugData[5],debugData[6],absW,absH
					dxDrawLine(x-sideSize,y-hSideSize,x+w+sideSize-1,y-hSideSize,sideColor,sideSize,isPostGUI)
					dxDrawLine(x-hSideSize,y,x-hSideSize,y+h,sideColor,sideSize,isPostGUI)
					dxDrawLine(x+w+hSideSize-1,y,x+w+hSideSize-1,y+h,sideColor,sideSize,isPostGUI)
					dxDrawLine(x-sideSize,y+h+hSideSize-1,x+w+sideSize-1,y+h+hSideSize-1,sideColor,sideSize,isPostGUI)
				end
			end
			local parent = debugHitElement
			dgsDrawText("Parent List:", sW*0.5+90,10,sW,sH,white,1,1,"default","left","top",false,false,true,true,false,0,0,0,0,1,1,black)
			dgsDrawText("DGS Root("..tostring(resourceRoot)..")", sW*0.5+100,25,sW,sH,white,1,1,"default","left","top",false,false,true,true,false,0,0,0,0,1,1,black)
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
				dgsDrawText("↑"..dgsGetPluginType(p).."("..tostring(p)..") "..debugStr, sW*0.5+100,25+i*15,sW,sH,white,1,1,"default","left","top",false,false,true,true,false,0,0,0,0,1,1,black)
			end
		end
		local version = getElementData(resourceRoot,"Version") or "?"
		local freeMemory = " | Free VMemory: "..(dxGetStatus().VideoMemoryFreeForMTA).."M" or "N/A"

		dgsDrawText("DGS "..version..freeMemory,5,sH*0.4-160,sW,sH,white,1,1,"default","left","top",false,false,true,true,false,0,0,0,0,1,1,black)
		local renderTimeStr = dgsRenderInfo.frameRenderTimeTotal.."ms-"..dgsRenderInfo.frameRenderTimeScreen.."ms-"..dgsRenderInfo.frameRenderTime3D.."ms"
		local tickColor
		if dgsRenderInfo.frameRenderTimeTotal <= 8 then
			tickColor = green
		elseif dgsRenderInfo.frameRenderTimeTotal <= 20 then
			tickColor = yellow
		else
			tickColor = red
		end
		dgsDrawText("CPU Time(All-2D-3D): "..renderTimeStr,5,sH*0.4-145,sW,sH,tickColor,1,1,"default","left","top",false,false,true,true,false,0,0,0,0,1,1,black)
		local Focused = MouseData.focused and dgsGetPluginType(MouseData.focused).."("..getElementID(MouseData.focused)..")" or "None"
		local enterStr = MouseData.hit and dgsGetPluginType(MouseData.hit).." ("..getElementID(MouseData.hit)..")" or "None"
		local leftStr = MouseData.click.left and dgsGetPluginType(MouseData.click.left).." ("..getElementID(MouseData.click.left)..")" or "None"
		local middleStr = MouseData.click.middle and dgsGetPluginType(MouseData.click.middle).." ("..getElementID(MouseData.click.middle)..")" or "None"
		local rightStr = MouseData.click.right and dgsGetPluginType(MouseData.click.right).." ("..getElementID(MouseData.click.right)..")" or "None"
		dgsDrawText("Cursor Pos On Screen: "..(mx or "Hidden")..","..(my or "Hidden"),10,sH*0.4-130,sW,sH,white,1,1,"default","left","top",false,false,true,true,false,0,0,0,0,1,1,black)
		local cursorPosDGS = MouseData.cursorPos
		dgsDrawText("Cursor Pos DGS: "..(cursorPosDGS[0] and cursorPosDGS[1]-cursorPosDGS[1]%1 or "Hidden")..","..(cursorPosDGS[0] and cursorPosDGS[2]-cursorPosDGS[2]%1 or "Hidden"),10,sH*0.4-115,sW,sH,white,1,1,"default","left","top",false,false,true,true,false,0,0,0,0,1,1,black)
		dgsDrawText("Focused: "..Focused,10,sH*0.4-100,sW,sH,white,1,1,"default","left","top",false,false,true,true,false,0,0,0,0,1,1,black)
		dgsDrawText("Enter: "..enterStr,10,sH*0.4-85,sW,sH,white,1,1,"default","left","top",false,false,true,true,false,0,0,0,0,1,1,black)
		dgsDrawText("Click:",10,sH*0.4-70,sW,sH,white,1,1,"default","left","top",false,false,true,true,false,0,0,0,0,1,1,black)
		dgsDrawText("L: "..leftStr,40,sH*0.4-70,sW,sH,white,1,1,"default","left","top",false,false,true,true,false,0,0,0,0,1,1,black)
		dgsDrawText("M: "..middleStr,40,sH*0.4-55,sW,sH,white,1,1,"default","left","top",false,false,true,true,false,0,0,0,0,1,1,black)
		dgsDrawText("R: "..rightStr,40,sH*0.4-40,sW,sH,white,1,1,"default","left","top",false,false,true,true,false,0,0,0,0,1,1,black)
		dgsRenderInfo.created = 0
		local index = 1
		for value in pairs(dgsType) do
			local elements = #getElementsByType(value)
			dgsRenderInfo.created = dgsRenderInfo.created+elements
			dgsDrawText(value.." : "..elements,15,sH*0.4-15+15*index+5,sW,sH,white,1,1,"default","left","top",false,false,true,true,false,0,0,0,0,1,1,black)
			index = index+1
		end
		dgsDrawText("Rendering: "..dgsRenderInfo.rendering,10,sH*0.4-25,sW,sH,green,1,1,"default","left","top",false,false,true,true,false,0,0,0,0,1,1,black)
		dgsDrawText("Created: "..dgsRenderInfo.rendering,10,sH*0.4-10,sW,sH,yellow,1,1,"default","left","top",false,false,true,true,false,0,0,0,0,1,1,black)
		dgsRenderInfo.runningAnimation = #animQueue
		dgsDrawText("Running Animations: "..dgsRenderInfo.runningAnimation,300,sH*0.4-115,sW,sH,white,1,1,"default","left","top",false,false,true,true,false,0,0,0,0,1,1,black)
		ResCount = 0
		for ka,va in pairs(boundResource) do
			if type(ka) == "userdata" and va then
				local resDGSCnt = 0
				for ele in pairs(va) do
					if dgsType[dgsGetType(ele)] then
						resDGSCnt = resDGSCnt+1
					end
				end
				if resDGSCnt ~= 0 then
					ResCount = ResCount +1
					dgsDrawText(getResourceName(ka).." : #00FF00"..(dgsRenderInfo.renderingResource[ka] or 0).."#FFFFFF/#FFFF00"..resDGSCnt,300,sH*0.4-100+15*ResCount,sW,sH,white,1,1,"default","left","top",false,false,true,true,false,0,0,0,0,1,1,black)
				end
			end
			dgsRenderInfo.renderingResource[ka] = 0
		end
		dgsDrawText("Resource("..ResCount..") Elements: #00FF00Rendering #FFFFFF/ #FFFF00Created",300,sH*0.4-100,sW,sH,white,1,1,"default","left","top",false,false,true,true,false,0,0,0,0,1,1,black)
	end
end

function renderGUI(source,mx,my,enabledInherited,enabledSelf,rndtgt,xRT,yRT,xNRT,yNRT,OffsetX,OffsetY,parentAlpha)
	local eleData = dgsElementData[source]
	local visible = eleData.visible
	local visibleInherited = eleData.visibleInherited
	if visible and visibleInherited and isElement(source) then
		if debugMode then	--Debug Mode
			dgsRenderInfo.rendering = dgsRenderInfo.rendering+1
			if eleData.resource then
				dgsRenderInfo.renderingResource[eleData.resource] = (dgsRenderInfo.renderingResource[eleData.resource] or 0)+1
			end
		end
		enabledSelf = eleData.enabled								--Seld enabled
		enabledInherited = enabledInherited and eleData.enabledInherited and enabledSelf	--Enabled inherited
		local eleType = dgsElementType[source]							--Element type of current element
		local parent = dgsElementData[source].parent					--Parent
		local children = dgsElementData[source].children				--Children
		rndtgt = isElement(rndtgt) and rndtgt or false			--Parent render target
		dxSetRenderTarget(rndtgt)										--Use parent render target
		local globalBlendMode = rndtgt and "modulate_add" or "blend"	--Blend mode by default
		dxSetBlendMode(globalBlendMode)									--Apply blend mode
		local dgsPreRendererFunction = dgsPreRenderer[eleType]
		if dgsPreRendererFunction then dgsPreRendererFunction(source) end	--Process something before render

		--Apply parent alpha
		if eleType == "dgs-dxscrollbar" then							--For scrollpane	(should be optimised soon)
			local attachedToParent = eleData.attachedToParent
			if isElement(attachedToParent) and dgsElementData[attachedToParent] then
				if not dgsElementData[attachedToParent].visible then return end
				parentAlpha = parentAlpha*dgsElementData[attachedToParent].alpha
			end
		end
		parentAlpha = (eleData.alpha or 1)*parentAlpha					--Apply parent alpha with element alpha

		--Process Position Alignment
		local eleTypeP,eleDataP
		local elePAlignH,elePAlignV
		if parent then
			eleTypeP,eleDataP = dgsElementType[parent],dgsElementData[parent]
			elePAlignH,elePAlignV = dgsElementData[parent].contentPositionAlignment[1],dgsElementData[parent].contentPositionAlignment[2]
		end

		local absX,absY,absW,absH
		local absPos,absSize = eleData.absPos,eleData.absSize
		if not absPos then absX,absY = 0,0 else absX,absY = absPos[1],absPos[2] end
		if not absSize then absW,absH = 0,0 else absW,absH = absSize[1],absSize[2] end
		local PosX,PosY,w,h = absX,absY,absW,absH
		local eleAlign = eleData.positionAlignment
		local eleAlignH,eleAlignV = eleAlign[1] or elePAlignH, eleAlign[2] or elePAlignV
		if eleAlignH == "right" then	--Horizontal
			local pWidth = parent and eleDataP.absSize[1] or sW
			PosX = pWidth-PosX-eleData.absSize[1]
		elseif eleAlignH == "center" then
			local pWidth = parent and eleDataP.absSize[1] or sW
			PosX = PosX+pWidth/2-eleData.absSize[1]/2
		end
		if eleAlignV == "bottom" then --Vertical
			local pHeight = parent and eleDataP.absSize[2] or sH
			PosY = pHeight-PosY-eleData.absSize[2]
		elseif eleAlignV == "center" then
			local pHeight = parent and eleDataP.absSize[2] or sH
			PosY = PosY+pHeight/2-eleData.absSize[2]/2
		end

		if eleTypeP == "dgs-dxwindow" and eleData.ignoreParentTitle then OffsetY = 0 end
		local x,y = PosX+OffsetX,PosY+OffsetY
		OffsetX,OffsetY = 0,0
		xRT,yRT,xNRT,yNRT = xRT+x,yRT+y,xNRT+x,yNRT+y
		local isPostGUI = (not debugMode) and (not rndtgt)
		if eleData.postGUI == nil then
			isPostGUI = isPostGUI and dgsRenderSetting.postGUI
		else
			isPostGUI = isPostGUI and eleData.postGUI
		end
		if eleDataP and eleDataP.mainRT == rndtgt and rndtgt then xRT,yRT = x,y end
		self = source
		renderArguments[1],renderArguments[2] = xRT,yRT
		renderArguments[3],renderArguments[4] = w,h
		renderArguments[5],renderArguments[6] = xNRT,yNRT
		local disableOutline
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
		local daDebugColor,daDebugTexture = 0xFFFFFF,nil
		local dgsRendererFunction = dgsRenderer[eleType]
		if dgsRendererFunction then
			local _hitElement
			if (enabledInherited or checkDisabledElement) and mx and eleType ~= "dgs-dxdetectarea" then
				local collider = eleData.dgsCollider
				if collider and dgsElementType[collider] == "dgs-dxdetectarea" then
					local daEleData = dgsElementData[collider]
					local checkPixel = daEleData.checkFunction
					if checkPixel then
						local _mx,_my = (mx-xNRT)/w,(my-yNRT)/h
						if _mx > 0 and _my > 0 and _mx <= 1 and _my <= 1 then
							if type(checkPixel) == "function" then
								local checkFnc = daEleData.checkFunction
								if checkFnc(_mx,_my,mx,my,xNRT,yNRT,w,h) then
									if enabledInherited then
										MouseData.hit = source
									elseif checkDisabledElement then
										MouseData.hitDebug = source
									end
									daDebugColor = 0xFF0000
								end
							else
								local px,py = dxGetPixelsSize(checkPixel)
								local pixX,pixY = _mx*px,_my*py
								local r,g,b = dxGetPixelColor(checkPixel,pixX-1,pixY-1)
								local gray = ((r or 0)+(g or 0)+(b or 0))/3
								if gray >= 128 then
									if enabledInherited then
										MouseData.hit = source
									elseif checkDisabledElement then
										MouseData.hitDebug = source
									end
									daDebugColor = 0xFF0000
								end
							end
						end
						daDebugTexture = daEleData.debugTexture
						daDebugColor = daEleData.debugModeAlpha*0x1000000+daDebugColor
					end
				else
					hit = (dgsCollider[eleType] or dgsCollider.default)(source,mx,my,xNRT,yNRT,w,h) or MouseData.hit
					if enabledInherited then
						MouseData.hit = hit or MouseData.hit
					elseif checkDisabledElement then
						MouseData.hitDebug = hit or MouseData.hitDebug
					end
				end
				if eleType == "dgs-dxgridlist" then
					_hitElement = MouseData.hit
				end
			end
			if MouseData.hit then
				if _hitElement and _hitElement ~= MouseData.hit then
					local scbThickV = dgsElementData[ eleData.scrollbars[1] ].visible and eleData.scrollBarThick or 0
					local scbThickH = dgsElementData[ eleData.scrollbars[2] ].visible and eleData.scrollBarThick or 0
					if mx > xNRT+w-scbThickH or my > yNRT+h-scbThickV then
						MouseData.hit = source
					end
				end
				MouseData.WithinElements[MouseData.hit] = true
			end
			local parentOffsetX,parentOffsetY
			rt,disableOutline,mx,my,parentOffsetX,parentOffsetY = dgsRendererFunction(source,xRT,yRT,w,h,mx,my,xNRT,yNRT,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt,xRT,yRT,xNRT,yNRT,OffsetX,OffsetY,visible)
			if MouseData.hit == source then
				eleData.cursorPosition[0] = dgsRenderInfo.frames
				eleData.cursorPosition[1],eleData.cursorPosition[2] = mx,my
			end
			if debugMode and isElement(source) then
				if not dgsElementData[source].debugData then dgsElementData[source].debugData = {} end
				dgsElementData[source].debugData[1] = x
				dgsElementData[source].debugData[2] = y
				dgsElementData[source].debugData[3] = w
				dgsElementData[source].debugData[4] = h
				dgsElementData[source].debugData[5] = xNRT
				dgsElementData[source].debugData[6] = yNRT
				if daDebugTexture then __dxDrawImage(xRT,yRT,w,h,daDebugTexture,0,0,0,daDebugColor,isPostGUI) end
			end
			rndtgt = rt or rndtgt
			OffsetX,OffsetY = parentOffsetX or OffsetX,parentOffsetY or OffsetY
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
					if outlineData[4] ~= false then dxDrawLine(xRT+hSideSize,yRT,xRT+hSideSize,yRT+h,sideColor,sideSize,isPostGUI) end
					if outlineData[5] ~= false then dxDrawLine(xRT+w-hSideSize,yRT,xRT+w-hSideSize,yRT+h,sideColor,sideSize,isPostGUI) end
					if outlineData[6] ~= false then dxDrawLine(xRT,yRT+hSideSize,xRT+w,yRT+hSideSize,sideColor,sideSize,isPostGUI) end
					if outlineData[7] ~= false then dxDrawLine(xRT,yRT+h-hSideSize,xRT+w,yRT+h-hSideSize,sideColor,sideSize,isPostGUI) end
				elseif side == "center" then
					if outlineData[4] ~= false then dxDrawLine(xRT,yRT+hSideSize,xRT,yRT+h-hSideSize,sideColor,sideSize,isPostGUI) end
					if outlineData[5] ~= false then dxDrawLine(xRT+w,yRT+hSideSize,xRT+w,yRT+h-hSideSize,sideColor,sideSize,isPostGUI) end
					if outlineData[6] ~= false then dxDrawLine(xRT-hSideSize,yRT,xRT+w+hSideSize,yRT,sideColor,sideSize,isPostGUI) end
					if outlineData[7] ~= false then dxDrawLine(xRT-hSideSize,yRT+h,xRT+w+hSideSize,yRT+h,sideColor,sideSize,isPostGUI) end
				elseif side == "out" then
					if outlineData[4] ~= false then dxDrawLine(xRT-hSideSize,yRT,xRT-hSideSize,yRT+h,sideColor,sideSize,isPostGUI) end
					if outlineData[5] ~= false then dxDrawLine(xRT+w+hSideSize,yRT,xRT+w+hSideSize,yRT+h,sideColor,sideSize,isPostGUI) end
					if outlineData[6] ~= false then dxDrawLine(xRT-sideSize,yRT-hSideSize,xRT+w+sideSize,yRT-hSideSize,sideColor,sideSize,isPostGUI) end
					if outlineData[7] ~= false then dxDrawLine(xRT-sideSize,yRT+h+hSideSize,xRT+w+sideSize,yRT+h+hSideSize,sideColor,sideSize,isPostGUI) end
				end
			end
		end
		------------------------------------
		local oldMouseIn = eleData.rndTmp_mouseIn or false
		local newMouseIn = MouseData.hit and true or false
		if eleData.enableFullEnterLeaveCheck then
			if oldMouseIn ~= newMouseIn then
				eleData.rndTmp_mouseIn = newMouseIn
				dgsTriggerEvent("onDgsElement"..(newMouseIn and "Enter" or "Leave"),source,mx,my)
			end
		end
		if eleData.renderEventCall then
			dgsTriggerEvent("onDgsElementRender",source,xNRT,yNRT,w,h)
		end
		local childrenCnt = children and #children or 0
		if childrenCnt ~= 0 then
			if not eleData.childOutsideHit then
				if MouseData.hit ~= source then
					enabledInherited = false
				end
			end
			if dgsChildRenderer[eleType] then
				dgsChildRenderer[eleType](children,mx,my,enabledInherited,enabledSelf,rndtgt,xRT,yRT,xNRT,yNRT,OffsetX,OffsetY,parentAlpha,parentOffsetX,parentOffsetY)
			elseif dgsChildRenderer[eleType] == nil then
				for i=1,childrenCnt do
					renderGUI(children[i],mx,my,enabledInherited,enabledSelf,rndtgt,xRT,yRT,xNRT,yNRT,OffsetX,OffsetY,parentAlpha)
				end
			end
		end
		dxSetBlendMode("blend")
	end
end
addEventHandler("onClientRender",root,dgsCoreRender,false,dgsRenderSetting.renderPriority)

function dgsCore3DRender()	--This renderer will only be attached to onClientPreRender when there are 3d elements, because onClientPreRender is slow and only used to render 3d elements
	dgsRenderInfo.frameStart3D = getTickCount()
	local rendering3D = 0
	if #dgsWorld3DTable ~= 0 then
		cameraPos[1],cameraPos[2],cameraPos[3] = getCameraMatrix()
		local aR,aG,aB,aA,bR,bG,bB,bA = getColorFilter(false)							--Get current color filter
		colorFilter[1],colorFilter[2],colorFilter[3] = 127/255+(aR*aA+bR*bA)/65535*0.5, 127/255+(aG*aA+bG*bA)/65535*0.5, 127/255+(aB*aA+bB*bA)/65535*0.5	--Calculate the result color of color filter
		local dimension = getElementDimension(localPlayer)
		local interior = getCameraInterior()
		local preBlendMode = dxGetBlendMode()
		for i=1,#dgsWorld3DTable do
			local ele = dgsWorld3DTable[i]
			local dgsType = dgsElementType[ele]
			local eleData = dgsElementData[ele]
			local selfDimen = eleData.dimension
			if (selfDimen == -1 or selfDimen == dimension) and (eleData.interior == -1 or eleData.interior == interior) then
				dxSetBlendMode(eleData.blendMode)
				local visible = eleData.visible
				local visibleInherited = eleData.visibleInherited
				if visible and visibleInherited and isElement(ele) then
					if dgs3DRenderer[dgsType] and dgs3DRenderer[dgsType](ele) then
						rendering3D = rendering3D+1
					end
				end
			end
		end
		dxSetBlendMode(preBlendMode)
	end
	dgsRenderInfo.rendering3D = rendering3D
	dgsRenderInfo.frameEnd3D = getTickCount()
end

function dgsCore3DStartRender()
	addEventHandler("onClientPreRender",root,dgsCore3DRender,false)
end

function dgsCore3DStopRender()
	removeEventHandler("onClientPreRender",root,dgsCore3DRender)
	dgsRenderInfo.rendering3D = 0
	dgsRenderInfo.frameStart3D = 0
	dgsRenderInfo.frameEnd3D = 0
end

addEventHandler("onClientKey",root,function(button,state)
	if button == "mouse_wheel_up" or button == "mouse_wheel_down" then
		if isElement(MouseData.entered) then
			dgsTriggerEvent("onDgsMouseWheel",MouseData.entered,button == "mouse_wheel_down" and -1 or 1)
		end
		local scroll = button == "mouse_wheel_down" and 1 or -1
		local enteredElement = MouseData.topScrollable or MouseData.entered
		local dgsType = dgsGetType(enteredElement)
		if dgsOnMouseScrollAction[dgsType] then
			dgsOnMouseScrollAction[dgsType](enteredElement,button == "mouse_wheel_down")
		end
	elseif state then
		local dgsType = dgsGetType(MouseData.focused)
		if dgsType == "dgs-dxmemo" or dgsType == "dgs-dxedit" then
			if not button:find("mouse") then
				local typingSound = dgsElementData[MouseData.focused].typingSound
				if typingSound then
					local sound = playSound(typingSound)
					setSoundVolume(sound,tonumber(dgsElementData[MouseData.focused].typingSoundVolume) or 1)
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
	if isElement(MouseData.focused) then
		triggerEvent("onDgsKey",MouseData.focused,button,state)
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
				text = eleData.text
				local f,b = dgsSearchFullWordType(text,cpos,-1)
				dgsEditMoveCaret(edit,f-cpos,shift)
			else
				dgsEditMoveCaret(edit,-1,shift)
			end
		elseif button == "arrow_r" then
			if ctrl then
				local cpos = eleData.caretPos
				text = eleData.text
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
						text = eleData.text
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
						text = eleData.text
						local f,b = dgsSearchFullWordType(text,cpos,-1)
						dgsEditDeleteText(edit,f,cpos)
					else
						dgsEditDeleteText(edit,cpos-1,cpos)
					end
				end
			end
		elseif button == "c" or button == "x" and ctrl then
			if eleData.allowCopy and not eleData.masked then
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
		elseif button == dgsElementData[edit].autoCompleteConfirmKey then
			makeEventCancelled = true
			local autoCompleteShow = eleData.autoCompleteShow or {}
			if autoCompleteShow.result then
				dgsSetText(edit,autoCompleteShow.result)
			else
				if getKeyState("lshift") or getKeyState("lshift") then
					dgsTriggerEvent("onDgsEditPreSwitch",edit,true)
				else
					dgsTriggerEvent("onDgsEditPreSwitch",edit,false)
				end
			end
		elseif button == "a" and ctrl then
			dgsSetData(edit,"caretPos",0)
			text = eleData.text
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
	elseif dgsGetType(MouseData.focused) == "dgs-dxgridlist" then--todo
		local gridlist = MouseData.focused
		if eleData.enableNavigation and eleData.visible and eleData.enabled then
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
	if not cursorShowing then
		if CursorData.enabled and CursorData[MouseData.cursorType] then
			setCursorAlpha(255)
		end
		return false
	end
	local enteredElementType = dgsGetType(MouseData.entered)
	local clickedElement
	local clickedButton
	if isElement(MouseData.click.left) then
		local mouseButtons = dgsElementData[MouseData.click.left].mouseButtons
		if not mouseButtons or mouseButtons[1] then
			clickedElement = MouseData.click.left
			clickedButton = "left"
		end
	elseif isElement(MouseData.click.right) then
		local mouseButtons = dgsElementData[MouseData.click.right].mouseButtons
		if mouseButtons and mouseButtons[2] then
			clickedElement = MouseData.click.right
			clickedButton = "right"
		end
	elseif isElement(MouseData.click.middle) then
		local mouseButtons = dgsElementData[MouseData.click.middle].mouseButtons
		if mouseButtons and mouseButtons[3] then
			clickedElement = MouseData.click.middle
			clickedButton = "middle"
		end
	end
	local mx,my = MouseData.cursorPos[1],MouseData.cursorPos[2]
	if not clickedElement or not (dgsGetType(clickedElement) == "dgs-dxscrollbar" and MouseData.scbClickData == 3) then
		if MouseData.entered ~= hits then
			if isElement(MouseData.entered) then
				if enteredElementType == "dgs-dxgridlist" then
					local preSelect = dgsElementData[MouseData.entered].preSelect
					preSelect[1],preSelect[2] = -1,-1
					dgsSetData(MouseData.entered,"preSelect",preSelect)
				end
				dgsTriggerEvent("onDgsMouseLeave",MouseData.entered,mx,my,hits)
			end
			--Clear mouse stay data
			mouseStay.element = false
			mouseStay.stayed = false
			if isElement(hits) then
				mouseStay.element = hits
				mouseStay.stayed = false
				mouseStay.x = mx
				mouseStay.y = my
				mouseStay.tick = getTickCount()
				dgsTriggerEvent("onDgsMouseEnter",hits,mx,my,MouseData.entered)
			end
			MouseData.left = MouseData.entered
			MouseData.entered = hits
			MouseData.hoverTick = getTickCount()
		else
			if isElement(hits) then
				dgsTriggerEvent("onDgsMouseHover",hits,getTickCount()-(MouseData.hoverTick or getTickCount()),mx,my)
			end
		end
	end
	if dgsElementType[hits] == "dgs-dxtab" then
		local parent = dgsElementData[hits].parent
		dgsElementData[parent].preSelect = dgsElementData[parent].rndPreSelect
	end
	if isElement(hits) then
		if MouseData.lastPos[1] ~= mx or MouseData.lastPos[2] ~= my then
			dgsTriggerEvent("onDgsMouseMove",hits,mx,my)
		end
	end
	if not mouseStay.stayed and isElement(mouseStay.element) then	--Check mouse stay
		if mouseStay.x == mx and mouseStay.y == my then
			if getTickCount()-mouseStay.tick > mouseStay.delay then
				mouseStay.stayed = true
				dgsTriggerEvent("onDgsMouseStay",mouseStay.element,mouseStay.x,mouseStay.y)
			end
		else
			mouseStay.tick = getTickCount()
			mouseStay.x = mx
			mouseStay.y = my
		end
	end
	if clickedElement then
		if MouseData.lastPos[1] ~= mx or MouseData.lastPos[2] ~= my then
			dgsTriggerEvent("onDgsMouseDrag",clickedElement,mx,my)
			if not dgsDragDropBoard.lock and MouseData.clickPosition[clickedButton][0] then
				if ((MouseData.clickPosition[clickedButton][1]-mx)^2+(MouseData.clickPosition[clickedButton][2]-my)^2)^0.5 > 10 then
					dgsDragDropBoard.lock = true
					dgsDragDropBoard.button = clickedButton
					dgsTriggerEvent("onDgsDrag",clickedElement)
					if not wasEventCancelled() then
						if dgsElementData[clickedElement].dragHandler then
							dgsSendDragNDropData(unpack(dgsElementData[clickedElement].dragHandler))
						end
					end
				end
			end
		end
		if MouseData.Move[0] then
			local posX,posY = 0,0
			local parent = dgsElementData[clickedElement].parent
			if parent then
				posX,posY = dgsGetPosition(parent,false,"screen")
				if dgsElementType[parent] == "dgs-dxwindow" then
					if not dgsElementData[clickedElement].ignoreParentTitle and not dgsElementData[parent].ignoreTitle then
						posY = posY + (dgsElementData[parent].titleHeight or 0)
					end
				elseif dgsElementType[parent] == "dgs-dxtab" then
					local tabpanel = dgsElementData[parent].parent
					local size = dgsElementData[tabpanel].absSize[2]
					local height = dgsElementData[tabpanel].tabHeight[2] and dgsElementData[tabpanel].tabHeight[1]*size or dgsElementData[tabpanel].tabHeight[1]
					posY = posY + height
				end
			end
			posX,posY = mx-MouseData.Move[1]-posX,my-MouseData.Move[2]-posY
			local absPos = dgsElementData[clickedElement].absPos
			if absPos[1] ~= posX or absPos[2] ~= posY then
				calculateGuiPositionSize(clickedElement,posX,posY,false)
			end
		end
		if MouseData.Scale[0] then
			local posX,posY = dgsGetPosition(clickedElement,false,true)
			local addPosX,addPosY = 0,0
			local parent = dgsElementData[clickedElement].parent
			if parent then
				addPosX,addPosY = dgsGetPosition(parent,false,"screen")
				if dgsElementType[parent] == "dgs-dxwindow" then
					if not dgsElementData[clickedElement].ignoreParentTitle and not dgsElementData[parent].ignoreTitle then
						addPosY = addPosY + (dgsElementData[parent].titleHeight or 0)
					end
				elseif dgsElementType[parent] == "dgs-dxtab" then
					local tabpanel = dgsElementData[parent].parent
					local size = dgsElementData[tabpanel].absSize[2]
					local height = dgsElementData[tabpanel].tabHeight[2] and dgsElementData[tabpanel].tabHeight[1]*size or dgsElementData[tabpanel].tabHeight[1]
					addPosY = addPosY + height
				end
			end
			local absPos = dgsElementData[clickedElement].absPos
			local absSize = dgsElementData[clickedElement].absSize
			local sizeW,sizeH = absSize[1],absSize[2]
			local endr = posX + sizeW
			local endd = posY + sizeH
			local minSize = dgsElementData[clickedElement].minSize
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
			posX,posY = posX-addPosX,posY-addPosY
			if posX+posY-absPos[1]-absPos[2] ~= 0 or sizeW+sizeH-absSize[1]-absSize[2] ~= 0 then
				calculateGuiPositionSize(clickedElement,posX,posY,false,sizeW,sizeH,false)
			end
		else
			MouseData.lastPos[1] = -1
			MouseData.lastPos[2] = -1
		end
		if not getKeyState("mouse1") then
			MouseData.click.left = false
			if MouseData.scbClickButton == "left" then
				MouseData.scbClickData = false
				MouseData.scbClickButton = nil
			end
			if MouseData.selectorClickButton == "left" then
				MouseData.selectorClickData = false
				MouseData.selectorClickButton = nil
			end
			if MouseData.Move[3] == "left" then
				MouseData.Move[0] = false
				MouseData.Move[3] = nil
			end
			MouseData.Scale[0] = false
			MouseData.lock3DInterface = false
		end
		if not getKeyState("mouse2") then
			MouseData.click.right = false
			if MouseData.scbClickButton == "right" then
				MouseData.scbClickData = false
				MouseData.scbClickButton = nil
			end
			if MouseData.selectorClickButton == "right" then
				MouseData.selectorClickData = false
				MouseData.selectorClickButton = nil
			end
			if MouseData.Move[3] == "right" then
				MouseData.Move[0] = false
				MouseData.Move[3] = nil
			end
		end

		if not getKeyState("mouse3") then
			MouseData.click.middle = false
			if MouseData.scbClickButton == "middle" then
				MouseData.scbClickData = false
				MouseData.scbClickButton = nil
			end
			if MouseData.selectorClickButton == "middle" then
				MouseData.selectorClickData = false
				MouseData.selectorClickButton = nil
			end
			if MouseData.Move[3] == "middle" then
				MouseData.Move[0] = false
				MouseData.Move[3] = nil
			end
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
				local xScroll = dgsElementData[scrollbar[2]].scrollPosition*0.01
				local yScroll = dgsElementData[scrollbar[1]].scrollPosition*0.01
				local renderOffsetX = -(resolution[1]-relSizX)*xScroll
				local renderOffsetY = -(resolution[2]-relSizY)*yScroll
				local posX,posY = mx-x+renderOffsetX-MouseData.MoveScale[1],my-y+renderOffsetY-MouseData.MoveScale[2]
				local xScr,yScr = 0,0
				if resolution[1]-relSizX ~= 0 then xScr = -posX/(resolution[1]-relSizX) end
				if resolution[2]-relSizY ~= 0 then yScr = -posY/(resolution[2]-relSizY) end
				dgsScrollBarSetScrollPosition(scrollbar[2],mathClamp(xScr,0,1)*100)
				dgsScrollBarSetScrollPosition(scrollbar[1],mathClamp(yScr,0,1)*100)
			end
		end
	end
	MouseData.lastPos[1] = mx
	MouseData.lastPos[2] = my
	if not clickedElement then
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
			elseif enteredElementType == "dgs-dxbutton" or enteredElementType == "dgs-dxtab" or enteredElementType == "dgs-dxswitchbutton" or enteredElementType == "dgs-dxcheckbox" or enteredElementType == "dgs-dxcombobox" or enteredElementType == "dgs-dxradiobutton" then
				_cursorType = "pointer"
			elseif enteredElementType == "dgs-dxscrollbar" then
				if MouseData.scbEnterData and MouseData.scbEnterData == 1 or MouseData.scbEnterData == 3 or MouseData.scbEnterData == 5 then
					_cursorType = "pointer"
				end
			elseif enteredElementType == "dgs-dxselector" then
				if MouseData.selectorEnterData and MouseData.selectorEnterData == 1 or MouseData.selectorEnterData == 3 then
					_cursorType = "pointer"
				end
			end
		end

		if _cursorType == "arrow" then
			_cursorType = guiGetCursorType()
		end
		if _cursorType ~= MouseData.cursorType then
			dgsTriggerEvent("onDgsCursorTypeChange",root,_cursorType,MouseData.cursorType)
			MouseData.cursorType = _cursorType
		end
	end

	if CursorData.enabled then
		local cData = CursorData[MouseData.cursorType]
		if cData then
			local image = cData[1]
			if image and not isElement(image) then
				CursorData[MouseData.cursorType] = nil
			else
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
				__dxDrawImage(cursorX,cursorY,cursorW,cursorH,image,rotation,rotCenter[1],rotCenter[2],color,true)
			end
		else
			setCursorAlpha(255)
		end
	end
end

function onClientMouseTriggered(button)
	if MouseHolder.element == MouseData.entered then
		local dgsType = dgsGetType(MouseHolder.element)
		if dgsType == "dgs-dxscrollbar" then
			if MouseData.scbEnterData then
				MouseData.scbClickData = MouseData.scbEnterData
				MouseData.scbClickButton = button
			end
			local scrollbar = MouseHolder.element
			if MouseData.scbEnterData == 1 or MouseData.scbEnterData == 5 then
				if dgsElementData[scrollbar].scrollArrow then
					scrollScrollBar(scrollbar,MouseData.scbClickData == 5,0.5)
					dgsSetData(scrollbar,"moveType","slow")
				end
			elseif MouseData.scbEnterDataDynamic == MouseData.scbEnterData and (MouseData.scbEnterDataDynamic == 2 or MouseData.scbEnterDataDynamic == 4) then
				local troughClickAction = dgsElementData[scrollbar].troughClickAction
				dgsSetData(scrollbar,"moveType","fast")
				if troughClickAction == "step" then
					scrollScrollBar(scrollbar,MouseData.scbClickData == 4,2)
				elseif troughClickAction == "jump" then
					dgsSetProperty(scrollbar,"scrollPosition",mathClamp(MouseData.scbEnterRltPos,0,1)*100)
				end
			end
		elseif dgsType == "dgs-dxselector" then
			local selector = MouseHolder.element
			if MouseData.selectorEnterData then
				MouseData.selectorClickData = MouseData.selectorEnterData
				MouseData.selectorClickButton = button
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
MouseMap = {left="mouse1",right="mouse2",middle="mouse3"}
function onDGSMouseCheck(source,button,state,x,y,isCoolingDown)
	local eleData = dgsElementData[source]
	local mouseButtons = eleData.mouseButtons
	local canLeftClick,canRightClick,canMiddleClick = true
	if mouseButtons then
		canLeftClick,canRightClick,canMiddleClick = mouseButtons[1],mouseButtons[2],mouseButtons[3]
	end
	if state == "down" then
		if (button == "left" and canLeftClick) or (button == "right" and canRightClick) or (button == "middle" and canMiddleClick) then
			if not MouseHolder.lastKey then
				if isTimer(MouseHolder.Timer) then killTimer(MouseHolder.Timer) end
				MouseHolder = {
					element = source,
					lastKey = MouseMap[button],
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
	elseif MouseHolder.lastKey == MouseMap[button] then
		if isTimer(MouseHolder.Timer) then killTimer(MouseHolder.Timer) end
		MouseHolder = {}
	end
end
dgsRegisterFastEventHandler("onDgsMouseClick","onDGSMouseCheck")

function dgsCleanElement(source)
	local isAlive = isElement(source)
	local dgsType = dgsIsType(source)
	if dgsType then
		local eleData = dgsElementData[source] or {}
		if dgsIsFocused(source) then
			dgsBlur(source)
		end
		if isAlive then
			if MouseData.entered == source then
				dgsTriggerEvent("onDgsMouseLeave",MouseData.entered,mx,my,hits)
				MouseData.entered = nil
			end
			if MouseData.click.left == source then MouseData.click.left = nil end
			if MouseData.click.middle == source then MouseData.click.middle = nil end
			if MouseData.click.right == source then MouseData.click.right = nil end
			dgsTriggerEvent("onDgsDestroy",source)
		end
		if eleData.attachedToGridList and isAlive then dgsDetachFromGridList(source) end
		local child = dgsElementData[source].children or {}
		for i=1,#child do
			if child[1] == source then
				outputDebugString("[DGS]Runtime ERROR: wrong relationship (child[1] = self)")	--To prevent some error and tell developer
				table.remove(child,1)	--Just remove
			else
				if isElement(child[1]) then destroyElement(child[1]) end
			end
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
		if dgsType == "dgs-dxcombobox" then
			local arrow = eleData.arrow
			if isElement(arrow) then
				if dgsElementData[arrow] and dgsElementData[arrow].styleResource then
					destroyElement(arrow)
				end
			end
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
					if id == dgsElementData[tabpanel].selected then
						local newSelectedID = dgsElementData[tabpanel].selected-1
						if newSelectedID ~= 0 then
							dgsSetData(tabpanel,"selected",newSelectedID)
						else
							dgsSetData(tabpanel,"selected",-1)
						end
					end
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
		if dgsIsAniming(source) then if isAlive then dgsStopAniming(source)  end end
		if dgsTypeWorld3D[dgsType] then
			tableRemoveItemFromArray(dgsWorld3DTable,source)
			if #dgsWorld3DTable+#dgsScreen3DTable == 0 then
				dgsCore3DStopRender()	--Remove renderer if no 3d elements
			end
		elseif dgsTypeScreen3D[dgsType] then
			tableRemoveItemFromArray(dgsScreen3DTable,source)
			if #dgsWorld3DTable+#dgsScreen3DTable == 0 then
				dgsCore3DStopRender()	--Remove renderer if no 3d elements
			end
		else
			local parent = dgsElementData[source].parent
			if not parent or parent == root then
				local layer = eleData.alwaysOn or "center"
				if layer == "bottom" then
					tableRemoveItemFromArray(BottomRootTable,source)
				elseif layer == "center" then
					tableRemoveItemFromArray(CenterRootTable,source)
				elseif layer == "top" then
					tableRemoveItemFromArray(TopRootTable,source)
				end
			else
				if dgsElementData[parent].children then
					tableRemoveItemFromArray(dgsElementData[parent].children,source)
				end
				dgsElementData[source].parent = nil
			end
		end
		if dgsBackEndRenderer[eleData.asPlugin] or dgsBackEndRenderer[dgsType] then
			tableRemoveItemFromArray(BackEndTable,source)
		end
		if eleData._translation_text then
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

function checkMove(source,button)
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
		MouseData.Move[3] = button
		dgsTriggerEvent("onDgsElementMove",source,offsetx,offsety)
	elseif dgsGetType(source) == "dgs-dxwindow" then
		local x,y = dgsGetPosition(source,false,true)
		local w,h = eleData.absSize[1],eleData.absSize[2]
		local offsetx,offsety = MouseData.cursorPos[1]-x,MouseData.cursorPos[2]-y
		if not eleData.movable then return end
		local titsize = eleData.moveType and h or eleData.titleHeight
		if offsety > titsize then return end
		MouseData.Move[0] = true
		MouseData.Move[1] = offsetx
		MouseData.Move[2] = offsety
		MouseData.Move[3] = button
		dgsTriggerEvent("onDgsElementMove",source,offsetx,offsety)
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
		dgsTriggerEvent("onDgsElementSize",source,offL,offT)
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
		dgsTriggerEvent("onDgsElementSize",source,offL,offT)
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

mouseStay = {
	delay = 1000,
	element = false,
	stayed = false,
	x = false,
	y = false,
	tick = false,
}

addEventHandler("onClientClick",root,function(button,state,x,y)
	local dgsEle = dgsGetMouseEnterGUI()
	local mouseX,mouseY = MouseData.cursorPos[0] and MouseData.cursorPos[1] or x,MouseData.cursorPos[0] and MouseData.cursorPos[2] or y
	if isElement(dgsEle) then	--If clicked on a dgs element
		local eleData = dgsElementData[dgsEle]
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
		if state == "down" then
			dgsTriggerEvent("onDgsMousePreClick",dgsEle,button,state,mouseX,mouseY,isCoolingDown)	--Down
		elseif MouseData.click[button] == dgsEle then
			dgsTriggerEvent("onDgsMousePreClick",dgsEle,button,state,mouseX,mouseY,isCoolingDown)	--Up
		end
		if not isElement(dgsEle) then return end
		if wasEventCancelled() then return end

		local mouseButtons = eleData.mouseButtons
		local canLeftClick,canRightClick,canMiddleClick = true,false,false
		if mouseButtons then
			canLeftClick,canRightClick,canMiddleClick = mouseButtons[1],mouseButtons[2],mouseButtons[3]
		end
		local mouseClicked = (button == "left" and canLeftClick) or (button == "right" and canRightClick) or (button == "middle" and canMiddleClick)

		--Check Grid List Click
		if mouseClicked then
			local dgsEleType = dgsGetType(dgsEle)
			if state == "down" then
				if not checkScale(dgsEle) then checkMove(dgsEle,button) end
				dgsBringToFront(dgsEle,button)
			end
			if dgsOnMouseClickAction[dgsEleType] then dgsOnMouseClickAction[dgsEleType](dgsEle,button,state) end
		end
		if not isElement(dgsEle) then return end
		if state == "down" then	--Down
			if eleData.clickingSound and eleData.clickingSound[button] and eleData.clickingSound[button][state] then
				setSoundVolume(playSound(eleData.clickingSound[button][state]),dgsGetClickingSoundVolume(dgsEle,button,state))
			end
			dgsTriggerEvent("onDgsMouseClick",dgsEle,button,state,mouseX,mouseY,isCoolingDown)
			if not isElement(dgsEle) then return end
			dgsTriggerEvent("onDgsMouseClickDown",dgsEle,button,state,mouseX,mouseY,isCoolingDown)
			MouseData.click[button] = dgsEle
		elseif MouseData.click[button] == dgsEle then	--Up
			if eleData.clickingSound and eleData.clickingSound[button] and eleData.clickingSound[button][state] then
				setSoundVolume(playSound(eleData.clickingSound[button][state]),dgsGetClickingSoundVolume(dgsEle,button,state))
			end
			dgsTriggerEvent("onDgsMouseClick",dgsEle,button,state,mouseX,mouseY,isCoolingDown)
			if not isElement(dgsEle) then return end
			dgsTriggerEvent("onDgsMouseClickUp",dgsEle,button,state,mouseX,mouseY,isCoolingDown)
		end
		if not isElement(dgsEle) then return end
		dgsTriggerEvent(state == "down" and "onDgsMouseDown" or "onDgsMouseUp",dgsEle,button,mouseX,mouseY,isCoolingDown)
		if not isElement(dgsEle) then return end
		if isTimer(multiClick[button][state][3]) then killTimer(multiClick[button][state][3]) end
		if multiClick[button][state][1] == 0 then multiClick[button][state][2] = dgsEle end
		if multiClick[button][state][2] == dgsEle then
			multiClick[button][state][1] = multiClick[button][state][1]+1
			if multiClick[button][state][1] == 2 then
				dgsTriggerEvent("onDgsMouseDoubleClick",dgsEle,button,state,mouseX,mouseY)
				if not isElement(dgsEle) then return end
				dgsTriggerEvent(state == "down" and "onDgsMouseDoubleClickDown" or "onDgsMouseDoubleClickUp",dgsEle,button,state,mouseX,mouseY)
			end
			if isElement(dgsEle) then
				dgsTriggerEvent("onDgsMouseMultiClick",dgsEle,button,state,mouseX,mouseY,multiClick[button][state][1])
				multiClick[button][state][3] = setTimer(function(button2,state2)
					multiClick[button2][state2] = {0,false,false}
				end,multiClick.Interval,1,button,state)
			end
		else
			multiClick[button][state] = {0,false,false}
		end
	elseif state == "down" then	--If clicked at the empty space
		dgsBlur()
	end
	if state == "down" then
		if isElement(dgsEle) then
			MouseData.clickPosition[button][0] = true
			local posX,posY = dgsGetPosition(dgsEle,false,true)
			MouseData.clickPosition[button][1] = mouseX
			MouseData.clickPosition[button][2] = mouseY
		end
	elseif state == "up" then
		MouseData.click[button] = false
		if button == "left" then
			MouseData.click.left = false
			MouseData.lock3DInterface = false
		end
		if button == MouseData.scbClickButton then
			MouseData.MoveScroll[0] = false
		end
		if dgsDragDropBoard[0] and button == dgsDragDropBoard.button then
			local data = dgsRetrieveDragNDropData()
			if isElement(dgsEle) then
				dgsTriggerEvent("onDgsDrop",dgsEle,data)
			end
		end
		dgsDragDropBoard.button = nil
		dgsDragDropBoard.lock = false
		MouseData.Move[0] = false
		MouseData.Move[3] = nil
		MouseData.MoveScale[0] = false
		MouseData.Scale[0] = false
		MouseData.scbClickData = nil
		MouseData.scbClickButton = nil
		MouseData.selectorClickData = nil
		MouseData.clickPosition[button][0] = false
	end
end)

function DGSPositionChange(source,oldx,oldy)
	local parent = dgsGetParent(source)
	if isElement(parent) and dgsGetType(parent) == "dgs-dxscrollpane" then
		resizeScrollPane(parent,source)
	end
	local eleData = dgsElementData[source]
	local attachedBy = eleData.attachedBy
	if attachedBy then
		local absx,absy = dgsGetPosition(source,false,true)
		local absw,absh = eleData.absSize[1],eleData.absSize[2]
		for i=1,#attachedBy do
			local attachSource = attachedBy[i]
			local attachedTable = dgsElementData[attachSource].attachedTo
			local relativePos = attachedTable[4]
			local offsetX,offsetY = relativePos and (absx+absw*attachedTable[2])/sW or attachedTable[2]+absx, relativePos and (absy+absh*attachedTable[3])/sH or attachedTable[3]+absy
			calculateGuiPositionSize(attachSource,offsetX,offsetY,relativePos)
		end
	end
end
dgsRegisterFastEventHandler("onDgsPositionChange","DGSPositionChange")

function DGSSizeChange(source,oldSizeAbsx,oldSizeAbsy)
	local eleData = dgsElementData[source]
	local children = eleData.children
	local childrenCnt = 9
	if children then childrenCnt = #children end
	for k=1,childrenCnt do
		local child = children[k]
		local eleDataChild = dgsElementData[child]
		if dgsElementType[child] ~= "dgs-dxtab" then
			local relt = eleDataChild.relative
			local relativePos,relativeSize = relt[1],relt[2]
			if relativePos or relativeSize then
				local x,y,sx,sy
				if relativePos then
					x,y = eleDataChild.rltPos[1],eleDataChild.rltPos[2]
				end
				if relativeSize then
					sx,sy = eleDataChild.rltSize[1],eleDataChild.rltSize[2]
				end
				calculateGuiPositionSize(child,x,y,relativePos,sx,sy,relativeSize)
			end
		end
	end
	local typ = dgsGetType(source)
	local absSize = eleData.absSize
	if absSize[1] ~= oldSizeAbsx or absSize[2] ~= oldSizeAbsy then
		if typ == "dgs-dxgridlist" then
			configGridList(source)
		elseif typ == "dgs-dxedit" then
			configEdit(source)
		elseif typ == "dgs-dxscrollpane" then
			dgsSetData(source,"configNextFrame",true)
		elseif typ == "dgs-dxtabpanel" then
			configTabPanel(source)
		elseif typ == "dgs-dxcombobox-Box" then
			configComboBox(eleData.myCombo)
		elseif typ == "dgs-dxmemo" then
			dgsSetData(source,"configNextFrame",true)
		elseif typ == "dgs-dxeffectview" then
			configEffectView(source)
		end
		local parent = dgsGetParent(source)
		if isElement(parent) then
			if dgsGetType(parent) == "dgs-dxscrollpane" then
				resizeScrollPane(source,parent)
			end
		end
	end
	local attachedBy = eleData.attachedBy
	if attachedBy then
		local absw,absh = eleData.absSize[1],eleData.absSize[2]
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
end
dgsRegisterFastEventHandler("onDgsSizeChange","DGSSizeChange")

-------------------------onCreateHandler
dgsRegisterProperties("dgsBasic",{
	visible =				{ PArg.Bool },
	enabled =				{ PArg.Bool },
	alpha =					{ PArg.Number },
})
dgsRegisterProperties("dgsType2D",{
	absPos = 				{	{ PArg.Number, PArg.Number }	},
	absSize = 				{	{ PArg.Number, PArg.Number }	},
	rltPos = 				{	{ PArg.Number, PArg.Number }	},
	rltSize = 				{	{ PArg.Number, PArg.Number }	},
	relative = 				{	{ PArg.Bool, PArg.Bool }	},
})

function dgsApplyGeneralProperties(source,theResource)
	local style
	local res = theResource or "global"
	if styleManager.styles[res] and styleManager.styles[res].using then
		local _style = styleManager.styles[res]
		local _using = styleManager.styles[res].using
		if _style.loaded[_using] then
			style = _style.loaded[_using]
		else
			style = styleManager.styles.global
			style = style.loaded[style.using]
		end
	else
		style = styleManager.styles.global
		style = style.loaded[style.using]
	end

	if not dgsElementData[source] then dgsElementData[source] = {} end
	local eleData = dgsElementData[source]
	eleData.positionAlignment = {nil,nil}
	eleData.contentPositionAlignment = {nil,nil}
	eleData.visible = true
	eleData.visibleInherited = true
	eleData.enabled = true
	eleData.enabledInherited = true
	--eleData.ignoreParentTitle = false
	eleData.alpha = 1
	--eleData.childOutsideHit = false
	eleData.PixelInt = true
	eleData.functionRunBefore = true --true : after render; false : before render
	eleData.disabledColor = style.disabledColor
	eleData.disabledColorPercent = style.disabledColorPercent
	--eleData.postGUI = nil
	--eleData.outline = false
	eleData.changeOrder = style.changeOrder --Change the order when "bring to front" or clicked
	--eleData.attachedTo = false
	--eleData.attachedBy = false
	--eleData.enableFullEnterLeaveCheck = false
	--eleData.clickCoolDown = false
	--eleData.clickingSound = false
	--eleData.clickingSoundVolume = false
	eleData.cursorPosition = {[0]=0}
	if not eleData.children then eleData.children = {} end
	insertResource(theResource,source)

	local dgsType = dgsGetType(source)
	if dgsTypeWorld3D[dgsType] or dgsTypeScreen3D[dgsType] then
		if #dgsWorld3DTable+#dgsScreen3DTable == 1 then
			dgsCore3DStartRender()	--Add renderer if there are 3d elements
		end
	end
end

function onDGSElementCreate(source,theResource)
	return triggerEvent("onDgsCreate",source,theResource)
end

function dgsClear(theType,res)
	if res == true then
		if not theType then
			for theRes,guiTable in pairs(boundResource) do
				for dgsEle in pairs(guiTable) do
					if isElement(dgsEle) then destroyElement(dgsEle) end
				end
				boundResource[theRes] = nil
			end
			return true
		else
			for theRes,guiTable in pairs(boundResource) do
				for dgsEle in pairs(guiTable) do
					if dgsElementType[dgsEle] == theType then
						if isElement(dgsEle) then
							boundResource[theRes][dgsEle] = nil
							destroyElement(dgsEle)
						end
					end
				end
			end
			return true
		end
	else
		res = res or sourceResource
		if not theType then
			for dgsEle in pairs(boundResource[res]) do
				if isElement(dgsEle) then destroyElement(dgsEle) end
			end
			boundResource[res] = nil
			return true
		else
			for dgsEle in pairs(boundResource[res]) do
				if dgsElementType[dgsEle] == theType then
					if isElement(dgsEle) then
						boundResource[res][dgsEle] = nil
						destroyElement(dgsEle)
					end
				end
			end
			return true
		end
	end
end