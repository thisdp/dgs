dgsLogLuaMemory()
dgsRegisterPluginType("dgs-dxcmd")
cmdBaseWhiteList = {}
commandHandlers = {}

function dgsCreateCmd(x,y,w,h,relative,parent)
	if not(type(x) == "number") then error(dgsGenAsrt(x,"dgsCreateCmd",1,"number")) end
	if not(type(y) == "number") then error(dgsGenAsrt(y,"dgsCreateCmd",2,"number")) end
	if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsCreateCmd",3,"number")) end
	if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsCreateCmd",4,"number")) end
	local cmdMemo = dgsCreateMemo(x,y,w,h,"",relative,parent)
	dgsMemoSetReadOnly(cmdMemo,true)
	dgsSetData(cmdMemo,"asPlugin","dgs-dxcmd")
	dgsSetData(cmdMemo,"readOnlyCaretShow",true)
	dgsSetData(cmdMemo,"textSize",{1.3,1.3})
	dgsMemoSetWordWrapState(cmdMemo,true)
	dgsSetData(cmdMemo,"bgColor",tocolor(0,0,0,180))
	dgsSetData(cmdMemo,"textColor",tocolor(255,255,255,255))
	dgsSetData(cmdMemo,"caretColor",tocolor(255,255,255,255))
	dgsSetFont(cmdMemo,"arial")
	dgsSetData(cmdMemo,"leading",tonumber(leading) or 20)
	dgsSetData(cmdMemo,"preName","")
	dgsSetData(cmdMemo,"commandHandlers",{})
	dgsSetData(cmdMemo,"whitelist",cmdBaseWhiteList)
	dgsSetData(cmdMemo,"cmdHistory",{[0]=""})
	dgsSetData(cmdMemo,"cmdCurrentHistory",0)
	dgsSetData(cmdmemo,"enableCommandInfo",true)
	local sx,sy = dgsGetSize(cmdMemo,false)
	local edit = dgsCreateEdit(0,-20,sx,20,"",false,cmdMemo,tocolor(255,255,255,255))
	dgsSetData(edit,"textSize",{1.3,1.3})
	dgsSetFont(edit,"arial")
	addEventHandler("onDgsEditAccepted",edit,function()
		local cmd = dgsElementData[source].mycmd
		if dgsGetPluginType(cmd) == "dgs-dxcmd" then
			local text = dgsElementData[source].text
			dgsEditClearText(source)
			if text ~= "" then
				receiveCmdEditInput(cmd,text)
			end
		end
	end,false)
	dgsSetPositionAlignment(edit,_,"bottom")
	dgsSetData(cmdMemo,"cmdEdit",edit)
	dgsSetData(cmdMemo,"childOutsideHit",true)
	dgsSetData(edit,"cursorStyle",1)
	dgsSetData(edit,"cursorThick",1.2)
	dgsSetData(edit,"mycmd",cmdMemo)
	addEventHandler("onDgsTextChange",edit,function()
		local text = dgsElementData[source].text
		local parent = dgsElementData[source].mycmd
		if isElement(parent) then
			if dgsGetPluginType(parent) == "dgs-dxcmd" then
				local hisid = dgsElementData[parent].cmdCurrentHistory
				local history = dgsElementData[parent].cmdHistory
				if history[hisid] ~= text then
					dgsSetData(parent,"cmdCurrentHistory",0)
				end
			end
		end
	end,false)
	dgsTriggerEvent("onDgsPluginCreate",cmdMemo,sourceResource)
	return cmdMemo
end

function dgsCmdApplyDefaultCommands(cmd)
	if not(dgsGetPluginType(cmd) == "dgs-dxcmd") then error(dgsGenAsrt(cmd,"dgsCmdApplyDefaultCommands",1,"plugin dgs-dxcmd")) end
	for command,functions in pairs(commandHandlers) do
		for index,fnc in ipairs(functions) do
			dgsCmdAddCommandHandler(cmd,command,fnc)
		end
	end
end

function dgsCmdClearText(cmd)
	if not(dgsGetPluginType(cmd) == "dgs-dxcmd") then error(dgsGenAsrt(cmd,"dgsCmdClearText",1,"plugin dgs-dxcmd")) end
	dgsSetData(cmd,"texts",{})
end

function dgsCmdIsInWhiteList(cmd,rule)
	if not(dgsGetPluginType(cmd) == "dgs-dxcmd" or cmd == "all") then error(dgsGenAsrt(cmd,"dgsCmdIsInWhiteList",1,"plugin dgs-dxcmd/string","all")) end
	if not(type(rule) == "string") then error(dgsGenAsrt(rule,"dgsCmdIsInWhiteList",2,"string")) end
	if table.find(preinstallWhiteList,rule) then
		return true
	else
		if cmd == "all" then
			if table.find(cmdBaseWhiteList,rule) then
				return true
			end
		else
			local wtlist = dgsGetData(cmd,"whitelist")
			if table.find(wtlist,rule) then
				return true
			end
		end
	end
	return false
end

function outputCmdMessage(cmd,str)
	if not(dgsGetPluginType(cmd) == "dgs-dxcmd") then error(dgsGenAsrt(cmd,"outputCmdMessage",1,"plugin dgs-dxcmd")) end
	dgsMemoAppendText(cmd,str.."\n",true)
	local textTable = dgsElementData[cmd].text
	local toLine = #textTable
	local toIndex = utf8.len(textTable[toLine][0])
	dgsMemoSetCaretPosition(cmd,toIndex,toLine)
end

function receiveCmdEditInput(cmd,str)
	if not(dgsGetPluginType(cmd) == "dgs-dxcmd") then error(dgsGenAsrt(cmd,"receiveCmdEditInput",1,"plugin dgs-dxcmd")) end
	local history = dgsGetData(cmd,"cmdHistory")
	if history[1] ~= str then
		table.insert(history,1,str)
		dgsSetData(cmd,"cmdHistory",history)
	end
	executeCmdCommand(cmd,unpack(split(str," ")))
end

function dgsCmdGetEdit(cmd)
	if dgsGetPluginType(cmd) == "dgs-dxcmd" then
		return dgsElementData[cmd].cmdEdit
	end
	return false
end

function configCMD(source)
	local dxedit = dgsElementData[source].cmdEdit
	local scalex,scaley = unpack(dgsGetData(source,"textSize"))
	local sx,sy = dgsGetSize(source,false)
	dgsSetPosition(dxedit,0,sy-scaley*20,false)
	dgsSetSize(dxedit,sx,scaley*20,false)
end

function dgsCmdAddCommandHandler(...)
	if select("#",...) == 2 then
		local str,func = ...
		commandHandlers[str] = commandHandlers[str] or {}
		if not(type(str) == "string") then error(dgsGenAsrt(str,"dgsCmdAddCommandHandler",1,"string")) end
		if not(type(func) == "function") then error(dgsGenAsrt(func,"dgsCmdAddCommandHandler",2,"function")) end
		return table.insert(commandHandlers[str],func)
	elseif select("#",...) == 3 then
		local cmd,str,func = ...
		if not(type(str) == "string") then error(dgsGenAsrt(str,"dgsCmdAddCommandHandler",2,"string")) end
		if not(type(func) == "function") then error(dgsGenAsrt(func,"dgsCmdAddCommandHandler",3,"function")) end
		local cmdEdit = dgsElementData[cmd].cmdEdit
		local cmdHandlers = dgsElementData[cmd].commandHandlers
		cmdHandlers[str] = cmdHandlers[str] or {}
		table.insert(cmdHandlers[str],func)
		dgsEditAddAutoComplete(cmdEdit,str,false)
	end
end

function dgsCmdRemoveCommandHandler(...)
	if select("#",...) == 2 then
		local str,func = ...
		commandHandlers[str] = commandHandlers[str] or {}
		if not(type(str) == "string") then error(dgsGenAsrt(str,"dgsCmdRemoveCommandHandler",1,"string")) end
		if not(type(func) == "function") then error(dgsGenAsrt(func,"dgsCmdRemoveCommandHandler",2,"function")) end
		local id = table.find(commandHandlers[str],func)
		if id then
			return table.remove(commandHandlers[str],id)
		end
		return true
	elseif select("#",...) == 3 then
		local cmd,str,func = ...
		commandHandlers[str] = commandHandlers[str] or {}
		if not(type(str) == "string") then error(dgsGenAsrt(str,"dgsCmdRemoveCommandHandler",2,"string")) end
		if not(type(func) == "function") then error(dgsGenAsrt(func,"dgsCmdRemoveCommandHandler",3,"function")) end
		local cmdHandlers = dgsElementData[cmd].commandHandlers or {}
		local id = table.find(cmdHandlers[str],func)
		if id then
			return table.remove(cmdHandlers[str],id)
		end
		if #cmdHandlers[str] == 0 then cmdHandlers[str] = nil end
		return true
	end
end

function executeCmdCommand(cmd,str,...)
	local arg = {...}
	local ifound = false
	if dgsElementData[cmd].enableCommandInfo then
		outputCmdMessage(cmd,"Execute: "..str)
	end
	local cmdHandlers = dgsElementData[cmd].commandHandlers or {}
	for k,v in pairs(cmdHandlers[str] or {}) do
		if type(v) == "function" then
			ifound = true
			v(cmd,unpack(arg))
			break
		end
	end
	if dgsElementData[cmd].enableCommandInfo then
		if not ifound then
			outputCmdMessage(cmd,"Could't Find Command:"..str)
		end
	end
end
--------------DGS CMD
dgs_MyIP = "Unknown"
triggerServerEvent("DGSI_RequestIP",resourceRoot)
addEventHandler("DGSI_ReceiveIP",resourceRoot,function(ip)
	dgs_MyIP = ip
end)

cmdSystem = {}
netSystem = {}
dxStatus = {}
performanceBrowser = {}
pBCat = {
	["Lua memory"] = {
		"name",
		"change",
		"current",
		"max",
		"XMLFiles",
		"refs",
		"Timers",
		"Elements",
		"TextItems",
		"DxFonts",
		"GuiFonts",
		"Textures",
		"Shaders",
		"RenderTargets",
		"ScreenSources",
		"WebBrowsers",
		"VectorGraphics",
	},
	["Lib memory"] = {
		"name",
		"change",
		"current",
		"max",
	},
	["Lua timing"] = {
		"name",
		"5s.cpu",
		"5s.time",
		"5s.calls",
		"5s.avg",
		"5s.max",
		"60s.cpu",
		"60s.time",
		"60s.calls",
		"60s.avg",
		"60s.max",
		"300s.cpu",
		"300s.time",
		"300s.calls",
		"300s.avg",
		"300s.max",
	},
	["Packet usage"] = {
		"Packet type",
		"Incoming.msgs/sec",
		"Incoming.bytes/sec",
		"Incoming.logic cpu",
		"Outgoing.msgs/sec",
		"Outgoing.bytes/sec",
		"Outgoing.msgs",
	},
}

--------------------------Variables
-----Net
local byteSent = false
local byteRecevied = false
local tick = getTickCount()
local speedSend = {}
local speedRecv = {}
local percentLoss = {}
local MaxStatisticTimes = 60
--------------------------
function dgsBuildInCMD(command)
	if not getElementData(resourceRoot,"DGS-allowCMD") then return outputChatBox("[DGS]Access Denied",255,0,0) end
	guiSetInputMode("no_binds_when_editing")
	if not isElement(cmdSystem["window"]) then
		cmdSystem["window"] = dgsCreateWindow(sW*0.5-20,sH*0.5,40,25,"CMD",false,tocolor(255,0,0,255),_,_,tocolor(80,140,200,255))
		dgsWindowSetSizable(cmdSystem["window"],false)
		dgsSetProperty(cmdSystem["window"],"textSize",{1.5,1.5})
		dgsSetProperty(cmdSystem["window"],"outline",{"out",1,tocolor(100,100,100,255)})
		dgsMoveTo(cmdSystem["window"],sW*0.25,sH*0.5,false,"OutQuad",300)
		dgsSizeTo(cmdSystem["window"],sW*0.5,25,false,"OutQuad",300)
		setTimer(function(command)
			dgsMoveTo(cmdSystem["window"],sW*0.25,sH*0.25,false,"InQuad",300)
			dgsSizeTo(cmdSystem["window"],sW*0.5,sH*0.6,false,"InQuad",300)
			setTimer(function(command)
				cmdSystem["cmd"] = dgsCreateCmd(0,0,sW*0.5,sH*0.6-45,false,cmdSystem["window"],1,1)
				dgsCmdApplyDefaultCommands(cmdSystem["cmd"])
				local version = getElementData(resourceRoot,"Version") or "N/A"
				outputCmdMessage(cmdSystem["cmd"],"( Thisdp's Dx Graphical User Interface System ) Version: "..version)
			end,310,1,command)
			dgsShowCursor(true,"cmd")
		end,310,1,command)
	else
		for k,v in pairs(cmdSystem) do
			if k ~= "window" then
				destroyElement(v)
			end
		end
		local x,y = unpack(dgsGetData(cmdSystem["window"],"absPos",false))
		local sx,sy = unpack(dgsGetData(cmdSystem["window"],"absSize",false))
		dgsSetProperty(cmdSystem["window"],"title","")
		dgsMoveTo(cmdSystem["window"],x,y+sy/2-20,false,"InQuad",450)
		dgsSizeTo(cmdSystem["window"],sx,40,false,"InQuad",450)
		setTimer(function()
			destroyElement(cmdSystem["window"])
		end,500,1)
	end
end
addCommandHandler("dgscmd",dgsBuildInCMD)

addEventHandler("onDgsWindowClose",resourceRoot,function()
	if source == cmdSystem["window"] then
		cancelEvent()
		for k,v in pairs(cmdSystem) do
			if k ~= "window" then
				destroyElement(v)
			end
		end
		local x,y = unpack(dgsGetData(cmdSystem["window"],"absPos",false))
		local sx,sy = unpack(dgsGetData(cmdSystem["window"],"absSize",false))
		dgsSetProperty(cmdSystem["window"],"title","")
		dgsMoveTo(cmdSystem["window"],x,y+sy/2-20,false,"InQuad",450)
		dgsSizeTo(cmdSystem["window"],sx,40,false,"InQuad",450)
		setTimer(function()
			destroyElement(cmdSystem["window"])
		end,500,1)
	elseif dgsGetData(source,"animated") == 1 then
		cancelEvent()
		local children = dgsGetChildren(source)
		for i=1,#children do
			destroyElement(children[1])
		end
		local x,y = unpack(dgsGetData(source,"absPos",false))
		local sx,sy = unpack(dgsGetData(source,"absSize",false))
		dgsSetData(source,"title","")
		dgsMoveTo(source,x,y+sy/2-20,false,"InQuad",350)
		dgsSizeTo(source,sx,40,false,"InQuad",350)
		setTimer(function(source)
			destroyElement(source)
		end,380,1,source)
	end
	if source == netSystem["window"] then
		byteSent = false
		byteRecevied = false
		speedSend = {}
		speedRecv = {}
		percentLoss = {}
	end
end)

----------------------------------------Insides
dgsCmdAddCommandHandler("version",function(cmd)
	local version = getElementData(resourceRoot,"Version") or "N/A"
	outputCmdMessage(cmd,version)
end)

dgsCmdAddCommandHandler("serial",function(cmd)
	outputCmdMessage(cmd,"Serial:"..getPlayerSerial())
end)

dgsCmdAddCommandHandler("mtaversion",function(cmd)
	outputCmdMessage(cmd,"MTA Client Version:")
	for k,v in pairs(getVersion()) do
		outputCmdMessage(cmd,k..":  "..tostring(v))
	end
end)

dgsCmdAddCommandHandler("dxstatus",function(cmd)
	if not isElement(dxStatus["window"]) then
		dxStatus["window"] = dgsCreateAnimationWindow(sW/2-350,sH/2-250,700,505,"Dx Status",false,tocolor(20,20,200,255),_,_,tocolor(80,140,200,255),_,tocolor(0,0,0,200))
		dgsWindowSetSizable(dxStatus["window"],false)
		dgsBringToFront(dxStatus["window"])
		outputCmdMessage(cmd,"Dx Status Monitor: ON")
		dgsShowCursor(true,"dx")
	else
		outputCmdMessage(cmd,"Dx Status Monitor: OFF")
		dgsCloseWindow(dxStatus["window"])
	end
end)

dgsCmdAddCommandHandler("performancebrowser",function(cmd)
	if not isElement(performanceBrowser["window"]) then
		performanceBrowser["window"] = dgsCreateAnimationWindow(sW/2-450,sH/2-250,900,505,"Performance Browser",false,tocolor(20,20,200,255),_,_,tocolor(80,140,200,255),_,tocolor(0,0,0,200))
		dgsWindowSetSizable(performanceBrowser["window"],false)
		dgsBringToFront(performanceBrowser["window"])
		outputCmdMessage(cmd,"Performance Browser Status Monitor: ON")
		dgsShowCursor(true,"performance")
	else
		outputCmdMessage(cmd,"Performance Browser Monitor: OFF")
		dgsCloseWindow(performanceBrowser["window"])
	end
end)

dgsCmdAddCommandHandler("netstatus",function(cmd)
	if not isElement(netSystem["window"]) then
		netSystem["window"] = dgsCreateAnimationWindow(sW/2-300,sH/2-200,600,400,"Network Status",false,tocolor(20,20,200,255),_,_,tocolor(80,140,200,255),_,tocolor(0,0,0,200))
		dgsWindowSetSizable(netSystem["window"],false)
		dgsBringToFront(netSystem["window"])
		outputCmdMessage(cmd,"Network Monitor: ON")
		dgsShowCursor(true,"net")
	else
		outputCmdMessage(cmd,"Network Monitor: OFF")
		dgsCloseWindow(netSystem["window"])
	end
end)

--------------------------------------------------Net
function netUpdate()
	local network = getNetworkStats()
	if getTickCount()-tick >= 1000 then
		if not byteSent then
			byteSent = network.bytesSent
		end
		if not byteRecevied then
			byteRecevied = network.bytesReceived
		end
		local _sent,_received = network.bytesSent-byteSent,network.bytesReceived-byteRecevied
		local sent,received = string.format("%.2f",_sent/1024),string.format("%.2f",_received/1024)
		dgsSetText(netSystem["Sent"],"Send "..sent.." KB/s")
		dgsSetText(netSystem["Received"],"Receive "..received.." KB/s")
		byteSent = network.bytesSent
		byteRecevied = network.bytesReceived
		speedSend[0] = speedSend[0] or 100
		speedRecv[0] = speedRecv[0] or 100
		percentLoss[0] = 100
		if speedSend[0] < _sent then
			speedSend[0] = _sent
		end
		if speedRecv[0] < _received then
			speedRecv[0] = _received
		end
		table.insert(speedSend,1,_sent)
		table.insert(speedRecv,1,_received)
		table.insert(percentLoss,1,network.packetlossLastSecond)
		if #speedSend > MaxStatisticTimes+1 then
			if speedSend[MaxStatisticTimes+2] == speedSend[0] then
				speedSend[0] = speedSend[1]
				for i=2,MaxStatisticTimes+1 do
					speedSend[0] = speedSend[0] <= speedSend[i] and speedSend[i] or speedSend[0]
				end
			end
			speedSend[MaxStatisticTimes+2] = nil
		end
		if #speedRecv > MaxStatisticTimes+1 then
			if speedRecv[MaxStatisticTimes+2] == speedRecv[0] then
				speedRecv[0] = speedRecv[1]
				for i=2,MaxStatisticTimes+1 do
					speedRecv[0] = speedRecv[0] <= speedRecv[i] and speedRecv[i] or speedRecv[0]
				end
			end
			speedRecv[MaxStatisticTimes+2] = nil
		end
		if #percentLoss > MaxStatisticTimes+1 then
			percentLoss[MaxStatisticTimes+2] = nil
		end
		tick = getTickCount()
	end
	dgsSetText(netSystem["BytesReceived"],"Bytes:"..(network.bytesReceived))
	dgsSetText(netSystem["PacketsReceived"],"Packages:"..(network.packetsReceived))
	dgsSetText(netSystem["ByteSent"],"Bytes:"..(network.bytesSent))
	dgsSetText(netSystem["PacketsSent"],"Packages:"..(network.packetsSent))
	dgsSetText(netSystem["packetlossLastSecond"],"Package Loss:"..string.format("%.2f",network.packetlossLastSecond).."%")
	dgsSetText(netSystem["PacketLossTotal"],"Average Loss:"..string.format("%.2f",network.packetlossTotal).."%")
	dgsSetText(netSystem["IP"],"My IP:"..dgs_MyIP)
end

addEventHandler("onDgsDestroy",resourceRoot,function()
	if source == cmdSystem["window"] then
		dgsShowCursor(false,"cmd")
	elseif source == netSystem["window"] then
		dgsShowCursor(false,"net")
	elseif source == dxStatus["window"] then
		dgsShowCursor(false,"dx")
	elseif source == performanceBrowser["window"] then
		dgsShowCursor(false,"performance")
	end
end)

cursorManager = {}
function dgsShowCursor(bool,code)
	assert(type(code) == "string","Bad argument @dgsShowCursor at argument 1, expect a string got "..dgsGetType(code))
	bool = bool and true or false
	cursorManager[code] = bool
	if bool then
		showCursor(true)
	else
		local noPass
		for k,v in pairs(cursorManager) do
			if v then
				noPass = true
				break
			end
		end
		if not noPass then
			showCursor(false)
		end
	end
end

function dgsCreateAnimationWindow(...)
	local tabl = {...}
	local x,y = tabl[6] and tabl[1]*sW or tabl[1],tabl[6] and tabl[2]*sH or tabl[2]
	local sx,sy = tabl[6] and tabl[3]*sW or tabl[3],tabl[6] and tabl[4]*sH or tabl[4]
	tabl[6] = false
	tabl[1] = x+sx/2-30
	tabl[2] = y+sy/2-12.5
	tabl[3] = 60
	tabl[4] = 25
	local window = dgsCreateWindow(unpack(tabl))
	dgsSetProperty(window,"textSize",{1.5,1.5})
	dgsSetProperty(window,"outline",{"out",1,tocolor(100,100,100,255)})
	dgsSetData(window,"animated",1)
	dgsMoveTo(window,x,y+sy/2-12.5,false,"OutQuad",200)
	dgsSizeTo(window,sx,25,false,"OutQuad",200)
	setTimer(function(window)
		dgsMoveTo(window,x,y,false,"InQuad",200)
		dgsSizeTo(window,sx,sy,false,"InQuad",200)
		setTimer(onAnimationWindowCreate,202,1,window)
	end,210,1,window)
	return window
end

function dxStatusUpdate()
	if not isElement(dxStatus["dxList"]) then return removeEventHandler("onClientRender",root,dxStatusUpdate) end
	local rowData = dgsGetProperty(dxStatus["dxList"],"rowData")
	local count = 0
	for k,v in pairs(dxGetStatus()) do
		count = count+1
		if not rowData[count] then
			dgsGridListAddRow(dxStatus["dxList"])
		end
		rowData[count][1] = {k,white}
		rowData[count][2] = {tostring(v),white}
	end
	dgsSetProperty(dxStatus["dxList"],"rowData",rowData)
end

function onAnimationWindowCreate(window)
	if window == netSystem["window"] then
		netSystem["Sent"] = dgsCreateLabel(10,10,100,30,"Send",false,netSystem["window"],_,1.6,1.6)
		netSystem["ByteSent"] = dgsCreateLabel(10,50,200,20,"Bytes:",false,netSystem["window"],_,1.2,1.2)
		netSystem["PacketsSent"] = dgsCreateLabel(10,80,200,20,"Packages:",false,netSystem["window"],_,1.2,1.2)
		netSystem["Received"] = dgsCreateLabel(10,120,100,30,"Receive",false,netSystem["window"],_,1.6,1.6)
		netSystem["BytesReceived"] = dgsCreateLabel(10,160,200,20,"Bytes:",false,netSystem["window"],_,1.2,1.2)
		netSystem["PacketsReceived"] = dgsCreateLabel(10,190,200,20,"Packages:",false,netSystem["window"],_,1.2,1.2)
		netSystem["PacketLoss"] = dgsCreateLabel(10,230,200,30,"Package Loss",false,netSystem["window"],_,1.6,1.6)
		netSystem["packetlossLastSecond"] = dgsCreateLabel(10,270,200,20,"Package Loss:",false,netSystem["window"],_,1.2,1.2)
		netSystem["PacketLossTotal"] = dgsCreateLabel(10,300,200,20,"Average Loss:",false,netSystem["window"],_,1.2,1.2)
		netSystem["IP"] = dgsCreateLabel(10,340,200,20,"My IP:"..dgs_MyIP,false,netSystem["window"],_,1.2,1.2)

		netSystem["chartSent"] = dgsCreateImage(290,10,300,90,_,false,netSystem["window"],tocolor(255,255,255,50))
		dgsSetProperty(netSystem.chartSent,"functionRunBefore",false)
		netSystem["chartSentMAX"] = dgsCreateLabel(240,15,40,0,"N/A",false,netSystem["window"],_,1.2,1.2,_,_,_,"right","center")
		netSystem["chartSentMin"] = dgsCreateLabel(240,95,40,0,"0Byte/s",false,netSystem["window"],_,1.2,1.2,_,_,_,"right","center")

		netSystem["chartRcv"] = dgsCreateImage(290,120,300,90,_,false,netSystem["window"],tocolor(255,255,255,50))
		dgsSetProperty(netSystem.chartRcv,"functionRunBefore",false)
		netSystem["chartRcvMax"] = dgsCreateLabel(240,125,40,0,"N/A",false,netSystem["window"],_,1.2,1.2,_,_,_,"right","center")
		netSystem["chartRcvMin"] = dgsCreateLabel(240,205,40,0,"0Byte/s",false,netSystem["window"],_,1.2,1.2,_,_,_,"right","center")

		netSystem["chartPkl"] = dgsCreateImage(290,230,300,90,_,false,netSystem["window"],tocolor(255,255,255,50))
		dgsSetProperty(netSystem.chartPkl,"functionRunBefore",false)
		netSystem["chartPklMax"] = dgsCreateLabel(240,235,40,0,"100%",false,netSystem["window"],_,1.2,1.2,_,_,_,"right","center")
		netSystem["chartPklMin"] = dgsCreateLabel(240,315,40,0,"0%",false,netSystem["window"],_,1.2,1.2,_,_,_,"right","center")

		dgsSetProperties({netSystem.chartSent,netSystem.chartRcv,netSystem.chartPkl},{
			sideSize=1,
			sideState="out",
			sideColor=tocolor(100,150,240,255),
		})
		
		dgsSetProperty(netSystem["Sent"],"renderEventCall",true)
		addEventHandler("onDgsElementRender",netSystem["Sent"],netUpdate,false)
		dgsSetProperty(netSystem["chartSent"],"renderEventCall",true)
		addEventHandler("onDgsElementRender",netSystem["chartSent"],function()
			local x,y = dgsGetPosition(source,false,true)
			local sx,sy = dgsGetSize(source,false)
			local maxPos = math.floor((speedSend[0] or 0)*1.2)
			local LineBlue = tocolor(80,180,255,255)
			local isPostGUI = dgsGetPostGUI(source)
			for i=1,#speedSend-1 do
				local nextone = speedSend[i+1] or 0
				dxDrawLine(x+sx-sx*i/MaxStatisticTimes-1,y+sy-sy*(nextone/maxPos)-1,x+sx-sx*(i-1)/MaxStatisticTimes-1,y+sy-sy*(speedSend[i]/maxPos)-1,LineBlue,1,isPostGUI)
			end
			dgsSetText(netSystem["chartSentMAX"],maxPos.."Byte/s")
		end)

		dgsSetProperty(netSystem["chartRcv"],"renderEventCall",true)
		addEventHandler("onDgsElementRender",netSystem["chartRcv"],function()
			local x,y = dgsGetPosition(source,false,true)
			local sx,sy = dgsGetSize(source,false)
			local maxPos = math.floor((speedRecv[0] or 0)*1.2)
			local LineBlue = tocolor(80,180,255,255)
			local isPostGUI = dgsGetPostGUI(source)
			for i=1,#speedRecv-1 do
				local nextone = speedRecv[i+1] or 0
				dxDrawLine(x+sx-sx*i/MaxStatisticTimes-1,y+sy-sy*(nextone/maxPos)-1,x+sx-sx*(i-1)/MaxStatisticTimes-1,y+sy-sy*(speedRecv[i]/maxPos)-1,LineBlue,1,isPostGUI)
			end
			dgsSetText(netSystem["chartRcvMax"],maxPos.."Byte/s")
		end)

		dgsSetProperty(netSystem["chartPkl"],"renderEventCall",true)
		addEventHandler("onDgsElementRender",netSystem["chartPkl"],function()
			local x,y = dgsGetPosition(source,false,true)
			local sx,sy = dgsGetSize(source,false)
			local LineBlue = tocolor(80,180,255,255)
			local isPostGUI = dgsGetPostGUI(source)
			for i=1,#percentLoss-1 do
				local nextone = percentLoss[i+1] or 0
				dxDrawLine(x+sx-sx*i/MaxStatisticTimes-1,y+sy-sy*(nextone/100)-1,x+sx-sx*(i-1)/MaxStatisticTimes-1,y+sy-sy*(percentLoss[i]/100)-1,LineBlue,1,isPostGUI)
			end
		end)

	elseif window == dxStatus["window"] then
		dxStatus["dxList"] = dgsCreateGridList(10,10,680,460,false,dxStatus["window"],_,tocolor(0,0,0,100),white,tocolor(0,0,0,100),tocolor(0,0,0,0),tocolor(100,100,100,100),tocolor(200,200,200,150))
		dgsGridListSetSortEnabled(dxStatus["dxList"],false)
		dgsSetProperty(dxStatus["dxList"],"rowHeight",25)
		dgsSetProperty(dxStatus["dxList"],"columnHeight",25)
		dgsSetProperty(dxStatus["dxList"],"rowTextSize",{1.5,1.5})
		dgsSetProperty(dxStatus["dxList"],"columnTextSize",{1.5,1.5})
		dgsGridListAddColumn(dxStatus["dxList"],"Name",0.5)
		dgsGridListAddColumn(dxStatus["dxList"],"Value",0.46)
		local scrollBars = dgsGridListGetScrollBar(dxStatus["dxList"])
		dgsSetProperty(scrollBars[1],"scrollArrow",false)
		dgsSetProperty(scrollBars[2],"scrollArrow",false)
		dgsSetProperty(dxStatus["dxList"],"mode",true)
		addEventHandler("onClientRender",root,dxStatusUpdate)
	elseif window == performanceBrowser["window"] then
		performanceBrowser["dxList"] = dgsCreateGridList(10,10,130,460,false,performanceBrowser["window"])
		dgsSetProperty(performanceBrowser["dxList"],"columnHeight",0)
		dgsSetProperty(performanceBrowser["dxList"],"rowHeight",40)
		dgsSetProperty(performanceBrowser["dxList"],"rowTextSize",{1.5,1.5})
		dgsGridListAddColumn(performanceBrowser["dxList"],"",1)
		local k = 0
		for v,t in pairs(pBCat) do
			k=k+1
			dgsGridListAddRow(performanceBrowser["dxList"],_,v)
			performanceBrowser[k] = dgsCreateGridList(140,10,750,460,false,performanceBrowser["window"])
			dgsGridListSetSortEnabled(performanceBrowser[k],false)
			dgsSetProperty(performanceBrowser[k],"rowHeight",25)
			dgsSetProperty(performanceBrowser[k],"columnHeight",25)
			dgsSetProperty(performanceBrowser[k],"columnTextSize",{1.3,1.3})
			dgsSetProperty(performanceBrowser[k],"rowTextSize",{1.3,1.3})
			for index,name in ipairs(t) do
				dgsGridListAddColumn(performanceBrowser[k],name,0.3)
			end
			addEventHandler("onDgsElementRender",performanceBrowser[k],function()
				dgsElementData[source].startTick = tick
				local columns,rows = getPerformanceStats(dgsGetProperty(source,"myType"),"d")
				local rowData = dgsGetProperty(source,"rowData")
				local count = 0
				if #rows < #rowData then
					for i=1,#rowData-#rows do
						dgsGridListRemoveRow(source,#rowData)
					end
				elseif #rows > #rowData then
					for i=1,#rows-#rowData do
						dgsGridListAddRow(source)
					end
				end
				for i=1,#rows do
					for k,v in pairs(rows[i]) do
						rowData[i][k] = rowData[i][k] or {}
						rowData[i][k][1] = v
						rowData[i][k][2] = white
					end
				end
				dgsSetProperty(source,"rowData",rowData)
			end,false)
			dgsSetProperty(performanceBrowser[k],"renderEventCall",true)
			dgsSetProperty(performanceBrowser[k],"myType",v)
			dgsSetProperty(performanceBrowser[k],"myIndex",k)
			dgsSetProperty(performanceBrowser[k],"startTick",getTickCount()-5000)
			dgsSetVisible(performanceBrowser[k],false)
		end
		addEventHandler("onDgsGridListSelect",performanceBrowser["dxList"],function(new,_,old)
			if old ~= -1 then
				dgsSetVisible(performanceBrowser[old],false)
			end
			if new == -1 then
				dgsGridListSetSelectedItem(performanceBrowser["dxList"],old)
			else
				dgsSetVisible(performanceBrowser[new],true)
			end
		end,false)
		dgsGridListSetSelectedItem(performanceBrowser["dxList"],1)
	end
end

---------About DGS (Contributed by Ahmed Ly)
AboutDGS = {}
function createAboutDGS()
	if not isElement(AboutDGS.window) then
		requestBrowserDomains ( {"raw.githubusercontent.com"},false,function(wasAccepted)
			if wasAccepted then
				fetchRemote("https://raw.githubusercontent.com/thisdp/dgs/master/README.md",{},function(data,info,player)
					if isElement(AboutDGS.content) then
						dgsSetText(AboutDGS.content,data)
					end
				end)
			else
				dgsSetText(AboutDGS.content,"Load Failed")
			end
		end)
		AboutDGS.window = dgsCreateWindow(sW/2-350, sH/2-200, 700, 400, "About DGS", false)
		dgsWindowSetSizable(AboutDGS.window, false)
		showCursor(true)
		dgsSetAlpha(AboutDGS.window,0)
		dgsAlphaTo(AboutDGS.window,1,"InQuad",500)
		setTimer(function()
			if isElement(AboutDGS.window) then
				AboutDGS.content = dgsCreateMemo(10, 5, 680, 360, "Loading...", false,AboutDGS.window)
				dgsSetProperty(AboutDGS.content,"bgColor",tocolor(0,0,0,50))
				dgsMemoSetReadOnly(AboutDGS.content,true)
			end
		end,500,1)
		addEventHandler("onDgsWindowClose",AboutDGS.window,function()
			cancelEvent()
			dgsAlphaTo(source,0,"InQuad",500)
			showCursor(false)
			setTimer(function(source)
				if isElement(source) then
					destroyElement(source)
				end
			end,500,1,source)
		end)
	else
		dgsCloseWindow(AboutDGS.window)
	end
end
addCommandHandler("aboutdgs", createAboutDGS )