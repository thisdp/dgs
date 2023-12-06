dgsLogLuaMemory()
dgsRegisterType("dgs-dx3dinterface","dgsBasic","dgsType3D","dgsTypeWorld3D")
dgsRegisterProperties("dgs-dx3dinterface",{
	blendMode = 			{	PArg.String		},
	color = 				{	PArg.Color		},
	dimension = 			{	PArg.Number		},
	faceTo = 				{	{ PArg.Number, PArg.Number, PArg.Number }	},
	faceRelativeTo = 		{	PArg.String		},
	fadeDistance = 			{	PArg.Number		},
	interior = 				{	PArg.Number		},
	maxDistance = 			{	PArg.Number		},
	position = 				{	{ PArg.Number, PArg.Number, PArg.Number }	},
	resolution = 			{	{ PArg.Number,PArg.Number }		},
	roll = 					{	PArg.Number		},
	size = 					{	{ PArg.Number, PArg.Number}		},
})
local cos,sin,rad,atan2,acos,deg = math.cos,math.sin,math.rad,math.atan2,math.acos,math.deg
local assert = assert
local type = type
local tableInsert = table.insert
local dxSetShaderValue = dxSetShaderValue
local dxDrawImage = dxDrawImage
local dxDrawMaterialLine3D = dxDrawMaterialLine3D

function dgsCreate3DInterface(...)
	local sRes = sourceResource or resource
	local x,y,z,w,h,resX,resY,color,faceX,faceY,faceZ,distance,roll
	if select("#",...) == 1 and type(select(1,...)) == "table" then
		local argTable = ...
		x = argTable.x or argTable[1]
		y = argTable.y or argTable[2]
		z = argTable.z or argTable[3]
		w = argTable.width or argTable.w or argTable[4]
		h = argTable.height or argTable.h or argTable[5]
		resX = argTable.resolutionX or argTable.resX or argTable[6]
		resY = argTable.resolutionY or argTable.resY or argTable[7]
		color = argTable.color or argTable[8]
		faceX = argTable.faceX or argTable[9]
		faceY = argTable.faceY or argTable[10]
		faceZ = argTable.faceZ or argTable[11]
		distance = argTable.distance or argTable[12]
		roll = argTable.roll or argTable[13]
	else
		x,y,z,w,h,resX,resY,color,faceX,faceY,faceZ,distance,roll = ...
	end
	if not(type(x) == "number") then error(dgsGenAsrt(x,"dgsCreate3DInterface",1,"number")) end
	if not(type(y) == "number") then error(dgsGenAsrt(y,"dgsCreate3DInterface",2,"number")) end
	if not(type(z) == "number") then error(dgsGenAsrt(z,"dgsCreate3DInterface",3,"number")) end
	if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsCreate3DInterface",4,"number")) end
	if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsCreate3DInterface",5,"number")) end
	if not(type(resX) == "number") then error(dgsGenAsrt(resX,"dgsCreate3DInterface",6,"number")) end
	if not(type(resY) == "number") then error(dgsGenAsrt(resY,"dgsCreate3DInterface",7,"number")) end
	local interface = createElement("dgs-dx3dinterface")
	local renderer = dxCreateShader(RendererShader3DInterface)
	tableInsert(dgsWorld3DTable,interface)
	dgsSetType(interface,"dgs-dx3dinterface")
	dgsElementData[interface] = {
		renderBuffer = {},
		position = {x,y,z},
		faceTo = {faceX,faceY,faceZ},
		size = {w,h},
		faceRelativeTo = "self",
		color = color or 0xFFFFFFFF,
		resolution = {resX,resY},
		maxDistance = distance or 200,
		fadeDistance = distance or 180,
		blendMode = "blend",
		attachTo = false,
		dimension = -1,
		interior = -1,
		roll = roll or 0,
		hit = {},
		renderer = renderer,
		doublesided = true,
		enableColorFilter = false,
	}
	dgsAttachToAutoDestroy(renderer,interface,-2)
	dgsApplyGeneralProperties(interface,sRes)
	onDGSElementCreate(interface,sRes)
	dgs3DInterfaceRecreateRenderTarget(interface,true)
	return interface
end

function dgs3DInterfaceRecreateRenderTarget(interface,lateAlloc)
	if isElement(dgsElementData[interface].mainRT) then destroyElement(dgsElementData[interface].mainRT) end
	if lateAlloc then
		dgsSetData(interface,"retrieveRT",true)
	else
		local resolution = dgsElementData[interface].resolution
		local mainRT,err = dgsCreateRenderTarget(resolution[1],resolution[2],true,interface)
		if mainRT == false and resolution[1]*resolution[2] ~= 0 then
			outputDebugString(err,2)
		else
			dxSetTextureEdge(mainRT,"mirror")
			dgsAttachToAutoDestroy(mainRT,interface,-1)
		end
		dxSetShaderValue(dgsElementData[interface].renderer,"sourceTexture",mainRT)
		dgsSetData(interface,"mainRT",mainRT)
		dgsSetData(interface,"retrieveRT",nil)
	end
end

--lnVP = lnVector(xyz)+lnPoint(xyz)
--pnVP = pnVector(xyz)+pnPoint(xyz)
function dgsCalculate3DInterfaceMouse(x,y,z,vx,vy,vz,w,h,lnVP1,lnVP2,lnVP3,lnVP4,lnVP5,lnVP6,roll)
	local offFaceX = atan2(vz,(vx*vx+vy*vy)^0.5)
	local offFaceZ = atan2(vx,vy)
	local cRoll = cos(roll)
	local sRoll = sin(roll)
	local cZ = cos(offFaceZ)
	local sZ = sin(offFaceZ)
	local sX = sin(offFaceX)
	local _x,_y,_z = sX*sZ*cRoll+sRoll*cZ,sX*cZ*cRoll-sRoll*sZ,-cos(offFaceX)*cRoll
	local _h=h
	h=h*0.5
	local x1,y1,z1 = _x*h,_y*h,_z*h
	if lnVP1 then
		local px,py,pz = dgsGetIntersection(lnVP1,lnVP2,lnVP3,lnVP4,lnVP5,lnVP6,vx,vy,vz,x,y,z) --Intersection Point
		if not px then return end
		local model = (vx*vx+vy*vy+vz*vz)^0.5
		vx,vy,vz = vx/model,vy/model,vz/model
		local ltX,ltY,ltZ = y1*vz-vy*z1,z1*vx-vz*x1,x1*vy-vx*y1 --Left Point
		local leftModel = (ltX*ltX+ltY*ltY+ltZ*ltZ)^0.5*2
		ltX,ltY,ltZ = ltX/leftModel*w,ltY/leftModel*w,ltZ/leftModel*w
		local vec1X,vec1Y,vec1Z = ltX+x-px,ltY+y-py,ltZ+z-pz
		local vec2X,vec2Y,vec2Z = px-x+x1,py-y+y1,pz-z+z1
		_x,_y = (vec1X*ltX+vec1Y*ltY+vec1Z*ltZ)/(ltX*ltX+ltY*ltY+ltZ*ltZ)^0.5/w,(vec2X*x1+vec2Y*y1+vec2Z*z1)/(x1*x1+y1*y1+z1*z1)^0.5/_h
		local angle = (x-lnVP4)*lnVP1+(y-lnVP5)*lnVP2+(z-lnVP6)*lnVP3
		local inSide = _x>=0 and _x<=1 and _y>=0 and _y <=1
		return (angle > 0) and inSide,_x,_y,px,py,pz
	end
end

function dgsGetIntersection(lnVP1,lnVP2,lnVP3,lnVP4,lnVP5,lnVP6,pnVP1,pnVP2,pnVP3,pnVP4,pnVP5,pnVP6)
	local vpt = pnVP1*lnVP1+pnVP2*lnVP2+pnVP3*lnVP3
	if vpt ~= 0 then
		local t = (pnVP1*(pnVP4-lnVP4)+pnVP2*(pnVP5-lnVP5)+pnVP3*(pnVP6-lnVP6))/vpt
		return lnVP4+lnVP1*t,lnVP5+lnVP2*t,lnVP6+lnVP3*t
	end
end

--[[
function dgsCalculate3DInterfaceMouse(x,y,z,vx,vy,vz,w,h,lnVP1,lnVP2,lnVP3,lnVP4,lnVP5,lnVP6,roll)
	local offFaceX,offFaceZ = atan2(vz,(vx*vx+vy*vy)^0.5),atan2(vx,vy)
	roll = roll/180*math.pi
	local cRoll,sRoll = cos(roll),sin(roll)
	local cZ,sZ = cos(offFaceZ),sin(offFaceZ)
	local cX,sX = cos(offFaceX),sin(offFaceX)
	local _x,_y,_z = sX*sZ*cRoll+sRoll*cZ,sX*cZ*cRoll-sRoll*sZ,-cX*cRoll
	local width,height = w/2,h/2
	local x1,y1,z1 = _x*height,_y*height,_z*height
	if not lnVP1 then return false end
	local vpt = vx*lnVP1+vy*lnVP2+vz*lnVP3
	if vpt == 0 then return false end
	local t = (vx*(x-lnVP4)+vy*(y-lnVP5)+vz*(z-lnVP6))/vpt
	local px,py,pz = lnVP4+lnVP1*t,lnVP5+lnVP2*t,lnVP6+lnVP3*t
	local model = (vx*vx+vy*vy+vz*vz)^0.5
	local vx,vy,vz = vx/model,vy/model,vz/model
	local ltX,ltY,ltZ = (y1*vz-vy*z1)/2,(z1*vx-vz*x1)/2,(x1*vy-vx*y1)/2 --Left Point
	local vec1X,vec1Y,vec1Z = ltX+x-px,ltY+y-py,ltZ+z-pz
	local vec2X,vec2Y,vec2Z = px-x+x1,py-y+y1,pz-z+z1
	local _x,_y = (vec1X*ltX+vec1Y*ltY+vec1Z*ltZ)/width/w,(vec2X*x1+vec2Y*y1+vec2Z*z1)/height/h
	local angle = (x-lnVP4)*lnVP1+(y-lnVP5)*lnVP2+(z-lnVP6)*lnVP3
	local inSide = _x>=0 and _x<=1 and _y>=0 and _y <=1
	return (angle > 0) and inSide,_x,_y,px,py,pz
end
]]

function dgs3DInterfaceCalculateMousePosition(interface)-- to delete
	local eleData = dgsElementData[interface]
	local pos = eleData.position
	local size = eleData.size
	local faceTo = eleData.faceTo
	local x,y,z,w,h,fx,fy,fz,roll = pos[1],pos[2],pos[3],size[1],size[2],faceTo[1],faceTo[2],faceTo[3],eleData.roll
	if x and y and z and w and h then
		local lnVP1,lnVP2,lnVP3,lnVP4,lnVP5,lnVP6 --,lnVec123,lnPnt123
		local camX,camY,camZ = cameraPos[1],cameraPos[2],cameraPos[3]
		if not fx or not fy or not fz then
			fx,fy,fz = camX-x,camY-y,camZ-z
		end
		if eleData.faceRelativeTo == "world" then
			fx,fy,fz = fx-x,fy-y,fz-z
		end
		if MouseData.cursorPos3D[0] then	--Is cursor 3d position available
			lnVP1,lnVP2,lnVP3,lnVP4,lnVP5,lnVP6 = MouseData.cursorPos3D[1]-camX,MouseData.cursorPos3D[2]-camY,MouseData.cursorPos3D[3]-camZ,camX,camY,camZ
			local isHit,hitX,hitY,hx,hy,hz = dgsCalculate3DInterfaceMouse(x,y,z,fx,fy,fz,w,h,lnVP1,lnVP2,lnVP3,lnVP4,lnVP5,lnVP6,roll)
			return hitX,hitY,hx,hy,hz,isHit
		end
	end
	return false
end

function dgs3DInterfaceProcessLineOfSight(interface,sx,sy,sz,ex,ey,ez)
	local eleData = dgsElementData[interface]
	local pos = eleData.position
	local size = eleData.size
	local faceTo = eleData.faceTo
	local x,y,z,w,h,fx,fy,fz,roll = pos[1],pos[2],pos[3],size[1],size[2],faceTo[1],faceTo[2],faceTo[3],eleData.roll
	if x and y and z and w and h then
		local lnVP1,lnVP2,lnVP3,lnVP4,lnVP5,lnVP6 = ex-sx,ey-sy,ez-sz,sx,sy,sz
		local camX,camY,camZ = cameraPos[1],cameraPos[2],cameraPos[3]
		if not fx or not fy or not fz then
			fx,fy,fz = camX-x,camY-y,camZ-z
		end
		if eleData.faceRelativeTo == "world" then
			fx,fy,fz = fx-x,fy-y,fz-z
		end
		local isHit,hitX,hitY,hx,hy,hz = dgsCalculate3DInterfaceMouse(x,y,z,fx,fy,fz,w,h,lnVP1,lnVP2,lnVP3,lnVP4,lnVP5,lnVP6,roll)
		return hitX,hitY,hx,hy,hz,isHit
	end
	return false
end

function dgs3DInterfaceSetRoll(interface,roll)
	if not dgsIsType(interface,"dgs-dx3dinterface") then error(dgsGenAsrt(interface,"dgs3DInterfaceSetRoll",1,"dgs-dx3dinterface")) end
	if not (type(roll) == "number") then error(dgsGenAsrt(roll,"dgs3DInterfaceSetRoll",2,"number")) end
	return dgsSetData(interface,"roll",roll)
end

function dgs3DInterfaceGetRoll(interface)
	if not dgsIsType(interface,"dgs-dx3dinterface") then error(dgsGenAsrt(interface,"dgs3DInterfaceGetRoll",1,"dgs-dx3dinterface")) end
	return dgsElementData[interface].roll
end

function dgs3DInterfaceSetDoublesided(interface,isDoublesided)
	assert(dgsGetType(interface) == "dgs-dx3dinterface","Bad argument @dgs3DInterfaceSetDoublesided at argument 1, expect a dgs-dx3dinterface got "..dgsGetType(interface))
	dgsSetData(interface,"doublesided",isDoublesided)
	return dxSetShaderValue(dgsElementData[interface].renderer,"doublesided",isDoublesided == true)
end

function dgs3DInterfaceGetDoublesided(interface)
	if not dgsIsType(interface,"dgs-dx3dinterface") then error(dgsGenAsrt(interface,"dgs3DInterfaceGetDoublesided",1,"dgs-dx3dinterface")) end
	return dgsElementData[interface].doublesided
end

function dgs3DInterfaceSetFaceTo(interface,fx,fy,fz,relativeTo)
	assert(dgsGetType(interface) == "dgs-dx3dinterface","Bad argument @dgs3DInterfaceSetFaceTo at argument 1, expect a dgs-dx3dinterface got "..dgsGetType(interface))
	if not fx and not fy and not fz then
		return dgsSetData(interface,"faceTo",{})
	else
		assert(type(fx) == "number","Bad argument @dgs3DInterfaceSetFaceTo at argument 2, expect a number got "..dgsGetType(fx))
		assert(type(fy) == "number","Bad argument @dgs3DInterfaceSetFaceTo at argument 3, expect a number got "..dgsGetType(fy))
		assert(type(fz) == "number","Bad argument @dgs3DInterfaceSetFaceTo at argument 4, expect a number got "..dgsGetType(fz))
		relativeTo = relativeTo == "world" and "world" or "self"
		return dgsSetData(interface,"faceTo",{fx,fy,fz}) and dgsSetData(interface,"faceRelativeTo",relativeTo)
	end
end

function dgs3DInterfaceGetFaceTo(interface)
	if not dgsIsType(interface,"dgs-dx3dinterface") then error(dgsGenAsrt(interface,"dgs3DInterfaceGetFaceTo",1,"dgs-dx3dinterface")) end
	local faceTo = dgsElementData[interface].faceTo or {}
	local faceRelativeTo = dgsElementData[interface].faceRelativeTo or "self"
	return faceTo[1],faceTo[2],faceTo[3],faceRelativeTo
end

function dgs3DInterfaceSetBlendMode(interface,blend)
	if not dgsIsType(interface,"dgs-dx3dinterface") then error(dgsGenAsrt(interface,"dgs3DInterfaceSetBlendMode",1,"dgs-dx3dinterface")) end
	if not (type(blend) == "string" and blendModeBuiltIn[blend]) then error(dgsGenAsrt(blend,"dgs3DInterfaceSetBlendMode",2,"string",blendModeBuiltIn[blend] and "blend/add/modulate_add/overwrite")) end
	return dgsSetData(interface,"blendMode",blend)
end

function dgs3DInterfaceGetBlendMode(interface)
	if not dgsIsType(interface,"dgs-dx3dinterface") then error(dgsGenAsrt(interface,"dgs3DInterfaceGetBlendMode",1,"dgs-dx3dinterface")) end
	return dgsElementData[interface].blendMode
end

function dgs3DInterfaceSetSize(interface,w,h)
	if not dgsIsType(interface,"dgs-dx3dinterface") then error(dgsGenAsrt(interface,"dgs3DInterfaceSetSize",1,"dgs-dx3dinterface")) end
	if not(type(w) == "number") then error(dgsGenAsrt(w,"dgs3DInterfaceSetSize",2,"number")) end
	if not(type(h) == "number") then error(dgsGenAsrt(h,"dgs3DInterfaceSetSize",3,"number")) end
	return dgsSetData(interface,"size",{w,h})
end

function dgs3DInterfaceGetSize(interface)
	if not dgsIsType(interface,"dgs-dx3dinterface") then error(dgsGenAsrt(interface,"dgs3DInterfaceGetSize",1,"dgs-dx3dinterface")) end
	local size = dgsElementData[interface].size
	return size[1],size[2]
end

function dgs3DInterfaceSetResolution(interface,resw,resh)
	if not dgsIsType(interface,"dgs-dx3dinterface") then error(dgsGenAsrt(interface,"dgs3DInterfaceSetResolution",1,"dgs-dx3dinterface")) end
	if not(type(resw) == "number") then error(dgsGenAsrt(resw,"dgs3DInterfaceSetResolution",2,"number")) end
	if not(type(resh) == "number") then error(dgsGenAsrt(resh,"dgs3DInterfaceSetResolution",3,"number")) end
	dgsSetData(interface,"resolution",{resw,resh})
	dgs3DInterfaceRecreateRenderTarget(interface)
	return true
end

function dgs3DInterfaceGetResolution(interface)
	if not dgsIsType(interface,"dgs-dx3dinterface") then error(dgsGenAsrt(interface,"dgs3DInterfaceGetResolution",1,"dgs-dx3dinterface")) end
	local size = dgsElementData[interface].resolution
	return size[1],size[2]
end

function dgs3DInterfaceAttachToElement(interface,element,offX,offY,offZ,offFaceX,offFaceY,offFaceZ)
	if not dgsIsType(interface,"dgs-dx3dinterface") then error(dgsGenAsrt(interface,"dgs3DInterfaceAttachToElement",1,"dgs-dx3dinterface")) end
	if not isElement(element) then error(dgsGenAsrt(element,"dgs3DInterfaceAttachToElement",2,"element")) end
	offX,offY,offZ = offX or 0,offY or 0,offZ or 0
	offFaceX,offFaceY,offFaceZ = offFaceX or 0,offFaceY or 1,offFaceZ or 0
	return dgsSetData(interface,"attachTo",{element,offX,offY,offZ,offFaceX,offFaceY,offFaceZ})
end

function dgs3DInterfaceIsAttached(interface)
	if not dgsIsType(interface,"dgs-dx3dinterface") then error(dgsGenAsrt(interface,"dgs3DInterfaceIsAttached",1,"dgs-dx3dinterface")) end
	return dgsElementData[interface].attachTo
end

function dgs3DInterfaceDetachFromElement(interface)
	if not dgsIsType(interface,"dgs-dx3dinterface") then error(dgsGenAsrt(interface,"dgs3DInterfaceDetachFromElement",1,"dgs-dx3dinterface")) end
	return dgsSetData(interface,"attachTo",false)
end

function dgs3DInterfaceSetAttachedOffsets(interface,offX,offY,offZ,offFaceX,offFaceY,offFaceZ)
	if not dgsIsType(interface,"dgs-dx3dinterface") then error(dgsGenAsrt(interface,"dgs3DInterfaceSetAttachedOffsets",1,"dgs-dx3dinterface")) end
	local attachTable = dgsElementData[interface].attachTo
	if attachTable then
		offX,offY,offZ = offX or attachTable[2],offY or attachTable[3],offZ or attachTable[4]
		offFaceX,offFaceY,offFaceZ = offFaceX or attachTable[5],offFaceY or attachTable[6],offFaceZ or attachTable[7]
		return dgsSetData(interface,"attachTo",{attachTable[1],offX,offY,offZ,offFaceX,offFaceY,offFaceZ})
	end
	return false
end

function dgs3DInterfaceGetAttachedOffsets(interface)
	if not dgsIsType(interface,"dgs-dx3dinterface") then error(dgsGenAsrt(interface,"dgs3DInterfaceGetAttachedOffsets",1,"dgs-dx3dinterface")) end
	local attachTable = dgsElementData[interface].attachTo
	if attachTable then
		local offX,offY,offZ = attachTable[2],attachTable[3],attachTable[4]
		local offFaceX,offFaceY,offFaceZ = attachTable[5],attachTable[6],attachTable[7]
		return offX,offY,offZ,offFaceX,offFaceY,offFaceZ
	end
	return false
end
----------------------------------------------------------------
----------------3D Interface Renderer Shader--------------------
----------------------------------------------------------------
function dgsDrawMaterialLine3D(x,y,z,vx,vy,vz,material,w,h,color,roll)
	local offFaceX = atan2(vz,(vx*vx+vy*vy)^0.5)
	local offFaceZ = atan2(vx,vy)
	local cRoll = cos(roll)*h*0.5
	local sRoll = sin(roll)*h*0.5
	local cZ = cos(offFaceZ)
	local sZ = sin(offFaceZ)
	local cX = cos(offFaceX)
	local sX = sin(offFaceX)
	local x1,y1,z1 = sX*cRoll*sZ + cZ*sRoll, sX*cRoll*cZ - sZ*sRoll, -cX*cRoll
	dxDrawMaterialLine3D(x-x1,y-y1,z-z1,x+x1,y+y1,z+z1,material,w,color,x+vx,y+vy,z+vz)
end

local rightBottom3D,rightTop3D,leftBottom3D,leftTop3D = {0,0,0,0,0,1},{0,0,0,0,0,0},{0,0,0,0,1,1},{0,0,0,0,1,0}
function dgsDrawMaterialLine3DPrimitive(x,y,z,vx,vy,vz,material,w,h,color,roll)
	local offFaceX = atan2(vz,(vx*vx+vy*vy)^0.5)
	local offFaceZ = atan2(vx,vy)
	local cRoll = cos(roll)
	local sRoll = sin(roll)
	local cZ = cos(offFaceZ)
	local sZ = sin(offFaceZ)
	local sX = sin(offFaceX)
	local _x,_y,_z = sX*sZ*cRoll+sRoll*cZ,sX*cZ*cRoll-sRoll*sZ,-cos(offFaceX)*cRoll
	w,h = w/2,h/2
	local topX,topY,topZ = _x*h,_y*h,_z*h
	local leftX,leftY,leftZ = topY*vz-vy*topZ,topZ*vx-vz*topX,topX*vy-vx*topY --Left Point
	local leftModel = (leftX*leftX+leftY*leftY+leftZ*leftZ)^0.5
	leftX,leftY,leftZ = leftX/leftModel*w,leftY/leftModel*w,leftZ/leftModel*w
	rightBottom3D[1]  = leftX+topX+x
	rightBottom3D[2]  = leftY+topY+y
	rightBottom3D[3]  = leftZ+topZ+z
	rightBottom3D[4]  = color
	rightTop3D[1]  = leftX-topX+x
	rightTop3D[2]  = leftY-topY+y
	rightTop3D[3]  = leftZ-topZ+z
	rightTop3D[4]  = color
	leftBottom3D[1]  = -leftX+topX+x
	leftBottom3D[2]  = -leftY+topY+y
	leftBottom3D[3]  = -leftZ+topZ+z
	leftBottom3D[4]  = color
	leftTop3D[1]  = -leftX-topX+x
	leftTop3D[2]  = -leftY-topY+y
	leftTop3D[3]  = -leftZ-topZ+z
	leftTop3D[4]  = color
	dxDrawMaterialPrimitive3D("trianglestrip",material,false,leftTop3D,leftBottom3D,rightTop3D,rightBottom3D)
end

RendererShader3DInterface = [[
float3 colorFilter = float3(1,1,1);
texture sourceTexture;

sampler2D SamplerTex = sampler_state{
    Texture = sourceTexture;
    MipFilter = Linear;
    MinFilter = Linear;
    MagFilter = Linear;
    AddressU = Mirror;
    AddressV = Mirror;
};

float4 colorFilterRemover(float4 color:COLOR0, float2 UV:TEXCOORD0) : COLOR0{
	color *= tex2D(SamplerTex, UV);
	color.rgb /= colorFilter;
	return color;
}

technique cFilterRemover{
	pass P0{
		PixelShader = compile ps_2_0 colorFilterRemover();
	}
}
]]
----------------------------------------------------------------
-----------------------PropertyListener-------------------------
----------------------------------------------------------------
dgsOnPropertyChange["dgs-dx3dinterface"] = {}
----------------------------------------------------------------
-----------------------VisibilityManage-------------------------
----------------------------------------------------------------
dgsOnVisibilityChange["dgs-dx3dinterface"] = function(dgsElement,selfVisibility,inheritVisibility)
	if not selfVisibility or not inheritVisibility then
		dgs3DInterfaceRecreateRenderTarget(dgsElement,true)
	end
end
----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dx3dinterface"] = function(source,x,y,w,h,mx,my,cx,cy,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI)
	if eleData.retrieveRT then
		dgs3DInterfaceRecreateRenderTarget(source)
	end
	local rndtgt = eleData.mainRT
	local hitData = eleData.hit
	hitData[1] = false
	if eleData.cameraDistance and eleData.cameraDistance <= eleData.maxDistance and mx then
		eleData = dgsElementData[source]
		local pos = eleData.position
		local size = eleData.size
		local faceTo = eleData.faceTo
		local resolution = eleData.resolution
		x,y,z,w,h = pos[1],pos[2],pos[3],size[1],size[2]
		local fx,fy,fz,roll = faceTo[1],faceTo[2],faceTo[3],eleData.roll
		local isHit,hitX,hitY,hx,hy,hz
		if x and y and z and w and h then
			local camX,camY,camZ = cameraPos[1],cameraPos[2],cameraPos[3]
			if not fx or not fy or not fz then fx,fy,fz = camX-x,camY-y,camZ-z end
			if eleData.faceRelativeTo == "world" then fx,fy,fz = fx-x,fy-y,fz-z end
			if MouseData.cursorPos3D[0] then	--Is cursor 3d position available
				local lnVP1,lnVP2,lnVP3,lnVP4,lnVP5,lnVP6 = MouseData.cursorPos3D[1]-camX,MouseData.cursorPos3D[2]-camY,MouseData.cursorPos3D[3]-camZ,camX,camY,camZ
				isHit,hitX,hitY,hx,hy,hz = dgsCalculate3DInterfaceMouse(x,y,z,fx,fy,fz,w,h,lnVP1,lnVP2,lnVP3,lnVP4,lnVP5,lnVP6,roll)
				hitX,hitY = hitX*resolution[1],hitY*resolution[2]
			end
		end
		hitData[1] = isHit
		hitData[2] = hitX
		hitData[3] = hitY
		hitData[4] = hx
		hitData[5] = hy
		hitData[6] = hz
		local camX,camY,camZ = cameraPos[1],cameraPos[2],cameraPos[3]
		local dx,dy,dz = camX-hx,camY-hy,camZ-hz
		local distance = (dx*dx+dy*dy+dz*dz)^0.5
		local oldPos = MouseData.hitData3D
		if (isElement(MouseData.lock3DInterface) and MouseData.lock3DInterface == source) or ((not oldPos[0] or distance <= oldPos[4]) and isHit and not MouseData.click.left) then
			MouseData.hit = source
			MouseData.hitData3D[0] = true
			MouseData.hitData3D[1] = hx
			MouseData.hitData3D[2] = hy
			MouseData.hitData3D[3] = hz
			MouseData.hitData3D[4] = distance
			MouseData.hitData3D[5] = source
			eleData.cursorPosition[0] = dgsRenderInfo.frames+1
			mx,my = hitX,hitY
			eleData.cursorPosition[1],eleData.cursorPosition[2] = mx,my
		end
	end
	if rndtgt then
		dxSetRenderTarget(rndtgt,true)
	end
	dxSetRenderTarget()
	return rndtgt,false,mx,my,0,0
end

dgs3DRenderer["dgs-dx3dinterface"] = function(source)
	local eleData = dgsElementData[source]
	local dimension = eleData.dimension
	if eleData.visible then
		if eleData.retrieveRT then
			dgs3DInterfaceRecreateRenderTarget(source)
		end
		local faceTo = eleData.faceTo
		local pos = eleData.position
		local attachTable = eleData.attachTo
		if attachTable then
			local element,offX,offY,offZ,offFaceX,offFaceY,offFaceZ = attachTable[1],attachTable[2],attachTable[3],attachTable[4],attachTable[5],attachTable[6],attachTable[7]
			if not isElement(element) then
				eleData.attachTo = false
			else
				local ex,ey,ez = getElementPosition(element)
				local tmpX,tmpY,tmpZ = getPositionFromElementOffset(element,offFaceX,offFaceY,offFaceZ)
				pos[1],pos[2],pos[3] = getPositionFromElementOffset(element,offX,offY,offZ)
				faceTo[1],faceTo[2],faceTo[3] = tmpX-ex,tmpY-ey,tmpZ-ez
			end
		end
		local size = eleData.size
		local x,y,z,w,h,fx,fy,fz,roll = pos[1],pos[2],pos[3],size[1],size[2],faceTo[1],faceTo[2],faceTo[3],eleData.roll
		eleData.hit[1] = false
		if x and y and z and w and h then
			self = source
			local camX,camY,camZ = cameraPos[1],cameraPos[2],cameraPos[3]
			local dx,dy,dz = camX-x,camY-y,camZ-z
			local cameraDistance = (dx*dx+dy*dy+dz*dz)^0.5
			eleData.cameraDistance = cameraDistance
			if cameraDistance <= eleData.maxDistance then
				local addalp = 1
				if cameraDistance >= eleData.fadeDistance then
					addalp = 1-(cameraDistance-eleData.fadeDistance)/(eleData.maxDistance-eleData.fadeDistance)
				end
				if not fx or not fy or not fz then
					fx,fy,fz = camX-x,camY-y,camZ-z
				end
				if eleData.faceRelativeTo == "world" then
					fx,fy,fz = fx-x,fy-y,fz-z
				end
				if eleData.mainRT then
					if eleData.enableColorFilter then
						dgsDrawMaterialLine3D(x,y,z,fx,fy,fz,eleData.mainRT,w,h,applyColorAlpha(eleData.color,eleData.alpha*addalp),roll)
					else
						dxSetShaderValue(eleData.renderer,"colorFilter",colorFilter)
						dgsDrawMaterialLine3D(x,y,z,fx,fy,fz,eleData.renderer,w,h,applyColorAlpha(eleData.color,eleData.alpha*addalp),roll)
					end
				end
				return true
			end
		end
	end
end