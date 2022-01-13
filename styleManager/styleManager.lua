local loadstring = loadstring

styleSecEnv = {
	tocolor = tocolor,
	dxCreateFont = dxCreateFont,
	dxCreateTexture = function(path) return dxCreateTexture(path,false) end,
	dxCreateScreenSource = dxCreateScreenSource,
	dxCreateShader = function(path) return dxCreateShader(path,false) end,
	dxCreateRenderTarget = dxCreateRenderTarget,
}

styleManager = {
	styles = setmetatable({
			global = {
				mapper = {},	--Name=Path
				loaded = {},	--Name={data}
				using = "Default",
			},
		},{__index=function(self) return self.global end}),
}
--[[
loaded = {
	styleName = {
		...
		created = {
			texture = {},
			font = {},
		},
		shared = {
			texture = {},
			font = {},
		},
		
	}
}
]]

---Style Utils
function deleteTexture()
	local styleResource = dgsElementData[source].styleResource
	if styleManager.styles[styleResource] then
		local styleName = dgsElementData[source].styleName
		styleManager.styles[styleResource].loaded[styleName].created.texture = styleManager.styles[styleResource].loaded[styleName].created.texture or {}
		styleManager.styles[styleResource].loaded[styleName].created.texture[source] = nil	--Remove a texture from a specific style with a specific resource
		--styleManager.styles[styleResource].shared.texture[source] = nil	--If it is shared, remove
	end
end

function deleteSvg()
	local styleResource = dgsElementData[source].styleResource
	if styleManager.styles[styleResource] then
		local styleName = dgsElementData[source].styleName
		styleManager.styles[styleResource].loaded[styleName].created.svg = styleManager.styles[styleResource].loaded[styleName].created.svg or {}
		styleManager.styles[styleResource].loaded[styleName].created.svg[source] = nil	--Remove a svg from a specific style with a specific resource
		--styleManager.styles[styleResource].shared.svg[source] = nil	--If it is shared, remove
	end
end

function newSvg(styleName, res, svg, width, height)
	if not isElement(svg) then
		svg = svgCreate(width, height, svg)
		dgsSetData(svg, "path", svg)
		dgsSetData(svg, "width", width)
		dgsSetData(svg, "height", height)
		dgsAddEventHandler("onClientElementDestroy",svg,"deleteSvg")
	end
	local res = res or "global"
	styleManager.styles[res].loaded[styleName].created.svg = styleManager.styles[res].loaded[styleName].created.svg or {}
	styleManager.styles[res].loaded[styleName].created.svg[svg] = true
	dgsSetData(svg,"styleResource",res)
	dgsSetData(svg,"styleName",styleName)
	return svg
end

function newTexture(styleName,res,texture)
	if not isElement(texture) then
		texture = dxCreateTexture(texture,false)
		dgsSetData(texture,"path",texture)
		dgsAddEventHandler("onClientElementDestroy",texture,"deleteTexture")
	end
	local res = res or "global"
	styleManager.styles[res].loaded[styleName].created.texture = styleManager.styles[res].loaded[styleName].created.texture or {}
	styleManager.styles[res].loaded[styleName].created.texture[texture] = true	--Add a texture into created list in a specific style with a specific resource
	dgsSetData(texture,"styleResource",res)
	dgsSetData(texture,"styleName",styleName)
	return texture
end

function deleteShader()
	local styleResource = dgsElementData[source].styleResource
	if styleManager.styles[styleResource] then
		local styleName = dgsElementData[source].styleName
		styleManager.styles[styleResource].loaded[styleName].created.shader = styleManager.styles[styleResource].loaded[styleName].created.shader or {}
		styleManager.styles[styleResource].loaded[styleName].created.shader[source] = nil	--Remove a shader from a specific style with a specific resource
	end
end

function newShader(styleName,res,shader)
	if not isElement(shader) then
		shader = dxCreateShader(shader,false)
		dgsAddEventHandler("onClientElementDestroy",shader,"deleteShader")
	end
	local res = res or "global"
	styleManager.styles[res].loaded[styleName].created.shader = styleManager.styles[res].loaded[styleName].created.shader or {}
	styleManager.styles[res].loaded[styleName].created.shader[shader] = true	--Add a shader into created list in a specific style with a specific resource
	dgsSetData(shader,"styleResource",res or "global")
	dgsSetData(shader,"styleName",styleName)
	return shader
end

function deleteFont()
	local styleResource = dgsElementData[source].styleResource
	if styleManager.styles[styleResource] then
		local styleName = dgsElementData[source].styleName
		styleManager.styles[styleResource].loaded[styleName].created.font = styleManager.styles[styleResource].loaded[styleName].created.font or {}
		styleManager.styles[styleResource].loaded[styleName].created.font[source] = nil	--Remove a font from a specific style with a specific resource
		--styleManager.styles[styleResource].shared.font[source] = nil	--If it is shared, remove
	end
end

function newFont(styleName,res,font,...)
	if not isElement(font) then
		font = dxCreateFont(font,...)
		dgsSetData(font,"path",texture)
		dgsAddEventHandler("onClientElementDestroy",font,"deleteFont")
	end
	local res = res or "global"
	styleManager.styles[res].loaded[styleName].created.font = styleManager.styles[res].loaded[styleName].created.font or {}
	styleManager.styles[res].loaded[styleName].created.font[font] = true	--Add a font into created list in a specific style with a specific resource
	dgsSetData(font,"styleResource",res or "global")
	dgsSetData(font,"styleName",styleName)
	return font
end

function getStyleFilePath(styleName,res,path)
	res = res or sourceResource or "global"
	styleName = styleName or "Default"
	local testPath = styleManager.styles[res].mapper[styleName].."/"..path
	return fileExists(testPath) and testPath or false
end
------------------------------------
function dgsScanGlobalStyle()
	local fnc,err = loadstring("return {\n"..fileGetContent("styleManager/styleMapper.lua").."\n}")
	if not fnc then
		error("Failed to load styleMapper ("..err..")")
	end
	setfenv(fnc,{})
	local customStyleTable = fnc()
	local using = customStyleTable.use or "Default"
	customStyleTable.Default = nil	--Skip Default
	customStyleTable.use = nil		--Skip Use
	dgsAddStyle("Default","styleManager/Default","global")	--Add default style
	for styleName,stylePath in pairs(customStyleTable) do
		dgsAddStyle(styleName,"styleManager/"..stylePath,"global")
	end
	return using
end

function dgsCreateFontFromStyle(styleName,res,theTable)
	if type(theTable) == "table" then
		res = res or sourceResource or "global"
		local filePath,size,isBold,quality = theTable[1],theTable[2] or 9,theTable[3] or false,theTable[4] or "proof"
		if filePath then
			local thePath = not isElement(filePath) and getStyleFilePath(styleName,res,filePath) or filePath
			local isFontSharing = styleManager.styles[res].loaded[styleName].sharedFont
			if isFontSharing then
				styleManager.styles[res].loaded[styleName].shared.font = styleManager.styles[res].loaded[styleName].shared.font or {}
				local sharedFonts = styleManager.styles[res].loaded[styleName].shared.font
				sharedFonts[thePath] = sharedFonts[thePath] or {}
				sharedFonts[thePath][size] = sharedFonts[thePath][size] or {}
				sharedFonts[thePath][size][isBold] = sharedFonts[thePath][size][isBold] or {}
				if not isElement(sharedFonts[thePath][size][isBold][quality]) then
					sharedFonts[thePath][size][isBold][quality] = newFont(styleName,res,thePath,size,isBold,quality)
				end
				return sharedFonts[thePath][size][isBold][quality]
			else
				return newFont(styleName,res,thePath,size,isBold,quality)
			end
		end
	end
end

function dgsCreateTextureFromStyle(styleName,res,theTable)
	if type(theTable) == "table" then
		res = res or sourceResource or "global"
		local filePath,textureType,shaderSettings = theTable[1],theTable[2],theTable[3]
		if filePath then
			textureType = textureType or "image"
			local thePath = not isElement(filePath) and getStyleFilePath(styleName,res,filePath) or filePath
			if textureType == "image" then
				local isTextureSharing = styleManager.styles[res].loaded[styleName].sharedTexture
				if isTextureSharing then
					styleManager.styles[res].loaded[styleName].shared.texture = styleManager.styles[res].loaded[styleName].shared.texture or {}
					local sharedTexture = styleManager.styles[res].loaded[styleName].shared.texture
					if not isElement(sharedTexture[thePath]) then
						sharedTexture[thePath] = newTexture(styleName,res,thePath)
					end
					return sharedTexture[thePath]
				else
					return newTexture(styleName,res,thePath)
				end
			elseif textureType == "shader" then
				local shader = newShader(styleName,res,thePath)
				for k,v in pairs(shaderSettings or {}) do
					dxSetShaderValue(shader,k,v)
				end
				return shader
			elseif textureType == "svg" then
				local width, height = tonumber(shaderSettings[1]), tonumber(shaderSettings[2])

				if width and height then
					return newSvg(styleName, res, thePath, width, height)
				end
			end
		end
	end
end

function dgsLoadSystemFont(newFont,path,styleName,res)
	res = res or sourceResource or "global"
	local fontSize = 12
	local fontBold = false
	local fontQuality = "proof"
	if type(newFont) == "table" then
		fontSize = newFont[2] or fontSize
		fontBold = newFont[3] or fontBold
		fontQuality = newFont[4] or fontQuality
		newFont = newFont[1]
	end
	if not fontBuiltIn[newFont] then
		newFont = path..newFont
	end
	dgsSetSystemFont(newFont,fontSize,fontBold,fontQuality,styleName,res)
end

function dgsAddStyle(styleName,stylePath,res)
	res = res or sourceResource or "global"
	assert(type(styleName) == "string","Bad argument @dgsAddStyle at argument 1, expect a string got "..type(styleName))
	assert(type(stylePath) == "string","Bad argument @dgsAddStyle at argument 2, expect a string got "..type(stylePath))
	styleManager.styles[res] = (styleManager.styles[res] ~= styleManager.styles.global) and styleManager.styles[res] or {
		mapper = setmetatable({},{__index=styleManager.styles.global.mapper}),
		loaded = setmetatable({},{__index=styleManager.styles.global.loaded}),
		using = "Default",
	}
	local stylePath = string.getPath(res,stylePath)
	assert(fileExists(stylePath.."/styleSettings.txt"),"Bad argument @dgsAddStyle at argument 3, Failed to add resource style [ styleSettings.txt not found at '"..stylePath.."']")
	styleManager.styles[res].mapper[styleName] = stylePath
	return true
end

function dgsLoadStyle(styleName,res)
	res = res or sourceResource or "global"
	assert(type(styleName) == "string","Bad argument @dgsLoadStyle at argument 1, expect a string got "..type(styleName))
	if res ~= "global" then
		assert(styleManager.styles[res],"Bad argument @dgsLoadStyle at argument 1, no style available in this resource ("..getResourceName(res)..")")
	end
	if not styleManager.styles[res].loaded[styleName] then
		local path = styleManager.styles[res].mapper[styleName]
		assert(fileExists(path.."/styleSettings.txt"),"[DGS Style] Missing style setting ("..path.."/styleSettings.txt)")
		local fnc,err = loadstring("return {\n"..fileGetContent(path.."/styleSettings.txt").."\n}")
		if not fnc then
			error("Error when loading "..path.."/styleSettings.txt ("..err..")")
		end
		setfenv(fnc,styleSecEnv)
		local newStyle = fnc()
		if styleName ~= "Default" then
			local gStyle = table.deepcopy(styleManager.styles.global.loaded.Default)
			for dgsType,settings in pairs(gStyle) do
				if newStyle[dgsType] then
					if type(settings) == "table" then
						for dgsProperty,value in pairs(settings) do
							if newStyle[dgsType][dgsProperty] ~= nil then
								gStyle[dgsType] = gStyle[dgsType] or {}
								gStyle[dgsType][dgsProperty] = newStyle[dgsType][dgsProperty]
							end
						end
					elseif newStyle[dgsType] ~= nil then
						gStyle[dgsType] = newStyle[dgsType]
					end
				end
			end
			newStyle = gStyle
		end
		styleManager.styles[res].loaded[styleName] = newStyle
		styleManager.styles[res].loaded[styleName].shared = {}
		styleManager.styles[res].loaded[styleName].created = {}
		dgsLoadSystemFont(newStyle.systemFont,path.."/",styleName,res)
	end
	return true
end

function dgsSetStyle(styleName,res)
	res = res or sourceResource or "global"
	if not styleManager.styles[res].loaded[styleName] then
		dgsLoadStyle(styleName,res)
	end
	styleManager.styles[res].using = styleName
	return true
end

function dgsGetStyle(res)
	res = res or sourceResource or "global"
	return styleManager.styles[res].using
end

function dgsUnloadStyle(styleName,res)
	res = res or sourceResource or "global"
	if styleManager.styles[res] then
		if styleName then
			if styleManager.styles[res].loaded[styleName] then
				for createdType,createdRecorder in pairs(styleManager.styles[res].loaded[styleName].created) do
					for element in pairs(createdRecorder) do
						destroyElement(element)
					end
				end
				styleManager.styles[res].loaded[styleName] = nil
			end
		else
			for styleName in pairs(styleManager.styles[res].loaded) do
				dgsUnloadStyle(styleName,res)
			end
		end
	end
	return true
end

function dgsGetValueFromStyle(elementType,key,styleName,res)
	res = res or sourceResource or "global"
	assert(type(elementType) == "string","Bad argument @dgsGetValueFromStyle at argument 1, expect a string got "..type(elementType))
	assert(type(key) == "string","Bad argument @dgsGetValueFromStyle at argument 2, expect a string got "..type(key))
	if styleManager.styles[res].loaded[styleName or styleManager.styles[res].using] then
		if key and styleManager.styles[res].loaded[styleName or styleManager.styles[res].using][elementType] then
			return styleManager.styles[res].loaded[styleName or styleManager.styles[res].using][elementType][key]
		else
			return styleManager.styles[res].loaded[styleName or styleManager.styles[res].using][elementType]
		end
	end
	return false
end

function dgsGetLoadedStyleList(includeGlobal,res)
	res = res or sourceResource or "global"
	local loadedListIndex = {}
	if includeGlobal then
		for name,data in pairs(styleManager.styles.global.loaded) do
			loadedListIndex[name] = true
		end
	end
	for name,data in pairs(styleManager.styles[res].loaded) do
		loadedListIndex[name] = true
	end
	local loadedList = {}
	for name in pairs(loadedList) do
		loadedList[#loadedList+1] = name
	end
	return loadedList
end

function dgsGetAddedStyleList(includeGlobal,res)
	res = res or sourceResource or "global"
	local addedListIndex = {}
	if includeGlobal then
		for name,data in pairs(styleManager.styles.global.mapper) do
			addedListIndex[name] = true
		end
	end
	for name,data in pairs(styleManager.styles[res].mapper) do
		addedListIndex[name] = true
	end
	local addedList = {}
	for name in pairs(addedList) do
		addedList[#addedList+1] = name
	end
	return addedList
end

addEventHandler("onClientResourceStop",root,function(res)
	if res ~= resource then
		dgsUnloadStyle(res)
	end
end)

addEventHandler("onClientResourceStart",resourceRoot,function()
	--Add exported functions to sandbox
	for i,name in ipairs(getResourceExportedFunctions()) do
		styleSecEnv[name] = _G[name]
	end
	
	local using = dgsScanGlobalStyle()
	dgsLoadStyle("Default")
	dgsLoadStyle(using)
	dgsSetStyle(using)
end)