resourceTranslation = {}
LanguageTranslation = {}
LanguageTranslationAttach = {}
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

function getParentLocation(dgsElement,rndsup,x,y)
	local eleData
	local x,y = 0,0
	repeat
		eleData = dgsElementData[dgsElement]
		if dgsElementType[dgsElement] == "dgs-dxtab" then
			dgsElement = eleData.parent
			eleData = dgsElementData[dgsElement]
			local h = eleData.absSize[2]
			local tabHeight = eleData.tabHeight[2] and eleData.tabHeight[1]*h or eleData.tabHeight[1]
			x = x+eleData.absPos[1]
			y = y+eleData.absPos[2]+tabHeight
		else
			local absPos = eleData.absPos or {0,0}
			x = x+absPos[1]
			y = y+absPos[2]
		end
		dgsElement = FatherTable[dgsElement]
	until(not isElement(dgsElement) or (rndsup and dgsElementData[dgsElement].renderTarget_parent))
	return x,y
end

function dgsGetPosition(dgsElement,bool,includeParent,rndsupport)
	assert(dgsIsDxElement(dgsElement),"Bad argument @dgsGetPosition at argument 1, expect dgs-dxgui got "..dgsGetType(dgsElement))
	if includeParent then
		guielex,guieley = getParentLocation(dgsElement,rndsupport,dgsElementData[dgsElement].absPos[1],dgsElementData[dgsElement].absPos[2])
		if relative then
			return guielex/sW,guieley/sH
		else
			return guielex,guieley
		end
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

function dgsSetAlpha(dxgui,alpha,absolute)
	assert(dgsIsDxElement(dxgui),"Bad argument @dgsSetAlpha at argument 1, expect a dgs-dxgui element got "..dgsGetType(dxgui))
	assert(type(alpha) == "number","Bad argument @dgsSetAlpha at argument 2, expect a number got "..type(alpha))
	alpha = absolute and alpha/255 or alpha
	return dgsSetData(dxgui,"alpha",(alpha > 1 and 1) or (alpha < 0 and 0) or alpha)
end

function dgsGetAlpha(dxgui,absolute)
	assert(dgsIsDxElement(dxgui),"Bad argument @dgsGetAlpha at argument 1, expect a dgs-dxgui element got "..dgsGetType(dxgui))
	local alp = dgsElementData[dxgui].alpha
	return absolute and alp*255 or alp
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
	return dgsSetData(dxgui,"text",text)
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

------------Move Scale Handler
function dgsAddMoveHandler(dgsElement,x,y,w,h,xRel,yRel,wRel,hRel,forceReplace)
	assert(dgsIsDxElement(dgsElement),"Bad Argument @dgsAddMoveHandler at argument 1, expect a dgs-dxgui got "..dgsGetType(dgsElement))
	local x,y,xRel,yRel = x or 0,y or 0,xRel ~= false and true,yRel ~= false and true
	local w,h,wRel,hRel = w or 0,h or 0,wRel ~= false and true,hRel ~= false and true
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
	dgsSetData(source,"changeOrder",true) --Change the order when "bring to front" or clicked
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

function dgsAttachToTranslation(dxgui,name)
	assert(dgsIsDxElement(dxgui),"Bad argument @dgsAttachToTranslation at argument 1, expect a dgs-dxgui element got "..dgsGetType(dxgui))
	local lastTrans = dgsElementData[dxgui]._translang
	if lastTrans and LanguageTranslationAttach[lastTrans] then
		local id = table.find(LanguageTranslationAttach[name])
		if id then
			table.remove(LanguageTranslationAttach[name])
		end
	end
	dgsSetData(dxgui,"_translang",name)
	if LanguageTranslation[name] then
		LanguageTranslationAttach[name] = LanguageTranslationAttach[name] or {}
		table.insert(LanguageTranslationAttach[name],dxgui)
	end
end

function dgsDetachFromTranslation(dxgui)
	assert(dgsIsDxElement(dxgui),"Bad argument @dgsDetachFromTranslation at argument 1, expect a dgs-dxgui element got "..dgsGetType(dxgui))
	local lastTrans = dgsElementData[dxgui]._translang
	if lastTrans and LanguageTranslationAttach[lastTrans] then
		local id = table.find(LanguageTranslationAttach[name])
		if id then
			table.remove(LanguageTranslationAttach[name])
		end
	end
	dgsSetData(dxgui,"_translang",nil)
end

function dgsSetAttachTranslation(name)
	resourceTranslation[sourceResource or getThisResource()] = name
	return true
end

function dgsGetTranslationName(dxgui)
	assert(dgsIsDxElement(dxgui),"Bad argument @dgsGetTranslationName at argument 1, expect a dgs-dxgui element got "..dgsGetType(dxgui))
	return dgsElementData[dxgui]._translang
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
function dgsTranslate(dxgui,textTable,sourceResource)
	if type(textTable) == "table" then
		local translation = dgsElementData[dxgui]._translang or resourceTranslation[sourceResource or getThisResource()]
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
							columnData[i][1] = dgsTranslate(gridlist,text,sourceResource)
						end
					end
				end
				dgsSetData(gridlist,"columnData",columnData)
				local rowData = dgsElementData[v].rowData
				for _r,row in ipairs(rowData) do
					for _c,item in ipairs(row) do
						if item._translationText then
							local text = item._translationText
							if text then
								rowData[_r][_c][1] = dgsTranslate(gridlist,text,sourceResource)
							end
						end
					end
				end
				dgsSetData(gridlist,"rowData",rowData)
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