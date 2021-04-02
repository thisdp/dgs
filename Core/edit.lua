--Dx Functions
local dxDrawLine = dxDrawLine
local dxDrawImage = dxDrawImageExt
local dxDrawText = dxDrawText
local dxGetFontHeight = dxGetFontHeight
local dxDrawRectangle = dxDrawRectangle
local dxSetRenderTarget = dxSetRenderTarget
local dxGetTextWidth = dxGetTextWidth
local _dxGetTextWidth = dxGetTextWidth
local dxSetBlendMode = dxSetBlendMode
local _dxDrawImage = _dxDrawImage
local dxCreateRenderTarget = dxCreateRenderTarget
--DGS Functions
local dgsSetType = dgsSetType
local dgsSetParent = dgsSetParent
local dgsSetData = dgsSetData
local dgsAttachToTranslation = dgsAttachToTranslation
local calculateGuiPositionSize = calculateGuiPositionSize
local dgsAttachToAutoDestroy = dgsAttachToAutoDestroy
local applyColorAlpha = applyColorAlpha
--Utilities
local isConsoleActive = isConsoleActive
local isMainMenuActive = isMainMenuActive
local isChatBoxInputActive = isChatBoxInputActive
local getKeyState = getKeyState
local triggerEvent = triggerEvent
local addEventHandler = addEventHandler
local createElement = createElement
local assert = assert
local tonumber = tonumber
local tostring = tostring
local type = type
local mathFloor = math.floor
local utf8Sub = utf8.sub
local utf8Len = utf8.len
local utf8Gsub = utf8.gsub
local utf8Lower = utf8.lower
local utf8GetCharType = utf8.getCharType
local strRep = string.rep
local tableInsert = table.insert
local tableRemove = table.remove
local strChar = string.char
local mathMin = math.min
local mathMax = math.max
----Initialize
GlobalEditParent = guiCreateLabel(-1,0,0,0,"",true)
GlobalEdit = guiCreateEdit(-1,0,0,0,"",true,GlobalEditParent)
addEventHandler("onClientGUIBlur",GlobalEdit,GlobalEditMemoBlurCheck,false)
dgsSetData(GlobalEdit,"linkedDxEdit",nil)
local splitChar = "\r\n"
local splitChar2 = "\n"
local editsCount = 1
----
function dgsCreateEdit(...)
	local x,y,w,h,text,relative,parent,textColor,scaleX,scaleY,bgImage,bgColor,selectMode
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
		selectMode = argTable.selectMode or argTable[13]
	else
		x,y,w,h,text,relative,parent,textColor,scaleX,scaleY,bgImage,bgColor,selectMode = ...
	end
	if not(type(x) == "number") then error(dgsGenAsrt(x,"dgsCreateEdit",1,"number")) end
	if not(type(y) == "number") then error(dgsGenAsrt(y,"dgsCreateEdit",2,"number")) end
	if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsCreateEdit",3,"number")) end
	if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsCreateEdit",4,"number")) end
	text = tostring(text)
	local edit = createElement("dgs-dxedit")
	dgsSetType(edit,"dgs-dxedit")
	dgsSetParent(edit,parent,true,true)
	local style = styleSettings.edit
	local textSizeX,textSizeY = tonumber(scalex) or style.textSize[1], tonumber(scaley) or style.textSize[2]
	dgsElementData[edit] = {
		text = "",
		bgColor = bgColor or style.bgColor,
		bgImage = bgImage or dgsCreateTextureFromStyle(style.bgImage),
		bgColorBlur = style.bgColorBlur,
		bgImageBlur = dgsCreateTextureFromStyle(style.bgImageBlur),
		textSize = {textSizeX,textSizeY},
		font = style.font or systemFont,
		textColor = textColor or style.textColor,
		caretPos = 0,
		selectFrom = 0,
		masked = false,
		maskText = style.maskText,
		showPos = 0,
		placeHolder = style.placeHolder,
		placeHolderFont = systemFont,
		placeHolderColor = style.placeHolderColor,
		placeHolderColorcoded = style.placeHolderColorcoded,
		placeHolderOffset = style.placeHolderOffset,
		placeHolderTextSize = style.placeHolderTextSize,
		placeHolderIgnoreRenderTarget = style.placeHolderIgnoreRenderTarget,
		padding = style.padding,
		alignment = {"left","center"},
		caretStyle = style.caretStyle,
		caretThick = style.caretThick,
		caretOffset = style.caretOffset,
		caretColor = style.caretColor,
		caretHeight = style.caretHeight,
		readOnly = false,
		readOnlyCaretShow = false,
		clearSelection = true,
		enableTabSwitch = true,
		clearSwitchPos = false,
		lastSwitchPosition = -1,
		underlineOffset = 0,
		lockView = false,
		allowCopy = true,
		autoCompleteShow = false,
		autoCompleteTextColor = nil,
		autoCompleteSkip = false,
		autoComplete = {},
		autoCompleteConfirmKey = "tab",
		selectColor = style.selectColor,
		selectColorBlur = style.selectColorBlur,
		historyMaxRecords = 100,
		enableRedoUndoRecord = true,
		undoHistory = {},
		redoHistory = {},
		typingSound = style.typingSound,
		maxLength = 0x3FFFFFFF,
		--rtl = nil,	--nil: auto; false:disabled; true: enabled
		editCounts = editsCount, --Tab Switch
	}
	editsCount = editsCount+1
	calculateGuiPositionSize(edit,x,y,relative or false,w,h,relative or false,true)
	local sx,sy = dgsGetSize(edit,false)
	local padding = dgsElementData[edit].padding
	local sizex,sizey = sx-padding[1]*2,sy-padding[2]*2
	sizex,sizey = sizex-sizex%1,sizey-sizey%1
	local renderTarget,err = dxCreateRenderTarget(sizex,sizey,true,edit)
	if renderTarget ~= false then
		dgsAttachToAutoDestroy(renderTarget,edit,-1)
	else
		outputDebugString(err,2)
	end
	dgsElementData[edit].renderTarget = renderTarget
	handleDxEditText(edit,text,false,true)
	dgsEditSetCaretPosition(edit,utf8Len(text))
	dgsAddEventHandler("onDgsTextChange",edit,"dgsEditCheckAutoComplete",false)
	dgsAddEventHandler("onDgsMouseMultiClick",edit,"dgsEditCheckMultiClick",false)
	dgsAddEventHandler("onDgsEditPreSwitch",edit,"dgsEditCheckPreSwitch",false)
	triggerEvent("onDgsCreate",edit,sourceResource)
	return edit
end

function dgsEditCheckMultiClick(button,state,x,y,times)
	if state == "down" then
		if times== 1 then
			if button ~= "middle" then
				local shift = getKeyState("lshift") or getKeyState("rshift")
				local pos,side = searchEditMousePosition(source,x)
				dgsEditSetCaretPosition(source,pos,shift)
			end
		elseif times == 2 then
			if button == "left" then
				local pos,side = searchEditMousePosition(source,x)
				local text = dgsElementData[source].text
				local s,e = dgsSearchFullWordType(text,pos,side)
				dgsEditSetCaretPosition(source,s)
				dgsEditSetCaretPosition(source,e,true)
			end
		elseif times == 3 then
			if button == "left" then
				dgsEditSetCaretPosition(source,_)
				dgsEditSetCaretPosition(source,0,true)
			end
		end
	end
end

function dgsEditCheckAutoComplete()
	if not dgsElementData[source].autoCompleteSkip then
		local text = dgsElementData[source].text
		dgsSetData(source,"autoCompleteShow",false)
		if text ~= "" then
			local lowertxt = utf8Lower(text)
			local textLen = utf8Len(text)
			local acTable = dgsElementData[source].autoComplete
			for k,v in pairs(acTable) do
				if v == true then
					if utf8Sub(k,1,textLen) == text then
						dgsSetData(source,"autoCompleteShow",{k,k})
						break
					end
				elseif v == false then
					if utf8Lower(utf8Sub(k,1,textLen)) == lowertxt then
						dgsSetData(source,"autoCompleteShow",{k,text..utf8Sub(k,textLen+1)})
						break
					end
				end
			end
		end
	end
end

function dgsEditCheckPreSwitch()
	if not wasEventCancelled() then
		if not dgsElementData[source].enableTabSwitch then return end
		local parent = FatherTable[source]
		local theTable = isElement(parent) and ChildrenTable[parent] or (dgsElementData[source].alwaysOnBottom and BottomFatherTable or CenterFatherTable)
		local id = dgsElementData[source].editCounts
		if id then
			local Next,theFirst
			for i=1,#theTable do
				local edit = theTable[i]
				local eleData = dgsElementData[edit]
				local editCounts = eleData.editCounts
				if editCounts and eleData.enabled and eleData.visible and not eleData.readOnly then
					if id ~= editCounts and dgsGetType(edit) == "dgs-dxedit" and eleData.enableTabSwitch then
						if editCounts < id then
							theFirst = theFirst and (dgsElementData[theFirst].editCounts > editCounts and edit or theFirst) or edit
						else
							Next = Next and (dgsElementData[Next].editCounts > editCounts and edit or Next) or edit
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
end

function dgsEditSetMasked(edit,masked)
	if not dgsIsType(edit,"dgs-dxedit") then error(dgsGenAsrt(edit,"dgsEditSetMasked",1,"dgs-dxedit")) end
	return dgsSetData(edit,"masked",masked and true or false)
end

function dgsEditGetMasked(edit)
	if not dgsIsType(edit,"dgs-dxedit") then error(dgsGenAsrt(edit,"dgsEditGetMasked",1,"dgs-dxedit")) end
	return dgsElementData[edit].masked
end

function dgsEditMoveCaret(edit,offset,selectText)
	if not dgsIsType(edit,"dgs-dxedit") then error(dgsGenAsrt(edit,"dgsEditMoveCaret",1,"dgs-dxedit")) end
	if not(type(offset) == "number") then error(dgsGenAsrt(offset,"dgsEditMoveCaret",2,"number")) end
	local eleData = dgsElementData[edit]
	local text = eleData.text
	local textLen = utf8Len(text)
	if eleData.masked then
		text = strRep(eleData.maskText,textLen)
	end
	local pos = eleData.caretPos+mathFloor(offset)
	if pos < 0 then
		pos = 0
	elseif pos > textLen then
		pos = textLen
	end
	dgsSetData(edit,"caretPos",pos)
	local isReadOnlyShow = true
	if eleData.readOnly then
		isReadOnlyShow = eleData.readOnlyCaretShow
	end
	if not selectText or not isReadOnlyShow then
		dgsSetData(edit,"selectFrom",pos)
	end
	dgsEditAlignmentShowPosition(edit,text)
	resetTimer(MouseData.EditMemoTimer)
	MouseData.EditMemoCursor = true
	return true
end

function dgsEditSetCaretPosition(edit,pos,doSelect)
	if not dgsIsType(edit,"dgs-dxedit") then error(dgsGenAsrt(edit,"dgsEditSetCaretPosition",1,"dgs-dxedit")) end
	if not(type(pos) == "number" or pos == nil) then error(dgsGenAsrt(pos,"dgsEditSetCaretPosition",2,"nil/number")) end
	local eleData = dgsElementData[edit]
	local text = eleData.text
	local textLen = utf8Len(text)
	if eleData.masked then
		text = strRep(eleData.maskText,textLen)
	end
	if not pos or pos > textLen then
		pos = textLen
	elseif pos < 0 then
		pos = 0
	end
	dgsSetData(edit,"caretPos",mathFloor(pos))
	if not doSelect then
		dgsSetData(edit,"selectFrom",mathFloor(pos))
	end
	dgsEditAlignmentShowPosition(edit,text)
	resetTimer(MouseData.EditMemoTimer)
	MouseData.EditMemoCursor = true
	return true
end

function dgsEditGetCaretPosition(edit)
	if not dgsIsType(edit,"dgs-dxedit") then error(dgsGenAsrt(edit,"dgsEditGetCaretPosition",1,"dgs-dxedit")) end
	return dgsElementData[edit].caretPos
end

function dgsEditSetCaretStyle(edit,style)
	if not dgsIsType(edit,"dgs-dxedit") then error(dgsGenAsrt(edit,"dgsEditSetCaretStyle",1,"dgs-dxedit")) end
	if not(type(style) == "number") then error(dgsGenAsrt(style,"dgsEditSetCaretStyle",2,"number")) end
	return dgsSetData(edit,"caretStyle",style)
end

function dgsEditGetCaretStyle(edit,style)
	if not dgsIsType(edit,"dgs-dxedit") then error(dgsGenAsrt(edit,"dgsEditGetCaretStyle",1,"dgs-dxedit")) end
	return dgsElementData[edit].caretStyle
end

function dgsEditSetMaxLength(edit,maxLength,nonTextCut)
	if not dgsIsType(edit,"dgs-dxedit") then error(dgsGenAsrt(edit,"dgsEditSetMaxLength",1,"dgs-dxedit")) end
	if not(type(maxLength) == "number") then error(dgsGenAsrt(maxLength,"dgsEditSetMaxLength",2,"number")) end
	if not nonTextCut then
		local text = dgsElementData[edit].text
		dgsEditDeleteText(edit,maxLength,utf8Len(text),true)
	end
	return dgsSetData(edit,"maxLength",maxLength)
end

function dgsEditGetMaxLength(edit)
	if not dgsIsType(edit,"dgs-dxedit") then error(dgsGenAsrt(edit,"dgsEditGetMaxLength",1,"dgs-dxedit")) end
	return dgsElementData[edit].maxLength
end

function dgsEditSetReadOnly(edit,state)
	if not dgsIsType(edit,"dgs-dxedit") then error(dgsGenAsrt(edit,"dgsEditSetReadOnly",1,"dgs-dxedit")) end
	return dgsSetData(edit,"readOnly",state and true or false)
end

function dgsEditGetReadOnly(edit)
	if not dgsIsType(edit,"dgs-dxedit") then error(dgsGenAsrt(edit,"dgsEditGetReadOnly",1,"dgs-dxedit")) end
	return dgsElementData[edit].readOnly
end

function dgsEditSetWhiteList(edit,str)
	if not dgsIsType(edit,"dgs-dxedit") then error(dgsGenAsrt(edit,"dgsEditSetWhiteList",1,"dgs-dxedit")) end
	if type(str) == "string" then
		dgsSetData(edit,"whiteList",str)
	else
		dgsSetData(edit,"whiteList",nil)
	end
	local eleData = dgsElementData[edit]
	local font = eleData.font or systemFont
	local textSize = eleData.textSize
	local index = dgsEditGetCaretPosition(edit,true)
	local whiteList = str or ""
	local oldText = eleData.text
	local text = utf8Gsub(eleData.text,whiteList,"")
	local textLen = utf8Len(text)
	eleData.text = text
	if eleData.masked then
		text = strRep(eleData.maskText,utf8Len(text))
	end
	eleData.textFontLen = _dxGetTextWidth(text,textSize[1],font)
	if index >= textLen then
		dgsEditSetCaretPosition(edit,textLen)
	end
	dgsSetData(edit,"undoHistory",{})
	dgsSetData(edit,"redoHistory",{})
	triggerEvent("onDgsTextChange",edit,oldText)
end

function dgsEditInsertText(edit,index,text)
	if not dgsIsType(edit,"dgs-dxedit") then error(dgsGenAsrt(edit,"dgsEditInsertText",1,"dgs-dxedit")) end
	if not(type(index) == "number") then error(dgsGenAsrt(index,"dgsEditInsertText",2,"number")) end
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
	if not dgsIsType(edit,"dgs-dxedit") then error(dgsGenAsrt(edit,"dgsEditDeleteText",1,"dgs-dxedit")) end
	if not(type(fromIndex) == "number") then error(dgsGenAsrt(fromIndex,"dgsEditDeleteText",2,"number")) end
	if not(type(toIndex) == "number") then error(dgsGenAsrt(toIndex,"dgsEditDeleteText",3,"number")) end
	local eleData = dgsElementData[edit]
	local text = eleData.text
	local oldText = text
	local textLen = utf8Len(text)
	local isMask = eleData.masked
	local fromIndex = (fromIndex < 0 and 0) or (fromIndex > textLen and textLen) or fromIndex
	local toIndex = (toIndex < 0 and 0) or (toIndex > textLen and textLen) or toIndex
	if fromIndex > toIndex then
		fromIndex,toIndex = toIndex,fromIndex
	end
	local _deletedText = utf8Sub(text,fromIndex+1,toIndex)
	local deletedText = _deletedText
	if isMask then
		deletedText = strRep(eleData.maskText,utf8Len(_deletedText))
	end
	local deleted = _dxGetTextWidth(deletedText,eleData.textSize[1],eleData.font)
	local text = utf8Sub(text,1,fromIndex)..utf8Sub(text,toIndex+1)
	eleData.text = text
	if not noAffectCaret then
		if eleData.caretPos >= fromIndex then
			dgsEditSetCaretPosition(edit,fromIndex)
		end
	end
	if eleData.enableRedoUndoRecord then
		historyRecState = historyRecState or 1
		if historyRecState ~= 0 and toIndex-fromIndex ~= 0 then
			dgsEditSaveHistory(edit,historyRecState,1,toIndex-fromIndex == 1 and 1 or 2,fromIndex,_deletedText)
		end
	end
	local showPos = eleData.showPos
	if showPos > 0 then
		showPos = showPos - deleted
		if showPos < 0 then showPos = 0 end
	else
		showPos = showPos + deleted
		if showPos > 0 then showPos = 0 end
	end
	eleData.showPos = showPos-showPos%1
	if eleData.masked then
		text = strRep(eleData.maskText,utf8Len(text))
	end
	eleData.textFontLen = _dxGetTextWidth(text,eleData.textSize[1],eleData.font)
	triggerEvent("onDgsTextChange",edit,oldText)
	return deletedText
end

function dgsEditClearText(edit)
	if not dgsIsType(edit,"dgs-dxedit") then error(dgsGenAsrt(edit,"dgsEditClearText",1,"dgs-dxedit")) end
	local oldText = dgsElementData[edit].text
	dgsElementData[edit].text = ""
	dgsSetData(edit,"caretPos",0)
	dgsSetData(edit,"selectFrom",0)
	dgsElementData[edit].textFontLen = 0
	triggerEvent("onDgsTextChange",edit,oldText)
	return true
end

function dgsEditGetPartOfText(edit,fromIndex,toIndex,delete)
	if not dgsIsType(edit,"dgs-dxedit") then error(dgsGenAsrt(edit,"dgsEditGetPartOfText",1,"dgs-dxedit")) end
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
	if not dgsIsType(edit,"dgs-dxedit") then error(dgsGenAsrt(edit,"dgsEditSetHorizontalAlign",1,"dgs-dxedit")) end
	if not HorizontalAlign[align] then error(dgsGenAsrt(align,"dgsEditSetHorizontalAlign",2,"string","left/center/right")) end
	local alignment = dgsElementData[edit].alignment
	return dgsSetData(edit,"alignment",{align,alignment[2]})
end

function dgsEditSetVerticalAlign(edit,align)
	if not dgsIsType(edit,"dgs-dxedit") then error(dgsGenAsrt(edit,"dgsEditSetVerticalAlign",1,"dgs-dxedit")) end
	if not VerticalAlign[align] then error(dgsGenAsrt(align,"dgsEditSetVerticalAlign",2,"string","top/center/bottom")) end
	local alignment = dgsElementData[edit].alignment
	return dgsSetData(edit,"alignment",{alignment[1],align})
end

function dgsEditGetHorizontalAlign(edit)
	if not dgsIsType(edit,"dgs-dxedit") then error(dgsGenAsrt(edit,"dgsEditGetHorizontalAlign",1,"dgs-dxedit")) end
	local alignment = dgsElementData[edit].alignment
	return alignment[1]
end

function dgsEditGetVerticalAlign(edit)
	if not dgsIsType(edit,"dgs-dxedit") then error(dgsGenAsrt(edit,"dgsEditGetVerticalAlign",1,"dgs-dxedit")) end
	local alignment = dgsElementData[edit].alignment
	return alignment[2]
end

function dgsEditSetUnderlined(edit,state)
	if not dgsIsType(edit,"dgs-dxedit") then error(dgsGenAsrt(edit,"dgsEditSetUnderlined",1,"dgs-dxedit")) end
	return dgsSetData(edit,"underline",state and true or false)
end

function dgsEditGetUnderlined(edit,state)
	if not dgsIsType(edit,"dgs-dxedit") then error(dgsGenAsrt(edit,"dgsEditGetUnderlined",1,"dgs-dxedit")) end
	return dgsElementData[edit].underline
end

-----------------Internal Functions
function configEdit(edit)
	local absSize = dgsElementData[edit].absSize
	local w,h = absSize[1],absSize[2]
	local padding = dgsElementData[edit].padding
	local px,py = w-padding[1]*2,h-padding[2]*2
	px,py = px-px%1,py-py%1
	local renderTarget,err = dxCreateRenderTarget(px,py,true,edit)
	if renderTarget ~= false then
		dgsAttachToAutoDestroy(renderTarget,edit,-1)
	else
		outputDebugString(err,2)
	end
	dgsAttachToAutoDestroy(renderTarget,edit,1)
	dgsSetData(edit,"renderTarget",renderTarget)
	local oldPos = dgsEditGetCaretPosition(edit)
	dgsEditSetCaretPosition(edit,0)
	dgsEditSetCaretPosition(edit,oldPos)
end

function resetEdit(x,y)
	if dgsGetType(MouseData.focused) == "dgs-dxedit" then
		if MouseData.focused == MouseData.clickl then
			local pos = searchEditMousePosition(MouseData.focused,MouseData.cursorPos[1] or x*sW)
			dgsEditSetCaretPosition(MouseData.focused,pos,true)
		end
	end
end
addEventHandler("onClientCursorMove",root,resetEdit)

function searchEditMousePosition(edit,posx)
	local eleData = dgsElementData[edit]
	local text
	--[[if eleData.isRTL then
		text = eleData.text:reverse()
	else
		text = eleData.text
	end]]
	text = eleData.text
	local sfrom,sto = 0,utf8Len(text)
	if eleData.masked then
		text = strRep(eleData.maskText,sto)
	end
	local font = eleData.font or systemFont
	local txtSizX = eleData.textSize[1]
	local size = eleData.absSize
	local offset = eleData.showPos
	local x = dgsGetPosition(edit,false,true)
	local alignment = eleData.alignment
	local padding = eleData.padding
	local pos
	local alllen = eleData.textFontLen
	if alignment[1] == "left" then
		pos = posx-x-offset-padding[1]
	elseif alignment[1] == "center" then
		local sx,sy = eleData.absSize[1],eleData.absSize[2]
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
			return sfrom,1
		elseif i >= sto and pos >= offsetR then
			return sto,-1
		elseif pos >= offsetL and pos <= offsetR then
			return i,pos-start < 0 and -1 or 1
		end
		start = start + Next*2
	end
	return -1,0
end

addEventHandler("onClientGUIAccepted",GlobalEdit,function()
	local dgsEdit = dgsElementData[source].linkedDxEdit
	if dgsGetType(dgsEdit) == "dgs-dxedit" then
		triggerEvent("onDgsEditAccepted",dgsEdit)
	end
end,true)

function dgsEditAlignmentShowPosition(edit,text)
	local eleData = dgsElementData[edit]
	local alignment = eleData.alignment
	local font = eleData.font
	local sx = eleData.absSize[1]
	local showPos = eleData.showPos
	local padding = eleData.padding
	local pos = eleData.caretPos
	local isMask = eleData.masked
	if isMask then
		text = strRep(eleData.maskText,utf8Len(text))
	end
	if alignment[1] == "left" then
		local nowLen = _dxGetTextWidth(utf8Sub(text,0,pos),eleData.textSize[1],font)
		if nowLen+showPos > sx-padding[1]*2 then
			dgsSetData(edit,"showPos",sx-padding[1]*2-nowLen)
		elseif nowLen+showPos < 0 then
			dgsSetData(edit,"showPos",-nowLen)
		end
	elseif alignment[1] == "right" then
		local nowLen = _dxGetTextWidth(utf8Sub(text,pos+1),eleData.textSize[1],font)
		if nowLen+showPos > sx-padding[1]*2 then
			dgsSetData(edit,"showPos",sx-padding[1]*2-nowLen)
		elseif nowLen+showPos < 0 then
			dgsSetData(edit,"showPos",-nowLen)
		end
	elseif alignment[1] == "center" then
		local __width = eleData.textFontLen
		local nowLen = _dxGetTextWidth(utf8Sub(text,0,pos),eleData.textSize[1],font)
		local checkCaret = sx*0.5+nowLen-__width*0.5+showPos*0.5
		if sx*0.5+nowLen-__width*0.5+showPos*0.5-padding[1] > sx-padding[1]*2 then
			dgsSetData(edit,"showPos",(sx*0.5-padding[1]-nowLen+__width*0.5)*2)
		elseif sx*0.5+nowLen-__width*0.5+showPos*0.5-padding[1] < 0 then
			dgsSetData(edit,"showPos",(padding[1]-sx*0.5-nowLen+__width*0.5)*2)
		end
	end
end

function handleDxEditText(edit,text,noclear,noAffectCaret,index,historyRecState)
	local eleData = dgsElementData[edit]
	local textData = eleData.text
	local oldText = textData
	local maxLength = eleData.maxLength
	if not noclear then
		eleData.text = ""
		textData = eleData.text
		dgsSetData(edit,"caretPos",0)
		dgsSetData(edit,"selectFrom",0)
	end
	local font = eleData.font or systemFont
	local textSize = eleData.textSize
	local _index = dgsEditGetCaretPosition(edit,true)
	local index = index or _index
	local whiteList = eleData.whiteList or ""
	local textDataLen = utf8Len(textData)
	local text = utf8Sub(text,1,maxLength-textDataLen)
	local _textLen = utf8Len(text)
	local textData_add = utf8Sub(textData,1,index)..text..utf8Sub(textData,index+1)
	local newTextData = utf8Gsub(textData_add,whiteList,"")
	local textLen = utf8Len(newTextData)-textDataLen
	eleData.text = newTextData
	newTextData = eleData.masked and strRep(eleData.maskText,utf8Len(newTextData)) or newTextData
	eleData.textFontLen = _dxGetTextWidth(newTextData,eleData.textSize[1],eleData.font)
	if not noAffectCaret then
		if index <= _index then
			dgsEditSetCaretPosition(edit,index+textLen)
		end
	end
	triggerEvent("onDgsTextChange",edit,oldText)
	if eleData.enableRedoUndoRecord then
		historyRecState = historyRecState or 1
		if historyRecState ~= 0 and textLen ~= 0 then
			dgsEditSaveHistory(edit,historyRecState,2,textLen == 1 and 1 or 2,index,textLen)
		else
			return index,textLen
		end
	end
end

function dgsEditSetTypingSound(edit,path)
	if not dgsIsType(edit,"dgs-dxedit") then error(dgsGenAsrt(edit,"dgsEditSetTypingSound",1,"dgs-dxedit")) end
	if not(type(path) == "string") then error(dgsGenAsrt(path,"dgsEditSetTypingSound",2,"string")) end
	if sourceResource then
		if not path:find(":") then
			path = ":"..getResourceName(sourceResource).."/"..path
		end
	end
	if not fileExists(path) then error(dgsGenAsrt(path,"dgsEditSetTypingSound",2,_,_,_,"Couldn't find such file '"..path.."'")) end
	dgsElementData[edit].typingSound = path
end

function dgsEditGetTypingSound(edit)
	if not dgsIsType(edit,"dgs-dxedit") then error(dgsGenAsrt(edit,"dgsEditGetTypingSound",1,"dgs-dxedit")) end
	return dgsElementData[edit].typingSound
end

function dgsEditSetAlignment(edit,horizontal,vertical)
	if not dgsIsType(edit,"dgs-dxedit") then error(dgsGenAsrt(edit,"dgsEditSetAlignment",1,"dgs-dxedit")) end
	if not (not horizontal or HorizontalAlign[horizontal]) then error(dgsGenAsrt(horizontal,"dgsEditSetAlignment",2,"string","left/center/right")) end
	if not (not vertical or VerticalAlign[vertical]) then error(dgsGenAsrt(vertical,"dgsEditSetAlignment",3,"string","top/center/bottom")) end
	local alignment = dgsElementData[edit].alignment
	return dgsSetData(edit,"alignment",{horizontal or alignment[1],vertical or alignment[2]})
end
function dgsEditGetAlignment(edit)
	if not dgsIsType(edit,"dgs-dxedit") then error(dgsGenAsrt(edit,"dgsEditGetAlignment",1,"dgs-dxedit")) end
	local alignment = dgsElementData[edit].alignment
	return alignment[1],alignment[2]
end

function dgsEditSetPlaceHolder(edit,placeHolder)
	if not dgsIsType(edit,"dgs-dxedit") then error(dgsGenAsrt(edit,"dgsEditSetPlaceHolder",1,"dgs-dxedit")) end
	return dgsSetData(edit,"placeHolder",placeHolder)
end

function dgsEditGetPlaceHolder(edit)
	if not dgsIsType(edit,"dgs-dxedit") then error(dgsGenAsrt(edit,"dgsEditGetPlaceHolder",1,"dgs-dxedit")) end
	return dgsElementData[edit].placeHolder
end

function dgsEditAddAutoComplete(edit,str,isSensitive)
	if not dgsIsType(edit,"dgs-dxedit") then error(dgsGenAsrt(edit,"dgsEditAddAutoComplete",1,"dgs-dxedit")) end
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
	if not dgsIsType(edit,"dgs-dxedit") then error(dgsGenAsrt(edit,"dgsEditSetAutoComplete",1,"dgs-dxedit")) end
	if not (type(acTable) == "table") then error(dgsGenAsrt(acTable,"dgsEditSetAutoComplete",2,"table")) end
	local autoComplete = dgsElementData[edit].autoComplete
	return dgsSetData(edit,"autoComplete",acTable)
end

function dgsEditDeleteAutoComplete(edit,str)
	if not dgsIsType(edit,"dgs-dxedit") then error(dgsGenAsrt(edit,"dgsEditDeleteAutoComplete",1,"dgs-dxedit")) end
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
	if not dgsIsType(edit,"dgs-dxedit") then error(dgsGenAsrt(edit,"dgsEditGetAutoComplete",1,"dgs-dxedit")) end
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
	local eleData = dgsElementData[edit]
	if eleData.enableRedoUndoRecord then
		local args = {...}
		local historyTable
		if historyRecState == 2 then
			historyTable = eleData.redoHistory
		else
			if historyRecState == 1 then
				eleData.redoHistory = {} --clear Redo History
			end
			historyTable = eleData.undoHistory
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
		local historyMaxRecords = eleData.historyMaxRecords
		historyTable[historyMaxRecords+1] = nil
		return true
	end
end

function dgsEditDoOpposite(edit,isUndo)
	local eleData = dgsElementData[edit]
	if eleData.enableRedoUndoRecord then
		local prevOp
		if isUndo then
			if eleData.undoHistory[1] then
				prevOp = eleData.undoHistory[1]
				tableRemove(eleData.undoHistory,1)
			end
		else
			if eleData.redoHistory[1] then
				prevOp = eleData.redoHistory[1]
				tableRemove(eleData.redoHistory,1)
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

addEventHandler("onClientGUIChanged",GlobalEdit,function()
	if getElementType(source) == "gui-edit" then
		local dgsEdit = dgsElementData[source].linkedDxEdit
		if isElement(dgsEdit) then
			local text = guiGetText(source)
			local eleData = dgsElementData[dgsEdit]
			local cool = eleData.CoolTime
			if #text ~= 0 then
				if not cool then
					if not eleData.readOnly then
						local caretPos = eleData.caretPos
						local selectFrom = eleData.selectFrom
						if selectFrom-caretPos ~= 0 then
							dgsEditReplaceText(dgsEdit,caretPos,selectFrom,text)
						else
							handleDxEditText(dgsEdit,text,true)
						end
					end
					eleData.CoolTime = true
					guiSetText(source,"")
					eleData.CoolTime = false
				end
			end
		end
	end
end,true)

----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxedit"] = function(source,x,y,w,h,mx,my,cx,cy,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt)
	local bgImage = eleData.isFocused and eleData.bgImage or (eleData.bgImageBlur or eleData.bgImage)
	local bgColor = eleData.isFocused and eleData.bgColor or (eleData.bgColorBlur or eleData.bgColor)
	bgColor = applyColorAlpha(bgColor,parentAlpha)
	local caretColor = applyColorAlpha(eleData.caretColor,parentAlpha)
	if MouseData.focused == source then
		if isConsoleActive() or isMainMenuActive() or isChatBoxInputActive() then
			MouseData.focused = false
		end
	end
	local text = eleData.text
	if eleData.masked then text = strRep(eleData.maskText,utf8Len(text)) end
	local caretPos = eleData.caretPos
	local selectFro = eleData.selectFrom
	local selectColor = MouseData.focused == source and eleData.selectColor or eleData.selectColorBlur
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
			if text == "" and MouseData.focused ~= source then
				local pColor = eleData.placeHolderColor
				local pFont = eleData.placeHolderFont
				local pColorcoded = eleData.placeHolderColorcoded
				local pHolderTextSizeX,pHolderTextSizeY
				local placeHolderTextSize = eleData.placeHolderTextSize
				if placeHolderTextSize then
					pHolderTextSizeX,pHolderTextSizeY = placeHolderTextSize[1],placeHolderTextSize[2]
				else
					pHolderTextSizeX,pHolderTextSizeY = txtSizX,txtSizY
				end
				
				dxDrawText(placeHolder,textX_Left+placeHolderOffset[1],placeHolderOffset[2],textX_Right-posFix+placeHolderOffset[1],h-sidelength+placeHolderOffset[2],pColor,pHolderTextSizeX,pHolderTextSizeY,pFont,alignment[1],alignment[2],false,false,false,pColorcoded)
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
		if not enabledInherited and not enabledSelf then
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
			dxDrawImage(x,y,w,h,bgImage,0,0,0,finalcolor,isPostGUI,rndtgt)
		else
			dxDrawRectangle(x,y,w,h,finalcolor,isPostGUI)
		end
		_dxDrawImage(px,py,pw,ph,renderTarget,0,0,0,tocolor(255,255,255,255*parentAlpha),isPostGUI)
		if placeHolderIgnoreRndTgt then
			if text == "" and MouseData.focused ~= source then
				local pColor = applyColorAlpha(eleData.placeHolderColor,parentAlpha)
				local pFont = eleData.placeHolderFont
				local pColorcoded = eleData.placeHolderColorcoded
				dxSetBlendMode(rndtgt and "modulate_add" or "blend")
				dxDrawText(placeHolder,px+textX_Left+placeHolderOffset[1],py+placeHolderOffset[2],px+textX_Right-posFix+placeHolderOffset[1],py+h-sidelength+placeHolderOffset[2],pColor,txtSizX,txtSizY,pFont,alignment[1],alignment[2],false,false,isPostGUI,pColorcoded)
			end
		end
		if MouseData.focused == source and MouseData.EditMemoCursor then
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
						local offset = eleData.caretOffset
						local selStartY = h/2-h/2*caretHeight+sideheight-offset
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
	return rndtgt,false,mx,my,0,0
end