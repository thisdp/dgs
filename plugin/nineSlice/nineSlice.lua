nineSliceShader = "plugin/nineSlice/nineSlice.fx"
function nineSliceRender(posX,posY,width,height,self,rotation,rotationCenterOffsetX,rotationCenterOffsetY,color,postGUI)
	local selfData = dgsElementData[self]
	width = width+math.cos(getTickCount()%3600/1800*math.pi)*150
	height = height+math.cos(getTickCount()%3600/1800*math.pi)*150
	dxSetShaderValue(selfData.renderShader,"rR",{width,height})
	dxSetShaderValue(selfData.renderShader,"gdX",selfData.gridX)
	dxSetShaderValue(selfData.renderShader,"gdY",selfData.gridY)
	dxDrawImage(posX,posY,width,height,dgsElementData[self].renderShader,rotation,rotationCenterOffsetX,rotationCenterOffsetY,color,postGUI)
end

function dgsCreateNineSlice(texture,gridXLeft,gridXRight,gridYTop,gridYBottom)
	assert(dgsGetType(texture) == "texture","Bad argument @dgsCreateNineSlice at argument 1, expect texture got "..dgsGetType(texture))
	local nineSlice = dgsCreateCustomRenderer()
	dgsSetData(nineSlice,"asPlugin","dgs-dxnineslice")
	local shader = dxCreateShader(nineSliceShader)
	dxSetShaderValue(shader,"gTex",texture)
	local matX,matY = dxGetMaterialSize(texture)
	dxSetShaderValue(shader,"tR",{matX,matY})
	dgsSetData(nineSlice,"textureResolution",{matX,matY})
	dgsSetData(nineSlice,"gridX",{gridXLeft,gridXRight})
	dgsSetData(nineSlice,"gridY",{gridYTop,gridYBottom})
	dgsSetData(nineSlice,"renderShader",shader)
	dgsSetData(nineSlice,"renderImage",texture)
	dgsCustomRendererSetFunction(nineSlice,nineSliceRender)
	triggerEvent("onDgsPluginCreate",nineSlice,sourceResource)
	return nineSlice
end

function dgsNineSliceSetGrid(nineSlice,gridXLeft,gridXRight,gridYTop,gridYBottom)
	assert(dgsGetPluginType(nineSlice) == "dgs-dxnineslice","Bad argument @dgsCreateNineSlice at argument 1, expect plugin dgs-dxnineslice got "..dgsGetType(dgsGetPluginType))
	local oGridX = dgsElementData[nineSlice].gridX
	local oGridY = dgsElementData[nineSlice].gridY
	gridXLeft = gridXLeft or oGridX[1]
	gridXRight = gridXRight or oGridX[2]
	gridYTop = gridYTop or oGridY[1]
	gridYBottom = gridYBottom or oGridY[2]
	return true
end

function dgsNineSliceGetGrid(nineSlice)
	assert(dgsGetPluginType(nineSlice) == "dgs-dxnineslice","Bad argument @dgsNineSliceGetGrid at argument 1, expect plugin dgs-dxnineslice got "..dgsGetType(dgsGetPluginType))
	local gridX = dgsElementData[nineSlice].gridX
	local gridY = dgsElementData[nineSlice].gridY
	return gridX[1],gridX[2],gridY[1],gridY[2]
end