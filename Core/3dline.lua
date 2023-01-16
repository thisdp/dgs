dgsLogLuaMemory()
dgsRegisterType("dgs-dx3dline","dgsBasic","dgsType3D","dgsTypeWorld3D")
dgsRegisterProperties("dgs-dx3dline",{
	color = 				{	PArg.Color		},
	dimension = 			{	PArg.Number		},
	fadeDistance = 			{	PArg.Number		},
	interior = 				{	PArg.Number		},
	maxDistance = 			{	PArg.Number		},
	position = 				{	{ PArg.Number, PArg.Number, PArg.Number }	},
	rotation = 				{	{ PArg.Number, PArg.Number, PArg.Number }	},
	lineWidth = 			{	PArg.Number		},
})
--Dx Functions
local dxDrawLine3D = dxDrawLine3D
local dxDrawImage = dxDrawImage
local dxSetShaderValue = dxSetShaderValue
--
local getRotationMatrix = getRotationMatrix
local getPositionFromOffsetByRotMat = getPositionFromOffsetByRotMat
local assert = assert
local type = type
local tableInsert = table.insert
local tableRemove = table.remove

function dgsCreate3DLine(...)
	local sRes = sourceResource or resource
	local x,y,z,color,lineWidth,maxDistance
	if select("#",...) == 1 and type(select(1,...)) == "table" then
		local argTable = ...
		x = argTable.x or argTable[1]
		y = argTable.y or argTable[2]
		z = argTable.z or argTable[3]
		rx = argTable.rx or argTable[4]
		ry = argTable.ry or argTable[5]
		rz = argTable.rz or argTable[6]
		lineWidth = argTable.lineWidth or argTable[7]
		color = argTable.color or argTable[8]
		maxDistance = argTable.maxDistance or argTable[9]
	else
		x,y,z,rx,ry,rz,lineWidth,color,maxDistance = ...
	end
	if not(type(x) == "number") then error(dgsGenAsrt(x,"dgsCreate3DLine",1,"number")) end
	if not(type(y) == "number") then error(dgsGenAsrt(y,"dgsCreate3DLine",2,"number")) end
	if not(type(z) == "number") then error(dgsGenAsrt(z,"dgsCreate3DLine",3,"number")) end
	local line3d = createElement("dgs-dx3dline")
	tableInsert(dgsWorld3DTable,line3d)
	dgsSetType(line3d,"dgs-dx3dline")
	dgsElementData[line3d] = {
		position = {x,y,z},
		rotation = {rx or 0,ry or 0,rz or 0},
		color = color or 0xFFFFFFFF,
		maxDistance = maxDistance or 80,
		fadeDistance = maxDistance or 80,
		dimension = -1,
		interior = -1,
		lineWidth = lineWidth or 1,
		lineType = "plane",
		lineData = {},
	}
	onDGSElementCreate(line3d,sRes)
	return line3d
end

function dgs3DLineSetLineType(line,mode)
	if not(dgsGetType(line) == "dgs-dx3dline") then error(dgsGenAsrt(line,"dgs3DLineSetLineType",1,"dgs-dx3dline")) end
	if mode == "plane" or mode == "cylinder" then
		return dgsSetData(line,"lineType",mode)
	end
	return false
end

function dgs3DLineGetLineType(line)
	if not(dgsGetType(line) == "dgs-dx3dline") then error(dgsGenAsrt(line,"dgs3DLineGetLineType",1,"dgs-dx3dline")) end
	return dgsElementData[line].lineType
end

--[[
Line Data Structure:
If StartXYZ don't exist, will use last endXYZ or center
{
	{	startX,	startY,	startZ,	endX,	endY,	endZ,	width,	color,	},
	{	startX,	startY,	startZ,	endX,	endY,	endZ,	width,	color,	},
}
]]
function dgs3DLineAddItem(line,sx,sy,sz,ex,ey,ez,width,color,isRelative)
	if not(dgsGetType(line) == "dgs-dx3dline") then error(dgsGenAsrt(line,"dgs3DLineAddItem",1,"dgs-dx3dline")) end
	if sx or sy or sz then
		if not(type(sx) == "number") then error(dgsGenAsrt(sx,"dgs3DLineAddItem",2,"number")) end
		if not(type(sy) == "number") then error(dgsGenAsrt(sy,"dgs3DLineAddItem",3,"number")) end
		if not(type(sz) == "number") then error(dgsGenAsrt(sz,"dgs3DLineAddItem",4,"number")) end
	end
	if not(type(ex) == "number") then error(dgsGenAsrt(ex,"dgs3DLineAddItem",5,"number")) end
	if not(type(ey) == "number") then error(dgsGenAsrt(ey,"dgs3DLineAddItem",6,"number")) end
	if not(type(ez) == "number") then error(dgsGenAsrt(ez,"dgs3DLineAddItem",7,"number")) end
	local lData = dgsElementData[line].lineData
	local lIndex = #lData+1
	lData[lIndex] = {
		sx,sy,sz,ex,ey,ez,width or lData.lineWidth,color or lData.color,isRelative or false
	}
	return lIndex
end

function dgs3DLineRemoveItem(line,index)
	if not(dgsGetType(line) == "dgs-dx3dline") then error(dgsGenAsrt(line,"dgs3DLineRemoveItem",1,"dgs-dx3dline")) end
	local lData = dgsElementData[line].lineData
	local inRange = index >= 1 and index <= #lData
	if not(type(index) == "number" and inRange) then error(dgsGenAsrt(index,"dgs3DLineRemoveItem",2,"number","1~"..(#lData),inRange and "Out Of Range")) end
	tableRemove(lData,index)
	return true
end

function dgs3DLineSetItemPosition(line,index,sx,sy,sz,ex,ey,ez)
	if not(dgsGetType(line) == "dgs-dx3dline") then error(dgsGenAsrt(line,"dgs3DLineSetItemPosition",1,"dgs-dx3dline")) end
	local lData = dgsElementData[line].lineData
	local inRange = index >= 1 and index <= #lData
	if not(type(index) == "number" and inRange) then error(dgsGenAsrt(index,"dgs3DLineSetItemPosition",2,"number","1~"..(#lData),inRange and "Out Of Range")) end
	local ilData = lData[index]
	if sx or sy or sz then
		if not(type(sx) == "number") then error(dgsGenAsrt(sx,"dgs3DLineSetItemPosition",3,"number")) end
		if not(type(sy) == "number") then error(dgsGenAsrt(sy,"dgs3DLineSetItemPosition",4,"number")) end
		if not(type(sz) == "number") then error(dgsGenAsrt(sz,"dgs3DLineSetItemPosition",5,"number")) end
	end
	if not(type(ex) == "number") then error(dgsGenAsrt(ex,"dgs3DLineSetItemPosition",6,"number")) end
	if not(type(ey) == "number") then error(dgsGenAsrt(ey,"dgs3DLineSetItemPosition",7,"number")) end
	if not(type(ez) == "number") then error(dgsGenAsrt(ez,"dgs3DLineSetItemPosition",8,"number")) end
	ilData[1],ilData[2],ilData[3],ilData[4],ilData[5],ilData[6] = sx,sy,sz,ex,ey,ez
	return true
end

function dgs3DLineGetItemPosition(line,index)
	if not(dgsGetType(line) == "dgs-dx3dline") then error(dgsGenAsrt(line,"dgs3DLineGetItemPosition",1,"dgs-dx3dline")) end
	local lData = dgsElementData[line].lineData
	local inRange = index >= 1 and index <= #lData
	if not(type(index) == "number" and inRange) then error(dgsGenAsrt(index,"dgs3DLineGetItemPosition",2,"number","1~"..(#lData),inRange and "Out Of Range")) end
	local ilData = lData[index]
	return ilData[1],ilData[2],ilData[3],ilData[4],ilData[5],ilData[6]
end

function dgs3DLineSetItemWidth(line,index,width)
	if not(dgsGetType(line) == "dgs-dx3dline") then error(dgsGenAsrt(line,"dgs3DLineSetItemWidth",1,"dgs-dx3dline")) end
	local lData = dgsElementData[line].lineData
	local inRange = index >= 1 and index <= #lData
	if not(type(index) == "number" and inRange) then error(dgsGenAsrt(index,"dgs3DLineSetItemWidth",2,"number","1~"..(#lData),inRange and "Out Of Range")) end
	if not(not width or type(width) == "number") then error(dgsGenAsrt(width,"dgs3DLineSetItemWidth",3,"nil/number")) end
	lData[index][7] = width
	return true
end

function dgs3DLineGetItemWidth(line,index)
	if not(dgsGetType(line) == "dgs-dx3dline") then error(dgsGenAsrt(line,"dgs3DLineGetItemWidth",1,"dgs-dx3dline")) end
	local lData = dgsElementData[line].lineData
	local inRange = index >= 1 and index <= #lData
	if not(type(index) == "number" and inRange) then error(dgsGenAsrt(index,"dgs3DLineGetItemWidth",2,"number","1~"..(#lData),inRange and "Out Of Range")) end
	local ilData = lData[index]
	return ilData[7]
end

function dgs3DLineSetItemColor(line,index,color)
	if not(dgsGetType(line) == "dgs-dx3dline") then error(dgsGenAsrt(line,"dgs3DLineSetItemColor",1,"dgs-dx3dline")) end
	local lData = dgsElementData[line].lineData
	local inRange = index >= 1 and index <= #lData
	if not(type(index) == "number" and inRange) then error(dgsGenAsrt(index,"dgs3DLineSetItemColor",2,"number","1~"..(#lData),inRange and "Out Of Range")) end
	if not(not color or type(color) == "number") then error(dgsGenAsrt(color,"dgs3DLineSetItemColor",3,"nil/number")) end
	lData[index][8] = color
	return true
end

function dgs3DLineGetItemColor(line,index)
	if not(dgsGetType(line) == "dgs-dx3dline") then error(dgsGenAsrt(line,"dgs3DLineGetItemColor",1,"dgs-dx3dline")) end
	local lData = dgsElementData[line].lineData
	local inRange = index >= 1 and index <= #lData
	if not(type(index) == "number" and inRange) then error(dgsGenAsrt(index,"dgs3DLineGetItemColor",2,"number","1~"..(#lData),inRange and "Out Of Range")) end
	local ilData = lData[index]
	return ilData[8]
end

function dgs3DLineAttachToElement(line,element,offX,offY,offZ,offRX,offRY,offRZ)
	if not(dgsGetType(line) == "dgs-dx3dline") then error(dgsGenAsrt(line,"dgs3DLineAttachToElement",1,"dgs-dx3dline")) end
	if not(isElement(element)) then error(dgsGenAsrt(element,"dgs3DLineAttachToElement",2,"element")) end
	local offX,offY,offZ = offX or 0,offY or 0,offZ or 0
	return dgsSetData(line,"attachTo",{element,offX,offY,offZ,offRX,offRY,offRZ})
end

function dgs3DLineIsAttached(line)
	if not(dgsGetType(line) == "dgs-dx3dline") then error(dgsGenAsrt(line,"dgs3DLineIsAttached",1,"dgs-dx3dline")) end
	return dgsElementData[line].attachTo
end

function dgs3DLineDetachFromElement(line)
	if not(dgsGetType(line) == "dgs-dx3dline") then error(dgsGenAsrt(line,"dgs3DLineDetachFromElement",1,"dgs-dx3dline")) end
	return dgsSetData(line,"attachTo",false)
end

function dgs3DLineSetAttachedOffsets(line,offX,offY,offZ,offRX,offRY,offRZ)
	if not(dgsGetType(line) == "dgs-dx3dline") then error(dgsGenAsrt(line,"dgs3DLineSetAttachedOffsets",1,"dgs-dx3dline")) end
	local attachTable = dgsElementData[line].attachTo
	if attachTable then
		local offX,offY,offZ = offX or attachTable[2],offY or attachTable[3],offZ or attachTable[4]
		local offRX,offRY,offRZ = offRX or attachTable[5],offRY or attachTable[6],offRZ or attachTable[7]
		return dgsSetData(line,"attachTo",{attachTable[1],offX,offY,offZ,offRX,offRY,offRZ})
	end
	return false
end

function dgs3DLineGetAttachedOffsets(line,offX,offY,offZ,offRX,offRY,offRZ)
	if not(dgsGetType(line) == "dgs-dx3dline") then error(dgsGenAsrt(line,"dgs3DLineGetAttachedOffsets",1,"dgs-dx3dline")) end
	local attachTable = dgsElementData[line].attachTo
	if attachTable then
		return attachTable[2],attachTable[3],attachTable[4],attachTable[5],attachTable[6],attachTable[7]
	end
	return false
end

function dgs3DLineSetRotation(line,rx,ry,rz)
	if not(dgsGetType(line) == "dgs-dx3dline") then error(dgsGenAsrt(line,"dgs3DLineSetRotation",1,"dgs-dx3dline")) end
	if not(type(rx) == "number") then error(dgsGenAsrt(rx,"dgs3DLineSetRotation",2,"number")) end
	if not(type(ry) == "number") then error(dgsGenAsrt(ry,"dgs3DLineSetRotation",3,"number")) end
	if not(type(rz) == "number") then error(dgsGenAsrt(rz,"dgs3DLineSetRotation",4,"number")) end
	return dgsSetData(line,"rotation",{rx,ry,rz})
end

function dgs3DLineGetRotation(line)
	if not(dgsGetType(line) == "dgs-dx3dline") then error(dgsGenAsrt(line,"dgs3DLineGetRotation",1,"dgs-dx3dline")) end
	local rot = dgsElementData[line].rotation
	return rot[1],rot[2],rot[3]
end

----------------------------------------------------------------
----------------------Cylinder 3D Line--------------------------
----------------------------------------------------------------
local cylinderLineShaderRaw = [[
float3x3 shapeConfig = {
	float3(0, 0, 0),	//Start Pos
	float3(0, 0, 0),	//End Pos
	float3(0, 0, 0),	//Radius
};
float4x4 gProjectionMainScene : PROJECTION_MAIN_SCENE;
float4x4 gViewMainScene : VIEW_MAIN_SCENE;
#define PI 3.1415926535897932384626433832795
#define PI2 6.283185307179586476925286766559

struct VSInput{
    float3 Position : POSITION0;
    float2 TexCoord : TEXCOORD0;
    float4 Diffuse : COLOR0;
};

struct PSInput{
    float4 Position : POSITION0;
    float2 TexCoord : TEXCOORD0;
    float4 Diffuse : COLOR0;
};

float3 findRotation3D(float3 sPos, float3 ePos) {
	float3 dPos = ePos-sPos;
	float3 rot = float3(atan2(dPos.z,length(dPos.xy)),0,-atan2(dPos.x,dPos.y));
	return rot;
}

float4x4 createWorldMatrix(float3 pos, float3 rot){
    float3 cRot, sRot;
    sincos(rot, sRot, cRot);
	float4x4 eleMatrix = float4x4(
        cRot.z * cRot.y - sRot.z * sRot.x * sRot.y, cRot.y * sRot.z + cRot.z * sRot.x * sRot.y, -cRot.x * sRot.y, 0,
        -cRot.x * sRot.z, cRot.z * cRot.x, sRot.x, 0,
        cRot.z * sRot.y + cRot.y * sRot.z * sRot.x, sRot.z * sRot.y - cRot.z * cRot.y * sRot.x, cRot.x * cRot.y, 0,
		pos.x, pos.y, pos.z, 1
	);
    return eleMatrix;
}

float3 getCylinderPosition(float3 inPosition){
    float3 outPosition = inPosition;
    outPosition.z = cos(inPosition.y*PI2);
    outPosition.y = sin(inPosition.y*PI2);
    return outPosition;
}

PSInput VertexShaderFunction(VSInput VS){
    PSInput PS = (PSInput)0;
    VS.Position.xyz = float3(-0.5+VS.TexCoord.xy, 0);
    float3 resultPos = getCylinderPosition(VS.Position.xyz);
	float3 startPos = shapeConfig[0];
	float3 endPos = shapeConfig[1];
	float3 radius = shapeConfig[2];
	resultPos.yz *= radius.x*0.00665;
	resultPos.x *= length(endPos-startPos);
    VS.Position.xyz = resultPos.zyx;
	float3 rot = findRotation3D(startPos,endPos);
	rot.x += PI/2;
    float4x4 sWorld = createWorldMatrix((endPos+startPos)/2,rot);
	PS.Position = mul(mul(mul(float4(VS.Position,1),sWorld),gViewMainScene),gProjectionMainScene);
    PS.TexCoord = VS.TexCoord;
    PS.Diffuse = VS.Diffuse;
    return PS;
}

float4 PixelShaderFunction(PSInput PS) : COLOR0{
    return PS.Diffuse;
}

technique dxDrawImage4D_cylinder_ap{
  pass P0{
    ZEnable = true;
    ZFunc = LessEqual;
    ZWriteEnable = true;
    CullMode = 3;
    ShadeMode = Gouraud;
    AlphaBlendEnable = true;
    SrcBlend = SrcAlpha;
    DestBlend = 6;
    AlphaTestEnable = true;
    AlphaRef = 1;
    AlphaFunc = GreaterEqual;
    Lighting = false;
    FogEnable = false;
    VertexShader = compile vs_2_0 VertexShaderFunction();
    PixelShader  = compile ps_2_0 PixelShaderFunction();
  }
}
]]
cylinderShader3DLine = dxCreateShader(cylinderLineShaderRaw)
dxSetShaderTessellation(cylinderShader3DLine,1,16)
cylinderLineShaderRaw = nil

----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
local dgs3DLineDraw = {
	plane = dxDrawLine3D,
	cylinder = function(startX,startY,startZ,endX,endY,endZ,color,width)
		dxSetShaderValue(cylinderShader3DLine,"shapeConfig",startX,startY,startZ,endX,endY,endZ,width,0,0)
		dxDrawImage(0,0,sW,sH,cylinderShader3DLine,0,0,0,color)	
	end,
}

dgs3DRenderer["dgs-dx3dline"] = function(source)
	local eleData = dgsElementData[source]
	local attachTable = eleData.attachTo
	local posTable = eleData.position
	local rotTable = eleData.rotation
	local wx,wy,wz = posTable[1],posTable[2],posTable[3]
	local wrx,wry,wrz = 0,0,0
	local lineWidth = eleData.lineWidth
	local color = eleData.color
	local lineType = eleData.lineType
	local isRender = true
	if attachTable then
		if isElement(attachTable[1]) then
			if isElementStreamedIn(attachTable[1]) then
				wx,wy,wz = getPositionFromElementOffset(attachTable[1],attachTable[2],attachTable[3],attachTable[4])
				local offrx,offry,offrz = attachTable[5] or 0,attachTable[6] or 0,attachTable[7] or 0
				local rx,ry,rz = getElementRotation(attachTable[1])
				if rx and ry and rz then
					wrx,wry,wrz = rx+offrx,ry+offry,rz+offrz
				end
				eleData.position[1],eleData.position[2],eleData.position[3] = wx,wy,wz
				eleData.rotation[1],eleData.rotation[2],eleData.rotation[3] = wrx,wry,wrz
			else
				isRender = false
			end
		else
			eleData.attachTo = false
		end
	end
	if isRender then
		local maxDistance = eleData.maxDistance
		local camX,camY,camZ = cameraPos[1],cameraPos[2],cameraPos[3]
		local dx,dy,dz = camX-wx,camY-wy,camZ-wz
		local distance = (dx*dx+dy*dy+dz*dz)^0.5
		if distance <= maxDistance and distance > 0 then
			local fadeDistance = eleData.fadeDistance
			local line = eleData.line
			local fadeMulti = 1
			if maxDistance > fadeDistance and distance >= fadeDistance then
				fadeMulti = 1-(distance-fadeDistance)/(maxDistance-fadeDistance)
			end
			local lData = eleData.lineData
			local m11,m12,m13,m21,m22,m23,m31,m32,m33 = getRotationMatrix(wrx,wry,wrz)
			local lastex,lastey,lastez,lastRlt
			local drawFunction = dgs3DLineDraw[lineType]
			for i=1,#lData do
				local lineItem = lData[i]
				local startX,startY,startZ,endX,endY,endZ = 0,0,0,lineItem[4],lineItem[5],lineItem[6]
				local isRelative = lineItem[9]
				local startIsRelative = true
				if lineItem[1] then
					startX,startY,startZ = lineItem[1],lineItem[2],lineItem[3]
					startIsRelative = isRelative
				elseif i ~= 1 then
					startX,startY,startZ = lastex,lastey,lastez
					startIsRelative = lastRlt
				end
				lastex,lastey,lastez,lastRlt = endX,endY,endZ,isRelative
				if startIsRelative then
					startX,startY,startZ = startX*m11+startY*m21+startZ*m31+wx,startX*m12+startY*m22+startZ*m32+wy,startX*m13+startY*m23+startZ*m33+wz
				end
				if isRelative then
					endX,endY,endZ = endX*m11+endY*m21+endZ*m31+wx,endX*m12+endY*m22+endZ*m32+wy,endX*m13+endY*m23+endZ*m33+wz
				end
				drawFunction(startX,startY,startZ,endX,endY,endZ,applyColorAlpha(lineItem[8] or color,fadeMulti),lineItem[7] or lineWidth)
			end
			return true
		end
	end
end