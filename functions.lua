---------------Speed Up
local tableInsert = table.insert
local tableRemove = table.remove
local assert = assert
local isElement = isElement
local destroyElement = destroyElement
local tableFind = table.find
local guiBlur = function()
	destroyElement(guiCreateLabel(0,0,0,0,"",false))
end

local guiFocus = guiBringToFront

resourceTranslation = {}
LanguageTranslation = {}
LanguageTranslationAttach = {}
boundResource = {}
SelfEasing = {}
SEInterface = [[
local args = {...};
local progress,setting,self = args[1],args[2],args[3];
local propertyTable = dgsElementData[self];
]]
function dgsAddEasingFunction(name,str)
	assert(type(name) == "string","Bad at argument @dgsAddEasingFunction at argument 1, expected a string got "..type(name))
	assert(type(str) == "string","Bad at argument @dgsAddEasingFunction at argument 2, expected a string got "..type(str))
	assert(not builtins[name],"Bad at argument @dgsAddEasingFunction at argument 1, duplicated name with builtins ("..name..")")
	assert(not SelfEasing[name],"Bad at argument @dgsAddEasingFunction at argument 1, this name has been used ("..name..")")
	local str = SEInterface..str
	local fnc = loadstring(str)
	assert(type(fnc) == "function","Bad at argument @dgsAddEasingFunction at argument 2, failed to load the code")
	SelfEasing[name] = fnc
	return true
end

function dgsRemoveEasingFunction(name)
	assert(type(name) == "string","Bad at argument @dgsRemoveEasingFunction at argument 1, expected a string got "..type(name))
	if SelfEasing[name] then
		SelfEasing[name] = nil
		return true
	end
	return false
end

function dgsEasingFunctionExists(name)
	assert(type(name) == "string","Bad at argument @dgsEasingFunctionExists at argument 1, expected a string got "..type(name))
	return builtins[name] or (SelfEasing[name] and true)
end	

function insertResource(res,dgsElement)
	if res and isElement(dgsElement) then
		boundResource[res] = boundResource[res] or {}
		table.insert(boundResource[res],dgsElement)
		setElementData(dgsElement,"resource",res)
	end
end

addEventHandler("onClientResourceStop",root,function(res)
	local guiTable = boundResource[res]
	if guiTable then
		for k,v in pairs(guiTable) do
			local ele = v
			guiTable[k] = ""
			if isElement(ele) then
				destroyElement(ele)
			end
		end
		boundResource[res] = nil
		resourceTranslation[res] = nil
	end
end)

function dgsGetGuiLocationOnScreen(dgsElement,relative,rndsup)
	if isElement(dgsElement) then
		guielex,guieley = getParentLocation(dgsElement,rndsup,dgsElementData[dgsElement].absPos[1],dgsElementData[dgsElement].absPos[2])
		if relative then
			return guielex/sW,guieley/sH
		else
			return guielex,guieley
		end
	end
	return false
end

function getParentLocation(dgsElement,rndSuspend,x,y,includeSide)
	local eleData
	local x,y = 0,0
	local startEle = dgsElement
	repeat
		eleData = dgsElementData[dgsElement]
		local absPos = eleData.absPos or {0,0}
		local addPosX,addPosY = absPos[1],absPos[2]
		if includeSide then
			local parent = FatherTable[dgsElement]
			if dgsElementData[dgsElement].lor == "right" then
				local pSize = parent and dgsElementData[parent].absSize or {sW,sH}
				addPosX = pSize[1]-addPosX
			end
			if dgsElementData[dgsElement].tob == "bottom" then
				local pSize = parent and dgsElementData[parent].absSize or {sW,sH}
				addPosY = pSize[2]-addPosY
			end
		end
		if dgsElementType[dgsElement] == "dgs-dxtab" then
			dgsElement = eleData.parent
			eleData = dgsElementData[dgsElement]
			local h = eleData.absSize[2]
			local tabHeight = eleData.tabHeight[2] and eleData.tabHeight[1]*h or eleData.tabHeight[1]
			x,y = x+eleData.absPos[1],y+eleData.absPos[2]
			y = y+tabHeight
		end
		dgsElement = FatherTable[dgsElement]
		if dgsElementType[dgsElement] == "dgs-dxwindow" then
			local titleHeight = 0
			if not eleData.ignoreParentTitle and not dgsElementData[dgsElement].ignoreTitle then
				titleHeight = dgsElementData[dgsElement].titleHeight or 0
			end
			x,y = x+addPosX,y+addPosY
			y = y+titleHeight
		elseif dgsElementType[dgsElement] == "dgs-dxscrollpane" then
			local scrollbar = dgsElementData[dgsElement].scrollbars
			local scbThick = dgsElementData[dgsElement].scrollBarThick
			local size = dgsElementData[dgsElement].absSize
			local relSizX,relSizY = size[1]-(dgsElementData[scrollbar[1]].visible and scbThick or 0),size[2]-(dgsElementData[scrollbar[2]].visible and scbThick or 0)
			local maxSize = dgsElementData[dgsElement].maxChildSize
			local maxX,maxY = (maxSize[1]-relSizX),(maxSize[2]-relSizY)
			maxX,maxY = maxX > 0 and maxX or 0,maxY > 0 and maxY or 0
			x,y = x+addPosX,y+addPosY
			x,y = x-maxX*dgsElementData[scrollbar[2]].position*0.01,y-maxY*dgsElementData[scrollbar[1]].position*0.01
		else
			x,y = x+addPosX,y+addPosY
		end
		assert(startEle ~= dgsElement,"Find an infinite loop")
	until(not isElement(dgsElement) or (rndSuspend and dgsElementData[dgsElement].renderTarget_parent))
	return x,y
end

function dgsGetPosition(dgsElement,bool,includeParent,rndSuspend,includeSide)
	assert(dgsIsDxElement(dgsElement),"Bad argument @dgsGetPosition at argument 1, expect dgs-dxgui got "..dgsGetType(dgsElement))
	if includeParent then
		guielex,guieley = getParentLocation(dgsElement,rndSuspend,dgsElementData[dgsElement].absPos[1],dgsElementData[dgsElement].absPos[2],includeSide)
		if relative then
			return guielex/sW,guieley/sH
		else
			return guielex,guieley
		end
	else
		local pos = dgsElementData[dgsElement][bool and "rltPos" or "absPos"]
		if pos then
			return pos[1],pos[2]
		end
		return false
	end
end

function dgsSetPosition(dgsElement,x,y,bool,isCenterPosition)
	assert(dgsIsDxElement(dgsElement),"Bad argument @dgsSetPosition at argument 1, expect dgs-dxgui got "..dgsGetType(dgsElement))
	local bool = bool and true or false
	if isCenterPosition then
		local size = dgsElementData[dgsElement][bool and "rltSize" or "absSize"]
		calculateGuiPositionSize(dgsElement,x-size[1]/2,y-size[2],bool)
	else
		calculateGuiPositionSize(dgsElement,x,y,bool)
	end
	return true
end

function dgsGetSize(dgsElement,bool)
	assert(dgsIsDxElement(dgsElement),"Bad argument @dgsGetSize at argument 1, expect dgs-dxgui got "..dgsGetType(dgsElement))
	local size = dgsElementData[dgsElement][bool and "rltSize" or "absSize"]
	return size[1],size[2]
end

function dgsSetSize(dgsElement,x,y,bool)
	assert(dgsIsDxElement(dgsElement),"Bad argument @dgsSetSize at argument 1, expect dgs-dxgui got "..dgsGetType(dgsElement))
	calculateGuiPositionSize(dgsElement,_,_,_,x,y,bool or false)
	return true
end

function dgsAttachElements(dgsElement,attachTo,offsetX,offsetY,relativePos,offsetW,offsetH,relativeSize)
	assert(dgsIsDxElement(dgsElement),"Bad argument @dgsAttachElements at argument 1, expect dgs-dxgui got "..dgsGetType(dgsElement))
	assert(dgsIsDxElement(attachTo),"Bad argument @dgsAttachElements at argument 2, expect dgs-dxgui got "..dgsGetType(attachTo))
	assert(not dgsGetParent(dgsElement),"Bad argument @dgsAttachElements at argument 1, source dgs element shouldn't have a parent")
	dgsDetachElements(dgsElement)
	if not offsetW or not offsetH then
		local size = dgsElementData[dgsElement].absSize
		offsetW,offsetH = size[1],size[2]
		relativeSize = false
	end
	offsetX,offsetY = offsetX or 0,offsetY or 0
	local attachedTable = {attachTo,offsetX,offsetY,relativePos,offsetW,offsetH,relativeSize}
	local attachedBy = dgsElementData[attachTo].attachedBy
	table.insert(attachedBy,dgsElement)
	dgsSetData(attachTo,"attachedBy",attachedBy)
	dgsSetData(dgsElement,"attachedTo",attachedTable)
	local attachedTable = dgsElementData[dgsElement].attachedTo
	local absx,absy = dgsGetPosition(attachTo,false,true)
	local absw,absh = dgsElementData[attachTo].absSize[1],dgsElementData[attachTo].absSize[2]
	offsetX,offsetY = relativePos and absw*offsetX or offsetX, relativePos and absh*offsetY or offsetY
	offsetW,offsetH = relativeSize and absw*offsetW or offsetW, relativeSize and absh*offsetH or offsetH
	offsetW,offsetH = relativeSize and offsetW/sW or offsetW,relativeSize and offsetH/sH or offsetH
	local resX,resY = (absx+offsetX)/sW,(absy+offsetY)/sH
	calculateGuiPositionSize(dgsElement,resX,resY,relativePos,offsetW,offsetH,relativeSize)
	return true
end

function dgsElementIsAttached(dgsElement)
	assert(dgsIsDxElement(dgsElement),"Bad argument @dgsElementIsAttached at argument 1, expect dgs-dxgui got "..dgsGetType(dgsElement))
	return dgsElementData[dgsElement].attachedTo and true or false
end

function dgsDetachElements(dgsElement)
	assert(dgsIsDxElement(dgsElement),"Bad argument @dgsDetachElements at argument 1, expect dgs-dxgui got "..dgsGetType(dgsElement))
	local attachedTable = dgsElementData[dgsElement].attachedTo or {}
	if isElement(attachedTable[1]) then
		local attachedBy = dgsElementData[attachedTable[1]].attachedBy
		local id = tableFind(attachedBy or {},dgsElement)
		if id then
			table.remove(attachedBy,dgsElement)
		end
	end
	return dgsSetData(dgsElement,"attachedTo",false)
end

function dgsApplyVisible(parent,visible)
	for k,v in ipairs(ChildrenTable[parent] or {}) do
		dgsApplyVisible(v,visible)
	end
end

function dgsSetVisible(dgsEle,visible)
	assert(dgsIsDxElement(dgsEle),"Bad argument @dgsSetVisible at argument 1, expect a dgs-dxgui element got "..dgsGetType(dgsEle))
	if type(dgsEle) == "table" then
		local result = true
		for i=1,#dgsEle do
			local dEle = dgsEle[i]
			local originalVisible = dgsElementData[dEle].visible
			local visible = visible and true or false
			if visible == originalVisible then
				return true
			end
			dgsApplyVisible(dEle,visible)
			result = result and dgsSetData(dEle,"visible",visible)
		end
		return result
	else
		local originalVisible = dgsElementData[dgsEle].visible
		local visible = visible and true or false
		if visible == originalVisible then
			return true
		end
		dgsApplyVisible(dgsEle,visible)
		return dgsSetData(dgsEle,"visible",visible)
	end
end

function dgsGetVisible(dgsEle)
	assert(dgsIsDxElement(dgsEle),"Bad argument @dgsGetVisible at argument 1, expect a dgs-dxgui element got "..dgsGetType(dgsEle))
	return dgsElementData[dgsEle].visible
end

function dgsSetSide(dgsEle,side,topleft)
	assert(dgsIsDxElement(dgsEle),"Bad argument @dgsSetSide at argument 1, expect a dgs-dxgui element got "..dgsGetType(dgsEle))
	return dgsSetData(dgsEle,topleft and "tob" or "lor",side)
end

function dgsGetSide(dgsEle,topleft)
	assert(dgsIsDxElement(dgsEle),"Bad argument @dgsGetSide at argument 1, expect a dgs-dxgui element got "..dgsGetType(dgsEle))
	return dgsElementData[dgsEle][topleft and "tob" or "lor"]
end

function configPosSize(dgsElement,pos,size)
	local eleData = dgsElementData[dgsElement]
	local relt = eleData.relative
	local x,y,rltPos,w,h,rltSize
	if pos then
		if relt[1] then
			x,y = eleData.rltPos[1],eleData.rltPos[2]
			rltPos = relt[1]
		else
			x,y = eleData.absPos[1],eleData.absPos[2]
			rltPos = relt[1]
		end
	end
	if size then
		if relt[2] then
			w,h = eleData.rltSize[1],eleData.rltSize[2]
			rltSize = relt[1]
		else
			w,h = eleData.absSize[1],eleData.absSize[2]
			rltSize = relt[2]
		end
	end
	calculateGuiPositionSize(dgsElement,x,y,rltPos,w,h,rltSize)
end

function calculateGuiPositionSize(dgsElement,x,y,relativep,sx,sy,relatives,notrigger)
	local eleData = dgsElementData[dgsElement]
	eleData = eleData or {}
	local parent = dgsGetParent(dgsElement)
	local psx,psy = sW,sH
	local relt = eleData.relative or {relativep,relatives}
	local oldRelativePos,oldRelativeSize = relt[1],relt[2]
	local haveParent = isElement(parent)
	local titleOffset = 0
	if haveParent then
		local parentData = dgsElementData[parent]
		if dgsGetType(parent) == "dgs-dxtab" then
			local tabpanel = parentData.parent
			local size = dgsElementData[tabpanel].absSize
			psx,psy = size[1],size[2]
			local height = dgsElementData[tabpanel].tabHeight[2] and dgsElementData[tabpanel].tabHeight[1]*psy or dgsElementData[tabpanel].tabHeight[1]
			psy = psy-height
		else
			local size = parentData.absSize or parentData.resolution
			psx,psy = size[1],size[2]
		end
		if eleData.ignoreParentTitle or parentData.ignoreTitle then
			titleOffset = 0
		else
			titleOffset = parentData.titleHeight or 0
		end
	end
	if x and y then
		local absPos = eleData.absPos or {}
		local oldPosAbsx,oldPosAbsy = absPos[1],absPos[2]
		local rltPos = eleData.rltPos or {}
		local oldPosRltx,oldPosRlty = rltPos[1],rltPos[2]
		x,y = relativep and x*psx or x,relativep and y*psy or y
		local abx,aby,relatx,relaty = x,y,x/psx,y/psy
		if psx == 0 then
			relatx = 0
		end
		if psy == 0 then
			relaty = 0
		end
		dgsSetData(dgsElement,"absPos",{abx,aby})
		dgsSetData(dgsElement,"rltPos",{relatx,relaty})
		dgsSetData(dgsElement,"relative",{relativep,oldRelativeSize})
		if not notrigger then
			triggerEvent("onDgsPositionChange",dgsElement,oldPosAbsx,oldPosAbsy,oldPosRltx,oldPosRlty)
		end
	end
	if sx and sy then
		local absSize = eleData.absSize or {}
		local oldSizeAbsx,oldSizeAbsy = absSize[1],absSize[2]
		local rltSize = eleData.rltSize or {}
		local oldSizeRltx,oldSizeRlty = rltSize[1],rltSize[2]
		sx,sy = relatives and sx*psx or sx,relatives and sy*(psy-titleOffset) or sy
		local absx,absy,relatsx,relatsy = sx,sy,sx/psx,sy/(psy-titleOffset)
		if psx == 0 then
			relatsx = 0
		end
		if psy-titleOffset == 0 then
			relatsy = 0
		end
		dgsSetData(dgsElement,"absSize",{absx,absy})
		dgsSetData(dgsElement,"rltSize",{relatsx,relatsy})
		dgsSetData(dgsElement,"relative",{oldRelativePos,relatives})
		if not notrigger then
			triggerEvent("onDgsSizeChange",dgsElement,oldSizeAbsx,oldSizeAbsy,oldSizeRltx,oldSizeRlty)
		end
	end
	return true
end

function dgsSetAlpha(dgsEle,alpha,absolute)
	assert(dgsIsDxElement(dgsEle),"Bad argument @dgsSetAlpha at argument 1, expect a dgs-dxgui element got "..dgsGetType(dgsEle))
	assert(type(alpha) == "number","Bad argument @dgsSetAlpha at argument 2, expect a number got "..type(alpha))
	alpha = absolute and alpha/255 or alpha
	return dgsSetData(dgsEle,"alpha",(alpha > 1 and 1) or (alpha < 0 and 0) or alpha)
end

function dgsGetAlpha(dgsEle,absolute)
	assert(dgsIsDxElement(dgsEle),"Bad argument @dgsGetAlpha at argument 1, expect a dgs-dxgui element got "..dgsGetType(dgsEle))
	local alp = dgsElementData[dgsEle].alpha
	return absolute and alp*255 or alp
end

function dgsSetEnabled(dgsEle,enabled)
	assert(dgsIsDxElement(dgsEle),"Bad argument @dgsSetEnabled at argument 1, expect a dgs-dxgui element got "..dgsGetType(dgsEle))	
	assert(type(enabled) == "boolean","Bad argument @dgsSetEnabled at argument 2, expect a boolean element got "..type(enabled))	
	return dgsSetData(dgsEle,"enabled",enabled)
end

function dgsGetEnabled(dgsEle)
	assert(dgsIsDxElement(dgsEle),"Bad argument @dgsGetEnabled at argument 1, expect a dgs-dxgui element got "..dgsGetType(dgsEle))
	return dgsElementData[dgsEle].enabled
end

function dgsCreateFont(path,size,bold,quality)
	assert(type(path) == "string","Bad argument @dgsCreateFont at argument 1, expect a string got "..dgsGetType(path))
	sourceResource = sourceResource or getThisResource()
	if not string.find(path,":") then
		local resname = getResourceName(sourceResource)
		path = ":"..resname.."/"..path
	end
	assert(fileExists(path),"Bad argument @dgsCreateFont at argument 1,couldn't find such file '"..path.."'")
	return dxCreateFont(path,size,bold,quality)
end

function dgsSetFont(dgsEle,font)
	assert(dgsIsDxElement(dgsEle),"Bad argument @dgsSetFont at argument 1, expect a dgs-dxgui element got "..dgsGetType(dgsEle))
	if font then
		dgsSetData(dgsEle,"font",font)	
	end
end

function dgsGetFont(dgsEle)
	assert(dgsIsDxElement(dgsEle),"Bad argument @dgsGetFont at argument 1, expect a dgs-dxgui element got "..dgsGetType(dgsEle))
	return dgsElementData[dgsEle].font
end

function dgsSetText(dgsEle,text)
	assert(dgsIsDxElement(dgsEle),"Bad argument @dgsSetText at argument 1, expect a dgs-dxgui element got "..dgsGetType(dgsEle))
	return dgsSetData(dgsEle,"text",text)
end

function dgsGetText(dgsEle)
	assert(dgsIsDxElement(dgsEle),"Bad argument @dgsGetText at argument 1, expect a dgs-dxgui element got "..dgsGetType(dgsEle))
	local dxtype = dgsGetType(dgsEle)
	if dxtype == "dgs-dxmemo" then
		return dgsMemoGetPartOfText(dgsEle)
	else
		return dgsElementData[dgsEle].text
	end
end

function dgsSetPostGUI(dgsEle,state)
	assert(dgsIsDxElement(dgsEle),"Bad argument @dgsSetPostGUI at argument 1, expect a dgs-dxgui element got "..dgsGetType(dgsEle))
	return dgsSetProperty(dgsEle,"postGUI",state)
end

function dgsGetPostGUI(dgsEle)
	assert(dgsIsDxElement(dgsEle),"Bad argument @dgsGetPostGUI at argument 1, expect a dgs-dxgui element got "..dgsGetType(dgsEle))
	return dgsElementData[dgsEle].postGUI
end

function dgsSetShaderValue(...)
	return dxSetShaderValue(...)
end

function dgsSimulateClick(dgsGUI,button)
	local x,y = dgsGetPosition(dgsGUI,false)
	local sx,sy = dgsGetSize(dgsGUI,false)
	local x,y = x+sx*0.5,y+sy*0.5
	triggerEvent("onDgsMouseClick",dgsGUI,button,"down",x,y)
	triggerEvent("onDgsMouseClick",dgsGUI,button,"up",x,y)
end

addEventHandler("onDgsMouseClick",resourceRoot,function(button,state,x,y)
	if not isElement(source) then return end
	if state == "down" then
		triggerEvent("onDgsMouseClickDown",source,button,state,x,y)
	elseif state == "up" then
		triggerEvent("onDgsMouseClickUp",source,button,state,x,y)
	end
end)

addEvent("onDgsScrollBarScrollPositionChange",true)
addEventHandler("onDgsElementScroll",resourceRoot,function(scb,new,old)
	if dgsGetType(source) == "scrollbar" then
		triggerEvent("onDgsScrollBarScrollPositionChange",source,new,old)
	end
end)

addEvent("onDgsCursorMove",true)
addEventHandler("onDgsMouseMove",resourceRoot,function(...)
	triggerEvent("onDgsCursorMove",source,...)
end)

function dgsGetMouseEnterGUI()
	return MouseData.enter
end

function dgsGetMouseLeaveGUI()
	return MouseData.lastEnter
end

function dgsGetMouseClickGUI(button)
	if button == "left" then
		return MouseData.clickl
	elseif button == "middle" then
		return MouseData.clickm
	else
		return MouseData.clickr
	end
end

function dgsGetFocusedGUI()
	return MouseData.nowShow
end

function dgsGetScreenSize()
	return guiGetScreenSize()
end

function dgsSetInputEnabled(...)
	return guiSetInputEnabled(...)
end

function dgsGetInputEnabled(...)
	return guiGetInputEnabled(...)
end

function dgsSetInputMode(...)
	return guiSetInputMode(...)
end

function dgsGetInputMode(...)
	return guiGetInputMode(...)
end

function dgsGetBrowser(...)
	return ...
end

function GlobalEditMemoBlurCheck()
	local dxChild = source == GlobalEdit and dgsElementData[source].linkedDxEdit or dgsElementData[source].linkedDxMemo
	if isElement(dxChild) and MouseData.nowShow == dxChild then
		dgsBlur(dxChild)
	end
end
addEventHandler("onClientGUIBlur",GlobalEdit,GlobalEditMemoBlurCheck,false)
addEventHandler("onClientGUIBlur",GlobalMemo,GlobalEditMemoBlurCheck,false)

function dgsFocus(dgsEle)
	assert(dgsIsDxElement(dgsEle),"Bad argument @dgsFocus at argument 1, expect a dgs-dxgui element got "..dgsGetType(dgsEle))
	local lastFront = MouseData.nowShow
	MouseData.nowShow = dgsEle
	local eleType = dgsElementType[dgsEle]
	if eleType == "dgs-dxbrowser" then
		focusBrowser(dgsEle)
	elseif eleType == "dgs-dxedit" then
		MouseData.editCursor = true
		resetTimer(MouseData.EditMemoTimer)
		guiFocus(GlobalEdit)
		dgsElementData[GlobalEdit].linkedDxEdit = dgsEle
	elseif eleType == "dgs-dxmemo" then
		MouseData.editCursor = true
		resetTimer(MouseData.EditMemoTimer)
		guiFocus(GlobalMemo)
		dgsElementData[GlobalMemo].linkedDxMemo = dgsEle
	end
	triggerEvent("onDgsFocus",dgsEle,lastFront)
	MouseData.nowShow = dgsEle
	return true
end

function dgsBlur(dgsEle)
	if not dgsEle or not isElement(MouseData.nowShow) or dgsEle ~= MouseData.nowShow then return end
	if not dgsEle then
		dgsEle = MouseData.nowShow
	end
	local eleType = dgsElementType[dgsEle]
	if eleType == "dgs-dxbrowser" then
		focusBrowser()
	elseif eleType == "dgs-dxedit" then
		guiBlur(GlobalEdit)
		dgsElementData[GlobalEdit].linkedDxEdit = nil
	elseif eleType == "dgs-dxmemo" then
		guiBlur(GlobalMemo)
		dgsElementData[GlobalEdit].linkedDxMemo = nil
	end
	triggerEvent("onDgsBlur",dgsEle)
	MouseData.nowShow = nil
	return true
end

function dgsGetRootElement()
	return resourceRoot
end

function dgsGetCursorPosition(relativeElement,relative,forceOnScreen)
	if isCursorShowing() then
		if MouseData.intfaceHitElement and not forceOnScreen then
			local absX,absY = MouseData.dgsCursorPos[1],MouseData.dgsCursorPos[2]
			local resolution = dgsElementData[MouseData.intfaceHitElement].resolution
			if not relativeElement and not dgsIsDxElement(relativeElement) then
				if relative then
					return absX/resolution[1],absY/resolution[2]
				else
					return absX,absY
				end
			else
				local xPos,yPos = dgsGetGuiLocationOnScreen(relativeElement,false)
				local curX,curY = absX-xPos,absY-yPos
				local eleSize = dgsElementData[relativeElement].absSize
				if relative then
					return curX/eleSize[1],curY/eleSize[2]
				else
					return curX,curY
				end
			end
		else
			local rltX,rltY = getCursorPosition()
			if dgsIsDxElement(relativeElement) then
				local xPos,yPos = dgsGetGuiLocationOnScreen(relativeElement,false)
				local absX,absY = rltX*sW,rltY*sH
				local curX,curY = absX-xPos,absY-yPos
				local eleSize = dgsElementData[relativeElement].absSize
				if relative then
					return curX/eleSize[1],curY/eleSize[2]
				else
					return curX,curY
				end
			else
				if relative then
					return rltX,rltY
				else
					return rltX*sW,rltY*sH
				end
			end
		end
	end
end

function dgsSetDoubleClickInterval(interval)
	assert(type(interval) == "number","Bad argument @dgsSetDoubleClickInterval at argument 1, expect a number got "..type(interval))
	assert(interval >= 50,"Bad argument @dgsSetDoubleClickInterval at argument 1, interval is too short, minimum is 50")
	DoubleClick.Interval = interval
	return true
end

function dgsGetDoubleClickInterval()
	return DoubleClick.Interval
end
------------Move Scale Handler
function dgsAddMoveHandler(dgsElement,x,y,w,h,xRel,yRel,wRel,hRel,forceReplace)
	assert(dgsIsDxElement(dgsElement),"Bad Argument @dgsAddMoveHandler at argument 1, expect a dgs-dxgui got "..dgsGetType(dgsElement))
	local x,y,xRel,yRel = x or 0,y or 0,xRel ~= false and true,yRel ~= false and true
	local w,h,wRel,hRel = w or 1,h or 1,wRel ~= false and true,hRel ~= false and true
	local moveData = dgsElementData[dgsElement].moveHandlerData
	if not moveData or forceReplace then
		dgsSetData(dgsElement,"moveHandlerData",{x,y,w,h,xRel,yRel,wRel,hRel})
	end
end

function dgsRemoveMoveHandler(dgsElement)
	assert(dgsIsDxElement(dgsElement),"Bad Argument @dgsRemoveMoveHandler at argument 1, expect a dgs-dxgui got "..dgsGetType(dgsElement))
	local moveData = dgsElementData[dgsElement].moveHandlerData
	if moveData then
		dgsSetData(dgsElement,"moveHandlerData",nil)
	end
end

function dgsIsMoveHandled(dgsElement)
	assert(dgsIsDxElement(dgsElement),"Bad Argument @dgsIsMoveHandled at argument 1, expect a dgs-dxgui got "..dgsGetType(dgsElement))
	return dgsElementData[dgsElement].moveHandlerData and true or false
end

function dgsAddSizeHandler(dgsElement,left,right,top,bottom,leftRel,rightRel,topRel,bottomRel,forceReplace)
	assert(dgsIsDxElement(dgsElement),"Bad Argument @dgsAddSizeHandler at argument 1, expect a dgs-dxgui got "..dgsGetType(dgsElement))
	local left = left or 0
	local right = right or left
	local top = top or right
	local bottom = bottom or top
	local leftRel = leftRel ~= false and true
	local rightRel = rightRel ~= false and true
	local topRel = topRel ~= false and true
	local bottomRel = bottomRel ~= false and true
	local sizeData = dgsElementData[dgsElement].sizeHandlerData
	if not sizeData or forceReplace then
		dgsSetData(dgsElement,"sizeHandlerData",{left,right,top,bottom,leftRel,rightRel,topRel,bottomRel})
	end
end

function dgsRemoveSizeHandler(dgsElement)
	assert(dgsIsDxElement(dgsElement),"Bad Argument @dgsRemoveSizeHandler at argument 1, expect a dgs-dxgui got "..dgsGetType(dgsElement))
	local sizeData = dgsElementData[dgsElement].sizeHandlerData
	if sizeData then
		dgsSetData(dgsElement,"sizeHandlerData",nil)
	end
end

function dgsIsSizeHandled(dgsElement)
	assert(dgsIsDxElement(dgsElement),"Bad Argument @dgsIsSizeHandled at argument 1, expect a dgs-dxgui got "..dgsGetType(dgsElement))
	return dgsElementData[dgsElement].sizeHandlerData and true or false
end


------------Round Up Functions
defaultRoundUpPoints = 3
function dgsRoundUp(num,points)
	if points then
		assert(type(points) == "number","Bad Argument @dgsRoundUp at argument 2, expect a positive integer got "..dgsGetType(points))
		assert(points%1 == 0,"Bad Argument @dgsRoundUp at argument 2, expect a positive integer got float")
		assert(points > 0,"Bad Argument @dgsRoundUp at argument 2, expect a positive integer got "..points)
	end
	local points = points or defaultRoundUpPoints
	local s_num = tostring(num)
	local from,to = utf8.find(s_num,"%.")
	if from then
		local single = s_num:sub(from+points,from+points)
		local single = tonumber(single) or 0
		local a = s_num:sub(0,from+points-1)
		if single >= 5 then
			a = a+10^(-points+1)
		end
		return tonumber(a)
	end
	return num
end

function dgsGetRoundUpPoints()
	return defaultRoundUpPoints
end

function dgsSetRoundUpPoints(points)
	assert(type(points) == "number","Bad Argument @dgsSetRoundUpPoints at argument 1, expect a positive integer got "..dgsGetType(points))
	assert(points%1 == 0,"Bad Argument @dgsSetRoundUpPoints at argument 1, expect a positive integer got float")
	assert(points > 0,"Bad Argument @dgsSetRoundUpPoints at argument 1, expect a positive integer got 0")
	defaultRoundUpPoints = points
	return true
end

-------------------------

addEventHandler("onDgsCreate",root,function(theResource)
	dgsSetData(source,"lor","left")
	dgsSetData(source,"tob","top")
	dgsSetData(source,"visible",true)
	dgsSetData(source,"enabled",true)
	dgsSetData(source,"ignoreParentTitle",false,true)
	dgsSetData(source,"textRelative",false)
	dgsSetData(source,"alpha",1)
	dgsSetData(source,"hitoutofparent",false)
	dgsSetData(source,"PixelInt",true)
	dgsSetData(source,"functionRunBefore",true) --true : after render; false : before render
	dgsSetData(source,"disabledColor",styleSettings.disabledColor)
	dgsSetData(source,"disabledColorPercent",styleSettings.disabledColorPercent)
	dgsSetData(source,"postGUI",dgsRenderSetting.postGUI == nil and true or false)
	dgsSetData(source,"outline",false) --{side,width,color}
	dgsSetData(source,"changeOrder",styleSettings.changeOrder) --Change the order when "bring to front" or clicked
	dgsSetData(source,"attachedTo",false) --Attached To
	dgsSetData(source,"attachedBy",{}) --Attached By
	dgsSetData(source,"rndTmpData",{}) --Stop edit this property!
	dgsSetData(source,"enableFullEnterLeaveCheck",false)
	ChildrenTable[source] = ChildrenTable[source] or {}
	insertResource(theResource,source)
	local getPropagated = dgsElementType[source] == "dgs-dxwindow"
	addEventHandler("onDgsBlur",source,function()
		dgsElementData[this].isFocused = false
	end,getPropagated)

	addEventHandler("onDgsFocus",source,function()
		dgsElementData[this].isFocused = true
	end,getPropagated)
end,true)

function dgsClear(theType,res)
	if res == true then
		if not theType then
			for theRes,guiTable in pairs(boundResource) do
				for k,v in pairs(guiTable) do
					local ele = v
					guiTable[k] = ""
					if isElement(ele) then
						destroyElement(ele)
					end
				end
				boundResource[theRes] = nil
			end
			return true
		else
			for theRes,guiTable in pairs(boundResource) do
				local rubbishRecycle = {}
				local cnt = 1
				for k,v in pairs(guiTable) do
					local ele = v
					if dgsElementType[v] == theType then
						rubbishRecycle[cnt] = v
						cnt = cnt+1
						if isElement(ele) then
							destroyElement(ele)
						end
					end
				end
				for k,v in ipairs(rubbishRecycle) do
					boundResource[theRes][v] = nil
				end
			end
			return true
		end
	else
		local res = res or sourceResource
		if not theType then
			for k,v in pairs(boundResource[res]) do
				local ele = v
				boundResource[res][k] = ""
				if isElement(ele) then
					destroyElement(ele)
				end
			end
			boundResource[res] = nil
			return true
		else
			local rubbishRecycle = {}
			local cnt = 1
			for k,v in pairs(boundResource[res]) do
				local ele = v
				if dgsElementType[v] == theType then
					rubbishRecycle[cnt] = v
					cnt = cnt+1
					if isElement(ele) then
						destroyElement(ele)
					end
				end
			end
			for k,v in ipairs(rubbishRecycle) do
				boundResource[res][v] = nil
			end
			return true
		end
	end
	return false
end

----------------------------------Multi Language Support

function dgsTranslationTableExists(name)
	assert(type(name) == "string", "Bad argument @dgsTranslationTableExists at argument 1, expect a string got "..dgsGetType(name))
	return LanguageTranslation[name] and true or false
end

function dgsSetTranslationTable(name,tab)
	assert(type(name) == "string", "Bad argument @dgsAddTranslationTable at argument 1, expect a string got "..dgsGetType(name))
	assert(type(tab) == "table" or not tab,"Bad argument @dgsAddTranslationTable at argument 2, expect a table/nil got "..dgsGetType(tab))
	if tab then
		LanguageTranslation[name] = tab
		LanguageTranslationAttach[name] = LanguageTranslationAttach[name] or {}
		dgsApplyLanguageChange(name,LanguageTranslation[name],LanguageTranslationAttach[name])
	elseif translationTableExists(name) then
		LanguageTranslation[name] = false
		for k,v in ipairs(LanguageTranslationAttach[name]) do
			dgsSetData(v,"_translang",nil)
		end
		LanguageTranslation[name] = nil
		LanguageTranslationAttach[name] = nil
	end
	return true
end

function dgsAttachToTranslation(dgsEle,name)
	assert(dgsIsDxElement(dgsEle),"Bad argument @dgsAttachToTranslation at argument 1, expect a dgs-dxgui element got "..dgsGetType(dgsEle))
	local lastTrans = dgsElementData[dgsEle]._translang
	if lastTrans and LanguageTranslationAttach[lastTrans] then
		local id = tableFind(LanguageTranslationAttach[name])
		if id then
			table.remove(LanguageTranslationAttach[name])
		end
	end
	dgsSetData(dgsEle,"_translang",name)
	if LanguageTranslation[name] then
		LanguageTranslationAttach[name] = LanguageTranslationAttach[name] or {}
		table.insert(LanguageTranslationAttach[name],dgsEle)
	end
end

function dgsDetachFromTranslation(dgsEle)
	assert(dgsIsDxElement(dgsEle),"Bad argument @dgsDetachFromTranslation at argument 1, expect a dgs-dxgui element got "..dgsGetType(dgsEle))
	local lastTrans = dgsElementData[dgsEle]._translang
	if lastTrans and LanguageTranslationAttach[lastTrans] then
		local id = tableFind(LanguageTranslationAttach[name])
		if id then
			table.remove(LanguageTranslationAttach[name])
		end
	end
	dgsSetData(dgsEle,"_translang",nil)
end

function dgsSetAttachTranslation(name)
	resourceTranslation[sourceResource or getThisResource()] = name
	return true
end

function dgsGetTranslationName(dgsEle)
	assert(dgsIsDxElement(dgsEle),"Bad argument @dgsGetTranslationName at argument 1, expect a dgs-dxgui element got "..dgsGetType(dgsEle))
	return dgsElementData[dgsEle]._translang
end

--------------Translation Interior
LanguageTranslationSupport = {
	"dgs-dx3dtext",
	"dgs-dxarrowlist",
	"dgs-dxbutton",
	"dgs-dxgridlist",
	"dgs-dxradiobutton",
	"dgs-dxcheckbox",
	"dgs-dxlabel",
	"dgs-dxwindow",
	"dgs-dxtab",
	"dgs-dxcombobox",
	"dgs-dxcombobox-Box",
}
function dgsTranslate(dgsEle,textTable,sourceResource)
	assert(dgsIsDxElement(dgsEle),"Bad argument @dgsTranslate at argument 1, expect a dgs-dxgui element got "..dgsGetType(dgsEle))
	if type(textTable) == "table" then
		local translation = dgsElementData[dgsEle]._translang or resourceTranslation[sourceResource or getThisResource()]
		local value = translation and LanguageTranslation[translation] and LanguageTranslation[translation][textTable[1]] or textTable[1]
		local count = 2
		while true do
			if not textTable[count] then break end
			local _value = value:gsub("%%rep%%",textTable[count])
			if _value == value then break end
			count = count+1
			value = _value
		end
		return value
	end
	return false
end

function dgsApplyLanguageChange(name,translation,attach)
	for k,v in ipairs(attach) do
		if isElement(v) then
			local dgsType = dgsGetType(v)
			if dgsType == "dgs-dxgridlist" then
				local columnData = dgsElementData[v].columnData
				for i,col in ipairs(columnData) do
					if col._translationText then
						local text = col._translationText
						if text then
							columnData[i][1] = dgsTranslate(v,text,sourceResource)
						end
					end
				end
				dgsSetData(v,"columnData",columnData)
				local rowData = dgsElementData[v].rowData
				for _r,row in ipairs(rowData) do
					for _c,item in ipairs(row) do
						if item._translationText then
							local text = item._translationText
							if text then
								rowData[_r][_c][1] = dgsTranslate(v,text,sourceResource)
							end
						end
					end
				end
				dgsSetData(v,"rowData",rowData)
			elseif dgsType == "dgs-dxarrowlist" then
				local itemData = dgsElementData[v].itemData
				for i,item in ipairs(itemData) do
					local text = itemData[i]._translationText
					if text then
						itemData[i][1] = dgsTranslate(v,text,sourceResource)
					end
				end
				dgsSetData(v,"itemData",itemData)
			elseif dgsType == "dgs-dxcombobox" then
				local text = dgsElementData[v]._translationText
				if text then
					dgsComboBoxSetCaptionText(v,text)
				end
				local itemData = dgsElementData[v].itemData
				for i,item in ipairs(itemData) do
					local text = itemData[i]._translationText
					if text then
						itemData[i][1] = dgsTranslate(v,text,sourceResource)
					end
				end
				dgsSetData(v,"itemData",itemData)
			elseif dgsType == "dgs-dxswitchbutton" then
				local textOn = dgsElementData[v]._translationtextOn
				local textOff = dgsElementData[v]._translationtextOff
				dgsSwitchButtonSetText(v,textOn,textOff)
			else
				local text = dgsElementData[v]._translationText
				if text then
					dgsSetData(v,"text",text)
				end
			end
		end
	end
end