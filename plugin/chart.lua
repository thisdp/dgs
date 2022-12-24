dgsLogLuaMemory()
dgsRegisterPluginType("dgs-dxchart")

chartProcessFunction = {
	["line"] = {
		create = function(x,y,w,h,chartType,relative,parent)
			local customRenderer = dgsCreateCustomRenderer()
			local svg = dgsCreateSVG(w,h)
			local svgDoc = dgsSVGGetDocument(svg)
			local chart = dgsCreateImage(x,y,w,h,customRenderer,relative,parent)
			dgsAttachToAutoDestroy(svg,chart,-1)
			dgsAttachToAutoDestroy(customRenderer,chart,-2)
			dgsSetData(chart,"svg",svg)
			dgsSetData(chart,"asPlugin","dgs-dxchart")
			local res = sourceResource or "global"
			local style = styleManager.styles[res]
			local using = style.using
			style = style.loaded[using]
			local systemFont = style.systemFontElement
			dgsSetData(chart,"chartType",chartType)
			dgsSetData(chart,"chartPadding",{5,20,20,5,false}) --Top Botton Left Right
			dgsSetData(chart,"sampleType","pointXY")
			dgsSetData(chart,"labels",{})
			dgsSetData(chart,"datasets",{})
			dgsSetData(chart,"gridHorizontal",{})
			dgsSetData(chart,"gridVertical",{})
			dgsSetData(chart,"enableGridHorizontal",true)
			dgsSetData(chart,"enableGridVertical",true)
			dgsSetData(chart,"renderer",customRenderer)
			dgsSetData(chart,"axisLineColor",tocolor(255,255,255,255))
			dgsSetData(chart,"axisLineWidth",2)
			dgsSetData(chart,"axisTextColor",tocolor(255,255,255,255))
			dgsSetData(chart,"axisTextSize",{1.5,1.5})
			dgsSetData(chart,"axisTextFont",systemFont)
			dgsSetData(chart,"axisTextOffsetFromGrid",10)
			dgsSetData(chart,"axisYScaler",nil)
			dgsSetData(chart,"axisYLines",10)
			dgsSetData(chart,"gridLineColor",tocolor(200,200,200,255))
			dgsSetData(chart,"gridLineWidth",1)
			dgsSetData(chart,"renderBuffer",{})
			local eleData = dgsElementData[chart]
			local bPosT = eleData.chartPadding[5] and eleData.chartPadding[1]*h or eleData.chartPadding[1]
			local bPosB = h-(eleData.chartPadding[5] and eleData.chartPadding[2]*h or eleData.chartPadding[2])
			local bPosL = eleData.chartPadding[5] and eleData.chartPadding[3]*w or eleData.chartPadding[3]
			local bPosR = w-(eleData.chartPadding[5] and eleData.chartPadding[4]*w or eleData.chartPadding[4])
			local gridLineWidth = eleData.gridLineWidth
			local def = dgsSVGCreateNode(svgDoc,"defs")
			local grid = dgsSVGCreateNode(def,"g","grid")
			local line = dgsSVGCreateNode(def,"g","line")
			local axis = dgsSVGCreateNode(def,"g","axis")
			dgsSetData(chart,"defs",{grid,line,axis})
			local gridUse = dgsSVGCreateNode(svgDoc,"use","grid",0,0)
			local lineUse = dgsSVGCreateNode(svgDoc,"use","line",0,0)
			local axisUse = dgsSVGCreateNode(svgDoc,"use","axis",0,0)
			dgsSetData(chart,"uses",{gridUse,lineUse,axisUse})
			local axisLine = dgsSVGCreateNode(svgDoc,"polyline",bPosL,bPosT-gridLineWidth/2,bPosL,bPosB,bPosR+gridLineWidth/2,bPosB)
			dgsSVGNodeSetAttribute(axisLine,"stroke",eleData.axisLineColor)
			dgsSVGNodeSetAttribute(axisLine,"stroke-width",eleData.axisLineWidth)
			dgsSVGNodeSetAttribute(axisLine,"fill","none")
			dgsSetData(chart,"axisLine",axisLine)
			dgsCustomRendererSetFunction(customRenderer,[[
				--posX,posY,width,height,self,rotation,rotationCenterOffsetX,rotationCenterOffsetY,color,postGUI
				local chart = dgsElementData[self].chart
				local eleData = dgsElementData[chart]
				local w,h = eleData.absSize[1],eleData.absSize[2]
				if eleData.updateNextFrame then dgsChartUpdate(chart) end
				local svg = eleData.svg
				dxDrawImage(posX,posY,width,height,svg,rotation,rotationCenterOffsetX,rotationCenterOffsetY,color,postGUI)
				
				local bPosT = eleData.chartPadding[5] and eleData.chartPadding[1]*h or eleData.chartPadding[1]
				local bPosB = h-(eleData.chartPadding[5] and eleData.chartPadding[2]*h or eleData.chartPadding[2])
				local bPosL = eleData.chartPadding[5] and eleData.chartPadding[3]*w or eleData.chartPadding[3]
				local bPosR = w-(eleData.chartPadding[5] and eleData.chartPadding[4]*w or eleData.chartPadding[4])

				local axisTextSize = eleData.axisTextSize
				local axisTextColor = eleData.axisTextColor
				local axisTextFont = eleData.axisTextFont or "default"
				local axisTextOffsetFromGrid = eleData.axisTextOffsetFromGrid
				
				local labels = eleData.labels
				for i=1,#labels do
					local x,y = posX+bPosL+(i-1)/(#labels-1)*(bPosR-bPosL),posY+bPosB+axisTextOffsetFromGrid
					dgsDrawText(labels[i],x,y,x,y,axisTextColor,axisTextSize[1],axisTextSize[2],axisTextFont,"center","top",false,false,postGUI)
				end
				local renderBuffer = eleData.renderBuffer
				if renderBuffer.yScale then
					local yMin,yMax = renderBuffer.yScale[1],renderBuffer.yScale[2]
					local range = yMax-yMin
					for i=1,eleData.axisYLines+1 do
						local x,y = posX+bPosL-axisTextOffsetFromGrid,posY+bPosB-(i-1)/(eleData.axisYLines)*(bPosB-bPosT)
						local scaleText = (i-1)/(eleData.axisYLines)*range+yMin
						dgsDrawText(scaleText,x,y,x,y,axisTextColor,axisTextSize[1],axisTextSize[2],axisTextFont,"right","center",false,false,postGUI)
					end
				end
			]])
			dgsSetData(customRenderer,"chart",chart)
			return chart
		end,
		update = function(chart)
			local eleData = dgsElementData[chart]
			local datasets = eleData.datasets
			local svg = eleData.svg
			local svgDoc = dgsSVGGetDocument(svg)
			local w,h = eleData.absSize[1],eleData.absSize[2]
			local bPosT = eleData.chartPadding[5] and eleData.chartPadding[1]*h or eleData.chartPadding[1]
			local bPosB = h-(eleData.chartPadding[5] and eleData.chartPadding[2]*h or eleData.chartPadding[2])
			local bPosL = eleData.chartPadding[5] and eleData.chartPadding[3]*w or eleData.chartPadding[3]
			local bPosR = w-(eleData.chartPadding[5] and eleData.chartPadding[4]*w or eleData.chartPadding[4])
			
			local gridLineWidth = eleData.gridLineWidth
				
			--Update Axis Line
			local axisLine = eleData.axisLine
			dgsSVGNodeSetAttribute(axisLine,"points",bPosL,bPosT-gridLineWidth/2,bPosL,bPosB,bPosR+gridLineWidth/2,bPosB)
			--Draw Grid
			--Find the Min/Max
			local minData,maxData
			local axisYScaler = eleData.axisYScaler
			if not axisYScaler then
				for id=1,#datasets do
					minData,maxData = minData or datasets[id][1][1],maxData or datasets[id][1][1]
					for i=2,#datasets[id][1] do
						if minData > datasets[id][1][i] then minData = datasets[id][1][i] end
						if maxData < datasets[id][1][i] then maxData = datasets[id][1][i] end
					end
				end
			else
				minData,maxData = axisYScaler[1],axisYScaler[2]
			end
			if minData and maxData then
				local renderBuffer = eleData.renderBuffer
				if not renderBuffer.yScale then renderBuffer.yScale = {} end
				renderBuffer.yScale[1] = minData
				renderBuffer.yScale[2] = maxData
				local gridLineColor = eleData.gridLineColor
				local gridHorizontal = eleData.gridHorizontal
				local range = (maxData-minData)*1.2
				local delta = (maxData-minData)*0.1
				local axisYLines = eleData.enableGridHorizontal and eleData.axisYLines or 0
				local unitSize = range/axisYLines
				local deltaGrid = axisYLines-#gridHorizontal
				local gridDef = eleData.defs[1]
				if deltaGrid > 0 then
					for i=1,deltaGrid do
						local newNode = dgsSVGCreateNode(gridDef,"line")
						table.insert(gridHorizontal,newNode)
					end
				elseif deltaGrid < 0 then
					for i=1,-deltaGrid do
						dgsSVGDestroyNode(gridHorizontal[#gridHorizontal])
						table.remove(gridHorizontal,#gridHorizontal)
					end
				end
				--Update Horizontal Grid
				for i=1,#gridHorizontal do
					dgsSVGNodeSetAttributes(gridHorizontal[i],{
						x1=bPosL,
						y1=bPosB-i/axisYLines*(bPosB-bPosT),
						x2=bPosR,
						y2=bPosB-i/axisYLines*(bPosB-bPosT),
						stroke=gridLineColor,
						["stroke-width"] = gridLineWidth,
					})
				end
				local gridVertical = eleData.gridVertical
				local labels = #eleData.labels
				local deltaGrid = (eleData.enableGridVertical and labels or 1)-#gridVertical-1
				if deltaGrid > 0 then
					for i=1,deltaGrid do
						table.insert(gridVertical,dgsSVGCreateNode(gridDef,"line"))
					end
				elseif deltaGrid < 0 then
					for i=1,-deltaGrid do
						dgsSVGDestroyNode(gridVertical[#gridVertical])
						table.remove(gridVertical,#gridVertical)
					end
				end
				--Update Vertical Grid
				for i=1,#gridVertical do
					dgsSVGNodeSetAttributes(gridVertical[i],{
						x1=bPosL+i/(labels-1)*(bPosR-bPosL),
						y1=bPosB,
						x2=bPosL+i/(labels-1)*(bPosR-bPosL),
						y2=bPosT,
						stroke=gridLineColor,
						["stroke-width"] = gridLineWidth,
					})
				end
				--Update Sample Line
				for id=1,#datasets do
					local points = {}
					for i=1,labels do
						if datasets[id][1][i] then
							points[#points+1] = bPosL+(i-1)/(labels-1)*(bPosR-bPosL)
							points[#points+1] = bPosB-(datasets[id][1][i]-(-delta+minData))/range*(bPosB-bPosT)
						end
					end
					dgsSVGNodeSetAttribute(datasets[id][0],"points",points)
				end
			end
			return true
		end,
	},
}

function dgsCreateChart(x,y,w,h,chartType,relative,parent)
	if chartProcessFunction[chartType] then
		local chart = chartProcessFunction[chartType].create(x,y,w,h,chartType,relative,parent)
		dgsSetData(chart,"updateNextFrame",true)
		dgsTriggerEvent("onDgsPluginCreate",chart,sourceResource)
		return chart
	end
	return false
end

function dgsChartUpdate(chart)
	dgsSetData(chart,"updateNextFrame",false)
	local chartType = dgsElementData[chart].chartType or ""
	if chartProcessFunction[chartType] then
		return chartProcessFunction[chartType].update(chart)
	end
end

function dgsChartSetLabels(chart,name,labels)
	dgsSetData(chart,"labelName",name)
	dgsSetData(chart,"labels",labels)
	dgsSetData(chart,"updateNextFrame",true)
end

function dgsChartRemoveDataset(chart,datasetID)
	local eleData = dgsElementData[chart]
	local datasets = eleData.datasets
	if datasets[datasetID] then
		dgsSVGDestroyNode(datasets[datasetID][1])
		table.remove(datasets,datasetID)
		return true
	end
	dgsSetData(chart,"updateNextFrame",true)
	return false
end

local dataSetStyle = {
	color = 3,
	width = 5,
}
function dgsChartAddDataset(chart,name)
	local eleData = dgsElementData[chart]
	local datasets = eleData.datasets
	local id = #datasets+1
	local svgDoc = dgsSVGGetDocument(eleData.svg)
	local dataLine = dgsSVGCreateNode(svgDoc,"polyline")
	dgsSVGNodeSetAttribute(dataLine,"fill","none")
	datasets[id] = {
		[0] = dataLine,
		[1] = {},
		[2] = name,	--Label Name
	}
	dgsSetData(chart,"updateNextFrame",true)
	return id
end

function dgsChartDatasetSetLabel(chart,datasetID,name)
	local eleData = dgsElementData[chart]
	local datasets = eleData.datasets
	if not datasets[datasetID] then return false end
	datasets[datasetID][2] = name
	--Use Dx, No need to update
	return true
end

function dgsChartDatasetSetStyle(chart,datasetID,style)
	local eleData = dgsElementData[chart]
	local datasets = eleData.datasets
	if not datasets[datasetID] then return false end
	if style.color then
		dgsSVGNodeSetAttribute(datasets[datasetID][0],"stroke",style.color)
	end
	if style.width then
		dgsSVGNodeSetAttribute(datasets[datasetID][0],"stroke-width",style.width)
	end
	for k,v in pairs(style) do
		if dataSetStyle[k] then
			datasets[datasetID][dataSetStyle[k]] = v
		end
	end
	dgsSetData(chart,"updateNextFrame",true)
	return true
end

function dgsChartDatasetSetData(chart,datasetID,data)
	local eleData = dgsElementData[chart]
	local datasets = eleData.datasets
	if not datasets[datasetID] then return false end
	datasets[datasetID][1] = data
	dgsSetData(chart,"updateNextFrame",true)
end

function dgsChartDatasetAddData(chart,datasetID,data)
	local eleData = dgsElementData[chart]
	local datasets = eleData.datasets
	if not datasets[datasetID] then return false end
	table.insert(datasets[datasetID][1],data)
	dgsSetData(chart,"updateNextFrame",true)
	return true
end

function dgsChartDatasetRemoveData(chart,datasetID,index)
	local eleData = dgsElementData[chart]
	local datasets = eleData.datasets
	if not datasets[datasetID] then return false end
	if index then
		if not datasets[datasetID][1][index] then return false end
		table.remove(datasets[datasetID][1],index)
	else
		table.remove(datasets[datasetID][1],#datasets[datasetID][1])
	end
	dgsSetData(chart,"updateNextFrame",true)
	return true
end

function dgsChartDatasetClearData(chart,datasetID)
	local eleData = dgsElementData[chart]
	local datasets = eleData.datasets
	if not datasets[datasetID] then return false end
	datasets[datasetID][1] = {}
	dgsSetData(chart,"updateNextFrame",true)
	return true
end