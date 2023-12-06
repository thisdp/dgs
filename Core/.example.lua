dgsLogLuaMemory()
dgsRegisterType("dgs-dxexample","dgsBasic","dgsType2D")
dgsRegisterProperties("dgs-dxexample",{

})

--Dx Functions
local dxDrawImage = dxDrawImage
local dgsDrawText = dgsDrawText
local dxDrawRectangle = dxDrawRectangle
--
local dgsTriggerEvent = dgsTriggerEvent
local isElement = isElement
local createElement = createElement
local addEventHandler = addEventHandler
local dgsSetType = dgsSetType
local dgsSetParent = dgsSetParent
local dgsSetData = dgsSetData
local dgsAttachToTranslation = dgsAttachToTranslation
local dgsTranslate = dgsTranslate
local calculateGuiPositionSize = calculateGuiPositionSize
local tonumber = tonumber
local assert = assert
local type = type
local applyColorAlpha = applyColorAlpha

function dgsCreateExample(...)
	local sRes = sourceResource or resource
	local x,y,w,h,relative,parent
	if select("#",...) == 1 and type(select(1,...)) == "table" then
		local argTable = ...
		x = argTable.x or argTable[1]
		y = argTable.y or argTable[2]
		w = argTable.width or argTable.w or argTable[3]
		h = argTable.height or argTable.h or argTable[4]
		relative = argTable.relative or argTable.rlt or argTable[5]
		parent = argTable.parent or argTable[6]
	else
		x,y,w,h,relative,parent = ...
	end
	if not(type(x) == "number") then error(dgsGenAsrt(x,"dgsCreateExample",1,"number")) end
	if not(type(y) == "number") then error(dgsGenAsrt(y,"dgsCreateExample",2,"number")) end
	if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsCreateExample",3,"number")) end
	if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsCreateExample",4,"number")) end
	local example = createElement("dgs-dxexample")
	dgsSetType(example,"dgs-dxexample")
	
	local res = sRes ~= resource and sRes or "global"
	local style = styleManager.styles[res]
	local using = style.using
	style = style.loaded[using]
	
	local systemFont = style.systemFontElement

	style = style.example
	dgsElementData[example] = {
        
	}
	dgsSetParent(example,parent,true,true)

	calculateGuiPositionSize(example,x,y,relative,w,h,relative,true)
	dgsApplyGeneralProperties(example,sRes)

	onDGSElementCreate(example,sRes)
	return example
end

----------------------------------------------------------------
-----------------------PropertyListener-------------------------
----------------------------------------------------------------


----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxexample"] = function(source,x,y,w,h,mx,my,cx,cy,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt)
	local color = applyColorAlpha(eleData.color,parentAlpha)

	local style = styleManager.styles[eleData.resource or "global"]
	style = style.loaded[style.using]
	local systemFont = style.systemFontElement


	
	return rndtgt,false,mx,my,0
end