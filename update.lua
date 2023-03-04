--Check whether you enable/disable dgs update system..
--If you don't trust dgs.. Please Disable It In "config.txt"

local check = fileExists("update.cfg") and fileOpen("update.cfg") or fileCreate("update.cfg")
local verRaw = fileRead(check,fileGetSize(check))
fileClose(check)
setElementData(resourceRoot,"Version",verRaw)
local version = tonumber(verRaw) or 0
if not DGSConfig.enableUpdateSystem then return end

local _fetchRemote = fetchRemote
function fetchRemote(...)
	if not hasObjectPermissionTo(getThisResource(),"function.fetchRemote",true) then
		outputDGSMessage("fetchRemote' was called, but access was denied. To resolve this issue, use the command 'aclrequest allow dgs all'.",2)
		return false
	end
	return _fetchRemote(...)
end

RemoteVersion = 0
ManualUpdate = false
updateTimer = false
updatePeriodTimer = false
function checkUpdate()
	outputDGSMessage("Checking for updates..",nil,"Updater")
	fetchRemote("https://raw.githubusercontent.com/thisdp/dgs/master/update.cfg",function(data,err)
		if err == 0 then
			RemoteVersion = tonumber(data)
			if not ManualUpdate then
				if RemoteVersion > version then
					outputDGSMessage("New update available: "..version.." > "..data..". Consider updating your DGS using /"..DGSConfig.updateCommand,nil,"Updater")
					outputDGSMessage("Please check the changelogs at https://github.com/thisdp/dgs/releases to avoid breaking changes.",nil,"Updater")
					if isTimer(updateTimer) then killTimer(updateTimer) end
					updateTimer = setTimer(function()
						if RemoteVersion > version then
							outputDGSMessage("New update available: "..version.." > "..data..". Consider updating your DGS using /"..DGSConfig.updateCommand,nil,"Updater")
							outputDGSMessage("Please check the changelogs at https://github.com/thisdp/dgs/releases before to avoid breaking changes.",nil,"Updater")
						else
							killTimer(updateTimer)
						end
					end,DGSConfig.updateCheckNoticeInterval*60000,0)
				else
					outputDGSMessage("Current version ("..version..") is the latest!",nil,"Updater")
				end
			else
				startUpdate()
			end
		else
			outputDGSMessage("The remote version could not be retrieved ("..err..")",nil,"Updater",2)
		end
	end)
end

function checkServerVersion(player)
	if getVersion().sortable > "1.5.4-9.11342" then
		outputDGSMessage("Your server version is too old to support dgs update system.",player,nil,2)
		return false
	end
	return true
end

if DGSConfig.updateCheckAuto then
	if not checkServerVersion() then return end
	checkUpdate()
	updatePeriodTimer = setTimer(checkUpdate,DGSConfig.updateCheckInterval*3600000,0)
end

addCommandHandler(DGSConfig.updateCommand,function(player)
	if not checkServerVersion(player) then return end
	local account = getPlayerAccount(player)
	local isPermit = hasObjectPermissionTo(player,"command."..DGSConfig.updateCommand,false)
	if not isPermit then
		local accName = getAccountName(account)
		local adminGroup = aclGetGroup("Admin")
		local consoleGroup = aclGetGroup("Console")
		isPermit = isPermit or (adminGroup and isObjectInACLGroup("user."..accName,adminGroup))
		isPermit = isPermit or (consoleGroup and isObjectInACLGroup("user."..accName,consoleGroup))
	end
	if isPermit then
		outputDGSMessage(getPlayerName(player).." attempt to update dgs (Allowed)")
		outputDGSMessage("Preparing to update dgs",{player,"console"},"Updater")
		if RemoteVersion > version then
			startUpdate()
		else
			ManualUpdate = true
			checkUpdate()
		end
	else
		outputDGSMessage("Access Denied!",player,"Updater",1)
		outputDGSMessage(getPlayerName(player).." attempt to update dgs (Denied)",nil,"Updater",2)
	end
end)

function startUpdate()
	ManualUpdate = false
	setTimer(function()
		outputDGSMessage("Requesting update data (From GitHub)...",nil,"Updater")
		fetchRemote("https://raw.githubusercontent.com/thisdp/dgs/master/meta.xml",function(data,err)
			if err == 0 then
				outputDGSMessage("Update data retrieved successfully.",nil,"Updater")
				if fileExists("updated/meta.xml") then
					fileDelete("updated/meta.xml")
				end
				local meta = fileCreate("updated/meta.xml")
				fileWrite(meta,data)
				fileClose(meta)
				outputDGSMessage("Requesting verification data...",nil,"Updater")
				getGitHubTree()
			else
				outputDGSMessage("Unable to retrieve remote update data ("..err..")",nil,"Updater",2)
			end
		end)
	end,50,1)
end

preUpdate = {}
fileHash = {}
UpdateCount = 0
folderGetting = {}
function getGitHubTree(path,nextPath)
	nextPath = nextPath or ""
	fetchRemote(path or "https://api.github.com/repos/thisdp/dgs/git/trees/master",function(data,err)
		if err == 0 then
			local theTable = fromJSON(data)
			folderGetting[theTable.sha] = nil
			for k,v in pairs(theTable.tree) do
				if (v.path ~= "styleMapper.lua" and fileExists("styleManager/styleMapper.lua")) and v.path ~= "meta.xml" then
					local thePath = nextPath..(v.path)
					if v.mode == "040000" then
						folderGetting[v.sha] = true
						getGitHubTree(v.url,thePath.."/")
					else
						fileHash[thePath] = v.sha
					end
				end
			end
			if not next(folderGetting) then
				checkFiles()
			end
		else
			outputDGSMessage("Failed to get verification data, please try again later (API Cool Down 60 mins)",nil,"Updater",2)
		end
	end)
end

function checkFiles()
	local xml = xmlLoadFile("updated/meta.xml")
	for k,v in ipairs(xmlNodeGetChildren(xml)) do
		repeat
		if xmlNodeGetName(v) == "script" or xmlNodeGetName(v) == "file" then
			local path = xmlNodeGetAttribute(v,"src")
			if string.find(path,"styleMapper.lua") then break end
			if path == "meta.xml" then break end
			if string.find(path,"test.lua") and not DGSConfig.enableTestFile then break end
			local sha = ""
			if fileExists(path) then
				local file = fileOpen(path)
				local size = fileGetSize(file)
				local text = fileRead(file,size)
				fileClose(file)
				sha = hash("sha1","blob " .. size .. "\0" ..text)
			end
			if sha ~= fileHash[path] then
				outputDGSMessage("Update required: ("..path..")",nil,"Updater")
				table.insert(preUpdate,path)
			end
		end
		break
		until true
	end
	DownloadFiles()
end

function DownloadFiles()
	UpdateCount = UpdateCount + 1
	if not preUpdate[UpdateCount] then
		DownloadFinish()
		return
	end
	outputDGSMessage("Requesting ("..UpdateCount.."/"..(#preUpdate or "Unknown").."): "..tostring(preUpdate[UpdateCount]),nil,"Updater")
	fetchRemote("https://raw.githubusercontent.com/thisdp/dgs/master/"..preUpdate[UpdateCount],function(data,err,path)
		if err == 0 then
			local size = 0
			if fileExists(path) then
				local file = fileOpen(path)
				size = fileGetSize(file)
				fileClose(file)
				fileDelete(path)
			end
			local file = fileCreate(path)
			fileWrite(file,data)
			local newsize = fileGetSize(file)
			fileClose(file)
			outputDGSMessage("Got ("..UpdateCount.."/"..#preUpdate.."): "..path.." [ "..size.."B -> "..newsize.."B ]",nil,"Updater")
		else
			outputDGSMessage("Download failed: "..path.." ("..err..")!",nil,"Updater",2)
		end
		if preUpdate[UpdateCount+1] then
			DownloadFiles()
		else
			DownloadFinish()
		end
	end,"",false,preUpdate[UpdateCount])
end

function DownloadFinish()
	outputDGSMessage("Updating version file",nil,"Updater")
	if fileExists("update.cfg") then
		fileDelete("update.cfg")
	end
	local file = fileCreate("update.cfg")
	fileWrite(file,tostring(RemoteVersion))
	fileClose(file)
	if fileExists("meta.xml") then
		backupStyleMapper()
		fileDelete("meta.xml")
	end
	recoverStyleMapper()
	if not DGSConfig.enableTestFile then	--Remove test.lua from meta.xml
		local xml = xmlLoadFile("meta.xml")
		for k,v in ipairs(xmlNodeGetChildren(xml)) do
			if xmlNodeGetName(v) == "script" then
				if string.find(xmlNodeGetAttribute(v,"src"),"test.lua") then
					xmlDestroyNode(v)
					break
				end
			end
		end
		xmlSaveFile(xml)
		xmlUnloadFile(xml)
	end
	outputDGSMessage("Update successful: "..#preUpdate.." file"..(#preUpdate==1 and "" or "s").." have been updated.",{root,"console"},"Updater")
	outputDGSMessage("Please restart DGS",nil,"Updater")
	preUpdate = {}
	UpdateCount = 0
end

addCommandHandler("dgsver",function(pla,cmd)
	local vsdd
	if fileExists("update.cfg") then
		local file = fileOpen("update.cfg")
		local vscd = fileRead(file,fileGetSize(file))
		fileClose(file)
		vsdd = tonumber(vscd)
		if vsdd then
			outputDGSMessage("Current version: "..vsdd,pla)
		else
			outputDGSMessage("Version file is damaged! Please use /"..DGSConfig.updateCommand.." to update",pla,nil,2)
		end
	else
		outputDGSMessage("Version file is damaged! Please use /"..DGSConfig.updateCommand.." to update",pla,nil,2)
	end
end)

styleBackupStr = ""
locator = [[	<export]]
function backupStyleMapper()
	if DGSConfig.enableMetaBackup then
		fileCopy("meta.xml","meta.xml.bak",true)
	end
	if not fileExists("meta.xml") then return outputDGSMessage("Please rename the meta xml as meta.xml",nil,"Updater",2) end
	local meta = fileOpen("meta.xml")
	local str = fileRead(meta,fileGetSize(meta))
	local startStr = "<!----$Add Your Styles Here---->"
	local endStr = "<!----&Add Your Styles Here---->"
	local startPos = str:find(startStr)
	local endPos = str:find(endStr)
	styleBackupStr = str:sub(startPos,endPos-1).."<!--&Add Your Styles Here-->"
	fileClose(meta)
	if fileExists("styleMapperBackup.bak") then
		fileDelete("styleMapperBackup.bak")
	end
	if DGSConfig.enableStyleMetaBackup then
		local file = fileCreate("styleMapperBackup.bak")
		fileWrite(file,styleBackupStr)
		fileClose(file)
	end
end

function recoverStyleMapper()
	if styleBackupStr == "" then return outputDGSMessage("Failed to recover style mapper",nil,"Updater",2) end
	local meta = fileOpen("updated/meta.xml")
	local str = fileRead(meta,fileGetSize(meta))
	fileClose(meta)
	local newMeta = fileCreate("meta.xml")
	local startStr = "<!----$Add Your Styles Here---->"
	local startPos = str:find(startStr)
	local exportPos = str:find(locator)
	local scriptsStr = str:sub(1,startPos-1)
	local exportsStr = str:sub(exportPos)
	fileWrite(newMeta,scriptsStr..styleBackupStr.."\r\n"..exportsStr)
	fileClose(newMeta)
	fileDelete("updated/meta.xml")
end