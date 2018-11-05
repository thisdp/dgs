--[[
Item List Struct:
table = {
index:	-2			-1					0					1
		textColor	BackGround Image	BackGround Color	Text	
	{	color,		{def,hov,sel},		{def,hov,sel},		text	},
	{	color,		{def,hov,sel},		{def,hov,sel},		text	},
	{	color,		{def,hov,sel},		{def,hov,sel},		text	},
	{	color,		{def,hov,sel},		{def,hov,sel},		text	},
	{	color,		{def,hov,sel},		{def,hov,sel},		text	},
	{	color,		{def,hov,sel},		{def,hov,sel},		text	},
	{	color,		{def,hov,sel},		{def,hov,sel},		text	},
	{	...														},
}
]]

function dgsCreateComboBox(x,y,sx,sy,caption,relative,parent,itemheight,textColor,scalex,scaley,defimg,hovimg,cliimg,defcolor,hovcolor,clicolor)
	assert(tonumber(x),"Bad argument @dgsCreateComboBox at argument 1, expect number got "..type(x))
	assert(tonumber(y),"Bad argument @dgsCreateComboBox at argument 2, expect number got "..type(y))
	assert(tonumber(sx),"Bad argument @dgsCreateComboBox at argument 3, expect number got "..type(sx))
	assert(tonumber(sy),"Bad argument @dgsCreateComboBox at argument 4, expect number got "..type(sy))
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"Bad argument @dgsCreateComboBox at argument 6, expect dgs-dxgui got "..dgsGetType(parent))
	end
	local combobox = createElement("dgs-dxcombobox")
	local _x = dgsIsDxElement(parent) and dgsSetParent(combobox,parent,true,true) or table.insert(CenterFatherTable,1,combobox)
	dgsSetType(combobox,"dgs-dxcombobox")
	dgsSetData(combobox,"renderBuffer",{})
	
	local defcolor = defcolor or styleSettings.combobox.color[1]
	local hovcolor = hovcolor or styleSettings.combobox.color[2]
	local clicolor = clicolor or styleSettings.combobox.color[3]
	dgsSetData(combobox,"color",{defcolor,hovcolor,clicolor})
	
	local defimg = defimg or dgsCreateTextureFromStyle(styleSettings.combobox.image[1])
	local hovimg = hovimg or dgsCreateTextureFromStyle(styleSettings.combobox.image[2])
	local cliimg = cliimg or dgsCreateTextureFromStyle(styleSettings.combobox.image[3])
	dgsSetData(combobox,"image",{defimg,hovimg,cliimg})
	
	local idefcolor = styleSettings.combobox.itemColor[1]
	local ihovcolor = styleSettings.combobox.itemColor[2]
	local iclicolor = styleSettings.combobox.itemColor[3]
	dgsSetData(combobox,"itemColor",{idefcolor,ihovcolor,iselcolor})
	
	local idefimg = dgsCreateTextureFromStyle(styleSettings.combobox.itemImage[1])
	local ihovimg = dgsCreateTextureFromStyle(styleSettings.combobox.itemImage[2])
	local iselimg = dgsCreateTextureFromStyle(styleSettings.combobox.itemImage[3])
	dgsSetData(combobox,"itemImage",{idefimg,ihovimg,iselimg})
	
	dgsSetData(combobox,"textColor",textColor or styleSettings.combobox.textColor)
	dgsSetData(combobox,"itemTextColor",textColor or styleSettings.combobox.itemTextColor)
	local textScaleX,textScaleY = tonumber(scalex),tonumber(scaley)
	dgsSetData(combobox,"textSize",{textScaleX or styleSettings.combobox.textSize[1],textScaleY or styleSettings.combobox.textSize[2]})
	dgsSetData(combobox,"itemTextSize",{textScaleX or styleSettings.combobox.itemTextSize[1],textScaleY or styleSettings.combobox.itemTextSize[2]})
	dgsSetData(combobox,"shadow",false)
	dgsSetData(combobox,"font",systemFont)
	dgsSetData(combobox,"bgColor",styleSettings.combobox.bgColor)
	dgsSetData(combobox,"bgImage",dgsCreateTextureFromStyle(styleSettings.combobox.bgImage))
	dgsSetData(combobox,"buttonLen",{1,true}) --height
	dgsSetData(combobox,"textBox",true) --enable textbox
	dgsSetData(combobox,"select",-1)
	dgsSetData(combobox,"clip",false)
	dgsSetData(combobox,"wordbreak",false)
	dgsSetData(combobox,"itemHeight",itemheight or styleSettings.combobox.itemHeight)
	dgsSetData(combobox,"colorcoded",false)
	dgsSetData(combobox,"listState",-1,true)
	dgsSetData(combobox,"listStateAnim",-1)
	dgsSetData(combobox,"itemTextSide",styleSettings.combobox.itemTextSide)
	dgsSetData(combobox,"comboTextSide",styleSettings.combobox.comboTextSide)
	dgsSetData(combobox,"arrowColor",styleSettings.combobox.arrowColor)
	dgsSetData(combobox,"arrowSettings",{"height",0.15})
	dgsSetData(combobox,"arrowOutSideColor",styleSettings.combobox.arrowOutSideColor)
	local scbThick = styleSettings.combobox.scrollBarThick
	dgsSetData(combobox,"scrollBarThick",scbThick,true)
	dgsSetData(combobox,"itemData",{})
	dgsSetData(combobox,"rightbottom",{"left","center"})
	dgsSetData(combobox,"rightbottomList",{"left","center"})
	dgsSetData(combobox,"FromTo",{0,0})
	dgsSetData(combobox,"itemMoveOffset",0)
	dgsSetData(combobox,"scrollFloor",true)
	dgsAttachToTranslation(combobox,resourceTranslation[sourceResource or getThisResource()])
	if type(caption) == "table" then
		dgsElementData[combobox]._translationText = caption
		print(dgsElementData[combobox]._translationText)
		caption = dgsTranslate(combobox,caption,sourceResource)
	end
	dgsSetData(combobox,"caption",tostring(caption),true)
	dgsSetData(combobox,"autoHideWhenSelecting",true)
	dgsSetData(combobox,"arrow",dgsCreateTextureFromStyle(styleSettings.combobox.arrow))
	insertResourceDxGUI(sourceResource,combobox)
	calculateGuiPositionSize(combobox,x,y,relative or false,sx,sy,relative or false,true)
	local box = dgsComboBoxCreateBox(0,1,1,3,true,combobox)
	dgsSetData(combobox,"myBox",box)
	dgsSetData(box,"myCombo",combobox)
	local boxsiz = dgsElementData[box].absSize
	local rendertarget = dxCreateRenderTarget(boxsiz[1],boxsiz[2],true)
	dgsSetData(combobox,"renderTarget",rendertarget)
	local scrollbar = dgsCreateScrollBar(boxsiz[1]-scbThick,0,scbThick,boxsiz[2],false,false,box)
	dgsSetData(scrollbar,"length",{0,true})
	dgsSetData(scrollbar,"multiplier",{1,true})
	dgsSetData(scrollbar,"myCombo",combobox)
	dgsSetVisible(scrollbar,false)
	dgsSetVisible(box,false)
	dgsSetData(combobox,"scrollbar",scrollbar)
	triggerEvent("onDgsCreate",combobox)
	dgsSetData(combobox,"hitoutofparent",true)
	return combobox
end

function dgsComboBoxSetCaptionText(combobox,caption)
	assert(dgsGetType(combobox) == "dgs-dxcombobox","Bad argument @dgsComboBoxSetDefaultText at argument 1, expect dgs-dxcombobox got "..dgsGetType(combobox))
	if type(caption) == "table" then
		dgsElementData[combobox]._translationText = caption
		caption = dgsTranslate(combobox,caption,sourceResource)
	else
		dgsElementData[combobox]._translationText = nil
	end
	return dgsSetData(combobox,"caption",caption)
end

function dgsComboBoxGetCaptionText(combobox)
	assert(dgsGetType(combobox) == "dgs-dxcombobox","Bad argument @dgsComboBoxSetDefaultText at argument 1, expect dgs-dxcombobox got "..dgsGetType(combobox))
	return dgsElementData[combobox].caption
end

function dgsComboBoxSetBoxHeight(combobox,height,relative)
	assert(dgsGetType(combobox) == "dgs-dxcombobox","Bad argument @dgsComboBoxSetBoxHeight at argument 1, expect dgs-dxcombobox got "..dgsGetType(combobox))
	assert(type(height) == "number","Bad argument @dgsComboBoxSetBoxHeight at argument 2, expect number got "..type(height))
	relative = relative and true or false
	local box = dgsElementData[combobox].myBox
	if isElement(box) then
		local size = relative and dgsElementData[box].rltSize or dgsElementData[box].absSize
		return dgsSetSize(box,size[1],height,relative)
	end
	return false
end

function dgsComboBoxGetBoxHeight(combobox,relative)
	assert(dgsGetType(combobox) == "dgs-dxcombobox","Bad argument @dgsComboBoxGetBoxHeight at argument 1, expect dgs-dxcombobox got "..dgsGetType(combobox))
	relative = relative and true or false
	local box = dgsElementData[combobox].myBox
	if isElement(box) then
		local size = relative and dgsElementData[box].rltSize or dgsElementData[box].absSize
		return size[2]
	end
	return false
end

function dgsComboBoxAddItem(combobox,text)
	assert(dgsGetType(combobox) == "dgs-dxcombobox","Bad argument @dgsComboBoxAddItem at argument 1, expect dgs-dxcombobox got "..dgsGetType(combobox))
	local data = dgsElementData[combobox].itemData
	local itemHeight = dgsElementData[combobox].itemHeight
	local box = dgsElementData[combobox].myBox
	local size = dgsElementData[box].absSize
	local id = #data+1
	local tab = {}
	if type(text) == "table" then
		tab._translationText = text
		text = dgsTranslate(combobox,text,sourceResource)
	end
	tab[-3] = dgsElementData[combobox].itemTextSize
	tab[-2] = dgsElementData[combobox].itemTextColor
	tab[-1] = dgsElementData[combobox].itemImage
	tab[0] = dgsElementData[combobox].itemColor
	tab[1] = tostring(text)
	table.insert(data,id,tab)
	if id*itemHeight > size[2] then
		local scrollBar = dgsElementData[combobox].scrollbar
		dgsSetVisible(scrollBar,true)
	end
	return id
end

function dgsComboBoxSetItemText(combobox,item,text)
	assert(dgsGetType(combobox) == "dgs-dxcombobox","Bad argument @dgsComboBoxSetItemText at argument 1, expect dgs-dxcombobox got "..dgsGetType(combobox))
	assert(type(item) == "number","Bad argument @dgsComboBoxSetItemText at argument 2, expect number got "..type(item))
	local data = dgsElementData[combobox].itemData
	item = math.floor(item)
	if item >= 1 and item <= #data then
		if type(text) == "table" then
			data[item]._translationText = text
			text = dgsTranslate(combobox,text,sourceResource)
		else
			data[item]._translationText = nil
		end
		data[item][1] = tostring(text)
		return true
	end
	return false
end

function dgsComboBoxGetItemText(combobox,item)
	assert(dgsGetType(combobox) == "dgs-dxcombobox","Bad argument @dgsComboBoxGetItemText at argument 1, expect dgs-dxcombobox got "..dgsGetType(combobox))
	assert(tonumber(item),"Bad argument @dgsComboBoxGetItemText at argument 2, expect number got "..type(item))
	local data = dgsElementData[combobox].itemData
	local item = tonumber(item)
	local item = math.floor(item)
	if item >= 1 and item <= #data then
		return data[item][1]
	end
	return false
end

function dgsComboBoxSetItemColor(combobox,item,color)
	assert(dgsGetType(combobox) == "dgs-dxcombobox","Bad argument @dgsComboBoxSetItemColor at argument 1, expect dgs-dxcombobox got "..dgsGetType(combobox))
	assert(type(item) == "number","Bad argument @dgsComboBoxSetItemColor at argument 2, expect number got "..type(item))
	assert(type(color) == "number" or type(color) == "number","Bad argument @dgsComboBoxSetItemColor at argument 3, expect number/string got "..type(color))
	local data = dgsElementData[combobox].itemData
	item = math.floor(item)
	if item >= 1 and item <= #data then
		data[item][-2] = color
		return true
	end
	return false
end

function dgsComboBoxSetState(combobox,state)
	assert(dgsGetType(combobox) == "dgs-dxcombobox","Bad argument @dgsComboBoxSetState at argument 1, expect dgs-dxcombobox got "..dgsGetType(combobox))
	return dgsSetData(combobox,"listState",state and 1 or -1)
end

function dgsComboBoxGetState(combobox)
	assert(dgsGetType(combobox) == "dgs-dxcombobox","Bad argument @dgsComboBoxGetState at argument 1, expect dgs-dxcombobox got "..dgsGetType(combobox))
	return dgsElementData[combobox].listState == 1 and true or false
end

function dgsComboBoxGetItemColor(combobox,item)
	assert(dgsGetType(combobox) == "dgs-dxcombobox","Bad argument @dgsComboBoxGetItemColor at argument 1, expect dgs-dxcombobox got "..dgsGetType(combobox))
	assert(type(item) == "number","@dgsComboBoxGetItemColor argument 2,expect number got "..type(item))
	local data = dgsElementData[combobox].itemData
	item = math.floor(item)
	if item >= 1 and item <= #data then
		return data[item][-2]
	end
	return false
end

function dgsComboBoxRemoveItem(combobox,item)
	assert(dgsGetType(combobox) == "dgs-dxcombobox","Bad argument @dgsComboBoxRemoveItem at argument 1, expect dgs-dxcombobox got "..dgsGetType(combobox))
	assert(tonumber(item),"Bad argument @dgsComboBoxRemoveItem at argument 2, expect number got "..type(item))
	local data = dgsElementData[combobox].itemData
	local item = tonumber(item)
	local item = math.floor(item)
	if item >= 1 and item <= #data then
		table.remove(data,item)
		local itemHeight = dgsElementData[combobox].itemHeight
		local box = dgsElementData[combobox].myBox
		local size = dgsElementData[box].absSize
		if #data*itemHeight < size[2] then
			local scrollBar = dgsElementData[combobox].scrollbar
			dgsSetVisible(scrollBar,false)
		end
		return true
	end
	return false
end

function dgsComboBoxClear(combobox)
	assert(dgsGetType(combobox) == "dgs-dxcombobox","Bad argument @dgsComboBoxClear at argument 1, expect dgs-dxcombobox got "..dgsGetType(combobox))
	local data = dgsElementData[combobox].itemData
	table.remove(data)
	dgsElementData[combobox].itemData = {}
	local scrollBar = dgsElementData[combobox].scrollbar
	dgsSetVisible(scrollBar,false)
	return true
end

function dgsComboBoxCreateBox(x,y,sx,sy,relative,parent)
	assert(tonumber(x),"Bad argument @dgsComboBoxCreateBox at argument 1, expect number got "..type(x))
	assert(tonumber(y),"Bad argument @dgsComboBoxCreateBox at argument 2, expect number got "..type(y))
	assert(tonumber(sx),"Bad argument @dgsComboBoxCreateBox at argument 3, expect number got "..type(sx))
	assert(tonumber(sy),"Bad argument @dgsComboBoxCreateBox at argument 4, expect number got "..type(sy))
	assert(dgsGetType(parent) == "dgs-dxcombobox","Bad argument @dgsComboBoxCreateBox at argument 6, expect dgs-dxcombobox got "..dgsGetType(parent))
	local box = createElement("dgs-dxcombobox-Box")
	local _x = dgsIsDxElement(parent) and dgsSetParent(box,parent,true,true) or table.insert(CenterFatherTable,1,box)
	dgsSetType(box,"dgs-dxcombobox-Box")	
	insertResourceDxGUI(sourceResource,box)
	calculateGuiPositionSize(box,x,y,relative or false,sx,sy,relative or false,true)
	triggerEvent("onDgsCreate",box)
	return box
end

function dgsComboBoxSetSelectedItem(combobox,id)
	assert(dgsGetType(combobox) == "dgs-dxcombobox","Bad argument @dgsComboBoxSetSelectedItem at argument 1, expect dgs-dxcombobox got "..dgsGetType(combobox))
	assert(type(id) == "number","Bad argument @dgsComboBoxSetSelectedItem at argument 2, expect number got "..type(id))
	local itemData = dgsElementData[combobox].itemData
	local old = dgsElementData[combobox].select
	if not id or id == -1 then
		dgsSetData(combobox,"select",-1)
		triggerEvent("onDgsComboBoxSelect",combobox,-1,old)
		return true
	elseif id >= 1 and id <= #itemData then
		dgsSetData(combobox,"select",id)
		triggerEvent("onDgsComboBoxSelect",combobox,id,old)
		return true
	end
	return false
end

function dgsComboBoxGetSelectedItem(combobox)
	assert(dgsGetType(combobox) == "dgs-dxcombobox","Bad argument @dgsComboBoxGetSelectedItem at argument 1, expect dgs-dxcombobox got "..dgsGetType(combobox))
	local itemData = dgsElementData[combobox].itemData
	local selected = dgsElementData[combobox].select
	if selected < 1 and selected > #itemData then
		return -1
	else
		return selected
	end
end

function configComboBox_Box(box)
	local combobox = dgsElementData[box].myCombo
	local boxsiz = dgsElementData[box].absSize
	local rendertarget = dgsElementData[combobox].renderTarget
	if isElement(rendertarget) then
		destroyElement(rendertarget)
	end
	local sbt = dgsElementData[combobox].scrollBarThick
	local rendertarget = dxCreateRenderTarget(boxsiz[1],boxsiz[2],true)
	dgsSetData(combobox,"renderTarget",rendertarget)
	local sb = dgsElementData[combobox].scrollbar
	dgsSetPosition(sb,boxsiz[1]-sbt,0,false)
	dgsSetSize(sb,sbt,boxsiz[2],false)
	local itemData = dgsElementData[combobox].itemData
	local itemHeight = dgsElementData[combobox].itemHeight
	dgsSetData(sb,"length",{boxsiz[2]/(itemHeight*#itemData),true})
end

addEventHandler("onDgsScrollBarScrollPositionChange",root,function(new,old)
	local parent = dgsGetParent(source)
	if dgsGetType(parent) == "dgs-dxcombobox-Box" then
		local combobox = dgsElementData[parent].myCombo
		local scrollBar = dgsElementData[combobox].scrollbar
		local sx,sy = dgsElementData[parent].absSize[1],dgsElementData[parent].absSize[2]
		if source == scrollBar then
			local itemLength = #dgsElementData[combobox].itemData*dgsElementData[combobox].itemHeight
			local temp = -new*(itemLength-sy)/100
			local temp = dgsElementData[combobox].scrollFloor and math.floor(temp) or temp 
			dgsSetData(combobox,"itemMoveOffset",temp)
		end
	end
end)

addEventHandler("onDgsComboBoxStateChange",root,function(state)
	if not wasEventCancelled() then
		local box = dgsElementData[source].myBox
		if state then
			dgsSetVisible(box,true)
		else
			dgsSetVisible(box,false)
		end
	end
end)

function dgsComboBoxSetScrollPosition(combobox,vertical)
	assert(dgsGetType(combobox) == "dgs-dxcombobox","Bad argument @dgsComboBoxSetScrollPosition at at argument 1, expect dgs-dxcombobox got "..dgsGetType(combobox))
	assert(not vertical or (type(vertical) == "number" and vertical>= 0 and vertical <= 100),"Bad argument @dgsComboBoxSetScrollPosition at at argument 2, expect nil, none or number∈[0,100] got "..dgsGetType(vertical).."("..tostring(vertical)..")")
	local scb = dgsElementData[combobox].scrollbar
	if dgsElementData[scb].visible then
		return dgsScrollBarSetScrollPosition(scb,vertical)
	end
	return true
end

function dgsComboBoxGetScrollPosition(combobox)
	assert(dgsGetType(combobox) == "dgs-dxcombobox","Bad argument @dgsComboBoxGetScrollPosition at at argument 1, expect dgs-dxcombobox got "..dgsGetType(combobox))
	local scb = dgsElementData[combobox].scrollbar
	return dgsScrollBarGetScrollPosition(scb)
end
