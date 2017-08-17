addEvent("giveIPBack",true)
dgs_MyIP = "Unknown"
triggerServerEvent("getMyIP",localPlayer)
addEventHandler("giveIPBack",root,function(ip)
	dgs_MyIP = ip
end)

cmdSystem = {}
netSystem = {}
addCommandHandler("cmd",function()
	if not isElement(cmdSystem["window"]) then
		cmdSystem["window"] = dgsDxCreateWindow(sW*0.5-20,sH*0.5,40,25,"CMD",false,tocolor(255,0,0,255),_,_,tocolor(80,140,200,255))
		dgsMoveTo(cmdSystem["window"],sW*0.25,sH*0.5,false,false,"OutQuad",300)
		dgsSizeTo(cmdSystem["window"],sW*0.5,25,false,false,"OutQuad",300)
		setTimer(function()
			dgsMoveTo(cmdSystem["window"],sW*0.25,sH*0.25,false,false,"InQuad",300)
			dgsSizeTo(cmdSystem["window"],sW*0.5,sH*0.6,false,false,"InQuad",300)
			setTimer(function()
				cmdSystem["cmd"] = dgsDxCreateCmd(0,0,1,1,true,cmdSystem["window"])
				dgsDxCmdAddEventToWhiteList(cmdSystem["cmd"],{"changeMode"})
				outputCmdMessage(cmdSystem["cmd"],"DGS ( Thisdp's Dx Graphical User Interface System ) Version: 2.70 beta")
			end,310,1)
			dgsShowCursor(true)
		end,310,1)
	else
		for k,v in pairs(cmdSystem) do
			if k ~= "window" then
				destroyElement(v)
			end
		end
		local x,y = unpack(dgsGetData(cmdSystem["window"],"absPos",false))
		local sx,sy = unpack(dgsGetData(cmdSystem["window"],"absSize",false))
		dgsDxGUISetProperty(cmdSystem["window"],"title","")
		dgsMoveTo(cmdSystem["window"],x,y+sy/2-20,false,false,"InQuad",450)
		dgsSizeTo(cmdSystem["window"],sx,40,false,false,"InQuad",450)
		setTimer(function()
			destroyElement(cmdSystem["window"])
		end,500,1)
	end
end)

addEventHandler("onClientDgsDxWindowClose",root,function()
	if source == cmdSystem["window"] then
		cancelEvent()
		for k,v in pairs(cmdSystem) do
			if k ~= "window" then
				destroyElement(v)
			end
		end
		local x,y = unpack(dgsGetData(cmdSystem["window"],"absPos",false))
		local sx,sy = unpack(dgsGetData(cmdSystem["window"],"absSize",false))
		dgsDxGUISetProperty(cmdSystem["window"],"title","")
		dgsMoveTo(cmdSystem["window"],x,y+sy/2-20,false,false,"InQuad",450)
		dgsSizeTo(cmdSystem["window"],sx,40,false,false,"InQuad",450)
		setTimer(function()
			destroyElement(cmdSystem["window"])
		end,500,1)
	elseif dgsGetData(source,"animated") == 1 then
		if source == netSystem["window"] then
			outputCmdMessage(cmdSystem["cmd"],"Network Monitor: OFF")
		end
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
dgsAddCommandHandler("version",function(cmd)
	outputCmdMessage(cmd,"[Version]1.62")
end)

dgsAddCommandHandler("mode",function(cmd,cmdtype)
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
		outputCmdMessage(cmd,"   function -->Function CMD: Only Run the command added by 'dgsAddCommandHandler'")
		outputCmdMessage(cmd,"   event    -->Event CMD: Only Run the command added by 'addEvent' like 'triggerEvent'")
	end
end)

dgsAddCommandHandler("serial",function(cmd)
	outputCmdMessage(cmd,"Serial:"..getPlayerSerial())
end)

dgsAddCommandHandler("mtaversion",function(cmd)
	outputCmdMessage(cmd,"MTA Client Version:")
	for k,v in pairs(getVersion()) do
		outputCmdMessage(cmd,k..":  "..tostring(v))
	end
end)

dgsAddCommandHandler("dxstatus",function(cmd)
	outputCmdMessage(cmd,"DX status:")
	for k,v in pairs(dxGetStatus()) do
		outputCmdMessage(cmd,k..":  "..tostring(v))
	end
end)

dgsAddCommandHandler("netstatus",function(cmd)
	if not isElement(netSystem["window"]) then
		netSystem["window"] = dgsCreateAnimationWindow(sW/2-250,sH/2-150,500,300,"Network Status",false,tocolor(20,20,200,255),_,_,tocolor(80,140,200,255),_,tocolor(0,0,0,200))
		dgsDxWindowSetSizable(netSystem["window"],false)
		dgsDxGUIBringToFront(netSystem["window"])
		outputCmdMessage(cmd,"Network Monitor:ON")
	else
		triggerEvent("onClientDgsDxWindowClose",netSystem["window"])
		outputCmdMessage(cmd,"Network Monitor:OFF")
	end
end)

dgsAddCommandHandler("getping",function(cmd,times,time)
	times = times or 1
	time = time or 500
	setTimer(function(cmd)
		if not isElement(cmd) then killTimer(selfTimer) end
		outputCmdMessage(cmd,"Ping:"..getPlayerPing(localPlayer).." ms")
	end,time,times,cmd)
end)

dgsAddCommandHandler("pos",function(cmd,playern)
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

dgsAddCommandHandler("getvehid",function(cmd)
    if isPedInVehicle(localPlayer) then
        local veh = getPedOccupiedVehicle(localPlayer)
        outputCmdMessage(cmd,"Current Vehicle ID:"..getElementModel(veh))
    else
        outputCmdMessage(cmd,"Are you in a vehicle?")
    end
end)

dgsAddCommandHandler("gettarvehid",function(cmd)
    local target = getPedTarget(localPlayer)
    if isElement(target) and getElementType(target) == "vehicle" then
        outputCmdMessage(cmd,"Target Vehicle ID:"..getElementModel(target))
    else
        outputCmdMessage(cmd,"No target vehicle")
    end
end)

dgsAddCommandHandler("getvehstate",function(cmd)
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
end)

dgsAddCommandHandler("exit",function(cmd)
    if isElement(cmdSystem["window"]) then
        dgsDxGUICloseWindow(cmdSystem["window"])
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

addEventHandler("onClientPreRender",root,function()
	guiSetInputMode("no_binds_when_editing")
	if isElement(netSystem["Sent"]) then
		local network = getNetworkStats()
		dgsDxGUISetText(netSystem["BytesReceived"],"Bytes:"..(network.bytesReceived))
		dgsDxGUISetText(netSystem["PacketsReceived"],"Packages:"..(network.packetsReceived))
		dgsDxGUISetText(netSystem["ByteSent"],"Bytes:"..(network.bytesSent))
		dgsDxGUISetText(netSystem["PacketsSent"],"Packages:"..(network.packetsSent))
		dgsDxGUISetText(netSystem["packetlossLastSecond"],"Package Loss:"..string.format("%.2f",network.packetlossLastSecond).."%")
		dgsDxGUISetText(netSystem["PacketLossTotal"],"Average Loss:"..string.format("%.2f",network.packetlossTotal).."%")
		dgsDxGUISetText(netSystem["IP"],"My IP:"..dgs_MyIP)
	end
end)

addEventHandler("onClientDgsDxGuiDestroy",root,function()
	if source == cmdSystem["window"] or source == netSystem["window"] then
		dgsShowCursor(false,source)
	end
end)

function dgsShowCursor(bool,gui)
	if bool then
		showCursor(true)
	else
		if (gui == cmdSystem["window"] and not isElement(netSystem["window"])) or (gui == netSystem["window"] and not isElement(cmdSystem["window"])) then
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
	local window = dgsDxCreateWindow(unpack(tabl))
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

addEvent("onAnimationWindowCreate",true)
addEventHandler("onAnimationWindowCreate",root,function()
	if source == netSystem["window"] then
		netSystem["Sent"] = dgsDxCreateLabel(10,5,100,30,"Send",false,netSystem["window"],_,1.5,1.5)
		dgsDxGUISetFont(netSystem["Sent"],msyh_18)
		netSystem["ByteSent"] = dgsDxCreateLabel(10,35,200,20,"Bytes:",false,netSystem["window"])
		netSystem["PacketsSent"] = dgsDxCreateLabel(10,55,200,20,"Packages:",false,netSystem["window"])

		netSystem["Received"] = dgsDxCreateLabel(10,85,100,30,"Receive",false,netSystem["window"],_,1.5,1.5)
		dgsDxGUISetFont(netSystem["Received"],msyh_18)
		netSystem["BytesReceived"] = dgsDxCreateLabel(10,115,200,20,"Bytes:",false,netSystem["window"])
		netSystem["PacketsReceived"] = dgsDxCreateLabel(10,135,200,20,"Packages:",false,netSystem["window"])

		netSystem["PacketLoss"] = dgsDxCreateLabel(10,165,200,30,"Package Loss",false,netSystem["window"],_,1.5,1.5)
		dgsDxGUISetFont(netSystem["PacketLoss"],msyh_18)
		netSystem["packetlossLastSecond"] = dgsDxCreateLabel(10,195,200,20,"Package Loss:",false,netSystem["window"])
		netSystem["PacketLossTotal"] = dgsDxCreateLabel(10,215,200,20,"Average Loss:",false,netSystem["window"])
		
		netSystem["IP"] = dgsDxCreateLabel(10,250,200,20,"My IP:"..dgs_MyIP,false,netSystem["window"])
	end
end)