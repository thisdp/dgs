dgsLogLuaMemory()
dgsRegisterType("dgs-dxswitchbutton","dgsBasic","dgsType2D")
dgsRegisterProperties("dgs-dxswitchbutton",{
	clickType = 		{	PArg.Number	},
	clip = 				{	PArg.Bool	},
	cursorColor = 		{	{ PArg.Color, PArg.Color, PArg.Color }	},
	cursorImage = 		{	{ PArg.Material+PArg.Nil, PArg.Material+PArg.Nil, PArg.Material+PArg.Nil }	},
	cursorLength = 		{	{ PArg.Number, PArg.Bool }	},
	cursorMoveSpeed = 	{	PArg.Number	},
	cursorWidth = 		{	{ PArg.Number, PArg.Bool }	},
	colorCoded = 		{	PArg.Number	},
	colorOff = 			{	{ PArg.Color, PArg.Color, PArg.Color }	},
	colorOn = 			{	{ PArg.Color, PArg.Color, PArg.Color }	},
	font = 				{	PArg.Font+PArg.String	},
	imageOff = 			{	{ PArg.Material+PArg.Nil, PArg.Material+PArg.Nil, PArg.Material+PArg.Nil }	},
	imageOn = 			{	{ PArg.Material+PArg.Nil, PArg.Material+PArg.Nil, PArg.Material+PArg.Nil }	},
	shadow = 			{	{ PArg.Number, PArg.Number, PArg.Color, PArg.Number+PArg.Bool+PArg.Nil, PArg.Font+PArg.Nil }, PArg.Nil	},
	state = 			{	PArg.Bool	},
	style = 			{	PArg.Number	},
	textColorOff = 		{	PArg.Color	},
	textColorOn = 		{	PArg.Color	},
	textOff = 			{	PArg.Text	},
	textOffset = 		{	{ PArg.Number, PArg.Bool }	},
	textOn = 			{	PArg.Text	},
	textSize = 			{	{ PArg.Number, PArg.Number }	},
	troughWidth = 		{	{ PArg.Number, PArg.Bool }	},
	wordBreak = 		{	PArg.Bool	},
})
--Dx Functions
local dxDrawImage = dxDrawImage
local dxDrawImageSection = dxDrawImageSection
local dgsDrawText = dgsDrawText
local dxDrawRectangle = dxDrawRectangle
--DGS Functions
local dgsSetType = dgsSetType
local dgsGetType = dgsGetType
local dgsSetParent = dgsSetParent
local dgsSetData = dgsSetData
local applyColorAlpha = applyColorAlpha
local dgsTranslate = dgsTranslate
local dgsAttachToTranslation = dgsAttachToTranslation
local calculateGuiPositionSize = calculateGuiPositionSize
local dgsCreateTextureFromStyle = dgsCreateTextureFromStyle
--Utilities
local dgsTriggerEvent = dgsTriggerEvent
local createElement = createElement
local assert = assert
local tonumber = tonumber
local tostring = tostring
local tocolor = tocolor
local type = type
local mathMin = math.min
local mathMax = math.max

function dgsCreateSwitchButton(...)
	local sRes = sourceResource or resource
	local x,y,w,h,textOn,textOff,state,relative,parent,textColorOn,textColorOff,scaleX,scaleY
	if select("#",...) == 1 and type(select(1,...)) == "table" then
		local argTable = ...
		x = argTable.x or argTable[1]
		y = argTable.y or argTable[2]
		w = argTable.width or argTable.w or argTable[3]
		h = argTable.height or argTable.h or argTable[4]
		textOn = argTable.textOn or argTable[5]
		textOff = argTable.textOff or argTable[6]
		state = argTable.state or argTable[7]
		relative = argTable.relative or argTable.rlt or argTable[8]
		parent = argTable.parent or argTable.p or argTable[9]
		textColorOn = argTable.textColorOn or argTable[10]
		textColorOff = argTable.textColorOff or argTable[11]
		scaleX = argTable.scaleX or argTable[12]
		scaleY = argTable.scaleY or argTable[13]
	else
		x,y,w,h,textOn,textOff,state,relative,parent,textColorOn,textColorOff,scaleX,scaleY = ...
	end
	if not(type(x) == "number") then error(dgsGenAsrt(x,"dgsCreateSwitchButton",1,"number")) end
	if not(type(y) == "number") then error(dgsGenAsrt(y,"dgsCreateSwitchButton",2,"number")) end
	if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsCreateSwitchButton",3,"number")) end
	if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsCreateSwitchButton",4,"number")) end
	local switchbutton = createElement("dgs-dxswitchbutton")
	dgsSetType(switchbutton,"dgs-dxswitchbutton")
	
	local res = sRes ~= resource and sRes or "global"
	local style = styleManager.styles[res]
	local using = style.using
	style = style.loaded[using]
	local systemFont = style.systemFontElement
	
	style = style.switchbutton
	local imageOff = style.imageOff
	local norimg_o = dgsCreateTextureFromStyle(using,res,imageOff[1])
	local hovimg_o = dgsCreateTextureFromStyle(using,res,imageOff[2]) or norimg_o
	local cliimg_o = dgsCreateTextureFromStyle(using,res,imageOff[3]) or norimg_o
	local imageOn = style.imageOn
	local norimg_f = dgsCreateTextureFromStyle(using,res,imageOn[1])
	local hovimg_f = dgsCreateTextureFromStyle(using,res,imageOn[2]) or norimg_f
	local cliimg_f = dgsCreateTextureFromStyle(using,res,imageOn[3]) or norimg_f
	local cursorImage = style.cursorImage
	local norimg_c = dgsCreateTextureFromStyle(using,res,cursorImage[1])
	local hovimg_c = dgsCreateTextureFromStyle(using,res,cursorImage[2]) or norimg_c
	local cliimg_c = dgsCreateTextureFromStyle(using,res,cursorImage[3]) or norimg_c
	local textSizeX,textSizeY = tonumber(scaleX) or style.textSize[1], tonumber(scaleY) or style.textSize[2]
	dgsElementData[switchbutton] = {
		renderBuffer = {};
		colorOff = style.colorOff,
		colorOn = style.colorOn,
		cursorColor = style.cursorColor,
		imageOff = {norimg_o,hovimg_o,cliimg_o},
		imageOn = {norimg_f,hovimg_f,cliimg_f},
		cursorImage = {norimg_c,hovimg_c,cliimg_c},
		textColorOn = tonumber(textColorOn) or style.textColorOn,
		textColorOff = tonumber(textColorOff) or style.textColorOff,
		textSize = {textSizeX,textSizeY},
		shadow = nil,
		font = style.font or systemFont,
		textOffset = {0.25,true},
		state = state and true or false,
		cursorMoveSpeed = 0.2,
		cursorWidth = style.cursorWidth,
		troughWidth = style.troughWidth,
		stateAnim = state and 1 or -1,
		clickButton = "left"; --"left":LMB;"middle":Wheel;"right":RM,
		clickState = "up"; --"down":Down;"up":U,
		cursorLength = style.cursorLength,
		clip = false,
		wordBreak = false,
		colorCoded = false,
		style = 1,
		isReverse = false,
	}
	dgsSetParent(switchbutton,parent,true,true)
	dgsAttachToTranslation(switchbutton,resourceTranslation[sRes])
	if type(textOn) == "table" then
		dgsElementData[switchbutton]._translation_textOn = textOn
		textOn = dgsTranslate(switchbutton,textOn,sRes)
	end
	if type(textOff) == "table" then
		dgsElementData[switchbutton]._translation_textOff = textOff
		textOff = dgsTranslate(switchbutton,textOff,sRes)
	end
	dgsElementData[switchbutton].textOn = tostring(textOn or "")
	dgsElementData[switchbutton].textOff = tostring(textOff or "")
	calculateGuiPositionSize(switchbutton,x,y,relative or false,w,h,relative or false,true)
	onDGSElementCreate(switchbutton,sRes)
	return switchbutton
end

function dgsSwitchButtonGetState(switchbutton)
	if not(dgsGetType(switchbutton) == "dgs-dxswitchbutton") then error(dgsGenAsrt(switchbutton,"dgsSwitchButtonGetState",1,"dgs-dxswitchbutton")) end
	return dgsElementData[switchbutton].state
end

function dgsSwitchButtonSetState(switchbutton,state)
	if not(dgsGetType(switchbutton) == "dgs-dxswitchbutton") then error(dgsGenAsrt(switchbutton,"dgsSwitchButtonSetState",1,"dgs-dxswitchbutton")) end
	return dgsSetData(switchbutton,"state",state and true or false)
end

function dgsSwitchButtonSetText(switchbutton,textOn,textOff)
	if not(dgsGetType(switchbutton) == "dgs-dxswitchbutton") then error(dgsGenAsrt(switchbutton,"dgsSwitchButtonSetText",1,"dgs-dxswitchbutton")) end
	if type(textOn) == "table" then
		dgsElementData[switchbutton]._translation_textOn = textOn
		textOn = dgsTranslate(switchbutton,textOn,sourceResource)
	else
		dgsElementData[switchbutton]._translation_textOn = nil
	end
	if type(textOff) == "table" then
		dgsElementData[switchbutton]._translation_textOff = textOff
		textOff = dgsTranslate(switchbutton,textOff,sourceResource)
	else
		dgsElementData[switchbutton]._translation_textOff = nil
	end
	textOn = textOn or dgsElementData[switchbutton].textOn
	textOff = textOff or dgsElementData[switchbutton].textOff
	dgsSetData(switchbutton,"textOn",tostring(textOn))
	dgsSetData(switchbutton,"textOff",tostring(textOff))
end

function dgsSwitchButtonGetText(switchbutton)
	if not(dgsGetType(switchbutton) == "dgs-dxswitchbutton") then error(dgsGenAsrt(switchbutton,"dgsSwitchButtonGetText",1,"dgs-dxswitchbutton")) end
	return dgsElementData[switchbutton].textOn,dgsElementData[switchbutton].textOff
end


----------------------------------------------------------------
-----------------------PropertyListener-------------------------
----------------------------------------------------------------
dgsOnPropertyChange["dgs-dxswitchbutton"] = {
	state = function(dgsEle,key,value,oldValue)
		dgsTriggerEvent("onDgsSwitchButtonStateChange",dgsEle,value,oldValue)
	end,
}

----------------------------------------------------------------
---------------------Translation Updater------------------------
----------------------------------------------------------------
dgsOnTranslationUpdate["dgs-dxswitchbutton"] = function(dgsEle,key,value)
	local textOn = dgsElementData[dgsEle]._translation_textOn
	local textOff = dgsElementData[dgsEle]._translation_textOff
	if key then textOn[key] = value end
	if key then textOff[key] = value end
	dgsSwitchButtonSetText(dgsEle,textOn,textOff)
	local font = dgsElementData[dgsEle]._translation_font
	if font then
		dgsSetData(dgsEle,"font",font)
	end
end
----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxswitchbutton"] = function(source,x,y,w,h,mx,my,cx,cy,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt)
	local res = eleData.resource or "global"
	local style = styleManager.styles[res]
	local using = style.using
	style = style.loaded[using]
	local systemFont = style.systemFontElement
	
	local font = eleData.font or systemFont
	local txtSizX,txtSizY = eleData.textSize[1],eleData.textSize[2] or eleData.textSize[1]
	local xAdd = eleData.textOffset[2] and w*eleData.textOffset[1] or eleData.textOffset[1]
	local clip = eleData.clip
	local wordBreak = eleData.wordBreak
	local colorCoded = eleData.colorCoded
	local cursorLength = eleData.cursorLength[2] and w*eleData.cursorLength[1] or eleData.cursorLength[1]
	local cursorWidth = eleData.cursorWidth[2] and h*eleData.cursorWidth[1] or eleData.cursorWidth[1]
	local troughWidth = eleData.troughWidth[2] and h*eleData.troughWidth[1] or eleData.troughWidth[1]
	local isReverse = eleData.isReverse and true or false
	local textColor,text
	if eleData.state ~= isReverse then
		textColor,text,xAdd = eleData.textColorOn,eleData.textOn,(isReverse and -1 or 1)*xAdd
	else
		textColor,text,xAdd = eleData.textColorOff,eleData.textOff,(isReverse and 1 or -1)*xAdd
	end
	local textX,textY,textWX,textHY = x+w*0.5+xAdd-cursorLength,y,x+w*0.5+xAdd+cursorLength,y+h
	local shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont
	local shadow = eleData.shadow
	if shadow then
		shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont = shadow[1],shadow[2],shadow[3],shadow[4],shadow[5]
		shadowColor = applyColorAlpha(shadowColor or white,parentAlpha)
	end
	
	local style = eleData.style
	local colorImgBgID = 1
	local colorImgID = 1
	local animProgress = (-eleData.stateAnim+1)*0.5
	local cursorX,cursorY,cursorW,cursorH = x+animProgress*(w-cursorLength),y+h/2-cursorWidth/2,cursorLength,cursorWidth
	if MouseData.entered == source then
		local isHitCursor = mx >= cursorX and mx <= cursorX+cursorLength
		colorImgBgID = 2
		if isHitCursor then
			colorImgID = 2
		end
		if eleData.clickType == 1 and MouseData.click.left == source then
			colorImgBgID = 3
			colorImgID = isHitCursor and 3 or colorImgID
		elseif eleData.clickType == 2 and MouseData.click.right == source then
			colorImgBgID = 3
			colorImgID = isHitCursor and 3 or colorImgID
		elseif MouseData.click.left == source or MouseData.click.right == source then
			colorImgBgID = 3
			colorImgID = isHitCursor and 3 or colorImgID
		end
	end
	local cursorImage = type(eleData.cursorImage) ~= "table" and eleData.cursorImage or (eleData.cursorImage[colorImgID] or eleData.cursorImage[1])
	local cursorColor = type(eleData.cursorColor) ~= "table" and eleData.cursorColor or (eleData.cursorColor[colorImgID] or eleData.cursorColor[1])
	local imageOn = type(eleData.imageOn) ~= "table" and eleData.imageOn or (eleData.imageOn[colorImgID] or eleData.imageOn[1])
	local imageOff = type(eleData.imageOff) ~= "table" and eleData.imageOff or (eleData.imageOff[colorImgID] or eleData.imageOff[1])
	local colorOn = type(eleData.colorOn) ~= "table" and eleData.colorOn or (eleData.colorOn[colorImgID] or eleData.colorOn[1])
	local colorOff = type(eleData.colorOff) ~= "table" and eleData.colorOff or (eleData.colorOff[colorImgID] or eleData.colorOff[1])
	if not enabledInherited and not enabledSelf then
		if type(eleData.disabledColor) == "number" then
			color = applyColorAlpha(eleData.disabledColor,parentAlpha)
		elseif eleData.disabledColor == true then
			local r,g,b,a = fromcolor(cursorColor)
			local average = (r+g+b)/3*eleData.disabledColorPercent
			cursorColor = tocolor(average,average,average,a*parentAlpha)
		end
	else
		cursorColor = applyColorAlpha(cursorColor,parentAlpha)
	end
	if style == 1 then
		if not enabledInherited and not enabledSelf then
			if type(eleData.disabledColor) == "number" then
				colorOff = applyColorAlpha(eleData.disabledColor,parentAlpha)
				colorOn = applyColorAlpha(eleData.disabledColor,parentAlpha)
			elseif eleData.disabledColor == true then
				local r,g,b,a = fromcolor(colorOff)
				local average = (r+g+b)/3*eleData.disabledColorPercent
				colorOff = tocolor(average,average,average,a*parentAlpha)
				local r,g,b,a = fromcolor(colorOn)
				local average = (r+g+b)/3*eleData.disabledColorPercent
				colorOn = tocolor(average,average,average,a*parentAlpha)
			end
		else
			colorOff = applyColorAlpha(colorOff,parentAlpha)
			colorOn = applyColorAlpha(colorOn,parentAlpha)
		end
		local xOff,yOff,wOff,hOff,xOn,yOn,wOn,hOn
		if isReverse then
			xOff,yOff,wOff,hOff = cursorX+cursorLength/2,y,w-(cursorX-x+cursorLength/2),h
			xOn,yOn,wOn,hOn = x,y,cursorX-x+cursorLength/2,h
		else
			xOn,yOn,wOn,hOn = cursorX+cursorLength/2,y,w-(cursorX-x+cursorLength/2),h
			xOff,yOff,wOff,hOff = x,y,cursorX-x+cursorLength/2,h
		end
		yOn = yOn+hOn/2-troughWidth/2
		hOn = troughWidth
		yOff = yOff+hOff/2-troughWidth/2
		hOff = troughWidth
		dxDrawImage(xOn,yOn,wOn,hOn,imageOn,0,0,0,colorOn,isPostGUI,rndtgt)
		dxDrawImage(xOff,yOff,wOff,hOff,imageOff,0,0,0,colorOff,isPostGUI,rndtgt)
		dgsDrawText(text,textX,textY,textWX,textHY,applyColorAlpha(textColor,parentAlpha),txtSizX,txtSizY,font,"center","center",clip,wordBreak,isPostGUI,colorCoded,subPixelPos,0,0,0,0,shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont)
		----Cursor
		dxDrawImage(cursorX,cursorY,cursorW,cursorH,cursorImage,0,0,0,cursorColor,isPostGUI,rndtgt)
	elseif style == 2 then
		if not enabledInherited and not enabledSelf then
			if type(eleData.disabledColor) == "number" then
				colorOff = applyColorAlpha(eleData.disabledColor,parentAlpha)
				colorOn = applyColorAlpha(eleData.disabledColor,parentAlpha)
			elseif eleData.disabledColor == true then
				local r,g,b,a = fromcolor(colorOff)
				local average = (r+g+b)/3*eleData.disabledColorPercent
				colorOff = tocolor(average,average,average,a*parentAlpha)
				local r,g,b,a = fromcolor(colorOn)
				local average = (r+g+b)/3*eleData.disabledColorPercent
				colorOn = tocolor(average,average,average,a*parentAlpha)
			end
		else
			colorOff = applyColorAlpha(colorOff,parentAlpha)
			colorOn = applyColorAlpha(colorOn,parentAlpha)
		end
		
		local xOff,yOff,wOff,hOff,xOn,yOn,wOn,hOn
		if isReverse then
			xOff,yOff,wOff,hOff = cursorX+cursorLength/2,y,w-(cursorX-x+cursorLength/2),h
			xOn,yOn,wOn,hOn = x,y,cursorX-x+cursorLength/2,h
		else
			xOn,yOn,wOn,hOn = cursorX+cursorLength/2,y,w-(cursorX-x+cursorLength/2),h
			xOff,yOff,wOff,hOff = x,y,cursorX-x+cursorLength/2,h
		end
		yOn = yOn+hOn/2-troughWidth/2
		hOn = troughWidth
		yOff = yOff+hOff/2-troughWidth/2
		hOff = troughWidth
		if imageOn then
			local onMaterialX,onMaterialY = dxGetMaterialSize(imageOn)
			dxDrawImageSection(xOn,yOn,wOn,hOn,(xOn-x)/w*onMaterialX,0,wOn/w*onMaterialX,onMaterialY,imageOn,0,0,0,colorOn,isPostGUI,rndtgt)
		else
			dxDrawRectangle(xOn,yOn,wOn,hOn,colorOn,isPostGUI)
		end
		if imageOff then
			local offMaterialX,offMaterialY = dxGetMaterialSize(imageOff)
			dxDrawImageSection(xOff,yOff,wOff,hOff,(xOff-x)/w*offMaterialX,0,wOff/w*offMaterialX,offMaterialY,imageOff,0,0,0,colorOff,isPostGUI,rndtgt)
		else
			dxDrawRectangle(xOff,yOff,wOff,hOff,colorOff,isPostGUI)
		end
		dgsDrawText(text,textX,textY,textWX,textHY,applyColorAlpha(textColor,parentAlpha),txtSizX,txtSizY,font,"center","center",clip,wordBreak,isPostGUI,colorCoded,subPixelPos,0,0,0,0,shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont)
		----Cursor
		dxDrawImage(cursorX,cursorY,cursorW,cursorH,cursorImage,0,0,0,cursorColor,isPostGUI,rndtgt)
	elseif style == 3 then
		local color = colorOn+(colorOff-colorOn)*animProgress
		if not enabledInherited and not enabledSelf then
			if type(eleData.disabledColor) == "number" then
				color = applyColorAlpha(eleData.disabledColor,parentAlpha)
			elseif eleData.disabledColor == true then
				local r,g,b,a = fromcolor(color)
				local average = (r+g+b)/3*eleData.disabledColorPercent
				color = tocolor(average,average,average,a*parentAlpha)
			end
		else
			color = applyColorAlpha(color,parentAlpha)
		end
		local xOn,yOn,wOn,hOn = x,y,w,h
		yOn = yOn+hOn/2-troughWidth/2
		hOn = troughWidth
		if animProgress == 0 then
			colorOn = applyColorAlpha(colorOn,parentAlpha)
			dxDrawImage(xOn,yOn,wOn,hOn,imageOn,0,0,0,colorOn,isPostGUI,rndtgt)
		elseif animProgress == 1 then
			colorOff = applyColorAlpha(colorOff,parentAlpha)
			dxDrawImage(xOn,yOn,wOn,hOn,imageOff,0,0,0,colorOff,isPostGUI,rndtgt)
		else
			colorOff = applyColorAlpha(colorOff,parentAlpha)
			colorOn = applyColorAlpha(colorOn,parentAlpha)
			local offColor = applyColorAlpha(colorOff,animProgress)
			local onColor = applyColorAlpha(colorOn,1-animProgress)
			dxDrawImage(xOn,yOn,wOn,hOn,imageOn,0,0,0,onColor,isPostGUI,rndtgt)
			dxDrawImage(xOn,yOn,wOn,hOn,imageOff,0,0,0,offColor,isPostGUI,rndtgt)
		end
		dgsDrawText(text,textX,textY,textWX,textHY,applyColorAlpha(textColor,parentAlpha),txtSizX,txtSizY,font,"center","center",clip,wordBreak,isPostGUI,colorCoded,subPixelPos,0,0,0,0,shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont)
		----Cursor
		dxDrawImage(cursorX,cursorY,cursorW,cursorH,cursorImage,0,0,0,cursorColor,isPostGUI,rndtgt)
	elseif style == 4 then
		local color = colorOn+(colorOff-colorOn)*animProgress
		if not enabledInherited and not enabledSelf then
			if type(eleData.disabledColor) == "number" then
				color = applyColorAlpha(eleData.disabledColor,parentAlpha)
			elseif eleData.disabledColor == true then
				local r,g,b,a = fromcolor(color)
				local average = (r+g+b)/3*eleData.disabledColorPercent
				color = tocolor(average,average,average,a*parentAlpha)
			end
		else
			color = applyColorAlpha(color,parentAlpha)
		end
		local xOn,yOn,wOn,hOn = x,y,w,h
		yOn = yOn+hOn/2-troughWidth/2
		hOn = troughWidth
		if animProgress == 0 then
			colorOn = applyColorAlpha(colorOn,parentAlpha)
			dxDrawImage(xOn,yOn,wOn,hOn,imageOn,0,0,0,colorOn,isPostGUI,rndtgt)
		elseif animProgress == 1 then
			colorOff = applyColorAlpha(colorOff,parentAlpha)
			dxDrawImage(xOn,yOn,wOn,hOn,imageOff,0,0,0,colorOff,isPostGUI,rndtgt)
		else
			colorOff = applyColorAlpha(colorOff,parentAlpha)
			colorOn = applyColorAlpha(colorOn,parentAlpha)
			local offColor = applyColorAlpha(colorOff,animProgress)
			local onColor = applyColorAlpha(colorOn,1-animProgress)
			dxDrawImage(xOn,yOn,wOn,hOn,imageOn,0,0,0,onColor,isPostGUI,rndtgt)
			dxDrawImage(xOn,yOn,wOn,hOn,imageOff,0,0,0,offColor,isPostGUI,rndtgt)
		end
		dgsDrawText(text,x,y,x+w,y+h,applyColorAlpha(textColor,parentAlpha),txtSizX,txtSizY,font,"center","center",clip,wordBreak,isPostGUI,colorCoded,subPixelPos,0,0,0,0,shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont)
	end
	local state = eleData.state and 1 or -1
	if eleData.stateAnim ~= state then
		local stat = eleData.stateAnim+state*eleData.cursorMoveSpeed
		eleData.stateAnim = state == -1 and mathMax(stat,state) or mathMin(stat,state)
	end
	------------------------------------
	return rndtgt,false,mx,my,0,0
end