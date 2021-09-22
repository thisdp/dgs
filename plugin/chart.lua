local lineShader = [[


]]

function dgsCreateChart(x,y,w,h,chartType,relative,parent)
	local customRenderer = dgsCreateCustomRenderer()
	local chartRT = dxCreateRenderTarget(w,h,true)
	local chart = dgsCreateImage(x,y,w,h,customRenderer,relative,parent)
	dgsSetData(chart,"asPlugin","dgs-dxchart")
	dgsSetData(chart,"chartRT",chartRT)
	if chartType == "line" then
		dgsSetData(chart,"chartType",chartType)
		dgsSetData(chart,"chartPadding",{0,0,20,20,false})
		dgsSetData(chart,"sampleType","pointXY")
		dgsSetData(chart,"xAxis",{})
		dgsSetData(chart,"yAxis",{0,0,0})	--Items/Min/Max
		dgsSetData(chart,"renderer",customRenderer)
		dgsSetData(chart,"axisLineColor",tocolor(0,0,0,255))
		dgsSetData(chart,"axisLineThick",5)
		dgsSetData(chart,"lineThick",2)
		dgsCustomRendererSetFunction(customRenderer,[[
			--posX,posY,width,height,self,rotation,rotationCenterOffsetX,rotationCenterOffsetY,color,postGUI
			
			
			local eleData = dgsElementData[ dgsElementData[self].chart ]
			local axisLineThick = eleData.axisLineThick
			local lineThick = eleData.lineThick
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
			local xAxis = eleData.xAxis
			local yAxis = eleData.yAxis
			local startPosX,chartWidth = posX+paddingLeft,width-paddingLeft-paddingRight
			local startPosY,chartHeight = posY+paddingTop,height-paddingDown-paddingTop
			for x=2,#xAxis do
				local percentA = (x-2)/(#xAxis-1)
				local percentB = (x-1)/(#xAxis-1)
				local pointAx = startPosX+chartWidth*percentA
				local pointAy = startPosY+chartHeight-xAxis[x-1]/yAxis[2]*chartHeight
				local pointBx = startPosX+chartWidth*percentB
				local pointBy = startPosY+chartHeight-xAxis[x]/yAxis[2]*chartHeight
				dxDrawLine(pointAx,pointAy,pointBx,pointBy,axisLineColor,lineThick,postGUI)
			end
			
		]])
	else
	
	end
	dgsSetData(customRenderer,"chart",chart)
	triggerEvent("onDgsPluginCreate",chart,sourceResource)
	return chart
end

--[[
sampleTableType:
"pointXYInOneTable" {x,y,x,y,x,y}
"pointYXInOneTable" {y,x,y,x,y,x}
"pointXY" {{x,y},{x,y},...}
"pointYX" {{y,x},{y,x},...}
"keyAsX"  {[X]=Y,[X]=Y,...}
"keyAsY"  {[Y]=X,[Y]=X,...}
]]
function dgsChartSetSamples(chart,samples,sampleTableType)
	
end
--[[
setTimer(function()

local chart = dgsCreateChart(400,300,400,400,"line",false)
dgsSetData(chart,"sampleType","keyAsY")
dgsSetData(chart,"xAxis",{1,2,4,8,16,32,64})
dgsSetData(chart,"yAxis",{0,100,10})	--Min/Max/Items

end,100,1)]]