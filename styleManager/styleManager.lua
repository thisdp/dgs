styleSettings = {}
styleManager = {}
styleManager.currentStyle = "Default"
styleManager.sharedTexture = {}
styleManager.styles = {Default="Default"}

function scanCustomStyle()
	local styleMapper = fileOpen("styleManager/styleMapper.lua")
	local str = fileRead(styleMapper,fileGetSize(styleMapper))
	local str = "return {\n"..str.."\n}"
	local fnc = loadstring(str)
	assert(fnc,"Failed to load styleMapper")
	local customStyleTable = fnc()
	for k,v in pairs(customStyleTable) do
		if k ~= "Default" then
			styleManager.styles[k] = v
		end
	end
end

function getPathFromStyle(styleName)
	return "styleManager/"..(styleManager.styles[styleName] or "Default").."/"
end

function dgsCreateTextureFromStyle(theTable)
	if theTable then
		local filePath,textureType,shaderSettings = theTable[1],theTable[2],theTable[3]
		if filePath then
			textureType = textureType or "image"
			local currentStyle = styleManager.currentStyle
			local thePath = getPathFromStyle(currentStyle)..filePath
			if textureType == "image" then
				if styleSettings.sharedTexture then
					if isElement(styleManager.sharedTexture[thePath]) then
						return styleManager.sharedTexture[thePath]
					else
						styleManager.sharedTexture[thePath] = dxCreateTexture(thePath)
						return styleManager.sharedTexture[thePath]
					end
				else
					return dxCreateTexture(thePath)
				end
			elseif textureType == "shader" then
				local shader = dxCreateShader(thePath)
				for k,v in pairs(shaderSettings or {}) do
					dxSetShaderValue(shader,k,v)
				end
				return shader
			end
		end
	end
end

function checkStyle(styleName)
	if styleName then
		local stylePath = getPathFromStyle(styleName)
		if stylePath then
			assert(fileExists(stylePath.."styleSettings.txt"),"[DGS Style] Missing style setting ("..stylePath.."styleSettings.txt)")
			local styleFile = fileOpen(stylePath.."styleSettings.txt")
			local str = fileRead(styleFile,fileGetSize(styleFile))
			local fnc = loadstring("return {\n"..str.."\n}")
			assert(fnc,"[DGS Style]Error when checking "..stylePath.."styleSettings.txt")
		end
	else
		for k,v in pairs(styleManager.styles) do
			local stylePath = getPathFromStyle(k)
			if stylePath then
				assert(fileExists(stylePath.."styleSettings.txt"),"[DGS Style] Missing style setting ("..stylePath.."styleSettings.txt)")
				local styleFile = fileOpen(stylePath.."styleSettings.txt")
				local str = fileRead(styleFile,fileGetSize(styleFile))
				local fnc = loadstring("return {\n"..str.."\n}")
				assert(fnc,"[DGS Style]Error when checking "..stylePath.."styleSettings.txt")
			end
		end
	end
end

function loadStyle(styleName)
	local path = getPathFromStyle(styleName)
	local styleFile = fileOpen(path.."styleSettings.txt")
	local str = fileRead(styleFile,fileGetSize(styleFile))
	local fnc = loadstring("return {\n"..str.."\n}")
	assert(fnc,"Error when loading "..path.."styleSettings.txt")
	local customStyleSettings = fnc()
	if not next(styleSettings) then
		styleSettings = customStyleSettings
		return
	end
	for dgsType,settigs in pairs(styleSettings) do
		if customStyleSettings[dgsType] then
			for dgsProperty,value in pairs(settings) do
				if customStyleSettings[dgsType][dgsProperty] then
					styleSettings[dgsType][dgsProperty] = customStyleSettings[dgsType][dgsProperty]
				end
			end
		end
	end
end

scanCustomStyle()
loadStyle("Default")