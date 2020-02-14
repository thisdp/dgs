﻿dgs_MyIP = "Unknown"
triggerServerEvent("DGSI_RequestIP",localPlayer)
addEventHandler("DGSI_ReceiveIP",root,function(ip)
	dgs_MyIP = ip
end)

cmdSystem = {}
netSystem = {}
dxStatus = {}
addCommandHandler("cmd",function()
	guiSetInputMode("no_binds_when_editing")
	if not isElement(cmdSystem["window"]) then
		cmdSystem["window"] = dgsCreateWindow(sW*0.5-20,sH*0.5,40,25,"CMD",false,tocolor(255,0,0,255),_,_,tocolor(80,140,200,255))
		dgsWindowSetSizable(cmdSystem["window"],false)
		dgsSetProperty(cmdSystem["window"],"outline",{"out",1,tocolor(100,100,100,255)})
		dgsMoveTo(cmdSystem["window"],sW*0.25,sH*0.5,false,false,"OutQuad",300)
		dgsSizeTo(cmdSystem["window"],sW*0.5,25,false,false,"OutQuad",300)
		setTimer(function()
			dgsMoveTo(cmdSystem["window"],sW*0.25,sH*0.25,false,false,"InQuad",300)
			dgsSizeTo(cmdSystem["window"],sW*0.5,sH*0.6,false,false,"InQuad",300)
			setTimer(function()
				cmdSystem["cmd"] = dgsCreateCmd(0,0,sW*0.5,sH*0.6-45,false,cmdSystem["window"],1,1)
				dgsCmdAddEventToWhiteList(cmdSystem["cmd"],{"changeMode"})
				local version = getElementData(resourceRoot,"Version") or "N/A"
				outputCmdMessage(cmdSystem["cmd"],"( Thisdp's Dx Graphical User Interface System ) Version: "..version)
			end,310,1)
			dgsShowCursor(true,"cmd")
		end,310,1)
	else
		for k,v in pairs(cmdSystem) do
			if k ~= "window" then
				destroyElement(v)
			end
		end
		local x,y = unpack(dgsGetData(cmdSystem["window"],"absPos",false))
		local sx,sy = unpack(dgsGetData(cmdSystem["window"],"absSize",false))
		dgsSetProperty(cmdSystem["window"],"title","")
		dgsMoveTo(cmdSystem["window"],x,y+sy/2-20,false,false,"InQuad",450)
		dgsSizeTo(cmdSystem["window"],sx,40,false,false,"InQuad",450)
		setTimer(function()
			destroyElement(cmdSystem["window"])
		end,500,1)
	end
end)

addEventHandler("onDgsWindowClose",root,function()
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
		dgsMoveTo(cmdSystem["window"],x,y+sy/2-20,false,false,"InQuad",450)
		dgsSizeTo(cmdSystem["window"],sx,40,false,false,"InQuad",450)
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
		dgsMoveTo(source,x,y+sy/2-20,false,false,"InQuad",350)
		dgsSizeTo(source,sx,40,false,false,"InQuad",350)
		setTimer(function(source)
			destroyElement(source)
		end,380,1,source)
	end
end)

----------------------------------------Insides
dgsCmdAddCommandHandler("version",function(cmd)
	local version = getElementData(resourceRoot,"Version") or "N/A"
	outputCmdMessage(cmd,version)
end)

dgsCmdAddCommandHandler("mode",function(cmd,cmdtype)
	triggerEvent("onCmdModePreChange",cmd,cmdtype)
	if not wasEventCancelled() then
		if cmdtype == "function" then
			dgsSetData(cmd,"cmdType","function")
			outputCmdMessage(cmd,"[Mode Switch]Function CMD")
			return
		elseif cmdtype == "event" then
			dgsSetData(cmd,"cmdType","event")
			outputCmdMessage(cmd,"[Mode Switch]Event CMD")
			return
		end
		triggerEvent("onCmdModeChange",cmd,cmdtype)
		outputCmdMessage(cmd,"[Mode Switch]Usage: mode <argument>")
		outputCmdMessage(cmd,"   function -->Function CMD: Only Run the command added by 'dgsCmdAddCommandHandler'")
		outputCmdMessage(cmd,"   event    -->Event CMD: Only Run the command added by 'addEvent' like 'triggerEvent'")
	end
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
		dxStatus["window"] = dgsCreateAnimationWindow(sW/2-250,sH/2-150,500,305,"Dx Status",false,tocolor(20,20,200,255),_,_,tocolor(80,140,200,255),_,tocolor(0,0,0,200))
		dgsWindowSetSizable(dxStatus["window"],false)
		dgsBringToFront(dxStatus["window"])
		outputCmdMessage(cmd,"Dx Status Monitor: ON")
		dgsShowCursor(true,"dx")
	else
		outputCmdMessage(cmd,"Dx Status Monitor: OFF")
		dgsCloseWindow(dxStatus["window"])
	end
end)

function netstatus(cmd)
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
end
dgsCmdAddCommandHandler("netstatus",netstatus)

dgsCmdAddCommandHandler("help",function(cmd)
	outputCmdMessage(cmd,"Help Commands:")
	outputCmdMessage(cmd," dxstatus")
	outputCmdMessage(cmd," exit")
	outputCmdMessage(cmd," mtaversion")
	outputCmdMessage(cmd," mode")
	outputCmdMessage(cmd," netstatus")
	outputCmdMessage(cmd," serial")
	outputCmdMessage(cmd," version")
end)

--[[
dgsCmdAddCommandHandler("getping",function(cmd,times,time)
	times = times or 1
	time = time or 500
	setTimer(function(cmd)
		if not isElement(cmd) then killTimer(selfTimer) end
		outputCmdMessage(cmd,"Ping:"..getPlayerPing(localPlayer).." ms")
	end,time,times,cmd)
end)

dgsCmdAddCommandHandler("pos",function(cmd,playern)
    local player = localPlayer
    if playern then
        player = getPlayerFromName(playern) or player
    end
    local x,y,z = getElementPosition(player)
    outputCmdMessage(cmd,"Player:"..getPlayerName(player))
    outputCmdMessage(cmd,"X:"..x)
    outputCmdMessage(cmd,"Y:"..y)
    outputCmdMessage(cmd,"Z:"..z)
    outputCmdMessage(cmd,"Interoir:"..getElementInterior(localPlayer))
    outputCmdMessage(cmd,"Dimension:"..getElementDimension(localPlayer))
end)

dgsCmdAddCommandHandler("getvehid",function(cmd)
    if isPedInVehicle(localPlayer) then
        local veh = getPedOccupiedVehicle(localPlayer)
        outputCmdMessage(cmd,"Current Vehicle ID:"..getElementModel(veh))
    else
        outputCmdMessage(cmd,"Are you in a vehicle?")
    end
end)

dgsCmdAddCommandHandler("gettarvehid",function(cmd)
    local target = getPedTarget(localPlayer)
    if isElement(target) and getElementType(target) == "vehicle" then
        outputCmdMessage(cmd,"Target Vehicle ID:"..getElementModel(target))
    else
        outputCmdMessage(cmd,"No target vehicle")
    end
end)

dgsCmdAddCommandHandler("getvehstate",function(cmd)
    local veh = getPedOccupiedVehicle(localPlayer)
    if isElement(veh) then
        outputCmdMessage(cmd,"Current Vehicle ID:"..getElementModel(veh))
        outputConsole("Current Vehicle ID:"..getElementModel(veh))
        local x,y,z = getElementPosition(veh)
        outputCmdMessage(cmd,"Current Vehicle Position: x:"..x.." y:"..y.." z:"..z)
        outputConsole("Current Vehicle Position: x:"..x.." y:"..y.." z:"..z)
        local rx,ry,rz = getElementRotation(veh)
        outputCmdMessage(cmd,"Current Vehicle Rotation: x:"..rx.." y:"..ry.." z:"..rz)
        outputConsole("Current Vehicle Rotation: x:"..rx.." y:"..ry.." z:"..rz)
    else
        outputCmdMessage(cmd,"Are you in a vehicle?")
    end
end)]]

dgsCmdAddCommandHandler("exit",function(cmd)
    if isElement(cmdSystem["window"]) then
        dgsCloseWindow(cmdSystem["window"])
    end
end)

addEvent("onDGSCmdOutput",true)
addEventHandler("onDGSCmdOutput",root,function(message)
    if isElement(cmdSystem["cmd"]) then
        outputCmdMessage(cmdSystem["cmd"],message)
    end
end)

-----------------------------Inside CMD_Event
preinstallWhiteList = {}

--[[
Create Inside CMD Event
str:		Event Name
]]
function dgsAddEventCommand(str)
	addEvent(str,true)
	table.insert(preinstallWhiteList,str)
end

dgsAddEventCommand("mode")
addEventHandler("mode",resourceRoot,function(cmdtype)
	triggerEvent("onCmdModePreChange",source,cmdtype)
	if not wasEventCancelled() then
		if cmdtype == "function" then
			dgsSetData(source,"cmdType","function")
			outputCmdMessage(source,"[Mode Switch]Function CMD")
			return
		elseif cmdtype == "event" then
			dgsSetData(source,"cmdType","event")
			outputCmdMessage(source,"[Mode Switch]Event CMD")
			return	
		end
		triggerEvent("onCmdModeChange",source,cmdtype)
		outputCmdMessage(source,"[Mode Switch]Usage: mode <argument>")
		outputCmdMessage(source,"   function -->Function CMD: Only Run the command added by 'dgsAddCommandHandler'")
		outputCmdMessage(source,"   event    -->Event CMD: Only Run the command added by 'addEvent' like 'triggerEvent'")
	end
end)

--------------------------------------------------
local byteSent = false
local byteRecevied = false
local tick = getTickCount()
local speedSend = {}
local speedRecv = {}
local percentLoss = {}
local MaxStatisticTimes = 60
function netUpdate()
	if isElement(netSystem["Sent"]) then
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
	else
		byteSent = false
		byteRecevied = false
		speedSend = {}
		speedRecv = {}
		percentLoss = {}
		removeEventHandler("onClientPreRender",root,netUpdate)
	end
end

addEventHandler("onDgsDestroy",root,function()
	if source == cmdSystem["window"] then
		dgsShowCursor(false,"cmd")
	elseif source == netSystem["window"] then
		dgsShowCursor(false,"net")
	elseif source == dxStatus["window"] then
		dgsShowCursor(false,"dx")
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
	dgsSetProperty(window,"outline",{"out",1,tocolor(100,100,100,255)})
	dgsSetData(window,"animated",1)
	dgsMoveTo(window,x,y+sy/2-12.5,false,false,"OutQuad",200)
	dgsSizeTo(window,sx,25,false,false,"OutQuad",200)
	setTimer(function(window)
		dgsMoveTo(window,x,y,false,false,"InQuad",200)
		dgsSizeTo(window,sx,sy,false,false,"InQuad",200)
		setTimer(function(window)
			triggerEvent("onAnimationWindowCreate",window)
		end,202,1,window)
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
addEvent("onDGSObjectRender",true)
addEvent("onAnimationWindowCreate",true)
addEventHandler("onAnimationWindowCreate",root,function()
	if source == netSystem["window"] then
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
		
		netSystem["picture_sen"] = dgsCreateImage(290,10,300,90,_,false,netSystem["window"],tocolor(255,255,255,50))
		dgsSetProperty(netSystem.picture_sen,"functionRunBefore",false)
		dgsSetProperty(netSystem.picture_sen,"functions","triggerEvent('onDGSObjectRender',self)")
		netSystem["picture_sen_max"] = dgsCreateLabel(240,15,40,0,"N/A",false,netSystem["window"],_,1.2,1.2,_,_,_,"right","center")
		netSystem["picture_sen_min"] = dgsCreateLabel(240,95,40,0,"0Byte/s",false,netSystem["window"],_,1.2,1.2,_,_,_,"right","center")
		dgsSetProperty(netSystem["picture_sen"],"sideSize",1)
		dgsSetProperty(netSystem["picture_sen"],"sideState","out")
		dgsSetProperty(netSystem["picture_sen"],"sideColor",tocolor(100,150,240,255))
		
		netSystem["picture_rec"] = dgsCreateImage(290,120,300,90,_,false,netSystem["window"],tocolor(255,255,255,50))
		dgsSetProperty(netSystem.picture_rec,"functionRunBefore",false)
		dgsSetProperty(netSystem.picture_rec,"functions","triggerEvent('onDGSObjectRender',self)")
		netSystem["picture_rec_max"] = dgsCreateLabel(240,125,40,0,"N/A",false,netSystem["window"],_,1.2,1.2,_,_,_,"right","center")
		netSystem["picture_rec_min"] = dgsCreateLabel(240,205,40,0,"0Byte/s",false,netSystem["window"],_,1.2,1.2,_,_,_,"right","center")
		dgsSetProperty(netSystem["picture_rec"],"sideSize",1)
		dgsSetProperty(netSystem["picture_rec"],"sideState","out")
		dgsSetProperty(netSystem["picture_rec"],"sideColor",tocolor(100,150,240,255))
		
		netSystem["picture_pkl"] = dgsCreateImage(290,230,300,90,_,false,netSystem["window"],tocolor(255,255,255,50))
		dgsSetProperty(netSystem.picture_pkl,"functionRunBefore",false)
		dgsSetProperty(netSystem.picture_pkl,"functions","triggerEvent('onDGSObjectRender',self)")
		netSystem["picture_pkl_max"] = dgsCreateLabel(240,235,40,0,"100%",false,netSystem["window"],_,1.2,1.2,_,_,_,"right","center")
		netSystem["picture_pkl_min"] = dgsCreateLabel(240,315,40,0,"0%",false,netSystem["window"],_,1.2,1.2,_,_,_,"right","center")
		dgsSetProperty(netSystem["picture_pkl"],"sideSize",1)
		dgsSetProperty(netSystem["picture_pkl"],"sideState","out")
		dgsSetProperty(netSystem["picture_pkl"],"sideColor",tocolor(100,150,240,255))
		
		addEventHandler("onClientPreRender",root,netUpdate)
		addEventHandler("onDGSObjectRender",netSystem["picture_sen"],function()
			local x,y = dgsGetPosition(source,false,true)
			local sx,sy = dgsGetSize(source,false)
			local maxPos = math.floor((speedSend[0] or 0)*1.2)
			local LineBlue = tocolor(80,180,255,255)
			local isPostGUI = dgsGetPostGUI(source)
			for i=1,#speedSend-1 do
				local nextone = speedSend[i+1] or 0 
				dxDrawLine(x+sx-sx*i/MaxStatisticTimes-1,y+sy-sy*(nextone/maxPos)-1,x+sx-sx*(i-1)/MaxStatisticTimes-1,y+sy-sy*(speedSend[i]/maxPos)-1,LineBlue,1,isPostGUI)
			end
			dgsSetText(netSystem["picture_sen_max"],maxPos.."Byte/s")
		end)
		
		addEventHandler("onDGSObjectRender",netSystem["picture_rec"],function()
			local x,y = dgsGetPosition(source,false,true)
			local sx,sy = dgsGetSize(source,false)
			local maxPos = math.floor((speedRecv[0] or 0)*1.2)
			local LineBlue = tocolor(80,180,255,255)
			local isPostGUI = dgsGetPostGUI(source)
			for i=1,#speedRecv-1 do
				local nextone = speedRecv[i+1] or 0 
				dxDrawLine(x+sx-sx*i/MaxStatisticTimes-1,y+sy-sy*(nextone/maxPos)-1,x+sx-sx*(i-1)/MaxStatisticTimes-1,y+sy-sy*(speedRecv[i]/maxPos)-1,LineBlue,1,isPostGUI)
			end
			dgsSetText(netSystem["picture_rec_max"],maxPos.."Byte/s")
		end)
		
		addEventHandler("onDGSObjectRender",netSystem["picture_pkl"],function()
			local x,y = dgsGetPosition(source,false,true)
			local sx,sy = dgsGetSize(source,false)
			local LineBlue = tocolor(80,180,255,255)
			local isPostGUI = dgsGetPostGUI(source)
			for i=1,#percentLoss-1 do
				local nextone = percentLoss[i+1] or 0 
				dxDrawLine(x+sx-sx*i/MaxStatisticTimes-1,y+sy-sy*(nextone/100)-1,x+sx-sx*(i-1)/MaxStatisticTimes-1,y+sy-sy*(percentLoss[i]/100)-1,LineBlue,1,isPostGUI)
			end
		end)
		
	elseif source == dxStatus["window"] then
		dxStatus["dxList"] = dgsCreateGridList(10,10,480,260,false,dxStatus["window"],_,tocolor(0,0,0,100),white,tocolor(0,0,0,100),tocolor(0,0,0,0),tocolor(100,100,100,100),tocolor(200,200,200,150))
		dgsGridListAddColumn(dxStatus["dxList"],"Name",0.55)
		dgsGridListAddColumn(dxStatus["dxList"],"Value",0.35)
		local scrollBars = dgsGridListGetScrollBar(dxStatus["dxList"])
		dgsSetProperty(scrollBars[1],"scrollArrow",false)
		dgsSetProperty(scrollBars[2],"scrollArrow",false)
		dgsSetProperty(dxStatus["dxList"],"mode",true)
		addEventHandler("onClientRender",root,dxStatusUpdate)
	end
end)