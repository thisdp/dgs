--Dx Functions
local dxDrawImage = dxDrawImageExt
local dxDrawImageSection = dxDrawImageSectionExt
local dxDrawText = dxDrawText
local dxDrawRectangle = dxDrawRectangle
--
--CheckBox State : true->checked; false->unchecked; nil->indeterminate;
function dgsCreateCheckBox(x,y,sx,sy,text,state,relative,parent,textColor,scalex,scaley,norimg_f,hovimg_f,cliimg_f,norcolor_f,hovcolor_f,clicolor_f,norimg_t,hovimg_t,cliimg_t,norcolor_t,hovcolor_t,clicolor_t,norimg_i,hovimg_i,cliimg_i,norcolor_i,hovcolor_i,clicolor_i)
	assert(tonumber(x),"Bad argument @dgsCreateCheckBox at argument 1, expect number got "..type(x))
	assert(tonumber(y),"Bad argument @dgsCreateCheckBox at argument 2, expect number got "..type(y))
	assert(tonumber(sx),"Bad argument @dgsCreateCheckBox at argument 3, expect number got "..type(sx))
	assert(tonumber(sy),"Bad argument @dgsCreateCheckBox at argument 4, expect number got "..type(sy))
	assert(tonumber(sy),"Bad argument @dgsCreateCheckBox at argument 4, expect number got "..type(sy))
	assert(not state or state == true,"@dgsCreateCheckBox at argument 6, expect boolean/nil got "..type(state))
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"Bad argument @dgsCreateCheckBox at argument 8,expect dgs-dxgui got "..dgsGetType(parent))
	end
	local cb = createElement("dgs-dxcheckbox")
	local _x = dgsIsDxElement(parent) and dgsSetParent(cb,parent,true,true) or table.insert(CenterFatherTable,cb)
	dgsSetType(cb,"dgs-dxcheckbox")
	dgsSetData(cb,"renderBuffer",{})
	
	local imageUnchecked = styleSettings.checkbox.image_f
	norimg_f = norimg_f or dgsCreateTextureFromStyle(imageUnchecked[1])
	hovimg_f = hovimg_f or dgsCreateTextureFromStyle(imageUnchecked[2])
	cliimg_f = cliimg_f or dgsCreateTextureFromStyle(imageUnchecked[3])
	dgsSetData(cb,"image_f",{norimg_f,hovimg_f,cliimg_f})
	local colorUnchecked = styleSettings.checkbox.color_f
	norcolor_f = norcolor_f or colorUnchecked[1]
	hovcolor_f = hovcolor_f or colorUnchecked[2]
	clicolor_f = clicolor_f or colorUnchecked[3]
	dgsSetData(cb,"color_f",{norcolor_f,hovcolor_f,clicolor_f})
	
	local imageChecked = styleSettings.checkbox.image_t
	norimg_t = norimg_t or dgsCreateTextureFromStyle(imageChecked[1])
	hovimg_t = hovimg_t or dgsCreateTextureFromStyle(imageChecked[2])
	cliimg_t = cliimg_t or dgsCreateTextureFromStyle(imageChecked[3])
	dgsSetData(cb,"image_t",{norimg_t,hovimg_t,cliimg_t})
	local colorChecked = styleSettings.checkbox.color_t
	norcolor_t = norcolor_t or colorChecked[1]
	hovcolor_t = hovcolor_t or colorChecked[2]
	clicolor_t = clicolor_t or colorChecked[3]
	dgsSetData(cb,"color_t",{norcolor_t,hovcolor_t,clicolor_t})
	
	local imageIndeterminate = styleSettings.checkbox.image_i
	norimg_i = norimg_i or dgsCreateTextureFromStyle(imageIndeterminate[1])
	hovimg_i = hovimg_i or dgsCreateTextureFromStyle(imageIndeterminate[2])
	cliimg_i = cliimg_i or dgsCreateTextureFromStyle(imageIndeterminate[3])
	dgsSetData(cb,"image_i",{norimg_i,hovimg_i,cliimg_i})
	local colorIndeterminate = styleSettings.checkbox.color_i
	norcolor_i = norcolor_i or colorIndeterminate[1]
	hovcolor_i = hovcolor_i or colorIndeterminate[2]
	clicolor_i = clicolor_i or colorIndeterminate[3]
	dgsSetData(cb,"color_i",{norcolor_i,hovcolor_i,clicolor_i})
	
	dgsSetData(cb,"cbParent",dgsIsDxElement(parent) and parent or resourceRoot)
	dgsAttachToTranslation(cb,resourceTranslation[sourceResource or getThisResource()])
	if type(text) == "table" then
		dgsElementData[cb]._translationText = text
		dgsSetData(cb,"text",text)
	else
		dgsSetData(cb,"text",tostring(text))
	end
	dgsSetData(cb,"textColor",textColor or styleSettings.checkbox.textColor)
	local textSizeX,textSizeY = tonumber(scalex) or styleSettings.checkbox.textSize[1], tonumber(scaley) or styleSettings.checkbox.textSize[2]
	dgsSetData(cb,"textSize",{textSizeX,textSizeY})
	dgsSetData(cb,"textPadding",styleSettings.checkbox.textPadding or {2,false})
	dgsSetData(cb,"buttonSize",styleSettings.checkbox.buttonSize)
	dgsSetData(cb,"shadow",{_,_,_})
	dgsSetData(cb,"font",styleSettings.checkbox.font or systemFont)
	dgsSetData(cb,"clip",false)
	dgsSetData(cb,"wordbreak",false)
	dgsSetData(cb,"colorcoded",false)
	dgsSetData(cb,"state",state)
	dgsSetData(cb,"alignment",{"left","center"})
	calculateGuiPositionSize(cb,x,y,relative or false,sx,sy,relative or false,true)
	triggerEvent("onDgsCreate",cb,sourceResource)
	return cb
end

function dgsCheckBoxGetSelected(cb)
	assert(dgsGetType(cb) == "dgs-dxcheckbox","Bad argument @dgsCheckBoxGetSelected at argument 1,expect dgs-dxcheckbox got "..dgsGetType(cb))
	return dgsElementData[cb].state
end

function dgsCheckBoxSetSelected(cb,state)
	assert(dgsGetType(cb) == "dgs-dxcheckbox","Bad argument @dgsCheckBoxSetSelected at argument 1,expect dgs-dxcheckbox got "..dgsGetType(cb))
	assert(not state or state == true,"Bad argument @dgsCheckBoxSetSelected at argument 2,expect boolean/nil got "..type(state))
	local oldState = dgsElementData[cb].state
	if state ~= oldState then
		triggerEvent("onDgsCheckBoxChange",cb,state,oldState)
	end
	return true
end

function dgsCheckBoxSetHorizontalAlign(checkbox,align)
	assert(dgsGetType(checkbox) == "dgs-dxcheckbox","Bad argument @dgsCheckBoxSetHorizontalAlign at argument 1, except a dgs-dxcheckbox got "..dgsGetType(checkbox))
	assert(HorizontalAlign[align],"Bad argument @dgsCheckBoxSetHorizontalAlign at argument 2, except a string [left/center/right], got"..tostring(align))
	local alignment = dgsElementData[checkbox].alignment
	return dgsSetData(checkbox,"alignment",{align,alignment[2]})
end

function dgsCheckBoxSetVerticalAlign(checkbox,align)
	assert(dgsGetType(checkbox) == "dgs-dxcheckbox","Bad argument @dgsCheckBoxSetVerticalAlign at argument 1, except a dgs-dxcheckbox got "..dgsGetType(checkbox))
	assert(VerticalAlign[align],"Bad argument @dgsCheckBoxSetVerticalAlign at argument 2, except a string [top/center/bottom], got"..tostring(align))
	local alignment = dgsElementData[checkbox].alignment
	return dgsSetData(checkbox,"alignment",{alignment[1],align})
end

function dgsCheckBoxGetHorizontalAlign(checkbox)
	assert(dgsGetType(checkbox) == "dgs-dxcheckbox","Bad argument @dgsCheckBoxGetHorizontalAlign at argument 1, except a dgs-dxcheckbox got "..dgsGetType(checkbox))
	local alignment = dgsElementData[checkbox].alignment
	return alignment[1]
end

function dgsCheckBoxGetVerticalAlign(checkbox)
	assert(dgsGetType(checkbox) == "dgs-dxcheckbox","Bad argument @dgsCheckBoxGetVerticalAlign at argument 1, except a dgs-dxcheckbox got "..dgsGetType(checkbox))
	local alignment = dgsElementData[checkbox].alignment
	return alignment[2]
end

addEventHandler("onDgsCheckBoxChange",resourceRoot,function(state)
	if not wasEventCancelled() then
		dgsSetData(source,"state",state)
	end
end)

----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxcheckbox"] = function(source,x,y,w,h,mx,my,cx,cy,enabled,eleData,parentAlpha,isPostGUI,rndtgt)
	local image_f,image_t,image_i = eleData.image_f,eleData.image_t,eleData.image_i
	local color_f,color_t,color_i = eleData.color_f,eleData.color_t,eleData.color_i
	local image,color
	local _buttonSize = eleData.buttonSize
	local buttonSizeX,buttonSizeY
	if tonumber(_buttonSize[2]) then
		buttonSizeX = _buttonSize[3] and _buttonSize[1]*w or _buttonSize[1]
		buttonSizeY = _buttonSize[3] and _buttonSize[2]*h or _buttonSize[2]
	else
		buttonSizeX = _buttonSize[2] and _buttonSize[1]*h or _buttonSize[1]
		buttonSizeY = buttonSizeX
	end
	if eleData.state == true then
		image,color = image_t,color_t
	elseif eleData.state == false then 
		image,color = image_f,color_f
	else
		image,color = image_i,color_i
	end
	local colorimgid = 1
	if MouseData.enter == source then
		colorimgid = 2
		if eleData.clickType == 1 then
			if MouseData.clickl == source then
				colorimgid = 3
			end
		elseif eleData.clickType == 2 then
			if MouseData.clickr == source then
				colorimgid = 3
			end
		else
			if MouseData.clickl == source or MouseData.clickr == source then
				colorimgid = 3
			end
		end
	end
	local finalcolor
	if not enabled[1] and not enabled[2] then
		if type(eleData.disabledColor) == "number" then
			finalcolor = applyColorAlpha(eleData.disabledColor,parentAlpha)
		elseif eleData.disabledColor == true then
			local r,g,b,a = fromcolor(color[1],true)
			local average = (r+g+b)/3*eleData.disabledColorPercent
			finalcolor = tocolor(average,average,average,a*parentAlpha)
		else
			finalcolor = color[colorimgid]
		end
	else
		finalcolor = applyColorAlpha(color[colorimgid],parentAlpha)
	end
	if image[colorimgid] then
		dxDrawImage(x,y+h*0.5-buttonSizeY*0.5,buttonSizeX,buttonSizeY,image[colorimgid],0,0,0,finalcolor,isPostGUI)
	else
		dxDrawRectangle(x,y+h*0.5-buttonSizeY*0.5,buttonSizeX,buttonSizeY,finalcolor,isPostGUI)
	end
	local font = eleData.font or systemFont
	local txtSizX,txtSizY = eleData.textSize[1],eleData.textSize[2] or eleData.textSize[1]
	local clip = eleData.clip
	local wordbreak = eleData.wordbreak
	local _textPadding = eleData.textPadding
	local textPadding = _textPadding[2] and _textPadding[1]*w or _textPadding[1]
	local text = eleData.text
	local colorcoded = eleData.colorcoded
	local alignment = eleData.alignment
	local px = x+buttonSizeX+textPadding
	if eleData.PixelInt then px = px-px%1 end
	local shadow = eleData.shadow
	if shadow then
		local shadowoffx,shadowoffy,shadowc,shadowIsOutline = shadow[1],shadow[2],shadow[3],shadow[4]
		local textX,textY = px,y
		if shadowoffx and shadowoffy and shadowc then
			local shadowc = applyColorAlpha(shadowc,parentAlpha)
			local shadowText = colorcoded and text:gsub('#%x%x%x%x%x%x','') or text
			dxDrawText(shadowText,textX+shadowoffx,textY+shadowoffy,textX+w+shadowoffx,textY+h+shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,isPostGUI)
			if shadowIsOutline then
				dxDrawText(shadowText,textX-shadowoffx,textY+shadowoffy,textX+w-shadowoffx,textY+h+shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,isPostGUI)
				dxDrawText(shadowText,textX-shadowoffx,textY-shadowoffy,textX+w-shadowoffx,textY+h-shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,isPostGUI)
				dxDrawText(shadowText,textX+shadowoffx,textY-shadowoffy,textX+w+shadowoffx,textY+h-shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,isPostGUI)
			end
		end
	end
	dxDrawText(text,px,y,px+w-1,y+h-1,applyColorAlpha(eleData.textColor,parentAlpha),txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,isPostGUI,colorcoded)
	if enabled[1] and mx then
		if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
			MouseData.hit = source
		end
	end
	return rndtgt
end
----------------------------------------------------------------
-------------------------OOP Class------------------------------
----------------------------------------------------------------
dgsOOP["dgs-dxcheckbox"] = [[
	getSelected = dgsOOP.genOOPFnc("dgsCheckBoxGetSelected"),
	setSelected = dgsOOP.genOOPFnc("dgsCheckBoxSetSelected",true),
	getHorizontalAlign = dgsOOP.genOOPFnc("dgsCheckBoxGetHorizontalAlign"),
	setHorizontalAlign = dgsOOP.genOOPFnc("dgsCheckBoxSetHorizontalAlign",true),
	getVerticalAlign = dgsOOP.genOOPFnc("dgsCheckBoxGetVerticalAlign"),
	setVerticalAlign = dgsOOP.genOOPFnc("dgsCheckBoxSetVerticalAlign",true),
]]