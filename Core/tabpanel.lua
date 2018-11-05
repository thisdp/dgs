function dgsCreateTabPanel(x,y,sx,sy,relative,parent,tabHeight,defbgColor)
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"Bad argument @dgsCreateTabPanel at argument 6, expect dgs-dxgui got "..dgsGetType(parent))
	end
	assert(tonumber(x),"Bad argument @dgsCreateTabPanel at argument 1, expect number got "..type(x))
	assert(tonumber(y),"Bad argument @dgsCreateTabPanel at argument 2, expect number got "..type(y))
	assert(tonumber(sx),"Bad argument @dgsCreateTabPanel at argument 3, expect number got "..type(sx))
	assert(tonumber(sy),"Bad argument @dgsCreateTabPanel at argument 4, expect number got "..type(sy))
	local tabpanel = createElement("dgs-dxtabpanel")
	local _ = dgsIsDxElement(parent) and dgsSetParent(tabpanel,parent,true,true) or table.insert(CenterFatherTable,1,tabpanel)
	dgsSetType(tabpanel,"dgs-dxtabpanel")
	dgsSetData(tabpanel,"renderBuffer",{})
	dgsSetData(tabpanel,"tabHeight",{tabHeight or styleSettings.tabpanel.tabHeight,false})
	dgsSetData(tabpanel,"tabMaxWidth",{10000,false})
	dgsSetData(tabpanel,"tabMinWidth",{10,false})
	dgsSetData(tabpanel,"font",systemFont)
	dgsSetData(tabpanel,"bgColor",tonumber(defbgColor) or styleSettings.tabpanel.bgColor)
	dgsSetData(tabpanel,"tabs",{})
	dgsSetData(tabpanel,"selected",-1)
	dgsSetData(tabpanel,"preSelect",-1)
	dgsSetData(tabpanel,"tabSideSize",styleSettings.tabpanel.tabSideSize,true)
	dgsSetData(tabpanel,"tabGapSize",styleSettings.tabpanel.tabGapSize,true)
	dgsSetData(tabpanel,"scrollSpeed",styleSettings.tabpanel.scrollSpeed)
	dgsSetData(tabpanel,"taboffperc",0)
	dgsSetData(tabpanel,"allleng",0)
	insertResourceDxGUI(sourceResource,tabpanel)
	calculateGuiPositionSize(tabpanel,x,y,relative,sx,sy,relative,true)
	local abx = dgsElementData[tabpanel].absSize[1]
	local rendertarget = dxCreateRenderTarget(abx,tabHeight or 20,true)
	dgsSetData(tabpanel,"renderTarget",rendertarget)
	triggerEvent("onDgsCreate",tabpanel)
	return tabpanel
end

function dgsCreateTab(text,tabpanel,textSizex,textSizey,textColor,bgImage,bgColor,tabnorimg,tabhovimg,tabcliimg,tabnorcolor,tabhovcolor,tabclicolor)
	assert(dgsGetType(tabpanel) == "dgs-dxtabpanel","Bad argument @dgsCreateTab at argument 2, expect dgs-dxtabpanel got "..dgsGetType(tabpanel))
	local tab = createElement("dgs-dxtab")
	dgsSetType(tab,"dgs-dxtab")
	dgsSetParent(tab,tabpanel,true,true)
	dgsSetData(tab,"parent",tabpanel)
	dgsAttachToTranslation(tab,resourceTranslation[sourceResource or getThisResource()])
	if type(text) == "table" then
		dgsElementData[tab]._translationText = text
		text = dgsTranslate(tab,text,sourceResource)
	end
	dgsSetData(tab,"text",tostring(text),true)
	local tabs = dgsElementData[tabpanel].tabs
	local id = #tabs+1
	table.insert(tabs,id,tab)
	dgsSetData(tab,"id",id)
	local tp_w = dgsElementData[tabpanel].absSize[1]
	local font = dgsElementData[tabpanel].font
	local t_minWid,t_maxWid = dgsElementData[tabpanel].tabMinWidth,dgsElementData[tabpanel].tabMaxWidth
	local minwidth,maxwidth = t_minWid[2] and t_minWid[1]*tp_w or t_minWid[1],t_maxWid[2] and t_maxWid[1]*tp_w or t_maxWid[1]
	local wid = math.restrict(minwidth,maxwidth,dxGetTextWidth(text,textSizex or 1,font))
	local t_sideSize = dgsElementData[tabpanel].tabSideSize
	local sidesize = t_sideSize[2] and t_sideSize[1]*tp_w or t_sideSize[1]
	local t_gapSize = dgsElementData[tabpanel].tabGapSize
	local gapsize = t_gapSize[2] and t_gapSize[1]*tp_w or t_gapSize[1]
	dgsSetData(tabpanel,"allleng",dgsElementData[tabpanel].allleng+wid+sidesize*2+gapsize*math.min(#tabs,1))
	dgsSetData(tab,"width",wid,true)
	dgsSetData(tab,"textColor",tonumber(textColor) or styleSettings.tab.textColor)
	local textSizeX,textSizeY = tonumber(textSizex) or styleSettings.tab.textSize[1], tonumber(textSizex) or styleSettings.tab.textSize[2]
	dgsSetData(tab,"textSize",{textSizeX,textSizeY})
	dgsSetData(tab,"bgColor",tonumber(bgColor) or styleSettings.tab.bgColor)
	dgsSetData(tab,"bgImage",bgImage or dgsCreateTextureFromStyle(styleSettings.tab.bgImage))
	
	local tabnorimg = tabnorimg or dgsCreateTextureFromStyle(styleSettings.tab.tabImage[1])
	local tabhovimg = tabhovimg or dgsCreateTextureFromStyle(styleSettings.tab.tabImage[2])
	local tabcliimg = tabcliimg or dgsCreateTextureFromStyle(styleSettings.tab.tabImage[3])
	dgsSetData(tab,"tabImage",{tabnorimg,tabhovimg,tabcliimg})
	
	local tabnorcolor = tabnorcolor or styleSettings.tab.tabColor[1]
	local tabhovcolor = tabhovcolor or styleSettings.tab.tabColor[2]
	local tabclicolor = tabclicolor or styleSettings.tab.tabColor[3]
	dgsSetData(tab,"tabColor",{tabnorcolor,tabhovcolor,tabclicolor})
	insertResourceDxGUI(sourceResource,tabpanel)
	triggerEvent("onDgsPreCreate",tab)
	if dgsElementData[tabpanel].selected == -1 then
		dgsSetData(tabpanel,"selected",id)
	end
	triggerEvent("onDgsCreate",tab)
	return tab
end

function dgsTabPanelGetWidth(tabpanel,includeInvisible)
	assert(dgsGetType(tabpanel) == "dgs-dxtabpanel","Bad argument @dgsTabPanelGetWidth at at argument 1, expect dgs-dxtabpanel got "..dgsGetType(tabpanel))
	local wid = 0
	local tabs = dgsElementData[tabpanel].tabs
	local t_sideSize = dgsElementData[tabpanel].tabSideSize
	local sidesize = t_sideSize[2] and t_sideSize[1]*tp_w or t_sideSize[1]
	local t_gapSize = dgsElementData[tabpanel].tabGapSize
	local gapsize = t_gapSize[2] and t_gapSize[1]*tp_w or t_gapSize[1]
	local cnt = 0
	if includeInvisible then
		for k,v in ipairs(tabs) do
			local width = dgsElementData[v].width
			wid = wid+width
			cnt=cnt+1
		end
	else
		for k,v in ipairs(tabs) do
			if dgsElementData[v].visible then
				local width = dgsElementData[v].width
				wid = wid+width
				cnt=cnt+1
			end
		end
	end
	return wid+(cnt-1)*gapsize+sidesize*2*cnt
end

function dgsTabPanelGetTabFromID(tabpanel,id)
	assert(dgsGetType(tabpanel) == "dgs-dxtabpanel","Bad argument @dgsTabPanelGetTabFromID at at argument 1, expect dgs-dxtabpanel got "..dgsGetType(tabpanel))
	assert(type(id) == "number","Bad argument @dgsTabPanelGetTabFromID at at argument 2, expect number got "..type(id))
	local tabs = dgsElementData[tabpanel].tabs
	return tabs[id]
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
		dgsElementData[tabs[i]].id = dgsElementData[tabs[i]].id-1
	end
	table.remove(tabs,myid)
	for i=to,#tabs do
		dgsElementData[tabs[i]].id = dgsElementData[tabs[i]].id+1
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
		local tp_w = dgsElementData[tabpanel].absSize[1]
		local wid = dgsElementData[tab].width
		local tabs = dgsElementData[tabpanel].tabs
		local t_sideSize = dgsElementData[tabpanel].tabSideSize
		local sidesize = t_sideSize[2] and t_sideSize[1]*tp_w or t_sideSize[1]
		local t_gapSize = dgsElementData[tabpanel].tabGapSize
		local gapsize = t_gapSize[2] and t_gapSize[1]*tp_w or t_gapSize[1]
		dgsSetData(tabpanel,"allleng",dgsElementData[tabpanel].allleng-wid-sidesize*2-gapsize*math.min(#tabs,1))
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
	if isElement(rentarg) then
		destroyElement(rentarg)
	end
	local tabRender = dxCreateRenderTarget(sx,tabHeight[2] and tabHeight[1]*sy or tabHeight[1],true)
	dgsSetData(source,"renderTarget",tabRender)
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
