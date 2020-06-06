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
local utf8Sub = utf8.sub
local utf8Len = utf8.len
local utf8Gsub = utf8.gsub
local strRep = string.rep
local tableInsert = table.insert
local tableRemove = table.remove
local strChar = string.char
local _dxGetTextWidth = dxGetTextWidth
local mathMin = math.min
local mathMax = math.max
local acceptedAlignment = {
	top=2,
	bottom=2,
	center=0,
	right=1,
	left=1,
}

----Initialize
VerticalAlign = {top=true,center=true,bottom=true}
HorizontalAlign = {left=true,center=true,right=true}
GlobalEditParent = guiCreateLabel(-1,0,0,0,"",true)
GlobalEdit = guiCreateEdit(-1,0,0,0,"",true,GlobalEditParent)
dgsSetData(GlobalEdit,"linkedDxEdit",nil)
local splitChar = "\r\n"
local splitChar2 = "\n"
local editsCount = 1
----
function dgsCreateEdit(x,y,sx,sy,text,relative,parent,textColor,scalex,scaley,bgImage,bgColor,selectMode)
	assert(type(x) == "number","Bad argument @dgsCreateEdit at argument 1, expect number, got "..type(x))
	assert(type(y) == "number","Bad argument @dgsCreateEdit at argument 2, expect number, got "..type(y))
	assert(type(sx) == "number","Bad argument @dgsCreateEdit at argument 3, expect number, got "..type(sx))
	assert(type(sy) == "number","Bad argument @dgsCreateEdit at argument 4, expect number, got "..type(sy))
	text = tostring(text)
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"@dgsCreateEdit argument 7,expect dgs-dxgui, got "..dgsGetType(parent))
	end
	local edit = createElement("dgs-dxedit")
	local _x = dgsIsDxElement(parent) and dgsSetParent(edit,parent,true,true) or tableInsert(CenterFatherTable,edit)
	dgsSetType(edit,"dgs-dxedit")
	dgsSetData(edit,"renderBuffer",{})
	dgsSetData(edit,"bgColor",bgColor or styleSettings.edit.bgColor)
	dgsSetData(edit,"bgImage",bgImage or dgsCreateTextureFromStyle(styleSettings.edit.bgImage))
	dgsSetData(edit,"bgColorBlur",styleSettings.edit.bgColorBlur)
	dgsSetData(edit,"bgImageBlur",dgsCreateTextureFromStyle(styleSettings.edit.bgImageBlur))
	local textSizeX,textSizeY = tonumber(scalex) or styleSettings.edit.textSize[1], tonumber(scaley) or styleSettings.edit.textSize[2]
	dgsSetData(edit,"textSize",{textSizeX,textSizeY},true)
	dgsSetData(edit,"font",styleSettings.edit.font or systemFont,true)
	dgsElementData[edit].text = ""
	dgsSetData(edit,"textColor",textColor or styleSettings.edit.textColor)
	dgsSetData(edit,"caretPos",0)
	dgsSetData(edit,"selectFrom",0)
	dgsSetData(edit,"masked",false)
	dgsSetData(edit,"maskText",styleSettings.edit.maskText)
	dgsSetData(edit,"showPos",0)
	dgsSetData(edit,"placeHolder",styleSettings.edit.placeHolder)
	dgsSetData(edit,"placeHolderFont",systemFont)
	dgsSetData(edit,"placeHolderColor",styleSettings.edit.placeHolderColor)
	dgsSetData(edit,"placeHolderColorcoded",styleSettings.edit.placeHolderColorcoded)
	dgsSetData(edit,"placeHolderOffset",styleSettings.edit.placeHolderOffset)
	dgsSetData(edit,"placeHolderIgnoreRenderTarget",styleSettings.edit.placeHolderIgnoreRenderTarget)
	dgsSetData(edit,"padding",styleSettings.edit.padding,true)
	dgsSetData(edit,"alignment",{"left","center"})
	dgsSetData(edit,"caretStyle",styleSettings.edit.caretStyle)
	dgsSetData(edit,"caretThick",styleSettings.edit.caretThick)
	dgsSetData(edit,"caretOffset",styleSettings.edit.caretOffset)
	dgsSetData(edit,"caretColor",styleSettings.edit.caretColor)
	dgsSetData(edit,"caretHeight",styleSettings.edit.caretHeight)
	dgsSetData(edit,"readOnly",false)
	dgsSetData(edit,"readOnlyCaretShow",false)
	dgsSetData(edit,"clearSelection",true)
	dgsSetData(edit,"enableTabSwitch",true)
	dgsSetData(edit,"clearSwitchPos",false)
	dgsSetData(edit,"lastSwitchPosition",-1)
	dgsSetData(edit,"underlineOffset",0)
	dgsSetData(edit,"lockView",false)
	dgsSetData(edit,"allowCopy",true)
	dgsSetData(edit,"autoCompleteShow",false)
	dgsSetData(edit,"autoCompleteTextColor",nil)
	dgsSetData(edit,"autoCompleteSkip",false)
	dgsSetData(edit,"autoComplete",{})
	dgsSetData(edit,"autoCompleteConfirmKey","tab")
	dgsSetData(edit,"selectColor",styleSettings.edit.selectColor)
	dgsSetData(edit,"selectColorBlur",styleSettings.edit.selectColorBlur)
	dgsSetData(edit,"historyMaxRecords",100)
	dgsSetData(edit,"enableRedoUndoRecord",true)
	dgsSetData(edit,"undoHistory",{})
	dgsSetData(edit,"redoHistory",{})
	dgsSetData(edit,"typingSound",styleSettings.edit.typingSound)
	dgsSetData(edit,"maxLength",0x3FFFFFFF)
	dgsSetData(edit,"rtl",nil)	--nil: auto; false:disabled; true: enabled
	dgsSetData(edit,"editCounts",editsCount) --Tab Switch
	editsCount = editsCount+1
	calculateGuiPositionSize(edit,x,y,relative or false,sx,sy,relative or false,true)
	local sx,sy = dgsGetSize(edit,false)
	local padding = dgsElementData[edit].padding
	local sizex,sizey = sx-padding[1]*2,sy-padding[2]*2
	sizex,sizey = sizex-sizex%1,sizey-sizey%1
	local renderTarget,err = dxCreateRenderTarget(sizex,sizey,true,edit)
	if renderTarget ~= false then
		dgsAttachToAutoDestroy(renderTarget,edit,-1)
	else
		outputDebugString(err)
	end
	dgsSetData(edit,"renderTarget",renderTarget)
	handleDxEditText(edit,text,false,true)
	dgsEditSetCaretPosition(edit,utf8Len(text))
	addEventHandler("onDgsTextChange",edit,function()
		if not dgsElementData[source].autoCompleteSkip then
			local text = dgsElementData[source].text
			dgsSetData(source,"autoCompleteShow",false)
			if text ~= "" then
				local lowertxt = utf8.lower(text)
				local textLen = utf8.len(text)
				local acTable = dgsElementData[source].autoComplete
				for k,v in pairs(acTable) do
					if v == true then
						if utf8.sub(k,1,textLen) == text then
							dgsSetData(source,"autoCompleteShow",{k,k})
							break
						end
					elseif v == false then
						if utf8.lower(utf8.sub(k,1,textLen)) == lowertxt then
							dgsSetData(source,"autoCompleteShow",{k,text..utf8.sub(k,textLen+1)})
							break
						end
					end
				end
			end
		end
	end,false)
	triggerEvent("onDgsCreate",edit,sourceResource)
	return edit
end

function dgsEditSetMasked(edit,masked)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditSetMasked at argument 1, expect dgs-dxedit, got "..dgsGetType(edit))
	return dgsSetData(edit,"masked",masked and true or false)
end

function dgsEditGetMasked(edit)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditGetMasked at argument 1, expect dgs-dxedit, got "..dgsGetType(edit))
	return dgsElementData[edit].masked
end

function dgsEditMoveCaret(edit,offset,selectText)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditMoveCaret at argument 1, expect dgs-dxedit, got "..dgsGetType(edit))
	assert(type(offset) == "number","Bad argument @dgsEditMoveCaret at argument 2, expect number, got "..type(offset))
	local text = dgsElementData[edit].text
	if dgsElementData[edit].masked then
		text = strRep(dgsElementData[edit].maskText,utf8Len(text))
	end
	local pos = dgsElementData[edit].caretPos+mathFloor(offset)
	if pos < 0 then
		pos = 0
	elseif pos > utf8Len(text) then
		pos = utf8Len(text)
	end
	dgsSetData(edit,"caretPos",pos)
	local isReadOnlyShow = true
	if dgsElementData[edit].readOnly then
		isReadOnlyShow = dgsElementData[edit].readOnlyCaretShow
	end
	if not selectText or not isReadOnlyShow then
		dgsSetData(edit,"selectFrom",pos)
	end
	dgsEditAlignmentShowPosition(edit,text)
	resetTimer(MouseData.EditMemoTimer)
	MouseData.editMemoCursor = true
	return true
end

function dgsEditSetCaretPosition(edit,pos,doSelect)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditSetCaretPosition at argument 1, expect dgs-dxedit, got "..dgsGetType(edit))
	assert(type(pos) == "number","Bad argument @dgsEditSetCaretPosition at argument 2, expect number, got "..type(pos))
	local text = dgsElementData[edit].text
	if dgsElementData[edit].masked then
		text = strRep(dgsElementData[edit].maskText,utf8Len(text))
	end
	if pos > utf8Len(text) then
		pos = utf8Len(text)
	elseif pos < 0 then
		pos = 0
	end
	dgsSetData(edit,"caretPos",mathFloor(pos))
	if not doSelect then
		dgsSetData(edit,"selectFrom",mathFloor(pos))
	end
	dgsEditAlignmentShowPosition(edit,text)
	resetTimer(MouseData.EditMemoTimer)
	MouseData.editMemoCursor = true
	return true
end

function dgsEditGetCaretPosition(edit)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditGetCaretPosition at argument 1, expect dgs-dxedit, got "..dgsGetType(edit))
	return dgsElementData[edit].caretPos
end

function dgsEditSetCaretStyle(edit,style)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditSetCaretStyle at argument 1, expect dgs-dxedit, got "..dgsGetType(edit))
	assert(type(style) == "number","Bad argument @dgsEditSetCaretStyle at argument 2, expect number, got "..type(style))
	return dgsSetData(edit,"caretStyle",style)
end

function dgsEditGetCaretStyle(edit,style)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditGetCaretStyle at argument 1, expect dgs-dxedit, got "..dgsGetType(edit))
	return dgsElementData[edit].caretStyle
end

function dgsEditSetMaxLength(edit,maxLength,nonTextCut)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditSetMaxLength at argument 1, expect dgs-dxedit, got "..dgsGetType(edit))
	assert(type(maxLength) == "number","Bad argument @dgsEditSetMaxLength at argument 2, expect number, got "..type(maxLength))
	if not nonTextCut then
		local text = dgsElementData[edit].text
		dgsEditDeleteText(edit,maxLength,utf8Len(text),true)
	end
	return dgsSetData(edit,"maxLength",maxLength)
end

function dgsEditGetMaxLength(edit)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditGetMaxLength at argument 1, expect dgs-dxedit, got "..dgsGetType(edit))
	return dgsElementData[edit].maxLength
end

function dgsEditSetReadOnly(edit,state)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditSetReadOnly at argument 1, expect dgs-dxedit, got "..dgsGetType(edit))
	return dgsSetData(edit,"readOnly",state and true or false)
end

function dgsEditGetReadOnly(edit)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditGetReadOnly at argument 1, expect dgs-dxedit, got "..dgsGetType(edit))
	return dgsElementData[edit].readOnly
end

function dgsEditSetWhiteList(edit,str)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditSetWhiteList at argument 1, expect dgs-dxedit, got "..dgsGetType(edit))
	if type(str) == "string" then
		dgsSetData(edit,"whiteList",str)
	else
		dgsSetData(edit,"whiteList",nil)
	end
	
	local font = dgsElementData[edit].font or systemFont
	local textSize = dgsElementData[edit].textSize
	local index = dgsEditGetCaretPosition(edit,true)
	local whiteList = str or ""
	local text = utf8Gsub(dgsElementData[edit].text,whiteList,"")
	local textLen = utf8Len(text)
	dgsElementData[edit].text = text
	if dgsElementData[edit].masked then
		text = strRep(dgsElementData[edit].maskText,utf8Len(text))
	end
	dgsElementData[edit].textFontLen = _dxGetTextWidth(text,textSize[1],font)
	if index >= textLen then
		dgsEditSetCaretPosition(edit,textLen)
	end
	dgsSetData(edit,"undoHistory",{})
	dgsSetData(edit,"redoHistory",{})
	triggerEvent("onDgsTextChange",edit)
end

function dgsEditInsertText(edit,index,text)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditInsertText at argument 1, expect dgs-dxedit, got "..dgsGetType(edit))
	assert(dgsGetType(index) == "number","Bad argument @dgsEditInsertText at argument 2, expect number, got "..dgsGetType(index))
	return handleDxEditText(edit,tostring(text),true,index)
end

function dgsEditReplaceText(edit,fromIndex,toIndex,text,noAffectCaret,historyRecState)
	local index = mathMin(fromIndex,toIndex)
	local prevText = dgsElementData[edit].text
	local deletedText = dgsEditDeleteText(edit,fromIndex,toIndex,noAffectCaret,0)
	local textIndex,textLength = handleDxEditText(edit,text,true,noAffectCaret,index,0)
	local caretPos = dgsEditGetCaretPosition(edit)
	if dgsElementData[edit].enableRedoUndoRecord then
		historyRecState = historyRecState or 1
		if historyRecState ~= 0 then
			return dgsEditSaveHistory(edit,historyRecState,3,1,mathMin(fromIndex,toIndex),textLength or utf8Len(text),deletedText)
		end
	end
	return true
end

function dgsEditDeleteText(edit,fromIndex,toIndex,noAffectCaret,historyRecState)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditDeleteText at argument 1, expect dgs-dxedit, got "..dgsGetType(edit))
	assert(dgsGetType(fromIndex) == "number","Bad argument @dgsEditDeleteText at argument 2, expect number, got "..dgsGetType(fromIndex))
	assert(dgsGetType(toIndex) == "number","Bad argument @dgsEditDeleteText at argument 3, expect number, got "..dgsGetType(toIndex))
	local text = dgsElementData[edit].text
	local textLen = utf8Len(text)
	local isMask = dgsElementData[edit].masked
	local fromIndex = (fromIndex < 0 and 0) or (fromIndex > textLen and textLen) or fromIndex
	local toIndex = (toIndex < 0 and 0) or (toIndex > textLen and textLen) or toIndex
	if fromIndex > toIndex then
		fromIndex,toIndex = toIndex,fromIndex
	end
	local _deletedText = utf8Sub(text,fromIndex+1,toIndex)
	local deletedText = _deletedText
	if isMask then
		deletedText = strRep(dgsElementData[edit].maskText,utf8Len(_deletedText))
	end
	local deleted = _dxGetTextWidth(deletedText,dgsElementData[edit].textSize[1],dgsElementData[edit].font)
	local text = utf8Sub(text,1,fromIndex)..utf8Sub(text,toIndex+1)
	dgsElementData[edit].text = text
	if not noAffectCaret then
		if dgsElementData[edit].caretPos >= fromIndex then
			dgsEditSetCaretPosition(edit,fromIndex)
		end
	end
	if dgsElementData[edit].enableRedoUndoRecord then
		historyRecState = historyRecState or 1
		if historyRecState ~= 0 and toIndex-fromIndex ~= 0 then
			dgsEditSaveHistory(edit,historyRecState,1,toIndex-fromIndex == 1 and 1 or 2,fromIndex,_deletedText)
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
	if dgsElementData[edit].masked then
		text = strRep(dgsElementData[edit].maskText,utf8Len(text))
	end
	dgsElementData[edit].textFontLen = _dxGetTextWidth(text,dgsElementData[edit].textSize[1],dgsElementData[edit].font)
	triggerEvent("onDgsTextChange",edit)
	return deletedText
end

function dgsEditClearText(edit)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditClearText at argument 1, expect dgs-dxedit, got "..dgsGetType(edit))
	dgsElementData[edit].text = ""
	dgsSetData(edit,"caretPos",0)
	dgsSetData(edit,"selectFrom",0)
	dgsElementData[edit].textFontLen = 0
	triggerEvent("onDgsTextChange",edit)
	return true
end

function dgsEditGetPartOfText(edit,fromIndex,toIndex,delete)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditGetPartOfText at argument 1, expect dgs-dxedit, got "..dgsGetType(edit))
	local text = dgsElementData[edit].text
	local textLen = utf8Len(text)
	local fromIndex,toIndex = fromIndex or 0,toIndex or textLen
	local fromIndex = (fromIndex < 0 and 0) or (fromIndex > textLen and textLen) or fromIndex
	local toIndex = (toIndex < 0 and 0) or (toIndex > textLen and textLen) or toIndex
	if fromIndex > toIndex then
		local temp = fromIndex
		fromIndex = toIndex
		toIndex = temp
	end
	if delete then
		dgsEditDeleteText(edit,fromIndex,toIndex)
	end
	return utf8Sub(text,fromIndex+1,toIndex)
end

function dgsEditSetHorizontalAlign(edit,align)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditSetHorizontalAlign at argument 1, except a dgs-dxedit, got "..dgsGetType(edit))
	assert(HorizontalAlign[align],"Bad argument @dgsEditSetHorizontalAlign at argument 2, except a string [left/center/right], got"..tostring(align))
	local alignment = dgsElementData[edit].alignment
	return dgsSetData(edit,"alignment",{align,alignment[2]})
end

function dgsEditSetVerticalAlign(edit,align)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditSetVerticalAlign at argument 1, except a dgs-dxedit, got "..dgsGetType(edit))
	assert(VerticalAlign[align],"Bad argument @dgsEditSetVerticalAlign at argument 2, except a string [top/center/bottom], got"..tostring(align))
	local alignment = dgsElementData[edit].alignment
	return dgsSetData(edit,"alignment",{alignment[1],align})
end

function dgsEditGetHorizontalAlign(edit)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditGetHorizontalAlign at argument 1, except a dgs-dxedit, got "..dgsGetType(edit))
	local alignment = dgsElementData[edit].alignment
	return alignment[1]
end

function dgsEditGetVerticalAlign(edit)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditGetVerticalAlign at argument 1, except a dgs-dxedit, got "..dgsGetType(edit))
	local alignment = dgsElementData[edit].alignment
	return alignment[2]
end

function dgsEditSetUnderlined(edit,state)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditSetUnderlined at argument 1, except a dgs-dxedit, got "..dgsGetType(edit))
	return dgsSetData(edit,"underline",state and true or false)
end

function dgsEditGetUnderlined(edit,state)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditGetUnderlined at argument 1, except a dgs-dxedit, got "..dgsGetType(edit))
	return dgsElementData[edit].underline
end

-----------------Internal Functions
function configEdit(edit)
	local x,y = dgsElementData[edit].absSize[1],dgsElementData[edit].absSize[2]
	local padding = dgsElementData[edit].padding
	local px,py = x-padding[1]*2,y-padding[2]*2
	px,py = px-px%1,py-py%1
	local renderTarget,err = dxCreateRenderTarget(px,py,true,edit)
	if renderTarget ~= false then
		dgsAttachToAutoDestroy(renderTarget,edit,-1)
	else
		outputDebugString(err)
	end
	dgsAttachToAutoDestroy(renderTarget,edit,1)
	dgsSetData(edit,"renderTarget",renderTarget)
	local oldPos = dgsEditGetCaretPosition(edit)
	dgsEditSetCaretPosition(edit,0)
	dgsEditSetCaretPosition(edit,oldPos)
end

function resetEdit(x,y)
	if dgsGetType(MouseData.nowShow) == "dgs-dxedit" then
		if MouseData.nowShow == MouseData.clickl then
			local pos = searchEditMousePosition(MouseData.nowShow,MouseX or x*sW, MouseY or y*sH)
			dgsEditSetCaretPosition(MouseData.nowShow,pos,true)
		end
	end
end
addEventHandler("onClientCursorMove",root,resetEdit)

function searchEditMousePosition(dxedit,posx)
	local text
	--[[if dgsElementData[dxedit].isRTL then
		text = dgsElementData[dxedit].text:reverse()
	else
		text = dgsElementData[dxedit].text
	end]]
	text = dgsElementData[dxedit].text
	local sfrom,sto = 0,utf8Len(text)
	if dgsElementData[dxedit].masked then
		text = strRep(dgsElementData[dxedit].maskText,sto)
	end
	local font = dgsElementData[dxedit].font or systemFont
	local txtSizX = dgsElementData[dxedit].textSize[1]
	local size = dgsElementData[dxedit].absSize
	local offset = dgsElementData[dxedit].showPos
	local x = dgsGetPosition(dxedit,false,true)
	local alignment = dgsElementData[dxedit].alignment 
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
		if sto-sfrom <= 10 then
			break
		end
	end
	local start = _dxGetTextWidth(utf8Sub(text,0,sfrom),txtSizX,font)
	local lastWidth
	for i=sfrom,sto do
		local Next = _dxGetTextWidth(utf8Sub(text,i+1,i+1),txtSizX,font)*0.5
		local offsetR = Next+start
		local Last = lastWidth or _dxGetTextWidth(utf8Sub(text,i,i),txtSizX,font)*0.5
		lastWidth = Next
		local offsetL = start-Last
		if i <= sfrom and pos <= offsetL then
			return sfrom
		elseif i >= sto and pos >= offsetR then
			return sto
		elseif pos >= offsetL and pos <= offsetR then
			return i
		end
		start = start + Next*2
	end
	return -1
end

function checkEditMousePosition(button,state,x,y)
	if dgsGetType(source) == "dgs-dxedit" then
		if state == "down" then
			local shift = getKeyState("lshift") or getKeyState("rshift")
			local pos = searchEditMousePosition(source,x)
			dgsEditSetCaretPosition(source,pos,shift)
		end
	end
end
addEventHandler("onDgsMouseClick",root,checkEditMousePosition)

addEventHandler("onClientGUIAccepted",resourceRoot,function()
	local dxEdit = dgsElementData[source].linkedDxEdit
	if dgsGetType(dxEdit) == "dgs-dxedit" then
		triggerEvent("onDgsEditAccepted",dxEdit)
	end
end)

addEventHandler("onDgsEditPreSwitch",resourceRoot,function()
	if not wasEventCancelled() then
		if not dgsElementData[source].enableTabSwitch then return end
		local parent = FatherTable[source]
		local theTable = isElement(parent) and ChildrenTable[parent] or (dgsElementData[source].alwaysOnBottom and BottomFatherTable or CenterFatherTable)
		local id = dgsElementData[source].editCounts
		if id then
			local Next,theFirst
			for k,v in ipairs(theTable) do
				local editCounts = dgsElementData[v].editCounts
				if editCounts and dgsElementData[v].enabled and dgsElementData[v].visible and not dgsElementData[v].readOnly then
					if id ~= editCounts and dgsGetType(v) == "dgs-dxedit" and dgsElementData[v].enableTabSwitch then
						if editCounts < id then
							theFirst = theFirst and (dgsElementData[theFirst].editCounts > editCounts and v or theFirst) or v
						else
							Next = Next and (dgsElementData[Next].editCounts > editCounts and v or Next) or v
						end
					end
				end
			end
			local theResult = Next or theFirst
			if theResult then
				if dgsElementData[theResult].clearSwitchPos then
					dgsEditSetCaretPosition(theResult,utf8Len(dgsElementData[theResult].text or ""))
				end
				dgsBringToFront(theResult)
				triggerEvent("onDgsEditSwitched",theResult,source)
			end
		end
	end
end)

function dgsEditAlignmentShowPosition(edit,text)
	local alignment = dgsElementData[edit].alignment
	local font = dgsElementData[edit].font
	local sx = dgsElementData[edit].absSize[1]
	local showPos = dgsElementData[edit].showPos
	local padding = dgsElementData[edit].padding
	local pos = dgsElementData[edit].caretPos
	local isMask = dgsElementData[edit].masked
	if isMask then
		text = strRep(dgsElementData[edit].maskText,utf8Len(text))
	end
	if alignment[1] == "left" then
		local nowLen = _dxGetTextWidth(utf8Sub(text,0,pos),dgsElementData[edit].textSize[1],font)
		if nowLen+showPos > sx-padding[1]*2 then
			dgsSetData(edit,"showPos",sx-padding[1]*2-nowLen)
		elseif nowLen+showPos < 0 then
			dgsSetData(edit,"showPos",-nowLen)
		end
	elseif alignment[1] == "right" then
		local nowLen = _dxGetTextWidth(utf8Sub(text,pos+1),dgsElementData[edit].textSize[1],font)
		if nowLen+showPos > sx-padding[1]*2 then
			dgsSetData(edit,"showPos",sx-padding[1]*2-nowLen)
		elseif nowLen+showPos < 0 then
			dgsSetData(edit,"showPos",-nowLen)
		end
	elseif alignment[1] == "center" then
		local __width = dgsElementData[edit].textFontLen
		local nowLen = _dxGetTextWidth(utf8Sub(text,0,pos),dgsElementData[edit].textSize[1],font)
		local checkCaret = sx*0.5+nowLen-__width*0.5+showPos*0.5
		if sx*0.5+nowLen-__width*0.5+showPos*0.5-padding[1] > sx-padding[1]*2 then
			dgsSetData(edit,"showPos",(sx*0.5-padding[1]-nowLen+__width*0.5)*2)
		elseif sx*0.5+nowLen-__width*0.5+showPos*0.5-padding[1] < 0 then
			dgsSetData(edit,"showPos",(padding[1]-sx*0.5-nowLen+__width*0.5)*2)
		end
	end
end

function handleDxEditText(edit,text,noclear,noAffectCaret,index,historyRecState)
	local textData = dgsElementData[edit].text
	local maxLength = dgsElementData[edit].maxLength
	if not noclear then
		dgsElementData[edit].text = ""
		textData = dgsElementData[edit].text
		dgsSetData(edit,"caretPos",0)
		dgsSetData(edit,"selectFrom",0)
	end
	local font = dgsElementData[edit].font or systemFont
	local textSize = dgsElementData[edit].textSize
	local _index = dgsEditGetCaretPosition(edit,true)
	local index = index or _index
	local whiteList = dgsElementData[edit].whiteList or ""
	local textDataLen = utf8Len(textData)
	local text = utf8Sub(text,1,maxLength-textDataLen)
	local _textLen = utf8Len(text)
	local textData_add = utf8Sub(textData,1,index)..text..utf8Sub(textData,index+1)
	local newTextData = utf8Gsub(textData_add,whiteList,"")
	local textLen = utf8Len(newTextData)-textDataLen
	dgsElementData[edit].text = newTextData
	if dgsElementData[edit].masked then
		newTextData = strRep(dgsElementData[edit].maskText,utf8Len(newTextData))
	end
	dgsElementData[edit].textFontLen = _dxGetTextWidth(newTextData,dgsElementData[edit].textSize[1],dgsElementData[edit].font)
	if not noAffectCaret then
		if index <= _index then
			dgsEditSetCaretPosition(edit,index+textLen)
		end
	end
	triggerEvent("onDgsTextChange",edit)
	if dgsElementData[edit].enableRedoUndoRecord then
		historyRecState = historyRecState or 1
		if historyRecState ~= 0 and textLen ~= 0 then
			dgsEditSaveHistory(edit,historyRecState,2,textLen == 1 and 1 or 2,index,textLen)
		else
			return index,textLen
		end
	end
end

function dgsEditSetTypingSound(edit,sound)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditSetTypingSound at argument 1, expect a dgs-dxedit, got "..dgsGetType(edit))
	assert(type(sound) == "string" or not sound,"Bad argument @dgsEditSetTypingSound at argument 2, expect a string or nil, got "..dgsGetType(sound))
	local path = sound
	if sourceResource then
		if not find(sound,":") then
			path = ":"..getResourceName(sourceResource).."/"..sound
		end
	end
	assert(fileExists(path),"Bad argument @dgsEditSetTypingSound at argument 1,couldn't find such file '"..path.."'")
	dgsElementData[edit].typingSound = path
end

function dgsEditGetTypingSound(edit)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditGetTypingSound at argument 1, expect a dgs-dxedit, got "..dgsGetType(edit))
	return dgsElementData[edit].typingSound
end

function dgsEditSetAlignment(edit,horizontal,vertical)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditSetAlignment at argument 1, expect a dgs-dxedit, got "..dgsGetType(edit))
	local alignment = dgsElementData[edit].alignment
	horizontal = horizontal or alignment[1] or "left"
	vertical = vertical or alignment[2] or "top"
	assert(acceptedAlignment[horizontal] and acceptedAlignment[horizontal] ~= 2,"Bad argument @dgsEditSetAlignment at argument 2, expect left/center/right, got "..horizontal)
	assert(acceptedAlignment[vertical] and acceptedAlignment[vertical] ~= 1,"Bad argument @dgsEditSetAlignment at argument 3, expect left/center/right, got "..vertical)
	return dgsSetData(edit,"alignment",{horizontal,vertical})
end
function dgsEditGetAlignment(edit)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditGetAlignment at argument 1, expect a dgs-dxedit, got "..dgsGetType(edit))
	local alignment = dgsElementData[edit].alignment
	return alignment[1],alignment[2]
end

function dgsEditSetPlaceHolder(edit,placeHolder)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditSetPlaceHolder at argument 1, expect a dgs-dxedit, got "..dgsGetType(edit))
	return dgsSetData(edit,"placeHolder",placeHolder)
end

function dgsEditGetPlaceHolder(edit)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditGetPlaceHolder at argument 1, expect a dgs-dxedit, got "..dgsGetType(edit))
	return dgsElementData[edit].placeHolder
end

function dgsEditAddAutoComplete(edit,str,isSensitive)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditAddAutoComplete at argument 1, expect a dgs-dxedit, got "..dgsGetType(edit))
	local strTyp = type(str)
	if strTyp == "table" then
		local autoComplete = dgsElementData[edit].autoComplete
		for k,v in pairs(str) do
			autoComplete[k] = isSensitive == nil and v or isSensitive
		end
		return true
	elseif strTyp == "string" then
		local autoComplete = dgsElementData[edit].autoComplete
		autoComplete[str] = isSensitive
		return true
	end
	return false
end

function dgsEditSetAutoComplete(edit,acTable)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditSetAutoComplete at argument 1, expect a dgs-dxedit, got "..dgsGetType(edit))
	assert(type(acTable) == "table","Bad argument @dgsEditSetAutoComplete at argument 2, expect a table, got "..type(edit))
	local autoComplete = dgsElementData[edit].autoComplete
	return dgsSetData(edit,"autoComplete",acTable)
end

function dgsEditDeleteAutoComplete(edit,str)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditDeleteAutoComplete at argument 1, expect a dgs-dxedit, got "..dgsGetType(edit))
	local strTyp = type(str)
	if strTyp == "table" then
		local autoComplete = dgsElementData[edit].autoComplete
		for k,v in pairs(str) do
			autoComplete[k] = isSensitive == nil and v or isSensitive
		end
		return true
	elseif strTyp == "string" then
		local autoComplete = dgsElementData[edit].autoComplete
		autoComplete[str] = nil
		return true
	end
	return false
end

function dgsEditGetAutoComplete(edit)
	assert(dgsGetType(edit) == "dgs-dxedit","Bad argument @dgsEditGetAutoComplete at argument 1, expect a dgs-dxedit,1   "..dgsGetType(edit))
	return dgsElementData[edit].autoComplete
end

--[[
	historyRecState:
		0 = disabled
		1 = undo
		2 = redo
		3 = undo produced by redo
	Undo History State(Arg1):
		1 = delete
		2 = add
		3 = replace
	
	Delete Mode(Arg2):
		1 = Single Char Deletion
		2 = Multi Chars Deletion
	Add Mode(Arg2):
		1 = Single Char Addition
		2 = Multi Chars Addition
	Replace Mode(Arg2):
		1 = Default
		
	lastHistory Struct:
		Delete:
			{1,DeleteMode,Index,text}
		Add:
			{2,AddMode,Index,Length}
		Replace:
			{3,ReplaceMode,Index,Length,Text}
]]
function dgsEditSaveHistory(edit,historyRecState,...)
	if dgsElementData[edit].enableRedoUndoRecord then
		local args = {...}
		local historyTable
		if historyRecState == 2 then
			historyTable = dgsElementData[edit].redoHistory
		else
			if historyRecState == 1 then
				dgsElementData[edit].redoHistory = {} --clear Redo History
			end
			historyTable = dgsElementData[edit].undoHistory
		end
		local lastHistory = historyTable[1] or {}
		local prevOp
		if args[1] == 1 then	--Delete
			if lastHistory[1] == 1 then
				if args[2] == lastHistory[2] then
					if args[2] == 1 then
						if args[3] == lastHistory[3] then
							lastHistory[4] = lastHistory[4]..args[4]
							return true
						elseif args[3] == lastHistory[3]-1 then
							lastHistory[4] = args[4]..lastHistory[4]
							lastHistory[3] = lastHistory[3]-1
							return true
						end
					end
				end
			end
			prevOp = {1,args[2],args[3],args[4]}
			tableInsert(historyTable,1,prevOp)
		elseif args[1] == 2 then	--Add
			if lastHistory[1] == 2 then
				if args[2] == lastHistory[2] then
					if args[2] == 1 then
						if args[3] == lastHistory[3]+lastHistory[4] then
							lastHistory[4] = lastHistory[4]+1
							return true
						end
					end
				end
			end
			prevOp = {2,args[2],args[3],args[4]}
			tableInsert(historyTable,1,prevOp)
		elseif args[1] == 3 then	--Replace
			prevOp = {3,args[2],args[3],args[4],args[5]}
			tableInsert(historyTable,1,prevOp)
		end
		local historyMaxRecords = dgsElementData[edit].historyMaxRecords
		historyTable[historyMaxRecords+1] = nil
		return true
	end
end

function dgsEditDoOpposite(edit,isUndo)
	if dgsElementData[edit].enableRedoUndoRecord then
		local prevOp
		if isUndo then
			if dgsElementData[edit].undoHistory[1] then
				prevOp = dgsElementData[edit].undoHistory[1]
				tableRemove(dgsElementData[edit].undoHistory,1)
			end
		else
			if dgsElementData[edit].redoHistory[1] then
				prevOp = dgsElementData[edit].redoHistory[1]
				tableRemove(dgsElementData[edit].redoHistory,1)
			end
		end
		if prevOp then
			local recState = isUndo and 2 or 3
			if prevOp[1] == 1 then
				handleDxEditText(edit,prevOp[4],true,_,prevOp[3],recState)
				dgsEditSetCaretPosition(edit,prevOp[3]+utf8Len(prevOp[4]))
			elseif prevOp[1] == 2 then
				dgsEditDeleteText(edit,prevOp[3],prevOp[3]+prevOp[4],_,recState)
				dgsEditSetCaretPosition(edit,prevOp[3])
			elseif prevOp[1] == 3 then
				dgsEditReplaceText(edit,prevOp[3],prevOp[3]+prevOp[4],prevOp[5],_,recState)
				dgsEditSetCaretPosition(edit,prevOp[3]+utf8Len(prevOp[5]))
			end
			return true
		end
	end
	return false
end

local CodeType = {}
for i=32,47 do
	CodeType[strChar(i)] = 1 --
end
function dgsEditFindBlock()
end

addEventHandler("onClientGUIChanged",resourceRoot,function()
	if getElementType(source) == "gui-edit" then
		local dxEdit = dgsElementData[source].linkedDxEdit
		if isElement(dxEdit) then
			local text = guiGetText(source)
			local cool = dgsElementData[dxEdit].CoolTime
			if #text ~= 0 then
				if not cool then
					if not dgsElementData[dxEdit].readOnly then
						local caretPos = dgsElementData[dxEdit].caretPos
						local selectFrom = dgsElementData[dxEdit].selectFrom
						if selectFrom-caretPos ~= 0 then
							dgsEditReplaceText(dxEdit,caretPos,selectFrom,text)
						else
							handleDxEditText(dxEdit,text,true)
						end
					end
					dgsElementData[dxEdit].CoolTime = true
					guiSetText(source,"")
					dgsElementData[dxEdit].CoolTime = false
				end
			end
		end
	end
end)

----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxedit"] = function(source,x,y,w,h,mx,my,cx,cy,enabled,eleData,parentAlpha,isPostGUI,rndtgt)
	local bgImage = eleData.isFocused and eleData.bgImage or (eleData.bgImageBlur or eleData.bgImage)
	local bgColor = eleData.isFocused and eleData.bgColor or (eleData.bgColorBlur or eleData.bgColor)
	bgColor = applyColorAlpha(bgColor,parentAlpha)
	local caretColor = applyColorAlpha(eleData.caretColor,parentAlpha)
	if MouseData.nowShow == source then
		if isConsoleActive() or isMainMenuActive() or isChatBoxInputActive() then
			MouseData.nowShow = false
		end
	end
	local text = eleData.text
	if eleData.masked then text = strRep(eleData.maskText,utf8Len(text)) end
	local caretPos = eleData.caretPos
	local selectFro = eleData.selectFrom
	local selectColor = MouseData.nowShow == source and eleData.selectColor or eleData.selectColorBlur
	local font = eleData.font or systemFont
	local txtSizX,txtSizY = eleData.textSize[1],eleData.textSize[2] or eleData.textSize[1]
	local renderTarget = eleData.renderTarget
	local alignment = eleData.alignment
	if isElement(renderTarget) then
		local textColor = eleData.textColor
		local selx = 0
		if selectFro-caretPos > 0 then
			selx = dxGetTextWidth(utf8Sub(text,caretPos+1,selectFro),txtSizX,font)
		elseif selectFro-caretPos < 0 then
			selx = -dxGetTextWidth(utf8Sub(text,selectFro+1,caretPos),txtSizX,font)
		end
		local showPos = eleData.showPos
		local padding = eleData.padding
		local sidelength,sideheight = padding[1]-padding[1]%1,padding[2]-padding[2]%1
		local caretHeight = eleData.caretHeight
		local textX_Left,textX_Right
		local insideH = h-sideheight*2
		local selStartY = insideH/2-insideH/2*caretHeight
		local selEndY = (insideH/2-selStartY)*2
		local width,selectX,selectW
		local posFix = 0
		local placeHolder = eleData.placeHolder
		local placeHolderIgnoreRndTgt = eleData.placeHolderIgnoreRenderTarget
		local placeHolderOffset = eleData.placeHolderOffset
		dxSetRenderTarget(renderTarget,true)
		dxSetBlendMode("modulate_add")
		if alignment[1] == "left" then
			width = dxGetTextWidth(utf8Sub(text,0,caretPos),txtSizX,font)
			textX_Left,textX_Right = showPos,w-sidelength
			selectX,selectW = width+showPos,selx
			if selx ~= 0 then
				dxDrawRectangle(selectX,selStartY,selectW,selEndY,selectColor)
			end
		elseif alignment[1] == "center" then
			local __width = eleData.textFontLen
			width = dxGetTextWidth(utf8Sub(text,0,caretPos),txtSizX,font)
			textX_Left,textX_Right = showPos,w-sidelength
			selectX,selectW = width+showPos*0.5+w*0.5-__width*0.5-sidelength+1,selx
			if selx ~= 0 then
				dxDrawRectangle(selectX,selStartY,selectW,selEndY,selectColor)
			end
			posFix = ((text:reverse():find("%S") or 1)-1)*dxGetTextWidth(" ",txtSizX,font)
		elseif alignment[1] == "right" then
			width = dxGetTextWidth(utf8Sub(text,caretPos+1),txtSizX,font)
			textX_Left,textX_Right = x,w-sidelength*2-showPos
			selectX,selectW = textX_Right-width,selx
			if selx ~= 0 then
				dxDrawRectangle(selectX,selStartY,selectW,selEndY,selectColor)
			end
			posFix = ((text:reverse():find("%S") or 1)-1)*dxGetTextWidth(" ",txtSizX,font)
		end
		textX_Left = textX_Left-textX_Left%1
		textX_Right = textX_Right-textX_Right%1
		if not placeHolderIgnoreRndTgt then
			if text == "" and MouseData.nowShow ~= source then
				local pColor = eleData.placeHolderColor
				local pFont = eleData.placeHolderFont
				local pColorcoded = eleData.placeHolderColorcoded
				dxDrawText(placeHolder,textX_Left+placeHolderOffset[1],placeHolderOffset[2],textX_Right-posFix+placeHolderOffset[1],h-sidelength+placeHolderOffset[2],pColor,txtSizX,txtSizY,pFont,alignment[1],alignment[2],false,false,false,pColorcoded)
			end
		end
		if eleData.autoCompleteShow then
			dxDrawText(eleData.autoCompleteShow[2],textX_Left,0,textX_Right-posFix,h-sidelength,eleData.autoCompleteTextColor or applyColorAlpha(textColor,0.7),txtSizX,txtSizY,font,alignment[1],alignment[2],false,false,false,false)
		end
		dxDrawText(text,textX_Left,0,textX_Right-posFix,h-sidelength,textColor,txtSizX,txtSizY,font,alignment[1],alignment[2],false,false,false,false)
		if eleData.underline then
			local textHeight = dxGetFontHeight(txtSizY,font)
			local lineOffset = eleData.underlineOffset+h*0.5+textHeight*0.5
			local lineWidth = eleData.underlineWidth
			local textFontLen = eleData.textFontLen
			dxDrawLine(showPos,lineOffset,showPos+textFontLen,lineOffset,textColor,lineWidth)
		end
		dxSetRenderTarget(rndtgt)
		dxSetBlendMode(rndtgt and "modulate_add" or "blend")
		local px,py,pw,ph = x+sidelength,y+sideheight,w-sidelength*2,h-sideheight*2
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
		if bgImage then
			dxDrawImage(x,y,w,h,bgImage,0,0,0,finalcolor,isPostGUI)
		else
			dxDrawRectangle(x,y,w,h,finalcolor,isPostGUI)
		end
		dxDrawImage(px,py,pw,ph,renderTarget,0,0,0,tocolor(255,255,255,255*parentAlpha),isPostGUI)
		if placeHolderIgnoreRndTgt then
			if text == "" and MouseData.nowShow ~= source then
				local pColor = applyColorAlpha(eleData.placeHolderColor,parentAlpha)
				local pFont = eleData.placeHolderFont
				local pColorcoded = eleData.placeHolderColorcoded
				dxSetBlendMode(rndtgt and "modulate_add" or "blend")
				dxDrawText(placeHolder,px+textX_Left+placeHolderOffset[1],py+placeHolderOffset[2],px+textX_Right-posFix+placeHolderOffset[1],py+h-sidelength+placeHolderOffset[2],pColor,txtSizX,txtSizY,pFont,alignment[1],alignment[2],false,false,isPostGUI,pColorcoded)
			end
		end
		if MouseData.nowShow == source and MouseData.editMemoCursor then
			local CaretShow = true
			if eleData.readOnly then
				CaretShow = eleData.readOnlyCaretShow
			end
			if CaretShow then
				local caretStyle = eleData.caretStyle
				local selStartX = selectX+x+sidelength
				selStartX = selStartX-selStartX%1
				if caretStyle == 0 then
					if selStartX+1 >= x+sidelength and selStartX <= x+w-sidelength then
						local selStartY = h/2-h/2*caretHeight+sideheight
						local selEndY = (h/2-selStartY)*2
						dxDrawLine(selStartX,y+selStartY,selStartX,y+selEndY+selStartY,caretColor,eleData.caretThick,isPostGUI)
					end
				elseif caretStyle == 1 then
					local cursorWidth = dxGetTextWidth(utf8Sub(text,caretPos+1,caretPos+1),txtSizX,font)
					if cursorWidth == 0 then
						cursorWidth = txtSizX*8
					end
					if selStartX+1 >= x+sidelength and selStartX+cursorWidth <= x+w-sidelength then
						local offset = eleData.caretOffset
						local selStartY = y+h/2-h/2*caretHeight+sideheight
						dxDrawLine(selStartX,selStartY-offset,selStartX+cursorWidth,selStartY-offset,caretColor,eleData.caretThick,isPostGUI)
					end
				end
			end
		end
	end
	if enabled[1] and mx then
		if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
			MouseData.hit = source
		end
	end
	return rndtgt
end
----------------------------------------------------------------
-------------------------OOP Class------------------------------
----------------------------------------------------------------
dgsOOP["dgs-dxedit"] = [[
	moveCaret = dgsOOP.genOOPFnc("dgsEditMoveCaret",true),
	setCaretPosition = dgsOOP.genOOPFnc("dgsEditSetCaretPosition",true),
	getCaretPosition = dgsOOP.genOOPFnc("dgsEditGetCaretPosition"),
	setCaretStyle = dgsOOP.genOOPFnc("dgsEditSetCaretStyle",true),
	getCaretStyle = dgsOOP.genOOPFnc("dgsEditGetCaretStyle"),
	setWhiteList = dgsOOP.genOOPFnc("dgsEditSetWhiteList",true),
	setMaxLength = dgsOOP.genOOPFnc("dgsEditSetMaxLength",true),
	getMaxLength = dgsOOP.genOOPFnc("dgsEditGetMaxLength"),
	setReadOnly = dgsOOP.genOOPFnc("dgsEditSetReadOnly",true),
	getReadOnly = dgsOOP.genOOPFnc("dgsEditGetReadOnly"),
	setMasked = dgsOOP.genOOPFnc("dgsEditSetMasked",true),
	getMasked = dgsOOP.genOOPFnc("dgsEditGetMasked"),
	setUnderlined = dgsOOP.genOOPFnc("dgsEditSetUnderlined",true),
	getUnderlined = dgsOOP.genOOPFnc("dgsEditGetUnderlined"),
	setHorizontalAlign = dgsOOP.genOOPFnc("dgsEditSetHorizontalAlign",true),
	getHorizontalAlign = dgsOOP.genOOPFnc("dgsEditGetHorizontalAlign"),
	setVerticalAlign = dgsOOP.genOOPFnc("dgsEditSetVerticalAlign",true),
	getVerticalAlign = dgsOOP.genOOPFnc("dgsEditGetVerticalAlign"),
	setAlignment = dgsOOP.genOOPFnc("dgsEditSetAlignment ",true),
	getAlignment = dgsOOP.genOOPFnc("dgsEditGetAlignment "),
	insertText = dgsOOP.genOOPFnc("dgsEditInsertText",true),
	deleteText = dgsOOP.genOOPFnc("dgsEditDeleteText",true),
	getPartOfText = dgsOOP.genOOPFnc("dgsEditGetPartOfText"),
	clearText = dgsOOP.genOOPFnc("dgsEditClearText",true),
	replaceText = dgsOOP.genOOPFnc("dgsEditReplaceText",true),
	setTypingSound = dgsOOP.genOOPFnc("dgsEditSetTypingSound",true),
	getTypingSound = dgsOOP.genOOPFnc("dgsEditGetTypingSound"),
	setPlaceHolder = dgsOOP.genOOPFnc("dgsEditSetPlaceHolder",true),
	getPlaceHolder = dgsOOP.genOOPFnc("dgsEditGetPlaceHolder"),
	setAutoComplete = dgsOOP.genOOPFnc("dgsEditSetAutoComplete",true),
	getAutoComplete = dgsOOP.genOOPFnc("dgsEditGetAutoComplete"),
	addAutoComplete = dgsOOP.genOOPFnc("dgsEditAddAutoComplete",true),
	removeAutoComplete = dgsOOP.genOOPFnc("dgsEditRemoveAutoComplete",true),
]]