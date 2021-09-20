function dgsLazyTextureLoad(texturePath,forceLoad)

end

function dgsCreateLazyTexture()
	local lt = dgsCreateElement("dgs-dxlazytexture")
	dgsSetData(lt,"asPlugin","dgs-dxlazytexture")
	triggerEvent("onDgsPluginCreate",lt,sourceResource)
	return lt
end