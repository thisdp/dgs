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
	onDGSElementCreate(menu,sRes)
	return menu
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
		[-3] = commandOrIsSeparator,	--Command
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

function dgsMenuRemoveItem(menu,uniqueID)
	local eleData = dgsElementData[menu]
	local itemMap = eleData.itemMap
	local item = itemMap[uniqueID]
	if not item then return end
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

addEventHandler("onDgsMenuHover",resourceRoot,function(nPreSelect,oPreSelect,nPreSelectDrawPos)
	if dgsGetType(source) == "dgs-dxmenu" then
		local eleData = dgsElementData[source]
		local itemMap = eleData.itemMap
		if isElement(eleData.subMenu) then
			destroyElement(eleData.subMenu)
			eleData.subMenu = nil
		end
		if nPreSelect ~= -1 and itemMap[nPreSelect] and #itemMap[nPreSelect] >= 1 then
			local width,height = eleData.absSize[1],eleData.absSize[2]
			eleData.subMenu = dgsCreateMenu(width,nPreSelectDrawPos,width,height,false,source)
			local subMenuEleData = dgsElementData[eleData.subMenu]
			subMenuEleData.itemData = itemMap[nPreSelect]
			subMenuEleData.itemMap = itemMap
			subMenuEleData.autoResizeMenu = true
		end
	end
end)

----------------------------------------------------------------
-----------------------PropertyListener-------------------------
----------------------------------------------------------------
dgsOnPropertyChange["dgs-dxmenu"] = {
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
	local buttonState = 1
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
	end
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
			dxDrawImage(x+drawPosX,y+drawPosY,drawWidth,itemHeight,itemImage[clickState],0,0,0,itemColor[clickState],isPostGUI,rndtgt)
			dgsDrawText(text,x+drawPosX+itemTextOffset,y+drawPosY,x+drawPosX+itemTextOffset+drawWidth,y+drawPosY+itemHeight,itemTextColor,itemTextSize[1],itemTextSize[2],font,"left","center",false,false,isPostGUI,colorCoded,subPixelPositioning,0,0,0,0,shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont)
			if #item >= 1 then
				dgsDrawText(">",x+w-padding[1],y+drawPosY,x+w-padding[1],y+drawPosY+itemHeight,itemTextColor,itemTextSize[1],itemTextSize[2],font,"right","center",false,false,isPostGUI,colorCoded,subPixelPositioning,0,0,0,0,shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont)
			end
			drawPosY = drawPosY+itemHeight
			drawPosY = drawPosY+itemGap
		end
	end
	if MouseData.entered == source then
		if preSelect ~= nPreSelect then
			eleData.preSelect = nPreSelect
			dgsTriggerEvent("onDgsMenuHover",source,nPreSelect,preSelect,nPreSelectDrawPos)
		end
	elseif not eleData.subMenu then
		nPreSelect = -1
		if preSelect ~= nPreSelect then
			eleData.preSelect = -1
			dgsTriggerEvent("onDgsMenuHover",source,nPreSelect,preSelect,nPreSelectDrawPos)
		end
	end

	return rndtgt,false,mx,my,0,0
end