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
local value,setting = args[1],args[2];
]]
function addEasingFunction(name,str)
	assert(type(name) == "string","Bad at argument @addEasingFunction at argument 1, expected a string got "..type(name))
	assert(type(str) == "string","Bad at argument @addEasingFunction at argument 2, expected a string got "..type(str))
	assert(not builtins[name],"Bad at argument @addEasingFunction at argument 1, duplicated name with builtins ("..name..")")
	assert(not SelfEasing[name],"Bad at argument @addEasingFunction at argument 1, this name has been used ("..name..")")
	local str = SEInterface..str
	local fnc = loadstring(str)
	assert(type(fnc) == "function","Bad at argument @addEasingFunction at argument 2, failed to load the code")
	SelfEasing[name] = fnc
	return true
end

function removeEasingFunction(name)
	assert(type(name) == "string","Bad at argument @removeEasingFunction at argument 1, expected a string got "..type(name))
	if SelfEasing[name] then
		SelfEasing[name] = nil
		return true
	end
	return false
end

function easingFunctionExists(name)
	assert(type(name) == "string","Bad at argument @easingFunctionExists at argument 1, expected a string got "..type(name))
	return builtins[name] or (SelfEasing[name] and true)
end	

function insertResourceDxGUI(res,gui)
	if res and isElement(gui) then
		resourceDxGUI[res] = resourceDxGUI[res] or {}
		table.insert(resourceDxGUI[res],gui)
		setElementData(gui,"resource",res)
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

function dgsGetGuiLocationOnScreen(baba,relative,rndsup)
	if isElement(baba) then
		guielex,guieley = getParentLocation(baba,rndsup,dgsElementData[baba].absPos[1],dgsElementData[baba].absPos[2])
		if relative then
			return guielex/sW,guieley/sH
		else
			return guielex,guieley
		end
	end
	return false
end

function getParentLocation(baba,rndsup,x,y)
	local baba = FatherTable[baba]
	if not isElement(baba) or (rndsup and dgsElementData[baba].renderTarget_parent) then return x,y end
	if dgsElementType[baba] == "dgs-dxtab" then
		baba = dgsElementData[baba]["parent"]
		local h = dgsElementData[baba].absSize[2]
		local tabheight = dgsElementData[baba]["tabheight"][2] and dgsElementData[baba]["tabheight"][1]*h or dgsElementData[baba]["tabheight"][1]
		x = x+dgsElementData[baba].absPos[1]
		y = y+dgsElementData[baba].absPos[2]+tabheight
	else
		x = x+dgsElementData[baba].absPos[1]
		y = y+dgsElementData[baba].absPos[2]
	end
	return getParentLocation(baba,rndsup,x,y)
end

function dgsGetPosition(gui,bool,includeParent,rndsupport)
	assert(dgsIsDxElement(gui),"Bad argument @dgsGetPosition at argument 1, expect dgs-dxgui got "..dgsGetType(gui))
	if includeParent then
		return dgsGetGuiLocationOnScreen(gui,bool,rndsupport)
	else
		local pos = dgsElementData[gui][bool and "rltPos" or "absPos"]
		return pos[1],pos[2]
	end
end

function dgsSetPosition(gui,x,y,bool)
	if dgsIsDxElement(gui) then
		calculateGuiPositionSize(gui,x,y,bool or false)
		return true
	end
	return false,"not a dx-gui"
end

function dgsGetSize(gui,bool)
	assert(dgsIsDxElement(gui),"Bad argument @dgsGetSize at argument 1, expect dgs-dxgui got "..dgsGetType(gui))
	local size = dgsElementData[gui][bool and "rltSize" or "absSize"]
	return size[1],size[2]
end

function dgsSetSize(gui,x,y,bool)
	if dgsIsDxElement(gui) then
		calculateGuiPositionSize(gui,_,_,_,x,y,bool or false)
		return true
	end
	return false,"not a dx-gui"
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
			local edit = dgsElementData[v]["edit"]
			guiSetVisible(edit,visible)
		else
			dgsApplyVisible(v,visible)
		end
	end
end

function dgsSetVisible(dxgui,visible)
	assert(dgsIsDxElement(dxgui),"Bad argument @dgsSetVisible at argument 1, expect a dgs-dxgui element got "..dgsGetType(dxgui))
	if dgsGetType(dxgui) == "dgs-dxedit" then
		local edit = dgsElementData[dxgui].edit
		guiSetVisible(edit,visible)
	else
		dgsApplyVisible(dxgui,false)
	end
	return dgsSetData(dxgui,"visible",visible and true or false)
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
	dgsElementData[gui] = dgsElementData[gui] or {}
	local parent = dgsGetParent(gui)
	local px,py = 0,0
	local psx,psy = sW,sH
	local relt = dgsElementData[gui].relative or {relativep,relatives}
	local oldRelativePos,oldRelativeSize = relt[1],relt[2]
	local titleOffset = 0
	if isElement(parent) then
		if dgsGetType(parent) == "dgs-dxtab" then
			local tabpanel = dgsElementData[parent].parent
			local size = dgsElementData[tabpanel].absSize
			psx,psy = size[1],size[2]
			local height = dgsElementData[tabpanel].tabheight[2] and dgsElementData[tabpanel].tabheight[1]*psx or dgsElementData[tabpanel].tabheight[1]
			psy = psy-height
		else
			local size = dgsElementData[parent].absSize
			psx,psy = size[1],size[2]
		end
		if dgsElementData[gui].ignoreParentTitle or dgsElementData[parent].ignoreTitleSize then
			titleOffset = 0
		else
			titleOffset = dgsElementData[parent].titlesize or 0
		end
	end
	if x and y then
		local absPos = dgsElementData[gui].absPos or {}
		local oldPosAbsx,oldPosAbsy = absPos[1],absPos[2]
		local rltPos = dgsElementData[gui].rltPos or {}
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
		local absSize = dgsElementData[gui].absSize or {}
		local oldSizeAbsx,oldSizeAbsy = absSize[1],absSize[2]
		local rltSize = dgsElementData[gui].rltSize or {}
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

function dgsSetShaderValue(...)
	return dxSetShaderValue(...)
end

function simulationClick(dgsGUI,button)
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
	dgsSetData(source,"disabledColor",schemeColor.disabledColor)
	dgsSetData(source,"disabledColorPercent",schemeColor.disabledColorPercent)
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