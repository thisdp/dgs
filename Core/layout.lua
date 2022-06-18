dgsLogLuaMemory()
dgsRegisterType("dgs-dxlayout","dgsBasic","dgsType2D")
builtinLayoutStyle = {
	horizontal = {
		onItemAdd = function(layout,item,id,updateOnly)
			local eleData = dgsElementData[layout]
			local layoutData = eleData.layoutData
			local spacing = eleData.spacing
			local alignment = eleData.alignment
			local size = eleData.absSize
			local itemWidth = 0
			local itemHeight = 0
			for i=1,id-1 do
				local itemSize = dgsElementData[layoutData[i]].absSize
				if itemSize then
					itemWidth = itemWidth+itemSize[1]+spacing[1]
					if itemSize[2] > itemHeight then
						itemHeight = itemSize[2]
					end
				end
			end
			dgsSetPosition(item,itemWidth,0,false)
			local iWid = dgsElementData[item].absSize[1]
			dgsSetSize(layout,itemWidth+iWid,itemHeight,false)
			return true
		end,
		onItemRemove = function(layout,item,id)
			local eleData = dgsElementData[layout]
			local layoutData = eleData.layoutData
			local spacing = eleData.spacing
			local alignment = eleData.alignment
			local size = eleData.absSize
			local itemWidth = 0
			local itemHeight = 0
			for i=1,id-1 do
				local itemSize = dgsElementData[layoutData[i]].absSize
				if itemSize then
					itemWidth = itemWidth+itemSize[1]+spacing[1]
					if itemSize[2] > itemHeight then
						itemHeight = itemSize[2]
					end
				end
			end
			for i=id+1,#layoutData do
				local itemSize = dgsElementData[layoutData[i]].absSize
				if itemSize then
					dgsSetPosition(layoutData[i],itemWidth,0,false)
					itemWidth = itemWidth+itemSize[1]+spacing[1]
					if itemSize[2] > itemHeight then
						itemHeight = itemSize[2]
					end
				end
			end
			dgsSetSize(layout,itemWidth-spacing[1],itemHeight,false)
			return true
		end,
	},
	vertical = {
		onItemAdd = function(layout,item,id)
			local eleData = dgsElementData[layout]
			local layoutData = eleData.layoutData
			local spacing = eleData.spacing
			local alignment = eleData.alignment
			local size = eleData.absSize
			local itemWidth = 0
			local itemHeight = 0
			for i=1,id-1 do
				local itemSize = dgsElementData[layoutData[i]].absSize
				if itemSize then
					itemHeight = itemHeight+itemSize[2]+spacing[2]
					if itemSize[1] > itemWidth then
						itemWidth = itemSize[1]
					end
				end
			end
			dgsSetPosition(item,0,itemHeight,false)
			local iHei = dgsElementData[item].absSize[2]
			dgsSetSize(layout,itemWidth,itemWidth+iHei,false)
			return true
		end,
		onItemRemove = function(layout,item,id)
			local eleData = dgsElementData[layout]
			local layoutData = eleData.layoutData
			local spacing = eleData.spacing
			local alignment = eleData.alignment
			local size = eleData.absSize
			local itemWidth = 0
			local itemHeight = 0
			for i=1,id-1 do
				local itemSize = dgsElementData[layoutData[i]].absSize
				if itemSize then
					itemHeight = itemHeight+itemSize[2]+spacing[2]
					if itemSize[1] > itemWidth then
						itemWidth = itemSize[1]
					end
				end
			end
			for i=id+1,#layoutData do
				local itemSize = dgsElementData[layoutData[i]].absSize
				if itemSize then
					dgsSetPosition(layoutData[i],0,itemHeight,false)
					itemHeight = itemHeight+itemSize[2]+spacing[2]
					if itemSize[2] > itemWidth then
						itemWidth = itemSize[2]
					end
				end
			end
			dgsSetSize(layout,itemWidth,itemHeight-spacing[2],false)
			return true
		end,
	},
}

function dgsCreateLayout(...)
	local sRes = sourceResource or resource
	local x,y,w,h,layoutStyle,relative,parent
	if select("#",...) == 1 and type(select(1,...)) == "table" then
		local argTable = ...
		x = argTable.x or argTable[1]
		y = argTable.y or argTable[2]
		w = argTable.width or argTable.w or argTable[3]
		h = argTable.height or argTable.h or argTable[4]
		layoutStyle = argTable.layoutStyle or argTable.style or argTable[5]
		relative = argTable.relative or argTable.rlt or argTable[6]
		parent = argTable.parent or argTable.p or argTable[7]
	else
		x,y,w,h,layoutStyle,relative,parent = ...
	end
	if not(type(x) == "number") then error(dgsGenAsrt(x,"dgsCreateLayout",1,"number")) end
	if not(type(y) == "number") then error(dgsGenAsrt(y,"dgsCreateLayout",2,"number")) end
	if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsCreateLayout",3,"number")) end
	if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsCreateLayout",4,"number")) end
	if builtinLayoutStyle[layoutStyle] then
		layoutStyle = builtinLayoutStyle[layoutStyle]
	else
		if dgsGetType(layoutStyle) ~= "string" then error(dgsGenAsrt(layoutStyle,"dgsCreateLayout",5,"string")) end
		local fnc,err = loadstring("return "..layoutStyle)
		if not fnc then error(dgsGenAsrt(fnc,"dgsCreateLayout",5,_,_,_,"Failed to load layout style function:"..err)) end
		local tempLayoutStyle = fnc()
		if type(tempLayoutStyle) ~= "table" then error(dgsGenAsrt(tempLayoutStyle,"dgsCreateLayout",5,"table",_,_,"Failed to load layout style")) end
		if layoutStyle.onItemAdd and layoutStyle.onItemRemove then
			layoutStyle = tempLayoutStyle
		end
	end
	local layout = createElement("dgs-dxlayout")
	dgsSetType(layout,"dgs-dxlayout")
	dgsElementData[layout] = {
		onItemAdd = layoutStyle.onItemAdd,
		onItemRemove = layoutStyle.onItemRemove,
		spacing = {5,5},
		hideInvisible = false,
		layoutData = {},
		autoUpdate = true,
		sortPriority = {},
	}
	dgsSetParent(layout,parent,true,true)
	calculateGuiPositionSize(layout,x,y,relative or false,w,h,relative or false,true)
	onDGSElementCreate(layout,sRes)
	dgsSetData(layout,"childOutsideHit",true)
	dgsAddEventHandler("onDgsCreate",layout,"dgsLayoutChildrenCreateHandler")
	dgsAddEventHandler("onDgsDestroy",layout,"dgsLayoutChildrenDestroyHandler")
	return layout
end

function dgsLayoutChildrenCreateHandler()
	dgsLayoutAddItem(this,source)
end

function dgsLayoutChildrenDestroyHandler()
	if this ~= source then
		dgsLayoutRemoveItem(this,source)
	end
end

function dgsLayoutUpdate(layout)
	local layoutData = dgsElementData[layout].layoutData
	local sortPriority = dgsElementData[layout].sortPriority
	local refreshTable = {}
	table.sort(layoutData,function(a,b)
		return (sortPriority[a] or 0) > (sortPriority[b] or 0)
	end)
	local onItemAdd = dgsElementData[layout].onItemAdd
	if onItemAdd then
		for i=1,#layoutData do
			onItemAdd(layout,layoutData[i],i)
		end
	end
end

function dgsLayoutAddItem(layout,item,sortPriority)
	if dgsGetType(layout) ~= "dgs-dxlayout" then error(dgsGenAsrt(layout,"dgsCreateLayout",1,"dgs-dxlayout")) end
	if not dgsIsType(item) then error(dgsGenAsrt(item,"dgsCreateLayout",2,"dgs-dxelement")) end
	if not (not sortPriority or type(sortPriority) == "number") then error(dgsGenAsrt(item,"dgsLayoutAddItem",1,"number/nil")) end
	local onItemAdd = dgsElementData[layout].onItemAdd
	local layoutData = dgsElementData[layout].layoutData
	local itemID = #layoutData+1
	if onItemAdd then
		if not sortPriority then
			onItemAdd(layout,item,itemID)
			if dgsGetParent(item) ~= layout then dgsSetParent(item,layout) end
			layoutData = dgsElementData[layout].layoutData
			layoutData[itemID] = item
		else
			if dgsGetParent(item) ~= layout then dgsSetParent(item,layout) end
			layoutData = dgsElementData[layout].layoutData
			layoutData[itemID] = item
			dgsLayoutSetItemSortPriority(item,sortPriority)
		end
		return itemID
	end
	return false
end

function dgsLayoutSetItemSortPriority(item,sortPriority)
	if not dgsIsType(item) then error(dgsGenAsrt(item,"dgsLayoutSetItemSortPriority",1,"dgs-dxelement")) end
	if not (not sortPriority or type(sortPriority) == "number") then error(dgsGenAsrt(item,"dgsLayoutSetItemSortPriority",1,"number/nil")) end
	local layout = dgsGetParent(item)
	if dgsGetType(layout) ~= "dgs-dxlayout" then error(dgsGenAsrt(layout,"dgsLayoutSetItemSortPriority",1,"dgs-dxlayout as parent")) end
	local sortPriorityTable = dgsElementData[layout].sortPriority
	sortPriorityTable[item] = sortPriority
	dgsLayoutUpdate(layout)
	return true
end

function dgsLayoutGetItemSortPriority(item)
	if not dgsIsType(item) then error(dgsGenAsrt(item,"dgsLayoutGetItemSortPriority",1,"dgs-dxelement")) end
	local layout = dgsGetParent(item)
	if dgsGetType(layout) ~= "dgs-dxlayout" then error(dgsGenAsrt(layout,"dgsLayoutGetItemSortPriority",1,"dgs-dxlayout as parent")) end
	local sortPriorityTable = dgsElementData[layout].sortPriority
	return sortPriorityTable[item] or false
end

function dgsLayoutRemoveItem(layout,item)
	if dgsGetType(layout) ~= "dgs-dxlayout" then error(dgsGenAsrt(layout,"dgsLayoutRemoveItem",1,"dgs-dxlayout")) end
	if not dgsIsType(item) then error(dgsGenAsrt(item,"dgsLayoutRemoveItem",2,"dgs-dxelement")) end
	local onItemRemove = dgsElementData[layout].onItemRemove
	local layoutData = dgsElementData[layout].layoutData
	local itemID = table.find(layoutData,item)
	if itemID then
		if onItemRemove and onItemRemove(layout,item,itemID) then
			if dgsGetParent(item) == layout then dgsSetParent(item,nil) end
			layoutData = dgsElementData[layout].layoutData
			table.remove(layoutData,itemID)
			return true
		end
	end
	return false
end

function dgsLayoutGetItemIndex(layout,item)
	if dgsGetType(layout) ~= "dgs-dxlayout" then error(dgsGenAsrt(layout,"dgsLayoutGetItemIndex",1,"dgs-dxlayout")) end
	if not dgsIsType(item) then error(dgsGenAsrt(item,"dgsLayoutGetItemIndex",2,"dgs-dxelement")) end
	local layoutData = dgsElementData[layout].layoutData
	return table.find(layoutData,item)
end

----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxlayout"] = function(source,x,y,w,h,mx,my,cx,cy,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt)
	return rndtgt,false,mx,my,0,0
end