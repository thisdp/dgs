dgsRegisterPluginType("dgs-dxtooltip")
showingToolTip = false

function dgsCreateToolTip(textColor,bgColor,bgImage)	--Tooltip template
	local tooltipTemplate = createElement("dgs-dxtooltip")
	dgsSetData(tooltipTemplate,"asPlugin","dgs-dxtooltip")
	
	dgsSetData(tooltipTemplate,"textColor",textColor or tocolor(255,255,255,255))
	--dgsSetData(tooltipTemplate,"colorCoded",false)
	dgsSetData(tooltipTemplate,"textSize",{1,1})
	dgsSetData(tooltipTemplate,"font","default")
	dgsSetData(tooltipTemplate,"shadow",nil)
	dgsSetData(tooltipTemplate,"alignment",{"left","top"})
	dgsSetData(tooltipTemplate,"maxWidth",sW)
	dgsSetData(tooltipTemplate,"minSize",{10,10})
	dgsSetData(tooltipTemplate,"padding",{10,10,false})
	dgsSetData(tooltipTemplate,"bgColor",bgColor or tocolor(0,0,0,128))
	dgsSetData(tooltipTemplate,"bgImage",bgImage or nil)
	
	dgsSetData(tooltipTemplate,"stayPosition",{0,0})
	dgsSetData(tooltipTemplate,"text","")
	
	dgsTriggerEvent("onDgsPluginCreate",tooltipTemplate,sourceResource)
	return tooltipTemplate
end

function dgsTooltipApplyTo(tooltip,ele,text,font,maxWidth)
	if not(dgsGetType(tooltip) == "dgs-dxtooltip") then error(dgsGenAsrt(tooltip,"dgsTooltipApplyTo",1,"plugin dgs-dxtooltip")) end
	if not(dgsIsType(ele)) then error(dgsGenAsrt(ele,"dgsTooltipApplyTo",2,"dgs-dxelement")) end
	local tooltipData = {
		tooltip,
		text or "",
		font,
		maxWidth or sW,
	}
	return dgsSetData(ele,"appliedTooltip",tooltipData)
end

function dgsTooltipRemoveFrom(ele)
	if not(dgsIsType(ele)) then error(dgsGenAsrt(ele,"dgsTooltipRemoveFrom",1,"dgs-dxelement")) end
	return dgsSetData(ele,"appliedTooltip",nil)
end

function DGSTooltipRender()
	if not isElement(showingToolTip) then return dgsRemoveFastEvent("onDgsRender","DGSTooltipRender") end
	local tooltipData = dgsElementData[showingToolTip]
	local textColor = tooltipData.textColor
	local textSize = tooltipData.textSize
	local text = tooltipData.text
	local font = tooltipData.font
	--local colorCoded = tooltipData.colorCoded
	local shadow = tooltipData.shadow
	local alignment = tooltipData.alignment
	local padding = tooltipData.padding
	local bgColor = tooltipData.bgColor
	local bgImage = tooltipData.bgImage
	
	local stayX,stayY = tooltipData.stayPosition[1],tooltipData.stayPosition[2]
	
	local maxWidth = tooltipData.maxWidth
	local textWidth,textHeight = dxGetTextSize(text,maxWidth-padding[1]*2,textSize[1],textSize[2],font,true)
	local bgWidth,bgHeight = textWidth+padding[1]*2,textHeight+padding[2]*2
	
	local drawX,drawY
	if stayX+bgWidth/2 > sW then
		drawX = sW-bgWidth
	elseif stayX-bgWidth/2 < 0 then
		drawX = 0
	else
		drawX = stayX-bgWidth/2
	end
	if stayY+bgHeight+18 > sH then
		drawY = sH-bgHeight
	else
		drawY = stayY+18
	end
	dxDrawImage(drawX,drawY,bgWidth,bgHeight,bgImage,0,0,0,bgColor,true)
	if shadow then
		shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont = shadow[1],shadow[2],shadow[3],shadow[4],shadow[5]
		--shadowColor = applyColorAlpha(shadowColor or white,parentAlpha)
	end
	dgsDrawText(text,drawX+padding[1],drawY+padding[2],drawX+bgWidth-padding[1],drawY+bgHeight-padding[2],textColor,textSize[1],textSize[2],font,alignment[1],alignment[2],false,true,true,false,false,0,0,0,0,shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont)
end

function DGSToolTipShow(enterElement,x,y)
	local eleData = dgsElementData[enterElement]
	local appliedTooltip = eleData.appliedTooltip

	if eleData.appliedTooltip then
		if isElement(appliedTooltip[1]) then
			showingToolTip = appliedTooltip[1]
			dgsSetData(showingToolTip,"stayPosition",{x,y})
			local targetTranslationName = dgsGetTranslationName(enterElement)
			local selfTranslationName = dgsGetTranslationName(showingToolTip)
			if targetTranslationName ~= selfTranslationName then
				dgsAttachToTranslation(showingToolTip,targetTranslationName)
			end
			dgsSetData(showingToolTip,"text",appliedTooltip[2])
			dgsSetData(showingToolTip,"font",appliedTooltip[3] or dgsElementData[showingToolTip].font)
			dgsSetData(showingToolTip,"maxWidth",appliedTooltip[4] or dgsElementData[showingToolTip].maxWidth)
			dgsRegisterFastEvent("onDgsRender","DGSTooltipRender")
		end
	end
end
dgsRegisterFastEvent("onDgsMouseStay","DGSToolTipShow")

function DGSMouseLeaveForToolTip(leaveElement)
	local eleData = dgsElementData[leaveElement]
	if not showingToolTip then return end
	if eleData.appliedTooltip and eleData.appliedTooltip[1] == showingToolTip then
		dgsRemoveFastEvent("onDgsRender","DGSTooltipRender")
	end
end
dgsRegisterFastEvent("onDgsMouseLeave","DGSMouseLeaveForToolTip")
