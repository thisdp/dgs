g_DGSCanvasIndex = 0
function dgsCreateCanvas(renderSource,w,h,color)
	assert(isElement(renderSource),"Bad argument @dgsCreateCanvas at argument 1, expected texture/shader/render target got "..type(renderSource))
	local eleType = getElementType(renderSource)
	assert(eleType=="shader" or eleType=="texture" or eleType=="render-target-texture","Bad argument @dgsCreateCanvas at argument 1, expected texture/shader/render target got "..eleType)
	assert(tonumber(w),"Bad argument @dgsCreateCanvas at argument 2, expect number got "..type(w))
	assert(tonumber(h),"Bad argument @dgsCreateCanvas at argument 3, expect number got "..type(h))
	color = color or 0xFFFFFFFF
	local canvas = dxCreateRenderTarget(w,h,true) -- Main Render Target
	if not isElement(canvas) then
		local videoMemory = dxGetStatus().VideoMemoryFreeForMTA
		outputDebugString("Failed to create render target for dgs-dxcanvas [Expected:"..(0.0000076*w*h).."MB/Free:"..videoMemory.."MB]",2)
		return false
	end
	dgsSetData(canvas,"asPlugin","dgs-dxcanvas")
	dgsSetData(canvas,"blendMode","blend")
	dgsSetData(canvas,"renderSource",renderSource)
	dgsSetData(canvas,"resolution",{w,h})
	triggerEvent("onDgsPluginCreate",canvas,sourceResource)
	return canvas
end

function dgsCanvasRender(canvas)
	local resolution = dgsElementData[canvas].resolution
	local renderSource = dgsElementData[canvas].renderSource
	local blendMode = dxGetBlendMode()
	dxSetRenderTarget(canvas,true)
	dxDrawImage(0,0,resolution[1],resolution[2],renderSource)
	dxSetRenderTarget()
	dxSetBlendMode(blendMode)
end


--[[g_DGSCanvasIndex = 0
function dgsCreateCanvas(w,h,color)
	assert(tonumber(w),"Bad argument @dgsCreateCanvas at argument 1, expect number got "..type(w))
	assert(tonumber(h),"Bad argument @dgsCreateCanvas at argument 2, expect number got "..type(h))
	color = color or 0xFFFFFFFF
	local canvas = dxCreateRenderTarget(w,h,true) -- Main Render Target
	if not isElement(canvas) then
		local videoMemory = dxGetStatus().VideoMemoryFreeForMTA
		outputDebugString("Failed to create render target for dgs-dxcanvas [Expected:"..(0.0000076*w*h).."MB/Free:"..videoMemory.."MB]",2)
		return false
	end
	dgsSetData(canvas,"asPlugin","dgs-dxcanvas")
	dgsSetData(canvas,"renderList",{})
	dgsSetData(canvas,"blendMode","blend")
	dgsSetData(canvas,"color",tocolor(255,255,255,255))
	dgsSetData(canvas,"resolution",{w,h})
	triggerEvent("onDgsPluginCreate",canvas,sourceResource)
	return canvas
end

function dgsCanvasAddRenderItem(canvas,item,options)
	assert(dgsGetPluginType(canvas) == "dgs-dxcanvas","Bad argument @dgsCanvasAddRenderItem at argument 1, expected dgs-dxcanvas got "..dgsGetPluginType(canvas))
	assert(isElement(item),"Bad argument @dgsCanvasAddRenderItem at argument 2, expected texture/shader/render target got "..type(item))
	local eleType = getElementType(item)
	assert(eleType=="shader" or eleType=="texture" or eleType=="render-target-texture","Bad argument @dgsCanvasAddRenderItem at argument 2, expected texture/shader/render target got "..eleType)
	local rL = dgsElementData[canvas].renderList
	g_DGSCanvasIndex = g_DGSCanvasIndex+1
	local resolution = dgsElementData[canvas].resolution
	
	local canvasLayer
	if eleType == "shader" then
		canvasLayer = dxCreateRenderTarget(resolution[1],resolution[2],true) -- Layer Render Target
		if not isElement(canvasLayer) then
			local videoMemory = dxGetStatus().VideoMemoryFreeForMTA
			outputDebugString("Failed to create render target for dgs-dxcanvas [Expected:"..(0.0000076*resolution[1]*resolution[2]).."MB/Free:"..videoMemory.."MB]",2)
			return false
		end
	end
	
	options.color = options.color or tocolor(255,255,255,255)
	if insertPlace then
		if insertPlace > #rL then
			insertPlace = #rL+1
		end
		table.insert(rL,insertPlace,{[-1]=canvasLayer,[0]=g_DGSCanvasIndex,item,options})
	else
		table.insert(rL,{[-1]=canvasLayer,[0]=g_DGSCanvasIndex,item,options})
	end
	return g_DGSCanvasIndex
end

function dgsCanvasRemoveFromRenderItem(canvas,id)
	local rL = dgsElementData[canvas].renderList
	for i=1,#rL do
		if rL[i][0] == id then
			if isElement(rL[i][-1]) then destroyElement(rL[i][-1]) end	-- destroy the render target
			table.remove(rL,i)
			return true
		end
	end
	return false
end

function findNextRndTarget(rL,startID)
	for findID=startID+1,#rL do
		if rL[findID][-1] then
			return rL[findID][-1]
		end
	end
	return 
end)

function dgsCanvasRender(canvas)
	local size = dgsElementData[canvas].resolution
	local rL = dgsElementData[canvas].renderList
	local pBlendMode = dgsElementData[canvas].blendMode
	local blendMode = dxGetBlendMode()
	local lastRenderTarget
	for i=1,#rL do
		local rndTable = rL[i]
		local rndOptions = rndTable[2]
		local rndTarget = rndTable[-1]
		local renderItem = rndTable[1]
		---Find
		if not rndTarget then
			for findID=startID+1,#rL do
				if rL[findID][-1] then
					rndTarget = rL[findID][-1]
					break
				end
			end
			if not rndTarget then
				rndTarget = canvas
			end
			dxSetRenderTarget(rndTarget,not dgsElementData[rndTarget])
			dgsSetData(rndTarget,"markForRemain",true)
		else
			dxSetRenderTarget(rndTarget,not dgsElementData[rndTarget])
		end
		---
		dxSetBlendMode(rndOptions.blendMode or pBlendMode)
		for k,v in pairs(rndOptions) do
			if k ~= "blendMode" then
				dxSetShaderValue(renderItem,k,v)
			end
		end
		if lastRenderTarget then
			if getElementType(renderItem) == "shader" then
				dxSetShaderValue(renderItem,"sourceTexture",lastRenderTarget)
				dxSetShaderValue(renderItem,"textureLoad",true)
			end
		end
		dxDrawImage(0,0,size[1],size[2],renderItem,0,0,0,currentRender[3])
		lastRenderTarget = rndTarget
		if rndTable[-1] then
			dgsSetData(rndTable[-1],"markForRemain",false)
		end
	end
	dxSetBlendMode(blendMode)	--Reset
	dxSetRenderTarget()
end]]