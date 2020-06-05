-- Style Table => StyleName (Folder) => FilePath

Styles = {
	["myStyle"] = {
		"styleSettings.txt",
	}
}

local meta = XML.load("meta.xml",false)

function isFileInMeta (filePath)
	for _,node in ipairs(meta:getChildren()) do 
		if node:getName() == "file" then 
			if node:getAttribute("src") == filePath then 
				return true
			end
		end
	end
	return false
end

function insertFileToMeta (path) 
	local fileTag = meta:createChild("file")
	fileTag:setAttribute("src",path)
	outputDebugString("File "..path.." Added To Meta !")
	
end

addEventHandler("onResourceStart",resourceRoot,function ()
	local tick = getTickCount()
	local restartRequired = false
	local count = 0

	for i,s in pairs(Styles) do 
		for _,v in pairs(s) do 
			local path = "StyleManager/"..tostring(i).."/"..v
			if not isFileInMeta(path) then 
				if not File.exists(path) then outputDebugString("File "..path.." Doesn't Exist !",1,255,0,0) else
					insertFileToMeta(path)
					restartRequired = true
					count = count + 1
				end
			end
		end
	end

	if restartRequired == true then 
		local final = getTickCount() - tick
		outputDebugString("Required Restarting "..getResourceName(getThisResource()).." | Adedd Totally "..count.." File(s) In "..final.." Mili-Second(s)")
	end
end)


addEventHandler("onResourceStop",resourceRoot,function ()
	meta:saveFile()
	meta:unload()
end)
