------------------Security
DGSFileVerify = false
DGSFileInfo = getElementData(resourceRoot,"DGSI_FileInfo")
function verifyFile(fName,exportContent)
	if fileExists(fName) then
		local _hash,_size,_content = hashFile(fName,exportContent)
		local localFileInfo = {_hash,_size}
		local targetFileInfo = DGSFileInfo[fName]
		if localFileInfo[1] ~= targetFileInfo[1] or localFileInfo[2] ~= targetFileInfo[2] then
			return false,localFileInfo
		end
		return true,_content
	end
	return true
end

function verifyFiles()
	local mismatched = {}
	for fName,fData in pairs(DGSFileInfo) do
		local matched,fileInfo = verifyFile(fName)
		if not matched then
			mismatched[fName] = fileInfo
		end
	end
	if table.count(mismatched) > 0 then
		triggerServerEvent("DGSI_AbnormalDetected",localPlayer,mismatched)
	end
	collectgarbage()
end
addEventHandler("onDgsStart",resourceRoot,verifyFiles)
