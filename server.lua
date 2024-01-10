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
	updateCheck = true,
	updateCheckInterval = 120,
	updateCheckNoticeInterval = 120,
	updateCommand = "updatedgs",
	updater = true,
	metaBackup = true,
	metaStyleBackup = true,
	G2DCMD = true,
	CMD = true,
	testFile = true,
	compatibilityChecks = true,
	debugging = true,
}

function loadConfig()
	if fileExists("config.txt") then
		local file = fileOpen ("config.txt")
		if file then
			if hasObjectPermissionTo(resource,"function.loadstring",true) then
				local str = fileRead(file,fileGetSize(file))
				fileClose(file)
				local fnc = loadstring(str)
				if fnc then
					local convertSettings = {
						["enableUpdateSystem"] = "updater",
						["enableMetaBackup"] = "metaBackup",
						["enableStyleMetaBackup"] = "metaStyleBackup",
						["enableG2DCMD"] = "G2DCMD",
						["enableBuiltInCMD"] = "CMD",
						["enableTestFile"] = "testFile",
						["enableCompatibilityCheck"] = "compatibilityChecks",
						["enableDebug"] = "debugging"
					}
					local dgsConfig = {}
					local customSettings
					setfenv(fnc,{dgsConfig=dgsConfig})
					fnc()
					for name,value in pairs(dgsConfig) do
						local setting = convertSettings[name]
						if setting or get(name) then 
							set("*"..(setting or name),value)
						else 
							customSettings = true 
						end
					end
					outputDGSMessage("Old config file has been converting to meta settings.","Config")
					if customSettings then 
						outputDGSMessage("However, custom settings were detected, so the file was not deleted.","Config")
						fileRename("config.txt","deleted/config.txt")
					else 
						fileDelete("config.txt")
						outputDGSMessage("The old config file was deleted.","Config")
					end
				end
			else
				outputDGSMessage("Failed to convert the old config file to MTA settings since function.loadstring is disabled. config.txt was backed up","Config",2)
				fileRename("config.txt","deleted/config.txt")
			end
		else
			outputDGSMessage("Failed to open the old config file.","Config",2)
		end
	end
	
	for setting,defaultValue in pairs (DGSConfig) do
		local value = get("*"..setting) 
		if type(defaultValue) == "boolean" then
			value = value == "true" or value == true
		elseif type(defaultValue) == "number" then
			value = tonumber(value) or defaultValue
		end
		DGSConfig[setting] = value
	end 

	setElementData(resourceRoot,"DGS-allowCMD",DGSConfig.CMD)
	setElementData(resourceRoot,"DGS-enableDebug",DGSConfig.debugging)
	setElementData(resourceRoot,"DGS-enableCompatibilityCheck",DGSConfig.compatibilityChecks)
	if DGSConfig.enableG2DCMD then
		outputDGSMessage("G2D command line is enabled.","Config")
	end
end
loadConfig()

local settingsPrefix = string.format("*%s.", getResourceName(resource))
addEventHandler("onSettingChange", root,
function (gsetting,_,jsonValue)
	if string.sub(gsetting,1,#settingsPrefix) == settingsPrefix then
		local setting = string.sub(gsetting,#settingsPrefix+1)
		local value = fromJSON(jsonValue)
		if setting == "CMD" then
			setElementData(resourceRoot,"DGS-allowCMD",value == true or value == "true")
		elseif setting == "debugging" then
			setElementData(resourceRoot,"DGS-enableDebug",value == true or value == "true")
		end
	end
end)


-----------Remote Stuff
addEvent("DGSI_RequestQRCode",true)
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
	triggerClientEvent(source,"DGSI_ReceiveIP",source,getPlayerIP(source))
end
addEventHandler("onPlayerResourceStart",root,getMyIP)

setElementData(root,"DGS-ResName",getResourceName(resource))

addEventHandler("onElementDataChange",resourceRoot,
function (key,old)
	if client and (string.sub(key,0,4) == "DGS-" or key == "DGSI_FileInfo") then
		setElementData(source,key,old)
		outputDGSMessage("Illegal attempt to modify element data ("..key..") by "..getPlayerName(client),"Security",1)
	end
end,false)