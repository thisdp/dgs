BottomFatherTable = {}		--Store Bottom Father Element
CenterFatherTable = {}		--Store Center Father Element (Default)
TopFatherTable = {}			--Store Top Father Element

FatherTable = {}			--Store Father Element
ChildrenTable = {}			--Store Children Element

function dgsSetBottom(dgsGUI)
	assert(dgsIsDxElement(dgsGUI),"Bad argument @dgsSetBottom at argument 1, expect a dgs-dxgui element got "..dgsGetType(dgsGUI))
	local arrange = dgsElementData[dgsGUI].alwaysOn
	if arrange == "Bottom" then return false end
	if arrange == "Top" then
		local id = table.find(TopFatherTable,dgsGUI)
		if id then
			table.remove(TopFatherTable,id)
		end
	elseif not arrange then
		local id = table.find(CenterFatherTable,dgsGUI)
		if id then
			table.remove(CenterFatherTable,id)
		end
	end
	dgsSetData(dgsGUI,"alwaysOn","Bottom")
	table.insert(BottomFatherTable,dgsGUI)
end

function dgsSetTop(dgsGUI)
	assert(dgsIsDxElement(dgsGUI),"Bad argument @dgsSetTop at argument 1, expect a dgs-dxgui element got "..dgsGetType(dgsGUI))
	local arrange = dgsElementData[dgsGUI].alwaysOn
	if arrange == "Top" then return false end
	if arrange == "Bottom" then
		local id = table.find(BottomFatherTable,dgsGUI)
		if id then
			table.remove(BottomFatherTable,id)
		end
	elseif not arrange then
		local id = table.find(CenterFatherTable,dgsGUI)
		if id then
			table.remove(CenterFatherTable,id)
		end
	end
	dgsSetData(dgsGUI,"alwaysOn","Bottom")
	table.insert(TopFatherTable,dgsGUI)
end

function dgsSetCenter(dgsGUI)
	assert(dgsIsDxElement(dgsGUI),"Bad argument @dgsSetCenter at argument 1, expect a dgs-dxgui element got "..dgsGetType(dgsGUI))
	local arrange = dgsElementData[dgsGUI].alwaysOn
	if not arrange then return false end
	if arrange == "Bottom" then
		local id = table.find(BottomFatherTable,dgsGUI)
		if id then
			table.remove(BottomFatherTable,id)
		end
	elseif arrange == "Top" then
		local id = table.find(TopFatherTable,dgsGUI)
		if id then
			table.remove(TopFatherTable,id)
		end
	end
	dgsSetData(dgsGUI,"alwaysOn",false)
	table.insert(CenterFatherTable,dgsGUI)
end

function dgsGetChild(parent,id)
	return ChildrenTable[parent][id] or false
end

function dgsGetChildren(parent)
	return ChildrenTable[parent] or {}
end

function dgsGetParent(child)
	return FatherTable[child] or false
end

function dgsGetDxGUIFromResource(res)
	local res = res or sourceResource
	if res then
		return resourceDxGUI[res] or {}
	end
end

function dgsGetDxGUINoParent(alwaysBottom)
	return alwaysBottom and BottomFatherTable or CenterFatherTable
end

function dgsSetParent(child,parent,nocheckfather)
	if isElement(child) then
		local _parent = FatherTable[child]
		local parentTable = isElement(_parent) and ChildrenTable[_parent] or CenterFatherTable
		if isElement(parent) then
			if not dgsIsDxElement(parent) then return end
			if not nocheckfather then
				local id = table.find(parentTable,child)
				if id then
					table.remove(parentTable,id)
				end
			end
			FatherTable[child] = parent
			ChildrenTable[parent] = ChildrenTable[parent] or {}
			table.insert(ChildrenTable[parent],child)
		else
			local id = table.find(parentTable,child)
			if id then
				table.remove(parentTable,id)
			end
			FatherTable[id] = nil
			table.insert(CenterFatherTable,child) 
		end
		return true
	end
	return false
end

function blurEditMemo()
	local gui = guiCreateLabel(0,0,0,0,"",false)
	guiBringToFront(gui)
	destroyElement(gui)
end

lastFront = false
function dgsBringToFront(dxgui,mouse,dontMoveParent,dontChangeData)
	assert(dgsIsDxElement(dxgui),"Bad argument @dgsBringToFront at argument 1, expect a dgs-dxgui element got "..dgsGetType(dxgui))
	local parent = FatherTable[dxgui]	--Get Parent
	local mouse = mouse or "left"
	if not dontChangeData then
		local oldShow = MouseData.nowShow
		MouseData.nowShow = dxgui
		if dgsGetType(dxgui) == "dgs-dxedit" then
			MouseData.editCursor = true
			resetTimer(MouseData.EditTimer)
			local edit = dgsElementData[dxgui].edit
			guiBringToFront(edit)
		elseif dxgui ~= oldShow then
			local dgsType = dgsGetType(oldShow)
			if dgsType == "dgs-dxedit" or dgsType == "dgs-dxmemo" then
				blurEditMemo()
			end
		end
		if isElement(oldShow) and dgsElementData[oldShow].clearSelection then
			dgsSetData(oldShow,"selectfrom",dgsElementData[oldShow].cursorpos)
		end
	end
	if not isElement(parent) then
		local id = table.find(CenterFatherTable,dxgui)
		if id then
			table.remove(CenterFatherTable,id)
			table.insert(CenterFatherTable,dxgui)
		end
	else
		local parents = dxgui
		while true do
			local uparents = FatherTable[parents]	--Get Parent
			if isElement(uparents) then
				local children = ChildrenTable[uparents]
				local id = table.find(children,parents)
				if id then
					table.remove(children,id)
					table.insert(children,parents)
					if dgsElementType[parents] == "dgs-dxscrollpane" then
						local scrollbar = dgsElementData[parents].scrollbars
						dgsBringToFront(scrollbar[1],"left",_,true)
						dgsBringToFront(scrollbar[2],"left",_,true)
					end
				end
				parents = uparents
			else
				local id = table.find(CenterFatherTable,parents)
				if id then
					table.remove(CenterFatherTable,id)
					table.insert(CenterFatherTable,parents)
					if dgsElementType[parents] == "dgs-dxscrollpane" then
						local scrollbar = dgsElementData[parents].scrollbars
						dgsBringToFront(scrollbar[1],"left",_,true)
						dgsBringToFront(scrollbar[2],"left",_,true)
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
		triggerEvent("onDgsBlur",lastFront,dxgui)
	end
	triggerEvent("onDgsFocus",dxgui,lastFront)
	lastFront = dxgui
	if mouse == "left" then
		MouseData.clickl = dxgui
		MouseData.clickData = nil
	elseif mouse == "right" then
		MouseData.clickr = dxgui
	end
	return true
end