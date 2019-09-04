--Check whether you enable/disable dgs update system..
--If you don't trust dgs.. Please Disable It In "config.txt"

local check
if fileExists("update.cfg") then
	check = fileOpen("update.cfg")
else
	check = fileCreate("update.cfg")
end
local allstr = fileRead(check,fileGetSize(check))
setElementData(resourceRoot,"Version",allstr)
fileClose(check)

if dgsConfig.updateSystemDisabled then return end
Version = tonumber(allstr) or 0
RemoteVersion = 0
ManualUpdate = false
updateTimer = false
updatePeriodTimer = false
function checkUpdate()
	outputDebugString("[DGS]Connecting to github...")
	fetchRemote("https://raw.githubusercontent.com/thisdp/dgs/master/update.cfg",function(data,err)
		if err == 0 then
			RemoteVersion = tonumber(data)
			if not ManualUpdate then
				if RemoteVersion > Version then
					outputDebugString("[DGS]Remote Version Got [Remote:"..data.." Current:"..allstr.."].")
					outputDebugString("[DGS]Update? Command: updatedgs")
					if isTimer(updateTimer) then killTimer(updateTimer) end
					updateTimer = setTimer(function()
						if RemoteVersion > Version then
							outputDebugString("[DGS]Remote Version Got [Remote:"..RemoteVersion.." Current:"..allstr.."].")
							outputDebugString("[DGS]Update? Command: updatedgs")
						else
							killTimer(updateTimer)
						end
					end,dgsConfig.updateCheckNoticeInterval*60000,0)
				else
					outputDebugString("[DGS]Current Version("..allstr..") is the latest!")
				end
			else
				startUpdate()
			end
		else
			outputDebugString("[DGS]Can't Get Remote Version ("..err..")")
		end
	end)
end

if dgsConfig.updateCheckAuto then
	checkUpdate()
	updatePeriodTimer = setTimer(checkUpdate,dgsConfig.updateCheckInterval*3600000,0)
end
	
addCommandHandler("updatedgs",function(player)
	local account = getPlayerAccount(player)
	local accName = getAccountName(account)
	local isAdmin = isObjectInACLGroup("user."..accName,aclGetGroup("Admin")) or isObjectInACLGroup("user."..accName,aclGetGroup("Console"))
	if isAdmin then
		outputDebugString("[DGS]Player "..getPlayerName(player).." attempt to update dgs (Allowed)")
		outputDebugString("[DGS]Preparing for updating dgs")
		outputChatBox("[DGS]Preparing for updating dgs",root,0,255,0)
		if RemoteVersion > Version then
			startUpdate()
		else
			ManualUpdate = true
			checkUpdate()
		end
	else
		outputChatBox("[DGS]Access Denined!",player,255,0,0)
		outputDebugString("[DGS]Player "..getPlayerName(player).." attempt to update dgs (Denied)!",2)
	end
end)

function startUpdate()
	ManualUpdate = false
	setTimer(function()
		outputDebugString("[DGS]Requesting Update Data (From github)...")
		fetchRemote("https://raw.githubusercontent.com/thisdp/dgs/master/meta.xml",function(data,err)
			if err == 0 then
				outputDebugString("[DGS]Update Data Acquired")
				if fileExists("updated/meta.xml") then
					fileDelete("updated/meta.xml")
				end
				local meta = fileCreate("updated/meta.xml")
				fileWrite(meta,data)
				fileClose(meta)
				outputDebugString("[DGS]Requesting Verification Data...")
				getGitHubTree()
			else
				outputDebugString("[DGS]!Can't Get Remote Update Data (ERROR:"..err..")",2)
			end
		end)
	end,50,1)
end

preUpdate = {}
fileHash = {}
preUpdateCount = 0
UpdateCount = 0
FetchCount = 0
preFetch = 0
folderGetting = {}
function getGitHubTree(path,nextPath)
	nextPath = nextPath or ""
	fetchRemote(path or "https://api.github.com/repos/thisdp/dgs/git/trees/master",function(data,err)
		if err == 0 then
			local theTable = fromJSON(data)
			folderGetting[theTable.sha] = nil
			for k,v in pairs(theTable.tree) do
				if v.path ~= "styleMapper.lua" and v.path ~= "meta.xml" then
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
			outputDebugString("[DGS]Failed To Get Verification Data, Please Try Again Later (API Cool Down 60 mins)!",2)
		end
	end)
end

function checkFiles()
	local xml = xmlLoadFile("updated/meta.xml")
	for k,v in pairs(xmlNodeGetChildren(xml)) do
		if xmlNodeGetName(v) == "script" or xmlNodeGetName(v) == "file" then
			local path = xmlNodeGetAttribute(v,"src")
			if not string.find(path,"styleMapper.lua") and path ~= "meta.xml" then
				local sha = ""
				if fileExists(path) then
					local file = fileOpen(path)
					local size = fileGetSize(file)
					local text = fileRead(file,size)
					fileClose(file)
					sha = hash("sha1","blob " .. size .. "\0" ..text)
				end
				if sha ~= fileHash[path] then
					outputDebugString("[DGS]Update Required: ("..path..")")
					table.insert(preUpdate,path)
				end
			end
		end
	end
	DownloadFiles()
end

function DownloadFiles()
	UpdateCount = UpdateCount + 1
	if not preUpdate[UpdateCount] then
		DownloadFinish()
		return
	end
	outputDebugString("[DGS]Requesting ("..UpdateCount.."/"..(#preUpdate or "Unknown").."): "..tostring(preUpdate[UpdateCount]).."")
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
			outputDebugString("[DGS]File Got ("..UpdateCount.."/"..#preUpdate.."): "..path.." [ "..size.."B -> "..newsize.."B ]")
		else
			outputDebugString("[DGS]Download Failed: "..path.." ("..err..")!",2)
		end
		if preUpdate[UpdateCount+1] then
			DownloadFiles()
		else
			DownloadFinish()
		end
	end,"",false,preUpdate[UpdateCount])
end

function DownloadFinish()
	outputDebugString("[DGS]Changing Config File")
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
	outputDebugString("[DGS]Update Complete (Updated "..#preUpdate.." Files)")
	outputDebugString("[DGS]Please Restart DGS")
	outputChatBox("[DGS]Update Complete (Updated "..#preUpdate.." Files)",root,0,255,0)
	preUpdate = {}
	preUpdateCount = 0
	UpdateCount = 0
	FetchCount = 0
	preFetch = 0
end

addCommandHandler("dgsver",function(pla,cmd)
	local vsdd
	if fileExists("update.cfg") then
		local file = fileOpen("update.cfg")
		local vscd = fileRead(file,fileGetSize(file))
		fileClose(file)
		vsdd = tonumber(vscd)
		if vsdd then
			outputDebugString("[DGS]Version: "..vsdd,3)
		else
			outputDebugString("[DGS]Version State is damaged! Please use /updatedgs to update",1)
		end
	else
		outputDebugString("[DGS]Version State is damaged! Please use /updatedgs to update",1)
	end
	if getPlayerName(pla) ~= "Console" then
		if vsdd then
			outputChatBox("[DGS]Version: "..vsdd,pla,0,255,0)
		else
			outputChatBox("[DGS]Version State is damaged! Please use /updatedgs to update",pla,255,0,0)
		end
	end
end)

styleBackupStr = ""
locator = [[	<export]]
function backupStyleMapper()
	if dgsConfig.backupMeta then
		fileCopy("meta.xml","meta.xml.bak",true)
	end
	assert(fileExists("meta.xml"),"[DGS] Please rename the meta xml as meta.xml")
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
	if dgsConfig.backupStyleMeta then
		local file = fileCreate("styleMapperBackup.bak")
		fileWrite(file,styleBackupStr)
		fileClose(file)
	end
end
function recoverStyleMapper()
	assert(styleBackupStr ~= "","[DGS] Failed to recover style mapper")
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