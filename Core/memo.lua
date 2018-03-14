function dgsCreateMemo(x,y,sx,sy,text,relative,parent,textcolor,scalex,scaley,bgimage,bgcolor)
	assert(type(x) == "number","Bad argument @dgsCreateMemo at argument 1, expect number got "..type(x))
	assert(type(y) == "number","Bad argument @dgsCreateMemo at argument 2, expect number got "..type(y))
	assert(type(sx) == "number","Bad argument @dgsCreateMemo at argument 3, expect number got "..type(sx))
	assert(type(sy) == "number","Bad argument @dgsCreateMemo at argument 4, expect number got "..type(sy))
	text = tostring(text)
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"Bad argument @dgsCreateMemo at argument 7, expect dgs-dxgui got "..dgsGetType(parent))
	end
	local memo = createElement("dgs-dxmemo")
	dgsSetType(memo,"dgs-dxmemo")
	dgsSetData(memo,"bgimage",bgimage)
	dgsSetData(memo,"bgcolor",bgcolor or schemeColor.memo.bgcolor)
	dgsSetData(memo,"text",{})
	dgsSetData(memo,"textLength",{})
	dgsSetData(memo,"textcolor",textcolor or schemeColor.memo.textcolor)
	dgsSetData(memo,"textsize",{scalex or 1,scaley or 1})
	dgsSetData(memo,"cursorposXY",{0,1})
	dgsSetData(memo,"selectfrom",{0,1})
	dgsSetData(memo,"rightLength",{0,1})
	dgsSetData(memo,"showPos",0)
	dgsSetData(memo,"showLine",1)
	dgsSetData(memo,"cursorStyle",0)
	dgsSetData(memo,"cursorThick",1.2)
	dgsSetData(memo,"scrollBarThick",20)
	dgsSetData(memo,"cursorOffset",{0,0})
	dgsSetData(memo,"readOnly",false)
	dgsSetData(memo,"font",systemFont)
	dgsSetData(memo,"side",0)
	dgsSetData(memo,"sidecolor",schemeColor.memo.sidecolor)
	dgsSetData(memo,"useFloor",false)
	dgsSetData(memo,"readOnlyCaretShow",false)
	dgsSetData(memo,"editmemoSign",true)
	dgsSetData(memo,"selectcolor",selectmode and tocolor(50,150,255,100) or tocolor(50,150,255,200))
	dgsSetData(memo,"caretColor",schemeColor.memo.caretcolor)
	local gmemo = guiCreateMemo(0,0,0,0,"",false)
	dgsSetData(memo,"memo",gmemo)
	dgsSetData(gmemo,"dxmemo",memo)
	guiSetAlpha(gmemo,0)
	guiSetProperty(gmemo,"AlwaysOnTop","True")
	dgsSetData(memo,"maxLength",guiGetProperty(gmemo,"MaxTextLength"))
	if isElement(parent) then
		dgsSetParent(memo,parent)
	else
		table.insert(MaxFatherTable,memo)
	end
	insertResourceDxGUI(sourceResource,memo)
	triggerEvent("onDgsPreCreate",memo)
	calculateGuiPositionSize(memo,x,y,relative or false,sx,sy,relative or false,true)
	local abx,aby = unpack(dgsElementData[memo].absSize)
	local scrollbar1 = dgsCreateScrollBar(abx-20,0,20,aby-20,false,false,memo)
	local scrollbar2 = dgsCreateScrollBar(0,aby-20,abx-20,20,true,false,memo)
	dgsSetVisible(scrollbar1,false)
	dgsSetVisible(scrollbar2,false)
	dgsSetData(scrollbar1,"length",{0,true})
	dgsSetData(scrollbar2,"length",{0,true})
	local renderTarget = dxCreateRenderTarget(abx-4,aby,true)
	dgsSetData(memo,"renderTarget",renderTarget)
	dgsSetData(memo,"scrollbars",{scrollbar1,scrollbar2})
	handleDxMemoText(memo,text,false,true)
	dgsMemoSetCaretPosition(memo,utf8.len(tostring(text)))
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
	local xpos = dgsElementData[memo].cursorposXY[1]
	local line = dgsElementData[memo].cursorposXY[2]
	local textTable = dgsElementData[memo].text
	local text = textTable[line] or ""
	local pos,line = dgsMemoSeekPosition(textTable,xpos+math.floor(offset),line+math.floor(lineoffset),noMoveLine)
	local showPos,showLine = dgsElementData[memo].showPos,dgsElementData[memo].showLine
	local font = dgsElementData[memo].font
	local nowLen = dxGetTextWidth(utf8.sub(text,0,pos),dgsElementData[memo].textsize[1],font)
	local fontHeight = dxGetFontHeight(dgsElementData[memo].textsize[2],font)
	local size = dgsElementData[memo].absSize
	local targetLen = nowLen+showPos
	local targetLine = line-showLine
	local scbThick = dgsElementData[memo].scrollBarThick
	local scrollbars = dgsElementData[memo].scrollbars
	local scbTakes = {dgsElementData[scrollbars[1]].visible and scbThick or 0,dgsElementData[scrollbars[2]].visible and scbThick or 0}
	local canHold = math.floor((size[2]-scbTakes[2])/fontHeight)
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
	dgsSetData(memo,"cursorposXY",{pos,line})
	local isReadOnlyShow = true
	if dgsElementData[memo].readOnly then
		isReadOnlyShow = dgsElementData[memo].readOnlyCaretShow
	end
	if not noselect or not isReadOnlyShow then
		dgsSetData(memo,"selectfrom",{pos,line})
	end
	resetTimer(MouseData.MemoTimer)
	MouseData.memoCursor = true
	return true
end

function dgsMemoSeekPosition(textTable,pos,line,noMoveLine)
	local line = (line < 1 and 1) or (line > #textTable and #textTable) or line
	local text = textTable[line] or ""
	local strCount = utf8.len(text)
	if not noMoveLine then
		while true do
			if pos < 0 then
				if line-1 >= 1 then
					line = line-1
					text = textTable[line] or ""
					strCount = utf8.len(text)
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
					strCount = utf8.len(text)
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
	local curpos = dgsElementData[memo].cursorposXY
	tline = tline or curpos[2]
	local text = textTable[tline] or ""
	local pos,line = dgsMemoSeekPosition(textTable,tpos,tline)
	local showPos,showLine = dgsElementData[memo].showPos,dgsElementData[memo].showLine
	local font = dgsElementData[memo].font
	local nowLen = dxGetTextWidth(utf8.sub(text,0,pos),dgsElementData[memo].textsize[1],font)
	local fontHeight = dxGetFontHeight(dgsElementData[memo].textsize[2],font)
	local size = dgsElementData[memo].absSize
	local targetLen = nowLen+showPos
	local targetLine = tline-showLine+1
	local scbThick = dgsElementData[memo].scrollBarThick
	local scrollbars = dgsElementData[memo].scrollbars
	local scbTakes = {dgsElementData[scrollbars[1]].visible and scbThick or 0,dgsElementData[scrollbars[2]].visible and scbThick or 0}
	local canHold = math.floor((size[2]-scbTakes[2])/fontHeight)
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
	elseif targetLine < 0 then
		dgsSetData(memo,"showLine",line)
		syncScrollBars(memo,1)
	end
	dgsSetData(memo,"cursorposXY",{pos,line})
	if not noselect then
		dgsSetData(memo,"selectfrom",{pos,line})
	end
	return true
end

function dgsMemoGetCaretPosition(memo,detail)
	assert(dgsGetType(memo) == "dgs-dxmemo","Bad argument @dgsMemoGetCaretPosition at argument 1, expect dgs-dxmemo got "..dgsGetType(memo))
	return dgsElementData[memo].cursorposXY[1],dgsElementData[memo].cursorposXY[2]
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
	local guimemo = dgsElementData[memo].memo
	return dgsSetData(memo,"readOnly",state and true or false)
end

function dgsMemoGetReadOnly(memo)
	assert(dgsGetType(memo) == "dgs-dxmemo","Bad argument @dgsMemoGetReadOnly at argument 1, expect dgs-dxmemo got "..dgsGetType(memo))
	return dgsGetData(memo,"readOnly")
end

function resetMemo(x,y)
	if dgsGetType(MouseData.nowShow) == "dgs-dxmemo" then
		if MouseData.nowShow == MouseData.clickl then
			local pos,line = searchMemoMousePosition(MouseData.nowShow,x*sW,y*sH)
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
		local txtSizX = dgsElementData[dxmemo].textsize[1]
		local fontHeight = dxGetFontHeight(dgsElementData[dxmemo].textsize[2],font)
		local offset = dgsElementData[dxmemo].showPos
		local showLine = dgsElementData[dxmemo].showLine
		local x,y = dgsGetPosition(dxmemo,false,true)
		local allText = dgsElementData[dxmemo].text
		local selLine = math.floor((posy-y)/fontHeight)+showLine
		selLine = selLine > #allText and #allText or selLine
		local text = dgsElementData[dxmemo].text[selLine] or ""
		local pos = posx-x-offset
		local sfrom,sto,templen = 0,utf8.len(text),0
		for i=1,sto do
			local strlen = dxGetTextWidth(utf8.sub(text,sfrom+1,sto/2+sfrom/2),txtSizX,font)
			local len1 = strlen+templen
			if pos < len1 then
				sto = math.floor((sto+sfrom)/2)
			elseif pos > len1 then
				sfrom = math.floor((sto+sfrom)/2)
				templen = dxGetTextWidth(utf8.sub(text,0,sfrom),txtSizX,font)
				start = len1
			elseif pos == len1 then
				start = len1
				sto = sfrom
				templen = dxGetTextWidth(utf8.sub(text,0,sfrom),txtSizX,font)
			end
			if sto-sfrom <= 10 then
				break
			end
		end
		local start = dxGetTextWidth(utf8.sub(text,0,sfrom),txtSizX,font)
		for i=sfrom,sto do
			local poslen1 = dxGetTextWidth(utf8.sub(text,sfrom+1,i),txtSizX,font)+start
			local theNext = dxGetTextWidth(utf8.sub(text,i+1,i+1),txtSizX,font)/2
			local offsetR = theNext+poslen1
			local theLast = dxGetTextWidth(utf8.sub(text,i,i),txtSizX,font)/2
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
function handleDxMemoText(dxgui,text,noclear,noAffectCaret,index,line)
	local textTable = dgsElementData[dxgui].text
	local textLen = dgsElementData[dxgui].textLength
	local str = textTable
	if not noclear then
		dgsElementData[dxgui].text = {}
		dgsElementData[dxgui].textLength = {}
	end
	local font = dgsElementData[dxgui].font
	local textsize = dgsElementData[dxgui].textsize
	local _index,_line = dgsMemoGetCaretPosition(dxgui,true)
	local index,line = index or _index,line or _line
	local fixed = utf8.gsub(text,splitChar,splitChar2)
	local fixed = utf8.gsub(fixed,"	"," ")
	fixed = " "..fixed.." "
	local tab = string.split(fixed,splitChar2)
	tab[1] = utf8.sub(tab[1],2)
	tab[#tab] = utf8.sub(tab[#tab],1,utf8.len(tab[#tab])-1)
	local offset = 0
	if tab ~= 0 then
		if #tab == 1 then
			tab[1] = tab[1] or ""
			offset = utf8.len(tab[1])+1
			textTable[line] = utf8.insert(textTable[line] or "",index+1,tab[1])
			textLen[line] = dxGetTextWidth(textTable[line],textsize[1],font)
			if dgsElementData[dxgui].rightLength[1] < textLen[line] then
				dgsElementData[dxgui].rightLength = {textLen[line],line}
			end
		else
			tab[1] = tab[1] or ""
			offset = offset+utf8.len(tab[1])+1
			textTable[line] = textTable[line] or ""
			local txt1 = utf8.sub(textTable[line],0,index) or ""
			local txt2 = utf8.sub(textTable[line],index+1) or ""
			textTable[line] = (txt1)..(tab[1])
			textLen[line] = dxGetTextWidth(textTable[line],textsize[1],font)
			for i=2,#tab do
				tab[i] = tab[i] or ""
				offset = offset+utf8.len(tab[i])+1
				local theline = line+i-1
				table.insert(textTable,theline,tab[i])
				table.insert(textLen,theline,dxGetTextWidth(tab[i],textsize[1],font))
				if dgsElementData[dxgui].rightLength[1] < textLen[theline] then
					dgsElementData[dxgui].rightLength = {textLen[theline],theline}
				elseif dgsElementData[dxgui].rightLength[2] > line+#tab-1 then
					dgsElementData[dxgui].rightLength[2] = dgsElementData[dxgui].rightLength[2]+1
				end
				if i == #tab then
					textTable[theline] = (tab[i] or "")..txt2
					textLen[theline] = dxGetTextWidth(textTable[theline],textsize[1],font)
					if dgsElementData[dxgui].rightLength[1] < textLen[theline] then
						dgsElementData[dxgui].rightLength = {textLen[theline],theline}
					elseif dgsElementData[dxgui].rightLength[2] > line+#tab-1 then
						dgsElementData[dxgui].rightLength[2] = dgsElementData[dxgui].rightLength[2]+1
					end
				end
			end
		end
		dgsElementData[dxgui].text = textTable
		dgsElementData[dxgui].textLength = textLen
		local font = dgsElementData[dxgui].font
		local fontHeight = dxGetFontHeight(dgsElementData[dxgui].textsize[2],font)
		local size = dgsElementData[dxgui].absSize
		local scbThick = dgsElementData[dxgui].scrollBarThick
		local scrollbars = dgsElementData[dxgui].scrollbars
		local scbTakes = {dgsElementData[scrollbars[1]].visible and scbThick or 0,dgsElementData[scrollbars[2]].visible and scbThick or 0}
		local canHold = math.floor((size[2]-scbTakes[2])/fontHeight)
		if dgsElementData[dxgui].rightLength[1] > size[1]-scbTakes[1] then
			configMemo(dxgui)
		else
			if dgsElementData[scrollbars[1]].visible then
				configMemo(dxgui)
			end
		end
		if #textTable > canHold then
			configMemo(dxgui)
		else
			if dgsElementData[scrollbars[2]].visible then
				configMemo(dxgui)
			end
		end
		if not noAffectCaret then
			if line < _line or (line == _line and index <= _index) then
				dgsMemoSetCaretPosition(dxgui,index+offset-1,line)
			end
		end
		triggerEvent("onDgsTextChange",dxgui,str)
	end
end

function dgsMemoInsertText(dxgui,index,line,text,noAffectCaret)
	assert(dgsGetType(dxgui) == "dgs-dxmemo","Bad argument @dgsMemoInsertText at argument 1, expect dgs-dxmemo got "..dgsGetType(dxgui))
	assert(dgsGetType(index) == "number","Bad argument @dgsMemoInsertText at argument 2, expect number got "..dgsGetType(index))
	assert(dgsGetType(line) == "number","Bad argument @dgsMemoInsertText at argument 3, expect number got "..dgsGetType(line))
	assert(type(text) == "number" or type(text) == "string","Bad argument @dgsMemoInsertText at argument 4, expect string/number got "..dgsGetType(text))
	return handleDxMemoText(dxgui,tostring(text),true,noAffectCaret,index,line)
end

function dgsMemoDeleteText(dxgui,fromindex,fromline,toindex,toline,noAffectCaret)
	assert(dgsGetType(dxgui) == "dgs-dxmemo","Bad argument @dgsMemoDeleteText at argument 1, expect dgs-dxmemo got "..dgsGetType(dxgui))
	local textTable = dgsElementData[dxgui].text
	local textLen = dgsElementData[dxgui].textLength
	local font = dgsElementData[dxgui].font
	local textsize = dgsElementData[dxgui].textsize
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
	local lineTextFromCnt = utf8.len(lineTextFrom)
	local lineTextToCnt = utf8.len(lineTextTo)
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
		textTable[toline] = utf8.sub(textTable[toline],0,_from)..utf8.sub(textTable[toline],_to+1)
		textLen[toline] = dxGetTextWidth(textTable[toline],textsize[1],font)
	else
		textTable[fromline] = utf8.sub(textTable[fromline],0,fromindex)..utf8.sub(textTable[toline],toindex+1)
		textLen[fromline] = dxGetTextWidth(textTable[fromline],textsize[1],font)
		for i=fromline+1,toline do
			table.remove(textTable,fromline+1)
			table.remove(textLen,fromline+1)
		end
	end
	dgsElementData[dxgui].text = textTable
	dgsElementData[dxgui].textLength = textLen
	local line,len = seekMaxLengthLine(dxgui)
	dgsElementData[dxgui].rightLength = {len,line}
	local font = dgsElementData[dxgui].font
	local fontHeight = dxGetFontHeight(dgsElementData[dxgui].textsize[2],font)
	local size = dgsElementData[dxgui].absSize
	local scbThick = dgsElementData[dxgui].scrollBarThick
	local scrollbars = dgsElementData[dxgui].scrollbars
	local scbTakes = {dgsElementData[scrollbars[1]].visible and scbThick or 0,dgsElementData[scrollbars[2]].visible and scbThick or 0}
	local canHold = math.floor((size[2]-scbTakes[2])/fontHeight)
	if dgsElementData[dxgui].rightLength[1] > size[1]-scbTakes[1] then
		configMemo(dxgui)
	else
		if dgsElementData[scrollbars[1]].visible then
			configMemo(dxgui)
		end
	end
	if #textTable > canHold then
		configMemo(dxgui)
	else
		if dgsElementData[scrollbars[2]].visible then
			configMemo(dxgui)
		end
	end
	if not noAffectCaret then
		local cpos = dgsElementData[dxgui].cursorposXY
		if cpos[2] > fromline then
			dgsMemoSetCaretPosition(dxgui,cpos[1]-(toindex-fromindex),cpos[2]-(toline-fromline))
		elseif cpos[2] == fromline and cpos[1] >= fromindex then
			dgsMemoSetCaretPosition(dxgui,fromindex,fromline)
		end
	end
end

function checkMemoMousePosition(button,state,x,y)
	if dgsGetType(source) == "dgs-dxmemo" then
		if state == "down" then
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
	cindex,cline,tindex,tline = cindex or 0,cline or 1,tindex or utf8.len(textTable[textLines]),tline or textLines
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
	local lineTextFromCnt = utf8.len(lineTextFrom)
	local lineTextToCnt = utf8.len(lineTextTo)
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
		outStr = utf8.sub(textTable[tline],_from,_to)
	else
		local txt1 = utf8.sub(textTable[cline],cindex+1) or ""
		local txt2 = utf8.sub(textTable[tline],0,tindex) or ""
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
	if dgsElementData[source].disableScrollBar then return end
	local mymemo = dgsElementData[source].memo
	local size = dgsElementData[source].absSize
	guiSetSize(mymemo,size[1],size[2],false)
	local text = dgsElementData[source].text
	local font = dgsElementData[source].font
	local textsize = dgsElementData[source].textsize
	local fontHeight = dxGetFontHeight(dgsElementData[source].textsize[2],font)
	local scbThick = dgsElementData[source].scrollBarThick
	local scrollbars = dgsElementData[source].scrollbars
	local visible1,visible2 = dgsElementData[scrollbars[1]].visible, dgsElementData[scrollbars[2]].visible
	dgsSetVisible(scrollbars[1],false)
	dgsSetVisible(scrollbars[2],false)

	dgsSetVisible(scrollbars[2],dgsElementData[source].rightLength[1] > size[1])
	local scbTakes2 = dgsElementData[scrollbars[2]].visible and scbThick or 0
	local canHold = math.floor((size[2]-scbTakes2)/fontHeight)
	dgsSetVisible(scrollbars[1], #text > canHold )
	local scbTakes1 = dgsElementData[scrollbars[1]].visible and scbThick+2 or 4
	dgsSetVisible(scrollbars[2],dgsElementData[source].rightLength[1] > size[1]-scbTakes1)
	local scbTakes2 = dgsElementData[scrollbars[2]].visible and scbThick or 0
	local higLen = #text/(#text-canHold)/4
	higLen = higLen >= 0.95 and 0.95 or higLen
	dgsSetData(scrollbars[1],"length",{higLen,true})
	local widLen = dgsElementData[source].rightLength[1]/(dgsElementData[source].rightLength[1]-size[1]+scbTakes1)/4
	widLen = widLen >= 0.95 and 0.95 or widLen
	dgsSetData(scrollbars[2],"length",{widLen,true})
	if visible1 ~= dgsElementData[scrollbars[1]].visible or visible2 ~= dgsElementData[scrollbars[2]].visible then
		local px,py = math.floor(size[1]), math.floor(size[2])
		local rnd = dgsElementData[source].renderTarget
		if isElement(rnd) then
			destroyElement(rnd)
		end
		local renderTarget = dxCreateRenderTarget(px-scbTakes1,py-scbTakes2,true)
		dgsSetData(source,"renderTarget",renderTarget)
	end
end

addEventHandler("onDgsScrollBarScrollPositionChange",root,function(new,old)
	local parent = dgsGetParent(source)
	if dgsGetType(parent) == "dgs-dxmemo" then
		local scrollbars = dgsElementData[parent].scrollbars
		local size = dgsElementData[parent].absSize
		local scbThick = dgsElementData[parent].scrollBarThick
		local font = dgsElementData[parent].font
		local textsize = dgsElementData[parent].textsize
		local text = dgsElementData[parent].text
		local scbTakes1,scbTakes2 = dgsElementData[scrollbars[1]].visible and scbThick+2 or 4,dgsElementData[scrollbars[2]].visible and scbThick or 0
		if source == scrollbars[1] then
			local fontHeight = dxGetFontHeight(dgsElementData[parent].textsize[2],font)
			local canHold = math.floor((size[2]-scbTakes2)/fontHeight)
			local temp = math.floor((#text-canHold)*new/100)+1
			dgsSetData(parent,"showLine",temp)
		elseif source == scrollbars[2] then
			local len = dgsElementData[parent].rightLength[1]
			local canHold = math.floor(len-size[1]+scbTakes1+2)/100
			local temp = -new*canHold
			dgsSetData(parent,"showPos",temp)
		end
	end
end)

function syncScrollBars(dxgui,which)
	local scrollbars = dgsElementData[dxgui].scrollbars
	local size = dgsElementData[dxgui].absSize
	local scbThick = dgsElementData[dxgui].scrollBarThick
	local font = dgsElementData[dxgui].font
	local textsize = dgsElementData[dxgui].textsize
	local text = dgsElementData[dxgui].text
	local scbTakes1,scbTakes2 = dgsElementData[scrollbars[1]].visible and scbThick+2 or 4,dgsElementData[scrollbars[2]].visible and scbThick or 0
	if which == 1 or not which then
		local fontHeight = dxGetFontHeight(dgsElementData[dxgui].textsize[2],font)
		local canHold = math.floor((size[2]-scbTakes2)/fontHeight)
		local new = (#text-canHold) == 0 and 0 or (dgsElementData[dxgui].showLine-1)*100/(#text-canHold)
		dgsScrollBarSetScrollBarPosition(scrollbars[1],new)
	end
	if which == 2 or not which then
		local len = dgsElementData[dxgui].rightLength[1]
		local canHold = math.floor(len-size[1]+scbTakes1+2)/100
		local new = -dgsElementData[dxgui].showPos/canHold
		dgsScrollBarSetScrollBarPosition(scrollbars[2],new)
	end
end

function dgsMemoSetScrollPosition(memo,vertical,horizontal)
	assert(dgsGetType(memo) == "dgs-dxmemo","Bad argument @dgsMemoSetScrollPosition at at argument 1, expect dgs-dxmemo got "..dgsGetType(memo))
	assert(not vertical or (type(vertical) == "number" and vertical>= 0 and vertical <= 100),"Bad argument @dgsMemoSetScrollPosition at at argument 2, expect nil, none or number∈[0,100] got "..dgsGetType(vertical).."("..tostring(vertical)..")")
	assert(not horizontal or (type(horizontal) == "number" and horizontal>= 0 and horizontal <= 100),"Bad argument @dgsMemoSetScrollPosition at at argument 3,  expect nil, none or number∈[0,100] got "..dgsGetType(horizontal).."("..tostring(horizontal)..")")
	local scb = dgsElementData[memo].scrollbars
	local state1,state2 = true,true
	if dgsElementData[scb[1]].visible then
		state1 = dgsScrollBarSetScrollBarPosition(scb[1],vertical)
	end
	if dgsElementData[scb[2]].visible then
		state2 = dgsScrollBarSetScrollBarPosition(scb[2],horizontal)
	end
	return state1 and state2
end

function dgsMemoGetScrollPosition(memo)
	assert(dgsGetType(memo) == "dgs-dxmemo","Bad argument @dgsMemoGetScrollPosition at at argument 1, expect dgs-dxmemo got "..dgsGetType(memo))
	local scb = dgsElementData[memo].scrollbars
	return dgsScrollBarGetScrollBarPosition(scb[1]),dgsScrollBarGetScrollBarPosition(scb[2])
end
