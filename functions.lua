dgsLogLuaMemory()
local loadstring = loadstring
---------------Speed Up
local tableInsert,tableRemove,tableFind = table.insert,table.remove,table.find
local dgsTriggerEvent = dgsTriggerEvent
local type,assert = type,assert
local isElement = isElement
local setElementData = setElementData
local destroyElement = destroyElement
local dgsSetProperty = dgsSetProperty
local guiBlur = guiBlur or function()
	destroyElement(guiCreateLabel(0,0,0,0,"",false))
end
local guiFocus = guiBringToFront

function insertResource(res,dgsEle)
	if res and isElement(dgsEle) then
		boundResource[res] = boundResource[res] or {}
		boundResource[res][dgsEle] = true
		setElementData(dgsEle,"resource",res)
		dgsSetProperty(dgsEle,"resource",res)
	end
end

function dgsGetGuiLocationOnScreen(dgsEle,rlt,rndsup)
	if not isElement(dgsEle) then return false end
	local pos = dgsElementData[dgsEle].absPos
	local x,y = getParentLocation(dgsEle,rndsup,pos[1],pos[2])
	return rlt and x/sW or x,rlt and y/sH or y
end
-- todo
function getParentLocation(dgsEle,rndSuspend,x,y,includeSide)
	local eleData
	local x,y = 0,0
	local startEle = dgsEle
	repeat
		eleData = dgsElementData[dgsEle]
		local absPos = eleData.absPos
		local absPosX,absPosY = 0,0
		if absPos then
			absPosX,absPosY = absPos[1],absPos[2]
		end
		if includeSide then
			local parent = dgsElementData[dgsEle].parent
			local pEleData = dgsElementData[parent]
			local eleConAlign = parent and pEleData.contentPositionAlignment
			local eleAlign = eleData.positionAlignment
			local eleAlignH,eleAlignV = eleAlign[1] or eleConAlign[1], eleAlign[2] or eleConAlign[2]
			if eleAlignH == "right" then
				local pWidth = parent and pEleData.absSize[1] or sW
				absPosX = pWidth-absPosX
			elseif eleAlignH == "center" then
				local pWidth = parent and pEleData.absSize[1] or sW
				absPosX = absPosX+pWidth/2-eleData.absSize[1]/2
			end
			if eleAlignV == "bottom" then
				local pHeight = parent and pEleData.absSize[2] or sH
				absPosY = pHeight-absPosY
			elseif eleAlignV == "center" then
				local pHeight = parent and pEleData.absSize[2] or sH
				absPosY = absPosY+pHeight/2-eleData.absSize[2]/2
			end
		end
		local _tmp = dgsEle
		if dgsElementType[dgsEle] == "dgs-dxtab" then
			dgsEle = eleData.parent
			eleData = dgsElementData[dgsEle]
			local h = eleData.absSize[2]
			local tabHeight = eleData.tabHeight[2] and eleData.tabHeight[1]*h or eleData.tabHeight[1]
			x,y = x+eleData.absPos[1],y+eleData.absPos[2]+tabHeight
		elseif eleData.attachedToGridList then
			local data = eleData.attachedToGridList	--GridList,Row,Column
			local gridList = data[1]	--Grid List
			local gridListEleData = dgsElementData[gridList]
			local scbThickV = dgsElementData[ gridListEleData.scrollbars[1] ].visible and gridListEleData.scrollBarThick or 0
			local columnData = gridListEleData.columnData
			local rowData = gridListEleData.rowData
			local columnOffset = rowData[data[2]][-4] or gridListEleData.columnOffset
			local columnMoveOffset = gridListEleData.columnMoveOffset
			local rowHeight = gridListEleData.rowHeight
			local leading = gridListEleData.leading
			local w = gridListEleData.absSize[1]
			x,y = x+columnMoveOffset+gridListEleData.columnOffset+columnOffset+columnData[data[3]][3]*(gridListEleData.columnRelative and (w-scbThickV) or 1), y+gridListEleData.rowMoveOffset+(data[2]-1)*(leading+rowHeight)+gridListEleData.columnHeight
		end
		dgsEle = dgsElementData[dgsEle].parent
		eleData = dgsElementData[dgsEle]
		if dgsElementType[dgsEle] == "dgs-dxwindow" then
			local titleHeight = 0
			if not eleData.ignoreParentTitle and not eleData.ignoreTitle then
				titleHeight = eleData.titleHeight or 0
			end
			x,y = x+absPosX,y+absPosY+titleHeight
		elseif dgsElementType[dgsEle] == "dgs-dxscrollpane" then
			x,y = x+absPosX+eleData.horizontalMoveOffset,y+absPosY+eleData.verticalMoveOffset
		elseif dgsElementType[dgsEle] == "dgs-dxscalepane" then
			--[[local scrollbar = eleData.scrollbars
			local scbThick = eleData.scrollBarThick
			local size = eleData.absSize
			local relSizX,relSizY = size[1]-(dgsElementData[ scrollbar[1] ].visible and scbThick or 0),size[2]-(dgsElementData[ scrollbar[2] ].visible and scbThick or 0)
			local maxSize = eleData.maxChildSize
			local maxX,maxY = (maxSize[1]-relSizX),(maxSize[2]-relSizY)
			maxX,maxY = maxX > 0 and maxX or 0,maxY > 0 and maxY or 0
			x,y = x+absPosX-maxX*dgsElementData[ scrollbar[2] ].scrollPosition*0.01,y+absPosY-maxY*dgsElementData[ scrollbar[1] ].scrollPosition*0.01]]
		else
			x,y = x+absPosX,y+absPosY
		end
		if startEle == dgsEle then
			return _,_,startEle,_tmp
		end
	until(not isElement(dgsEle) or (rndSuspend and eleData.renderTarget_parent))
	return x,y
end

function dgsGetPosition(dgsEle,relative,includeParent,rndSuspend,includeSide)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsGetPosition",1,"dgs-dxelement")) end
	if includeParent then
		local absPos = dgsElementData[dgsEle].absPos
		local absPosX,absPosY = 0,0
		if absPos then
			absPosX,absPosY = absPos[1],absPos[2]
		end
		guielex,guieley,startElement,brokenElement = getParentLocation(dgsEle,rndSuspend,absPosX,absPosY,includeSide)
		if brokenElement then error("Bad argument @'dgsGetPosition', Found an infinite loop under "..tostring(brokenElement).."("..dgsGetType(brokenElement).."), start from element "..tostring(startElement).."("..dgsGetType(startElement)..")") end
		if relative then
			return guielex/sW,guieley/sH
		else
			return guielex,guieley
		end
	else
		local pos = dgsElementData[dgsEle][relative and "rltPos" or "absPos"]
		if not pos then return false end
		return pos[1],pos[2]
	end
end

function dgsSetPosition(dgsEle,x,y,relative,...)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsSetPosition",1,"dgs-dxelement")) end
	if (x and type(x) ~= "number") then error(dgsGenAsrt(x,"dgsSetPosition",2,"nil/number")) end
	if (y and type(y) ~= "number") then error(dgsGenAsrt(y,"dgsSetPosition",3,"nil/number")) end
	local pos = relative and dgsElementData[dgsEle].rltPos or dgsElementData[dgsEle].absPos
	local x,y = x or pos[1],y or pos[2]
	local pivot = dgsElementData[dgsEle].posPivot
	if select("#",...) == 2 or pivot then
		local pivotX,pivotY
		if select("#",...) == 2 then
			pivotX,pivotY = ...
		else
			pivotX,pivotY = pivot[1],pivot[2]
		end
		if (type(pivotX) ~= "number") then error(dgsGenAsrt(pivotX,"dgsSetPosition",5,"number")) end
		if (type(pivotY) ~= "number") then error(dgsGenAsrt(pivotY,"dgsSetPosition",6,"number")) end
		local size = dgsElementData[dgsEle].absSize
		calculateGuiPositionSize(dgsEle,x-size[1]*pivotX,y-size[2]*pivotX,relative)
	else
		local isCenterPosition = ...
		if isCenterPosition then
			local size = dgsElementData[dgsEle][relative and "rltSize" or "absSize"]
			calculateGuiPositionSize(dgsEle,x-size[1]/2,y-size[2]/2,relative)
		else
			calculateGuiPositionSize(dgsEle,x,y,relative)
		end
	end
	return true
end

function dgsCenterElement(dgsEle,remainX,remainY)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsCenterElement",1,"dgs-dxelement")) end
	local rlt = dgsElementData[dgsEle].relative[1]
	if rlt then
		local remainPos = dgsElementData[dgsEle].rltPos
		local size = dgsElementData[dgsEle].rltSize
		return dgsSetPosition(dgsEle,remainX and remainPos[1] or 0.5-size[1]/2,remainY and remainPos[2] or 0.5-size[2]/2,true)
	else
		local parent = dgsGetParent(dgsEle)
		local windowSize = parent and dgsElementData[parent].absSize or {sW,sH}
		local remainPos = dgsElementData[dgsEle].absPos
		local size = dgsElementData[dgsEle].absSize
		return dgsSetPosition(dgsEle,remainX and remainPos[1] or windowSize[1]/2-size[1]/2,remainY and remainPos[2] or windowSize[2]/2-size[2]/2,false)
   end
end

function dgsGetSize(dgsEle,relative)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsGetSize",1,"dgs-dxelement")) end
	local size = dgsElementData[dgsEle][relative and "rltSize" or "absSize"]
	if size then return size[1],size[2] end
	return 0,0
end

function dgsSetSize(dgsEle,w,h,relative,...)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsSetSize",1,"dgs-dxelement")) end
	if (w and type(w) ~= "number") then error(dgsGenAsrt(w,"dgsSetSize",2,"nil/number")) end
	if (h and type(h) ~= "number") then error(dgsGenAsrt(h,"dgsSetSize",3,"nil/number")) end
	local size = relative and dgsElementData[dgsEle].rltSize or dgsElementData[dgsEle].absSize
	local w,h = w or size[1], h or size[2]
	local pivot = dgsElementData[dgsEle].sizePivot
	if select("#",...) == 2 or pivot then
		local pivotX,pivotY
		if select("#",...) == 2 then
			pivotX,pivotY = ...
		else
			pivotX,pivotY = pivot[1],pivot[2]
		end
		if (type(pivotX) ~= "number") then error(dgsGenAsrt(pivotX,"dgsSetSize",5,"number")) end
		if (type(pivotY) ~= "number") then error(dgsGenAsrt(pivotY,"dgsSetSize",6,"number")) end
		local oldSize = relative and dgsElementData[dgsEle].rltSize or dgsElementData[dgsEle].absSize
		calculateGuiPositionSize(dgsEle,_,_,_,w,h,relative or false)
		local oldPos = relative and dgsElementData[dgsEle].rltPos or dgsElementData[dgsEle].absPos
		local newSize = relative and dgsElementData[dgsEle].rltSize or dgsElementData[dgsEle].absSize
		calculateGuiPositionSize(dgsEle,oldPos[1]-(newSize[1]-oldSize[1])*pivotX,oldPos[2]-(newSize[2]-oldSize[2])*pivotY,relative)
	else
		calculateGuiPositionSize(dgsEle,_,_,_,w,h,relative or false)
	end
	return true
end

function dgsAttachElements(dgsEle,attachTo,offsetX,offsetY,offsetW,offsetH,relativePos,relativeSize)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsAttachElements",1,"dgs-dxelement")) end
	if dgsGetParent(dgsEle) then error(dgsGenAsrt(dgsEle,"dgsAttachElements",1,_,_,"source dgs element shouldn't have a parent")) end
	if not(dgsIsType(attachTo)) then error(dgsGenAsrt(attachTo,"dgsAttachElements",2,"dgs-dxelement")) end
	dgsDetachElements(dgsEle)
	relativeSize = relativeSize == nil and relativePos or relativeSize
	if not offsetW or not offsetH then
		local size = dgsElementData[dgsEle].absSize
		offsetW,offsetH = size[1],size[2]
		relativeSize = false
	end
	offsetX,offsetY = offsetX or 0,offsetY or 0
	local attachedTable = {attachTo,offsetX,offsetY,relativePos,offsetW,offsetH,relativeSize}
	dgsElementData[attachTo] = dgsElementData[attachTo] or {}
	dgsElementData[attachTo].attachedBy = dgsElementData[attachTo].attachedBy or {}
	local attachedBy = dgsElementData[attachTo].attachedBy
	tableInsert(attachedBy,dgsEle)
	dgsSetData(attachTo,"attachedBy",attachedBy)
	dgsSetData(dgsEle,"attachedTo",attachedTable)
	local attachedTable = dgsElementData[dgsEle].attachedTo
	local absx,absy = dgsGetPosition(attachTo,false,true)
	local absw,absh = dgsElementData[attachTo].absSize[1],dgsElementData[attachTo].absSize[2]
	offsetX,offsetY = relativePos and (absx+absw*offsetX)/sW or offsetX+absx, relativePos and (absy+absh*offsetY)/sH or offsetY+absy
	offsetW,offsetH = relativeSize and absw*offsetW/sW or offsetW, relativeSize and absh*offsetH/sH or offsetH
	calculateGuiPositionSize(dgsEle,offsetX,offsetY,relativePos,offsetW,offsetH,relativeSize)
	return true
end

function dgsElementIsAttached(dgsEle)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsElementIsAttached",1,"dgs-dxelement")) end
	return dgsElementData[dgsEle].attachedTo and true or false
end

function dgsDetachElements(dgsEle)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsDetachElements",1,"dgs-dxelement")) end
	local attachedTable = dgsElementData[dgsEle].attachedTo or {}
	if isElement(attachedTable[1]) then
		local attachedBy = dgsElementData[attachedTable[1]].attachedBy
		local id = tableFind(attachedBy or {},dgsEle)
		if id then
			tableRemove(attachedBy,dgsEle)
		end
	end
	return dgsSetData(dgsEle,"attachedTo",false)
end

function dgsApplyDetectArea(dgsEle,da)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsApplyDetectArea",1,"dgs-dxelement")) end
	if not(dgsGetType(da) == "dgs-dxdetectarea") then error(dgsGenAsrt(da,"dgsApplyDetectArea",2,"dgs-dxdetectarea")) end
	return dgsSetData(dgsEle,"dgsCollider",da)
end

function dgsRemoveDetectArea(dgsEle)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsRemoveDetectArea",1,"dgs-dxelement")) end
	return dgsSetData(dgsEle,"dgsCollider",nil)
end

function dgsGetDetectArea(dgsEle)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsGetDetectArea",1,"dgs-dxelement")) end
	return dgsElementData[dgsEle].dgsCollider or false
end

function dgsApplyEnabledInherited(parent,enabled)
	local children = dgsElementData[parent].children
	for k,child in ipairs(children) do
		dgsElementData[child].enabledInherited = enabled
		dgsApplyEnabledInherited(child,dgsElementData[child].enabledInherited)
	end
end

function dgsSetEnabled(dgsEle,enabled)
	local enabled = enabled and true or false
	if type(dgsEle) == "table" then
		for i=1,#dgsEle do
			if not(dgsIsType(dgsEle[i])) then error(dgsGenAsrt(dgsEle[i],"dgsSetEnabled",1,"dgs-dxelement",_,_,"at table index "..i)) end
			dgsSetEnabled(dgsEle[i],enabled)
		end
		return true
	else
		if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsSetEnabled",1,"dgs-dxelement")) end
		local originalEnabled = dgsElementData[dgsEle].enabled
		if enabled == originalEnabled then return true end
		local parentInherited = true
		local parent = dgsGetParent(dgsEle)
		if parent then parentInherited = dgsElementData[parent].enabledInherited and dgsElementData[parent].enabled end
		dgsElementData[dgsEle].enabledInherited = parentInherited
		dgsApplyEnabledInherited(dgsEle,enabled and dgsElementData[dgsEle].enabledInherited)
		return dgsSetData(dgsEle,"enabled",enabled)
	end
end

function dgsGetEnabled(dgsEle,selfOnly)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsGetEnabled",1,"dgs-dxelement")) end
	if selfOnly then return dgsElementData[dgsEle].enabled end
	return dgsElementData[dgsEle].enabledInherited and dgsElementData[dgsEle].enabled
end

function dgsApplyVisibleInherited(parent,visible)
	local children = dgsElementData[parent].children
	for i=1,#children do
		local child = children[i]
		dgsElementData[child].visibleInherited = visible
		local eleType = dgsElementType[child]
		if dgsOnVisibilityChange[eleType] then dgsOnVisibilityChange[eleType](child) end
		dgsApplyVisibleInherited(child,dgsElementData[child].visibleInherited)
	end
end

function dgsSetVisible(dgsEle,visible)
	local visible = visible and true or false
	if type(dgsEle) == "table" then
		local result = true
		for i=1,#dgsEle do
			if not(dgsIsType(dgsEle[i])) then error(dgsGenAsrt(dgsEle[i],"dgsSetVisible",1,"dgs-dxelement",_,_,"at table index "..i)) end
			dgsSetVisible(dgsEle[i],visible)
		end
		return true
	else
		if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsSetVisible",1,"dgs-dxelement")) end
		local originalVisible = dgsElementData[dgsEle].visible
		if visible == originalVisible then return true end
		local parentInherited = true
		local parent = dgsGetParent(dgsEle)
		if parent then parentInherited = dgsElementData[parent].visibleInherited  and dgsElementData[parent].visible end
		dgsElementData[dgsEle].visibleInherited = parentInherited
		if dgsOnVisibilityChange[eleType] then dgsOnVisibilityChange[eleType](dgsEle) end
		dgsApplyVisibleInherited(dgsEle,visible and dgsElementData[dgsEle].visibleInherited)
		return dgsSetData(dgsEle,"visible",visible)
	end
end

function dgsGetVisible(dgsEle,selfOnly)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsGetVisible",1,"dgs-dxelement")) end
	if selfOnly then return dgsElementData[dgsEle].visible end
	return dgsElementData[dgsEle].visibleInherited and dgsElementData[dgsEle].visible
end

function dgsSetPositionAlignment(dgsEle,horizontal,vertical)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsSetPositionAlignment",1,"dgs-dxelement")) end
	local eleAlign = dgsElementData[dgsEle].positionAlignment
	eleAlign[1] = horizontal or eleAlign[1]
	eleAlign[2] = vertical or eleAlign[2]
	return dgsSetData(dgsEle,"positionAlignment",eleAlign)
end

function dgsGetPositionAlignment(dgsEle)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsGetPositionAlignment",1,"dgs-dxelement")) end
	return dgsElementData[dgsEle].positionAlignment[1] or "left",dgsElementData[dgsEle].positionAlignment[2] or "top"
end

function configPosSize(dgsEle,pos,size)
	local eleData = dgsElementData[dgsEle]
	local rlt = eleData.relative
	local x,y,rltPos,w,h,rltSize
	if pos then
		local pos = rlt[1] and eleData.rltPos or eleData.absPos
		x,y,rltPos = pos[1],pos[2],rlt[1]
	end
	if size then
		local size = rlt[1] and eleData.rltSize or eleData.absSize
		w,h,rltSize = size[1],size[2],rlt[2]
	end
	calculateGuiPositionSize(dgsEle,x,y,rltPos,w,h,rltSize)
end

function calculateGuiPositionSize(dgsEle,x,y,relativep,sx,sy,relatives,notrigger)
	if not dgsElementData[dgsEle] then dgsElementData[dgsEle] = {} end
	local eleData = dgsElementData[dgsEle]
	local parent = eleData.parent
	local psx,psy = sW,sH
	local relt = eleData.relative
	local oldRelativePos,oldRelativeSize
	if relt then
		oldRelativePos,oldRelativeSize = relt[1],relt[2]
	else
		oldRelativePos,oldRelativeSize = relativep,relatives
	end
	local titleOffset = 0
	if isElement(parent) then
		local parentData = dgsElementData[parent]
		if dgsElementType[parent] == "dgs-dxtab" then
			local tabpanel = parentData.parent
			local size = dgsElementData[tabpanel].absSize
			psx,psy = size[1],size[2]
			local height = dgsElementData[tabpanel].tabHeight[2] and dgsElementData[tabpanel].tabHeight[1]*psy or dgsElementData[tabpanel].tabHeight[1]
			psy = psy-height
		else
			local size = parentData.absSize or parentData.resolution
			psx,psy = size[1],size[2]
		end
		if not eleData.ignoreParentTitle and parentData.ignoreTitle then
			titleOffset = parentData.titleHeight or 0
		end
	end
	if x and y then
		if not eleData.absPos then eleData.absPos = {} end
		if not eleData.rltPos then eleData.rltPos = {} end
		local absPos = eleData.absPos
		local oldPosAbsx,oldPosAbsy = absPos[1],absPos[2]
		local rltPos = eleData.rltPos
		local oldPosRltx,oldPosRlty = rltPos[1],rltPos[2]
		x,y = relativep and x*psx or x,relativep and y*psy or y
		local abx,aby,relatx,relaty = x,y,x/psx,y/psy
		if psx == 0 then relatx = 0 end
		if psy == 0 then relaty = 0 end
		dgsSetData(dgsEle,"absPos",{abx,aby})
		dgsSetData(dgsEle,"rltPos",{relatx,relaty})
		dgsSetData(dgsEle,"relative",{relativep,oldRelativeSize})
		if not notrigger then
			dgsTriggerEvent("onDgsPositionChange",dgsEle,oldPosAbsx,oldPosAbsy,oldPosRltx,oldPosRlty)
		end
	end
	if sx and sy then
		if not eleData.absSize then eleData.absSize = {} end
		if not eleData.rltSize then eleData.rltSize = {} end
		local absSize = eleData.absSize
		local oldSizeAbsx,oldSizeAbsy = absSize[1],absSize[2]
		local rltSize = eleData.rltSize
		local oldSizeRltx,oldSizeRlty = rltSize[1],rltSize[2]
		sx,sy = relatives and sx*psx or sx,relatives and sy*(psy-titleOffset) or sy
		local absx,absy,relatsx,relatsy = sx,sy,sx/psx,sy/(psy-titleOffset)
		if psx == 0 then relatsx = 0 end
		if psy-titleOffset == 0 then relatsy = 0 end
		dgsSetData(dgsEle,"absSize",{absx,absy})
		dgsSetData(dgsEle,"rltSize",{relatsx,relatsy})
		dgsSetData(dgsEle,"relative",{oldRelativePos,relatives})
		if not notrigger then
			dgsTriggerEvent("onDgsSizeChange",dgsEle,oldSizeAbsx,oldSizeAbsy,oldSizeRltx,oldSizeRlty)
		end
	end
	return true
end

function dgsSetAlpha(dgsEle,alpha,absolute)
	if not(type(alpha) == "number") then error(dgsGenAsrt(alpha,"dgsSetAlpha",2,"number")) end
	if type(dgsEle) == "table" then
		for i=1,#dgsEle do
			if not(dgsIsType(dgsEle[i])) then error(dgsGenAsrt(dgsEle[i],"dgsSetAlpha",1,"dgs-dxelement",_,_,"at table index "..i)) end
			dgsSetAlpha(dgsEle[i],alpha,absolute)
		end
		return true
	end
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsSetAlpha",1,"dgs-dxelement")) end
	alpha = absolute and alpha/255 or alpha
	return dgsSetData(dgsEle,"alpha",(alpha > 1 and 1) or (alpha < 0 and 0) or alpha)
end

function dgsGetAlpha(dgsEle,absolute,includeParent)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsGetAlpha",1,"dgs-dxelement")) end
	if includeParent then
		local alp = 1
		local p = dgsEle
		for i=1,5000 do
			if not p then return absolute and alp*255 or alp end
			alp = alp*(dgsElementData[p].alpha or 1)
			p = dgsElementData[p].parent
		end
	else
		local alp = dgsElementData[dgsEle].alpha
		return absolute and alp*255 or alp
	end
end

function dgsCreateFont(path,size,bold,quality)
	if not(type(path) == "string") then error(dgsGenAsrt(path,"dgsCreateFont",1,"string")) end
	if not path:find(":") then
		local resname = getResourceName(sourceResource or getThisResource())
		path = ":"..resname.."/"..path
	end
	if not fileExists(path) then error(dgsGenAsrt(path,"dgsCreateFont",1,_,_,_,"Couldn't find such file '"..path.."'")) end
	return dxCreateFont({path,size,bold,quality})
end

function dgsSetFont(dgsEle,font)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsSetFont",1,"dgs-dxelement")) end
	local fontType = dgsGetType(font)
	if fontType == "string" then
		if not(fontBuiltIn[font]) then error(dgsGenAsrt(font,"dgsSetFont",2,_,_,_,"font "..font.." doesn't exist")) end
	elseif fontType == "table" then
		--nothing
	elseif fontType ~= "dx-font" then
		error(dgsGenAsrt(font,"dgsSetFont",2,"string/dx-font/table"))
	end
	dgsSetData(dgsEle,"font",font)
end

function dgsGetFont(dgsEle)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsGetFont",1,"dgs-dxelement")) end
	return dgsElementData[dgsEle].font
end

function dgsGetSystemFont(sres)
	local res = sres or sourceResource or "global"
	local style = styleManager.styles[res]
	style = style.loaded[style.using]
	local systemFont = style.systemFontElement
	return systemFont
end

function dgsSetSystemFont(font,size,bold,quality,styleName,res)
	if not(type(font) == "string") then error(dgsGenAsrt(font,"dgsSetSystemFont",1,"string")) end
	local res = sres or sourceResource or "global"
	local style = styleManager.styles[res]
	style = style.loaded[styleName or style.using]
	local systemFont = style.systemFontElement
	if isElement(systemFont) then
		destroyElement(systemFont)
	end
	local sResource = sourceResource or getThisResource()
	if fontBuiltIn[font] then
		style.systemFontElement = font
		return true
	else
		local path = font:find(":") and font or ":"..getResourceName(sResource).."/"..font
		if not fileExists(path) then error(dgsGenAsrt(path,"dgsSetSystemFont",1,_,_,_,"Couldn't find such file '"..path.."'")) end
		local font = dxCreateFont({path,size,bold,quality},sres or sResource)
		if isElement(font) then
			style.systemFontElement = font
		end
	end
	return false
end

function dgsSetText(dgsEle,text)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsSetText",1,"dgs-dxelement")) end
	return dgsSetData(dgsEle,"text",text)
end

function dgsGetText(dgsEle)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsGetText",1,"dgs-dxelement")) end
	local dxtype = dgsGetType(dgsEle)
	if dxtype == "dgs-dxmemo" then
		return dgsMemoGetPartOfText(dgsEle)
	else
		return dgsElementData[dgsEle].text
	end
end

function dgsSetClickingSound(dgsEle,soundPath,volume,button,state)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsSetClickingSound",1,"dgs-dxelement")) end
	if not(type(soundPath) == "string") then error(dgsGenAsrt(soundPath,"dgsSetClickingSound",2,"string")) end
	if sourceResource then
		if not soundPath:find(":") then
			soundPath = ":"..getResourceName(sourceResource).."/"..soundPath
		end
	end
	if not fileExists(soundPath) then error(dgsGenAsrt(soundPath,"dgsSetClickingSound",2,_,_,_,"Couldn't find such file '"..soundPath.."'")) end
	button = button or "left"
	state = state or "down"
	local eleData = dgsElementData[dgsEle]
	if not eleData.clickingSound then eleData.clickingSound = {} end
	if not eleData.clickingSound[button] then eleData.clickingSound[button] = {} end
	eleData.clickingSound[button][state] = soundPath
	if not eleData.clickingSoundVolume then eleData.clickingSoundVolume = {} end
	if not eleData.clickingSoundVolume[button] then eleData.clickingSoundVolume[button] = {} end
	eleData.clickingSoundVolume[button][state] = tonumber(volume)
	return true
end

function dgsGetClickingSound(dgsEle,button,state)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsSetClickingSound",1,"dgs-dxelement")) end
	button = button or "left"
	state = state or "down"
	local eleData = dgsElementData[dgsEle]
	if not eleData.clickingSound then return false end
	if not eleData.clickingSound[button] then return false end
	return eleData.clickingSound[button][state] or false
end

function dgsSetClickingSoundVolume(dgsEle,volume,button,state)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsSetClickingSoundVolume",1,"dgs-dxelement")) end
	if type(volume) ~= "number" then error(dgsGenAsrt(volume,"dgsSetClickingSoundVolume",2,"number")) end
	button = button or "left"
	state = state or "down"
	local eleData = dgsElementData[dgsEle]
	if not eleData.clickingSoundVolume then eleData.clickingSoundVolume = {} end
	if not eleData.clickingSoundVolume[button] then eleData.clickingSoundVolume[button] = {} end
	eleData.clickingSoundVolume[button][state] = volume
	return true
end

function dgsGetClickingSoundVolume(dgsEle,button,state)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsSetClickingSound",1,"dgs-dxelement")) end
	button = button or "left"
	state = state or "down"
	local eleData = dgsElementData[dgsEle]
	if not eleData.clickingSoundVolume then return 1 end
	if not eleData.clickingSoundVolume[button] then return 1 end
	return eleData.clickingSoundVolume[button][state] or 1
end

function dgsSetPostGUI(dgsEle,state)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsSetPostGUI",1,"dgs-dxelement")) end
	return dgsSetProperty(dgsEle,"postGUI",state)
end

function dgsGetPostGUI(dgsEle)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsGetPostGUI",1,"dgs-dxelement")) end
	return dgsElementData[dgsEle].postGUI
end

function dgsSimulateClick(dgsGUI,button)
	local x,y = dgsGetPosition(dgsGUI,false)
	local sx,sy = dgsGetSize(dgsGUI,false)
	local x,y = x+sx*0.5,y+sy*0.5
	dgsTriggerEvent("onDgsMouseClick",dgsGUI,button,"down",x,y)
	dgsTriggerEvent("onDgsMouseClick",dgsGUI,button,"up",x,y)
end

function DGSMouseClickConvert(source,button,state,x,y,isCoolingDown)
	if not isElement(source) then return end
	if state == "down" then
		dgsTriggerEvent("onDgsMouseClickDown",source,button,state,x,y,isCoolingDown)
	elseif state == "up" then
		dgsTriggerEvent("onDgsMouseClickUp",source,button,state,x,y,isCoolingDown)
	end
end
dgsRegisterFastEvent("onDgsMouseClick","DGSMouseClickConvert")

function DGSMouseDoubleClickConvert(source,button,state,x,y)
	if not isElement(source) then return end
	if state == "down" then
		dgsTriggerEvent("onDgsMouseDoubleClickDown",source,button,state,x,y)
	elseif state == "up" then
		dgsTriggerEvent("onDgsMouseDoubleClickUp",source,button,state,x,y)
	end
end
dgsRegisterFastEvent("onDgsMouseDoubleClick","DGSMouseDoubleClickConvert")

function dgsGetMouseClickGUI(button)
	if button == "left" then
		return MouseData.click.left
	elseif button == "middle" then
		return MouseData.click.middle
	else
		return MouseData.click.right
	end
end

function dgsIsMouseWithinGUI(ele)
	if type(ele) == "table" then
		local result = {}
		if isCursorShowing() then
			for key,e in pairs(ele) do
				result[e] = MouseData.WithinElements[e] and true or nil
			end
		end
		return result
	else
		return (isCursorShowing() and MouseData.WithinElements[ele]) and true or false
	end
end
function dgsGetMouseEnterGUI() return MouseData.entered end
function dgsGetMouseLeaveGUI() return MouseData.left end
function dgsGetFocusedGUI() return MouseData.focused end
function dgsGetScreenSize() return guiGetScreenSize() end
function dgsSetInputEnabled(...) return guiSetInputEnabled(...) end
function dgsGetInputEnabled(...) return guiGetInputEnabled(...) end
function dgsSetInputMode(...) return guiSetInputMode(...) end
function dgsGetInputMode(...) return guiGetInputMode(...) end
function dgsGetBrowser(b) return b end
function dgsGetRootElement() return resourceRoot end

function dgsFocus(dgsEle)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsFocus",1,"dgs-dxelement")) end
	local lastFront = MouseData.focused
	local eleType = dgsElementType[dgsEle]
	if eleType == "dgs-dxbrowser" then
		focusBrowser(dgsEle)
	elseif eleType == "dgs-dxedit" then
		resetTimer(MouseData.EditMemoTimer)
		MouseData.EditMemoCursor = true
		guiFocus(GlobalEdit)
		dgsElementData[GlobalEdit].linkedDxEdit = dgsEle
	elseif eleType == "dgs-dxmemo" then
		resetTimer(MouseData.EditMemoTimer)
		MouseData.EditMemoCursor = true
		guiFocus(GlobalMemo)
		dgsElementData[GlobalMemo].linkedDxMemo = dgsEle
	end
	if isElement(lastFront) and dgsEle ~= lastFront then
		dgsTriggerEvent("onDgsBlur",lastFront,dgsEle)
	end
	MouseData.focused = dgsEle
	dgsTriggerEvent("onDgsFocus",dgsEle,isElement(lastFront) and lastFront or nil)
	return true
end

function dgsBlur(dgsEle)
	if not dgsEle then dgsEle = MouseData.focused end
	if not isElement(dgsEle) or dgsEle ~= MouseData.focused then return true end
	local eleType = dgsElementType[dgsEle]
	MouseData.focused = nil
	if eleType == "dgs-dxbrowser" then
		focusBrowser()
	else
		blurEditMemo(dgsEle)
	end
	dgsTriggerEvent("onDgsBlur",dgsEle)
	return true
end

------------------Cursor Management
local CursorPosX,CursorPosY = sW/2,sH/2
local CursorPosXVisible,CursorPosYVisible = CursorPosX,CursorPosY
if isCursorShowing() then
	local cx,cy = getCursorPosition()
	CursorPosX,CursorPosY = cx*sW,cy*sH
	CursorPosXVisible,CursorPosYVisible = CursorPosX,CursorPosY
end

function dgsGetCursorVisible()
	return (isCursorShowing() or isChatBoxInputActive() or isConsoleActive()) and not isMainMenuActive() --Is visible in game
end

function dgsGetCursorPosition(rltEle,rlt,forceOnScreen)
	if dgsGetCursorVisible() then
		if dgsGetType(rltEle) == "dgs-dx3dinterface" then 	--For 3d interface, recalculate position and ignore "forceOnScreen"
			local hitX,hitY,px,py,pz,isHit = dgs3DInterfaceCalculateMousePosition(rltEle)
			if rlt then
				return hitX,hitY,px,py,pz,isHit
			else
				local resolution = dgsElementData[rltEle].resolution
				return hitX*resolution[1],hitY*resolution[2],px,py,pz,isHit
			end
		elseif MouseData.lock3DInterface and not forceOnScreen then	--For 3d interface using calculated position
			local absX,absY = dgsElementData[MouseData.lock3DInterface].cursorPosition[1],dgsElementData[MouseData.lock3DInterface].cursorPosition[2]
			local resolution = dgsElementData[MouseData.lock3DInterface].resolution
			if not rltEle and not dgsIsType(rltEle) then
				if rlt then
					return absX/resolution[1],absY/resolution[2]
				else
					return absX,absY
				end
			else
				local xPos,yPos = dgsGetGuiLocationOnScreen(rltEle,false)
				local eleSize = dgsElementData[rltEle].absSize
				if rlt then
					return (absX-xPos)/eleSize[1],(absY-yPos)/eleSize[2]
				else
					return absX-xPos,absY-yPos
				end
			end
		else
			local absX,absY = CursorPosXVisible,CursorPosYVisible
			if dgsIsType(rltEle) then
				local xPos,yPos = dgsGetGuiLocationOnScreen(rltEle,false)
				local eleSize = dgsElementData[rltEle].absSize
				
				
				-- todo
				if dgsElementData[rltEle].scale then
					x,y = (absX-xPos),(absY-yPos)
				end
				--[[
				OffsetX = -(resolution[1]-relSizX/scale[1])*eleData.horizontalMoveOffsetTemp
				OffsetY = -(resolution[2]-relSizY/scale[2])*eleData.verticalMoveOffsetTemp
				mx = (mx-xNRT)/scale[1]-OffsetX+xNRT
				my = (my-yNRT)/scale[2]-OffsetY+yNRT]]
	
				if rlt then
					return (absX-xPos)/eleSize[1],(absY-yPos)/eleSize[2]
				else
					return absX-xPos,absY-yPos
				end
			else
				if rlt then
					return absX/sW,absY/sH
				else
					return absX,absY
				end
			end
		end
	end
	return false
end

addEventHandler("onClientCursorMove",root,function(_,_,x,y)
	CursorPosX,CursorPosY = x,y
	if dgsGetCursorVisible() then
		CursorPosXVisible,CursorPosYVisible = CursorPosX,CursorPosY
	end
end)

--Multi Click Interval
function dgsGetMultiClickInterval() return multiClick.Interval end
function dgsSetMultiClickInterval(interval)
	if not(type(interval) == "number") then error(dgsGenAsrt(interval,"dgsSetClickInterval",1,"number")) end
	multiClick.Interval = interval
	return true
end
--Mouse Stay Delay
function dgsGetMouseStayDelay() return mouseStay.delay end
function dgsSetMouseStayDelay(delay)
	if not(type(delay) == "number") then error(dgsGenAsrt(delay,"dgsSetMouseStayDelay",1,"number")) end
	mouseStay.delay = delay
	return true
end

------------Move Scale Handler
function dgsAddMoveHandler(dgsEle,x,y,w,h,xRel,yRel,wRel,hRel,forceReplace)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsAddMoveHandler",1,"dgs-dxelement")) end
	local x,y,xRel,yRel = x or 0,y or 0,xRel ~= false and true,yRel ~= false and true
	local w,h,wRel,hRel = w or 1,h or 1,wRel ~= false and true,hRel ~= false and true
	local moveData = dgsElementData[dgsEle].moveHandlerData
	if not moveData or forceReplace then
		dgsSetData(dgsEle,"moveHandlerData",{x,y,w,h,xRel,yRel,wRel,hRel})
	end
end

function dgsRemoveMoveHandler(dgsEle)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsRemoveMoveHandler",1,"dgs-dxelement")) end
	local moveData = dgsElementData[dgsEle].moveHandlerData
	if moveData then
		dgsSetData(dgsEle,"moveHandlerData",nil)
	end
end

function dgsIsMoveHandled(dgsEle)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsIsMoveHandled",1,"dgs-dxelement")) end
	return dgsElementData[dgsEle].moveHandlerData and true or false
end

function dgsAddSizeHandler(dgsEle,left,right,top,bottom,leftRel,rightRel,topRel,bottomRel,forceReplace)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsAddSizeHandler",1,"dgs-dxelement")) end
	local left = left or 0
	local right = right or left
	local top = top or right
	local bottom = bottom or top
	local leftRel = leftRel ~= false and true
	local rightRel = rightRel ~= false and true
	local topRel = topRel ~= false and true
	local bottomRel = bottomRel ~= false and true
	local sizeData = dgsElementData[dgsEle].sizeHandlerData
	if not sizeData or forceReplace then
		dgsSetData(dgsEle,"sizeHandlerData",{left,right,top,bottom,leftRel,rightRel,topRel,bottomRel})
	end
end

function dgsRemoveSizeHandler(dgsEle)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsRemoveSizeHandler",1,"dgs-dxelement")) end
	local sizeData = dgsElementData[dgsEle].sizeHandlerData
	if sizeData then
		dgsSetData(dgsEle,"sizeHandlerData",nil)
	end
end

function dgsIsSizeHandled(dgsEle)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsIsSizeHandled",1,"dgs-dxelement")) end
	return dgsElementData[dgsEle].sizeHandlerData and true or false
end

dgsDragDropBoard = {
	[0] = false,
	data = {},		--The data you want to transfer
	lock = false,
	preview = nil,	--The preview you want to show
	previewColor = nil,
	previewOffsetX = nil,
	previewOffsetY = nil,
	previewWidth = nil,
	previewHeight = nil,
	previewAlignment = nil,
}

function dgsSendDragNDropData(dragData,preview,previewColor,previewOffsetX,previewOffsetY,previewWidth,previewHeight,previewHorizontalAlign,previewVerticalAlign)
	dgsDragDropBoard[0] = true
	dgsDragDropBoard.data = dragData
	dgsDragDropBoard.preview = preview
	dgsDragDropBoard.previewColor = previewColor
	dgsDragDropBoard.previewOffsetX = previewOffsetX
	dgsDragDropBoard.previewOffsetY = previewOffsetY
	dgsDragDropBoard.previewWidth = previewWidth
	dgsDragDropBoard.previewHeight = previewHeight
	dgsDragDropBoard.previewAlignment = {previewHorizontalAlign,previewVerticalAlign}
	return true
end

function dgsRetrieveDragNDropData(retainState)
	if dgsDragDropBoard[0] then
		if not retainState then
			dgsDragDropBoard[0] = false
		end
		return dgsDragDropBoard.data
	end
end

function dgsIsDragNDropData()
	return dgsDragDropBoard[0]
end

function dgsAddDragHandler(dgsEle,...)
	--dragData,preview,previewColor,previewOffsetX,previewOffsetY,previewWidth,previewHeight,previewHorizontalAlign,previewVerticalAlign
	return dgsSetData(dgsEle,"dragHandler",{...})
end

function dgsRemoveDragHandler(dgsEle)
	return dgsSetData(dgsEle,"dragHandler",nil)
end

------------Auto Destroy
function dgsAttachToAutoDestroy(element,dgsEle,index)
	if not isElement(element) then return true end
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsAttachToAutoDestroy",2,"dgs-dxelement")) end
	local eleData = dgsElementData[dgsEle]
	eleData.autoDestroyList = eleData.autoDestroyList or {}
	if not index then
		tableInsert(eleData.autoDestroyList,element)
	else
		eleData.autoDestroyList[index] = element
	end
	return true
end

function dgsDetachFromAutoDestroy(element,dgsEle)
	if not(isElement(element)) then error(dgsGenAsrt(element,"dgsDetachFromAutoDestroy",1,"element")) end
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsDetachFromAutoDestroy",2,"dgs-dxelement")) end
	local id = tableFind(dgsElementData[dgsEle].autoDestroyList or {},element)
	if id then tableRemove(dgsElementData[dgsEle].autoDestroyList,id) end
	return true
end

----------------------------------Multi Language Support
function dgsTranslationTableExists(name)
	if not(type(name) == "string") then error(dgsGenAsrt(name,"dgsTranslationTableExists",1,"string")) end
	return LanguageTranslation[name] and true or false
end

function dgsSetTranslationTable(name,tab)
	if not(type(name) == "string") then error(dgsGenAsrt(name,"dgsSetTranslationTable",1,"string")) end
	if not(not table or type(tab) == "table") then error(dgsGenAsrt(tab,"dgsSetTranslationTable",1,"table/nil")) end
	if tab then
		LanguageTranslation[name] = tab
		if not LanguageTranslationAttach[name] then LanguageTranslationAttach[name] = {} end
		dgsApplyLanguageChange(name,LanguageTranslation[name],LanguageTranslationAttach[name])
	elseif dgsTranslationTableExists(name) then
		LanguageTranslation[name] = false
		for k,v in ipairs(LanguageTranslationAttach[name]) do
			dgsSetData(v,"_translang",nil)
		end
		LanguageTranslation[name] = nil
		LanguageTranslationAttach[name] = nil
	end
	return true
end

function dgsAttachToTranslation(dgsEle,name)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsAttachToTranslation",1,"dgs-dxelement")) end
	local lastTrans = dgsElementData[dgsEle]._translang
	if lastTrans and LanguageTranslationAttach[lastTrans] then
		local id = tableFind(LanguageTranslationAttach[name])
		if id then
			tableRemove(LanguageTranslationAttach[name])
		end
	end
	dgsSetData(dgsEle,"_translang",name)
	if name then
		if LanguageTranslation[name] then
			LanguageTranslationAttach[name] = LanguageTranslationAttach[name] or {}
			tableInsert(LanguageTranslationAttach[name],dgsEle)
		end
		local text = dgsElementData[dgsEle]._translation_text
		if text then
			dgsSetData(dgsEle,"text",text)
		end
		local font = dgsElementData[dgsEle]._translation_font
		if font then
			dgsSetData(dgsEle,"font",font)
		end
	end
	return true
end

function dgsDetachFromTranslation(dgsEle)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsDetachFromTranslation",1,"dgs-dxelement")) end
	local lastTrans = dgsElementData[dgsEle]._translang
	if lastTrans and LanguageTranslationAttach[lastTrans] then
		local id = tableFind(LanguageTranslationAttach[name])
		if id then
			tableRemove(LanguageTranslationAttach[name])
		end
	end
	return dgsSetData(dgsEle,"_translang",nil)
end

function dgsSetAttachTranslation(name)
	resourceTranslation[sourceResource or getThisResource()] = name
	return true
end

function dgsGetTranslationName(dgsEle)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsGetTranslationName",1,"dgs-dxelement")) end
	return dgsElementData[dgsEle]._translang
end

function dgsGetTranslationValue(name,key)
	if name and LanguageTranslation[name] then
		return LanguageTranslation[name][key]
	end
	return false
end

local cTranslationBuffer = {}
local cTranslationEnvMeta = {
	__index = {
		table = table,
		string = string,
		find = function(tableToFind,value)
			for i=1,#tableToFind do
				if tableToFind[i] == value then return i end
			end
			return false
		end,
	}
}

function dgsTranslateText(textTable,translationTableName)
	if type(textTable) == "table" then
		local translation = translationTableName or resourceTranslation[sourceResource or getThisResource()]
		local value = translation and LanguageTranslation[translation] and LanguageTranslation[translation][textTable[1]] or textTable[1]
		local result,status = value
		if type(value) == "table" then	--Conditional Translation
			--[[ --Conditional Translation
			TestText={
				"health == 'Superman'",				"You are a superman",
				"find({0}, health)",				"Your health is 0",
				"health <= 40",						"Your health is low",
				"health <= 60",						"Your health is medium",
				"health <= 80",						"Your health is high",
				"Your health is $health",
			},
			]]
			if #value%2 == 0 then error("Bad argument @dgsTranslateText at argument 1, Bad conditional translation item count (should be odd, got even), maybe missing default translation") end
			result = value[#value]
			for i=1,#value-1,2 do --Odd item is conditional, Even item is translation, and skip default translation
				if not cTranslationBuffer[value[i]] then
					local fnc,err = loadstring("return "..value[i])
					if not fnc then error("Bad argument @dgsTranslateText, failed to load conditional ("..err..") at dictionary:"..translation.."[\""..textTable[1].."\"]["..math.floor(i/2).."]") end
					cTranslationBuffer[value[i]] = fnc	--buffer
				end
				local condition = cTranslationBuffer[value[i]]
				setmetatable(textTable,cTranslationEnvMeta)
				setfenv(condition,textTable)
				status,result = pcall(condition)
				if status and result then
					result = value[i+1]
					break
				end
			end
			local count = 2
			while true do
				local textArg = textTable[count]
				if not textArg then break end
				if type(textArg) == "table" then
					textArg = dgsTranslateText(textArg,translationTableName)
				end
				local _value = result:gsub("%%rep%%",textArg,1)
				if _value == result then break end
				count = count+1
				result = _value
			end
		else	--Replacing Translation
			local count = 2
			while true do
				local textArg = textTable[count]
				if not textArg then break end
				if type(textArg) == "table" then
					textArg = dgsTranslateText(textArg,translationTableName)
				end
				local _value = value:gsub("%%rep%%",textArg,1)
				if _value == value then break end
				count = count+1
				result = _value
			end
		end
		for k,v in pairs(textTable) do
			if type(k) == "string" then
				result = result:gsub("$"..k,v)
			end
		end
		result = result:gsub("%%rep%%","")
		return result
	end
	return textTable
end
--------------Translation Internal
function dgsTranslationAddPropertyListener(dgsEle,property)
	local translationListener = dgsElementData[dgsEle].translationListener or {}
	translationListener[property] = true
	return dgsSetData(dgsEle,"translationListener",translationListener)
end

function dgsTranslationRemovePropertyListener(dgsEle,property)
	local translationListener = dgsElementData[dgsEle].translationListener or {}
	translationListener[property] = nil
	return dgsSetData(dgsEle,"translationListener",translationListener)
end

function dgsGetTranslationFont(dgsEle,fontTable,sourceResource)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsTranslate",1,"dgs-dxelement")) end
	if type(fontTable) == "table" then
		local translation = dgsElementData[dgsEle]._translang or resourceTranslation[sourceResource or getThisResource()]
		local font = translation and LanguageTranslation[translation] and LanguageTranslation[translation][fontTable[1]] or fontTable[1]
		local fontType = dgsGetType(font)
		if fontType == "dx-font" then
			return font
		elseif fontType == "string" then
			if not(fontBuiltIn[font]) then return "default" end
			return font
		end
	end
	return false
end

function dgsApplyLanguageChange(name,translation,attach)
	for i=1,#attach do
		local dgsEle = attach[i]
		if isElement(dgsEle) then
			local dgsType = dgsGetType(dgsEle)
			if dgsOnTranslationUpdate[dgsType] then dgsOnTranslationUpdate[dgsType](dgsEle) else dgsOnTranslationUpdate.default(dgsEle) end
		end
	end
end

function dgsTranslate(dgsEle,textTable,sourceResource,skipPropertyListener)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsTranslate",1,"dgs-dxelement")) end
	local eleData = dgsElementData[dgsEle]
	if type(textTable) == "table" then
		local translation = eleData._translang or resourceTranslation[sourceResource or getThisResource()]
		local value = translation and LanguageTranslation[translation] and LanguageTranslation[translation][textTable[1]] or textTable[1]
		local result,status = value
		if type(value) == "table" then	--Conditional Translation
			--[[ --Conditional Translation
			TestText={
				"health == 'Superman'",				"You are a superman",
				"find({0}, health)",				"Your health is 0",
				"health <= 40",						"Your health is low",
				"health <= 60",						"Your health is medium",
				"health <= 80",						"Your health is high",
				"Your health is $health",
			},
			]]
			if #value%2 == 0 then error(dgsGenAsrt(dgsEle,"dgsTranslate",_,_,_,"Bad conditional translation item count (should be odd, got even), maybe missing default translation")) end
			result = value[#value]
			for i=1,#value-1,2 do --Odd item is conditional, Even item is translation, and skip default translation
				if not cTranslationBuffer[value[i]] then
					local fnc,err = loadstring("return "..value[i])
					if not fnc then error("Bad argument @dgsTranslate, failed to load conditional ("..err..") at dictionary:"..translation.."[\""..textTable[1].."\"]["..math.floor(i/2).."]") end
					cTranslationBuffer[value[i]] = fnc	--buffer
				end
				local condition = cTranslationBuffer[value[i]]
				setmetatable(textTable,cTranslationEnvMeta)
				setfenv(condition,textTable)
				status,result = pcall(condition)
				if status and result then
					result = value[i+1]
					break
				end
			end
			local count = 2
			while true do
				local textArg = textTable[count]
				if not textArg then break end
				if type(textArg) == "table" then
					textArg = dgsTranslate(dgsEle,textArg,sourceResource)
				end
				local _value = result:gsub("%%rep%%",textArg,1)
				if _value == result then break end
				count = count+1
				result = _value
			end
		else	--Replacing Translation
			local count = 2
			while true do
				local textArg = textTable[count]
				if not textArg then break end
				if type(textArg) == "table" then
					textArg = dgsTranslate(dgsEle,textArg,sourceResource)
				end
				local _value = value:gsub("%%rep%%",textArg,1)
				if _value == value then break end
				count = count+1
				result = _value
			end
		end
		for k,v in pairs(textTable) do
			if type(k) == "string" then
				result = result:gsub("$"..k,v)
			end
		end
		if not skipPropertyListener and eleData.translationListener then	--Dynamic Translation
			for property in pairs(eleData.translationListener) do
				local propertyValue = eleData[property]
				if type(propertyValue) == "table" then
					propertyValue = dgsTranslate(dgsEle,propertyValue,sourceResource,true)
				end
				result = result:gsub("$"..property,propertyValue)
			end
		end
		result = result:gsub("%%rep%%","")
		return result
	end
	return false
end
---------------DGS XML Loader
--[[
function dgsCreateFromXML(xmlFile)
	if getUserdataType(xmlFile) == "xml-node" then
		local createdTable = {}
		local elementIDUsed = {}
		local tree = function(xmlNode)
			local eleType = xmlNodeGetName(xmlNode)
			if eleType ~= "root" then
				local attrs = xmlNodeGetAttributes(xmlNode)
				
				
				
				local xmlChildren = xmlNodeGetChildren(xmlNode)
				for i=1,#xmlChildren do
					local child = xmlChildren[i]
					tree(child)
				end
			end
		end
	elseif type(xmlFile) == "string" then
		local pathOrStr = xmlFile
		local xml
		if not fileExists(pathOrStr) then
			if not fileExists(":"..getResourceName(sourceResource).."/"..pathOrStr) then
				xml = xmlLoadString(pathOrStr)
			else
				xml = xmlLoadFile(":"..getResourceName(sourceResource).."/"..pathOrStr)
			end
		else
			xml = xmlLoadFile(xmlFile)
		end
		local createdTable = dgsCreateFromXML(xml)
		xmlUnloadFile(xml)
		return createdTable
	end
end]]
---------------DGS 3D Common Functions
function dgs3DSetPosition(ele3D,x,y,z)
	if not(dgsIsType(ele3D,"dgsType3D")) then error(dgsGenAsrt(ele3D,"dgs3DSetPosition",1,"dgs-dx3delement")) end
	if not(type(x) == "number") then error(dgsGenAsrt(x,"dgs3DSetPosition",2,"number")) end
	if not(type(y) == "number") then error(dgsGenAsrt(y,"dgs3DSetPosition",3,"number")) end
	if not(type(z) == "number") then error(dgsGenAsrt(z,"dgs3DSetPosition",4,"number")) end
	return dgsSetData(ele3D,"position",{x,y,z})
end

function dgs3DGetPosition(ele3D)
	if not(dgsIsType(ele3D,"dgsType3D")) then error(dgsGenAsrt(ele3D,"dgs3DGetPosition",1,"dgs-dx3delement")) end
	local pos = dgsElementData[ele3D].position
	return pos[1],pos[2],pos[3]
end

function dgs3DSetInterior(ele3D,interior)
	if not(dgsIsType(ele3D,"dgsType3D")) then error(dgsGenAsrt(ele3D,"dgs3DSetInterior",1,"dgs-dx3delement")) end
	local inRange = interior >= -1
	if not(type(interior) == "number" and inRange) then error(dgsGenAsrt(interior,"dgs3DSetInterior",2,"number","-1~+∞",inRange and "Out Of Range")) end
	return dgsSetData(ele3D,"interior",interior-interior%1)
end

function dgs3DGetInterior(ele3D)
	if not(dgsIsType(ele3D,"dgsType3D")) then error(dgsGenAsrt(ele3D,"dgs3DGetInterior",1,"dgs-dx3delement")) end
	return dgsElementData[ele3D].interior or -1
end

function dgs3DSetDimension(ele3D,dimension)
	if not(dgsIsType(ele3D,"dgsType3D")) then error(dgsGenAsrt(ele3D,"dgs3DSetDimension",1,"dgs-dx3delement")) end
	local inRange = dimension >= -1 and dimension <= 65535
	if not(type(dimension) == "number" and dimension) then error(dgsGenAsrt(dimension,"dgs3DSetDimension",2,"number","-1~+∞",inRange and "Out Of Range")) end
	return dgsSetData(ele3D,"dimension",dimension-dimension%1)
end

function dgs3DGetDimension()
	if not(dgsIsType(ele3D,"dgsType3D")) then error(dgsGenAsrt(ele3D,"dgs3DGetDimension",1,"dgs-dx3delement")) end
	return dgsElementData[ele3D].dimension or -1
end