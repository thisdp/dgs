local currentVersion = getResourceInfo(resource,"version") or 0
setElementData(resourceRoot,"Version",currentVersionRaw)

if fileExists("update.cfg") then
    outputDGSMessage("Deleteing the old update.cfg file..","Updater",2)
    if not fileDelete("update.cfg") then
        outputDGSMessage("Failed to delete the old update.cfg file.","Updater",1)
    end
end

addCommandHandler("dgsver",function (player)
    outputDGSMessage("Current version: "..currentVersion,nil,3,player)
end)

if not DGSConfig.enableUpdateSystem then return end

local repoName = "thisdp/dgs"
local latestBranch = "master"

function checkForUpdate(player,callback)
    outputDGSMessage("Checking for updates..","Updater",2,player)
    local apiGETOptions = {
        headers = {
            ["X-GitHub-Api-Version"] = "2022-11-28"
        }
    }
    fetchRemote ("https://api.github.com/repos/"..repoName.."/releases/latest",apiGETOptions,function (remoteData,resInfo)
        local remoteVersion
        if resInfo.success then
            local data = fromJSON(remoteData)
            remoteVersion = data.tag_name or 0
            if tonumber(remoteVersion) > tonumber(currentVersion) then
                outputDGSMessage("New update available: "..currentVersion.." > "..remoteVersion..". Consider updating your DGS using /"..DGSConfig.updateCommand,"Updater",2,player)
                outputDGSMessage("Please check the changelogs at "..data.html_url.." to avoid breaking changes.","Updater",2,player)
            elseif tonumber(remoteVersion) == tonumber(currentVersion) then
                outputDGSMessage("The current version ("..currentVersion..") is the latest!","Updater",2,player)
            else
                outputDGSMessage("The current version is newer than the remote one "..currentVersion.." > "..remoteVersion..". Are you from the future?","Updater",2,player)
            end
        else
            outputDGSMessage("The remote version could not be retrieved ("..resInfo.statusCode..")","Updater",1,player)
        end
        if callback then
            callback(remoteVersion,player)
        end
    end)
end

if DGSConfig.updateCheckAuto then
    checkForUpdate()
    setTimer(checkForUpdate,DGSConfig.updateCheckInterval*60000,0)
end

local updateInfo
local function updateCommandUsage(command,player)
    outputDGSMessage("Usage: /"..command.." [release/latest] or a branch name","Updater",2,player)
    outputDGSMessage ("release: Update to the latest release version which should be the stable version.","Updater",2,player)
    outputDGSMessage ("latest: Update to the latest version which may be unstable.","Updater",2,player)
end

addCommandHandler(DGSConfig.updateCommand,function(player,command,updateType)
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
        updateType = updateType and string.lower(updateType)
        if updateInfo then
            if updateInfo.status == 0 then
                outputDGSMessage("Please wait for the update info to be fetched.","Updater",2,player)
            elseif updateInfo.status == 1 and not updateType then
                updateInfo.player = player
                local tree = updateInfo.files
                startUpdate(updateInfo.target,player,tree)
            elseif updateInfo.status == 2 then
                outputDGSMessage("An update is already in progress.","Updater",2,player)
            end
            return
        end
        if not updateType then return updateCommandUsage(command,player) end
        isUpdating = true
        if updateType == "latest" then
            updateInfo = {status=1,target=latestBranch}
            outputDGSMessage("Are you sure you want to update to the "..updateType.." version?","Updater",2,player)
            outputDGSMessage("Use /"..command.." to confirm.","Updater",2,player)
        elseif updateType == "release" then
            updateInfo = {status=0}
            checkForUpdate(player,function(remoteVersion)
                if remoteVersion then
                    updateInfo = {status=1,target=remoteVersion}
                    outputDGSMessage("Are you sure you want to update to the "..updateType.." version?","Updater",2,player)
                    outputDGSMessage("Use /"..command.." to confirm.","Updater",2,player)
                else
                    updateInfo = nil
                end
            end)
        else
            getUpdateTree(updateType,player,function(updateFiles)
                if updateFiles and #updateFiles > 0 then
                    updateInfo = {status=1,target=updateType,files=updateFiles}
                    outputDGSMessage("Are you sure you want to update to the "..updateType.." version?","Updater",2,player)
                    outputDGSMessage("Use /"..command.." to confirm.","Updater",2,player)
                else
                    updateCommandUsage(command,player)
                    updateInfo = nil
                end
            end)
        end
    else
        outputDGSMessage("You don't have permission to use this command.","Updater",1,player)
    end
end)

function startUpdate(target,player,tree)
    updateInfo.status = 2
    updateInfo.player = player
    outputDGSMessage("Starting update to "..target,"Updater",2,{updateInfo.player,"console"})
    if not tree then
        getUpdateTree(target)
    else
        checkUpdateFiles(tree)
    end
end

function getUpdateTree(target,player,callback)
    local updateFiles = {}
    local treePath = "https://api.github.com/repos/"..repoName.."/git/trees/"..target.."?recursive=1"
    local apiGETOptions = {
        headers = {
            ["X-GitHub-Api-Version"] = "2022-11-28"
        }
    }
    fetchRemote(treePath,apiGETOptions,function(remoteData,resInfo)
        if resInfo.success then
            local data = fromJSON(remoteData)
            if data.tree then
                for k,v in ipairs(data.tree) do
                    if v.type == "blob" and v.path and string.sub(v.path, 1, 1) ~= "." then
                        local downloadURL = "https://raw.githubusercontent.com/"..repoName.."/"..target.."/"..v.path
                        table.insert(updateFiles,{path = v.path,url=downloadURL,sha=v.sha})
                    end
                end
            end
            if not callback then
                checkUpdateFiles(updateFiles)
            end
        else
            outputDGSMessage("Failed to fetch the update files ("..resInfo.statusCode..").","Updater",1,player)
            updateInfo = nil
        end
        if callback then
            callback(updateFiles,player)
        end
    end)
end

function checkUpdateFiles(updateFiles)
    outputDGSMessage("Checking files...","Updater",2,updateInfo.player)
    local filesCount = #updateFiles
    for i=filesCount,1,-1 do
        local remoteFile = updateFiles[i]
        if remoteFile then
            if fileExists (remoteFile.path) then
                local localFile = fileOpen(remoteFile.path,true)
                local localFileSize = fileGetSize(localFile)
                local localFileContent = fileRead(localFile,localFileSize)
                fileClose(localFile)
                local localFileSHA = hash("sha1","blob "..localFileSize.."\0"..localFileContent)
                if localFileSHA == remoteFile.sha then
                    table.remove(updateFiles,i)
                end
            end
        else
            table.remove(updateFiles,i)
        end
    end
    if #updateFiles == 0 then
        outputDGSMessage("Your DGS is already up to date.","Updater",3,updateInfo.player)
        updateInfo = nil
    else
        outputDGSMessage("There are "..#updateFiles.." files needs to be updated. Downloading...","Updater",2,{updateInfo.player,"console"})
        downloadUpdate(updateFiles,true)
    end
end

function downloadUpdate(updateFiles,initial)
    local filesCount = #updateFiles
    if initial then
        updateInfo.filesCount = filesCount
        updateInfo.deletedFiles = {}
        updateInfo.errorsCount = 0
    end
    local file = updateFiles[1]
    table.remove(updateFiles,1)
    outputDGSMessage("Downloading "..file.path.." ("..(updateInfo.filesCount-#updateFiles).."/"..updateInfo.filesCount..")","Updater",2)
    fetchRemote(file.url,{},updateFile,{{file.path,updateFiles}})
end

function updateFile(remoteData,resInfo,args)
    local path,fetchPoll = args[1],args[2]
    if resInfo.success then
        if path == "meta.xml" then
            handleMetaUpdate(remoteData)
        else
            if fileExists(path) then
                fileDelete(path)
            end
            local file = fileCreate(path)
            if file then
                fileWrite(file,remoteData)
                fileClose(file)
            else
                outputDGSMessage("Failed to write the file "..path,"Updater",2)
                updateInfo.errorsCount = updateInfo.errorsCount+1
            end
        end
    else
        outputDGSMessage("Failed to download the file "..path.." ("..resInfo.statusCode..")","Updater",1)
        updateInfo.errorsCount = updateInfo.errorsCount+1
    end

    if #fetchPoll ~= 0 then
        downloadUpdate(fetchPoll)
    else
        outputDGSMessage("Download completed!","Updater",2)
        if #updateInfo.deletedFiles > 0 then
            outputDGSMessage("The following files are deleted:","Updater",2)
            for i=1,#updateInfo.deletedFiles do
                path = updateInfo.deletedFiles[i]
                if fileExists(path) then
                    if fileCopy(path,"backup/"..path,true) then
                        if fileDelete(path) then
                            outputDGSMessage("Deleted "..path,"Updater",2)
                        else
                            outputDGSMessage("Failed to delete "..path,"Updater",1)
                            updateInfo.errorsCount = updateInfo.errorsCount+1
                        end
                    else 
                        outputDGSMessage("Failed to backup "..path,"Updater",1) -- we don't want to delete the file if we can't backup it
                        updateInfo.errorsCount = updateInfo.errorsCount+1
                    end
                end
            end
        end
        if updateInfo.errorsCount == 0 then
            outputDGSMessage("Update completed! Restart DGS.","Updater",3,{updateInfo.player,"console"})
        else
            outputDGSMessage("Update completed with "..updateInfo.errorsCount.." errors.","Updater",2,{updateInfo.player,"console"})
        end
        updateInfo = nil
    end
end

function handleMetaUpdate(remoteMetaContent)
    local localMeta = fileOpen ("meta.xml",true)
    if not localMeta then
        outputDGSMessage("Failed to open meta.xml","Updater",1)
        updateInfo.errorsCount = updateInfo.errorsCount+1
        return
    end
    local localMetaContent = fileRead(localMeta,fileGetSize(localMeta))
    fileClose(localMeta)

	local customPlugins,remoteCustomPlugins = getCustomPluginsFromMeta(localMetaContent),getCustomPluginsFromMeta(remoteMetaContent)
    local localCustomPluginsFiles = getMetaFiles("<meta> "..customPlugins.." </meta>")
    newMetaContent = remoteMetaContent:gsub(remoteCustomPlugins,customPlugins)

    local localMetaFiles,remoteMetaFiles = getMetaFiles(localMetaContent,customPluginsFiles),getMetaFiles(remoteMetaContent)
    updateInfo.deletedFiles = getMetaDeletedFiles(localMetaFiles,remoteMetaFiles,localCustomPluginsFiles)

    if DGSConfig.enableStyleMetaBackup then
        if fileExists("backup/customPlugins.xml") then
            fileDelete("backup/customPlugins.xml")
        end
        local backupFile = fileCreate("backup/customPlugins.xml")
        if backupFile then
            fileWrite(backupFile,customPlugins)
            fileClose(backupFile)
        end
    end

    if DGSConfig.enableMetaBackup then
        fileCopy("meta.xml","backup/meta.xml",true)
    end
    
    fileDelete("meta.xml")
    local newMeta = fileCreate("meta.xml")
    if newMeta then
        fileWrite(newMeta,newMetaContent)
        fileClose(newMeta)
    else
        outputDGSMessage("Failed to update meta.xml","Updater",1)
        updateInfo.errorsCount = updateInfo.errorsCount+1
    end
end

function getCustomPluginsFromMeta(metaContent)
    local startTag = "<!%-%-$Add Your Styles Here%-%->"
    local endTag = "<!%-%-&Add Your Styles Here%-%->"

    local startI = metaContent:find(startTag)
    local endI = metaContent:find(endTag)
    if startI and endI then
        customPlugins = metaContent:sub(startI + #startTag -1,endI -1)
        customPlugins = "\t"..customPlugins:gsub("^%s*(.-)%s*$", "%1") -- remove trailing spaces
        return customPlugins
    end
end

function getMetaFiles(xml)
    local metaNode = xmlLoadString(xml)
    if metaNode then
        local metaFiles = {}
        local metaChildren = xmlNodeGetChildren(metaNode)
        for i=1,#metaChildren do
            local xmlNode = metaChildren[i]
            local nodeName = xmlNodeGetName(xmlNode)
            if nodeName == "file" or nodeName == "script" then
                local path = xmlNodeGetAttribute(xmlNode,"src")
                if path then
                    table.insert(metaFiles,path)
                end
            end
        end
        return metaFiles
    end
end

function getMetaDeletedFiles(localMetaFiles, remoteMetaFiles, excludedFiles)
    local deletedFiles = {}
    for i=1,#localMetaFiles do
        local localMetaFile = localMetaFiles[i]
        local found = false
        for j=1,#remoteMetaFiles do
            if localMetaFile == remoteMetaFiles[j] then
                found = true
                break
            end
        end
        if not found then
            local excluded = false
            for k=1,#exludedFiles do
                if localMetaFile == exludedFiles[k] then
                    excluded = true
                    break
                end
            end
            if not excluded then
                table.insert(deletedFiles,localMetaFile)
            end
        end
    end
    return deletedFiles
end