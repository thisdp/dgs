-----------Config Loader
DGSConfig = {
	updateCheck						= true,			-- Enable:true;Disable:false
	updateCheckInterval				= 120,			-- Minutes
	updateCheckNoticeInterval		= 120,			-- Minutes
	updateCommand					= "updatedgs",	-- Command of update dgs
	enableUpdateSystem				= true	,		-- Enable update system
	enableMetaBackup				= true,			-- Backup meta.xml
	enableStyleMetaBackup			= true,			-- Backup style files meta index from meta.xml
	enableG2DCMD					= true,			-- Enable GUI To DGS command line
	enableBuiltInCMD				= true,			-- Enable DGS Built-in CMD /dgscmd
	enableTestFile					= true,			-- Loads DGS Test File (If you want to save some bytes of memory, disable this by set to false)
	enableCompatibilityCheck	 	= true,			-- Enable compatibility check warnings
	enableDebug 					= true,			-- Enable /debugdgs
}

function loadConfig()
	if fileExists("config.txt") then 
		local file = fileOpen ("config.txt")
		if file then 
			local configUpdateRequired = false
			local str = fileRead(file,fileGetSize(file))
			fileClose(file)
			local fnc = loadstring(str)
			if fnc then 
				local dgsConfig = {}
				setfenv(fnc,{dgsConfig=dgsConfig})
				fnc()
				for name,value in pairs(DGSConfig) do
					if dgsConfig[name] == nil then
						configUpdateRequired = true
					else
						DGSConfig[name] = dgsConfig[name]
					end
				end
				outputDebugString("[DGS]Config Loaded!")
			else
				configUpdateRequired = true
				outputDebugString("[DGS]Invalid config file!",3)
			end
			if configUpdateRequired then
				fileDelete("config.txt")
				local file = fileCreate("config.txt")
				local str = ""
				for k,v in pairs(DGSConfig) do
					local value = type(v) == "string" and '"'..v..'"' or tostring(v)
					str = str.."\r\ndgsConfig."..k.." = "..value
				end
				fileWrite(file,str:sub(3))
				fileClose(file)
				outputDebugString("[DGS]Config Updated!")
			end
		else
			outputDebugString("[DGS]Failed to open config file!",3)
		end
	else
		local file = fileCreate("config.txt")
		local str = ""
		for k,v in pairs(DGSConfig) do
			local value = type(v) == "string" and '"'..v..'"' or tostring(v)
			str = str.."\r\ndgsConfig."..k.." = "..value
		end
		fileWrite(file,str:sub(3))
		fileClose(file)
		outputDebugString("[DGS]Config Created!")
	end

	setElementData(resourceRoot,"DGS-allowCMD",DGSConfig.enableBuiltInCMD)
	setElementData(resourceRoot,"DGS-enableDebug",DGSConfig.enableDebug)
	setElementData(resourceRoot,"DGS-enableCompatibilityCheck",DGSConfig.enableCompatibilityCheck)
	if DGSConfig.enableG2DCMD then
		outputDebugString("[DGS]G2D command line is enabled!")
	end
end
loadConfig()

-----------Remote Stuff
addEvent("DGSI_RequestQRCode",true)
addEvent("DGSI_RequestIP",true)
addEvent("DGSI_RequestRemoteImage",true)
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

function hashFile(fName)
	local f = fileOpen(fName)
	local fSize = fileGetSize(f)
	local fContent = fileRead(f,fSize)
	fileClose(f)
	return hash("sha256",fContent),fSize
end

function verifyFile()
	local xml = xmlLoadFile("meta.xml")
	local children = xmlNodeGetChildren(xml)
	local DGSRecordedFiles = {}
	for index,child in ipairs(children) do
		local nodeName = xmlNodeGetName(child)
		if nodeName == "file" then
			local src = xmlNodeGetAttribute(child,"src")
			DGSRecordedFiles[src] = {hashFile(src)}
		end
	end
	setElementData(resourceRoot,"DGSI_FileInfo",DGSRecordedFiles)
end
verifyFile()

addEvent("DGSI_AbnormalDetected",true)
addEventHandler("DGSI_AbnormalDetected",root,function(fData)
	local pName = getPlayerName(client)
	for fName,fData in pairs(fData) do
		outputDebugString("[DGS-Security]Abnormal Detected at '"..fName.."' of player '"..pName.."'")
	end
end)