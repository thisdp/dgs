--Dx Functions
local dxDrawImage = dxDrawImageExt
local dxDrawText = dxDrawText
local dxDrawRectangle = dxDrawRectangle
local dxSetShaderValue = dxSetShaderValue
local dxSetRenderTarget = dxSetRenderTarget
local dxSetBlendMode = dxSetBlendMode
local _dxDrawImage = _dxDrawImage
--DGS Functions
local dgsSetType = dgsSetType
local dgsGetType = dgsGetType
local dgsSetParent = dgsSetParent
local dgsSetData = dgsSetData
local dgsAttachToTranslation = dgsAttachToTranslation
local dgsAttachToAutoDestroy = dgsAttachToAutoDestroy
local calculateGuiPositionSize = calculateGuiPositionSize
local dgsCreateTextureFromStyle = dgsCreateTextureFromStyle
--Utilities
local triggerEvent = triggerEvent
local addEventHandler = addEventHandler
local createElement = createElement
local mathLerp = math.lerp
local mathFloor = math.floor
local mathMin = math.min
local mathMax = math.max
local tableInsert = table.insert
local tableRemove = table.remove
local assert = assert
local type = type
local tonumber = tonumber
local tostring = tostring
local tocolor = tocolor
--[[
Item List Struct:
table = {
index:	-3			-2			-1					0					1
		ItemData	textColor	BackGround Image	BackGround Color	Text
	{	dataTable,	color,		{def,hov,sel},		{def,hov,sel},		text	},
	{	dataTable,	color,		{def,hov,sel},		{def,hov,sel},		text	},
	{	dataTable,	color,		{def,hov,sel},		{def,hov,sel},		text	},
	{				...														},
}
]]

function dgsCreateComboBox(...)
	local x,y,w,h,caption,relative,parent,itemHeight,textColor,scaleX,scaleY,nImage,hImage,cImage,nColor,hColor,cColor
	if select("#",...) == 1 and type(select(1,...)) == "table" then
		local argTable = ...
		x = argTable.x or argTable[1]
		y = argTable.y or argTable[2]
		w = argTable.width or argTable.w or argTable[3]
		h = argTable.height or argTable.h or argTable[4]
		caption = argTable.caption or argTable[5]
		relative = argTable.relative or argTable.rlt or argTable[6]
		parent = argTable.parent or argTable.p or argTable[7]
		itemHeight = argTable.itemHeight or argTable[8]
		textColor = argTable.textColor or argTable[9]
		scaleX = argTable.scaleX or argTable[10]
		scaleY = argTable.scaleY or argTable[11]
		nImage = argTable.normalImage or argTable[12]
		hImage = argTable.hoveringImage or argTable[13]
		cImage = argTable.clickedImage or argTable[14]
		nColor = argTable.normalColor or argTable[15]
		hColor = argTable.hoveringColor or argTable[16]
		cColor = argTable.clickedColor or argTable[17]
	else
		x,y,w,h,caption,relative,parent,itemHeight,textColor,scaleX,scaleY,nImage,hImage,cImage,nColor,hColor,cColor = ...
	end
	if not(type(x) == "number") then error(dgsGenAsrt(x,"dgsCreateComboBox",1,"number")) end
	if not(type(y) == "number") then error(dgsGenAsrt(y,"dgsCreateComboBox",2,"number")) end
	if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsCreateComboBox",3,"number")) end
	if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsCreateComboBox",4,"number")) end
	local combobox = createElement("dgs-dxcombobox")
	dgsSetType(combobox,"dgs-dxcombobox")
	dgsSetParent(combobox,parent,true,true)
	local style = styleSettings.combobox
	local nColor = nColor or style.color[1]
	local hColor = hColor or style.color[2]
	local cColor = cColor or style.color[3]
	local nImage = nImage or dgsCreateTextureFromStyle(style.image[1])
	local hImage = hImage or dgsCreateTextureFromStyle(style.image[2])
	local cImage = cImage or dgsCreateTextureFromStyle(style.image[3])
	local inColor = style.itemColor[1]
	local ihColor = style.itemColor[2]
	local icColor = style.itemColor[3]
	local inImage = dgsCreateTextureFromStyle(style.itemImage[1])
	local ihImage = dgsCreateTextureFromStyle(style.itemImage[2])
	local icliimage = dgsCreateTextureFromStyle(style.itemImage[3])
	local textScaleX,textScaleY = tonumber(scaleX),tonumber(scaleY)
	local scbThick = style.scrollBarThick
	dgsElementData[combobox] = {
		renderBuffer = {},
		color = {nColor,hColor,cColor},
		image = {nImage,hImage,cImage},
		itemColor = {inColor,ihColor,icColor},
		itemImage = {inImage,ihImage,icliimage},
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
		itemHeight = itemHeight or style.itemHeight,
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
	dgsAttachToTranslation(combobox,resourceTranslation[sourceResource or resource])
	if type(caption) == "table" then
		dgsElementData[combobox]._translationText = caption
		dgsSetData(combobox,"caption",caption)
	else
		dgsSetData(combobox,"caption",tostring(caption))
	end
	calculateGuiPositionSize(combobox,x,y,relative or false,w,h,relative or false,true)
	local box = dgsComboBoxCreateBox(0,1,1,3,true,combobox)
	dgsElementData[combobox].myBox = box
	dgsElementData[box].myCombo = combobox
	local boxsiz = dgsElementData[box].absSize
	local renderTarget,err = dxCreateRenderTarget(boxsiz[1],boxsiz[2],true,combobox,sourceResource)
	if renderTarget ~= false then
		dgsAttachToAutoDestroy(renderTarget,combobox,-1)
	else
		outputDebugString(err,2)
	end
	dgsElementData[combobox].renderTarget = renderTarget
	local scrollbar = dgsCreateScrollBar(boxsiz[1]-scbThick,0,scbThick,boxsiz[2],false,false,box)
	dgsSetData(scrollbar,"length",{0,true})
	dgsSetData(scrollbar,"multiplier",{1,true})
	dgsSetData(scrollbar,"myCombo",combobox)
	dgsSetData(scrollbar,"minLength",10)
	dgsSetVisible(scrollbar,false)
	dgsSetVisible(box,false)
	dgsAddEventHandler("onDgsElementScroll",scrollbar,"checkComboBoxScrollBar",false)
	dgsAddEventHandler("onDgsComboBoxStateChange",combobox,"dgsComboBoxCheckState",false)
	dgsAddEventHandler("onDgsBlur",box,"closeComboBoxWhenBoxBlur",false)
	dgsAddEventHandler("onDgsBlur",scrollbar,"closeComboBoxWhenScrolBarBlur",false)
	dgsAddEventHandler("onDgsSizeChange",combobox,"updateBoxSizeWhenComboBoxResize",false)
	dgsAddEventHandler("onDgsSizeChange",box,"updateBoxContentWhenBoxResize",false)
	dgsElementData[combobox].scrollbar = scrollbar
	triggerEvent("onDgsCreate",combobox,sourceResource)
	dgsSetData(combobox,"hitoutofparent",true)
	return combobox
end

function checkComboBoxScrollBar(scb,new,old)
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

function dgsComboBoxCheckState(state)
	if not wasEventCancelled() then
		local box = dgsElementData[source].myBox
		if state then
			dgsSetVisible(box,true)
			dgsFocus(box)
		else
			dgsSetVisible(box,false)
		end
	end
end

function closeComboBoxWhenBoxBlur(nextFocused)
	local combobox = dgsElementData[source].myCombo
	local scb = dgsElementData[combobox].scrollbar
	if nextFocused ~= combobox and nextFocused ~= scb then
		dgsComboBoxSetState(combobox,false)
	end
end

function closeComboBoxWhenScrolBarBlur(nextFocused)
	local combobox = dgsElementData[source].myCombo
	local box = dgsElementData[combobox].myBox
	if nextFocused ~= combobox and nextFocused ~= box then
		dgsComboBoxSetState(combobox,false)
	end
end

function updateBoxSizeWhenComboBoxResize()
	local box = dgsElementData[source].myBox
	if not dgsElementData[box].relative[2] then
		local size = dgsElementData[source].absSize
		local bsize = dgsElementData[box].absSize
		dgsSetSize(box,size[1],bsize[2],false)
	end
end

function updateBoxContentWhenBoxResize()
	local combobox = dgsElementData[source].myCombo
	dgsSetData(combobox,"configNextFrame",true)
end

function dgsComboBoxSetCaptionText(combobox,caption)
	if not dgsIsType(combobox,"dgs-dxcombobox") then error(dgsGenAsrt(combobox,"dgsComboBoxSetCaptionText",1,"dgs-dxcombobox")) end
	return dgsSetData(combobox,"caption",caption)
end

function dgsComboBoxGetText(combobox)
	if not dgsIsType(combobox,"dgs-dxcombobox") then error(dgsGenAsrt(combobox,"dgsComboBoxGetText",1,"dgs-dxcombobox")) end
	local eleData = dgsElementData[combobox]
	local captionEdit = eleData.captionEdit
	local selection = eleData.select
	local itemData = eleData.itemData
	local text = itemData[selection] and itemData[selection][1]
	if captionEdit then
		text = text or dgsGetText(captionEdit)
	else
		text = text or eleData.caption
	end
	return text or false
end

function dgsComboBoxGetCaptionText(combobox)
	if not dgsIsType(combobox,"dgs-dxcombobox") then error(dgsGenAsrt(combobox,"dgsComboBoxGetCaptionText",1,"dgs-dxcombobox")) end
	return dgsElementData[combobox].caption
end

function dgsComboBoxSetEditEnabled(combobox,enabled)
	if not dgsIsType(combobox,"dgs-dxcombobox") then error(dgsGenAsrt(combobox,"dgsComboBoxSetEditEnabled",1,"dgs-dxcombobox")) end
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
	if not dgsIsType(combobox,"dgs-dxcombobox") then error(dgsGenAsrt(combobox,"dgsComboBoxGetEditEnabled",1,"dgs-dxcombobox")) end
	return isElement(dgsElementData[combobox].captionEdit) and true or false
end

function dgsComboBoxSetBoxHeight(combobox,height,relative)
	if not dgsIsType(combobox,"dgs-dxcombobox") then error(dgsGenAsrt(combobox,"dgsComboBoxSetBoxHeight",1,"dgs-dxcombobox")) end
	if not type(height) == "number" then error(dgsGenAsrt(height,"dgsComboBoxSetBoxHeight",2,"number")) end
	relative = relative and true or false
	local box = dgsElementData[combobox].myBox
	dgsSetData(combobox,"configNextFrame",true)
	if isElement(box) then
		local size = relative and dgsElementData[box].rltSize or dgsElementData[box].absSize
		return dgsSetSize(box,size[1],height,relative)
	end
	return false
end

function dgsComboBoxGetBoxHeight(combobox,relative)
	if not dgsIsType(combobox,"dgs-dxcombobox") then error(dgsGenAsrt(combobox,"dgsComboBoxGetBoxHeight",1,"dgs-dxcombobox")) end
	relative = relative and true or false
	local box = dgsElementData[combobox].myBox
	if isElement(box) then
		local size = relative and dgsElementData[box].rltSize or dgsElementData[box].absSize
		return size[2]
	end
	return false
end

function dgsComboBoxAddItem(combobox,text)
	if not dgsIsType(combobox,"dgs-dxcombobox") then error(dgsGenAsrt(combobox,"dgsComboBoxAddItem",1,"dgs-dxcombobox")) end
	local iData = dgsElementData[combobox].itemData
	local id = #iData+1
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

	tableInsert(iData,id,tab)
	dgsSetData(combobox,"configNextFrame",true)
	return id
end

function dgsComboBoxSetItemText(combobox,i,text)
	if not dgsIsType(combobox,"dgs-dxcombobox") then error(dgsGenAsrt(combobox,"dgsComboBoxSetItemText",1,"dgs-dxcombobox")) end
	local iData = dgsElementData[combobox].itemData
	local iLen = #iData
	local iIsNum = type(i) == "number"
	local iNInRange = iIsNum and not (i>=1 and i<=iLen)
	if not (iIsNum and not iNInRange) then error(dgsGenAsrt(i,"dgsComboBoxSetItemText",2,"number","1~"..iLen,iNInRange and "Out Of Range")) end
	local i = i-i%1
	if type(text) == "table" then
		iData[i]._translationText = text
		text = dgsTranslate(combobox,text,sourceResource)
	else
		iData[i]._translationText = nil
	end
	iData[i][1] = tostring(text)
	return true
end

function dgsComboBoxGetItemText(combobox,i)
	if not dgsIsType(combobox,"dgs-dxcombobox") then error(dgsGenAsrt(combobox,"dgsComboBoxGetItemText",1,"dgs-dxcombobox")) end
	local iData = dgsElementData[combobox].itemData
	local iLen = #iData
	local iIsNum = type(i) == "number"
	local iNInRange = iIsNum and not (i>=1 and i<=iLen)
	if not (iIsNum and not iNInRange) then error(dgsGenAsrt(i,"dgsComboBoxGetItemText",2,"number","1~"..iLen,iNInRange and "Out Of Range")) end
	local i = i-i%1
	return iData[i][1]
end

function dgsComboBoxSetItemData(combobox,i,data,...)
	if not dgsIsType(combobox,"dgs-dxcombobox") then error(dgsGenAsrt(combobox,"dgsComboBoxSetItemData",1,"dgs-dxcombobox")) end
	local iData = dgsElementData[combobox].itemData
	local iLen = #iData
	local iIsNum = type(i) == "number"
	local iNInRange = iIsNum and not (i>=1 and i<=iLen)
	if not (iIsNum and not iNInRange) then error(dgsGenAsrt(i,"dgsComboBoxSetItemData",2,"number","1~"..iLen,iNInRange and "Out Of Range")) end
	local i = i-i%1
	if select("#",...) == 0 then
		iData[i][-1] = data
		return true
	else
		iData[i][-2] = iData[i][-2] or {}
		iData[i][-2][data] = ...
		return true
	end
	return false
end

function dgsComboBoxGetItemData(combobox,i,key)
	if not dgsIsType(combobox,"dgs-dxcombobox") then error(dgsGenAsrt(combobox,"dgsComboBoxGetItemData",1,"dgs-dxcombobox")) end
	local iData = dgsElementData[combobox].itemData
	local iLen = #iData
	local iIsNum = type(i) == "number"
	local iNInRange = iIsNum and not (i>=1 and i<=iLen)
	if not (iIsNum and not iNInRange) then error(dgsGenAsrt(i,"dgsComboBoxGetItemData",2,"number","1~"..iLen,iNInRange and "Out Of Range")) end
	local i = i-i%1
	if not key then
		return itemData[i][-1]
	else
		return (itemData[i][-2] or {})[key] or false
	end
	return false
end

function dgsComboBoxGetItemCount(combobox)
	if not dgsIsType(combobox,"dgs-dxcombobox") then error(dgsGenAsrt(combobox,"dgsComboBoxGetItemCount",1,"dgs-dxcombobox")) end
	return #dgsElementData[combobox].itemData
end

function dgsComboBoxSetItemColor(combobox,i,color)
	if not dgsIsType(combobox,"dgs-dxcombobox") then error(dgsGenAsrt(combobox,"dgsComboBoxSetItemColor",1,"dgs-dxcombobox")) end
	local iData = dgsElementData[combobox].itemData
	local iLen = #iData
	local iIsNum = type(i) == "number"
	local iNInRange = iIsNum and not (i>=1 and i<=iLen)
	if not (iIsNum and not iNInRange) then error(dgsGenAsrt(i,"dgsComboBoxSetItemColor",2,"number","1~"..iLen,iNInRange and "Out Of Range")) end
	local i = i-i%1
	iData[i][-2] = color
	return true
end

function dgsComboBoxGetItemColor(combobox,i)
	if not dgsIsType(combobox,"dgs-dxcombobox") then error(dgsGenAsrt(combobox,"dgsComboBoxGetItemColor",1,"dgs-dxcombobox")) end
	local iData = dgsElementData[combobox].itemData
	local iLen = #iData
	local iIsNum = type(i) == "number"
	local iNInRange = iIsNum and not (i>=1 and i<=iLen)
	if not (iIsNum and not iNInRange) then error(dgsGenAsrt(i,"dgsComboBoxGetItemColor",2,"number","1~"..iLen,iNInRange and "Out Of Range")) end
	local i = i-i%1
	return iData[i][-2]
end

function dgsComboBoxSetItemFont(combobox,i,font)
	if not dgsIsType(combobox,"dgs-dxcombobox") then error(dgsGenAsrt(combobox,"dgsComboBoxSetItemFont",1,"dgs-dxcombobox")) end
	local iData = dgsElementData[combobox].itemData
	local iLen = #iData
	local iIsNum = type(i) == "number"
	local iNInRange = iIsNum and not (i>=1 and i<=iLen)
	if not (iIsNum and not iNInRange) then error(dgsGenAsrt(i,"dgsComboBoxSetItemFont",2,"number","1~"..iLen,iNInRange and "Out Of Range")) end
	local i = i-i%1
	iData[i][-4] = font
	return true
end

function dgsComboBoxGetItemFont(combobox,i)
	if not dgsIsType(combobox,"dgs-dxcombobox") then error(dgsGenAsrt(combobox,"dgsComboBoxGetItemFont",1,"dgs-dxcombobox")) end
	local iData = dgsElementData[combobox].itemData
	local iLen = #iData
	local iIsNum = type(i) == "number"
	local iNInRange = iIsNum and not (i>=1 and i<=iLen)
	if not (iIsNum and not iNInRange) then error(dgsGenAsrt(i,"dgsComboBoxGetItemFont",2,"number","1~"..iLen,iNInRange and "Out Of Range")) end
	local i = i-i%1
	return iData[i][-4]
end

function dgsComboBoxSetItemImage(combobox,i,image,color,offx,offy,w,h,relative)
	if not dgsIsType(combobox,"dgs-dxcombobox") then error(dgsGenAsrt(combobox,"dgsComboBoxSetItemImage",1,"dgs-dxcombobox")) end
	local iData = dgsElementData[combobox].itemData
	local iLen = #iData
	local iIsNum = type(i) == "number"
	local iNInRange = iIsNum and not (i>=1 and i<=iLen)
	if not (iIsNum and not iNInRange) then error(dgsGenAsrt(i,"dgsComboBoxSetItemImage",2,"number","1~"..iLen,iNInRange and "Out Of Range")) end
	local i = i-i%1
	local imageData = iData[i][-6] or {}
	imageData[1] = image or imageData[1]
	imageData[2] = color or imageData[2] or white
	imageData[3] = offx or imageData[3] or 0
	imageData[4] = offy or imageData[4] or 0
	imageData[5] = w or imageData[5] or relative and 1 or dgsGetSize(combobox)
	imageData[6] = h or imageData[6] or relative and 1 or dgsElementData[combobox].itemHeight
	imageData[7] = relative or false
	iData[i][-6] = imageData
	return true
end

function dgsComboBoxGetItemImage(combobox,i)
	if not dgsIsType(combobox,"dgs-dxcombobox") then error(dgsGenAsrt(combobox,"dgsComboBoxGetItemImage",1,"dgs-dxcombobox")) end
	local iData = dgsElementData[combobox].itemData
	local iLen = #iData
	local iIsNum = type(i) == "number"
	local iNInRange = iIsNum and not (i>=1 and i<=iLen)
	if not (iIsNum and not iNInRange) then error(dgsGenAsrt(i,"dgsComboBoxGetItemImage",2,"number","1~"..iLen,iNInRange and "Out Of Range")) end
	local i = i-i%1
	return unpack(iData[i][-6] or {})
end

function dgsComboBoxRemoveItemImage(combobox,i)
	if not dgsIsType(combobox,"dgs-dxcombobox") then error(dgsGenAsrt(combobox,"dgsComboBoxRemoveItemImage",1,"dgs-dxcombobox")) end
	local iData = dgsElementData[combobox].itemData
	local iLen = #iData
	local iIsNum = type(i) == "number"
	local iNInRange = iIsNum and not (i>=1 and i<=iLen)
	if not (iIsNum and not iNInRange) then error(dgsGenAsrt(i,"dgsComboBoxRemoveItemImage",2,"number","1~"..iLen,iNInRange and "Out Of Range")) end
	local i = i-i%1
	iData[i][-6] = nil
	return true
end

function dgsComboBoxSetState(combobox,state)
	if not dgsIsType(combobox,"dgs-dxcombobox") then error(dgsGenAsrt(combobox,"dgsComboBoxSetState",1,"dgs-dxcombobox")) end
	return dgsSetData(combobox,"listState",state and 1 or -1)
end

function dgsComboBoxGetState(combobox)
	if not dgsIsType(combobox,"dgs-dxcombobox") then error(dgsGenAsrt(combobox,"dgsComboBoxGetState",1,"dgs-dxcombobox")) end
	return dgsElementData[combobox].listState == 1 and true or false
end

function dgsComboBoxRemoveItem(combobox,i)
	if not dgsIsType(combobox,"dgs-dxcombobox") then error(dgsGenAsrt(combobox,"dgsComboBoxRemoveItem",1,"dgs-dxcombobox")) end
	local iData = dgsElementData[combobox].itemData
	local iLen = #iData
	local iIsNum = type(i) == "number"
	local iNInRange = iIsNum and not (i>=1 and i<=iLen)
	if not (iIsNum and not iNInRange) then error(dgsGenAsrt(i,"dgsComboBoxRemoveItem",2,"number","1~"..iLen,iNInRange and "Out Of Range")) end
	local i = i-i%1
	tableRemove(iData,i)
	dgsElementData[combobox].configNextFrame = true
	return true
end

function dgsComboBoxClear(combobox)
	if not dgsIsType(combobox,"dgs-dxcombobox") then error(dgsGenAsrt(combobox,"dgsComboBoxClear",1,"dgs-dxcombobox")) end
	dgsElementData[combobox].itemData = {}
	dgsSetData(combobox,"configNextFrame",true)
	return true
end

function dgsComboBoxCreateBox(x,y,w,h,relative,parent)
	if not(type(x) == "number") then error(dgsGenAsrt(x,"dgsComboBoxCreateBox",1,"number")) end
	if not(type(y) == "number") then error(dgsGenAsrt(y,"dgsComboBoxCreateBox",2,"number")) end
	if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsComboBoxCreateBox",3,"number")) end
	if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsComboBoxCreateBox",4,"number")) end
	if not(dgsGetType(parent) == "dgs-dxcombobox") then error(dgsGenAsrt(parent,"dgsComboBoxCreateBox",6,"dgs-dxcombobox")) end
	local box = createElement("dgs-dxcombobox-Box")
	dgsSetType(box,"dgs-dxcombobox-Box")
	dgsSetParent(box,parent,true,true)
	insertResource(sourceResource,box)
	calculateGuiPositionSize(box,x,y,relative or false,w,h,relative or false,true)
	triggerEvent("onDgsCreate",box)
	return box
end

function dgsComboBoxSetSelectedItem(combobox,i)
	if not dgsIsType(combobox,"dgs-dxcombobox") then error(dgsGenAsrt(combobox,"dgsComboBoxSetSelectedItem",1,"dgs-dxcombobox")) end
	local iData = dgsElementData[combobox].itemData
	local iLen = #iData
	local iIsNum = type(i) == "number"
	local iNInRange = iIsNum and not (i>=1 and i<=iLen or i == -1)
	if not (iIsNum and not iNInRange) then error(dgsGenAsrt(i,"dgsComboBoxSetSelectedItem",2,"number","-1,1~"..iLen,iNInRange and "Out Of Range")) end
	local i = i-i%1
	local old = dgsElementData[combobox].select
	dgsSetData(combobox,"select",i)
	triggerEvent("onDgsComboBoxSelect",combobox,i,old)
	return true
end

function dgsComboBoxGetSelectedItem(combobox)
	if not dgsIsType(combobox,"dgs-dxcombobox") then error(dgsGenAsrt(combobox,"dgsComboBoxGetSelectedItem",1,"dgs-dxcombobox")) end
	local itemData = dgsElementData[combobox].itemData
	local selected = dgsElementData[combobox].select
	if selected < 1 and selected > #itemData then
		return -1
	else
		return selected
	end
end

function configComboBox(combobox,remainBox)
	local eleData = dgsElementData[combobox]
	local box = eleData.myBox
	local size = dgsElementData[box].absSize
	local iData = eleData.itemData
	local iLen = #iData
	local scrollbar = eleData.scrollbar
	local itemHeight = eleData.itemHeight
	local allHeight = iLen*itemHeight
	dgsSetVisible(scrollbar,allHeight > size[2])
	local res = eleData.resource
	if not remainBox then
		local boxsiz = dgsElementData[box].absSize
		local renderTarget = eleData.renderTarget
		if isElement(renderTarget) then destroyElement(renderTarget) end
		local sbt = eleData.scrollBarThick
		local renderTarget,err = dxCreateRenderTarget(boxsiz[1],boxsiz[2],true,combobox,res)
		if renderTarget ~= false then
			dgsAttachToAutoDestroy(renderTarget,combobox,-1)
		else
			outputDebugString(err,2)
		end
		dgsSetData(combobox,"renderTarget",renderTarget)
		dgsSetPosition(scrollbar,boxsiz[1]-sbt,0,false)
		dgsSetSize(scrollbar,sbt,boxsiz[2],false)
		local higLen = 1-(allHeight-boxsiz[2])/allHeight
		higLen = higLen >= 0.95 and 0.95 or higLen
		dgsSetData(scrollbar,"length",{higLen,true})
		local verticalScrollSize = eleData.scrollSize/(allHeight-boxsiz[2])
		dgsSetData(scrollbar,"multiplier",{verticalScrollSize,true})
		dgsSetData(combobox,"configNextFrame",false)
	end
	---------------Caption edit
	local edit = eleData.captionEdit
	if edit then
		local size = eleData.absSize
		local w,h = size[1],size[2]
		local buttonLen_t = eleData.buttonLen
		local buttonLen = 0
		if eleData.textBox then
			buttonLen = w - (buttonLen_t[2] and buttonLen_t[1]*h or buttonLen_t[1])
		end
		dgsSetSize(edit,buttonLen,h,false)
		dgsSetVisible(edit,eleData.textBox)
	end
end


function dgsComboBoxSetScrollPosition(combobox,vertical)
	if not dgsIsType(combobox,"dgs-dxcombobox") then error(dgsGenAsrt(combobox,"dgsComboBoxSetScrollPosition",1,"dgs-dxcombobox")) end
	if vertical and not (type(vertical) == "number" and vertical>= 0 and vertical <= 100) then error(dgsGenAsrt(vertical,"dgsComboBoxSetScrollPosition",2,"nil/number","0~100")) end
	local scb = dgsElementData[combobox].scrollbar
	if dgsElementData[scb].visible then
		return dgsScrollBarSetScrollPosition(scb,vertical)
	end
	return true
end

function dgsComboBoxGetScrollPosition(combobox)
	if not dgsIsType(combobox,"dgs-dxcombobox") then error(dgsGenAsrt(combobox,"dgsComboBoxGetScrollPosition",1,"dgs-dxcombobox")) end
	local scb = dgsElementData[combobox].scrollbar
	return dgsScrollBarGetScrollPosition(scb)
end

function dgsComboBoxSetViewCount(combobox,count)
	if not dgsIsType(combobox,"dgs-dxcombobox") then error(dgsGenAsrt(combobox,"dgsComboBoxSetViewCount",1,"dgs-dxcombobox")) end
	if not (count == nil or type(count) == "number") then error(dgsGenAsrt(count,"dgsComboBoxSetViewCount",2,"nil/number")) end
	if type(count) == "number" then
		dgsSetData(combobox,"viewCount",count)
		return dgsComboBoxSetBoxHeight(combobox,count*dgsElementData[combobox].itemHeight)
	else
		return dgsSetData (combobox,"viewCount",false,true)
	end
end

function dgsComboBoxGetViewCount(combobox,count)
	if not dgsIsType(combobox,"dgs-dxcombobox") then error(dgsGenAsrt(combobox,"dgsComboBoxGetViewCount",1,"dgs-dxcombobox")) end
	return dgsElementData[combobox].viewCount
end

----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxcombobox"] = function(source,x,y,w,h,mx,my,cx,cy,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt)
	if eleData.configNextFrame then
		configComboBox(source)
	end
	local captionEdit = eleData.captionEdit
	local colors,imgs = eleData.color,eleData.image
	local selectState = 1
	local textBox = eleData.textBox
	local buttonLen = textBox and (eleData.buttonLen[2] and eleData.buttonLen[1]*h or eleData.buttonLen[1]) or w
	if MouseData.entered == source then
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
	if not enabledInherited and not enabledSelf then
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
	return rndtgt,false,mx,my,0,0
end

dgsRenderer["dgs-dxcombobox-Box"] = function(source,x,y,w,h,mx,my,cx,cy,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt,xRT,yRT,xNRT,yNRT,OffsetX,OffsetY,visible)
	if MouseData.hit == source and MouseData.focused == source then
		MouseData.topScrollable = source
	end
	local combo = eleData.myCombo
	local DataTab = dgsElementData[combo]
	local itemData = DataTab.itemData
	local itemDataCount = #itemData
	local scbThick = dgsElementData[combo].scrollBarThick
	local itemHeight = DataTab.itemHeight
	--Smooth Item
	local _itemMoveOffset = DataTab.itemMoveOffset
	local scrollbar = dgsElementData[combo].scrollbar
	local itemMoveHardness = dgsElementData[scrollbar].moveType == "slow" and DataTab.moveHardness[1] or DataTab.moveHardness[2]
	DataTab.itemMoveOffsetTemp = mathLerp(itemMoveHardness,DataTab.itemMoveOffsetTemp,_itemMoveOffset)
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
		if mx >= cx and mx <= cx+w-scbcheck and my >= cy and my <= cy+h and MouseData.entered == source then
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
	return rndtgt,false,mx,my,0,0
end
