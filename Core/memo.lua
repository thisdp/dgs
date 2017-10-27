function dgsDxCreateMemo(x,y,sx,sy,text,relative,parent,textcolor,scalex,scaley,imagebg,colorbg,selectmode)
	assert(type(x) == "number","@dgsDxCreateMemo argument 1,expect number got "..type(x))
	assert(type(y) == "number","@dgsDxCreateMemo argument 2,expect number got "..type(y))
	assert(type(sx) == "number","@dgsDxCreateMemo argument 3,expect number got "..type(sx))
	assert(type(sy) == "number","@dgsDxCreateMemo argument 4,expect number got "..type(sy))
	text = tostring(text)
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"@dgsDxCreateMemo argument 7,expect dgs-dxgui got "..dgsGetType(parent))
	end
	local memo = createElement("dgs-dxmemo")
	dgsSetType(memo,"dgs-dxmemo")
	dgsSetData(memo,"imagebg",imagebg)
	dgsSetData(memo,"colorbg",colorbg or tocolor(200,200,200,255))
	dgsSetData(memo,"text",{})
	dgsSetData(memo,"textcolor",textcolor or tocolor(0,0,0,255))
	dgsSetData(memo,"textsize",{scalex or 1,scaley or 1})
	dgsSetData(memo,"cursorposXY",{0,1})
	dgsSetData(memo,"selectfrom",{1,1})
	dgsSetData(memo,"maskText","*")
	dgsSetData(memo,"showPos",0)
	dgsSetData(memo,"showLine",1)
	dgsSetData(memo,"cursorStyle",0)
	dgsSetData(memo,"cursorThick",1.2)
	dgsSetData(memo,"cursorOffset",{0,0})
	dgsSetData(memo,"readOnly",false)
	dgsSetData(memo,"font",systemFont)
	dgsSetData(memo,"side",0)
	dgsSetData(memo,"sidecolor",tocolor(0,0,0,255))
	dgsSetData(memo,"changeEventRnt",false)
	dgsSetData(memo,"useFloor",false)
	dgsSetData(memo,"selectmode",selectmode and false or true) ----true->选择色在文字底层;false->选择色在文字顶层
	dgsSetData(memo,"selectcolor",selectmode and tocolor(50,150,255,100) or tocolor(50,150,255,200))
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
	triggerEvent("onClientDgsDxGUIPreCreate",memo)
	calculateGuiPositionSize(memo,x,y,relative or false,sx,sy,relative or false,true)
	triggerEvent("onClientDgsDxGUICreate",memo)
	local sx,sy = dgsGetSize(memo,false)
	local renderTarget = dxCreateRenderTarget(sx-4,sy,true)
	dgsSetData(memo,"renderTarget",renderTarget)
	handleDxMemoText(memo,text)
	dgsDxMemoSetCaretPosition(memo,utf8.len(tostring(text)))
	return memo
end

function dgsDxMemoMoveCaret(memo,offset,lineoffset,noselect,noMoveLine)
	assert(dgsGetType(memo) == "dgs-dxmemo","@dgsDxMemoMoveCaret argument 1,expect dgs-dxmemo got "..dgsGetType(memo))
	assert(type(offset) == "number","@dgsDxMemoMoveCaret argument 2,expect number got "..type(offset))
	lineoffset = lineoffset or 0
	local xpos = dgsElementData[memo].cursorposXY[1]
	local line = dgsElementData[memo].cursorposXY[2]
	local textTable = dgsElementData[memo].text
	local text = textTable[line] or ""
	local pos,line = dgsDxMemoSeekPosition(textTable,xpos+math.floor(offset),line+math.floor(lineoffset),noMoveLine)
	local showPos,showLine = dgsElementData[memo].showPos,dgsElementData[memo].showLine
	local font = dgsElementData[memo].font
	local nowLen = dxGetTextWidth(utf8.sub(text,0,pos),dgsElementData[memo].textsize[1],font)
	local fontHeight = dxGetFontHeight(dgsElementData[memo].textsize[2],font)
	local size = dgsElementData[memo].absSize
	local targetLen = nowLen+showPos
	local targetLine = line-showLine
	local canHold = math.floor(size[2]/fontHeight)
	if targetLen > size[1]-4 then
		dgsSetData(memo,"showPos",size[1]-4-nowLen)
	elseif targetLen < 0 then
		dgsSetData(memo,"showPos",-nowLen)
	end
	if targetLine >= canHold then
		dgsSetData(memo,"showLine",line-canHold+1)
	elseif targetLine < 1 then
		dgsSetData(memo,"showLine",line)
	end
	dgsSetData(memo,"cursorposXY",{pos,line})
	if not noselect then
		dgsSetData(memo,"selectfrom",{pos,line})
	end
	resetTimer(MouseData.MemoTimer)
	MouseData.memoCursor = true
	return true
end

function dgsDxMemoSeekPosition(textTable,pos,line,noMoveLine)
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

function dgsDxMemoSetCaretPosition(memo,tpos,tline,noselect)
	assert(dgsGetType(memo) == "dgs-dxmemo","@dgsDxMemoSetCaretPosition argument 1,expect dgs-dxmemo got "..dgsGetType(memo))
	assert(type(tpos) == "number","@dgsDxMemoSetCaretPosition argument 2,expect number got "..type(tpos))
	local textTable = dgsElementData[memo].text
	local curpos = dgsElementData[memo].cursorposXY
	tline = tline or curpos[2]
	local text = textTable[tline] or ""
	local pos,line = dgsDxMemoSeekPosition(textTable,tpos,tline)
	local showPos,showLine = dgsElementData[memo].showPos,dgsElementData[memo].showLine
	local font = dgsElementData[memo].font
	local nowLen = dxGetTextWidth(utf8.sub(text,0,pos),dgsElementData[memo].textsize[1],font)
	local fontHeight = dxGetFontHeight(dgsElementData[memo].textsize[2],font)
	local size = dgsElementData[memo].absSize
	local targetLen = nowLen+showPos
	local targetLine = tline-showLine+1
	local canHold = math.floor(size[2]/fontHeight)
	if targetLen > size[1]-4 then
		dgsSetData(memo,"showPos",size[1]-4-nowLen)
	elseif targetLen < 0 then
		dgsSetData(memo,"showPos",-nowLen)
	end
	if targetLine >= canHold then
		dgsSetData(memo,"showLine",line-canHold+1)
	elseif targetLine < 0 then
		dgsSetData(memo,"showLine",line)
	end
	dgsSetData(memo,"cursorposXY",{pos,line})
	if not noselect then
		dgsSetData(memo,"selectfrom",{pos,line})
	end
	return true
end

function dgsDxMemoGetCaretPosition(memo,detail)
	assert(dgsGetType(memo) == "dgs-dxmemo","@dgsDxMemoGetCaretPosition argument 1,expect dgs-dxmemo got "..dgsGetType(memo))
	return dgsElementData[memo].cursorposXY[1],dgsElementData[memo].cursorposXY[2]
end

function dgsDxMemoSetCaretStyle(memo,style)
	assert(dgsGetType(memo) == "dgs-dxmemo","@dgsDxMemoSetCaretStyle argument 1,expect dgs-dxmemo got "..dgsGetType(memo))
	assert(type(style) == "number","@dgsDxMemoSetCaretStyle argument 2,expect number got "..type(style))
	return dgsSetData(memo,"cursorStyle",style)
end

--[[function dgsDxMemoSetMaxLength(memo,maxLength)
	assert(dgsGetType(memo) == "dgs-dxmemo","@dgsDxMemoSetMaxLength argument 1,expect dgs-dxmemo got "..dgsGetType(memo))
	assert(type(maxLength) == "number","@dgsDxMemoSetMaxLength argument 2,expect number got "..type(maxLength))
	local guimemo = dgsElementData[memo].memo
	dgsSetData(memo,"maxLength",maxLength)
	return guimemoSetMaxLength(guimemo,maxLength)
end

function dgsDxMemoGetMaxLength(memo,fromgui)
	assert(dgsGetType(memo) == "dgs-dxmemo","@dgsDxMemoGetMaxLength argument 1,expect dgs-dxmemo got "..dgsGetType(memo))
	local guimemo = dgsElementData[memo].memo
	if fromgui then
		return guiGetProperty(guimemo,"MaxTextLength")
	else
		return dgsElementData[memo].maxLength
	end
end]]

function dgsDxMemoSetReadOnly(memo,state)
	assert(dgsGetType(memo) == "dgs-dxmemo","@dgsDxMemoSetReadOnly argument 1,expect dgs-dxmemo got "..dgsGetType(memo))
	local guimemo = dgsElementData[memo].memo
	return dgsSetData(memo,"readOnly",state and true or false)
end

function dgsDxMemoGetReadOnly(memo)
	assert(dgsGetType(memo) == "dgs-dxmemo","@dgsDxMemoGetReadOnly argument 1,expect dgs-dxmemo got "..dgsGetType(memo))
	return dgsGetData(memo,"readOnly")
end

function configMemo(source)
	local mymemo = dgsGetData(source,"memo")
	local x,y = unpack(dgsGetData(source,"absSize"))
	guiSetSize(mymemo,x,y,false)
	local px,py = math.floor(x-4), math.floor(y)
	local renderTarget = dxCreateRenderTarget(px,py,true)
	dgsSetData(source,"renderTarget",renderTarget)
	local oldIndex,oldLine = dgsDxMemoGetCaretPosition(source)
	dgsDxMemoSetCaretPosition(source,1,0)
	dgsDxMemoSetCaretPosition(source,oldIndex,oldLine)
end

function resetMemo(x,y)
	if dgsGetType(MouseData.nowShow) == "dgs-dxmemo" then
		if MouseData.nowShow == MouseData.clickl then
			local pos,line = searchMemoMousePosition(MouseData.nowShow,x*sW,y*sH)
			dgsDxMemoSetCaretPosition(MouseData.nowShow,pos,line,true)
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
	local str = textTable
	if not noclear then
		dgsElementData[dxgui].text = {}
	end
	local _index,_line = dgsDxMemoGetCaretPosition(dxgui,true)
	local index,line = index or _index,line or _line
	local fixed = utf8.gsub(text,splitChar,splitChar2)
	local fixed = utf8.gsub(fixed,"	"," ")
	fixed = " "..fixed.." "
	local tab = split(fixed,splitChar2)
	tab[1] = utf8.sub(tab[1],2)
	tab[#tab] = utf8.sub(tab[#tab],1,utf8.len(tab[#tab])-1)
	local offset = 0
	if tab ~= 0 then
		if #tab == 1 then
			tab[1] = tab[1] or ""
			offset = utf8.len(tab[1])+1
			textTable[line] = utf8.insert(textTable[line] or "",index+1,tab[1])
		else
			tab[1] = tab[1] or ""
			offset = offset+utf8.len(tab[1])+1
			textTable[line] = textTable[line] or ""
			local txt1 = utf8.sub(textTable[line],0,index) or ""
			local txt2 = utf8.sub(textTable[line],index+1) or ""
			textTable[line] = (txt1)..(tab[1])
			for i=2,#tab do
				tab[i] = tab[i] or ""
				offset = offset+utf8.len(tab[i])+1
				local theline = line+i-1
				table.insert(textTable,theline,tab[i])
				if i == #tab then
					textTable[theline] = (tab[i] or "")..txt2
				end
			end
		end
		dgsElementData[dxgui].text = textTable
		if not noAffectCaret then
			if line < _line or (line == _line and index <= _index) then
				dgsDxMemoSetCaretPosition(dxgui,index+offset-1,line)
			end
		end
		triggerEvent("onClientDgsDxGUITextChange",dxgui,str)
	end
end

function dgsDxMemoDeleteText(dxgui,fromindex,fromline,toindex,toline,noAffectCaret)
	assert(dgsGetType(dxgui) == "dgs-dxmemo","@dgsDxMemoDeleteText argument 1,expect dgs-dxmemo got "..dgsGetType(dxgui))
	local textTable = dgsElementData[dxgui].text
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
	else
		textTable[fromline] = utf8.sub(textTable[fromline],0,fromindex)..utf8.sub(textTable[toline],toindex+1)
		for i=fromline+1,toline do
			table.remove(textTable,fromline+1)
		end
	end
	dgsElementData[dxgui].text = textTable
	if not noAffectCaret then
		local cpos = dgsElementData[dxgui].cursorposXY
		if cpos[2] > fromline then
			dgsDxMemoSetCaretPosition(dxgui,cpos[1]-(toindex-fromindex),cpos[2]-(toline-fromline))
		elseif cpos[2] == fromline and cpos[1] >= fromindex then
			dgsDxMemoSetCaretPosition(dxgui,fromindex,fromline)
		end
	end
end

function checkMemoMousePosition(button,state,x,y)
	if dgsGetType(source) == "dgs-dxmemo" then
		if state == "down" then
			local pos,line = searchMemoMousePosition(source,x,y)
			dgsDxMemoSetCaretPosition(source,pos,line)
		end
	end
end
addEventHandler("onClientDgsDxMouseClick",root,checkMemoMousePosition)

--[[function dgsDxMemoSetWhiteList(memo,str)
	assert(dgsGetType(memo) == "dgs-dxmemo","@dgsDxMemoSetWhiteList argument 1,expect dgs-dxmemo got "..dgsGetType(memo))
	if type(str) == "string" then
		dgsSetData(memo,"whiteList",str)
	else
		dgsSetData(memo,"whiteList",nil)
	end
end]]

function dgsDxMemoGetPartOfText(memo,cindex,cline,tindex,tline,delete)
	assert(dgsGetType(memo) == "dgs-dxmemo","@dgsDxMemoGetPartOfText argument 1,expect dgs-dxmemo got "..dgsGetType(memo))
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
		dgsDxMemoDeleteText(memo,cindex,cline,tindex,tline)
	end
	return outStr
end
