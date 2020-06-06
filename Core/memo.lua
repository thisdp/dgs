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
--
----Speed UP
local mathFloor = math.floor
local tableInsert = table.insert
local tableRemove = table.remove
local utf8Sub = utf8.sub
local utf8Gsub = utf8.gsub
local utf8Len = utf8.len
local utf8Insert = utf8.insert
local utf8Byte = utf8.byte
local _dxGetTextWidth = dxGetTextWidth
GlobalMemoParent = guiCreateLabel(-1,0,0,0,"",true)
GlobalMemo = guiCreateMemo(-1,0,0,0,"",true,GlobalMemoParent)
dgsSetData(GlobalMemo,"linkedDxMemo",nil)
--[[
---------------In Normal Mode------------------
	Text Table Structure:
			Text Width(Int),	Original Text(Str)
		{
			{[-1] = text Width,	[0] = text},
			{[-1] = text Width,	[0] = text},
			{[-1] = text Width,	[0] = text},
			...
		}
--------------In Word Wrap Mode----------------
	Text Table Structure:
			Text Width(Int),	Text(Str),	Map Tables For Weak Line(Table),	
		{
			{[-1] = text Width,	[0] = text,	[1] = { table1, table2, table3, ... }},	--String Line 1
			{[-1] = text Width,	[0] = text,	[1] = { table1, table2, table3, ... }},	--String Line 2
			{[-1] = text Width,	[0] = text,	[1] = { table1, table2, table3, ... }},	--String Line 3
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
function dgsCreateMemo(x,y,sx,sy,text,relative,parent,textColor,scalex,scaley,bgImage,bgColor)
	assert(type(x) == "number","Bad argument @dgsCreateMemo at argument 1, expect number got "..type(x))
	assert(type(y) == "number","Bad argument @dgsCreateMemo at argument 2, expect number got "..type(y))
	assert(type(sx) == "number","Bad argument @dgsCreateMemo at argument 3, expect number got "..type(sx))
	assert(type(sy) == "number","Bad argument @dgsCreateMemo at argument 4, expect number got "..type(sy))
	text = tostring(text)
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"Bad argument @dgsCreateMemo at argument 7, expect dgs-memo got "..dgsGetType(parent))
	end
	local memo = createElement("dgs-dxmemo")
	local _ = dgsIsDxElement(parent) and dgsSetParent(memo,parent,true,true) or tableInsert(CenterFatherTable,memo)
	dgsSetType(memo,"dgs-dxmemo")
	dgsSetData(memo,"renderBuffer",{})
	dgsSetData(memo,"bgColor",bgColor or styleSettings.memo.bgColor)
	dgsSetData(memo,"bgImage",bgImage or dgsCreateTextureFromStyle(styleSettings.memo.bgImage))
	dgsSetData(memo,"bgColorBlur",styleSettings.memo.bgColorBlur)
	dgsSetData(memo,"bgImageBlur",dgsCreateTextureFromStyle(styleSettings.memo.bgImageBlur))
	dgsSetData(memo,"font",styleSettings.memo.font or systemFont,true)
	dgsElementData[memo].text = {}
	dgsSetData(memo,"wordWrap",false,true)	--false:Normal Mode; 1:Word Wrap by character; 2:Word Wrap by word;
	dgsSetData(memo,"wordWrapShowLine",{1,1,1})
	dgsSetData(memo,"wordWrapMapText",{})
	dgsSetData(memo,"textColor",textColor or styleSettings.memo.textColor)
	local textSizeX,textSizeY = tonumber(scalex) or styleSettings.memo.textSize[1], tonumber(scaley) or styleSettings.memo.textSize[2]
	dgsSetData(memo,"textSize",{textSizeX,textSizeY},true)
	dgsSetData(memo,"caretPos",{0,1})
	dgsSetData(memo,"selectFrom",{0,1})
	--dgsSetData(memo,"insertMode",false)
	dgsSetData(memo,"rightLength",{0,1})
	dgsSetData(memo,"scrollSize",3)	-- Lines
	dgsSetData(memo,"showPos",0)
	dgsSetData(memo,"showLine",1)
	dgsSetData(memo,"caretStyle",styleSettings.memo.caretStyle)
	dgsSetData(memo,"caretThick",styleSettings.memo.caretThick)
	dgsSetData(memo,"caretOffset",styleSettings.memo.caretOffset)
	dgsSetData(memo,"caretColor",styleSettings.memo.caretColor)
	dgsSetData(memo,"caretHeight",styleSettings.memo.caretHeight)
	dgsSetData(memo,"scrollBarThick",styleSettings.memo.scrollBarThick,true)
	dgsSetData(memo,"allowCopy",true)
	dgsSetData(memo,"readOnly",false)
	dgsSetData(memo,"readOnlyCaretShow",false)
	dgsSetData(memo,"scrollBarState",{nil,nil},true)
	dgsSetData(memo,"historyMaxRecords",100)
	dgsSetData(memo,"enableRedoUndoRecord",true)
	dgsSetData(memo,"undoHistory",{})
	dgsSetData(memo,"redoHistory",{})
	dgsSetData(memo,"padding",styleSettings.memo.padding)
	dgsSetData(memo,"typingSound",styleSettings.memo.typingSound)
	dgsSetData(memo,"selectColor",styleSettings.memo.selectColor)
	dgsSetData(memo,"selectColorBlur",styleSettings.memo.selectColorBlur)
	dgsSetData(memo,"selectVisible",styleSettings.memo.selectVisible)
	dgsSetData(memo,"configNextFrame",false)
	dgsSetData(memo,"rebuildMapTableNextFrame",false)
	dgsSetData(memo,"maxLength",0x3FFFFFFF)
	dgsSetData(memo,"scrollBarLength",{},true)
	calculateGuiPositionSize(memo,x,y,relative or false,sx,sy,relative or false,true)
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
	addEventHandler("onDgsElementScroll",scrollbar1,checkMMScrollBar,false)
	addEventHandler("onDgsElementScroll",scrollbar2,checkMMScrollBar,false)
	local padding = dgsElementData[memo].padding
	local sizex,sizey = abx-padding[1]*2,abx-padding[2]*2
	sizex,sizey = sizex-sizex%1,sizey-sizey%1
	local renderTarget,err = dxCreateRenderTarget(sizex,sizey,true,memo)
	if renderTarget ~= false then
		dgsAttachToAutoDestroy(renderTarget,memo,-1)
	else
		outputDebugString(err)
	end
	dgsSetData(memo,"renderTarget",renderTarget)
	dgsSetData(memo,"scrollbars",{scrollbar1,scrollbar2})
	handleDxMemoText(memo,text,false,true)
	triggerEvent("onDgsCreate",memo,sourceResource)
	return memo
end

function dgsMemoGetLineCount(memo,forceStrongLine)
	assert(dgsGetType(memo) == "dgs-dxmemo","Bad argument @dgsMemoGetLineCount at argument 1, expect dgs-dxmemo got "..dgsGetType(memo))
	if not forceStrongLine and dgsElementData[memo].wordWrap then
		return #dgsElementData[memo].wordWrapMapText
	end
	return #dgsElementData[memo].text
end

function dgsMemoGetScrollBar(memo)
	assert(dgsGetType(memo) == "dgs-dxmemo","Bad argument @dgsMemoGetScrollBar at argument 1, expect dgs-dxmemo got "..dgsGetType(memo))
	return dgsElementData[memo].scrollbars
end

function dgsMemoMoveCaret(memo,indexOffset,lineOffset,noselect,noMoveLine)
	assert(dgsGetType(memo) == "dgs-dxmemo","Bad argument @dgsMemoMoveCaret at argument 1, expect dgs-dxmemo got "..dgsGetType(memo))
	assert(type(indexOffset) == "number","Bad argument @dgsMemoMoveCaret at argument 2, expect number got "..type(indexOffset))
	lineOffset = lineOffset or 0
	local index = dgsElementData[memo].caretPos[1]
	local line = dgsElementData[memo].caretPos[2]
	local font = dgsElementData[memo].font
	local size = dgsElementData[memo].absSize
	local padding = dgsElementData[memo].padding
	local fontHeight = dxGetFontHeight(dgsElementData[memo].textSize[2],font)
	local scbThick = dgsElementData[memo].scrollBarThick
	local scrollbars = dgsElementData[memo].scrollbars
	local scbTakes = {dgsElementData[scrollbars[1]].visible and scbThick or 0,dgsElementData[scrollbars[2]].visible and scbThick or 0}
	local canHold = mathFloor((size[2]-scbTakes[2]-padding[2]*2)/fontHeight)
	local textTable = dgsElementData[memo].text
	local isWordWrap = dgsElementData[memo].wordWrap
	if isWordWrap then
		local wordWrapShowLine = dgsElementData[memo].wordWrapShowLine
		local mapTable = dgsElementData[memo].wordWrapMapText
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
		if dgsElementData[memo].readOnly then
			isReadOnlyShow = dgsElementData[memo].readOnlyCaretShow
		end
		if not noselect or not isReadOnlyShow then
			dgsSetData(memo,"selectFrom",{newIndex,newLine})
		end
	else
		local text = (textTable[line] or {[0]=""})[0]
		local pos,line = dgsMemoSeekPosition(textTable,index+mathFloor(indexOffset),line+mathFloor(lineOffset),noMoveLine)
		local showLine = dgsElementData[memo].showLine
		local targetLine = line-showLine
		local showPos = dgsElementData[memo].showPos
		local nowLen = _dxGetTextWidth(utf8Sub(text,0,pos),dgsElementData[memo].textSize[1],font)
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
		if dgsElementData[memo].readOnly then
			isReadOnlyShow = dgsElementData[memo].readOnlyCaretShow
		end
		if not noselect or not isReadOnlyShow then
			dgsSetData(memo,"selectFrom",{pos,line})
		end
	end
	resetTimer(MouseData.EditMemoTimer)
	MouseData.editMemoCursor = true
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
	assert(dgsGetType(memo) == "dgs-dxmemo","Bad argument @dgsMemoSetCaretPosition at argument 1, expect dgs-dxmemo got "..dgsGetType(memo))
	assert(type(tpos) == "number","Bad argument @dgsMemoSetCaretPosition at argument 2, expect number got "..type(tpos))
	local textTable = dgsElementData[memo].text
	local curpos = dgsElementData[memo].caretPos
	tline = tline or curpos[2]
	local text = (textTable[tline] or {[-1]=0,[0]=""})[0]
	local index,line
	local isWordWrap = dgsElementData[memo].wordWrap
	local showLine = dgsElementData[memo].showLine
	local font = dgsElementData[memo].font
	local fontHeight = dxGetFontHeight(dgsElementData[memo].textSize[2],font)
	local padding = dgsElementData[memo].padding
	local size = dgsElementData[memo].absSize
	local scbThick = dgsElementData[memo].scrollBarThick
	local scrollbars = dgsElementData[memo].scrollbars
	local scbTakes = {dgsElementData[scrollbars[1]].visible and scbThick or 0,dgsElementData[scrollbars[2]].visible and scbThick or 0}
	local canHold = mathFloor((size[2]-padding[2]*2-scbTakes[2])/fontHeight)
	if isWordWrap then
		if noSeekPosition then
			index = math.restrict(tpos,0,utf8Len(text))
			line = tline
		else
			index,line = dgsMemoSeekPosition(textTable,tpos,tline)
		end
		local wordWrapShowLine = dgsElementData[memo].wordWrapShowLine
		local mapTable = dgsElementData[memo].wordWrapMapText
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
			index = math.restrict(tpos,0,utf8Len(text))
			line = tline
		else
			index,line = dgsMemoSeekPosition(textTable,tpos,tline)
		end
		local showPos = dgsElementData[memo].showPos
		local nowLen = _dxGetTextWidth(utf8Sub(text,0,index),dgsElementData[memo].textSize[1],font)
		local targetLen = nowLen-showPos
		if targetLen > size[1]-padding[1]*2-scbTakes[1] then
			dgsSetData(memo,"showPos",-(size[1]-padding[1]*2-scbTakes[1]-nowLen))
			syncScrollBars(memo,2)
		elseif targetLen < 0 then
			dgsSetData(memo,"showPos",nowLen)
			syncScrollBars(memo,2)
		end
		local targetLine = tline-showLine+1
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
	MouseData.editMemoCursor = true
	return true
end

function dgsMemoGetLineLength(memo,line)
	assert(dgsGetType(memo) == "dgs-dxmemo","Bad argument @dgsMemoGetCaretPosition at argument 1, expect dgs-dxmemo got "..dgsGetType(memo))
	local textTable = dgsElementData[memo].text
	return textTable[line] and textTable[line][-1] or false
end

function dgsMemoGetCaretPosition(memo,detail)
	assert(dgsGetType(memo) == "dgs-dxmemo","Bad argument @dgsMemoGetCaretPosition at argument 1, expect dgs-dxmemo got "..dgsGetType(memo))
	return dgsElementData[memo].caretPos[1],dgsElementData[memo].caretPos[2]
end

function dgsMemoSetCaretStyle(memo,style)
	assert(dgsGetType(memo) == "dgs-dxmemo","Bad argument @dgsMemoSetCaretStyle at argument 1, expect dgs-dxmemo got "..dgsGetType(memo))
	assert(type(style) == "number","Bad argument @dgsMemoSetCaretStyle at argument 2, expect number got "..type(style))
	return dgsSetData(memo,"cursorStyle",style)
end

function dgsMemoGetCaretStyle(memo,style)
	assert(dgsGetType(memo) == "dgs-dxmemo","Bad argument @dgsMemoGetCaretStyle at argument 1, expect dgs-dxmemo got "..dgsGetType(memo))
	return dgsElementData[memo].cursorStyle
end

function dgsMemoSetReadOnly(memo,state)
	assert(dgsGetType(memo) == "dgs-dxmemo","Bad argument @dgsMemoSetReadOnly at argument 1, expect dgs-dxmemo got "..dgsGetType(memo))
	return dgsSetData(memo,"readOnly",state and true or false)
end

function dgsMemoGetReadOnly(memo)
	assert(dgsGetType(memo) == "dgs-dxmemo","Bad argument @dgsMemoGetReadOnly at argument 1, expect dgs-dxmemo got "..dgsGetType(memo))
	return dgsGetData(memo,"readOnly")
end

function resetMemo(x,y)
	if dgsGetType(MouseData.nowShow) == "dgs-dxmemo" then
		if MouseData.nowShow == MouseData.clickl then
			local pos,line = searchMemoMousePosition(MouseData.nowShow,MouseX or x*sW, MouseY or y*sH)
			dgsMemoSetCaretPosition(MouseData.nowShow,pos,line,true)
		end
	end
end
addEventHandler("onClientCursorMove",root,resetMemo)

function searchMemoMousePosition(dxmemo,posx,posy)
	local font = dgsElementData[dxmemo].font or systemFont
	local txtSizX = dgsElementData[dxmemo].textSize[1]
	local padding = dgsElementData[dxmemo].padding
	local fontHeight = dxGetFontHeight(dgsElementData[dxmemo].textSize[2],font)
	local showPos = dgsElementData[dxmemo].showPos
	local isWordWrap = dgsElementData[dxmemo].wordWrap
	local showLine = isWordWrap and dgsElementData[dxmemo].wordWrapShowLine[3] or dgsElementData[dxmemo].showLine
	local x,y = dgsGetPosition(dxmemo,false,true)
	local originalText = dgsElementData[dxmemo].text
	local allText = isWordWrap and dgsElementData[dxmemo].wordWrapMapText or originalText
	local selLine = mathFloor((posy-y-padding[1])/fontHeight)+showLine
	selLine = selLine > #allText and #allText or selLine 
	local text = (allText[selLine] or {[0]=""})[0]
	local pos = posx-x-padding[1]+showPos
	local sfrom,sto,templen = 0,utf8Len(text),0
	for i=1,sto do
		stoSfrom_Half = (sto+sfrom)*0.5
		local stoSfrom_Half = stoSfrom_Half-stoSfrom_Half%1
		local strlen = _dxGetTextWidth(utf8Sub(text,sfrom+1,stoSfrom_Half),txtSizX,font)
		local len1 = strlen+templen
		if pos < len1 then
			sto = stoSfrom_Half
		elseif pos > len1 then
			sfrom = stoSfrom_Half
			templen = _dxGetTextWidth(utf8Sub(text,0,sfrom),txtSizX,font)
			start = len1
		elseif pos == len1 then
			start = len1
			sfrom = stoSfrom_Half
			sto = sfrom
			templen = _dxGetTextWidth(utf8Sub(text,0,sfrom),txtSizX,font)
		end
		if sto-sfrom <= 10 then break end
	end
	local start = _dxGetTextWidth(utf8Sub(text,0,sfrom),txtSizX,font)
	local resultIndex,resultLine = 0,1
	for i=sfrom,sto do
		local poslen1 = _dxGetTextWidth(utf8Sub(text,sfrom+1,i),txtSizX,font)+start
		local theNext = _dxGetTextWidth(utf8Sub(text,i+1,i+1),txtSizX,font)*0.5
		local offsetR = theNext+poslen1
		local theLast = _dxGetTextWidth(utf8Sub(text,i,i),txtSizX,font)*0.5
		local offsetL = poslen1-theLast
		if i <= sfrom and pos <= offsetL then
			resultIndex,resultLine = sfrom,selLine
			break
		elseif i >= sto and pos >= offsetR then
			resultIndex,resultLine = sto,selLine
			break
		elseif pos >= offsetL and pos <= offsetR then
			resultIndex,resultLine = i,selLine
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
	return resultIndex,resultLine
end

function searchTextFromPosition(text,font,textSizeX,pos)
	local sfrom,sto = 0,utf8Len(text)
	local templen = 0
	for i=1,sto do
		local stoSfrom_Half = (sto+sfrom)*0.5
		local stoSfrom_Half = stoSfrom_Half-stoSfrom_Half%1
		local strlen = _dxGetTextWidth(utf8Sub(text,sfrom+1,stoSfrom_Half),textSizeX,font)
		local len1 = strlen+templen
		if pos < len1 then
			sto = stoSfrom_Half
		elseif pos > len1 then
			sfrom = stoSfrom_Half
			templen = _dxGetTextWidth(utf8Sub(text,1,sfrom),textSizeX,font)
			start = len1
		elseif pos == len1 then
			start = len1
			sfrom = stoSfrom_Half-1
			sto = sfrom
			templen = _dxGetTextWidth(utf8Sub(text,1,sfrom),textSizeX,font)	
		end
		if sto-sfrom <= 10 then
			break
		end
	end
	local start = _dxGetTextWidth(utf8Sub(text,1,sfrom),textSizeX,font)
	for i=sfrom,sto do
		local Current = _dxGetTextWidth(utf8Sub(text,i+1,i+1),textSizeX,font)
		if start+Current >= pos then
			return i
		end
		start = start+Current
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
	local font = font or systemFont
	local textSizeX = textSizeX or 1
	local textWidth = textWidth or _dxGetTextWidth(text,textSizeX,font)
	if maxWidth > textWidth then
		return {text},1
	end
	local cnt = 1
	if isSplitByWord == 2 then
		while(text ~= "") do
			local breakPoint = false
			local tick = getTickCount()
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
			local tick = getTickCount()
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
	local textTable = dgsElementData[memo].text or {}
	if not noclear then
		dgsElementData[memo].text = {{[-1]=0,[0]="",[1]={}}}
		textTable = dgsElementData[memo].text
		dgsSetData(memo,"caretPos",{0,1})
		dgsSetData(memo,"selectFrom",{0,1})
		dgsSetData(memo,"rightLength",{0,1})
		configMemo(memo)
	end
	local font = dgsElementData[memo].font
	local textSize = dgsElementData[memo].textSize
	local _index,_line = dgsMemoGetCaretPosition(memo,true)
	local index,line = index or _index,line or _line
	local fixed = utf8Gsub(text,splitChar,splitChar2)
	local fixed = " "..utf8Gsub(fixed,"	"," ").." "
	local tab = string.split(fixed,splitChar2)
	tab[1] = utf8Sub(tab[1],2)
	tab[#tab] = utf8Sub(tab[#tab],1,utf8Len(tab[#tab])-1)
	local isWordWrap = dgsElementData[memo].wordWrap
	local mapTable = dgsElementData[memo].wordWrapMapText or {}
	local size = dgsElementData[memo].absSize
	local padding = dgsElementData[memo].padding
	local scbThick = dgsElementData[memo].scrollBarThick
	local scrollbars = dgsElementData[memo].scrollbars
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
				local textLen = _dxGetTextWidth(tab[i],textSize[1],font)
				local text = tab[i]
				tableInsert(textTable,theline,{[-1]=textLen,[0]=text})
			else
				if i == 1 then
					textTable[theline] = textTable[theline] or {[0]=""}
					textFront = utf8Sub(textTable[theline][0],0,index) or ""
					textRear = utf8Sub(textTable[theline][0],index+1) or ""
					local isAppendRear = newTextLines == 1 and textRear or ""
					textTable[theline][0] = textFront..tab[1]..isAppendRear
					textTable[theline][-1] = _dxGetTextWidth(textTable[theline][0],textSize[1],font)
				end
				if i == newTextLines and i ~= 1 then
					local text = {}
					text[0] = (tab[i] or "")..textRear
					text[-1] = _dxGetTextWidth(text[0],textSize[1],font)
					tableInsert(textTable,theline,text)
				end
			end
			if isWordWrap then
				local splitedText,splitedTextLine = dgsMemoWordSplit(textTable[theline][0],canHold,textTable[theline][-1],font,textSize[1],isWordWrap)
				textTable[theline][1] = dgsMemoInsertMapTable(mapTable,insertLine,splitedText,textTable[theline])
				insertLine = insertLine + splitedTextLine
			end

			if dgsElementData[memo].rightLength[1] < textTable[theline][-1] then
				dgsElementData[memo].rightLength = {textTable[theline][-1],theline}
			elseif dgsElementData[memo].rightLength[2] > line+#tab-1 then
				dgsElementData[memo].rightLength[2] = dgsElementData[memo].rightLength[2]+1
			end
		end
		dgsElementData[memo].text = textTable
		local fontHeight = dxGetFontHeight(dgsElementData[memo].textSize[2],font)
		local scbTakes = {dgsElementData[scrollbars[1]].visible and scbThick or 0,dgsElementData[scrollbars[2]].visible and scbThick or 0}
		local canHold = mathFloor((size[2]-padding[2]*2-scbTakes[2])/fontHeight)
		if dgsElementData[scrollbars[1]].visible or dgsElementData[memo].rightLength[1] > size[1]-padding[1]*2-scbTakes[1] or dgsElementData[scrollbars[2]].visible or #textTable > canHold then
			configMemo(memo)
		end
		if not noAffectCaret then
			if line < _line or (line == _line and index <= _index) then
				dgsMemoSetCaretPosition(memo,index+offset-1,line)
			end
		end
		triggerEvent("onDgsTextChange",memo)
	end
end

function dgsMemoAppendText(memo,text,noAffectCaret)
	assert(dgsGetType(memo) == "dgs-dxmemo","Bad argument @dgsMemoAppendText at argument 1, expect dgs-dxmemo got "..dgsGetType(memo))
	assert(type(text) == "number" or type(text) == "string","Bad argument @dgsMemoAppendText at argument 2, expect string/number got "..dgsGetType(text))
	local textTable = dgsElementData[memo].text
	local line = #textTable
	local index = textTable[line][-1]
	return handleDxMemoText(memo,tostring(text),true,noAffectCaret,index,line)
end

function dgsMemoInsertText(memo,index,line,text,noAffectCaret)
	assert(dgsGetType(memo) == "dgs-dxmemo","Bad argument @dgsMemoInsertText at argument 1, expect dgs-dxmemo got "..dgsGetType(memo))
	assert(dgsGetType(index) == "number","Bad argument @dgsMemoInsertText at argument 2, expect number got "..dgsGetType(index))
	assert(dgsGetType(line) == "number","Bad argument @dgsMemoInsertText at argument 3, expect number got "..dgsGetType(line))
	assert(type(text) == "number" or type(text) == "string","Bad argument @dgsMemoInsertText at argument 4, expect string/number got "..dgsGetType(text))
	return handleDxMemoText(memo,tostring(text),true,noAffectCaret,index,line)
end

function dgsMemoDeleteText(memo,fromIndex,fromLine,toIndex,toLine,noAffectCaret)
	assert(dgsGetType(memo) == "dgs-dxmemo","Bad argument @dgsMemoDeleteText at argument 1, expect dgs-dxmemo got "..dgsGetType(memo))
	assert(dgsGetType(fromIndex) == "number","Bad argument @dgsMemoDeleteText at argument 2, expect number got "..dgsGetType(fromIndex))
	assert(dgsGetType(fromLine) == "number","Bad argument @dgsMemoDeleteText at argument 3, expect number got "..dgsGetType(fromLine))
	assert(dgsGetType(toIndex) == "number","Bad argument @dgsMemoDeleteText at argument 4, expect number got "..dgsGetType(toIndex))
	assert(dgsGetType(toLine) == "number","Bad argument @dgsMemoDeleteText at argument 5, expect number got "..dgsGetType(toLine))
	if fromIndex == toIndex and fromLine == toLine then return end
	local textTable = dgsElementData[memo].text
	local mapTable = dgsElementData[memo].wordWrapMapText
	local font = dgsElementData[memo].font
	local textSize = dgsElementData[memo].textSize
	local fontHeight = dxGetFontHeight(dgsElementData[memo].textSize[2],font)
	local size = dgsElementData[memo].absSize
	local padding = dgsElementData[memo].padding
	local scbThick = dgsElementData[memo].scrollBarThick
	local scrollbars = dgsElementData[memo].scrollbars
	local textLines = #textTable
	local isWordWrap = dgsElementData[memo].wordWrap
	local lineTextFrom = textTable[fromLine][0]
	local lineTextTo = textTable[toLine][0]
	local lineTextFromCnt = utf8Len(lineTextFrom)
	local lineTextToCnt = utf8Len(lineTextTo)
	local insertLine,lineCnt
	fromIndex,toIndex = math.restrict(fromIndex,0,lineTextFromCnt),math.restrict(toIndex,0,lineTextToCnt)
	fromLine,toLine = math.restrict(fromLine,1,textLines),math.restrict(toLine,1,textLines)
	if fromLine > toLine then
		fromLine,toLine,fromIndex,toIndex = toLine,fromLine,toIndex,fromIndex
	end
	if fromLine == toLine then
		local _to = toIndex < fromIndex and fromIndex or toIndex
		local _from = fromIndex > toIndex and toIndex or fromIndex
		textTable[toLine][0] = utf8Sub(textTable[toLine][0],0,_from)..utf8Sub(textTable[toLine][0],_to+1)
		textTable[toLine][-1] = _dxGetTextWidth(textTable[toLine][0],textSize[1],font)
		if isWordWrap then
			insertLine,lineCnt = dgsMemoGetInsertLine(textTable,mapTable,fromLine)
			dgsMemoRemoveMapTable(mapTable,insertLine,lineCnt)
		end
	else
		textTable[fromLine][0] = utf8Sub(textTable[fromLine][0],0,fromIndex)..utf8Sub(textTable[toLine][0],toIndex+1)
		textTable[fromLine][-1] = _dxGetTextWidth(textTable[fromLine][0],textSize[1],font)
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
	dgsElementData[memo].text = textTable
	local line,len = seekMaxLengthLine(memo)
	dgsElementData[memo].rightLength = {len,line}
	if dgsElementData[scrollbars[1]].visible or dgsElementData[memo].rightLength[1] > size[1]-padding[2]*2-scbTakes[1] or dgsElementData[scrollbars[2]].visible or #textTable > canHold then
		configMemo(memo)
	end
	if not noAffectCaret then
		local cpos = dgsElementData[memo].caretPos
		if cpos[2] > fromLine then
			dgsMemoSetCaretPosition(memo,cpos[1]-(toIndex-fromIndex),cpos[2]-(toLine-fromLine))
		elseif cpos[2] == fromLine and cpos[1] >= fromIndex then
			dgsMemoSetCaretPosition(memo,fromIndex,fromLine)
		end
	end
	local textTable = dgsElementData[memo].text
	if isWordWrap then
		local mapTable = dgsElementData[memo].wordWrapMapText
		local mapTableCnt = #mapTable
		local wordWrapShowLine = dgsElementData[memo].wordWrapShowLine
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
		if #textTable > canHold and dgsElementData[memo].showLine-1+canHold > #textTable then
			dgsElementData[memo].showLine = 1-canHold+#textTable
		end
	end
	triggerEvent("onDgsTextChange",memo)
end

function dgsMemoClearText(memo)
	assert(dgsGetType(memo) == "dgs-dxmemo","Bad argument @dgsMemoClearText at argument 1, expect dgs-dxmemo got "..dgsGetType(memo))
	dgsElementData[memo].text = {{[-1]=0,[0]=""}}
	dgsSetData(memo,"caretPos",{0,1})
	dgsSetData(memo,"wordWrapMapText",{})
	dgsSetData(memo,"wordWrapShowLine",{1,1,1})
	dgsSetData(memo,"selectFrom",{0,1})
	dgsSetData(memo,"rightLength",{0,1})
	configMemo(memo)
	triggerEvent("onDgsTextChange",memo)
	return true
end

function checkMemoMousePosition(button,state,x,y)
	if dgsGetType(source) == "dgs-dxmemo" then
		if state == "down" and button ~= "middle" then
			local pos,line = searchMemoMousePosition(source,x,y)
			local shift = getKeyState("lshift") or getKeyState("rshift")
			dgsMemoSetCaretPosition(source,pos,line,shift)
		end
	end
end
addEventHandler("onDgsMouseClick",root,checkMemoMousePosition)

function dgsMemoGetPartOfText(memo,cindex,cline,tindex,tline,isDelete)
	assert(dgsGetType(memo) == "dgs-dxmemo","Bad argument @dgsMemoGetPartOfText at argument 1, expect dgs-dxmemo got "..dgsGetType(memo))
	local outStr = ""
	local textTable = dgsElementData[memo].text
	local textLines = #textTable
	cindex,cline,tindex,tline = cindex or 0,cline or 1,tindex or utf8Len(textTable[textLines][0]),tline or textLines
	cline = math.restrict(cline,1,textLines)
	tline = math.restrict(tline,1,textLines)
	local lineTextFrom = textTable[cline][0]
	local lineTextTo = textTable[tline][0]
	local lineTextFromCnt = utf8Len(lineTextFrom)
	local lineTextToCnt = utf8Len(lineTextTo)
	cindex = math.restrict(cindex,0,lineTextFromCnt)
	tindex = math.restrict(tindex,0,lineTextToCnt)
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
	assert(dgsGetType(memo) == "dgs-dxmemo","Bad argument @dgsMemoSetSelectedArea at argument 1, except a dgs-memo got "..dgsGetType(memo))
	assert(type(fromIndex) == "number","Bad argument @dgsMemoSetSelectedArea at argument 2, except a number got "..type(fromIndex))
	assert(type(fromLine) == "number","Bad argument @dgsMemoSetSelectedArea at argument 3, except a number got "..type(fromLine))
	local args = {...}
	local textTable = dgsElementData[memo].text
	local toIndex,toLine
	if #args == 1 then
		if args[1] == "all" then
			toLine = #textTable
			toIndex = utf8Len(textTable[toLine][0])
		else
			assert(type(args[1]) == "number","Bad argument @dgsMemoSetSelectedArea at argument 4, except a number got "..type(args[1]))
			toIndex,toLine = dgsMemoSeekPosition(textTable,fromIndex+args[1],fromLine)
		end
	elseif #args == 2 then
		toIndex,toLine = args[1],args[2]
		assert(type(toIndex) == "number","Bad argument @dgsMemoSetSelectedArea at argument 4, except a number got "..type(toIndex))
		assert(type(toLine) == "number","Bad argument @dgsMemoSetSelectedArea at argument 5, except a number got "..type(toLine))
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
	assert(dgsGetType(memo) == "dgs-dxmemo","Bad argument @dgsMemoGetSelectedArea at argument 1, except a dgs-memo got "..dgsGetType(memo))
	local fromIndex,fromLine = dgsElementData[memo].caretPos[1],dgsElementData[memo].caretPos[2]
	local toIndex,toLine = dgsElementData[memo].selectFrom[1],dgsElementData[memo].selectFrom[2]
	return fromIndex,fromLine,toIndex,toLine
end

function dgsMemoSetTypingSound(memo,sound)
	assert(dgsGetType(memo) == "dgs-dxmemo","Bad argument @dgsMemoSetTypingSound at argument 1, expect a dgs-dxmemo "..dgsGetType(memo))
	assert(type(sound) == "string" or not sound,"Bad argument @dgsMemoSetTypingSound at argument 2, expect a string or nil got "..dgsGetType(sound))
	local path = sound
	if sourceResource then
		if not find(sound,":") then
			path = ":"..getResourceName(sourceResource).."/"..sound
		end
	end
	assert(fileExists(path),"Bad argument @dgsMemoSetTypingSound at argument 1,couldn't find such file '"..path.."'")
	dgsElementData[memo].typingSound = path
end

function dgsMemoGetTypingSound(memo)
	assert(dgsGetType(memo) == "dgs-dxmemo","Bad argument @dgsMemoGetTypingSound at argument 1, expect a dgs-dxmemo "..dgsGetType(memo))
	return dgsElementData[memo].typingSound
end

function dgsMemoSetWordWrapState(memo,state)
	assert(dgsGetType(memo) == "dgs-dxmemo","Bad argument @dgsMemoSetWordWrapState at argument 1, expect a dgs-dxmemo "..dgsGetType(memo))
	if state == true then
		state = 1
	elseif state ~= false and state ~= 1 and state ~= 2 then
		state = false
	end
	return dgsSetData(memo,"wordWrap",state)
end

function dgsMemoGetWordWrapState(memo)
	assert(dgsGetType(memo) == "dgs-dxmemo","Bad argument @dgsMemoGetWordWrapState at argument 1, expect a dgs-dxmemo "..dgsGetType(memo))
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
	local size = dgsElementData[memo].absSize
	local padding = dgsElementData[memo].padding
	local scrollbar = dgsElementData[memo].scrollbars
	local scrollBarBefore = {dgsElementData[scrollbar[1]].visible,dgsElementData[scrollbar[2]].visible}
	local textCnt
	if dgsElementData[memo].wordWrap then
		textCnt = #dgsElementData[memo].wordWrapMapText	--Weak Line for word Wrap
	else
		textCnt = #dgsElementData[memo].text			--Strong Line for no word Wrap
	end
	local font = dgsElementData[memo].font
	local textSize = dgsElementData[memo].textSize
	local fontHeight = dxGetFontHeight(dgsElementData[memo].textSize[2],font)
	local scbThick = dgsElementData[memo].scrollBarThick
	local scbStateV,scbStateH = false,false
	if not dgsElementData[memo].wordWrap then
		scbStateH = dgsElementData[memo].rightLength[1] > size[1]-padding[1]*2
	end
	local scbTakes2 = scbStateH and scbThick or 0
	local canHold = mathFloor((size[2]-padding[2]*2-scbTakes2)/fontHeight)
	scbStateV = textCnt > canHold
	local scbTakes1 = scbStateV and scbThick or 0
	if not dgsElementData[memo].wordWrap then
		scbStateH = dgsElementData[memo].rightLength[1] > size[1]-padding[1]*2-scbTakes1
	end
	local forceState = dgsElementData[memo].scrollBarState
	if forceState[1] ~= nil then
		scbStateV = forceState[1]
	end
	if forceState[2] ~= nil then
		scbStateH = forceState[2]
	end
	dgsSetVisible(scrollbar[1],scbStateV and true or false)
	dgsSetVisible(scrollbar[2],scbStateH and true or false)
	local scbTakes1 = scbStateV and scbThick or 0
	local scbTakes2 = scbStateH and scbThick or 0
	dgsSetPosition(scrollbar[1],size[1]-scbThick,0,false)
	dgsSetPosition(scrollbar[2],0,size[2]-scbThick,false)
	dgsSetSize(scrollbar[1],scbThick,size[2]-padding[2]*2-scbTakes2,false)
	dgsSetSize(scrollbar[2],size[1]-padding[1]*2-scbTakes1,scbThick,false)

	local scbLengthVrt = dgsElementData[memo].scrollBarLength[1]
	local higLen = 1-(textCnt-canHold)/textCnt
	higLen = higLen >= 0.95 and 0.95 or higLen
	dgsSetData(scrollbar[1],"length",scbLengthVrt or {higLen,true})
	local verticalScrollSize = dgsElementData[memo].scrollSize/(textCnt-canHold)
	dgsSetData(scrollbar[1],"multiplier",{verticalScrollSize,true})
	
	local scbLengthHoz = dgsElementData[memo].scrollBarLength[2]
	local widLen = 1-(dgsElementData[memo].rightLength[1]-size[1]+scbTakes1+padding[1]*2)/dgsElementData[memo].rightLength[1]
	widLen = widLen >= 0.95 and 0.95 or widLen
	dgsSetData(scrollbar[2],"length",scbLengthHoz or {widLen,true})
	local horizontalScrollSize = dgsElementData[memo].scrollSize*5/(dgsElementData[memo].rightLength[1]-size[1]+scbTakes1+padding[1]*2)
	dgsSetData(scrollbar[2],"multiplier",{horizontalScrollSize,true})
	local scrollBarAfter = {dgsElementData[scrollbar[1]].visible,dgsElementData[scrollbar[2]].visible}
	if scrollBarAfter[1] ~= scrollBarBefore[1] or scrollBarAfter[2] ~= scrollBarBefore[2] then
		dgsSetData(memo,"rebuildMapTableNextFrame",true)
	end
	local padding = dgsElementData[memo].padding
	local sizex,sizey = size[1]-padding[1]*2,size[2]-padding[2]*2
	sizex,sizey = sizex-sizex%1,sizey-sizey%1
	local rt_old = dgsElementData[memo].renderTarget
	if isElement(rt_old) then destroyElement(rt_old) end
	local renderTarget,err = dxCreateRenderTarget(sizex-scbTakes1,sizey-scbTakes2,true,memo)
	if renderTarget ~= false then
		dgsAttachToAutoDestroy(renderTarget,memo,-1)
	else
		outputDebugString(err)
	end
	dgsSetData(memo,"renderTarget",renderTarget)
	dgsSetData(memo,"configNextFrame",false)
end

function checkMMScrollBar(source,new,old)
	local memo = dgsGetParent(source)
	if dgsGetType(memo) == "dgs-dxmemo" then
		local scrollbars = dgsElementData[memo].scrollbars
		local size = dgsElementData[memo].absSize
		local padding = dgsElementData[memo].padding
		local scbThick = dgsElementData[memo].scrollBarThick
		local font = dgsElementData[memo].font
		local textSize = dgsElementData[memo].textSize
		local isWordWrap = dgsElementData[memo].wordWrap
		local textTable = dgsElementData[memo].text
		local scbTakes1,scbTakes2 = dgsElementData[scrollbars[1]].visible and scbThick+2 or 4,dgsElementData[scrollbars[2]].visible and scbThick or 0
		if source == scrollbars[1] then
			local fontHeight = dxGetFontHeight(dgsElementData[memo].textSize[2],font)
			local canHold = mathFloor((size[2]-padding[2]*2-scbTakes2)/fontHeight)
			if isWordWrap then
				local mapTable = dgsElementData[memo].wordWrapMapText
				local temp = mathFloor((#mapTable-canHold)*new*0.01)+1
				local wordWrapShowLine = dgsElementData[memo].wordWrapShowLine
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
			local len = dgsElementData[memo].rightLength[1]
			local canHold = mathFloor(len-size[1]+scbTakes1+padding[1]*2)*0.01
			local temp = new*canHold
			dgsSetData(memo,"showPos",temp)
		end
	end
end

function syncScrollBars(memo,which)
	local scrollbars = dgsElementData[memo].scrollbars
	local size = dgsElementData[memo].absSize
	local padding = dgsElementData[memo].padding
	local scbThick = dgsElementData[memo].scrollBarThick
	local font = dgsElementData[memo].font
	local textSize = dgsElementData[memo].textSize
	local isWordWrap = dgsElementData[memo].wordWrap
	local scbTakes1,scbTakes2 = dgsElementData[scrollbars[1]].visible and scbThick+2 or 4,dgsElementData[scrollbars[2]].visible and scbThick or 0
	if which == 1 or not which then
		local fontHeight = dxGetFontHeight(dgsElementData[memo].textSize[2],font)
		local canHold = mathFloor((size[2]-padding[2]*2-scbTakes2)/fontHeight)
		if isWordWrap then
			local line = #dgsElementData[memo].wordWrapMapText
			local new = (line-canHold) == 0 and 0 or (dgsElementData[memo].wordWrapShowLine[3]-1)*100/(line-canHold)
			dgsScrollBarSetScrollPosition(scrollbars[1],new)
		else
			local line = #dgsElementData[memo].text
			local new = (line-canHold) == 0 and 0 or (dgsElementData[memo].showLine-1)*100/(line-canHold)
			dgsScrollBarSetScrollPosition(scrollbars[1],new)
		end
	end
	if which == 2 or not which then
		local len = dgsElementData[memo].rightLength[1]
		local canHold = mathFloor(len-size[1]+scbTakes1+padding[1]*2)*0.01
		local new = dgsElementData[memo].showPos/canHold
		if new >= 100 then new = 100 end
		dgsScrollBarSetScrollPosition(scrollbars[2],new)
	end
end

function dgsMemoSetScrollBarState(memo,vertical,horizontal)
	assert(dgsGetType(memo) == "dgs-dxmemo","Bad argument @dgsMemoSetScrollBarState at at argument 1, expect dgs-dxmemo got "..dgsGetType(memo))
	dgsSetData(memo,"scrollBarState",{vertical,horizontal},true)
	dgsSetData(memo,"configNextFrame",true)
end

function dgsMemoGetScrollBarState(memo)
	assert(dgsGetType(memo) == "dgs-dxscrollpane","Bad argument @dgsMemoGetScrollBarState at at argument 1, expect dgs-dxmemo got "..dgsGetType(memo))
	return dgsElementData[memo].scrollBarState[1],dgsElementData[memo].scrollBarState[2]
end

function dgsMemoSetScrollPosition(memo,vertical,horizontal)
	assert(dgsGetType(memo) == "dgs-dxmemo","Bad argument @dgsMemoSetScrollPosition at at argument 1, expect dgs-dxmemo got "..dgsGetType(memo))
	assert(not vertical or (type(vertical) == "number" and vertical>= 0 and vertical <= 100),"Bad argument @dgsMemoSetScrollPosition at at argument 2, expect nil, none or number∈[0,100] got "..dgsGetType(vertical).."("..tostring(vertical)..")")
	assert(not horizontal or (type(horizontal) == "number" and horizontal>= 0 and horizontal <= 100),"Bad argument @dgsMemoSetScrollPosition at at argument 3,  expect nil, none or number∈[0,100] got "..dgsGetType(horizontal).."("..tostring(horizontal)..")")
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
	assert(dgsGetType(memo) == "dgs-dxmemo","Bad argument @dgsMemoGetScrollPosition at at argument 1, expect dgs-dxmemo got "..dgsGetType(memo))
	local scb = dgsElementData[memo].scrollbars
	return dgsScrollBarGetScrollPosition(scb[1]),dgsScrollBarGetScrollPosition(scb[2])
end

--Make compatibility for GUI
function dgsMemoGetHorizontalScrollPosition(memo)
	assert(dgsGetType(memo) == "dgs-dxmemo","Bad argument @dgsMemoGetHorizontalScrollPosition at at argument 1, expect dgs-dxmemo got "..dgsGetType(memo))
	local scb = dgsElementData[memo].scrollbars
	return dgsScrollBarGetScrollPosition(scb[2])
end

function dgsMemoSetHorizontalScrollPosition(memo,horizontal)
	assert(dgsGetType(memo) == "dgs-dxmemo","Bad argument @dgsMemoSetHorizontalScrollPosition at at argument 1, expect dgs-dxmemo got "..dgsGetType(memo))
	assert(type(horizontal) == "number" and horizontal>= 0 and horizontal <= 100,"Bad argument @dgsMemoSetHorizontalScrollPosition at at argument 3, expect number ranges from 0 to 100 got "..dgsGetType(horizontal).."("..tostring(horizontal)..")")
	local scb = dgsElementData[memo].scrollbars
	return dgsScrollBarSetScrollPosition(scb[2],horizontal)
end

function dgsMemoGetVerticalScrollPosition(memo)
	assert(dgsGetType(memo) == "dgs-dxmemo","Bad argument @dgsMemoGetVerticalScrollPosition at at argument 1, expect dgs-dxmemo got "..dgsGetType(memo))
	local scb = dgsElementData[memo].scrollbars
	return dgsScrollBarGetScrollPosition(scb[1])
end

function dgsMemoSetVerticalScrollPosition(memo,vertical)
	assert(dgsGetType(memo) == "dgs-dxmemo","Bad argument @dgsMemoSetVerticalScrollPosition at at argument 1, expect dgs-dxmemo got "..dgsGetType(memo))
	assert(type(vertical) == "number" and vertical>= 0 and vertical <= 100,"Bad argument @dgsMemoSetVerticalScrollPosition at at argument 2, expect number ranges from 0 to 100 got "..dgsGetType(vertical).."("..tostring(vertical)..")")
	local scb = dgsElementData[memo].scrollbars
	return dgsScrollBarSetScrollPosition(scb[1],vertical)
end

addEventHandler("onClientGUIChanged",resourceRoot,function()
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
end)

function dgsMemoRebuildWordWrapMapTable(memo)
	dgsSetData(memo,"rebuildMapTableNextFrame",false)
	local isWordWrap = dgsElementData[memo].wordWrap
	if isWordWrap then
		local textTable = dgsElementData[memo].text
		local size = dgsElementData[memo].absSize
		local padding = dgsElementData[memo].padding
		local font = dgsElementData[memo].font
		local textSizeX = dgsElementData[memo].textSize[1]
		local scbThick = dgsElementData[memo].scrollBarThick
		local scrollbars = dgsElementData[memo].scrollbars
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
	local textTable = dgsElementData[memo].text
	local textSize = dgsElementData[memo].textSize
	local font = dgsElementData[memo].font
	for i=1,#textTable do
		local text = textTable[i][0]
		textTable[i][-1] = _dxGetTextWidth(text,textSize[1],font)
		if dgsElementData[memo].rightLength[1] < textTable[i][-1] then
			dgsElementData[memo].rightLength = {textTable[i][-1],i}
		end
	end
	configMemo(memo)
end

----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxmemo"] = function(source,x,y,w,h,mx,my,cx,cy,enabled,eleData,parentAlpha,isPostGUI,rndtgt)
	if eleData.configNextFrame then
		configMemo(source)
	end
	local bgImage = eleData.bgImage
	local bgColor = applyColorAlpha(eleData.bgColor,parentAlpha)
	local caretColor = applyColorAlpha(eleData.caretColor,parentAlpha)
	if MouseData.nowShow == source then
		if isConsoleActive() or isMainMenuActive() or isChatBoxInputActive() then
			MouseData.nowShow = false
		end
	end
	local text = eleData.text
	local caretPos = eleData.caretPos
	local selectFro = eleData.selectFrom
	local selectColor = MouseData.nowShow == source and eleData.selectColor or eleData.selectColorBlur
	local font = eleData.font or systemFont
	local txtSizX,txtSizY = eleData.textSize[1],eleData.textSize[2]
	local renderTarget = eleData.renderTarget
	local fontHeight = dxGetFontHeight(eleData.textSize[2],font)
	local wordwrap = eleData.wordWrap
	local scbThick = eleData.scrollBarThick
	local scrollbars = eleData.scrollbars
	local selectVisible = eleData.selectVisible
	local finalcolor
	if not enabled[1] and not enabled[2] then
		if type(eleData.disabledColor) == "number" then
			finalcolor = eleData.disabledColor
		elseif eleData.disabledColor == true then
			local r,g,b,a = fromcolor(bgColor,true)
			local average = (r+g+b)/3*eleData.disabledColorPercent
			finalcolor = tocolor(average,average,average,a)
		else
			finalcolor = bgColor
		end
	else
		finalcolor = bgColor
	end
	local padding = eleData.padding
	local sidelength,sideheight = padding[1]-padding[1]%1,padding[2]-padding[2]%1
	local px,py,pw,ph = x+sidelength,y+sideheight,w-sidelength*2,h-sideheight*2
	if bgImage then
		dxDrawImage(x,y,w,h,bgImage,0,0,0,finalcolor,isPostGUI)
	else
		dxDrawRectangle(x,y,w,h,finalcolor,isPostGUI)
	end
	if isElement(renderTarget) then
		if wordwrap then
			if eleData.rebuildMapTableNextFrame then
				dgsMemoRebuildWordWrapMapTable(source)
			end
			local allLines = #eleData.wordWrapMapText
			local textColor = eleData.textColor
			local showLine = eleData.showLine
			local wordWrapShowLine = eleData.wordWrapShowLine
			local caretHeight = eleData.caretHeight-1
			local canHoldLines = mathFloor((h-4)/fontHeight)
			canHoldLines = canHoldLines > allLines and allLines or canHoldLines
			dxSetRenderTarget(renderTarget,true)
			dxSetBlendMode("modulate_add")
			local showPos = eleData.showPos
			local caretRltHeight = fontHeight*caretHeight
			local caretDrawPos
			local selPosStart,selPosEnd,selStart,selEnd
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
				local isInWeakLine = false
				local lineCnt = 0
				local rndLine,rndPos,totalLine = eleData.wordWrapShowLine[1],eleData.wordWrapShowLine[2],eleData.wordWrapShowLine[3]
				if rndLine <= 1 then
					rndLine = 1
				end
				local caretPos = eleData.caretPos
				for a=rndLine,#text do
					local weakLinePos = 0
					local nextWeakLineLen = 0
					for b=1,#text[a][1] do
						weakLineLen = text[a][1][b][3]
						if b >= rndPos then
							local ypos = lineCnt*fontHeight
							local renderingText = text[a][1][b][0]
							if selectVisible then
								if a == selStart or a == selEnd then
									if a == selStart and a == selEnd then
										if selPosStart >= weakLinePos then
											local startPosX = dxGetTextWidth(utf8Sub(renderingText,0,selPosStart-weakLinePos),txtSizX,font)
											local selectLen = dxGetTextWidth(utf8Sub(renderingText,selPosStart-weakLinePos+1,selPosEnd-weakLinePos),txtSizX,font)
											dxDrawRectangle(-showPos+startPosX,ypos-caretRltHeight,selectLen,caretRltHeight+fontHeight,selectColor)
										elseif selPosStart < weakLinePos and selPosEnd > weakLinePos+weakLineLen then
											local startPosX = dxGetTextWidth(renderingText,txtSizX,font)
											dxDrawRectangle(-showPos,ypos-caretRltHeight,startPosX,caretRltHeight+fontHeight,selectColor)
										elseif selPosEnd >= weakLinePos and selPosEnd <= weakLinePos+weakLineLen then
											local selectLen = dxGetTextWidth(utf8Sub(renderingText,0,selPosEnd-weakLinePos),txtSizX,font)
											dxDrawRectangle(-showPos,ypos-caretRltHeight,selectLen,caretRltHeight+fontHeight,selectColor)
										end
									elseif a == selStart then
										if selPosStart >= weakLinePos and selPosStart <= weakLinePos+weakLineLen then
											local startPosX = dxGetTextWidth(utf8Sub(renderingText,0,selPosStart-weakLinePos),txtSizX,font)
											local selectLen = dxGetTextWidth(utf8Sub(renderingText,selPosStart-weakLinePos+1),txtSizX,font)
											dxDrawRectangle(-showPos+startPosX,ypos-caretRltHeight,selectLen,caretRltHeight+fontHeight,selectColor)
										elseif selPosStart <= weakLinePos then
											dxDrawRectangle(-showPos,ypos-caretRltHeight,dxGetTextWidth(renderingText,txtSizX,font),caretRltHeight+fontHeight,selectColor)
										end
									elseif a == selEnd then
										if selPosEnd >= weakLinePos and selPosEnd <= weakLinePos+weakLineLen then
											local selectLen = dxGetTextWidth(utf8Sub(renderingText,0,selPosEnd-weakLinePos),txtSizX,font)
											dxDrawRectangle(-showPos,ypos-caretRltHeight,selectLen,caretRltHeight+fontHeight,selectColor)
										elseif selPosEnd >= weakLinePos then
											dxDrawRectangle(-showPos,ypos-caretRltHeight,dxGetTextWidth(renderingText,txtSizX,font),caretRltHeight+fontHeight,selectColor)
										end
									end
								elseif a > selStart and a < selEnd then
									dxDrawRectangle(-showPos,ypos-caretRltHeight,dxGetTextWidth(renderingText,txtSizX,font),caretRltHeight+fontHeight,selectColor)
								end
							end
							if caretPos[2] == a then
								if caretPos[1] >= weakLinePos and caretPos[1] <= weakLinePos+weakLineLen then
									local indexInWeakLine = caretPos[1]-weakLinePos
									caretDrawPos = {px-showPos-2,py+ypos,utf8Sub(renderingText,1,indexInWeakLine),utf8Sub(renderingText,indexInWeakLine+1,indexInWeakLine+1)}
								end
							end
							dxDrawText(renderingText,-showPos,ypos,-showPos,fontHeight+ypos,textColor,txtSizX,txtSizY,font,"left","top",false,false,false,false)
							rndPos = 1
							lineCnt = lineCnt + 1
						end
						weakLinePos = weakLinePos+weakLineLen
						if lineCnt > canHoldLines then
							break
						end
					end
					if lineCnt > canHoldLines then
						break
					end
				end
			end
			dxSetRenderTarget(rndtgt)
			local scbTakes1,scbTakes2 = dgsElementData[scrollbars[1]].visible and scbThick+2 or 4,dgsElementData[scrollbars[2]].visible and scbThick or 0
			dxSetBlendMode(rndtgt and "modulate_add" or "blend")
			dxDrawImageSection(px,py,pw-scbTakes1,ph-scbTakes2,0,0,pw-scbTakes1,ph-scbTakes2,renderTarget,0,0,0,tocolor(255,255,255,255*parentAlpha),isPostGUI)
			if MouseData.nowShow == source and MouseData.editMemoCursor then
				local CaretShow = true
				if eleData.readOnly then
					CaretShow = eleData.readOnlyCaretShow
				end
				if CaretShow and caretDrawPos then
					local caretStyle = eleData.caretStyle
					local caretRenderX = caretDrawPos[1]+dxGetTextWidth(caretDrawPos[3],txtSizX,font)+1
					if caretStyle == 0 then
						dxDrawLine(caretRenderX,caretDrawPos[2],caretRenderX,caretDrawPos[2]+fontHeight*(1-caretHeight),caretColor,eleData.caretThick,isPostGUI)
					elseif caretStyle == 1 then
						local cursorWidth = dxGetTextWidth(caretDrawPos[4],txtSizX,font)
						if cursorWidth == 0 then
							cursorWidth = txtSizX*8
						end
						local offset = eleData.caretOffset
						local caretRenderX = caretDrawPos[1]+dxGetTextWidth(caretDrawPos[3],txtSizX,font)+1
						local caretRenderY = caretDrawPos[2]+fontHeight*(1-caretHeight)*0.85+offset-2
						dxDrawLine(caretRenderX,caretRenderY,caretRenderX+cursorWidth,caretRenderY,caretColor,eleData.caretThick,isPostGUI)
					end
				end
			end
		else
			local allLine = #text
			local textColor = eleData.textColor
			local showLine = eleData.showLine
			local caretHeight = eleData.caretHeight-1
			local canHoldLines = mathFloor((h-4)/fontHeight)
			canHoldLines = canHoldLines > allLine and allLine or canHoldLines
			local selPosStart,selPosEnd,selStart,selEnd
			dxSetRenderTarget(renderTarget,true)
			dxSetBlendMode("modulate_add")
			local showPos = eleData.showPos
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
				for i=showLine,toShowLine do
					local ypos = (i-showLine)*fontHeight
					if selectVisible then
						if i == selStart or i == selEnd then
							if i == selStart and i == selEnd then
								local startPosX = dxGetTextWidth(utf8Sub(text[i][0],0,selPosStart),txtSizX,font)
								local selectLen = dxGetTextWidth(utf8Sub(text[i][0],selPosStart+1,selPosEnd),txtSizX,font)
								dxDrawRectangle(-showPos+startPosX,ypos-caretRltHeight,selectLen,caretRltHeight+fontHeight,selectColor)
							elseif i == selStart then
								local startPosX = dxGetTextWidth(utf8Sub(text[i][0],0,selPosStart),txtSizX,font)
								local selectLen = dxGetTextWidth(utf8Sub(text[i][0],selPosStart+1),txtSizX,font)
								dxDrawRectangle(-showPos+startPosX,ypos-caretRltHeight,selectLen,caretRltHeight+fontHeight,selectColor)
							elseif i == selEnd then
								local selectLen = dxGetTextWidth(utf8Sub(text[i][0],0,selPosEnd),txtSizX,font)
								dxDrawRectangle(-showPos,ypos-caretRltHeight,selectLen,caretRltHeight+fontHeight,selectColor)
							end
						elseif i > selStart and i < selEnd then
							dxDrawRectangle(-showPos,ypos-caretRltHeight,text[i][-1],caretRltHeight+fontHeight,selectColor)
						end
					end
					dxDrawText(text[i][0],-showPos,ypos,-showPos,fontHeight+ypos,textColor,txtSizX,txtSizY,font,"left","top",false,false,false,false)
				end
			end
			dxSetRenderTarget(rndtgt)
			local scbTakes1,scbTakes2 = dgsElementData[scrollbars[1]].visible and scbThick+2 or 4,dgsElementData[scrollbars[2]].visible and scbThick or 0
			dxSetBlendMode(rndtgt and "modulate_add" or "blend")
			dxDrawImageSection(px,py,pw-scbTakes1,ph-scbTakes2,0,0,pw-scbTakes1,ph-scbTakes2,renderTarget,0,0,0,tocolor(255,255,255,255*parentAlpha),isPostGUI)
			if MouseData.nowShow == source and MouseData.editMemoCursor then
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
							dxDrawLine(px+width-showPos-1,selStartY,px+width-showPos-1,selEndY,caretColor,eleData.caretThick,noRenderTarget)
						elseif eleData.caretStyle == 1 then
							local cursorWidth = dxGetTextWidth(utf8Sub(theText,cursorPX+1,cursorPX+1),txtSizX,font)
							cursorWidth = cursorWidth ~= 0 and cursorWidth or txtSizX*8
							local offset = eleData.caretOffset
							dxDrawLine(px+width-showPos,py+ph-4+offset,px+width-showPos+cursorWidth+2,py+ph-4+offset,caretColor,eleData.caretThick,noRenderTarget)
						end
					end
				end
			end
		end
	end
	if enabled[1] and mx then
		if mx >= cx-2 and mx<= cx+w-1 and my >= cy-2 and my <= cy+h-1 then
			MouseData.hit = source
		end
	end
	return rndtgt
end
----------------------------------------------------------------
-------------------------OOP Class------------------------------
----------------------------------------------------------------
dgsOOP["dgs-dxmemo"] = [[
	moveCaret = dgsOOP.genOOPFnc("dgsMemoMoveCaret",true),
	seekPosition = dgsOOP.genOOPFnc("dgsMemoSeekPosition"),
	getScrollBar = dgsOOP.genOOPFnc("dgsMemoGetScrollBar"),
	setScrollPosition = dgsOOP.genOOPFnc("dgsMemoSetScrollPosition",true),
	getScrollPosition = dgsOOP.genOOPFnc("dgsMemoGetScrollPosition"),
	setHorizontalScrollPosition = dgsOOP.genOOPFnc("dgsMemoSetHorizontalScrollPosition",true),
	getHorizontalScrollPosition = dgsOOP.genOOPFnc("dgsMemoGetHorizontalScrollPosition"),
	setVerticalScrollPosition = dgsOOP.genOOPFnc("dgsMemoSetVerticalScrollPosition",true),
	getVerticalScrollPosition = dgsOOP.genOOPFnc("dgsMemoGetVerticalScrollPosition"),
	setCaretPosition = dgsOOP.genOOPFnc("dgsMemoSetCaretPosition",true),
	getCaretPosition = dgsOOP.genOOPFnc("dgsMemoGetCaretPosition"),
	setCaretStyle = dgsOOP.genOOPFnc("dgsMemoSetCaretStyle",true),
	getCaretStyle = dgsOOP.genOOPFnc("dgsMemoGetCaretStyle"),
	setReadOnly = dgsOOP.genOOPFnc("dgsMemoSetReadOnly",true),
	getReadOnly = dgsOOP.genOOPFnc("dgsMemoGetReadOnly"),
	getPartOfText = dgsOOP.genOOPFnc("dgsMemoGetPartOfText"),
	deleteText = dgsOOP.genOOPFnc("dgsMemoDeleteText",true),
	insertText = dgsOOP.genOOPFnc("dgsMemoInsertText",true),
	appendText = dgsOOP.genOOPFnc("dgsMemoAppendText",true),
	clearText = dgsOOP.genOOPFnc("dgsMemoClearText",true),
	getTypingSound = dgsOOP.genOOPFnc("dgsMemoGetTypingSound"),
	setTypingSound = dgsOOP.genOOPFnc("dgsMemoSetTypingSound",true),
	getLineCount = dgsOOP.genOOPFnc("dgsMemoGetLineCount"),
	setWordWrapState = dgsOOP.genOOPFnc("dgsMemoSetWordWrapState",true),
	getWordWrapState = dgsOOP.genOOPFnc("dgsMemoGetWordWrapState"),
	setScrollBarState = dgsOOP.genOOPFnc("dgsMemoSetScrollBarState",true),
	getScrollBarState = dgsOOP.genOOPFnc("dgsMemoGetScrollBarState"),
]]