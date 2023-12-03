dgsLogLuaMemory()
dgsRegisterType("dgs-dxeffectview","dgsBasic","dgsType2D")
dgsRegisterProperties("dgs-dxeffectview",{

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

function dgsCreateEffectView(...)
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
	if not(type(x) == "number") then error(dgsGenAsrt(x,"dgsCreateEffectView",1,"number")) end
	if not(type(y) == "number") then error(dgsGenAsrt(y,"dgsCreateEffectView",2,"number")) end
	if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsCreateEffectView",3,"number")) end
	if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsCreateEffectView",4,"number")) end
	local effectview = createElement("dgs-dxeffectview")
	dgsSetType(effectview,"dgs-dxeffectview")
	
	--[[
	local res = sRes ~= resource and sRes or "global"
	local style = styleManager.styles[res]
	local using = style.using
	style = style.loaded[using]
	
	local systemFont = style.systemFontElement

	style = style.effectview
	]]

	dgsElementData[effectview] = {
        color = tocolor(255,255,255,255),
	}
	dgsSetParent(effectview,parent,true,true)

	calculateGuiPositionSize(effectview,x,y,relative,w,h,relative,true)
	dgsApplyGeneralProperties(effectview,sRes)

	onDGSElementCreate(effectview,sRes)
	dgsEffectViewRecreateRenderTarget(effectview,true)
	return effectview
end

function dgsEffectViewRecreateRenderTarget(effectview)
	local eleData = dgsElementData[effectview]
	if isElement(eleData.mainRT) then destroyElement(eleData.mainRT) end
	dgsSetData(effectview,"mainRT",nil)
	if lateAlloc then
		dgsSetData(effectview,"retrieveRT",true)
	else
		local res = eleData.resource
		local mainRT
		local w,h = eleData.absSize[1],eleData.absSize[2]
		if w ~= 0 and h ~= 0 then
			mainRT,err = dgsCreateRenderTarget(w,h,true,effectview)
			if mainRT ~= false then
				dgsAttachToAutoDestroy(mainRT,effectview,-1)
			else
				outputDebugString(err,2)
			end
		end
		dgsSetData(effectview,"mainRT",mainRT)
		dgsSetData(effectview,"retrieveRT",nil)
	end
end

function dgsEffectViewSetEffectShader(effectview,effect)
	if not dgsIsType(effectview,"dgs-dxeffectview") then error(dgsGenAsrt(effectview,"dgsEffectViewSetEffectShader",1,"dgs-dxeffectview")) end
	local eleData = dgsElementData[effectview]
	if effect then
		if not isElement(effect) or getElementType(effect) ~= "shader" then error(dgsGenAsrt(effect,"dgsEffectViewSetEffectShader",2,"shader")) end
		eleData.effect = effect
	else
		eleData.effect = nil
	end
end

function configEffectView(effectview)
	local eleData = dgsElementData[effectview]
	dgsEffectViewRecreateRenderTarget(effectview,true)
	eleData.configNextFrame = false
end
----------------------------------------------------------------
-----------------------VisibilityManage-------------------------
----------------------------------------------------------------
dgsOnVisibilityChange["dgs-dxeffectview"] = function(dgsElement,selfVisibility,inheritVisibility)
	if not selfVisibility or not inheritVisibility then
		dgsEffectViewRecreateRenderTarget(dgsElement,true)
	end
end
----------------------------------------------------------------
-----------------------PropertyListener-------------------------
----------------------------------------------------------------


----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxeffectview"] = function(source,x,y,w,h,mx,my,cx,cy,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt)
	if eleData.configNextFrame then
		configEffectView(source)
	end
	local color = applyColorAlpha(eleData.color,parentAlpha)

	--[[
	local style = styleManager.styles[eleData.resource or "global"]
	style = style.loaded[style.using]
	local systemFont = style.systemFontElement
	]]
	
	local newRndTgt = eleData.mainRT
	local drawTarget
	if newRndTgt then
		local effect = eleData.effect
		drawTarget = newRndTgt
		if effect then
			if type(effect) == "table" and isElement(effect[1]) then
				if eleData.sourceTexture ~= newRndTgt then
					dxSetShaderValue(effect[1],"sourceTexture",newRndTgt)
					eleData.sourceTexture = newRndTgt
				end
				dxSetShaderTransform(effect[1],effect[2],effect[3],effect[4],effect[5],effect[6],effect[7],effect[8],effect[9],effect[10],effect[11])
				drawTarget = effect[1]
			elseif isElement(effect) then
				if eleData.sourceTexture ~= newRndTgt then
					dxSetShaderValue(effect,"sourceTexture",newRndTgt)
					dxSetShaderValue(effect,"textureLoad",true)
					eleData.sourceTexture = newRndTgt
				end
				drawTarget = effect
			end
		else
			eleData.sourceTexture = false
		end
	end
	dxSetRenderTarget(newRndTgt,true)
	local children = eleData.children
	if not eleData.childOutsideHit then
		if MouseData.hit ~= source then
			enabledInherited = false
		end
	end

	dxSetBlendMode("add")
	for i=1, #children do
		local child = children[i]
		renderGUI(child,mx,my,enabledInherited,enabledSelf,newRndTgt,x,y,cx,cy,0,0,parentAlpha,visible)
	end

	dxSetRenderTarget(rndtgt)
	if drawTarget then
		dxDrawImage(x,y,w,h,drawTarget,0,0,0,white,isPostGUI)
	end
	dxSetBlendMode(rndtgt and "modulate_add" or "blend")
	return rndtgt,false,mx,my
end

----------------------------------------------------------------
-------------------------Children Renderer----------------------
----------------------------------------------------------------
dgsChildRenderer["dgs-dxeffectview"] = false	--Disable children renderer