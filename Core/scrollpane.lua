function dgsCreateScrollPane(x,y,sx,sy,relative,parent)
	assert(tonumber(x),"Bad argument @dgsCreateScrollPane at argument 1, expect number got "..type(x))
	assert(tonumber(y),"Bad argument @dgsCreateScrollPane at argument 2, expect number got "..type(y))
	assert(tonumber(sx),"Bad argument @dgsCreateScrollPane at argument 3, expect number got "..type(sx))
	assert(tonumber(sy),"Bad argument @dgsCreateScrollPane at argument 4, expect number got "..type(sy))
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"Bad argument @dgsCreateScrollPane at argument 6, expect dgs-dxgui got "..dgsGetType(parent))
	end
	local scrollpane = createElement("dgs-dxscrollpane")
	local _ = dgsIsDxElement(parent) and dgsSetParent(scrollpane,parent,true,true) or table.insert(CenterFatherTable,1,scrollpane)
	dgsSetType(scrollpane,"dgs-dxscrollpane")
	dgsSetData(scrollpane,"renderBuffer",{})
	local scbThick = styleSettings.scrollpane.scrollBarThick
	dgsSetData(scrollpane,"scrollBarThick",scbThick,true)
	calculateGuiPositionSize(scrollpane,x,y,relative or false,sx,sy,relative or false,true)
	local sx,sy = dgsElementData[scrollpane].absSize[1],dgsElementData[scrollpane].absSize[2]
	local x,y = dgsElementData[scrollpane].absPos[1],dgsElementData[scrollpane].absPos[2]
	local renderTarget = dxCreateRenderTarget(sx,sy,true)
	dgsSetData(scrollpane,"renderTarget_parent",renderTarget)
	dgsSetData(scrollpane,"maxChildSize",{0,0})
	dgsSetData(scrollpane,"scrollBarState",{nil,nil},true) --true: force on; false: force off; nil: auto
	dgsSetData(scrollpane,"configNextFrame",false)
	dgsSetData(scrollpane,"mouseWheelScrollBar",false) --false:vertical; true:horizontal
	local titleOffset = 0
	if isElement(parent) then
		if not dgsElementData[scrollpane].ignoreParentTitle and not dgsElementData[parent].ignoreTitle then
			titleOffset = dgsElementData[parent].titleHeight or 0
		end
	end
	local scrollbar1 = dgsCreateScrollBar(x+sx-scbThick,y-titleOffset,scbThick,sy-scbThick,false,false,parent)
	local scrollbar2 = dgsCreateScrollBar(x,y+sy-scbThick-titleOffset,sx-scbThick,scbThick,true,false,parent)
	
	dgsSetVisible(scrollbar1,false)
	dgsSetVisible(scrollbar2,false)
	dgsSetData(scrollbar1,"length",{0,true})
	dgsSetData(scrollbar2,"length",{0,true})
	dgsSetData(scrollpane,"scrollbars",{scrollbar1,scrollbar2})
	dgsSetData(scrollbar1,"attachedToParent",scrollpane)
	dgsSetData(scrollbar2,"attachedToParent",scrollpane)
	dgsSetData(scrollbar1,"hitoutofparent",true)
	dgsSetData(scrollbar2,"hitoutofparent",true)
	dgsSetData(scrollbar1,"scrollType","Vertical")
	dgsSetData(scrollbar2,"scrollType","Horizontal")
	dgsSetData(scrollbar1,"multiplier",{1,true})
	dgsSetData(scrollbar2,"multiplier",{1,true})
	triggerEvent("onDgsCreate",scrollpane)
	if not isElement(renderTarget) then
		destroyElement(scrollpane)
		return false
	end
	return scrollpane
end

addEventHandler("onDgsCreate",root,function()
	local parent = dgsGetParent(source)
	if isElement(parent) and dgsGetType(parent) == "dgs-dxscrollpane" then
		local relativePos,relativeSize = dgsElementData[source].relative[1],dgsElementData[source].relative[2]
		local x,y,sx,sy
		if relativePos then
			x,y = dgsElementData[source].rltPos[1],dgsElementData[source].rltPos[2]
		end
		if relativeSize then
			sx,sy = dgsElementData[source].rltSize[1],dgsElementData[source].rltSize[2]
		end
		calculateGuiPositionSize(source,x,y,relativePos or _,sx,sy,relativeSize or _)
		local sx,sy = dgsElementData[source].absSize[1],dgsElementData[source].absSize[2]
		local x,y = dgsElementData[source].absPos[1],dgsElementData[source].absPos[2]
		local maxSize = dgsElementData[parent].maxChildSize
		local tempx,tempy = x+sx,y+sy
		local ntempx,ntempy
		if maxSize[1] <= tempx then
			ntempx = 0
			for k,v in ipairs(dgsGetChildren(parent)) do
				local pos = dgsElementData[source].absPos
				local size = dgsElementData[source].absSize
				ntempx = ntempx > pos[1]+size[1] and ntempx or pos[1]+size[1]
			end
		end
		if maxSize[2] <= tempy then
			ntempy = 0
			for k,v in ipairs(dgsGetChildren(parent)) do
				local pos = dgsElementData[source].absPos
				local size = dgsElementData[source].absSize
				ntempy = ntempy > pos[2]+size[2] and ntempy or pos[2]+size[2]	
			end
		end
		dgsSetData(parent,"maxChildSize",{ntempx or maxSize[1],ntempy or maxSize[2]})
		dgsSetData(parent,"configNextFrame",true)
	end
end)

addEventHandler("onDgsDestroy",root,function()
	local parent = dgsGetParent(source)
	if isElement(parent) then
		if dgsGetType(parent) == "dgs-dxscrollpane" then
			local sx,sy = dgsElementData[source].absSize[1],dgsElementData[source].absSize[2]
			local x,y = dgsElementData[source].absPos[1],dgsElementData[source].absPos[2]
			local maxSize = dgsElementData[parent].maxChildSize
			local tempx,tempy = x+sx,y+sy
			local ntempx,ntempy
			if maxSize[1]-10 <= tempx then
				ntempx = 0
				for k,v in ipairs(dgsGetChildren(parent)) do
					if v ~= source then
						local pos = dgsElementData[v].absPos
						local size = dgsElementData[v].absSize
						ntempx = ntempx > pos[1]+size[1] and ntempx or pos[1]+size[1]
					end
				end
			end
			if maxSize[2]-10 <= tempy then
				ntempy = 0
				for k,v in ipairs(dgsGetChildren(parent)) do
					if v ~= source then
						local pos = dgsElementData[v].absPos
						local size = dgsElementData[v].absSize
						ntempy = ntempy > pos[2]+size[2] and ntempy or pos[2]+size[2]
					end
				end	
			end
			dgsSetData(parent,"maxChildSize",{ntempx or maxSize[1],ntempy or maxSize[2]})
			dgsSetData(parent,"configNextFrame",true)
		end
	end
end)

function configScrollPane(source)
	local scrollbar = dgsElementData[source].scrollbars
	local sx,sy = dgsElementData[source].absSize[1],dgsElementData[source].absSize[2]
	local x,y = dgsElementData[source].absPos[1],dgsElementData[source].absPos[2]
	local scbThick = dgsElementData[source].scrollBarThick
	local childBounding = dgsElementData[source].maxChildSize
	local scbStateV,scbStateH
	if childBounding[1] > sx then
		scbStateH = true
	elseif childBounding[1] < sx-scbThick then
		scbStateH = false
	end
	if childBounding[2] > sy then
		scbStateV = true
	elseif childBounding[2] < sy-scbThick then
		scbStateV = false
	end
	if scbStateH == nil then
		scbStateH = scbStateV
	end
	if scbStateV == nil then
		scbStateV = scbStateH
	end
	local forceState = dgsElementData[source].scrollBarState
	if forceState[1] ~= nil then
		scbStateV = forceState[1]
	end
	if forceState[2] ~= nil then
		scbStateH = forceState[2]
	end
	local scbThickV,scbThickH = scbStateV and scbThick or 0,scbStateH and scbThick or 0
	local relSizX,relSizY = sx-scbThickV,sy-scbThickH
	if scbStateH then
		dgsSetData(scrollbar[2],"position",0)
	end
	if scbStateV then
		dgsSetData(scrollbar[1],"position",0)
	end
	local parent = dgsGetParent(source)
	local titleOffset = 0
	if isElement(parent) then
		if not dgsElementData[source].ignoreParentTitle and not dgsElementData[parent].ignoreTitle then
			titleOffset = dgsElementData[parent].titleHeight or 0
		end
	end
	local scrollBarOffset = dgsElementData[source].scrollBarOffset
	dgsSetVisible(scrollbar[1],scbStateV and true or false)
	dgsSetVisible(scrollbar[2],scbStateH and true or false)
	dgsSetPosition(scrollbar[1],x+sx-scbThick,y-titleOffset,false)
	dgsSetPosition(scrollbar[2],x,y+sy-scbThick-titleOffset,false)
	dgsSetSize(scrollbar[1],scbThick,relSizY,false)
	dgsSetSize(scrollbar[2],relSizX,scbThick,false)
	local scroll1 = dgsElementData[scrollbar[1]].position
	local scroll2 = dgsElementData[scrollbar[2]].position
	local lengthVertical = relSizY/childBounding[2]
	local lengthHorizontal = relSizX/childBounding[1]
	lengthVertical = lengthVertical < 1 and lengthVertical or 1
	lengthHorizontal = lengthHorizontal < 1 and lengthHorizontal or 1
	dgsSetEnabled(scrollbar[1],lengthVertical ~= 1 and true or false)
	dgsSetEnabled(scrollbar[2],lengthHorizontal  ~= 1 and true or false)
	dgsSetData(scrollbar[1],"length",{lengthVertical,true})
	dgsSetData(scrollbar[2],"length",{lengthHorizontal,true})
	local renderTarget = dgsElementData[source].renderTarget_parent
	if isElement(renderTarget) then
		destroyElement(renderTarget)
	end
	local renderTarget = dxCreateRenderTarget(relSizX,relSizY,true)
	dgsSetData(source,"renderTarget_parent",renderTarget)
end

function sortScrollPane(source,parent)
	local sx,sy = dgsElementData[source].absSize[1],dgsElementData[source].absSize[2]
	local x,y = dgsElementData[source].absPos[1],dgsElementData[source].absPos[2]
	local maxSize = dgsElementData[parent].maxChildSize
	local tempx,tempy = x+sx,y+sy
	local ntempx,ntempy
	if maxSize[1] <= tempx then
		ntempx = tempx
	else
		ntempx = 0
		for k,v in ipairs(dgsGetChildren(parent)) do
			local pos = dgsElementData[v].absPos
			local size = dgsElementData[v].absSize
			ntempx = ntempx > pos[1]+size[1] and ntempx or pos[1]+size[1]
		end
	end
	if maxSize[2] <= tempy then
		ntempy = tempy
	else
		ntempy = 0
		for k,v in ipairs(dgsGetChildren(parent)) do
			local pos = dgsElementData[v].absPos
			local size = dgsElementData[v].absSize
			ntempy = ntempy > pos[2]+size[2] and ntempy or pos[2]+size[2]
		end
	end
	maxSize[1] = ntempx or maxSize[1]
	maxSize[2] = ntempy or maxSize[2]
	dgsSetData(parent,"maxChildSize",maxSize)
	dgsSetData(parent,"configNextFrame",true)
end

function dgsScrollPaneGetScrollBar(scrollpane)
	assert(dgsGetType(scrollpane) == "dgs-dxscrollpane","Bad argument @dgsScrollPaneGetScrollBar at at argument 1, expect dgs-dxscrollpane got "..dgsGetType(scrollpane))
	return dgsElementData[scrollpane].scrollbars
end

function dgsScrollPaneSetScrollPosition(scrollpane,vertical,horizontal)
	assert(dgsGetType(scrollpane) == "dgs-dxscrollpane","Bad argument @dgsScrollPaneSetScrollPosition at at argument 1, expect dgs-dxscrollpane got "..dgsGetType(scrollpane))
	assert(not vertical or (type(vertical) == "number" and vertical>= 0 and vertical <= 100),"Bad argument @dgsScrollPaneSetScrollPosition at at argument 2, expect nil, none or number∈[0,100] got "..dgsGetType(vertical).."("..tostring(vertical)..")")
	assert(not horizontal or (type(horizontal) == "number" and horizontal>= 0 and horizontal <= 100),"Bad argument @dgsScrollPaneSetScrollPosition at at argument 3,  expect nil, none or number∈[0,100] got "..dgsGetType(horizontal).."("..tostring(horizontal)..")")
	local scb = dgsElementData[scrollpane].scrollbars
	local state1,state2 = true,true
	if dgsElementData[scb[1]].visible then
		state1 = dgsScrollBarSetScrollPosition(scb[1],vertical)
	end
	if dgsElementData[scb[2]].visible then
		state2 = dgsScrollBarSetScrollPosition(scb[2],horizontal)
	end
	return state1 and state2
end

function dgsScrollPaneGetScrollPosition(scrollpane)
	assert(dgsGetType(scrollpane) == "dgs-dxscrollpane","Bad argument @dgsScrollPaneGetScrollPosition at at argument 1, expect dgs-dxscrollpane got "..dgsGetType(scrollpane))
	local scb = dgsElementData[scrollpane].scrollbars
	return dgsScrollBarGetScrollPosition(scb[1]),dgsScrollBarGetScrollPosition(scb[2])
end

function dgsScrollPaneSetScrollBarState(scrollpane,vertical,horizontal)
	assert(dgsGetType(scrollpane) == "dgs-dxscrollpane","Bad argument @dgsScrollPaneSetScrollBarState at at argument 1, expect dgs-dxscrollpane got "..dgsGetType(scrollpane))
	dgsSetData(scrollpane,"scrollBarState",{vertical,horizontal},true)
	dgsSetData(scrollpane,"configNextFrame",true)
	return true
end

function dgsScrollPaneGetScrollBarState(scrollpane)
	assert(dgsGetType(scrollpane) == "dgs-dxscrollpane","Bad argument @dgsScrollPaneSetScrollBarState at at argument 1, expect dgs-dxscrollpane got "..dgsGetType(scrollpane))
	return dgsElementData[scrollpane].scrollBarState[1],dgsElementData[scrollpane].scrollBarState[2]
end

addEventHandler("onDgsScrollBarScrollPositionChange",resourceRoot,function(new,old)
	local parent = dgsElementData[source].attachedToParent
	if parent and dgsGetType(parent) == "dgs-dxscrollpane" then
		local scrollbars = dgsElementData[parent].scrollbars
		local pos1,pos2 = dgsElementData[scrollbars[1]].position,dgsElementData[scrollbars[2]].position
		triggerEvent("onDgsScrollPaneScroll",parent,pos1,pos2)
	end
end)
