local loadstring = loadstring
--Dx Functions
local dxDrawLine = dxDrawLine
local dxDrawImage = dxDrawImageExt
local dxDrawImageSection = dxDrawImageSectionExt
local dxDrawText = dxDrawText
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
local triggerEvent = triggerEvent
local createElement = createElement
--
--This is a special dgs element that won't be rendered itself.
--This dgs element is usually used for plugins
--Note: There will be nothing if you use this dgs element as a child element or a parent element
function dgsCreateCustomRenderer(customFnc)
	local cr = createElement("dgs-dxcustomrenderer")
	dgsSetType(cr,"dgs-dxcustomrenderer")
	if customFnc then
		dgsCustomRendererSetFunction(cr,customFnc)
	else
		dgsSetData(cr,"customRenderer",function() return false end)
	end
	triggerEvent("onDgsCreate",cr,sourceResource)
	return cr
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