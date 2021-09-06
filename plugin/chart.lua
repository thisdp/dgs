function dgsCreateChart(x,y,w,h,chartType,relative,parent)
	local customRenderer = dgsCreateCustomRenderer()
	local chart = dgsCreateImage(x,y,w,h,customRenderer,relative,parent)
	dgsSetData(chart,"asPlugin","dgs-dxchart")
	if chartType == "line" then
		dgsSetData(chart,"chartType",chartType)
		dgsSetData(chart,"chartPadding",{0,0,20,20,false})
		dgsSetData(chart,"xAxis",{})
		dgsSetData(chart,"yAxis",{0,0,0})	--Min/Max/Step
		dgsSetData(chart,"axisLeading",{10,false})
		dgsSetData(chart,"xAxisLeading",{10,false})
		dgsSetData(chart,"renderer",customRenderer)
		dgsSetData(chart,"axisLineColor",tocolor(0,0,0,255))
		dgsSetData(chart,"axisLineThick",5)
		dgsCustomRendererSetFunction(customRenderer,[[
			--posX,posY,width,height,self,rotation,rotationCenterOffsetX,rotationCenterOffsetY,color,postGUI
			
			
			local eleData = dgsElementData[ dgsElementData[self].chart ]
			local axisLineThick = eleData.axisLineThick
			local axisLineThickHalf = axisLineThick/2
			local axisLineColor = eleData.axisLineColor
			local padding = eleData.chartPadding
			local paddingTop = padding[5] and padding[1]*height or padding[1]
			local paddingRight = padding[5] and padding[2]*width or padding[2]
			local paddingDown = padding[5] and padding[3]*height or padding[3]
			local paddingLeft = padding[5] and padding[4]*width or padding[4]
			
			--xAxis
			dxDrawLine(posX+paddingLeft-axisLineThickHalf,posY+height-paddingDown,posX+width,posY+height-paddingDown,axisLineColor,axisLineThick,postGUI)
			--yAxis
			dxDrawLine(posX+paddingLeft,posY,posX+paddingLeft,posY+height-paddingDown+axisLineThickHalf,axisLineColor,axisLineThick,postGUI)
		]])
	else
	
	end
	dgsSetData(customRenderer,"chart",chart)
	triggerEvent("onDgsPluginCreate",chart,sourceResource)
	return chart
end

function dgsChartSetSamples(chart,samples)
	
end
--[[
setTimer(function()

--dgsCreateChart(400,300,400,400,"line",false)


end,100,1)]]