function dgsCreateScrollPane(x,y,sx,sy,relative,parent)
	assert(tonumber(x),"Bad argument @dgsCreateScrollPane at argument 1, expect number got "..type(x))
	assert(tonumber(y),"Bad argument @dgsCreateScrollPane at argument 2, expect number got "..type(y))
	assert(tonumber(sx),"Bad argument @dgsCreateScrollPane at argument 3, expect number got "..type(sx))
	assert(tonumber(sy),"Bad argument @dgsCreateScrollPane at argument 4, expect number got "..type(sy))
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"Bad argument @dgsCreateScrollPane at argument 6, expect dgs-dxgui got "..dgsGetType(parent))
	end
	local scrollpane = createElement("dgs-dxscrollpane")
	local _ = dgsIsDxElement(parent) and dgsSetParent(scrollpane,parent,true) or table.insert(CenterFatherTable,1,scrollpane)
	dgsSetType(scrollpane,"dgs-dxscrollpane")
	dgsSetData(scrollpane,"scrollBarThick",20,true)
	calculateGuiPositionSize(scrollpane,x,y,relative or false,sx,sy,relative or false,true)
	local sx,sy = dgsElementData[scrollpane].absSize
	local x,y = dgsElementData[scrollpane].absPos
	local renderTarget = dxCreateRenderTarget(sx,sy,true)
	dgsSetData(scrollpane,"renderTarget_parent",renderTarget)
	dgsSetData(scrollpane,"maxChildSize",{0,0})
	local scrbThick = 20
	local titleOffset = 0
	if isElement(parent) then
		if dgsElementData[scrollpane].withoutTitle then
			titleOffset = dgsElementData[parent].titlesize or 0
		end
	end
	local scrollbar1 = dgsCreateScrollBar(x+sx-scrbThick,y-titleOffset,scrbThick,sy-scrbThick,false,false,parent)
	local scrollbar2 = dgsCreateScrollBar(x,y+sy-scrbThick-titleOffset,sx-scrbThick,scrbThick,true,false,parent)
	dgsSetVisible(scrollbar1,false)
	dgsSetVisible(scrollbar2,false)
	dgsSetData(scrollbar1,"length",{0,true})
	dgsSetData(scrollbar2,"length",{0,true})
	dgsSetData(scrollpane,"scrollbars",{scrollbar1,scrollbar2})
	dgsSetData(scrollbar1,"parent_sp",scrollpane)
	dgsSetData(scrollbar2,"parent_sp",scrollpane)
	triggerEvent("onDgsCreate",scrollpane)
	return scrollpane
end

addEventHandler("onDgsCreate",root,function()
	local parent = dgsGetParent(source)
	if isElement(parent) and dgsGetType(parent) == "dgs-dxscrollpane" then
		local relativePos,relativeSize = unpack(dgsGetData(source,"relative"))
		local x,y,sx,sy
		if relativePos then
			x,y = unpack(dgsGetData(source,"rltPos"))
		end
		if relativeSize then
			sx,sy = unpack(dgsGetData(source,"rltSize"))
		end
		calculateGuiPositionSize(source,x,y,relativePos or _,sx,sy,relativeSize or _)
		local sx,sy = unpack(dgsGetData(source,"absSize"))
		local x,y = unpack(dgsGetData(source,"absPos"))
		local maxSize = dgsGetData(parent,"maxChildSize")
		local tempx,tempy = x+sx,y+sy
		local ntempx,ntempy
		if maxSize[1] <= tempx then
			ntempx = 0
			for k,v in ipairs(dgsGetChildren(parent)) do
				local pos = dgsGetData(source,"absPos")
				local size = dgsGetData(source,"absSize")
				ntempx = ntempx > pos[1]+size[1] and ntempx or pos[1]+size[1]
			end
		end
		if maxSize[2] <= tempy then
			ntempy = 0
			for k,v in ipairs(dgsGetChildren(parent)) do
				local pos = dgsGetData(source,"absPos")
				local size = dgsGetData(source,"absSize")
				ntempy = ntempy > pos[2]+size[2] and ntempy or pos[2]+size[2]	
			end
		end
		dgsSetData(parent,"maxChildSize",{ntempx or maxSize[1],ntempy or maxSize[2]})
		dgsScrollPaneUpdateScrollBar(parent,ntempx or maxSize[1],ntempy or maxSize[2])
		local renderTarget = dgsGetData(parent,"renderTarget_parent")
		if isElement(renderTarget) then
			destroyElement(renderTarget)
		end
		local scrbThick = dgsGetData(parent,"scrollBarThick")
		local scrollbar = dgsGetData(parent,"scrollbars")
		local xthick,ythick = 0,0
		if scrollbar then
			xthick = dgsGetVisible(scrollbar[1]) and scrbThick or 0
			ythick = dgsGetVisible(scrollbar[2]) and scrbThick or 0
		end
		local sx,sy = unpack(dgsGetData(parent,"absSize"))
		local renderTarget = dxCreateRenderTarget(sx-xthick,sy-ythick,true)
		dgsSetData(parent,"renderTarget_parent",renderTarget)
	end
end)

function dgsScrollPaneUpdateScrollBar(scrollpane,ntempx,ntempy)
	if dgsGetType(scrollpane) == "dgs-dxscrollpane" then
		local scrollbar = dgsGetData(scrollpane,"scrollbars")
		if isElement(scrollbar[1]) and isElement(scrollbar[2]) then
			local ntmpx,ntmpy = unpack(dgsGetData(scrollpane,"maxChildSize"))
			ntempx,ntempy = ntempx or ntmpx,ntempy or ntmpy
			local sx,sy = unpack(dgsGetData(scrollpane,"absSize"))
			local scbstate = {dgsGetVisible(scrollbar[1]),dgsGetVisible(scrollbar[2])}
			local scbThick = dgsGetData(scrollpane,"scrollBarThick")
			local xthick,ythick = scbstate[1] and scbThick or 0,scbstate[2] and scbThick or 0
			
			if ntempx then
				if ntempx > sx then
					dgsSetVisible(scrollbar[2],true)
				else
					dgsSetVisible(scrollbar[2],false)
				end
			end
			if ntempy then
				if ntempy > sy then
					dgsSetVisible(scrollbar[1],true)
				else
					dgsSetVisible(scrollbar[1],false)
				end
			end
		end
	end
end

addEventHandler("onDgsDestroy",root,function()
	local parent = dgsGetParent(source)
	if isElement(parent) then
		if dgsGetType(parent) == "dgs-dxscrollpane" then
			local x,y = unpack(dgsGetData(source,"absPos"))
			local sx,sy = unpack(dgsGetData(source,"absSize"))
			local maxSize = dgsGetData(parent,"maxChildSize")
			local tempx,tempy = x+sx,y+sy
			local ntempx,ntempy
			if maxSize[1]-10 <= tempx then
				ntempx = 0
				for k,v in ipairs(dgsGetChildren(parent)) do
					if v ~= source then
						local pos = dgsGetData(v,"absPos")
						local size = dgsGetData(v,"absSize")
						ntempx = ntempx > pos[1]+size[1] and ntempx or pos[1]+size[1]
					end
				end
			end
			if maxSize[2]-10 <= tempy then
				ntempy = 0
				for k,v in ipairs(dgsGetChildren(parent)) do
					if v ~= source then
						local pos = dgsGetData(v,"absPos")
						local size = dgsGetData(v,"absSize")
						ntempy = ntempy > pos[2]+size[2] and ntempy or pos[2]+size[2]
					end
				end	
			end
			dgsSetData(parent,"maxChildSize",{ntempx or maxSize[1],ntempy or maxSize[2]})
			dgsScrollPaneUpdateScrollBar(parent,ntempx or maxSize[1],ntempy or maxSize[2])
		end
	end
end)

function configScrollPane(source)
	local renderTarget = dgsGetData(source,"renderTarget_parent")
	if isElement(renderTarget) then
		destroyElement(renderTarget)
	end
	local sx,sy = unpack(dgsGetData(source,"absSize"))
	local x,y = unpack(dgsGetData(source,"absPos"))
	local scrbThick = dgsGetData(source,"scrollBarThick")
	local scrollbar = dgsGetData(source,"scrollbars")
	local xthick,ythick = 0,0
	dgsScrollPaneUpdateScrollBar(source)
	if scrollbar then
		local parent = dgsGetParent(source)
		local titleOffset = 0
		if isElement(parent) then
			if dgsGetData(source,"withoutTitle") then
				titleOffset = dgsGetData(parent,"titlesize") or 0
			end
		end
		xthick = dgsGetVisible(scrollbar[1]) and scrbThick or 0
		ythick = dgsGetVisible(scrollbar[2]) and scrbThick or 0
		dgsSetPosition(scrollbar[1],x+sx-scrbThick,y-titleOffset,false)
		dgsSetPosition(scrollbar[2],x,y+sy-scrbThick-titleOffset,false)
		dgsSetSize(scrollbar[1],scrbThick,sy-scrbThick,false)
		dgsSetSize(scrollbar[2],sx-scrbThick,scrbThick,false)
	end
	local renderTarget = dxCreateRenderTarget(sx-xthick,sy-ythick,true)
	dgsSetData(source,"renderTarget_parent",renderTarget)
end

function sortScrollPane(source,parent)
	local sx,sy = unpack(dgsGetData(source,"absSize"))
	local x,y = unpack(dgsGetData(source,"absPos"))
	local maxSize = dgsGetData(parent,"maxChildSize")
	local tempx,tempy = x+sx,y+sy
	local ntempx,ntempy
	if maxSize[1] <= tempx then
		ntempx = tempx
	else
		ntempx = 0
		for k,v in ipairs(dgsGetChildren(parent)) do
			local pos = dgsGetData(v,"absPos")
			local size = dgsGetData(v,"absSize")
			ntempx = ntempx > pos[1]+size[1] and ntempx or pos[1]+size[1]
		end
	end
	if maxSize[2] <= tempy then
		ntempy = tempy
	else
		ntempy = 0
		for k,v in ipairs(dgsGetChildren(parent)) do
			local pos = dgsGetData(v,"absPos")
			local size = dgsGetData(v,"absSize")
			ntempy = ntempy > pos[2]+size[2] and ntempy or pos[2]+size[2]
		end
	end
	maxSize[1] = ntempx or maxSize[1]
	maxSize[2] = ntempy or maxSize[2]
	dgsScrollPaneUpdateScrollBar(parent,ntempx,ntempy)
	dgsSetData(parent,"maxChildSize",maxSize)
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