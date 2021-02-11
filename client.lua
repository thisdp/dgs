focusBrowser()
------------Copyrights thisdp's DirectX Graphical User Interface System
--Speed Up
local abs = math.abs
local find = string.find
local rep = string.rep
local gsub = string.gsub
local floor = math.floor
local ceil = math.ceil
local min = math.min
local max = math.max
local clamp = math.restrict
local lerp = math.lerp
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
sW,sH = guiGetScreenSize()
fontSize = {}
self,renderArguments = false,false
dgsRenderSetting = {
	postGUI = nil,
	renderPriority = "normal",
}
dgsRenderer = {}
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
MouseData = {}
MouseData.enter = false
MouseData.lastEnter = false
MouseData.scbEnterData = false
MouseData.scbEnterRltPos = false
MouseData.topScrollable = false
MouseData.hit = false
MouseData.nowShow = false
MouseData.editMemoCursor = false
MouseData.gridlistMultiSelection = false
MouseData.lastPos = {-1,-1}
MouseData.interfaceHit = {}
MouseData.intfaceHitElement = false
MouseData.lock3DInterface = false
MouseData.dgsCursorPos = {}
MouseData.EditMemoTimer = setTimer(function()
	local dgsType = dgsGetType(MouseData.nowShow)
	if dgsType == "dgs-dxedit" or dgsType == "dgs-dxmemo" then
		MouseData.editMemoCursor = not MouseData.editMemoCursor
	end
end,500,0)

function dgsCoreRender()
	local tk = getTickCount()
	triggerEvent("onDgsPreRender",resourceRoot)
	local bottomTableSize = #BottomFatherTable
	local centerTableSize = #CenterFatherTable
	local topTableSize = #TopFatherTable
	local dx3DInterfaceTableSize = #dx3DInterfaceTable
	local dx3DTextTableSize = #dx3DTextTable
	local dx3DImageTableSize = #dx3DImageTable
	MouseData.hit = false
	DGSShow = 0
	wX,wY,wZ = nil,nil,nil
	local mx,my = -1000,-1000
	MouseData.intfaceHitElement = false
	if isCursorShowing() then
		mx,my = getCursorPosition()
		mx,my = mx*sW,my*sH
		wX,wY,wZ = getWorldFromScreenPosition(mx,my,1)
		MouseX,MouseY = mx,my
	else
		MouseData.Move = false
		MouseData.MoveScroll = false
		MouseData.scbClickData = false
		MouseData.selectorClickData = false
		MouseData.clickl = false
		MouseData.clickr = false
		MouseData.clickm = false
		MouseData.lock3DInterface = false
		MouseData.Scale = false
		MouseData.dgsCursorPos = {false,false}
	end
	if isElement(BlurBoxGlobalScreenSource) then
		dxUpdateScreenSource(BlurBoxGlobalScreenSource,true)
	end
	local normalMx,normalMy = mx,my
	if bottomTableSize+centerTableSize+topTableSize+dx3DInterfaceTableSize+dx3DTextTableSize+dx3DImageTableSize ~= 0 then
		dxSetRenderTarget()
		MouseData.interfaceHit = {}
		MouseData.topScrollable = false
		local dxInterfaceHitElement = false
		local intfaceClickElementl = false
		local dimension = getElementDimension(localPlayer)
		local interior = getCameraInterior()
		MouseData.WithinElements = {}
		for i=1,dx3DInterfaceTableSize do
			local v = dx3DInterfaceTable[i]
			local eleData = dgsElementData[v]
			if (eleData.dimension == -1 or eleData.dimension == dimension) and (eleData.interior == -1 or eleData.interior == interior) then
				dxSetBlendMode(eleData.blendMode)
				if renderGUI(v,mx,my,eleData.enabled,eleData.enabled,eleData.renderTarget_parent,0,0,0,0,0,0,1,eleData.visible,MouseData.clickl) then
					intfaceClickElementl = true
				end
			end
		end
		dxSetBlendMode("blend")
		dxSetRenderTarget()
		local intfaceMx,intfaceMy = MouseX,MouseY
		MouseData.intfaceHitElement = MouseData.hit
		local mx,my = normalMx,normalMy
		for i=1,dx3DTextTableSize do
			local v = dx3DTextTable[i]
			local eleData = dgsElementData[v]
			if (eleData.dimension == -1 or eleData.dimension == dimension) and (eleData.interior == -1 or eleData.interior == interior) then
				renderGUI(v,mx,my,eleData.enabled,eleData.enabled,nil,0,0,0,0,0,0,1,eleData.visible)
			end
		end
		for i=1,dx3DImageTableSize do
			local v = dx3DImageTable[i]
			local eleData = dgsElementData[v]
			if (eleData.dimension == -1 or eleData.dimension == dimension) and (eleData.interior == -1 or eleData.interior == interior) then
				renderGUI(v,mx,my,eleData.enabled,eleData.enabled,nil,0,0,0,0,0,0,1,eleData.visible)
			end
		end
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
		if intfaceClickElementl then
			MouseX,MouseY = intfaceMx,intfaceMy
		else
			if MouseData.clickl then
				MouseX,MouseY = normalMx,normalMy
			elseif MouseData.hit == MouseData.intfaceHitElement then
				MouseX,MouseY = intfaceMx,intfaceMy
			else
				MouseX,MouseY = normalMx,normalMy
			end
		end
		MouseData.dgsCursorPos = {MouseX,MouseY}
		dxSetRenderTarget()
		if not isCursorShowing() then
			MouseData.hit = false
			MouseData.Move = false
			MouseData.MoveScroll = false
			MouseData.scbClickData = false
			MouseData.selectorClickData = false
			MouseData.clickl = false
			MouseData.clickr = false
			MouseData.clickm = false
			MouseData.lock3DInterface = false
			MouseData.Scale = false
			MouseX,MouseY = nil,nil
		end
		triggerEvent("onDgsRender",resourceRoot)
		dgsCheckHit(MouseData.hit,MouseX,MouseY)
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
	local ticks = getTickCount()-tk
	if debugMode then
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
		dxDrawText("Render Time: "..ticks.." ms",11,sH*0.4-99,sW,sH,black)
		local tickColor
		if ticks <= 8 then
			tickColor = green
		elseif ticks <= 20 then
			tickColor = yellow
		else
			tickColor = red
		end
		dxDrawText("Render Time: "..ticks.." ms",10,sH*0.4-100,_,_,tickColor)
		local Focused = MouseData.nowShow and dgsGetPluginType(MouseData.nowShow).."("..getElementID(MouseData.nowShow)..")" or "None"
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
		DGSCount = 0
		for i=1,#dgsType do
			local value = dgsType[i]
			local elements = #getElementsByType(value)
			DGSCount = DGSCount+elements
			local x = 15
			if value == "dgs-dxtab" or value == "dgs-dxcombobox-Box" then
				x = 30
			end
			dxDrawText(value.." : "..elements,x+1,sH*0.4+15*i+6,sW,sH,black)
			dxDrawText(value.." : "..elements,x,sH*0.4+15*i+5)
		end
		dxDrawText("Rendering: "..DGSShow,11,sH*0.4-9,sW,sH,black)
		dxDrawText("Rendering: "..DGSShow,10,sH*0.4-10,sW,sH,green)
		dxDrawText("Created: "..DGSCount,11,sH*0.4+6,sW,sH,black)
		dxDrawText("Created: "..DGSCount,10,sH*0.4+5,sW,sH,yellow)
		local anim = tableCount(animGUIList)
		local move = tableCount(moveGUIList)
		local size = tableCount(sizeGUIList)
		local alp = tableCount(alphaGUIList)
		local all = anim+move+size+alp
		dxDrawText("Running Animation("..all.."):",301,sH*0.4-114,sW,sH,black)
		dxDrawText("Running Animation("..all.."):",300,sH*0.4-115)

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
		if debugMode then DGSShow = DGSShow+1 end
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
		if eleData.lor == "right" then
			local pWidth = parent and eleDataP.absSize[1] or sW
			PosX = pWidth-PosX
		end
		if eleData.tob == "bottom" then
			local pHeight = parent and eleDataP.absSize[2] or sH
			PosY = pHeight-PosY
		end
		local x,y = PosX+OffsetX,PosY+OffsetY
		OffsetX,OffsetY = 0,0
		xRT,yRT,xNRT,yNRT = xRT+x,yRT+y,xNRT+x,yNRT+y
		local isPostGUI = not debugMode and (not rndtgt) and (dgsRenderSetting.postGUI == nil and eleData.postGUI) or dgsRenderSetting.postGUI
		if eleDataP and eleDataP.renderTarget_parent == rndtgt and rndtgt then xRT,yRT = x,y end
		self = source
		renderArguments = {xRT,yRT,w,h,xNRT,yNRT}
		if xRT and yRT then
			------------------------------------
			if eleData.functionRunBefore then
				local fnc = eleData.functions
				if type(fnc) == "table" then
					fnc[1](unpack(fnc[2]))
				end
			end
			------------------------------------
			if eleData.PixelInt then xRT,yRT,w,h = xRT-xRT%1,yRT-yRT%1,w-w%1,h-h%1 end
			------------------------------------Main Renderer
			local _mx,_my,rt,noRender
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
				end
				rt,noRender,_mx,_my,offx,offy = dgsRendererFunction(source,xRT,yRT,w,h,mx,my,xNRT,yNRT,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt,xRT,yRT,xNRT,yNRT,OffsetX,OffsetY,visible)
				if MouseData.hit then
					if _hitElement and _hitElement ~= MouseData.hit then
						local scbThickV = dgsElementData[ eleData.scrollbars[1] ].visible and eleData.scrollBarThick or 0
						local scbThickH = dgsElementData[ eleData.scrollbars[2] ].visible and eleData.scrollBarThick or 0
						if mx > xNRT+w-scbThickH or my > yNRT+h-scbThickV then
							MouseData.hit = source
						end
					end
					if MouseData.hit then
						MouseData.WithinElements[MouseData.hit] = true
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
			mx,my = _mx or mx,_my or my
			------------------------------------
			if not eleData.functionRunBefore then
				local fnc = eleData.functions
				if type(fnc) == "table" then
					fnc[1](unpack(fnc[2]))
				end
			end
			------------------------------------OutLine
			if not noRender then
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					local hSideSize = sideSize*0.5
					sideColor = applyColorAlpha(sideColor,parentAlpha)
					local side = outlineData[1]
					if side == "in" then
						dxDrawLine(xRT,yNRT+hSideSize,xRT+w,yNRT+hSideSize,sideColor,sideSize,isPostGUI)
						dxDrawLine(xRT+hSideSize,yNRT,xRT+hSideSize,yNRT+h,sideColor,sideSize,isPostGUI)
						dxDrawLine(xRT+w-hSideSize,yNRT,xRT+w-hSideSize,yNRT+h,sideColor,sideSize,isPostGUI)
						dxDrawLine(xRT,yNRT+h-hSideSize,xRT+w,yNRT+h-hSideSize,sideColor,sideSize,isPostGUI)
					elseif side == "center" then
						dxDrawLine(xRT-hSideSize,yNRT,xRT+w+hSideSize,yNRT,sideColor,sideSize,isPostGUI)
						dxDrawLine(xRT,yNRT+hSideSize,xRT,yNRT+h-hSideSize,sideColor,sideSize,isPostGUI)
						dxDrawLine(xRT+w,yNRT+hSideSize,xRT+w,yNRT+h-hSideSize,sideColor,sideSize,isPostGUI)
						dxDrawLine(xRT-hSideSize,yNRT+h,xRT+w+hSideSize,yNRT+h,sideColor,sideSize,isPostGUI)
					elseif side == "out" then
						dxDrawLine(xRT-sideSize,yNRT-hSideSize,xRT+w+sideSize,yNRT-hSideSize,sideColor,sideSize,isPostGUI)
						dxDrawLine(xRT-hSideSize,yNRT,xRT-hSideSize,yNRT+h,sideColor,sideSize,isPostGUI)
						dxDrawLine(xRT+w+hSideSize,yNRT,xRT+w+hSideSize,yNRT+h,sideColor,sideSize,isPostGUI)
						dxDrawLine(xRT-sideSize,yNRT+h+hSideSize,xRT+w+sideSize,yNRT+h+hSideSize,sideColor,sideSize,isPostGUI)
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

addEventHandler("onClientKey",root,function(button,state)
	if button == "mouse_wheel_up" or button == "mouse_wheel_down" then
		if isElement(MouseData.enter) then
			triggerEvent("onDgsMouseWheel",MouseData.enter,button == "mouse_wheel_down" and -1 or 1)
		end
		local scroll = button == "mouse_wheel_down" and 1 or -1
		local enteredElement = MouseData.topScrollable or MouseData.enter
		local dgsType = dgsGetType(enteredElement)
		if dgsGetType(scrollbar) == "dgs-dxscrollbar" then
			local scrollbar = enteredElement
			dgsSetData(scrollbar,"moveType","slow")
			scrollScrollBar(scrollbar,button == "mouse_wheel_down" or false)
		elseif dgsType == "dgs-dxgridlist" then
			local scrollbar
			local gridlist = enteredElement
			local scrollbar1,scrollbar2 = dgsElementData[gridlist].scrollbars[1],dgsElementData[gridlist].scrollbars[2]
			local visibleScb1,visibleScb2 = dgsGetVisible(scrollbar1),dgsGetVisible(scrollbar2)
			if visibleScb1 and not visibleScb2 then
				scrollbar = scrollbar1
			elseif visibleScb2 and not visibleScb1 then
				scrollbar = scrollbar2
			elseif visibleScb1 and visibleScb2 then
				local whichScrollBar = dgsElementData[gridlist].mouseWheelScrollBar and 2 or 1
				scrollbar = dgsElementData[gridlist].scrollbars[whichScrollBar]
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
			local scrollPane = enteredElement
			local scrollbar
			local scrollbar1,scrollbar2 = dgsElementData[scrollPane].scrollbars[1],dgsElementData[scrollPane].scrollbars[2]
			local visibleScb1,visibleScb2 = dgsGetVisible(scrollbar1),dgsGetVisible(scrollbar2)
			if visibleScb1 and not visibleScb2 then
				scrollbar = scrollbar1
			elseif visibleScb2 and not visibleScb1 then
				scrollbar = scrollbar2
			elseif visibleScb1 and visibleScb2 then
				local whichScrollBar = dgsElementData[scrollPane].mouseWheelScrollBar and 2 or 1
				scrollbar = dgsElementData[scrollPane].scrollbars[whichScrollBar]
			end
			if scrollbar then
				dgsSetData(scrollbar,"moveType","slow")
				scrollScrollBar(scrollbar,button == "mouse_wheel_down" or false)
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
				local mx,my = getCursorPosition()
				mx,my = (mx or -1)*sW,(my or -1)*sH
				local _,y = dgsGetPosition(tabpanel,false,true)
				local height = eleData.tabHeight[2] and eleData.tabHeight[1]*h or eleData.tabHeight[1]
				if my < y+height then
					local speed = eleData.scrollSpeed[2] and eleData.scrollSpeed[1] or eleData.scrollSpeed[1]/width
					local orgoff = eleData.showPos
					orgoff = clamp(orgoff+scroll*speed,0,1)
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
			if dgsElementData[selector].enableScroll and MouseData.nowShow == selector then
				local itemData = dgsElementData[selector].itemData
				local itemCount = #itemData
				local currentItem = dgsElementData[selector].selectedItem
				dgsSelectorSetSelectedItem(selector,floor(clamp(currentItem+(button == "mouse_wheel_down" and 1 or -1),1,itemCount)))
			end
		end
	elseif state then
		local dgsType = dgsGetType(MouseData.nowShow)
		if dgsType == "dgs-dxmemo" or dgsType == "dgs-dxedit" then
			if not button:find("mouse") then
				local typingSound = dgsElementData[MouseData.nowShow].typingSound
				if typingSound then
					playSound(typingSound)
				end
			end
		end
	end
end)

function onClientKeyTriggered(button)
	local makeEventCancelled = false
	local eleData = dgsElementData[MouseData.nowShow]
	if dgsGetType(MouseData.nowShow) == "dgs-dxedit" then
		local edit = MouseData.nowShow
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
	elseif dgsGetType(MouseData.nowShow) == "dgs-dxmemo" then
		local memo = MouseData.nowShow
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
	elseif dgsGetType(MouseData.nowShow) == "dgs-dxgridlist" then
		local gridlist = MouseData.nowShow
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
addEventHandler("onClientKey",root,onClientKeyCheck)

function dgsCheckHit(hits,mx,my)
	if not isElement(MouseData.clickl) or not (dgsGetType(MouseData.clickl) == "dgs-dxscrollbar" and MouseData.scbClickData == 3) then
		if MouseData.enter ~= hits then
			if isElement(MouseData.enter) then
				triggerEvent("onDgsMouseLeave",MouseData.enter,mx,my,hits)
				if dgsGetType(MouseData.enter) == "dgs-dxgridlist" then
					dgsSetData(MouseData.enter,"preSelect",{-1,-1})
				end
			end
			if isElement(hits) then
				triggerEvent("onDgsMouseEnter",hits,mx,my,MouseData.enter)
			end
			MouseData.lastEnter = MouseData.enter
			MouseData.enter = hits
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
		end
		if MouseData.Move then
			local pos = {0,0}
			local parent = FatherTable[MouseData.clickl]
			if parent then
				pos = {getParentLocation(parent)}
				if dgsElementType[parent] == "dgs-dxwindow" then
					if not dgsElementData[MouseData.clickl].ignoreParentTitle and not dgsElementData[parent].ignoreTitle then
						pos[2] = pos[2] + (dgsElementData[parent].titleHeight or 0)
					end
				elseif dgsElementType[parent] == "dgs-dxtab" then
					local tabpanel = dgsElementData[parent].parent
					local size = dgsElementData[tabpanel].absSize[2]
					local height = dgsElementData[tabpanel].tabHeight[2] and dgsElementData[tabpanel].tabHeight[1]*size or dgsElementData[tabpanel].tabHeight[1]
					pos[2] = pos[2] + height
				end
			end
			local posX = (mx-MouseData.Move[1]-pos[1])
			local posY = (my-MouseData.Move[2]-pos[2])
			local absPos = dgsElementData[MouseData.clickl].absPos
			if absPos[1] ~= posX or absPos[2] ~= posY then
				calculateGuiPositionSize(MouseData.clickl,posX,posY,false)
			end
		end
		if MouseData.Scale then
			local pos = {dgsGetPosition(MouseData.clickl,false,true)}
			local addPos = {0,0}
			local parent = FatherTable[MouseData.clickl]
			if parent then
				addPos = {getParentLocation(parent)}
				if dgsElementType[parent] == "dgs-dxwindow" then
					if not dgsElementData[MouseData.clickl].ignoreParentTitle and not dgsElementData[parent].ignoreTitle then
						addPos[2] = addPos[2] + (dgsElementData[parent].titleHeight or 0)
					end
				elseif dgsElementType[parent] == "dgs-dxtab" then
					local tabpanel = dgsElementData[parent].parent
					local size = dgsElementData[tabpanel].absSize[2]
					local height = dgsElementData[tabpanel].tabHeight[2] and dgsElementData[tabpanel].tabHeight[1]*size or dgsElementData[tabpanel].tabHeight[1]
					addPos[2] = addPos[2] + height
				end
			end
			local absPos = dgsElementData[MouseData.clickl].absPos
			local _size = dgsElementData[MouseData.clickl].absSize
			local siz = {_size[1],_size[2]}
			local endr = pos[1] + siz[1]
			local endd = pos[2] + siz[2]
			local minSize = dgsElementData[MouseData.clickl].minSize or {10,10}
			local minSizeX,minSizeY = minSize[1] or 10,minSize[2] or 10
			if MouseData.Scale[5] == 1 then
				local old = pos[1]
				siz[1] = (siz[1]-(mx-MouseData.Scale[1]-old))
				if siz[1] < minSizeX then
					siz[1] = minSizeX
					pos[1] = endr-siz[1]
				else
					pos[1] = (mx-MouseData.Scale[1])
				end
			end
			if MouseData.Scale[5] == 3 then
				siz[1] = (mx-pos[1]-MouseData.Scale[3])
				if siz[1] < minSizeX then
					siz[1] = minSizeX
				end
			end
			if MouseData.Scale[6] == 2 then
				local old = pos[2]
				siz[2] = siz[2]-(my-MouseData.Scale[2]-old)
				if siz[2] < minSizeY then
					siz[2] = minSizeY
					pos[2] = endd-siz[2]
				else
					pos[2] = (my-MouseData.Scale[2])
				end
			end
			if MouseData.Scale[6] == 4 then
				siz[2] = (my-pos[2]-MouseData.Scale[4])
				if siz[2] < minSizeY then
					siz[2] = minSizeY
				end
			end
			local posX,posY = pos[1]-addPos[1],pos[2]-addPos[2]
			local sizeX,sizeY = siz[1],siz[2]
			local absSize = dgsElementData[MouseData.clickl].absSize
			if posX+posY-absPos[1]-absPos[2] ~= 0 or sizeX+sizeY-absSize[1]-absSize[2] ~= 0 then
				calculateGuiPositionSize(MouseData.clickl,posX,posY,false,sizeX,sizeY,false)
			end
		else
			MouseData.lastPos = {-1,-1}
		end
		if not getKeyState("mouse1") then
			MouseData.clickl = false
			MouseData.scbClickData = false
			MouseData.selectorClickData = false
			MouseData.Move = false
			MouseData.Scale = false
			MouseData.lock3DInterface = false
		end
		if not getKeyState("mouse2") then
			MouseData.clickr = false
		end
	else
		MouseData.lastPos = {}
	end
	MouseData.lastPos = {mx,my}
end

function onClientMouseTriggered()
	if MouseHolder.element == MouseData.enter then
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
					dgsSetProperty(scrollbar,"position",clamp(scbEnterRltPos,0,1)*100)
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
				local currentItem = dgsElementData[selector].selectedItem
				if currentItem ~= -1 then
					local offsetItem = 1
					if MouseHolder.notIsFirst then
						dgsElementData[selector].quickLeapState = lerp(0.2,dgsElementData[selector].quickLeapState,dgsElementData[selector].quickLeap)
						offsetItem = dgsElementData[selector].quickLeapState*itemCount
					else
						dgsElementData[selector].quickLeapState = 0
					end
					dgsSelectorSetSelectedItem(selector,ceil(clamp(currentItem-offsetItem,1,itemCount)))
				end
			elseif MouseData.selectorEnterData == 3 then
				local itemData = dgsElementData[selector].itemData
				local itemCount = #itemData
				local currentItem = dgsElementData[selector].selectedItem
				if currentItem ~= -1 then
					local offsetItem = 1
					if MouseHolder.notIsFirst then
						dgsElementData[selector].quickLeapState = lerp(0.2,dgsElementData[selector].quickLeapState,dgsElementData[selector].quickLeap)
						offsetItem = dgsElementData[selector].quickLeapState*itemCount
					else
						dgsElementData[selector].quickLeapState = 0
					end
					dgsSelectorSetSelectedItem(selector,floor(clamp(currentItem+offsetItem,1,itemCount)))
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

addEventHandler("onClientElementDestroy",resourceRoot,function()
	local parent = dgsGetParent(source) or root
	if dgsIsType(source) then
		local eleData = dgsElementData[source] or {}
		triggerEvent("onDgsDestroy",source)
		local isAttachedToGridList = eleData.attachedToGridList
		if isAttachedToGridList then dgsDetachFromGridList(source) end
		local child = ChildrenTable[source] or {}
		for i=1,#child do
			if isElement(child[1]) then destroyElement(child[1]) end
		end
		local autoDestroyList = eleData.autoDestroyList or {}
		for i=-10,#autoDestroyList do	--From -10, to reserve dynamic space
			local ele = autoDestroyList[i]
			if ele and isElement(ele) then
				destroyElement(ele)
			end
		end
		local dgsType = dgsGetType(source)
		if dgsType == "dgs-dxedit" then
			blurEditMemo()
		elseif dgsType == "dgs-dxmemo" then
			blurEditMemo()
		elseif dgsType == "dgs-dxtabpanel" then
			local tabs = eleData.tabs or {}
			for i=1,#tabs do
				destroyElement(tabs[i])
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
					dgsSetData(tabpanel,"tabLengthAll",dgsElementData[tabpanel].tabLengthAll-wid-sidesize*2-gapSize*min(#tabs,1))
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
		tableRemove(ChildrenTable[source] or {})
		local tresource = getElementData(source,"resource")
		if tresource and boundResource[tresource] then
			boundResource[tresource][source] = nil
		end
		if animGUIList[source] then dgsStopAniming(source) end
		if moveGUIList[source] then dgsStopMoving(source) end
		if sizeGUIList[source] then dgsStopSizing(source) end
		if alphaGUIList[source] then dgsStopAlphaing(source) end
		if dgsType == "dgs-dx3dinterface" then
			tableRemoveItemFromArray(dx3DInterfaceTable,source)
		elseif dgsType == "dgs-dx3dtext" then
			tableRemoveItemFromArray(dx3DTextTable,source)
		elseif dgsType == "dgs-dx3dimage" then
			tableRemoveItemFromArray(dx3DImageTable,source)
		else
			local parent = dgsGetParent(source)
			if not isElement(parent) then
				local layer = eleData.alwaysOn or "center"
				if layer == "bottom" then
					tableRemoveItemFromArray(BottomFatherTable,source)
				elseif layer == "center" then
					tableRemoveItemFromArray(CenterFatherTable,source)
				elseif layer == "top" then
					tableRemoveItemFromArray(TopFatherTable,source)
				end
			else
				tableRemoveItemFromArray(ChildrenTable[parent] or {},source)
			end
		end
		if eleData._translationText then
			tableRemoveItemFromArray(LanguageTranslationAttach,source)
		end
	end
	dgsElementData[source] = nil
end)

function checkMove(source)
	local eleData = dgsElementData[source]
	local moveData = eleData.moveHandlerData
	if moveData then
		local mx,my = getCursorPosition()
		mx,my = MouseX or (mx or -1)*sW,MouseY or (my or -1)*sH
		local x,y = dgsGetPosition(source,false,true)
		local w,h = eleData.absSize[1],eleData.absSize[2]
		local offsetx,offsety = mx-x,my-y
		local xRel,yRel,wRel,hRel = moveData[5],moveData[6],moveData[7],moveData[8]
		local chx = xRel and moveData[1]*w or moveData[1]
		local chy = yRel and moveData[2]*h or moveData[2]
		local chw = wRel and moveData[3]*w or moveData[3]
		local chh = hRel and moveData[4]*h or moveData[4]
		if not (offsetx >= chx and offsetx <= chx+chw and offsety >= chy and offsety <= chy+chh) then
			return
		end
		MouseData.Move = {offsetx,offsety}
		triggerEvent("onDgsElementMove",source,offsetx,offsety)
	elseif dgsGetType(source) == "dgs-dxwindow" then
		local mx,my = getCursorPosition()
		mx,my = MouseX or (mx or -1)*sW,MouseY or (my or -1)*sH
		local x,y = dgsGetPosition(source,false,true)
		local w,h = eleData.absSize[1],eleData.absSize[2]
		local offsetx,offsety = mx-x,my-y
		local moveData = eleData.moveHandlerData
		local movable = eleData.movable
		if not movable then return end
		local titsize = eleData.movetyp and h or eleData.titleHeight
		if offsety > titsize then return end
		MouseData.Move = {offsetx,offsety}
		triggerEvent("onDgsElementMove",source,offsetx,offsety)
	end
end

function checkScrollBar(source,py,sd)
	local mx,my = getCursorPosition()
	mx,my = MouseX or (mx or -1)*sW,MouseY or (my or -1)*sH
	local x,y = dgsElementData[source].absPos[1],dgsElementData[source].absPos[2]
	local offsetx,offsety = mx-x,my-y
	MouseData.MoveScroll = {sd and offsetx-py or offsetx,sd and offsety or offsety-py}
end

function checkScale(source)
	local eleData = dgsElementData[source]
	local sizeData = eleData.sizeHandlerData
	if sizeData then
		local mx,my = getCursorPosition()
		mx,my = MouseX or (mx or -1)*sW,MouseY or (my or -1)*sH
		local x,y = dgsGetPosition(source,false,true)
		local w,h = eleData.absSize[1],eleData.absSize[2]
		local offsetx,offsety = mx-x,my-y
		local leftRel,rightRel,topRel,bottomRel = sizeData[5],sizeData[6],sizeData[7],sizeData[8]
		local left = leftRel and sizeData[1]*w or sizeData[1]
		local right = rightRel and sizeData[2]*h or sizeData[2]
		local top = topRel and sizeData[3]*w or sizeData[3]
		local bottom = bottomRel and sizeData[4]*h or sizeData[4]
		local offsets = {mx-x,my-y,mx-x-w,my-y-h}
		if abs(offsets[1]) < left then
			offsets[5] = 1
		elseif abs(offsets[3]) < right then
			offsets[5] = 3
		end
		if abs(offsets[2]) < top then
			offsets[6] = 2
		elseif abs(offsets[4]) < bottom then
			offsets[6] = 4
		end
		if not offsets[5] and not offsets[6] then
			MouseData.Scale = false
			return false
		end
		MouseData.Scale = offsets
		triggerEvent("onDgsElementSize",source,offsets[1],offsets[2])
		return true
	elseif dgsGetType(source) == "dgs-dxwindow" then
		local mx,my = getCursorPosition()
		mx,my = MouseX or (mx or -1)*sW,MouseY or (my or -1)*sH
		local x,y = dgsGetPosition(source,false,true)
		local w,h = eleData.absSize[1],eleData.absSize[2]
		local offsets = {mx-x,my-y,mx-x-w,my-y-h}
		local sizable = eleData.sizable
		if not sizable then return false end
		local borderSize = eleData.borderSize
		if abs(offsets[1]) < borderSize then
			offsets[5] = 1
		elseif abs(offsets[3]) < borderSize then
			offsets[5] = 3
		end
		if abs(offsets[2]) < borderSize then
			offsets[6] = 2
		elseif abs(offsets[4]) < borderSize then
			offsets[6] = 4
		end
		if not offsets[5] and not offsets[6] then
			MouseData.Scale = false
			return false
		end
		MouseData.Scale = offsets
		triggerEvent("onDgsElementSize",source,offsets[1],offsets[2])
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
	if isElement(guiele) then
		if state == "down" then
			triggerEvent("onDgsMouseDown",guiele,button,MouseX or x,MouseY or y)
		elseif state == "up" then
			triggerEvent("onDgsMouseUp",guiele,button,MouseX or x,MouseY or y)
		end
		local guitype = dgsGetType(guiele)
		if guitype == "dgs-dxbrowser" then
			focusBrowser(guiele)
		else
			focusBrowser()
		end
		local parent = dgsGetParent(guiele)
		local eleData = dgsElementData[guiele]
		if guitype == "dgs-dxswitchbutton" then
			if eleData.clickState == state and eleData.clickButton == button then
				dgsSetData(guiele,"state", not eleData.state)
			end
		end
		if state == "down" then
			dgsBringToFront(guiele,button)
			if guitype == "dgs-dxscrollpane" then
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
					local parent = eleData.attachedToParent
					if isElement(parent) then
						if guiele == dgsElementData[parent].scrollbars[1] then
							dgsSetData(parent,"mouseWheelScrollBar",false)
						elseif guiele == dgsElementData[parent].scrollbars[2] then
							dgsSetData(parent,"mouseWheelScrollBar",true)
						end
					end
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
											local startRow,endRow = min(clicked[1],preSelect[1]),max(clicked[1],preSelect[1])
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
											local startColumn,endColumn = min(clicked[2],preSelect[2]),max(clicked[2],preSelect[2])
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
											local startRow,endRow = min(clicked[1],preSelect[1]),max(clicked[1],preSelect[1])
											local startColumn,endColumn = min(clicked[2],preSelect[2]),max(clicked[2],preSelect[2])
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
		if state == "up" then
			if button == "left" then
				if MouseData.clickl == guiele then
					triggerEvent("onDgsMouseClick",guiele,button,state,MouseX or x,MouseY or y)
				end
			elseif button == "right" then
				if MouseData.clickr == guiele then
					triggerEvent("onDgsMouseClick",guiele,button,state,MouseX or x,MouseY or y)
				end
			else
				triggerEvent("onDgsMouseClick",guiele,button,state,MouseX or x,MouseY or y)
			end
		else
			triggerEvent("onDgsMouseClick",guiele,button,state,MouseX or x,MouseY or y)
		end
		if not isElement(guiele) then return end
		if isTimer(multiClick[button][state][3]) then killTimer(multiClick[button][state][3]) end
		if multiClick[button][state][1] == 0 then multiClick[button][state][2] = guiele end
		if multiClick[button][state][2] == guiele then
			multiClick[button][state][1] = multiClick[button][state][1]+1
			if multiClick[button][state][1] == 2 then
				triggerEvent("onDgsMouseDoubleClick",guiele,button,state,MouseX or x,MouseY or y)
			end
			triggerEvent("onDgsMouseMultiClick",guiele,button,state,MouseX or x,MouseY or y,multiClick[button][state][1])
			multiClick[button][state][3] = setTimer(function(button,state)
				multiClick[button][state] = {0,false,false}
			end,multiClick.Interval,1,button,state)
		else
			multiClick[button][state] = {0,false,false}
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
	elseif state == "down" then
		if dgsType == "dgs-dxedit" or dgsType == "dgs-dxmemo" then
			blurEditMemo()
		end
		if isElement(MouseData.nowShow) then
			triggerEvent("onDgsBlur",MouseData.nowShow,false)
		end
	end
	if state == "up" then
		if button == "left" then
			MouseData.clickl = false
			MouseData.lock3DInterface = false
			MouseData.MoveScroll = false
		elseif button == "right" then
			MouseData.clickr = false
		end
		MouseData.Move = false
		MouseData.Scale = false
		MouseData.scbClickData = nil
		MouseData.selectorClickData = nil
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
	local attachedBy = dgsElementData[source].attachedBy or {}
	local absx,absy = dgsGetPosition(source,false,true)
	local absw,absh = dgsElementData[source].absSize[1],dgsElementData[source].absSize[2]
	for i=1,#attachedBy do
		local attachSource = attachedBy[i]
		local attachedTable = dgsElementData[attachSource].attachedTo
		local relativePos = attachedTable[4]
		local offsetX,offsetY = relativePos and (absx+absw*attachedTable[2])/sW or attachedTable[2]+absx, relativePos and (absy+absh*attachedTable[3])/sH or attachedTable[3]+absy
		calculateGuiPositionSize(attachSource,offsetX,offsetY,relativePos)
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
	local attachedBy = dgsElementData[source].attachedBy or {}
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
end)