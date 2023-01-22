dgsLogLuaMemory()
dgsRegisterType("dgs-dxtab","dgsBasic")
dgsRegisterType("dgs-dxtabpanel","dgsBasic","dgsType2D")
dgsRegisterProperties("dgs-dxtabpanel",{
	bgColor = 		{	PArg.Color	},
	bgImage = 		{	PArg.Material+PArg.Nil },
	colorCoded = 	{	PArg.Bool	},
	font = 			{	PArg.Font+PArg.String },
	scrollSpeed = 	{	{ PArg.Number, PArg.Bool }	},
	selected = 		{	PArg.Number	},
	shadow = 		{	{ PArg.Number, PArg.Number, PArg.Color, PArg.Number+PArg.Bool+PArg.Nil, PArg.Font+PArg.Nil }, PArg.Nil	},
	tabAlignment = 	{	PArg.String	},
	tabGapSize = 	{	{ PArg.Number, PArg.Bool }	},
	tabHeight = 	{	{ PArg.Number, PArg.Bool }	},
	tabMaxWidth = 	{	{ PArg.Number, PArg.Bool }	},
	tabMinWidth = 	{	{ PArg.Number, PArg.Bool }	},
	tabOffset = 	{	{ PArg.Number, PArg.Bool }	},
	tabPadding = 	{	{ PArg.Number, PArg.Bool }	},
	wordBreak = 	{	PArg.Bool	},
})
dgsRegisterProperties("dgs-dxtab",{
	bgColor = 		{	PArg.Color	},
	bgImage = 		{	PArg.Material+PArg.Nil	},
	colorCoded = 	{	PArg.Bool	},
	font = 			{	PArg.Font+PArg.String	},
	id = 			{	PArg.Number	},
	shadow = 		{	{ PArg.Number, PArg.Number, PArg.Color, PArg.Number+PArg.Bool+PArg.Nil, PArg.Font+PArg.Nil }, PArg.Nil	},
	tabColor = 		{	{ PArg.Color, PArg.Color, PArg.Color }	},
	tabImage = 		{	{ PArg.Material+PArg.Nil, PArg.Material+PArg.Nil, PArg.Material+PArg.Nil }	},
	text = 			{	PArg.Text	},
	textColor = 	{	PArg.Number	},
	textSize = 		{	{ PArg.Number,PArg.Number }	},
	wordBreak = 	{	PArg.Bool	},
})
--Dx Functions
local __dxDrawImage = __dxDrawImage
local dxDrawImage = dxDrawImage
local dgsDrawText = dgsDrawText
local dxSetRenderTarget = dxSetRenderTarget
local dxGetTextWidth = dxGetTextWidth
local dxSetBlendMode = dxSetBlendMode
local dgsCreateRenderTarget = dgsCreateRenderTarget
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
local dgsTriggerEvent = dgsTriggerEvent
local createElement = createElement
local assert = assert
local tonumber = tonumber
local type = type
local mathClamp = math.clamp
local mathMin = math.min
local mathMax = math.max
local mathFloor = math.floor
local mathInRange = math.inRange
local tableInsert = table.insert
local tableRemove = table.remove

function dgsCreateTabPanel(...)
	local sRes = sourceResource or resource
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
		if not isMaterial(bgImage) then error(dgsGenAsrt(bgImage,"dgsCreateTabPanel",8,"material")) end
	end
	local tabpanel = createElement("dgs-dxtabpanel")
	dgsSetType(tabpanel,"dgs-dxtabpanel")
	
	local res = sRes ~= resource and sRes or "global"
	local style = styleManager.styles[res]
	local using = style.using
	style = style.loaded[using]
	local systemFont = style.systemFontElement
	
	style = style.tabpanel
	local tabHeight = tabHeight or style.tabHeight
	local nImage = nImage or (style.tabImage and dgsCreateTextureFromStyle(using,res,style.tabImage[1]))
	local hImage = hImage or (style.tabImage and dgsCreateTextureFromStyle(using,res,style.tabImage[2])) or nImage
	local cImage = cImage or (style.tabImage and dgsCreateTextureFromStyle(using,res,style.tabImage[3])) or nImage
	local nColor = nColor or (style.tabColor and style.tabColor[1])
	local hColor = hColor or (style.tabColor and style.tabColor[2])
	local cColor = cColor or (style.tabColor and style.tabColor[3])
	dgsElementData[tabpanel] = {
		tabHeight = {tabHeight,false},
		tabMaxWidth = {10000,false},
		tabMinWidth = {10,false},
		bgColor = tonumber(bgColor) or style.bgColor,
		bgImage = bgImage or dgsCreateTextureFromStyle(using,res,style.bgImage),
		tabs = {},
		font = style.font or systemFont,
		selected = -1,
		preSelect = -1,
		tabPadding = style.tabPadding,
		tabGapSize = style.tabGapSize,
		scrollSpeed = style.scrollSpeed,
		showPos = 0,
		tabLengthAll = 0,
		colorCoded = nil,
		wordBreak = nil,
		tabAlignment = "left",
		tabOffset = {0,false},
		textRenderBuffer = {},
		tabImage = {nImage,hImage,cImage},
		tabColor = {nColor,hColor,cColor},
	}
	dgsSetParent(tabpanel,parent,true,true)
	calculateGuiPositionSize(tabpanel,x,y,relative,w,h,relative,true)
	dgsAddEventHandler("onDgsSizeChange",tabpanel,"configTabPanelWhenResize",false)
	onDGSElementCreate(tabpanel,sRes)
	dgsTabPanelRecreateRenderTarget(tabpanel,true)
	return tabpanel
end

function dgsTabPanelRecreateRenderTarget(tabpanel,lateAlloc)
	local eleData = dgsElementData[tabpanel]
	if isElement(eleData.bgRT) then destroyElement(eleData.bgRT) end
	if lateAlloc then
		dgsSetData(tabpanel,"retrieveRT",true)
	else
		local tabHeight = eleData.tabHeight[1]*(eleData.tabHeight[2] and eleData.absSize[2] or 1)
		local bgRT,err = dgsCreateRenderTarget(eleData.absSize[1],tabHeight,true,tabpanel)
		if bgRT ~= false then
			dgsAttachToAutoDestroy(bgRT,tabpanel,-1)
		else
			outputDebugString(err,2)
		end
		dgsSetData(tabpanel,"bgRT",bgRT)
		dgsSetData(tabpanel,"retrieveRT",nil)
	end
end

function configTabPanelWhenResize()
	dgsElementData[source].configNextFrame = true
end

function dgsCreateTab(...)
	local sRes = sourceResource or resource
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
						
	local res = sRes ~= resource and sRes or "global"
	local style = styleManager.styles[res]
	local using = style.using
	style = style.loaded[using]
	local systemFont = style.systemFontElement

	style = style.tab
	local eleData = dgsElementData[tabpanel]
	local pTextColor = eleData.textColor
	local w = eleData.absSize[1]
	local tabs = eleData.tabs
	local id = #tabs+1
	tableInsert(tabs,id,tab)
	local font = style.font or eleData.font
	local t_minWid,t_maxWid = eleData.tabMinWidth,eleData.tabMaxWidth
	local minwidth,maxwidth = t_minWid[2] and t_minWid[1]*w or t_minWid[1],t_maxWid[2] and t_maxWid[1]*w or t_maxWid[1]
	local tabPadding = eleData.tabPadding
	local padding = tabPadding[2] and tabPadding[1]*w or tabPadding[1]
	local tabGapSize = eleData.tabGapSize
	local gapSize = tabGapSize[2] and tabGapSize[1]*w or tabGapSize[1]
	local textSizeX,textSizeY = tonumber(scaleX) or style.textSize[1], tonumber(scaleY) or style.textSize[2]
	local nImage = nImage or (style.tabImage and dgsCreateTextureFromStyle(using,res,style.tabImage[1]))
	local hImage = hImage or (style.tabImage and dgsCreateTextureFromStyle(using,res,style.tabImage[2]))
	local cImage = cImage or (style.tabImage and dgsCreateTextureFromStyle(using,res,style.tabImage[3]))
	local nColor = nColor or (style.tabColor and style.tabColor[1])
	local hColor = hColor or (style.tabColor and style.tabColor[2])
	local cColor = cColor or (style.tabColor and style.tabColor[3])
	dgsElementData[tab] = {
		parent = tabpanel,
		id = id,
		font = style.font or systemFont,
		width = wid,
		textColor = tonumber(textColor) or style.textColor or pTextColor,
		textSize = {textSizeX,textSizeY},
		bgColor = tonumber(bgColor),
		bgImage = bgImage,
		tabImage = {nImage,hImage,cImage},
		tabColor = {nColor,hColor,cColor},
		iconColor = 0xFFFFFFFF,
		iconDirection = "left",
		iconImage = nil,
		iconOffset = 5,
		iconSize = {1,1,true}, -- Text's font heigh,
		colorCoded = nil,
		wordBreak = nil,
	}
	dgsSetParent(tab,tabpanel,true,true)
	if eleData.selected == -1 then eleData.selected = id end
	dgsAttachToTranslation(tab,resourceTranslation[sRes])
	if type(text) == "table" then
		dgsElementData[tab]._translation_text = text
		local wid = mathClamp(dxGetTextWidth(dgsTranslate(tab,text,sRes),scaleX or 1,font),minwidth,maxwidth)
		dgsElementData[tab].tabLengthAll = eleData.tabLengthAll+wid+padding*2+gapSize*mathMin(#tabs,1)
		dgsElementData[tab].width = wid
	else
		text = tostring(text or "")
		local wid = mathClamp(dxGetTextWidth(text,scaleX or 1,font),minwidth,maxwidth)
		dgsElementData[tab].tabLengthAll = eleData.tabLengthAll+wid+padding*2+gapSize*mathMin(#tabs,1)
		dgsElementData[tab].width = wid
	end
	dgsSetData(tab,"text",text)
	onDGSElementCreate(tab,sRes)
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
	local eleData = dgsElementData[source]
	dgsTabPanelRecreateRenderTarget(source,true)
	eleData.configNextFrame = false
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
-----------------------PropertyListener-------------------------
----------------------------------------------------------------
dgsOnPropertyChange["dgs-dxtabpanel"] = {
	selected = function(dgsEle,key,value,oldValue)
		local old,new = oldValue,value
		local tabs = dgsElementData[dgsEle].tabs
		dgsTriggerEvent("onDgsTabPanelTabSelect",dgsEle,new,old,tabs[new],tabs[old])
		dgsApplyVisibleInherited(tabs[old],false)
		if isElement(tabs[new]) then
			dgsTriggerEvent("onDgsTabSelect",tabs[new],new,old,tabs[new],tabs[old])
			dgsApplyVisibleInherited(tabs[new],true)
		end
	end,
	tabPadding = function(dgsEle,key,value,oldValue)
		local width = dgsElementData[dgsEle].absSize[1]
		local change = value[2] and value[1]*width or value[1]
		local old = oldValue[2] and oldValue[1]*width or oldValue[1]
		local tabs = dgsElementData[dgsEle].tabs
		dgsSetData(dgsEle,"tabLengthAll",dgsElementData[dgsEle].tabLengthAll+(change-old)*#tabs*2)
	end,
	tabGapSize = function(dgsEle,key,value,oldValue)
		local width = dgsElementData[dgsEle].absSize[1]
		local change = value[2] and value[1]*width or value[1]
		local old = oldValue[2] and oldValue[1]*width or oldValue[1]
		local tabs = dgsElementData[dgsEle].tabs
		dgsSetData(dgsEle,"tabLengthAll",dgsElementData[dgsEle].tabLengthAll+(change-old)*mathMax((#tabs-1),1))
	end,
	tabAlignment = function(dgsEle,key,value,oldValue)
		dgsElementData[dgsEle].showPos = 0
	end,
	tabHeight = function(dgsEle,key,value,oldValue)
		dgsElementData[dgsEle].configNextFrame = true
	end,
}

dgsOnPropertyChange["dgs-dxtab"] = {
	text = function(dgsEle,key,value,oldValue)
		if type(value) == "table" then
			dgsElementData[dgsEle]._translation_text = value
			value = dgsTranslate(dgsEle,value,sourceResource)
		else
			dgsElementData[dgsEle]._translation_text = nil
		end
		local tabpanel = dgsElementData[dgsEle].parent
		local w = dgsElementData[tabpanel].absSize[1]
		local t_minWid = dgsElementData[tabpanel].tabMinWidth
		local t_maxWid = dgsElementData[tabpanel].tabMaxWidth
		local minwidth = t_minWid[2] and t_minWid[1]*w or t_minWid[1]
		local maxwidth = t_maxWid[2] and t_maxWid[1]*w or t_maxWid[1]
		dgsElementData[dgsEle].text = tostring(value)
		dgsSetData(dgsEle,"width",mathClamp(dxGetTextWidth(tostring(value),dgsElementData[dgsEle].textSize[1],dgsElementData[dgsEle].font or dgsElementData[tabpanel].font),minwidth,maxwidth))
		return dgsTriggerEvent("onDgsTextChange",dgsEle)
	end,
	textSize = function(dgsEle,key,value,oldValue)
		local tabpanel = dgsElementData[dgsEle].parent
		local w = dgsElementData[tabpanel].absSize[1]
		local t_minWid = dgsElementData[tabpanel].tabMinWidth
		local t_maxWid = dgsElementData[tabpanel].tabMaxWidth
		local minwidth = t_minWid[2] and t_minWid[1]*w or t_minWid[1]
		local maxwidth = t_maxWid[2] and t_maxWid[1]*w or t_maxWid[1]
		dgsSetData(dgsEle,"width",mathClamp(dxGetTextWidth(dgsElementData[dgsEle].text,dgsElementData[dgsEle].textSize[1],dgsElementData[dgsEle].font or dgsElementData[tabpanel].font),minwidth,maxwidth))
	end,
	font = function(dgsEle,key,value,oldValue)
		--Multilingual
		if type(value) == "table" then
			dgsElementData[dgsEle]._translation_font = value
			value = dgsGetTranslationFont(dgsEle,value,sourceResource)
		else
			dgsElementData[dgsEle]._translation_font = nil
		end
		dgsElementData[dgsEle].font = value
		
		local tabpanel = dgsElementData[dgsEle].parent
		local w = dgsElementData[tabpanel].absSize[1]
		local t_minWid = dgsElementData[tabpanel].tabMinWidth
		local t_maxWid = dgsElementData[tabpanel].tabMaxWidth
		local minwidth = t_minWid[2] and t_minWid[1]*w or t_minWid[1]
		local maxwidth = t_maxWid[2] and t_maxWid[1]*w or t_maxWid[1]
		dgsSetData(dgsEle,"width",mathClamp(dxGetTextWidth(dgsElementData[dgsEle].text,dgsElementData[dgsEle].textSize[1],dgsElementData[dgsEle].font or dgsElementData[tabpanel].font),minwidth,maxwidth))
	end,
	width = function(dgsEle,key,value,oldValue)
		local tabpanel = dgsElementData[dgsEle].parent
		dgsSetData(tabpanel,"tabLengthAll",dgsElementData[tabpanel].tabLengthAll+(value-oldValue))
	end,
}

----------------------------------------------------------------
-----------------------VisibilityManage-------------------------
----------------------------------------------------------------
dgsOnVisibilityChange["dgs-dxtabpanel"] = function(dgsElement,selfVisibility,inheritVisibility)
	if not selfVisibility or not inheritVisibility then
		dgsTabPanelRecreateRenderTarget(dgsElement,true)
	end
end
----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxtabpanel"] = function(source,x,y,w,h,mx,my,cx,cy,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt,xRT,yRT,xNRT,yNRT,OffsetX,OffsetY,visible)
	if eleData.configNextFrame then configTabPanel(source) end
	if eleData.retrieveRT then
		dgsTabPanelRecreateRenderTarget(source)
	end
	eleData.rndPreSelect = -1
	local selected = eleData.selected
	local tabs = eleData.tabs
	local height = eleData.tabHeight[2] and eleData.tabHeight[1]*h or eleData.tabHeight[1]

	local res = eleData.resource or "global"
	local style = styleManager.styles[res]
	local using = style.using
	style = style.loaded[using]
	local systemFont = style.systemFontElement
	
	local font = eleData.font or systemFont
	local colorCoded = eleData.colorCoded
	local shadow = eleData.shadow
	local wordBreak = eleData.wordBreak
	local tabAlignment = eleData.tabAlignment
	local tabImageP = eleData.tabImage
	local tabColorP = eleData.tabColor
	local tabImagePIsTable = type(tabImageP) == "table"
	local tabColorPIsTable = type(tabColorP) == "table"
	if selected == -1 then
		local color = applyColorAlpha(eleData.bgColor,parentAlpha)
		dxDrawImage(x,y+height,w,h-height,eleData.bgImage,0,0,0,color,isPostGUI)
	else
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
		local textRenderBuffer = eleData.textRenderBuffer
		textRenderBuffer.count = 0
		if eleData.bgRT then
			dxSetRenderTarget(eleData.bgRT,true)
			for d=1,#tabs do
				local t = tabs[d]
				local tabData = dgsElementData[t]
				if tabData.visible then
					local twordBreak,tcolorCoded,tshadow = tabData.wordBreak,tabData.colorCoded,tabData.shadow
					if twordBreak == nil then twordBreak = wordBreak end
					if tcolorCoded == nil then tcolorCoded = colorCoded end
					if tshadow == nil then tshadow = shadow end
					local width = tabData.width+tabPadding*2
					if tabX+width >= 0 and tabX <= w then
						local tabTextColor = tabData.textColor
						local selState = 1
						if selected == d then
							selState = 3
						elseif eleData.preSelect == d then
							selState = 2
						end
						local tabImage = type(tabData.tabImage) ~= "table" and tabData.tabImage or (tabData.tabImage[selState] or (not tabImagePIsTable and tabImageP or tabImageP[selState]))
						local tabColor = type(tabData.tabColor) ~= "table" and tabData.tabColor or (tabData.tabColor[selState] or (not tabColorPIsTable and tabColorP or tabColorP[selState]))
						local finalcolor
						if not enabledSelf then
							if type(eleData.disabledColor) == "number" then
								finalcolor = applyColorAlpha(eleData.disabledColor,parentAlpha)
							elseif eleData.disabledColor == true then
								local r,g,b,a = fromcolor(tabColor[1])
								local average = (r+g+b)/3*eleData.disabledColorPercent
								finalcolor = tocolor(average,average,average,a*parentAlpha)
							else
								finalcolor = applyColorAlpha(tabColor,parentAlpha)
							end
						else
							finalcolor = applyColorAlpha(tabColor,parentAlpha)
						end
						dxDrawImage(tabX,0,width,height,tabImage,0,0,0,finalcolor,false,rndtgt)
						local textSizeX,textSizeY = tabData.textSize[1],tabData.textSize[2]
						--[[local iconImage = eleData.iconImage
						if iconImage then
							local iconColor = eleData.iconColor
							iconImage = type(iconImage) == "table" and iconImage or {iconImage,iconImage,iconImage}
							iconColor = type(iconColor) == "table" and iconColor or {iconColor,iconColor,iconColor}
							local iconSize = eleData.iconSize
							local fontHeight = dxGetFontHeight(textSizeY,font)
							local fontWidth = dxGetTextWidth(text,textSizeX,font,colorCoded)
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

						textRenderBuffer.count = textRenderBuffer.count+1
						if not textRenderBuffer[textRenderBuffer.count] then textRenderBuffer[textRenderBuffer.count] = {} end
						textRenderBuffer[textRenderBuffer.count][1] = tabData.text
						textRenderBuffer[textRenderBuffer.count][2] = tabX
						textRenderBuffer[textRenderBuffer.count][3] = 0
						textRenderBuffer[textRenderBuffer.count][4] = width+tabX
						textRenderBuffer[textRenderBuffer.count][5] = height
						textRenderBuffer[textRenderBuffer.count][6] = applyColorAlpha(type(tabTextColor) == "table" and tabTextColor[selState] or tabTextColor,parentAlpha)
						textRenderBuffer[textRenderBuffer.count][7] = textSizeX
						textRenderBuffer[textRenderBuffer.count][8] = textSizeY
						textRenderBuffer[textRenderBuffer.count][9] = tabData.font or font
						textRenderBuffer[textRenderBuffer.count][10] = colorCoded	--Color Coded
						textRenderBuffer[textRenderBuffer.count][11] = tshadow	--Shadow
						if mx and my and mx >= tabX+cx and mx <= tabX+cx+width and my > cy and my < cy+height and tabData.enabled and enabledSelf then
							eleData.rndPreSelect = d
							tabData.cursorPosition[0] = dgsRenderInfo.frames
							tabData.cursorPosition[1],tabData.cursorPosition[2] = mx,my
							MouseData.hit = t
						end
					end
					tabX = tabX+width+gap
				end
			end
			dxSetBlendMode("modulate_add")
			local shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont
			for i=1,textRenderBuffer.count do
				local tRB = textRenderBuffer[i]
				local text = tRB[1]
				if tRB[11] then
					shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont = tRB[11][1],tRB[11][2],tRB[11][3],tRB[11][4],tRB[11][5]
					shadowColor = applyColorAlpha(shadowColor or white,parentAlpha)
				end
				dgsDrawText(tRB[1],tRB[2],tRB[3],tRB[4],tRB[5],tRB[6],tRB[7],tRB[8],tRB[9],"center","center",false,false,false,tRB[10],false,0,0,0,0,shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont)
			end		
		end
		eleData.preSelect = -1
		dxSetRenderTarget(rndtgt)
		dxSetBlendMode(rndtgt and "modulate_add" or "blend")
		if eleData.bgRT then
			__dxDrawImage(x,y,w,height,eleData.bgRT,0,0,0,white,isPostGUI)
		end
		local tabEleData = dgsElementData[ tabs[selected] ]
		local colors = applyColorAlpha(tabEleData.bgColor or eleData.bgColor,parentAlpha)
		dxDrawImage(x,y+height,w,h-height,tabEleData.bgImage or eleData.bgImage,0,0,0,colors,isPostGUI,rndtgt)
		local children = tabEleData.children
		for i=1,#children do
			renderGUI(children[i],mx,my,enabledInherited,enabledSelf,rndtgt,xRT,yRT,xNRT,yNRT,OffsetX,OffsetY,parentAlpha,visible)
		end
	end
	return rndtgt,false,mx,my,0,0
end

----------------------------------------------------------------
-------------------------Children Renderer----------------------
----------------------------------------------------------------
dgsChildRenderer["dgs-dxtabpanel"] = function(children,mx,my,enabledInherited,enabledSelf,rndtgt,xRT,yRT,xNRT,yNRT,OffsetX,OffsetY,parentAlpha)
	for i=1,#children do
		local child = children[i]
		if dgsElementType[child] ~= "dgs-dxtab" then
			renderGUI(child,mx,my,enabledInherited,enabledSelf,rndtgt,xRT,yRT,xNRT,yNRT,OffsetX,OffsetY,parentAlpha)
		end
	end
end