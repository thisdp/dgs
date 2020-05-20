--Speed Up
local tableInsert = table.insert
local tableRemove = table.remove
local tableFind = table.find
local isElement = isElement
local assert = assert

BottomFatherTable = {}		--Store Bottom Father Element
CenterFatherTable = {}		--Store Center Father Element (Default)
TopFatherTable = {}			--Store Top Father Element
dx3DInterfaceTable = {}
dx3DTextTable = {}
FatherTable = {}			--Store Father Element
ChildrenTable = {}			--Store Children Element
LayerCastTable = {center=CenterFatherTable,top=TopFatherTable,bottom=BottomFatherTable}

function dgsSetLayer(dgsEle,layer,forceDetatch)
	assert(dgsIsDxElement(dgsEle),"Bad argument @dgsSetLayer at argument 1, expect a dgs-dgsEle element got "..dgsGetType(dgsEle))
	if dgsElementType[dgsEle] == "dgs-dxtab" then return false end
	assert(layer == "center" or layer == "top" or layer == "bottom","Bad argument @dgsSetLayer at argument 2, expect a string(top/center/bottom) got "..dgsGetType(layer))
	local hasParent = isElement(FatherTable[dgsEle])
	if hasParent and not forceDetatch then return false end
	if hasParent then
		local id = tableFind(ChildrenTable[FatherTable[dgsEle]],dgsEle)
		if id then
			tableRemove(ChildrenTable[FatherTable[dgsEle]],id)
		end
		FatherTable[dgsEle] = nil
	end
	local oldLayer = dgsElementData[dgsEle].alwaysOn or "center"
	if oldLayer == layer then return false end
	local id = tableFind(LayerCastTable[oldLayer],dgsEle)
	if id then
		tableRemove(LayerCastTable[oldLayer],id)
	end
	dgsSetData(dgsEle,"alwaysOn",layer == "center" and false or layer)
	tableInsert(LayerCastTable[layer],dgsEle)
	return true
end

function dgsGetLayer(dgsEle)
	assert(dgsIsDxElement(dgsEle),"Bad argument @dgsGetLayer at argument 1, expect a dgs-dgsEle element got "..dgsGetType(dgsEle))
	return dgsElementData[dgsEle].alwaysOn or "center"
end

function dgsSetCurrentLayerIndex(dgsEle,index)
	assert(dgsIsDxElement(dgsEle),"Bad argument @dgsSetCurrentLayerIndex at argument 1, expect a dgs-dgsEle element got "..dgsGetType(dgsEle))
	assert(type(index) == "number" ,"Bad argument @dgsSetCurrentLayerIndex at argument 2, expect a number got "..dgsGetType(index))
	local layer = dgsElementData[dgsEle].alwaysOn or "center"
	local hasParent = isElement(FatherTable[dgsEle])
	local theTable = hasParent and ChildrenTable[FatherTable[dgsEle]] or LayerCastTable[layer]
	local index = math.restrict(1,#theTable+1,index)
	local id = tableFind(theTable,dgsEle)
	if id then
		tableRemove(theTable,id)
	end
	tableInsert(theTable,index,dgsEle)
	return true
end

function dgsGetCurrentLayerIndex(dgsEle)
	assert(dgsIsDxElement(dgsEle),"Bad argument @dgsGetCurrentLayerIndex at argument 1, expect a dgs-dgsEle element got "..dgsGetType(dgsEle))
	local layer = dgsElementData[dgsEle].alwaysOn or "center"
	local hasParent = isElement(FatherTable[dgsEle])
	local theTable = hasParent and ChildrenTable[FatherTable[dgsEle]] or LayerCastTable[layer]
	return tableFind(theTable,dgsEle) or false
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
		local serialized = {}
		local cnt = 0
		for k,v in pairs(boundResource[res] or {}) do
			cnt = cnt+1
			serialized[cnt] = k
		end
		return serialized
	end
end

function dgsGetDxGUINoParent(alwaysBottom)
	return alwaysBottom and BottomFatherTable or CenterFatherTable
end

function dgsSetParent(child,parent,nocheckfather,noUpdatePosSize)
	assert(not dgsElementData[child] or not dgsElementData[child].attachTo, "Bad argument @dgsSetParent at argument 1, attached dgs element shouldn't have a parent")
	if isElement(child) then
		local _parent = FatherTable[child]
		local parentTable = isElement(_parent) and ChildrenTable[_parent] or CenterFatherTable
		if isElement(parent) then
			if not dgsIsDxElement(parent) then return end
			if not nocheckfather then
				local id = tableFind(parentTable,child)
				if id then
					tableRemove(parentTable,id)
				end
			end
			FatherTable[child] = parent
			ChildrenTable[parent] = ChildrenTable[parent] or {}
			tableInsert(ChildrenTable[parent],child)
		else
			local id = tableFind(parentTable,child)
			if id then
				tableRemove(parentTable,id)
			end
			FatherTable[id] = nil
			tableInsert(CenterFatherTable,child) 
		end
		setElementParent(child,parent)
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
		if dgsElementType[child] == "dgs-dxscrollpane" then
			local scrollbars = (dgsElementData[child] or {}).scrollbars
			if scrollbars then
				dgsSetParent(scrollbars[1],parent)
				dgsSetParent(scrollbars[2],parent)
				configScrollPane(child)
			end
		end
		return true
	end
	return false
end

function blurEditMemo()
	local dgsType = dgsGetType(MouseData.nowShow)
	if dgsType == "dgs-dxedit" then
		guiBlur(GlobalEdit)
	elseif dgsType == "dgs-dxmemo" then
		guiBlur(GlobalMemo)
	end
end

function dgsBringToFront(dgsEle,mouse,dontMoveParent,dontChangeData)
	assert(dgsIsDxElement(dgsEle),"Bad argument @dgsBringToFront at argument 1, expect a dgs-dgsEle element got "..dgsGetType(dgsEle))
	local parent = FatherTable[dgsEle]	--Get Parent
	local lastFront = MouseData.nowShow
	if not dontChangeData then
		MouseData.nowShow = dgsEle
		if dgsGetType(dgsEle) == "dgs-dxedit" then
			MouseData.editCursor = true
			resetTimer(MouseData.EditMemoTimer)
			guiFocus(GlobalEdit)
			dgsElementData[GlobalEdit].linkedDxEdit = dgsEle
		elseif dgsElementType[dgsEle] == "dgs-dxmemo" then
			MouseData.editCursor = true
			resetTimer(MouseData.EditMemoTimer)
			guiFocus(GlobalMemo)
			dgsElementData[GlobalMemo].linkedDxMemo = dgsEle
		elseif dgsEle ~= lastFront then
			local dgsType = dgsGetType(lastFront)
			if dgsType == "dgs-dxedit" then
				guiBlur(GlobalEdit)
			elseif dgsType == "dgs-dxmemo" then
				guiBlur(GlobalMemo)
			end
		end
		if isElement(lastFront) and dgsElementData[lastFront].clearSelection then
			dgsSetData(lastFront,"selectfrom",dgsElementData[lastFront].cursorpos)
		end
	end
	if dgsElementData[dgsEle].changeOrder then
		if not isElement(parent) then
			local layer = dgsElementData[dgsEle].alwaysOn or "center"
			local layerTable = LayerCastTable[layer]
			local id = tableFind(layerTable,dgsEle)
			if id then
				tableRemove(layerTable,id)
				tableInsert(layerTable,dgsEle)
			end
		else
			local parents = dgsEle
			while true do
				local uparents = FatherTable[parents]	--Get Parent
				if isElement(uparents) then
					local children = ChildrenTable[uparents]
					local id = tableFind(children,parents)
					if id then
						tableRemove(children,id)
						tableInsert(children,parents)
						if dgsElementType[parents] == "dgs-dxscrollpane" then
							local scrollbar = dgsElementData[parents].scrollbars
							dgsBringToFront(scrollbar[1],"left",_,true)
							dgsBringToFront(scrollbar[2],"left",_,true)
						end
					end
					parents = uparents
				else
					local id = tableFind(CenterFatherTable,parents)
					if id then
						tableRemove(CenterFatherTable,id)
						tableInsert(CenterFatherTable,parents)
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
	dgsFocus(dgsEle)
	lastFront = dgsEle
	if mouse == "left" then
		MouseData.clickl = dgsEle
		if MouseData.interfaceHit and MouseData.interfaceHit[5] then
			MouseData.lock3DInterface = MouseData.interfaceHit[5]
		end
		MouseData.clickData = nil
	elseif mouse == "right" then
		MouseData.clickr = dgsEle
	end
	return true
end

function dgsMoveToBack(dgsEle)
	assert(dgsIsDxElement(dgsEle),"Bad argument @dgsMoveToBack at argument 1, expect a dgs-dgsEle element got "..dgsGetType(dgsEle))
	if dgsElementData[dgsEle].changeOrder then
		local parent = FatherTable[dgsEle]	--Get Parent
		if isElement(parent) then
			local children = ChildrenTable[parent]
			local id = tableFind(children,dgsEle)
			if id then
				tableRemove(children,id)
				tableInsert(children,1,dgsEle)
				return true
			end
			return false
		else
			local layer = dgsElementData[dgsEle].alwaysOn or "center"
			local layerTable = LayerCastTable[layer]
			local id = tableFind(layerTable,dgsEle)
			if id then
				tableRemove(layerTable,id)
				tableInsert(layerTable,1,dgsEle)
				return true
			end
			return false
		end
	end
end