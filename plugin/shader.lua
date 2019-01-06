shaderSimpleMap = {
	circle="shaders/circle.fx",
}

function dgsCreateSimpleShader(shaderSimple,shaderArguments)
	local shader = dxCreateShader(shaderSimpleMap[shaderSimple])
end