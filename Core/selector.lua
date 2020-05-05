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