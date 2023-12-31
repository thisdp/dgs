dgsLogLuaMemory()
dgsRegisterPluginType("dgs-dxnineslice")
local nineSliceShader
function nineSliceRender(posX,posY,width,height,self,rotation,rotationCenterOffsetX,rotationCenterOffsetY,color,postGUI)
	local selfData = dgsElementData[self]
	dxSetShaderValue(selfData.renderShader,"rR",width,height)
	dxSetShaderValue(selfData.renderShader,"gdX",selfData.gridX)
	dxSetShaderValue(selfData.renderShader,"gdY",selfData.gridY)
	dxDrawImage(posX,posY,width,height,dgsElementData[self].renderShader,rotation,rotationCenterOffsetX,rotationCenterOffsetY,color,postGUI)
end

function dgsCreateNineSlice(texture,gridXLeft,gridXRight,gridYTop,gridYBottom,relative)
	relative = relative and true or false
	local imgType = dgsGetType(texture)
	if not(imgType == "texture" or imgType == "svg") then error(dgsGenAsrt(texture,"dgsCreateNineSlice",1,"texture")) end
	if not(type(gridXLeft) == "number") then error(dgsGenAsrt(gridXLeft,"dgsCreateNineSlice",2,"number")) end
	if not(type(gridXLeft) == "number") then error(dgsGenAsrt(gridXLeft,"dgsCreateNineSlice",3,"number")) end
	if not(type(gridYTop) == "number") then error(dgsGenAsrt(gridYTop,"dgsCreateNineSlice",4,"number")) end
	if not(type(gridYBottom) == "number") then error(dgsGenAsrt(gridYBottom,"dgsCreateNineSlice",5,"number")) end
	local nineSlice = dgsCreateCustomRenderer()
	dgsSetData(nineSlice,"asPlugin","dgs-dxnineslice")
	local shader = dxCreateShader("plugin/NineSlice/nineSlice.fx")
	dxSetShaderValue(shader,"sourceTexture",texture)
	dgsSetData(nineSlice,"renderImage",texture)
	local matX,matY = dxGetMaterialSize(texture)
	dxSetShaderValue(shader,"tR",{matX,matY})
	dgsSetData(nineSlice,"textureResolution",{matX,matY})
	if not relative then
		gridXLeft,gridXRight = gridXLeft/matX,gridXRight/matX
		gridYTop,gridYBottom = gridYTop/matY,gridYBottom/matY
	end
	dgsSetData(nineSlice,"gridX",{gridXLeft,gridXRight})
	dgsSetData(nineSlice,"gridY",{gridYTop,gridYBottom})
	dgsSetData(nineSlice,"renderShader",shader)
	dgsCustomRendererSetFunction(nineSlice,nineSliceRender)
	addEventHandler("onClientElementDestroy",nineSlice,function()
		if isElement(dgsElementData[nineSlice].renderShader) then
			destroyElement(dgsElementData[nineSlice].renderShader)
		end
	end,false)
	dgsTriggerEvent("onDgsPluginCreate",nineSlice,sourceResource)
	return nineSlice
end

function dgsNineSliceSetGrid(nineSlice,gridXLeft,gridXRight,gridYTop,gridYBottom,relative)
	relative = relative and true or false
	if not(dgsGetPluginType(nineSlice) == "dgs-dxnineslice") then error(dgsGenAsrt(nineSlice,"dgsNineSliceSetGrid",1,"dgs-dxnineslice")) end
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
	if not(dgsGetPluginType(nineSlice) == "dgs-dxnineslice") then error(dgsGenAsrt(nineSlice,"dgsNineSliceGetGrid",1,"dgs-dxnineslice")) end
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
	if not(dgsGetPluginType(nineSlice) == "dgs-dxnineslice") then error(dgsGenAsrt(nineSlice,"dgsNineSliceSetTexture",1,"dgs-dxnineslice")) end
	local imgType = dgsGetType(texture)
	if not(imgType == "texture" or imgType == "svg") then error(dgsGenAsrt(texture,"dgsNineSliceSetTexture",2,"texture")) end
	dxSetShaderValue(shader,"sourceTexture",texture)
	dgsSetData(nineSlice,"renderImage",texture)
	local matX,matY = dxGetMaterialSize(texture)
	dxSetShaderValue(shader,"tR",{matX,matY})
	dgsSetData(nineSlice,"textureResolution",{matX,matY})
end

function dgsNineSliceGetTexture(nineSlice)
	if not(dgsGetPluginType(nineSlice) == "dgs-dxnineslice") then error(dgsGenAsrt(nineSlice,"dgsNineSliceGetTexture",1,"dgs-dxnineslice")) end
	return dgsElementData[nineSlice].renderImage
end