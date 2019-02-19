----Speed UP
local mathFloor = math.floor
local tableInsert = table.insert
local tableRemove = table.remove
local utf8Sub = utf8.sub
local utf8Len = utf8.len
----
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
	dgsSetData(memo,"font",systemFont,true)
	dgsElementData[memo].text = {}
	dgsSetData(memo,"textLength",{""})
	dgsSetData(memo,"textColor",textColor or styleSettings.memo.textColor)
	local textSizeX,textSizeY = tonumber(scalex) or styleSettings.memo.textSize[1], tonumber(scaley) or styleSettings.memo.textSize[2]
	dgsSetData(memo,"textSize",{textSizeX,textSizeY},true)
	dgsSetData(memo,"caretPos",{0,1})
	dgsSetData(memo,"selectFrom",{0,1})
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
	dgsSetData(memo,"scrollBarState",{nil,nil})
	dgsSetData(memo,"historyMaxRecords",100)
	dgsSetData(memo,"enableRedoUndoRecord",true)
	dgsSetData(memo,"undoHistory",{})
	dgsSetData(memo,"redoHistory",{})
	dgsSetData(memo,"typingSound",styleSettings.memo.typingSound)
	dgsSetData(memo,"selectColor",styleSettings.memo.selectColor)
	local gmemo = guiCreateMemo(0,0,0,0,"",true,GlobalEditParent)
	dgsSetData(memo,"memo",gmemo)
	dgsSetData(gmemo,"dxmemo",memo)
	guiSetAlpha(gmemo,0)
	dgsSetData(memo,"maxLength",guiGetProperty(gmemo,"MaxTextLength"))
	insertResourceDxGUI(sourceResource,memo)
	calculateGuiPositionSize(memo,x,y,relative or false,sx,sy,relative or false,true)
	local abx,aby = dgsElementData[memo].absSize[1],dgsElementData[memo].absSize[2]
	local scrollbar1 = dgsCreateScrollBar(abx-20,0,20,aby-20,false,false,memo)
	local scrollbar2 = dgsCreateScrollBar(0,aby-20,abx-20,20,true,false,memo)
	dgsSetVisible(scrollbar1,false)
	dgsSetData(scrollbar1,"length",{0,true})
	dgsSetData(scrollbar2,"length",{0,true})
	dgsSetData(scrollbar1,"multiplier",{1,true})
	dgsSetData(scrollbar2,"multiplier",{1,true})
	local renderTarget = dxCreateRenderTarget(abx-4,aby,true)
	if not isElement(renderTarget) then
		local videoMemory = dxGetStatus().VideoMemoryFreeForMTA
		outputDebugString("Failed to create render target for dgs-dxmemo [Expected:"..(0.0000076*(abx-4)*aby).."MB/Free:"..videoMemory.."MB]",2)
	end
	dgsSetData(memo,"renderTarget",renderTarget)
	dgsSetData(memo,"scrollbars",{scrollbar1,scrollbar2})
	handleDxMemoText(memo,text,false,true)
	dgsMemoSetCaretPosition(memo,utf8Len(tostring(text)))
	triggerEvent("onDgsCreate",memo)
	return memo
end

function dgsMemoGetScrollBar(memo)
	assert(dgsGetType(memo) == "dgs-dxmemo","Bad argument @dgsMemoGetScrollBar at argument 1, expect dgs-dxmemo got "..dgsGetType(memo))
	return dgsElementData[memo].scrollbars
end

function dgsMemoMoveCaret(memo,offset,lineoffset,noselect,noMoveLine)
	assert(dgsGetType(memo) == "dgs-dxmemo","Bad argument @dgsMemoMoveCaret at argument 1, expect dgs-dxmemo got "..dgsGetType(memo))
	assert(type(offset) == "number","Bad argument @dgsMemoMoveCaret at argument 2, expect number got "..type(offset))
	lineoffset = lineoffset or 0
	local xpos = dgsElementData[memo].caretPos[1]
	local line = dgsElementData[memo].caretPos[2]
	local textTable = dgsElementData[memo].text
	local text = textTable[line] or ""
	local pos,line = dgsMemoSeekPosition(textTable,xpos+mathFloor(offset),line+mathFloor(lineoffset),noMoveLine)
	local showPos,showLine = dgsElementData[memo].showPos,dgsElementData[memo].showLine
	local font = dgsElementData[memo].font
	local nowLen = dxGetTextWidth(utf8Sub(text,0,pos),dgsElementData[memo].textSize[1],font)
	local fontHeight = dxGetFontHeight(dgsElementData[memo].textSize[2],font)
	local size = dgsElementData[memo].absSize
	local targetLen = nowLen+showPos
	local targetLine = line-showLine
	local scbThick = dgsElementData[memo].scrollBarThick
	local scrollbars = dgsElementData[memo].scrollbars
	local scbTakes = {dgsElementData[scrollbars[1]].visible and scbThick or 0,dgsElementData[scrollbars[2]].visible and scbThick or 0}
	local canHold = mathFloor((size[2]-scbTakes[2])/fontHeight)
	if targetLen > size[1]-scbTakes[1]-4 then
		dgsSetData(memo,"showPos",size[1]-scbTakes[1]-4-nowLen)
		syncScrollBars(memo,2)
	elseif targetLen < 0 then
		dgsSetData(memo,"showPos",-nowLen)
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
	resetTimer(MouseData.EditMemoTimer)
	MouseData.editMemoCursor = true
	return true
end

function dgsMemoSeekPosition(textTable,pos,line,noMoveLine)
	local line = (line < 1 and 1) or (line > #textTable and #textTable) or line
	local text = textTable[line] or ""
	local strCount = utf8Len(text)
	if not noMoveLine then
		while true do
			if pos < 0 then
				if line-1 >= 1 then
					line = line-1
					text = textTable[line] or ""
					strCount = utf8Len(text)
					pos = strCount+pos+1
					if pos >= 0 then
						break
					end
				else
					pos = 0
					break
				end
			elseif pos > strCount then
				if line+1 <= #textTable then
					pos = pos-strCount-1
					line = line+1
					text = textTable[line] or ""
					strCount = utf8Len(text)
					if pos <= strCount then
						break
					end
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

function dgsMemoSetCaretPosition(memo,tpos,tline,noselect)
	assert(dgsGetType(memo) == "dgs-dxmemo","Bad argument @dgsMemoSetCaretPosition at argument 1, expect dgs-dxmemo got "..dgsGetType(memo))
	assert(type(tpos) == "number","Bad argument @dgsMemoSetCaretPosition at argument 2, expect number got "..type(tpos))
	local textTable = dgsElementData[memo].text
	local curpos = dgsElementData[memo].caretPos
	tline = tline or curpos[2]
	local text = textTable[tline] or ""
	local pos,line = dgsMemoSeekPosition(textTable,tpos,tline)
	local showPos,showLine = dgsElementData[memo].showPos,dgsElementData[memo].showLine
	local font = dgsElementData[memo].font
	local nowLen = dxGetTextWidth(utf8Sub(text,0,pos),dgsElementData[memo].textSize[1],font)
	local fontHeight = dxGetFontHeight(dgsElementData[memo].textSize[2],font)
	local size = dgsElementData[memo].absSize
	local targetLen = nowLen+showPos
	local targetLine = tline-showLine+1
	local scbThick = dgsElementData[memo].scrollBarThick
	local scrollbars = dgsElementData[memo].scrollbars
	local scbTakes = {dgsElementData[scrollbars[1]].visible and scbThick or 0,dgsElementData[scrollbars[2]].visible and scbThick or 0}
	local canHold = mathFloor((size[2]-scbTakes[2])/fontHeight)
	if targetLen > size[1]-scbTakes[1]-4 then
		dgsSetData(memo,"showPos",size[1]-scbTakes[1]-4-nowLen)
		syncScrollBars(memo,2)
	elseif targetLen < 0 then
		dgsSetData(memo,"showPos",-nowLen)
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
	if not noselect then
		dgsSetData(memo,"selectFrom",{pos,line})
	end
	resetTimer(MouseData.EditMemoTimer)
	MouseData.editMemoCursor = true
	return true
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
	local memo = dgsElementData[dxmemo].memo
	if isElement(memo) then
		local size = dgsElementData[dxmemo].absSize
		local font = dgsElementData[dxmemo].font or systemFont
		local txtSizX = dgsElementData[dxmemo].textSize[1]
		local fontHeight = dxGetFontHeight(dgsElementData[dxmemo].textSize[2],font)
		local offset = dgsElementData[dxmemo].showPos
		local showLine = dgsElementData[dxmemo].showLine
		local x,y = dgsGetPosition(dxmemo,false,true)
		local allText = dgsElementData[dxmemo].text
		local selLine = mathFloor((posy-y)/fontHeight)+showLine
		selLine = selLine > #allText and #allText or selLine 
		local text = dgsElementData[dxmemo].text[selLine] or ""
		local pos = posx-x-offset
		local sfrom,sto,templen = 0,utf8Len(text),0
		for i=1,sto do
			halfStoSfrom = (sto+sfrom)*0.5
			local strlen = dxGetTextWidth(utf8Sub(text,sfrom+1,halfStoSfrom),txtSizX,font)
			local len1 = strlen+templen
			if pos < len1 then
				sto = halfStoSfrom-halfStoSfrom%1
			elseif pos > len1 then
				sfrom = halfStoSfrom-halfStoSfrom%1
				templen = dxGetTextWidth(utf8Sub(text,0,sfrom),txtSizX,font)
				start = len1
			elseif pos == len1 then
				start = len1
				sto = sfrom
				templen = dxGetTextWidth(utf8Sub(text,0,sfrom),txtSizX,font)
			end
			if sto-sfrom <= 10 then
				break
			end
		end
		local start = dxGetTextWidth(utf8Sub(text,0,sfrom),txtSizX,font)
		for i=sfrom,sto do
			local poslen1 = dxGetTextWidth(utf8Sub(text,sfrom+1,i),txtSizX,font)+start
			local theNext = dxGetTextWidth(utf8Sub(text,i+1,i+1),txtSizX,font)*0.5
			local offsetR = theNext+poslen1
			local theLast = dxGetTextWidth(utf8Sub(text,i,i),txtSizX,font)*0.5
			local offsetL = poslen1-theLast
			if i <= sfrom and pos <= offsetL then
				return sfrom,selLine
			elseif i >= sto and pos >= offsetR then
				return sto,selLine
			elseif pos >= offsetL and pos <= offsetR then
				return i,selLine
			end
		end
		return 0,1
	end
	return false
end

local splitChar = "\r\n"
local splitChar2 = "\n"
function handleDxMemoText(memo,text,noclear,noAffectCaret,index,line)
	local textTable = dgsElementData[memo].text
	local textLen = dgsElementData[memo].textLength
	local str = textTable
	if not noclear then
		dgsElementData[memo].text = {""}
		dgsElementData[memo].textLength = {}
		textTable = dgsElementData[memo].text
		textLen = dgsElementData[memo].textLength
		dgsSetData(memo,"caretPos",{0,1})
		dgsSetData(memo,"selectFrom",{0,1})
		dgsSetData(memo,"rightLength",{0,1})
		configMemo(memo)
	end
	local font = dgsElementData[memo].font
	local textSize = dgsElementData[memo].textSize
	local _index,_line = dgsMemoGetCaretPosition(memo,true)
	local index,line = index or _index,line or _line
	local fixed = utf8.gsub(text,splitChar,splitChar2)
	local fixed = utf8.gsub(fixed,"	"," ")
	fixed = " "..fixed.." "
	local tab = string.split(fixed,splitChar2)
	tab[1] = utf8Sub(tab[1],2)
	tab[#tab] = utf8Sub(tab[#tab],1,utf8Len(tab[#tab])-1)
	local offset = 0
	if tab ~= 0 then
		if #tab == 1 then
			tab[1] = tab[1] or ""
			offset = utf8Len(tab[1])+1
			textTable[line] = utf8.insert(textTable[line] or "",index+1,tab[1])
			textLen[line] = dxGetTextWidth(textTable[line],textSize[1],font)
			if dgsElementData[memo].rightLength[1] < textLen[line] then
				dgsElementData[memo].rightLength = {textLen[line],line}
			end
		else
			tab[1] = tab[1] or ""
			offset = offset+utf8Len(tab[1])+1
			textTable[line] = textTable[line] or ""
			local txt1 = utf8Sub(textTable[line],0,index) or ""
			local txt2 = utf8Sub(textTable[line],index+1) or ""
			textTable[line] = (txt1)..(tab[1])
			textLen[line] = dxGetTextWidth(textTable[line],textSize[1],font)
			for i=2,#tab do
				tab[i] = tab[i] or ""
				offset = offset+utf8Len(tab[i])+1
				local theline = line+i-1
				tableInsert(textTable,theline,tab[i])
				tableInsert(textLen,theline,dxGetTextWidth(tab[i],textSize[1],font))
				if dgsElementData[memo].rightLength[1] < textLen[theline] then
					dgsElementData[memo].rightLength = {textLen[theline],theline}
				elseif dgsElementData[memo].rightLength[2] > line+#tab-1 then
					dgsElementData[memo].rightLength[2] = dgsElementData[memo].rightLength[2]+1
				end
				if i == #tab then
					textTable[theline] = (tab[i] or "")..txt2
					textLen[theline] = dxGetTextWidth(textTable[theline],textSize[1],font)
					if dgsElementData[memo].rightLength[1] < textLen[theline] then
						dgsElementData[memo].rightLength = {textLen[theline],theline}
					elseif dgsElementData[memo].rightLength[2] > line+#tab-1 then
						dgsElementData[memo].rightLength[2] = dgsElementData[memo].rightLength[2]+1
					end
				end
			end
		end
		dgsElementData[memo].text = textTable
		dgsElementData[memo].textLength = textLen
		local font = dgsElementData[memo].font
		local fontHeight = dxGetFontHeight(dgsElementData[memo].textSize[2],font)
		local size = dgsElementData[memo].absSize
		local scbThick = dgsElementData[memo].scrollBarThick
		local scrollbars = dgsElementData[memo].scrollbars
		local scbTakes = {dgsElementData[scrollbars[1]].visible and scbThick or 0,dgsElementData[scrollbars[2]].visible and scbThick or 0}
		local canHold = mathFloor((size[2]-scbTakes[2])/fontHeight)
		if dgsElementData[memo].rightLength[1] > size[1]-scbTakes[1] then
			configMemo(memo)
		else
			if dgsElementData[scrollbars[1]].visible then
				configMemo(memo)
			end
		end
		if #textTable > canHold then
			configMemo(memo)
		elseif dgsElementData[scrollbars[2]].visible then
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

function dgsMemoInsertText(memo,index,line,text,noAffectCaret)
	assert(dgsGetType(memo) == "dgs-dxmemo","Bad argument @dgsMemoInsertText at argument 1, expect dgs-dxmemo got "..dgsGetType(memo))
	assert(dgsGetType(index) == "number","Bad argument @dgsMemoInsertText at argument 2, expect number got "..dgsGetType(index))
	assert(dgsGetType(line) == "number","Bad argument @dgsMemoInsertText at argument 3, expect number got "..dgsGetType(line))
	assert(type(text) == "number" or type(text) == "string","Bad argument @dgsMemoInsertText at argument 4, expect string/number got "..dgsGetType(text))
	return handleDxMemoText(memo,tostring(text),true,noAffectCaret,index,line)
end

function dgsMemoDeleteText(memo,fromindex,fromline,toindex,toline,noAffectCaret)
	assert(dgsGetType(memo) == "dgs-dxmemo","Bad argument @dgsMemoDeleteText at argument 1, expect dgs-dxmemo got "..dgsGetType(memo))
	assert(dgsGetType(fromindex) == "number","Bad argument @dgsMemoDeleteText at argument 2, expect number got "..dgsGetType(fromindex))
	assert(dgsGetType(fromline) == "number","Bad argument @dgsMemoDeleteText at argument 3, expect number got "..dgsGetType(fromline))
	assert(dgsGetType(toindex) == "number","Bad argument @dgsMemoDeleteText at argument 4, expect number got "..dgsGetType(toindex))
	assert(dgsGetType(toline) == "number","Bad argument @dgsMemoDeleteText at argument 5, expect number got "..dgsGetType(toline))
	local textTable = dgsElementData[memo].text
	local textLen = dgsElementData[memo].textLength
	local font = dgsElementData[memo].font
	local textSize = dgsElementData[memo].textSize
	local textLines = #textTable
	if fromline < 1 then
		fromline = 1
	elseif fromline > textLines then
		fromline = textLines
	end
	if toline < 1 then
		toline = 1
	elseif toline > textLines then
		toline = textLines
	end
	local lineTextFrom = textTable[fromline]
	local lineTextTo = textTable[toline]
	local lineTextFromCnt = utf8Len(lineTextFrom)
	local lineTextToCnt = utf8Len(lineTextTo)
	if fromindex < 0 then
		fromindex = 0
	elseif fromindex > lineTextFromCnt then
		toline = lineTextFromCnt
	end
	if toindex < 0 then
		toindex = 0
	elseif toindex > lineTextToCnt then
		toline = lineTextToCnt
	end
	if fromline > toline then
		local temp = toline
		toline = fromline
		fromline = temp
		local temp = toindex
		toindex = fromindex
		fromindex = temp
	end
	if fromline == toline then
		local _to = toindex < fromindex  and fromindex or toindex
		local _from = fromindex > toindex and toindex or fromindex
		textTable[toline] = utf8Sub(textTable[toline],0,_from)..utf8Sub(textTable[toline],_to+1)
		textLen[toline] = dxGetTextWidth(textTable[toline],textSize[1],font)
	else
		textTable[fromline] = utf8Sub(textTable[fromline],0,fromindex)..utf8Sub(textTable[toline],toindex+1)
		textLen[fromline] = dxGetTextWidth(textTable[fromline],textSize[1],font)
		for i=fromline+1,toline do
			tableRemove(textTable,fromline+1)
			tableRemove(textLen,fromline+1)
		end
	end
	dgsElementData[memo].text = textTable
	dgsElementData[memo].textLength = textLen
	local line,len = seekMaxLengthLine(memo)
	dgsElementData[memo].rightLength = {len,line}
	local font = dgsElementData[memo].font
	local fontHeight = dxGetFontHeight(dgsElementData[memo].textSize[2],font)
	local size = dgsElementData[memo].absSize
	local scbThick = dgsElementData[memo].scrollBarThick
	local scrollbars = dgsElementData[memo].scrollbars
	local scbTakes = {dgsElementData[scrollbars[1]].visible and scbThick or 0,dgsElementData[scrollbars[2]].visible and scbThick or 0}
	local canHold = mathFloor((size[2]-scbTakes[2])/fontHeight)
	if dgsElementData[memo].rightLength[1] > size[1]-scbTakes[1] then
		configMemo(memo)
	else
		if dgsElementData[scrollbars[1]].visible then
			configMemo(memo)
		end
	end
	if #textTable > canHold then
		configMemo(memo)
	else
		if dgsElementData[scrollbars[2]].visible then
			configMemo(memo)
		end
	end
	if not noAffectCaret then
		local cpos = dgsElementData[memo].caretPos
		if cpos[2] > fromline then
			dgsMemoSetCaretPosition(memo,cpos[1]-(toindex-fromindex),cpos[2]-(toline-fromline))
		elseif cpos[2] == fromline and cpos[1] >= fromindex then
			dgsMemoSetCaretPosition(memo,fromindex,fromline)
		end
	end
	triggerEvent("onDgsTextChange",memo)
end

function dgsMemoClearText(memo)
	assert(dgsGetType(memo) == "dgs-dxmemo","Bad argument @dgsMemoClearText at argument 1, expect dgs-dxmemo got "..dgsGetType(memo))
	dgsElementData[memo].text = {""}
	dgsElementData[memo].textLength = {}
	dgsSetData(memo,"caretPos",{0,1})
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
			dgsMemoSetCaretPosition(source,pos,line)
		end
	end
end
addEventHandler("onDgsMouseClick",root,checkMemoMousePosition)

function dgsMemoGetPartOfText(memo,cindex,cline,tindex,tline,delete)
	assert(dgsGetType(memo) == "dgs-dxmemo","Bad argument @dgsMemoGetPartOfText at argument 1, expect dgs-dxmemo got "..dgsGetType(memo))
	local outStr = ""
	local textTable = dgsElementData[memo].text
	local textLines = #textTable
	cindex,cline,tindex,tline = cindex or 0,cline or 1,tindex or utf8Len(textTable[textLines]),tline or textLines
	if cline < 1 then
		cline = 1
	elseif cline > textLines then
		cline = textLines
	end
	if tline < 1 then
		tline = 1
	elseif tline > textLines then
		tline = textLines
	end
	local lineTextFrom = textTable[cline]
	local lineTextTo = textTable[tline]
	local lineTextFromCnt = utf8Len(lineTextFrom)
	local lineTextToCnt = utf8Len(lineTextTo)
	if cindex < 0 then
		cindex = 0
	elseif cindex > lineTextFromCnt then
		tline = lineTextFromCnt
	end
	if tindex < 0 then
		tindex = 0
	elseif tindex > lineTextToCnt then
		tline = lineTextToCnt
	end
	if cline > tline then
		local temp = tline
		tline = cline
		cline = temp
		local temp = tindex
		tindex = cindex
		cindex = temp
	end
	if cline == tline then
		local _to = tindex < cindex  and cindex or tindex
		local _from = cindex > tindex and tindex or cindex
		outStr = utf8Sub(textTable[tline],_from,_to)
	else
		local txt1 = utf8Sub(textTable[cline],cindex+1) or ""
		local txt2 = utf8Sub(textTable[tline],0,tindex) or ""
		for i=cline+1,tline-1 do
			outStr = outStr..textTable[i]..splitChar2
		end
		outStr = txt1 ..splitChar2 ..outStr.. txt2
	end
	if delete then
		dgsMemoDeleteText(memo,cindex,cline,tindex,tline)
	end
	return outStr
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

function seekMaxLengthLine(memo)
	local line,lineLen = -1,-1
	for k,v in ipairs(dgsElementData[memo].textLength) do
		if v > lineLen then
			lineLen = v
			line = k
		end
	end
	return line,lineLen
end
	
function configMemo(source)
	local mymemo = dgsElementData[source].memo
	local size = dgsElementData[source].absSize
	local text = dgsElementData[source].text
	local font = dgsElementData[source].font
	local textSize = dgsElementData[source].textSize
	local fontHeight = dxGetFontHeight(dgsElementData[source].textSize[2],font)
	local scbThick = dgsElementData[source].scrollBarThick
	local scrollbar = dgsElementData[source].scrollbars
	local visible1,visible2 = dgsElementData[scrollbar[1]].visible, dgsElementData[scrollbar[2]].visible
	dgsSetVisible(scrollbar[1],false)
	dgsSetVisible(scrollbar[2],false)
	dgsSetVisible(scrollbar[2],dgsElementData[source].rightLength[1] > size[1])
	local scbTakes2 = dgsElementData[scrollbar[2]].visible and scbThick or 0
	local canHold = mathFloor((size[2]-scbTakes2)/fontHeight)
	dgsSetVisible(scrollbar[1], #text > canHold )
	local scbTakes1 = dgsElementData[scrollbar[1]].visible and scbThick or 0
	dgsSetVisible(scrollbar[2],dgsElementData[source].rightLength[1] > size[1]-scbTakes1)
	local scbTakes2 = dgsElementData[scrollbar[2]].visible and scbThick or 0
	dgsSetPosition(scrollbar[1],size[1]-scbThick,0,false)
	dgsSetPosition(scrollbar[2],0,size[2]-scbThick,false)
	dgsSetSize(scrollbar[1],scbThick,size[2]-scbTakes2,false)
	dgsSetSize(scrollbar[2],size[1]-scbTakes1,scbThick,false)

	local higLen = 1-(#text-canHold)/#text
	higLen = higLen >= 0.95 and 0.95 or higLen
	dgsSetData(scrollbar[1],"length",{higLen,true})
	local verticalScrollSize = dgsElementData[source].scrollSize/(#text-canHold)
	dgsSetData(scrollbar[1],"multiplier",{verticalScrollSize,true})
	
	local widLen = 1-(dgsElementData[source].rightLength[1]-size[1]+scbTakes1+4)/dgsElementData[source].rightLength[1]
	widLen = widLen >= 0.95 and 0.95 or widLen
	dgsSetData(scrollbar[2],"length",{widLen,true})
	local horizontalScrollSize = dgsElementData[source].scrollSize*5/(dgsElementData[source].rightLength[1]-size[1]+scbTakes1+4)
	dgsSetData(scrollbar[2],"multiplier",{horizontalScrollSize,true})
	
	local px,py = size[1]-size[1]%1, size[2]-size[2]%1
	local rnd = dgsElementData[source].renderTarget
	if isElement(rnd) then
		destroyElement(rnd)
	end
	local renderTarget = dxCreateRenderTarget(px-scbTakes1,py-scbTakes2,true)
	if not isElement(renderTarget) then
		local videoMemory = dxGetStatus().VideoMemoryFreeForMTA
		outputDebugString("Failed to create render target for dgs-dxmemo [Expected:"..(0.0000076*(px-scbTakes1)*(py-scbTakes2)).."MB/Free:"..videoMemory.."MB]",2)
	end

	dgsSetData(source,"renderTarget",renderTarget)
end

addEventHandler("onDgsScrollBarScrollPositionChange",root,function(new,old)
	local parent = dgsGetParent(source)
	if dgsGetType(parent) == "dgs-dxmemo" then
		local scrollbars = dgsElementData[parent].scrollbars
		local size = dgsElementData[parent].absSize
		local scbThick = dgsElementData[parent].scrollBarThick
		local font = dgsElementData[parent].font
		local textSize = dgsElementData[parent].textSize
		local text = dgsElementData[parent].text
		local scbTakes1,scbTakes2 = dgsElementData[scrollbars[1]].visible and scbThick+2 or 4,dgsElementData[scrollbars[2]].visible and scbThick or 0
		if source == scrollbars[1] then
			local fontHeight = dxGetFontHeight(dgsElementData[parent].textSize[2],font)
			local canHold = mathFloor((size[2]-scbTakes2)/fontHeight)
			local temp = mathFloor((#text-canHold)*new/100)+1
			dgsSetData(parent,"showLine",temp)
		elseif source == scrollbars[2] then
			local len = dgsElementData[parent].rightLength[1]
			local canHold = mathFloor(len-size[1]+scbTakes1+2)/100
			local temp = -new*canHold
			dgsSetData(parent,"showPos",temp)
		end
	end
end)

function syncScrollBars(memo,which)
	local scrollbars = dgsElementData[memo].scrollbars
	local size = dgsElementData[memo].absSize
	local scbThick = dgsElementData[memo].scrollBarThick
	local font = dgsElementData[memo].font
	local textSize = dgsElementData[memo].textSize
	local text = dgsElementData[memo].text
	local scbTakes1,scbTakes2 = dgsElementData[scrollbars[1]].visible and scbThick+2 or 4,dgsElementData[scrollbars[2]].visible and scbThick or 0
	if which == 1 or not which then
		local fontHeight = dxGetFontHeight(dgsElementData[memo].textSize[2],font)
		local canHold = mathFloor((size[2]-scbTakes2)/fontHeight)
		local new = (#text-canHold) == 0 and 0 or (dgsElementData[memo].showLine-1)*100/(#text-canHold)
		dgsScrollBarSetScrollPosition(scrollbars[1],new)
	end
	if which == 2 or not which then
		local len = dgsElementData[memo].rightLength[1]
		local canHold = mathFloor(len-size[1]+scbTakes1+2)/100
		local new = -dgsElementData[memo].showPos/canHold
		dgsScrollBarSetScrollPosition(scrollbars[2],new)
	end
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

addEventHandler("onClientGUIChanged",resourceRoot,function()
	if not dgsElementData[source] then return end
	if getElementType(source) == "gui-memo" then
		local mymemo = dgsElementData[source].dxmemo
		if isElement(mymemo) then
			if source == dgsElementData[mymemo].memo then
				local text = guiGetText(source)
				local cool = dgsElementData[mymemo].CoolTime
				if #text ~= 0 and not cool then
					local caretPos = dgsElementData[mymemo].caretPos
					local selectFrom = dgsElementData[mymemo].selectFrom
					dgsMemoDeleteText(mymemo,caretPos[1],caretPos[2],selectFrom[1],selectFrom[2])
					handleDxMemoText(mymemo,utf8Sub(text,1,utf8Len(text)-1),true)
					dgsElementData[mymemo].CoolTime = true
					guiSetText(source,"")
					dgsElementData[mymemo].CoolTime = false
				end
			end
		end
	end
end)
