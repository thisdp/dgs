g_DGSCanvasIndex = 0
function dgsCreateCanvas(renderSource,w,h,color)
	if not(isMaterial(renderSource)) then error(dgsGenAsrt(renderSource,"dgsCreateCanvas",1,"material")) end
	if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsCreateCanvas",2,"number")) end
	if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsCreateCanvas",3,"number")) end
	color = color or 0xFFFFFFFF
	local canvas = dxCreateRenderTarget(w,h,true) -- Main Render Target
	dgsElementData[canvas] = {
		blendMode="blend",
		renderSource=renderSource,
		resolution={w,h},
	}
	dgsSetType(canvas,"dgs-dxcanvas")
	dgsSetData(canvas,"asPlugin","dgs-dxcanvas")
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

dgsCustomTexture["dgs-dxcanvas"] = function(posX,posY,width,height,u,v,usize,vsize,image,rotation,rotationX,rotationY,color,postGUI)
	return dgsCanvasRender(image)
end