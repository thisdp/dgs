--Dx Functions
local dxDrawImage = dxDrawImageExt
local dxDrawImageSection = dxDrawImageSectionExt
local dxDrawRectangle = dxDrawRectangle
local dxGetMaterialSize = dxGetMaterialSize
local dxCreateTexture = dxCreateTexture
--DGS Functions
local dgsSetType = dgsSetType
local dgsGetType = dgsGetType
local dgsSetParent = dgsSetParent
local dgsSetData = dgsSetData
local applyColorAlpha = applyColorAlpha
local dgsAttachToAutoDestroy = dgsAttachToAutoDestroy
local calculateGuiPositionSize = calculateGuiPositionSize
--Utilities
local isElement = isElement
local getElementType = getElementType
local triggerEvent = triggerEvent
local createElement = createElement
local assert = assert
local tonumber = tonumber
local type = type

function dgsCreateScalePane(...)
	local x,y,w,h,resX,resY,relative,parent
	if select("#",...) == 1 and type(select(1,...)) == "table" then
		local argTable = ...
		x = argTable.x or argTable[1]
		y = argTable.y or argTable[2]
		w = argTable.width or argTable.w or argTable[3]
		h = argTable.height or argTable.h or argTable[4]
		relative = argTable.relative or argTable.rlt or argTable[5]
		parent = argTable.parent or argTable.p or argTable[6]
		resX = argTable.resolutionX or argTable.resX or argTable[7]
		resY = argTable.resolutionY or argTable.resY or argTable[8]
	else
		x,y,w,h,relative,parent,resX,resY = ...
	end
	if not(type(x) == "number") then error(dgsGenAsrt(x,"dgsCreateScalePane",1,"number")) end
	if not(type(y) == "number") then error(dgsGenAsrt(y,"dgsCreateScalePane",2,"number")) end
	if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsCreateScalePane",3,"number")) end
	if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsCreateScalePane",4,"number")) end
	if not(type(resX) == "number") then error(dgsGenAsrt(resX,"dgsCreateScalePane",7,"number")) end
	if not(type(resY) == "number") then error(dgsGenAsrt(resY,"dgsCreateScalePane",8,"number")) end
	local scalepane = createElement("dgs-dxscalepane")
	dgsSetType(scalepane,"dgs-dxscalepane")
	dgsSetParent(scalepane,parent,true,true)
	dgsElementData[scalepane] = {
	
	}
	
	calculateGuiPositionSize(scalepane,x,y,relative or false,w,h,relative or false,true)
	triggerEvent("onDgsCreate",scalepane,sourceResource)
	return scalepane
end

----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxscalepane"] = function(source,x,y,w,h,mx,my,cx,cy,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt)
	
	return rndtgt
end