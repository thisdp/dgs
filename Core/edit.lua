local editsCount = 1
function dgsDxCreateEdit(x,y,sx,sy,text,relative,parent,textcolor,scalex,scaley,imagebg,colorbg,selectmode)
	assert(type(x) == "number","@dgsDxCreateEdit argument 1,expect number got "..type(x))
	assert(type(y) == "number","@dgsDxCreateEdit argument 2,expect number got "..type(y))
	assert(type(sx) == "number","@dgsDxCreateEdit argument 3,expect number got "..type(sx))
	assert(type(sy) == "number","@dgsDxCreateEdit argument 4,expect number got "..type(sy))
	text = tostring(text)
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"@dgsDxCreateEdit argument 7,expect dgs-dxgui got "..dgsGetType(parent))
	end
	local edit = createElement("dgs-dxedit")
	dgsSetType(edit,"dgs-dxedit")
	dgsSetData(edit,"imagebg",imagebg)
	dgsSetData(edit,"colorbg",colorbg or tocolor(200,200,200,255))
	dgsSetData(edit,"text",tostring(text) or "")
	dgsSetData(edit,"textcolor",textcolor or tocolor(0,0,0,255))
	dgsSetData(edit,"textsize",{scalex or 1,scaley or 1})
	dgsSetData(edit,"cursorpos",0)
	dgsSetData(edit,"masked",false)
	dgsSetData(edit,"maskText","*")
	dgsSetData(edit,"showPos",0)
	dgsSetData(edit,"cursorStyle",0)
	dgsSetData(edit,"cursorThick",1.2)
	dgsSetData(edit,"cursorOffset",0)
	dgsSetData(edit,"readOnly",false)
	dgsSetData(edit,"font",systemFont)
	dgsSetData(edit,"side",0)
	dgsSetData(edit,"sidecolor",tocolor(0,0,0,255))
	dgsSetData(edit,"selectfrom",0)
	dgsSetData(edit,"useFloor",false)
	dgsSetData(edit,"enableTabSwitch",true)
	dgsSetData(edit,"selectmode",selectmode and false or true) ----true->选择色在文字底层;false->选择色在文字顶层
	dgsSetData(edit,"selectcolor",selectmode and tocolor(50,150,255,100) or tocolor(50,150,255,200))
	local gedit = guiCreateEdit(0,0,0,0,tostring(text) or "",false,GlobalEditParent)
	guiSetProperty(gedit,"ClippedByParent","False")
	dgsSetData(edit,"edit",gedit)
	dgsSetData(gedit,"dxedit",edit)
	guiSetAlpha(gedit,0)
	dgsSetData(edit,"maxLength",guiGetProperty(gedit,"MaxTextLength"))
	dgsSetData(edit,"editCounts",editsCount) --Tab Switch
	editsCount = editsCount+1
	if isElement(parent) then
		dgsSetParent(edit,parent)
	else
		table.insert(MaxFatherTable,edit)
	end
	insertResourceDxGUI(sourceResource,edit)
	triggerEvent("onClientDgsDxGUIPreCreate",edit)
	calculateGuiPositionSize(edit,x,y,relative or false,sx,sy,relative or false,true)
	triggerEvent("onClientDgsDxGUICreate",edit)
	local sx,sy = dgsGetSize(edit,false)
	local renderTarget = dxCreateRenderTarget(sx-4,sy,true)
	dgsSetData(edit,"renderTarget",renderTarget)
	dgsDxEditSetCaretPosition(edit,utf8.len(tostring(text) or ""))
	return edit
end

function dgsDxEditMoveCaret(edit,offset,noselect)
	assert(dgsGetType(edit) == "dgs-dxedit","@dgsDxEditMoveCaret argument 1,expect dgs-dxedit got "..dgsGetType(edit))
	assert(type(offset) == "number","@dgsDxEditMoveCaret argument 2,expect number got "..type(offset))
	local guiedit = dgsElementData[edit].edit
	local text = guiGetText(guiedit)
	if dgsElementData[edit].masked then
		text = string.rep(dgsElementData[edit].maskText,utf8.len(text))
	end
	local pos = dgsElementData[edit].cursorpos+math.floor(offset)
	if pos < 0 then
		pos = 0
	elseif pos > utf8.len(text) then
		pos = utf8.len(text)
	end
	local showPos = dgsElementData[edit].showPos
	local font = dgsElementData[edit].font
	local nowLen = dxGetTextWidth(utf8.sub(text,0,pos),dgsElementData[edit].textsize[1],font)
	local sx,sy = dgsGetSize(edit)
	if nowLen+showPos > sx-4 then
		dgsSetData(edit,"showPos",sx-4-nowLen)
	elseif nowLen+showPos < 0 then
		dgsSetData(edit,"showPos",-nowLen)
	end
	dgsSetData(edit,"cursorpos",pos)
	if not noselect then
		dgsSetData(edit,"selectfrom",pos)
	end
	resetTimer(MouseData.EditTimer)
	MouseData.editCursor = true
	return true
end

function dgsDxEditSetCaretPosition(edit,pos,noselect)
	assert(dgsGetType(edit) == "dgs-dxedit","@dgsDxEditSetCaretPosition argument 1,expect dgs-dxedit got "..dgsGetType(edit))
	assert(type(pos) == "number","@dgsDxEditSetCaretPosition argument 2,expect number got "..type(pos))
	local text = guiGetText(dgsElementData[edit].edit)
	if dgsElementData[edit].masked then
		text = string.rep(dgsElementData[edit].maskText,utf8.len(text))
	end
	if pos > utf8.len(text) then
		pos = utf8.len(text)
	elseif pos < 0 then
		pos = 0
	end
	dgsSetData(edit,"cursorpos",math.floor(pos))
	if not noselect then
		dgsSetData(edit,"selectfrom",math.floor(pos))
	end
	local showPos = dgsElementData[edit].showPos
	local font = dgsElementData[edit].font
	local nowLen = dxGetTextWidth(utf8.sub(text,0,pos),dgsGetData(edit,"textsize")[1],font)
	local sx,sy = dgsGetSize(edit,false)
	if nowLen+showPos > sx-4 then
		dgsSetData(edit,"showPos",sx-4-nowLen)
	elseif nowLen+showPos < 0 then
		dgsSetData(edit,"showPos",-nowLen)
	end
	return true
end

function dgsDxEditGetCaretPosition(edit)
	assert(dgsGetType(edit) == "dgs-dxedit","@dgsDxEditGetCaretPosition argument 1,expect dgs-dxedit got "..dgsGetType(edit))
	return dgsGetData(edit,"cursorpos")
end

function dgsDxEditSetCaretStyle(edit,style)
	assert(dgsGetType(edit) == "dgs-dxedit","@dgsDxEditSetCaretStyle argument 1,expect dgs-dxedit got "..dgsGetType(edit))
	assert(type(style) == "number","@dgsDxEditSetCaretStyle argument 2,expect number got "..type(style))
	return dgsSetData(edit,"cursorStyle",style)
end

function dgsDxEditSetMaxLength(edit,maxLength)
	assert(dgsGetType(edit) == "dgs-dxedit","@dgsDxEditSetMaxLength argument 1,expect dgs-dxedit got "..dgsGetType(edit))
	assert(type(maxLength) == "number","@dgsDxEditSetMaxLength argument 2,expect number got "..type(maxLength))
	local guiedit = dgsElementData[edit].edit
	dgsSetData(edit,"maxLength",maxLength)
	return guiEditSetMaxLength(guiedit,maxLength)
end

function dgsDxEditGetMaxLength(edit,fromgui)
	assert(dgsGetType(edit) == "dgs-dxedit","@dgsDxEditGetMaxLength argument 1,expect dgs-dxedit got "..dgsGetType(edit))
	local guiedit = dgsElementData[edit].edit
	if fromgui then
		return guiGetProperty(guiedit,"MaxTextLength")
	else
		return dgsElementData[edit].maxLength
	end
end

function dgsDxEditSetReadOnly(edit,state)
	assert(dgsGetType(edit) == "dgs-dxedit","@dgsDxEditSetReadOnly argument 1,expect dgs-dxedit got "..dgsGetType(edit))
	local guiedit = dgsElementData[edit].edit
	return dgsSetData(edit,"readOnly",state and true or false)
end

function dgsDxEditGetReadOnly(edit)
	assert(dgsGetType(edit) == "dgs-dxedit","@dgsDxEditGetReadOnly argument 1,expect dgs-dxedit got "..dgsGetType(edit))
	return dgsGetData(edit,"readOnly")
end

function configEdit(source)
	local myedit = dgsGetData(source,"edit")
	local x,y = unpack(dgsGetData(source,"absSize"))
	guiSetSize(myedit,x,y,false)
	local px,py = math.floor(x-4), math.floor(y)
	local renderTarget = dxCreateRenderTarget(px,py,true)
	dgsSetData(source,"renderTarget",renderTarget)
	local oldPos = dgsDxEditGetCaretPosition(source)
	dgsDxEditSetCaretPosition(source,0)
	dgsDxEditSetCaretPosition(source,oldPos)
end

function resetEdit(x,y)
	if dgsGetType(MouseData.nowShow) == "dgs-dxedit" then
		if MouseData.nowShow == MouseData.clickl then
			local edit = dgsElementData[MouseData.nowShow].edit
			local pos = searchEditMousePosition(MouseData.nowShow,x*sW,y*sH)
			dgsDxEditSetCaretPosition(MouseData.nowShow,pos,true)
		end
	end
end
addEventHandler("onClientCursorMove",root,resetEdit)

function searchEditMousePosition(dxedit,posx,posy)
	local edit = dgsElementData[dxedit].edit
	if isElement(edit) then
		local text = guiGetText(edit)
		local sfrom,sto = 0,utf8.len(text)
		if dgsElementData[edit].masked then
			text = string.rep(dgsElementData[edit].maskText,sto)
		end
		local font = dgsElementData[dxedit].font or systemFont
		local txtSizX = dgsElementData[dxedit].textsize[1]
		local offset = dgsElementData[dxedit].showPos
		local x = dgsGetPosition(dxedit,false,true)
		local pos = posx-x-offset
		local templen = 0
		for i=1,sto do
			local strlen = dxGetTextWidth(utf8.sub(text,sfrom+1,sto/2+sfrom/2),txtSizX,font)
			local len1 = strlen+templen
			if pos < len1 then
				sto = math.floor(sto/2+sfrom/2)
			elseif pos > len1 then
				sfrom = math.floor(sto/2+sfrom/2)
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
				return sfrom
			elseif i >= sto and pos >= offsetR then
				return sto
			elseif pos >= offsetL and pos <= offsetR then
				return i
			end
		end
		return -1
	end
end

function checkEditMousePosition(button,state,x,y)
	if dgsGetType(source) == "dgs-dxedit" then
		if state == "down" then
			local pos = searchEditMousePosition(source,x,y)
			dgsDxEditSetCaretPosition(source,pos)
		end
	end
end
addEventHandler("onClientDgsDxMouseClick",root,checkEditMousePosition)

addEventHandler("onClientGUIAccepted",root,function()
	local mydxedit = dgsGetData(source,"dxedit")
	if dgsGetType(mydxedit) == "dgs-dxedit" then
		local cmd = dgsGetData(mydxedit,"mycmd")
		if dgsGetType(cmd) == "dgs-dxcmd" then
			local text = guiGetText(source)
			if text ~= "" then
				receiveCmdEditInput(cmd,text)
			end
			guiSetText(source,"")
		end
	end
end)

function dgsDxEditSetWhiteList(edit,str)
	assert(dgsGetType(edit) == "dgs-dxedit","@dgsDxEditSetWhiteList argument 1,expect dgs-dxedit got "..dgsGetType(edit))
	if type(str) == "string" then
		dgsSetData(edit,"whiteList",str)
	else
		dgsSetData(edit,"whiteList",nil)
	end
end

addEventHandler("onClientDgsDxEditPreSwitch",resourceRoot,function()
	if not wasEventCancelled() then
		if not dgsElementData[source].enableTabSwitch then return end
		local parent = FatherTable[source]
		local theTable = isElement(parent) and ChildrenTable[parent] or (dgsElementData[source].alwaysOnBottom and BottomFatherTable or MaxFatherTable)
		local id = dgsElementData[source].editCounts
		if id then
			local theNext
			local theFirst
			for k,v in ipairs(theTable) do
				local editCounts = dgsElementData[v].editCounts
				if editCounts then
					if id ~= editCounts and dgsGetType(v) == "dgs-dxedit" and dgsElementData[v].enableTabSwitch then
						if editCounts < id then
							theFirst = theFirst and (dgsElementData[theFirst].editCounts > editCounts and v or theFirst) or v
						else
							theNext = theNext and (dgsElementData[theNext].editCounts > editCounts and v or theNext) or v
						end
					end
				end
			end
			local theFinal = theNext or theFirst
			if theFinal then
				dgsDxGUIBringToFront(theFinal)
				triggerEvent("onClientDgsDxEditSwitched",theFinal,source)
			end
		end
	end
end)