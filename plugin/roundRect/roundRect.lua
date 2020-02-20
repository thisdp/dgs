rectShaderPath = "plugin/roundRect/roundRect.fx"

function dgsCreateRoundRect(radius,color,texture,relative)
	assert(dgsGetType(radius) == "number","Bad argument @dgsCreateRoundRect at argument 1, expect number got "..dgsGetType(radius))
	local shader = dxCreateShader(rectShaderPath)
	local color = color or tocolor(255,255,255,255)
	dgsSetData(shader,"asPlugin","dgs-dxroundrectangle")
	dgsSetData(shader,"radius",radius)
	dgsSetData(shader,"color",color)
	dgsSetData(shader,"colorOverwritten",true)
	dgsRoundRectSetRadius(shader,radius,relative)
	dgsRoundRectSetTexture(shader,texture)
	dgsRoundRectSetColor(shader,color)
	triggerEvent("onDgsPluginCreate",shader,sourceResource)
	return shader
end

function dgsRoundRectSetTexture(rectShader,texture)
	assert(dgsElementData[rectShader].asPlugin == "dgs-dxroundrectangle","Bad argument @dgsRoundRectSetTexture at argument 1, expect dgs-dxroundrectangle got "..dgsGetType(rectShader))
	if isElement(texture) then
		dxSetShaderValue(rectShader,"textureLoad",true)
		dxSetShaderValue(rectShader,"background",texture)
	else
		dxSetShaderValue(rectShader,"textureLoad",false)
		dxSetShaderValue(rectShader,"background",0)
	end
	return true
end

function dgsRoundRectSetRadius(rectShader,radius,relative)
	assert(dgsElementData[rectShader].asPlugin == "dgs-dxroundrectangle","Bad argument @dgsRoundRectSetRadius at argument 1, expect dgs-dxroundrectangle got "..dgsGetType(rectShader))
	assert(dgsGetType(radius) == "number","Bad argument @dgsRoundRectSetRadius at argument 2, expect number got "..dgsGetType(radius))
	dxSetShaderValue(rectShader,"radius",radius)
	dxSetShaderValue(rectShader,"isRelative",relative and true or false)
	dgsSetData(rectShader,"radius",radius)
	dgsSetData(rectShader,"isRelative",relative and true or false)
	return true
end

function dgsRoundRectGetRadius(rectShader)
	assert(dgsElementData[rectShader].asPlugin == "dgs-dxroundrectangle","Bad argument @dgsRoundRectGetRadius at argument 1, expect dgs-dxroundrectangle got "..dgsGetType(rectShader))
	return dgsElementData[rectShader].radius
end

function dgsRoundRectSetColor(rectShader,color)
	assert(dgsElementData[rectShader].asPlugin == "dgs-dxroundrectangle","Bad argument @dgsRoundRectSetColor at argument 1, expect dgs-dxroundrectangle got "..dgsGetType(rectShader))
	assert(dgsGetType(color) == "number","Bad argument @dgsRoundRectSetColor at argument 2, expect number got "..dgsGetType(color))
	dxSetShaderValue(rectShader,"color",{fromcolor(color,true,true)})
	dgsSetData(rectShader,"color",color)
	return true
end

function dgsRoundRectGetColor(rectShader)
	assert(dgsElementData[rectShader].asPlugin == "dgs-dxroundrectangle","Bad argument @dgsRoundRectGetColor at argument 1, expect dgs-dxroundrectangle got "..dgsGetType(rectShader))
	return dgsElementData[rectShader].color
end

function dgsRoundRectGetColorOverwritten(rectShader)
	assert(dgsElementData[rectShader].asPlugin == "dgs-dxroundrectangle","Bad argument @dgsRoundRectGetColorOverwritten at argument 1, expect dgs-dxroundrectangle got "..dgsGetType(rectShader))
	return dgsElementData[rectShader].colorOverwritten
end

function dgsRoundRectSetColorOverwritten(rectShader,colorOverwritten)
	assert(dgsElementData[rectShader].asPlugin == "dgs-dxroundrectangle","Bad argument @dgsRoundRectSetColorOverwritten at argument 1, expect dgs-dxroundrectangle got "..dgsGetType(rectShader))
	dgsSetData(rectShader,"colorOverwritten",colorOverwritten)
	dxSetShaderValue(rectShader,"colorOverwritten",colorOverwritten)
end
