dgsLogLuaMemory()
dgsRegisterType("dgs-dxmemo","dgsBasic","dgsType2D")
dgsRegisterProperties("dgs-dxmemo",{
	allowCopy = 					{	PArg.Bool	},
	bgColor =  						{	PArg.Color	},
	bgColorBlur = 					{	PArg.Color	},
	bgImage =  						{	PArg.Material+PArg.Nil	},
	bgImageBlur =  					{	PArg.Material+PArg.Nil	},
	caretColor = 					{	PArg.Color	},
	caretHeight = 					{	PArg.Number	},
	caretOffset = 					{	PArg.Number	},
	caretPos = 						{	{ PArg.Number, PArg.Number }	},
	caretStyle = 					{	PArg.Number	},
	caretThick = 					{	PArg.Number	},
	font =	 						{	PArg.Font+PArg.String	},
	maxLength = 					{	PArg.Number	},
	padding = 						{	{ PArg.Number, PArg.Number }	},
	placeHolder = 					{	PArg.String	},
	placeHolderColor = 				{	PArg.Color	},
	placeHolderColorCoded = 		{	PArg.Bool	},
	placeHolderFont = 				{	PArg.Font	},
	placeHolderIgnoreRenderTarget = {	PArg.Bool	},
	placeHolderOffset = 			{	{ PArg.Number, PArg.Number }	},
	placeHolderVisibleWhenFocus = 	{	PArg.Bool	},
	readOnly = 						{	PArg.Bool	},
	readOnlyCaretShow =				{	PArg.Bool	},
	scrollBarState = 				{	{ PArg.Bool+PArg.Nil, PArg.Bool+PArg.Nil }	},
	scrollBarThick = 				{	PArg.Number	},
	scrollBarLength = 				{	{ { PArg.Number, PArg.Bool }, { PArg.Number, PArg.Bool } }, { PArg.Nil, PArg.Nil }	},
	scrollSize = 					{	PArg.Number	},
	selectColor = 					{	PArg.Color	},
	selectColorBlur = 				{	PArg.Color	},
	selectVisible = 				{	PArg.Bool	},
	shadow = 						{	{ PArg.Number, PArg.Number, PArg.Color, PArg.Number+PArg.Bool+PArg.Nil, PArg.Font+PArg.Nil }, PArg.Nil	},
	--text = 							{	PArg.String	},
	textColor = 					{	PArg.Color	},
	textSize = 						{	{ PArg.Number, PArg.Number }	},
	typingSound = 					{	PArg.String	},
	typingSoundVolume = 			{	PArg.Number	},
	wordWrap = 						{	PArg.Bool+PArg.Number	},
})
--Dx Functions
local dxDrawLine = dxDrawLine
local dxDrawImage = dxDrawImage
local dgsDrawText = dgsDrawText
local dxGetFontHeight = dxGetFontHeight
local dxDrawRectangle = dxDrawRectangle
local dxSetShaderValue = dxSetShaderValue
local dxGetPixelsSize = dxGetPixelsSize
local dxGetPixelColor = dxGetPixelColor
local dxSetRenderTarget = dxSetRenderTarget
local dgsCreateRenderTarget = dgsCreateRenderTarget
local dxGetTextWidth = dxGetTextWidth
local dxSetBlendMode = dxSetBlendMode
local __dxDrawImageSection = __dxDrawImageSection
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
local dgsTriggerEvent = dgsTriggerEvent
local addEventHandler = addEventHandler
local createElement = createElement
local isElement = isElement
local assert = assert
local tonumber = tonumber
local tostring = tostring
local type = type
local tocolor = tocolor
local tableSort = table.sort
local tableInsert = table.insert
local tableRemove = table.remove
local mathFloor = math.floor
local mathClamp = math.clamp
local utf8Sub = utf8.sub
local utf8Gsub = utf8.gsub
local utf8Len = utf8.len
local utf8Insert = utf8.insert
local utf8Byte = utf8.byte
GlobalMemoParent = guiCreateLabel(-1,0,0,0,"",true)
GlobalMemo = guiCreateMemo(-1,0,0,0,"",true,GlobalMemoParent)
addEventHandler("onClientGUIBlur",GlobalMemo,GlobalEditMemoBlurCheck,false)
dgsSetData(GlobalMemo,"linkedDxMemo",nil)
--[[
---------------In Normal Mode------------------
Text Table Structure:
	text width no color code,			text no color code,				Text Width(Int),	Original Text(Str),	TextBlock1,						TextBlock2,...
{
	{[-3] = textWidthWithoutColorCode,	[-2] = textWithoutColorCode,	[-1] = text Width,	[0] = text,			{textBlock1,color,styleType},	{textBlock2,color,styleType},	...	},
	{[-3] = textWidthWithoutColorCode,	[-2] = textWithoutColorCode,	[-1] = text Width,	[0] = text,			{textBlock1,color,styleType},	{textBlock2,color,styleType},	...	},
	...
}
--------------In Word Wrap Mode----------------
Text Table Structure:
	Text Width(Int),	Text(Str),	Map Tables For Weak Line(Table),
{
	{[-1] = text Width,	[0] = text,	[1] = { table1, table2, table3, ... }},	--Strong Line 1
	{[-1] = text Width,	[0] = text,	[1] = { table1, table2, table3, ... }},	--Strong Line 2
	...
}

Map Table Structure:
	Text Of Weak Line(Str),	Row In Text Table(Table),	Weak Line Index In Text Table(Int),	Length Of Text(Int),
{
	{[0] = SplitedText,		[1] = LineInTextTable,		[2] = WeakIndex,					[3] = utf8Len(SplitedText)},
	{[0] = SplitedText,		[1] = LineInTextTable,		[2] = WeakIndex,					[3] = utf8Len(SplitedText)},
	{[0] = SplitedText,		[1] = LineInTextTable,		[2] = WeakIndex,					[3] = utf8Len(SplitedText)},
	...
}
]]
function dgsCreateMemo(...)
	local sRes = sourceResource or resource
	local x,y,w,h,text,relative,parent,textColor,scaleX,scaleY,bgImage,bgColor
	if select("#",...) == 1 and type(select(1,...)) == "table" then
		local argTable = ...
		x = argTable.x or argTable[1]
		y = argTable.y or argTable[2]
		w = argTable.width or argTable.w or argTable[3]
		h = argTable.height or argTable.h or argTable[4]
		text = argTable.text or argTable.txt or argTable[5]
		relative = argTable.relative or argTable.rlt or argTable[6]
		parent = argTable.parent or argTable.p or argTable[7]
		textColor = argTable.textColor or argTable[8]
		scaleX = argTable.scaleX or argTable[9]
		scaleY = argTable.scaleY or argTable[10]
		bgImage = argTable.bgImage or argTable[11]
		bgColor = argTable.bgColor or argTable[12]
	else
		x,y,w,h,text,relative,parent,textColor,scaleX,scaleY,bgImage,bgColor = ...
	end
	if not(type(x) == "number") then error(dgsGenAsrt(x,"dgsCreateMemo",1,"number")) end
	if not(type(y) == "number") then error(dgsGenAsrt(y,"dgsCreateMemo",2,"number")) end
	if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsCreateMemo",3,"number")) end
	if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsCreateMemo",4,"number")) end
	text = tostring(text or "")
	local memo = createElement("dgs-dxmemo")
	dgsSetType(memo,"dgs-dxmemo")
	
	local res = sRes ~= resource and sRes or "global"
	local style = styleManager.styles[res]
	local using = style.using
	style = style.loaded[using]
	local systemFont = style.systemFontElement
	
	style = style.memo
	local textSizeX,textSizeY = tonumber(scaleX) or style.textSize[1], tonumber(scaleY) or style.textSize[2]
	dgsElementData[memo] = {
		renderBuffer = {
			placeHolderState = false,
			parentAlphaLast = false,
			isFocused = false,
		},
		bgColor = bgColor or style.bgColor,
		bgImage = bgImage or dgsCreateTextureFromStyle(using,res,style.bgImage),
		bgColorBlur = style.bgColorBlur,
		bgImageBlur = bgImageBlur,
		font = style.font or systemFont,
		text = {},
		wordWrap = false,
		wordWrapShowLine = {1,1,1},
		wordWrapMapText = {},
		textColor = textColor or style.textColor,
		textSize = {textSizeX,textSizeY},
		caretPos = {0,1},
		selectForm = {0,1},
		--insertMode = false,
		rightLength = {0,1},
		scrollSize = 3,
		showPos = 0,
		showLine = 1,
		caretStyle = style.caretStyle,
		caretThick = style.caretThick,
		caretOffset = style.caretOffset,
		caretColor = style.caretColor,
		caretHeight = style.caretHeight,
		scrollBarThick = style.scrollBarThick,
		allowCopy = true,
		readOnly = false,
		readOnlyCaretShow = false,
		scrollBarState = {nil,nil},
		historyMaxRecords = 100,
		enableRedoUndoRecord = true,
		undoHistory = {},
		redoHistory = {},
		padding = style.padding,
		placeHolder = style.placeHolder,
		placeHolderFont = systemFont,
		placeHolderVisibleWhenFocus = false,
		placeHolderColor = style.placeHolderColor,
		placeHolderColorCoded = style.placeHolderColorCoded,
		placeHolderOffset = style.placeHolderOffset,
		placeHolderTextSize = style.placeHolderTextSize,
		placeHolderIgnoreRenderTarget = style.placeHolderIgnoreRenderTarget,
		typingSound = style.typingSound,
		typingSoundVolume = style.typingSoundVolume,
		selectColor = style.selectColor,
		selectColorBlur = style.selectColorBlur,
		selectVisible = style.selectVisible,
		configNextFrame = nil,
		rebuildMapTableNextFrame = nil,
		maxLength = 0x3FFFFFFF,
		scrollBarLength = {},
		multiClickCounter = {false,false,0},
		colorCoded = true,
		textRenderBuffer = {},
		updateRTNextFrame = nil,
	}
	dgsSetParent(memo,parent,true,true)
	calculateGuiPositionSize(memo,x,y,relative or false,w,h,relative or false,true)
	local abx,aby = dgsElementData[memo].absSize[1],dgsElementData[memo].absSize[2]
	local scrollbar1 = dgsCreateScrollBar(abx-20,0,20,aby-20,false,false,memo)
	local scrollbar2 = dgsCreateScrollBar(0,aby-20,abx-20,20,true,false,memo)
	dgsSetVisible(scrollbar1,false)
	dgsSetData(scrollbar1,"length",{0,true})
	dgsSetData(scrollbar2,"length",{0,true})
	dgsSetData(scrollbar1,"multiplier",{1,true})
	dgsSetData(scrollbar2,"multiplier",{1,true})
	dgsSetData(scrollbar1,"minLength",10)
	dgsSetData(scrollbar2,"minLength",10)
	dgsAddEventHandler("onDgsElementScroll",scrollbar1,"checkMemoScrollBar",false)
	dgsAddEventHandler("onDgsElementScroll",scrollbar2,"checkMemoScrollBar",false)
	dgsElementData[memo].scrollbars = {scrollbar1,scrollbar2}
	handleDxMemoText(memo,text,false,true)
	dgsAddEventHandler("onDgsMouseMultiClick",memo,"dgsMemoMultiClickCheck",false)
	onDGSElementCreate(memo,sRes)
	dgsMemoRecreateRenderTarget(memo,true)
	return memo
end

function dgsMemoRecreateRenderTarget(memo,lateAlloc)
	local eleData = dgsElementData[memo]
	if isElement(eleData.bgRT) then destroyElement(eleData.bgRT) end
	if lateAlloc then
		dgsSetData(memo,"retrieveRT",true)
	else
		local padding = eleData.padding
		local sizex,sizey = eleData.absSize[1]-padding[1]*2,eleData.absSize[2]-padding[2]*2
		sizex,sizey = sizex-sizex%1,sizey-sizey%1
		local scbThick = eleData.scrollBarThick
		local scrollbar = eleData.scrollbars
		local scbThickV,scbThickH = dgsElementData[scrollbar[1]].visible and scbThick or 0,dgsElementData[scrollbar[2]].visible and scbThick or 0
		local bgRT,err = dgsCreateRenderTarget(sizex-scbThickV,sizey-scbThickH,true,memo)
		if bgRT ~= false then
			dgsAttachToAutoDestroy(bgRT,memo,-1)
		else
			outputDebugString(err,2)
		end
		dgsSetData(memo,"bgRT",bgRT)
		dgsSetData(memo,"retrieveRT",nil)
	end
end

function dgsMemoMultiClickCheck(button,state,x,y,times)
	if state == "down" then
		local pos,line,side = searchMemoMousePosition(source,x,y)
		eleData = dgsElementData[source]
		if button == "left" then
			if not eleData.multiClickCounter[1] then
				eleData.multiClickCounter = {pos,line,times-1}
			elseif eleData.multiClickCounter[1] ~= pos or eleData.multiClickCounter[2] ~= line then
				eleData.multiClickCounter = {pos,line,times-1}
			end
		end
		local t = times-eleData.multiClickCounter[3]
		if t == 1 then
			if button ~= "middle" then
				local shift = getKeyState("lshift") or getKeyState("rshift")
				dgsMemoSetCaretPosition(source,pos,line,shift)
			end
		elseif t == 2 then
			if button == "left" then
				local textTable = dgsElementData[source].text
				local text = textTable[line][0]
				local s,e = dgsSearchFullWordType(text,pos,side)
				dgsMemoSetCaretPosition(source,s,line)
				dgsMemoSetCaretPosition(source,e,line,true)
			end
		elseif t == 3 then
			if button == "left" then
				dgsMemoSetCaretPosition(source,_,line)
				dgsMemoMoveCaret(source,1,0)
				dgsMemoSetCaretPosition(source,0,line,true)
			end
		end
	end
end

function dgsMemoGetLineCount(memo,strongLineOnly)
	if dgsGetType(memo) ~= "dgs-dxmemo" then error(dgsGenAsrt(memo,"dgsMemoGetLineCount",1,"dgs-dxmemo")) end
	if not strongLineOnly and dgsElementData[memo].wordWrap then
		if dgsElementData[memo].rebuildMapTableNextFrame then dgsMemoRebuildWordWrapMapTable(memo) end
		return #dgsElementData[memo].wordWrapMapText
	end
	return #dgsElementData[memo].text
end

function dgsMemoGetTextBoundingBox(memo,excludePadding)
	if dgsGetType(memo) ~= "dgs-dxmemo" then error(dgsGenAsrt(memo,"dgsMemoGetTextBoundingBox",1,"dgs-dxmemo")) end
	local eleData = dgsElementData[memo]
	
	local res = eleData.resource or "global"
	local style = styleManager.styles[res]
	local using = style.using
	style = style.loaded[using]
	local systemFont = style.systemFontElement
			
	local fontHeight = dxGetFontHeight(eleData.textSize[2],eleData.font or systemFont)
	if eleData.wordWrap then
		if eleData.rebuildMapTableNextFrame then dgsMemoRebuildWordWrapMapTable(memo) end
		local textTable = eleData.wordWrapMapText
		if excludePadding then
			return eleData.absSize[1],#textTable*fontHeight
		else
			local padding = eleData.padding
			return eleData.absSize[1]+padding[1]*2,#textTable*fontHeight+padding[2]*2
		end
	else
		local textTable = eleData.text
		if excludePadding then
			return eleData.rightLength[1],#textTable*fontHeight
		else
			local padding = eleData.padding
			return eleData.rightLength[1]+padding[1]*2,#textTable*fontHeight+padding[2]*2
		end
	end
end

function dgsMemoGetScrollBar(memo)
	if dgsGetType(memo) ~= "dgs-dxmemo" then error(dgsGenAsrt(memo,"dgsMemoGetScrollBar",1,"dgs-dxmemo")) end
	return dgsElementData[memo].scrollbars
end

function dgsMemoMoveCaret(memo,indexOffset,lineOffset,noselect,noMoveLine)
	if dgsGetType(memo) ~= "dgs-dxmemo" then error(dgsGenAsrt(memo,"dgsMemoMoveCaret",1,"dgs-dxmemo")) end
	if not(type(indexOffset) == "number") then error(dgsGenAsrt(indexOffset,"dgsMemoMoveCaret",2,"number")) end
	lineOffset = lineOffset or 0
	local eleData = dgsElementData[memo]
	local index = eleData.caretPos[1]
	local line = eleData.caretPos[2]
	local font = eleData.font
	local size = eleData.absSize
	local padding = eleData.padding
	local fontHeight = dxGetFontHeight(eleData.textSize[2],font)
	local scbThick = eleData.scrollBarThick
	local scrollbars = eleData.scrollbars
	local scbTakes = {dgsElementData[scrollbars[1]].visible and scbThick or 0,dgsElementData[scrollbars[2]].visible and scbThick or 0}
	local canHold = mathFloor((size[2]-scbTakes[2]-padding[2]*2)/fontHeight)
	local textTable = eleData.text
	local isWordWrap = eleData.wordWrap
	if isWordWrap then
		local wordWrapShowLine = eleData.wordWrapShowLine
		local mapTable = eleData.wordWrapMapText
		local weakIndex,weakLine = dgsMemoTransformStrongLineToWeakLine(textTable,mapTable,index,line,indexOffset > 0)
		local newWeakIndex,newWeakLine = dgsMemoSeekPosition(mapTable,weakIndex+indexOffset,weakLine+lineOffset,noMoveLine)
		local newIndex,newLine = dgsMemoTransfromWeakLineToStrongLine(textTable,mapTable,newWeakIndex,newWeakLine)
		local targetLine = newWeakLine-wordWrapShowLine[3]
		if targetLine >= canHold then
			local theWeakLineIndex = newWeakLine-canHold+1
			dgsSetData(memo,"wordWrapShowLine",{newLine,mapTable[theWeakLineIndex][2],theWeakLineIndex})
			syncScrollBars(memo,1)
		elseif targetLine < 1 then
			dgsSetData(memo,"wordWrapShowLine",{newLine,mapTable[newWeakLine][2],newWeakLine})
			syncScrollBars(memo,1)
		end
		dgsSetData(memo,"caretPos",{newIndex,newLine})
		local isReadOnlyShow = true
		if eleData.readOnly then
			isReadOnlyShow = eleData.readOnlyCaretShow
		end
		if not noselect or not isReadOnlyShow then
			dgsSetData(memo,"selectFrom",{newIndex,newLine})
		end
	else
		local text = (textTable[line] or {[0]=""})[0]
		local pos,line = dgsMemoSeekPosition(textTable,index+mathFloor(indexOffset),line+mathFloor(lineOffset),noMoveLine)
		local showLine = eleData.showLine
		local targetLine = line-showLine
		local showPos = eleData.showPos
		local nowLen = dxGetTextWidth(utf8Sub(text,0,pos),eleData.textSize[1],font)
		local targetLen = nowLen-showPos
		if targetLen > size[1]-padding[1]*2-scbTakes[1] then
			dgsSetData(memo,"showPos",-(size[1]-padding[1]*2-scbTakes[1]-nowLen))
			syncScrollBars(memo,2)
		elseif targetLen < 0 then
			dgsSetData(memo,"showPos",nowLen)
			syncScrollBars(memo,2)
		end
		if targetLine >= canHold then
			dgsSetData(memo,"showLine",line-canHold+1)
			syncScrollBars(memo,1)
		elseif targetLine < 1 then
			dgsSetData(memo,"showLine",line)
			syncScrollBars(memo,1)
		end
		dgsSetData(memo,"caretPos",{pos,line})
		local isReadOnlyShow = true
		if eleData.readOnly then
			isReadOnlyShow = eleData.readOnlyCaretShow
		end
		if not noselect or not isReadOnlyShow then
			dgsSetData(memo,"selectFrom",{pos,line})
		end
	end
	resetTimer(MouseData.EditMemoTimer)
	MouseData.EditMemoCursor = true
	return true
end

function dgsMemoSeekPosition(textTable,pos,line,noMoveLine)
	local line = (line < 1 and 1) or (line > #textTable and #textTable) or line
	local text = (textTable[line] or {[0]=""})[0]
	local strCount = utf8Len(text)
	if not noMoveLine then
		while true do
			if pos < 0 then
				if line-1 >= 1 then
					line = line-1
					text = (textTable[line] or {[0]=""})[0]
					strCount = utf8Len(text)
					pos = strCount+pos+1
					if pos >= 0 then break end
				else
					pos = 0
					break
				end
			elseif pos > strCount then
				if line+1 <= #textTable then
					pos = pos-strCount-1
					line = line+1
					text = (textTable[line] or {[0]=""})[0]
					strCount = utf8Len(text)
					if pos <= strCount then break end
				else
					pos = strCount
					break
				end
			else
				break
			end
		end
		return pos,line
	else
		return pos >= strCount and strCount or pos,line
	end
end

function dgsMemoSetCaretPosition(memo,tpos,tline,doSelect,noSeekPosition)
	if dgsGetType(memo) ~= "dgs-dxmemo" then error(dgsGenAsrt(memo,"dgsMemoSetCaretPosition",1,"dgs-dxmemo")) end
	local eleData = dgsElementData[memo]
	local textTable = eleData.text
	local curpos = eleData.caretPos
	tline = tline or curpos[2]
	local text = (textTable[tline] or {[-1]=0,[0]=""})[0]
	if tpos == nil then
		tpos = utf8Len(text)
	end
	if not (type(tpos) == "number") then error(dgsGenAsrt(tpos,"dgsMemoSetCaretPosition",1,"number")) end
	local index,line
	local isWordWrap = eleData.wordWrap
	local showLine = eleData.showLine
	local font = eleData.font
	local fontHeight = dxGetFontHeight(eleData.textSize[2],font)
	local padding = eleData.padding
	local size = eleData.absSize
	local scbThick = eleData.scrollBarThick
	local scrollbars = eleData.scrollbars
	local scbTakes = {dgsElementData[scrollbars[1]].visible and scbThick or 0,dgsElementData[scrollbars[2]].visible and scbThick or 0}
	local canHold = mathFloor((size[2]-padding[2]*2-scbTakes[2])/fontHeight)
	if isWordWrap then
		if noSeekPosition then
			index = mathClamp(tpos,0,utf8Len(text))
			line = tline
		else
			index,line = dgsMemoSeekPosition(textTable,tpos,tline)
		end
		local wordWrapShowLine = eleData.wordWrapShowLine
		local mapTable = eleData.wordWrapMapText
		local weakIndex,weakLine = dgsMemoTransformStrongLineToWeakLine(textTable,mapTable,index,line)
		local targetLine = weakLine-wordWrapShowLine[3]+1
		if targetLine >= canHold then
			local theWeakLineIndex = weakLine-canHold+1
			local theWeakLine = mapTable[theWeakLineIndex]
			local newLine
			for i=1,#textTable do
				if textTable[i] == theWeakLine[1] then
					newLine = i
					break
				end
			end
			dgsSetData(memo,"wordWrapShowLine",{newLine,mapTable[theWeakLineIndex][2],theWeakLineIndex})
			syncScrollBars(memo,1)
		elseif targetLine < 1 then
			dgsSetData(memo,"wordWrapShowLine",{line,mapTable[weakLine][2],weakLine})
			syncScrollBars(memo,1)
		end
		dgsSetData(memo,"caretPos",{index,line})
		if not doSelect then
			dgsSetData(memo,"selectFrom",{index,line})
		end
	else
		if noSeekPosition then
			index = mathClamp(tpos,0,utf8Len(text))
			line = tline
		else
			index,line = dgsMemoSeekPosition(textTable,tpos,tline)
		end
		local showPos = eleData.showPos
		local nowLen = dxGetTextWidth(utf8Sub(text,0,index),eleData.textSize[1],font)
		local targetLen = nowLen-showPos
		if targetLen > size[1]-padding[1]*2-scbTakes[1] then
			dgsSetData(memo,"showPos",-(size[1]-padding[1]*2-scbTakes[1]-nowLen))
			syncScrollBars(memo,2)
		elseif targetLen < 0 then
			dgsSetData(memo,"showPos",nowLen)
			syncScrollBars(memo,2)
		end
		local targetLine = line-showLine+1
		if targetLine >= canHold then
			dgsSetData(memo,"showLine",line-canHold+1)
			syncScrollBars(memo,1)
		elseif targetLine < 1 then
			dgsSetData(memo,"showLine",line)
			syncScrollBars(memo,1)
		end
		dgsSetData(memo,"caretPos",{index,line})
		if not doSelect then
			dgsSetData(memo,"selectFrom",{index,line})
		end
	end
	resetTimer(MouseData.EditMemoTimer)
	MouseData.EditMemoCursor = true
	return true
end

function dgsMemoGetLineLength(memo,line)
	if dgsGetType(memo) ~= "dgs-dxmemo" then error(dgsGenAsrt(memo,"dgsMemoGetLineLength",1,"dgs-dxmemo")) end
	local textTable = dgsElementData[memo].text
	return textTable[line] and textTable[line][-1] or false
end

function dgsMemoGetCaretPosition(memo,detail)
	if dgsGetType(memo) ~= "dgs-dxmemo" then error(dgsGenAsrt(memo,"dgsMemoGetCaretPosition",1,"dgs-dxmemo")) end
	return dgsElementData[memo].caretPos[1],dgsElementData[memo].caretPos[2]
end

function dgsMemoSetCaretStyle(memo,style)
	if dgsGetType(memo) ~= "dgs-dxmemo" then error(dgsGenAsrt(memo,"dgsMemoSetCaretStyle",1,"dgs-dxmemo")) end
	if not(type(style) == "number") then error(dgsGenAsrt(style,"dgsMemoSetCaretStyle",2,"number")) end
	return dgsSetData(memo,"cursorStyle",style)
end

function dgsMemoGetCaretStyle(memo,style)
	if dgsGetType(memo) ~= "dgs-dxmemo" then error(dgsGenAsrt(memo,"dgsMemoGetCaretStyle",1,"dgs-dxmemo")) end
	return dgsElementData[memo].cursorStyle
end

function dgsMemoSetMaxLength(memo,maxLength)
	if dgsGetType(memo) ~= "dgs-dxmemo" then error(dgsGenAsrt(memo,"dgsMemoSetMaxLength",1,"dgs-dxmemo")) end
	if not(type(maxLength) == "number") then error(dgsGenAsrt(maxLength,"dgsMemoSetMaxLength",2,"number")) end
	return dgsSetData(memo,"maxLength",maxLength)
end

function dgsMemoGetMaxLength(memo)
	if dgsGetType(memo) ~= "dgs-dxmemo" then error(dgsGenAsrt(memo,"dgsMemoGetMaxLength",1,"dgs-dxmemo")) end
	return dgsElementData[memo].maxLength
end

function dgsMemoSetReadOnly(memo,state)
	if dgsGetType(memo) ~= "dgs-dxmemo" then error(dgsGenAsrt(memo,"dgsMemoSetReadOnly",1,"dgs-dxmemo")) end
	return dgsSetData(memo,"readOnly",state and true or false)
end

function dgsMemoGetReadOnly(memo)
	if dgsGetType(memo) ~= "dgs-dxmemo" then error(dgsGenAsrt(memo,"dgsMemoGetReadOnly",1,"dgs-dxmemo")) end
	return dgsGetData(memo,"readOnly")
end

function resetMemo(x,y)
	if dgsGetType(MouseData.focused) == "dgs-dxmemo" then
		if MouseData.focused == MouseData.click.left then
			local pos,line = searchMemoMousePosition(MouseData.focused,MouseData.cursorPos[1] or x*sW, MouseData.cursorPos[2] or y*sH)
			dgsMemoSetCaretPosition(MouseData.focused,pos,line,true)
		end
	end
end
addEventHandler("onClientCursorMove",root,resetMemo)

function searchMemoMousePosition(memo,posx,posy)
	local eleData = dgsElementData[memo]
	
	local res = eleData.resource or "global"
	local style = styleManager.styles[res]
	local using = style.using
	style = style.loaded[using]
	local systemFont = style.systemFontElement
	
	local font = eleData.font or systemFont
	local txtSizX = eleData.textSize[1]
	local padding = eleData.padding
	local fontHeight = dxGetFontHeight(eleData.textSize[2],font)
	local showPos = eleData.showPos
	local isWordWrap = eleData.wordWrap
	local showLine = isWordWrap and eleData.wordWrapShowLine[3] or eleData.showLine
	local x,y = dgsGetPosition(memo,false,true)
	local originalText = eleData.text
	local allText = isWordWrap and eleData.wordWrapMapText or originalText
	local selLine = mathClamp(mathFloor((posy-y-padding[1])/fontHeight)+showLine,1,#allText)
	local text = (allText[selLine] or {[0]=""})[0]
	local pos = posx-x-padding[1]+showPos
	local sfrom,sto,templen = 0,utf8Len(text),0
	for i=1,sto do
		stoSfrom_Half = (sto+sfrom)*0.5
		local stoSfrom_Half = stoSfrom_Half-stoSfrom_Half%1
		local strlen = dxGetTextWidth(utf8Sub(text,sfrom+1,stoSfrom_Half),txtSizX,font)
		local len1 = strlen+templen
		if pos < len1 then
			sto = stoSfrom_Half
		elseif pos > len1 then
			sfrom = stoSfrom_Half
			templen = dxGetTextWidth(utf8Sub(text,0,sfrom),txtSizX,font)
			start = len1
		elseif pos == len1 then
			start = len1
			sfrom = stoSfrom_Half
			sto = sfrom
			templen = dxGetTextWidth(utf8Sub(text,0,sfrom),txtSizX,font)
		end
		if sto-sfrom <= 10 then break end
	end
	local start = dxGetTextWidth(utf8Sub(text,0,sfrom),txtSizX,font)
	local resultIndex,resultLine,resultOffset = 0,1,1
	for i=sfrom,sto do
		local poslen1 = dxGetTextWidth(utf8Sub(text,sfrom+1,i),txtSizX,font)+start
		local theNext = dxGetTextWidth(utf8Sub(text,i+1,i+1),txtSizX,font)*0.5
		local offsetR = theNext+poslen1
		local theLast = dxGetTextWidth(utf8Sub(text,i,i),txtSizX,font)*0.5
		local offsetL = poslen1-theLast
		if i <= sfrom and pos <= offsetL then
			resultIndex,resultLine,resultOffset = sfrom,selLine,1
			break
		elseif i >= sto and pos >= offsetR then
			resultIndex,resultLine,resultOffset = sto,selLine,-1
			break
		elseif pos >= offsetL and pos <= offsetR then
			resultIndex,resultLine,resultOffset = i,selLine,pos-start < 0 and -1 or 1
			break
		end
	end
	if isWordWrap then
		local WrapTotalLine = 0
		for line=1,#originalText do
			for weakLine=1,#originalText[line][1] do
				WrapTotalLine = WrapTotalLine + 1
				if WrapTotalLine == resultLine then
					resultLine = line
					local before = 0
					for i=1,weakLine-1 do
						before = before + originalText[line][1][i][3]
					end
					resultIndex = resultIndex + before
				end
			end
		end
	end
	return resultIndex,resultLine,resultOffset
end

function searchTextFromPosition(text,font,textSizeX,pos)
	local sfrom,sto = 0,utf8Len(text)
	local templen = 0
	local stoSfrom_Half,len1
	for i=1,sto do
		stoSfrom_Half = (sto+sfrom)*0.5
		stoSfrom_Half = stoSfrom_Half-stoSfrom_Half%1
		len1 = dxGetTextWidth(utf8Sub(text,sfrom+1,stoSfrom_Half),textSizeX,font)+templen
		if pos < len1 then
			sto = stoSfrom_Half
		elseif pos > len1 then
			sfrom = stoSfrom_Half
			templen = dxGetTextWidth(utf8Sub(text,1,sfrom),textSizeX,font)
			start = len1
		elseif pos == len1 then
			start = len1
			sfrom = stoSfrom_Half-1
			sto = sfrom
			templen = dxGetTextWidth(utf8Sub(text,1,sfrom),textSizeX,font)
		end
		if sto-sfrom <= 10 then
			break
		end
	end
	local start = dxGetTextWidth(utf8Sub(text,1,sfrom),textSizeX,font)
	local current
	for i=sfrom,sto do
		current = dxGetTextWidth(utf8Sub(text,i+1,i+1),textSizeX,font)
		if start+current >= pos then return i end
		start = start+current
	end
	return sto
end

--Optimize Mark: textLength/textCount
wordArea = {
	{48,57},
	{65,90},
	{97,122},
}
function dgsMemoWordSplit(text,maxWidth,textWidth,font,textSizeX,isSplitByWord)
	local splitTable = {}

	local textSizeX = textSizeX or 1
	local textWidth = textWidth or dxGetTextWidth(text,textSizeX,font)
	if maxWidth > textWidth then
		return {text},1
	end
	local cnt = 1
	if isSplitByWord == 2 then
		while(text ~= "") do
			local breakPoint = false
			local index = searchTextFromPosition(text,font,textSizeX,maxWidth)
			if index < utf8Len(text) then
				local NextWordByte = utf8Byte(text,index+1,index+1)
				local checkContinuity = false
				for i=1,#wordArea do
					if NextWordByte >= wordArea[i][1] and NextWordByte <= wordArea[i][2] then
						checkContinuity = true
						break
					end
				end
				if checkContinuity then
					for i=index,1,-1 do
						local checkCharByte = utf8Byte(text,i,i)
						local isContinue = false
						for i=1,#wordArea do
							if checkCharByte >= wordArea[i][1] and checkCharByte <= wordArea[i][2] then
								isContinue = true
								break
							end
						end
						if not isContinue then
							breakPoint = i
							break
						end
					end
				end
			end
			local tempText = utf8Sub(text,1,breakPoint or index)
			text = utf8Sub(text,(breakPoint or index)+1)
			splitTable[cnt] = tempText
			cnt = cnt+1
		end
		return splitTable,cnt-1
	else
		while(text ~= "") do
			local index = searchTextFromPosition(text,font,textSizeX,maxWidth)
			local tempText = utf8Sub(text,1,index)
			text = utf8Sub(text,index+1)
			splitTable[cnt] = tempText
			cnt = cnt+1
		end
		return splitTable,cnt-1
	end
	return false,false
end

function dgsMemoGetInsertLine(textTable,mapTable,theLine)
	for i=1,#mapTable do
		if mapTable[i][1] == textTable[theLine] then
			return i,#textTable[theLine][1]
		end
	end
	return 1,1
end

function dgsMemoRemoveMapTable(mapTable,from,count)
	for i=from,from+count-1 do
		tableRemove(mapTable,from)
	end
end

function dgsMemoInsertMapTable(mapTable,from,insertTable,strongLine)
	local resultTable = {}
	for i=1,#insertTable do
		local readyTable = {[0]=insertTable[i],strongLine,i,utf8Len(insertTable[i])}
		tableInsert(mapTable,from+i-1,readyTable)
		resultTable[i] = readyTable
	end
	return resultTable
end

function dgsMemoFindWeakLineInStrongLine(strongLine,index,isCeil)
	if #strongLine[1] == 1 then
		return index,1
	end
	for i=1,#strongLine[1] do
		local textLen = strongLine[1][i][3]
		if (isCeil and index >= textLen) or (not isCeil and index > textLen) then
			index = index-textLen
		else
			return index,i
		end
	end
	return index,#strongLine[1]
end

function dgsMemoTransfromWeakLineToStrongLine(textTable,mapTable,index,weakLine)
	local weakLineText = mapTable[weakLine]
	local allPos = 0
	for i=1,#textTable do
		if weakLineText[1] == textTable[i] then
			local textLen = index
			for a=1,weakLine-allPos-1 do
				textLen = textTable[i][1][a][3]+textLen
			end
			return textLen,i
		end
		allPos = allPos+#textTable[i][1]
	end
	return utf8Len(textTable[#textTable][0]),#textTable
end

function dgsMemoTransformStrongLineToWeakLine(textTable,mapTable,index,line,isCeil)
	local strongLine = textTable[line]
	for i=1,#strongLine[1] do
		local textLen = strongLine[1][i][3]
		if index-textLen < 0 then
			local weakLineBefore = 0
			for weakLine=1,#mapTable do
				if mapTable[weakLine][1] == strongLine then
					weakLineBefore = weakLine-1
					break
				end
			end
			return index,i+weakLineBefore
		elseif index-textLen == 0 then
			if not isCeil or i == #strongLine[1] then
				local weakLineBefore = 0
				for weakLine=1,#mapTable do
					if mapTable[weakLine][1] == strongLine then
						weakLineBefore = weakLine-1
						break
					end
				end
				return index,i+weakLineBefore
			end
		end
		index = index-textLen
	end
	return utf8Len(mapTable[#mapTable][0]),#mapTable
end

local splitChar = "\r\n"
local splitChar2 = "\n"
function handleDxMemoText(memo,text,noclear,noAffectCaret,index,line)
	local eleData = dgsElementData[memo]
	local textTable = eleData.text or {}
	local maxLength = eleData.maxLength
	if not noclear then
		eleData.text = {{[-1]=0,[0]=""}}
		textTable = eleData.text
		dgsSetData(memo,"caretPos",{0,1})
		dgsSetData(memo,"selectFrom",{0,1})
		dgsSetData(memo,"rightLength",{0,1})
		if eleData.wordWrap then
			dgsSetData(memo,"wordWrapMapText",{})
			dgsSetData(memo,"wordWrapShowLine",{1,1,1})
			dgsMemoRebuildWordWrapMapTable(memo)
		end
		configMemo(memo)
		
		eleData.updateRTNextFrame = true
	end
	
	local res = eleData.resource or "global"
	local style = styleManager.styles[res]
	local using = style.using
	style = style.loaded[using]
	local systemFont = style.systemFontElement
	
	local font = eleData.font or systemFont
	local textSize = eleData.textSize
	local _index,_line = dgsMemoGetCaretPosition(memo,true)
	local index,line = index or _index,line or _line
	local fixed = utf8Gsub(text,splitChar,splitChar2)
	local fixed = " "..utf8Gsub(fixed,"	"," ").." "
	local tab = string.split(fixed,splitChar2)
	tab[1] = utf8Sub(tab[1],2)
	tab[#tab] = utf8Sub(tab[#tab],1,utf8Len(tab[#tab])-1)
	local text = dgsGetText(memo)
	local textLen = utf8Len(text)
	if textLen >= maxLength then return false end
	local isWordWrap = eleData.wordWrap
	local mapTable = eleData.wordWrapMapText or {}
	local size = eleData.absSize
	local padding = eleData.padding
	local scbThick = eleData.scrollBarThick
	local scrollbars = eleData.scrollbars
	local scbTakes1 = dgsElementData[scrollbars[1]].visible and scbThick+2 or 4
	local canHold = mathFloor(size[1]-padding[1]*2-scbTakes1)

	local offset = 0
	if tab ~= 0 then
		local insertLine,lineCnt
		if isWordWrap then
			insertLine,lineCnt = dgsMemoGetInsertLine(textTable,mapTable,line)
			dgsMemoRemoveMapTable(mapTable,insertLine,lineCnt)
		end
		local textFront,textRear
		local newTextLines = #tab
		for i=1,newTextLines do
			tab[i] = tab[i] or ""
			offset = offset+utf8Len(tab[i])+1
			theline = line+i-1
			if i ~= 1 and i ~= newTextLines then
				local textLen = dxGetTextWidth(tab[i],textSize[1],font)
				local text = tab[i]
				tableInsert(textTable,theline,{[-1]=textLen,[0]=text})
			else
				if i == 1 then
					textTable[theline] = textTable[theline] or {[0]=""}
					textFront = utf8Sub(textTable[theline][0],0,index) or ""
					textRear = utf8Sub(textTable[theline][0],index+1) or ""
					local isAppendRear = newTextLines == 1 and textRear or ""
					textTable[theline][0] = textFront..tab[1]..isAppendRear
					textTable[theline][-1] = dxGetTextWidth(textTable[theline][0],textSize[1],font)
				end
				if i == newTextLines and i ~= 1 then
					local text = {}
					text[0] = (tab[i] or "")..textRear
					text[-1] = dxGetTextWidth(text[0],textSize[1],font)
					tableInsert(textTable,theline,text)
				end
			end
			if isWordWrap then
				local splitedText,splitedTextLine = dgsMemoWordSplit(textTable[theline][0],canHold,textTable[theline][-1],font,textSize[1],isWordWrap)
				textTable[theline][1] = dgsMemoInsertMapTable(mapTable,insertLine,splitedText,textTable[theline])
				insertLine = insertLine + splitedTextLine
			end

			if eleData.rightLength[1] < textTable[theline][-1] then
				eleData.rightLength = {textTable[theline][-1],theline}
			elseif eleData.rightLength[2] > line+#tab-1 then
				eleData.rightLength[2] = eleData.rightLength[2]+1
			end
		end
		eleData.text = textTable
		local fontHeight = dxGetFontHeight(eleData.textSize[2],font)
		local scbTakes = {dgsElementData[scrollbars[1]].visible and scbThick or 0,dgsElementData[scrollbars[2]].visible and scbThick or 0}
		local canHold = mathFloor((size[2]-padding[2]*2-scbTakes[2])/fontHeight)
		if dgsElementData[scrollbars[1]].visible or eleData.rightLength[1] > size[1]-padding[1]*2-scbTakes[1] or dgsElementData[scrollbars[2]].visible or #textTable > canHold then
			configMemo(memo)
		end
		if not noAffectCaret then
			if line < _line or (line == _line and index <= _index) then
				dgsMemoSetCaretPosition(memo,index+offset-1,line)
			end
		end
		eleData.updateRTNextFrame = true
		dgsTriggerEvent("onDgsTextChange",memo)
	end
end

function dgsMemoAppendText(memo,text,noAffectCaret)
	if dgsGetType(memo) ~= "dgs-dxmemo" then error(dgsGenAsrt(memo,"dgsMemoAppendText",1,"dgs-dxmemo")) end
	local textTable = dgsElementData[memo].text
	local line = #textTable
	local index = textTable[line][-1]
	return handleDxMemoText(memo,tostring(text),true,noAffectCaret,index,line)
end

function dgsMemoInsertText(memo,index,line,text,noAffectCaret)
	if dgsGetType(memo) ~= "dgs-dxmemo" then error(dgsGenAsrt(memo,"dgsMemoInsertText",1,"dgs-dxmemo")) end
	if not(dgsGetType(index) == "number") then error(dgsGenAsrt(index,"dgsMemoInsertText",2,"number")) end
	if not(dgsGetType(line) == "number") then error(dgsGenAsrt(line,"dgsMemoInsertText",3,"number")) end
	return handleDxMemoText(memo,tostring(text),true,noAffectCaret,index,line)
end

function dgsMemoDeleteText(memo,fromIndex,fromLine,toIndex,toLine,noAffectCaret)
	if dgsGetType(memo) ~= "dgs-dxmemo" then error(dgsGenAsrt(memo,"dgsMemoDeleteText",1,"dgs-dxmemo")) end
	if not(dgsGetType(fromIndex) == "number") then error(dgsGenAsrt(fromIndex,"dgsMemoDeleteText",2,"number")) end
	if not(dgsGetType(fromLine) == "number") then error(dgsGenAsrt(fromLine,"dgsMemoDeleteText",3,"number")) end
	if not(dgsGetType(toIndex) == "number") then error(dgsGenAsrt(toIndex,"dgsMemoDeleteText",4,"number")) end
	if not(dgsGetType(toIndex) == "number") then error(dgsGenAsrt(toIndex,"dgsMemoDeleteText",5,"number")) end
	if fromIndex == toIndex and fromLine == toLine then return end
	local eleData = dgsElementData[memo]
	local textTable = eleData.text
	local mapTable = eleData.wordWrapMapText
		
	local res = eleData.resource or "global"
	local style = styleManager.styles[res]
	local using = style.using
	style = style.loaded[using]
	local systemFont = style.systemFontElement
	
	local font = eleData.font or systemFont
	local textSize = eleData.textSize
	local fontHeight = dxGetFontHeight(eleData.textSize[2],font)
	local size = eleData.absSize
	local padding = eleData.padding
	local scbThick = eleData.scrollBarThick
	local scrollbars = eleData.scrollbars
	local textLines = #textTable
	local isWordWrap = eleData.wordWrap
	local lineTextFrom = textTable[fromLine][0]
	local lineTextTo = textTable[toLine][0]
	local lineTextFromCnt = utf8Len(lineTextFrom)
	local lineTextToCnt = utf8Len(lineTextTo)
	local insertLine,lineCnt
	fromIndex,toIndex = mathClamp(fromIndex,0,lineTextFromCnt),mathClamp(toIndex,0,lineTextToCnt)
	fromLine,toLine = mathClamp(fromLine,1,textLines),mathClamp(toLine,1,textLines)
	if fromLine > toLine then
		fromLine,toLine,fromIndex,toIndex = toLine,fromLine,toIndex,fromIndex
	end
	if fromLine == toLine then
		local _to = toIndex < fromIndex and fromIndex or toIndex
		local _from = fromIndex > toIndex and toIndex or fromIndex
		textTable[toLine][0] = utf8Sub(textTable[toLine][0],0,_from)..utf8Sub(textTable[toLine][0],_to+1)
		textTable[toLine][-1] = dxGetTextWidth(textTable[toLine][0],textSize[1],font)
		if isWordWrap then
			insertLine,lineCnt = dgsMemoGetInsertLine(textTable,mapTable,fromLine)
			dgsMemoRemoveMapTable(mapTable,insertLine,lineCnt)
		end
	else
		textTable[fromLine][0] = utf8Sub(textTable[fromLine][0],0,fromIndex)..utf8Sub(textTable[toLine][0],toIndex+1)
		textTable[fromLine][-1] = dxGetTextWidth(textTable[fromLine][0],textSize[1],font)
		insertLine,lineCnt = dgsMemoGetInsertLine(textTable,mapTable,fromLine)
		dgsMemoRemoveMapTable(mapTable,insertLine,lineCnt)
		for i=fromLine+1,toLine do
			if isWordWrap then
				insertLine,lineCnt = dgsMemoGetInsertLine(textTable,mapTable,fromLine+1)
				dgsMemoRemoveMapTable(mapTable,insertLine,lineCnt)
			end
			tableRemove(textTable,fromLine+1)
		end
	end
	local scbTakes = {dgsElementData[scrollbars[1]].visible and scbThick+2 or 4,dgsElementData[scrollbars[2]].visible and scbThick+2 or 4}
	local canHold = mathFloor((size[2]-padding[2]*2-scbTakes[2])/fontHeight)
	if isWordWrap then
		local splitedText,splitedTextLine = dgsMemoWordSplit(textTable[fromLine][0],size[1]-padding[2]*2-scbTakes[1],textTable[fromLine][-1],font,textSize[1],isWordWrap)
		textTable[fromLine][1] = dgsMemoInsertMapTable(mapTable,insertLine,splitedText,textTable[fromLine])
		insertLine = insertLine + splitedTextLine
	end
	eleData.text = textTable
	local line,len = seekMaxLengthLine(memo)
	eleData.rightLength = {len,line}
	if dgsElementData[scrollbars[1]].visible or eleData.rightLength[1] > size[1]-padding[2]*2-scbTakes[1] or dgsElementData[scrollbars[2]].visible or #textTable > canHold then
		configMemo(memo)
	end
	if not noAffectCaret then
		local cpos = eleData.caretPos
		if cpos[2] > fromLine then
			dgsMemoSetCaretPosition(memo,cpos[1]-(toIndex-fromIndex),cpos[2]-(toLine-fromLine))
		elseif cpos[2] == fromLine and cpos[1] >= fromIndex then
			dgsMemoSetCaretPosition(memo,fromIndex,fromLine)
		end
	end
	local textTable = eleData.text
	if isWordWrap then
		local mapTable = eleData.wordWrapMapText
		local mapTableCnt = #mapTable
		local wordWrapShowLine = eleData.wordWrapShowLine
		if mapTableCnt> canHold and wordWrapShowLine[3]-1+canHold > mapTableCnt then
			wordWrapShowLine[3] = 1-canHold+mapTableCnt
			local startStrongLine
			for i = 1,#textTable do
				if textTable[i] == mapTable[wordWrapShowLine[3]][1] then
					startStrongLine = i
				end
			end
			local startWeakLine
			for i=1,mapTableCnt do
				if mapTable[i][1] == textTable[startStrongLine] then
					startWeakLine = wordWrapShowLine[3]-i+1
				end
			end
			wordWrapShowLine[1] = startStrongLine
			wordWrapShowLine[2] = startWeakLine
		end
	else
		if #textTable > canHold and eleData.showLine-1+canHold > #textTable then
			eleData.showLine = 1-canHold+#textTable
		end
	end
	eleData.updateRTNextFrame = true
	dgsTriggerEvent("onDgsTextChange",memo)
end

function dgsMemoClearText(memo)
	if dgsGetType(memo) ~= "dgs-dxmemo" then error(dgsGenAsrt(memo,"dgsMemoClearText",1,"dgs-dxmemo")) end
	local eleData = dgsElementData[memo]
	eleData.text = {{[-1]=0,[0]=""}}
	dgsSetData(memo,"caretPos",{0,1})
	dgsSetData(memo,"selectFrom",{0,1})
	dgsSetData(memo,"rightLength",{0,1})
	if eleData.wordWrap then
		dgsSetData(memo,"wordWrapMapText",{})
		dgsSetData(memo,"wordWrapShowLine",{1,1,1})
		dgsMemoRebuildWordWrapMapTable(memo)
	end
	configMemo(memo)
	eleData.updateRTNextFrame = true
	dgsTriggerEvent("onDgsTextChange",memo)
	return true
end

function dgsMemoGetPartOfText(memo,cindex,cline,tindex,tline,isDelete)
	if dgsGetType(memo) ~= "dgs-dxmemo" then error(dgsGenAsrt(memo,"dgsMemoGetPartOfText",1,"dgs-dxmemo")) end
	local outStr = ""
	local textTable = dgsElementData[memo].text
	local textLines = #textTable
	cindex,cline,tindex,tline = cindex or 0,cline or 1,tindex or utf8Len(textTable[textLines][0]),tline or textLines
	cline = mathClamp(cline,1,textLines)
	tline = mathClamp(tline,1,textLines)
	local lineTextFrom = textTable[cline][0]
	local lineTextTo = textTable[tline][0]
	local lineTextFromCnt = utf8Len(lineTextFrom)
	local lineTextToCnt = utf8Len(lineTextTo)
	cindex = mathClamp(cindex,0,lineTextFromCnt)
	tindex = mathClamp(tindex,0,lineTextToCnt)
	if cline > tline then
		tline,cline = cline,tline
	end
	if cline == tline then
		local _to = tindex < cindex  and cindex or tindex
		local _from = cindex > tindex and tindex or cindex
		outStr = utf8Sub(textTable[tline][0],_from,_to)
	else
		local txt1 = utf8Sub(textTable[cline][0],cindex+1) or ""
		local txt2 = utf8Sub(textTable[tline][0],0,tindex) or ""
		for i=cline+1,tline-1 do
			outStr = outStr..textTable[i][0]..splitChar2
		end
		outStr = txt1 ..splitChar2 ..outStr.. txt2
	end
	if isDelete then
		dgsMemoDeleteText(memo,cindex,cline,tindex,tline)
	end
	return outStr
end

function dgsMemoSetSelectedArea(memo,fromIndex,fromLine,...)
	if dgsGetType(memo) ~= "dgs-dxmemo" then error(dgsGenAsrt(memo,"dgsMemoSetSelectedArea",1,"dgs-dxmemo")) end
	if not(dgsGetType(fromIndex) == "number") then error(dgsGenAsrt(fromIndex,"dgsMemoSetSelectedArea",2,"number")) end
	if not(dgsGetType(fromLine) == "number") then error(dgsGenAsrt(fromLine,"dgsMemoSetSelectedArea",3,"number")) end
	local args = {...}
	local textTable = dgsElementData[memo].text
	local toIndex,toLine
	if #args == 1 then
		if args[1] == "all" then
			toLine = #textTable
			toIndex = utf8Len(textTable[toLine][0])
		else
			if not(dgsGetType(args[1]) == "number") then error(dgsGenAsrt(args[1],"dgsMemoSetSelectedArea",4,"number")) end
			toIndex,toLine = dgsMemoSeekPosition(textTable,fromIndex+args[1],fromLine)
		end
	elseif #args == 2 then
		toIndex,toLine = args[1],args[2]
		if not(dgsGetType(toIndex) == "number") then error(dgsGenAsrt(toIndex,"dgsMemoSetSelectedArea",4,"number")) end
		if not(dgsGetType(toLine) == "number") then error(dgsGenAsrt(toLine,"dgsMemoSetSelectedArea",5,"number")) end
		if #textTable <= toLine then
			toLine = #textTable
		end
		local textCnt = utf8Len(textTable[toLine][0])
		if textCnt <= toIndex then
			toIndex = textCnt
		end
	end
	dgsSetData(memo,"caretPos",{fromIndex,fromLine})
	dgsSetData(memo,"selectFrom",{toIndex,toLine})
	return true
end

function dgsMemoGetSelectedArea(memo)
	if dgsGetType(memo) ~= "dgs-dxmemo" then error(dgsGenAsrt(memo,"dgsMemoGetSelectedArea",1,"dgs-dxmemo")) end
	local eleData = dgsElementData[memo]
	local fromIndex,fromLine = eleData.caretPos[1],eleData.caretPos[2]
	local toIndex,toLine = eleData.selectFrom[1],eleData.selectFrom[2]
	return fromIndex,fromLine,toIndex,toLine
end

function dgsMemoSetTypingSound(memo,path,volume)
	if dgsGetType(memo) ~= "dgs-dxmemo" then error(dgsGenAsrt(memo,"dgsMemoSetTypingSound",1,"dgs-dxmemo")) end
	if not(type(path) == "string") then error(dgsGenAsrt(path,"dgsMemoSetTypingSound",2,"string")) end
	if sourceResource then
		if not path:find(":") then
			path = ":"..getResourceName(sourceResource).."/"..path
		end
	end
	if not fileExists(path) then error(dgsGenAsrt(path,"dgsMemoSetTypingSound",2,_,_,_,"Couldn't find such file '"..path.."'")) end
	dgsElementData[memo].typingSound = path
	dgsElementData[memo].typingSoundVolume = volume
end

function dgsMemoGetTypingSound(memo)
	if dgsGetType(memo) ~= "dgs-dxmemo" then error(dgsGenAsrt(memo,"dgsMemoGetTypingSound",1,"dgs-dxmemo")) end
	return dgsElementData[memo].typingSound
end

function dgsMemoSetTypingSoundVolume(memo,volume)
	if dgsGetType(memo) ~= "dgs-dxmemo" then error(dgsGenAsrt(memo,"dgsMemoSetTypingSoundVolume",1,"dgs-dxmemo")) end
	if type(volume) ~= "number" then error(dgsGenAsrt(volume,"dgsMemoSetTypingSoundVolume",2,"number")) end
	dgsElementData[memo].typingSoundVolume = tonumber(volume)
	return true
end

function dgsMemoGetTypingSoundVolume(memo)
	if dgsGetType(memo) ~= "dgs-dxmemo" then error(dgsGenAsrt(memo,"dgsMemoGetTypingSoundVolume",1,"dgs-dxmemo")) end
	return dgsElementData[memo].typingSoundVolume or 1
end

function dgsMemoSetWordWrapState(memo,state)
	if dgsGetType(memo) ~= "dgs-dxmemo" then error(dgsGenAsrt(memo,"dgsMemoSetWordWrapState",1,"dgs-dxmemo")) end
	if state == true then
		state = 1
	elseif state ~= false and state ~= 1 and state ~= 2 then
		state = false
	end
	return dgsSetData(memo,"wordWrap",state)
end

function dgsMemoGetWordWrapState(memo)
	if dgsGetType(memo) ~= "dgs-dxmemo" then error(dgsGenAsrt(memo,"dgsMemoGetWordWrapState",1,"dgs-dxmemo")) end
	return dgsElementData[memo].wordWrap
end

function seekMaxLengthLine(memo)
	local line,lineLen = -1,-1
	local textTable = dgsElementData[memo].text
	for i=1,#textTable do
		local v = textTable[i][-1]
		if v > lineLen then
			lineLen = v
			line = i
		end
	end
	return line,lineLen
end

function configMemo(memo)
	local eleData = dgsElementData[memo]
	local size = eleData.absSize
	local padding = eleData.padding
	local scrollbar = eleData.scrollbars
	local scrollBarBefore = {dgsElementData[scrollbar[1]].visible,dgsElementData[scrollbar[2]].visible}
	local textCnt
	if eleData.wordWrap then
		textCnt = #eleData.wordWrapMapText	--Weak Line for word Wrap
	else
		textCnt = #eleData.text			--Strong Line for no word Wrap
	end
	local font = eleData.font
	local textSize = eleData.textSize
	local fontHeight = dxGetFontHeight(eleData.textSize[2],font)
	local scbThick = eleData.scrollBarThick
	local scbStateV,scbStateH = false,false
	if not eleData.wordWrap then
		scbStateH = eleData.rightLength[1] > size[1]-padding[1]*2
	end
	local scbTakes2 = scbStateH and scbThick or 0
	local canHold = mathFloor((size[2]-padding[2]*2-scbTakes2)/fontHeight)
	scbStateV = textCnt > canHold
	local scbTakes1 = scbStateV and scbThick or 0
	if not eleData.wordWrap then
		scbStateH = eleData.rightLength[1] > size[1]-padding[1]*2-scbTakes1
	end
	local forceState = eleData.scrollBarState
	if forceState[1] ~= nil then scbStateV = forceState[1] end
	if forceState[2] ~= nil then scbStateH = forceState[2] end
	dgsSetVisible(scrollbar[1],scbStateV and true or false)
	dgsSetVisible(scrollbar[2],scbStateH and true or false)
	local scbTakes1 = scbStateV and scbThick or 0
	local scbTakes2 = scbStateH and scbThick or 0
	dgsSetPosition(scrollbar[1],size[1]-scbThick,0,false)
	dgsSetPosition(scrollbar[2],0,size[2]-scbThick,false)
	dgsSetSize(scrollbar[1],scbThick,size[2]-scbTakes2,false)
	dgsSetSize(scrollbar[2],size[1]-scbTakes1,scbThick,false)

	local scbLengthVrt = eleData.scrollBarLength[1]
	local higLen = 1-(textCnt-canHold)/textCnt
	higLen = higLen >= 0.95 and 0.95 or higLen
	dgsSetData(scrollbar[1],"length",scbLengthVrt or {higLen,true})
	local verticalScrollSize = eleData.scrollSize/(textCnt-canHold)
	dgsSetData(scrollbar[1],"multiplier",{verticalScrollSize,true})

	local scbLengthHoz = eleData.scrollBarLength[2]
	local widLen = 1-(eleData.rightLength[1]-size[1]+scbTakes1+padding[1]*2)/eleData.rightLength[1]
	widLen = widLen >= 0.95 and 0.95 or widLen
	dgsSetData(scrollbar[2],"length",scbLengthHoz or {widLen,true})
	local horizontalScrollSize = eleData.scrollSize*5/(eleData.rightLength[1]-size[1]+scbTakes1+padding[1]*2)
	dgsSetData(scrollbar[2],"multiplier",{horizontalScrollSize,true})
	if dgsElementData[scrollbar[1]].visible ~= scrollBarBefore[1] or dgsElementData[scrollbar[2]].visible ~= scrollBarBefore[2] then
		dgsSetData(memo,"rebuildMapTableNextFrame",true)
	end
	dgsMemoRecreateRenderTarget(memo,true)
	dgsSetData(memo,"configNextFrame",nil)
	dgsElementData[memo].updateRTNextFrame = true
end

function checkMemoScrollBar(source,new,old)
	local memo = dgsGetParent(source)
	local eleData = dgsElementData[memo]
	local scrollbars = eleData.scrollbars
	local size = eleData.absSize
	local padding = eleData.padding
	local scbThick = eleData.scrollBarThick
	local font = eleData.font
	local textSize = eleData.textSize
	local isWordWrap = eleData.wordWrap
	local textTable = eleData.text
	local scbTakes1,scbTakes2 = dgsElementData[scrollbars[1]].visible and scbThick+2 or 4,dgsElementData[scrollbars[2]].visible and scbThick or 0
	if source == scrollbars[1] then
		local fontHeight = dxGetFontHeight(eleData.textSize[2],font)
		local canHold = mathFloor((size[2]-padding[2]*2-scbTakes2)/fontHeight)
		if isWordWrap then
			local mapTable = dgsElementData[memo].wordWrapMapText
			local temp = mathFloor((#mapTable-canHold)*new*0.01)+1
			if temp <= 1 then temp = 1 end
			local wordWrapShowLine = eleData.wordWrapShowLine
			wordWrapShowLine[3] = temp
			local startStrongLine
			for i=1,#textTable do
				if textTable[i] == mapTable[wordWrapShowLine[3]][1] then
					startStrongLine = i
				end
			end
			local startWeakLine
			for i=1,#mapTable do
				if mapTable[i][1] == textTable[startStrongLine] then
					startWeakLine = wordWrapShowLine[3]-i+1
					break
				end
			end
			wordWrapShowLine[1] = startStrongLine
			wordWrapShowLine[2] = startWeakLine
		else
			local temp = mathFloor((#textTable-canHold)*new*0.01)+1
			dgsSetData(memo,"showLine",temp)
		end
	elseif source == scrollbars[2] then
		local canHold = mathFloor(eleData.rightLength[1]-size[1]+scbTakes1+padding[1]*2)*0.01
		local temp = new*canHold
		dgsSetData(memo,"showPos",temp)
	end
	eleData.updateRTNextFrame = true
end

function syncScrollBars(memo,which)
	local eleData = dgsElementData[memo]
	local scrollbars = eleData.scrollbars
	local size = eleData.absSize
	local padding = eleData.padding
	local scbThick = eleData.scrollBarThick
	local font = eleData.font
	local textSize = eleData.textSize
	local isWordWrap = eleData.wordWrap
	local scbTakes1,scbTakes2 = dgsElementData[scrollbars[1]].visible and scbThick+2 or 4,dgsElementData[scrollbars[2]].visible and scbThick or 0
	if which == 1 or not which then
		local fontHeight = dxGetFontHeight(eleData.textSize[2],font)
		local canHold = mathFloor((size[2]-padding[2]*2-scbTakes2)/fontHeight)
		if isWordWrap then
			local line = #eleData.wordWrapMapText
			local new = (line-canHold) == 0 and 0 or (eleData.wordWrapShowLine[3]-1)*100/(line-canHold)
			dgsScrollBarSetScrollPosition(scrollbars[1],new)
		else
			local line = #eleData.text
			local new = (line-canHold) == 0 and 0 or (eleData.showLine-1)*100/(line-canHold)
			dgsScrollBarSetScrollPosition(scrollbars[1],new)
		end
	end
	if which == 2 or not which then
		local canHold = mathFloor(eleData.rightLength[1]-size[1]+scbTakes1+padding[1]*2)*0.01
		local new = eleData.showPos/canHold
		if new >= 100 then new = 100 end
		dgsScrollBarSetScrollPosition(scrollbars[2],new)
	end
end

function dgsMemoSetScrollBarState(memo,vertical,horizontal)
	if dgsGetType(memo) ~= "dgs-dxmemo" then error(dgsGenAsrt(memo,"dgsMemoSetScrollBarState",1,"dgs-dxmemo")) end
	dgsSetData(memo,"scrollBarState",{vertical,horizontal},true)
	dgsSetData(memo,"configNextFrame",true)
	return true
end

function dgsMemoGetScrollBarState(memo)
	if dgsGetType(memo) ~= "dgs-dxmemo" then error(dgsGenAsrt(memo,"dgsMemoGetScrollBarState",1,"dgs-dxmemo")) end
	return dgsElementData[memo].scrollBarState[1],dgsElementData[memo].scrollBarState[2]
end

function dgsMemoSetScrollPosition(memo,vertical,horizontal)
	if dgsGetType(memo) ~= "dgs-dxmemo" then error(dgsGenAsrt(memo,"dgsMemoSetScrollPosition",1,"dgs-dxmemo")) end
	if vertical and not (type(vertical) == "number" and vertical>= 0 and vertical <= 100) then error(dgsGenAsrt(vertical,"dgsMemoSetScrollPosition",2,"nil/number","0~100")) end
	if horizontal and not (type(horizontal) == "number" and horizontal>= 0 and horizontal <= 100) then error(dgsGenAsrt(horizontal,"dgsMemoSetScrollPosition",3,"nil/number","0~100")) end
	local scb = dgsElementData[memo].scrollbars
	local state1,state2 = true,true
	if dgsElementData[scb[1]].visible then
		state1 = dgsScrollBarSetScrollPosition(scb[1],vertical)
	end
	if dgsElementData[scb[2]].visible then
		state2 = dgsScrollBarSetScrollPosition(scb[2],horizontal)
	end
	return state1 and state2
end

function dgsMemoGetScrollPosition(memo)
	if dgsGetType(memo) ~= "dgs-dxmemo" then error(dgsGenAsrt(memo,"dgsMemoGetScrollPosition",1,"dgs-dxmemo")) end
	local scb = dgsElementData[memo].scrollbars
	return dgsScrollBarGetScrollPosition(scb[1]),dgsScrollBarGetScrollPosition(scb[2])
end

--Make compatibility for GUI
function dgsMemoGetHorizontalScrollPosition(memo)
	if dgsGetType(memo) ~= "dgs-dxmemo" then error(dgsGenAsrt(memo,"dgsMemoGetHorizontalScrollPosition",1,"dgs-dxmemo")) end
	local scb = dgsElementData[memo].scrollbars
	return dgsScrollBarGetScrollPosition(scb[2])
end

function dgsMemoSetHorizontalScrollPosition(memo,horizontal)
	if dgsGetType(memo) ~= "dgs-dxmemo" then error(dgsGenAsrt(memo,"dgsMemoSetHorizontalScrollPosition",1,"dgs-dxmemo")) end
	if horizontal and not (type(horizontal) == "number" and horizontal>= 0 and horizontal <= 100) then error(dgsGenAsrt(horizontal,"dgsMemoSetHorizontalScrollPosition",2,"nil/number","0~100")) end
	local scb = dgsElementData[memo].scrollbars
	return dgsScrollBarSetScrollPosition(scb[2],horizontal)
end

function dgsMemoGetVerticalScrollPosition(memo)
	if dgsGetType(memo) ~= "dgs-dxmemo" then error(dgsGenAsrt(memo,"dgsMemoGetVerticalScrollPosition",1,"dgs-dxmemo")) end
	local scb = dgsElementData[memo].scrollbars
	return dgsScrollBarGetScrollPosition(scb[1])
end

function dgsMemoSetVerticalScrollPosition(memo,vertical)
	if dgsGetType(memo) ~= "dgs-dxmemo" then error(dgsGenAsrt(memo,"dgsMemoSetVerticalScrollPosition",1,"dgs-dxmemo")) end
	if vertical and not (type(vertical) == "number" and vertical>= 0 and vertical <= 100) then error(dgsGenAsrt(vertical,"dgsMemoSetVerticalScrollPosition",2,"nil/number","0~100")) end
	local scb = dgsElementData[memo].scrollbars
	return dgsScrollBarSetScrollPosition(scb[1],vertical)
end

addEventHandler("onClientGUIChanged",GlobalMemo,function()
	if not dgsElementData[source] then return end
	if getElementType(source) == "gui-memo" then
		local dxMemo = dgsElementData[source].linkedDxMemo
		if isElement(dxMemo) then
			local text = guiGetText(source)
			local cool = dgsElementData[dxMemo].CoolTime
			if text ~= "\n" then
				if not cool and not dgsElementData[dxMemo].readOnly then
					local caretPos = dgsElementData[dxMemo].caretPos
					local selectFrom = dgsElementData[dxMemo].selectFrom
					dgsMemoDeleteText(dxMemo,caretPos[1],caretPos[2],selectFrom[1],selectFrom[2])
					handleDxMemoText(dxMemo,utf8Sub(text,1,utf8Len(text)-1),true)
				end
				dgsElementData[dxMemo].CoolTime = true
				guiSetText(source,"")
				dgsElementData[dxMemo].CoolTime = false
			end
		end
	end
end,false)

function dgsMemoRebuildWordWrapMapTable(memo)
	dgsSetData(memo,"rebuildMapTableNextFrame",nil)
	local eleData = dgsElementData[memo]
	local isWordWrap = eleData.wordWrap
	if isWordWrap then
		local textTable = eleData.text
		local size = eleData.absSize
		local padding = eleData.padding
			
		local res = eleData.resource or "global"
		local style = styleManager.styles[res]
		local using = style.using
		style = style.loaded[using]
		local systemFont = style.systemFontElement
		
		local font = eleData.font or systemFont
		local textSizeX = eleData.textSize[1]
		local scbThick = eleData.scrollBarThick
		local scrollbars = eleData.scrollbars
		local scbTakes1 = dgsElementData[scrollbars[1]].visible and scbThick+2 or 4
		local canHold = mathFloor(size[1]-padding[1]*2-scbTakes1)
		local insertLine = 1
		local mapTable = {}
		for i=1,#textTable do
			local strongLine = textTable[i]
			local splitedText,splitedTextLine = dgsMemoWordSplit(strongLine[0],canHold,_,font,textSizeX,isWordWrap)
			strongLine[1] = dgsMemoInsertMapTable(mapTable,insertLine,splitedText,strongLine)
			insertLine = insertLine+splitedTextLine
		end
		dgsSetData(memo,"wordWrapMapText",mapTable)
	end
	return true
end

function dgsMemoRebuildTextTable(memo)
	local eleData = dgsElementData[memo]
	local textTable = eleData.text
	local textSize = eleData.textSize
	local font = eleData.font
	for i=1,#textTable do
		local text = textTable[i][0]
		textTable[i][-1] = dxGetTextWidth(text,textSize[1],font)
		if eleData.rightLength[1] < textTable[i][-1] then
			eleData.rightLength = {textTable[i][-1],i}
		end
	end
	configMemo(memo)
end


----------------------------------------------------------------
-----------------------PropertyListener-------------------------
----------------------------------------------------------------
function dgsMemoUpdateRTNextFrame(dgsEle)
	dgsElementData[dgsEle].updateRTNextFrame = true
end

dgsOnPropertyChange["dgs-dxmemo"] = {
	text = function(dgsEle,key,value,oldValue)
		return handleDxMemoText(dgsEle,value)
	end,
	scrollBarThick = configMemo,
	scrollBarState = configMemo,
	textSize = function(dgsEle,key,value,oldValue)
		dgsMemoRebuildTextTable(dgsEle)
		dgsElementData[dgsEle].updateRTNextFrame = true
	end,
	textColor = dgsMemoUpdateRTNextFrame,
	font = function(dgsEle,key,value,oldValue)
		--Multilingual
		if type(value) == "table" then
			dgsElementData[dgsEle]._translation_font = value
			value = dgsGetTranslationFont(dgsEle,value,sourceResource)
		else
			dgsElementData[dgsEle]._translation_font = nil
		end
		dgsElementData[dgsEle].font = value
		
		dgsMemoRebuildTextTable(dgsEle)
		dgsElementData[dgsEle].updateRTNextFrame = true
	end,
	wordWrap = function(dgsEle,key,value,oldValue)
		if value then
			dgsMemoRebuildWordWrapMapTable(dgsEle)
		end
		dgsElementData[dgsEle].updateRTNextFrame = true
	end,
	showPos = dgsMemoUpdateRTNextFrame,
	selectFrom = dgsMemoUpdateRTNextFrame,
	caretPos = dgsMemoUpdateRTNextFrame,
	padding = configMemo,
}

----------------------------------------------------------------
---------------------Translation Updater------------------------
----------------------------------------------------------------
dgsOnTranslationUpdate["dgs-dxmemo"] = function(dgsEle,key,value)
	local text = dgsElementData[dgsEle]._translation_placeHolderText
	if text then
		if key then text[key] = value end
		dgsSetData(dgsEle,"placeHolder",text)
	end
	local font = dgsElementData[dgsEle]._translation_placeHolderFont
	if font then
		dgsSetData(dgsEle,"placeHolderFont",font)
	end
	dgsElementData[dgsEle].updateRTNextFrame = true
end

----------------------------------------------------------------
-----------------------VisibilityManage-------------------------
----------------------------------------------------------------
dgsOnVisibilityChange["dgs-dxmemo"] = function(dgsElement,selfVisibility,inheritVisibility)
	if not selfVisibility or not inheritVisibility then
		dgsMemoRecreateRenderTarget(dgsElement,true)
	end
end
----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxmemo"] = function(source,x,y,w,h,mx,my,cx,cy,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt)
	local renderBuffer = eleData.renderBuffer
	if MouseData.hit == source and MouseData.focused == source then
		MouseData.topScrollable = source
	end
	if eleData.configNextFrame then
		configMemo(source)
	end
	if eleData.retrieveRT then
		dgsMemoRecreateRenderTarget(source)
		eleData.updateRTNextFrame = true
	end
	local bgColor = applyColorAlpha(eleData.bgColor,parentAlpha)
	local caretColor = applyColorAlpha(eleData.caretColor,parentAlpha)
	local isFocused = MouseData.focused == source
	if isFocused then
		if isConsoleActive() or isMainMenuActive() or isChatBoxInputActive() then
			MouseData.focused = false
		end
	end
	if isFocused ~= renderBuffer.isFocused then
		renderBuffer.isFocused = isFocused
		eleData.updateRTNextFrame = true
	end
	
	local shadow = eleData.shadow
	local text = eleData.text
	local caretPos = eleData.caretPos
	local selectFro = eleData.selectFrom
	local selectColor = applyColorAlpha(MouseData.focused == source and eleData.selectColor or eleData.selectColorBlur,parentAlpha)
	local res = eleData.resource or "global"
	local style = styleManager.styles[res]
	local using = style.using
	style = style.loaded[using]
	local systemFont = style.systemFontElement
	
	local font = eleData.font or systemFont
	local txtSizX,txtSizY = eleData.textSize[1],eleData.textSize[2]
	local fontHeight = dxGetFontHeight(txtSizY,font)
	local scbThick = eleData.scrollBarThick
	local scrollbars = eleData.scrollbars
	local selectVisible = eleData.selectVisible
	local padding = eleData.padding
	local sidelength,sideheight = padding[1]-padding[1]%1,padding[2]-padding[2]%1
	local px,py,pw,ph = x+sidelength,y+sideheight,w-sidelength*2,h-sideheight*2
	local textRenderBuffer = eleData.textRenderBuffer
	textRenderBuffer.count = 0
	local textColor = eleData.textColor
	
	local isPlaceHolderShown = (#text == 1 and text[1][0] == "") and placeHolder ~= "" and (MouseData.focused ~= source or eleData.placeHolderVisibleWhenFocus) 
	if renderBuffer.placeHolderState ~= isPlaceHolderShown then
		renderBuffer.placeHolderState = isPlaceHolderShown
		eleData.updateRTNextFrame = true
	end
	if renderBuffer.parentAlphaLast ~= parentAlpha then
		renderBuffer.parentAlphaLast = parentAlpha
		eleData.updateRTNextFrame = true
	end
	local placeHolder = eleData.placeHolder
	local placeHolderIgnoreRndTgt = eleData.placeHolderIgnoreRenderTarget
	local placeHolderOffset = eleData.placeHolderOffset

	if eleData.wordWrap then
		if eleData.rebuildMapTableNextFrame then
			dgsMemoRebuildWordWrapMapTable(source)
		end
		local allLines = #eleData.wordWrapMapText
		local wordWrapShowLine = eleData.wordWrapShowLine
		local caretHeight = eleData.caretHeight-1
		local canHoldLines = mathFloor((h-4)/fontHeight)
		canHoldLines = canHoldLines > allLines and allLines or canHoldLines
		local showPos = eleData.showPos
		local caretRltHeight = fontHeight*caretHeight
		local selPosStart,selPosEnd,selStart,selEnd
		if renderBuffer.parentAlphaLast ~= parentAlpha then
			renderBuffer.parentAlphaLast = parentAlpha
			eleData.updateRTNextFrame = true
		end
		if eleData.bgRT and (eleData.updateRTNextFrame or dgsRenderInfo.RTRestoreNeed) then
			dxSetRenderTarget(eleData.bgRT,true)
			if allLines > 0 then
				if selectFro[2] > caretPos[2] then
					selStart,selEnd = caretPos[2],selectFro[2]
					selPosStart,selPosEnd = caretPos[1],selectFro[1]
				elseif selectFro[2] < caretPos[2] then
					selStart,selEnd = selectFro[2],caretPos[2]
					selPosStart,selPosEnd = selectFro[1],caretPos[1]
				else
					selStart,selEnd = caretPos[2],selectFro[2]
					if selectFro[1] > caretPos[1] then
						selPosStart,selPosEnd = caretPos[1],selectFro[1]
					else
						selPosStart,selPosEnd = selectFro[1],caretPos[1]
					end
				end
				local lineCnt = 0
				local rndLine,rndPos,totalLine = eleData.wordWrapShowLine[1],eleData.wordWrapShowLine[2],eleData.wordWrapShowLine[3]
				if rndLine <= 1 then rndLine = 1 end
				local weakLinePos,nextWeakLineLen,yPos,renderingText
				for a=rndLine,#text do
					weakLinePos,nextWeakLineLen = 0,0
					for b=1,#text[a][1] do
						weakLineLen = text[a][1][b][3]
						if b >= rndPos then
							yPos = lineCnt*fontHeight
							renderingText = text[a][1][b][0]
							if selectVisible then
								if a == selStart or a == selEnd then
									if a == selStart and a == selEnd then
										if selPosStart >= weakLinePos then
											local startPosX = dxGetTextWidth(utf8Sub(renderingText,0,selPosStart-weakLinePos),txtSizX,font)
											local selectLen = dxGetTextWidth(utf8Sub(renderingText,selPosStart-weakLinePos+1,selPosEnd-weakLinePos),txtSizX,font)
											dxDrawRectangle(-showPos+startPosX,yPos-caretRltHeight,selectLen,caretRltHeight+fontHeight,selectColor)
										elseif selPosStart < weakLinePos and selPosEnd > weakLinePos+weakLineLen then
											local startPosX = dxGetTextWidth(renderingText,txtSizX,font)
											dxDrawRectangle(-showPos,yPos-caretRltHeight,startPosX,caretRltHeight+fontHeight,selectColor)
										elseif selPosEnd >= weakLinePos and selPosEnd <= weakLinePos+weakLineLen then
											local selectLen = dxGetTextWidth(utf8Sub(renderingText,0,selPosEnd-weakLinePos),txtSizX,font)
											dxDrawRectangle(-showPos,yPos-caretRltHeight,selectLen,caretRltHeight+fontHeight,selectColor)
										end
									elseif a == selStart then
										if selPosStart >= weakLinePos and selPosStart <= weakLinePos+weakLineLen then
											local startPosX = dxGetTextWidth(utf8Sub(renderingText,0,selPosStart-weakLinePos),txtSizX,font)
											local selectLen = dxGetTextWidth(utf8Sub(renderingText,selPosStart-weakLinePos+1),txtSizX,font)
											dxDrawRectangle(-showPos+startPosX,yPos-caretRltHeight,selectLen,caretRltHeight+fontHeight,selectColor)
										elseif selPosStart <= weakLinePos then
											dxDrawRectangle(-showPos,yPos-caretRltHeight,dxGetTextWidth(renderingText,txtSizX,font),caretRltHeight+fontHeight,selectColor)
										end
									elseif a == selEnd then
										if selPosEnd >= weakLinePos and selPosEnd <= weakLinePos+weakLineLen then
											local selectLen = dxGetTextWidth(utf8Sub(renderingText,0,selPosEnd-weakLinePos),txtSizX,font)
											dxDrawRectangle(-showPos,yPos-caretRltHeight,selectLen,caretRltHeight+fontHeight,selectColor)
										elseif selPosEnd >= weakLinePos then
											dxDrawRectangle(-showPos,yPos-caretRltHeight,dxGetTextWidth(renderingText,txtSizX,font),caretRltHeight+fontHeight,selectColor)
										end
									end
								elseif a > selStart and a < selEnd then
									dxDrawRectangle(-showPos,yPos-caretRltHeight,dxGetTextWidth(renderingText,txtSizX,font),caretRltHeight+fontHeight,selectColor)
								end
							end
							if caretPos[2] == a then
								if caretPos[1] >= weakLinePos and caretPos[1] <= weakLinePos+weakLineLen then
									local indexInWeakLine = caretPos[1]-weakLinePos
									renderBuffer.caretDrawPos = {px-showPos-2,py+yPos,utf8Sub(renderingText,1,indexInWeakLine),utf8Sub(renderingText,indexInWeakLine+1,indexInWeakLine+1)}
								end
							end
							textRenderBuffer.count = textRenderBuffer.count+1
							if not textRenderBuffer[textRenderBuffer.count] then textRenderBuffer[textRenderBuffer.count] = {} end
							textRenderBuffer[textRenderBuffer.count][1] = renderingText
							textRenderBuffer[textRenderBuffer.count][2] = -showPos
							textRenderBuffer[textRenderBuffer.count][3] = yPos
							textRenderBuffer[textRenderBuffer.count][4] = -showPos
							textRenderBuffer[textRenderBuffer.count][5] = fontHeight+yPos
							textRenderBuffer[textRenderBuffer.count][6] = applyColorAlpha(textColor,parentAlpha)
							textRenderBuffer[textRenderBuffer.count][7] = txtSizX
							textRenderBuffer[textRenderBuffer.count][8] = txtSizY
							textRenderBuffer[textRenderBuffer.count][9] = font
							rndPos = 1
							lineCnt = lineCnt + 1
						end
						weakLinePos = weakLinePos+weakLineLen
						if lineCnt > canHoldLines then break end
					end
					if lineCnt > canHoldLines then break end
				end
			end
			
			eleData.updateRTNextFrame = nil
			dxSetBlendMode("modulate_add")
			
			if not placeHolderIgnoreRndTgt then
				if isPlaceHolderShown then
					local pColor = applyColorAlpha(eleData.placeHolderColor,parentAlpha)
					local pFont = eleData.placeHolderFont
					local pColorCoded = eleData.placeHolderColorCoded
					local pHolderTextSizeX,pHolderTextSizeY
					local placeHolderTextSize = eleData.placeHolderTextSize
					if placeHolderTextSize then
						pHolderTextSizeX,pHolderTextSizeY = placeHolderTextSize[1],placeHolderTextSize[2]
					else
						pHolderTextSizeX,pHolderTextSizeY = txtSizX,txtSizY
					end
					dgsDrawText(placeHolder,0+placeHolderOffset[1],0+placeHolderOffset[2],pw+placeHolderOffset[1],fontHeight+placeHolderOffset[2],pColor,pHolderTextSizeX,pHolderTextSizeY,pFont,"left","top",false,false,false,pColorcoded)
				end
			end
			
			local tRB
			local shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont
			if shadow then
				shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont = shadow[1],shadow[2],shadow[3],shadow[4],shadow[5]
				shadowColor = applyColorAlpha(shadowColor or white,parentAlpha)
			end
			for i=1,textRenderBuffer.count do
				tRB = textRenderBuffer[i]
				dgsDrawText(tRB[1],tRB[2],tRB[3],tRB[4],tRB[5],tRB[6],tRB[7],tRB[8],tRB[9],"left","top",false,false,false,false,subPixelPos,0,0,0,0,shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont)
			end
		end
		dxSetRenderTarget(rndtgt)
		dxSetBlendMode(rndtgt and "modulate_add" or "blend")
		local finalcolor = bgColor
		if not enabledInherited and not enabledSelf then
			if type(eleData.disabledColor) == "number" then
				finalcolor = eleData.disabledColor
			elseif eleData.disabledColor == true then
				local r,g,b,a = fromcolor(bgColor)
				local average = (r+g+b)/3*eleData.disabledColorPercent
				finalcolor = tocolor(average,average,average,a)
			end
		end
		dxDrawImage(x,y,w,h,eleData.bgImage,0,0,0,finalcolor,isPostGUI,rndtgt)
		dxSetBlendMode(rndtgt and "modulate_add" or "add")

		local scbTakes1,scbTakes2 = dgsElementData[scrollbars[1]].visible and scbThick or 0,dgsElementData[scrollbars[2]].visible and scbThick or 0
		if eleData.bgRT then
			__dxDrawImageSection(px,py,pw-scbTakes1,ph-scbTakes2,0,0,pw-scbTakes1,ph-scbTakes2,eleData.bgRT,0,0,0,white,isPostGUI)
		end
		if placeHolderIgnoreRndTgt then
			if isPlaceHolderShown then
				local pColor = applyColorAlpha(eleData.placeHolderColor,parentAlpha)
				local pFont = eleData.placeHolderFont
				local pColorCoded = eleData.placeHolderColorCoded
				local pHolderTextSizeX,pHolderTextSizeY
				local placeHolderTextSize = eleData.placeHolderTextSize
				if placeHolderTextSize then
					pHolderTextSizeX,pHolderTextSizeY = placeHolderTextSize[1],placeHolderTextSize[2]
				else
					pHolderTextSizeX,pHolderTextSizeY = txtSizX,txtSizY
				end
				dgsDrawText(placeHolder,px+placeHolderOffset[1],py+placeHolderOffset[2],px+pw+placeHolderOffset[1],py+fontHeight+placeHolderOffset[2],pColor,pHolderTextSizeX,pHolderTextSizeY,pFont,"left","top",false,false,false,pColorcoded)
			end
		end

		dxSetBlendMode(rndtgt and "modulate_add" or "blend")
		
		if MouseData.focused == source and MouseData.EditMemoCursor then
			local CaretShow = true
			if eleData.readOnly then
				CaretShow = eleData.readOnlyCaretShow
			end
			local caretDrawPos = renderBuffer.caretDrawPos
			if CaretShow and caretDrawPos then
				local caretStyle = eleData.caretStyle
				local caretRenderX = caretDrawPos[1]+dxGetTextWidth(caretDrawPos[3],txtSizX,font)+1
				if caretStyle == 0 then
					local caretOffset = eleData.caretOffset
					dxDrawLine(caretRenderX,caretDrawPos[2]-caretOffset,caretRenderX,caretDrawPos[2]+fontHeight*(1-caretHeight)-caretOffset,caretColor,eleData.caretThick,isPostGUI)
				elseif caretStyle == 1 then
					local cursorWidth = dxGetTextWidth(caretDrawPos[4],txtSizX,font)
					if cursorWidth == 0 then
						cursorWidth = txtSizX*8
					end
					local caretOffset = eleData.caretOffset
					local caretRenderY = caretDrawPos[2]+fontHeight*(1-caretHeight)*0.85-caretOffset-2
					dxDrawLine(caretRenderX,caretRenderY,caretRenderX+cursorWidth,caretRenderY,caretColor,eleData.caretThick,isPostGUI)
				end
			end
		end
	else
		local allLine = #text
		local showLine = eleData.showLine
		local caretHeight = eleData.caretHeight-1
		local canHoldLines = mathFloor((h-4)/fontHeight)
		canHoldLines = canHoldLines > allLine and allLine or canHoldLines
		local selPosStart,selPosEnd,selStart,selEnd
		local showPos = eleData.showPos
		if renderBuffer.parentAlphaLast ~= parentAlpha then
			renderBuffer.parentAlphaLast = parentAlpha
			eleData.updateRTNextFrame = true
		end
		if eleData.bgRT and (eleData.updateRTNextFrame or dgsRenderInfo.RTRestoreNeed) then
			dxSetRenderTarget(eleData.bgRT,true)
			if allLine > 0 then
				local toShowLine = showLine+canHoldLines
				toShowLine = toShowLine > allLine and allLine or toShowLine
				if selectFro[2] > caretPos[2] then
					selStart,selEnd = caretPos[2],selectFro[2]
					selPosStart,selPosEnd = caretPos[1],selectFro[1]
				elseif selectFro[2] < caretPos[2] then
					selStart,selEnd = selectFro[2],caretPos[2]
					selPosStart,selPosEnd = selectFro[1],caretPos[1]
				else
					selStart,selEnd = caretPos[2],selectFro[2]
					if selectFro[1] > caretPos[1] then
						selPosStart,selPosEnd = caretPos[1],selectFro[1]
					else
						selPosStart,selPosEnd = selectFro[1],caretPos[1]
					end
				end
				local caretRltHeight = fontHeight*caretHeight
				local yPos
				for i=showLine,toShowLine do
					yPos = (i-showLine)*fontHeight
					if selectVisible then
						if i == selStart or i == selEnd then
							if i == selStart and i == selEnd then
								local startPosX = dxGetTextWidth(utf8Sub(text[i][0],0,selPosStart),txtSizX,font)
								local selectLen = dxGetTextWidth(utf8Sub(text[i][0],selPosStart+1,selPosEnd),txtSizX,font)
								dxDrawRectangle(-showPos+startPosX,yPos-caretRltHeight,selectLen,caretRltHeight+fontHeight,selectColor)
							elseif i == selStart then
								local startPosX = dxGetTextWidth(utf8Sub(text[i][0],0,selPosStart),txtSizX,font)
								local selectLen = dxGetTextWidth(utf8Sub(text[i][0],selPosStart+1),txtSizX,font)
								dxDrawRectangle(-showPos+startPosX,yPos-caretRltHeight,selectLen,caretRltHeight+fontHeight,selectColor)
							elseif i == selEnd then
								local selectLen = dxGetTextWidth(utf8Sub(text[i][0],0,selPosEnd),txtSizX,font)
								dxDrawRectangle(-showPos,yPos-caretRltHeight,selectLen,caretRltHeight+fontHeight,selectColor)
							end
						elseif i > selStart and i < selEnd then
							dxDrawRectangle(-showPos,yPos-caretRltHeight,text[i][-1],caretRltHeight+fontHeight,selectColor)
						end
					end
					textRenderBuffer.count = textRenderBuffer.count+1
					if not textRenderBuffer[textRenderBuffer.count] then textRenderBuffer[textRenderBuffer.count] = {} end
					textRenderBuffer[textRenderBuffer.count][1] = text[i][0]
					textRenderBuffer[textRenderBuffer.count][2] = -showPos
					textRenderBuffer[textRenderBuffer.count][3] = yPos
					textRenderBuffer[textRenderBuffer.count][4] = -showPos
					textRenderBuffer[textRenderBuffer.count][5] = fontHeight+yPos
					textRenderBuffer[textRenderBuffer.count][6] = applyColorAlpha(textColor,parentAlpha)
					textRenderBuffer[textRenderBuffer.count][7] = txtSizX
					textRenderBuffer[textRenderBuffer.count][8] = txtSizY
					textRenderBuffer[textRenderBuffer.count][9] = font
				end
			end
			
			eleData.updateRTNextFrame = nil
			dxSetBlendMode("modulate_add")
			
			if not placeHolderIgnoreRndTgt then
				if isPlaceHolderShown then
					local pColor = applyColorAlpha(eleData.placeHolderColor,parentAlpha)
					local pFont = eleData.placeHolderFont
					local pColorCoded = eleData.placeHolderColorCoded
					local pHolderTextSizeX,pHolderTextSizeY
					local placeHolderTextSize = eleData.placeHolderTextSize
					if placeHolderTextSize then
						pHolderTextSizeX,pHolderTextSizeY = placeHolderTextSize[1],placeHolderTextSize[2]
					else
						pHolderTextSizeX,pHolderTextSizeY = txtSizX,txtSizY
					end
					dgsDrawText(placeHolder,0+placeHolderOffset[1],0+placeHolderOffset[2],pw+placeHolderOffset[1],fontHeight+placeHolderOffset[2],pColor,pHolderTextSizeX,pHolderTextSizeY,pFont,"left","top",false,false,false,pColorcoded)
				end
			end
			
			local tRB
			local shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont
			if shadow then
				shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont = shadow[1],shadow[2],shadow[3],shadow[4],shadow[5]
				shadowColor = applyColorAlpha(shadowColor or white,parentAlpha)
			end
			for i=1,textRenderBuffer.count do
				tRB = textRenderBuffer[i]
				dgsDrawText(tRB[1],tRB[2],tRB[3],tRB[4],tRB[5],tRB[6],tRB[7],tRB[8],tRB[9],"left","top",false,false,false,false,subPixelPos,0,0,0,0,shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont)
			end
		end
		dxSetRenderTarget(rndtgt)
		
		dxSetBlendMode(rndtgt and "modulate_add" or "blend")
		local finalcolor = bgColor
		if not enabledInherited and not enabledSelf then
			if type(eleData.disabledColor) == "number" then
				finalcolor = eleData.disabledColor
			elseif eleData.disabledColor == true then
				local r,g,b,a = fromcolor(bgColor)
				local average = (r+g+b)/3*eleData.disabledColorPercent
				finalcolor = tocolor(average,average,average,a)
			end
		end
		dxDrawImage(x,y,w,h,eleData.bgImage,0,0,0,finalcolor,isPostGUI,rndtgt)
		
		dxSetBlendMode(rndtgt and "modulate_add" or "add")
		local scbTakes1,scbTakes2 = dgsElementData[scrollbars[1]].visible and scbThick or 0,dgsElementData[scrollbars[2]].visible and scbThick or 0
		if eleData.bgRT then
			__dxDrawImageSection(px,py,pw-scbTakes1,ph-scbTakes2,0,0,pw-scbTakes1,ph-scbTakes2,eleData.bgRT,0,0,0,white,isPostGUI)
		end

		if placeHolderIgnoreRndTgt then
			if isPlaceHolderShown then
				local pColor = applyColorAlpha(eleData.placeHolderColor,parentAlpha)
				local pFont = eleData.placeHolderFont
				local pColorCoded = eleData.placeHolderColorCoded
				local pHolderTextSizeX,pHolderTextSizeY
				local placeHolderTextSize = eleData.placeHolderTextSize
				if placeHolderTextSize then
					pHolderTextSizeX,pHolderTextSizeY = placeHolderTextSize[1],placeHolderTextSize[2]
				else
					pHolderTextSizeX,pHolderTextSizeY = txtSizX,txtSizY
				end
				dgsDrawText(placeHolder,px+placeHolderOffset[1],py+placeHolderOffset[2],px+pw+placeHolderOffset[1],py+fontHeight+placeHolderOffset[2],pColor,pHolderTextSizeX,pHolderTextSizeY,pFont,"left","top",false,false,false,pColorcoded)
			end
		end
		
		dxSetBlendMode(rndtgt and "modulate_add" or "blend")
		if MouseData.focused == source and MouseData.EditMemoCursor then
			local CaretShow = true
			if eleData.readOnly then
				CaretShow = eleData.readOnlyCaretShow
			end
			if CaretShow then
				local showLine = eleData.showLine
				local currentLine = eleData.caretPos[2]
				if currentLine >= showLine and currentLine <= showLine+canHoldLines then
					local lineStart = fontHeight*(currentLine-showLine)
					local theText = (text[caretPos[2]] or {[0]=""})[0]
					local cursorPX = caretPos[1]
					local width = dxGetTextWidth(utf8Sub(theText,1,cursorPX),txtSizX,font)
					if eleData.caretStyle == 0 then
						local selStartY = py+lineStart+fontHeight*(1-caretHeight)
						local selEndY = py+lineStart+fontHeight*caretHeight
						local caretOffset = eleData.caretOffset
						dxDrawLine(px+width-showPos-1,selStartY-caretOffset,px+width-showPos-1,selEndY-caretOffset,caretColor,eleData.caretThick,isPostGUI)
					elseif eleData.caretStyle == 1 then
						local cursorWidth = dxGetTextWidth(utf8Sub(theText,cursorPX+1,cursorPX+1),txtSizX,font)
						cursorWidth = cursorWidth ~= 0 and cursorWidth or txtSizX*8
						local caretOffset = eleData.caretOffset
						dxDrawLine(px+width-showPos,py+ph-4-caretOffset,px+width-showPos+cursorWidth+2,py+ph-4-caretOffset,caretColor,eleData.caretThick,isPostGUI)
					end
				end
			end
		end
	end
	return rndtgt,false,mx,my,0,0
end