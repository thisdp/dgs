dgsLogLuaMemory()
dgsRegisterType("dgs-dxmenu","dgsBasic","dgsType2D")
dgsRegisterProperties("dgs-dxmenu",{
})
--Dx Functions
local dxDrawLine = dxDrawLine
local dxDrawImage = dxDrawImage
local dxDrawImageSection = dxDrawImageSection
local dgsDrawText = dgsDrawText
local dxGetFontHeight = dxGetFontHeight
local dxDrawRectangle = dxDrawRectangle
local dxSetShaderValue = dxSetShaderValue
local dxGetPixelsSize = dxGetPixelsSize
local dxGetPixelColor = dxGetPixelColor
local dxSetRenderTarget = dxSetRenderTarget
local dxGetTextWidth = dxGetTextWidth
local dxSetBlendMode = dxSetBlendMode
--
local dgsTriggerEvent = dgsTriggerEvent
local createElement = createElement
local dgsSetType = dgsSetType
local dgsSetParent = dgsSetParent
local dgsSetData = dgsSetData
local dgsAttachToTranslation = dgsAttachToTranslation
local calculateGuiPositionSize = calculateGuiPositionSize
local assert = assert
local type = type

function dgsCreateMenu(...)
	local sRes = sourceResource or resource
	local x,y,w,h,text,relative,parent
	if select("#",...) == 1 and type(select(1,...)) == "table" then
		local argTable = ...
		x = argTable.x or argTable[1]
		y = argTable.y or argTable[2]
		w = argTable.width or argTable.w or argTable[3]
		h = argTable.height or argTable.h or argTable[4]
		relative = argTable.relative or argTable.rlt or argTable[5]
		parent = argTable.parent or argTable.p or argTable[6]
	else
		x,y,w,h,relative,parent,textColor = ...
	end
	if not(type(x) == "number") then error(dgsGenAsrt(x,"dgsCreateMenu",1,"number")) end
	if not(type(y) == "number") then error(dgsGenAsrt(y,"dgsCreateMenu",2,"number")) end
	if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsCreateMenu",3,"number")) end
	if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsCreateMenu",4,"number")) end
	local menu = createElement("dgs-dxmenu")
	dgsSetType(menu,"dgs-dxmenu")

	local res = sRes ~= resource and sRes or "global"
	local style = styleManager.styles[res]
	local using = style.using
	style = style.loaded[using]
	local systemFont = style.systemFontElement
	style = style.menu

	local normalImage = dgsCreateTextureFromStyle(using,res,style.itemImage[1])
	local hoveringImage = dgsCreateTextureFromStyle(using,res,style.itemImage[2])

	dgsElementData[menu] = {
		autoHide = true,	--Hide when mouse click

		bgColor = style.bgColor,
		bgImage = style.bgImage,
		itemData = {},
		itemHeight = style.itemHeight,
		itemGap = style.itemGap,
		itemColor = {style.itemColor[1],style.itemColor[2]},
		itemTextColor = style.itemTextColor,
		itemTextOffset = {style.itemTextOffset[1],style.itemTextOffset[2]},
		itemImage = {normalImage,hoveringImage},
		itemTextSize = {style.itemTextSize[1],style.itemTextSize[2]},
		itemIconSize = {1,1,true},
		itemIconOffset = {0,0,false},
		-- to do

		padding = {style.padding[1],style.padding[2]},
		colorCoded = false,
		font = style.font or systemFont,
		separatorHeight = style.separatorHeight,
		separatorTextColor = style.separatorTextColor,
		separatorGap = style.separatorGap,
		separatorLine = {style.separatorLine[1],style.separatorLine[2],style.separatorLine[3]},
		itemUniqueIndex = 0,
		itemMap = {},
		subMenu = nil,
		preSelect = -1,
		childOutsideHit = true,
	}
	dgsElementData[menu].itemMap[0] = dgsElementData[menu].itemData
	dgsSetParent(menu,parent,true,true)
	dgsAttachToTranslation(menu,resourceTranslation[sRes])
	calculateGuiPositionSize(menu,x,y,relative or false,w,h,relative or false,true)
	dgsApplyGeneralProperties(menu,sRes)
	if not isElement(parent) or getElementType(parent) ~= "dgs-dxmenu" then
		addEventHandler("onDgsBlur",menu,function()
			dgsMenuHide(menu)
		end,false,"LOW")
	end
	onDGSElementCreate(menu,sRes)
	dgsMenuHide(menu)
	return menu
end

function dgsMenuClean(menu)
	if not dgsIsType(menu,"dgs-dxmenu") then error(dgsGenAsrt(menu,"dgsMenuClean",1,"dgs-dxmenu")) end
	local eleData = dgsElementData[menu]
	if isElement(eleData.subMenu) then
		destroyElement(eleData.subMenu)
	end
	eleData.subMenu = nil
	return true
end

function dgsMenuShow(menu,x,y)
	if not dgsIsType(menu,"dgs-dxmenu") then error(dgsGenAsrt(menu,"dgsMenuShow",1,"dgs-dxmenu")) end
	dgsSetVisible(menu,true)
	if not x or not y then
		x,y = dgsGetCursorPosition()
	end
	dgsSetPosition(menu,x,y,false)
	dgsBringToFront(menu)
end

function dgsMenuHide(menu)
	if not dgsIsType(menu,"dgs-dxmenu") then error(dgsGenAsrt(menu,"dgsMenuHide",1,"dgs-dxmenu")) end
	dgsBlur(menu)
	dgsMenuClean(menu)
	dgsSetVisible(menu,false)
end

function dgsMenuAutoResize(menu)
	local eleData = dgsElementData[menu]
	local itemData = eleData.itemData
	local itemHeight = eleData.itemHeight
	local itemGap = eleData.itemGap/2
	local padding = eleData.padding

	local separatorHeight = eleData.separatorHeight
	local separatorGap = eleData.separatorGap/2

	local drawPosY = padding[2]

	for itemIndex = 1, #itemData do
		local item = itemData[itemIndex]
		local commandOrIsSeparator = item[-3]
		if commandOrIsSeparator == true then
			drawPosY = drawPosY+separatorGap
			drawPosY = drawPosY+separatorHeight
			drawPosY = drawPosY+separatorGap
		else
			drawPosY = drawPosY+itemGap
			drawPosY = drawPosY+itemHeight
			drawPosY = drawPosY+itemGap
		end
	end
	eleData.autoResizeMenu = false
	dgsSetSize(menu,_,drawPosY+padding[2],false)
end

function dgsMenuAddItem(menu,text,command,parentItemID,pos)
	if not dgsIsType(menu,"dgs-dxmenu") then error(dgsGenAsrt(menu,"dgsMenuAddItem",1,"dgs-dxmenu")) end
	local eleData = dgsElementData[menu]
	local itemData = eleData.itemData
	local itemMap = eleData.itemMap
	local parentItem
	if parentItemID and not itemMap[parentItemID] then return end	--Error
	eleData.itemUniqueIndex = eleData.itemUniqueIndex+1
	local item = {
		[-7] = nil,						--ColorCoded
		[-6] = nil,						--Text Size
		[-5] = nil,						--Text Color
		[-4] = true,					--Selectable
		[-3] = command,					--Command
		[-2] = text,					--Text
		[-1] = eleData.itemUniqueIndex,	--Unique Index
		[0] = parentItemID or 0,	--Parent Item Unique Index
	}
	itemMap[eleData.itemUniqueIndex] = item
	pos = pos or #itemMap[item[0]]+1
	table.insert(itemMap[item[0]],pos,item)
	eleData.autoResizeMenu = true
	return eleData.itemUniqueIndex,pos
end

function dgsMenuAddSeparator(menu,text,parentItemID,pos)
	if not dgsIsType(menu,"dgs-dxmenu") then error(dgsGenAsrt(menu,"dgsMenuAddSeparator",1,"dgs-dxmenu")) end
	local eleData = dgsElementData[menu]
	local itemData = eleData.itemData
	local itemMap = eleData.itemMap
	local parentItem
	if parentItemID and not itemMap[parentItemID] then return end	--Error
	eleData.itemUniqueIndex = eleData.itemUniqueIndex+1
	local item = {
		[-7] = nil,						--ColorCoded
		[-6] = nil,						--Text Size
		[-5] = nil,						--Text Color
		[-4] = true,					--Selectable
		[-3] = true,					--Command
		[-2] = text,					--Text
		[-1] = eleData.itemUniqueIndex,	--Unique Index
		[0] = parentItemID or 0,	--Parent Item Unique Index
	}
	itemMap[eleData.itemUniqueIndex] = item
	pos = pos or #itemMap[item[0]]+1
	table.insert(itemMap[item[0]],pos,item)
	eleData.autoResizeMenu = true
	return eleData.itemUniqueIndex,pos
end

function dgsMenuGetItemCommand(menu,uniqueID)
	if not dgsIsType(menu,"dgs-dxmenu") then error(dgsGenAsrt(menu,"dgsMenuGetItemCommand",1,"dgs-dxmenu")) end
	if type(uniqueID) ~= "number" then error(dgsGenAsrt(menu,"dgsMenuGetItemCommand",2,"number")) end
	local eleData = dgsElementData[menu]
	local itemMap = eleData.itemMap
	local item = itemMap[uniqueID]
	if not item then error(dgsGenAsrt(menu,"dgsMenuGetItemCommand",2,_,_,"Invalid index '"..tostring(uniqueID).."'")) end
	return item[-3]
end

function dgsMenuSetItemCommand(menu,uniqueID,command)
	if not dgsIsType(menu,"dgs-dxmenu") then error(dgsGenAsrt(menu,"dgsMenuSetItemCommand",1,"dgs-dxmenu")) end
	if type(uniqueID) ~= "number" then error(dgsGenAsrt(menu,"dgsMenuSetItemCommand",2,"number")) end
	local eleData = dgsElementData[menu]
	local itemMap = eleData.itemMap
	local item = itemMap[uniqueID]
	if not item then error(dgsGenAsrt(menu,"dgsMenuSetItemCommand",2,_,_,"Invalid index '"..tostring(uniqueID).."'")) end
	item[-3] = command
	eleData.autoResizeMenu = true
	return true
end

function dgsMenuGetItemText(menu,uniqueID)
	if not dgsIsType(menu,"dgs-dxmenu") then error(dgsGenAsrt(menu,"dgsMenuGetItemText",1,"dgs-dxmenu")) end
	if type(uniqueID) ~= "number" then error(dgsGenAsrt(menu,"dgsMenuGetItemText",2,"number")) end
	local eleData = dgsElementData[menu]
	local itemMap = eleData.itemMap
	local item = itemMap[uniqueID]
	if not item then error(dgsGenAsrt(menu,"dgsMenuGetItemText",2,_,_,"Invalid index '"..tostring(uniqueID).."'")) end
	return item[-2]
end

function dgsMenuSetItemText(menu,uniqueID,text)
	if not dgsIsType(menu,"dgs-dxmenu") then error(dgsGenAsrt(menu,"dgsMenuSetItemText",1,"dgs-dxmenu")) end
	if type(uniqueID) ~= "number" then error(dgsGenAsrt(menu,"dgsMenuSetItemText",2,"number")) end
	local eleData = dgsElementData[menu]
	local itemMap = eleData.itemMap
	local item = itemMap[uniqueID]
	if not item then error(dgsGenAsrt(menu,"dgsMenuSetItemText",2,_,_,"Invalid index '"..tostring(uniqueID).."'")) end
	item[-2] = text
	return true
end

function dgsMenuGetItemColor(menu,uniqueID,notSplitColor)
	if not dgsIsType(menu,"dgs-dxmenu") then error(dgsGenAsrt(menu,"dgsMenuGetItemColor",1,"dgs-dxmenu")) end
	if type(uniqueID) ~= "number" then error(dgsGenAsrt(menu,"dgsMenuGetItemColor",2,"number")) end
	local eleData = dgsElementData[menu]
	local itemMap = eleData.itemMap
	local item = itemMap[uniqueID]
	if not item then error(dgsGenAsrt(menu,"dgsMenuGetItemColor",2,_,_,"Invalid index '"..tostring(uniqueID).."'")) end
	if notSplitColor then
		return item[-5][1],item[-5][2]
	else
		local dR,dG,dB,dA = fromColor(item[-5][1])
		local hR,hG,hB,hA = fromColor(item[-5][2])
		return dR,dG,dB,dA,hR,hG,hB,hA
	end
end

function dgsMenuSetItemColor(menu,uniqueID,...)
	if not dgsIsType(menu,"dgs-dxmenu") then error(dgsGenAsrt(menu,"dgsMenuSetItemColor",1,"dgs-dxmenu")) end
	if type(uniqueID) ~= "number" then error(dgsGenAsrt(menu,"dgsMenuSetItemColor",2,"number")) end
	local eleData = dgsElementData[menu]
	local itemMap = eleData.itemMap
	local item = itemMap[uniqueID]
	if not item then error(dgsGenAsrt(menu,"dgsMenuSetItemColor",2,_,_,"Invalid index '"..tostring(uniqueID).."'")) end
	--Deal with the color
	local colors
	local args = {...}
	if #args == 0 then
		error(dgsGenAsrt(args[1],"dgsMenuSetItemColor",3,"table/number"))
	elseif #args == 1 then
		if type(args[1]) == "table" then
			colors = {args[1][1],args[1][2] or args[1][1]}
		else
			colors = {args[1],args[1]}
		end
	elseif #args >= 3 then
		if not (type(args[1]) == "number") then error(dgsGenAsrt(args[1],"dgsMenuSetItemColor",2,"number")) end
		if not (type(args[2]) == "number") then error(dgsGenAsrt(args[2],"dgsMenuSetItemColor",3,"number")) end
		if not (type(args[3]) == "number") then error(dgsGenAsrt(args[3],"dgsMenuSetItemColor",4,"number")) end
		if not (not args[4] or type(args[4]) == "number") then error(dgsGenAsrt(args[4],"dgsMenuSetItemColor",5,"nil/number")) end
		local clr = tocolor(...)
		colors = {clr,clr}
	end
	item[-5] = colors
	return true
end

function dgsMenuGetItemTextSize(menu,uniqueID)
	if not dgsIsType(menu,"dgs-dxmenu") then error(dgsGenAsrt(menu,"dgsMenuGetItemTextSize",1,"dgs-dxmenu")) end
	if type(uniqueID) ~= "number" then error(dgsGenAsrt(menu,"dgsMenuGetItemTextSize",2,"number")) end
	local eleData = dgsElementData[menu]
	local itemMap = eleData.itemMap
	local item = itemMap[uniqueID]
	if not item then error(dgsGenAsrt(menu,"dgsMenuGetItemTextSize",2,_,_,"Invalid index '"..tostring(uniqueID).."'")) end
	return item[-6][1],item[-6][2]
end

function dgsMenuSetItemTextSize(menu,uniqueID,textSizeX,textSizeY)
	if not dgsIsType(menu,"dgs-dxmenu") then error(dgsGenAsrt(menu,"dgsMenuSetItemTextSize",1,"dgs-dxmenu")) end
	if type(uniqueID) ~= "number" then error(dgsGenAsrt(menu,"dgsMenuSetItemTextSize",2,"number")) end
	local eleData = dgsElementData[menu]
	local itemMap = eleData.itemMap
	local item = itemMap[uniqueID]
	if not item then error(dgsGenAsrt(menu,"dgsMenuSetItemTextSize",2,_,_,"Invalid index '"..tostring(uniqueID).."'")) end
	item[-6][1] = textSizeX
	item[-6][2] = textSizeY or textSizeX
	return true
end

function dgsMenuRemoveItem(menu,uniqueID)
	if not dgsIsType(menu,"dgs-dxmenu") then error(dgsGenAsrt(menu,"dgsMenuRemoveItem",1,"dgs-dxmenu")) end
	if type(uniqueID) ~= "number" then error(dgsGenAsrt(menu,"dgsMenuRemoveItem",2,"number")) end
	local eleData = dgsElementData[menu]
	local itemMap = eleData.itemMap
	local item = itemMap[uniqueID]
	if not item then return false end
	if item[3] then	--If has children
		for i=1,#item[3] do
			item[3][i][0] = nil	--Skip parent
			dgsMenuRemoveItem(menu,item[3][i][-1])
		end
	end
	local parentUniqueID = item[0]	--Get parent item id if exist
	if parentUniqueID then	--If has parent
		if parentUniqueID == 0 then	--Root
			for i=1,#eleData.itemData do	--Find item in root
				if eleData.itemData[i] == item then
					table.remove(eleData.itemData[i],item)	--Remove from root
				end
			end
		else
			local parent = itemMap[parentUniqueID]
			if parent and parent[3] then
				for i=1,#parent[3] do	--Find item in parent
					if parent[3][i] == item then
						table.remove(parent[3],i)	--Remove from parent
					end
				end
			end
		end
	end
	itemMap[uniqueID] = nil
	eleData.autoResizeMenu = true
	return true
end

function onDgsMenuHover(source,nPreSelect,nPreSelectDrawPos)
	local eleData = dgsElementData[source]
	local rootMenu = eleData.rootMenu or source
	local itemMap = eleData.itemMap
	dgsMenuClean(source)
	if nPreSelect ~= -1 and itemMap[nPreSelect] and #itemMap[nPreSelect] >= 1 then
		local width,height = eleData.absSize[1],eleData.absSize[2]
		local padding = eleData.padding
		eleData.subMenu = dgsCreateMenu(width,nPreSelectDrawPos-padding[2],width,height,false,source)
		local subMenuEleData = dgsElementData[eleData.subMenu]
		subMenuEleData.itemData = itemMap[nPreSelect]
		subMenuEleData.itemMap = itemMap
		subMenuEleData.autoResizeMenu = true
		subMenuEleData.rootMenu = eleData.rootMenu or source
		dgsMenuShow(eleData.subMenu,width,nPreSelectDrawPos-padding[2])
	end
	dgsTriggerEvent("onDgsMenuHover",rootMenu,source,nPreSelect,nPreSelectDrawPos)
end

----------------------------------------------------------------
----------------------OnMouseClickAction------------------------
----------------------------------------------------------------
dgsOnMouseClickAction["dgs-dxmenu"] = function(dgsEle,button,state)
	if state ~= "up" then return end
	local eleData = dgsElementData[dgsEle]
	local rootMenu = eleData.rootMenu or dgsEle
	dgsTriggerEvent("onDgsMenuSelect",rootMenu,dgsEle,eleData.preSelect)
end
----------------------------------------------------------------
-----------------------PropertyListener-------------------------
----------------------------------------------------------------
dgsOnPropertyChange["dgs-dxmenu"] = {
	visible = function(source)
		
	end,
}
----------------------------------------------------------------
------------------------PreRenderer-----------------------------
----------------------------------------------------------------
dgsPreRenderer["dgs-dxmenu"] = function(source)
	local eleData = dgsElementData[source]
	if eleData.autoResizeMenu then
		dgsMenuAutoResize(source)
	end
end
----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxmenu"] = function(source,x,y,w,h,mx,my,cx,cy,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt)
	local itemData = eleData.itemData
	local itemHeight = eleData.itemHeight
	local itemGap = eleData.itemGap/2
	--[[local buttonState = 1
	if MouseData.entered == source then
		buttonState = 2
		if eleData.clickType == 1 then
			if MouseData.click.left == source then
				buttonState = 3
			end
		elseif eleData.clickType == 2 then
			if MouseData.click.right == source then
				buttonState = 3
			end
		else
			if MouseData.click.left == source or MouseData.click.right == source then
				buttonState = 3
			end
		end
	end]]
	local bgImage = eleData.bgImage
	local bgColor = eleData.bgColor
	dxDrawImage(x,y,w,h,bgImage,0,0,0,bgColor,isPostGUI,rndtgt)
	local itemColor = eleData.itemColor
	local itemTextColor = eleData.itemTextColor
	local separatorTextColor = eleData.separatorTextColor
	local itemImage = eleData.itemImage
	local itemTextSize = eleData.itemTextSize
	local itemTextOffset = eleData.itemTextOffset[2] and eleData.itemTextOffset[1]*w or eleData.itemTextOffset[1]
	local colorCoded = eleData.colorCoded
	local padding = eleData.padding
	local font = eleData.font
	local drawWidth = w-padding[2]*2
	local drawPosX = padding[1]
	local drawPosY = padding[2]

	local separatorHeight = eleData.separatorHeight
	local separatorLineStart = eleData.separatorLine[3] and eleData.separatorLine[1]*drawWidth or eleData.separatorLine[1]
	local separatorLineEnd = eleData.separatorLine[3] and eleData.separatorLine[2]*drawWidth or eleData.separatorLine[2]
	local separatorGap = eleData.separatorGap/2
	local preSelect = eleData.preSelect

	local nPreSelect = -1
	local nPreSelectDrawPos = -1
	for itemIndex = 1, #itemData do
		local item = itemData[itemIndex]
		local itemUniqueID = item[-1]
		local text = item[-2]
		local commandOrIsSeparator = item[-3]
		local selectable = item[-4]
		local textColor = item[-5] or itemTextColor
		if commandOrIsSeparator == true then
			drawPosY = drawPosY+separatorGap
			if text == nil then	--If no text specified, use "line" instead
				dxDrawImage(x+drawPosX+separatorLineStart,y+drawPosY,separatorLineEnd-separatorLineStart,separatorHeight,_,0,0,0,separatorTextColor,isPostGUI,rndtgt)
			else	--Use text
				dgsDrawText(text,x+drawPosX+itemTextOffset,y+drawPosY,x+drawPosX+itemTextOffset+drawWidth,y+drawPosY+itemHeight,separatorTextColor,itemTextSize[1],itemTextSize[2],font,"left","center",false,false,isPostGUI,colorCoded,subPixelPositioning,0,0,0,0,shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont)
			end
			drawPosY = drawPosY+separatorHeight
			drawPosY = drawPosY+separatorGap
		else
			drawPosY = drawPosY+itemGap
			if MouseData.entered == source and my-cy >= drawPosY and my-cy <= drawPosY+itemHeight and selectable then
				nPreSelect = itemUniqueID	--Record unique index
				nPreSelectDrawPos = drawPosY
			end
			local clickState = 1
			if preSelect == itemUniqueID then
				clickState = 2
			end
			if type(textColor) == "table" then
				textColor = textColor[clickState]
			end
			dxDrawImage(x+drawPosX,y+drawPosY,drawWidth,itemHeight,itemImage[clickState],0,0,0,itemColor[clickState],isPostGUI,rndtgt)
			dgsDrawText(text,x+drawPosX+itemTextOffset,y+drawPosY,x+drawPosX+itemTextOffset+drawWidth,y+drawPosY+itemHeight,textColor,itemTextSize[1],itemTextSize[2],font,"left","center",false,false,isPostGUI,colorCoded,subPixelPositioning,0,0,0,0,shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont)
			if #item >= 1 then
				dgsDrawText(">",x+w-padding[1],y+drawPosY,x+w-padding[1],y+drawPosY+itemHeight,textColor,itemTextSize[1],itemTextSize[2],font,"right","center",false,false,isPostGUI,colorCoded,subPixelPositioning,0,0,0,0,shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont)
			end
			drawPosY = drawPosY+itemHeight
			drawPosY = drawPosY+itemGap
		end
	end
	if MouseData.entered == source then
		if preSelect ~= nPreSelect then
			eleData.preSelect = nPreSelect
			onDgsMenuHover(source,nPreSelect,nPreSelectDrawPos)
		end
	elseif not eleData.subMenu then
		nPreSelect = -1
		if preSelect ~= nPreSelect then
			eleData.preSelect = -1
			onDgsMenuHover(source,nPreSelect,nPreSelectDrawPos)
		end
	end

	return rndtgt,false,mx,my,0,0
end