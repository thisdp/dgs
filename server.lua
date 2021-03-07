-----------Config Loader
dgsConfig = {}
dgsConfig.updateCheck				= true		-- Enable:true;Disable:false
dgsConfig.updateCheckInterval		= 120		-- Minutes
dgsConfig.updateCheckNoticeInterval	= 120		-- Minutes
dgsConfig.updateSystemDisabled		= false		-- Minutes
dgsConfig.backupMeta				= true		-- Backup meta.xml
dgsConfig.backupStyleMeta			= true		-- Backup style files meta index from meta.xml
dgsConfig.g2d						= true		-- GUI To DGS command line
dgsConfig.enableBuiltInCMD			= true		-- Enable DGS Built CMD /dgscmd

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
				local src = xmlNodeGetAttribute(child,"src")
				DGSRecordedFiles[src] = {hashFile(src)}
			end
		elseif nodeName == "file" then
			local src = xmlNodeGetAttribute(child,"src")
			DGSRecordedFiles[src] = {hashFile(src)}
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