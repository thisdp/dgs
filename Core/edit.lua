----Speed UP
local mathFloor = math.floor
local utf8Sub = utf8.sub
----
GlobalEditParent = guiCreateLabel(-1,0,0,0,"",true)
local editsCount = 1
function dgsCreateEdit(x,y,sx,sy,text,relative,parent,textColor,scalex,scaley,bgImage,bgColor,selectMode)
	assert(type(x) == "number","Bad argument @dgsCreateEdit at argument 1, expect number got "..type(x))
	assert(type(y) == "number","Bad argument @dgsCreateEdit at argument 2, expect number got "..type(y))
	assert(type(sx) == "number","Bad argument @dgsCreateEdit at argument 3, expect number got "..type(sx))
	assert(type(sy) == "number","Bad argument @dgsCreateEdit at argument 4, expect number got "..type(sy))
	text = tostring(text)
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"@dgsCreateEdit argument 7,expect dgs-dxgui got "..dgsGetType(parent))
	end
	local edit = createElement("dgs-dxedit")
	local _x = dgsIsDxElement(parent) and dgsSetParent(edit,parent,true,true) or table.insert(CenterFatherTable,1,edit)
	dgsSetType(edit,"dgs-dxedit")
	dgsSetData(edit,"renderBuffer",{})
	dgsSetData(edit,"bgImage",bgImage or dgsCreateTextureFromStyle(styleSettings.edit.bgImage))
	dgsSetData(edit,"bgColor",bgColor or styleSettings.edit.bgColor)
	local textSizeX,textSizeY = tonumber(scalex) or styleSettings.edit.textSize[1], tonumber(scaley) or styleSettings.edit.textSize[2]
	dgsSetData(edit,"textSize",{textSizeX,textSizeY},true)
	dgsSetData(edit,"font",systemFont,true)
	dgsElementData[edit].text = ""
	dgsSetData(edit,"textColor",textColor or styleSettings.edit.textColor)
	dgsSetData(edit,"caretPos",0)
	dgsSetData(edit,"selectFrom",0)
	dgsSetData(edit,"masked",false)
	dgsSetData(edit,"maskText",styleSettings.edit.maskText)
	dgsSetData(edit,"showPos",0)
	dgsSetData(edit,"padding",styleSettings.edit.padding)
	dgsSetData(edit,"rightbottom",{"left","center"})
	dgsSetData(edit,"caretStyle",styleSettings.edit.caretStyle)
	dgsSetData(edit,"caretThick",styleSettings.edit.caretThick)
	dgsSetData(edit,"caretOffset",styleSettings.edit.caretOffset)
	dgsSetData(edit,"caretColor",styleSettings.edit.caretColor)
	dgsSetData(edit,"caretHeight",styleSettings.edit.caretHeight)
	dgsSetData(edit,"readOnly",false)
	dgsSetData(edit,"readOnlyCaretShow",false)
	dgsSetData(edit,"clearSelection",true)
	dgsSetData(edit,"enableTabSwitch",true)
	dgsSetData(edit,"savePositionSwitch",false)
	dgsSetData(edit,"lastSwitchPosition",-1)
	dgsSetData(edit,"lockView",false)
	dgsSetData(edit,"allowCopy",true)
	dgsSetData(edit,"selectColor",styleSettings.edit.selectColor)
	local gedit = guiCreateEdit(0,0,0,0,"" or "",true,GlobalEditParent)
	guiSetProperty(gedit,"ClippedByParent","False")
	dgsSetData(edit,"edit",gedit)
	dgsSetData(gedit,"dxedit",edit)
	guiSetAlpha(gedit,0)
	dgsSetData(edit,"maxLength",guiGetProperty(gedit,"MaxTextLength"))
	dgsSetData(edit,"editCounts",editsCount) --Tab Switch
	editsCount = editsCount+1
	insertResourceDxGUI(sourceResource,edit)
	calculateGuiPositionSize(edit,x,y,relative or false,sx,sy,relative or false,true)
	local sx,sy = dgsGetSize(edit,false)
	local padding = dgsElementData[edit].padding
	local sizex,sizey = sx-padding[1]*2,sy-padding[2]*2
	local renderTarget = dxCreateRenderTarget(mathFloor(sizex),mathFloor(sizey),true)
	dgsSetData(edit,"renderTarget",renderTarget)
	handleDxEditText(edit,text,false,true)
	dgsEditSetCaretPosition(edit,utf8.len(text))
	triggerEvent("onDgsCreate",edit)
	return edit
end

function dgsEditSetMasked(edit,masked)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditSetMasked at argument 1, expect dgs-dxedit got "..dgsGetType(edit))
	return dgsSetData(edit,"masked",masked and true or false)
end

function dgsEditGetMasked(edit)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditGetMasked at argument 1, expect dgs-dxedit got "..dgsGetType(edit))
	return dgsElementData[edit].masked
end

function dgsEditMoveCaret(edit,offset,selectText)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditMoveCaret at argument 1, expect dgs-dxedit got "..dgsGetType(edit))
	assert(type(offset) == "number","Bad argument @dgsEditMoveCaret at argument 2, expect number got "..type(offset))
	local text = dgsElementData[edit].text
	if dgsElementData[edit].masked then
		text = string.rep(dgsElementData[edit].maskText,utf8.len(text))
	end
	local pos = dgsElementData[edit].caretPos+mathFloor(offset)
	if pos < 0 then
		pos = 0
	elseif pos > utf8.len(text) then
		pos = utf8.len(text)
	end
	dgsSetData(edit,"caretPos",pos)
	local isReadOnlyShow = true
	if dgsElementData[edit].readOnly then
		isReadOnlyShow = dgsElementData[edit].readOnlyCaretShow
	end
	if not selectText or not isReadOnlyShow then
		dgsSetData(edit,"selectFrom",pos)
	end
	dgsEditRepositionShowPosition(edit,text)
	resetTimer(MouseData.EditTimer)
	MouseData.editCursor = true
	return true
end

function dgsEditSetCaretPosition(edit,pos,selectText)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditSetCaretPosition at argument 1, expect dgs-dxedit got "..dgsGetType(edit))
	assert(type(pos) == "number","Bad argument @dgsEditSetCaretPosition at argument 2, expect number got "..type(pos))
	local text = dgsElementData[edit].text
	if dgsElementData[edit].masked then
		text = string.rep(dgsElementData[edit].maskText,utf8.len(text))
	end
	if pos > utf8.len(text) then
		pos = utf8.len(text)
	elseif pos < 0 then
		pos = 0
	end
	dgsSetData(edit,"caretPos",mathFloor(pos))
	if not selectText then
		dgsSetData(edit,"selectFrom",mathFloor(pos))
	end
	dgsEditRepositionShowPosition(edit,text)
	resetTimer(MouseData.EditTimer)
	MouseData.editCursor = true
	return true
end

function dgsEditRepositionShowPosition(edit,text)
	local alignment = dgsElementData[edit].rightbottom
	local font = dgsElementData[edit].font
	local sx = dgsElementData[edit].absSize[1]
	local showPos = dgsElementData[edit].showPos
	local padding = dgsElementData[edit].padding
	local pos = dgsElementData[edit].caretPos
	if alignment[1] == "left" then
		local nowLen = dxGetTextWidth(utf8.sub(text,0,pos),dgsElementData[edit].textSize[1],font)
		if nowLen+showPos > sx-padding[1]*2 then
			dgsSetData(edit,"showPos",sx-padding[1]*2-nowLen)
		elseif nowLen+showPos < 0 then
			dgsSetData(edit,"showPos",-nowLen)
		end
	elseif alignment[1] == "right" then
		local nowLen = dxGetTextWidth(utf8.sub(text,pos+1),dgsElementData[edit].textSize[1],font)
		if nowLen+showPos > sx-padding[1]*2 then
			dgsSetData(edit,"showPos",sx-padding[1]*2-nowLen)
		elseif nowLen+showPos < 0 then
			dgsSetData(edit,"showPos",-nowLen)
		end
	elseif alignment[1] == "center" then
		local __width = dgsElementData[edit].textFontLen
		local nowLen = dxGetTextWidth(utf8.sub(text,0,pos),dgsElementData[edit].textSize[1],font)
		local checkCaret = sx/2+nowLen-__width/2+showPos/2
		if sx/2+nowLen-__width/2+showPos/2-padding[1] > sx-padding[1]*2 then
			dgsSetData(edit,"showPos",(sx/2-padding[1]-nowLen+__width/2)*2)
		elseif sx/2+nowLen-__width/2+showPos/2-padding[1] < 0 then
			dgsSetData(edit,"showPos",(padding[1]-sx/2-nowLen+__width/2)*2)
		end
	end
end

function dgsEditGetCaretPosition(edit)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditGetCaretPosition at argument 1, expect dgs-dxedit got "..dgsGetType(edit))
	return dgsElementData[edit].caretPos
end

function dgsEditSetCaretStyle(edit,style)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditSetCaretStyle at argument 1, expect dgs-dxedit got "..dgsGetType(edit))
	assert(type(style) == "number","Bad argument @dgsEditSetCaretStyle at argument 2, expect number got "..type(style))
	return dgsSetData(edit,"caretStyle",style)
end

function dgsEditGetCaretStyle(edit,style)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditGetCaretStyle at argument 1, expect dgs-dxedit got "..dgsGetType(edit))
	return dgsElementData[edit].caretStyle
end

function dgsEditSetMaxLength(edit,maxLength)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditSetMaxLength at argument 1, expect dgs-dxedit got "..dgsGetType(edit))
	assert(type(maxLength) == "number","Bad argument @dgsEditSetMaxLength at argument 2, expect number got "..type(maxLength))
	local guiedit = dgsElementData[edit].edit
	dgsSetData(edit,"maxLength",maxLength)
	return guiEditSetMaxLength(guiedit,maxLength)
end

function dgsEditGetMaxLength(edit,fromgui)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditGetMaxLength at argument 1, expect dgs-dxedit got "..dgsGetType(edit))
	local guiedit = dgsElementData[edit].edit
	if fromgui then
		return guiGetProperty(guiedit,"MaxTextLength")
	else
		return dgsElementData[edit].maxLength
	end
end

function dgsEditSetReadOnly(edit,state)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditSetReadOnly at argument 1, expect dgs-dxedit got "..dgsGetType(edit))
	local guiedit = dgsElementData[edit].edit
	return dgsSetData(edit,"readOnly",state and true or false)
end

function dgsEditGetReadOnly(edit)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditGetReadOnly at argument 1, expect dgs-dxedit got "..dgsGetType(edit))
	return dgsElementData[edit].readOnly
end

function dgsEditSetWhiteList(edit,str)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditSetWhiteList at argument 1, expect dgs-dxedit got "..dgsGetType(edit))
	if type(str) == "string" then
		dgsSetData(edit,"whiteList",str)
	else
		dgsSetData(edit,"whiteList",nil)
	end
end

function configEdit(source)
	local myedit = dgsElementData[source].edit
	local x,y = dgsElementData[source].absSize[1],dgsElementData[source].absSize[2]
	local padding = dgsElementData[source].padding
	local px,py = x-padding[1],y-padding[2]
	px,py = px-px%1,py-py%1
	local renderTarget = dxCreateRenderTarget(px,py,true)
	dgsSetData(source,"renderTarget",renderTarget)
	local oldPos = dgsEditGetCaretPosition(source)
	dgsEditSetCaretPosition(source,0)
	dgsEditSetCaretPosition(source,oldPos)
end

function resetEdit(x,y)
	if dgsGetType(MouseData.nowShow) == "dgs-dxedit" then
		if MouseData.nowShow == MouseData.clickl then
			local edit = dgsElementData[MouseData.nowShow].edit
			local pos = searchEditMousePosition(MouseData.nowShow,MouseX or x*sW, MouseY or y*sH)
			dgsEditSetCaretPosition(MouseData.nowShow,pos,true)
		end
	end
end
addEventHandler("onClientCursorMove",root,resetEdit)

function searchEditMousePosition(dxedit,posx,posy)
	local text = dgsElementData[dxedit].text
	local sfrom,sto = 0,utf8.len(text)
	if dgsElementData[dxedit].masked then
		text = string.rep(dgsElementData[dxedit].maskText,sto)
	end
	local font = dgsElementData[dxedit].font or systemFont
	local txtSizX = dgsElementData[dxedit].textSize[1]
	local size = dgsElementData[dxedit].absSize
	local offset = dgsElementData[dxedit].showPos
	local x = dgsGetPosition(dxedit,false,true)
	local alignment = dgsElementData[dxedit].rightbottom 
	local padding = dgsElementData[dxedit].padding
	local pos
	local alllen = dgsElementData[dxedit].textFontLen
	if alignment[1] == "left" then
		pos = posx-x-offset-padding[1]
	elseif alignment[1] == "center" then
		local sx,sy = dgsElementData[dxedit].absSize[1],dgsElementData[dxedit].absSize[2]
		pos = (alllen-size[1]-offset)*0.5-x+posx
	elseif alignment[1] == "right" then
		pos = alllen-(size[1]+x-posx-padding[1]-offset)
	end
	local templen = 0
	for i=1,sto do
		local stoSfrom_Half = (sto+sfrom)*0.5
		local strlen = dxGetTextWidth(utf8Sub(text,sfrom+1,stoSfrom_Half),txtSizX,font)
		local len1 = strlen+templen
		if pos < len1 then
			sto = mathFloor(stoSfrom_Half)
		elseif pos > len1 then
			sfrom = mathFloor(stoSfrom_Half)
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
	local lastWidth
	for i=sfrom,sto do
		local poslen1 = dxGetTextWidth(utf8Sub(text,sfrom+1,i),txtSizX,font)+start
		local theNext = dxGetTextWidth(utf8Sub(text,i+1,i+1),txtSizX,font)*0.5
		local offsetR = theNext+poslen1
		local theLast = lastWidth or dxGetTextWidth(utf8Sub(text,i,i),txtSizX,font)*0.5
		lastWidth = theNext
		local offsetL = poslen1-theLast
		if i <= sfrom and pos <= offsetL then
			return sfrom
		elseif i >= sto and pos >= offsetR then
			return sto
		elseif pos >= offsetL and pos <= offsetR then
			return i
		end
	end
	return -1
end

function checkEditMousePosition(button,state,x,y)
	if dgsGetType(source) == "dgs-dxedit" then
		if state == "down" then
			local pos = searchEditMousePosition(source,x,y)
			dgsEditSetCaretPosition(source,pos)
		end
	end
end
addEventHandler("onDgsMouseClick",root,checkEditMousePosition)

addEventHandler("onClientGUIAccepted",resourceRoot,function()
	local mydxedit = dgsElementData[source].dxedit
	if dgsGetType(mydxedit) == "dgs-dxedit" then
		triggerEvent("onDgsEditAccepted",mydxedit)
		local cmd = dgsElementData[mydxedit].mycmd
		if dgsGetType(cmd) == "dgs-dxcmd" then
			local text = dgsElementData[mydxedit].text
			if text ~= "" then
				receiveCmdEditInput(cmd,text)
			end
			dgsEditClearText(mydxedit)
		end
	end
end)

addEventHandler("onDgsEditPreSwitch",resourceRoot,function()
	if not wasEventCancelled() then
		if not dgsElementData[source].enableTabSwitch then return end
		local parent = FatherTable[source]
		local theTable = isElement(parent) and ChildrenTable[parent] or (dgsElementData[source].alwaysOnBottom and BottomFatherTable or CenterFatherTable)
		local id = dgsElementData[source].editCounts
		if id then
			local theNext
			local theFirst
			for k,v in ipairs(theTable) do
				local editCounts = dgsElementData[v].editCounts
				if editCounts and dgsElementData[v].enabled and dgsElementData[v].visible and not dgsElementData[v].readOnly then
					if id ~= editCounts and dgsGetType(v) == "dgs-dxedit" and dgsElementData[v].enableTabSwitch then
						if editCounts < id then
							theFirst = theFirst and (dgsElementData[theFirst].editCounts > editCounts and v or theFirst) or v
						else
							theNext = theNext and (dgsElementData[theNext].editCounts > editCounts and v or theNext) or v
						end
					end
				end
			end
			local theResult = theNext or theFirst
			if theResult then
				if dgsElementData[source].savePositionSwitch then
					dgsSetData(source,"lastSwitchPosition",dgsEditGetCaretPosition(source))
				else
					dgsSetData(source,"lastSwitchPosition",-1)
				end
				dgsBringToFront(theResult)
				if dgsElementData[theResult].savePositionSwitch and dgsElementData[theResult].lastSwitchPosition >= 0 then
					dgsEditSetCaretPosition(theResult,dgsElementData[theResult].lastSwitchPosition)
				else
					dgsEditSetCaretPosition(theResult,utf8.len(dgsElementData[theResult].text or ""))
				end
				triggerEvent("onDgsEditSwitched",theResult,source)
			end
		end
	end
end)

local splitChar = "\r\n"
local splitChar2 = "\n"
function handleDxEditText(edit,text,noclear,noAffectCaret,index)
	local textData = dgsElementData[edit].text
	if not noclear then
		dgsElementData[edit].text = ""
		textData = dgsElementData[edit].text
		dgsSetData(edit,"caretPos",0)
		dgsSetData(edit,"selectFrom",0)
	end
	local font = dgsElementData[edit].font
	local textSize = dgsElementData[edit].textSize
	local _index = dgsEditGetCaretPosition(edit,true)
	local index = index or _index
	local text = utf8.gsub(text,dgsElementData[edit].whiteList or "","") or text
	local textData = utf8.sub(textData,1,index)..text..utf8.sub(textData,index+1)
	dgsElementData[edit].text = textData
	dgsElementData[edit].textFontLen = dxGetTextWidth(dgsElementData[edit].text,dgsElementData[edit].textSize[1],dgsElementData[edit].font)
	if not noAffectCaret then
		if index <= _index then
			dgsEditSetCaretPosition(edit,index+utf8.len(text))
		end
	end
	triggerEvent("onDgsTextChange",edit)
end

function dgsEditInsertText(edit,index,text)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditInsertText at argument 1, expect dgs-dxedit got "..dgsGetType(edit))
	assert(dgsGetType(index) == "number","Bad argument @dgsEditInsertText at argument 2, expect number got "..dgsGetType(index))
	return handleDxEditText(edit,tostring(text),true,index)
end

function dgsEditDeleteText(edit,fromindex,toindex,noAffectCaret)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditDeleteText at argument 1, expect dgs-dxedit got "..dgsGetType(edit))
	assert(dgsGetType(fromindex) == "number","Bad argument @dgsEditDeleteText at argument 2, expect number got "..dgsGetType(fromindex))
	assert(dgsGetType(toindex) == "number","Bad argument @dgsEditDeleteText at argument 3, expect number got "..dgsGetType(toindex))
	local text = dgsElementData[edit].text
	local textLen = utf8.len(text)
	local fromindex = (fromindex < 0 and 0) or (fromindex > textLen and textLen) or fromindex
	local toindex = (toindex < 0 and 0) or (toindex > textLen and textLen) or toindex
	if fromindex > toindex then
		local temp = fromindex
		fromindex = toindex
		toindex = temp
	end
	local deleted = dxGetTextWidth(utf8.sub(text,fromindex+1,toindex),dgsElementData[edit].textSize[1],dgsElementData[edit].font)
	local text = utf8.sub(text,1,fromindex)..utf8.sub(text,toindex+1)
	dgsElementData[edit].text = text
	if not noAffectCaret then
		local cpos = dgsElementData[edit].caretPos
		if cpos >= fromindex then
			dgsEditSetCaretPosition(edit,fromindex)
		end
	end
	local showPos = dgsElementData[edit].showPos
	if showPos > 0 then
		showPos = showPos - deleted
		if showPos < 0 then
			showPos = 0
		end
	else
		showPos = showPos + deleted
		if showPos > 0 then
			showPos = 0
		end
	end
	dgsElementData[edit].showPos = showPos-showPos%1
	dgsElementData[edit].textFontLen = dxGetTextWidth(dgsElementData[edit].text,dgsElementData[edit].textSize[1],dgsElementData[edit].font)
	triggerEvent("onDgsTextChange",edit)
end

function dgsEditClearText(edit)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditClearText at argument 1, expect dgs-dxedit got "..dgsGetType(edit))
	dgsElementData[edit].text = ""
	dgsSetData(edit,"caretPos",0)
	dgsSetData(edit,"selectFrom",0)
	dgsElementData[edit].textFontLen = 0
	triggerEvent("onDgsTextChange",edit)
	return true
end

function dgsEditGetPartOfText(edit,fromindex,toindex,delete)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditGetPartOfText at argument 1, expect dgs-dxedit got "..dgsGetType(edit))
	local text = dgsElementData[edit].text
	local textLen = utf8.len(text)
	local fromindex,toindex = fromindex or 0,toindex or textLen
	local fromindex = (fromindex < 0 and 0) or (fromindex > textLen and textLen) or fromindex
	local toindex = (toindex < 0 and 0) or (toindex > textLen and textLen) or toindex
	if fromindex > toindex then
		local temp = fromindex
		fromindex = toindex
		toindex = temp
	end
	if delete then
		dgsEditDeleteText(edit,fromindex,toindex)
	end
	return utf8.sub(text,fromindex+1,toindex)
end

VerticalAlign = {top=true,center=true,bottom=true}
HorizontalAlign = {left=true,center=true,right=true}
function dgsEditSetHorizontalAlign(edit,align)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditSetHorizontalAlign at argument 1, except a dgs-dxedit got "..dgsGetType(edit))
	assert(HorizontalAlign[align],"Bad argument @dgsEditSetHorizontalAlign at argument 2, except a string [left/center/right], got"..tostring(align))
	local rightbottom = dgsElementData[edit].rightbottom
	return dgsSetData(edit,"rightbottom",{align,rightbottom[2]})
end

function dgsEditSetVerticalAlign(edit,align)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditSetVerticalAlign at argument 1, except a dgs-dxedit got "..dgsGetType(edit))
	assert(VerticalAlign[align],"Bad argument @dgsEditSetVerticalAlign at argument 2, except a string [top/center/bottom], got"..tostring(align))
	local rightbottom = dgsElementData[edit].rightbottom
	return dgsSetData(edit,"rightbottom",{rightbottom[1],align})
end

function dgsEditGetHorizontalAlign(edit)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditGetHorizontalAlign at argument 1, except a dgs-dxedit got "..dgsGetType(edit))
	local rightbottom = dgsElementData[edit].rightbottom
	return rightbottom[1]
end

function dgsEditGetVerticalAlign(edit)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditGetVerticalAlign at argument 1, except a dgs-dxedit got "..dgsGetType(edit))
	local rightbottom = dgsElementData[edit].rightbottom
	return rightbottom[2]
end

	
addEventHandler("onClientGUIChanged",resourceRoot,function()
	if not dgsElementData[source] then return end
	if getElementType(source) == "gui-edit" then
		local myedit = dgsElementData[source].dxedit
		if isElement(myedit) then
			if source == dgsElementData[myedit].edit then
				local text = guiGetText(source)
				local cool = dgsElementData[myedit].CoolTime
				if #text ~= 0 and not cool then
					local caretPos = dgsElementData[myedit].caretPos
					local selectFrom = dgsElementData[myedit].selectFrom
					dgsEditDeleteText(myedit,caretPos,selectFrom)
					handleDxEditText(myedit,text,true)
					dgsElementData[myedit].CoolTime = true
					guiSetText(source,"")
					dgsElementData[myedit].CoolTime = false
				end
			end
		end
	end
end)
