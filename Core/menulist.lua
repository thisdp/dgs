dgsLogLuaMemory()
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
--
local dgsTriggerEvent = dgsTriggerEvent
local createElement = createElement
local dgsSetType = dgsSetType
local dgsSetParent = dgsSetParent
local dgsSetData = dgsSetData
local dgsAttachToTranslation = dgsAttachToTranslation
local calculateGuiPositionSize = calculateGuiPositionSize
local assert = assert
local type = type
--
function dgsCreateMenuList(x,y,sx,sy,data,relative,parent)
	local sRes = sourceResource or resource
	local xCheck,yCheck,wCheck,hCheck = type (x) == "number",type(y) == "number",type(sx) == "number",type(sy) == "number"
	if not xCheck then assert(false,"Bad argument @dgsCreateMenuList at argument 1, expect number got "..type(x)) end
	if not yCheck then assert(false,"Bad argument @dgsCreateMenuList at argument 2, expect number got "..type(y)) end
	if not wCheck then assert(false,"Bad argument @dgsCreateMenuList at argument 3, expect number got "..type(sx)) end
	if not hCheck then assert(false,"Bad argument @dgsCreateMenuList at argument 4, expect number got "..type(sy)) end
	local menulist = createElement("dgs-dxmenulist")
	dgsSetType(menulist,"dgs-dxmenulist")
	dgsSetParent(menulist,parent,true,true)
	calculateGuiPositionSize(menulist,x,y,relative,sx,sy,relative,true)
	onDGSElementCreate(menulist,sRes)
	return menulist
end