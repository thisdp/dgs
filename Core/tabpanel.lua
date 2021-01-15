--Dx Functions
local dxDrawLine = dxDrawLine
local dxDrawImage = dxDrawImageExt
local dxDrawImageSection = dxDrawImageSectionExt
local dxDrawText = dxDrawText
local dxGetFontHeight = dxGetFontHeight
local dxDrawRectangle = dxDrawRectangle
local dxSetShaderValue = dxSetShaderValue
local dxGetPixelsSize = dxGetPixelsSize
local dxGetPixelColor = dxGetPixelColor
local dxSetRenderTarget = dxSetRenderTarget
local dxGetTextWidth = dxGetTextWidth
local dxSetBlendMode = dxSetBlendMode
local _dxDrawImage = _dxDrawImage
local _dxDrawImageSection = _dxDrawImageSection
--
local mathFloor = math.floor
local assert = assert
local type = type
local tonumber = tonumber

function dgsCreateTabPanel(x,y,sx,sy,relative,parent,tabHeight,bgImage,bgColor)
	local xCheck,yCheck,wCheck,hCheck = type(x) == "number",type(y) == "number",type(sx) == "number",type(sy) == "number"
	if not xCheck then assert(false,"Bad argument @dgsCreateTabPanel at argument 1, expect number got "..type(x)) end
	if not yCheck then assert(false,"Bad argument @dgsCreateTabPanel at argument 2, expect number got "..type(y)) end
	if not wCheck then assert(false,"Bad argument @dgsCreateTabPanel at argument 3, expect number got "..type(sx)) end
	if not hCheck then assert(false,"Bad argument @dgsCreateTabPanel at argument 4, expect number got "..type(sy)) end
	if bgImage then
		local eleType = dgsIsMaterialElement(bgImage)
		assert(eleType == true,"Bad argument @dgsCreateTabPanel at argument 8, expect material got "..eleType)
	end
	local tabpanel = createElement("dgs-dxtabpanel")
	dgsSetType(tabpanel,"dgs-dxtabpanel")
	dgsSetParent(tabpanel,parent,true,true)
	local style = styleSettings.tabpanel
	local tabHeight = tabHeight or style.tabHeight
	dgsElementData[tabpanel] = {
		tabHeight = {tabHeight,false};
		tabMaxWidth = {10000,false};
		tabMinWidth = {10,false};
		bgColor = tonumber(bgColor) or style.bgColor;
		bgImage = bgImage or dgsCreateTextureFromStyle(style.bgImage);
		tabs = {};
		font = style.font or systemFont;
		selected = -1;
		preSelect = -1;
		tabPadding = style.tabPadding;
		tabGapSize = style.tabGapSize;
		scrollSpeed = style.scrollSpeed;
		showPos = 0;
		tabLengthAll = 0;
	}
	calculateGuiPositionSize(tabpanel,x,y,relative,sx,sy,relative,true)
	local abx = dgsElementData[tabpanel].absSize[1]
	local renderTarget,err = dxCreateRenderTarget(abx,tabHeight,true,tabpanel)
	if renderTarget ~= false then
		dgsAttachToAutoDestroy(renderTarget,tabpanel,-1)
	else
		outputDebugString(err)
	end
	dgsElementData[tabpanel].renderTarget = renderTarget
	triggerEvent("onDgsCreate",tabpanel,sourceResource)
	return tabpanel
end

function dgsCreateTab(text,tabpanel,textSizex,textSizey,textColor,bgImage,bgColor,tabnorimg,tabhovimg,tabcliimg,tabnorcolor,tabhovcolor,tabclicolor)
	local typeCheck =  dgsGetType(tabpanel) == "dgs-dxtabpanel"
	if not typeCheck then assert(false,"Bad argument @dgsCreateTab at argument 2, expect dgs-dxtabpanel got "..dgsGetType(tabpanel)) end
	local tab = createElement("dgs-dxtab")
	dgsSetType(tab,"dgs-dxtab")
	dgsSetParent(tab,tabpanel,true,true)
	local style = styleSettings.tab
	local tabs = dgsElementData[tabpanel].tabs
	local id = #tabs+1
	table.insert(tabs,id,tab)
	local w = dgsElementData[tabpanel].absSize[1]
	local font = style.font or dgsElementData[tabpanel].font
	local t_minWid,t_maxWid = dgsElementData[tabpanel].tabMinWidth,dgsElementData[tabpanel].tabMaxWidth
	local minwidth,maxwidth = t_minWid[2] and t_minWid[1]*w or t_minWid[1],t_maxWid[2] and t_maxWid[1]*w or t_maxWid[1]
	local wid = math.restrict(dxGetTextWidth(text,textSizex or 1,font),minwidth,maxwidth)
	local tabPadding = dgsElementData[tabpanel].tabPadding
	local padding = tabPadding[2] and tabPadding[1]*w or tabPadding[1]
	local tabGapSize = dgsElementData[tabpanel].tabGapSize
	local gapSize = tabGapSize[2] and tabGapSize[1]*w or tabGapSize[1]
	local textSizeX,textSizeY = tonumber(textSizex) or style.textSize[1], tonumber(textSizex) or style.textSize[2]
	local tabnorimg = tabnorimg or dgsCreateTextureFromStyle(style.tabImage[1])
	local tabhovimg = tabhovimg or dgsCreateTextureFromStyle(style.tabImage[2])
	local tabcliimg = tabcliimg or dgsCreateTextureFromStyle(style.tabImage[3])
	local tabnorcolor = tabnorcolor or style.tabColor[1]
	local tabhovcolor = tabhovcolor or style.tabColor[2]
	local tabclicolor = tabclicolor or style.tabColor[3]
	dgsElementData[tab] = {
		parent = tabpanel,
		id = id,
		font = style.font or systemFont,
		tabLengthAll = dgsElementData[tabpanel].tabLengthAll+wid+padding*2+gapSize*math.min(#tabs,1),
		width = wid,
		textColor = tonumber(textColor) or style.textColor,
		textSize = {textSizeX,textSizeY},
		bgColor = tonumber(bgColor) or style.bgColor or dgsElementData[tabpanel].bgColor,
		bgImage = bgImage or dgsCreateTextureFromStyle(style.bgImage) or dgsElementData[tabpanel].bgImage,
		tabImage = {tabnorimg,tabhovimg,tabcliimg},
		tabColor = {tabnorcolor,tabhovcolor,tabclicolor},
	}
	if dgsElementData[tabpanel].selected == -1 then
		dgsElementData[tabpanel].selected = id
	end
	dgsAttachToTranslation(tab,resourceTranslation[sourceResource or getThisResource()])
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
	assert(dgsGetType(tabpanel) == "dgs-dxtabpanel","Bad argument @dgsTabPanelGetWidth at at argument 1, expect dgs-dxtabpanel got "..dgsGetType(tabpanel))
	local wid = 0
	local tabs = dgsElementData[tabpanel].tabs
	local tabPadding = dgsElementData[tabpanel].tabPadding
	local w = dgsElementData[tabpanel].absSize[1]
	local padding = tabPadding[2] and tabPadding[1]*w or tabPadding[1]
	local tabGapSize = dgsElementData[tabpanel].tabGapSize
	local gapSize = tabGapSize[2] and tabGapSize[1]*w or tabGapSize[1]
	local cnt = 0
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
	assert(dgsGetType(tabpanel) == "dgs-dxtabpanel","Bad argument @dgsTabPanelGetTabFromID at at argument 1, expect dgs-dxtabpanel got "..dgsGetType(tabpanel))
	assert(type(id) == "number","Bad argument @dgsTabPanelGetTabFromID at at argument 2, expect number got "..type(id))
	return dgsElementData[tabpanel].tabs[id]
end

function dgsTabPanelMoveTab(tabpanel,from,to)
	assert(dgsGetType(tabpanel) == "dgs-dxtabpanel","Bad argument @dgsTabPanelMoveTab at at argument 1, expect dgs-dxtabpanel got "..dgsGetType(tabpanel))
	assert(type(from) == "number","Bad argument @dgsTabPanelMoveTab at at argument 2, expect number got "..type(from))
	assert(type(to) == "number","Bad argument @dgsTabPanelMoveTab at at argument 3, expect number got "..type(to))
	local tab = dgsElementData[tabpanel].tabs[from]
	local myid = dgsElementData[tab].id
	local parent = dgsElementData[tab].parent
	local tabs = dgsElementData[parent].tabs
	for i=myid+1,#tabs do
		local _tab = tabs[i]
		dgsElementData[_tab].id = dgsElementData[_tab].id-1
	end
	table.remove(tabs,myid)
	for i=to,#tabs do
		local _tab = tabs[i]
		dgsElementData[_tab].id = dgsElementData[_tab].id+1
	end
	table.insert(tabs,to,tab)
	return true
end

function dgsTabPanelGetTabID(tab)
	assert(dgsGetType(tab) == "dgs-dxtab","Bad argument @dgsTabPanelGetTabID at at argument 1, expect dgs-dxtab got "..dgsGetType(tab))
	return dgsElementData[tab].id
end

function dgsDeleteTab(tab)
	assert(dgsGetType(tab) == "dgs-dxtab","Bad argument @dgsDeleteTab at at argument 1, expect dgs-dxtab got "..dgsGetType(tab))
	local tabpanel = dgsElementData[tab].parent
	if dgsGetType(tabpanel) == "dgs-dxtabpanel" then
		local w = dgsElementData[tabpanel].absSize[1]
		local tabWidth = dgsElementData[tab].width
		local tabs = dgsElementData[tabpanel].tabs
		local tabPadding = dgsElementData[tabpanel].tabPadding
		local padding = tabPadding[2] and tabPadding[1]*w or tabPadding[1]
		local tabGapSize = dgsElementData[tabpanel].tabGapSize
		local gapSize = tabGapSize[2] and tabGapSize[1]*w or tabGapSize[1]
		dgsSetData(tabpanel,"tabLengthAll",dgsElementData[tabpanel].tabLengthAll-tabWidth-padding*2-gapSize*math.min(#tabs,1))
		local id = dgsElementData[tab].id
		for i=id,#tabs do
			dgsElementData[tabs[i]].id = dgsElementData[tabs[i]].id-1
		end
		table.remove(tabs,id)
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
		outputDebugString(err)
	end
	dgsSetData(source,"renderTarget",renderTarget)
end

function dgsGetSelectedTab(tabpanel,useNumber)
	assert(dgsGetType(tabpanel) == "dgs-dxtabpanel","Bad argument @dgsGetSelectedTab at at argument 1, expect dgs-dxtabpanel got "..dgsGetType(tabpanel))
	local id = dgsElementData[tabpanel].selected
	local tabs = dgsElementData[tabpanel].tabs
	if useNumber then
		return id
	else
		return tabs[id] or false
	end
end

function dgsSetSelectedTab(tabpanel,id)
	assert(dgsGetType(tabpanel) == "dgs-dxtabpanel","Bad argument @dgsSetSelectedTab at at argument 1, expect dgs-dxtabpanel got "..dgsGetType(tabpanel))
	local idtype = dgsGetType(id)
	assert(idtype == "number" or idtype == "dgs-dxtab","Bad argument @dgsSetSelectedTab at at argument 2, expect number/dgs-dxtab got "..idtype)
	local tabs = dgsElementData[tabpanel].tabs
	id = idtype == "dgs-dxtab" and dgsElementData[id].id or id
	if math.inRange(1,#tabs,id) then
		return dgsSetData(tabpanel,"selected",id)
	end
	return false
end


----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxtabpanel"] = function(source,x,y,w,h,mx,my,cx,cy,enabled,eleData,parentAlpha,isPostGUI,rndtgt,position,OffsetX,OffsetY,visible)
	eleData.rndPreSelect = -1
	local selected = eleData.selected
	local tabs = eleData.tabs
	local height = eleData.tabHeight[2] and eleData.tabHeight[1]*h or eleData.tabHeight[1]
	local font = eleData.font or systemFont
	if selected == -1 then
		dxDrawRectangle(x,y+height,w,h-height,eleData.bgColor,isPostGUI)
	else
		local rendt = eleData.renderTarget
		if isElement(rendt) then
			dxSetRenderTarget(rendt,true)
			dxSetBlendMode("blend")
			local tabPadding = eleData.tabPadding[2] and eleData.tabPadding[1]*w or eleData.tabPadding[1]
			local tabsize = -eleData.showPos*(dgsTabPanelGetWidth(source)-w)
			local gap = eleData.tabGapSize[2] and eleData.tabGapSize[1]*w or eleData.tabGapSize[1]
			if eleData.PixelInt then height = height-height%1 end
			for d=1,#tabs do
				local t = tabs[d]
				local tabData = dgsElementData[t]
				if tabData.visible then
					local width = tabData.width+tabPadding*2
					local _width = 0
					if tabs[d+1] then
						_width = dgsElementData[tabs[d+1]].width+tabPadding*2
					end
					if tabsize+width >= 0 and tabsize <= w then
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
						if not enabled[2] then
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
							dxDrawImage(tabsize,0,width,height,tabImage[selState],0,0,0,finalcolor,false,rendt)
						else
							dxDrawRectangle(tabsize,0,width,height,finalcolor)
						end
						local textSize = tabData.textSize
						if eleData.PixelInt then
							_tabsize,_width = tabsize-tabsize%1,mathFloor(width+tabsize)
						end
						dxDrawText(tabData.text,_tabsize,0,_width,height,tabTextColor[selState],textSize[1],textSize[2],tabData.font or font,"center","center",false,false,false,colorcoded,true)
						if mx >= tabsize+x and mx <= tabsize+x+width and my > y and my < y+height and tabData.enabled and enabled[2] then
							eleData.rndPreSelect = d
							MouseData.hit = t
						end
					end
					tabsize = tabsize+width+gap
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
				renderGUI(children[i],mx,my,enabled,rndtgt,position,OffsetX,OffsetY,parentAlpha,visible)
			end
		end
	end
	return rndtgt
end