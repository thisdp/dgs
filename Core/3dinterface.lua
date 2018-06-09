local cos,sin,rad,atan2 = math.cos,math.sin,math.rad,math.atan2

function dgsCreate3DInterface(x,y,z,w,h,resolX,resolY,color,faceX,faceY,faceZ,distance)
	assert(tonumber(x),"Bad argument @dgsCreate3DInterface at argument 1, expect number got "..type(x))
	assert(tonumber(y),"Bad argument @dgsCreate3DInterface at argument 2, expect number got "..type(y))
	assert(tonumber(y),"Bad argument @dgsCreate3DInterface at argument 3, expect number got "..type(z))
	assert(tonumber(w),"Bad argument @dgsCreate3DInterface at argument 4, expect number got "..type(w))
	assert(tonumber(h),"Bad argument @dgsCreate3DInterface at argument 5, expect number got "..type(h))
	assert(tonumber(resolX),"Bad argument @dgsCreate3DInterface at argument 6, expect number got "..type(w))
	assert(tonumber(resolY),"Bad argument @dgsCreate3DInterface at argument 7, expect number got "..type(h))
	local interface = createElement("dgs-dx3dinterface")
	table.insert(dx3DInterfaceTable,interface)
	dgsSetType(interface,"dgs-dx3dinterface")
	dgsSetData(interface,"position",{x,y,z})
	dgsSetData(interface,"faceTo",{faceX,faceY,faceZ})
	dgsSetData(interface,"size",{w,h})
	dgsSetData(interface,"color",color or tocolor(255,255,255,255))
	dgsSetData(interface,"resolution",{resolX,resolY})
	dgsSetData(interface,"maxDistance",distance or 100)
	local rndTgt = dxCreateRenderTarget(resolX,resolY,true)
	dgsSetData(interface,"renderTarget_parent",rndTgt)
	triggerEvent("onDgsCreate",interface)
	return interface
end


function dgsDrawMaterialLine3D(x,y,z,vx,vy,vz,material,w,h,color,lnVec,lnPnt)
	local rx = atan2(vz,(vx^2+vy^2)^0.5)
	local rz = atan2(vx,vy)
	local _h=h
	h=h/2
	local x1,y1,z1 = sin(rx)*sin(rz)*h,sin(rx)*cos(rz)*h,-cos(rx)*h
	dxDrawMaterialLine3D(x-x1,y-y1,z-z1,x+x1,y+y1,z+z1,material,w,tocolor(255,255,255,255),x+vx,y+vy,z+vz)
	if lnVec and lnPnt then
		local px,py,pz = dgsGetIntersection(lnVec,lnPnt,{vx,vy,vz},{x,y,z}) --Intersection Point
		local model = (vx^2+vy^2+vz^2)^0.5
		local vx,vy,vz = vx/model,vy/model,vz/model
		local ltX,ltY,ltZ = y1*vz-vy*z1,z1*vx-vz*x1,x1*vy-vx*y1 --Left Point
		local vec1X,vec1Y,vec1Z = ltX+x-px,ltY+y-py,ltZ+z-pz
		local vec2X,vec2Y,vec2Z = px-x+x1,py-y+y1,pz-z+z1
		local _x,_y = (vec1X*ltX+vec1Y*ltY+vec1Z*ltZ)/(ltX^2+ltY^2+ltZ^2)^0.5/w,(vec2X*x1+vec2Y*y1+vec2Z*z1)/(x1^2+y1^2+z1^2)^0.5/_h
		local hit = false
		local angle = (x-lnPnt[1])*lnVec[1]+(y-lnPnt[2])*lnVec[2]+(z-lnPnt[3])*lnVec[3]
		local inSide = _x>=0 and _x<=1 and _y>=0 and _y <=1
		return (angle > 0) and inSide,_x,_y
	end
end

function dgsGetIntersection(lnVec,lnPnt,pnVec,pnPnt)
	local vpt = (pnVec[1]*lnVec[1]+pnVec[2]*lnVec[2]+pnVec[3]*lnVec[3])
	if vpt ~= 0 then
		local t = (pnVec[1]*(pnPnt[1]-lnPnt[1])+pnVec[2]*(pnPnt[2]-lnPnt[2])+pnVec[3]*(pnPnt[3]-lnPnt[3]))/vpt
		return lnPnt[1]+lnVec[1]*t,lnPnt[2]+lnVec[2]*t,lnPnt[3]+lnVec[3]*t
	end
end