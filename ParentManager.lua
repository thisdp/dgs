BottomFatherTable = {}		--Store Bottom Father Element
CenterFatherTable = {}		--Store Center Father Element (Default)
TopFatherTable = {}			--Store Top Father Element
dx3DInterfaceTable = {}
dx3DTextTable = {}

FatherTable = {}			--Store Father Element
ChildrenTable = {}			--Store Children Element

LayerCastTable = {center=CenterFatherTable,top=TopFatherTable,bottom=BottomFatherTable}

function dgsSetLayer(dgsGUI,layer,forceDetatch)
	assert(dgsIsDxElement(dgsGUI),"Bad argument @dgsSetLayer at argument 1, expect a dgs-dxgui element got "..dgsGetType(dgsGUI))
	if dgsElementType[dgsGUI] == "dgs-dxtab" then return false end
	assert(layer == "center" or layer == "top" or layer == "bottom","Bad argument @dgsSetLayer at argument 2, expect a string(top/center/bottom) got "..dgsGetType(layer))
	local hasParent = isElement(FatherTable[dgsGUI])
	if hasParent and not forceDetatch then return false end
	if hasParent then
		local id = table.find(ChildrenTable[FatherTable[dgsGUI]],dgsGUI)
		if id then
			table.remove(ChildrenTable[FatherTable[dgsGUI]],id)
		end
		FatherTable[dgsGUI] = nil
	end
	local oldLayer = dgsElementData[dgsGUI].alwaysOn or "center"
	if oldLayer == layer then return false end
	local id = table.find(LayerCastTable[oldLayer],dgsGUI)
	if id then
		table.remove(LayerCastTable[oldLayer],id)
	end
	dgsSetData(dgsGUI,"alwaysOn",layer == "center" and false or layer)
	table.insert(LayerCastTable[layer],dgsGUI)
	return true
end

function dgsGetLayer(dgsGUI)
	assert(dgsIsDxElement(dgsGUI),"Bad argument @dgsGetLayer at argument 1, expect a dgs-dxgui element got "..dgsGetType(dgsGUI))
	return dgsElementData[dgsGUI].alwaysOn or "center"
end

function dgsSetCurrentLayerIndex(dgsGUI,index)
	assert(dgsIsDxElement(dgsGUI),"Bad argument @dgsSetCurrentLayerIndex at argument 1, expect a dgs-dxgui element got "..dgsGetType(dgsGUI))
	assert(type(index) == "number" ,"Bad argument @dgsSetCurrentLayerIndex at argument 2, expect a number got "..dgsGetType(index))
	local layer = dgsElementData[dgsGUI].alwaysOn or "center"
	local hasParent = isElement(FatherTable[dgsGUI])
	local theTable = hasParent and ChildrenTable[FatherTable[dgsGUI]] or LayerCastTable[layer]
	local index = math.restrict(1,#theTable+1,index)
	local id = table.find(theTable,dgsGUI)
	if id then
		table.remove(theTable,id)
	end
	table.insert(theTable,index,dgsGUI)
	return true
end

function dgsGetCurrentLayerIndex(dgsGUI)
	assert(dgsIsDxElement(dgsGUI),"Bad argument @dgsGetCurrentLayerIndex at argument 1, expect a dgs-dxgui element got "..dgsGetType(dgsGUI))
	local layer = dgsElementData[dgsGUI].alwaysOn or "center"
	local hasParent = isElement(FatherTable[dgsGUI])
	local theTable = hasParent and ChildrenTable[FatherTable[dgsGUI]] or LayerCastTable[layer]
	return table.find(theTable,dgsGUI) or false
end

function dgsGetLayerElements(layer)
	assert(layer == "center" or layer == "top" or layer == "bottom","Bad argument @dgsGetLayerElements at argument 1, expect a string(top/center/bottom) got "..dgsGetType(layer))
	return #LayerCastTable[layer] or false
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

function dgsSetParent(child,parent,nocheckfather,noUpdatePosSize)
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
		---Update Position and Size
		if not noUpdatePosSize then
			local rlt = dgsElementData[child].relative
			if rlt[1] then
				local pos = dgsElementData[child].rltPos
				calculateGuiPositionSize(child,pos[1],pos[2],true)
			else
				local pos = dgsElementData[child].absPos
				calculateGuiPositionSize(child,pos[1],pos[2],false)
			end
			if rlt[2] then
				local size = dgsElementData[child].rltSize
				calculateGuiPositionSize(child,_,_,_,size[1],size[2],true)
			else
				local size = dgsElementData[child].absSize
				calculateGuiPositionSize(child,_,_,_,size[1],size[2],false)
			end
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
	if not dontChangeData then
		local oldShow = MouseData.nowShow
		MouseData.nowShow = dxgui
		if dgsGetType(dxgui) == "dgs-dxedit" then
			MouseData.editCursor = true
			resetTimer(MouseData.EditTimer)
			local edit = dgsElementData[dxgui].edit
			guiBringToFront(edit)
		elseif dgsElementType[dxgui] == "dgs-dxmemo" then
			MouseData.editCursor = true
			resetTimer(MouseData.MemoTimer)
			local memo = dgsElementData[dxgui].memo
			guiBringToFront(memo)
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
	if dgsElementData[dxgui].changeOrder then
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
	end
	if isElement(lastFront) and lastFront ~= dxgui then
		triggerEvent("onDgsBlur",lastFront,dxgui)
	end
	triggerEvent("onDgsFocus",dxgui,lastFront)
	lastFront = dxgui
	if mouse == "left" then
		MouseData.clickl = dxgui
		if MouseData.interfaceHit and MouseData.interfaceHit[5] then
			MouseData.lock3DInterface = MouseData.interfaceHit[5]
		end
		MouseData.clickData = nil
	elseif mouse == "right" then
		MouseData.clickr = dxgui
	end
	return true
end
