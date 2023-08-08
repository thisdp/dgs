--Video Memory Manager

function dgsCreateFont(pathOrRaw,size,bold,quality)
	local sRes = sourceResource or resource
	if not(type(pathOrRaw) == "string") then error(dgsGenAsrt(pathOrRaw,"dgsCreateFont",1,"string")) end
	local realPath = string.getPath(sRes,pathOrRaw)
	if not(ileExists(realPath)) then error(dgsGenAsrt(realPath,"dgsCreateFont",1,_,_,"file \""..realPath.."\" doesn't exist")) end
	size = size or 9
	bold = bold or false
	quality = quality or "proof"
	local dgsFont = createElement("dgs-dxfont")
	dgsSetType(dgsFont,"dgs-dxfont")
	dgsElementData[dgsFont] = {
		path = realPath,
		size = size,
		bold = bold,
		quality = quality,
		font = nil,
		lastUsing = getTickCount(),
	}
	return dgsFont
end

function dgsFontRequest(dgsFont)
	local eleData = dgsElementData[dgsTexture]
	if eleData.font then return eleData.font end
	local f = dxCreateFont(eleData.path,eleData.size or 9,eleData.bold or false,eleData.quality or "proof")
	eleData.font = f
	return f
end

function dgsCreateTexture(...)
	local sRes = sourceResource or resource
	
	local textureCreationType
	local textureFormat,mipmaps,textureEdge,textureType,depth
	local realPath
	local width,height
	
	if type(select(1,...)) == "number" then
		textureCreationType = "empty"
		width,height,textureFormat,textureEdge,textureType,depth = ...
	else type(select(1,...)) == "string" then
		if not(type(pathOrRaw) == "string") then error(dgsGenAsrt(pathOrRaw,"dgsCreateFont",1,"string")) end
		if dgsGetPixelsFormat(pathOrRaw) then
			realPath = pathOrRaw
			textureCreationType = "raw"
		else
			realPath = string.getPath(sRes,pathOrRaw)
			if not(fileExists(realPath)) then error(dgsGenAsrt(realPath,"dgsCreateFont",1,_,_,"file \""..realPath.."\" doesn't exist")) end
			textureCreationType = "path"
		end
		textureFormat,mipmaps,textureEdge = ...
	end
	local dgsTexture = createElement("dgs-dxtexture")
	dgsSetType(dgsFont,"dgs-dxfont")
	dgsElementData[dgsFont] = {
		creationType = textureCreationType,
		path = realPath,
		width = width,
		height = height,
		format = textureFormat,
		mipmaps = mipmaps,
		edge = textureEdge,
		type = textureType,
		depth = depth,
		texture = nil,
		lastUsing = getTickCount(),
	}
	return dgsTexture
end

function dgsTextureRequest(dgsTexture)
	local eleData = dgsElementData[dgsTexture]
	if eleData.texture then return eleData.texture end
	local cType = eleData.creationType
	if cType == "path" or cType == "raw" then
		local t = dxCreateTexture(eleData.path,eleData.format or "argb",eleData.mipmaps ~= false, eleData.edge or "wrap")
		eleData.texture = t
	elseif cType == "empty" then
		local t = dxCreateTexture(eleData.width,eleData.height,eleData.format or "argb",eleData.edge or "wrap",eleData.type or "2d",eleData.depth or 1)
		eleData.texture = t
	end
	return false
end

function dgsTextureSetAlwaysAlive()
	
end

function dgsCreateRenderTarget(width,height,withAlpha)
	if not(type(width) == "number") then error(dgsGenAsrt(width,"dgsCreateRenderTarget",1,"number")) end
	if not(type(height) == "number") then error(dgsGenAsrt(height,"dgsCreateRenderTarget",2,"number")) end
	local dgsRenderTarget = createElement("dgs-dxrendertarget")
	dgsElementData[dgsRenderTarget] = {
		width = width,
		height = height,
		withAlpha = withAlpha,
		rendertarget = nil,
		lastUsing = getTickCount(),
	}
	return dgsRenderTarget
end

function dgsRenderTargetRequest(dgsRenderTarget)
	local eleData = dgsElementData[dgsRenderTarget]
	if eleData.rendertarget then return eleData.rendertarget end
	local rt = dgsCreateRenderTarget(eleData.width,eleData.height,eleData.withAlpha)
	eleData.rendertarget = rt
	return rt
end