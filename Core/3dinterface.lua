local cos,sin,rad,atan2,acos,deg = math.cos,math.sin,math.rad,math.atan2,math.acos,math.deg
function LookRotation(x,y,z,rot)
	local rx = deg(acos(((x^2+z^2)/(x^2+y^2+z^2))^0.5))
	if (y > 0) then
		rx = 360-rx
	end
	local ry = deg(atan2(x, z))
	if (ry < 0) then
		ry = ry+ 180
	end
	if (x < 0) then
		ry = ry+ 180
	end
	rz = rot
	return rz,ry,rz
end

function dgsSetFilterShaderData(shader,x,y,z,fx,fy,fz,rotation,w,h,tex,r,g,b,a)
	local rx,ry,rz = LookRotation(fx,fy,fz,rotation)
	dxSetShaderValue(shader, "sElementColor",r/255,g/255,b/255,a/255)
	dxSetShaderValue(shader, "sTexColor", tex )
end

function dgsCreate3DInterface(x,y,z,w,h,resolX,resolY,color,faceX,faceY,faceZ,distance,rot)
	assert(tonumber(x),"Bad argument @dgsCreate3DInterface at argument 1, expect a number got "..type(x))
	assert(tonumber(y),"Bad argument @dgsCreate3DInterface at argument 2, expect a number got "..type(y))
	assert(tonumber(y),"Bad argument @dgsCreate3DInterface at argument 3, expect a number got "..type(z))
	assert(tonumber(w),"Bad argument @dgsCreate3DInterface at argument 4, expect a number got "..type(w))
	assert(tonumber(h),"Bad argument @dgsCreate3DInterface at argument 5, expect a number got "..type(h))
	assert(tonumber(resolX),"Bad argument @dgsCreate3DInterface at argument 6, expect a number got "..type(resolX))
	assert(tonumber(resolY),"Bad argument @dgsCreate3DInterface at argument 7, expect a number got "..type(resolX))
	local interface = createElement("dgs-dx3dinterface")
	table.insert(dx3DInterfaceTable,interface)
	dgsSetType(interface,"dgs-dx3dinterface")
	dgsSetData(interface,"renderBuffer",{})
	dgsSetData(interface,"position",{x,y,z})
	dgsSetData(interface,"faceTo",{faceX,faceY,faceZ})
	dgsSetData(interface,"size",{w,h})
	dgsSetData(interface,"faceRelativeTo","self")
	dgsSetData(interface,"color",color or tocolor(255,255,255,255))
	dgsSetData(interface,"resolution",{resolX,resolY})
	dgsSetData(interface,"maxDistance",distance or 200)
	dgsSetData(interface,"fadeDistance",distance or 180)
	dgsSetData(interface,"filterShader",false)
	dgsSetData(interface,"blendMode","add")
	dgsSetData(interface,"attachTo",false)
	dgsSetData(interface,"dimension",-1)
	dgsSetData(interface,"interior",-1)
	dgsSetData(interface,"rotation",rot or 0)
	local renderTarget,err = dxCreateRenderTarget(resolX,resolY,true,interface)
	if renderTarget ~= false then
		dgsAttachToAutoDestroy(renderTarget,interface,-1)
	else
		outputDebugString(err)
	end
	dgsSetData(interface,"renderTarget_parent",renderTarget)
	triggerEvent("onDgsCreate",interface,sourceResource)
	if not isElement(renderTarget) then
		destroyElement(interface)
		return false
	end
	return interface
end

function dgsDrawMaterialLine3D(x,y,z,vx,vy,vz,material,w,h,color,rot)
	local offFaceX = atan2(vz,(vx^2+vy^2)^0.5)
	local offFaceZ = atan2(vx,vy)
	local _x,_y,_z = sin(offFaceX)*sin(offFaceZ)*cos(rot)+sin(rot)*cos(offFaceZ),sin(offFaceX)*cos(offFaceZ)*cos(rot)-sin(rot)*sin(offFaceZ),-cos(offFaceX)*cos(rot)
	w,h = w/2,h/2
	local topX,topY,topZ = _x*h,_y*h,_z*h
	local leftX,leftY,leftZ = topY*vz-vy*topZ,topZ*vx-vz*topX,topX*vy-vx*topY --Left Point
	local leftModel = (leftX^2+leftY^2+leftZ^2)^0.5
	local leftX,leftY,leftZ = leftX/leftModel*w,leftY/leftModel*w,leftZ/leftModel*w
	local r,g,b = fromcolor(color)
	color = tocolor(r,g,b)
	local rightBottom = {leftX+topX+x,leftY+topY+y,leftZ+topZ+z,color,0,1}
	local rightTop = {leftX-topX+x,leftY-topY+y,leftZ-topZ+z,color,0,0}
	local leftBottom = {-leftX+topX+x,-leftY+topY+y,-leftZ+topZ+z,color,1,1}
	local leftTop= {-leftX-topX+x,-leftY-topY+y,-leftZ-topZ+z,color,1,0}
	dxDrawMaterialPrimitive3D("trianglestrip",material,false,leftTop,leftBottom,rightTop,rightBottom)
end

function dgsCalculate3DInterfaceMouse(x,y,z,vx,vy,vz,w,h,lnVec,lnPnt,rot)
	local offFaceX = atan2(vz,(vx^2+vy^2)^0.5)
	local offFaceZ = atan2(vx,vy)
	local _h=h
	h=h*0.5
	local _x,_y,_z = sin(offFaceX)*sin(offFaceZ)*cos(rot)+sin(rot)*cos(offFaceZ),sin(offFaceX)*cos(offFaceZ)*cos(rot)-sin(rot)*sin(offFaceZ),-cos(offFaceX)*cos(rot)
	local x1,y1,z1 = _x*h,_y*h,_z*h
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

function dgs3DInterfaceSetRotation(interface,rotation)
	assert(dgsGetType(interface) == "dgs-dx3dinterface","Bad argument @dgs3DInterfaceSetRotation at argument 1, expect a dgs-dx3dinterface got "..dgsGetType(interface))
	assert(type(rotation) == "number","Bad argument @dgs3DInterfaceSetRotation at argument 2, expect a number got "..dgsGetType(rotation))
	return dgsSetData(interface,"rotation",rotation)
end

function dgs3DInterfaceGetRotation(interface)
	assert(dgsGetType(interface) == "dgs-dx3dinterface","Bad argument @dgs3DInterfaceGetRotation at argument 1, expect a dgs-dx3dinterface got "..dgsGetType(interface))
	return dgsElementData[interface].rotation
end


function dgs3DInterfaceSetFaceTo(interface,fx,fy,fz,relativeTo)
	assert(dgsGetType(interface) == "dgs-dx3dinterface","Bad argument @dgs3DInterfaceSetFaceTo at argument 1, expect a dgs-dx3dinterface got "..dgsGetType(interface))
	if not fx and not fy and not fz then
		return dgsSetData(interface,"faceTo",nil)
	else
		assert(type(fx) == "number","Bad argument @dgs3DInterfaceSetFaceTo at argument 2, expect a number got "..dgsGetType(fx))
		assert(type(fy) == "number","Bad argument @dgs3DInterfaceSetFaceTo at argument 3, expect a number got "..dgsGetType(fy))
		assert(type(fz) == "number","Bad argument @dgs3DInterfaceSetFaceTo at argument 4, expect a number got "..dgsGetType(fz))
		relativeTo = relativeTo == "world" and "world" or "self"
		return dgsSetData(interface,"faceTo",{fx,fy,fz}) and dgsSetData(interface,"faceRelativeTo",relativeTo)
	end
end

function dgs3DInterfaceGetFaceTo(interface)
	assert(dgsGetType(interface) == "dgs-dx3dinterface","Bad argument @dgs3DInterfaceGetFaceTo at argument 1, expect a dgs-dx3dinterface got "..dgsGetType(interface))
	local faceTo = dgsElementData[interface].faceTo or {}
	local faceRelativeTo = dgsElementData[interface].faceRelativeTo or "self"
	return faceTo[1],faceTo[2],faceTo[3],faceRelativeTo
end

function dgs3DInterfaceSetBlendMode(interface,blend)
	assert(dgsGetType(interface) == "dgs-dx3dinterface","Bad argument @dgs3DInterfaceSetBlendMode at argument 1, expect a dgs-dx3dinterface got "..dgsGetType(interface))
	assert(type(blend) == "string","Bad argument @dgs3DInterfaceSetBlendMode at argument 2, expect a string got "..dgsGetType(blend))
	assert(blendMode[blend],"Bad argument @dgs3DInterfaceSetBlendMode at argument 2, couldn't find such blend mode "..blend)
	return dgsSetData(interface,"blendMode",blend)
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

function dgs3DInterfaceGetDimension(interface)
	assert(dgsGetType(interface) == "dgs-dx3dinterface","Bad argument @dgs3DInterfaceGetDimension at argument 1, expect a dgs-dx3dinterface got "..dgsGetType(interface))
	return dgsElementData[interface].dimension or -1
end

function dgs3DInterfaceSetDimension(interface,dimension)
	assert(dgsGetType(interface) == "dgs-dx3dinterface","Bad argument @dgs3DInterfaceSetDimension at argument 1, expect a dgs-dx3dinterface got "..dgsGetType(interface))
	assert(tonumber(dimension),"Bad argument @dgs3DInterfaceSetDimension at argument 2, expect a number got "..type(dimension))
	assert(dimension >= -1 and dimension <= 65535,"Bad argument @dgs3DInterfaceSetDimension at argument 2, out of range [ -1 ~ 65535 ] got "..dimension)
	return dimension-dimension%1
end

function dgs3DInterfaceGetInterior(interface)
	assert(dgsGetType(interface) == "dgs-dx3dinterface","Bad argument @dgs3DInterfaceGetInterior at argument 1, expect a dgs-dx3dinterface got "..dgsGetType(interface))
	return dgsElementData[interface].interior or -1
end

function dgs3DInterfaceSetInterior(interface,interior)
	assert(dgsGetType(interface) == "dgs-dx3dinterface","Bad argument @dgs3DInterfaceSetInterior at argument 1, expect a dgs-dx3dinterface got "..dgsGetType(interface))
	assert(tonumber(interior),"Bad argument @dgs3DInterfaceSetInterior at argument 2, expect a number got "..type(interior))
	assert(interior >= -1,"Bad argument @dgs3DInterfaceSetInterior at argument 2, out of range [ -1 ~ +∞ ] got "..interior)
	return interior-interior%1
end

function dgs3DInterfaceSetResolution(interface,w,h)
	assert(dgsGetType(interface) == "dgs-dx3dinterface","Bad argument @dgs3DInterfaceSetResolution at argument 1, expect a dgs-dx3dinterface got "..dgsGetType(interface))
	assert(tonumber(w),"Bad argument @dgs3DInterfaceSetResolution at argument 2, expect a number got "..type(w))
	assert(tonumber(h),"Bad argument @dgs3DInterfaceSetResolution at argument 3, expect a number got "..type(h))
	local oldRT = dgsElementData[interface].renderTarget_parent
	if isElement(oldRT) then destroyElement(oldRT) end
	local renderTarget,err = dxCreateRenderTarget(w,h,true,interface)
	if renderTarget ~= false then
		dgsAttachToAutoDestroy(renderTarget,interface,-1)
	else
		outputDebugString(err)
	end
	dgsSetData(interface,"renderTarget_parent",renderTarget)
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
	local offFaceX,offFaceY,offFaceZ = offFaceX or 0,offFaceY or 1,offFaceZ or 0
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

function dgs3DInterfaceGetAttachedOffsets(interface)
	assert(dgsGetType(interface) == "dgs-dx3dinterface","Bad argument @dgs3DInterfaceGetAttachedOffsets at argument 1, expect a dgs-dx3dinterface got "..dgsGetType(interface))
	local attachTable = dgsElementData[interface].attachTo
	if attachTable then
		local offX,offY,offZ = attachTable[2],attachTable[3],attachTable[4]
		local offFaceX,offFaceY,offFaceZ = attachTable[5],attachTable[6],attachTable[7]
		return offX,offY,offZ,offFaceX,offFaceY,offFaceZ
	end
	return false
end

----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dx3dinterface"] = function(source,x,y,w,h,mx,my,cx,cy,enabled,eleData,parentAlpha,isPostGUI,rndtgt)
	local pos = eleData.position
	local size = eleData.size
	local faceTo = eleData.faceTo
	local x,y,z,w,h,fx,fy,fz,rot = pos[1],pos[2],pos[3],size[1],size[2],faceTo[1],faceTo[2],faceTo[3],eleData.rotation
	rndtgt = eleData.renderTarget_parent
	if x and y and z and w and h and enabled[1] and mx then
		local lnVec,lnPnt
		local camX,camY,camZ = getCameraMatrix()
		if not fx or not fy or not fz then
			fx,fy,fz = camX-x,camY-y,camZ-z
		end
		if eleData.faceRelativeTo == "world" then
			fx,fy,fz = fx-x,fy-y,fz-z
		end
		if wX and wY and wZ then
			lnVec = {wX-camX,wY-camY,wZ-camZ}
			lnPnt = {camX,camY,camZ}
		end
		if eleData.cameraDistance or 0 <= eleData.maxDistance then
			eleData.hit = {dgsCalculate3DInterfaceMouse(x,y,z,fx,fy,fz,w,h,lnVec,lnPnt,rot)}
		else
			eleData.hit = {}
		end
		local hitData = eleData.hit or {}
		if #hitData > 0 then
			local hit,hitX,hitY,hx,hy,hz = hitData[1],hitData[2],hitData[3],hitData[4],hitData[5],hitData[6]
			local distance = ((camX-hx)^2+(camY-hy)^2+(camZ-hz)^2)^0.5
			local oldPos = MouseData.interfaceHit
			if isElement(MouseData.lock3DInterface) then
				if MouseData.lock3DInterface == source then
					MouseData.hit = source
					mx,my = hitX*eleData.resolution[1],hitY*eleData.resolution[2]
					MouseX,MouseY = mx,my
					MouseData.interfaceHit = {hx,hy,hz,distance,source}
				end
			elseif (not oldPos[4] or distance <= oldPos[4]) and hit then
				MouseData.hit = source
				mx,my = hitX*eleData.resolution[1],hitY*eleData.resolution[2]
				MouseX,MouseY = mx,my
				MouseData.interfaceHit = {hx,hy,hz,distance,source}
			end
		end
		dxSetRenderTarget(rndtgt,true)
		dxSetRenderTarget()
		return rndtgt,false,mx,my
	end
	return rndtgt,true
end

function interfaceRender()
	for i=1,#dx3DInterfaceTable do
		local v = dx3DInterfaceTable[i]
		local eleData = dgsElementData[v]
		local dimension = eleData.dimension
		if eleData.visible then
			local attachTable = eleData.attachTo
			if attachTable then
				local element,offX,offY,offZ,offFaceX,offFaceY,offFaceZ = attachTable[1],attachTable[2],attachTable[3],attachTable[4],attachTable[5],attachTable[6],attachTable[7]
				if not isElement(element) then
					eleData.attachTo = false
				else
					local ex,ey,ez = getElementPosition(element)
					local tmpX,tmpY,tmpZ = getPositionFromElementOffset(element,offFaceX,offFaceY,offFaceZ)
					eleData.position = {getPositionFromElementOffset(element,offX,offY,offZ)}
					eleData.faceTo = {tmpX-ex,tmpY-ey,tmpZ-ez}
				end
			end
			local pos = eleData.position
			local size = eleData.size
			local faceTo = eleData.faceTo or {}
			local x,y,z,w,h,fx,fy,fz,rot = pos[1],pos[2],pos[3],size[1],size[2],faceTo[1],faceTo[2],faceTo[3],eleData.rotation
			eleData.hit = false
			if x and y and z and w and h then
				self = v
				local camX,camY,camZ = getCameraMatrix()
				local cameraDistance = ((camX-x)^2+(camY-y)^2+(camZ-z)^2)^0.5
				eleData.cameraDistance = cameraDistance
				if cameraDistance <= eleData.maxDistance then
					local renderThing = eleData.renderTarget_parent
					local addalp = 1
					if cameraDistance >= eleData.fadeDistance then
						addalp = 1-(cameraDistance-eleData.fadeDistance)/(eleData.maxDistance-eleData.fadeDistance)
					end
					local colors = applyColorAlpha(eleData.color,eleData.alpha*addalp)
					if not fx or not fy or not fz then
						fx,fy,fz = camX-x,camY-y,camZ-z
					end
					if eleData.faceRelativeTo == "world" then
						fx,fy,fz = fx-x,fy-y,fz-z
					end
					local filter = eleData.filterShader
					if isElement(filter) then
						dgsSetFilterShaderData(filter,x,y,z,fx,fy,fz,rot,w,h,renderThing,fromcolor(colors))
						renderThing = filter
						colors = white
					end
					dgsDrawMaterialLine3D(x,y,z,fx,fy,fz,renderThing,w,h,colors,rot)
				end
			end
		end
	end
end
addEventHandler("onClientPreRender",root,interfaceRender)

----------------------------------------------------------------
-------------------------OOP Class------------------------------
----------------------------------------------------------------
dgsOOP["dgs-dx3dinterface"] = [[
	getBlendMode = dgsOOP.genOOPFnc("dgs3DInterfaceGetBlendMode"),
	setBlendMode = dgsOOP.genOOPFnc("dgs3DInterfaceSetBlendMode",true),
	getPosition = dgsOOP.genOOPFnc("dgs3DInterfaceGetPosition"),
	setPosition = dgsOOP.genOOPFnc("dgs3DInterfaceSetPosition",true),
	getSize = dgsOOP.genOOPFnc("dgs3DInterfaceGetSize"),
	setSize = dgsOOP.genOOPFnc("dgs3DInterfaceSetSize",true),
	getResolution = dgsOOP.genOOPFnc("dgs3DInterfaceGetResolution"),
	setResolution = dgsOOP.genOOPFnc("dgs3DInterfaceSetResolution",true),
	attachToElement = dgsOOP.genOOPFnc("dgs3DInterfaceAttachToElement",true),
	isAttached = dgsOOP.genOOPFnc("dgs3DInterfaceIsAttached",true),
	getResolution = dgsOOP.genOOPFnc("dgs3DInterfaceGetResolution"),
	setResolution = dgsOOP.genOOPFnc("dgs3DInterfaceSetResolution",true),
	detachFromElement = dgsOOP.genOOPFnc("dgs3DInterfaceDetachFromElement",true),
	setAttachedOffsets = dgsOOP.genOOPFnc("dgs3DInterfaceSetAttachedOffsets",true),
	getAttachedOffsets = dgsOOP.genOOPFnc("dgs3DInterfaceGetAttachedOffsets"),
	setRotation = dgsOOP.genOOPFnc("dgs3DInterfaceSetRotation",true),
	getRotation = dgsOOP.genOOPFnc("dgs3DInterfaceGetRotation"),
	setFaceTo = dgsOOP.genOOPFnc("dgs3DInterfaceSetFaceTo",true),
	getFaceTo = dgsOOP.genOOPFnc("dgs3DInterfaceGetFaceTo"),
]]