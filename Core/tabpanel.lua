function dgsDxCreateTabPanel(x,y,sx,sy,relative,parent,tabheight,defbgcolor)
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"@dgsDxCreateTabPanel argument 6,expect dgs-dxgui got "..dgsGetType(parent))
	end
	assert(tonumber(x),"@dgsDxCreateTabPanel argument 1,expect number got "..type(x))
	assert(tonumber(y),"@dgsDxCreateTabPanel argument 2,expect number got "..type(y))
	assert(tonumber(sx),"@dgsDxCreateTabPanel argument 3,expect number got "..type(sx))
	assert(tonumber(sy),"@dgsDxCreateTabPanel argument 4,expect number got "..type(sy))
	local tabpanel = createElement("dgs-dxtabpanel")
	dgsSetType(tabpanel,"dgs-dxtabpanel")
	if isElement(parent) then
		dgsSetParent(tabpanel,parent)
	else
		table.insert(MaxFatherTable,tabpanel)
	end
	dgsSetData(tabpanel,"tabheight",{tabheight or 20,false})
	dgsSetData(tabpanel,"tabmaxwidth",{10000,false})
	dgsSetData(tabpanel,"tabminwidth",{10,false})
	dgsSetData(tabpanel,"font",msyh)
	dgsSetData(tabpanel,"defbackground",tonumber(defbgcolor) or tocolor(0,0,0,180))
	dgsSetData(tabpanel,"tabs",{})
	dgsSetData(tabpanel,"selected",-1)
	dgsSetData(tabpanel,"tabsidesize",{4,false},true)
	dgsSetData(tabpanel,"tabgapsize",{1,false},true)
	dgsSetData(tabpanel,"scrollSpeed",{10,false})
	dgsSetData(tabpanel,"taboffperc",0)
	dgsSetData(tabpanel,"allleng",0)
	insertResourceDxGUI(sourceResource,tabpanel)
	triggerEvent("onClientDgsDxGuiPreCreate",tabpanel)
	calculateGuiPositionSize(tabpanel,x,y,relative,sx,sy,relative,true)
	local abx,aby = unpack(dgsGetData(tabpanel,"absSize"))
	local rendertarget = dxCreateRenderTarget(abx,tabheight or 20,true)
	dgsSetData(tabpanel,"renderTarget",rendertarget)
	triggerEvent("onClientDgsDxGuiCreate",tabpanel)
	return tabpanel
end

function dgsDxCreateTab(text,tabpanel,textsizex,textsizey,textcolor,bgimg,bgcolor,tabdefimg,tabselimg,tabcliimg,tabdefcolor,tabselcolor,tabclicolor)
	assert(type(text) == "string" or type(text) == "number","@dgsCreateTab argument 1, expect string/number got "..type(text))
	assert(dgsGetType(tabpanel) == "dgs-dxtabpanel","@dgsCreateTab argument 2, expect dgs-dxtabpanel got "..(dgsGetType(tabpanel) or type(tabpanel)))
	local tab = createElement("dgs-dxtab")
	dgsSetType(tab,"dgs-dxtab")
	dgsSetData(tab,"text",text)
	dgsSetData(tab,"parent",tabpanel)
	local tabs = dgsElementData[tabpanel].tabs
	local id = #tabs+1
	table.insert(tabs,id,tab)
	dgsSetData(tab,"id",id)
	local font = dgsElementData[tabpanel]["font"]
	local minwidth = dgsElementData[tabpanel]["tabminwidth"][2] and dgsElementData[tabpanel]["tabminwidth"][1]*h or dgsElementData[tabpanel]["tabminwidth"][1]
	local maxwidth = dgsElementData[tabpanel]["tabmaxwidth"][2] and dgsElementData[tabpanel]["tabmaxwidth"][1]*h or dgsElementData[tabpanel]["tabmaxwidth"][1]
	local wid = math.min(math.max(dxGetTextWidth(text,textsizex or 1,font),minwidth),maxwidth)
	local tabsidesize = dgsElementData[tabpanel]["tabsidesize"][2] and dgsElementData[tabpanel]["tabsidesize"][1]*w or dgsElementData[tabpanel]["tabsidesize"][1]
	local gap = dgsElementData[tabpanel]["tabgapsize"][2] and dgsElementData[tabpanel]["tabgapsize"][1]*w or dgsElementData[tabpanel]["tabgapsize"][1]
	dgsSetData(tabpanel,"allleng",dgsElementData[tabpanel]["allleng"]+wid+tabsidesize*2+gap*math.min(#tabs,1))
	dgsSetData(tab,"width",wid)
	dgsSetData(tab,"textcolor",tonumber(textcolor) or tocolor(255,255,255,255))
	dgsSetData(tab,"textsize",{textsizex or 1,textsizey or 1})
	dgsSetData(tab,"bgcolor",tonumber(bgcolor) or tocolor(0,0,0,200))
	dgsSetData(tab,"bgimg",bgimg or nil)
	dgsSetData(tab,"tabimg",{tabdefimg,tabselimg,tabcliimg})
	dgsSetData(tab,"tabcolor",{tonumber(tabdefcolor) or tocolor(40,40,40,180),tonumber(tabselcolor) or tocolor(80,80,80,190),tonumber(tabclicolor) or tocolor(0,0,0,200)})
	insertResourceDxGUI(sourceResource,tabpanel)
	triggerEvent("onClientDgsDxGuiPreCreate",tab)
	if dgsElementData[tabpanel]["selected"] == -1 then
		dgsSetData(tabpanel,"selected",id)
	end
	triggerEvent("onClientDgsDxGuiCreate",tab)
	return tab
end

function dgsDxTabPanelGetTabFromID(tabpanel,id)
	assert(dgsGetType(tabpanel) == "dgs-dxtabpanel","@dgsDxTabPanelGetTabFromID at argument 1, expect dgs-dxtabpanel got "..(dgsGetType(tabpanel) or type(tabpanel)))
	assert(type(id) == "number","@dgsDxTabPanelGetTabFromID at argument 2, expect number got "..type(id))
	local tabs = dgsElementData[tabpanel]["tabs"]
	return tabs[id]
end

function dgsDxTabPanelMoveTab(tabpanel,from,to)
	assert(dgsGetType(tabpanel) == "dgs-dxtabpanel","@dgsDxTabPanelMoveTab at argument 1, expect dgs-dxtabpanel got "..(dgsGetType(tabpanel) or type(tabpanel)))
	assert(type(from) == "number","@dgsDxTabPanelMoveTab at argument 2, expect number got "..type(from))
	assert(type(to) == "number","@dgsDxTabPanelMoveTab at argument 3, expect number got "..type(to))
	local tab = dgsElementData[tabpanel]["tabs"][from]
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

function dgsDxTabPanelGetTabID(tab)
	assert(dgsGetType(tab) == "dgs-dxtab","@dgsDxTabPanelGetTabID at argument 1, expect dgs-dxtab got "..(dgsGetType(tab) or type(tab)))
	return dgsElementData[tab].id
end

function dgsDxDeleteTab(tab)
	assert(dgsGetType(tab) == "dgs-dxtab","@dgsDxDeleteTab at argument 1, expect dgs-dxtab got "..(dgsGetType(tab) or type(tab)))
	local tabpanel = dgsGetData(tab,"parent")
	if dgsGetType(tabpanel) == "dgs-dxtabpanel" then
		local wid = dgsElementData[tab]["width"]
		local tabs = dgsElementData[tabpanel].tabs
		local tabsidesize = dgsElementData[tabpanel]["tabsidesize"][2] and dgsElementData[tabpanel]["tabsidesize"][1]*w or dgsElementData[tabpanel]["tabsidesize"][1]
		local gap = dgsElementData[tabpanel]["tabgapsize"][2] and dgsElementData[tabpanel]["tabgapsize"][1]*w or dgsElementData[tabpanel]["tabgapsize"][1]
		dgsSetData(tabpanel,"allleng",dgsElementData[tabpanel]["allleng"]-wid-tabsidesize*2-gap*math.min(#tabs,1))
		local id = dgsGetData(tab,"id")
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
	local sx,sy = unpack(dgsGetData(source,"absSize"))
	local tabHeight = dgsGetData(source,"tabheight")
	local rentarg = dgsGetData(source,"renderTarget")
	if isElement(rentarg[1]) then
		destroyElement(rentarg[1])
	end
	local tabRender = dxCreateRenderTarget(sx,tabHeight[2] and tabHeight[1]*sy or tabHeight[1],true)
	dgsSetData(source,"renderTarget",tabRender)
end