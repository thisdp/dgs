------------------Security
DGSFileVerify = false
addEventHandler("onDgsStart",resourceRoot,function()
	triggerServerEvent("DGSI_RequestFileInfo",localPlayer)
end)

function verifyFiles()
	local mismatched = {}
	for fName,fData in pairs(DGSFileVerify) do
		local fileInfo = {hashFile(fName)}
		if fileInfo[1] ~= fData[1] or fileInfo[2] ~= fData[2] then
			mismatched[fName] = fData
		end
	end
	if table.count(mismatched) > 0 then
		triggerServerEvent("DGSI_AbnormalDetected",localPlayer,mismatched)
	end
end

addEvent("DGSI_ReceiveFileInfo",true)
addEventHandler("DGSI_ReceiveFileInfo",root,function(data)
	DGSFileVerify = data
	verifyFiles()
end)