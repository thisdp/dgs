rectShaderPath = "shaders/roundRect.fx"

function dgsCreateRoundRect(radius,color,texture)
	assert(dgsGetType(radius) == "number","Bad argument @dgsCreateRoundRect at argument 1, expect number got "..dgsGetType(radius))
	local shader = dxCreateShader(rectShaderPath)
	dgsSetType(shader,"dgs-dxroundrectangle")
	local color = color or tocolor(255,255,255,255)
	dgsSetData(shader,"radius",radius)
	dgsSetData(shader,"color",color)
	dgsRoundRectSetRadius(shader,radius)
	dgsRoundRectSetTexture(shader,texture)
	dgsRoundRectSetColor(shader,color)
	return shader
end

function dgsRoundRectSetTexture(rectShader,texture)
	assert(dgsGetType(rectShader) == "dgs-dxroundrectangle","Bad argument @dgsRoundRectSetTexture at argument 1, expect dgs-dxroundrectangle got "..dgsGetType(rectShader))
	if isElement(texture) then
		dxSetShaderValue(rectShader,"textureLoad",true)
		dxSetShaderValue(rectShader,"background",texture)
	else
		dxSetShaderValue(rectShader,"textureLoad",false)
		dxSetShaderValue(rectShader,"background",0)
	end
	return true
end

function dgsRoundRectSetRadius(rectShader,radius)
	assert(dgsGetType(rectShader) == "dgs-dxroundrectangle","Bad argument @dgsRoundRectSetRadius at argument 1, expect dgs-dxroundrectangle got "..dgsGetType(rectShader))
	assert(dgsGetType(radius) == "number","Bad argument @dgsRoundRectSetRadius at argument 2, expect number got "..dgsGetType(radius))
	dxSetShaderValue(rectShader,"radius",radius)
	dgsSetData(rectShader,"radius",radius)
	return true
end

function dgsRoundRectGetRadius(rectShader)
	assert(dgsGetType(rectShader) == "dgs-dxroundrectangle","Bad argument @dgsRoundRectGetRadius at argument 1, expect dgs-dxroundrectangle got "..dgsGetType(rectShader))
	return dgsElementData[rectShader].radius
end

function dgsRoundRectSetColor(rectShader,color)
	assert(dgsGetType(rectShader) == "dgs-dxroundrectangle","Bad argument @dgsRoundRectSetColor at argument 1, expect dgs-dxroundrectangle got "..dgsGetType(rectShader))
	assert(dgsGetType(color) == "number","Bad argument @dgsRoundRectSetColor at argument 2, expect number got "..dgsGetType(color))
	dxSetShaderValue(rectShader,"color",{fromcolor(color,true,true)})
	dgsSetData(rectShader,"color",color)
	return true
end

function dgsRoundRectGetColor(rectShader)
	assert(dgsGetType(rectShader) == "dgs-dxroundrectangle","Bad argument @dgsRoundRectGetColor at argument 1, expect dgs-dxroundrectangle got "..dgsGetType(rectShader))
	return dgsElementData[rectShader].color
end
