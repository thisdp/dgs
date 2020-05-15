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
local min = math.min
local max = math.max
--
function dgsCreateSwitchButton(x,y,sx,sy,textOn,textOff,state,relative,parent,textColorOn,textColorOff,scalex,scaley)
	assert(tonumber(x),"Bad argument @dgsCreateSwitchButton at argument 1, expect number got "..type(x))
	assert(tonumber(y),"Bad argument @dgsCreateSwitchButton at argument 2, expect number got "..type(y))
	assert(tonumber(sx),"Bad argument @dgsCreateSwitchButton at argument 3, expect number got "..type(sx))
	assert(tonumber(sy),"Bad argument @dgsCreateSwitchButton at argument 4, expect number got "..type(sy))
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"Bad argument @dgsCreateSwitchButton at argument 9, expect dgs-dxgui got "..dgsGetType(parent))
	end
	local switchbutton = createElement("dgs-dxswitchbutton")
	local _x = dgsIsDxElement(parent) and dgsSetParent(switchbutton,parent,true,true) or table.insert(CenterFatherTable,switchbutton)
	dgsSetType(switchbutton,"dgs-dxswitchbutton")
	dgsSetData(switchbutton,"renderBuffer",{})

	dgsSetData(switchbutton,"colorOn",styleSettings.switchbutton.colorOn)
	dgsSetData(switchbutton,"colorOff",styleSettings.switchbutton.colorOff)
	dgsSetData(switchbutton,"cursorColor",styleSettings.switchbutton.cursorColor)
	
	local imageOn = styleSettings.switchbutton.imageOn
	local imageNormalOn = dgsCreateTextureFromStyle(imageOn[1])
	local imageHoverOn = dgsCreateTextureFromStyle(imageOn[2])
	local imageClickOn = dgsCreateTextureFromStyle(imageOn[3])
	dgsSetData(switchbutton,"imageOn",{imageNormalOn,imageHoverOn,imageClickOn})
	
	local imageOff = styleSettings.switchbutton.imageOff
	local imageNormalOff = dgsCreateTextureFromStyle(imageOff[1])
	local imageHoverOff = dgsCreateTextureFromStyle(imageOff[2])
	local imageClickOff = dgsCreateTextureFromStyle(imageOff[3])
	dgsSetData(switchbutton,"imageOff",{imageNormalOff,imageHoverOff,imageClickOff})
	
	local cursorImage = styleSettings.switchbutton.cursorImage
	local cursorNormal = dgsCreateTextureFromStyle(cursorImage[1])
	local cursorHover = dgsCreateTextureFromStyle(cursorImage[2])
	local cursorClick = dgsCreateTextureFromStyle(cursorImage[3])
	dgsSetData(switchbutton,"cursorImage",{cursorNormal,cursorHover,cursorClick})
	
	dgsAttachToTranslation(switchbutton,resourceTranslation[sourceResource or getThisResource()])
	if type(textOn) == "table" then
		dgsElementData[switchbutton]._translationtextOn = textOn
		textOn = dgsTranslate(switchbutton,textOn,sourceResource)
	end
	if type(textOff) == "table" then
		dgsElementData[switchbutton]._translationtextOff = textOff
		textOff = dgsTranslate(switchbutton,textOff,sourceResource)
	end
	dgsSetData(switchbutton,"textOn",tostring(textOn))
	dgsSetData(switchbutton,"textOff",tostring(textOff))
	dgsSetData(switchbutton,"textColorOn",tonumber(textColorOn) or styleSettings.switchbutton.textColorOn)
	dgsSetData(switchbutton,"textColorOff",tonumber(textColorOff) or styleSettings.switchbutton.textColorOff)
	
	local textSizeX,textSizeY = tonumber(scalex) or styleSettings.switchbutton.textSize[1], tonumber(scaley) or styleSettings.switchbutton.textSize[2]
	dgsSetData(switchbutton,"textSize",{textSizeX,textSizeY})
	dgsSetData(switchbutton,"shadow",{_,_,_})
	dgsSetData(switchbutton,"font",styleSettings.switchbutton.font or systemFont)
	dgsSetData(switchbutton,"textOffset",{0.25,true})
	dgsSetData(switchbutton,"state",state and true or false)
	dgsSetData(switchbutton,"cursorMoveSpeed",0.2)
	dgsSetData(switchbutton,"stateAnim",state and 1 or -1)
	dgsSetData(switchbutton,"clickButton","left")	--"left":LMB;"middle":Wheel;"right":RMB
	dgsSetData(switchbutton,"clickState","up")	--"down":Down;"up":Up
	dgsSetData(switchbutton,"cursorWidth",styleSettings.switchbutton.cursorWidth)
	dgsSetData(switchbutton,"clip",false)
	dgsSetData(switchbutton,"wordbreak",false)
	dgsSetData(switchbutton,"colorcoded",false)
	dgsSetData(switchbutton,"style",1)	--default
	calculateGuiPositionSize(switchbutton,x,y,relative or false,sx,sy,relative or false,true)
	triggerEvent("onDgsCreate",switchbutton,sourceResource)
	return switchbutton
end

function dgsSwitchButtonGetState(switchbutton)
	assert(dgsGetType(switchbutton) == "dgs-dxswitchbutton","Bad argument @dgsSwitchButtonGetState at argument at 1, expect dgs-dxswitchbutton got "..dgsGetType(switchbutton))
	return dgsElementData[switchbutton].state
end

function dgsSwitchButtonSetState(switchbutton,state)
	assert(dgsGetType(switchbutton) == "dgs-dxswitchbutton","Bad argument @dgsSwitchButtonSetState at argument at 1, expect dgs-dxswitchbutton got "..dgsGetType(switchbutton))
	return dgsSetData(switchbutton,"state",state and true or false)
end

function dgsSwitchButtonSetText(switchbutton,textOn,textOff)
	assert(dgsGetType(switchbutton) == "dgs-dxswitchbutton","Bad argument @dgsSwitchButtonSetText at argument at 1, expect dgs-dxswitchbutton got "..dgsGetType(switchbutton))
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
	assert(dgsGetType(switchbutton) == "dgs-dxswitchbutton","Bad argument @dgsSwitchButtonGetText at argument at 1, expect dgs-dxswitchbutton got "..dgsGetType(switchbutton))
	return dgsElementData[switchbutton].textOn,dgsElementData[switchbutton].textOff
end

----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxswitchbutton"] = function(source,x,y,w,h,mx,my,cx,cy,enabled,eleData,parentAlpha,isPostGUI,rndtgt)
	local imageOff,imageOn = eleData.imageOff,eleData.imageOn
	local colorOff,colorOn = eleData.colorOff,eleData.colorOn
	local textColor,text
	local xAdd = eleData.textOffset[2] and w*eleData.textOffset[1] or eleData.textOffset[1]
	if eleData.state then
		textColor,text,xAdd = eleData.textColorOn,eleData.textOn,-xAdd
	else 
		textColor,text = eleData.textColorOff,eleData.textOff
	end
	local style = eleData.style
	local colorImgBgID = 1
	local colorImgID = 1
	local cursorWidth = eleData.cursorWidth[2] and w*eleData.cursorWidth[1] or eleData.cursorWidth[1]
	local animProgress = (eleData.stateAnim+1)*0.5
	local cursorX = x+animProgress*(w-cursorWidth)
	if MouseData.enter == v then
		local isHitCursor = mx >= cursorX and mx <= cursorX+cursorWidth
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
	if not enabled[1] and not enabled[2] then
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
		local color = colorOff[colorImgID]+(colorOn[colorImgID]-colorOff[colorImgID])*animProgress
		if not enabled[1] and not enabled[2] then
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
		if animProgress == 0 then
			local _empty = imageOff[colorImgBgID] and dxDrawImage(x,y,w,h,imageOff[colorImgBgID],0,0,0,color,isPostGUI) or dxDrawRectangle(x,y,w,h,color,isPostGUI)
		elseif animProgress == 1 then
			local _empty = imageOn[colorImgBgID] and dxDrawImage(x,y,w,h,imageOn[colorImgBgID],0,0,0,color,isPostGUI) or dxDrawRectangle(x,y,w,h,color,isPostGUI)
		else
			local offColor = applyColorAlpha(color,1-animProgress)
			local onColor = applyColorAlpha(color,animProgress)
			local _empty = imageOff[colorImgBgID] and dxDrawImage(x,y,w,h,imageOff[colorImgBgID],0,0,0,offColor,isPostGUI) or dxDrawRectangle(x,y,w,h,offColor,isPostGUI)
			local _empty = imageOn[colorImgBgID] and dxDrawImage(x,y,w,h,imageOn[colorImgBgID],0,0,0,onColor,isPostGUI) or dxDrawRectangle(x,y,w,h,onColor,isPostGUI)
		end
	elseif style == 1 then
		local colorOn = colorOn[colorImgID]
		local colorOff = colorOff[colorImgID]
		if not enabled[1] and not enabled[2] then
			if type(eleData.disabledColor) == "number" then
				colorOn = applyColorAlpha(eleData.disabledColor,parentAlpha)
				colorOff = applyColorAlpha(eleData.disabledColor,parentAlpha)
			elseif eleData.disabledColor == true then
				local r,g,b,a = fromcolor(colorOn,true)
				local average = (r+g+b)/3*eleData.disabledColorPercent
				colorOn = tocolor(average,average,average,a*parentAlpha)
				local r,g,b,a = fromcolor(colorOff,true)
				local average = (r+g+b)/3*eleData.disabledColorPercent
				colorOff = tocolor(average,average,average,a*parentAlpha)
			end
		else
			colorOn = applyColorAlpha(colorOn,parentAlpha)
			colorOff = applyColorAlpha(colorOff,parentAlpha)
		end
		local _empty = imageOff[colorImgBgID] and dxDrawImage(x,y,cursorX-x+cursorWidth/2,h,imageOff[colorImgBgID],0,0,0,colorOff,isPostGUI) or dxDrawRectangle(x,y,cursorX-x+cursorWidth/2,h,colorOff,isPostGUI)
		local _empty = imageOn[colorImgBgID] and dxDrawImage(cursorX+cursorWidth/2,y,w-(cursorX-x+cursorWidth/2),h,imageOn[colorImgBgID],0,0,0,colorOn,isPostGUI) or dxDrawRectangle(cursorX+cursorWidth/2,y,w-(cursorX-x+cursorWidth/2),h,colorOn,isPostGUI)
	end
	local font = eleData.font or systemFont
	local txtSizX,txtSizY = eleData.textSize[1],eleData.textSize[2] or eleData.textSize[1]
	local clip = eleData.clip
	local wordbreak = eleData.wordbreak
	local colorcoded = eleData.colorcoded
	local shadow = eleData.shadow
	local textX,textY,textWX,textHY = x+w*0.5+xAdd-cursorWidth,y,x+w*0.5+xAdd+cursorWidth,y+h
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
		dxDrawImage(cursorX,y,cursorWidth,h,cursorImage,0,0,0,cursorColor,isPostGUI)
	else
		dxDrawRectangle(cursorX,y,cursorWidth,h,cursorColor,isPostGUI)
	end
	
	local state = eleData.state and 1 or -1
	if eleData.stateAnim ~= state then
		local stat = eleData.stateAnim+state*eleData.cursorMoveSpeed
		eleData.stateAnim = state == -1 and max(stat,state) or min(stat,state)
	end
	------------------------------------
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
dgsOOP["dgs-dxswitchbutton"] = [[
	setState = dgsOOP.genOOPFnc("dgsSwitchButtonSetState",true),
	getState = dgsOOP.genOOPFnc("dgsSwitchButtonGetState"),
	setText = dgsOOP.genOOPFnc("dgsSwitchButtonSetText",true),
	getText = dgsOOP.genOOPFnc("dgsSwitchButtonGetText"),
]]