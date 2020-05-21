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
function dgsCreateSelector(x,y,sx,sy,relative,parent,textColor,scalex,scaley,shadowoffsetx,shadowoffsety,shadowcolor)
	assert(tonumber(x),"Bad argument @dgsCreateSelector at argument 1, expect number got "..type(x))
	assert(tonumber(y),"Bad argument @dgsCreateSelector at argument 2, expect number got "..type(y))
	assert(tonumber(sx),"Bad argument @dgsCreateSelector at argument 3, expect number got "..type(sx))
	assert(tonumber(sy),"Bad argument @dgsCreateSelector at argument 4, expect number got "..type(sy))
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"Bad argument @dgsCreateLabel at argument 7, expect dgs-dxgui got "..dgsGetType(parent))
	end
	local selector = createElement("dgs-dxselector")
	local _ = dgsIsDxElement(parent) and dgsSetParent(selector,parent,true,true) or table.insert(CenterFatherTable,selector)
	dgsSetType(selector,"dgs-dxselector")
	dgsSetData(selector,"textColor",textColor or styleSettings.selector.textColor)
	dgsAttachToTranslation(selector,resourceTranslation[sourceResource or getThisResource()])
	if type(text) == "table" then
		dgsElementData[selector]._translationText = text
		dgsSetData(selector,"text",text)
	else
		dgsSetData(selector,"text",tostring(text))
	end
	local textSizeX,textSizeY = tonumber(scalex) or styleSettings.selector.textSize[1], tonumber(scaley) or styleSettings.selector.textSize[2]
	dgsSetData(selector,"textSize",{textSizeX,textSizeY})
	dgsSetData(selector,"clip",false)
	dgsSetData(selector,"selectorText",{"<",">"})
	dgsSetData(selector,"selectorImage",{_,_,_})
	dgsSetData(selector,"selectorColor",{tocolor()})
	dgsSetData(selector,"colorcoded",false)
	dgsSetData(selector,"subPixelPositioning",false)
	dgsSetData(selector,"shadow",{shadowoffsetx,shadowoffsety,shadowcolor})
	dgsSetData(selector,"font",styleSettings.selector.font or systemFont)
	calculateGuiPositionSize(selector,x,y,relative or false,sx,sy,relative or false,true)
	triggerEvent("onDgsCreate",selector,sourceResource)
	return selector
end

function dgsSelectorAddItem(selector,text)
	
end

----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxselector"] = function(x,y,w,h,eleData,parentAlpha,isPostGUI)
	if x and y then
		if eleData.PixelInt then
			x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
		end
		------------------------------------
		if eleData.functionRunBefore then
			local fnc = eleData.functions
			if type(fnc) == "table" then
				fnc[1](unpack(fnc[2]))
			end
		end
		------------------------------------
		dxDrawText()
		------------------------------------OutLine
		local outlineData = eleData.outline
		if outlineData then
			local sideColor = outlineData[3]
			local sideSize = outlineData[2]
			local hSideSize = sideSize*0.5
			sideColor = applyColorAlpha(sideColor,parentAlpha)
			local side = outlineData[1]
			if side == "in" then
				dxDrawLine(x,y+hSideSize,x+w,y+hSideSize,sideColor,sideSize,isPostGUI)
				dxDrawLine(x+hSideSize,y,x+hSideSize,y+h,sideColor,sideSize,isPostGUI)
				dxDrawLine(x+w-hSideSize,y,x+w-hSideSize,y+h,sideColor,sideSize,isPostGUI)
				dxDrawLine(x,y+h-hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,isPostGUI)
			elseif side == "center" then
				dxDrawLine(x-hSideSize,y,x+w+hSideSize,y,sideColor,sideSize,isPostGUI)
				dxDrawLine(x,y+hSideSize,x,y+h-hSideSize,sideColor,sideSize,isPostGUI)
				dxDrawLine(x+w,y+hSideSize,x+w,y+h-hSideSize,sideColor,sideSize,isPostGUI)
				dxDrawLine(x-hSideSize,y+h,x+w+hSideSize,y+h,sideColor,sideSize,isPostGUI)
			elseif side == "out" then
				dxDrawLine(x-sideSize,y-hSideSize,x+w+sideSize,y-hSideSize,sideColor,sideSize,isPostGUI)
				dxDrawLine(x-hSideSize,y,x-hSideSize,y+h,sideColor,sideSize,isPostGUI)
				dxDrawLine(x+w+hSideSize,y,x+w+hSideSize,y+h,sideColor,sideSize,isPostGUI)
				dxDrawLine(x-sideSize,y+h+hSideSize,x+w+sideSize,y+h+hSideSize,sideColor,sideSize,isPostGUI)
			end
		end
		------------------------------------
		if not eleData.functionRunBefore then
			local fnc = eleData.functions
			if type(fnc) == "table" then
				fnc[1](unpack(fnc[2]))
			end
		end
		------------------------------------
		if enabled[1] and mx then
			if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
				MouseData.hit = v
			end
		end
	else
		visible = false
	end
end
----------------------------------------------------------------
-------------------------OOP Class------------------------------
----------------------------------------------------------------
dgsOOP["dgs-dxselector"] = [[
	setColor = dgsOOP.genOOPFnc("dgsLabelSetColor",true),
	getColor = dgsOOP.genOOPFnc("dgsLabelGetColor"),
	setHorizontalAlign = dgsOOP.genOOPFnc("dgsLabelSetHorizontalAlign",true),
	getHorizontalAlign = dgsOOP.genOOPFnc("dgsLabelGetHorizontalAlign"),
	setVerticalAlign = dgsOOP.genOOPFnc("dgsLabelSetVerticalAlign",true),
	getVerticalAlign = dgsOOP.genOOPFnc("dgsLabelGetVerticalAlign"),
	getTextExtent = dgsOOP.genOOPFnc("dgsLabelGetTextExtent"),
	getFontHeight = dgsOOP.genOOPFnc("dgsLabelGetFontHeight"),
]]