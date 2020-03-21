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