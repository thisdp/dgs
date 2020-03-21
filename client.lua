focusBrowser()
------------Copyrights thisdp's DirectX Graphical User Interface System
--Speed Up
local abs = math.abs
local find = string.find
local rep = string.rep
local gsub = string.gsub
local floor = math.floor
local min = math.min
local max = math.max
local tocolor = tocolor
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
local utf8Sub = utf8.sub
local utf8Len = utf8.len
local tableInsert = table.insert
local tableRemove = table.remove
local tableCount = table.count
local tableFind = table.find
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
white = 0xFFFFFFFF
black = 0xFF000000
green = 0xFF00FF00
red = 0xFFFF0000
blue = 0xFF0000FF
yellow = 0xFFFFFF00
fontSize = {}
systemFont = styleSettings.systemFont
self,renderArguments = false,false
dgsRenderSetting = {
	postGUI = nil,
	renderPriority = "normal",
}

function dgsSetSystemFont(font,size,bold,quality)
	assert(type(font) == "string","Bad argument @dgsSetSystemFont at argument 1, expect a string got "..dgsGetType(font))
	if isElement(systemFont) then
		destroyElement(systemFont)
	end
	sourceResource = sourceResource or getThisResource()
	if fontDxHave[font] then
		systemFont = font
		return true
	elseif sourceResource then
		local path = font:find(":") and font or ":"..getResourceName(sourceResource).."/"..font
		assert(fileExists(path),"Bad argument @dgsSetSystemFont at argument 1,couldn't find such file '"..path.."'")
		local font = dxCreateFont(path,size,bold,quality)
		if isElement(font) then
			systemFont = font
		end
	end
	return false
end

function dgsGetSystemFont()
	return systemFont
end

function dgsGetRenderSetting(name)
	return dgsRenderSetting[name]
end

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
MouseData.enterData = false
MouseData.scrollPane = false
MouseData.hit = false
MouseData.nowShow = false
MouseData.arrowListEnter = false
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
		MouseData.clickData = false
		MouseData.clickl = false
		MouseData.clickr = false
		MouseData.clickm = false
		MouseData.lock3DInterface = false
		MouseData.Scale = false
		MouseData.scrollPane = false
		MouseData.dgsCursorPos = {false,false}
		if MouseData.arrowListEnter then
			if isElement(MouseData.arrowListEnter[1]) then
				dgsSetData(MouseData.arrowListEnter[1],"arrowListClick",false)
			end
		end
		MouseData.arrowListEnter = false
	end
	local normalMx,normalMy = mx,my
	if bottomTableSize+centerTableSize+topTableSize+dx3DInterfaceTableSize+dx3DTextTableSize ~= 0 then
		local dgsData = dgsElementData
		dxSetRenderTarget()
		MouseData.interfaceHit = {}
		local dxInterfaceHitElement = false
		local intfaceClickElementl = false
		local dimension = getElementDimension(localPlayer)
		local interior = getCameraInterior()	
		for i=1,dx3DInterfaceTableSize do
			local v = dx3DInterfaceTable[i]
			local eleData = dgsData[v]
			if (eleData.dimension == -1 or eleData.dimension == dimension) and (eleData.interior == -1 or eleData.interior == interior) then
				dxSetBlendMode(eleData.blendMode)
				if renderGUI(v,mx,my,{eleData.enabled,eleData.enabled},eleData.renderTarget_parent,{0,0,0,0},0,0,1,eleData.visible,MouseData.clickl) then
					intfaceClickElementl = true
				end
			end
		end
		dxSetBlendMode("blend")
		local intfaceMx,intfaceMy = MouseX,MouseY
		MouseData.intfaceHitElement = MouseData.hit
		dxSetRenderTarget()
		local mx,my = normalMx,normalMy
		for i=1,dx3DTextTableSize do
			local v = dx3DTextTable[i]
			local eleData = dgsData[v]
			if (eleData.dimension == -1 or eleData.dimension == dimension) and (eleData.interior == -1 or eleData.interior == interior) then
				renderGUI(v,mx,my,{eleData.enabled,eleData.enabled},nil,{0,0,0,0},0,0,1,eleData.visible)
			end
		end
		for i=1,bottomTableSize do
			local v = BottomFatherTable[i]
			local eleData = dgsData[v]
			renderGUI(v,mx,my,{eleData.enabled,eleData.enabled},nil,{0,0,0,0},0,0,1,eleData.visible)
		end
		for i=1,centerTableSize do
			local v = CenterFatherTable[i]
			local eleData = dgsData[v]
			renderGUI(v,mx,my,{eleData.enabled,eleData.enabled},nil,{0,0,0,0},0,0,1,eleData.visible)
		end
		for i=1,topTableSize do
			local v = TopFatherTable[i]
			local eleData = dgsData[v]
			renderGUI(v,mx,my,{eleData.enabled,eleData.enabled},nil,{0,0,0,0},0,0,1,eleData.visible)
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
			MouseData.clickData = false
			MouseData.clickl = false
			MouseData.clickr = false
			MouseData.clickm = false
			MouseData.lock3DInterface = false
			MouseData.Scale = false
			MouseData.scrollPane = false
			if MouseData.arrowListEnter then
				if isElement(MouseData.arrowListEnter[1]) then
					dgsSetData(MouseData.arrowListEnter[1],"arrowListClick",false)
				end
			end
			MouseData.arrowListEnter = false
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
		if isElement(MouseData.hit) and debugMode == 2 then
			local highlight = MouseData.hit
			if dgsElementType[MouseData.hit] == "dgs-dxtab" then
				highlight = dgsElementData[highlight].parent
			end
			local scAbsX,scAbsY = dgsGetPosition(highlight,false,true,false,true)
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
			local x,y,w,h = scAbsX,scAbsY,absW,absH
			dxDrawLine(x-sideSize,y-hSideSize,x+w+sideSize,y-hSideSize,sideColor,sideSize,rendSet)
			dxDrawLine(x-hSideSize,y,x-hSideSize,y+h,sideColor,sideSize,rendSet)
			dxDrawLine(x+w+hSideSize,y,x+w+hSideSize,y+h,sideColor,sideSize,rendSet)
			dxDrawLine(x-sideSize,y+h+hSideSize,x+w+sideSize,y+h+hSideSize,sideColor,sideSize,rendSet)
		end
		local version = getElementData(resourceRoot,"Version") or "?"
		dxDrawText("Thisdp's Dx Lib(DGS)",6,sH*0.4-129,sW,sH,black)
		dxDrawText("Thisdp's Dx Lib(DGS)",5,sH*0.4-130)
		dxDrawText("Version: "..version,6,sH*0.4-114,sW,sH,black)
		dxDrawText("Version: "..version,5,sH*0.4-115)
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
		local Focused = MouseData.nowShow and dgsGetType(MouseData.nowShow).."("..getElementID(MouseData.nowShow)..")" or "None"
		local enterStr = MouseData.hit and dgsGetType(MouseData.hit).." ("..getElementID(MouseData.hit)..")" or "None"
		local leftStr = MouseData.clickl and dgsGetType(MouseData.clickl).." ("..getElementID(MouseData.clickl)..")" or "None"
		local rightStr = MouseData.clickr and dgsGetType(MouseData.clickr).." ("..getElementID(MouseData.clickr)..")" or "None"
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
				local resDGSCnt = #va
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

function interfaceRender()
	for i=1,#dx3DInterfaceTable do
		local v = dx3DInterfaceTable[i]
		local eleData = dgsElementData[v]
		local dimension = eleData.dimension
		if eleData.visible then
			local attachTable = eleData.attachTo
			if attachTable then
				local element,offX,offY,offZ,offFaceX,offFaceY,offFaceZ = attachTable[1],attachTable[2],attachTable[3],attachTable[4],attachTable[5],attachTable[6],attachTable[7]
				if not isElement(element) then
					eleData.attachTo = false
				else
					local ex,ey,ez = getElementPosition(element)
					local tmpX,tmpY,tmpZ = getPositionFromElementOffset(element,offFaceX,offFaceY,offFaceZ)
					eleData.position = {getPositionFromElementOffset(element,offX,offY,offZ)}
					eleData.faceTo = {tmpX-ex,tmpY-ey,tmpZ-ez}
				end
			end
			local pos = eleData.position
			local size = eleData.size
			local faceTo = eleData.faceTo or {}
			local x,y,z,w,h,fx,fy,fz,rot = pos[1],pos[2],pos[3],size[1],size[2],faceTo[1],faceTo[2],faceTo[3],eleData.rotation
			eleData.hit = false
			if x and y and z and w and h then
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				local camX,camY,camZ = getCameraMatrix()
				local cameraDistance = ((camX-x)^2+(camY-y)^2+(camZ-z)^2)^0.5
				eleData.cameraDistance = cameraDistance
				if cameraDistance <= eleData.maxDistance then
					local renderThing = eleData.renderTarget_parent
					local addalp = 1
					if cameraDistance >= eleData.fadeDistance then
						addalp = 1-(cameraDistance-eleData.fadeDistance)/(eleData.maxDistance-eleData.fadeDistance)
					end
					local colors = applyColorAlpha(eleData.color,eleData.alpha*addalp)
					if not fx or not fy or not fz then
						fx,fy,fz = camX-x,camY-y,camZ-z
					end
					if eleData.faceRelativeTo == "world" then
						fx,fy,fz = fx-x,fy-y,fz-z
					end
					local filter = eleData.filterShader
					if isElement(filter) then
						dgsSetFilterShaderData(filter,x,y,z,fx,fy,fz,rot,w,h,renderThing,fromcolor(colors))
						renderThing = filter
						colors = white
					end
					dgsDrawMaterialLine3D(x,y,z,fx,fy,fz,renderThing,w,h,colors,rot)
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
			end
		end
	end
end
addEventHandler("onClientPreRender",root,interfaceRender)

function renderGUI(v,mx,my,enabled,rndtgt,position,OffsetX,OffsetY,galpha,visible,checkElement)
	local rndtgt = isElement(rndtgt) and rndtgt or false
	local globalBlendMode = rndtgt and "modulate_add" or "blend"
	dxSetBlendMode(globalBlendMode)
	local isElementInside = false
	local eleData = dgsElementData[v]
	local enabled = {enabled[1] and eleData.enabled,eleData.enabled}
	if eleData.visible and visible and isElement(v) then
		if debugMode then
			DGSShow = DGSShow+1
		end
		visible = eleData.visible
		local dxType = dgsGetType(v)
		if dxType == "dgs-dxscrollbar" then
			local pnt = eleData.attachedToParent
			if pnt and not dgsElementData[pnt].visible then
				return
			end
		end
		local parent,children,galpha = FatherTable[v] or false,ChildrenTable[v] or {},(eleData.alpha or 1)*galpha
		local dxType_p = dgsGetType(parent)
		dxSetRenderTarget(rndtgt)
		local absPos = eleData.absPos
		local absSize = eleData.absSize
		
		--Side Processing
		local PosX,PosY,w,h = 0,0,0,0
		if dxType_p == "dgs-dxwindow" then
			local pEleData = dgsElementData[parent]
			if not pEleData.ignoreTitle and not eleData.ignoreParentTitle then
				PosY = PosY+(pEleData.titleHeight or 0)
			end
		elseif dxType_p == "dgs-dxtab" then
			local pEleData = dgsElementData[FatherTable[parent]]
			local pSize = pEleData.absSize
			local tabHeight = pEleData.tabHeight[2] and pEleData.tabHeight[1]*pSize[2] or pEleData.tabHeight[1]
			PosY = PosY+tabHeight
			w,h = pSize[1],pSize[2]-tabHeight
		end
		if dxType ~= "dgs-dxtab" then
			absPos = absPos or {0,0}
			absSize = absSize or {0,0}
			PosX,PosY = PosX+absPos[1],PosY+absPos[2]
			w,h = absSize[1],absSize[2]
		end
		if dgsElementData[v].lor == "right" then
			local pSize = parent and dgsElementData[parent].absSize or {sW,sH}
			PosX = pSize[1]-PosX
		end
		if dgsElementData[v].tob == "bottom" then
			local pSize = parent and dgsElementData[parent].absSize or {sW,sH}
			PosY = pSize[2]-PosY
		end
		local x,y = PosX+OffsetX,PosY+OffsetY
		OffsetX,OffsetY = 0,0
		position = {position[1]+x,position[2]+y,position[3]+x,position[4]+y}
		local noRenderTarget = (not rndtgt) and true or false
		if (dgsElementData[parent] or {}).renderTarget_parent == rndtgt and not noRenderTarget then
			position[1],position[2] = x,y
		end
		local x,y,cx,cy = position[1],position[2],position[3],position[4]
		eleData.rndTmpData.coordinate = {x,y,cx,cy}
		self = v
		renderArguments = {x,y,w,h}
		local interrupted = false
		local rendSet = not debugMode and noRenderTarget and (dgsRenderSetting.postGUI == nil and eleData.postGUI) or dgsRenderSetting.postGUI
		if dxType == "dgs-dxwindow" then
			if x and y then
				if eleData.PixelInt then
					x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
				end
				local img = eleData.image
				local color = eleData.color
				color = applyColorAlpha(color,galpha)
				local titimg,titleColor,titsize = eleData.titleImage,eleData.isFocused and eleData.titleColor or eleData.titleColorBlur,eleData.titleHeight
				titleColor = applyColorAlpha(titleColor,galpha)
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if img then
					dxDrawImage(x,y+titsize,w,h-titsize,img,0,0,0,color,rendSet)
				else
					dxDrawRectangle(x,y+titsize,w,h-titsize,color,rendSet)
				end
				if titimg then
					dxDrawImage(x,y,w,titsize,titimg,0,0,0,titleColor,rendSet)
				else
					dxDrawRectangle(x,y,w,titsize,titleColor,rendSet)
				end
				local alignment = eleData.alignment
				local font = eleData.font or systemFont
				local textColor = applyColorAlpha(eleData.textColor,galpha)
				local txtSizX,txtSizY = eleData.textSize[1],eleData.textSize[2] or eleData.textSize[1]
				local clip,wordbreak,colorcoded = eleData.clip,eleData.wordbreak,eleData.colorcoded
				local text = eleData.text
				local shadow = eleData.shadow
				if shadow then
					local shadowoffx,shadowoffy,shadowc,shadowIsOutline = shadow[1],shadow[2],shadow[3],shadow[4]
					local textX,textY = x,y
					if shadowoffx and shadowoffy and shadowc then
						local shadowText = colorcoded and text:gsub('#%x%x%x%x%x%x','') or text
						local shadowc = applyColorAlpha(shadowc,galpha)
						dxDrawText(shadowText,textX+shadowoffx,textY+shadowoffy,textX+w+shadowoffx,textY+titsize+shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,rendSet)
						if shadowIsOutline then
							dxDrawText(shadowText,textX-shadowoffx,textY+shadowoffy,textX+w-shadowoffx,textY+titsize+shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,rendSet)
							dxDrawText(shadowText,textX-shadowoffx,textY-shadowoffy,textX+w-shadowoffx,textY+titsize-shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,rendSet)
							dxDrawText(shadowText,textX+shadowoffx,textY-shadowoffy,textX+w+shadowoffx,textY+titsize-shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,rendSet)
						end
					end
				end
				dxDrawText(text,x,y,x+w,y+titsize,textColor,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,rendSet,eleData.colorcoded)
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					local hSideSize = sideSize*0.5
					sideColor = applyColorAlpha(sideColor,galpha)
					local side = outlineData[1]
					if side == "in" then
						dxDrawLine(x,y+hSideSize,x+w,y+hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x+hSideSize,y,x+hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w-hSideSize,y,x+w-hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+h-hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,rendSet)
					elseif side == "center" then
						dxDrawLine(x-hSideSize,y,x+w+hSideSize,y,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+hSideSize,x,y+h-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x+w,y+hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x-hSideSize,y+h,x+w+hSideSize,y+h,sideColor,sideSize,rendSet)
					elseif side == "out" then
						dxDrawLine(x-sideSize,y-hSideSize,x+w+sideSize,y-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x-hSideSize,y,x-hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w+hSideSize,y,x+w+hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize,y+h+hSideSize,x+w+sideSize,y+h+hSideSize,sideColor,sideSize,rendSet)
					end
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if enabled[1] and mx and mx then
					if mx >= x and mx<= x+w and my >= y and my <= y+h then
						MouseData.hit = v
					end
				end
			else
				visible = false
			end
		elseif dxType == "dgs-dxbutton" then
			if x and y then
				if eleData.PixelInt then
					x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
				end
				local colors,imgs = eleData.color,eleData.image
				local colorimgid = 1
				if MouseData.enter == v then
					colorimgid = 2
					if eleData.clickType == 1 then
						if MouseData.clickl == v then
							colorimgid = 3
						end
					elseif eleData.clickType == 2 then
						if MouseData.clickr == v then
							colorimgid = 3
						end
					else
						if MouseData.clickl == v or MouseData.clickr == v then
							colorimgid = 3
						end
					end
				end
				local finalcolor
				if not enabled[1] and not enabled[2] then
					if type(eleData.disabledColor) == "number" then
						finalcolor = applyColorAlpha(eleData.disabledColor,galpha)
					elseif eleData.disabledColor == true then
						local r,g,b,a = fromcolor(colors[1],true)
						local average = (r+g+b)/3*eleData.disabledColorPercent
						finalcolor = tocolor(average,average,average,a*galpha)
					else
						finalcolor = colors[colorimgid]
					end
				else
					finalcolor = applyColorAlpha(colors[colorimgid],galpha)
				end
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if imgs[colorimgid] then
					dxDrawImage(x,y,w,h,imgs[colorimgid],0,0,0,finalcolor,rendSet)
				else
					dxDrawRectangle(x,y,w,h,finalcolor,rendSet)
				end
				local text = eleData.text
				if #text ~= 0 then
					local font = eleData.font or systemFont
					local txtSizX,txtSizY = eleData.textSize[1],eleData.textSize[2] or eleData.textSize[1]
					local clip = eleData.clip
					local wordbreak = eleData.wordbreak
					local colorcoded = eleData.colorcoded
					local alignment = eleData.alignment
					local textOffset = eleData.textOffset
					local txtoffsetsX = textOffset[3] and textOffset[1]*w or textOffset[1]
					local txtoffsetsY = textOffset[3] and textOffset[2]*h or textOffset[2]
					if colorimgid == 3 then
						txtoffsetsX,txtoffsetsY = txtoffsetsX+eleData.clickoffset[1],txtoffsetsY+eleData.clickoffset[2]
					end
					local textX,textY = x+txtoffsetsX,y+txtoffsetsY
					local shadow = eleData.shadow
					if shadow then
						local shadowoffx,shadowoffy,shadowc,shadowIsOutline = shadow[1],shadow[2],shadow[3],shadow[4]
						if shadowoffx and shadowoffy and shadowc then
							local shadowText = colorcoded and text:gsub('#%x%x%x%x%x%x','') or text
							local shadowc = applyColorAlpha(shadowc,galpha)
							dxDrawText(shadowText,textX+shadowoffx,textY+shadowoffy,textX+w+shadowoffx,textY+h+shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,rendSet)
							if shadowIsOutline then
								dxDrawText(shadowText,textX-shadowoffx,textY+shadowoffy,textX+w-shadowoffx,textY+h+shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,rendSet)
								dxDrawText(shadowText,textX-shadowoffx,textY-shadowoffy,textX+w-shadowoffx,textY+h-shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,rendSet)
								dxDrawText(shadowText,textX+shadowoffx,textY-shadowoffy,textX+w+shadowoffx,textY+h-shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,rendSet)
							end
						end
					end
					dxDrawText(text,textX,textY,textX+w-1,textY+h-1,applyColorAlpha(eleData.textColor,galpha),txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,rendSet,colorcoded)
				end
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					local hSideSize = sideSize*0.5
					sideColor = applyColorAlpha(sideColor,galpha)
					local side = outlineData[1]
					if side == "in" then
						dxDrawLine(x,y+hSideSize,x+w,y+hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x+hSideSize,y,x+hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w-hSideSize,y,x+w-hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+h-hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,rendSet)
					elseif side == "center" then
						dxDrawLine(x-hSideSize,y,x+w+hSideSize,y,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+hSideSize,x,y+h-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x+w,y+hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x-hSideSize,y+h,x+w+hSideSize,y+h,sideColor,sideSize,rendSet)
					elseif side == "out" then
						dxDrawLine(x-sideSize,y-hSideSize,x+w+sideSize,y-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x-hSideSize,y,x-hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w+hSideSize,y,x+w+hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize,y+h+hSideSize,x+w+sideSize,y+h+hSideSize,sideColor,sideSize,rendSet)
					end
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if enabled[1] and mx then
					if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
						MouseData.hit = v
					end
				end
			else
				visible = false
			end
		elseif dxType == "dgs-dxeda" then
			if x and y then
				if eleData.PixelInt then
					x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
				end
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if enabled[1] and mx then
					if dgsCheckRadius(v,mx,my) then
						MouseData.hit = v
					end
					if eleData.debug then
						local debugShader = eleData.debugShader
						if debugShader ~= "Error" then
							if not isElement(debugShader) then
								debugShader = dxCreateShader("image/eda/ellipse.fx")
								if isElement(debugShader) then
									eleData.debugShader = debugShader
								else
									outputChatBox("[DGS]Couldn't create ellipse shader (Maybe video memory isn't enough or your video card doesn't support the shader)",255,0,0)
									eleData.debugShader = "Error"
								end
							end
							if MouseData.hit == v then
								dxSetShaderValue(debugShader,"tcolor",{1,0,0,0.5})
							else
								dxSetShaderValue(debugShader,"tcolor",{1,1,1,0.5})
							end
							dxDrawImage(x,y,w,h,debugShader,0,0,0,white,rendSet)
						end
					end
				end
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					local hSideSize = sideSize*0.5
					sideColor = applyColorAlpha(sideColor,galpha)
					local side = outlineData[1]
					if side == "in" then
						dxDrawLine(x,y+hSideSize,x+w,y+hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x+hSideSize,y,x+hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w-hSideSize,y,x+w-hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+h-hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,rendSet)
					elseif side == "center" then
						dxDrawLine(x-hSideSize,y,x+w+hSideSize,y,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+hSideSize,x,y+h-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x+w,y+hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x-hSideSize,y+h,x+w+hSideSize,y+h,sideColor,sideSize,rendSet)
					elseif side == "out" then
						dxDrawLine(x-sideSize,y-hSideSize,x+w+sideSize,y-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x-hSideSize,y,x-hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w+hSideSize,y,x+w+hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize,y+h+hSideSize,x+w+sideSize,y+h+hSideSize,sideColor,sideSize,rendSet)
					end
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
			else
				visible = false
			end
		elseif dxType == "dgs-dxdetectarea" then
			if x and y then
				if eleData.PixelInt then
					x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
				end
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				local color = 0xFFFFFFFF
				if enabled[1] and mx then
					local checkPixel = eleData.checkFunction
					if checkPixel then
						local _mx,_my = (mx-x)/w,(my-y)/h
						if _mx > 0 and _my > 0 and _mx <= 1 and _my <= 1 then
							if type(checkPixel) == "function" then
								local checkFnc = eleData.checkFunction
								if checkFnc((mx-x)/w,(my-y)/h,mx,my) then
									MouseData.hit = v
									color = 0xFFFF0000
								end
							else
								local px,py = dxGetPixelsSize(checkPixel)
								local pixX,pixY = _mx*px,_my*py
								local r,g,b = dxGetPixelColor(checkPixel,pixX-1,pixY-1)
								if r then
									local gray = (r+g+b)/3
									if gray >= 128 then
										MouseData.hit = v
										color = 0xFFFF0000
									end
								end
							end
						end
					end
				end
				local debugTexture = eleData.debugTexture
				if isElement(debugTexture) then
					dxDrawImage(x,y,w,h,debugTexture,0,0,0,color,rendSet)
				end
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					local hSideSize = sideSize*0.5
					sideColor = applyColorAlpha(sideColor,galpha)
					local side = outlineData[1]
					if side == "in" then
						dxDrawLine(x,y+hSideSize,x+w,y+hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x+hSideSize,y,x+hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w-hSideSize,y,x+w-hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+h-hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,rendSet)
					elseif side == "center" then
						dxDrawLine(x-hSideSize,y,x+w+hSideSize,y,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+hSideSize,x,y+h-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x+w,y+hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x-hSideSize,y+h,x+w+hSideSize,y+h,sideColor,sideSize,rendSet)
					elseif side == "out" then
						dxDrawLine(x-sideSize,y-hSideSize,x+w+sideSize,y-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x-hSideSize,y,x-hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w+hSideSize,y,x+w+hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize,y+h+hSideSize,x+w+sideSize,y+h+hSideSize,sideColor,sideSize,rendSet)
					end
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
			else
				visible = false
			end
		elseif dxType == "dgs-dximage" then
			if x and y then
				if eleData.PixelInt then
					x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
				end
				local colors,imgs = eleData.color,eleData.image
				colors = applyColorAlpha(colors,galpha)
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if imgs then
					local uvPos,uvSize = eleData.renderBuffer.UVPos or {},eleData.renderBuffer.UVSize or {}
					local sx,sy = uvSize[1],uvSize[2]
					local px,py = uvPos[1],uvPos[2]
					local rotOffx,rotOffy = eleData.rotationCenter[1],eleData.rotationCenter[2]
					local rot = eleData.rotation or 0
					if not sx or not sy or not px or not py then
						dxDrawImage(x,y,w,h,imgs,rot,rotOffx,rotOffy,colors,rendSet)
					else
						dxDrawImageSection(x,y,w,h,px,py,sx,sy,imgs,rot,rotOffy,rotOffy,colors,rendSet)
					end
				else
					dxDrawRectangle(x,y,w,h,colors,rendSet)
				end
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					sideColor = applyColorAlpha(sideColor,galpha)
					local side = outlineData[1]
					if side == "in" then
						dxDrawLine(x,y+sideSize*0.5,x+w,y+sideSize*0.5,sideColor,sideSize,rendSet)
						dxDrawLine(x+sideSize*0.5,y,x+sideSize*0.5,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w-sideSize*0.5,y,x+w-sideSize*0.5,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+h-sideSize*0.5,x+w,y+h-sideSize*0.5,sideColor,sideSize,rendSet)
					elseif side == "center" then
						dxDrawLine(x-sideSize*0.5,y,x+w+sideSize*0.5,y,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+sideSize*0.5,x,y+h-sideSize*0.5,sideColor,sideSize,rendSet)
						dxDrawLine(x+w,y+sideSize*0.5,x+w,y+h-sideSize*0.5,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize*0.5,y+h,x+w+sideSize*0.5,y+h,sideColor,sideSize,rendSet)
					elseif side == "out" then
						dxDrawLine(x-sideSize,y-sideSize*0.5,x+w+sideSize,y-sideSize*0.5,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize*0.5,y,x-sideSize*0.5,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w+sideSize*0.5,y,x+w+sideSize*0.5,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize,y+h+sideSize*0.5,x+w+sideSize,y+h+sideSize*0.5,sideColor,sideSize,rendSet)
					end
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if enabled[1] and mx then
					if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
						MouseData.hit = v
					end
				end
			else
				visible = false
			end
		elseif dxType == "dgs-dxradiobutton" then
			if x and y then
				if eleData.PixelInt then
					x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
				end
				local image_f,image_t = eleData.image_f,eleData.image_t
				local color_f,color_t = eleData.color_f,eleData.color_t
				local rbParent = eleData.rbParent
				local image,color
				local _buttonSize = eleData.buttonSize
				local buttonSizeX,buttonSizeY
				if tonumber(_buttonSize[2]) then
					buttonSizeX = _buttonSize[3] and _buttonSize[1]*w or _buttonSize[1]
					buttonSizeY = _buttonSize[3] and _buttonSize[2]*h or _buttonSize[2]
				else
					buttonSizeX = _buttonSize[2] and _buttonSize[1]*h or _buttonSize[1]
					buttonSizeY = buttonSizeX
				end
				if dgsElementData[rbParent].RadioButton == v then
					image,color = image_t,color_t
				else
					image,color = image_f,color_f
				end
				local colorimgid = 1
				if MouseData.enter == v then
					colorimgid = 2
					if eleData.clickType == 1 then
						if MouseData.clickl == v then
							colorimgid = 3
						end
					elseif eleData.clickType == 2 then
						if MouseData.clickr == v then
							colorimgid = 3
						end
					else
						if MouseData.clickl == v or MouseData.clickr == v then
							colorimgid = 3
						end
					end
				end
				local finalcolor
				if not enabled[1] and not enabled[2] then
					if type(eleData.disabledColor) == "number" then
						finalcolor = applyColorAlpha(eleData.disabledColor,galpha)
					elseif eleData.disabledColor == true then
						local r,g,b,a = fromcolor(color[1],true)
						local average = (r+g+b)/3*eleData.disabledColorPercent
						finalcolor = tocolor(average,average,average,a*galpha)
					else
						finalcolor = color[colorimgid]
					end
				else
					finalcolor = applyColorAlpha(color[colorimgid],galpha)
				end
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if image[colorimgid] then
					dxDrawImage(x,y+h*0.5-buttonSizeY*0.5,buttonSizeX,buttonSizeY,image[colorimgid],0,0,0,finalcolor,rendSet)
				else
					dxDrawRectangle(x,y+h*0.5-buttonSizeY*0.5,buttonSizeX,buttonSizeY,finalcolor,rendSet)
				end
				local font = eleData.font or systemFont
				local txtSizX,txtSizY = eleData.textSize[1],eleData.textSize[2] or eleData.textSize[1]
				local clip = eleData.clip
				local wordbreak = eleData.wordbreak
				local _textImageSpace = eleData.textImageSpace
				local text = eleData.text
				local textImageSpace = _textImageSpace[2] and _textImageSpace[1]*w or _textImageSpace[1]
				local colorcoded = eleData.colorcoded
				local alignment = eleData.alignment
				local px = x+buttonSizeX+textImageSpace
				if eleData.PixelInt then
					px,y,w,h = px-px%1,y-y%1,w-w%1,h-h%1
				end			
				local shadow = eleData.shadow
				if shadow then
					local shadowoffx,shadowoffy,shadowc,shadowIsOutline = shadow[1],shadow[2],shadow[3],shadow[4]
					local textX,textY = px,y
					if shadowoffx and shadowoffy and shadowc then
						shadowc = applyColorAlpha(shadowc,galpha)
						local shadowText = colorcoded and text:gsub('#%x%x%x%x%x%x','') or text
						dxDrawText(shadowText,textX+shadowoffx,textY+shadowoffy,textX+w+shadowoffx,textY+h+shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,rendSet)
						if shadowIsOutline then
							dxDrawText(shadowText,textX-shadowoffx,textY+shadowoffy,textX+w-shadowoffx,textY+h+shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,rendSet)
							dxDrawText(shadowText,textX-shadowoffx,textY-shadowoffy,textX+w-shadowoffx,textY+h-shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,rendSet)
							dxDrawText(shadowText,textX+shadowoffx,textY-shadowoffy,textX+w+shadowoffx,textY+h-shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,rendSet)
						end
					end
				end
				dxDrawText(eleData.text,px,y,px+w-1,y+h-1,applyColorAlpha(eleData.textColor,galpha),txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,rendSet,colorcoded)
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					local hSideSize = sideSize*0.5
					sideColor = applyColorAlpha(sideColor,galpha)
					local side = outlineData[1]
					if side == "in" then
						dxDrawLine(x,y+hSideSize,x+w,y+hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x+hSideSize,y,x+hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w-hSideSize,y,x+w-hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+h-hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,rendSet)
					elseif side == "center" then
						dxDrawLine(x-hSideSize,y,x+w+hSideSize,y,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+hSideSize,x,y+h-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x+w,y+hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x-hSideSize,y+h,x+w+hSideSize,y+h,sideColor,sideSize,rendSet)
					elseif side == "out" then
						dxDrawLine(x-sideSize,y-hSideSize,x+w+sideSize,y-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x-hSideSize,y,x-hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w+hSideSize,y,x+w+hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize,y+h+hSideSize,x+w+sideSize,y+h+hSideSize,sideColor,sideSize,rendSet)
					end
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if enabled[1] and mx then
					if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
						MouseData.hit = v
					end
				end
			else
				visible = false
			end
		elseif dxType == "dgs-dxcheckbox" then
			if x and y then
				if eleData.PixelInt then
					x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
				end
				local image_f,image_t,image_i = eleData.image_f,eleData.image_t,eleData.image_i
				local color_f,color_t,color_i = eleData.color_f,eleData.color_t,eleData.color_i
				local image,color
				local _buttonSize = eleData.buttonSize
				local buttonSizeX,buttonSizeY
				if tonumber(_buttonSize[2]) then
					buttonSizeX = _buttonSize[3] and _buttonSize[1]*w or _buttonSize[1]
					buttonSizeY = _buttonSize[3] and _buttonSize[2]*h or _buttonSize[2]
				else
					buttonSizeX = _buttonSize[2] and _buttonSize[1]*h or _buttonSize[1]
					buttonSizeY = buttonSizeX
				end
				if eleData.state == true then
					image,color = image_t,color_t
				elseif eleData.state == false then 
					image,color = image_f,color_f
				else
					image,color = image_i,color_i
				end
				local colorimgid = 1
				if MouseData.enter == v then
					colorimgid = 2
					if eleData.clickType == 1 then
						if MouseData.clickl == v then
							colorimgid = 3
						end
					elseif eleData.clickType == 2 then
						if MouseData.clickr == v then
							colorimgid = 3
						end
					else
						if MouseData.clickl == v or MouseData.clickr == v then
							colorimgid = 3
						end
					end
				end
				local finalcolor
				if not enabled[1] and not enabled[2] then
					if type(eleData.disabledColor) == "number" then
						finalcolor = applyColorAlpha(eleData.disabledColor,galpha)
					elseif eleData.disabledColor == true then
						local r,g,b,a = fromcolor(color[1],true)
						local average = (r+g+b)/3*eleData.disabledColorPercent
						finalcolor = tocolor(average,average,average,a*galpha)
					else
						finalcolor = color[colorimgid]
					end
				else
					finalcolor = applyColorAlpha(color[colorimgid],galpha)
				end
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if image[colorimgid] then
					dxDrawImage(x,y+h*0.5-buttonSizeY*0.5,buttonSizeX,buttonSizeY,image[colorimgid],0,0,0,finalcolor,rendSet)
				else
					dxDrawRectangle(x,y+h*0.5-buttonSizeY*0.5,buttonSizeX,buttonSizeY,finalcolor,rendSet)
				end
				local font = eleData.font or systemFont
				local txtSizX,txtSizY = eleData.textSize[1],eleData.textSize[2] or eleData.textSize[1]
				local clip = eleData.clip
				local wordbreak = eleData.wordbreak
				local _textImageSpace = eleData.textImageSpace
				local textImageSpace = _textImageSpace[2] and _textImageSpace[1]*w or _textImageSpace[1]
				local text = eleData.text
				local colorcoded = eleData.colorcoded
				local alignment = eleData.alignment
				local px = x+buttonSizeX+textImageSpace
				if eleData.PixelInt then
					px,y,w,h = px-px%1,y-y%1,w-w%1,h-h%1
				end
				local shadow = eleData.shadow
				if shadow then
					local shadowoffx,shadowoffy,shadowc,shadowIsOutline = shadow[1],shadow[2],shadow[3],shadow[4]
					local textX,textY = px,y
					if shadowoffx and shadowoffy and shadowc then
						local shadowc = applyColorAlpha(shadowc,galpha)
						local shadowText = colorcoded and text:gsub('#%x%x%x%x%x%x','') or text
						dxDrawText(shadowText,textX+shadowoffx,textY+shadowoffy,textX+w+shadowoffx,textY+h+shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,rendSet)
						if shadowIsOutline then
							dxDrawText(shadowText,textX-shadowoffx,textY+shadowoffy,textX+w-shadowoffx,textY+h+shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,rendSet)
							dxDrawText(shadowText,textX-shadowoffx,textY-shadowoffy,textX+w-shadowoffx,textY+h-shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,rendSet)
							dxDrawText(shadowText,textX+shadowoffx,textY-shadowoffy,textX+w+shadowoffx,textY+h-shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,rendSet)
						end
					end
				end
				dxDrawText(text,px,y,px+w-1,y+h-1,applyColorAlpha(eleData.textColor,galpha),txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,rendSet,colorcoded)
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					local hSideSize = sideSize*0.5
					sideColor = applyColorAlpha(sideColor,galpha)
					local side = outlineData[1]
					if side == "in" then
						dxDrawLine(x,y+hSideSize,x+w,y+hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x+hSideSize,y,x+hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w-hSideSize,y,x+w-hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+h-hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,rendSet)
					elseif side == "center" then
						dxDrawLine(x-hSideSize,y,x+w+hSideSize,y,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+hSideSize,x,y+h-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x+w,y+hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x-hSideSize,y+h,x+w+hSideSize,y+h,sideColor,sideSize,rendSet)
					elseif side == "out" then
						dxDrawLine(x-sideSize,y-hSideSize,x+w+sideSize,y-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x-hSideSize,y,x-hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w+hSideSize,y,x+w+hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize,y+h+hSideSize,x+w+sideSize,y+h+hSideSize,sideColor,sideSize,rendSet)
					end
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if enabled[1] and mx then
					if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
						MouseData.hit = v
					end
				end
			else
				visible = false
			end
		elseif dxType == "dgs-dxedit" then
			if x and y then
				if eleData.PixelInt then
					x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
				end
				local bgImage = eleData.isFocused and eleData.bgImage or (eleData.bgImageBlur or eleData.bgImage)
				local bgColor = eleData.isFocused and eleData.bgColor or (eleData.bgColorBlur or eleData.bgColor)
				
				bgColor = applyColorAlpha(bgColor,galpha)
				local caretColor = applyColorAlpha(eleData.caretColor,galpha)
				if MouseData.nowShow == v then
					if isConsoleActive() or isMainMenuActive() or isChatBoxInputActive() then
						MouseData.nowShow = false
					end
				end
				local text = eleData.text
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						text = fnc[1](unpack(fnc[2])) or text
					end
				end
				------------------------------------
				if eleData.masked then
					text = rep(eleData.maskText,utf8Len(text))
				end
				local caretPos = eleData.caretPos
				local selectFro = eleData.selectFrom
				local selectColor = MouseData.nowShow == v and eleData.selectColor or eleData.selectColorBlur
				local font = eleData.font or systemFont
				local txtSizX,txtSizY = eleData.textSize[1],eleData.textSize[2] or eleData.textSize[1]
				local renderTarget = eleData.renderTarget
				local alignment = eleData.alignment
				if isElement(renderTarget) then
					local textColor = eleData.textColor
					local selx = 0
					if selectFro-caretPos > 0 then
						selx = dxGetTextWidth(utf8Sub(text,caretPos+1,selectFro),txtSizX,font)
					elseif selectFro-caretPos < 0 then
						selx = -dxGetTextWidth(utf8Sub(text,selectFro+1,caretPos),txtSizX,font)
					end
					local showPos = eleData.showPos
					local padding = eleData.padding
					local sidelength,sideheight = padding[1]-padding[1]%1,padding[2]-padding[2]%1
					local caretHeight = eleData.caretHeight
					local textX_Left,textX_Right
					local insideH = h-sideheight*2
					local selStartY = insideH/2-insideH/2*caretHeight
					local selEndY = (insideH/2-selStartY)*2
					local width,selectX,selectW
					local posFix = 0
					local placeHolder = eleData.placeHolder
					local placeHolderIgnoreRndTgt = eleData.placeHolderIgnoreRenderTarget
					local placeHolderOffset = eleData.placeHolderOffset
					dxSetRenderTarget(renderTarget,true)
					dxSetBlendMode("modulate_add")
					if alignment[1] == "left" then
						width = dxGetTextWidth(utf8Sub(text,0,caretPos),txtSizX,font)
						textX_Left,textX_Right = showPos,w-sidelength
						selectX,selectW = width+showPos,selx
						if selx ~= 0 then
							dxDrawRectangle(selectX,selStartY,selectW,selEndY,selectColor)
						end
					elseif alignment[1] == "center" then
						local __width = eleData.textFontLen
						width = dxGetTextWidth(utf8Sub(text,0,caretPos),txtSizX,font)
						textX_Left,textX_Right = showPos,w-sidelength
						selectX,selectW = width+showPos*0.5+w*0.5-__width*0.5-sidelength+1,selx
						if selx ~= 0 then
							dxDrawRectangle(selectX,selStartY,selectW,selEndY,selectColor)
						end
						posFix = ((text:reverse():find("%S") or 1)-1)*dxGetTextWidth(" ",txtSizX,font)
					elseif alignment[1] == "right" then
						width = dxGetTextWidth(utf8Sub(text,caretPos+1),txtSizX,font)
						textX_Left,textX_Right = x,w-sidelength*2-showPos
						selectX,selectW = textX_Right-width,selx
						if selx ~= 0 then
							dxDrawRectangle(selectX,selStartY,selectW,selEndY,selectColor)
						end
						posFix = ((text:reverse():find("%S") or 1)-1)*dxGetTextWidth(" ",txtSizX,font)
					end
					textX_Left = textX_Left-textX_Left%1
					textX_Right = textX_Right-textX_Right%1
					if not placeHolderIgnoreRndTgt then
						if text == "" and MouseData.nowShow ~= v then
							local pColor = eleData.placeHolderColor
							local pFont = eleData.placeHolderFont
							local pColorcoded = eleData.placeHolderColorcoded
							dxDrawText(placeHolder,textX_Left+placeHolderOffset[1],placeHolderOffset[2],textX_Right-posFix+placeHolderOffset[1],h-sidelength+placeHolderOffset[2],pColor,txtSizX,txtSizY,pFont,alignment[1],alignment[2],false,false,false,pColorcoded)
						end
					end
					if eleData.autoCompleteShow then
						dxDrawText(eleData.autoCompleteShow[2],textX_Left,0,textX_Right-posFix,h-sidelength,applyColorAlpha(textColor,0.2),txtSizX,txtSizY,font,alignment[1],alignment[2],false,false,false,false)
					end
					dxDrawText(text,textX_Left,0,textX_Right-posFix,h-sidelength,textColor,txtSizX,txtSizY,font,alignment[1],alignment[2],false,false,false,false)
					if eleData.underline then
						local textHeight = dxGetFontHeight(txtSizY,font)
						local lineOffset = eleData.underlineOffset+h*0.5+textHeight*0.5
						local lineWidth = eleData.underlineWidth
						local textFontLen = eleData.textFontLen
						dxDrawLine(showPos,lineOffset,showPos+textFontLen,lineOffset,textColor,lineWidth)
					end
					dxSetRenderTarget(rndtgt)
					dxSetBlendMode(rndtgt and "modulate_add" or "blend")
					local finalcolor
					if not enabled[1] and not enabled[2] then
						if type(eleData.disabledColor) == "number" then
							finalcolor = eleData.disabledColor
						elseif eleData.disabledColor == true then
							local r,g,b,a = fromcolor(bgColor,true)
							local average = (r+g+b)/3*eleData.disabledColorPercent
							finalcolor = tocolor(average,average,average,a)
						else
							finalcolor = bgColor
						end
					else
						finalcolor = bgColor
					end
					if bgImage then
						dxDrawImage(x,y,w,h,bgImage,0,0,0,finalcolor,rendSet)
					else
						dxDrawRectangle(x,y,w,h,finalcolor,rendSet)
					end
					local px,py,pw,ph = x+sidelength,y+sideheight,w-sidelength*2,h-sideheight*2
					dxDrawImage(px,py,pw,ph,renderTarget,0,0,0,tocolor(255,255,255,255*galpha),rendSet)
					if placeHolderIgnoreRndTgt then
						if text == "" and MouseData.nowShow ~= v then
							local pColor = applyColorAlpha(eleData.placeHolderColor,galpha)
							local pFont = eleData.placeHolderFont
							local pColorcoded = eleData.placeHolderColorcoded
							dxSetBlendMode(rndtgt and "modulate_add" or "blend")
							dxDrawText(placeHolder,px+textX_Left+placeHolderOffset[1],py+placeHolderOffset[2],px+textX_Right-posFix+placeHolderOffset[1],py+h-sidelength+placeHolderOffset[2],pColor,txtSizX,txtSizY,pFont,alignment[1],alignment[2],false,false,rendSet,pColorcoded)
						end
					end
					if MouseData.nowShow == v and MouseData.editMemoCursor then
						local CaretShow = true
						if eleData.readOnly then
							CaretShow = eleData.readOnlyCaretShow
						end
						if CaretShow then
							local caretStyle = eleData.caretStyle
							local selStartX = selectX+x+sidelength
							selStartX = selStartX-selStartX%1
							if caretStyle == 0 then
								if selStartX+1 >= x+sidelength and selStartX <= x+w-sidelength then
									local selStartY = h/2-h/2*caretHeight+sideheight
									local selEndY = (h/2-selStartY)*2
									dxDrawLine(selStartX,y+selStartY,selStartX,y+selEndY+selStartY,caretColor,eleData.caretThick,noRenderTarget)
								end
							elseif caretStyle == 1 then
								local cursorWidth = dxGetTextWidth(utf8Sub(text,caretPos+1,caretPos+1),txtSizX,font)
								if cursorWidth == 0 then
									cursorWidth = txtSizX*8
								end
								if selStartX+1 >= x+sidelength and selStartX+cursorWidth <= x+w-sidelength then
									local offset = eleData.caretOffset
									local selStartY = y+h/2-h/2*caretHeight+sideheight
									dxDrawLine(selStartX,selStartY-offset,selStartX+cursorWidth,selStartY-offset,caretColor,eleData.caretThick,noRenderTarget)
								end
							end
						end
					end
				end
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					local hSideSize = sideSize*0.5
					sideColor = applyColorAlpha(sideColor,galpha)
					local side = outlineData[1]
					if side == "in" then
						dxDrawLine(x,y+hSideSize,x+w,y+hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x+hSideSize,y,x+hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w-hSideSize,y,x+w-hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+h-hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,rendSet)
					elseif side == "center" then
						dxDrawLine(x-hSideSize,y,x+w+hSideSize,y,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+hSideSize,x,y+h-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x+w,y+hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x-hSideSize,y+h,x+w+hSideSize,y+h,sideColor,sideSize,rendSet)
					elseif side == "out" then
						dxDrawLine(x-sideSize,y-hSideSize,x+w+sideSize,y-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x-hSideSize,y,x-hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w+hSideSize,y,x+w+hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize,y+h+hSideSize,x+w+sideSize,y+h+hSideSize,sideColor,sideSize,rendSet)
					end
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if enabled[1] and mx then
					if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
						MouseData.hit = v
					end
				end
			else
				visible = false
			end
		elseif dxType == "dgs-dxmemo" then
			if x and y then
				if eleData.configNextFrame then
					configMemo(v)
				end
				if eleData.PixelInt then
					x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
				end
				local bgImage = eleData.bgImage
				local bgColor = applyColorAlpha(eleData.bgColor,galpha)
				local caretColor = applyColorAlpha(eleData.caretColor,galpha)
				if MouseData.nowShow == v then
					if isConsoleActive() or isMainMenuActive() or isChatBoxInputActive() then
						MouseData.nowShow = false
					end
				end
				local text = eleData.text
				local caretPos = eleData.caretPos
				local selectFro = eleData.selectFrom
				local selectColor = MouseData.nowShow == v and eleData.selectColor or eleData.selectColorBlur
				local font = eleData.font or systemFont
				local txtSizX,txtSizY = eleData.textSize[1],eleData.textSize[2]
				local renderTarget = eleData.renderTarget
				local fontHeight = dxGetFontHeight(eleData.textSize[2],font)
				local wordwarp = eleData.wordWarp
				local scbThick = eleData.scrollBarThick
				local scrollbars = eleData.scrollbars
				local selectVisible = eleData.selectVisible
				local finalcolor
				if not enabled[1] and not enabled[2] then
					if type(eleData.disabledColor) == "number" then
						finalcolor = eleData.disabledColor
					elseif eleData.disabledColor == true then
						local r,g,b,a = fromcolor(bgColor,true)
						local average = (r+g+b)/3*eleData.disabledColorPercent
						finalcolor = tocolor(average,average,average,a)
					else
						finalcolor = bgColor
					end
				else
					finalcolor = bgColor
				end
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if isElement(renderTarget) then
					if wordwarp then
						if eleData.rebuildMapTableNextFrame then
							dgsMemoRebuildWordWarpMapTable(v)
						end
						local allLines = #eleData.wordWarpMapText
						local textColor = eleData.textColor
						local showLine = eleData.showLine
						local wordWarpShowLine = eleData.wordWarpShowLine
						local caretHeight = eleData.caretHeight-1
						local canHoldLines = floor((h-4)/fontHeight)
						canHoldLines = canHoldLines > allLines and allLines or canHoldLines
						dxSetRenderTarget(renderTarget,true)
						dxSetBlendMode("modulate_add")
						local showPos = eleData.showPos
						local caretRltHeight = fontHeight*caretHeight
						local caretDrawPos
						local selPosStart,selPosEnd,selStart,selEnd
						if selectVisible and allLines > 0 then
							if selectFro[2] > caretPos[2] then
								selStart,selEnd = caretPos[2],selectFro[2]
								selPosStart,selPosEnd = caretPos[1],selectFro[1]
							elseif selectFro[2] < caretPos[2] then
								selStart,selEnd = selectFro[2],caretPos[2]
								selPosStart,selPosEnd = selectFro[1],caretPos[1]
							else
								selStart,selEnd = caretPos[2],selectFro[2]
								if selectFro[1] > caretPos[1] then
									selPosStart,selPosEnd = caretPos[1],selectFro[1]
								else
									selPosStart,selPosEnd = selectFro[1],caretPos[1]
								end
							end
							local isInWeakLine = false
							local lineCnt = 0
							local rndLine,rndPos,totalLine = eleData.wordWarpShowLine[1],eleData.wordWarpShowLine[2],eleData.wordWarpShowLine[3]
							if rndLine <= 1 then
								rndLine = 1
							end
							local caretPos = eleData.caretPos
							for a=rndLine,#text do
								local weakLinePos = 0
								local nextWeakLineLen = 0
								for b=1,#text[a][1] do
									weakLineLen = text[a][1][b][3]
									if b >= rndPos then
										local ypos = lineCnt*fontHeight
										local renderingText = text[a][1][b][0]
										if a == selStart or a == selEnd then
											if a == selStart and a == selEnd then
												if selPosStart >= weakLinePos then
													local startPosX = dxGetTextWidth(utf8Sub(renderingText,0,selPosStart-weakLinePos),txtSizX,font)
													local selectLen = dxGetTextWidth(utf8Sub(renderingText,selPosStart-weakLinePos+1,selPosEnd-weakLinePos),txtSizX,font)
													dxDrawRectangle(-showPos+startPosX,ypos-caretRltHeight,selectLen,caretRltHeight+fontHeight,selectColor)
												elseif selPosStart < weakLinePos and selPosEnd > weakLinePos+weakLineLen then
													local startPosX = dxGetTextWidth(renderingText,txtSizX,font)
													dxDrawRectangle(-showPos,ypos-caretRltHeight,startPosX,caretRltHeight+fontHeight,selectColor)
												elseif selPosEnd >= weakLinePos and selPosEnd <= weakLinePos+weakLineLen then
													local selectLen = dxGetTextWidth(utf8Sub(renderingText,0,selPosEnd-weakLinePos),txtSizX,font)
													dxDrawRectangle(-showPos,ypos-caretRltHeight,selectLen,caretRltHeight+fontHeight,selectColor)
												end
											elseif a == selStart then
												if selPosStart >= weakLinePos and selPosStart <= weakLinePos+weakLineLen then
													local startPosX = dxGetTextWidth(utf8Sub(renderingText,0,selPosStart-weakLinePos),txtSizX,font)
													local selectLen = dxGetTextWidth(utf8Sub(renderingText,selPosStart-weakLinePos+1),txtSizX,font)
													dxDrawRectangle(-showPos+startPosX,ypos-caretRltHeight,selectLen,caretRltHeight+fontHeight,selectColor)
												elseif selPosStart <= weakLinePos then
													dxDrawRectangle(-showPos,ypos-caretRltHeight,dxGetTextWidth(renderingText,txtSizX,font),caretRltHeight+fontHeight,selectColor)
												end
											elseif a == selEnd then
												if selPosEnd >= weakLinePos and selPosEnd <= weakLinePos+weakLineLen then
													local selectLen = dxGetTextWidth(utf8Sub(renderingText,0,selPosEnd-weakLinePos),txtSizX,font)
													dxDrawRectangle(-showPos,ypos-caretRltHeight,selectLen,caretRltHeight+fontHeight,selectColor)
												elseif selPosEnd >= weakLinePos then
													dxDrawRectangle(-showPos,ypos-caretRltHeight,dxGetTextWidth(renderingText,txtSizX,font),caretRltHeight+fontHeight,selectColor)
												end
											end
										elseif a > selStart and a < selEnd then
											dxDrawRectangle(-showPos,ypos-caretRltHeight,dxGetTextWidth(renderingText,txtSizX,font),caretRltHeight+fontHeight,selectColor)
										end
										if caretPos[2] == a then
											if caretPos[1] >= weakLinePos and caretPos[1] <= weakLinePos+weakLineLen then
												local indexInWeakLine = caretPos[1]-weakLinePos
												caretDrawPos = {x-showPos,y+ypos,utf8Sub(renderingText,1,indexInWeakLine),utf8Sub(renderingText,indexInWeakLine+1,indexInWeakLine+1)}
											end
										end
										dxDrawText(renderingText,-showPos,ypos,-showPos,fontHeight+ypos,textColor,txtSizX,txtSizY,font,"left","top",false,false,false,false)
										rndPos = 1
										lineCnt = lineCnt + 1
									end
									weakLinePos = weakLinePos+weakLineLen
									if lineCnt > canHoldLines then
										break
									end
								end
								if lineCnt > canHoldLines then
									break
								end
							end
						end
						dxSetRenderTarget(rndtgt)
						dxSetBlendMode(rndtgt and "modulate_add" or "add")
						if bgImage then
							dxDrawImage(x,y,w,h,bgImage,0,0,0,finalcolor,rendSet)
						else
							dxDrawRectangle(x,y,w,h,finalcolor,rendSet)
						end
						local scbTakes1,scbTakes2 = dgsElementData[scrollbars[1]].visible and scbThick+2 or 4,dgsElementData[scrollbars[2]].visible and scbThick or 0
						dxSetBlendMode("add")
						dxDrawImageSection(x+2,y,w-scbTakes1,h-scbTakes2,0,0,w-scbTakes1,h-scbTakes2,renderTarget,0,0,0,tocolor(255,255,255,255*galpha),rendSet)
						dxSetBlendMode(rndtgt and "modulate_add" or "blend")
						if MouseData.nowShow == v and MouseData.editMemoCursor then
							local CaretShow = true
							if eleData.readOnly then
								CaretShow = eleData.readOnlyCaretShow
							end
							if CaretShow and caretDrawPos then
								local caretStyle = eleData.caretStyle
								local caretRenderX = caretDrawPos[1]+dxGetTextWidth(caretDrawPos[3],txtSizX,font)+1
								if caretStyle == 0 then
									dxDrawLine(caretRenderX,caretDrawPos[2],caretRenderX,caretDrawPos[2]+fontHeight*(1-caretHeight),caretColor,eleData.caretThick,noRenderTarget)
								elseif caretStyle == 1 then
									local cursorWidth = dxGetTextWidth(caretDrawPos[4],txtSizX,font)
									if cursorWidth == 0 then
										cursorWidth = txtSizX*8
									end
									local offset = eleData.caretOffset
									local caretRenderX = caretDrawPos[1]+dxGetTextWidth(caretDrawPos[3],txtSizX,font)+1
									local caretRenderY = caretDrawPos[2]+fontHeight*(1-caretHeight)*0.85+offset-2
									dxDrawLine(caretRenderX,caretRenderY,caretRenderX+cursorWidth,caretRenderY,caretColor,eleData.caretThick,noRenderTarget)
								end
							end
						end
					else
						local allLine = #text
						local textColor = eleData.textColor
						local showLine = eleData.showLine
						local caretHeight = eleData.caretHeight-1
						local canHoldLines = floor((h-4)/fontHeight)
						canHoldLines = canHoldLines > allLine and allLine or canHoldLines
						local selPosStart,selPosEnd,selStart,selEnd
						dxSetRenderTarget(renderTarget,true)
						dxSetBlendMode("modulate_add")
						local showPos = eleData.showPos
						if selectVisible and allLine > 0 then
							local toShowLine = showLine+canHoldLines
							toShowLine = toShowLine > allLine and allLine or toShowLine
							if selectFro[2] > caretPos[2] then
								selStart,selEnd = caretPos[2],selectFro[2]
								selPosStart,selPosEnd = caretPos[1],selectFro[1]
							elseif selectFro[2] < caretPos[2] then
								selStart,selEnd = selectFro[2],caretPos[2]
								selPosStart,selPosEnd = selectFro[1],caretPos[1]
							else
								selStart,selEnd = caretPos[2],selectFro[2]
								if selectFro[1] > caretPos[1] then
									selPosStart,selPosEnd = caretPos[1],selectFro[1]
								else
									selPosStart,selPosEnd = selectFro[1],caretPos[1]
								end
							end
							local caretRltHeight = fontHeight*caretHeight
							for i=showLine,toShowLine do
								local ypos = (i-showLine)*fontHeight
								if i == selStart or i == selEnd then
									if i == selStart and i == selEnd then
										local startPosX = dxGetTextWidth(utf8Sub(text[i][0],0,selPosStart),txtSizX,font)
										local selectLen = dxGetTextWidth(utf8Sub(text[i][0],selPosStart+1,selPosEnd),txtSizX,font)
										dxDrawRectangle(-showPos+startPosX,ypos-caretRltHeight,selectLen,caretRltHeight+fontHeight,selectColor)
									elseif i == selStart then
										local startPosX = dxGetTextWidth(utf8Sub(text[i][0],0,selPosStart),txtSizX,font)
										local selectLen = dxGetTextWidth(utf8Sub(text[i][0],selPosStart+1),txtSizX,font)
										dxDrawRectangle(-showPos+startPosX,ypos-caretRltHeight,selectLen,caretRltHeight+fontHeight,selectColor)
									elseif i == selEnd then
										local selectLen = dxGetTextWidth(utf8Sub(text[i][0],0,selPosEnd),txtSizX,font)
										dxDrawRectangle(-showPos,ypos-caretRltHeight,selectLen,caretRltHeight+fontHeight,selectColor)
									end
								elseif i > selStart and i < selEnd then
									dxDrawRectangle(-showPos,ypos-caretRltHeight,text[i][-1],caretRltHeight+fontHeight,selectColor)
								end
								dxDrawText(text[i][0],-showPos,ypos,-showPos,fontHeight+ypos,textColor,txtSizX,txtSizY,font,"left","top",false,false,false,false)
							end
						end
						dxSetRenderTarget(rndtgt)
						dxSetBlendMode(rndtgt and "modulate_add" or "add")
						if bgImage then
							dxDrawImage(x,y,w,h,bgImage,0,0,0,finalcolor,rendSet)
						else
							dxDrawRectangle(x,y,w,h,finalcolor,rendSet)
						end
						local scbTakes1,scbTakes2 = dgsElementData[scrollbars[1]].visible and scbThick+2 or 4,dgsElementData[scrollbars[2]].visible and scbThick or 0
						dxSetBlendMode("add")
						dxDrawImageSection(x+2,y,w-scbTakes1,h-scbTakes2,0,0,w-scbTakes1,h-scbTakes2,renderTarget,0,0,0,tocolor(255,255,255,255*galpha),rendSet)
						dxSetBlendMode(rndtgt and "modulate_add" or "blend")
						if MouseData.nowShow == v and MouseData.editMemoCursor then
							local CaretShow = true
							if eleData.readOnly then
								CaretShow = eleData.readOnlyCaretShow
							end
							if CaretShow then
								local showLine = eleData.showLine
								local currentLine = eleData.caretPos[2]
								if currentLine >= showLine and currentLine <= showLine+canHoldLines then
									local lineStart = fontHeight*(currentLine-showLine)
									local theText = (text[caretPos[2]] or {[0]=""})[0]
									local cursorPX = caretPos[1]
									local width = dxGetTextWidth(utf8Sub(theText,1,cursorPX),txtSizX,font)
									if eleData.caretStyle == 0 then
										local selStartY = y+lineStart+fontHeight*(1-caretHeight)
										local selEndY = y+lineStart+fontHeight*caretHeight
										dxDrawLine(x+width-showPos+1,selStartY,x+width-showPos+1,selEndY,caretColor,eleData.caretThick,noRenderTarget)
									elseif eleData.caretStyle == 1 then
										local cursorWidth = dxGetTextWidth(utf8Sub(theText,cursorPX+1,cursorPX+1),txtSizX,font)
										cursorWidth = cursorWidth ~= 0 and cursorWidth or txtSizX*8
										local offset = eleData.caretOffset
										dxDrawLine(x+width-showPos+1,y+h-4+offset,x+width-showPos+cursorWidth+2,y+h-4+offset,caretColor,eleData.caretThick,noRenderTarget)
									end
								end
							end
						end
					end
				end
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					local hSideSize = sideSize*0.5
					sideColor = applyColorAlpha(sideColor,galpha)
					local side = outlineData[1]
					if side == "in" then
						dxDrawLine(x,y+hSideSize,x+w,y+hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x+hSideSize,y,x+hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w-hSideSize,y,x+w-hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+h-hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,rendSet)
					elseif side == "center" then
						dxDrawLine(x-hSideSize,y,x+w+hSideSize,y,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+hSideSize,x,y+h-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x+w,y+hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x-hSideSize,y+h,x+w+hSideSize,y+h,sideColor,sideSize,rendSet)
					elseif side == "out" then
						dxDrawLine(x-sideSize,y-hSideSize,x+w+sideSize,y-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x-hSideSize,y,x-hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w+hSideSize,y,x+w+hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize,y+h+hSideSize,x+w+sideSize,y+h+hSideSize,sideColor,sideSize,rendSet)
					end
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if enabled[1] and mx then
					if mx >= cx-2 and mx<= cx+w-1 and my >= cy-2 and my <= cy+h-1 then
						MouseData.hit = v
					end
				end
			else
				visible = false
			end
		elseif dxType == "dgs-dxscrollpane" then
			if eleData.configNextFrame then
				configScrollPane(v)
			end
			if x and y then
				if eleData.PixelInt then
					x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
				end
				local scrollbar = eleData.scrollbars
				local scbThick = eleData.scrollBarThick
				local scbstate = {dgsElementData[scrollbar[1]].visible,dgsElementData[scrollbar[2]].visible}
				local xthick = scbstate[1] and scbThick or 0
				local ythick = scbstate[2] and scbThick or 0
				local maxSize = eleData.maxChildSize
				local relSizX,relSizY = w-xthick,h-ythick
				local maxX,maxY = (maxSize[1]-relSizX),(maxSize[2]-relSizY)
				maxX,maxY = maxX > 0 and maxX or 0,maxY > 0 and maxY or 0
				OffsetX = -maxX*dgsElementData[scrollbar[2]].position*0.01
				OffsetY = -maxY*dgsElementData[scrollbar[1]].position*0.01
				if OffsetX > 0 then
					OffsetX = 0
				end
				if OffsetY > 0 then
					OffsetY = 0
				end
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				local newRndTgt = eleData.renderTarget_parent
				if newRndTgt then
					dxSetRenderTarget(rndtgt)
					local bgColor = eleData.bgColor
					dxSetBlendMode(rndtgt and "modulate_add" or "blend")
					if eleData.bgImage then
						bgColor = bgColor or 0xFFFFFFFF
						dxDrawImage(x,y,relSizX,relSizY,eleData.bgImage,0,0,0,tocolor(255,255,255,255*galpha),rendSet)
						bgColor = applyColorAlpha(bgColor,galpha)
					elseif eleData.bgColor then
						bgColor = applyColorAlpha(bgColor,galpha)
						dxDrawRectangle(x,y,relSizX,relSizY,bgColor,rendSet)
					end
					dxSetBlendMode("add")
					local filter = eleData.filter
					local drawTarget = newRndTgt
					if filter then
						if isElement(filter[1]) then
							dxSetShaderValue(filter[1],"gTexture",newRndTgt)
							dxSetShaderTransform(filter[1],filter[2],filter[3],filter[4],filter[5],filter[6],filter[7],filter[8],filter[9],filter[10],filter[11])
							drawTarget = filter[1]
						end
					end
					dxDrawImage(x,y,relSizX,relSizY,drawTarget,0,0,0,tocolor(255,255,255,255*galpha),rendSet)
				end
				dxSetBlendMode(rndtgt and "modulate_add" or "blend")
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					local hSideSize = sideSize*0.5
					sideColor = applyColorAlpha(sideColor,galpha)
					local side = outlineData[1]
					if side == "in" then
						dxDrawLine(x,y+hSideSize,x+w,y+hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x+hSideSize,y,x+hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w-hSideSize,y,x+w-hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+h-hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,rendSet)
					elseif side == "center" then
						dxDrawLine(x-hSideSize,y,x+w+hSideSize,y,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+hSideSize,x,y+h-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x+w,y+hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x-hSideSize,y+h,x+w+hSideSize,y+h,sideColor,sideSize,rendSet)
					elseif side == "out" then
						dxDrawLine(x-sideSize,y-hSideSize,x+w+sideSize,y-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x-hSideSize,y,x-hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w+hSideSize,y,x+w+hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize,y+h+hSideSize,x+w+sideSize,y+h+hSideSize,sideColor,sideSize,rendSet)
					end
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				dxSetRenderTarget(newRndTgt,true)
				rndtgt = newRndTgt
				dxSetRenderTarget(rndtgt)
				if enabled[1] and mx then
					if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
						MouseData.scrollPane = v
						MouseData.hit = v
						if mx >= cx+relSizX and my >= cy+relSizY and scbstate[1] and scbstate[2] then
							enabled[1] = false
						end
					else
						enabled[1] = false
					end
				end
			end
		elseif dxType == "dgs-dxscrollbar" then
			if x and y then
				if eleData.PixelInt then
					x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
				end
				local voh = eleData.voh
				local image = eleData.image
				local pos = eleData.position
				local length,lrlt = eleData.length[1],eleData.length[2]
				local cursorColor,arrowColor,troughColor,arrowBgColor = eleData.cursorColor,eleData.arrowColor,eleData.troughColor,eleData.arrowBgColor
				local tempCursorColor = {applyColorAlpha(cursorColor[1],galpha),applyColorAlpha(cursorColor[2],galpha),applyColorAlpha(cursorColor[3],galpha)}
				local tempArrowColor = {applyColorAlpha(arrowColor[1],galpha),applyColorAlpha(arrowColor[2],galpha),applyColorAlpha(arrowColor[3],galpha)}
				local tempArrowBgColor = {applyColorAlpha(arrowBgColor[1],galpha),applyColorAlpha(arrowBgColor[2],galpha),applyColorAlpha(arrowBgColor[3],galpha)}
				local tempTroughColor = applyColorAlpha(troughColor,galpha)
				local colorImageIndex = {1,1,1,1}
				local slotRange
				local scrollArrow =  eleData.scrollArrow
				local cursorWidth = eleData.cursorWidth
				local troughWidth = eleData.troughWidth
				local arrowWidth = eleData.arrowWidth
				local imgRot = eleData.imageRotation
				local troughPadding,cursorPadding,arrowPadding
				if voh then
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
				if MouseData.enter == v then
					if not MouseData.clickData then
						MouseData.enterData = false
						if voh then
							if my >= cy and my <= cy+h then
								if mx >= cx and mx <= cx+arrowWidth then			------left
									if abs(cy+h/2-my) <= arrowWidth then
										MouseData.enterData = 1
									end
								elseif mx >= cx+w-arrowWidth and mx <= cx+w then		------right
									if abs(cy+h/2-my) <= arrowWidth then
										MouseData.enterData = 4
									end
								elseif mx >= cx+arrowWidth+pos*0.01*csRange and mx <= cx+arrowWidth+pos*0.01*csRange+cursorRange then
									if abs(cy+h/2-my) <= cursorWidth then
										MouseData.enterData = 2
									end
								end
							end
						else
							if mx >= cx and mx <= cx+w then
								if my >= cy and my <= cy+arrowWidth then			------up
									if abs(cx+w/2-mx) <= arrowWidth then
										MouseData.enterData = 1
									end
								elseif my >= cy+h-arrowWidth and my <= cy+h then			------down
									if abs(cx+w/2-mx) <= arrowWidth then
										MouseData.enterData = 4
									end
								elseif my >= cy+arrowWidth+pos*0.01*csRange and my <= cy+arrowWidth+pos*0.01*csRange+cursorRange then
									if abs(cx+w/2-mx) <= cursorWidth then
										MouseData.enterData = 2
									end
								end
							end
						end
						if MouseData.enterData then
							colorImageIndex[MouseData.enterData] = 2
						end
					else
						colorImageIndex[MouseData.clickData] = 3
						if MouseData.clickData == 2 then
							local position = 0
							local mvx,mvy = MouseData.MoveScroll[1],MouseData.MoveScroll[2]
							local ax,ay = dgsGetPosition(v,false)
							if csRange ~= 0 then
								if voh then
									local gx = (mx-mvx-ax)/csRange
									position = (gx < 0 and 0) or (gx > 1 and 1) or gx
								else
									local gy = (my-mvy-ay)/csRange
									position = (gy < 0 and 0) or (gy > 1 and 1) or gy
								end
							end
							dgsSetData(v,"position",position*100)
						end
					end
				end
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if voh then
					local imgRotVert = imgRot[2]
					if image[3] then
						dxDrawImage(x+arrowWidth,y+troughPadding,w-2*arrowWidth,troughWidth,image[3],imgRotVert[3],0,0,tempTroughColor,rendSet)
					else
						dxDrawRectangle(x+arrowWidth,y+troughPadding,w-2*arrowWidth,troughWidth,tempTroughColor,rendSet)
					end
					if scrollArrow then
						if tempArrowBgColor then
							dxDrawRectangle(x,y+arrowPadding,arrowWidth,arrowWidth,tempArrowBgColor[colorImageIndex[1]],rendSet)
							dxDrawRectangle(x+w-arrowWidth,y+arrowPadding,arrowWidth,arrowWidth,tempArrowBgColor[colorImageIndex[4]],rendSet)
						end
						dxDrawImage(x,y+arrowPadding,arrowWidth,arrowWidth,image[1],imgRotVert[1],0,0,tempArrowColor[colorImageIndex[1]],rendSet)
						dxDrawImage(x+w-arrowWidth,y+arrowPadding,arrowWidth,arrowWidth,image[1],imgRotVert[1]+180,0,0,tempArrowColor[colorImageIndex[4]],rendSet)
					end
					if image[2] then
						dxDrawImage(x+arrowWidth+pos*0.01*csRange,y+cursorPadding,cursorRange,cursorWidth,image[2],imgRotVert[2],0,0,tempCursorColor[colorImageIndex[2]],rendSet)
					else
						dxDrawRectangle(x+arrowWidth+pos*0.01*csRange,y+cursorPadding,cursorRange,cursorWidth,tempCursorColor[colorImageIndex[2]],rendSet)
					end
				else
					local imgRotHorz = imgRot[1]
					if image[3] then
						dxDrawImage(x+troughPadding,y+arrowWidth,troughWidth,h-2*arrowWidth,image[3],imgRotHorz[3],0,0,tempTroughColor,rendSet)
					else
						dxDrawRectangle(x+troughPadding,y+arrowWidth,troughWidth,h-2*arrowWidth,tempTroughColor,rendSet)
					end
					if scrollArrow then
						if tempArrowBgColor then
							dxDrawRectangle(x+arrowPadding,y,arrowWidth,arrowWidth,tempArrowBgColor[colorImageIndex[1]],rendSet)
							dxDrawRectangle(x+arrowPadding,y+h-arrowWidth,arrowWidth,arrowWidth,tempArrowBgColor[colorImageIndex[4]],rendSet)
						end
						dxDrawImage(x+arrowPadding,y,arrowWidth,arrowWidth,image[1],imgRotHorz[1],0,0,tempArrowColor[colorImageIndex[1]],rendSet)
						dxDrawImage(x+arrowPadding,y+h-arrowWidth,arrowWidth,arrowWidth,image[1],imgRotHorz[1]+180,0,0,tempArrowColor[colorImageIndex[4]],rendSet)
					end
					if image[2] then
						dxDrawImage(x+cursorPadding,y+arrowWidth+pos*0.01*csRange,cursorWidth,cursorRange,image[2],imgRotHorz[2],0,0,tempCursorColor[colorImageIndex[2]],rendSet)
					else
						dxDrawRectangle(x+cursorPadding,y+arrowWidth+pos*0.01*csRange,cursorWidth,cursorRange,tempCursorColor[colorImageIndex[2]],rendSet)
					end
				end
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					local hSideSize = sideSize*0.5
					sideColor = applyColorAlpha(sideColor,galpha)
					local side = outlineData[1]
					if side == "in" then
						dxDrawLine(x,y+hSideSize,x+w,y+hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x+hSideSize,y,x+hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w-hSideSize,y,x+w-hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+h-hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,rendSet)
					elseif side == "center" then
						dxDrawLine(x-hSideSize,y,x+w+hSideSize,y,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+hSideSize,x,y+h-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x+w,y+hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x-hSideSize,y+h,x+w+hSideSize,y+h,sideColor,sideSize,rendSet)
					elseif side == "out" then
						dxDrawLine(x-sideSize,y-hSideSize,x+w+sideSize,y-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x-hSideSize,y,x-hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w+hSideSize,y,x+w+hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize,y+h+hSideSize,x+w+sideSize,y+h+hSideSize,sideColor,sideSize,rendSet)
					end
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if enabled[1] and mx then
					if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
						MouseData.hit = v
					end
				end
			else
				visible = false
			end
		elseif dxType == "dgs-dxlabel" then
			if x and y then
				if eleData.PixelInt then
					x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
				end
				local alignment = eleData.alignment
				local colors,imgs = eleData.textColor,eleData.image
				colors = applyColorAlpha(colors,galpha)
				local colorimgid = 1
				if MouseData.enter == v then
					colorimgid = 2
					if MouseData.clickl == v then
						colorimgid = 3
					end
				end
				local font = eleData.font or systemFont
				local clip = eleData.clip
				local wordbreak = eleData.wordbreak
				local text = eleData.text
				local txtSizX,txtSizY = eleData.textSize[1],eleData.textSize[2]
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						text = fnc[1](unpack(fnc[2])) or text
					end
				end
				------------------------------------
				local colorcoded = eleData.colorcoded
				local shadow = eleData.shadow
				if shadow then
					local shadowoffx,shadowoffy,shadowc,shadowIsOutline = shadow[1],shadow[2],shadow[3],shadow[4]
					local textX,textY = x,y
					if shadowoffx and shadowoffy and shadowc then
						local shadowc = applyColorAlpha(shadowc,galpha)
						local shadowText = colorcoded and text:gsub('#%x%x%x%x%x%x','') or text
						dxDrawText(shadowText,textX+shadowoffx,textY+shadowoffy,textX+w+shadowoffx,textY+h+shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,rendSet)
						if shadowIsOutline then
							dxDrawText(shadowText,textX-shadowoffx,textY+shadowoffy,textX+w-shadowoffx,textY+h+shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,rendSet)
							dxDrawText(shadowText,textX-shadowoffx,textY-shadowoffy,textX+w-shadowoffx,textY+h-shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,rendSet)
							dxDrawText(shadowText,textX+shadowoffx,textY-shadowoffy,textX+w+shadowoffx,textY+h-shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,rendSet)
						end
					end
				end
				dxDrawText(text,x,y,x+w,y+h,colors,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,rendSet,colorcoded,true)
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					local hSideSize = sideSize*0.5
					sideColor = applyColorAlpha(sideColor,galpha)
					local side = outlineData[1]
					if side == "in" then
						dxDrawLine(x,y+hSideSize,x+w,y+hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x+hSideSize,y,x+hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w-hSideSize,y,x+w-hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+h-hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,rendSet)
					elseif side == "center" then
						dxDrawLine(x-hSideSize,y,x+w+hSideSize,y,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+hSideSize,x,y+h-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x+w,y+hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x-hSideSize,y+h,x+w+hSideSize,y+h,sideColor,sideSize,rendSet)
					elseif side == "out" then
						dxDrawLine(x-sideSize,y-hSideSize,x+w+sideSize,y-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x-hSideSize,y,x-hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w+hSideSize,y,x+w+hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize,y+h+hSideSize,x+w+sideSize,y+h+hSideSize,sideColor,sideSize,rendSet)
					end
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if enabled[1] and mx then
					if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
						MouseData.hit = v
					end
				end
			else
				visible = false
			end
		elseif dxType == "dgs-dxgridlist" then
			if eleData.configNextFrame then
				configGridList(v)
			end
			if x and y then
				local nx,ny,nw,nh = x,y,w,h
				if eleData.PixelInt then
					x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
				end
				local DataTab = eleData
				local bgColor,bgImage = applyColorAlpha(DataTab.bgColor,galpha),DataTab.bgImage
				local columnColor,columnImage = applyColorAlpha(DataTab.columnColor,galpha),DataTab.columnImage
				local font = DataTab.font or systemFont
				local columnHeight = DataTab.columnHeight
				if MouseData.enter == v then
					colorimgid = 2
					if MouseData.clickl == v then
						colorimgid = 3
					end
					MouseData.enterData = false
				end
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				dxSetBlendMode(rndtgt and "modulate_add" or "blend")
				if bgImage then
					dxDrawImage(x,y+columnHeight,w,h-columnHeight,bgImage,0,0,0,bgColor,rendSet)
				else
					dxDrawRectangle(x,y+columnHeight,w,h-columnHeight,bgColor,rendSet)
				end
				if columnImage then
					dxDrawImage(x,y,w,columnHeight,columnImage,0,0,0,columnColor,rendSet)
				else
					dxDrawRectangle(x,y,w,columnHeight,columnColor,rendSet)
				end
				local columnData = DataTab.columnData
				local sortColumn = DataTab.sortColumn
				if sortColumn and columnData[sortColumn] then
					if DataTab.nextRenderSort then
						dgsGridListSort(v)
						dgsElementData[v].nextRenderSort = false
					end
				end
				local columnTextColor = DataTab.columnTextColor
				local columnRelt = DataTab.columnRelative
				local rowData = DataTab.rowData
				local rowHeight = DataTab.rowHeight
				local rowTextPosOffset = DataTab.rowTextPosOffset
				local columnTextPosOffset = DataTab.columnTextPosOffset
				local leading = DataTab.leading
				local scbThick = DataTab.scrollBarThick
				local scrollbars = DataTab.scrollbars
				local scbThickV,scbThickH = dgsElementData[ scrollbars[1] ].visible and scbThick or 0,dgsElementData[ scrollbars[2] ].visible and scbThick or 0
				local colorcoded = DataTab.colorcoded
				local shadow = DataTab.rowShadow
				local columnCount = #columnData
				local rowCount = #rowData
				local rowHeightLeadingTemp = rowHeight+leading
				local rowMoveOffset = DataTab.rowMoveOffset
				local columnOffset = DataTab.columnOffset
				local columnMoveOffset = eleData.PixelInt and DataTab.columnMoveOffset-DataTab.columnMoveOffset%1
				local fnc = eleData.functions
				local rowTextSx,rowTextSy = DataTab.rowTextSize[1],DataTab.rowTextSize[2] or DataTab.rowTextSize[1]
				local columnTextSx,columnTextSy = DataTab.columnTextSize[1],DataTab.columnTextSize[2] or DataTab.columnTextSize[1]
				local selectionMode = DataTab.selectionMode
				local clip = eleData.clip
				local mouseInsideGridList = mx >= cx and mx <= cx+w and my >= cy and my <= cy+h-scbThickH
				local mouseInsideColumn = mouseInsideGridList and my <= cy+columnHeight
				local mouseInsideRow = mouseInsideGridList and my > cy+columnHeight
				DataTab.selectedColumn = -1
				local sortIcon = DataTab.sortFunction == sortFunctions_lower and "▼" or (DataTab.sortFunction == sortFunctions_upper and "▲") or nil
				local sortColumn = DataTab.sortColumn
				local backgroundOffset = DataTab.backgroundOffset
				if not DataTab.mode then
					local renderTarget = DataTab.renderTarget
					local isDraw1,isDraw2 = isElement(renderTarget[1]),isElement(renderTarget[2])
					dxSetRenderTarget(renderTarget[1],true)
					dxSetBlendMode("modulate_add")
						local cpos = {}
						local cend = {}
						local multiplier = columnRelt and (w-scbThickV) or 1
						local tempColumnOffset = columnMoveOffset+columnOffset
						local mouseColumnPos = mx-cx
						local mouseSelectColumn = -1
						local cPosStart,cPosEnd
						for id = 1,#columnData do
							local data = columnData[id]
							local _columnTextColor = data[5] or columnTextColor
							local _columnTextColorCoded = data[6] or colorcoded
							local _columnTextSx,_columnTextSy = data[7] or columnTextSx,data[8] or columnTextSy
							local _columnFont = data[9] or font
							local tempCpos = data[3]*multiplier
							local _tempStartx = tempCpos+tempColumnOffset
							local _tempEndx = _tempStartx+data[2]*multiplier
							if _tempStartx <= w and _tempEndx >= 0 then
								cpos[id] = tempCpos
								cend[id] = _tempEndx
								cPosStart = cPosStart or id
								cPosEnd = id
								if isDraw1 then
									local _tempStartx = eleData.PixelInt and _tempStartx-_tempStartx%1 or _tempStartx
									local textPosL = _tempStartx+columnTextPosOffset[1]
									local textPosT = columnTextPosOffset[2]
									local textPosR = _tempEndx+columnTextPosOffset[1]
									local textPosB = columnHeight+columnTextPosOffset[2]
									if sortColumn == id and sortIcon then
										local iconWidth = dxGetTextWidth(sortIcon,_columnTextSx*0.8,_columnFont)
										local iconTextPosL = textPosL-iconWidth
										local iconTextPosR = textPosR-iconWidth
										if DataTab.columnShadow then
											dxDrawText(sortIcon,iconTextPosL,textPosT,iconTextPosR,textPosB,black,_columnTextSx*0.8,_columnTextSy*0.8,_columnFont,"left","center",clip,false,false,false,true)
										end
										dxDrawText(sortIcon,iconTextPosL-1,textPosT,iconTextPosR-1,textPosB,_columnTextColor,_columnTextSx*0.8,_columnTextSy*0.8,_columnFont,"left","center",clip,false,false,false,true)
									end
									if DataTab.columnShadow then
										dxDrawText(data[1],textPosL+1,textPosT+1,textPosR+1,textPosB+1,black,_columnTextSx,_columnTextSy,_columnFont,data[4],"center",clip,false,false,false,true)
									end
									dxDrawText(data[1],textPosL,textPosT,textPosR,textPosB,_columnTextColor,_columnTextSx,_columnTextSy,_columnFont,data[4],"center",clip,false,false,_columnTextColorCoded,true)
								end
								if mouseInsideGridList and mouseSelectColumn == -1 then
									if mouseColumnPos >= _tempStartx and mouseColumnPos <= _tempEndx then
										mouseSelectColumn = id
									end
								end
							end
						end
					dxSetRenderTarget(renderTarget[2],true)
						local preSelectLastFrame = DataTab.preSelect
						if MouseData.enter == v then		-------PreSelect
							if mouseInsideRow then
								local toffset = (DataTab.FromTo[1]*rowHeightLeadingTemp)+rowMoveOffset
								local tempID = (my-cy-columnHeight-toffset)/rowHeightLeadingTemp
								sid = (tempID-tempID%1)+DataTab.FromTo[1]+1
								if sid >= 1 and sid <= rowCount and my-cy-columnHeight < sid*rowHeight+(sid-1)*leading+rowMoveOffset then
									DataTab.oPreSelect = sid
									if rowData[sid][-2] ~= false then
										DataTab.preSelect = {sid,mouseSelectColumn}
									else
										DataTab.preSelect = {-1,mouseSelectColumn}
									end
									MouseData.enterData = true
								else
									DataTab.preSelect = {-1,mouseSelectColumn}
								end
							elseif mouseInsideColumn then
								DataTab.selectedColumn = mouseSelectColumn
								DataTab.preSelect = {}
							else
								DataTab.preSelect = {-1,-1}
							end
						end
						local preSelect = DataTab.preSelect
						if preSelectLastFrame[1] ~= preSelect[1] or preSelectLastFrame[2] ~= preSelect[2] then
							triggerEvent("onDgsGridListHover",v,preSelect[1],preSelect[2],preSelectLastFrame[1],preSelectLastFrame[2])
						end
						local Select = DataTab.rowSelect
						local sectionFont = eleData.sectionFont or font
						for i=DataTab.FromTo[1],DataTab.FromTo[2] do
							local lc_rowData = rowData[i]
							local image,columnOffset,isSection,color = lc_rowData[-3] or eleData.rowImage,lc_rowData[-4] or eleData.columnOffset,lc_rowData[-5],lc_rowData[0] or eleData.rowColor
							if isDraw2 then
								local rowpos = i*rowHeight+rowMoveOffset+(i-1)*leading
								local rowpos_1 = rowpos-rowHeight
								local _x,_y,_sx,_sy = tempColumnOffset+columnOffset,rowpos_1,sW,rowpos
								if eleData.PixelInt then
									_x,_y,_sx,_sy = _x-_x%1,_y-_y%1,_sx-_sx%1,_sy-_sy%1
								end
								local textBuffer = {}
								local textBufferCnt = 1
								
								if not cPosStart or not cPosEnd then break end
								dxSetBlendMode("modulate_add")
								for id = cPosStart,cPosEnd do
									local currentRowData = lc_rowData[id]
									local text = currentRowData[1]
									local _txtFont = isSection and sectionFont or (currentRowData[6] or font)
									local _txtScalex = currentRowData[4] or rowTextSx
									local _txtScaley = currentRowData[5] or rowTextSy
									local rowState = 1
									if selectionMode == 1 then
										if i == preSelect[1] then
											rowState = 2
										end
										if Select[i] and Select[i][1] then
											rowState = 3
										end
									elseif selectionMode == 2 then
										if id == preSelect[2] then
											rowState = 2
										end
										if Select[1] and Select[1][id] then
											rowState = 3
										end
									elseif selectionMode == 3 then
										if i == preSelect[1] and id == preSelect[2] then
											rowState = 2
										end
										if Select[i] and Select[i][id] then
											rowState = 3
										end
									end
									local offset = cpos[id]
									local _x = _x+offset
									local _sx = cend[id]
									local _backgroundWidth = columnData[id][2]*multiplier
									local _bgX = _x
									local backgroundWidth = _backgroundWidth
									if id == 1 then
										_bgX = _x+backgroundOffset
										backgroundWidth = _backgroundWidth-backgroundOffset
									elseif backgroundWidth+_x-x >= w or columnCount == id then
										backgroundWidth = w-_x+x
									end
									if #image > 0 then
										dxDrawImage(_bgX,_y,backgroundWidth,rowHeight,image[rowState],0,0,0,color[rowState])
									else
										dxDrawRectangle(_bgX,_y,backgroundWidth,rowHeight,color[rowState])
									end
									if text then
										local colorcoded = currentRowData[3] == nil and colorcoded or currentRowData[3]
										if currentRowData[7] then
											local imageData = currentRowData[7]
											if isElement(imageData[1]) then
												dxDrawImage(_x+imageData[3],_y+imageData[4],imageData[5],imageData[6],imageData[1],0,0,0,imageData[2])
											else
												dxDrawRectangle(_x+imageData[3],_y+imageData[4],imageData[5],imageData[6],imageData[2])
											end
										end
										textBuffer[textBufferCnt] = {currentRowData[1],_x-_x%1,_sx-_sx%1,currentRowData[2],_txtScalex,_txtScaley,_txtFont,clip,colorcoded,columnData[id][4]}
										textBufferCnt = textBufferCnt + 1
									end
								end
								for i=1,#textBuffer do
									local v = textBuffer[i]
									local colorcoded = v[9]
									local text = v[1]
									if shadow then
										if colorcoded then
											text = text:gsub("#%x%x%x%x%x%x","") or text
										end
										dxDrawText(text,v[2]+shadow[1]+rowTextPosOffset[1],_y+shadow[2]+rowTextPosOffset[2],v[3]+shadow[1]+rowTextPosOffset[1],_sy+shadow[2]+rowTextPosOffset[2],shadow[3],v[5],v[6],v[7],v[10],"center",v[8],false,false,false,true)
									end
									dxDrawText(v[1],v[2]+rowTextPosOffset[1],_y+rowTextPosOffset[2],v[3]+rowTextPosOffset[1],_sy+rowTextPosOffset[2],v[4],v[5],v[6],v[7],v[10],"center",v[8],false,false,colorcoded,true)
								end
							end
						end
					dxSetRenderTarget(rndtgt)
					dxSetBlendMode("add")
					if isDraw2 then
						dxDrawImage(x,y+columnHeight,w-scbThickV,h-columnHeight-scbThickH,renderTarget[2],0,0,0,tocolor(255,255,255,255*galpha),rendSet)
					end
					if isDraw1 then
						dxDrawImage(x,y,w-scbThickV,columnHeight,renderTarget[1],0,0,0,tocolor(255,255,255,255*galpha),rendSet)
					end
				elseif columnCount >= 1 then
					local whichColumnToStart,whichColumnToEnd = -1,-1
					local _rowMoveOffset = (1-DataTab.FromTo[1])*rowHeightLeadingTemp
					local cpos = {}
					local multiplier = columnRelt and (w-scbThickV) or 1
					local ypcolumn = cy+columnHeight
					local _y,_sx = ypcolumn+_rowMoveOffset,cx+w-scbThickV
					local column_x = columnOffset
					local allColumnWidth = columnData[columnCount][2]+columnData[columnCount][3]
					local scrollbar = eleData.scrollbars[2]
					local scrollPos = dgsElementData[scrollbar].position*0.01
					local mouseSelectColumn = -1
					local does = false
					for id = 1,#columnData do
						local data = columnData[id]
						cpos[id] = data[3]*multiplier
						if (data[3]+data[2])*multiplier-columnOffset >= scrollPos*allColumnWidth*multiplier then
							if (data[3]+data[2])*multiplier-scrollPos*allColumnWidth*multiplier <= w-scbThickV then
								whichColumnToStart = whichColumnToStart ~= -1 and whichColumnToStart or id
								whichColumnToEnd = whichColumnToEnd <= whichColumnToStart and whichColumnToStart or id
								whichColumnToEnd = id
								does = true
							end
						end
					end
					if not does then
						whichColumnToStart,whichColumnToEnd = columnCount,columnCount
					end
					column_x = cx-cpos[whichColumnToStart]+columnOffset
					dxSetBlendMode(rndtgt and "modulate_add" or "blend")
					for i=whichColumnToStart,whichColumnToEnd or columnCount do
						local data = columnData[i]
						local _columnTextColor = data[5] or columnTextColor
						local _columnTextColorCoded = data[6] or colorcoded
						local _columnTextSx,_columnTextSy = data[7] or columnTextSx,data[8] or columnTextSy
						local _columnFont = data[9] or font
						local column_sx = column_x+cpos[i]+data[2]*multiplier-scbThickV
						local posx = column_x+cpos[i]
						local tPosX = posx-posx%1
						local textPosL = tPosX+columnTextPosOffset[1]
						local textPosT = cy+columnTextPosOffset[2]
						local textPosR = column_sx+columnTextPosOffset[1]
						local textPosB = ypcolumn+columnTextPosOffset[2]
						if sortColumn == i and sortIcon then
							local iconWidth = dxGetTextWidth(sortIcon,_columnTextSx*0.8,_columnFont)
							local iconTextPosL = textPosL-iconWidth
							local iconTextPosR = textPosR-iconWidth
							if DataTab.columnShadow then
								dxDrawText(sortIcon,iconTextPosL,textPosT,iconTextPosR,textPosB,black,_columnTextSx*0.8,_columnTextSy*0.8,_columnFont,"left","center",clip,false,rendSet,false,true)
							end
							dxDrawText(sortIcon,iconTextPosL-1,textPosT,iconTextPosR-1,textPosB,_columnTextColor,_columnTextSx*0.8,_columnTextSy*0.8,_columnFont,"left","center",clip,false,rendSet,false,true)
						end
						if DataTab.columnShadow then
							dxDrawText(data[1],textPosL+1,textPos+1,textPosR+1,textPosB+1,black,_columnTextSx,_columnTextSy,_columnFont,data[4],"center",clip,false,rendSet,false,true)
						end
						dxDrawText(data[1],textPosL,textPosT,textPosR,textPosB,_columnTextColor,_columnTextSx,_columnTextSy,_columnFont,data[4],"center",clip,false,rendSet,false,true)
						if mouseInsideGridList and mouseSelectColumn == -1 then
							backgroundWidth = data[2]*multiplier
							if backgroundWidth+posx-x >= w or whichColumnToEnd == i then
								backgroundWidth = w-posx+x
							end
							local _tempStartx = posx
							local _tempEndx = _tempStartx+backgroundWidth
							if mx >= _tempStartx and mx <= _tempEndx then
								mouseSelectColumn = i
							end
						end
					end
					if MouseData.enter == v then		-------PreSelect
						if mouseInsideRow then
							local tempID = (my-cy-columnHeight)/rowHeightLeadingTemp-1
							sid = (tempID-tempID%1)+DataTab.FromTo[1]+1
							if sid >= 1 and sid <= rowCount and my-cy-columnHeight < sid*rowHeight+(sid-1)*leading+_rowMoveOffset then
								DataTab.oPreSelect = sid
								if rowData[sid][-2] ~= false then
									DataTab.preSelect = {sid,mouseSelectColumn}
								else
									DataTab.preSelect = {-1,mouseSelectColumn}
								end
								MouseData.enterData = true
							else
								DataTab.preSelect = {-1,mouseSelectColumn}
							end
						elseif mouseInsideColumn then
							DataTab.selectedColumn = mouseSelectColumn
							DataTab.preSelect = {}
						else
							DataTab.preSelect = {-1,-1}
						end
					end
					local preSelect = DataTab.preSelect
					local Select = DataTab.rowSelect
					local sectionFont = eleData.sectionFont or font
					for i=DataTab.FromTo[1],DataTab.FromTo[2] do
						local lc_rowData = rowData[i]
						local image = lc_rowData[-3]
						local color = lc_rowData[0]
						local columnOffset = lc_rowData[-4]
						local isSection = lc_rowData[-5]
						local rowpos = i*rowHeight+(i-1)*leading
						local _x,_y,_sx,_sy = column_x+columnOffset,_y+rowpos-rowHeight,_sx,_y+rowpos
						if eleData.PixelInt then
							_x,_y,_sx,_sy = _x-_x%1,_y-_y%1,_sx-_sx%1,_sy-_sy%1
						end
						local textBuffer = {}
						local textBufferCnt = 1
						for id=whichColumnToStart,whichColumnToEnd do
							local currentRowData = lc_rowData[id]
							local text = currentRowData[1]
							local _txtFont = isSection and sectionFont or (currentRowData[6] or font)
							local _txtScalex = currentRowData[4] or rowTextSx
							local _txtScaley = currentRowData[5] or rowTextSy
							local rowState = 1
							if selectionMode == 1 then
								if i == preSelect[1] then
									rowState = 2
								end
								if Select[i] and Select[i][1] then
									rowState = 3
								end
							elseif selectionMode == 2 then
								if id == preSelect[2] then
									rowState = 2
								end
								if Select[1] and Select[1][id] then
									rowState = 3
								end
							elseif selectionMode == 3 then
								if i == preSelect[1] and id == preSelect[2] then
									rowState = 2
								end
								if Select[i] and Select[i][id] then
									rowState = 3
								end
							end
							local offset = cpos[id]
							local _x = _x+offset
							local _sx = cpos[id+1] or (columnData[id][2])*multiplier
							local backgroundWidth = columnData[id][2]*multiplier
							local _bgX = _x
							if id == 1 then
								_bgX = _x+backgroundOffset
								backgroundWidth = backgroundWidth-backgroundOffset
							elseif backgroundWidth+_x-x >= w or whichColumnToEnd == id then
								backgroundWidth = w-_x+x-scbThickV
							end
							if #image > 0 then
								dxDrawImage(_bgX,_y,backgroundWidth,rowHeight,image[rowState],0,0,0,color[rowState],rendSet)
							else
								dxDrawRectangle(_bgX,_y,backgroundWidth,rowHeight,color[rowState],rendSet)
							end
							if text ~= "" then
								local colorcoded = currentRowData[3] == nil and colorcoded or currentRowData[3]
								if currentRowData[7] then
									local imageData = currentRowData[7]
									if isElement(imageData[1]) then
										dxDrawImage(_x+imageData[3],_y+imageData[4],imageData[5],imageData[6],imageData[1],0,0,0,imageData[2])
									else
										dxDrawRectangle(_x+imageData[3],_y+imageData[4],imageData[5],imageData[6],imageData[2])
									end
								end
								textBuffer[textBufferCnt] = {currentRowData[1],_x,_sx+_x,currentRowData[2],_txtScalex,_txtScaley,_txtFont,clip,colorcoded,columnData[id][4]}
								textBufferCnt = textBufferCnt+1
							end
						end
						for i=1,#textBuffer do
							local v = textBuffer[i]
							local colorcoded = v[9]
							local text = v[1]
							if shadow then
								if colorcoded then
									text = text:gsub("#%x%x%x%x%x%x","") or text
								end
								dxDrawText(text,v[2]+shadow[1]+rowTextPosOffset[1],_y+shadow[2]+rowTextPosOffset[2],v[3]+shadow[1]+rowTextPosOffset[1],_sy+shadow[2]+rowTextPosOffset[2],shadow[3],v[5],v[6],v[7],v[10],"center",v[8],false,rendSet,false,true)
							end
							dxDrawText(v[1],v[2]+rowTextPosOffset[1],_y+rowTextPosOffset[2],v[3]+rowTextPosOffset[1],_sy+rowTextPosOffset[2],v[4],v[5],v[6],v[7],v[10],"center",v[8],false,rendSet,colorcoded,true)
						end
					end
				end
				dxSetBlendMode(rndtgt and "modulate_add" or "blend")
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					local hSideSize = sideSize*0.5
					sideColor = applyColorAlpha(sideColor,galpha)
					local side = outlineData[1]
					if side == "in" then
						dxDrawLine(x,y+hSideSize,x+w,y+hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x+hSideSize,y,x+hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w-hSideSize,y,x+w-hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+h-hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,rendSet)
					elseif side == "center" then
						dxDrawLine(x-hSideSize,y,x+w+hSideSize,y,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+hSideSize,x,y+h-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x+w,y+hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x-hSideSize,y+h,x+w+hSideSize,y+h,sideColor,sideSize,rendSet)
					elseif side == "out" then
						dxDrawLine(x-sideSize,y-hSideSize,x+w+sideSize,y-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x-hSideSize,y,x-hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w+hSideSize,y,x+w+hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize,y+h+hSideSize,x+w+sideSize,y+h+hSideSize,sideColor,sideSize,rendSet)
					end
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if enabled then
					if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
						MouseData.hit = v
					end
				end
			else
				visible = false
			end
		elseif dxType == "dgs-dxprogressbar" then
			if x and y then
				if eleData.PixelInt then
					x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
				end
				local bgImage = eleData.bgImage
				local bgColor = applyColorAlpha(eleData.bgColor,galpha)
				local indicatorImage = eleData.indicatorImage
				local indicatorColor = applyColorAlpha(eleData.indicatorColor,galpha)
				local indicatorMode = eleData.indicatorMode
				local padding = eleData.padding
				local percent = eleData.progress*0.01
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				ProgressBarStyle[eleData.style](v,x,y,w,h,bgImage,bgColor,indicatorImage,indicatorColor,indicatorMode,padding,percent,rendSet)
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					local hSideSize = sideSize*0.5
					sideColor = applyColorAlpha(sideColor,galpha)
					local side = outlineData[1]
					if side == "in" then
						dxDrawLine(x,y+hSideSize,x+w,y+hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x+hSideSize,y,x+hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w-hSideSize,y,x+w-hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+h-hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,rendSet)
					elseif side == "center" then
						dxDrawLine(x-hSideSize,y,x+w+hSideSize,y,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+hSideSize,x,y+h-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x+w,y+hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x-hSideSize,y+h,x+w+hSideSize,y+h,sideColor,sideSize,rendSet)
					elseif side == "out" then
						dxDrawLine(x-sideSize,y-hSideSize,x+w+sideSize,y-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x-hSideSize,y,x-hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w+hSideSize,y,x+w+hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize,y+h+hSideSize,x+w+sideSize,y+h+hSideSize,sideColor,sideSize,rendSet)
					end
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if enabled[1] and mx then
					if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
						MouseData.hit = v
					end
				end
			else
				visible = false
			end
		elseif dxType =="dgs-dxcombobox" then
			if x and y then
				if eleData.configNextFrame then
					configComboBox(v)
				end
				if eleData.PixelInt then
					x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
				end
				local captionEdit = eleData.captionEdit
				local colors,imgs = eleData.color,eleData.image
				local colorimgid = 1
				local textBox = eleData.textBox
				local buttonLen_t = eleData.buttonLen
				local buttonLen
				if textBox then
					buttonLen = buttonLen_t[2] and buttonLen_t[1]*h or buttonLen_t[1]
				else
					buttonLen = w
				end
				if MouseData.enter == v then
					colorimgid = 2
					if eleData.clickType == 1 then
						if MouseData.clickl == v then
							colorimgid = 3
						end
					elseif eleData.clickType == 2 then
						if MouseData.clickr == v then
							colorimgid = 3
						end
					else
						if MouseData.clickl == v or MouseData.clickr == v then
							colorimgid = 3
						end
					end
				end
				local finalcolor
				if not enabled[1] and not enabled[2] then
					if type(eleData.disabledColor) == "number" then
						finalcolor = applyColorAlpha(eleData.disabledColor,galpha)
					elseif eleData.disabledColor == true then
						local r,g,b,a = fromcolor(colors[1],true)
						local average = (r+g+b)/3*eleData.disabledColorPercent
						finalcolor = tocolor(average,average,average,a*galpha)
					else
						finalcolor = colors[colorimgid]
					end
				else
					finalcolor = applyColorAlpha(colors[colorimgid],galpha)
				end
				local bgColor = eleData.bgColor or finalcolor
				local bgImage = eleData.bgImage
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if imgs[colorimgid] then
					dxDrawImage(x+w-buttonLen,y,buttonLen,h,imgs[colorimgid],0,0,0,finalcolor,rendSet)
				else
					dxDrawRectangle(x+w-buttonLen,y,buttonLen,h,finalcolor,rendSet)
				end
				local arrowColor = eleData.arrowColor
				local arrowOutSideColor = eleData.arrowOutSideColor
				local textBoxLen = w-buttonLen
				if bgImage then
					dxDrawImage(x,y,textBoxLen,h,bgImage,0,0,0,applyColorAlpha(bgColor,galpha),rendSet)
				else
					dxDrawRectangle(x,y,textBoxLen,h,applyColorAlpha(bgColor,galpha),rendSet)
				end
				local shader = eleData.arrow
				local listState = eleData.listState
				if eleData.listStateAnim ~= listState then
					local stat = eleData.listStateAnim+eleData.listState*0.08
					eleData.listStateAnim = listState == -1 and max(stat,listState) or min(stat,listState)
				end
				if eleData.arrowSettings then
					dxSetShaderValue(shader,"width",eleData.arrowSettings[1])
					dxSetShaderValue(shader,"height",eleData.arrowSettings[2]*eleData.listStateAnim)
					dxSetShaderValue(shader,"linewidth",eleData.arrowSettings[3])
				end
				local r,g,b,a = fromcolor(arrowColor,true)
				dxSetShaderValue(shader,"_color",{r/255,g/255,b/255,a/255*galpha})
				local r,g,b,a = fromcolor(arrowOutSideColor,true)
				dxSetShaderValue(shader,"ocolor",{r/255,g/255,b/255,a/255*galpha})
				dxDrawImage(x+textBoxLen,y,buttonLen,h,shader,0,0,0,white,rendSet)
				if textBox and not captionEdit then
					local textSide = eleData.comboTextSide
					local font = eleData.font or systemFont
					local textColor = eleData.textColor
					local rb = eleData.alignment
					local txtSizX,txtSizY = eleData.textSize[1],eleData.textSize[2] or eleData.textSize[1]
					local colorcoded = eleData.colorcoded
					local shadow = eleData.shadow
					local wordbreak = eleData.wordbreak
					local selection = eleData.select
					local itemData = eleData.itemData
					local sele = itemData[selection]
					local text = sele and sele[1] or eleData.caption
					local nx,ny,nw,nh = x+textSide[1],y,x+textBoxLen-textSide[2],y+h
					if shadow then
						dxDrawText(text:gsub("#%x%x%x%x%x%x",""),nx-shadow[1],ny-shadow[2],nw-shadow[1],nh-shadow[2],applyColorAlpha(shadow[3],galpha),txtSizX,txtSizY,font,rb[1],rb[2],clip,wordbreak,rendSet)
					end
					dxDrawText(text,nx,ny,nw,nh,applyColorAlpha(textColor,galpha),txtSizX,txtSizY,font,rb[1],rb[2],clip,wordbreak,rendSet,colorcoded)
				end
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					local hSideSize = sideSize*0.5
					sideColor = applyColorAlpha(sideColor,galpha)
					local side = outlineData[1]
					if side == "in" then
						dxDrawLine(x,y+hSideSize,x+w,y+hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x+hSideSize,y,x+hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w-hSideSize,y,x+w-hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+h-hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,rendSet)
					elseif side == "center" then
						dxDrawLine(x-hSideSize,y,x+w+hSideSize,y,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+hSideSize,x,y+h-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x+w,y+hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x-hSideSize,y+h,x+w+hSideSize,y+h,sideColor,sideSize,rendSet)
					elseif side == "out" then
						dxDrawLine(x-sideSize,y-hSideSize,x+w+sideSize,y-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x-hSideSize,y,x-hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w+hSideSize,y,x+w+hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize,y+h+hSideSize,x+w+sideSize,y+h+hSideSize,sideColor,sideSize,rendSet)
					end
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if enabled[1] and mx then
					if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
						MouseData.hit = v
					end
				end
			else
				visible = false
			end
		elseif dxType == "dgs-dxcombobox-Box" then
			local combo = eleData.myCombo
			if x and y then
				if eleData.PixelInt then
					x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
				end
				local DataTab = dgsElementData[combo]
				local itemData = DataTab.itemData
				local itemDataCount = #itemData
				local scbThick = dgsElementData[combo].scrollBarThick
				local itemHeight = DataTab.itemHeight
				local itemMoveOffset = DataTab.itemMoveOffset
				local whichRowToStart = -floor((itemMoveOffset+itemHeight)/itemHeight)+1
				local whichRowToEnd = whichRowToStart+floor(h/itemHeight)+1
				DataTab.FromTo = {whichRowToStart > 0 and whichRowToStart or 1,whichRowToEnd <= itemDataCount and whichRowToEnd or itemDataCount}
				local renderTarget = dgsElementData[combo].renderTarget
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if isElement(renderTarget) then
					dxSetRenderTarget(renderTarget,true)
					dxSetBlendMode("modulate_add")
					local rb_l = dgsElementData[combo].alignmentList
					local scrollbar = dgsElementData[combo].scrollbar
					local scbcheck = dgsElementData[scrollbar].visible and scbThick or 0
					if mx >= cx and mx <= cx+w-scbcheck and my >= cy and my <= cy+h and MouseData.enter == v then
						local toffset = (whichRowToStart*itemHeight)+itemMoveOffset
						sid = floor((my+2-cy-toffset)/itemHeight)+whichRowToStart+1
						if sid <= itemDataCount then
							DataTab.preSelect = sid
							MouseData.enterData = true
						else
							DataTab.preSelect = -1
						end
					else
						DataTab.preSelect = -1
					end
					local preSelect = DataTab.preSelect
					local Select = DataTab.select
					local font = DataTab.font
					local shadow = dgsElementData[combo].shadow
					local colorcoded = eleData.colorcoded
					local wordbreak = eleData.wordbreak
					local clip = eleData.clip
					local textSide = dgsElementData[combo].itemTextSide
					for i=DataTab.FromTo[1],DataTab.FromTo[2] do
						local lc_rowData = itemData[i]
						local textSize = lc_rowData[-3]
						local textColor = lc_rowData[-2]
						local image = lc_rowData[-1]
						local color = lc_rowData[0]
						local itemState = 1
						if i == preSelect then
							itemState = 2
						end
						if i == Select then
							itemState = 3
						end
						local rowpos = i*itemHeight
						local rowpos_1 = (i-1)*itemHeight
						if image[itemState] then
							dxDrawImage(0,rowpos_1+itemMoveOffset,w,itemHeight,image[itemState],0,0,0,color[itemState])
						else
							dxDrawRectangle(0,rowpos_1+itemMoveOffset,w,itemHeight,color[itemState])
						end
						local _y,_sx,_sy = rowpos_1+itemMoveOffset,sW-textSide[2],rowpos+itemMoveOffset
						local text = itemData[i][1]
						if shadow then
							dxDrawText(text:gsub("#%x%x%x%x%x%x",""),textSide[1]-shadow[1],_y-shadow[2],_sx-shadow[1],_sy-shadow[2],shadow[3],textSize[1],textSize[2],font,rb_l[1],rb_l[2],clip,wordbreak)
						end
						dxDrawText(text,textSide[1],_y,_sx,_sy,textColor,textSize[1],textSize[2],font,rb_l[1],rb_l[2],clip,wordbreak,false,colorcoded)
					end
					dxSetRenderTarget(rndtgt)
					dxSetBlendMode("add")
					dxDrawImage(x,y,w,h,renderTarget,0,0,0,tocolor(255,255,255,255*galpha),rendSet)
					dxSetBlendMode(rndtgt and "modulate_add" or "blend")
				end
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					local hSideSize = sideSize*0.5
					sideColor = applyColorAlpha(sideColor,galpha)
					local side = outlineData[1]
					if side == "in" then
						dxDrawLine(x,y+hSideSize,x+w,y+hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x+hSideSize,y,x+hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w-hSideSize,y,x+w-hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+h-hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,rendSet)
					elseif side == "center" then
						dxDrawLine(x-hSideSize,y,x+w+hSideSize,y,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+hSideSize,x,y+h-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x+w,y+hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x-hSideSize,y+h,x+w+hSideSize,y+h,sideColor,sideSize,rendSet)
					elseif side == "out" then
						dxDrawLine(x-sideSize,y-hSideSize,x+w+sideSize,y-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x-hSideSize,y,x-hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w+hSideSize,y,x+w+hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize,y+h+hSideSize,x+w+sideSize,y+h+hSideSize,sideColor,sideSize,rendSet)
					end
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if enabled[1] and mx then
					local height = itemDataCount*itemHeight
					if height > h then
						height = h
					end
					if mx >= cx and mx<= cx+w and my >= cy and my <= cy+height then
						MouseData.hit = v
					end
				end
			else
				visible = false
			end
		elseif dxType == "dgs-dxtabpanel" then
			if x and y then
				if eleData.PixelInt then
					x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
				end
				local tabHeight,relat = eleData["tabHeight"][1],eleData["tabHeight"][2]
				local tabHeight = relat and tabHeight*y or tabHeight
				eleData.rndPreSelect = -1
				local selected = eleData["selected"]
				local tabs = eleData["tabs"]
				local height = eleData["tabHeight"][2] and eleData["tabHeight"][1]*h or eleData["tabHeight"][1]
				local bgColor = eleData.bgColor
				local font = eleData.font or systemFont
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if enabled[1] and mx then
					if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
						MouseData.hit = v
					end
				end
				if selected == -1 then
					dxDrawRectangle(x,y+height,w,h-height,eleData.bgColor,rendSet)
				else
					local rendt = eleData.renderTarget
					if isElement(rendt) then
						dxSetRenderTarget(rendt,true)
						dxSetBlendMode("modulate_add")
						local tabPadding = eleData.tabPadding[2] and eleData.tabPadding[1]*w or eleData.tabPadding[1]
						local tabsize = -eleData.showPos*(dgsTabPanelGetWidth(v)-w)
						local gap = eleData.tabGapSize[2] and eleData.tabGapSize[1]*w or eleData.tabGapSize[1]
						if eleData.PixelInt then
							x,y,w,height = x-x%1,y-y%1,w-w%1,height-height%1
						end
						for d=1,#tabs do
							local t = tabs[d]
							if dgsElementData[t].visible then
								local width = dgsElementData[t].width+tabPadding*2
								local _width = 0
								if tabs[d+1] then
									_width = dgsElementData[tabs[d+1]].width+tabPadding*2
								end
								if tabsize+width >= 0 and tabsize <= w then
									local tabImage = dgsElementData[t].tabImage
									local tabColor = dgsElementData[t].tabColor
									local selectstate = 1
									if selected == d then
										selectstate = 3
									elseif eleData.preSelect == d then
										selectstate = 2
									end
									local finalcolor
									if not enabled[2] then
										if type(eleData.disabledColor) == "number" then
											finalcolor = applyColorAlpha(eleData.disabledColor,galpha)
										elseif eleData.disabledColor == true then
											local r,g,b,a = fromcolor(tabColor[1],true)
											local average = (r+g+b)/3*eleData.disabledColorPercent
											finalcolor = tocolor(average,average,average,a*galpha)
										else
											finalcolor = tabColor[selectstate]
										end
									else
										finalcolor = applyColorAlpha(tabColor[selectstate],galpha)
									end
									if tabImage[selectstate] then
										dxDrawImage(tabsize,0,width,height,tabImage[selectstate],0,0,0,finalcolor)
									else
										dxDrawRectangle(tabsize,0,width,height,finalcolor)
									end
									local textSize = dgsElementData[t].textSize
									if eleData.PixelInt then
										_tabsize,_width = tabsize-tabsize%1,floor(width+tabsize)
									end
									dxDrawText(dgsElementData[t].text,_tabsize,0,_width,height,dgsElementData[t].textColor,textSize[1],textSize[2],dgsElementData[t].font or font,"center","center",false,false,false,colorcoded,true)
									if mx >= tabsize+x and mx <= tabsize+x+width and my > y and my < y+height and dgsElementData[t].enabled and enabled[2] then
										eleData.rndPreSelect = d
										MouseData.hit = t
									end
								end
								tabsize = tabsize+width+gap
							end
						end
						eleData.preSelect = -1
						dxSetRenderTarget(rndtgt)
						dxSetBlendMode("add")
						dxDrawImage(x,y,w,height,rendt,0,0,0,applyColorAlpha(white,galpha),rendSet)
						dxSetBlendMode(rndtgt and "modulate_add" or "blend")
						local colors = applyColorAlpha(dgsElementData[tabs[selected]].bgColor,galpha)
						if dgsElementData[tabs[selected]].bgImage then
							dxDrawImage(x,y+height,w,h-height,dgsElementData[tabs[selected]].bgImage,0,0,0,colors,rendSet)
						else
							dxDrawRectangle(x,y+height,w,h-height,colors,rendSet)
						end
						local children = ChildrenTable[tabs[selected]]
						for i=1,#children do
							renderGUI(children[i],mx,my,enabled,rndtgt,position,OffsetX,OffsetY,galpha,visible)
						end
					end
				end
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					local hSideSize = sideSize*0.5
					sideColor = applyColorAlpha(sideColor,galpha)
					local side = outlineData[1]
					if side == "in" then
						dxDrawLine(x,y+hSideSize,x+w,y+hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x+hSideSize,y,x+hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w-hSideSize,y,x+w-hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+h-hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,rendSet)
					elseif side == "center" then
						dxDrawLine(x-hSideSize,y,x+w+hSideSize,y,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+hSideSize,x,y+h-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x+w,y+hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x-hSideSize,y+h,x+w+hSideSize,y+h,sideColor,sideSize,rendSet)
					elseif side == "out" then
						dxDrawLine(x-sideSize,y-hSideSize,x+w+sideSize,y-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x-hSideSize,y,x-hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w+hSideSize,y,x+w+hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize,y+h+hSideSize,x+w+sideSize,y+h+hSideSize,sideColor,sideSize,rendSet)
					end
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
			else
				visible = false
			end
		elseif dxType == "dgs-dxbrowser" then
			if x and y then
				if eleData.PixelInt then
					x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
				end
				local color = applyColorAlpha(eleData.color,galpha)
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						text = fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				dxDrawImage(x,y,w,h,v,0,0,0,color,rendSet)
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					local hSideSize = sideSize*0.5
					sideColor = applyColorAlpha(sideColor,galpha)
					local side = outlineData[1]
					if side == "in" then
						dxDrawLine(x,y+hSideSize,x+w,y+hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x+hSideSize,y,x+hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w-hSideSize,y,x+w-hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+h-hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,rendSet)
					elseif side == "center" then
						dxDrawLine(x-hSideSize,y,x+w+hSideSize,y,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+hSideSize,x,y+h-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x+w,y+hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x-hSideSize,y+h,x+w+hSideSize,y+h,sideColor,sideSize,rendSet)
					elseif side == "out" then
						dxDrawLine(x-sideSize,y-hSideSize,x+w+sideSize,y-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x-hSideSize,y,x-hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w+hSideSize,y,x+w+hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize,y+h+hSideSize,x+w+sideSize,y+h+hSideSize,sideColor,sideSize,rendSet)
					end
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if enabled[1] and mx then
					if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
						MouseData.hit = v
					end
				end
			else
				visible = false
			end
		elseif dxType == "dgs-dx3dinterface" then
			local pos = eleData.position
			local size = eleData.size
			local faceTo = eleData.faceTo
			local x,y,z,w,h,fx,fy,fz,rot = pos[1],pos[2],pos[3],size[1],size[2],faceTo[1],faceTo[2],faceTo[3],eleData.rotation
			rndtgt = eleData.renderTarget_parent
			if x and y and z and w and h and enabled[1] and mx then
				local lnVec,lnPnt
				local camX,camY,camZ = getCameraMatrix()
				if not fx or not fy or not fz then
					fx,fy,fz = camX-x,camY-y,camZ-z
				end
				if wX and wY and wZ then
					lnVec = {wX-camX,wY-camY,wZ-camZ}
					lnPnt = {camX,camY,camZ}
				end
				if eleData.cameraDistance or 0 <= eleData.maxDistance then
					eleData.hit = {dgsCalculate3DInterfaceMouse(x,y,z,fx,fy,fz,w,h,lnVec,lnPnt,rot)}
				else
					eleData.hit = {}
				end
				local hitData = eleData.hit or {}
				if #hitData > 0 then
					local hit,hitX,hitY,hx,hy,hz = hitData[1],hitData[2],hitData[3],hitData[4],hitData[5],hitData[6]
					local distance = ((camX-hx)^2+(camY-hy)^2+(camZ-hz)^2)^0.5
				
					local oldPos = MouseData.interfaceHit
					if isElement(MouseData.lock3DInterface) then
						if MouseData.lock3DInterface == v then
							MouseData.hit = v
							mx,my = hitX*eleData.resolution[1],hitY*eleData.resolution[2]
							MouseX,MouseY = mx,my
							MouseData.interfaceHit = {hx,hy,hz,distance,v}
						end
					elseif (not oldPos[4] or distance <= oldPos[4]) and hit then
						MouseData.hit = v
						mx,my = hitX*eleData.resolution[1],hitY*eleData.resolution[2]
						MouseX,MouseY = mx,my
						MouseData.interfaceHit = {hx,hy,hz,distance,v}
					end
				end
				dxSetRenderTarget(rndtgt,true)
				dxSetRenderTarget()
			else
				visible = false
			end
		elseif dxType == "dgs-dxarrowlist" then
			if eleData.configNextFrame then
				configArrowList(v)
				dgsSetData(v,"configNextFrame",false)
			end
			if x and y then
				if eleData.PixelInt then
					x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
				end
				local color = applyColorAlpha(eleData.bgColor,galpha)
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						text = fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				local rendTarget = eleData.renderTarget
				if isElement(eleData.bgImage) then
					dxDrawImage(x,y,h,w,eleData.bgImage,0,0,0,color,rendSet)
				else
					dxDrawRectangle(x,y,w,h,color,rendSet)
				end
				local sid
				local itemData = eleData.itemData
				local itemDataCount = #itemData
				if not eleData.mode then
					dxSetRenderTarget(rendTarget,true)
					dxSetBlendMode("modulate_add")
					local leading = eleData.leading
					local itemHeight = eleData.itemHeight
					local itemMoveOffset = eleData.itemMoveOffset
					local whichRowToStart = -floor((itemMoveOffset+itemHeight+leading)/itemHeight)+1
					local whichRowToEnd = whichRowToStart+floor(h/(itemHeight+leading))+1
					eleData.FromTo = {whichRowToStart > 0 and whichRowToStart or 1,whichRowToEnd <= itemDataCount and whichRowToEnd or itemDataCount}
					local scbThick = eleData.scrollBarThick
					local scrollbar = eleData.scrollbar
					local scbcheck = eleData.visible and scbThick or 0
					if mx >= cx and mx <= cx+w-scbcheck and my >= cy and my <= cy+h then
						local toffset = (whichRowToStart*itemHeight+(whichRowToStart-1)*leading)+itemMoveOffset
						local mouseTemp = (my-cy-toffset)
						sid = floor(mouseTemp/(itemHeight+leading))+whichRowToStart+1
						if sid <= itemDataCount and my-cy > (sid-1)*(itemHeight+leading)+itemMoveOffset then
							eleData.select = sid
							MouseData.enterData = true
						else
							eleData.select = -1
						end
					else
						eleData.select = -1
					end
					local arrowListSelect = eleData.select
					local rndtgtWidth = w - scbcheck
					for i=eleData.FromTo[1],eleData.FromTo[2] do
						local iData = itemData[i]
						local iConfig = iData[7]
						local itemY = itemMoveOffset+(i-1)*(itemHeight+leading)
						local colorImgID = arrowListSelect == i and 2 or 1
						if iConfig[2][colorImgID] then
							dxDrawImage(0,itemY,rndtgtWidth,itemHeight,iConfig[2][colorImgID],0,0,0,iConfig[1][colorImgID],false)
						else
							dxDrawRectangle(0,itemY,rndtgtWidth,itemHeight,iConfig[1][colorImgID],false)
						end
						if iConfig[8] then
							dxDrawText(iData[1],iConfig[7],itemY,rndtgtWidth,itemY+itemHeight,black,iConfig[4][1],iConfig[4][2],iConfig[11],iConfig[6],"center")
						end
						dxDrawText(iData[1],iConfig[7],itemY,rndtgtWidth,itemY+itemHeight,iConfig[3],iConfig[4][1],iConfig[4][2],iConfig[11],iConfig[6],"center")
						local operatorLen = dxGetTextWidth("<",iConfig[4][1],"default-bold")
						if iConfig[12] == "right" then
							local currentSelected = iData[6]
							if iData[5] and iData[5][currentSelected] then
								currentSelected = iData[5][currentSelected]
							end
							local textLength = iConfig[14] or dxGetTextWidth(currentSelected,iConfig[10][1],iConfig[11])
							local initialXPos = rndtgtWidth-iConfig[13]-operatorLen
							local distance = iConfig[16]
							local selectorR_sx,selectorR_ex = initialXPos,initialXPos+operatorLen
							local selectorL_sx,selectorL_ex = initialXPos-textLength-operatorLen-distance*2,initialXPos-textLength-distance*2
							local selectorText_sx,selectorText_ex = initialXPos-textLength-distance,initialXPos-distance
							local selectStateL,selectStateR = 1,1
							if eleData.select == i then
								local mouseX,mouseY = mx-cx,my-cy
								if mouseX > selectorL_sx and mouseX < selectorL_ex then
									selectStateL = 2
									MouseData.arrowListEnter = {v,i,"left"}
									if eleData.arrowListClick and eleData.arrowListClick[1] == i and eleData.arrowListClick[2] == "left" then
										selectStateL = 3
									end
								elseif mouseX > selectorR_sx and mouseX < selectorR_ex then
									selectStateR = 2
									MouseData.arrowListEnter = {v,i,"right"}
									if eleData.arrowListClick and eleData.arrowListClick[1] == i and eleData.arrowListClick[2] == "right" then
										selectStateR = 3
									end
								else
									MouseData.arrowListEnter = {v,i}
								end
							end
							local selectorColorLeft = iConfig[9][selectStateL]
							local selectorColorRight = iConfig[9][selectStateR]
							dxDrawText(">",selectorR_sx,itemY,selectorR_ex,itemY+itemHeight,selectorColorRight,iConfig[4][1],iConfig[4][2],"default-bold","center","center")
							dxDrawText(currentSelected,selectorText_sx,itemY,selectorText_ex,itemY+itemHeight,iConfig[17],iConfig[4][1],iConfig[4][2],iConfig[11],"center","center")
							dxDrawText("<",selectorL_sx,itemY,selectorL_ex,itemY+itemHeight,selectorColorLeft,iConfig[4][1],iConfig[4][2],"default-bold","center","center")
						elseif iConfig[12] == "left" then
							
						end
					end
					dxSetRenderTarget(rndtgt)
					dxSetBlendMode("add")
					dxDrawImage(x,y,rndtgtWidth,h,rendTarget,0,0,0,tocolor(255,255,255,galpha*255),rendSet)
					dxSetBlendMode(rndtgt and "modulate_add" or "blend")
				else
				
				end
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					local hSideSize = sideSize*0.5
					sideColor = applyColorAlpha(sideColor,galpha)
					local side = outlineData[1]
					if side == "in" then
						dxDrawLine(x,y+hSideSize,x+w,y+hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x+hSideSize,y,x+hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w-hSideSize,y,x+w-hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+h-hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,rendSet)
					elseif side == "center" then
						dxDrawLine(x-hSideSize,y,x+w+hSideSize,y,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+hSideSize,x,y+h-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x+w,y+hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x-hSideSize,y+h,x+w+hSideSize,y+h,sideColor,sideSize,rendSet)
					elseif side == "out" then
						dxDrawLine(x-sideSize,y-hSideSize,x+w+sideSize,y-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x-hSideSize,y,x-hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w+hSideSize,y,x+w+hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize,y+h+hSideSize,x+w+sideSize,y+h+hSideSize,sideColor,sideSize,rendSet)
					end
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if enabled[1] and mx then
					if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
						MouseData.hit = v
					end
				end
			else
				visible = false
			end
		elseif dxType == "dgs-dx3dtext" then
			local camX,camY,camZ = getCameraMatrix()
			local attachTable = eleData.attachTo
			local posTable = eleData.position
			local wx,wy,wz = posTable[1],posTable[2],posTable[3]
			local text = eleData.text
			local font = eleData.font or systemFont
			local textSizeX,textSizeY = eleData.textSize[1],eleData.textSize[2]
			local colorcoded = eleData.colorcoded
			local maxDistance = eleData.maxDistance
			if attachTable then
				if isElement(attachTable[1]) then
					wx,wy,wz = getPositionFromElementOffset(attachTable[1],attachTable[2],attachTable[3],attachTable[4])
					eleData.position = {wx,wy,wz}
				else
					eleData.attachTo = false
				end
			end
			local fadeDistance = eleData.fadeDistance
			local distance = ((wx-camX)^2+(wy-camY)^2+(wz-camZ)^2)^0.5
			if distance <= maxDistance and distance > 0 then
				local fadeMulti = 1
				if maxDistance > fadeDistance and distance >= fadeDistance then
					fadeMulti = 1-(distance-fadeDistance)/(maxDistance-fadeDistance)
				end
				local x,y = getScreenFromWorldPosition(wx,wy,wz)
				if x and y then
					local x,y = x-x%1,y-y%1
					if eleData.fixTextSize then
						distance = 50
					end
					local antiDistance = 1/distance
					local sizeX = textSizeX*textSizeX/distance*50
					local sizeY = textSizeY*textSizeY/distance*50
					------------------------------------
					if eleData.functionRunBefore then
						local fnc = eleData.functions
						if type(fnc) == "table" then
							fnc[1](unpack(fnc[2]))
						end
					end
					------------------------------------
					local color = applyColorAlpha(eleData.color,galpha*fadeMulti)
					local shadow = eleData.shadow
					if shadow then
						local shadowoffx,shadowoffy,shadowc,shadowIsOutline = shadow[1],shadow[2],shadow[3],shadow[4]
						if shadowoffx and shadowoffy and shadowc then
							local shadowText = colorcoded and text:gsub('#%x%x%x%x%x%x','') or text
							local shadowc = applyColorAlpha(shadowc,galpha*fadeMulti)
							local shadowoffx,shadowoffy = shadowoffx*antiDistance*25,shadowoffy*antiDistance*25
							dxDrawText(shadowText,x+shadowoffx,y+shadowoffy,_,_,shadowc,sizeX,sizeY,font,"center","center",false,false,false,false,true)
							if shadowIsOutline then
								dxDrawText(shadowText,x-shadowoffx,y+shadowoffy,_,_,shadowc,sizeX,sizeY,font,"center","center",false,false,false,false,true)
								dxDrawText(shadowText,x-shadowoffx,y-shadowoffy,_,_,shadowc,sizeX,sizeY,font,"center","center",false,false,false,false,true)
								dxDrawText(shadowText,x+shadowoffx,y-shadowoffy,_,_,shadowc,sizeX,sizeY,font,"center","center",false,false,false,false,true)
							end
						end
					end
					dxDrawText(text,x,y,x,y,color,sizeX,sizeY,font,"center","center",false,false,false,colorcoded,true)
					------------------------------------OutLine
					local outlineData = eleData.outline
					if outlineData then
						local shadowText = colorcoded and text:gsub('#%x%x%x%x%x%x','') or text
						local w,h = dxGetTextWidth(shadowText,sizeX,font),dxGetFontHeight(sizeY,font)
						local x,y=x-w*0.5,y-h*0.5
						local sideColor = outlineData[3]
						local sideSize = outlineData[2]*antiDistance*25
						local hSideSize = sideSize*0.5
						sideColor = applyColorAlpha(sideColor,galpha*fadeMulti)
						local side = outlineData[1]
						if side == "in" then
							dxDrawLine(x,y+hSideSize,x+w,y+hSideSize,sideColor,sideSize)
							dxDrawLine(x+hSideSize,y,x+hSideSize,y+h,sideColor,sideSize)
							dxDrawLine(x+w-hSideSize,y,x+w-hSideSize,y+h,sideColor,sideSize)
							dxDrawLine(x,y+h-hSideSize,x+w,y+h-hSideSize,sideColor,sideSize)
						elseif side == "center" then
							dxDrawLine(x-hSideSize,y,x+w+hSideSize,y,sideColor,sideSize)
							dxDrawLine(x,y+hSideSize,x,y+h-hSideSize,sideColor,sideSize)
							dxDrawLine(x+w,y+hSideSize,x+w,y+h-hSideSize,sideColor,sideSize)
							dxDrawLine(x-hSideSize,y+h,x+w+hSideSize,y+h,sideColor,sideSize)
						elseif side == "out" then
							dxDrawLine(x-sideSize,y-hSideSize,x+w+sideSize,y-hSideSize,sideColor,sideSize)
							dxDrawLine(x-hSideSize,y,x-hSideSize,y+h,sideColor,sideSize)
							dxDrawLine(x+w+hSideSize,y,x+w+hSideSize,y+h,sideColor,sideSize)
							dxDrawLine(x-sideSize,y+h+hSideSize,x+w+sideSize,y+h+hSideSize,sideColor,sideSize)
						end
					end
					------------------------------------
					if not eleData.functionRunBefore then
						local fnc = eleData.functions
						if type(fnc) == "table" then
							fnc[1](unpack(fnc[2]))
						end
					end
					------------------------------------
				end
			end
		elseif dxType == "dgs-dxswitchbutton" then
			if x and y then
				if eleData.PixelInt then
					x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
				end
				local image_f,image_t = eleData.image_f,eleData.image_t
				local color_f,color_t = eleData.color_f,eleData.color_t
				local image,color,textColor,text
				local cursorImage,cursorColor = eleData.cursorImage,eleData.cursorColor
				local xAdd = eleData.textOffset[2] and w*eleData.textOffset[1] or eleData.textOffset[1]
				if eleData.state then
					image,color,textColor,text,xAdd = image_t,color_t,eleData.textColor_t,eleData.textOn,-xAdd
				else 
					image,color,textColor,text = image_f,color_f,eleData.textColor_f,eleData.textOff
				end
				local colorImgBgID = 1
				local colorImgID = 1
				local cursorWidth = eleData.cursorWidth[2] and w*eleData.cursorWidth[1] or eleData.cursorWidth[1]
				local cursorX = x+(eleData.stateAnim+1)*0.5*(w-cursorWidth)
				if MouseData.enter == v then
					local isHitCursor = mx >= cursorX and mx <= cursorX+cursorWidth
					colorImgBgID = 2
					if isHitCursor then
						colorImgID = 2
					end
					if eleData.clickType == 1 then
						if MouseData.clickl == v then
							colorImgBgID = 3
							if isHitCursor then
								colorImgID = 3
							end
						end
					elseif eleData.clickType == 2 then
						if MouseData.clickr == v then
							colorImgBgID = 3
							if isHitCursor then
								colorImgID = 3
							end
						end
					else
						if MouseData.clickl == v or MouseData.clickr == v then
							colorImgBgID = 3
							if isHitCursor then
								colorImgID = 3
							end
						end
					end
				end
				local cursorImage = cursorImage[colorImgID]
				local finalcolor
				if not enabled[1] and not enabled[2] then
					if type(eleData.disabledColor) == "number" then
						finalcolor = applyColorAlpha(eleData.disabledColor,galpha)
					elseif eleData.disabledColor == true then
						local r,g,b,a = fromcolor(color[1],true)
						local average = (r+g+b)/3*eleData.disabledColorPercent
						finalcolor = tocolor(average,average,average,a*galpha)
						local r,g,b,a = fromcolor(cursorColor[1],true)
						local average = (r+g+b)/3*eleData.disabledColorPercent
						cursorColor = tocolor(average,average,average,a*galpha)
					else
						finalcolor = color[colorImgBgID]
						cursorColor = cursorColor[colorImgID]
					end
				else
					finalcolor = applyColorAlpha(color[colorImgBgID],galpha)
					cursorColor = applyColorAlpha(cursorColor[colorImgID],galpha)
				end
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if image[colorImgBgID] then
					dxDrawImage(x,y,w,h,image[colorImgBgID],0,0,0,finalcolor,rendSet)
				else
					dxDrawRectangle(x,y,w,h,finalcolor,rendSet)
				end
				local font = eleData.font or systemFont
				local txtSizX,txtSizY = eleData.textSize[1],eleData.textSize[2] or eleData.textSize[1]
				local clip = eleData.clip
				local wordbreak = eleData.wordbreak
				local colorcoded = eleData.colorcoded
				local shadow = eleData.shadow
				local textX,textY,textWX,textHY = x+w*0.5+xAdd-cursorWidth,y,x+w*0.5+xAdd+cursorWidth,y+h
				if shadow then
					local shadowoffx,shadowoffy,shadowc,shadowIsOutline = shadow[1],shadow[2],shadow[3],shadow[4]
					if shadowoffx and shadowoffy and shadowc then
						local shadowc = applyColorAlpha(shadowc,galpha)
						local shadowText = colorcoded and text:gsub('#%x%x%x%x%x%x','') or text
						dxDrawText(shadowText,textX+shadowoffx,textY+shadowoffy,textWX+shadowoffx,textHY+shadowoffy,shadowc,txtSizX,txtSizY,font,"center","center",clip,wordbreak,rendSet)
						if shadowIsOutline then
							dxDrawText(shadowText,textX-shadowoffx,textY+shadowoffy,textWX-shadowoffx,textHY+shadowoffy,shadowc,txtSizX,txtSizY,font,"center","center",clip,wordbreak,rendSet)
							dxDrawText(shadowText,textX-shadowoffx,textY-shadowoffy,textWX-shadowoffx,textHY-shadowoffy,shadowc,txtSizX,txtSizY,font,"center","center",clip,wordbreak,rendSet)
							dxDrawText(shadowText,textX+shadowoffx,textY-shadowoffy,textWX+shadowoffx,textHY-shadowoffy,shadowc,txtSizX,txtSizY,font,"center","center",clip,wordbreak,rendSet)
						end
					end
				end
				dxDrawText(text,textX,textY,textWX,textHY,applyColorAlpha(textColor,galpha),txtSizX,txtSizY,font,"center","center",clip,wordbreak,rendSet,colorcoded)
				----Cursor
				if cursorImage then
					dxDrawImage(cursorX,y,cursorWidth,h,cursorImage,0,0,0,cursorColor,rendSet)
				else
					dxDrawRectangle(cursorX,y,cursorWidth,h,cursorColor,rendSet)
				end
				
				local state = eleData.state and 1 or -1
				if eleData.stateAnim ~= state then
					local stat = eleData.stateAnim+eleData.state*eleData.cursorMoveSpeed
					eleData.stateAnim = state == -1 and max(stat,state) or min(stat,state)
				end
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					local hSideSize = sideSize*0.5
					sideColor = applyColorAlpha(sideColor,galpha)
					local side = outlineData[1]
					if side == "in" then
						dxDrawLine(x,y+hSideSize,x+w,y+hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x+hSideSize,y,x+hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w-hSideSize,y,x+w-hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+h-hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,rendSet)
					elseif side == "center" then
						dxDrawLine(x-hSideSize,y,x+w+hSideSize,y,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+hSideSize,x,y+h-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x+w,y+hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x-hSideSize,y+h,x+w+hSideSize,y+h,sideColor,sideSize,rendSet)
					elseif side == "out" then
						dxDrawLine(x-sideSize,y-hSideSize,x+w+sideSize,y-hSideSize,sideColor,sideSize,rendSet)
						dxDrawLine(x-hSideSize,y,x-hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w+hSideSize,y,x+w+hSideSize,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize,y+h+hSideSize,x+w+sideSize,y+h+hSideSize,sideColor,sideSize,rendSet)
					end
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if enabled[1] and mx then
					if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
						MouseData.hit = v
					end
				end
			else
				visible = false
			end
		else
			interrupted = true
		end
		local oldMouseIn = eleData.rndTmp_mouseIn or false
		local newMouseIn = MouseData.hit and true or false
		if eleData.enableFullEnterLeaveCheck then
			if oldMouseIn ~= newMouseIn then
				eleData.rndTmp_mouseIn = newMouseIn
				triggerEvent("onDgsElement"..(newMouseIn and "Enter" or "Leave"),v)
			end
		end
		if eleData.renderEventCall then
			triggerEvent("onDgsElementRender",v,x,y,w,h)
		end
		if not eleData.hitoutofparent then
			if MouseData.hit ~= v then
				enabled[1] = false
			end
		end
		if not interrupted then
			for i=1,#children do
				local child = children[i]
				isElementInside = isElementInside or renderGUI(child,mx,my,enabled,rndtgt,position,OffsetX,OffsetY,galpha,visible,checkElement)
			end
		end
	end
	dxSetBlendMode("blend")
	return isElementInside or v == checkElement
end
addEventHandler("onClientRender",root,dgsCoreRender,false,dgsRenderSetting.renderPriority)

addEventHandler("onClientKey",root,function(button,state)
	if button == "mouse_wheel_up" or button == "mouse_wheel_down" then
		local dgsType = dgsGetType(MouseData.enter)
		if isElement(MouseData.enter) then
			triggerEvent("onDgsMouseWheel",MouseData.enter,button == "mouse_wheel_down" and -1 or 1)
		end
		local scroll = button == "mouse_wheel_down" and 1 or -1
		local scrollbar = MouseData.enter
		if dgsGetType(scrollbar) == "dgs-dxscrollbar" then
			scrollScrollBar(scrollbar,button == "mouse_wheel_down" or false)
		elseif dgsType == "dgs-dxgridlist" then
			local scrollbar
			local scrollbar1,scrollbar2 = dgsElementData[MouseData.enter].scrollbars[1],dgsElementData[MouseData.enter].scrollbars[2]
			local visibleScb1,visibleScb2 = dgsGetVisible(scrollbar1),dgsGetVisible(scrollbar2)
			if visibleScb1 and not visibleScb2 then
				scrollbar = scrollbar1
			elseif visibleScb2 and not visibleScb1 then
				scrollbar = scrollbar2
			elseif visibleScb1 and visibleScb2 then
				local whichScrollBar = dgsElementData[MouseData.enter].mouseWheelScrollBar and 2 or 1
				scrollbar = dgsElementData[MouseData.enter].scrollbars[whichScrollBar]
			end
			if scrollbar then
				scrollScrollBar(scrollbar,button == "mouse_wheel_down" or false)
			end
		elseif dgsType == "dgs-dxmemo" then
			local scrollbar = dgsElementData[MouseData.enter].scrollbars[1]
			if dgsGetVisible(scrollbar) then
				scrollScrollBar(scrollbar,button == "mouse_wheel_down" or false)
			end
		elseif isElement(MouseData.scrollPane) then
			local scrollbar
			local scrollbar1,scrollbar2 = dgsElementData[MouseData.scrollPane].scrollbars[1],dgsElementData[MouseData.scrollPane].scrollbars[2]
			local visibleScb1,visibleScb2 = dgsGetVisible(scrollbar1),dgsGetVisible(scrollbar2)
			if visibleScb1 and not visibleScb2 then
				scrollbar = scrollbar1
			elseif visibleScb2 and not visibleScb1 then
				scrollbar = scrollbar2
			elseif visibleScb1 and visibleScb2 then
				local whichScrollBar = dgsElementData[MouseData.scrollPane].mouseWheelScrollBar and 2 or 1
				scrollbar = dgsElementData[MouseData.scrollPane].scrollbars[whichScrollBar]
			end
			if scrollbar then
				scrollScrollBar(scrollbar,button == "mouse_wheel_down" or false)
			end
		elseif dgsType == "dgs-dxtabpanel" or dgsType == "dgs-dxtab" then
			local tabpanel = MouseData.enter
			if dgsType == "dgs-dxtab" then
				tabpanel = dgsElementData[MouseData.enter].parent
			end
			local width = dgsTabPanelGetWidth(tabpanel)
			local w,h = dgsElementData[tabpanel].absSize[1],dgsElementData[tabpanel].absSize[2]
			if width > w then
				local mx,my = getCursorPosition()
				mx,my = (mx or -1)*sW,(my or -1)*sH
				local _,y = dgsGetPosition(tabpanel,false,true)
				local height = dgsElementData[tabpanel].tabHeight[2] and dgsElementData[tabpanel].tabHeight[1]*h or dgsElementData[tabpanel].tabHeight[1]
				if my < y+height then
					local speed = dgsElementData[tabpanel].scrollSpeed[2] and dgsElementData[tabpanel].scrollSpeed[1] or dgsElementData[tabpanel].scrollSpeed[1]/width
					local orgoff = dgsElementData[tabpanel].showPos
					orgoff = math.restrict(orgoff+scroll*speed,0,1)
					dgsSetData(tabpanel,"showPos",orgoff)
				end
			end
		elseif dgsType == "dgs-dxcombobox-Box" then
			local combo = dgsElementData[MouseData.enter].myCombo
			local scrollbar = dgsElementData[combo].scrollbar
			if dgsGetVisible(scrollbar) then
				scrollScrollBar(scrollbar,button == "mouse_wheel_down" or false)
			end
		elseif dgsType == "dgs-dxarrowlist" then
			local scrollbar = dgsElementData[MouseData.enter].scrollbar
			if dgsGetVisible(scrollbar) then
				scrollScrollBar(scrollbar,button == "mouse_wheel_down" or false)
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
	if dgsGetType(MouseData.nowShow) == "dgs-dxedit" then
		local dgsEdit = MouseData.nowShow
		local text = dgsElementData[dgsEdit].text
		local shift = getKeyState("lshift") or getKeyState("rshift")
		local ctrl = getKeyState("lctrl") or getKeyState("rctrl")
		if button == "arrow_l" then
			dgsEditMoveCaret(dgsEdit,-1,shift)
		elseif button == "arrow_r" then
			dgsEditMoveCaret(dgsEdit,1,shift)
		elseif button == "arrow_u" then
			local cmd = dgsElementData[dgsEdit].mycmd
			if dgsGetPluginType(cmd) == "dgs-dxcmd" then
				local int = dgsElementData[cmd].cmdCurrentHistory+1
				local history = dgsElementData[cmd].cmdHistory
				if history[int] then
					dgsSetData(cmd,"cmdCurrentHistory",int)
					dgsSetText(dgsEdit,history[int])
					dgsEditSetCaretPosition(dgsEdit,#history[int])
				end
			end
		elseif button == "arrow_d" then
			local cmd = dgsElementData[dgsEdit].mycmd
			if dgsGetPluginType(cmd) == "dgs-dxcmd" then
				local int = dgsElementData[cmd].cmdCurrentHistory-1
				local history = dgsElementData[cmd].cmdHistory
				if history[int] then
					dgsSetData(cmd,"cmdCurrentHistory",int)
					dgsSetText(dgsEdit,history[int])
					dgsEditSetCaretPosition(dgsEdit,#history[int])
				end
			end
		elseif button == "home" then
			dgsEditSetCaretPosition(dgsEdit,0,shift)
		elseif button == "end" then
			dgsEditSetCaretPosition(dgsEdit,#text,shift)
		elseif button == "delete" then
			if not dgsElementData[dgsEdit].readOnly then
				local cpos = dgsElementData[dgsEdit].caretPos
				local spos = dgsElementData[dgsEdit].selectFrom
				if cpos ~= spos then
					dgsEditDeleteText(dgsEdit,cpos,spos)
					dgsElementData[dgsEdit].selectFrom = dgsElementData[dgsEdit].caretPos
				else
					dgsEditDeleteText(dgsEdit,cpos,cpos+1)
				end
			end
		elseif button == "backspace" then
			if not dgsElementData[dgsEdit].readOnly then
				local cpos = dgsElementData[dgsEdit].caretPos
				local spos = dgsElementData[dgsEdit].selectFrom
				if cpos ~= spos then
					dgsEditDeleteText(dgsEdit,cpos,spos)
					dgsElementData[dgsEdit].selectFrom = dgsElementData[dgsEdit].caretPos
				else
					dgsEditDeleteText(dgsEdit,cpos-1,cpos)
				end
			end
		elseif button == "c" or button == "x" then
			if dgsElementData[dgsEdit].allowCopy then
				if ctrl then
					local cpos = dgsElementData[dgsEdit].caretPos
					local spos = dgsElementData[dgsEdit].selectFrom
					if cpos ~= spos then
						local deleteText = button == "x" and not dgsElementData[dgsEdit].readOnly
						local theText = dgsEditGetPartOfText(dgsEdit,cpos,spos,deleteText)
						setClipboard(theText)
					end
				end
			end
		elseif button == "z" then
			if ctrl then
				dgsEditDoOpposite(dgsEdit,true)
			end
		elseif button == "y" then
			if ctrl then
				dgsEditDoOpposite(dgsEdit,false)
			end
		elseif button == "tab" then
			makeEventCancelled = true
			triggerEvent("onDgsEditPreSwitch",dgsEdit)
		elseif button == "a" then
			if ctrl then
				dgsSetData(dgsEdit,"caretPos",0)
				local text = dgsElementData[dgsEdit].text
				dgsSetData(dgsEdit,"selectFrom",utf8Len(text))
			end
		end
	elseif dgsGetType(MouseData.nowShow) == "dgs-dxmemo" then
		local memo = MouseData.nowShow
		local shift = getKeyState("lshift") or getKeyState("rshift")
		local ctrl = getKeyState("lctrl") or getKeyState("rctrl")
		local isWordWarp = dgsElementData[memo].wordWarp
		if button == "arrow_l" then
			dgsMemoMoveCaret(memo,-1,0,shift)
		elseif button == "arrow_r" then
				dgsMemoMoveCaret(memo,1,0,shift)
		elseif button == "arrow_u" then
			dgsMemoMoveCaret(memo,0,-1,shift,true)
		elseif button == "arrow_d" then
			dgsMemoMoveCaret(memo,0,1,shift,true)
		elseif button == "home" then
			if isWordWarp then
				local text = dgsElementData[memo].text
				local index,line = dgsElementData[memo].caretPos[1],dgsElementData[memo].caretPos[2]
				local weakLineIndex,weakLine = dgsMemoFindWeakLineInStrongLine(text[line],index)
				local currentPos = utf8Len(text[line][0],1,index)-utf8Len(text[line][1][weakLine][0],1,weakLineIndex)
				dgsMemoSetCaretPosition(memo,currentPos,ctrl and 1,shift)
			else
				dgsMemoSetCaretPosition(memo,0,ctrl and 1,shift)
			end
		elseif button == "end" then
			local text = dgsElementData[memo].text
			local index,line = dgsElementData[memo].caretPos[1],dgsElementData[memo].caretPos[2]
			if isWordWarp then
				local weakLineIndex,weakLine = dgsMemoFindWeakLineInStrongLine(dgsElementData[memo].text[line],index,true)
				local currentPos = utf8Len(dgsElementData[memo].text[line][0],1,index)-utf8Len(text[line][1][weakLine][0],1,weakLineIndex)+dgsElementData[memo].text[line][1][weakLine][3]
				dgsMemoSetCaretPosition(memo,currentPos,ctrl and #text,shift,not ctrl and true)
			else
				dgsMemoSetCaretPosition(memo,utf8Len(text[line][0] or ""),ctrl and #text,shift)
			end
		elseif button == "delete" then
			if not dgsElementData[memo].readOnly then
				local cpos = dgsElementData[memo].caretPos
				local spos = dgsElementData[memo].selectFrom
				if cpos[1] ~= spos[1] or cpos[2] ~= spos[2] then
					dgsMemoDeleteText(memo,cpos[1],cpos[2],spos[1],spos[2])
					dgsElementData[memo].selectFrom = dgsElementData[memo].caretPos
				else
					local tarindex,tarline = dgsMemoSeekPosition(dgsElementData[memo].text,cpos[1]+1,cpos[2])
					dgsMemoDeleteText(memo,cpos[1],cpos[2],tarindex,tarline)
				end
			end
		elseif button == "backspace" then
			if not dgsElementData[memo].readOnly then
				local cpos = dgsElementData[memo].caretPos
				local spos = dgsElementData[memo].selectFrom
				if cpos[1] ~= spos[1] or cpos[2] ~= spos[2] then
					dgsMemoDeleteText(memo,cpos[1],cpos[2],spos[1],spos[2])
					dgsElementData[memo].selectFrom = dgsElementData[memo].caretPos
				else
					local tarindex,tarline = dgsMemoSeekPosition(dgsElementData[memo].text,cpos[1]-1,cpos[2])
					dgsMemoDeleteText(memo,tarindex,tarline,cpos[1],cpos[2])
				end
			end
		elseif button == "c" or button == "x" then
			if dgsElementData[memo].allowCopy then
				if ctrl then
					local cpos = dgsElementData[memo].caretPos
					local spos = dgsElementData[memo].selectFrom
					if not(cpos[1] == spos[1] and cpos[2] == spos[2]) then 
						local deleteText = button == "x" and not dgsElementData[memo].readOnly
						local theText = dgsMemoGetPartOfText(memo,cpos[1],cpos[2],spos[1],spos[2],deleteText)
						setClipboard(theText)
					end
				end
			end
		elseif button == "a" then
			if ctrl then
				dgsMemoSetSelectedArea(memo,0,1,"all")
			end
		end
	elseif dgsGetType(MouseData.nowShow) == "dgs-dxgridlist" then
		local gridlist = MouseData.nowShow
		if dgsElementData[gridlist].enableNavigation then
			if button == "arrow_u" then
				if dgsElementData[gridlist].selectionMode ~= 2 then
					local lastSelected = dgsElementData[gridlist].lastSelectedItem
					local nextSelected = lastSelected[1]-1
					dgsGridListSetSelectedItem(gridlist,nextSelected <= 1 and 1 or nextSelected,lastSelected[2],true)
				end
			elseif button == "arrow_d" then
				if dgsElementData[gridlist].selectionMode ~= 2 then
					local lastSelected = dgsElementData[gridlist].lastSelectedItem
					local nextSelected = lastSelected[1]+1
					local rowCount = #dgsElementData[gridlist].rowData
					dgsGridListSetSelectedItem(gridlist,nextSelected >= rowCount and rowCount or nextSelected,lastSelected[2],true)
				end
			elseif button == "arrow_l" then
				if dgsElementData[gridlist].selectionMode ~= 1 then
					local lastSelected = dgsElementData[gridlist].lastSelectedItem
					local nextSelected = lastSelected[2]-1
					dgsGridListSetSelectedItem(gridlist,lastSelected[1],nextSelected <= 1 and 1 or nextSelected,true)
				end
			elseif button == "arrow_r" then
				if dgsElementData[gridlist].selectionMode ~= 1 then
					local lastSelected = dgsElementData[gridlist].lastSelectedItem
					local nextSelected = lastSelected[2]+1
					local columCount = #dgsElementData[gridlist].columnData
					dgsGridListSetSelectedItem(gridlist,lastSelected[1],nextSelected >= columCount and columCount or nextSelected,true)
				end
			end
		end
	end
	return makeEventCancelled
end

KeyHolder = {}
function onClientKeyCheck(button,state)
	if state then
		if button:sub(1,5) ~= "mouse" then
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
end
addEventHandler("onClientKey",root,onClientKeyCheck)

addEventHandler("onDgsTextChange",root,function()
	local text = dgsElementData[source].text
	local parent = dgsElementData[source].mycmd
	if isElement(parent) then
		if dgsGetPluginType(parent) == "dgs-dxcmd" then
			local hisid = dgsElementData[parent].cmdCurrentHistory
			local history = dgsElementData[parent].cmdHistory
			if history[hisid] ~= text then
				dgsSetData(parent,"cmdCurrentHistory",0)
			end
		end
	end
end)

function dgsCheckHit(hits,mx,my)
	if not isElement(MouseData.clickl) or not (dgsGetType(MouseData.clickl) == "dgs-dxscrollbar" and MouseData.clickData == 2) then
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
			MouseData.clickData = false
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
	if MouseHolder.element == MouseData.enter and dgsGetType(MouseHolder.element) == "dgs-dxscrollbar" then
		if MouseData.enterData then
			MouseData.clickData = MouseData.enterData
		end
		local scrollbar = MouseHolder.element
		if MouseData.enterData == 1 or MouseData.enterData == 4 then
			if dgsElementData[scrollbar].scrollArrow then
				scrollScrollBar(scrollbar,MouseData.clickData == 4)
			end
		end
	end
end

MouseHolder = {}
MouseKeyConverter = {left="mouse1",right="mouse2",middle="mouse3"}
MouseKeySupports = {["dgs-dxscrollbar"] = true}
function onDGSMouseCheck(button,state)
	local button = MouseKeyConverter[button]
	if state == "down" then
		if MouseKeySupports[dgsGetType(source)] then
			if not MouseHolder.lastKey then
				if isTimer(MouseHolder.Timer) then killTimer(MouseHolder.Timer) end
				MouseHolder = {}
				MouseHolder.element = source
				MouseHolder.lastKey = button
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
	if dgsIsDxElement(source) then
		triggerEvent("onDgsDestroy",source)
		local child = ChildrenTable[source] or {}
		for i=1,#child do
			if isElement(child[1]) then
				destroyElement(child[1])
			end
		end
		local dgsType = dgsGetType(source)
		if dgsType == "dgs-dxedit" then
			local rentarg = dgsElementData[source].renderTarget
			if isElement(rentarg) then
				destroyElement(rentarg)
			end
			blurEditMemo()
		elseif dgsType == "dgs-dxmemo" then
			local rentarg = dgsElementData[source].renderTarget
			if isElement(rentarg) then
				destroyElement(rentarg)
			end
			blurEditMemo()
		elseif dgsType == "dgs-dxgridlist" then
			local rentarg = dgsElementData[source].renderTarget
			if isElement(rentarg[1]) then
				destroyElement(rentarg[1])
			end
			if isElement(rentarg[2]) then
				destroyElement(rentarg[2])
			end
		elseif dgsType == "dgs-dxscrollpane" then
			local rentarg = dgsElementData[source].renderTarget_parent
			destroyElement(rentarg)
			local scrollbar = dgsElementData[source].scrollbars or {}
			if isElement(scrollbar[1]) then
				destroyElement(scrollbar[1])
			end
			if isElement(scrollbar[2]) then
				destroyElement(scrollbar[2])
			end
		elseif dgsType == "dgs-dxtabpanel" then
			local rentarg = dgsElementData[source].renderTarget
			local tabs = dgsElementData[source].tabs or {}
			for i=1,#tabs do
				destroyElement(tabs[i])
			end
			if isElement(rentarg) then
				destroyElement(rentarg)
			end
		elseif dgsType == "dgs-dxtab" then
			local isRemove = dgsElementData[source].isRemove
			if not isRemove then
				local tabpanel = dgsElementData[source].parent
				if dgsGetType(tabpanel) == "dgs-dxtabpanel" then
					local w = dgsElementData[tabpanel].absSize[1]
					local wid = dgsElementData[source].width
					local tabs = dgsElementData[tabpanel].tabs
					local tabPadding = dgsElementData[tabpanel].tabPadding
					local sidesize = tabPadding[2] and tabPadding[1]*w or tabPadding[1]
					local tabGapSize = dgsElementData[tabpanel].tabGapSize
					local gapSize = tabGapSize[2] and tabGapSize[1]*w or tabGapSize[1]
					dgsSetData(tabpanel,"tabLengthAll",dgsElementData[tabpanel].tabLengthAll-wid-sidesize*2-gapSize*min(#tabs,1))
					local id = dgsElementData[source].id
					for i=id,#tabs do
						dgsElementData[tabs[i]].id = dgsElementData[tabs[i]].id-1
					end
					tableRemove(tabs,id)
				end
			end
		elseif dgsType == "dgs-dxcombobox" then
			local rentarg = dgsElementData[source].renderTarget
			if isElement(rentarg) then
				destroyElement(rentarg)
			end
		elseif dgsType == "dgs-dxarrowlist" then
			local rentarg = dgsElementData[source].renderTarget
			if isElement(rentarg) then
				destroyElement(rentarg)
			end
		elseif dgsType == "dgs-dx3dinterface" then
			local rentarg = dgsElementData[source].renderTarget_parent
			if isElement(rentarg) then
				destroyElement(rentarg)
			end
		elseif dgsType == "dgs-dximage" then
			local image = dgsElementData[source].image
			if isElement(image) then
				if dgsElementData[image] and dgsElementData[image].parent == image then
					destroyElement(image)
				end
			end
		end
		tableRemove(ChildrenTable[source] or {})
		local tresource = getElementData(source,"resource")
		if tresource then
			local id = tableFind(boundResource[tresource] or {},source)
			if id then
				tableRemove(boundResource[tresource],id)
			end
		end
		dgsStopAniming(source)
		dgsStopMoving(source)
		dgsStopSizing(source)
		dgsStopAlphaing(source)
		if dgsType == "dgs-dx3dinterface" then
			local id = tableFind(dx3DInterfaceTable,source)
			if id then
				tableRemove(dx3DInterfaceTable,id)
			end
		elseif dgsType == "dgs-dx3dtext" then
			local id = tableFind(dx3DTextTable,source)
			if id then
				tableRemove(dx3DTextTable,id)
				return
			end
		else
			local parent = dgsGetParent(source)
			if not isElement(parent) then
				local id = tableFind(CenterFatherTable,source)
				if id then
					tableRemove(CenterFatherTable,id)
				else
					local id = tableFind(BottomFatherTable,source)
					if id then
						tableRemove(BottomFatherTable,id)
					else
						local id = tableFind(TopFatherTable,source)
						if id then
							tableRemove(TopFatherTable,id)
						end
					end
				end
			else
				local id = tableFind(ChildrenTable[parent] or {},source)
				if id then
					tableRemove(ChildrenTable[parent],id)
				end
			end
		end
		local lang = (dgsElementData[source] or {})._translationText
		if lang then
			local id = tableFind(LanguageTranslationAttach,source)
			if id then
				tableRemove(LanguageTranslationAttach,id)
			end
		end
	end
	dgsElementData[source] = nil
end)

function checkMove(source)
	local moveData = dgsElementData[source].moveHandlerData
	if moveData then
		local mx,my = getCursorPosition()
		mx,my = MouseX or (mx or -1)*sW,MouseY or (my or -1)*sH
		local x,y = dgsGetPosition(source,false,true)
		local w,h = dgsElementData[source].absSize[1],dgsElementData[source].absSize[2]
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
		local w,h = dgsElementData[source].absSize[1],dgsElementData[source].absSize[2]
		local offsetx,offsety = mx-x,my-y
		local moveData = dgsElementData[source].moveHandlerData
		local movable = dgsElementData[source].movable
		if not movable then return end
		local titsize = dgsElementData[source].movetyp and h or dgsElementData[source].titleHeight
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
	local sizeData = dgsElementData[source].sizeHandlerData
	if sizeData then
		local mx,my = getCursorPosition()
		mx,my = MouseX or (mx or -1)*sW,MouseY or (my or -1)*sH
		local x,y = dgsGetPosition(source,false,true)
		local w,h = dgsElementData[source].absSize[1],dgsElementData[source].absSize[2]
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
		local w,h = dgsElementData[source].absSize[1],dgsElementData[source].absSize[2]
		local offsets = {mx-x,my-y,mx-x-w,my-y-h}
		local sizable = dgsElementData[source].sizable
		if not sizable then return false end
		local borderSize = dgsElementData[source].borderSize
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
DoubleClick = {}
DoubleClick.Interval = 500
DoubleClick.down = false
DoubleClick.up = false
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
		local gtype = dgsGetType(guiele)
		if gtype == "dgs-dxbrowser" then
			focusBrowser(guiele)
		else
			focusBrowser()
		end
		local parent = dgsGetParent(guiele)
		local guitype = dgsGetType(guiele)
		if state == "down" then
			dgsBringToFront(guiele,button)
			if guitype == "dgs-dxscrollpane" then
				local scrollbar = dgsElementData[guiele].scrollbars
				dgsBringToFront(scrollbar[1],"left",_,true)
				dgsBringToFront(scrollbar[2],"left",_,true)
			elseif guitype == "dgs-dxswitchbutton" then
				local clickType = dgsElementData[guiele].clickType
				if clickType == 1 and button == "left" then
					dgsSetData(guiele,"state", -dgsElementData[guiele].state)
				elseif clickType == 2 and button == "middle" then
					dgsSetData(guiele,"state", -dgsElementData[guiele].state)
				elseif clickType == 3 and button == "right" then
					dgsSetData(guiele,"state", -dgsElementData[guiele].state)
				end
			end
			if button == "left" then
				if not checkScale(guiele) then
					checkMove(guiele)
				end
				if guitype == "dgs-dxscrollbar" then
					local scrollArrow = dgsElementData[guiele].scrollArrow
					local x,y = dgsGetPosition(guiele,false,true)
					local w,h = dgsGetSize(guiele,false)
					local voh = dgsElementData[guiele].voh
					local pos = dgsElementData[guiele].position
					local length,lrlt = dgsElementData[guiele].length[1],dgsElementData[guiele].length[2]
					local slotRange
					local arrowPos = 0
					local arrowWid = dgsElementData[guiele].arrowWidth
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
					local cursorRange = (lrlt and length*slotRange) or (length <= slotRange and length or slotRange*0.01)
					local py = pos*0.01*(slotRange-cursorRange)
					checkScrollBar(guiele,py,voh)
					local parent = dgsElementData[guiele].attachedToParent
					if isElement(parent) then
						if guiele == dgsElementData[parent].scrollbars[1] then
							dgsSetData(parent,"mouseWheelScrollBar",false)
						elseif guiele == dgsElementData[parent].scrollbars[2] then
							dgsSetData(parent,"mouseWheelScrollBar",true)
						end
					end
				elseif gtype == "dgs-dxradiobutton" then
					dgsRadioButtonSetSelected(guiele,true)
				elseif gtype == "dgs-dxcheckbox" then
					local state = dgsElementData[guiele].state
					dgsCheckBoxSetSelected(guiele,not state)
				elseif guitype == "dgs-dxcombobox-Box" then
					local combobox = dgsElementData[guiele].myCombo
					local preSelect = dgsElementData[combobox].preSelect
					local oldSelect = dgsElementData[combobox].select
					dgsElementData[combobox].select = preSelect
					local captionEdit = dgsElementData[combobox].captionEdit
					if isElement(captionEdit) then
						local selection = dgsElementData[combobox].select
						local itemData = dgsElementData[combobox].itemData
						dgsSetText(captionEdit,itemData[selection] and itemData[selection][1] or "")
					end
					triggerEvent("onDgsComboBoxSelect",combobox,preSelect,oldSelect)
					if dgsElementData[combobox].autoHideAfterSelected then
						dgsSetData(combobox,"listState",-1)
					end
				elseif guitype == "dgs-dxarrowlist" then
					local alEnter = MouseData.arrowListEnter
					if alEnter and alEnter[1] == guiele then
						dgsSetData(guiele,"arrowListClick",{alEnter[2],alEnter[3]})
						local id = alEnter[2]
						local itemData = dgsElementData[guiele].itemData
						local sItemData = itemData[id]
						if alEnter[3] then
							local mathSymbol = alEnter[3] == "left" and -1 or 1
							local old = sItemData[6]
							sItemData[6] = math.restrict(sItemData[6]+sItemData[4]*mathSymbol,sItemData[2],sItemData[3])
							triggerEvent("onDgsArrowListValueChange",guiele,id,sItemData[6],old)
						end
					end
				elseif guitype == "dgs-dxtab" then
					local tabpanel = dgsElementData[guiele].parent
					dgsBringToFront(tabpanel)
					if dgsElementData[tabpanel]["preSelect"] ~= -1 then
						dgsSetData(tabpanel,"selected",dgsElementData[tabpanel]["preSelect"])
					end
				elseif guitype == "dgs-dxcombobox" then
					dgsSetData(guiele,"listState",dgsElementData[guiele].listState == 1 and -1 or 1)
				end
			end
			if guitype == "dgs-dxgridlist" then
				local clickButton = dgsElementData[guiele].mouseSelectButton
				local isSelectButtonEnabled = clickButton[mouseButtonOrder[button]]
				if isSelectButtonEnabled then
					local oPreSelect = dgsElementData[guiele].oPreSelect
					local rowData = dgsElementData[guiele].rowData
					----Sort
					if dgsElementData[guiele].sortEnabled then
						local column = dgsElementData[guiele].selectedColumn
						if column and column >= 1 then
							local sortFunction = dgsElementData[guiele].sortFunction
							local targetfunction = (sortFunction == sortFunctions_upper or dgsElementData[guiele].sortColumn ~= column) and sortFunctions_lower or sortFunctions_upper
							dgsGridListSetSortFunction(guiele,targetfunction)
							dgsGridListSetSortColumn(guiele,column)
						end
					end
					--------
					if oPreSelect and rowData[oPreSelect] and rowData[oPreSelect][-1] ~= false then 
						local old1,old2
						local selectionMode = dgsElementData[guiele].selectionMode
						local multiSelection = dgsElementData[guiele].multiSelection
						local preSelect = dgsElementData[guiele].preSelect
						local clicked = dgsElementData[guiele].itemClick
						local shift,ctrl = getKeyState("lshift") or getKeyState("rshift"),getKeyState("lctrl") or getKeyState("rctrl")
						if #preSelect == 2 then
							if selectionMode == 1 then
								if multiSelection then
									if ctrl then
										local selected = dgsGridListItemIsSelected(guiele,preSelect[1],1)
										dgsGridListSelectItem(guiele,preSelect[1],1,not selected)
									elseif shift then
										if clicked and #clicked == 2 then
											dgsGridListSetSelectedItem(guiele,-1,-1)
											local startRow,endRow = min(clicked[1],preSelect[1]),max(clicked[1],preSelect[1])
											for row = startRow,endRow do
												dgsGridListSelectItem(guiele,row,1,true)
											end
											dgsElementData[guiele].itemClick = clicked
										end
									else
										dgsGridListSetSelectedItem(guiele,preSelect[1],preSelect[2])
										dgsElementData[guiele].itemClick = preSelect
									end
								else
									dgsGridListSetSelectedItem(guiele,preSelect[1],preSelect[2])
									dgsElementData[guiele].itemClick = preSelect
								end
							elseif selectionMode == 2 then
								if multiSelection then
									if ctrl then
										local selected = dgsGridListItemIsSelected(guiele,1,preSelect[2])
										dgsGridListSelectItem(guiele,preSelect[1],preSelect[2],not selected)
									elseif shift then
										if clicked and #clicked == 2 then
											dgsGridListSetSelectedItem(guiele,-1,-1)
											local startColumn,endColumn = min(clicked[2],preSelect[2]),max(clicked[2],preSelect[2])
											for column = startColumn, endColumn do
												dgsGridListSelectItem(guiele,preSelect[1],column,true)
											end
											dgsElementData[guiele].itemClick = clicked
										end
									else
										dgsGridListSetSelectedItem(guiele,preSelect[1],preSelect[2])
										dgsElementData[guiele].itemClick = preSelect
									end
								else
									dgsGridListSetSelectedItem(guiele,preSelect[1],preSelect[2])
									dgsElementData[guiele].itemClick = preSelect
								end
							elseif selectionMode == 3 then
								if multiSelection then
									if ctrl then
										local selected = dgsGridListItemIsSelected(guiele,preSelect[1],preSelect[2])
										dgsGridListSelectItem(guiele,preSelect[1],preSelect[2],not selected)
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
											dgsElementData[guiele].itemClick = clicked
										end
									else
										dgsGridListSetSelectedItem(guiele,preSelect[1],preSelect[2])
										dgsElementData[guiele].itemClick = preSelect
									end
								else
									dgsGridListSetSelectedItem(guiele,preSelect[1],preSelect[2])
									dgsElementData[guiele].itemClick = preSelect
								end
							end
						end
					end
				end
			end
		else
			if button == "left" then
				if MouseData.arrowListEnter then
					if isElement(MouseData.arrowListEnter[1]) then
						dgsSetData(MouseData.arrowListEnter[1],"arrowListClick",false)
					end
				end
				MouseData.arrowListEnter = false
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
		if DoubleClick[state] and isTimer(DoubleClick[state].timer) and DoubleClick[state].ele == guiele and DoubleClick[state].but == button then
			triggerEvent("onDgsMouseDoubleClick",guiele,button,state,x,y)
			killTimer(DoubleClick[state].timer)
			DoubleClick[state] = {}
		else
			if DoubleClick[state] then
				if isTimer(DoubleClick[state].timer) then
					killTimer(DoubleClick[state].timer)
				end
			end
			DoubleClick[state] = {}
			DoubleClick[state].ele = guiele
			DoubleClick[state].but = button
			DoubleClick[state].timer = setTimer(function()
				DoubleClick[state] = false
			end,DoubleClick.Interval,1)
		end
		if not isElement(guiele) then return end
		if GirdListDoubleClick[state] and isTimer(GirdListDoubleClick[state].timer) then
			local clicked = dgsElementData[guiele].itemClick
			local selectionMode = dgsElementData[guiele].selectionMode
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
				local clicked = dgsElementData[guiele].itemClick
				if clicked[1] ~= -1 and clicked[2] ~= -1 then
					GirdListDoubleClick[state] = {}
					GirdListDoubleClick[state].item,GirdListDoubleClick[state].column = clicked[1],clicked[2]
					GirdListDoubleClick[state].gridlist = guiele
					GirdListDoubleClick[state].but = button
					GirdListDoubleClick[state].timer = setTimer(function()
						GirdListDoubleClick[state].gridlist = false
					end,DoubleClick.Interval,1)
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
		elseif button == "right" then
			MouseData.clickr = false
		end
		MouseData.Move = false
		MouseData.MoveScroll = false
		MouseData.Scale = false
		MouseData.clickData = nil
	end
end)

addEventHandler("onDgsPositionChange",root,function(oldx,oldy)
	local parent = dgsGetParent(source)
	if isElement(parent) then
		if dgsGetType(parent) == "dgs-dxscrollpane" then
			local abspos = dgsElementData[source].absPos
			local abssize = dgsElementData[source].absSize
			if abspos and abssize then
				local x,y,sx,sy = abspos[1],abspos[2],abssize[1],abssize[2]
				local maxSize = dgsElementData[parent].maxChildSize
				local ntempx,ntempy
				local children = ChildrenTable[parent] or {}
				local childrenCnt = #children
				if maxSize[1] <= sx then
					ntempx = 0
					for k=1,#children do
						local child = children[k]
						local pos = dgsElementData[child].absPos
						local size = dgsElementData[child].absSize
						ntempx = ntempx > pos[1]+size[1] and ntempx or pos[1]+size[1]
					end
				end
				if maxSize[2] <= sy then
					ntempy = 0
					for k=1,#children do
						local child = children[k]
						local pos = dgsElementData[child].absPos
						local size = dgsElementData[child].absSize
						ntempy = ntempy > pos[2]+size[2] and ntempy or pos[2]+size[2]	
					end
				end
				dgsSetData(parent,"maxChildSize",{ntempx or maxSize[1],ntempy or maxSize[2]})
			end
		end
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
		local offsetX,offsetY = attachedTable[2],attachedTable[3]
		offsetX,offsetY = relativePos and absw*offsetX or offsetX, relativePos and absh*offsetY or offsetY
		local resX,resY = (absx+offsetX)/sW,(absy+offsetY)/sH
		calculateGuiPositionSize(attachSource,resX,resY,relativePos)
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
				sortScrollPane(source,parent)
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

loadStyleConfig()