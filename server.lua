-----------Config Loader
dgsConfig = {}
dgsConfig.updateCheck				= true		-- Enable:true;Disable:false
dgsConfig.updateCheckInterval		= 120		-- Minutes
dgsConfig.updateCheckNoticeInterval	= 120		-- Minutes
dgsConfig.updateSystemDisabled		= false		-- Minutes
dgsConfig.backupMeta				= true		-- Backup meta.xml
dgsConfig.backupStyleMeta			= true		-- Backup style files meta index from meta.xml
dgsConfig.g2d						= true		-- GUI To DGS command line
dgsConfig.enableBuiltInCMD			= true		-- Enable DGS Built-in CMD /dgscmd
dgsConfig.enableServerConsole		= false		-- Enable DGS Built Server Console

function loadConfig()
	if fileExists("config.txt") then
		local file = fileOpen("config.txt")
		if file then
			local str = fileRead(file,fileGetSize(file))
			fileClose(file)
			local fnc = loadstring(str)
			if fnc then
				fnc()
				outputDebugString("[DGS]Config File Loaded!")
			else
				outputDebugString("[DGS]Invaild Config File!",2)
			end
		else
			outputDebugString("[DGS]Invaild Config File!",2)
		end
	end
	setElementData(resourceRoot,"allowCMD",dgsConfig.enableBuiltInCMD)
	setElementData(resourceRoot,"enableServerConsole",dgsConfig.enableBuiltInCMD)
	if dgsConfig.g2d then
		outputDebugString("[DGS]G2D is enabled!")
	end
	--Regenerate config file
	local file = fileCreate("config.txt")
	local str = ""
	for k,v in pairs(dgsConfig) do
		local value = type(v) == "string" and '"'..v..'"' or tostring(v)
		str = str.."\r\ndgsConfig."..k.." = "..value
	end
	fileWrite(file,str:sub(3))
	fileClose(file)
end
loadConfig()

-----------Remote Stuff
addEvent("DGSI_RequestQRCode",true)
addEvent("DGSI_RequestIP",true)
addEvent("DGSI_RequestRemoteImage",true)
addEvent("DGSI_RequestAboutData",true)
addEventHandler("DGSI_RequestQRCode",resourceRoot,function(str,w,h,id)
	fetchRemote("https://api.qrserver.com/v1/create-qr-code/?size="..w.."x"..h.."&data="..str,{},function(data,info,player,id)
		triggerClientEvent(player,"DGSI_ReceiveQRCode",resourceRoot,data,info.success,id)
	end,{client,id})
end)

addEventHandler("DGSI_RequestRemoteImage",resourceRoot,function(website,id)
	fetchRemote(website,{},function(data,info,player,id)
		triggerClientEvent(player,"DGSI_ReceiveRemoteImage",resourceRoot,data,info,id)
	end,{client,id})
end)

function getMyIP()
	triggerClientEvent(client,"DGSI_ReceiveIP",resourceRoot,getPlayerIP(client))
end
addEventHandler("DGSI_RequestIP",resourceRoot,getMyIP)

setElementData(root,"DGS-ResName",getResourceName(getThisResource()))

-----------About DGS
addEventHandler("DGSI_RequestAboutData",resourceRoot,function()
	if not checkServerVersion(player) then return end
    fetchRemote("https://raw.githubusercontent.com/thisdp/dgs/master/README.md",{},function(data,info,player)
		triggerClientEvent(player,"DGSI_SendAboutData",resourceRoot,data)
	end,{client})
end)

function hashFile(fName)
	local f = fileOpen(fName)
	local fSize = fileGetSize(f)
	local fContent = fileRead(f,fSize)
	fileClose(f)
	return hash("sha256",fContent),fSize
end

addEvent("DGSI_AbnormalDetected",true)
addEvent("DGSI_RequestFileInfo",true)
DGSRecordedFiles = {}
function verifyFile()
	local xml = xmlLoadFile("meta.xml")
	local children = xmlNodeGetChildren(xml)
	for index,child in ipairs(children) do
		local nodeName = xmlNodeGetName(child)
		if nodeName == "script" then
			local typ = xmlNodeGetAttribute(child,"type") or "server"
			if typ == "client" then
				local cache = xmlNodeGetAttribute(child,"cache")
				if cache ~= "false" then
					local src = xmlNodeGetAttribute(child,"src")
					DGSRecordedFiles[src] = {hashFile(src)}
				end
			end
		elseif nodeName == "file" then
			local cache = xmlNodeGetAttribute(child,"cache")
			if cache ~= "false" then
				local src = xmlNodeGetAttribute(child,"src")
				DGSRecordedFiles[src] = {hashFile(src)}
			end
		end
	end
end
verifyFile()

addEventHandler("DGSI_RequestFileInfo",root,function()
	triggerClientEvent(client,"DGSI_ReceiveFileInfo",client,DGSRecordedFiles)
end)

addEventHandler("DGSI_AbnormalDetected",root,function(fData)
	local pName = getPlayerName(client)
	for fName,fData in pairs(fData) do
		outputDebugString("[DGS-Security]Abnormal Detected at '"..fName.."' of player '"..pName.."'")
	end
end)

-------------------Server Console
addEvent("DGSI_RequestServerInfo",true)
if not dgsConfig.enableServerConsole then 
	addEventHandler("DGSI_RequestServerInfo",root,function(required)
		triggerClientEvent(client,"DGSI_ReceiveServerInfo",client,"disabled")
	end)
	return
end
local resourceTable = {}
for key,res in ipairs(getResources()) do
	local resName = getResourceName(res)
	resourceTable[resName] = getResourceState(res)
end
setElementData(root,"DGSI_Resources",resourceTable)

addEventHandler("onResourceLoadStateChange",root,function(changedResource,newState)
	local resName = getResourceName(changedResource)
	resourceTable[resName] = newState
	setElementData(root,"DGSI_Resources",resourceTable)
end)

local playerConnection = {}
addEventHandler("DGSI_RequestServerInfo",root,function(required)
	--Access Control?
	if required.connection == true then
		playerConnection[client] = true
	elseif required.connection == false then
		playerConnection[client] = nil
	end
	if required.maxPlayers then
		required.maxPlayers = getMaxPlayers()
	end
	-------------------------------Execute
	--Start
	if required.start then
		local res = getResourceFromName(required.start)
		local resName = getResourceName(res)
		if res then
			triggerClientEvent(client,"DGSI_ReceiveServerInfo",client,{
				time = getRealTime(),
				start = {
					"start: Requested by "..getPlayerName(client),
					"start: Starting "..resName,
				}
			})
			if startResource(res) then
				triggerClientEvent(client,"DGSI_ReceiveServerInfo",client,{time = getRealTime(),start="start: Resource '"..resName.."' started"})
			end
		else
			triggerClientEvent(client,"DGSI_ReceiveServerInfo",client,{time = getRealTime(),start="start: Resource could not be found"})
		end
		required.start = nil
	end
	
	--Stop
	if required.stop then
		local res = getResourceFromName(required.stop)
		local resName = getResourceName(res)
		if res then
			triggerClientEvent(client,"DGSI_ReceiveServerInfo",client,{
				time = getRealTime(),
				start = {
					"stop: Requested by "..getPlayerName(client),
					"stop: Stopping "..resName,
				}
			})
			if stopResource(res) then
				triggerClientEvent(client,"DGSI_ReceiveServerInfo",client,{time = getRealTime(),stop = "start: Resource '"..resName.."' stopped"})
			end
		else
			triggerClientEvent(client,"DGSI_ReceiveServerInfo",client,{time = getRealTime(),stop = "stop: Resource could not be found"})
		end
		required.stop = nil
	end
	
	--Restart
	if required.restart then
		local res = getResourceFromName(required.restart)
		local resName = getResourceName(res)
		if res then
			triggerClientEvent(client,"DGSI_ReceiveServerInfo",client,{
				time = getRealTime(),
				restart = {
					"restart: Requested by "..getPlayerName(client),
					"restart: Stopping "..resName,
				}
			})
			stopResource(res)
			triggerClientEvent(client,"DGSI_ReceiveServerInfo",client,{
				time = getRealTime(),
				restart = {
					"restart: Starting "..resName,
				}
			})
			if startResource(res) then
				triggerClientEvent(client,"DGSI_ReceiveServerInfo",client,{time = getRealTime(),restart="restart: "..resName.." restarted successfully"})
			end
		else
			required.restart = "restart: Resource could not be found"
		end
		required.restart = nil
	end
	
	--Refresh
	if required.refresh then
		if required.refresh == true then
			triggerClientEvent(client,"DGSI_ReceiveServerInfo",client,{time = getRealTime(),refresh="refresh: refreshing resources..."})
			if refreshResources() then
				triggerClientEvent(client,"DGSI_ReceiveServerInfo",client,{time = getRealTime(),refresh="refresh: complete"})
			end
		elseif type(required.refresh) == "string" then
			local res = getResourceFromName(required.refresh)
			local resName = getResourceName(res)
			triggerClientEvent(client,"DGSI_ReceiveServerInfo",client,{time = getRealTime(),refresh="refresh: refreshing resource '"..resName.."'..."})
			if refreshResources(false,res) then
				triggerClientEvent(client,"DGSI_ReceiveServerInfo",client,{time = getRealTime(),refresh="refresh: complete"})
			end
		end
		required.refresh = nil
	end
	--Refresh all
	if required.refreshall then
		triggerClientEvent(client,"DGSI_ReceiveServerInfo",client,{time = getRealTime(),refreshall="refreshall: refreshing all resources..."})
		if refreshResources(true) then
			triggerClientEvent(client,"DGSI_ReceiveServerInfo",client,{time = getRealTime(),refreshall="refreshall: complete"})
		end
		required.refreshall = nil
	end
	
	required.time = getRealTime()
	triggerClientEvent(client,"DGSI_ReceiveServerInfo",client,required)
end)

addEventHandler("onDebugMessage", root, function(message, level, file, line)
	local debugMessage
	if level == 1 then
		debugMessage = "ERROR: "..file..":"..tostring(line)..": "..message
	elseif level == 2 then
		debugMessage = "WARNING: ".. file..":"..tostring(line)..": "..message
	else
		debugMessage = "INFO: "..file..":"..tostring(line)..": "..message
	end
	for player in pairs(playerConnection) do
		triggerClientEvent(player,"DGSI_ReceiveServerInfo",player,{time = getRealTime(), debugMessage=debugMessage})
	end
end)

addEventHandler("onPlayerQuit",root,function()
	playerConnection[source] = nil
end)