BlurBoxGlobalScreenSource = false

function dgsCreateBlurBox()
	if not isElement(BlurBoxGlobalScreenSource) then
		BlurBoxGlobalScreenSource = dxCreateScreenSource(sW,sH)
	end
	local shader = dxCreateShader("plugin/BlurBox/BlurBox.fx")
	dgsSetData(shader,"asPlugin","dgs-dxblurbox")
	dxSetShaderValue(shader,"screenSource",BlurBoxGlobalScreenSource)
	triggerEvent("onDgsPluginCreate",shader,sourceResource)
	return shader
end

function dgsBlurBoxRender(blurBox,x,y,w,h,postGUI)
	dxUpdateScreenSource(BlurBoxGlobalScreenSource,true)
	dxDrawImageSection(x,y,w,h,x,y,w,h,blurBox,0,0,0,0xFFFFFFFF,postGUI or false)
end

