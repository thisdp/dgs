dgsConfig = {}
dgsConfig.updateCheckAuto			= true										-- Enable:true;Disable:false
dgsConfig.updateCheckInterval		= 60										-- Minutes
dgsConfig.updateCheckNoticeInterval	= 5											-- Minutes
dgsConfig.updateCheckURL			= "http://angel.mtaip.cn:233/dgsUpdate"		-- URL
dgsConfig.backup					= true										-- Whether to make a backup for current dgs before updating
dgsConfig.backupMax					= 10										-- How many backup can dgs store in maximum.

function loadConfig()
	outputDebugString("[DGS]Loading Config File...")
	if fileExists("config.txt") then
		local file = fileOpen("config.txt")
		if file then
			local str = fileRead(file,fileGetSize(file))
			fileClose(file)
			local fnc = loadstring(str)
			if fnc then
				fnc()
				outputDebugString("[DGS]Config File Loaded!")
			else
				outputDebugString("[DGS]Config File is invaild!",2)
			end
		else
			outputDebugString("[DGS]Config File is unavailable!",2)
		end
	else
		outputDebugString("[DGS]Config File is not exists! Creating...")
		local file = fileCreate("config.txt")
		local str = ""
		for k,v in pairs(dgsConfig) do
			local value = type(v) == "string" and '"'..v..'"' or tostring(v)
			str = str..string.char(13)..string.char(10).."dgsConfig."..k.." = "..value
		end
		fileWrite(file,str:sub(3))
		fileClose(file)
		outputDebugString("[DGS]Config File Created!")
	end
end
loadConfig()