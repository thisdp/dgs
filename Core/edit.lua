dgsLogLuaMemory()
dgsRegisterType("dgs-dxedit","dgsBasic","dgsType2D")
dgsRegisterProperties("dgs-dxedit",{
	alignment = 					{	{ PArg.String, PArg.String }	},
	allowCopy = 					{	PArg.Bool	},
	autoCompleteSkip = 				{	PArg.Bool	},
	bgColor = 						{	PArg.Color	},
	bgColorBlur = 					{	PArg.Color	},
	bgImage = 						{	PArg.Material+PArg.Nil	},
	bgImageBlur = 					{	PArg.Material+PArg.Nil	},
	caretColor = 					{	PArg.Color	},
	caretHeight = 					{	PArg.Number	},
	caretOffset = 					{	PArg.Number	},
	caretStyle = 					{	PArg.Number	},
	caretThick = 					{	PArg.Number	},
	caretWidth = 					{	{ PArg.Number, PArg.Number, PArg.Bool }	},
	clearSelection = 				{	PArg.Bool	},
	enableTabSwitch = 				{	PArg.Bool	},
	font = 							{	PArg.Font+PArg.String	},
	masked = 						{	PArg.Bool	},
	maskText = 						{	PArg.String	},
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
	readOnlyCaretShow = 			{	PArg.Bool	},
	selectColorBlur = 				{	PArg.Color	},
	selectColor = 					{	PArg.Color	},
	shadow = 						{	{ PArg.Number, PArg.Number, PArg.Color, PArg.Number+PArg.Bool+PArg.Nil, PArg.Font+PArg.Nil }, PArg.Nil	},
	text = 							{	PArg.Text	},
	textColor = 					{	PArg.Color	},
	textSize = 						{	{ PArg.Number, PArg.Number }	},
	typingSound = 					{	PArg.String	},
	typingSoundVolume = 			{	PArg.Number	},
})
--Dx Functions
local dxDrawLine = dxDrawLine
local dxDrawImage = dxDrawImage
local dgsDrawText = dgsDrawText
local dxGetFontHeight = dxGetFontHeight
local dxDrawRectangle = dxDrawRectangle
local dxSetRenderTarget = dxSetRenderTarget
local dxGetTextWidth = dxGetTextWidth
local dxSetBlendMode = dxSetBlendMode
local __dxDrawImage = __dxDrawImage
local dgsCreateRenderTarget = dgsCreateRenderTarget
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
local dgsTriggerEvent = dgsTriggerEvent
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
local autoCompleteParameterFunction = {}
----
function dgsCreateEdit(...)
	local sRes = sourceResource or resource
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
	text = tostring(text or "")
	local edit = createElement("dgs-dxedit")
	dgsSetType(edit,"dgs-dxedit")
	
	local res = sRes ~= resource and sRes or "global"
	local style = styleManager.styles[res]
	local using = style.using
	style = style.loaded[using]
	local systemFont = style.systemFontElement
	
	style = style.edit
	local textSizeX,textSizeY = tonumber(scaleX) or style.textSize[1], tonumber(scaleY) or style.textSize[2]
	dgsElementData[edit] = {
		text = "",
		bgColor = bgColor or style.bgColor,
		bgImage = bgImage or dgsCreateTextureFromStyle(using,res,style.bgImage),
		bgColorBlur = style.bgColorBlur,
		bgImageBlur = dgsCreateTextureFromStyle(using,res,style.bgImageBlur),
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
		placeHolderVisibleWhenFocus = false,
		placeHolderColor = style.placeHolderColor,
		placeHolderColorCoded = style.placeHolderColorCoded,
		placeHolderOffset = style.placeHolderOffset,
		placeHolderTextSize = style.placeHolderTextSize,
		placeHolderIgnoreRenderTarget = style.placeHolderIgnoreRenderTarget,
		padding = style.padding,
		alignment = {"left","center"},
		caretStyle = style.caretStyle,
		caretThick = style.caretThick,
		caretOffset = style.caretOffset,
		caretColor = style.caretColor,
		caretHeight = style.caretHeight, --For caretStyle 0
		caretWidth = {1,8,true}, --For caretStyle 1, {1,true}: textSize * 8   or {10,false}: 10 pixels
		readOnly = false,
		readOnlyCaretShow = false,
		clearSelection = true,
		enableTabSwitch = true,
		clearSwitchPos = false,
		lastSwitchPosition = -1,
		underlineOffset = 0,
		lockView = false,
		allowCopy = true,
		shadow = nil,
		autoCompleteShow = false,
		autoCompleteTextColor = nil,
		autoCompleteSkip = false,
		autoCompleteCount = 0,
		autoComplete = {},
		autoCompleteConfirmKey = "tab",
		selectColor = style.selectColor,
		selectColorBlur = style.selectColorBlur,
		historyMaxRecords = 100,
		enableRedoUndoRecord = true,
		undoHistory = {},
		redoHistory = {},
		typingSound = style.typingSound,
		typingSoundVolume = style.typingSoundVolume,
		maxLength = 0x3FFFFFFF,
		--rtl = nil,	--nil: auto; false:disabled; true: enabled
		insertMode = false,
		editCounts = editsCount, --Tab Switch
		updateRTNextFrame = true,
		
		renderBuffer = {
			placeHolderState = false,
			parentAlphaLast = false,
			isFocused = false,
		},
	}
	dgsSetParent(edit,parent,true,true)
	editsCount = editsCount+1
	calculateGuiPositionSize(edit,x,y,relative or false,w,h,relative or false,true)
	handleDxEditText(edit,text,false,true)
	dgsEditSetCaretPosition(edit,utf8Len(text))
	dgsAddEventHandler("onDgsTextChange",edit,"dgsEditCheckAutoComplete",false)
	dgsAddEventHandler("onDgsMouseMultiClick",edit,"dgsEditCheckMultiClick",false)
	dgsAddEventHandler("onDgsEditPreSwitch",edit,"dgsEditCheckPreSwitch",false)
	onDGSElementCreate(edit,sRes)
	dgsEditRecreateRenderTarget(edit,true)
	return edit
end

function dgsEditRecreateRenderTarget(edit,lateAlloc)
	local eleData = dgsElementData[edit]
	if isElement(eleData.bgRT) then destroyElement(eleData.bgRT) end
	if lateAlloc then
		dgsSetData(edit,"retrieveRT",true)
	else
		local padding = eleData.padding
		local width,height = eleData.absSize[1]-padding[1]*2,eleData.absSize[2]-padding[2]*2
		width,height = width-width%1,height-height%1
		local bgRT,err = dgsCreateRenderTarget(width,height,true,edit)
		if bgRT ~= false then
			dgsAttachToAutoDestroy(bgRT,edit,-1)
		else
			outputDebugString(err,2)
		end
		dgsSetData(edit,"bgRT",bgRT)
		dgsSetData(edit,"retrieveRT",nil)
	end
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
	local eleData = dgsElementData[source]
	if not eleData.autoCompleteSkip and eleData.autoCompleteCount ~= 0 then
		local text = eleData.text
		local autoCompleteResult = {}
		local autoCompleteShow = eleData.autoCompleteShow or {}
		if text ~= "" then
			local currentStart = 0
			local textTable = string.split(text," ")
			local acTable = eleData.autoComplete
			local lowerText = utf8Lower(textTable[1])
			local isSensitive
			local textLen = utf8Len(textTable[1])
			local foundAC = {}
			autoCompleteResult[1] = textTable[1]
			for k,v in pairs(acTable) do
				local isAdvanced = type(v) == "table"
				if isAdvanced then
					isSensitive = v[1]
				else
					isSensitive = v
				end
				local _inputAC = utf8Sub(k,1,textLen)
				local textAutoComplete = isSensitive and _inputAC or utf8Lower(_inputAC)
				local textInput = isSensitive and textTable[1] or lowerText
				if textInput == textAutoComplete then
					foundAC[#foundAC+1] = k
				end
			end
			currentStart = currentStart+textLen+1
			table.sort(foundAC)
			if foundAC[1] then
				autoCompleteResult[1] = textTable[1]..utf8Sub(foundAC[1],textLen+1)
				for i=2,#textTable do
					local textParam = textTable[i]
					local paramLen = utf8Len(textParam)
					autoCompleteResult[i] = textParam
					if eleData.caretPos >= currentStart and eleData.caretPos <= currentStart+paramLen+1 then
						local acParamFunctionName = type(acTable[foundAC[1]]) == "table" and acTable[foundAC[1]][i]
						if acParamFunctionName then
							local acParamFunction = autoCompleteParameterFunction[acParamFunctionName] and autoCompleteParameterFunction[acParamFunctionName][1] or function(input) 
								if input:lower() == acParamFunctionName:sub(1,input:len()):lower() then
									return acParamFunctionName
								end
							end
							local fullParam = acParamFunction(textParam)
							if fullParam then
								autoCompleteResult[i] = textParam..utf8Sub(fullParam,paramLen+1)
							end
						end
					end
					currentStart = currentStart+paramLen+1
				end
			else
				autoCompleteShow.result = ""
			end
		end
		autoCompleteShow.result = table.concat(autoCompleteResult," ")
		eleData.updateRTNextFrame = true
		dgsSetData(source,"autoCompleteShow",autoCompleteShow)
	end
end

function dgsEditCheckPreSwitch()
	if not wasEventCancelled() then
		if not dgsElementData[source].enableTabSwitch then return end
		local parent = dgsElementData[source].parent
		local theTable = isElement(parent) and dgsElementData[parent].children or (dgsElementData[source].alwaysOnBottom and BottomFatherTable or CenterFatherTable)
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
				dgsTriggerEvent("onDgsEditSwitched",theResult,source)
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

function dgsEditSetTextFilter(edit,str)
	if not dgsIsType(edit,"dgs-dxedit") then error(dgsGenAsrt(edit,"dgsEditSetTextFilter",1,"dgs-dxedit")) end
	if type(str) == "string" then
		dgsSetData(edit,"textFilter",str)
	else
		dgsSetData(edit,"textFilter",nil)
	end
	local eleData = dgsElementData[edit]
	
	local res = eleData.resource or "global"
	local style = styleManager.styles[res]
	local using = style.using
	style = style.loaded[using]
	local systemFont = style.systemFontElement
	
	local font = eleData.font or systemFont
	local textSize = eleData.textSize
	local index = dgsEditGetCaretPosition(edit,true)
	local textFilter = str or ""
	local oldText = eleData.text
	local text = utf8Gsub(eleData.text,textFilter,"")
	local textLen = utf8Len(text)
	eleData.text = text
	if eleData.masked then
		text = strRep(eleData.maskText,utf8Len(text))
	end
	eleData.textFontLen = dxGetTextWidth(text,textSize[1],font)
	if index >= textLen then
		dgsEditSetCaretPosition(edit,textLen)
	end
	dgsSetData(edit,"undoHistory",{})
	dgsSetData(edit,"redoHistory",{})
	eleData.updateRTNextFrame = true
	dgsTriggerEvent("onDgsTextChange",edit,oldText)
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
	local deleted = dxGetTextWidth(deletedText,eleData.textSize[1],eleData.font)
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
	dgsSetData(edit,"showPos",showPos-showPos%1)
	if eleData.masked then
		text = strRep(eleData.maskText,utf8Len(text))
	end
	eleData.textFontLen = dxGetTextWidth(text,eleData.textSize[1],eleData.font)
	eleData.updateRTNextFrame = true
	dgsTriggerEvent("onDgsTextChange",edit,oldText)
	return deletedText
end

function dgsEditClearText(edit)
	if not dgsIsType(edit,"dgs-dxedit") then error(dgsGenAsrt(edit,"dgsEditClearText",1,"dgs-dxedit")) end
	local oldText = dgsElementData[edit].text
	dgsElementData[edit].text = ""
	dgsSetData(edit,"caretPos",0)
	dgsSetData(edit,"selectFrom",0)
	dgsElementData[edit].textFontLen = 0
	dgsElementData[edit].updateRTNextFrame = true
	dgsTriggerEvent("onDgsTextChange",edit,oldText)
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
	local eleData = dgsElementData[edit]
	dgsEditRecreateRenderTarget(edit,true)
	local oldPos = dgsEditGetCaretPosition(edit)
	dgsEditSetCaretPosition(edit,0)
	dgsEditSetCaretPosition(edit,oldPos)
	eleData.updateRTNextFrame = true
end

function resetEdit(x,y)
	if dgsGetType(MouseData.focused) == "dgs-dxedit" then
		if MouseData.focused == MouseData.click.left then
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
	
	local res = eleData.resource or "global"
	local style = styleManager.styles[res]
	local using = style.using
	style = style.loaded[using]
	local systemFont = style.systemFontElement
	
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
		if sto-sfrom <= 10 then
			break
		end
	end
	local start = dxGetTextWidth(utf8Sub(text,0,sfrom),txtSizX,font)
	local lastWidth
	for i=sfrom,sto do
		local Next = dxGetTextWidth(utf8Sub(text,i+1,i+1),txtSizX,font)*0.5
		local offsetR = Next+start
		local Last = lastWidth or dxGetTextWidth(utf8Sub(text,i,i),txtSizX,font)*0.5
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
		dgsTriggerEvent("onDgsEditAccepted",dgsEdit,dgsEdit)
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
		local nowLen = dxGetTextWidth(utf8Sub(text,0,pos),eleData.textSize[1],font)
		if nowLen+showPos > sx-padding[1]*2 then
			dgsSetData(edit,"showPos",sx-padding[1]*2-nowLen)
		elseif nowLen+showPos < 0 then
			dgsSetData(edit,"showPos",-nowLen)
		end
	elseif alignment[1] == "right" then
		local nowLen = dxGetTextWidth(utf8Sub(text,pos+1),eleData.textSize[1],font)
		if nowLen+showPos > sx-padding[1]*2 then
			dgsSetData(edit,"showPos",sx-padding[1]*2-nowLen)
		elseif nowLen+showPos < 0 then
			dgsSetData(edit,"showPos",-nowLen)
		end
	elseif alignment[1] == "center" then
		local __width = eleData.textFontLen
		local nowLen = dxGetTextWidth(utf8Sub(text,0,pos),eleData.textSize[1],font)
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
	
	local res = eleData.resource or "global"
	local style = styleManager.styles[res]
	local using = style.using
	style = style.loaded[using]
	local systemFont = style.systemFontElement
	
	local font = eleData.font or systemFont
	local textSize = eleData.textSize
	local _index = dgsEditGetCaretPosition(edit,true)
	local index = index or _index
	local textFilter = eleData.textFilter or ""
	local textDataLen = utf8Len(textData)
	local text = utf8Sub(text,1,maxLength-textDataLen)
	local _textLen = utf8Len(text)
	local textData_add = utf8Sub(textData,1,index)..text..utf8Sub(textData,index+1)
	local newTextData = utf8Gsub(textData_add,textFilter,"")
	local textLen = utf8Len(newTextData)-textDataLen
	eleData.text = newTextData
	newTextData = eleData.masked and strRep(eleData.maskText,utf8Len(newTextData)) or newTextData
	eleData.textFontLen = dxGetTextWidth(newTextData,eleData.textSize[1],eleData.font)
	if not noAffectCaret then
		if index <= _index then
			dgsEditSetCaretPosition(edit,index+textLen)
		end
	end
	eleData.updateRTNextFrame = true
	dgsTriggerEvent("onDgsTextChange",edit,oldText)
	if eleData.enableRedoUndoRecord then
		historyRecState = historyRecState or 1
		if historyRecState ~= 0 and textLen ~= 0 then
			dgsEditSaveHistory(edit,historyRecState,2,textLen == 1 and 1 or 2,index,textLen)
		else
			return index,textLen
		end
	end
end

function dgsEditSetTypingSound(edit,path,volume)
	if not dgsIsType(edit,"dgs-dxedit") then error(dgsGenAsrt(edit,"dgsEditSetTypingSound",1,"dgs-dxedit")) end
	if not(type(path) == "string") then error(dgsGenAsrt(path,"dgsEditSetTypingSound",2,"string")) end
	if sourceResource then
		if not path:find(":") then
			path = ":"..getResourceName(sourceResource).."/"..path
		end
	end
	if not fileExists(path) then error(dgsGenAsrt(path,"dgsEditSetTypingSound",2,_,_,_,"Couldn't find such file '"..path.."'")) end
	dgsElementData[edit].typingSound = path
	dgsElementData[edit].typingSoundVolume = tonumber(volume)
	return true
end

function dgsEditGetTypingSound(edit)
	if not dgsIsType(edit,"dgs-dxedit") then error(dgsGenAsrt(edit,"dgsEditGetTypingSound",1,"dgs-dxedit")) end
	return dgsElementData[edit].typingSound
end

function dgsEditSetTypingSoundVolume(edit,volume)
	if dgsGetType(edit) ~= "dgs-dxedit" then error(dgsGenAsrt(edit,"dgsEditSetTypingSoundVolume",1,"dgs-dxedit")) end
	if type(volume) ~= "number" then error(dgsGenAsrt(volume,"dgsEditSetTypingSoundVolume",2,"number")) end
	dgsElementData[edit].typingSoundVolume = volume
	return true
end

function dgsEditGetTypingSoundVolume(edit)
	if dgsGetType(edit) ~= "dgs-dxedit" then error(dgsGenAsrt(edit,"dgsEditGetTypingSoundVolume",1,"dgs-dxedit")) end
	return dgsElementData[edit].typingSoundVolume or 1
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

function dgsEditAutoCompleteAddParameterFunction(parameterType,parameterFunction)
	if not dgsIsType(parameterType,"string") then error(dgsGenAsrt(parameterType,"dgsEditAddAutoCompleteParameterFunction",1,"string")) end
	if not dgsIsType(parameterFunction,"string") then error(dgsGenAsrt(parameterFunction,"dgsEditAddAutoCompleteParameterFunction",2,"string")) end
	local fnc,err = loadstring(parameterFunction)
	if err then error(dgsGenAsrt(parameterFunction,"dgsEditAddAutoCompleteParameterFunction",_,_,_,err)) end
	autoCompleteParameterFunction[parameterType] = {fnc,parameterFunction}
	return true
end

function dgsEditAutoCompleteRemoveParameterFunction(parameterType)
	if not dgsIsType(parameterType,"string") then error(dgsGenAsrt(parameterType,"dgsEditRemoteAutoCompleteParameterFunction",1,"string")) end
	autoCompleteParameterFunction[parameterType] = nil
	return true
end

--[[
Auto Complete String Format:
{Identifier [, parameterType1, parameterType2, ... ]}
]]
function dgsEditAddAutoComplete(edit,str,isSensitive,isAdvanced)
	if not dgsIsType(edit,"dgs-dxedit") then error(dgsGenAsrt(edit,"dgsEditAddAutoComplete",1,"dgs-dxedit")) end
	local strTyp = type(str)
	if strTyp == "table" then
		if isAdvanced then
			local autoComplete = dgsElementData[edit].autoComplete
			if not autoComplete[identifier] then dgsElementData[edit].autoCompleteCount = dgsElementData[edit].autoCompleteCount+1 end
			local identifier = str[1]
			str[1] = isSensitive == nil and v or isSensitive
			autoComplete[identifier] = str
			return true
		else
			local autoComplete = dgsElementData[edit].autoComplete
			for k,v in pairs(str) do
				if not autoComplete[k] then dgsElementData[edit].autoCompleteCount = dgsElementData[edit].autoCompleteCount+1 end
				autoComplete[k] = isSensitive == nil and v or isSensitive
			end
			return true
		end
	elseif strTyp == "string" then
		local autoComplete = dgsElementData[edit].autoComplete
		if not autoComplete[str] then dgsElementData[edit].autoCompleteCount = dgsElementData[edit].autoCompleteCount+1 end
		autoComplete[str] = isSensitive
		return true
	end
	return false
end

function dgsEditSetAutoComplete(edit,acTable)
	if not dgsIsType(edit,"dgs-dxedit") then error(dgsGenAsrt(edit,"dgsEditSetAutoComplete",1,"dgs-dxedit")) end
	if not (type(acTable) == "table") then error(dgsGenAsrt(acTable,"dgsEditSetAutoComplete",2,"table")) end
	local autoComplete = dgsElementData[edit].autoComplete
	dgsElementData[edit].autoCompleteCount = table.count(autoComplete)
	return dgsSetData(edit,"autoComplete",acTable)
end

function dgsEditDeleteAutoComplete(edit,str)
	if not dgsIsType(edit,"dgs-dxedit") then error(dgsGenAsrt(edit,"dgsEditDeleteAutoComplete",1,"dgs-dxedit")) end
	local strTyp = type(str)
	if strTyp == "table" then
		local autoComplete = dgsElementData[edit].autoComplete
		for k,v in pairs(str) do
			if autoComplete[k] then dgsElementData[edit].autoCompleteCount = dgsElementData[edit].autoCompleteCount-1 end
			autoComplete[k] = isSensitive == nil and v or isSensitive
		end
		return true
	elseif strTyp == "string" then
		local autoComplete = dgsElementData[edit].autoComplete
		if autoComplete[str] then dgsElementData[edit].autoCompleteCount = dgsElementData[edit].autoCompleteCount-1 end
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
-----------------------PropertyListener-------------------------
----------------------------------------------------------------
function dgsEditUpdateRTNextFrame(dgsEle)
	dgsElementData[dgsEle].updateRTNextFrame = true
end

dgsOnPropertyChange["dgs-dxedit"] = {
	text = function(dgsEle,key,value,oldValue)
		handleDxEditText(dgsEle,value)
	end,
	textSize = function(dgsEle,key,value,oldValue)
		dgsElementData[dgsEle].textFontLen = dxGetTextWidth(dgsElementData[dgsEle].text,value[1],dgsElementData[dgsEle].font)
		dgsElementData[dgsEle].updateRTNextFrame = true
	end,
	textColor = dgsEditUpdateRTNextFrame,
	caretPos = dgsEditUpdateRTNextFrame,
	selectFrom = dgsEditUpdateRTNextFrame,
	font = function(dgsEle,key,value,oldValue)
		--Multilingual
		if type(value) == "table" then
			dgsElementData[dgsEle]._translation_font = value
			value = dgsGetTranslationFont(dgsEle,value,sourceResource)
		else
			dgsElementData[dgsEle]._translation_font = nil
		end
		dgsElementData[dgsEle].font = value
		
		local eleData = dgsElementData[dgsEle]
		eleData.textFontLen = dxGetTextWidth(eleData.text,eleData.textSize[1],eleData.font)
		dgsElementData[dgsEle].updateRTNextFrame = true
	end,
	padding = function(dgsEle,key,value,oldValue)
		configEdit(dgsEle)
	end,
	showPos = dgsEditUpdateRTNextFrame,
	masked = dgsEditUpdateRTNextFrame,
	placeHolder = function(dgsEle,key,value,oldValue)
		dgsElementData[dgsEle].updateRTNextFrame = true
		--Multilingual
		if type(value) == "table" then
			dgsElementData[dgsEle]._translation_placeHolderText = value
			value = dgsTranslate(dgsEle,value,sourceResource)
		else
			dgsElementData[dgsEle]._translation_placeHolderText = nil
		end
		dgsElementData[dgsEle].placeHolder = tostring(value)
	end,
	placeHolderFont = function(dgsEle,key,value,oldValue)
		dgsElementData[dgsEle].updateRTNextFrame = true
		--Multilingual
		if type(value) == "table" then
			dgsElementData[dgsEle]._translation_placeHolderFont = value
			value = dgsGetTranslationFont(dgsEle,value,sourceResource)
		else
			dgsElementData[dgsEle]._translation_placeHolderFont = nil
		end
		dgsElementData[dgsEle].placeHolderFont = value
	end,
	placeHolderVisibleWhenFocus = dgsEditUpdateRTNextFrame,
	placeHolderColor = dgsEditUpdateRTNextFrame,
	placeHolderColorcoded = dgsEditUpdateRTNextFrame,
	placeHolderOffset = dgsEditUpdateRTNextFrame,
	placeHolderTextSize = dgsEditUpdateRTNextFrame,
	placeHolderIgnoreRenderTarget = dgsEditUpdateRTNextFrame,
}
----------------------------------------------------------------
---------------------Translation Updater------------------------
----------------------------------------------------------------
dgsOnTranslationUpdate["dgs-dxedit"] = function(dgsEle,key,value)
	local text = dgsElementData[dgsEle]._translation_placeHolderText
	if text then
		if key then text[key] = value end
		dgsSetData(dgsEle,"placeHolder",text)
	end
	local font = dgsElementData[dgsEle]._translation_placeHolderFont
	if font then
		dgsSetData(dgsEle,"placeHolderFont",font)
	end
	dgsElementData[dgsEle].updateTextRTNextFrame = true
end

----------------------------------------------------------------
-----------------------VisibilityManage-------------------------
----------------------------------------------------------------
dgsOnVisibilityChange["dgs-dxedit"] = function(dgsElement,selfVisibility,inheritVisibility)
	if not selfVisibility or not inheritVisibility then
		dgsEditRecreateRenderTarget(dgsElement,true)
	end
end
----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxedit"] = function(source,x,y,w,h,mx,my,cx,cy,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt)
	local renderBuffer = eleData.renderBuffer
	if eleData.retrieveRT then
		dgsEditRecreateRenderTarget(source)
		eleData.updateRTNextFrame = true
	end
	local bgImage = eleData.isFocused and eleData.bgImage or (eleData.bgImageBlur or eleData.bgImage)
	local bgColor = eleData.isFocused and eleData.bgColor or (eleData.bgColorBlur or eleData.bgColor)
	bgColor = applyColorAlpha(bgColor,parentAlpha)
	local caretColor = applyColorAlpha(eleData.caretColor,parentAlpha)
	local isFocused = MouseData.focused == source
	if isFocused == source then
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
	if eleData.masked then text = strRep(eleData.maskText,utf8Len(text)) end
	local caretPos = eleData.caretPos
	local selectFro = eleData.selectFrom
	local selectColor = applyColorAlpha(MouseData.focused == source and eleData.selectColor or eleData.selectColorBlur,parentAlpha)
	
	local res = eleData.resource or "global"
	local style = styleManager.styles[res]
	local using = style.using
	style = style.loaded[using]
	local systemFont = style.systemFontElement
	
	local font = eleData.font or systemFont
	local txtSizX,txtSizY = eleData.textSize[1],eleData.textSize[2] or eleData.textSize[1]
	local alignment = eleData.alignment
	local textLeft,textRight,textTop,textBottom
	local textColor = eleData.textColor
	
	local selx = 0
	if selectFro-caretPos > 0 then
		selx = dxGetTextWidth(utf8Sub(text,caretPos+1,selectFro),txtSizX,font)
	elseif selectFro-caretPos < 0 then
		selx = -dxGetTextWidth(utf8Sub(text,selectFro+1,caretPos),txtSizX,font)
	end
	local showPos = eleData.showPos
	local padding = eleData.padding
	local paddingX,paddingY = padding[1]-padding[1]%1,padding[2]-padding[2]%1
	local caretHeight = eleData.caretHeight
	local textTop,textBottom = 0,h-paddingY*2
	local selStartY = textBottom/2-textBottom/2*caretHeight
	local selEndY = (textBottom/2-selStartY)*2
	local width,selectX,selectW
	local posFix = 0
	local placeHolder = eleData.placeHolder
	local placeHolderIgnoreRndTgt = eleData.placeHolderIgnoreRenderTarget
	local placeHolderOffset = eleData.placeHolderOffset
	if alignment[1] == "left" then
		width = dxGetTextWidth(utf8Sub(text,0,caretPos),txtSizX,font)
		textLeft,textRight = showPos,w-paddingX
		selectX,selectW = width+showPos,selx
	elseif alignment[1] == "center" then
		local __width = eleData.textFontLen
		width = dxGetTextWidth(utf8Sub(text,0,caretPos),txtSizX,font)
		textLeft,textRight = showPos,w-paddingX
		selectX,selectW = width+showPos*0.5+w*0.5-__width*0.5-paddingX+1,selx
		posFix = ((text:reverse():find("%S") or 1)-1)*dxGetTextWidth(" ",txtSizX,font)
	elseif alignment[1] == "right" then
		width = dxGetTextWidth(utf8Sub(text,caretPos+1),txtSizX,font)
		textLeft,textRight = x,w-paddingX*2-showPos
		selectX,selectW = textRight-width,selx
		posFix = ((text:reverse():find("%S") or 1)-1)*dxGetTextWidth(" ",txtSizX,font)
	end
	
	local isPlaceHolderShown = text == "" and placeHolder ~= "" and (MouseData.focused ~= source or eleData.placeHolderVisibleWhenFocus) 
	if renderBuffer.placeHolderState ~= isPlaceHolderShown then
		renderBuffer.placeHolderState = isPlaceHolderShown
		eleData.updateRTNextFrame = true
	end
	if renderBuffer.parentAlphaLast ~= parentAlpha then
		renderBuffer.parentAlphaLast = parentAlpha
		eleData.updateRTNextFrame = true
	end
	
	local shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont
	if shadow then
		shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont = shadow[1],shadow[2],shadow[3],shadow[4],shadow[5]
		shadowColor = applyColorAlpha(shadowColor or white,parentAlpha)
	end
	
	if eleData.bgRT and (eleData.updateRTNextFrame or dgsRenderInfo.RTRestoreNeed) then
		dxSetRenderTarget(eleData.bgRT,true)
		if selx ~= 0 then
			dxDrawRectangle(selectX,selStartY,selectW,selEndY,selectColor)
		end
		dxSetBlendMode("modulate_add")
		if eleData.underline then
			local textBottomeight = dxGetFontHeight(txtSizY,font)
			local lineOffset = eleData.underlineOffset+h*0.5+textBottomeight*0.5
			local lineWidth = eleData.underlineWidth
			local textFontLen = eleData.textFontLen
			dxDrawLine(showPos,lineOffset,showPos+textFontLen,lineOffset,applyColorAlpha(textColor,parentAlpha),lineWidth)
		end
		eleData.updateRTNextFrame = nil
		textLeft = textLeft-textLeft%1
		textRight = textRight-textRight%1
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
				dgsDrawText(placeHolder,textLeft+placeHolderOffset[1],textTop+placeHolderOffset[2],textRight-posFix+placeHolderOffset[1],textBottom+placeHolderOffset[2],pColor,pHolderTextSizeX,pHolderTextSizeY,pFont,alignment[1],alignment[2],false,false,false,pColorcoded,subPixelPos,0,0,0,0,shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont)
			end
		end
		if eleData.autoCompleteShow then
			dgsDrawText(eleData.autoCompleteShow.result or "",textLeft,textTop,textRight-posFix,textBottom,eleData.autoCompleteTextColor or applyColorAlpha(textColor,0.7*parentAlpha),txtSizX,txtSizY,font,alignment[1],alignment[2],false,false,false,false,subPixelPos,0,0,0,0,shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont)
		end
		
		dgsDrawText(text,textLeft,textTop,textRight-posFix,textBottom,applyColorAlpha(textColor,parentAlpha),txtSizX,txtSizY,font,alignment[1],alignment[2],false,false,false,false,subPixelPos,0,0,0,0,shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont)
	end
	dxSetRenderTarget(rndtgt)
	dxSetBlendMode(rndtgt and "modulate_add" or "blend")
	local px,py,pw,ph = x+paddingX,y+paddingY,w-paddingX*2,textBottom
	local finalcolor
	if not enabledInherited and not enabledSelf then
		if type(eleData.disabledColor) == "number" then
			finalcolor = eleData.disabledColor
		elseif eleData.disabledColor == true then
			local r,g,b,a = fromcolor(bgColor)
			local average = (r+g+b)/3*eleData.disabledColorPercent
			finalcolor = tocolor(average,average,average,a)
		else
			finalcolor = bgColor
		end
	else
		finalcolor = bgColor
	end
	dxDrawImage(x,y,w,h,bgImage,0,0,0,finalcolor,isPostGUI,rndtgt)
	dxSetBlendMode(rndtgt and "modulate_add" or "add")
	if eleData.bgRT then
		__dxDrawImage(px,py,pw,ph,eleData.bgRT,0,0,0,white,isPostGUI)
	end
	if placeHolderIgnoreRndTgt then
		if isPlaceHolderShown then
			local pColor = applyColorAlpha(eleData.placeHolderColor,parentAlpha)
			local pFont = eleData.placeHolderFont
			local pColorCoded = eleData.placeHolderColorCoded
			dxSetBlendMode(rndtgt and "modulate_add" or "blend")
			dgsDrawText(placeHolder,px+textLeft+placeHolderOffset[1],py+placeHolderOffset[2],px+textRight-posFix+placeHolderOffset[1],py+textBottom+placeHolderOffset[2],pColor,txtSizX,txtSizY,pFont,alignment[1],alignment[2],false,false,isPostGUI,pColorcoded,subPixelPos,0,0,0,0,shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont)
		end
	end

	if MouseData.focused == source and MouseData.EditMemoCursor then
		local CaretShow = true
		if eleData.readOnly then
			CaretShow = eleData.readOnlyCaretShow
		end
		if CaretShow then
			local caretStyle = eleData.caretStyle
			local selStartX = selectX+x+paddingX-1
			selStartX = selStartX-selStartX%1
			if caretStyle == 0 then
				if selStartX+1 >= x+paddingX and selStartX <= x+w-paddingX then
					local offset = eleData.caretOffset
					local selStartY = h/2-h/2*caretHeight+paddingY
					local selEndY = (h/2-selStartY)*2
					dxDrawLine(selStartX,y+selStartY-offset,selStartX,y+selEndY+selStartY-offset,caretColor,eleData.caretThick,isPostGUI)
				end
			elseif caretStyle == 1 then
				local caretWidth = eleData.caretWidth
				if caretWidth[3] == true then
					local cWidth = dxGetTextWidth(utf8Sub(text,caretPos+1,caretPos+1),txtSizX,font)
					if cWidth == 0 then
						cWidth = txtSizX*caretWidth[2]
					end
					caretWidth = cWidth*caretWidth[1]
				else
					caretWidth = caretWidth[1]
				end
				if selStartX+1 >= x+paddingX and selStartX+caretWidth <= x+w-paddingX then
					local offset = eleData.caretOffset
					local textBottomeight = dxGetFontHeight(txtSizY,font)
					local selStartY = y+h/2+textBottomeight/2+paddingY-offset
					dxDrawLine(selStartX,selStartY,selStartX+caretWidth,selStartY,caretColor,eleData.caretThick,isPostGUI)
				end
			end
		end
	end
	return rndtgt,false,mx,my,0,0
end