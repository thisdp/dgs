function dgsCreateBlurTextEffect(label,offsetx,offsety,level,intensity,brightness)
	local w,h = dgsGetSize(label)
	local customRenderer = dgsCreateCustomRenderer([[
	if dgsElementData[self].renderTarget then
		local pLabel = dgsElementData[self].parentLabel
		local textSize = dgsElementData[pLabel].textSize
		local font = dgsElementData[pLabel].font
		local textColor = dgsElementData[pLabel].textColor
		local text = dgsElementData[pLabel].text
		local align = dgsElementData[pLabel].alignment
		local rotation = dgsElementData[pLabel].rotation
		local rotationCenter = dgsElementData[pLabel].rotationCenter
		local subPixelPos = dgsElementData[pLabel].subPixelPositioning
		local textOffset = dgsElementData[pLabel].textOffset
		local clip = dgsElementData[pLabel].clip
		local colorCoded = dgsElementData[pLabel].colorCoded
		local wordBreak = dgsElementData[pLabel].wordBreak
		local offsetx,offsety = 0,0
		if textOffset then
			offsetx,offsety = textOffset[1],textOffset[2]
		end
		dxSetRenderTarget(dgsElementData[self].renderTarget,true)
		local rtSize = dgsElementData[self].renderTargetResolution
		print(text)
		dxDrawText(text,0,0,rtSize[1],rtSize[2],textColor,textSize[1],textSize[2],font,align[1],align[2],
			clip,wordBreak,false,colorCoded,subPixelPos,rotation,
			offsetx+rotationCenter[1],offsety+rotationCenter[2],0)
		dxSetRenderTarget()
	end
	]],w,h,true)	--Create a custom renderer that draws text
	local blurbox = dgsCreateBlurBox(400,160,dgsGetProperty(customRenderer,"renderTarget"),level)	--Create Blur Box that takes render target from custom renderer as source texture
	dgsBlurBoxSetBrightness(blurbox,brightness)
	dgsBlurBoxSetIntensity(blurbox,intensity)
	
	dgsSetProperty(customRenderer,"parentLabel",label)
	dgsSetProperty(label,"blurBox",blurbox)
	dgsSetProperty(label,"blurEffect",customRenderer)
	addEventHandler("onDgsSizeChange",label,function()
		local w,h = dgsGetSize(source)
		dgsCustomRendererSetRenderTargetResolution(customRenderer,w,h)
		dgsBlurBoxSetResolution(blurbox,w,h)
	end,false)
	dgsSetProperty(label,"functionRunBefore",true)
	dgsSetProperty(label,"functions",[[
		local cr = dgsElementData[self].blurEffect
		local bb = dgsElementData[self].blurBox
		dxDrawImage(renderArguments[1],renderArguments[2],renderArguments[3],renderArguments[4],cr)
		dxDrawImage(renderArguments[1],renderArguments[2],renderArguments[3],renderArguments[4],bb)
	]])
	dgsAttachToAutoDestroy(customRenderer,label)
	dgsAttachToAutoDestroy(blurbox,label)
	return blurbox
end