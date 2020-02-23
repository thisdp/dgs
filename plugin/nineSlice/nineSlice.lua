nineSliceShader = "plugin/nineSlice/nineSlice.fx"
function nineSliceRender(posX,posY,width,height,self,rotation,rotationCenterOffsetX,rotationCenterOffsetY,color,postGUI)
	local selfData = dgsElementData[self]
	dxSetShaderValue(selfData.renderShader,"rR",{width,height})
	dxSetShaderValue(selfData.renderShader,"gdX",selfData.gridX)
	dxSetShaderValue(selfData.renderShader,"gdY",selfData.gridY)
	dxDrawImage(posX,posY,width,height,dgsElementData[self].renderShader,rotation,rotationCenterOffsetX,rotationCenterOffsetY,color,postGUI)
end

function dgsCreateNineSlice(texture,gridXLeft,gridXRight,gridYTop,gridYBottom,relative)
	relative = relative and true or false
	assert(dgsGetType(texture) == "texture","Bad argument @dgsCreateNineSlice at argument 1, expect texture got "..dgsGetType(texture))
	assert(type(gridXLeft) == "number","Bad argument @dgsCreateNineSlice at argument 2, expect number got "..type(gridXLeft))
	assert(type(gridXRight) == "number","Bad argument @dgsCreateNineSlice at argument 3, expect number got "..type(gridXRight))
	assert(type(gridYTop) == "number","Bad argument @dgsCreateNineSlice at argument 4, expect number got "..type(gridYTop))
	assert(type(gridYBottom) == "number","Bad argument @dgsCreateNineSlice at argument 5, expect number got "..type(gridYBottom))
	local nineSlice = dgsCreateCustomRenderer()
	dgsSetData(nineSlice,"asPlugin","dgs-dxnineslice")
	local shader = dxCreateShader(nineSliceShader)
	dxSetShaderValue(shader,"gTex",texture)
	dgsSetData(nineSlice,"renderImage",texture)
	local matX,matY = dxGetMaterialSize(texture)
	dxSetShaderValue(shader,"tR",{matX,matY})
	dgsSetData(nineSlice,"textureResolution",{matX,matY})
	if relative then
		gridXLeft,gridXRight = gridXLeft/matX,gridXRight/matX
		gridYTop,gridYBottom = gridYTop/matY,gridYBottom/matY
	end
	dgsSetData(nineSlice,"gridX",{gridXLeft,gridXRight})
	dgsSetData(nineSlice,"gridY",{gridYTop,gridYBottom})
	dgsSetData(nineSlice,"renderShader",shader)
	dgsCustomRendererSetFunction(nineSlice,nineSliceRender)
	triggerEvent("onDgsPluginCreate",nineSlice,sourceResource)
	return nineSlice
end

function dgsNineSliceSetGrid(nineSlice,gridXLeft,gridXRight,gridYTop,gridYBottom,relative)
	relative = relative and true or false
	assert(dgsGetPluginType(nineSlice) == "dgs-dxnineslice","Bad argument @dgsCreateNineSlice at argument 1, expect plugin dgs-dxnineslice got "..dgsGetPluginType(nineSlice))
	local oGridX = dgsElementData[nineSlice].gridX
	local oGridY = dgsElementData[nineSlice].gridY
	local matSize = dgsElementData[nineSlice].textureResolution
	gridXLeft = gridXLeft and (relative and gridXleft or gridXLeft/matSize[1]) or oGridX[1]
	gridXRight = gridXRight and (relative and gridXRight or gridXRight/matSize[1]) or oGridX[2]
	gridYTop = gridYTop and (relative and gridYTop or gridYTop/matSize[2]) or oGridY[1]
	gridYBottom = gridYBottom and (relative and gridYBottom or gridYBottom/matSize[2]) or oGridY[2]
	dgsSetData(nineSlice,"gridX",{gridXLeft,gridXRight})
	dgsSetData(nineSlice,"gridY",{gridYTop,gridYBottom})
	return true
end

function dgsNineSliceGetGrid(nineSlice,relative)
	assert(dgsGetPluginType(nineSlice) == "dgs-dxnineslice","Bad argument @dgsNineSliceGetGrid at argument 1, expect plugin dgs-dxnineslice got "..dgsGetPluginType(nineSlice))
	local gridX = dgsElementData[nineSlice].gridX
	local gridY = dgsElementData[nineSlice].gridY
	local matSize = dgsElementData[nineSlice].textureResolution
	local gridXLeft = relative and gridX[1] or gridX[1]*matSize[1]
	local gridXRight = relative and gridX[2] or gridX[2]*matSize[1]
	local gridYTop = relative and gridY[1] or gridY[1]*matSize[2]
	local gridYBottom = relative and gridY[2] or gridY[2]*matSize[2]
	return gridXLeft,gridXRight,gridYTop,gridYBottom
end

function dgsNineSliceSetTexture(nineSlice,texture)
	assert(dgsGetPluginType(nineSlice) == "dgs-dxnineslice","Bad argument @dgsNineSliceSetTexture at argument 1, expect plugin dgs-dxnineslice got "..dgsGetPluginType(nineSlice))
	assert(dgsGetType(texture) == "texture","Bad argument @dgsNineSliceSetTexture at argument 2, expect texture got "..dgsGetType(texture))
	dxSetShaderValue(shader,"gTex",texture)
	dgsSetData(nineSlice,"renderImage",texture)
	local matX,matY = dxGetMaterialSize(texture)
	dxSetShaderValue(shader,"tR",{matX,matY})
	dgsSetData(nineSlice,"textureResolution",{matX,matY})
end

function dgsNineSliceGetTexture(nineSlice)
	assert(dgsGetPluginType(nineSlice) == "dgs-dxnineslice","Bad argument @dgsNineSliceGetTexture at argument 1, expect plugin dgs-dxnineslice got "..dgsGetPluginType(nineSlice))
	return dgsElementData[nineSlice].renderImage
end
