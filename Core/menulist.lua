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
function dgsCreateMenuList(x,y,sx,sy,data,relative,parent)
	assert(type(x) == "number","Bad argument @dgsCreateMenuList at argument 1, expect number got "..type(x))
	assert(type(y) == "number","Bad argument @dgsCreateMenuList at argument 2, expect number got "..type(y))
	assert(type(sx) == "number","Bad argument @dgsCreateMenuList at argument 3, expect number got "..type(sx))
	assert(type(sy) == "number","Bad argument @dgsCreateMenuList at argument 4, expect number got "..type(sy))
	local menulist = createElement("dgs-dxmenulist")
	dgsSetParent(menulist,parent,true,true)
	dgsSetType(menulist,"dgs-dxmenulist")
	calculateGuiPositionSize(menulist,x,y,relative,sx,sy,relative,true)
	triggerEvent("onDgsCreate",menulist,sourceResource)
	return menulist
end