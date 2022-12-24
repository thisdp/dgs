dgsLogLuaMemory()
dgsRegisterType("dgs-dxdetectarea","dgsBasic","dgsType2D")
dgsRegisterProperties("dgs-dxdetectarea",{
	checkFunctionImage = 	{	PArg.Material	},
	debugMode = 			{	PArg.Bool	},
})
local loadstring = loadstring
--Dx Functions
local dxDrawImage = dxDrawImage
local dxGetPixelsSize = dxGetPixelsSize
local dxGetPixelColor = dxGetPixelColor
local dxSetRenderTarget = dxSetRenderTarget
local dxGetTextWidth = dxGetTextWidth
--
local dgsTriggerEvent = dgsTriggerEvent
local createElement = createElement
local dgsSetType = dgsSetType
local dgsSetParent = dgsSetParent
local dgsSetData = dgsSetData
local assert = assert
local type = type

detectAreaBuiltIn = {
	default = [[
		return true
	]],
	circle = [[
		return math.sqrt((mxRlt-0.5)^2+(myRlt-0.5)^2)<0.5
	]],
}
function dgsCreateDetectArea(...)
	local sRes = sourceResource or resource
	local x,y,w,h,relative,parent
	if select("#",...) == 1 and type(select(1,...)) == "table" then
		local argTable = ...
		x = argTable.x or argTable[1]
		y = argTable.y or argTable[2]
		w = argTable.width or argTable.w or argTable[3]
		h = argTable.height or argTable.h or argTable[4]
		relative = argTable.relative or argTable.rlt or argTable[5]
		parent = argTable.parent or argTable.p or argTable[6]
	else
		x,y,w,h,relative,parent = ...
	end
	if not x then
		local detectarea = createElement("dgs-dxdetectarea")
		dgsSetType(detectarea,"dgs-dxdetectarea")
		onDGSElementCreate(detectarea,sRes)
		dgsDetectAreaSetFunction(detectarea,detectAreaBuiltIn.default)
		dgsSetData(detectarea,"debugTextureSize",{sW/2,sH/2})
		dgsSetData(detectarea,"debugModeAlpha",128)
		return detectarea
	else
		if not(type(x) == "number") then error(dgsGenAsrt(x,"dgsCreateDetectArea",1,"number")) end
		if not(type(y) == "number") then error(dgsGenAsrt(y,"dgsCreateDetectArea",2,"number")) end
		if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsCreateDetectArea",3,"number")) end
		if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsCreateDetectArea",4,"number")) end
		local detectarea = createElement("dgs-dxdetectarea")
		dgsSetType(detectarea,"dgs-dxdetectarea")
		dgsSetParent(detectarea,parent,true,true)
		dgsSetData(detectarea,"debugMode",false)
		dgsSetData(detectarea,"debugModeAlpha",128)
		calculateGuiPositionSize(detectarea,x,y,relative or false,w,h,relative or false,true)
		dgsTriggerEvent("onDgsCreate",detectarea,sRes)
		dgsDetectAreaSetFunction(detectarea,detectAreaBuiltIn.default)
		return detectarea
	end
end

detectAreaPreDefine = [[
	local args = {...}
	local mxRlt,myRlt,mxAbs,myAbs = args[1],args[2],args[3],args[4]
]]

function dgsDetectAreaDefaultFunction(mxRlt,myRlt,mxAbs,myAbs)
	return true
end

function dgsDetectAreaSetFunction(detectarea,fncStr)
	if dgsGetType(detectarea) ~= "dgs-dxdetectarea" then error(dgsGenAsrt(detectarea,"dgsDetectAreaSetFunction",1,"dgs-dxdetectarea")) end
	if not (dgsIsType(fncStr,"string") or dgsIsType(fncStr,"texture") or dgsIsType(fncStr,"svg")) then error(dgsGenAsrt(fncStr,"dgsDetectAreaSetFunction",2,"string/texture")) end
	if type(fncStr) == "string" then
		fncStr = detectAreaBuiltIn[fncStr] or fncStr
		local fnc,err = loadstring(detectAreaPreDefine..fncStr)
		if not fnc then error(dgsGenAsrt(fnc,"dgsDetectAreaSetFunction",2,_,_,_,"Failed to load function:"..err)) end
		dgsSetData(detectarea,"checkFunction",fnc)
		dgsSetData(detectarea,"checkFunctionImage",nil)
	else
		local pixels = dxGetTexturePixels(fncStr)
		dgsSetData(detectarea,"checkFunction",pixels)
		dgsSetData(detectarea,"checkFunctionImage",fncStr)
	end
	dgsDetectAreaUpdateDebugView(detectarea)
	return true
end

function dgsDetectAreaSetDebugModeEnabled(detectarea,state,alpha)
	if dgsGetType(detectarea) ~= "dgs-dxdetectarea" then error(dgsGenAsrt(detectarea,"dgsDetectAreaSetDebugModeEnabled",1,"dgs-dxdetectarea")) end
	dgsSetData(detectarea,"debugMode",state)
	dgsSetData(detectarea,"debugModeAlpha",alpha or dgsElementData[detectarea].debugModeAlpha)
	if state then
		dgsDetectAreaUpdateDebugView(detectarea)
	elseif isElement(dgsElementData[detectarea].debugTexture) then
		destroyElement(dgsElementData[detectarea].debugTexture)
	end
	return true
end

function dgsDetectAreaGetDebugModeEnabled(detectarea)
	if dgsGetType(detectarea) ~= "dgs-dxdetectarea" then error(dgsGenAsrt(detectarea,"dgsDetectAreaGetDebugModeEnabled",1,"dgs-dxdetectarea")) end
	return dgsElementData[detectarea].debugMode
end

function dgsDetectAreaUpdateDebugView(detectarea)
	if not dgsElementData[detectarea].debugMode then return end
	local checkFunction = dgsElementData[detectarea].checkFunction
	local absSize = dgsElementData[detectarea].absSize or dgsElementData[detectarea].debugTextureSize
	if isElement(dgsElementData[detectarea].debugTexture) then
		local mX,mY = dxGetMaterialSize(dgsElementData[detectarea].debugTexture)
		if mX ~= absSize[1] and mY ~= absSize[2] then
			if isElement(dgsElementData[detectarea].debugTexture) then
				destroyElement(dgsElementData[detectarea].debugTexture)
			end
		end
	end
	if not isElement(dgsElementData[detectarea].debugTexture) then
		local texture = dxCreateEmptyTexture(absSize[1],absSize[2])
		dgsSetData(detectarea,"debugTexture",texture)
	end
	if type(checkFunction) == "function" then
		local pixels = dxGetTexturePixels(dgsElementData[detectarea].debugTexture)
		for i=0,absSize[1]-1 do
			for j=0,absSize[2]-1 do
				local color = checkFunction((i+1)/absSize[1],(j+1)/absSize[2]) and {255,255,255,255} or {0,0,0,0}
				dxSetPixelColor(pixels,i,j,color[1],color[2],color[3],color[4])
			end
		end
		dxSetTexturePixels(dgsElementData[detectarea].debugTexture,pixels)
	else
		dxSetTexturePixels(dgsElementData[detectarea].debugTexture,checkFunction)
	end
	return true
end
----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxdetectarea"] = function(source,x,y,w,h,mx,my,cx,cy,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt)
	local color = 0xFFFFFFFF
	if enabledInherited and mx then
		local checkPixel = eleData.checkFunction
		if checkPixel then
			local _mx,_my = (mx-x)/w,(my-y)/h
			if _mx > 0 and _my > 0 and _mx <= 1 and _my <= 1 then
				if type(checkPixel) == "function" then
					local checkFnc = eleData.checkFunction
					if checkFnc((mx-x)/w,(my-y)/h,mx,my) then
						MouseData.hit = source
						color = 0xFFFF0000
					end
				else
					local px,py = dxGetPixelsSize(checkPixel)
					local pixX,pixY = _mx*px,_my*py
					local r,g,b = dxGetPixelColor(checkPixel,pixX-1,pixY-1)
					if r then
						local gray = (r+g+b)/3
						if gray >= 128 then
							MouseData.hit = source
							color = 0xFFFF0000
						end
					end
				end
			end
		end
	end
	local debugTexture = eleData.debugTexture
	if eleData.debugMode and isElement(debugTexture) then
		dxDrawImage(x,y,w,h,debugTexture,0,0,0,color,isPostGUI,rndtgt)
	end
	return rndtgt,false,mx,my,0,0
end