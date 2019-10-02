function dgsCreateNineSlice(texture,paddingX,paddingY,usingCache) --todo
	assert(dgsGetType(texture) == "texture","Bad argument @dgsCreateNineSlice at argument 1, expect texture got "..dgsGetType(texture))
	local shader = dxCreateShader("")
	dgsSetData(shader,"asPlugin","dgs-dxnineslice")
	dgsSetData(shader,"padding",{paddingX or 1/3,paddingY or 1/3})
	triggerEvent("onDgsPluginCreate",shader,sourceResource)
	return shader
end