function dgsDxCreateScrollPane(x,y,sx,sy,relative,parent)
	assert(tonumber(x),"Bad argument @dgsDxCreateScrollPane at argument 1, expect number got "..type(x))
	assert(tonumber(y),"Bad argument @dgsDxCreateScrollPane at argument 2, expect number got "..type(y))
	assert(tonumber(sx),"Bad argument @dgsDxCreateScrollPane at argument 3, expect number got "..type(sx))
	assert(tonumber(sy),"Bad argument @dgsDxCreateScrollPane at argument 4, expect number got "..type(sy))
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"Bad argument @dgsDxCreateScrollPane at argument 6, expect dgs-dxgui got "..dgsGetType(parent))
	end
	local scrollpane = createElement("dgs-dxscrollpane")
	local _ = dgsIsDxElement(parent) and dgsSetParent(scrollpane,parent,true) or table.insert(MaxFatherTable,1,scrollpane)
	dgsSetType(scrollpane,"dgs-dxscrollpane")
	dgsSetData(scrollpane,"scrollBarThick",20,true)
	triggerEvent("onClientDgsDxGUIPreCreate",scrollpane)
	calculateGuiPositionSize(scrollpane,x,y,relative or false,sx,sy,relative or false,true)
	local sx,sy = unpack(dgsGetData(scrollpane,"absSize"))
	local x,y = unpack(dgsGetData(scrollpane,"absPos"))
	local renderTarget = dxCreateRenderTarget(sx,sy,true)
	dgsSetData(scrollpane,"renderTarget_parent",renderTarget)
	dgsSetData(scrollpane,"maxChildSize",{0,0})
	local scrbThick = 20
	local titleOffset = 0
	if isElement(parent) then
		if dgsGetData(scrollpane,"withoutTitle") then
			titleOffset = dgsGetData(parent,"titlesize") or 0
		end
	end
	local scrollbar1 = dgsDxCreateScrollBar(x+sx-scrbThick,y-titleOffset,scrbThick,sy-scrbThick,false,false,parent)
	local scrollbar2 = dgsDxCreateScrollBar(x,y+sy-scrbThick-titleOffset,sx-scrbThick,scrbThick,true,false,parent)
	dgsDxGUISetVisible(scrollbar1,false)
	dgsDxGUISetVisible(scrollbar2,false)
	dgsSetData(scrollbar1,"length",{0,true})
	dgsSetData(scrollbar2,"length",{0,true})
	dgsSetData(scrollpane,"scrollbars",{scrollbar1,scrollbar2})
	dgsSetData(scrollbar1,"parent_sp",scrollpane)
	dgsSetData(scrollbar2,"parent_sp",scrollpane)
	triggerEvent("onClientDgsDxGUICreate",scrollpane)
	return scrollpane
end

addEventHandler("onClientDgsDxGUICreate",root,function()
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
			xthick = dgsDxGUIGetVisible(scrollbar[1]) and scrbThick or 0
			ythick = dgsDxGUIGetVisible(scrollbar[2]) and scrbThick or 0
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
			local scbstate = {dgsDxGUIGetVisible(scrollbar[1]),dgsDxGUIGetVisible(scrollbar[2])}
			local scbThick = dgsGetData(scrollpane,"scrollBarThick")
			local xthick,ythick = scbstate[1] and scbThick or 0,scbstate[2] and scbThick or 0
			
			if ntempx then
				if ntempx > sx then
					dgsDxGUISetVisible(scrollbar[2],true)
				else
					dgsDxGUISetVisible(scrollbar[2],false)
				end
			end
			if ntempy then
				if ntempy > sy then
					dgsDxGUISetVisible(scrollbar[1],true)
				else
					dgsDxGUISetVisible(scrollbar[1],false)
				end
			end
		end
	end
end

addEventHandler("onClientDgsDxGUIDestroy",root,function()
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
		xthick = dgsDxGUIGetVisible(scrollbar[1]) and scrbThick or 0
		ythick = dgsDxGUIGetVisible(scrollbar[2]) and scrbThick or 0
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

function dgsDxScrollPaneGetScrollBar(scrollpane)
	assert(dgsGetType(scrollpane) == "dgs-dxscrollpane","Bad argument @dgsDxScrollPaneGetScrollBar at at argument 1, expect dgs-dxscrollpane got "..tostring(dgsGetType(scrollpane) or type(scrollpane)))
	return dgsGetData(scrollpane,"scrollbars")
end