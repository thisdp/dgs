xmlLoadStr = _G["xmlLoad".."String"]
if not xmlLoadStr then
	tempXmlLogger = {count=0}
	xmlLoadStr = function(str)
		local tick = tempXmlLogger.count
		tempXmlLogger.count = tempXmlLogger.count+1
		local xmlFile = fileCreate("g2dCrawlTmp_"..tick..".xml")
		fileWrite(xmlFile,str)
		fileClose(xmlFile)
		local xml = xmlLoadFile("g2dCrawlTmp_"..tick..".xml")
		tempXmlLogger[xml] = {path="g2dCrawlTmp_"..tick..".xml"}
		return xml
	end
	xmlReleaseTempFiles = function(xml)
		if tempXmlLogger[xml] then
			xmlUnloadFile(xml)
			fileDelete(tempXmlLogger[xml].path)
			tempXmlLogger[xml] = nil
		end
	end
else
	xmlReleaseTempFiles = function() end
end

local function tableCount(tabl)
	local cnt = 0
	for k,v in pairs(tabl) do
		cnt = cnt + 1
	end
	return cnt
end
G2D = {}
G2D.type = "convertor"
G2D.backup = true
G2D.select = {}

G2DHelp = {
	--Options,Extra,Argument,Comment
	{"add","Resource Name","Retain selections and select other resources (match :Pattern Match)"},
	{"clear","	","Clear selections"},
	{"help","	","G2D Help"},
	{"type","G2D Type","Change the type of G2D command, can be 'convertor' or 'hooker'. 'convertor' by default"},
	{"remove","Resource Name","Remove specific selected resources from list  (match :Pattern Match)"},
	{"list","	","List all selected resources"},
	{"start","	","Start to convert"},
	{"stop","	","Stop converting process"},
	{"crawl","autocomplete type","Crawl and Generate DGS autocomplete"},
}

addCommandHandler("g2d",function(player,command,...)
	if not DGSConfig.enableG2DCMD then end
	local account = getPlayerAccount(player)
	if account then
		local accn = getAccountName(account)
		if accn == "Console" then
			local args = {...}
			if args[1] == "remove" then
				if args[2] and args[2] ~= "" then
					if args[3] == "match" then
						for k,v in pairs(G2D.select) do
							if k:lower():find(args[2]:lower()) then
								G2D.select[k] = nil
							end
						end
					else
						for k,v in pairs(G2D.select) do
							if k:lower() == args[2]:lower() then
								G2D.select[k] = nil
							end
						end
					end
					outputDebugString("[DGS-G2D] Selected "..tableCount(G2D.select).." resources, to see the selections, command: g2d list")
				else
					outputDebugString("[DGS-G2D] Selected 0 resources, to see the selections, command: g2d list")
				end
			elseif args[1] == "add" then
				if args[2] and args[2] ~= "" then
					if args[3] == "match" then
						for k,v in ipairs(getResources()) do
							local resN = getResourceName(v)
							if resN:lower():find(args[2]:lower()) then
								G2D.select[resN] = v
							end
						end
					else
						for k,v in ipairs(getResources()) do
							local resN = getResourceName(v)
							if resN:lower() == args[2]:lower() then
								G2D.select[resN] = v
							end
						end
					end
					outputDebugString("[DGS-G2D] Selected "..tableCount(G2D.select).." resources, to see the selections, command: g2d list")
				else
					outputDebugString("[DGS-G2D] Selected 0 resources, to see the selections, command: g2d list")
				end
			elseif args[1] == "list" then
				outputDebugString("[DGS-G2D] There are "..tableCount(G2D.select).." resources selected:")
				for k,v in pairs(G2D.select) do
					outputDebugString(k)
				end
			elseif args[1] == "clear" then
				G2D.select = {}
				outputDebugString("[DGS-G2D] Selections cleared!")
			elseif args[1] == "start" then
				if not G2D.Process then
					G2D.Process = true
					G2D.Running = {}
					G2DStart()
				else
					print("[DGS-G2D]G2D is running!")
				end
			elseif args[1] == "stop" then
				if G2D.Process then
					print("[DGS-G2D]G2D process terminated!")
					G2D.Process = false
				else
					print("[DGS-G2D]G2D is not running!")
				end
			elseif args[1] == "crawl" then
				if not checkServerVersion() then return end
				if args[2] and args[2] ~= "" then
					if args[2] == "npp" or args[2] == "n++" then
						CrawlWikiFromMTA("npp")
					elseif args[2] == "vscode" or args[2] == "vsc" then
						CrawlWikiFromMTA("vsc")
					elseif args[2] == "sublime" then
						CrawlWikiFromMTA("sublime")
					else
						print("[DGS]Current type is not supported!")
					end
				else
					print("[DGS]Please select target type: g2d -g <npp/vsc/sublime>")
				end
			elseif args[1] == "type" then
				if args[2] then
					if not G2D.Process then
						if args[2] == "convertor" then
							G2D.type = "convertor"
							print("[DGS-G2D]Current G2D type has been changed to "..G2D.type)
						elseif args[2] == "hooker" then
							G2D.type = "hooker"
							print("[DGS-G2D]Current G2D type has been changed to "..G2D.type)
						else
							print("[DGS-G2D]Bad G2D type, expected convertor/hooker got "..args[2])
						end
					else
						print("[DGS-G2D]G2D type can not be changed while G2D process is running")
					end
				else
					print("[DGS-G2D]Current G2D type is "..G2D.type)
				end
			else
				outputDebugString("[DGS-G2D]Command help")
				outputDebugString("Option		Arguments		Comment")
				for i=1,#G2DHelp do
					local items = G2DHelp[i]
					outputDebugString(items[1].."		"..items[2].."		"..items[3])
				end
			end
		end
	end
end)

function throw(ls,err)
	G2D.Process = false
	assert(false,"[Line:"..ls.prevLine..",Index:"..ls.prevIndex.."]"..err)
end

AnalyzerState = {}

setmetatable(AnalyzerState,{
	__call = function(self,lexResult)
			return {
				tokenIndex=0,
				separatorDepth = 0,
				blockDepth = 0,
				lexResult=lexResult,
				replacedFunction = {},
				replacedEvent = {},
				executeProcess = function(self)
					local GUIFnc = self.replacedFunction[1]
					local DGSFnc = self.replacedFunction[2]
					local GUIEvt = self.replacedEvent[1]
					local DGSEvt = self.replacedEvent[2]
					local resLen = #self.lexResult
					while(true) do
						local item = self:getNext()
						if not item then break end
						if item[2] == "identifier" and GUIFnc then
							if item[1] == GUIFnc[1] then	-- matched, get into the process
								self.lexResult[self.tokenIndex][1] = DGSFnc[1]
							end
						elseif item[2] == "short string" and DGSEvt then
							if item[1] == GUIEvt[1] then
								self.lexResult[self.tokenIndex][1] = DGSEvt[1]
							end
						end
					end
				end,
				getNext = function(self,dontSkipSpace)
					self.tokenIndex = self.tokenIndex+1
					if self.lexResult[self.tokenIndex] and self.lexResult[self.tokenIndex][2] == "space" and not dontSkipSpace then
						return self:getNext()
					end
					return self.lexResult[self.tokenIndex]
				end,
				getCurrent = function(self)
					return self.lexResult[self.tokenIndex]
				end,
				removeCurrent = function(self)
					table.remove(self.lexResult,self.tokenIndex)
					return self.tokenIndex
				end,
				insertCurrent = function(self,insert)
					table.insert(self.lexResult,self.tokenIndex,insert)
				end,
				set = function(self,repFnc,isEvent)
					if isEvent then
						self.replacedEvent = repFnc
						self.replacedFunction = {}
					else
						self.replacedEvent = {}
						self.replacedFunction = repFnc
					end
					self.tokenIndex=0
					self.separatorDepth = 0
				end,
				generateFile = function(self,filename)
					local path = filename:sub(2)
					local file = fileCreate("G2DOutput/"..path)
					local newtab = {}
					local isDGSDef = false
					for i=1,#self.lexResult do
						if self.lexResult[i][2] == "short comment" then
							newtab[i] = "--"..self.lexResult[i][1]
						elseif self.lexResult[i][2] == "long comment" then
							newtab[i] = "--[["..self.lexResult[i][1].."]]"
						elseif self.lexResult[i][2] == "short string" then
							newtab[i] = "\""..self.lexResult[i][1].."\""
						elseif self.lexResult[i][2] == "long string" then
							newtab[i] = "[["..self.lexResult[i][1].."]]"
						else
							newtab[i] = self.lexResult[i][1]
						end
						if self.lexResult[i][1] == "__DGSDef" then
							isDGSDef = true
						end
					end
					if not isDGSDef then
						table.insert(newtab,1,Hooker)
					end
					fileWrite(file,table.concat(newtab))
					fileClose(file)
				end,
			}
	end
})

convertFunctionTable = {
	{{"guiBringToFront"},{"dgsBringToFront"}},
	{{"guiCreateFont"},{"dgsCreateFont"}},
	{{"guiBlur"},{"dgsBlur"}},
	{{"guiFocus"},{"dgsFocus"}},
	{{"guiGetAlpha"},{"dgsGetAlpha"}},
	{{"guiGetEnabled"},{"dgsGetEnabled"}},
	{{"guiGetFont"},{"dgsGetFont"}},
	{{"guiGetInputEnabled"},{"dgsGetInputEnabled"}},
	{{"guiGetInputMode"},{"dgsGetInputMode"}},
	{{"guiGetPosition"},{"dgsGetPosition"}},
	{{"guiGetProperties"},{"dgsGetProperties"}},
	{{"guiGetProperty"},{"dgsGetProperty"}},
	{{"guiGetScreenSize"},{"dgsGetScreenSize"}},
	{{"guiGetSize"},{"dgsGetSize"}},
	{{"guiGetText"},{"dgsGetText"}},
	{{"guiGetVisible"},{"dgsGetVisible"}},
	{{"guiMoveToBack"},{"dgsMoveToBack"}},
	{{"guiSetAlpha"},{"dgsSetAlpha"}},
	{{"guiSetEnabled"},{"dgsSetEnabled"}},
	{{"guiSetFont"},{"dgsSetFont"}},
	{{"guiSetInputEnabled"},{"dgsSetInputEnabled"}},
	{{"guiSetInputMode"},{"dgsSetInputMode"}},
	{{"guiSetPosition"},{"dgsSetPosition"}},
	{{"guiSetProperty"},{"dgsSetProperty"}},
	{{"guiSetSize"},{"dgsSetSize"}},
	{{"guiSetText"},{"dgsSetText"}},
	{{"guiSetVisible"},{"dgsSetVisible"}},
	{{"guiCreateBrowser"},{"dgsCreateBrowser"}},
	{{"guiCreateButton"},{"dgsCreateButton"}},
	{{"guiCheckBoxGetSelected"},{"dgsCheckBoxGetSelected"}},
	{{"guiCheckBoxSetSelected"},{"dgsCheckBoxSetSelected"}},
	{{"guiCreateCheckBox"},{"dgsCreateCheckBox"}},
	{{"guiCreateComboBox"},{"dgsCreateComboBox"}},
	{{"guiComboBoxAddItem"},{"dgsComboBoxAddItem"}},
	{{"guiComboBoxClear"},{"dgsComboBoxClear"}},
	{{"guiComboBoxGetItemCount"},{"dgsComboBoxGetItemCount"}},
	{{"guiComboBoxGetItemText"},{"dgsComboBoxGetItemText"}},
	{{"guiComboBoxGetSelected"},{"dgsComboBoxGetSelected"}},
	{{"guiComboBoxIsOpen"},{"dgsComboBoxGetState"}},
	{{"guiComboBoxRemoveItem"},{"dgsComboBoxRemoveItem"}},
	{{"guiComboBoxSetItemText"},{"dgsComboBoxSetItemText"}},
	{{"guiComboBoxSetOpen"},{"dgsComboBoxSetState"}},
	{{"guiComboBoxSetSelected"},{"dgsComboBoxSetSelected"}},
	{{"guiCreateEdit"},{"dgsCreateEdit"}},
	{{"guiEditGetCaretIndex"},{"dgsEditGetCaretPosition"}},
	{{"guiEditGetMaxLength"},{"dgsEditGetMaxLength"}},
	{{"guiEditIsMasked"},{"dgsEditGetMasked"}},
	{{"guiEditIsReadOnly"},{"dgsEditGetReadOnly"}},
	{{"guiEditSetCaretIndex"},{"dgsEditSetCaretPosition"}},
	{{"guiEditSetMasked"},{"dgsEditSetMasked"}},
	{{"guiEditSetMaxLength"},{"dgsEditSetMaxLength"}},
	{{"guiEditSetReadOnly"},{"dgsEditSetReadOnly"}},
	{{"guiCreateGridList"},{"dgsCreateGridList"}},
	{{"guiGridListAddColumn"},{"dgsGridListAddColumn"}},
	{{"guiGridListAddRow"},{"dgsGridListAddRow"}},
	{{"guiGridListAutoSizeColumn"},{"dgsGridListAutoSizeColumn"}},
	{{"guiGridListClear"},{"dgsGridListClear"}},
	{{"guiGridListGetColumnCount"},{"dgsGridListGetColumnCount"}},
	{{"guiGridListGetColumnTitle"},{"dgsGridListGetColumnTitle"}},
	{{"guiGridListGetColumnWidth"},{"dgsGridListGetColumnWidth"}},
	{{"guiGridListGetItemColor"},{"dgsGridListGetItemColor"}},
	{{"guiGridListGetItemData"},{"dgsGridListGetItemData"}},
	{{"guiGridListGetItemText"},{"dgsGridListGetItemText"}},
	{{"guiGridListGetRowCount"},{"dgsGridListGetRowCount"}},
	{{"guiGridListGetSelectedCount"},{"dgsGridListGetSelectedCount"}},
	{{"guiGridListGetSelectedItem"},{"dgsGridListGetSelectedItem"}},
	{{"guiGridListGetSelectedItems"},{"dgsGridListGetSelectedItems"}},
	{{"guiGridListGetSelectionMode"},{"dgsGridListGetSelectionMode"}},
	{{"guiGridListIsSortingEnabled"},{"dgsGridListGetSortEnabled"}},
	{{"guiGridListRemoveColumn"},{"dgsGridListRemoveColumn"}},
	{{"guiGridListRemoveRow"},{"dgsGridListRemoveRow"}},
	{{"guiGridListSetColumnTitle"},{"dgsGridListSetColumnTitle"}},
	{{"guiGridListSetColumnWidth"},{"dgsGridListSetColumnWidth"}},
	{{"guiGridListSetItemColor"},{"dgsGridListSetItemColor"}},
	{{"guiGridListSetItemData"},{"dgsGridListSetItemData"}},
	{{"guiGridListSetItemText"},{"dgsGridListSetItemText"}},
	{{"guiGridListSetScrollBars"},{"dgsGridListSetScrollBarState"}},
	{{"guiGridListSetSelectedItem"},{"dgsGridListSetSelectedItem"}},
	{{"guiGridListSetSelectionMode"},{"dgsGridListSetSelectionMode"}},
	{{"guiGridListSetSortingEnabled"},{"dgsGridListSetSortEnabled"}},
	{{"guiCreateMemo"},{"dgsCreateMemo"}},
	{{"guiMemoGetCaretIndex"},{"dgsMemoGetCaretIndex"}},
	{{"guiMemoIsReadOnly"},{"dgsMemoIsReadOnly"}},
	{{"guiMemoSetCaretIndex"},{"dgsMemoSetCaretIndex"}},
	{{"guiMemoSetReadOnly"},{"dgsMemoSetReadOnly"}},
	{{"guiCreateProgressBar"},{"dgsCreateProgressBar"}},
	{{"guiProgressBarGetProgress"},{"dgsProgressBarGetProgress"}},
	{{"guiProgressBarSetProgress"},{"dgsProgressBarSetProgress"}},
	{{"guiCreateRadioButton"},{"dgsCreateRadioButton"}},
	{{"guiRadioButtonGetSelected"},{"dgsRadioButtonGetSelected"}},
	{{"guiRadioButtonSetSelected"},{"dgsRadioButtonSetSelected"}},
	{{"guiCreateScrollBar"},{"dgsCreateScrollBar"}},
	{{"guiScrollBarGetScrollPosition"},{"dgsScrollBarGetScrollPosition"}},
	{{"guiScrollBarSetScrollPosition"},{"dgsScrollBarSetScrollPosition"}},
	{{"guiCreateScrollPane"},{"dgsCreateScrollPane"}},
	{{"guiScrollPaneSetScrollBars"},{"dgsScrollPaneSetScrollBarState"}},
	{{"guiCreateStaticImage"},{"dgsCreateImage"}},
	{{"guiStaticImageGetNativeSize"},{"dgsImageGetNativeSize"}},
	{{"guiStaticImageLoadImage"},{"dgsImageSetImage"}},
	{{"guiCreateTabPanel"},{"dgsCreateTabPanel"}},
	{{"guiGetSelectedTab"},{"dgsGetSelectedTab"}},
	{{"guiSetSelectedTab"},{"dgsSetSelectedTab"}},
	{{"guiCreateTab"},{"dgsCreateTab"}},
	{{"guiDeleteTab"},{"dgsDeleteTab"}},
	{{"guiCreateLabel"},{"dgsCreateLabel"}},
	{{"guiLabelGetColor"},{"dgsLabelGetColor"}},
	{{"guiLabelGetFontHeight"},{"dgsLabelGetFontHeight"}},
	{{"guiLabelGetTextExtent"},{"dgsLabelGetTextExtent"}},
	{{"guiLabelSetColor"},{"dgsLabelSetColor"}},
	{{"guiLabelSetHorizontalAlign"},{"dgsLabelSetHorizontalAlign"}},
	{{"guiLabelSetVerticalAlign"},{"dgsLabelSetVerticalAlign"}},
	{{"guiCreateWindow"},{"dgsCreateWindow"}},
	{{"guiWindowIsMovable"},{"dgsWindowGetMovable"}},
	{{"guiWindowIsSizable"},{"dgsWindowGetSizable"}},
	{{"guiWindowSetMovable"},{"dgsWindowSetMovable"}},
	{{"guiWindowSetSizable"},{"dgsWindowSetSizable"}},
	{{"guiGridListGetHorizontalScrollPosition"},{"dgsGridListGetHorizontalScrollPosition"}},
	{{"guiGridListSetHorizontalScrollPosition"},{"dgsGridListSetHorizontalScrollPosition"}},
	{{"guiGridListGetVerticalScrollPosition"},{"dgsGridListGetVerticalScrollPosition"}},
	{{"guiGridListSetVerticalScrollPosition"},{"dgsGridListSetVerticalScrollPosition"}},
	{{"guiMemoGetVerticalScrollPosition"},{"dgsMemoGetVerticalScrollPosition"}},
	{{"guiMemoSetVerticalScrollPosition"},{"dgsMemoSetVerticalScrollPosition"}},
	{{"guiScrollPaneGetHorizontalScrollPosition"},{"dgsScrollPaneGetHorizontalScrollPosition"}},
	{{"guiScrollPaneGetVerticalScrollPosition"},{"dgsScrollPaneGetVerticalScrollPosition"}},
	{{"guiScrollPaneSetHorizontalScrollPosition"},{"dgsScrollPaneSetHorizontalScrollPosition"}},
	{{"guiScrollPaneSetVerticalScrollPosition"},{"dgsScrollPaneSetVerticalScrollPosition"}},
	{{"guiGridListInsertRowAfter"},{"dgsGridListInsertRowAfter"}},
	{{"guiGetBrowser"},{"dgsGetBrowser"}},
}

Hooker = [[

----------GUI To DGS Converted----------
if not getElementData(resourceRoot,"__DGSDef") then
	setElementData(resourceRoot,"__DGSDef",true)
	addEvent("onDgsEditAccepted-C",true)
	addEvent("onDgsTextChange-C",true)
	addEvent("onDgsComboBoxSelect-C",true)
	addEvent("onDgsTabSelect-C",true)
	function fncTrans(...)
		triggerEvent(eventName.."-C",source,source,...)
	end
	addEventHandler("onDgsEditAccepted",root,fncTrans)
	addEventHandler("onDgsTextChange",root,fncTrans)
	addEventHandler("onDgsComboBoxSelect",root,fncTrans)
	addEventHandler("onDgsTabSelect",root,fncTrans)
	loadstring(exports.dgs:dgsImportFunction())()
end
----------GUI To DGS Converted----------

]]

convertEventTable = {
	{{"onClientGUIAccepted",			},{"onDgsEditAccepted-C"}},
	{{"onClientGUIBlur",				},{"onDgsBlur"}},
	{{"onClientGUIChanged",				},{"onDgsTextChange-C"}},
	{{"onClientGUIClick",				},{"onDgsMouseClickUp"}},
	{{"onClientGUIComboBoxAccepted",	},{"onDgsComboBoxSelect-C"}},
	{{"onClientGUIDoubleClick",			},{"onDgsMouseDoubleClick"}},
	{{"onClientGUIFocus",				},{"onDgsFocus"}},
	{{"onClientGUIMouseDown",			},{"onDgsMouseDown"}},
	{{"onClientGUIMouseUp",				},{"onDgsMouseUp"}},
	{{"onClientGUIMove",				},{"onDgsElementMove"}},
	{{"onClientGUIScroll",				},{"onDgsElementScroll"}},
	{{"onClientGUISize",				},{"onDgsElementSize"}},
	{{"onClientGUITabSwitched",			},{"onDgsTabSelect-C"}},
	{{"onClientMouseEnter",				},{"onDgsMouseEnter"}},
	{{"onClientMouseLeave",				},{"onDgsMouseLeave"}},
	{{"onClientMouseMove",				},{"onDgsMouseMove"}},
	{{"onClientMouseWheel",				},{"onDgsMouseWheel"}},
}


function showProgress(progress)
	print("[G2D]Progress "..string.format("%.2f",progress).."%")
end

G2DRunningData = {
	File=false,
	Timer= false
}

function G2DStart()
	if G2D.type == "convertor" then
		print("[DGS-G2D]Scanning files...")
		local process = {}
		for resN,res in pairs(G2D.select) do
			local xml = xmlLoadFile(":"..resN.."/meta.xml")
			for k,v in pairs(xmlNodeGetChildren(xml)) do
				if xmlNodeGetName(v) == "script" and xmlNodeGetAttribute(v,"type") == "client" then
					local path = xmlNodeGetAttribute(v,"src")
					table.insert(process,":"..resN.."/"..path)
				end
			end
		end
		print("[DGS-G2D]"..#process.." files to be converted")
		G2D.Files = process
		G2D.Running = coroutine.create(function()
			G2D.StartTick = getTickCount()
			for i=1,#G2D.Files do
				processFileConvertor(G2D.File[i])
			end
			print("[DGS-G2D]Process Done")
			G2D.Process = false
		end)
	elseif G2D.type == "hooker" then
		print("[DGS-G2D]Scanning resources...")
		G2D.Running = coroutine.create(function()
			G2D.StartTick = getTickCount()
			for resN,res in pairs(G2D.select) do
				local resPath = ":"..resN.."/"
				local xml = xmlLoadFile(resPath.."meta.xml")
				for index,node in ipairs(xmlNodeGetChildren(xml)) do
					if xmlNodeGetName(node) == "script" and xmlNodeGetAttribute(node,"type") == "client" then
						local path = resPath..xmlNodeGetAttribute(node,"src")
						local file = fileOpen(path)
						local str = fileRead(file,fileGetSize(file))
						local backupStr = str
						if str:find("guiCreate") then	--has gui create function and is the 1st script in client
							print("[DGS-G2D]Processing "..path)
							local findA,findB = string.find(str,"loadstring%s*%(.*dgsG2DLoadHooker%s*%(%s*%)%s*%)")
							if not findA then	--if not, add
								fileSetPos(file,0)
								fileWrite(file,"loadstring(exports."..getResourceName(getThisResource())..":dgsG2DLoadHooker())()\n\n"..str)
							else	--if exists, update (maybe solve dgs resource name problems)
								local oldStrLen = #str
								str = string.sub(str,1,findA-1).."loadstring(exports."..getResourceName(getThisResource())..":dgsG2DLoadHooker())"..string.sub(str,findB+1)
								local diff = oldStrLen-#str
								fileSetPos(file,0)
								fileWrite(file,str)
								if diff > 0 then
									fileWrite(file,string.rep(" ",diff))
								end
							end
							local backup = fileCreate("G2DHookerBackUp/"..path:sub(2))
							fileWrite(backup,backupStr)
							fileClose(backup)
							break
						end
						fileClose(file)
						processExpired()
					end
				end
			end
			print("[DGS-G2D]Process Done")
			G2D.Process = false
		end)
	end
	local result,errmess = coroutine.resume(G2D.Running)
	if not result then
		print(errmess)
	end
end

function processExpired()
	setTimer(function()
		G2D.StartTick = getTickCount()
		coroutine.resume(G2D.Running)
	end,50,1)
end

function processFileConvertor(filename)
	print("[G2D]Start to process file '"..filename.."'")
	local file = fileOpen(filename)
	local str = fileRead(file,fileGetSize(file))
	local utf8BOM = false
	local txtByte = {str:byte(1,3)}
	if txtByte[1] == 0xEF and txtByte[2] == 0xBB and txtByte[3] == 0xBF then
		str = str:sub(4)
		utf8BOM = true
	end
	fileClose(file)
	local ls = createLuaLexer("5.1",function(line,index,err)
		assert("Failed to analyse lua script "..line..":"..index..":"..err)
	end)
	ls:init(str)
	ls:start()
	local az = AnalyzerState(ls.result)
	local convTabCnt = #convertFunctionTable
	print("[G2D]Replacing Functions")
	for i=1,convTabCnt do
		az:set(convertFunctionTable[i])
		az:executeProcess()
		if getTickCount()-G2D.StartTick >= 100 then
			showProgress((i-1)/convTabCnt*100)
			processExpired()
			coroutine.yield()
		end
	end
	local convTabCnt = #convertEventTable
	print("[G2D]Replacing Events")
	for i=1,convTabCnt do
		az:set(convertEventTable[i],true)
		az:executeProcess()
		if getTickCount()-G2D.StartTick >= 100 then
			showProgress((i-1)/convTabCnt*100)
			processExpired()
			coroutine.yield()
		end
	end
	showProgress(100)
	az:generateFile(filename,utf8BOM)
	return true
end


function processFileHooker(filename)
	print("[G2D]Start to process file '"..filename.."'")
	local file = fileOpen(filename)
	local str = fileRead(file,fileGetSize(file))
	local utf8BOM = false
	local txtByte = {str:byte(1,3)}
	if txtByte[1] == 0xEF and txtByte[2] == 0xBB and txtByte[3] == 0xBF then
		str = str:sub(4)
		utf8BOM = true
	end
	fileClose(file)
	local ls = createLuaLexer("5.1",function(line,index,err)
		assert("Failed to analyse lua script "..line..":"..index..":"..err)
	end)
	ls:init(str)
	ls:start()
	local az = AnalyzerState(ls.result)
	local convTabCnt = #convertFunctionTable
	print("[G2D]Replacing Functions")
	for i=1,convTabCnt do
		az:set(convertFunctionTable[i])
		az:executeProcess()
		if getTickCount()-G2D.StartTick >= 100 then
			showProgress((i-1)/convTabCnt*100)
			processExpired()
			coroutine.yield()
		end
	end
	local convTabCnt = #convertEventTable
	print("[G2D]Replacing Events")
	for i=1,convTabCnt do
		az:set(convertEventTable[i],true)
		az:executeProcess()
		if getTickCount()-G2D.StartTick >= 100 then
			showProgress((i-1)/convTabCnt*100)
			processExpired()
			coroutine.yield()
		end
	end
	showProgress(100)
	az:generateFile(filename,utf8BOM)
	return processExpired(true)
end



-------------------------------------

local mainWikiURL = "https://wiki.multitheftauto.com"
local threadPoolSize = 2
function CrawlWikiFromMTA(t)
	local targetURL = mainWikiURL.."/wiki/Template:DGSFUNCTIONS"
	print("[DGS]Crawling wiki...")
	fetchRemote(targetURL,{},function(data,info,t)
		if info.success then
			local startPos = 0
			print("[DGS]Wiki data is ready, Reading...")
			local fncList = {type=t}
			while(true) do
				liStart_1,liStart_2 = string.find(data,"%<li%>",startPos)
				liEnd_1,liEnd_2 = string.find(data,"%<%/li%>",startPos)
				if not liStart_1 or not liEnd_1 then break end
				local str = string.sub(data,liStart_2+1,liEnd_1-1)
				local xmlNode = xmlLoadStr(str)
				local fncName = xmlNodeGetValue(xmlNode)
				local nTable = {
					href=xmlNodeGetAttribute(xmlNode,"href"),
					title=xmlNodeGetAttribute(xmlNode,"title"),
					isEmpty = xmlNodeGetAttribute(xmlNode,"class") == "new",
					name = fncName,
				}
				table.insert(fncList,nTable)
				startPos = liEnd_2
				xmlReleaseTempFiles(xmlNode)
			end
			print("[DGS]Function list("..#fncList..") is ready, Crawling...")
			local fRProg = {thread=0,index=0,valid=0,progress=0,total=#fncList}
			local fncData = {}
			setTimer(function()
				if fRProg.progress < fRProg.total then
					for i=1,threadPoolSize-fRProg.thread do
						fRProg.index = fRProg.index+1
						if fRProg.index <= fRProg.total then
							item = fncList[fRProg.index]
							if item then
								if not item.isEmpty then
									local poolID
									for tableIndex=1,threadPoolSize do
										if not fRProg[tableIndex] then
											poolID = tableIndex
											break
										end
									end
									fRProg.thread = fRProg.thread+1
									fRProg[poolID] = fetchRemote(mainWikiURL.."/index.php?title="..item.title.."&action=edit",{queueName=poolID},function(data,info,poolID,index)
										fRProg.progress = fRProg.progress+1
										fRProg.thread = fRProg.thread-1
										fRProg[poolID] = false
										if info.success then
											print("[DGS]Recorded ("..fRProg.progress.."/"..fRProg.total..")["..fncList[index].name.."]")
											local startPos = data:find("%<textarea")
											local _,endPos = data:find("%<%/textarea>",startPos)
											local line = data:sub(startPos,endPos)
											local xmlNode = xmlLoadStr(line)
											local pageSource = xmlNodeGetValue(xmlNode)
											xmlReleaseTempFiles(xmlNode)
											local _,rangeStart = pageSource:find("==Syntax==")
											local _,syntaxStart = pageSource:find("%<syntaxhighlight lang%=\"lua\"%>",rangeStart+1)
											local syntaxEnd = pageSource:find("%<%/syntaxhighlight%>",syntaxStart+1)
											local targetSyntax = pageSource:sub(syntaxStart+1,syntaxEnd-1)
											local targetSyntax = targetSyntax:gsub("\r",""):gsub("\n","")
											fncList[index].syntax = targetSyntax
										else
											print("[DGS]Failed to get remote wiki data ("..info.statusCode ..")")
										end
									end,{poolID,fRProg.index})
									fRProg.valid = fRProg.valid+1
								else
									fRProg.progress = fRProg.progress+1
								end
							end
						end
					end
				else
					print("[DGS]Crawling stage complete [Total:"..fRProg.total.."/Valid:"..fRProg.valid.."]")
					killTimer(sourceTimer)
					fncList.valid = fRProg.valid
					AnalyzeFunction(fncList)
				end
			end,50,0)
		end
	end,{t})
end

function AnalyzeFunction(tab)
	print("[DGS]Start to analyze syntax")
	local nTable = {}
	local validCount = 0
	for i=1,#tab do
		local item = tab[i]
		if item.syntax then
			validCount = validCount+1
			print("[DGS]Analyzing syntax ("..validCount.."/"..tab.valid..")["..item.name.."]")
			local startPos,endPos = string.find(item.syntax,item.name)
			local rets = split(item.syntax:sub(1,startPos-1)," ")
			local argStr = item.syntax:sub(endPos+1):gsub("%(",""):gsub("%)","")
			local argSplited = split(argStr,"%[")
			local reqArgStr = argSplited[1] or ""
			local optArgStr = (argSplited[2] or ""):gsub("%]","")

			local reqArgs = split(reqArgStr,",")
			local optArgs = split(optArgStr,",")
			local emptyArgCheck = {req={},opt={}}
			for _i=1,#reqArgs do
				reqArgs[_i] = reqArgs[_i]:match("^[%s]*(.-)[%s]*$") or reqArgs[_i]
				if reqArgs[_i] == "" then
					table.insert(emptyArgCheck.req,_i)
				end
			end
			for _i=1,#optArgs do
				optArgs[_i] = optArgs[_i]:match("^[%s]*(.-)[%s]*$") or optArgs[_i]
				if optArgs[_i] == "" then
					table.insert(emptyArgCheck.opt,_i)
				end
			end
			for _i=1,#rets do
				rets[_i] = rets[_i]:gsub(",",""):gsub(" ","")
			end

			for i=1,#emptyArgCheck.req do
				table.remove(reqArgs,emptyArgCheck.req[i])
			end
			for i=1,#emptyArgCheck.opt do
				table.remove(optArgs,emptyArgCheck.opt[i])
			end
			local resultTable = {returns=rets,fncName=item.name,requiredArguments=reqArgs,optionalArguments=optArgs}
			table.insert(nTable,resultTable)
		end
	end
	print("[DGS]Syntax analyzing stage done")
	if tab.type == "npp" then
		GenerateNPPAutoComplete(nTable)
	elseif tab.type == "vsc" then
		GenerateVSCodeAutoComplete(nTable)
	elseif tab.type == "sublime" then
		GenerateSublimeAutoComplete(nTable)
	end
end

function GenerateNPPAutoComplete(tab)
	if fileExists("nppAC4DGS.xml") then fileDelete("nppAC4DGS.xml") end
	print("[DGS]Generating NPP autocomplete file...")
	local xml = xmlCreateFile("nppAC4DGS.xml","NotepadPlus")
	local envNode = xmlCreateChild(xml,"Environment")
	local acNode = xmlCreateChild(xml,"AutoComplete")
	xmlNodeSetAttribute(envNode,"ignoreCase","no")
	xmlNodeSetAttribute(envNode,"startFunc","(")
	xmlNodeSetAttribute(envNode,"stopFunc",")")
	xmlNodeSetAttribute(envNode,"paramSeparator",",")
	xmlNodeSetAttribute(envNode,"terminal",";")
	xmlNodeSetAttribute(envNode,"additionalWordChar",".:")
	xmlNodeSetAttribute(acNode,"language","lua")
	for i=1,#tab do
		local item = tab[i]
		local kwNode = xmlCreateChild(acNode,"KeyWord")
		xmlNodeSetAttribute(kwNode,"name",item.fncName)
		xmlNodeSetAttribute(kwNode,"func","yes")
		local olNode = xmlCreateChild(kwNode,"Overload")
		xmlNodeSetAttribute(olNode,"retVal",table.concat(item.returns,", "))
		for argid=1,#item.requiredArguments do
			local paramNode = xmlCreateChild(olNode,"Param")
			xmlNodeSetAttribute(paramNode,"name",item.requiredArguments[argid])
		end
		for argid=1,#item.optionalArguments do
			local paramNode = xmlCreateChild(olNode,"Param")
			xmlNodeSetAttribute(paramNode,"name",item.optionalArguments[argid])
		end
	end
	xmlSaveFile(xml)
	xmlUnloadFile(xml)
	local f = fileOpen("nppAC4DGS.xml")
	local str = "<?xml version=\"1.0\" encoding=\"Windows-1252\" ?>\r\n"..fileRead(f,fileGetSize(f))
	fileSetPos(f,0)
	fileWrite(f,str)
	fileClose(f)
	print("[DGS]NPP autocomplete file is saved as 'nppAC4DGS.xml'")
end

function GenerateVSCodeAutoComplete(tab)
	if fileExists("dgs.code-snippets") then fileDelete("dgs.code-snippets") end
	print("[DGS]Generating VSCode autocomplete file...")
	local t = {}
	for i=1,#tab do
		local item = tab[i]
		local r = item.fncName.."("..table.concat(item.requiredArguments,", ")..""..(#item.optionalArguments > 0 and " [, "..table.concat(item.optionalArguments,", ").." ] " or "")..")\n\nReturns "..table.concat(item.returns,", ").."\n"
		t[item.fncName] = {scope="lua",prefix=item.fncName,body=item.fncName,description=r}
	end
	local f = fileCreate("dgs.code-snippets")
	fileSetPos(f,0)
	local json = toJSON(t,false,"spaces")
	fileWrite(f,json:sub(3, json:len() - 1))
	fileClose(f)
	print("[DGS]VSCode autocomplete file is saved as 'dgs.code-snippets'")
end

function GenerateSublimeAutoComplete(tab)
	if fileExists("dgs.sublime-completions") then fileDelete("dgs.sublime-completions") end
	print("[DGS]Generating Sublime autocomplete file...")
	local t = {scope = "source.lua",completions = {}}
	for i=1,#tab do
		local item = tab[i]
		local r = item.fncName.."("..table.concat(item.requiredArguments,", ")..")\t Returns "..table.concat(item.returns,", ")
		table.insert(t.completions,{trigger=r,contents=item.fncName})
	end
	local f = fileCreate("dgs.sublime-completions")
	fileSetPos(f,0)
	local json = toJSON(t,false,"spaces")
	fileWrite(f,json:sub(3, json:len() - 1))
	fileClose(f)
	print("[DGS]Sublime autocomplete file is saved as 'dgs.sublime-completions'")
end
