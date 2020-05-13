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
	assert(dgsGetType(cr) == "dgs-dxcustomrenderer","Bad argument @dgsCustomRendererSetFunction at argument 1, expected a dgs-dxcustomrenderer got "..dgsGetType(cr))
	local fncType = type(fncStr)
	if fncType == "function" then
		return dgsSetData(cr,"customRenderer",fncStr)
	else
		assert(type(fncStr) == "string","Bad argument @dgsCustomRendererSetFunction at argument 2, expected a string got "..dgsGetType(fncStr))
		fncStr = [[posX,posY,width,height,self,rotation,rotationCenterOffsetX,rotationCenterOffsetY,color,postGUI = ...
		]]..fncStr
		local fnc = loadstring(fncStr)
		assert(fnc,"Bad argument @dgsCustomRendererSetFunction at argument 2, failed to load function")
		return dgsSetData(cr,"customRenderer",fnc)
	end
end

----------------------------------------------------------------
-------------------------OOP Class------------------------------
----------------------------------------------------------------
dgsOOP["dgs-dxcustomrenderer"] = [[
	setFunction = dgsOOP.genOOPFnc("dgsCustomRendererSetFunction",true),
]]