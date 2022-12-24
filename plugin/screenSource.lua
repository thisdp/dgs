dgsLogLuaMemory()
dgsRegisterPluginType("dgs-dxscreensource")
GlobalScreenSource = false
GlobalScreenSourceWidthFactor = 1
GlobalScreenSourceHeightFactor = 1

DGSI_RegisterMaterialType("dgs-dxscreensource","texture")
function dgsCreateScreenSource(uPos,vPos,uSize,vSize,relative)
	local ss = createElement("dgs-dxscreensource")
	dgsSetData(ss,"asPlugin","dgs-dxscreensource")
	if not uPos or not vPos or not uSize or not vSize then
		dgsSetData(ss,"uvPos",{nil,nil,false})
		dgsSetData(ss,"uvSize",{nil,nil,false})
	else
		dgsSetData(ss,"uvPos",{uPos,vPos,relative or false})
		dgsSetData(ss,"uvSize",{uSize,vSize,relative or false})
	end
	dgsTriggerEvent("onDgsPluginCreate",ss,sourceResource)
	if not isElement(GlobalScreenSource) then
		GlobalScreenSource = dxCreateScreenSource(sW*GlobalScreenSourceWidthFactor,sH*GlobalScreenSourceHeightFactor)
	end
	return ss
end

function dgsScreenSourceSetUVPosition(ss,uPos,vPos,relative)
	if not(dgsGetPluginType(ss) == "dgs-dxscreensource") then error(dgsGenAsrt(ss,"dgsScreenSourceSetUVPosition",1,"dgs-dxscreensource")) end
	dgsSetData(ss,"uvPos",{uPos,vPos,relative or false})
	return true
end

function dgsScreenSourceGetUVPosition(ss,relative)
	if not(dgsGetPluginType(ss) == "dgs-dxscreensource") then error(dgsGenAsrt(ss,"dgsScreenSourceSetUVPosition",1,"dgs-dxscreensource")) end
	local relative = relative or false
	local uvPos = dgsElementData[ss].uvPos
	if uvPos[1] and uvPos[2] then
		if relative then
			if uvPos[3] == relative then
				return uvPos[1],uvPos[2]
			else
				return uvPos[1]/(sW*GlobalScreenSourceWidthFactor),uvPos[2]/(sH*GlobalScreenSourceHeightFactor)
			end
		else
			if uvPos[3] == relative then
				return uvPos[1],uvPos[2]
			else
				return uvPos[1]*sW*GlobalScreenSourceWidthFactor,uvPos[2]*sH*GlobalScreenSourceHeightFactor
			end
		end
	end
	return false,false
end

function dgsScreenSourceSetUVSize(ss,uSize,vSize,relative)
	if not(dgsGetPluginType(ss) == "dgs-dxblurbox") then error(dgsGenAsrt(ss,"dgsScreenSourceSetUVSize",1,"dgs-dxblurbox")) end
	dgsSetData(ss,"uvSize",{uSize,vSize,relative or false})
	return true
end

function dgsScreenSourceGetUVSize(ss,relative)
	if not(dgsGetPluginType(ss) == "dgs-dxscreensource") then error(dgsGenAsrt(ss,"dgsScreenSourceGetUVSize",1,"dgs-dxscreensource")) end
	local relative = relative or false
	local uvSize = dgsElementData[ss].uvSize
	if uvSize[1] and uvSize[2] then
		if relative then
			if uvSize[3] == relative then
				return uvSize[1],uvSize[2]
			else
				return uvSize[1]/(sW*GlobalScreenSourceWidthFactor),uvSize[2]/(sH*GlobalScreenSourceHeightFactor)
			end
		else
			if uvSize[3] == relative then
				return uvSize[1],uvSize[2]
			else
				return uvSize[1]*sW*GlobalScreenSourceWidthFactor,uvSize[2]*sH*GlobalScreenSourceHeightFactor
			end
		end
	end
	return false,false
end

dgsCustomTexture["dgs-dxscreensource"] = function(posX,posY,width,height,u,v,usize,vsize,image,rotation,rotationX,rotationY,color,postGUI)
	local uvPos = dgsElementData[image].uvPos
	local uvSize = dgsElementData[image].uvSize
	if uvPos[1] and uvPos[2] and uvSize[1] and uvSize[2] then
		local uPos,vPos = uvPos[3] and uvPos[1]*GlobalScreenSourceWidthFactor or uvPos[1], uvPos[3] and uvPos[2]*GlobalScreenSourceHeightFactor or uvPos[2]
		local uSize,vSize = uvSize[3] and uvSize[1]*GlobalScreenSourceWidthFactor or uvSize[1], uvSize[3] and uvSize[2]*GlobalScreenSourceHeightFactor or uvSize[2]
		__dxDrawImageSection(posX,posY,width,height,uPos,vPos,uSize,vSize,GlobalScreenSource,rotation,rotationX,rotationY,color,postGUI)
	else
		__dxDrawImageSection(posX,posY,width,height,posX*GlobalScreenSourceWidthFactor,posY*GlobalScreenSourceHeightFactor,width*GlobalScreenSourceWidthFactor,height*GlobalScreenSourceHeightFactor,GlobalScreenSource,rotation,rotationX,rotationY,color,postGUI)
	end
end