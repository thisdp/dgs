resourceDxGUI ={}

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
	assert(dgsIsDxElement(gui),"@dgsGetPosition argument 1,expect dgs-dxgui got "..dgsGetType(gui))
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
	assert(dgsIsDxElement(gui),"@dgsGetSize argument 1,expect dgs-dxgui got "..dgsGetType(gui))
	return unpack(dgsElementData[gui][bool and "rltSize" or "absSize"])
end

function dgsSetSize(gui,x,y,bool)
	if dgsIsDxElement(gui) then
		calculateGuiPositionSize(gui,_,_,_,x,y,bool or false)
		return true
	end
	return false,"not a dx-gui"
end

function dgsDxGUISetProperty(dxgui,key,value,...)
	assert(dgsIsDxElement(dxgui),"@dgsDxGUISetProperty argument at 1,expect a dgs-dxgui element got "..dgsGetType(dxgui))
	if key == "functions" then
		value = {loadstring(value),{...}}
	elseif key == "textcolor" then
		if not tonumber(value) then
			assert(false,"@dgsDxGUISetProperty argument at 3,expect a number got "..type(value))
		end
	elseif key == "text" then
		if dgsGetType(dxgui) == "dgs-dxtab" then
			local tabpanel = dgsElementData[dxgui]["parent"]
			local font = dgsElementData[tabpanel]["font"]
			local wid = min(max(dxGetTextWidth(value,dgsElementData[dxgui]["textsize"][1],font),dgsElementData[tabpanel]["tabminwidth"]),dgsElementData[tabpanel]["tabmaxwidth"])
			local owid = dgsElementData[tab]["width"]
			dgsSetData(tabpanel,"allleng",dgsElementData[tabpanel]["allleng"]-owid+wid)
			dgsSetData(dxgui,"width",wid)
		end
	end
	return dgsSetData(dxgui,tostring(key),value)
end

function dgsDxGUIGetProperty(dxgui,key)
	assert(dgsIsDxElement(dxgui),"@dgsDxGUIGetProperty argument at 1,expect a dgs-dxgui element got "..dgsGetType(dxgui))
	if dgsElementData[dxgui] then
		return dgsElementData[dxgui][key]
	end
	return false
end

function getType(thing)
	if isElement(thing) then
		return dgsGetType(thing)
	else
		return type(thing)
	end
end

function dgsGUIApplyVisible(parent,visible)
	for k,v in pairs(ChildrenTable[parent] or {}) do
		if dgsElementType[v] == "dgs-dxedit" then
			local edit = dgsElementData[v]["edit"]
			guiSetVisible(edit,visible)
		else
			dgsGUIApplyVisible(v,visible)
		end
	end
end

function dgsDxGUISetVisible(dxgui,visible)
	assert(dgsIsDxElement(dxgui),"@dgsDxGUISetVisible argument at 1,expect a dgs-dxgui element got "..dgsGetType(dxgui))
	if dgsGetType(dxgui) == "dgs-dxedit" then
		local edit = dgsGetData(dxgui,"edit")
		guiSetVisible(edit,visible)
	else
		dgsGUIApplyVisible(dxgui,false)
	end
	return dgsSetData(dxgui,"visible",visible and true or false)
end

function dgsDxGUIGetVisible(dxgui)
	assert(dgsIsDxElement(dxgui),"@dgsDxGUIGetVisible argument at 1,expect a dgs-dxgui element got "..dgsGetType(dxgui))
	return dgsElementData[dxgui]["visible"]
end

function dgsDxGUISetSide(dxgui,side,topleft)
	if dgsIsDxElement(dxgui) then
		return dgsSetData(dxgui,topleft and "tob" or "lor",side)
	end
end

function dgsDxGUIGetSide(dxgui,topleft)
	if dgsIsDxElement(dxgui) then
		return dgsGetData(dxgui,topleft and "tob" or "lor")
	end
end

lastFront = false
function dgsDxGUIBringToFront(dxgui,mouse,dontMoveParent,dontChangeData)
	assert(dgsIsDxElement(dxgui),"@dgsDxGUIBringToFront argument at 1,expect a dgs-dxgui element got "..dgsGetType(dxgui))
	local parent = dgsGetParent(dxgui)
	if not dontChangeData then
		local oldShow = MouseData.nowShow
		MouseData.nowShow = dxgui
		if dgsGetType(dxgui) == "dgs-dxedit" then
			if mouse == "left" then
				MouseData.editCursor = true
				resetTimer(MouseData.EditTimer)
			else
				if oldShow ~= dxgui then
					MouseData.nowShow = oldShow	
				end
			end
		elseif dgsGetType(oldShow) == "dgs-dxedit" then
			local gui = guiCreateLabel(0,0,0,0,"",false)
			guiBringToFront(gui)
			destroyElement(gui)
		end
	end
	if not isElement(parent) then
		local id = table.find(MaxFatherTable,dxgui)
		if id then
			table.remove(MaxFatherTable,id)
			table.insert(MaxFatherTable,dxgui)
		end
	else
		local parents = dxgui
		while true do
			local uparents = dgsGetParent(parents)
			if isElement(uparents) then
				local children = dgsGetChildren(uparents)
				local id = table.find(children,parents)
				if id then
					table.remove(children,id)
					table.insert(children,parents)
					if dgsGetType(parents) == "dgs-dxscrollpane" then
						local scrollbar = dgsGetData(parents,"scrollbars")
						dgsDxGUIBringToFront(scrollbar[1],"left",_,true)
						dgsDxGUIBringToFront(scrollbar[2],"left",_,true)
					end
				end
				parents = uparents
			else
				local id = table.find(MaxFatherTable,parents)
				if id then
					table.remove(MaxFatherTable,id)
					table.insert(MaxFatherTable,parents)
					if dgsGetType(parents) == "dgs-dxscrollpane" then
						local scrollbar = dgsGetData(parents,"scrollbars")
						dgsDxGUIBringToFront(scrollbar[1],"left",_,true)
						dgsDxGUIBringToFront(scrollbar[2],"left",_,true)
					end
				end
				break
			end
			if dontMoveParent then
				break
			end
		end
	end
	if isElement(lastFront) and lastFront ~= dxgui then
		triggerEvent("onClientDgsDxBlur",lastFront,dxgui)
	end
	triggerEvent("onClientDgsDxFocus",dxgui,lastFront)
	lastFront = dxgui
	if mouse == "left" then
		MouseData.clickl = dxgui
		MouseData.clickData = nil
	elseif mouse == "right" then
		MouseData.clickr = dxgui
	end
	return true
end

function calculateGuiPositionSize(gui,x,y,relativep,sx,sy,relatives,notrigger)
	local parent = dgsGetParent(gui)
	local px,py = 0,0
	local psx,psy = sW,sH
	local oldRelativePos,oldRelativeSize = unpack(dgsElementData[gui].relative or {relativep,relatives})
	local titleOffset = 0
	if isElement(parent) then
		if dgsGetType(parent) == "dgs-dxtab" then
			local tabpanel = dgsElementData[parent]["parent"]
			psx,psy = unpack(dgsElementData[tabpanel].absSize)
			local height = dgsElementData[tabpanel]["tabheight"][2] and dgsElementData[tabpanel]["tabheight"][1]*psx or dgsElementData[tabpanel]["tabheight"][1]
			psy = psy-height
		else
			psx,psy = unpack(dgsElementData[parent].absSize)
		end
		if dgsElementData[gui].withoutTitle then
			titleOffset = dgsElementData[parent].titlesize or 0
		end
	end
	if x and y then
		local oldPosAbsx,oldPosAbsy = unpack(dgsElementData[gui].absPos or {})
		local oldPosRltx,oldPosRlty = unpack(dgsElementData[gui].rltPos or {})
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
			triggerEvent("onClientDgsDxGUIPositionChange",gui,oldPosAbsx,oldPosAbsy,oldPosRltx,oldPosRlty)
		end
	end
	if sx and sy then
		local oldSizeAbsx,oldSizeAbsy = unpack(dgsElementData[gui].absSize or {})
		local oldSizeRltx,oldSizeRlty = unpack(dgsElementData[gui].rltSize or {})
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
			triggerEvent("onClientDgsDxGUISizeChange",gui,oldSizeAbsx,oldSizeAbsy,oldSizeRltx,oldSizeRlty)
		end
	end
	return true
end

function dgsDxGUISetAlpha(dxgui,alpha)
	assert(dgsIsDxElement(dxgui),"@dgsDxGUISetAlpha argument at 1,expect a dgs-dxgui element got "..dgsGetType(dxgui))
	assert(type(alpha) == "number","@dgsDxGUISetAlpha argument at 2,expect a number got "..type(alpha))
	return dgsSetData(dxgui,"alpha",(alpha > 1 and 1) or (alpha < 0 and 0) or alpha)
end

function dgsDxGUIGetAlpha(dxgui)
	assert(dgsIsDxElement(dxgui),"@dgsDxGUIGetAlpha argument at 1,expect a dgs-dxgui element got "..dgsGetType(dxgui))
	return dgsGetData(dxgui,"alpha")
end

function dgsDxGUISetEnabled(dxgui,enabled)
	assert(dgsIsDxElement(dxgui),"@dgsDxGUISetEnabled argument at 1,expect a dgs-dxgui element got "..dgsGetType(dxgui))	
	assert(type(enabled) == "boolean","@dgsDxGUISetEnabled argument at 2,expect a boolean element got "..type(enabled))	
	return dgsSetData(dxgui,"enabled",enabled)
end

function dgsDxGUIGetEnabled(dxgui)
	assert(dgsIsDxElement(dxgui),"@dgsDxGUIGetEnabled argument at 1,expect a dgs-dxgui element got "..dgsGetType(dxgui))
	return dgsGetData(dxgui,"enabled")
end

function dgsDxGUICreateFont(path,clear)
	assert(type(path) == "string","@dgsDxGUICreateFont argument at 1,expect string got "..type(path))
	assert(type(clear) == "number","@dgsDxGUICreateFont argument at 2,expect number got "..type(clear))
	if not fileExists(":"..getResourceName(getThisResource()).."/"..path) and not fileExists(path) then
		if not fileExists(path) then
			assert(false,"@dgsDxGUICreateFont argument at 1,couldn't find such file '"..path.."'")
		end
		local filename = split(path,"/")
		fileCopy(path,":"..getResourceName(getThisResource()).."/"..filename[#filename])
		path = filename[#filename]
	end
	local font = dxCreateFont(path,clear)
	return font
end

function dgsDxGUISetFont(dxgui,font)
	assert(dgsIsDxElement(dxgui),"@dgsDxGUISetFont argument at 1,expect a dgs-dxgui element got "..dgsGetType(dxgui))
	if font then
		dgsSetData(dxgui,"font",font)	
	end
end

function dgsDxGUIGetFont(dxgui)
	assert(dgsIsDxElement(dxgui),"@dgsDxGUIGetFont argument at 1,expect a dgs-dxgui element got "..dgsGetType(dxgui))
	if dgsIsDxElement(dxgui) then
		return dgsGetData(dxgui,"font")	
	end
end

function dgsDxGUISetText(dxgui,text)
	assert(dgsIsDxElement(dxgui),"@dgsDxGUISetText argument at 1,expect a dgs-dxgui element got "..dgsGetType(dxgui))
	return dgsDxGUISetProperty(dxgui,"text",tostring(text))
end

function dgsDxGUIGetText(dxgui)
	assert(dgsIsDxElement(dxgui),"@dgsDxGUIGetText argument at 1,expect a dgs-dxgui element got "..dgsGetType(dxgui))
	return dgsGetData(dxgui,"text")
end

function dgsDxSetShaderValue(...)
	return dxSetShaderValue(...)
end

addEventHandler("onClientDgsDxGUIPreCreate",root,function()
	dgsSetData(source,"lor","left")
	dgsSetData(source,"tob","top")
	dgsSetData(source,"visible",true)
	dgsSetData(source,"enabled",true)
	dgsSetData(source,"withoutTitle",true)
	dgsSetData(source,"textRelative",false)
	dgsSetData(source,"alpha",1)
	dgsSetData(source,"hitoutofparent",false)
end)

function fromcolor(int)
	local a,r,g,b = getColorFromString(string.format("#%.8x",int))
	return r,g,b,a
end