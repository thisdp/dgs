dgsLogLuaMemory()
dgsRegisterType("dgs-dxcustomrenderer")
local loadstring = loadstring
--Dx Functions
local dxDrawLine = dxDrawLine
local dxDrawImage = dxDrawImage
local dxDrawImageSection = dxDrawImageSection
local dgsDrawText = dgsDrawText
local dxGetFontHeight = dxGetFontHeight
local dxDrawRectangle = dxDrawRectangle
local dxSetShaderValue = dxSetShaderValue
local dxGetPixelsSize = dxGetPixelsSize
local dxGetPixelColor = dxGetPixelColor
local dxSetRenderTarget = dxSetRenderTarget
local dxGetTextWidth = dxGetTextWidth
local dxSetBlendMode = dxSetBlendMode
--DGS Functions
local dgsSetType = dgsSetType
local dgsSetData = dgsSetData
--Utilities
local dgsTriggerEvent = dgsTriggerEvent
local createElement = createElement
--
--This is a special dgs element that won't be rendered itself.
--This dgs element is usually used for plugins
--Note: There will be nothing if you use this dgs element as a child element or a parent element
function dgsCreateCustomRenderer(customFnc,width,height)
	local sRes = sourceResource or resource
	local cr = createElement("dgs-dxcustomrenderer")
	dgsSetType(cr,"dgs-dxcustomrenderer")
	if customFnc then
		dgsCustomRendererSetFunction(cr,customFnc)
	else
		dgsSetData(cr,"customRenderer",function() return false end)
	end
	if width and width > 0 and height and height > 0 then
		local crRenderTarget,err = dgsCreateRenderTarget(width,height,true,cr,sRes)
		if crRenderTarget then
			dgsAttachToAutoDestroy(crRenderTarget,cr,-1)
		else
			outputDebugString(err,2)
		end
		dgsSetData(cr,"renderTarget",crRenderTarget)
		dgsSetData(cr,"renderTargetResolution",{width,height})
	else
		dgsSetData(cr,"renderTargetResolution",{0,0})
	end
	dgsTriggerEvent("onDgsCreate",cr,sRes)
	return cr
end

function dgsCustomRendererSetrenderTargetResolution(cr,width,height)
	if dgsGetType(cr) ~= "dgs-dxcustomrenderer" then error(dgsGenAsrt(cr,"dgsCustomRendererSetrenderTargetResolution",1,"dgs-dxcustomrenderer")) end
	if not(not width or type(width) == "number") then error(dgsGenAsrt(width,"dgsCustomRendererSetrenderTargetResolution",2,"number/nil")) end
	if not(not height or type(height) == "number") then error(dgsGenAsrt(height,"dgsCustomRendererSetrenderTargetResolution",3,"number/nil")) end
	local eleData = dgsElementData[cr]
	if eleData.renderTargetResolution[1] ~= width or eleData.renderTargetResolution[2] ~= height then
		if isElement(eleData.renderTarget) then destroyElement(eleData.renderTarget) end
		if not width or width == 0 or not height or height == 0 then
			local crRenderTarget,err = dgsCreateRenderTarget(width,height,true,cr,sourceResource)
			if crRenderTarget then
				dgsAttachToAutoDestroy(crRenderTarget,cr,-1)
			else
				outputDebugString(err,2)
			end
			dgsSetData(cr,"renderTarget",crRenderTarget)
			dgsSetData(cr,"renderTargetResolution",{width,height})
		else
			dgsSetData(cr,"renderTarget",nil)
			dgsSetData(cr,"renderTargetResolution",{0,0})
		end
	end
	return true
end

function dgsCustomRendererGetrenderTargetResolution(cr)
	if dgsGetType(cr) ~= "dgs-dxcustomrenderer" then error(dgsGenAsrt(cr,"dgsCustomRendererGetrenderTargetResolution",1,"dgs-dxcustomrenderer")) end
	return dgsElementData[cr].renderTargetResolution[1],dgsElementData[cr].renderTargetResolution[2]
end

function dgsCustomRendererGetRenderTarget(cr)
	if dgsGetType(cr) ~= "dgs-dxcustomrenderer" then error(dgsGenAsrt(cr,"dgsCustomRendererGetRenderTarget",1,"dgs-dxcustomrenderer")) end
	return dgsElementData[cr].renderTarget
end

function dgsCustomRendererSetFunction(cr,fncStr)
	if dgsGetType(cr) ~= "dgs-dxcustomrenderer" then error(dgsGenAsrt(cr,"dgsCustomRendererSetFunction",1,"dgs-dxcustomrenderer")) end
	local fncType = type(fncStr)
	if fncType == "function" then
		return dgsSetData(cr,"customRenderer",fncStr)
	else
		if not (type(fncStr) == "string") then error(dgsGenAsrt(fncStr,"dgsCustomRendererSetFunction",2,"string")) end
		fncStr = [[posX,posY,width,height,self,rotation,rotationCenterOffsetX,rotationCenterOffsetY,color,postGUI = ...
		]]..fncStr
		local fnc,err = loadstring(fncStr)
		if not fnc then error(dgsGenAsrt(fnc,"dgsCustomRendererSetFunction",2,_,_,_,"Failed to load function:"..err)) end
		return dgsSetData(cr,"customRenderer",fnc)
	end
end

function dgsCustomRendererSetBackEndFunction(cr,fncStr)
	if dgsGetType(cr) ~= "dgs-dxcustomrenderer" then error(dgsGenAsrt(cr,"dgsCustomRendererSetBackEndFunction",1,"dgs-dxcustomrenderer")) end
	local fncType = type(fncStr)
	if fncType == "function" then
		return dgsSetData(cr,"customRendererBackEnd",fncStr)
	else
		if not (type(fncStr) == "string") then error(dgsGenAsrt(fncStr,"dgsCustomRendererSetBackEndFunction",2,"string")) end
		fncStr = [[self = ...]]..fncStr
		local fnc,err = loadstring(fncStr)
		if not fnc then error(dgsGenAsrt(fnc,"dgsCustomRendererSetBackEndFunction",2,_,_,_,"Failed to load function:"..err)) end
		return dgsSetData(cr,"customRendererBackEnd",fnc)
	end
end

dgsCustomTexture["dgs-dxcustomrenderer"] = function(posX,posY,width,height,u,v,usize,vsize,image,rotation,rotationX,rotationY,color,postGUI)
	return dgsElementData[image].customRenderer(posX,posY,width,height,image,rotation,rotationX,rotationY,color,postGUI)
end

dgsBackEndRenderer:register("dgs-dxcustomrenderer",function(image)
	if dgsElementData[image].customRendererBackEnd then
		return dgsElementData[image].customRendererBackEnd(image)
	end
end)