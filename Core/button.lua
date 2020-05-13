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

function dgsCreateButton(x,y,sx,sy,text,relative,parent,textColor,scalex,scaley,norimg,selimg,cliimg,norcolor,hovcolor,clicolor)
	assert(tonumber(x),"Bad argument @dgsCreateButton at argument 1, expect number got "..type(x))
	assert(tonumber(y),"Bad argument @dgsCreateButton at argument 2, expect number got "..type(y))
	assert(tonumber(sx),"Bad argument @dgsCreateButton at argument 3, expect number got "..type(sx))
	assert(tonumber(sy),"Bad argument @dgsCreateButton at argument 4, expect number got "..type(sy))
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"Bad argument @dgsCreateButton at argument 7, expect dgs-dxgui got "..dgsGetType(parent))
	end
	local button = createElement("dgs-dxbutton")
	local _x = dgsIsDxElement(parent) and dgsSetParent(button,parent,true,true) or table.insert(CenterFatherTable,button)
	dgsSetType(button,"dgs-dxbutton")
	dgsSetData(button,"renderBuffer",{})
	local norcolor = norcolor or styleSettings.button.color[1]
	local hovcolor = hovcolor or styleSettings.button.color[2]
	local clicolor = clicolor or styleSettings.button.color[3]
	dgsSetData(button,"color",{norcolor,hovcolor,clicolor})
	local norimg = norimg or dgsCreateTextureFromStyle(styleSettings.button.image[1])
	local hovimg = selimg or dgsCreateTextureFromStyle(styleSettings.button.image[2])
	local cliimg = cliimg or dgsCreateTextureFromStyle(styleSettings.button.image[3])
	dgsSetData(button,"image",{norimg,hovimg,cliimg})
	dgsAttachToTranslation(button,resourceTranslation[sourceResource or getThisResource()])
	if type(text) == "table" then
		dgsElementData[button]._translationText = text
		dgsSetData(button,"text",text)
	else
		dgsSetData(button,"text",tostring(text))
	end
	dgsSetData(button,"textColor",tonumber(textColor) or styleSettings.button.textColor)
	local textSizeX,textSizeY = tonumber(scalex) or styleSettings.button.textSize[1], tonumber(scaley) or styleSettings.button.textSize[2]
	dgsSetData(button,"textSize",{textSizeX,textSizeY})
	dgsSetData(button,"shadow",{_,_,_})
	dgsSetData(button,"font",styleSettings.button.font or systemFont)
	dgsSetData(button,"clickoffset",{0,0})
	dgsSetData(button,"textOffset",{0,0,false})
	dgsSetData(button,"clip",false)
	dgsSetData(button,"clickType",1)	--1:LMB;2:Wheel;3:RMB
	dgsSetData(button,"wordbreak",false)
	dgsSetData(button,"colorcoded",false)
	dgsSetData(button,"alignment",{"center","center"})
	calculateGuiPositionSize(button,x,y,relative or false,sx,sy,relative or false,true)
	triggerEvent("onDgsCreate",button,sourceResource)
	return button
end
----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxbutton"] = function(source,x,y,w,h,mx,my,cx,cy,enabled,eleData,parentAlpha,isPostGUI,rndtgt)
	local colors,imgs = eleData.color,eleData.image
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
			local r,g,b,a = fromcolor(colors[1],true)
			local average = (r+g+b)/3*eleData.disabledColorPercent
			finalcolor = tocolor(average,average,average,a*parentAlpha)
		else
			finalcolor = colors[colorimgid]
		end
	else
		finalcolor = applyColorAlpha(colors[colorimgid],parentAlpha)
	end
	------------------------------------
	if eleData.functionRunBefore then
		local fnc = eleData.functions
		if type(fnc) == "table" then
			fnc[1](unpack(fnc[2]))
		end
	end
	------------------------------------
	if imgs[colorimgid] then
		dxDrawImage(x,y,w,h,imgs[colorimgid],0,0,0,finalcolor,isPostGUI)
	else
		dxDrawRectangle(x,y,w,h,finalcolor,isPostGUI)
	end
	local text = eleData.text
	if #text ~= 0 then
		local font = eleData.font or systemFont
		local txtSizX,txtSizY = eleData.textSize[1],eleData.textSize[2] or eleData.textSize[1]
		local clip = eleData.clip
		local wordbreak = eleData.wordbreak
		local colorcoded = eleData.colorcoded
		local alignment = eleData.alignment
		local textOffset = eleData.textOffset
		local txtoffsetsX = textOffset[3] and textOffset[1]*w or textOffset[1]
		local txtoffsetsY = textOffset[3] and textOffset[2]*h or textOffset[2]
		if colorimgid == 3 then
			txtoffsetsX,txtoffsetsY = txtoffsetsX+eleData.clickoffset[1],txtoffsetsY+eleData.clickoffset[2]
		end
		local textX,textY = x+txtoffsetsX,y+txtoffsetsY
		local shadow = eleData.shadow
		if shadow then
			local shadowoffx,shadowoffy,shadowc,shadowIsOutline = shadow[1],shadow[2],shadow[3],shadow[4]
			if shadowoffx and shadowoffy and shadowc then
				local shadowText = colorcoded and text:gsub('#%x%x%x%x%x%x','') or text
				local shadowc = applyColorAlpha(shadowc,parentAlpha)
				dxDrawText(shadowText,textX+shadowoffx,textY+shadowoffy,textX+w+shadowoffx,textY+h+shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,isPostGUI)
				if shadowIsOutline then
					dxDrawText(shadowText,textX-shadowoffx,textY+shadowoffy,textX+w-shadowoffx,textY+h+shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,isPostGUI)
					dxDrawText(shadowText,textX-shadowoffx,textY-shadowoffy,textX+w-shadowoffx,textY+h-shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,isPostGUI)
					dxDrawText(shadowText,textX+shadowoffx,textY-shadowoffy,textX+w+shadowoffx,textY+h-shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,isPostGUI)
				end
			end
		end
		dxDrawText(text,textX,textY,textX+w-1,textY+h-1,applyColorAlpha(eleData.textColor,parentAlpha),txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,isPostGUI,colorcoded)
	end
	if enabled[1] and mx then
		if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
			MouseData.hit = source
		end
	end
	return rndtgt
end