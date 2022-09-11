dgsLogLuaMemory()
local loadstring = loadstring
dgsExportedFunctionName = {}
dgsResName = getResourceName(getThisResource())

addEventHandler("onClientResourceStart",resourceRoot,function()
	triggerEvent("onDgsStart",resourceRoot,dgsResName)
end)

function dgsImportFunction(name,nameAs)
	if not sourceResource or sourceResource == getThisResource() then return "return true" end
	if not name then
		local allCode = [[
		--Check Error Message Above
		if not dgsImportHead then
			local getResourceRootElement = getResourceRootElement
			local call = call
			local getResourceFromName = getResourceFromName
			local tostring = tostring
			local unpack = unpack
			local outputDebugString = outputDebugString
			local DGSCallMT = {}
			local functionCallLogger = {}
			dgsImportHead = {}
			dgsImportHead.dgsName = "]]..dgsResName..[["
			dgsImportHead.dgsResource = getResourceFromName(dgsImportHead.dgsName)
			dgsRoot = getResourceRootElement(dgsImportHead.dgsResource)
			dgsImportHead.dgsTypes = getElementData(dgsRoot,"DGSType")
			addEvent("onDgsRequestCreateRemoteElement",true)
			addEventHandler("onDgsRequestCreateRemoteElement",resourceRoot,function(createType,...)
				if createType == "shader" then
					local shader = dxCreateShader(...)
					call(dgsImportHead.dgsResource, "dgsPushElement",shader,createType)
				elseif createType == "rendertarget" then
					local RT = dxCreateRenderTarget(...)
					call(dgsImportHead.dgsResource, "dgsPushElement",RT,createType)
				elseif createType == "texture" then
					local tex = dxCreateTexture(...)
					call(dgsImportHead.dgsResource, "dgsPushElement",tex,createType)
				elseif createType == "font" then
					local font = dxCreateFont(...)
					call(dgsImportHead.dgsResource, "dgsPushElement",font,createType)
				elseif createType:sub(1,6) == "dgs-dx" then
					local dgsElement = createElement(createType)
					call(dgsImportHead.dgsResource, "dgsPushElement",dgsElement,createType)
				end
			end)
			addEventHandler("onClientResourceStop",dgsRoot,function()
				outputDebugString("[DGS] Alert! DGS has stopped. Everything keeps disconnected from DGS till the next time DGS starts!",2)
				function onDgsStart(dResN)
					outputDebugString("[DGS] DGS has started, reconnecting to DGS...",3)
					dgsImportHead = nil
					dgsRoot = nil
					loadstring(exports[dResN]:dgsImportFunction())()
					removeEventHandler("onDgsStart",root,onDgsStart)
				end
				addEventHandler("onDgsStart",root,onDgsStart)
			end)
			local isTraceDebug = getElementData(localPlayer,"DGS-DebugTracer") or (getElementData(localPlayer,"DGS-DEBUG") == 3)
			addEventHandler("onClientElementDataChange",localPlayer,function(key,_,v)
				if key == "DGS-DebugTracer" or key == "DGS-DEBUG" then
					isTraceDebug = getElementData(localPlayer,"DGS-DebugTracer") and (getElementData(localPlayer,"DGS-DEBUG") == 3)
				end
			end,false)
			local fncCallLoggerDef = {line=-1,file="Unknown",fncName="Unknown"}
			local fncCallLoggerSelf = {line=-1,file="Unknown",fncName="Unknown"}
			function DGSCallMT:__index(fncName)
				if type(fncName) ~= 'string' then fncName = tostring(fncName) end
				self[fncName] = function(...)
					if not dgsImportHead then error("DGS import data is missing or DGS is not running, please reimport dgs functions("..getResourceName(getThisResource())..")") end
					if isElement(dgsRoot) then
						local isCreateFunction = fncName:sub(1,9) == "dgsCreate"
						if isTraceDebug then
							local data
							local index = 1
							local isLocated = false
							repeat
								local d = debug.getinfo(index)
								if not d then break end
								data = d
								index = index+1
								if data.func == self[fncName] then
									if isLocated == true then
										break
									else
										isLocated = true	--Need to get the next index
									end
								end
							until data and data.source:sub(1,1) == "@" 
							if data then
								functionCallLogger = fncCallLoggerSelf
								functionCallLogger.line=data.currentline
								functionCallLogger.file=data.source
								functionCallLogger.fncName=fncName
								local retValue = {call(dgsImportHead.dgsResource, fncName, ...)}
								if isCreateFunction and isElement(retValue[1]) and dgsGetType(retValue[1],true) then
									call(dgsImportHead.dgsResource, "dgsSetProperty",retValue[1],"debugTrace",functionCallLogger)
								end
								return unpack(retValue)
							else
								functionCallLogger = fncCallLoggerDef
							end
						end
						return call(dgsImportHead.dgsResource, fncName, ...)
					else
						dgsImportHead = nil
						dgsRoot = nil
						return nil
					end
				end
				return self[fncName]
			end
			addEventHandler("DGSI_onDebugRequestContext",resourceRoot,function()
				triggerEvent("DGSI_onDebugSendContext",resourceRoot,functionCallLogger)
			end,false)
			addEventHandler("DGSI_onDebug",resourceRoot,function(debugType,...)
				if isTraceDebug then
					if debugType == "PropertyCompatibility" then
						local line,file,fncName = functionCallLogger.line,functionCallLogger.file,functionCallLogger.fncName
						local oldPropertyName,newPropertyName = ...
						outputDebugString("Compatibility Check "..file..":"..line.." @'"..fncName.."', replace property '"..oldPropertyName.."' with '"..newPropertyName.."'",4,255,180,100)
					elseif debugType == "FunctionCompatibility" then
						local line,file,fncName = functionCallLogger.line,functionCallLogger.file,functionCallLogger.fncName
						local oldFunctionName,newFunctionName = ...
						outputDebugString("Compatibility Check "..file..":"..line.." @'"..fncName.."', replace function '"..oldFunctionName.."' with '"..newFunctionName.."'",4,255,180,100)
					elseif debugType == "ArgumentCompatibility" then
						local line,file,fncName = functionCallLogger.line,functionCallLogger.file,functionCallLogger.fncName
						local argument,detail = ...
						outputDebugString("Compatibility Check "..file..":"..line.." @'"..fncName.."', at argument "..argument..". "..detail,4,255,180,100)
					elseif debugType == "AnimationError" then
						local property,file,line,fncName = ...
						if file and line and fncName then
							outputDebugString("Traced "..file..":"..line.." @'"..fncName.."'",4,255,180,100)
						end
					end
				end
			end,false)
			DGS = setmetatable({}, DGSCallMT)
			triggerEvent("DGSI_onImport",root,resourceRoot)
		end
		]]
		for i,name in ipairs(getResourceExportedFunctions()) do
			allCode = allCode.."\n "..name.." = DGS."..name..";"
		end
		return allCode
	else
		assert(dgsExportedFunctionName[name],"Bad Argument @dgsImportFunction at argument 1, the function is undefined")
		nameAs = nameAs or name
		return nameAs.." = DGS['"..name.."'];"
	end
end

G2DHookerEvents = {}
function dgsG2DLoadHooker(isLocal)
	if table.count(G2DHookerEvents) == 0 then 
		addEventHandler("onDgsEditAccepted",root,handleHookerEvents)
		addEventHandler("onDgsTextChange",root,handleHookerEvents)
		addEventHandler("onDgsComboBoxSelect",root,handleHookerEvents)
		addEventHandler("onDgsTabSelect",root,handleHookerEvents)
	end
	G2DHookerEvents[sourceResource or resource] = true
	local usingLocal = isLocal and "local" or ""
	return [[
		if loadedG2D then return end
		isGUIGridList = {}
		isGUIComboBox = {}
		loadedG2D = true
		loadstring(exports["]]..dgsResName..[["]:dgsImportFunction())()
		for fName,fnc in pairs(_G) do
			if fName:sub(1,3) == "gui" then
				_G["_"..fName] = fnc
			end
		end
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
		guiSetInputEnabled = dgsSetInputEnabled
		guiSetInputMode = dgsSetInputMode
		guiSetPosition = dgsSetPosition
		guiSetSize = function (gl,w,h,relative)
			local v = dgsSetSize(gl,w,h,relative)
			if _getElementType(gl) == "dgs-dxcombobox" then 
				local width,height = dgsGetSize(gl,false)
				dgsSetSize(gl,width,22,false)
				dgsComboBoxSetBoxHeight(gl,height-22,false)
			end
			return v
		end
		guiSetText = dgsSetText
		guiSetVisible = dgsSetVisible
		guiCreateBrowser = dgsCreateBrowser
		guiCreateButton = dgsCreateButton
		guiCheckBoxGetSelected = dgsCheckBoxGetSelected
		guiCheckBoxSetSelected = dgsCheckBoxSetSelected
		guiCreateCheckBox = dgsCreateCheckBox
		guiCreateComboBox = function(...)
			local x,y,w,h,caption,relative,parent = ...
			local combobox = dgsCreateComboBox(x,y,w,h,caption,relative,parent)
			local width,height = dgsGetSize(combobox,false)
			dgsSetSize(combobox,width,22,false)
			dgsSetProperty(combobox,"relative",{relative,relative})
			dgsComboBoxSetBoxHeight(combobox,height-22,false)
			isGUIComboBox[combobox] = true
			addEventHandler("onDgsDestroy",combobox,function()
				isGUIComboBox[source] = nil
			end,false)
			return combobox
		end
		guiComboBoxAddItem = dgsComboBoxAddItem
		guiComboBoxClear = dgsComboBoxClear
		guiComboBoxGetItemCount = dgsComboBoxGetItemCount
		guiComboBoxGetItemText = function(combobox,item,...)
			if item and item ~= -1 then
				item = isGUIComboBox[combobox] and item+1 or item
			end
			return dgsComboBoxGetItemText(combobox,item,...)
		end
		guiComboBoxGetSelected = function(combobox,...)
			if isGUIComboBox[combobox] then
				local selectedItem = dgsComboBoxGetSelectedItem(combobox,...)
				selectedItem = selectedItem == -1 and -1 or selectedItem-1
				return selectedItem
			else
				return dgsComboBoxGetSelectedItem(combobox,...)
			end
		end
		guiComboBoxIsOpen = dgsComboBoxGetState
		guiComboBoxRemoveItem = function(combobox,item,...)
			if item and item ~= -1 then
				item = isGUIComboBox[combobox] and item+1 or item
			end
			return dgsComboBoxRemoveItem(combobox,item,...)
		end
		guiComboBoxSetItemText = function(combobox,item,...)
			if item and item ~= -1 then
				item = isGUIComboBox[combobox] and item+1 or item
			end
			return dgsComboBoxSetItemText(combobox,item,...)
		end
		guiComboBoxSetOpen = dgsComboBoxSetState
		guiComboBoxSetSelected = function(combobox,item,...)
			if item and isGUIComboBox[combobox] and item ~= -1 then
				item = item+1
			end
			return dgsComboBoxSetSelectedItem(combobox,item,...)
		end
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
			dgsSetProperty(gl,"defaultSortFunctions",{"numGreaterLowerStrFirst","numGreaterUpperStrFirst"})
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
			if row and row ~= -1 then
				row = isGUIGridList[gl] and row+1 or row
			end
			return dgsGridListGetItemColor(gl,row,...)
		end
		guiGridListGetItemData = function(gl,row,...)
			if row and row ~= -1 then
				row = isGUIGridList[gl] and row+1 or row
			end
			return dgsGridListGetItemData(gl,row,...)
		end
		guiGridListSetItemData = function(gl,row,...)
			if row and row ~= -1 then
				row = isGUIGridList[gl] and row+1 or row
			end
			return dgsGridListSetItemData(gl,row,...)
		end
		guiGridListGetItemText = function(gl,row,...)
			if row and row ~= -1 then
				row = isGUIGridList[gl] and row+1 or row
			end
			return dgsGridListGetItemText(gl,row,...)
		end
		guiGridListSetItemText = function(gl,row,...)
			if row and row ~= -1 then
				row = isGUIGridList[gl] and row+1 or row
			end
			return dgsGridListSetItemText(gl,row,...)
		end
		guiGridListGetSelectedCount = dgsGridListGetSelectedCount
		guiGridListGetSelectedItem = function(gl)
			if isGUIGridList[gl] then
				local selectedRow,selectedColumn = dgsGridListGetSelectedItem(gl)
				selectedRow = selectedRow == -1 and -1 or selectedRow-1
				selectedColumn = selectedColumn == -1 and 0 or selectedColumn
				return selectedRow,selectedColumn
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
			if row and row ~= -1 then
				row = isGUIGridList[gl] and row+1 or row
			end
			return dgsGridListRemoveRow(gl,row,...)
		end
		guiGridListSetItemColor = function(gl,row,...)
			if row and row ~= -1 then
				row = isGUIGridList[gl] and row+1 or row
			end
			return dgsGridListSetItemColor(gl,row,...)
		end
		guiGridListSetSelectedItem = function(gl,row,...)
			if row and row ~= -1 then
				row = isGUIGridList[gl] and row+1 or row
			end
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
		guiMemoGetCaretIndex = dgsMemoGetCaretPosition
		guiMemoIsReadOnly = dgsMemoIsReadOnly
		guiMemoSetCaretIndex = dgsMemoSetCaretPosition
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

		local fontReplace = {
            ["default-normal"]="default",
			["default-small"]="arial",
			["default-bold-small"]="default-bold",
			["clear-normal"]="clear",
			["sa-gothic"]="beckett",
			["sa-header"]="diploma",
        }
        guiSetFont = function(gl,font)
            return dgsSetFont(gl,fontReplace[font] or font)
		end

		guiSetProperty = function(gl,prop,v)
			local eleType = getElementType(gl)
			if prop == "NormalTextColour" or prop == "HoverTextColour" or prop == "PushedTextColour" then
				local a,r,g,b = getColorFromString("#"..v)
				local ct = dgsGetProperty(gl,"textColor")
				if prop == "NormalTextColour" and type (ct) ~= "table" then
					return dgsSetProperty(gl,"textColor",tocolor(r,g,b,a))
				else
					if type(ct) ~= "table" then
						ct = {ct}
					end
					ct[prop == "NormalTextColour" and 1 or prop == "HoverTextColour" and 2 or 3] = tocolor(r,g,b,a)
					return dgsSetProperty(gl,"textColor",ct)
				end
			elseif prop == "Disabled" then
				return dgsSetProperty(gl,"enabled",not v:lower() == "true")
			elseif prop == "Visible" then
				return dgsSetVisible(gl,v:lower() == "true")
			elseif prop == "ReadOnly" then
				return dgsSetProperty(gl,"readOnly",v:lower() == "true")
			elseif prop == "Alpha" or prop == "Font" or prop == "Text" then
				return dgsSetProperty(gl,prop:lower(),v)
			else
				return dgsSetProperty(gl,prop,v)
			end
		end
		local eventReplace = {
			onClientGUIAccepted="onDgsEditAccepted-C",
			onClientGUIBlur="onDgsBlur",
			onClientGUIChanged="onDgsTextChange-C",
			onClientGUIClick="onDgsMouseClickUp",
			onClientGUIComboBoxAccepted="onDgsComboBoxSelect-C",
			onClientGUIDoubleClick="onDgsMouseDoubleClickUp",
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

		addEventHandler = function(event,...)
			return _addEventHandler(eventReplace[event] or event,...)
		end
		
		_removeEventHandler = removeEventHandler
		
		removeEventHandler = function(event,...)
			return _removeEventHandler(eventReplace[event] or event,...)
		end
		local typeReplace ={
			["dgs-dxbutton"]="gui-button",
			["dgs-dxedit"]="gui-edit",
			["dgs-dxprogressbar"]="gui-progressbar",
			["dgs-dxwindow"]="gui-window",
			["dgs-dxlabel"]="gui-label",
			["dgs-dxscrollpane"]="gui-scrollpane",
			["dgs-dxtab"]="gui-tab",
			["dgs-dxmemo"]="gui-memo",
			["dgs-dxtabpanel"]="gui-tabpanel",
			["dgs-dximage"]="gui-staticimage",
			["dgs-dxscrollbar"]="gui-scrollbar",
			["dgs-dxcombobox"]="gui-combobox",
			["dgs-dxcheckbox"]="gui-checkbox",
			["dgs-dxradiobutton"]="gui-radiobutton",
			["dgs-dxgridlist"]="gui-gridlist",
		}
		_getElementType = getElementType

		getElementType = function(gl)
			local typ = _getElementType(gl)
			return typ and typeReplace[typ] or typ
		end
	]]
end

function handleHookerEvents(...)
	triggerEvent(eventName.."-C",source,source,...)
end
	
-------Inside DGS
setElementData(root,"__DGSRes",getThisResource(),false)
addEventHandler("onClientResourceStop",resourceRoot,function() setElementData(root,"__DGSRes",false,false) end)

OOPImportCache = nil
OOPImportTimer = nil

function dgsImportOOPClass()
	if OOPImportCache then return OOPImportCache end
	local matched,content = verifyFile("classlib.lua",true)
	if not matched then return outputChatBox("[DGS] Failed to load classlib.lua (File mismatch)",255,0,0) end
	local str = content
	if fileExists("customOOP.lua") then
		local matched,content = verifyFile("customOOP.lua",true)
		if not matched then outputChatBox("[DGS] Failed to load customOOP.lua (File mismatch)",255,0,0) end
		local s = content:gsub("\r\n","\n")
		local list = split(s,"\n")
		for i=1,#list do
			if fileExists(list[i]) then
				local matched,content = verifyFile(list[i],true)
				if not matched then outputChatBox("[DGS] Failed to load "..list[i].." (File mismatch)",255,0,0) end
				local f,e = loadstring(content)
				if f then
					str = str.."\n"..content
				else
					outputDebugString("[DGS]Failed to load custom OOP script ("..list[i]..":"..e..")",1)
				end
			else
				outputDebugString("[DGS]Failed to load custom OOP script (Could not find "..list[i]..")",1)
			end
		end
	end
	OOPImportCache = str
	OOPImportTimer = setTimer(function()
		OOPImportCache = nil
		OOPImportTimer = nil
		collectgarbage()
	end,1000,1) --Clear cache
	return OOPImportCache
end