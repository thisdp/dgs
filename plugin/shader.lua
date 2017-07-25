--this one allows you just create one shader to apply multi gui
function dgsDxGUIAddShader(dxgui,shader,tab)
	assert(dgsIsDxElement(dxgui),"@dgsDxGUIAddShader argument at 1,expect a dgs-dxgui element got "..(dgsGetType(dxgui) or type(dxgui)))
	assert(isElement(shader) and getElementType(shader) == "shader","@dgsDxGUIAddShader argument at 2,expect a shader element got "..tostring(isElement(shader) and getElementType(shader) or shader))
	for k,v in pairs(tab) do
		dgsSetData(dxgui,"shader_"..v,{dgsGetData(dxgui,v),{}})
		dgsSetData(dxgui,v,shader)
	end
end

function dgsDxGUISetShaderValue(gdxguim,key,vkey,values)
	assert(isElement(shader) and getElementType(shader) == "shader","@dgsDxGUISetShaderValue argument at 1,expect a shader element got "..tostring(isElement(shader) and getElementType(shader) or shader))
	if type(vkey) == "table" and not values then
		for k,v in pairs(vkey) do
			local data = dgsGetData(dxgui,"shader_"..key) or {}
			data[2][k] = v
			dgsSetData(dxgui,"shader_"..key,data)
		end
	elseif type(vkey) == "string" and values then
		local data = dgsGetData(dxgui,"shader_"..key) or {}
		data[2][vkey] = values
		dgsSetData(dxgui,"shader_"..key,data)
	end
end

function dgsDxGUIRemoveShader(dxgui,tab)
	assert(dgsIsDxElement(dxgui),"@dgsDxGUIRemoveShader argument at 1,expect a dgs-dxgui element got "..(dgsGetType(dxgui) or type(dxgui)))
	for k,v in pairs(tab) do
		local data = dgsGetData(dxgui,"shader_"..v)
		dgsSetData(dxgui,v,data[1])
		dgsSetData(dxgui,"shader_"..v,false)
	end
	return true
end

--[[addEventHandler("onDGSPreRender",root,function(x,y,w,h)
	for k,v in pairs(dgsGetData(source)) do
		if string.find(k,"shader_") then
			local options = dgsGetData(v,"k")[2]
			for a,b in pairs(options) do
				dxSetShaderValue(v,"a",b)
			end
		end
	end
end)]]