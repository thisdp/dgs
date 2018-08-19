local cos,sin,rad,atan2 = math.cos,math.sin,math.rad,math.atan2

function dgsCreate3DInterface(x,y,z,w,h,resolX,resolY,color,faceX,faceY,faceZ,distance)
	assert(tonumber(x),"Bad argument @dgsCreate3DInterface at argument 1, expect a number got "..type(x))
	assert(tonumber(y),"Bad argument @dgsCreate3DInterface at argument 2, expect a number got "..type(y))
	assert(tonumber(y),"Bad argument @dgsCreate3DInterface at argument 3, expect a number got "..type(z))
	assert(tonumber(w),"Bad argument @dgsCreate3DInterface at argument 4, expect a number got "..type(w))
	assert(tonumber(h),"Bad argument @dgsCreate3DInterface at argument 5, expect a number got "..type(h))
	assert(tonumber(resolX),"Bad argument @dgsCreate3DInterface at argument 6, expect a number got "..type(w))
	assert(tonumber(resolY),"Bad argument @dgsCreate3DInterface at argument 7, expect a number got "..type(h))
	local interface = createElement("dgs-dx3dinterface")
	table.insert(dx3DInterfaceTable,interface)
	dgsSetType(interface,"dgs-dx3dinterface")
	dgsSetData(interface,"position",{x,y,z})
	dgsSetData(interface,"faceTo",{faceX,faceY,faceZ})
	dgsSetData(interface,"size",{w,h})
	dgsSetData(interface,"color",color or tocolor(255,255,255,255))
	dgsSetData(interface,"resolution",{resolX,resolY})
	dgsSetData(interface,"maxDistance",distance or 100)
	dgsSetData(interface,"filterShader",false)
	dgsSetData(interface,"blendMode","add")
	dgsSetData(interface,"attachTo",false)
	local rndTgt = dxCreateRenderTarget(resolX,resolY,true)
	dgsSetData(interface,"renderTarget_parent",rndTgt)
	insertResourceDxGUI(sourceResource,interface)
	triggerEvent("onDgsCreate",interface)
	if not isElement(rndTgt) then
		destroyElement(interface)
		return false
	end
	return interface
end

function dgsDrawMaterialLine3D(x,y,z,vx,vy,vz,material,w,h,color,lnVec,lnPnt)
	local offFaceX = atan2(vz,(vx^2+vy^2)^0.5)
	local offFaceZ = atan2(vx,vy)
	local _h=h
	h=h/2
	local x1,y1,z1 = sin(offFaceX)*sin(offFaceZ)*h,sin(offFaceX)*cos(offFaceZ)*h,-cos(offFaceX)*h
	dxDrawMaterialLine3D(x-x1,y-y1,z-z1,x+x1,y+y1,z+z1,material,w,tocolor(255,255,255,255),x+vx,y+vy,z+vz)
	if lnVec and lnPnt then
		local px,py,pz = dgsGetIntersection(lnVec,lnPnt,{vx,vy,vz},{x,y,z}) --Intersection Point
		if not px then return end
		local model = (vx^2+vy^2+vz^2)^0.5
		local vx,vy,vz = vx/model,vy/model,vz/model
		local ltX,ltY,ltZ = y1*vz-vy*z1,z1*vx-vz*x1,x1*vy-vx*y1 --Left Point
		local leftModel = (ltX^2+ltY^2+ltZ^2)^0.5*2
		local ltX,ltY,ltZ = ltX/leftModel*w,ltY/leftModel*w,ltZ/leftModel*w
		local vec1X,vec1Y,vec1Z = ltX+x-px,ltY+y-py,ltZ+z-pz
		local vec2X,vec2Y,vec2Z = px-x+x1,py-y+y1,pz-z+z1
		local _x,_y = (vec1X*ltX+vec1Y*ltY+vec1Z*ltZ)/(ltX^2+ltY^2+ltZ^2)^0.5/w,(vec2X*x1+vec2Y*y1+vec2Z*z1)/(x1^2+y1^2+z1^2)^0.5/_h
		local angle = (x-lnPnt[1])*lnVec[1]+(y-lnPnt[2])*lnVec[2]+(z-lnPnt[3])*lnVec[3]
		local inSide = _x>=0 and _x<=1 and _y>=0 and _y <=1
		return (angle > 0) and inSide,_x,_y,px,py,pz
	end
end

function dgsGetIntersection(lnVec,lnPnt,pnVec,pnPnt)
	local vpt = (pnVec[1]*lnVec[1]+pnVec[2]*lnVec[2]+pnVec[3]*lnVec[3])
	if vpt ~= 0 then
		local t = (pnVec[1]*(pnPnt[1]-lnPnt[1])+pnVec[2]*(pnPnt[2]-lnPnt[2])+pnVec[3]*(pnPnt[3]-lnPnt[3]))/vpt
		return lnPnt[1]+lnVec[1]*t,lnPnt[2]+lnVec[2]*t,lnPnt[3]+lnVec[3]*t
	end
end

local blendMode = {
	blend = true,
	add = true,
	modulate_add = true,
	overwrite = true,
}

function dgs3DInterfaceSetBlendMode(interface,blend)
	assert(dgsGetType(interface) == "dgs-dx3dinterface","Bad argument @dgs3DInterfaceSetBlendMode at argument 1, expect a dgs-dx3dinterface got "..dgsGetType(interface))
	assert(type(blend) == "string","Bad argument @dgs3DInterfaceSetBlendMode at argument 2, expect a string got "..dgsGetType(blend))
	assert(blendMode[blend],"Bad argument @dgs3DInterfaceSetBlendMode at argument 2, couldn't find such blend mode "..blend)
	return dgsSetData(interface,"blendMode",blendMode)
end

function dgs3DInterfaceGetBlendMode(interface)
	assert(dgsGetType(interface) == "dgs-dx3dinterface","Bad argument @dgs3DInterfaceGetBlendMode at argument 1, expect a dgs-dx3dinterface got "..dgsGetType(interface))
	return dgsElementData[interface].blendMode
end

function dgs3DInterfaceSetPosition(interface,x,y,z)
	assert(dgsGetType(interface) == "dgs-dx3dinterface","Bad argument @dgs3DInterfaceSetBlendMode at argument 1, expect a dgs-dx3dinterface got "..dgsGetType(interface))
	assert(tonumber(x),"Bad argument @dgs3DInterfaceSetPosition at argument 2, expect a number got "..type(x))
	assert(tonumber(y),"Bad argument @dgs3DInterfaceSetPosition at argument 3, expect a number got "..type(y))
	assert(tonumber(z),"Bad argument @dgs3DInterfaceSetPosition at argument 4, expect a number got "..type(z))
	return dgsSetData(interface,"position",{x,y,z})
end

function dgs3DInterfaceGetPosition(interface)
	assert(dgsGetType(interface) == "dgs-dx3dinterface","Bad argument @dgs3DInterfaceGetPosition at argument 1, expect a dgs-dx3dinterface got "..dgsGetType(interface))
	local pos = dgsElementData[interface].position
	return pos[1],pos[2],pos[3]
end

function dgs3DInterfaceSetSize(interface,w,h)
	assert(dgsGetType(interface) == "dgs-dx3dinterface","Bad argument @dgs3DInterfaceSetSize at argument 1, expect a dgs-dx3dinterface got "..dgsGetType(interface))
	assert(tonumber(w),"Bad argument @dgs3DInterfaceSetSize at argument 2, expect a number got "..type(w))
	assert(tonumber(h),"Bad argument @dgs3DInterfaceSetSize at argument 3, expect a number got "..type(h))
	return dgsSetData(interface,"size",{w,h})
end

function dgs3DInterfaceGetSize(interface)
	assert(dgsGetType(interface) == "dgs-dx3dinterface","Bad argument @dgs3DInterfaceGetSize at argument 1, expect a dgs-dx3dinterface got "..dgsGetType(interface))
	local size = dgsElementData[interface].size
	return size[1],size[2]
end

function dgs3DInterfaceSetResolution(interface,w,h)
	assert(dgsGetType(interface) == "dgs-dx3dinterface","Bad argument @dgs3DInterfaceSetResolution at argument 1, expect a dgs-dx3dinterface got "..dgsGetType(interface))
	assert(tonumber(w),"Bad argument @dgs3DInterfaceSetResolution at argument 2, expect a number got "..type(w))
	assert(tonumber(h),"Bad argument @dgs3DInterfaceSetResolution at argument 3, expect a number got "..type(h))
	local rndTgt = dxCreateRenderTarget(w,h,true)
	assert(rndTgt,"Bad argument @dgs3DInterfaceSetResolution, Failed to create render target for dgs 3d interface")
	dgsSetData(interface,"renderTarget_parent",rndTgt)
	return dgsSetData(interface,"resolution",{w,h})
end

function dgs3DInterfaceGetResolution(interface)
	assert(dgsGetType(interface) == "dgs-dx3dinterface","Bad argument @dgs3DInterfaceSetResolution at argument 1, expect a dgs-dx3dinterface got "..dgsGetType(interface))
	assert(tonumber(w),"Bad argument @dgs3DInterfaceSetResolution at argument 2, expect a number got "..type(w))
	assert(tonumber(h),"Bad argument @dgs3DInterfaceSetResolution at argument 3, expect a number got "..type(h))
	local size = dgsElementData[interface].resolution
	return size[1],size[2]
end

function dgs3DInterfaceAttachToElement(interface,element,offX,offY,offZ,offFaceX,offFaceY,offFaceZ)
	assert(dgsGetType(interface) == "dgs-dx3dinterface","Bad argument @dgs3DInterfaceAttachToElement at argument 1, expect a dgs-dx3dinterface got "..dgsGetType(interface))
	assert(isElement(element),"Bad argument @dgs3DInterfaceAttachToElement at argument 2, expect an element got "..dgsGetType(element))
	local offX,offY,offZ = offX or 0,offY or 0,offZ or 0
	local offFaceX,offFaceY,offFaceZ = offFaceX or 0,offFaceY or 0,offFaceZ or 0
	return dgsSetData(interface,"attachTo",{element,offX,offY,offZ,offFaceX,offFaceY,offFaceZ})
end

function dgs3DInterfaceIsAttached(interface)
	assert(dgsGetType(interface) == "dgs-dx3dinterface","Bad argument @dgs3DInterfaceIsAttached at argument 1, expect a dgs-dx3dinterface got "..dgsGetType(interface))
	return dgsElementData[interface].attachTo
end

function dgs3DInterfaceDetachFromElement(interface)
	assert(dgsGetType(interface) == "dgs-dx3dinterface","Bad argument @dgs3DInterfaceDetachFromElement at argument 1, expect a dgs-dx3dinterface got "..dgsGetType(interface))
	return dgsSetData(interface,"attachTo",false)
end

function dgs3DInterfaceSetAttachedOffsets(interface,offX,offY,offZ,offFaceX,offFaceY,offFaceZ)
	assert(dgsGetType(interface) == "dgs-dx3dinterface","Bad argument @dgs3DInterfaceSetAttachedOffsets at argument 1, expect a dgs-dx3dinterface got "..dgsGetType(interface))
	local attachTable = dgsElementData[interface].attachTo
	if attachTable then
		local offX,offY,offZ = offX or attachTable[2],offY or attachTable[3],offZ or attachTable[4]
		local offFaceX,offFaceY,offFaceZ = offFaceX or attachTable[5],offFaceY or attachTable[6],offFaceZ or attachTable[7]
		return dgsSetData(interface,"attachTo",{attachTable[1],offX,offY,offZ,offFaceX,offFaceY,offFaceZ})
	end
	return false
end

function dgs3DInterfaceGetAttachedOffsets(interface,offX,offY,offZ,offFaceX,offFaceY,offFaceZ)
	assert(dgsGetType(interface) == "dgs-dx3dinterface","Bad argument @dgs3DInterfaceGetAttachedOffsets at argument 1, expect a dgs-dx3dinterface got "..dgsGetType(interface))
	local attachTable = dgsElementData[interface].attachTo
	if attachTable then
		local offX,offY,offZ = attachTable[2],attachTable[3],attachTable[4]
		local offFaceX,offFaceY,offFaceZ = attachTable[5],attachTable[6],attachTable[7]
		return offX,offY,offZ,offFaceX,offFaceY,offFaceZ
	end
	return false
end

function getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix ( element )
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z
end