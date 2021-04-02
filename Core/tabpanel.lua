--Dx Functions
local dxDrawImage = dxDrawImageExt
local _dxDrawImage = _dxDrawImage
local dxDrawText = dxDrawText
local dxDrawRectangle = dxDrawRectangle
local dxSetRenderTarget = dxSetRenderTarget
local dxGetTextWidth = dxGetTextWidth
local dxSetBlendMode = dxSetBlendMode
local dxCreateRenderTarget = dxCreateRenderTarget
--DGS Functions
local dgsSetType = dgsSetType
local dgsGetType = dgsGetType
local dgsSetParent = dgsSetParent
local dgsSetData = dgsSetData
local applyColorAlpha = applyColorAlpha
local dgsTranslate = dgsTranslate
local dgsAttachToTranslation = dgsAttachToTranslation
local dgsAttachToAutoDestroy = dgsAttachToAutoDestroy
local calculateGuiPositionSize = calculateGuiPositionSize
local dgsCreateTextureFromStyle = dgsCreateTextureFromStyle
--Utilities
local isElement = isElement
local destroyElement = destroyElement
local triggerEvent = triggerEvent
local createElement = createElement
local assert = assert
local tonumber = tonumber
local type = type
local mathClamp = math.restrict
local mathMin = math.min
local mathFloor = math.floor
local mathInRange = math.inRange
local tableInsert = table.insert
local tableRemove = table.remove

function dgsCreateTabPanel(...)
	local x,y,w,h,relative,parent,tabHeight,bgImage,bgColor
	if select("#",...) == 1 and type(select(1,...)) == "table" then
		local argTable = ...
		x = argTable.x or argTable[1]
		y = argTable.y or argTable[2]
		w = argTable.width or argTable.w or argTable[3]
		h = argTable.height or argTable.h or argTable[4]
		relative = argTable.relative or argTable.rlt or argTable[5]
		parent = argTable.parent or argTable.p or argTable[6]
		tabHeight = argTable.tabHeight or argTable[7]
		bgImage = argTable.bgImage or argTable[8]
		bgColor = argTable.bgColor or argTable[9]
	else
		x,y,w,h,relative,parent,tabHeight,bgImage,bgColor = ...
	end
	if not(type(x) == "number") then error(dgsGenAsrt(x,"dgsCreateTabPanel",1,"number")) end
	if not(type(y) == "number") then error(dgsGenAsrt(y,"dgsCreateTabPanel",2,"number")) end
	if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsCreateTabPanel",3,"number")) end
	if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsCreateTabPanel",4,"number")) end
	if bgImage then
		if not dgsIsMaterialElement(bgImage) then error(dgsGenAsrt(bgImage,"dgsCreateTabPanel",8,"material")) end
	end
	local tabpanel = createElement("dgs-dxtabpanel")
	dgsSetType(tabpanel,"dgs-dxtabpanel")
	dgsSetParent(tabpanel,parent,true,true)
	local style = styleSettings.tabpanel
	local tabHeight = tabHeight or style.tabHeight
	dgsElementData[tabpanel] = {
		tabHeight = {tabHeight,false},
		tabMaxWidth = {10000,false},
		tabMinWidth = {10,false},
		bgColor = tonumber(bgColor) or style.bgColor,
		bgImage = bgImage or dgsCreateTextureFromStyle(style.bgImage),
		tabs = {},
		font = style.font or systemFont,
		selected = -1,
		preSelect = -1,
		tabPadding = style.tabPadding,
		tabGapSize = style.tabGapSize,
		scrollSpeed = style.scrollSpeed,
		showPos = 0,
		tabLengthAll = 0,
		colorcoded = false,
		wordbreak = false,
		tabAlignment = "left",
		tabOffset = {0,false},
	}
	calculateGuiPositionSize(tabpanel,x,y,relative,w,h,relative,true)
	local renderTarget,err = dxCreateRenderTarget(dgsElementData[tabpanel].absSize[1],tabHeight,true,tabpanel)
	if renderTarget ~= false then
		dgsAttachToAutoDestroy(renderTarget,tabpanel,-1)
	else
		outputDebugString(err,2)
	end
	dgsElementData[tabpanel].renderTarget = renderTarget
	dgsAddEventHandler("onDgsSizeChange",tabpanel,"configTabPanelWhenResize",false)
	triggerEvent("onDgsCreate",tabpanel,sourceResource)
	return tabpanel
end

function configTabPanelWhenResize()
	dgsElementData[source].configNextFrame = true
end

function dgsCreateTab(...)
	local text,tabpanel,scaleX,scaleY,textColor,bgImage,bgColor,nImage,hImage,cImage,nColor,hColor,cColor
	if select("#",...) == 1 and type(select(1,...)) == "table" then
		local argTable = ...
		text = argTable.text or argTable.txt or argTable[1]
		tabpanel = argTable.parent or argTable.tabPanel or argTable.tabpanel or argTable[2]
		scaleX = argTable.scaleX or argTable[3]
		scaleY = argTable.scaleY or argTable[4]
		textColor = argTable.textColor or argTable[5]
		bgImage = argTable.bgImage or argTable[6]
		bgColor = argTable.bgColor or argTable[7]
		nImage = argTable.normalImage or argTable.nImage or argTable[8]
		hImage = argTable.hoveringImage or argTable.hImage or argTable[9]
		cImage = argTable.clickedImage or argTable.cImage or argTable[10]
		nColor = argTable.normalColor or argTable.nColor or argTable[11]
		hColor = argTable.hoveringColor or argTable.hColor or argTable[12]
		cColor = argTable.clickedColor or argTable.cColor or argTable[13]
	else
		text,tabpanel,scaleX,scaleY,textColor,bgImage,bgColor,nImage,hImage,cImage,nColor,hColor,cColor = ...
	end
	if not dgsIsType(tabpanel,"dgs-dxtabpanel") then error(dgsGenAsrt(tabpanel,"dgsCreateTab",2,"dgs-dxtabpanel")) end
	local tab = createElement("dgs-dxtab")
	dgsSetType(tab,"dgs-dxtab")
	dgsSetParent(tab,tabpanel,true,true)
	local style = styleSettings.tab
	local eleData = dgsElementData[tabpanel]
	local pTextColor = eleData.textColor
	local w = eleData.absSize[1]
	local tabs = eleData.tabs
	local id = #tabs+1
	tableInsert(tabs,id,tab)
	local font = style.font or eleData.font
	local t_minWid,t_maxWid = eleData.tabMinWidth,eleData.tabMaxWidth
	local minwidth,maxwidth = t_minWid[2] and t_minWid[1]*w or t_minWid[1],t_maxWid[2] and t_maxWid[1]*w or t_maxWid[1]
	local wid = mathClamp(dxGetTextWidth(text,scaleX or 1,font),minwidth,maxwidth)
	local tabPadding = eleData.tabPadding
	local padding = tabPadding[2] and tabPadding[1]*w or tabPadding[1]
	local tabGapSize = eleData.tabGapSize
	local gapSize = tabGapSize[2] and tabGapSize[1]*w or tabGapSize[1]
	local textSizeX,textSizeY = tonumber(scaleX) or style.textSize[1], tonumber(scaleY) or style.textSize[2]
	local nImage = nImage or dgsCreateTextureFromStyle(style.tabImage[1])
	local hImage = hImage or dgsCreateTextureFromStyle(style.tabImage[2])
	local cImage = cImage or dgsCreateTextureFromStyle(style.tabImage[3])
	local nColor = nColor or style.tabColor[1]
	local hColor = hColor or style.tabColor[2]
	local cColor = cColor or style.tabColor[3]
	dgsElementData[tab] = {
		parent = tabpanel,
		id = id,
		font = style.font or systemFont,
		tabLengthAll = eleData.tabLengthAll+wid+padding*2+gapSize*mathMin(#tabs,1),
		width = wid,
		textColor = tonumber(textColor) or style.textColor or pTextColor,
		textSize = {textSizeX,textSizeY},
		bgColor = tonumber(bgColor) or style.bgColor or eleData.bgColor,
		bgImage = bgImage or dgsCreateTextureFromStyle(style.bgImage) or eleData.bgImage,
		tabImage = {nImage,hImage,cImage},
		tabColor = {nColor,hColor,cColor},
		iconColor = 0xFFFFFFFF,
		iconDirection = "left",
		iconImage = nil,
		iconOffset = 5,
		iconSize = {1,1,true}, -- Text's font heigh,
		colorcoded = nil,
		wordbreak = nil,
	}
	if eleData.selected == -1 then eleData.selected = id end
	dgsAttachToTranslation(tab,resourceTranslation[sourceResource or resource])
	if type(text) == "table" then
		dgsElementData[tab]._translationText = text
		dgsSetData(tab,"text",text)
	else
		dgsSetData(tab,"text",tostring(text))
	end
	triggerEvent("onDgsCreate",tab)
	return tab
end

function dgsTabPanelGetWidth(tabpanel,includeInvisible)
	if not dgsIsType(tabpanel,"dgs-dxtabpanel") then error(dgsGenAsrt(tabpanel,"dgsTabPanelGetWidth",1,"dgs-dxtabpanel")) end
	local wid,cnt = 0,0
	local eleData = dgsElementData[tabpanel]
	local w = eleData.absSize[1]
	local tabs = eleData.tabs
	local tabPadding,tabGapSize = eleData.tabPadding,eleData.tabGapSize
	local padding = tabPadding[2] and tabPadding[1]*w or tabPadding[1]
	local gapSize = tabGapSize[2] and tabGapSize[1]*w or tabGapSize[1]
	if includeInvisible then
		for i=1,#tabs do
			local tab = tabs[i]
			local width = dgsElementData[tab].width
			wid = wid+width
			cnt=cnt+1
		end
	else
		for i=1,#tabs do
			local tab = tabs[i]
			if dgsElementData[tab].visible then
				local width = dgsElementData[tab].width
				wid = wid+width
				cnt=cnt+1
			end
		end
	end
	return wid+(cnt-1)*gapSize+padding*2*cnt
end

function dgsTabPanelGetTabFromID(tabpanel,id)
	if not dgsIsType(tabpanel,"dgs-dxtabpanel") then error(dgsGenAsrt(tabpanel,"dgsTabPanelGetTabFromID",1,"dgs-dxtabpanel")) end
	if not(type(id) == "number") then error(dgsGenAsrt(id,"dgsTabPanelGetTabFromID",1,"number")) end
	return dgsElementData[tabpanel].tabs[id]
end

function dgsTabPanelMoveTab(tabpanel,from,to)
	if not dgsIsType(tabpanel,"dgs-dxtabpanel") then error(dgsGenAsrt(tabpanel,"dgsTabPanelMoveTab",1,"dgs-dxtabpanel")) end
	if not(type(from) == "number") then error(dgsGenAsrt(from,"dgsTabPanelGetTabFromID",2,"number")) end
	if not(type(to) == "number") then error(dgsGenAsrt(to,"dgsTabPanelGetTabFromID",3,"number")) end
	local tab = dgsElementData[tabpanel].tabs[from]
	local myid = dgsElementData[tab].id
	local parent = dgsElementData[tab].parent
	local tabs = dgsElementData[parent].tabs
	for i=myid+1,#tabs do
		local _tab = tabs[i]
		dgsElementData[_tab].id = dgsElementData[_tab].id-1
	end
	tableRemove(tabs,myid)
	for i=to,#tabs do
		local _tab = tabs[i]
		dgsElementData[_tab].id = dgsElementData[_tab].id+1
	end
	tableInsert(tabs,to,tab)
	return true
end

function dgsTabPanelGetTabID(tab)
	if not dgsIsType(tab,"dgs-dxtab") then error(dgsGenAsrt(tab,"dgsTabPanelGetTabID",1,"dgs-dxtab")) end
	return dgsElementData[tab].id
end

function dgsDeleteTab(tab)
	if not dgsIsType(tab,"dgs-dxtab") then error(dgsGenAsrt(tab,"dgsDeleteTab",1,"dgs-dxtab")) end
	local tabpanel = dgsElementData[tab].parent
	local eleData = dgsElementData[tabpanel]
	if dgsGetType(tabpanel) == "dgs-dxtabpanel" then
		local w = eleData.absSize[1]
		local tabWidth = dgsElementData[tab].width
		local tabs = eleData.tabs
		local tabPadding = eleData.tabPadding
		local padding = tabPadding[2] and tabPadding[1]*w or tabPadding[1]
		local tabGapSize = eleData.tabGapSize
		local gapSize = tabGapSize[2] and tabGapSize[1]*w or tabGapSize[1]
		dgsSetData(tabpanel,"tabLengthAll",eleData.tabLengthAll-tabWidth-padding*2-gapSize*mathMin(#tabs,1))
		local id = dgsElementData[tab].id
		for i=id,#tabs do
			dgsElementData[tabs[i]].id = dgsElementData[tabs[i]].id-1
		end
		tableRemove(tabs,id)
	end
	for k,v in pairs(dgsGetChildren(tab)) do
		destroyElement(v)
	end
	dgsElementData[tab].isRemove = true
	destroyElement(tab)
	return true
end

function configTabPanel(source)
	local sx,sy = dgsElementData[source].absSize[1],dgsElementData[source].absSize[2]
	local tabHeight = dgsElementData[source].tabHeight
	local rentarg = dgsElementData[source].renderTarget
	if isElement(rentarg) then destroyElement(rentarg) end
	local renderTarget,err = dxCreateRenderTarget(sx,tabHeight[2] and tabHeight[1]*sy or tabHeight[1],true,source)
	if renderTarget ~= false then
		dgsAttachToAutoDestroy(renderTarget,source,-1)
	else
		outputDebugString(err,2)
	end
	dgsSetData(source,"renderTarget",renderTarget)
	dgsElementData[source].configNextFrame = false
end

function dgsGetSelectedTab(tabpanel,useNumber)
	if not dgsIsType(tabpanel,"dgs-dxtabpanel") then error(dgsGenAsrt(tabpanel,"dgsGetSelectedTab",1,"dgs-dxtabpanel")) end
	local id = dgsElementData[tabpanel].selected
	local tabs = dgsElementData[tabpanel].tabs
	if useNumber then
		return id
	else
		return tabs[id] or false
	end
end

function dgsSetSelectedTab(tabpanel,id)
	if not dgsIsType(tabpanel,"dgs-dxtabpanel") then error(dgsGenAsrt(tabpanel,"dgsSetSelectedTab",1,"dgs-dxtabpanel")) end
	local idtype = dgsGetType(id)
	if not(idtype=="number" or idtype=="dgs-dxtab") then error(dgsGenAsrt(idtype,"dgsSetSelectedTab",2,"number/dgs-dxtab")) end
	local tabs = dgsElementData[tabpanel].tabs
	id = idtype == "dgs-dxtab" and dgsElementData[id].id or id
	if mathInRange(1,#tabs,id) then
		return dgsSetData(tabpanel,"selected",id)
	end
	return false
end

----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxtabpanel"] = function(source,x,y,w,h,mx,my,cx,cy,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt,xRT,yRT,xNRT,yNRT,OffsetX,OffsetY,visible)
	if eleData.configNextFrame then configTabPanel(source) end
	eleData.rndPreSelect = -1
	local selected = eleData.selected
	local tabs = eleData.tabs
	local height = eleData.tabHeight[2] and eleData.tabHeight[1]*h or eleData.tabHeight[1]
	local font = eleData.font or systemFont
	local colorcoded = eleData.colorcoded
	local wordbreak = eleData.wordbreak
	local tabAlignment = eleData.tabAlignment
	if selected == -1 then
		dxDrawRectangle(x,y+height,w,h-height,eleData.bgColor,isPostGUI)
	else
		local rendt = eleData.renderTarget
		if isElement(rendt) then
			dxSetRenderTarget(rendt,true)
			dxSetBlendMode("blend")
			local tabOffset = eleData.tabOffset[2] and eleData.tabOffset[1]*w or eleData.tabOffset[1]
			local tabPadding = eleData.tabPadding[2] and eleData.tabPadding[1]*w or eleData.tabPadding[1]
			local tabAllWidth = dgsTabPanelGetWidth(source)
			local tabX = tabOffset
			if tabAlignment == "left" then
				tabX = tabX-eleData.showPos*(tabAllWidth-w)
			elseif tabAlignment == "center" then
				tabX = tabX-(0.5-eleData.showPos)*(tabAllWidth-w)
			elseif tabAlignment == "right" then
				tabX = tabX-(1-eleData.showPos)*(tabAllWidth-w)
			end
			local gap = eleData.tabGapSize[2] and eleData.tabGapSize[1]*w or eleData.tabGapSize[1]
			if eleData.PixelInt then height = height-height%1 end
			for d=1,#tabs do
				local t = tabs[d]
				local tabData = dgsElementData[t]
				if tabData.visible then
					local tWordbreak,tColorcoded = tabData.wordbreak,tabData.colorcoded
					if tWordbreak == nil then tWordbreak = wordbreak end
					if tColorcoded == nil then tColorcoded = colorcoded end
					local width = tabData.width+tabPadding*2
					local _width = 0
					if tabs[d+1] then
						_width = dgsElementData[tabs[d+1]].width+tabPadding*2
					end
					if tabX+width >= 0 and tabX <= w then
						local tabImage = tabData.tabImage
						local tabColor = tabData.tabColor
						local tabTextColor = tabData.textColor
						if type(tabTextColor) ~= "table" then tabTextColor = {tabTextColor,tabTextColor,tabTextColor} end
						local selState = 1
						if selected == d then
							selState = 3
						elseif eleData.preSelect == d then
							selState = 2
						end
						local finalcolor
						if not enabledSelf then
							if type(eleData.disabledColor) == "number" then
								finalcolor = applyColorAlpha(eleData.disabledColor,parentAlpha)
							elseif eleData.disabledColor == true then
								local r,g,b,a = fromcolor(tabColor[1],true)
								local average = (r+g+b)/3*eleData.disabledColorPercent
								finalcolor = tocolor(average,average,average,a*parentAlpha)
							else
								finalcolor = tabColor[selState]
							end
						else
							finalcolor = applyColorAlpha(tabColor[selState],parentAlpha)
						end
						if tabImage[selState] then
							dxDrawImage(tabX,0,width,height,tabImage[selState],0,0,0,finalcolor,false,rendt)
						else
							dxDrawRectangle(tabX,0,width,height,finalcolor)
						end
						local textSizeX,textSizeY = tabData.textSize[1],tabData.textSize[2]
						if eleData.PixelInt then
							_tabsize,_width = tabX-tabX%1,mathFloor(width+tabX)
						end
						--[[local iconImage = eleData.iconImage
						if iconImage then
							local iconColor = eleData.iconColor
							iconImage = type(iconImage) == "table" and iconImage or {iconImage,iconImage,iconImage}
							iconColor = type(iconColor) == "table" and iconColor or {iconColor,iconColor,iconColor}
							local iconSize = eleData.iconSize
							local fontHeight = dxGetFontHeight(textSizeY,font)
							local fontWidth = dxGetTextWidth(text,textSizeX,font,colorcoded)
							local iconHeight,iconWidth = iconSize[2],iconSize[1]
							if iconSize[3] == "text" then
								iconWidth,iconHeight = fontHeight*iconSize[1],fontHeight*iconSize[2]
							elseif iconSize[3] == true then
								iconWidth,iconHeight = w*iconSize[1],h*iconSize[2]
							end
							local posX,posY = txtoffsetsY,txtoffsetsX
							local iconOffset = eleData.iconOffset
							if eleData.iconDirection == "left" then
								if alignment[1] == "left" then
									posX = posX-iconWidth-iconOffset
								elseif alignment[1] == "right" then
									posX = posX+w-fontWidth-iconWidth-iconOffset
								else
									posX = posX+w/2-fontWidth/2-iconWidth-iconOffset
								end
							elseif eleData.iconDirection == "right" then
								if alignment[1] == "left" then
									posX = posX+fontWidth+iconOffset
								elseif alignment[1] == "right" then
									posX = posX+w+iconOffset
								else
									posX = posX+w/2+fontWidth/2+iconOffset
								end
							end
							if alignment[2] == "top" then
								posY = posY
							elseif alignment[2] == "bottom" then
								posY = posY+h-fontHeight
							else
								posY = posY+(h-iconHeight)/2
							end
							posX,posY = posX+x,posY+y
							if iconImage[buttonState] then
								dxDrawImage(posX,posY,iconWidth,iconHeight,iconImage[buttonState],0,0,0,applyColorAlpha(iconColor[buttonState],parentAlpha),isPostGUI,rndtgt)
							end
						end]]

						dxDrawText(tabData.text,_tabsize,0,_width,height,applyColorAlpha(tabTextColor[selState],parentAlpha),textSizeX,textSizeY,tabData.font or font,"center","center",false,false,false,colorcoded,true)
						if mx >= tabX+x and mx <= tabX+x+width and my > y and my < y+height and tabData.enabled and enabledSelf then
							eleData.rndPreSelect = d
							MouseData.hit = t
						end
					end
					tabX = tabX+width+gap
				end
			end
			eleData.preSelect = -1
			dxSetRenderTarget(rndtgt)
			dxSetBlendMode("add")
			_dxDrawImage(x,y,w,height,rendt,0,0,0,applyColorAlpha(white,parentAlpha),isPostGUI)
			dxSetBlendMode(rndtgt and "modulate_add" or "blend")
			local colors = applyColorAlpha(dgsElementData[tabs[selected]].bgColor,parentAlpha)
			if dgsElementData[tabs[selected]].bgImage then
				dxDrawImage(x,y+height,w,h-height,dgsElementData[tabs[selected]].bgImage,0,0,0,colors,isPostGUI,rndtgt)
			else
				dxDrawRectangle(x,y+height,w,h-height,colors,isPostGUI)
			end
			local children = ChildrenTable[tabs[selected]]
			for i=1,#children do
				renderGUI(children[i],mx,my,enabledInherited,enabledSelf,rndtgt,xRT,yRT,xNRT,yNRT,OffsetX,OffsetY,parentAlpha,visible)
			end
		end
	end
	return rndtgt,false,mx,my,0,0
end