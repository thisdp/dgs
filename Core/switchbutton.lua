--Dx Functions
local dxDrawImage = dxDrawImageExt
local dxDrawText = dxDrawText
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
local triggerEvent = triggerEvent
local createElement = createElement
local assert = assert
local tonumber = tonumber
local tostring = tostring
local tocolor = tocolor
local type = type
local mathMin = math.min
local mathMax = math.max

function dgsCreateSwitchButton(...)
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
	dgsSetParent(switchbutton,parent,true,true)
	local style = styleSettings.switchbutton
	local imageOff = style.imageOff
	local norimg_o,hovimg_o,cliimg_o = dgsCreateTextureFromStyle(imageOff[1]),dgsCreateTextureFromStyle(imageOff[2]),dgsCreateTextureFromStyle(imageOff[3])
	local imageOn = style.imageOn
	local norimg_f,hovimg_f,cliimg_f = dgsCreateTextureFromStyle(imageOn[1]),dgsCreateTextureFromStyle(imageOn[2]),dgsCreateTextureFromStyle(imageOn[3])
	local cursorImage = style.cursorImage
	local norimg_c,hovimg_c,cliimg_c = dgsCreateTextureFromStyle(cursorImage[1]),dgsCreateTextureFromStyle(cursorImage[2]),dgsCreateTextureFromStyle(cursorImage[3])
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
		shadow = {nil,nil,nil},
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
		wordbreak = false,
		colorcoded = false,
		style = 1,
		isReverse = false,
	}
	dgsAttachToTranslation(switchbutton,resourceTranslation[sourceResource or resource])
	if type(textOn) == "table" then
		dgsElementData[switchbutton]._translationtextOn = textOn
		textOn = dgsTranslate(switchbutton,textOn,sourceResource)
	end
	if type(textOff) == "table" then
		dgsElementData[switchbutton]._translationtextOff = textOff
		textOff = dgsTranslate(switchbutton,textOff,sourceResource)
	end
	dgsElementData[switchbutton].textOn = tostring(textOn)
	dgsElementData[switchbutton].textOff = tostring(textOff)
	calculateGuiPositionSize(switchbutton,x,y,relative or false,w,h,relative or false,true)
	triggerEvent("onDgsCreate",switchbutton,sourceResource)
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
		dgsElementData[switchbutton]._translationtextOn = textOn
		textOn = dgsTranslate(switchbutton,textOn,sourceResource)
	else
		dgsElementData[switchbutton]._translationtextOn = nil
	end
	if type(textOff) == "table" then
		dgsElementData[switchbutton]._translationtextOff = textOff
		textOff = dgsTranslate(switchbutton,textOff,sourceResource)
	else
		dgsElementData[switchbutton]._translationtextOff = nil
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
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxswitchbutton"] = function(source,x,y,w,h,mx,my,cx,cy,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt)
	local imageOn,imageOff = eleData.imageOn,eleData.imageOff
	local colorOn,colorOff = eleData.colorOn,eleData.colorOff
	local isReverse = eleData.isReverse and true or false
	local textColor,text
	local xAdd = eleData.textOffset[2] and w*eleData.textOffset[1] or eleData.textOffset[1]
	if eleData.state ~= isReverse then
		textColor,text,xAdd = eleData.textColorOn,eleData.textOn,(isReverse and -1 or 1)*xAdd
	else
		textColor,text,xAdd = eleData.textColorOff,eleData.textOff,(isReverse and 1 or -1)*xAdd
	end
	local style = eleData.style
	local colorImgBgID = 1
	local colorImgID = 1
	local cursorLength = eleData.cursorLength[2] and w*eleData.cursorLength[1] or eleData.cursorLength[1]
	local cursorWidth = eleData.cursorWidth[2] and h*eleData.cursorWidth[1] or eleData.cursorWidth[1]
	local troughWidth = eleData.troughWidth[2] and h*eleData.troughWidth[1] or eleData.troughWidth[1]
	local animProgress = (-eleData.stateAnim+1)*0.5
	local cursorX,cursorY,cursorW,cursorH = x+animProgress*(w-cursorLength),y+h/2-cursorWidth/2,cursorLength,cursorWidth
	if MouseData.entered == v then
		local isHitCursor = mx >= cursorX and mx <= cursorX+cursorLength
		colorImgBgID = 2
		if isHitCursor then
			colorImgID = 2
		end
		if eleData.clickType == 1 and MouseData.clickl == v then
			colorImgBgID = 3
			colorImgID = isHitCursor and 3 or colorImgID
		elseif eleData.clickType == 2 and MouseData.clickr == v then
			colorImgBgID = 3
			colorImgID = isHitCursor and 3 or colorImgID
		else
			if MouseData.clickl == v or MouseData.clickr == v then
				colorImgBgID = 3
				colorImgID = isHitCursor and 3 or colorImgID
			end
		end
	end
	local cursorImage = eleData.cursorImage[colorImgID]
	local cursorColor = eleData.cursorColor[colorImgID]
	if not enabledInherited and not enabledSelf then
		if type(eleData.disabledColor) == "number" then
			color = applyColorAlpha(eleData.disabledColor,parentAlpha)
		elseif eleData.disabledColor == true then
			local r,g,b,a = fromcolor(cursorColor,true)
			local average = (r+g+b)/3*eleData.disabledColorPercent
			cursorColor = tocolor(average,average,average,a*parentAlpha)
		end
	else
		cursorColor = applyColorAlpha(cursorColor,parentAlpha)
	end
	if not style then
		local color = colorOn[colorImgID]+(colorOff[colorImgID]-colorOn[colorImgID])*animProgress
		if not enabledInherited and not enabledSelf then
			if type(eleData.disabledColor) == "number" then
				color = applyColorAlpha(eleData.disabledColor,parentAlpha)
			elseif eleData.disabledColor == true then
				local r,g,b,a = fromcolor(color,true)
				local average = (r+g+b)/3*eleData.disabledColorPercent
				color = tocolor(average,average,average,a*parentAlpha)
			end
		else
			color = applyColorAlpha(color,parentAlpha)
		end
		local xOn,yOn,wOn,hOn = x,y,w,h
		yOn = yOn+hOn/2-troughWidth/2 -- todo
		hOn = troughWidth
		if animProgress == 0 then
			local _empty = imageOn[colorImgBgID] and dxDrawImage(xOn,yOn,wOn,hOn,imageOn[colorImgBgID],0,0,0,colorOn[colorImgID],isPostGUI,rndtgt) or dxDrawRectangle(xOn,yOn,wOn,hOn,colorOn[colorImgID],isPostGUI)
		elseif animProgress == 1 then
			local _empty = imageOff[colorImgBgID] and dxDrawImage(xOn,yOn,wOn,hOn,imageOff[colorImgBgID],0,0,0,colorOff[colorImgID],isPostGUI,rndtgt) or dxDrawRectangle(xOn,yOn,wOn,hOn,colorOff[colorImgID],isPostGUI)
		else
			local offColor = applyColorAlpha(colorOff[colorImgID],animProgress)
			local onColor = applyColorAlpha(colorOn[colorImgID],1-animProgress)
			local _empty = imageOn[colorImgBgID] and dxDrawImage(xOn,yOn,wOn,hOn,imageOn[colorImgBgID],0,0,0,onColor,isPostGUI,rndtgt) or dxDrawRectangle(xOn,yOn,wOn,hOn,onColor,isPostGUI)
			local _empty = imageOff[colorImgBgID] and dxDrawImage(xOn,yOn,wOn,hOn,imageOff[colorImgBgID],0,0,0,offColor,isPostGUI,rndtgt) or dxDrawRectangle(xOn,yOn,wOn,hOn,offColor,isPostGUI)
		end
	elseif style == 1 then
		local colorOff = colorOff[colorImgID]
		local colorOn = colorOn[colorImgID]
		if not enabledInherited and not enabledSelf then
			if type(eleData.disabledColor) == "number" then
				colorOff = applyColorAlpha(eleData.disabledColor,parentAlpha)
				colorOn = applyColorAlpha(eleData.disabledColor,parentAlpha)
			elseif eleData.disabledColor == true then
				local r,g,b,a = fromcolor(colorOff,true)
				local average = (r+g+b)/3*eleData.disabledColorPercent
				colorOff = tocolor(average,average,average,a*parentAlpha)
				local r,g,b,a = fromcolor(colorOn,true)
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
		local _empty = imageOn[colorImgBgID] and dxDrawImage(xOn,yOn,wOn,hOn,imageOn[colorImgBgID],0,0,0,colorOn,isPostGUI,rndtgt) or dxDrawRectangle(xOn,yOn,wOn,hOn,colorOn,isPostGUI)
		local _empty = imageOff[colorImgBgID] and dxDrawImage(xOff,yOff,wOff,hOff,imageOff[colorImgBgID],0,0,0,colorOff,isPostGUI,rndtgt) or dxDrawRectangle(xOff,yOff,wOff,hOff,colorOff,isPostGUI)
	elseif style == 2 then
		local colorOff = colorOff[colorImgID]
		local colorOn = colorOn[colorImgID]
		if not enabledInherited and not enabledSelf then
			if type(eleData.disabledColor) == "number" then
				colorOff = applyColorAlpha(eleData.disabledColor,parentAlpha)
				colorOn = applyColorAlpha(eleData.disabledColor,parentAlpha)
			elseif eleData.disabledColor == true then
				local r,g,b,a = fromcolor(colorOff,true)
				local average = (r+g+b)/3*eleData.disabledColorPercent
				colorOff = tocolor(average,average,average,a*parentAlpha)
				local r,g,b,a = fromcolor(colorOn,true)
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
		if imageOn[colorImgBgID] then
			local onMaterialX,onMaterialY = dxGetMaterialSize(imageOn[colorImgBgID])
			dxDrawImageSection(xOn,yOn,wOn,hOn,(xOn-x)/w*onMaterialX,0,wOn/w*onMaterialX,onMaterialY,imageOn[colorImgBgID],0,0,0,colorOn,isPostGUI,rndtgt)
		else
			dxDrawRectangle(xOn,yOn,wOn,hOn,colorOn,isPostGUI)
		end
		if imageOff[colorImgBgID] then
			local offMaterialX,offMaterialY = dxGetMaterialSize(imageOff[colorImgBgID])
			dxDrawImageSection(xOff,yOff,wOff,hOff,(xOff-x)/w*offMaterialX,0,wOff/w*offMaterialX,offMaterialY,imageOff[colorImgBgID],0,0,0,colorOff,isPostGUI,rndtgt)
		else
			dxDrawRectangle(xOff,yOff,wOff,hOff,colorOff,isPostGUI)
		end
	end
	local font = eleData.font or systemFont
	local txtSizX,txtSizY = eleData.textSize[1],eleData.textSize[2] or eleData.textSize[1]
	local clip = eleData.clip
	local wordbreak = eleData.wordbreak
	local colorcoded = eleData.colorcoded
	local shadow = eleData.shadow
	local textX,textY,textWX,textHY = x+w*0.5+xAdd-cursorLength,y,x+w*0.5+xAdd+cursorLength,y+h
	if shadow then
		local shadowoffx,shadowoffy,shadowc,shadowIsOutline = shadow[1],shadow[2],shadow[3],shadow[4]
		if shadowoffx and shadowoffy and shadowc then
			local shadowc = applyColorAlpha(shadowc,parentAlpha)
			local shadowText = colorcoded and text:gsub('#%x%x%x%x%x%x','') or text
			dxDrawText(shadowText,textX+shadowoffx,textY+shadowoffy,textWX+shadowoffx,textHY+shadowoffy,shadowc,txtSizX,txtSizY,font,"center","center",clip,wordbreak,isPostGUI)
			if shadowIsOutline then
				dxDrawText(shadowText,textX-shadowoffx,textY+shadowoffy,textWX-shadowoffx,textHY+shadowoffy,shadowc,txtSizX,txtSizY,font,"center","center",clip,wordbreak,isPostGUI)
				dxDrawText(shadowText,textX-shadowoffx,textY-shadowoffy,textWX-shadowoffx,textHY-shadowoffy,shadowc,txtSizX,txtSizY,font,"center","center",clip,wordbreak,isPostGUI)
				dxDrawText(shadowText,textX+shadowoffx,textY-shadowoffy,textWX+shadowoffx,textHY-shadowoffy,shadowc,txtSizX,txtSizY,font,"center","center",clip,wordbreak,isPostGUI)
			end
		end
	end
	dxDrawText(text,textX,textY,textWX,textHY,applyColorAlpha(textColor,parentAlpha),txtSizX,txtSizY,font,"center","center",clip,wordbreak,isPostGUI,colorcoded)
	----Cursor
	if cursorImage then
		dxDrawImage(cursorX,cursorY,cursorW,cursorH,cursorImage,0,0,0,cursorColor,isPostGUI,rndtgt)
	else
		dxDrawRectangle(cursorX,cursorY,cursorW,cursorH,cursorColor,isPostGUI)
	end

	local state = eleData.state and 1 or -1
	if eleData.stateAnim ~= state then
		local stat = eleData.stateAnim+state*eleData.cursorMoveSpeed
		eleData.stateAnim = state == -1 and mathMax(stat,state) or mathMin(stat,state)
	end
	------------------------------------
	return rndtgt,false,mx,my,0,0
end