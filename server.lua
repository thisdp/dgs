function outputDGSMessage(message,title,level,visibleTo) -- level: 3 = info, 2 = warning, 1 = error, default is info
	message = "[DGS"..(title and " "..title or "").."] "..message
	if type(visibleTo) ~= "table" then
		visibleTo = {visibleTo or "console"}
	end
	local r,g,b = 0,255,0
	if level == 2 then
		r,g,b = 255, 147, 0
	elseif level == 1 then
		r,g,b = 255,0,0
	end
	for i=1,#visibleTo do
		local to = visibleTo[i]
		if to and (to ~= "console" and (not isElement(to) or getElementType(to) ~= "console")) then
			outputChatBox(message,to,r,g,b)
		else
			outputDebugString(message,getVersion().sortable > "1.5.7-9.20477" and 4 or level,r,g,b)
		end
	end
end

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
				outputDGSMessage("The config file has been loaded.","Config")
			else
				configUpdateRequired = true
				outputDGSMessage("Invalid config file.","Config",2)
			end
			if configUpdateRequired then
				fileDelete("config.txt")
				file = fileCreate("config.txt")
				str = ""
				for k,v in pairs(DGSConfig) do
					local value = type(v) == "string" and '"'..v..'"' or tostring(v)
					str = str.."\r\ndgsConfig."..k.." = "..value
				end
				fileWrite(file,str:sub(3))
				fileClose(file)
				outputDGSMessage("The config file has been updated.","Config")
			end
		else
			outputDGSMessage("Failed to open the config file.","Config",2)
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
		outputDGSMessage("Config file was created.","Config")
	end

	setElementData(resourceRoot,"DGS-allowCMD",DGSConfig.enableBuiltInCMD)
	setElementData(resourceRoot,"DGS-enableDebug",DGSConfig.enableDebug)
	setElementData(resourceRoot,"DGS-enableCompatibilityCheck",DGSConfig.enableCompatibilityCheck)
	if DGSConfig.enableG2DCMD then
		outputDGSMessage("G2D command line is enabled.","Config")
	end
end
loadConfig()

-----------Remote Stuff
addEvent("DGSI_RequestQRCode",true)
addEvent("DGSI_RequestIP",true)
addEvent("DGSI_RequestRemoteImage",true)
addEventHandler("DGSI_RequestQRCode",root,function(str,w,h,id)
	fetchRemote("https://api.qrserver.com/v1/create-qr-code/?size="..w.."x"..h.."&data="..str,{},function(data,info,player,id2)
		triggerClientEvent(player,"DGSI_ReceiveQRCode",player,data,info.success,id2)
	end,{client,id})
end)

addEventHandler("DGSI_RequestRemoteImage",root,function(website,id)
	fetchRemote(website,{},function(data,info,player,id2)
		triggerClientEvent(player,"DGSI_ReceiveRemoteImage",player,data,info,id2)
	end,{client,id})
end)

function getMyIP()
	triggerClientEvent(client,"DGSI_ReceiveIP",client,getPlayerIP(client))
end
addEventHandler("DGSI_RequestIP",root,getMyIP)

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
	for fName,_ in pairs(fData) do
		outputDGSMessage("Abnormal Detected at '"..fName.."' of player '"..pName.."'","Security")
	end
end)

addEventHandler("onElementDataChange",resourceRoot,
function (key,old)
	if client and (string.sub(key,0,4) == "DGS-" or key == "DGSI_FileInfo") then
		setElementData(source,key,old)
		outputDGSMessage("Illegal attempt to modify element data ("..key..") by "..getPlayerName(client),"Security",1)
	end
end,false)