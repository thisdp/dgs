function dgsCreateTabPanel(x,y,sx,sy,relative,parent,tabheight,defbgcolor)
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"Bad argument @dgsCreateTabPanel at argument 6, expect dgs-dxgui got "..dgsGetType(parent))
	end
	assert(tonumber(x),"Bad argument @dgsCreateTabPanel at argument 1, expect number got "..type(x))
	assert(tonumber(y),"Bad argument @dgsCreateTabPanel at argument 2, expect number got "..type(y))
	assert(tonumber(sx),"Bad argument @dgsCreateTabPanel at argument 3, expect number got "..type(sx))
	assert(tonumber(sy),"Bad argument @dgsCreateTabPanel at argument 4, expect number got "..type(sy))
	local tabpanel = createElement("dgs-dxtabpanel")
	dgsSetType(tabpanel,"dgs-dxtabpanel")
	local _ = dgsIsDxElement(parent) and dgsSetParent(tabpanel,parent,true) or table.insert(CenterFatherTable,1,tabpanel)
	dgsSetData(tabpanel,"tabheight",{tabheight or 20,false})
	dgsSetData(tabpanel,"tabmaxwidth",{10000,false})
	dgsSetData(tabpanel,"tabminwidth",{10,false})
	dgsSetData(tabpanel,"font",systemFont)
	dgsSetData(tabpanel,"defbackground",tonumber(defbgcolor) or schemeColor.tabpanel.defbackground)
	dgsSetData(tabpanel,"tabs",{})
	dgsSetData(tabpanel,"selected",-1)
	dgsSetData(tabpanel,"preSelect",-1)
	dgsSetData(tabpanel,"tabsidesize",{4,false},true)
	dgsSetData(tabpanel,"tabgapsize",{1,false},true)
	dgsSetData(tabpanel,"scrollSpeed",{10,false})
	dgsSetData(tabpanel,"taboffperc",0)
	dgsSetData(tabpanel,"allleng",0)
	insertResourceDxGUI(sourceResource,tabpanel)
	calculateGuiPositionSize(tabpanel,x,y,relative,sx,sy,relative,true)
	local abx,aby = dgsElementData[tabpanel].absSize
	local rendertarget = dxCreateRenderTarget(abx,tabheight or 20,true)
	dgsSetData(tabpanel,"renderTarget",rendertarget)
	triggerEvent("onDgsCreate",tabpanel)
	return tabpanel
end

function dgsCreateTab(text,tabpanel,textsizex,textsizey,textcolor,bgimg,bgcolor,tabdefimg,tabselimg,tabcliimg,tabdefcolor,tabselcolor,tabclicolor)
	assert(type(text) == "string" or type(text) == "number","Bad argument @dgsCreateTab at argument 1, expect string/number got "..type(text))
	assert(dgsGetType(tabpanel) == "dgs-dxtabpanel","Bad argument @dgsCreateTab at argument 2, expect dgs-dxtabpanel got "..dgsGetType(tabpanel))
	local tab = createElement("dgs-dxtab")
	dgsSetType(tab,"dgs-dxtab")
	dgsSetData(tab,"text",text,true)
	dgsSetData(tab,"parent",tabpanel)
	local tabs = dgsElementData[tabpanel].tabs
	local id = #tabs+1
	table.insert(tabs,id,tab)
	dgsSetData(tab,"id",id)
	local tp_w = dgsElementData[tabpanel].absSize[1]
	local font = dgsElementData[tabpanel].font
	local t_minWid,t_maxWid = dgsElementData[tabpanel].tabminwidth,dgsElementData[tabpanel].tabmaxwidth
	local minwidth,maxwidth = t_minWid[2] and t_minWid[1]*tp_w or t_minWid[1],t_maxWid[2] and t_maxWid[1]*tp_w or t_maxWid[1]
	local wid = math.restrict(minwidth,maxwidth,dxGetTextWidth(text,textsizex or 1,font))
	local t_sideSize = dgsElementData[tabpanel].tabsidesize
	local sidesize = t_sideSize[2] and t_sideSize[1]*tp_w or t_sideSize[1]
	local t_gapSize = dgsElementData[tabpanel].tabgapsize
	local gapsize = t_gapSize[2] and t_gapSize[1]*tp_w or t_gapSize[1]
	dgsSetData(tabpanel,"allleng",dgsElementData[tabpanel].allleng+wid+sidesize*2+gapsize*math.min(#tabs,1))
	dgsSetData(tab,"width",wid,true)
	dgsSetData(tab,"absrltWidth",{-1,false},false)
	dgsSetData(tab,"textcolor",tonumber(textcolor) or schemeColor.tab.textcolor)
	dgsSetData(tab,"textsize",{textsizex or 1,textsizey or 1})
	dgsSetData(tab,"bgcolor",tonumber(bgcolor) or schemeColor.tab.bgcolor)
	dgsSetData(tab,"bgimg",bgimg or nil)
	dgsSetData(tab,"tabimg",{tabdefimg,tabselimg,tabcliimg})
	dgsSetData(tab,"tabcolor",{tonumber(tabdefcolor) or schemeColor.tab.tabcolor[1],tonumber(tabselcolor) or schemeColor.tab.tabcolor[2],tonumber(tabclicolor) or schemeColor.tab.tabcolor[3]})
	insertResourceDxGUI(sourceResource,tabpanel)
	triggerEvent("onDgsPreCreate",tab)
	if dgsElementData[tabpanel].selected == -1 then
		dgsSetData(tabpanel,"selected",id)
	end
	triggerEvent("onDgsCreate",tab)
	return tab
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
		local t_sideSize = dgsElementData[tabpanel].tabsidesize
		local sidesize = t_sideSize[2] and t_sideSize[1]*tp_w or t_sideSize[1]
		local t_gapSize = dgsElementData[tabpanel].tabgapsize
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
	destroyElement(tab)
	return true
end

function configTabPanel(source)
	local sx,sy = dgsElementData[source].absSize[1],dgsElementData[source].absSize[2]
	local tabHeight = dgsElementData[source].tabheight
	local rentarg = dgsElementData[source].renderTarget
	if isElement(rentarg[1]) then
		destroyElement(rentarg[1])
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