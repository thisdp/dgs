local check
if fileExists("update.cfg") then
	check = fileOpen("update.cfg")
else
	check = fileCreate("update.cfg")
end
local allstr = fileRead(check,fileGetSize(check))
fileClose(check)
Version = tonumber(allstr) or 0
RemoteVersion = 0
ManualUpdate = false
updateTimer = false
updatePeriodTime = 1 --hour
updatePeriodTimer = false
updateCheckTime = 5 --minute
DP_URL = "http://angel.mtaip.cn:233/dgsUpdate"
function checkUpdate()
	fetchRemote(DP_URL.."/dgs/update.cfg",function(data,err)
		if err == 0 then
			RemoteVersion = tonumber(data)
			if not ManualUpdate then
				if RemoteVersion > Version then
					print("[DGS]Remote Version Got [Remote:"..data.." Current:"..Version.."]")
					print("[DGS]Update? Command: updatedgs")
					if isTimer(updateTimer) then killTimer(updateTimer) end
					updateTimer = setTimer(function()
						if RemoteVersion > Version then
							print("[DGS]Remote Version Got [Remote:"..RemoteVersion.." Current:"..Version.."]")
							print("[DGS]Update? Command: updatedgs")
						else
							killTimer(updateTimer)
						end
					end,updateCheckTime*60000,0)
				end
			else
				startUpdate()
			end
		else
			print("[DGS]Can't Get Remote Version ("..err..")")
		end
	end)
end

checkUpdate()
updatePeriodTimer = setTimer(checkUpdate,updatePeriodTime*3600000,0)

addCommandHandler("updatedgs",function(player)
	print("[DGS]Preparing for updating dgs")
	outputChatBox("[DGS]Preparing for updating dgs",root,0,255,0)
	if RemoteVersion > Version then
		startUpdate()
	else
		ManualUpdate = true
		checkUpdate()
	end
end)

function startUpdate()
	ManualUpdate = false
	setTimer(function()
		print("[DGS]Downloading meta.xml")
		fetchRemote(DP_URL.."/dgs/meta.xml",function(data,err)
			if err == 0 then
				local meta = fileCreate("updated/meta.xml")
				fileWrite(meta,data)
				fileClose(meta)
				checkFiles()
				print("[DGS]Preparing For Checking Files")
			else
				print("[DGS]Can't Get meta.xml, Update Failed ("..err..")")
			end
		end)
	end,50,1)
end

preUpdate = {}
preUpdateCount = 0
UpdateCount = 0
FetchCount = 0
preFetch = 0
function checkFiles()
	local xml = xmlLoadFile("updated/meta.xml")
	for k,v in pairs(xmlNodeGetChildren(xml)) do
		if xmlNodeGetName(v) == "script" or xmlNodeGetName(v) == "file" then
			local path = xmlNodeGetAttribute(v,"src")
			local sha = ""
			if fileExists(path) then
				local file = fileOpen(path)
				local text = fileRead(file,fileGetSize(file))
				fileClose(file)
				sha = hash("sha256",text)
			end
			preFetch = preFetch+1
			print("[DGS]Checking File:"..path.."("..preFetch..")")
			fetchRemote(DP_URL.."/dgsUpdate.php?path="..path,function(data,err,path,sha)
				FetchCount = FetchCount+1
				if sha ~= data then
					print("[DGS]Need Update ("..path..")")
					table.insert(preUpdate,path)
				end
				if FetchCount == preFetch then
					DownloadFiles()
				end
			end,"",false,path,sha)
		end
	end
	print("[DGS]Please Wait...")
end

function DownloadFiles()
	UpdateCount = UpdateCount + 1
	if not preUpdate[UpdateCount] then
		DownloadFinish()
		return
	end
	print("[DGS]Downloading :"..tostring(preUpdate[UpdateCount]).." ("..UpdateCount.."/"..(#preUpdate or "Unknown")..")")
	fetchRemote(DP_URL.."/dgs/"..preUpdate[UpdateCount],function(data,err,path)
		if err == 0 then
			if fileExists(path) then
				fileDelete(path)
			end
			local file = fileCreate(path)
			fileWrite(file,data)
			fileClose(file)
			print("[DGS]File Got :"..path.." ("..UpdateCount.."/"..#preUpdate..")")
		else
			print("[DGS]Download Failed:"..path.." ("..err..")")
		end
		if preUpdate[UpdateCount+1] then
			DownloadFiles()
		else
			DownloadFinish()
		end
	end,"",false,preUpdate[UpdateCount])
end

function DownloadFinish()
	print("[DGS]Changing Config File")
	if fileExists("update.cfg") then
		fileDelete("update.cfg")
	end
	local file = fileCreate("update.cfg")
	fileWrite(file,tostring(RemoteVersion))
	fileClose(file)
	if fileExists("meta.xml") then
		fileDelete("meta.xml")
	end
	fileRename("updated/meta.xml","meta.xml")
	print("[DGS]Update Complete (Updated "..#preUpdate.." Files)")
	print("[DGS]Please Restart DGS")
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
			outputChatBox("ERROR:[DGS]Version State is damaged! Please use /updatedgs to update",pla,255,0,0)
		end
	end
end)