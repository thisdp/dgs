dgsConfig = {}
dgsConfig.updateCheckAuto			= true										-- Enable:true;Disable:false
dgsConfig.updateCheckInterval		= 120										-- Minutes
dgsConfig.updateCheckNoticeInterval	= 120										-- Minutes
dgsConfig.backupMeta				= true										-- Backup meta.xml
dgsConfig.backupStyleMeta			= false										-- Backup style files meta index from meta.xml
dgsConfig.g2d						= false										-- GUI To DGS command line

function loadConfig()
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
	if dgsConfig.g2d then
		outputDebugString("[DGS]G2D is enabled! If your server isn't under development, Please disable it in config as soon as possible!",2)
	end
end
loadConfig()