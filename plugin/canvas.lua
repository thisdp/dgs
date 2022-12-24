dgsLogLuaMemory()
dgsRegisterPluginType("dgs-dxcanvas")
local dxDrawImage = dxDrawImage
g_DGSCanvasIndex = 0
function dgsCreateCanvas(renderSource,w,h,color)
	if not(isMaterial(renderSource) or dgsGetType(renderSource) == "dgs-dxcustomrenderer") then error(dgsGenAsrt(renderSource,"dgsCreateCanvas",1,"material/dgs-dxcustomrenderer")) end
	if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsCreateCanvas",2,"number")) end
	if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsCreateCanvas",3,"number")) end
	color = color or 0xFFFFFFFF
	local canvas = dgsCreateRenderTarget(w,h,true) -- Main Render Target
	dgsElementData[canvas] = {
		blendMode="blend",
		renderSource=renderSource,
		resolution={w,h},
	}
	dgsSetType(canvas,"dgs-dxcanvas")
	dgsSetData(canvas,"asPlugin","dgs-dxcanvas")
	dgsSetData(canvas,"disableCustomTexture",false)
	dgsTriggerEvent("onDgsPluginCreate",canvas,sourceResource)
	return canvas
end

function dgsCanvasSetBackEndFunction(canvas,fncStr)
	if dgsGetType(canvas) ~= "dgs-dxcanvas" then error(dgsGenAsrt(canvas,"dgsCanvasSetBackEndFunction",1,"dgs-dxcanvas")) end
	local fncType = type(fncStr)
	if fncType == "function" then
		return dgsSetData(canvas,"canvasBackEnd",fncStr)
	else
		if not (type(fncStr) == "string") then error(dgsGenAsrt(fncStr,"dgsCanvasSetBackEndFunction",2,"string")) end
		fncStr = [[self = ...]]..fncStr
		local fnc,err = loadstring(fncStr)
		if not fnc then error(dgsGenAsrt(fnc,"dgsCanvasSetBackEndFunction",2,_,_,_,"Failed to load function:"..err)) end
		return dgsSetData(canvas,"canvasBackEnd",fnc)
	end
end

function dgsCanvasRender(canvas)
	local resolution = dgsElementData[canvas].resolution
	local renderSource = dgsElementData[canvas].renderSource
	local blendMode = dxGetBlendMode()
	--dxSetBlendMode("overwrite")
	dxSetRenderTarget(canvas,true)
	dxDrawImage(0,0,resolution[1],resolution[2],renderSource)
	dxSetRenderTarget()
	--dxSetBlendMode(blendMode)
end

dgsCustomTexture["dgs-dxcanvas"] = function(posX,posY,width,height,u,v,usize,vsize,image,rotation,rotationX,rotationY,color,postGUI)
	return dgsCanvasRender(image)
	--return __dxDrawImage(posX,posY,width,height,image,rotation,rotationX,rotationY,color,postGUI)
end

dgsBackEndRenderer:register("dgs-dxcanvas",function(image)
	if dgsElementData[image].canvasBackEnd then
		return dgsElementData[image].canvasBackEnd(image)
	end
end)