resourceDxGUI = {}
builtins = {}
builtins.Linear = true
builtins.InQuad = true
builtins.OutQuad = true
builtins.InOutQuad = true
builtins.OutInQuad = true
builtins.InElastic = true
builtins.OutElastic = true
builtins.InOutElastic = true
builtins.OutInElastic = true
builtins.InBack = true
builtins.OutBack = true
builtins.InOutBack = true
builtins.OutInBack = true
builtins.InBounce = true
builtins.OutBounce = true
builtins.InOutBounce = true
builtins.OutInBounce = true
builtins.SineCurve = true
builtins.CosineCurve = true
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

function insertResourceDxGUI(res,dgsElement)
	if res and isElement(dgsElement) then
		resourceDxGUI[res] = resourceDxGUI[res] or {}
		table.insert(resourceDxGUI[res],dgsElement)
		setElementData(dgsElement,"resource",res)
	end
end

addEventHandler("onClientResourceStop",root,function(res)
	local guiTable = resourceDxGUI[res]
	if guiTable then
		for k,v in pairs(guiTable) do
			local ele = v
			guiTable[k] = ""
			if isElement(ele) then
				destroyElement(ele)
			end
		end
		resourceDxGUI[res] = nil
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

function getParentLocation(dgsElement,rndsup,x,y)
	local dgsElement = FatherTable[dgsElement]
	if not isElement(dgsElement) or (rndsup and dgsElementData[dgsElement].renderTarget_parent) then return x,y end
	if dgsElementType[dgsElement] == "dgs-dxtab" then
		dgsElement = dgsElementData[dgsElement].parent
		local h = dgsElementData[dgsElement].absSize[2]
		local tabHeight = dgsElementData[dgsElement].tabHeight[2] and dgsElementData[dgsElement].tabHeight[1]*h or dgsElementData[dgsElement].tabHeight[1]
		x = x+dgsElementData[dgsElement].absPos[1]
		y = y+dgsElementData[dgsElement].absPos[2]+tabHeight
	else
		local absPos = dgsElementData[dgsElement].absPos or {0,0}
		x = x+absPos[1]
		y = y+absPos[2]
	end
	return getParentLocation(dgsElement,rndsup,x,y)
end

function dgsGetPosition(dgsElement,bool,includeParent,rndsupport)
	assert(dgsIsDxElement(dgsElement),"Bad argument @dgsGetPosition at argument 1, expect dgs-dxgui got "..dgsGetType(dgsElement))
	if includeParent then
		return dgsGetGuiLocationOnScreen(dgsElement,bool,rndsupport)
	else
		local pos = dgsElementData[dgsElement][bool and "rltPos" or "absPos"]
		return pos[1],pos[2]
	end
end

function dgsSetPosition(dgsElement,x,y,bool)
	assert(dgsIsDxElement(dgsElement),"Bad argument @dgsSetPosition at argument 1, expect dgs-dxgui got "..dgsGetType(dgsElement))
	calculateGuiPositionSize(dgsElement,x,y,bool or false)
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

function getType(thing)
	if isElement(thing) then
		return dgsGetType(thing)
	else
		return type(thing)
	end
end

function dgsApplyVisible(parent,visible)
	for k,v in pairs(ChildrenTable[parent] or {}) do
		if dgsElementType[v] == "dgs-dxedit" then
			local edit = dgsElementData[v].edit
			guiSetVisible(edit,visible)
		else
			dgsApplyVisible(v,visible)
		end
	end
end

function dgsSetVisible(dxgui,visible)
	assert(dgsIsDxElement(dxgui),"Bad argument @dgsSetVisible at argument 1, expect a dgs-dxgui element got "..dgsGetType(dxgui))
	local visible = visible and true or false
	if dgsGetType(dxgui) == "dgs-dxedit" then
		local edit = dgsElementData[dxgui].edit
		guiSetVisible(edit,visible)
	else
		dgsApplyVisible(dxgui,visible)
	end
	return dgsSetData(dxgui,"visible",visible)
end

function dgsGetVisible(dxgui)
	assert(dgsIsDxElement(dxgui),"Bad argument @dgsGetVisible at argument 1, expect a dgs-dxgui element got "..dgsGetType(dxgui))
	return dgsElementData[dxgui].visible
end

function dgsSetSide(dxgui,side,topleft)
	assert(dgsIsDxElement(dxgui),"Bad argument @dgsSetSide at argument 1, expect a dgs-dxgui element got "..dgsGetType(dxgui))
	return dgsSetData(dxgui,topleft and "tob" or "lor",side)
end

function dgsGetSide(dxgui,topleft)
	assert(dgsIsDxElement(dxgui),"Bad argument @dgsGetSide at argument 1, expect a dgs-dxgui element got "..dgsGetType(dxgui))
	return dgsElementData[dxgui][topleft and "tob" or "lor"]
end

function calculateGuiPositionSize(gui,x,y,relativep,sx,sy,relatives,notrigger)
	local eleData = dgsElementData[gui]
	eleData = eleData or {}
	local parent = dgsGetParent(gui)
	local px,py = 0,0
	local psx,psy = sW,sH
	local relt = eleData.relative or {relativep,relatives}
	local oldRelativePos,oldRelativeSize = relt[1],relt[2]
	local titleOffset = 0
	if isElement(parent) then
		local parentData = dgsElementData[parent]
		if dgsGetType(parent) == "dgs-dxtab" then
			local tabpanel = parentData.parent
			local size = dgsElementData[tabpanel].absSize
			psx,psy = size[1],size[2]
			local height = dgsElementData[tabpanel].tabHeight[2] and dgsElementData[tabpanel].tabHeight[1]*psx or dgsElementData[tabpanel].tabHeight[1]
			psy = psy-height
		else
			local size = parentData.absSize or parentData.size
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
		x,y = relativep and x*psx or x,relativep and y*(psy-titleOffset) or y
		local abx,aby,relatx,relaty = x,y+titleOffset,x/psx,y/(psy-titleOffset)
		if psx == 0 then
			relatx = 0
		end
		if psy-titleOffset == 0 then
			relaty = 0
		end
		dgsSetData(gui,"absPos",{abx,aby})
		dgsSetData(gui,"rltPos",{relatx,relaty})
		dgsSetData(gui,"relative",{relativep,oldRelativeSize})
		if not notrigger then
			triggerEvent("onDgsPositionChange",gui,oldPosAbsx,oldPosAbsy,oldPosRltx,oldPosRlty)
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
		dgsSetData(gui,"absSize",{absx,absy})
		dgsSetData(gui,"rltSize",{relatsx,relatsy})
		dgsSetData(gui,"relative",{oldRelativePos,relatives})
		if not notrigger then
			triggerEvent("onDgsSizeChange",gui,oldSizeAbsx,oldSizeAbsy,oldSizeRltx,oldSizeRlty)
		end
	end
	return true
end

function dgsSetAlpha(dxgui,alpha)
	assert(dgsIsDxElement(dxgui),"Bad argument @dgsSetAlpha at argument 1, expect a dgs-dxgui element got "..dgsGetType(dxgui))
	assert(type(alpha) == "number","Bad argument @dgsSetAlpha at argument 2, expect a number got "..type(alpha))
	return dgsSetData(dxgui,"alpha",(alpha > 1 and 1) or (alpha < 0 and 0) or alpha)
end

function dgsGetAlpha(dxgui)
	assert(dgsIsDxElement(dxgui),"Bad argument @dgsGetAlpha at argument 1, expect a dgs-dxgui element got "..dgsGetType(dxgui))
	return dgsGetData(dxgui,"alpha")
end

function dgsSetEnabled(dxgui,enabled)
	assert(dgsIsDxElement(dxgui),"Bad argument @dgsSetEnabled at argument 1, expect a dgs-dxgui element got "..dgsGetType(dxgui))	
	assert(type(enabled) == "boolean","Bad argument @dgsSetEnabled at argument 2, expect a boolean element got "..type(enabled))	
	return dgsSetData(dxgui,"enabled",enabled)
end

function dgsGetEnabled(dxgui)
	assert(dgsIsDxElement(dxgui),"Bad argument @dgsGetEnabled at argument 1, expect a dgs-dxgui element got "..dgsGetType(dxgui))
	return dgsGetData(dxgui,"enabled")
end

function dgsCreateFont(path,...)
	assert(type(path) == "string","Bad argument @dgsCreateFont at argument 1, expect string got "..type(path))
	if not fileExists(":"..getResourceName(getThisResource()).."/"..path) and not fileExists(path) then
		if not fileExists(path) then
			assert(false,"Bad argument @dgsCreateFont at argument 1,couldn't find such file '"..path.."'")
		end
		local filename = split(path,"/")
		fileCopy(path,":"..getResourceName(getThisResource()).."/"..filename[#filename])
		path = filename[#filename]
	end
	local font = dxCreateFont(path,...)
	return font
end

function dgsSetFont(dxgui,font)
	assert(dgsIsDxElement(dxgui),"Bad argument @dgsSetFont at argument 1, expect a dgs-dxgui element got "..dgsGetType(dxgui))
	if font then
		dgsSetData(dxgui,"font",font)	
	end
end

function dgsGetFont(dxgui)
	assert(dgsIsDxElement(dxgui),"Bad argument @dgsGetFont at argument 1, expect a dgs-dxgui element got "..dgsGetType(dxgui))
	if dgsIsDxElement(dxgui) then
		return dgsGetData(dxgui,"font")	
	end
end

function dgsSetText(dxgui,text)
	assert(dgsIsDxElement(dxgui),"Bad argument @dgsSetText at argument 1, expect a dgs-dxgui element got "..dgsGetType(dxgui))
	return dgsSetProperty(dxgui,"text",tostring(text))
end

function dgsGetText(dxgui)
	assert(dgsIsDxElement(dxgui),"Bad argument @dgsGetText at argument 1, expect a dgs-dxgui element got "..dgsGetType(dxgui))
	local dxtype = dgsGetType(dxgui)
	if dxtype == "dgs-dxmemo" then
		return dgsMemoGetPartOfText(dxgui)
	else
		return dgsElementData[dxgui].text
	end
end

function dgsSetPostGUI(dxgui,state)
	assert(dgsIsDxElement(dxgui),"Bad argument @dgsSetPostGUI at argument 1, expect a dgs-dxgui element got "..dgsGetType(dxgui))
	return dgsSetProperty(dxgui,"postGUI",state)
end

function dgsGetPostGUI(dxgui)
	assert(dgsIsDxElement(dxgui),"Bad argument @dgsGetPostGUI at argument 1, expect a dgs-dxgui element got "..dgsGetType(dxgui))
	return dgsElementData[dxgui].postGUI
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

function dgsGetRootElement()
	return resourceRoot
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

addEventHandler("onDgsCreate",root,function()
	dgsSetData(source,"lor","left")
	dgsSetData(source,"tob","top")
	dgsSetData(source,"visible",true)
	dgsSetData(source,"enabled",true)
	dgsSetData(source,"ignoreParentTitle",false)
	dgsSetData(source,"textRelative",false)
	dgsSetData(source,"alpha",1)
	dgsSetData(source,"hitoutofparent",false)
	dgsSetData(source,"PixelInt",true)
	dgsSetData(source,"functionRunBefore",true) --true : after render; false : before render
	dgsSetData(source,"disabledColor",styleSettings.disabledColor)
	dgsSetData(source,"disabledColorPercent",styleSettings.disabledColorPercent)
	dgsSetData(source,"postGUI",dgsRenderSetting.postGUI == nil and true or false)
	dgsSetData(source,"outline",false) --{side,width,color}
end)

function dgsClear(theType,res)
	if res == true then
		if not theType then
			for theRes,guiTable in pairs(resourceDxGUI) do
				for k,v in pairs(guiTable) do
					local ele = v
					guiTable[k] = ""
					if isElement(ele) then
						destroyElement(ele)
					end
				end
				resourceDxGUI[theRes] = nil
			end
			return true
		else
			for theRes,guiTable in pairs(resourceDxGUI) do
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
					resourceDxGUI[theRes][v] = nil
				end
			end
			return true
		end
	else
		local res = res or sourceResource
		if not theType then
			for k,v in pairs(resourceDxGUI[res]) do
				local ele = v
				resourceDxGUI[res][k] = ""
				if isElement(ele) then
					destroyElement(ele)
				end
			end
			resourceDxGUI[res] = nil
			return true
		else
			local rubbishRecycle = {}
			local cnt = 1
			for k,v in pairs(resourceDxGUI[res]) do
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
				resourceDxGUI[res][v] = nil
			end
			return true
		end
	end
	return false
end
