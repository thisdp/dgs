--Dx Functions
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
local lerp = math.lerp
local mathFloor = math.floor
local mathMin = math.min
local mathMax = math.max
local tableInsert = table.insert
local tableRemove = table.remove
local assert = assert
local type = type
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
	local xCheck,yCheck,wCheck,hCheck = type (x) == "number",type(y) == "number",type(sx) == "number",type(sy) == "number"
	if not xCheck then assert(false,"Bad argument @dgsCreateComboBox at argument 1, expect number got "..type(x)) end
	if not yCheck then assert(false,"Bad argument @dgsCreateComboBox at argument 2, expect number got "..type(y)) end
	if not wCheck then assert(false,"Bad argument @dgsCreateComboBox at argument 3, expect number got "..type(sx)) end
	if not hCheck then assert(false,"Bad argument @dgsCreateComboBox at argument 4, expect number got "..type(sy)) end
	local combobox = createElement("dgs-dxcombobox")
	dgsSetType(combobox,"dgs-dxcombobox")
	dgsSetParent(combobox,parent,true,true)
	local style = styleSettings.combobox
	local defcolor = defcolor or style.color[1]
	local hovcolor = hovcolor or style.color[2]
	local clicolor = clicolor or style.color[3]
	local defimg = defimg or dgsCreateTextureFromStyle(style.image[1])
	local hovimg = hovimg or dgsCreateTextureFromStyle(style.image[2])
	local cliimg = cliimg or dgsCreateTextureFromStyle(style.image[3])
	local idefcolor = style.itemColor[1]
	local ihovcolor = style.itemColor[2]
	local iclicolor = style.itemColor[3]
	local idefimg = dgsCreateTextureFromStyle(style.itemImage[1])
	local ihovimg = dgsCreateTextureFromStyle(style.itemImage[2])
	local icliimage = dgsCreateTextureFromStyle(style.itemImage[3])
	local textScaleX,textScaleY = tonumber(scalex),tonumber(scaley)
	local scbThick = style.scrollBarThick
	dgsElementData[combobox] = {
		renderBuffer = {},
		color = {defcolor,hovcolor,clicolor},
		image = {defimg,hovimg,cliimg},
		itemColor = {idefcolor,ihovcolor,iclicolor},
		itemImage = {idefimg,ihovimg,icliimage},
		textColor = textColor or style.textColor,
		itemTextColor = textColor or style.itemTextColor,
		textSize = {textScaleX or style.textSize[1],textScaleY or style.textSize[2]},
		itemTextSize = {textScaleX or style.itemTextSize[1],textScaleY or style.itemTextSize[2]},
		shadow = false,
		font = style.font or systemFont,
		bgColor = style.bgColor,
		bgImage = dgsCreateTextureFromStyle(style.bgImage),
		buttonLen = {1,true}, --1,isRelative
		textBox = true,
		select = -1,
		clip = false,
		wordbreak = false,
		itemHeight = itemheight or style.itemHeight,
		viewCount = false,
		colorcoded = false,
		listState = -1,
		listStateAnim = -1,
		autoHideAfterSelected = style.autoHideAfterSelected,
		itemTextPadding = style.itemTextPadding,
		textPadding = style.textPadding,
		arrow = dgsCreateTextureFromStyle(style.arrow),
		arrowColor = style.arrowColor,
		arrowSettings = style.arrowSettings or {0.3,0.15,0.04},
		arrowOutSideColor = style.arrowOutSideColor,
		scrollBarThick = scbThick,
		itemData = {},
		alignment = {"left","center"},
		itemAlignment = {"left","center"},
		FromTo = {0,0},
		moveHardness = {0.1,0.9},
		itemMoveOffset = 0,
		itemMoveOffsetTemp = 0,
		scrollSize = 20, --60px pixels
		scrollFloor = true,
		captionEdit = false,
		configNextFrame = false,
	}
	dgsAttachToTranslation(combobox,resourceTranslation[sourceResource or getThisResource()])
	if type(caption) == "table" then
		dgsElementData[combobox]._translationText = caption
		dgsSetData(combobox,"caption",caption)
	else
		dgsSetData(combobox,"caption",tostring(caption))
	end
	calculateGuiPositionSize(combobox,x,y,relative or false,sx,sy,relative or false,true)
	local box = dgsComboBoxCreateBox(0,1,1,3,true,combobox)
	dgsElementData[combobox].myBox = box
	dgsElementData[box].myCombo = combobox
	local boxsiz = dgsElementData[box].absSize
	local renderTarget,err = dxCreateRenderTarget(boxsiz[1],boxsiz[2],true,combobox)
	if renderTarget ~= false then
		dgsAttachToAutoDestroy(renderTarget,combobox,-1)
	else
		outputDebugString(err)
	end
	dgsElementData[combobox].renderTarget = renderTarget
	local scrollbar = dgsCreateScrollBar(boxsiz[1]-scbThick,0,scbThick,boxsiz[2],false,false,box)
	dgsSetData(scrollbar,"length",{0,true})
	dgsSetData(scrollbar,"multiplier",{1,true})
	dgsSetData(scrollbar,"myCombo",combobox)
	dgsSetData(scrollbar,"minLength",10)
	dgsSetVisible(scrollbar,false)
	dgsSetVisible(box,false)
	addEventHandler("onDgsElementScroll",scrollbar,checkCBScrollBar,false)
	dgsElementData[combobox].scrollbar = scrollbar
	addEventHandler("onDgsBlur",box,function(nextFocused)
		local combobox = dgsElementData[source].myCombo
		local scb = dgsElementData[combobox].scrollbar
		if nextFocused ~= combobox and nextFocused ~= scb then
			dgsComboBoxSetState(combobox,false)
		end
	end,false)
	addEventHandler("onDgsBlur",scrollbar,function(nextFocused)
		local combobox = dgsElementData[source].myCombo
		local box = dgsElementData[combobox].myBox
		if nextFocused ~= combobox and nextFocused ~= box then
			dgsComboBoxSetState(combobox,false)
		end
	end,false)
	triggerEvent("onDgsCreate",combobox,sourceResource)
	dgsSetData(combobox,"hitoutofparent",true)
	return combobox
end

function dgsComboBoxSetCaptionText(combobox,caption)
	assert(dgsGetType(combobox) == "dgs-dxcombobox","Bad argument @dgsComboBoxSetDefaultText at argument 1, expect dgs-dxcombobox got "..dgsGetType(combobox))
	return dgsSetData(combobox,"caption",caption)
end

function dgsComboBoxGetText(combobox)
	assert(dgsGetType(combobox) == "dgs-dxcombobox","Bad argument @dgsComboBoxGetText at argument 1, expect dgs-dxcombobox got "..dgsGetType(combobox))
	local captionEdit = dgsElementData[combobox].captionEdit
	local selection = dgsElementData[combobox].select
	local itemData = dgsElementData[combobox].itemData
	local text = itemData[selection] and itemData[selection][1]
	if captionEdit then
		text = text or dgsGetText(captionEdit)
	else
		text = text or dgsElementData[combobox].caption
	end
	return text or false
end

function dgsComboBoxGetCaptionText(combobox)
	assert(dgsGetType(combobox) == "dgs-dxcombobox","Bad argument @dgsComboBoxSetDefaultText at argument 1, expect dgs-dxcombobox got "..dgsGetType(combobox))
	return dgsElementData[combobox].caption
end

function dgsComboBoxSetEditEnabled(combobox,enabled)
	assert(dgsGetType(combobox) == "dgs-dxcombobox","Bad argument @dgsComboBoxSetEditEnabled at argument 1, expect dgs-dxcombobox got "..dgsGetType(combobox))
	local captionEdit = dgsElementData[combobox].captionEdit
	if enabled then
		if not isElement(captionEdit) then
			local size = dgsElementData[combobox].absSize
			local w,h = size[1],size[2]
			local buttonLen_t = dgsElementData[combobox].buttonLen
			local buttonLen = 0
			if dgsElementData[combobox].textBox then
				buttonLen = w - (buttonLen_t[2] and buttonLen_t[1]*h or buttonLen_t[1])
			end
			local edit = dgsCreateEdit(0,0,buttonLen,h,dgsElementData[combobox].caption,false,combobox)
			dgsSetData(edit,"bgColor",0)
			dgsSetData(combobox,"captionEdit",edit)
			dgsSetData(edit,"padding",dgsElementData[combobox].textPadding)
			if not dgsElementData[combobox].textBox then
				dgsSetVisible(edit,false)
			end
		end
	elseif isElement(captionEdit) then
		destroyElement(captionEdit)
		dgsSetData(combobox,"captionEdit",false)
	end
end


function dgsComboBoxGetEditEnabled(combobox)
	assert(dgsGetType(combobox) == "dgs-dxcombobox","Bad argument @dgsComboBoxGetEditEnabled at argument 1, expect dgs-dxcombobox got "..dgsGetType(combobox))
	return isElement(dgsElementData[combobox].captionEdit) and true or false
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
	local _text
	if type(text) == "table" then
		_text = text
		text = dgsTranslate(combobox,text,sourceResource)
	end
	local tab = {
		[-6] = nil,										--built-in image {[1]=image,[2]=color,[3]=offsetX,[4]=offsetY,[5]=width,[6]=height,[7]=relative}
		[-5] = dgsElementData[combobox].colorcoded,		--use color code
		[-4] = dgsElementData[combobox].font,			--font
		[-3] = dgsElementData[combobox].itemTextSize,	--text size of item
		[-2] = dgsElementData[combobox].itemTextColor,	--text color of item
		[-1] = dgsElementData[combobox].itemImage,		--background image of item
		[0] = dgsElementData[combobox].itemColor,		--background color of item
		tostring(text),
		_translationText = _text
	}

	tableInsert(data,id,tab)
	if id*itemHeight > size[2] then
		local scrollBar = dgsElementData[combobox].scrollbar
		dgsSetVisible(scrollBar,true)
	end
	dgsSetData(combobox,"configNextFrame",true)
	return id
end

function dgsComboBoxSetItemText(combobox,item,text)
	assert(dgsGetType(combobox) == "dgs-dxcombobox","Bad argument @dgsComboBoxSetItemText at argument 1, expect dgs-dxcombobox got "..dgsGetType(combobox))
	assert(type(item) == "number","Bad argument @dgsComboBoxSetItemText at argument 2, expect number got "..type(item))
	local data = dgsElementData[combobox].itemData
	item = mathFloor(item)
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
	local item = mathFloor(item)
	if item >= 1 and item <= #data then
		return data[item][1]
	end
	return false
end

function dgsComboBoxGetItemCount(combobox)
	assert(dgsGetType(combobox) == "dgs-dxcombobox","Bad argument @dgsComboBoxGetItemCount at argument 1, expect dgs-dxcombobox got "..dgsGetType(combobox))
	return #dgsElementData[combobox].itemData
end

function dgsComboBoxSetItemColor(combobox,item,color)
	assert(dgsGetType(combobox) == "dgs-dxcombobox","Bad argument @dgsComboBoxSetItemColor at argument 1, expect dgs-dxcombobox got "..dgsGetType(combobox))
	assert(type(item) == "number","Bad argument @dgsComboBoxSetItemColor at argument 2, expect number got "..type(item))
	assert(type(color) == "number" or type(color) == "number","Bad argument @dgsComboBoxSetItemColor at argument 3, expect number/string got "..type(color))
	local data = dgsElementData[combobox].itemData
	item = mathFloor(item)
	if item >= 1 and item <= #data then
		data[item][-2] = color
		return true
	end
	return false
end

function dgsComboBoxGetItemColor(combobox,item)
	assert(dgsGetType(combobox) == "dgs-dxcombobox","Bad argument @dgsComboBoxGetItemColor at argument 1, expect dgs-dxcombobox got "..dgsGetType(combobox))
	assert(type(item) == "number","@dgsComboBoxGetItemColor argument 2,expect number got "..type(item))
	local data = dgsElementData[combobox].itemData
	item = mathFloor(item)
	if item >= 1 and item <= #data then
		return data[item][-2]
	end
	return false
end

function dgsComboBoxSetItemFont(combobox,item,font)
	assert(dgsGetType(combobox) == "dgs-dxcombobox","Bad argument @dgsComboBoxSetItemFont at argument 1, expect dgs-dxcombobox got "..dgsGetType(combobox))
	assert(type(item) == "number","Bad argument @dgsComboBoxSetItemFont at argument 2, expect number got "..type(item))
	assert(fontBuiltIn[font] or dgsGetType(font) == "dx-font","Bad argument @dgsComboBoxSetItemFont at argument 3, invaild font (Type:"..dgsGetType(font)..",Value:"..tostring(font)..")")
	local data = dgsElementData[combobox].itemData
	item = mathFloor(item)
	if item >= 1 and item <= #data then
		data[item][-4] = font
		return true
	end
	return false
end

function dgsComboBoxGetItemFont(combobox,item)
	assert(dgsGetType(combobox) == "dgs-dxcombobox","Bad argument @dgsComboBoxGetItemFont at argument 1, expect dgs-dxcombobox got "..dgsGetType(combobox))
	assert(type(item) == "number","@dgsComboBoxGetItemFont argument 2,expect number got "..type(item))
	local data = dgsElementData[combobox].itemData
	item = mathFloor(item)
	if item >= 1 and item <= #data then
		return data[item][-4]
	end
	return false
end

function dgsComboBoxSetItemImage(combobox,item,image,color,offx,offy,w,h,relative)
	assert(dgsGetType(combobox) == "dgs-dxcombobox","Bad argument @dgsComboBoxSetItemImage at argument 1, expect dgs-dxcombobox got "..dgsGetType(combobox))
	assert(type(item) == "number","Bad argument @dgsComboBoxSetItemImage at argument 2, expect number got "..type(item))
	local data = dgsElementData[combobox].itemData
	item = mathFloor(item)
	if item >= 1 and item <= #data then
		local imageData = data[item][-6] or {}
		imageData[1] = image or imageData[1]
		imageData[2] = color or imageData[2] or white
		imageData[3] = offx or imageData[3] or 0
		imageData[4] = offy or imageData[4] or 0
		imageData[5] = w or imageData[5] or relative and 1 or dgsGetSize(combobox)
		imageData[6] = h or imageData[6] or relative and 1 or dgsElementData[combobox].itemHeight
		imageData[7] = relative or false
		data[item][-6] = imageData
		return true
	end
	return false
end

function dgsComboBoxGetItemImage(combobox,item)
	assert(dgsGetType(combobox) == "dgs-dxcombobox","Bad argument @dgsComboBoxGetItemImage at argument 1, expect dgs-dxcombobox got "..dgsGetType(combobox))
	assert(type(item) == "number","Bad argument @dgsComboBoxGetItemImage at argument 2, expect number got "..type(item))
	local data = dgsElementData[combobox].itemData
	item = mathFloor(item)
	if item >= 1 and item <= #data then
		return unpack(data[item][-6] or {})
	end
	return false
end

function dgsComboBoxRemoveItemImage(combobox,item)
	assert(dgsGetType(combobox) == "dgs-dxcombobox","Bad argument @dgsComboBoxRemoveItemImage at argument 1, expect dgs-dxcombobox got "..dgsGetType(combobox))
	assert(type(item) == "number","Bad argument @dgsComboBoxRemoveItemImage at argument 2, expect number got "..type(item))
	local data = dgsElementData[combobox].itemData
	item = mathFloor(item)
	if item >= 1 and item <= #data and data[item][-6] then
		data[item][-6] = nil
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

function dgsComboBoxRemoveItem(combobox,item)
	assert(dgsGetType(combobox) == "dgs-dxcombobox","Bad argument @dgsComboBoxRemoveItem at argument 1, expect dgs-dxcombobox got "..dgsGetType(combobox))
	assert(tonumber(item),"Bad argument @dgsComboBoxRemoveItem at argument 2, expect number got "..type(item))
	local data = dgsElementData[combobox].itemData
	local item = tonumber(item)
	local item = mathFloor(item)
	if item >= 1 and item <= #data then
		tableRemove(data,item)
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
	tableRemove(data)
	dgsElementData[combobox].itemData = {}
	local scb = dgsElementData[combobox].scrollbar
	dgsSetVisible(scb,false)
	return true
end

function dgsComboBoxCreateBox(x,y,sx,sy,relative,parent)
	local xCheck,yCheck,wCheck,hCheck,pCheck = type (x) == "number",type(y) == "number",type(sx) == "number",type(sy) == "number",dgsGetType(parent) == "dgs-dxcombobox"
	if not xCheck then assert(false,"Bad argument @dgsComboBoxCreateBox at argument 1, expect number got "..type(x)) end
	if not yCheck then assert(false,"Bad argument @dgsComboBoxCreateBox at argument 2, expect number got "..type(y)) end
	if not wCheck then assert(false,"Bad argument @dgsComboBoxCreateBox at argument 3, expect number got "..type(sx)) end
	if not hCheck then assert(false,"Bad argument @dgsComboBoxCreateBox at argument 4, expect number got "..type(sy)) end
	if not pCheck then assert(false,"Bad argument @dgsComboBoxCreateBox at argument 6, expect dgs-dxcombobox got "..dgsGetType(parent)) end
	local box = createElement("dgs-dxcombobox-Box")
	dgsSetType(box,"dgs-dxcombobox-Box")
	dgsSetParent(box,parent,true,true)
	insertResource(sourceResource,box)
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

function configComboBox(combobox,remainBox)
	if not remainBox then
		local box = dgsElementData[combobox].myBox
		local boxsiz = dgsElementData[box].absSize
		local renderTarget = dgsElementData[combobox].renderTarget
		if isElement(renderTarget) then destroyElement(renderTarget) end
		local sbt = dgsElementData[combobox].scrollBarThick
		local renderTarget,err = dxCreateRenderTarget(boxsiz[1],boxsiz[2],true,combobox)
		if renderTarget ~= false then
			dgsAttachToAutoDestroy(renderTarget,combobox,-1)
		else
			outputDebugString(err)
		end
		dgsSetData(combobox,"renderTarget",renderTarget)
		local scrollbar = dgsElementData[combobox].scrollbar
		dgsSetPosition(scrollbar,boxsiz[1]-sbt,0,false)
		dgsSetSize(scrollbar,sbt,boxsiz[2],false)
		local itemData = dgsElementData[combobox].itemData
		local itemHeight = dgsElementData[combobox].itemHeight
		local itemLength = itemHeight*#itemData
		local higLen = 1-(itemLength-boxsiz[2])/itemLength
		higLen = higLen >= 0.95 and 0.95 or higLen
		dgsSetData(scrollbar,"length",{higLen,true})
		local verticalScrollSize = dgsElementData[combobox].scrollSize/(itemLength-boxsiz[2])
		dgsSetData(scrollbar,"multiplier",{verticalScrollSize,true})
		dgsSetData(combobox,"configNextFrame",false)
	end
	---------------Caption edit
	local edit = dgsElementData[combobox].captionEdit
	if edit then
		local size = dgsElementData[combobox].absSize
		local w,h = size[1],size[2]
		local buttonLen_t = dgsElementData[combobox].buttonLen
		local buttonLen = 0
		if dgsElementData[combobox].textBox then
			buttonLen = w - (buttonLen_t[2] and buttonLen_t[1]*h or buttonLen_t[1])
		end
		dgsSetSize(edit,buttonLen,h,false)
		dgsSetVisible(edit,dgsElementData[combobox].textBox)
	end
end

function checkCBScrollBar(scb,new,old)
	local parent = dgsGetParent(source)
	if dgsGetType(parent) == "dgs-dxcombobox-Box" then
		local combobox = dgsElementData[parent].myCombo
		local scrollBar = dgsElementData[combobox].scrollbar
		local sx,sy = dgsElementData[parent].absSize[1],dgsElementData[parent].absSize[2]
		if source == scrollBar then
			local itemLength = #dgsElementData[combobox].itemData*dgsElementData[combobox].itemHeight
			local temp = -new*(itemLength-sy)/100
			local temp = dgsElementData[combobox].scrollFloor and mathFloor(temp) or temp
			dgsSetData(combobox,"itemMoveOffset",temp)
			triggerEvent("onDgsElementScroll",combobox,source,new,old)
		end
	end
end

addEventHandler("onDgsComboBoxStateChange",resourceRoot,function(state)
	if not wasEventCancelled() then
		local box = dgsElementData[source].myBox
		if state then
			dgsSetVisible(box,true)
			dgsFocus(box)
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

function dgsComboBoxSetViewCount(combobox,count)
	assert(dgsGetType(combobox) == "dgs-dxcombobox","Bad argument @dgsComboBoxSetViewCount at at argument 1, expect dgs-dxcombobox got "..dgsGetType(combobox))
	if type(count) == "number" then
		dgsSetData(combobox,"viewCount",count,true)
		return dgsComboBoxSetBoxHeight (combobox,count * dgsGetData(combobox,"itemHeight"))
	else
		return dgsSetData (combobox,"viewCount",false,true)
	end
end

function dgsComboBoxGetViewCount(combobox,count)
	assert(dgsGetType(combobox) == "dgs-dxcombobox","Bad argument @dgsComboBoxGetViewCount at at argument 1, expect dgs-dxcombobox got "..dgsGetType(combobox))
	return dgsElementData[combobox].viewCount
end

----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxcombobox"] = function(source,x,y,w,h,mx,my,cx,cy,enabled,eleData,parentAlpha,isPostGUI,rndtgt)
	if eleData.configNextFrame then
		configComboBox(source)
	end
	local captionEdit = eleData.captionEdit
	local colors,imgs = eleData.color,eleData.image
	local selectState = 1
	local textBox = eleData.textBox
	local buttonLen = textBox and (eleData.buttonLen[2] and eleData.buttonLen[1]*h or eleData.buttonLen[1]) or w
	if MouseData.enter == source then
		selectState = 2
		if eleData.clickType == 1 then
			if MouseData.clickl == source then
				selectState = 3
			end
		elseif eleData.clickType == 2 then
			if MouseData.clickr == source then
				selectState = 3
			end
		else
			if MouseData.clickl == source or MouseData.clickr == source then
				selectState = 3
			end
		end
	end
	local finalcolor
	if not enabled[1] and not enabled[2] then
		if type(eleData.disabledColor) == "number" then
			finalcolor = applyColorAlpha(eleData.disabledColor,parentAlpha)
		elseif eleData.disabledColor == true then
			local r,g,b,a = fromcolor(colors[1],true)
			local average = (r+g+b)/3*eleData.disabledColorPercent
			finalcolor = tocolor(average,average,average,a*parentAlpha)
		else
			finalcolor = colors[selectState]
		end
	else
		finalcolor = applyColorAlpha(colors[selectState],parentAlpha)
	end
	local bgColor = eleData.bgColor or finalcolor
	local bgImage = eleData.bgImage
	if imgs[selectState] then
		dxDrawImage(x+w-buttonLen,y,buttonLen,h,imgs[selectState],0,0,0,finalcolor,isPostGUI,rndtgt)
	else
		dxDrawRectangle(x+w-buttonLen,y,buttonLen,h,finalcolor,isPostGUI)
	end
	local arrowColor = eleData.arrowColor
	local arrowOutSideColor = eleData.arrowOutSideColor
	local textBoxLen = w-buttonLen
	if bgImage then
		dxDrawImage(x,y,textBoxLen,h,bgImage,0,0,0,applyColorAlpha(bgColor,parentAlpha),isPostGUI,rndtgt)
	else
		dxDrawRectangle(x,y,textBoxLen,h,applyColorAlpha(bgColor,parentAlpha),isPostGUI)
	end
	local shader = eleData.arrow
	local listState = eleData.listState
	if eleData.listStateAnim ~= listState then
		local stat = eleData.listStateAnim+eleData.listState*0.08
		eleData.listStateAnim = listState == -1 and mathMax(stat,listState) or mathMin(stat,listState)
	end
	if eleData.arrowSettings then
		dxSetShaderValue(shader,"width",eleData.arrowSettings[1])
		dxSetShaderValue(shader,"height",eleData.arrowSettings[2]*eleData.listStateAnim)
		dxSetShaderValue(shader,"linewidth",eleData.arrowSettings[3])
	end
	local r,g,b,a = fromcolor(arrowColor,true)
	dxSetShaderValue(shader,"_color",{r/255,g/255,b/255,a/255*parentAlpha})
	local r,g,b,a = fromcolor(arrowOutSideColor,true)
	dxSetShaderValue(shader,"ocolor",{r/255,g/255,b/255,a/255*parentAlpha})
	dxDrawImage(x+textBoxLen,y,buttonLen,h,shader,0,0,0,white,isPostGUI,rndtgt)
	if textBox and not captionEdit then
		local item = eleData.itemData[eleData.select] or {}
		local itemTextPadding = dgsElementData[source].itemTextPadding
		local font = item[-4] or eleData.font or systemFont
		local textColor = item[-2] or eleData.textColor
		local rb = eleData.alignment
		local txtSizX,txtSizY = item[-3] and item[-3][1] or eleData.textSize[1],item[-3] and (item[-3][2] or item[-3][1]) or eleData.textSize[2] or eleData.textSize[1]
		local colorcoded = item[-5] or eleData.colorcoded
		local shadow = eleData.shadow
		local wordbreak = eleData.wordbreak
		local text = item[1] or eleData.caption
		local image = item[-6]
		if image then
			local imagex = x+(image[7] and image[3]*textBoxLen or image[3])
			local imagey = y+(image[7] and image[4]*h or image[4])
			local imagew = image[7] and image[5]*textBoxLen or image[5]
			local imageh = image[7] and image[6]*h or image[6]
			if isElement(image[1]) then
				dxDrawImage(imagex,imagey,imagew,imageh,image[1],0,0,0,applyColorAlpha(image[2],parentAlpha),isPostGUI,rndtgt)
			else
				dxDrawRectangle(imagex,imagey,imagew,imageh,applyColorAlpha(image[2],parentAlpha),isPostGUI)
			end
		end
		local nx,ny,nw,nh = x+itemTextPadding[1],y,x+textBoxLen-itemTextPadding[2],y+h
		if shadow then
			dxDrawText(text:gsub("#%x%x%x%x%x%x",""),nx-shadow[1],ny-shadow[2],nw-shadow[1],nh-shadow[2],applyColorAlpha(shadow[3],parentAlpha),txtSizX,txtSizY,font,rb[1],rb[2],clip,wordbreak,isPostGUI)
		end
		dxDrawText(text,nx,ny,nw,nh,applyColorAlpha(textColor,parentAlpha),txtSizX,txtSizY,font,rb[1],rb[2],clip,wordbreak,isPostGUI,colorcoded)
	end
	return rndtgt
end

dgsRenderer["dgs-dxcombobox-Box"] = function(source,x,y,w,h,mx,my,cx,cy,enabled,eleData,parentAlpha,isPostGUI,rndtgt,position,OffsetX,OffsetY,visible)
	local combo = eleData.myCombo
	local DataTab = dgsElementData[combo]
	local itemData = DataTab.itemData
	local itemDataCount = #itemData
	local scbThick = dgsElementData[combo].scrollBarThick
	local itemHeight = DataTab.itemHeight
	--Smooth Item
	local _itemMoveOffset = DataTab.itemMoveOffset
	local scrollbar = dgsElementData[combo].scrollbar
	local itemMoveHardness = dgsElementData[ scrollbar ].moveType == "slow" and DataTab.moveHardness[1] or DataTab.moveHardness[2]
	DataTab.itemMoveOffsetTemp = lerp(itemMoveHardness,DataTab.itemMoveOffsetTemp,_itemMoveOffset)
	local itemMoveOffset = DataTab.itemMoveOffsetTemp-DataTab.itemMoveOffsetTemp%1

	local whichRowToStart = -mathFloor((itemMoveOffset+itemHeight)/itemHeight)+1
	local whichRowToEnd = whichRowToStart+mathFloor(h/itemHeight)+1
	DataTab.FromTo = {whichRowToStart > 0 and whichRowToStart or 1,whichRowToEnd <= itemDataCount and whichRowToEnd or itemDataCount}
	local renderTarget = dgsElementData[combo].renderTarget
	if isElement(renderTarget) then
		dxSetRenderTarget(renderTarget,true)
		dxSetBlendMode("modulate_add")
		local rb_l = dgsElementData[combo].itemAlignment
		local scbcheck = dgsElementData[scrollbar].visible and scbThick or 0
		if mx >= cx and mx <= cx+w-scbcheck and my >= cy and my <= cy+h and MouseData.enter == source then
			local toffset = (whichRowToStart*itemHeight)+itemMoveOffset
			sid = mathFloor((my+2-cy-toffset)/itemHeight)+whichRowToStart+1
			if sid <= itemDataCount then
				DataTab.preSelect = sid
				MouseData.enterData = true
			else
				DataTab.preSelect = -1
			end
		else
			DataTab.preSelect = -1
		end
		local preSelect = DataTab.preSelect
		local Select = DataTab.select
		local shadow = dgsElementData[combo].shadow
		local wordbreak = eleData.wordbreak
		local clip = eleData.clip
		local itemTextPadding = dgsElementData[combo].itemTextPadding
		for i=DataTab.FromTo[1],DataTab.FromTo[2] do
			local item = itemData[i]
			local textSize = item[-3]
			local textColor = item[-2]
			local image = item[-1]
			local color = item[0]
			local font = item[-4]
			local colorcoded = item[-5]
			local itemState = 1
			itemState = i == preSelect and 2 or itemState
			itemState = i == Select and 3 or itemState
			local rowpos = (i-1)*itemHeight
			if image[itemState] then
				dxDrawImage(0,rowpos+itemMoveOffset,w,itemHeight,image[itemState],0,0,0,color[itemState],false,rndtgt)
			else
				dxDrawRectangle(0,rowpos+itemMoveOffset,w,itemHeight,color[itemState])
			end
			local rowImage = item[-6]
			if rowImage then
				local itemWidth = dgsElementData[scrollbar].visible and w-dgsElementData[scrollbar].absSize[1] or w
				local imagex = rowImage[7] and rowImage[3]*itemWidth or rowImage[3]
				local imagey = (rowpos+itemMoveOffset) + (rowImage[7] and rowImage[4]*itemHeight or rowImage[4])
				local imagew = rowImage[7] and rowImage[5]*itemWidth or rowImage[5]
				local imageh = rowImage[7] and rowImage[6]*itemHeight or rowImage[6]
				if isElement(rowImage[1]) then
					dxDrawImage(imagex,imagey,imagew,imageh,rowImage[1],0,0,0,rowImage[2],false,rndtgt)
				else
					dxDrawRectangle(imagex,imagey,imagew,imageh,rowImage[2])
				end
			end
			local _y,_sx,_sy = rowpos+itemMoveOffset,sW-itemTextPadding[2],rowpos+itemHeight+itemMoveOffset
			local text = itemData[i][1]
			if shadow then
				dxDrawText(text:gsub("#%x%x%x%x%x%x",""),itemTextPadding[1]-shadow[1],_y-shadow[2],_sx-shadow[1],_sy-shadow[2],shadow[3],textSize[1],textSize[2],font,rb_l[1],rb_l[2],clip,wordbreak)
			end
			dxDrawText(text,itemTextPadding[1],_y,_sx,_sy,textColor,textSize[1],textSize[2],font,rb_l[1],rb_l[2],clip,wordbreak,false,colorcoded)
		end
		dxSetRenderTarget(rndtgt)
		dxSetBlendMode("add")
		_dxDrawImage(x,y,w,h,renderTarget,0,0,0,tocolor(255,255,255,255*parentAlpha),isPostGUI)
		dxSetBlendMode(rndtgt and "modulate_add" or "blend")
	end
	return rndtgt
end
