dgsExportedFunctionName = {}
dgsResName = getResourceName(getThisResource())
local metafile = xmlLoadFile("meta.xml")
local nodes = xmlNodeGetChildren(metafile)

addEventHandler("onClientResourceStart",resourceRoot,function()
	triggerEvent("onDgsStart",resourceRoot,dgsResName)
end)

for k,v in ipairs(nodes) do
	if xmlNodeGetName(v) == "export" then
		local func = xmlNodeGetAttribute(v,"function")
		local typ = xmlNodeGetAttribute(v,"type")
		if typ == "client" or typ == "shared" then
			dgsExportedFunctionName[func] = func
		end
	end
end

function dgsGetExportedFunctionName(name)
	if name then
		return dgsExportedFunctionName[name]
	else
		return dgsExportedFunctionName
	end
end

function dgsImportFunction(name,nameAs)
	if not name then
		local allCode = [[
		--Check Error Message Above
		if not dgsImportHead then
			local getResourceRootElement = getResourceRootElement
			local call = call
			local getResourceFromName = getResourceFromName
			local tostring = tostring
			local outputDebugString = outputDebugString
			local DGSCallMT = {}
			local dgsImportHead = {}
			dgsImportHead.dgsName = "]]..dgsResName..[["
			dgsImportHead.dgsResource = getResourceFromName(dgsImportHead.dgsName)
			dgsRoot = getResourceRootElement(dgsImportHead.dgsResource)
			addEventHandler("onClientResourceStop",dgsRoot,function()
				outputDebugString("[DGS] Alert! DGS has stopped. Everything keeps disconnected from DGS till the next time DGS starts!",2)
				function onDgsStart(dResN)
					outputDebugString("[DGS] DGS has started, reconnecting to DGS...",3)
					dgsImportHead = nil
					loadstring(exports[dResN]:dgsImportFunction())()
					removeEventHandler("onDgsStart",root,onDgsStart)
				end
				addEventHandler("onDgsStart",root,onDgsStart)
			end)

			function DGSCallMT:__index(k)
				if type(k) ~= 'string' then k = tostring(k) end
				self[k] = function(...)
					assert(dgsImportHead,"DGS import data is missing or DGS is not running, please reimport dgs functions("..getResourceName(getThisResource())..")")
					if isElement(dgsRoot) then
						return call(dgsImportHead.dgsResource, k, ...)
					else
						dgsImportHead = nil
						dgsRoot = nil
						return nil
					end
				end
				return self[k]
			end
			DGS = setmetatable({}, DGSCallMT)
			
			function unloadDGSFunction()
				
			end
		end
		]]
		for k,v in pairs(dgsExportedFunctionName) do
			allCode = allCode.."\n "..k.." = DGS."..k..";"
		end
		return allCode
	else
		assert(dgsExportedFunctionName[name],"Bad Argument @dgsImportFunction at argument 1, the function is undefined")
		nameAs = nameAs or name
		return nameAs.." = DGS."..name..";"
	end
end

function dgsG2DLoadHooker()
	return [[
		local isGUIGridList = {}
		loadstring(exports.dgs:dgsImportFunction())()
		_guiBringToFront = guiBringToFront
		_guiCreateFont = guiCreateFont
		_guiBlur = guiBlur
		_guiFocus = guiFocus
		_guiGetAlpha = guiGetAlpha
		_guiGetEnabled = guiGetEnabled
		_guiGetFont = guiGetFont
		_guiGetInputEnabled = guiGetInputEnabled
		_guiGetInputMode = guiGetInputMode
		_guiGetPosition = guiGetPosition
		_guiGetProperties = guiGetProperties
		_guiGetProperty = guiGetProperty
		_guiGetScreenSize = guiGetScreenSize
		_guiGetSize = guiGetSize
		_guiGetText = guiGetText
		_guiGetVisible = guiGetVisible
		_guiMoveToBack = guiMoveToBack
		_guiSetAlpha = guiSetAlpha
		_guiSetEnabled = guiSetEnabled
		_guiSetFont = guiSetFont
		_guiSetInputEnabled = guiSetInputEnabled
		_guiSetInputMode = guiSetInputMode
		_guiSetPosition = guiSetPosition
		_guiSetProperty = guiSetProperty
		_guiSetSize = guiSetSize
		_guiSetText = guiSetText
		_guiSetVisible = guiSetVisible
		_guiCreateBrowser = guiCreateBrowser
		_guiCreateButton = guiCreateButton
		_guiCheckBoxGetSelected = guiCheckBoxGetSelected
		_guiCheckBoxSetSelected = guiCheckBoxSetSelected
		_guiCreateCheckBox = guiCreateCheckBox
		_guiCreateComboBox = guiCreateComboBox
		_guiComboBoxAddItem = guiComboBoxAddItem
		_guiComboBoxClear = guiComboBoxClear
		_guiComboBoxGetItemCount = guiComboBoxGetItemCount
		_guiComboBoxGetItemText = guiComboBoxGetItemText
		_guiComboBoxGetSelected = guiComboBoxGetSelected
		_guiComboBoxIsOpen = guiComboBoxIsOpen
		_guiComboBoxRemoveItem = guiComboBoxRemoveItem
		_guiComboBoxSetItemText = guiComboBoxSetItemText
		_guiComboBoxSetOpen = guiComboBoxSetOpen
		_guiComboBoxSetSelected = guiComboBoxSetSelected
		_guiCreateEdit = guiCreateEdit
		_guiEditGetCaretIndex = guiEditGetCaretIndex
		_guiEditGetMaxLength = guiEditGetMaxLength
		_guiEditIsMasked = guiEditIsMasked
		_guiEditIsReadOnly = guiEditIsReadOnly
		_guiEditSetCaretIndex = guiEditSetCaretIndex
		_guiEditSetMasked = guiEditSetMasked
		_guiEditSetMaxLength = guiEditSetMaxLength
		_guiEditSetReadOnly = guiEditSetReadOnly
		_guiCreateGridList = guiCreateGridList
		_guiGridListAddColumn = guiGridListAddColumn
		_guiGridListAddRow = guiGridListAddRow
		_guiGridListAutoSizeColumn = guiGridListAutoSizeColumn
		_guiGridListClear = guiGridListClear
		_guiGridListGetColumnCount = guiGridListGetColumnCount
		_guiGridListGetColumnTitle = guiGridListGetColumnTitle
		_guiGridListGetColumnWidth = guiGridListGetColumnWidth
		_guiGridListGetItemColor = guiGridListGetItemColor
		_guiGridListGetItemData = guiGridListGetItemData
		_guiGridListGetItemText = guiGridListGetItemText
		_guiGridListGetRowCount = guiGridListGetRowCount
		_guiGridListGetSelectedCount = guiGridListGetSelectedCount
		_guiGridListGetSelectedItem = guiGridListGetSelectedItem
		_guiGridListGetSelectedItems = guiGridListGetSelectedItems
		_guiGridListGetSelectionMode = guiGridListGetSelectionMode
		_guiGridListIsSortingEnabled = guiGridListIsSortingEnabled
		_guiGridListRemoveColumn = guiGridListRemoveColumn
		_guiGridListRemoveRow = guiGridListRemoveRow
		_guiGridListSetColumnTitle = guiGridListSetColumnTitle
		_guiGridListSetColumnWidth = guiGridListSetColumnWidth
		_guiGridListSetItemColor = guiGridListSetItemColor
		_guiGridListSetItemData = guiGridListSetItemData
		_guiGridListSetItemText = guiGridListSetItemText
		_guiGridListSetScrollBars = guiGridListSetScrollBars
		_guiGridListSetSelectedItem = guiGridListSetSelectedItem
		_guiGridListSetSelectionMode = guiGridListSetSelectionMode
		_guiGridListSetSortingEnabled = guiGridListSetSortingEnabled
		_guiCreateMemo = guiCreateMemo
		_guiMemoGetCaretIndex = guiMemoGetCaretIndex
		_guiMemoIsReadOnly = guiMemoIsReadOnly
		_guiMemoSetCaretIndex = guiMemoSetCaretIndex
		_guiMemoSetReadOnly = guiMemoSetReadOnly
		_guiCreateProgressBar = guiCreateProgressBar
		_guiProgressBarGetProgress = guiProgressBarGetProgress
		_guiProgressBarSetProgress = guiProgressBarSetProgress
		_guiCreateRadioButton = guiCreateRadioButton
		_guiRadioButtonGetSelected = guiRadioButtonGetSelected
		_guiRadioButtonSetSelected = guiRadioButtonSetSelected
		_guiCreateScrollBar = guiCreateScrollBar
		_guiScrollBarGetScrollPosition = guiScrollBarGetScrollPosition
		_guiScrollBarSetScrollPosition = guiScrollBarSetScrollPosition
		_guiCreateScrollPane = guiCreateScrollPane
		_guiScrollPaneSetScrollBars = guiScrollPaneSetScrollBars
		_guiCreateStaticImage = guiCreateStaticImage
		_guiStaticImageGetNativeSize = guiStaticImageGetNativeSize
		_guiStaticImageLoadImage = guiStaticImageLoadImage
		_guiCreateTabPanel = guiCreateTabPanel
		_guiGetSelectedTab = guiGetSelectedTab
		_guiSetSelectedTab = guiSetSelectedTab
		_guiCreateTab = guiCreateTab
		_guiDeleteTab = guiDeleteTab
		_guiCreateLabel = guiCreateLabel
		_guiLabelGetColor = guiLabelGetColor
		_guiLabelGetFontHeight = guiLabelGetFontHeight
		_guiLabelGetTextExtent = guiLabelGetTextExtent
		_guiLabelSetColor = guiLabelSetColor
		_guiLabelSetHorizontalAlign = guiLabelSetHorizontalAlign
		_guiLabelSetVerticalAlign = guiLabelSetVerticalAlign
		_guiCreateWindow = guiCreateWindow
		_guiWindowIsMovable = guiWindowIsMovable
		_guiWindowIsSizable = guiWindowIsSizable
		_guiWindowSetMovable = guiWindowSetMovable
		_guiWindowSetSizable = guiWindowSetSizable
		_guiGridListGetHorizontalScrollPosition = guiGridListGetHorizontalScrollPosition
		_guiGridListSetHorizontalScrollPosition = guiGridListSetHorizontalScrollPosition
		_guiGridListGetVerticalScrollPosition = guiGridListGetVerticalScrollPosition
		_guiGridListSetVerticalScrollPosition = guiGridListSetVerticalScrollPosition
		_guiMemoGetVerticalScrollPosition = guiMemoGetVerticalScrollPosition
		_guiMemoSetVerticalScrollPosition = guiMemoSetVerticalScrollPosition
		_guiScrollPaneGetHorizontalScrollPosition = guiScrollPaneGetHorizontalScrollPosition
		_guiScrollPaneGetVerticalScrollPosition = guiScrollPaneGetVerticalScrollPosition
		_guiScrollPaneSetHorizontalScrollPosition = guiScrollPaneSetHorizontalScrollPosition
		_guiScrollPaneSetVerticalScrollPosition = guiScrollPaneSetVerticalScrollPosition
		_guiGridListInsertRowAfter = guiGridListInsertRowAfter
		_guiGetBrowser = guiGetBrowser
	--GUI TO DGS
		guiBringToFront = dgsBringToFront
		guiCreateFont = dgsCreateFont
		guiBlur = dgsBlur
		guiFocus = dgsFocus
		guiGetAlpha = dgsGetAlpha
		guiGetEnabled = dgsGetEnabled
		guiGetFont = dgsGetFont
		guiGetInputEnabled = dgsGetInputEnabled
		guiGetInputMode = dgsGetInputMode
		guiGetPosition = dgsGetPosition
		guiGetProperties = dgsGetProperties
		guiGetProperty = dgsGetProperty
		guiGetScreenSize = dgsGetScreenSize
		guiGetSize = dgsGetSize
		guiGetText = dgsGetText
		guiGetVisible = dgsGetVisible
		guiMoveToBack = dgsMoveToBack
		guiSetAlpha = dgsSetAlpha
		guiSetEnabled = dgsSetEnabled
		guiSetFont = dgsSetFont
		guiSetInputEnabled = dgsSetInputEnabled
		guiSetInputMode = dgsSetInputMode
		guiSetPosition = dgsSetPosition
		guiSetProperty = dgsSetProperty
		guiSetSize = dgsSetSize
		guiSetText = dgsSetText
		guiSetVisible = dgsSetVisible
		guiCreateBrowser = dgsCreateBrowser
		guiCreateButton = dgsCreateButton
		guiCheckBoxGetSelected = dgsCheckBoxGetSelected
		guiCheckBoxSetSelected = dgsCheckBoxSetSelected
		guiCreateCheckBox = dgsCreateCheckBox
		guiCreateComboBox = dgsCreateComboBox
		guiComboBoxAddItem = dgsComboBoxAddItem
		guiComboBoxClear = dgsComboBoxClear
		guiComboBoxGetItemCount = dgsComboBoxGetItemCount
		guiComboBoxGetItemText = dgsComboBoxGetItemText
		guiComboBoxGetSelected = dgsComboBoxGetSelected
		guiComboBoxIsOpen = dgsComboBoxGetState
		guiComboBoxRemoveItem = dgsComboBoxRemoveItem
		guiComboBoxSetItemText = dgsComboBoxSetItemText
		guiComboBoxSetOpen = dgsComboBoxSetState
		guiComboBoxSetSelected = dgsComboBoxSetSelected
		guiCreateEdit = dgsCreateEdit
		guiEditGetCaretIndex = dgsEditGetCaretPosition
		guiEditGetMaxLength = dgsEditGetMaxLength
		guiEditIsMasked = dgsEditGetMasked
		guiEditIsReadOnly = dgsEditGetReadOnly
		guiEditSetCaretIndex = dgsEditSetCaretPosition
		guiEditSetMasked = dgsEditSetMasked
		guiEditSetMaxLength = dgsEditSetMaxLength
		guiEditSetReadOnly = dgsEditSetReadOnly
		guiCreateGridList = function(...)
			local gl = dgsCreateGridList(...)
			isGUIGridList[gl] = true
			addEventHandler("onDgsDestroy",gl,function()
				isGUIGridList[source] = nil
			end,false)
			return gl
		end
		guiGridListAddColumn = dgsGridListAddColumn
		guiGridListInsertRowAfter = function(gl,row,...)
			local rowData = dgsGetProperty(gl,"rowData")
			if isGUIGridList[gl] then
				row = tonumber(row) or #rowData
				return dgsGridListInsertRowAfter(gl,row+1,...)-1
			else
				row = tonumber(row) or #rowData+1
				return dgsGridListInsertRowAfter(gl,row,...)
			end
		end
		guiGridListAddRow = function(gl,row,...)
			local rowData = dgsGetProperty(gl,"rowData")
			if isGUIGridList[gl] then
				row = tonumber(row) or #rowData
				return dgsGridListAddRow(gl,row+1,...)-1
			else
				row = tonumber(row) or #rowData+1
				return dgsGridListAddRow(gl,row,...)
			end
		end
		guiGridListGetItemColor = function(gl,row,...)
			row = isGUIGridList[gl] and row+1 or row
			return dgsGridListGetItemColor(gl,row,...)
		end
		guiGridListGetItemData = function(gl,row,...)
			row = isGUIGridList[gl] and row+1 or row
			return dgsGridListGetItemData(gl,row,...)
		end
		guiGridListSetItemData = function(gl,row,...)
			row = isGUIGridList[gl] and row+1 or row
			return dgsGridListSetItemData(gl,row,...)
		end
		guiGridListGetItemText = function(gl,row,...)
			row = isGUIGridList[gl] and row+1 or row
			return dgsGridListGetItemText(gl,row,...)
		end
		guiGridListSetItemText = function(gl,row,...)
			row = isGUIGridList[gl] and row+1 or row
			return dgsGridListSetItemText(gl,row,...)
		end
		guiGridListGetSelectedCount = function(gl,row,...)
			row = isGUIGridList[gl] and row+1 or row
			return dgsGridListGetSelectedCount(gl,row,...)
		end
		guiGridListGetSelectedItem = function(gl)
			if isGUIGridList[gl] then
				local selected = dgsGridListGetSelectedItem(gl)
				if selected == -1 then return -1 end
				return selected-1
			else
				return dgsGridListGetSelectedItem(gl)
			end
		end
		guiGridListGetSelectedItems = function(gl,isOrigin)
			local newItems = dgsGridListGetSelectedItems(gl,isOrigin)
			if not isOrigin then
				for k,v in ipairs(newItems) do
					newItems[k].row = newItems[k].row+1
				end
			else
				--To Do
			end
			return newItems
		end
		guiGridListRemoveRow = function(gl,row,...)
			row = isGUIGridList[gl] and row+1 or row
			return dgsGridListRemoveRow(gl,row,...)
		end
		guiGridListSetItemColor = function(gl,row,...)
			row = isGUIGridList[gl] and row+1 or row
			return dgsGridListSetItemColor(gl,row,...)
		end
		guiGridListSetSelectedItem = function(gl,row,...)
			row = isGUIGridList[gl] and row+1 or row
			return dgsGridListSetSelectedItem(gl,row,...)
		end
		guiGridListAutoSizeColumn = dgsGridListAutoSizeColumn
		guiGridListClear = dgsGridListClear
		guiGridListGetColumnCount = dgsGridListGetColumnCount
		guiGridListGetColumnTitle = dgsGridListGetColumnTitle
		guiGridListGetColumnWidth = dgsGridListGetColumnWidth
		guiGridListGetRowCount = dgsGridListGetRowCount
		guiGridListGetSelectionMode = dgsGridListGetSelectionMode
		guiGridListIsSortingEnabled = dgsGridListGetSortEnabled
		guiGridListRemoveColumn = dgsGridListRemoveColumn
		guiGridListSetColumnTitle = dgsGridListSetColumnTitle
		guiGridListSetColumnWidth = dgsGridListSetColumnWidth
		guiGridListSetScrollBars = dgsGridListSetScrollBarState
		guiGridListSetSelectionMode = dgsGridListSetSelectionMode
		guiGridListSetSortingEnabled = dgsGridListSetSortEnabled
		guiCreateMemo = dgsCreateMemo
		guiMemoGetCaretIndex = dgsMemoGetCaretIndex
		guiMemoIsReadOnly = dgsMemoIsReadOnly
		guiMemoSetCaretIndex = dgsMemoSetCaretIndex
		guiMemoSetReadOnly = dgsMemoSetReadOnly
		guiCreateProgressBar = dgsCreateProgressBar
		guiProgressBarGetProgress = dgsProgressBarGetProgress
		guiProgressBarSetProgress = dgsProgressBarSetProgress
		guiCreateRadioButton = dgsCreateRadioButton
		guiRadioButtonGetSelected = dgsRadioButtonGetSelected
		guiRadioButtonSetSelected = dgsRadioButtonSetSelected
		guiCreateScrollBar = dgsCreateScrollBar
		guiScrollBarGetScrollPosition = dgsScrollBarGetScrollPosition
		guiScrollBarSetScrollPosition = dgsScrollBarSetScrollPosition
		guiCreateScrollPane = dgsCreateScrollPane
		guiScrollPaneSetScrollBars = dgsScrollPaneSetScrollBarState
		guiCreateStaticImage = dgsCreateImage
		guiStaticImageGetNativeSize = dgsImageGetNativeSize
		guiStaticImageLoadImage = dgsImageSetImage
		guiCreateTabPanel = dgsCreateTabPanel
		guiGetSelectedTab = dgsGetSelectedTab
		guiSetSelectedTab = dgsSetSelectedTab
		guiCreateTab = dgsCreateTab
		guiDeleteTab = dgsDeleteTab
		guiCreateLabel = dgsCreateLabel
		guiLabelGetColor = dgsLabelGetColor
		guiLabelGetFontHeight = dgsLabelGetFontHeight
		guiLabelGetTextExtent = dgsLabelGetTextExtent
		guiLabelSetColor = dgsLabelSetColor
		guiLabelSetHorizontalAlign = dgsLabelSetHorizontalAlign
		guiLabelSetVerticalAlign = dgsLabelSetVerticalAlign
		guiCreateWindow = function(...)
			local window = dgsCreateWindow(...)
			dgsSetProperty(window,"ignoreTitle",true)
			dgsWindowSetCloseButtonEnabled(window,false)
			return window
		end
		guiWindowIsMovable = dgsWindowGetMovable
		guiWindowIsSizable = dgsWindowGetSizable
		guiWindowSetMovable = dgsWindowSetMovable
		guiWindowSetSizable = dgsWindowSetSizable
		guiGridListGetHorizontalScrollPosition = dgsGridListGetHorizontalScrollPosition
		guiGridListSetHorizontalScrollPosition = dgsGridListSetHorizontalScrollPosition
		guiGridListGetVerticalScrollPosition = dgsGridListGetVerticalScrollPosition
		guiGridListSetVerticalScrollPosition = dgsGridListSetVerticalScrollPosition
		guiMemoGetVerticalScrollPosition = dgsMemoGetVerticalScrollPosition
		guiMemoSetVerticalScrollPosition = dgsMemoSetVerticalScrollPosition
		guiScrollPaneGetHorizontalScrollPosition = dgsScrollPaneGetHorizontalScrollPosition
		guiScrollPaneGetVerticalScrollPosition = dgsScrollPaneGetVerticalScrollPosition
		guiScrollPaneSetHorizontalScrollPosition = dgsScrollPaneSetHorizontalScrollPosition
		guiScrollPaneSetVerticalScrollPosition = dgsScrollPaneSetVerticalScrollPosition
		guiGetBrowser = dgsGetBrowser
		
		addEvent("onDgsEditAccepted-C",true)
		addEvent("onDgsTextChange-C",true)
		addEvent("onDgsComboBoxSelect-C",true)
		addEvent("onDgsTabSelect-C",true)
		if not getElementData(root,"__DGSDef") then
			setElementData(root,"__DGSDef",true)
			function fncTrans(...)
				triggerEvent(eventName.."-C",source,source,...)
			end
			addEventHandler("onDgsEditAccepted",root,fncTrans)
			addEventHandler("onDgsTextChange",root,fncTrans)
			addEventHandler("onDgsComboBoxSelect",root,fncTrans)
			addEventHandler("onDgsTabSelect",root,fncTrans)
		end
		local eventReplace = {
			onClientGUIAccepted="onDgsEditAccepted-C",
			onClientGUIBlur="onDgsBlur",
			onClientGUIChanged="onDgsTextChange-C",
			onClientGUIClick="onDgsMouseClickUp",
			onClientGUIComboBoxAccepted="onDgsComboBoxSelect-C",
			onClientGUIDoubleClick="onDgsMouseDoubleClick",
			onClientGUIFocus="onDgsFocus",
			onClientGUIMouseDown="onDgsMouseDown",
			onClientGUIMouseUp="onDgsMouseUp",
			onClientGUIMove="onDgsElementMove",
			onClientGUIScroll="onDgsElementScroll",
			onClientGUISize="onDgsElementSize",
			onClientGUITabSwitched="onDgsTabSelect-C",
			onClientMouseEnter="onDgsMouseEnter",
			onClientMouseLeave="onDgsMouseLeave",
			onClientMouseMove="onDgsMouseMove",
			onClientMouseWheel="onDgsMouseWheel",
		}
		_addEventHandler = addEventHandler
		addEventHandler = function(even,...)
			_addEventHandler(eventReplace[even] or even,...)
		end
	]]
end
