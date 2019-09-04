BlurBoxGlobalScreenSource = false

function dgsCreateBlurBox()
	if not BlurBoxGlobalScreenSource then
		BlurBoxGlobalScreenSource = dxCreateScreenSource(sW,sH)
	end
	local shader = dxCreateShader("plugin/BlurBox/blur.fx")
	dxSetShaderValue(shader,"screenSource",scS)
end