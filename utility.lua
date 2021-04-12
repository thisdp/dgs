local cos,sin,rad,atan2,deg = math.cos,math.sin,math.rad,math.atan2,math.deg
local gsub,sub,len,find,format,byte = string.gsub,string.sub,string.len,string.find,string.format,byte
local utf8Len,utf8Byte,utf8Sub = utf8.len,utf8.byte,utf8.sub
local setmetatable,ipairs,pairs = setmetatable,ipairs,pairs
local tableInsert = table.insert
local tableRemove = table.remove
local pi180 = math.pi/180
sW,sH = guiGetScreenSize()
_dxDrawImageSection = dxDrawImageSection
_dxDrawImage = dxDrawImage
_dxCreateTexture = dxCreateTexture
_dxCreateShader = dxCreateShader
_createElement = createElement
_dxCreateRenderTarget = dxCreateRenderTarget
__createElement = _createElement
__dxCreateShader = _dxCreateShader
__dxCreateTexture = _dxCreateTexture
__dxCreateRenderTarget = _dxCreateRenderTarget
__dxDrawImageSection = dxDrawImageSection
__dxDrawImage = dxDrawImage
ClientInfo = {
	SupportedPixelShader={}
}
dgs = exports[getResourceName(getThisResource())]

-------Built-in DX Fonts
fontBuiltIn = {
	["default"]=true,
	["default-bold"]=true,
	["clear"]=true,
	["arial"]=true,
	["sans"]=true,
	["pricedown"]=true,
	["bankgothic"]=true,
	["diploma"]=true,
	["beckett"]=true,
}

-------Built-in Blend Modes
blendModeBuiltIn = {
	blend = "blend",
	add = "add",
	modulate_add = "modulate_add",
	overwrite = "overwrite",
}
------Built-in Layers
layerBuiltIn = {
	top = true,
	center = true,
	bottom = true,
}
-------Built-in Easing Functions
easingBuiltIn = {
	Linear = true,
	InQuad = true,
	OutQuad = true,
	InOutQuad = true,
	OutInQuad = true,
	InElastic = true,
	OutElastic = true,
	InOutElastic = true,
	OutInElastic = true,
	InBack = true,
	OutBack = true,
	InOutBack = true,
	OutInBack = true,
	InBounce = true,
	OutBounce = true,
	InOutBounce = true,
	OutInBounce = true,
	SineCurve = true,
	CosineCurve = true,
}
-------Built-in Cursor Types
cursorTypesBuiltIn = {
	arrow = true,
	sizing_ns = true,
	sizing_ew = true,
	sizing_nwse = true,
	sizing_nesw = true,
	text = true,
	move = true,
	pointer = true,
}
-------DGS Built-in Texture
DGSBuiltInTex = {
	transParent_1x1 = dxCreateTexture(1,1,"dxt5"),
}

-------DEBUG
addCommandHandler("debugdgs",function(command,arg)
	if not arg or arg == "1" then
		debugMode = (not getElementData(localPlayer,"DGS-DEBUG") or arg == "1") and 1 or false
		setElementData(localPlayer,"DGS-DEBUG",debugMode,false)
		outputChatBox("[DGS]Debug Mode "..(debugMode and "#00FF00Enabled" or "#FF0000Disabled"),255,255,255,true)
	elseif arg == "2" then
		debugMode = 2
		setElementData(localPlayer,"DGS-DEBUG",2,false)
		outputChatBox("[DGS]Debug Mode "..(debugMode and "#00FF00Enabled ( Mode 2 )"),255,255,255,true)
	elseif arg == "3" then
		debugMode = 3
		setElementData(localPlayer,"DGS-DEBUG",3,false)
		outputChatBox("[DGS]Debug Mode "..(debugMode and "#00FF00Enabled ( Mode 3 )"),255,255,255,true)
	elseif arg == "c" then
		local comp = not getElementData(localPlayer,"DGS-DEBUG-C")
		outputChatBox("[DGS]Debug Mode For Compatibility Check "..(comp and "#00FF00Enabled" or "#FF0000Disabled"),255,255,255,true)
		setElementData(localPlayer,"DGS-DEBUG-C",comp,false)
	end
end)

debugMode = getElementData(localPlayer,"DGS-DEBUG")
--------------------------------Element Utility
--------Element Pool
externalElementPool = {}
function dgsPushElement(element,eleType,sRes)
	eleType = eleType or dgsGetType(element)
	local sourceRes = sRes or sourceResource or resource
	externalElementPool[sourceRes] = externalElementPool[sourceRes] or {}
	externalElementPool[sourceRes][eleType] = externalElementPool[sourceRes][eleType] or {}
	local elePool = externalElementPool[sourceRes][eleType]
	elePool[#elePool+1] = element
	return true
end

function dgsPopElement(eleType,sRes)
	eleType = eleType or dgsGetType(element)
	local sourceRes = sRes or sourceResource or resource
	externalElementPool[sourceRes] = externalElementPool[sourceRes] or {}
	externalElementPool[sourceRes][eleType] = externalElementPool[sourceRes][eleType] or {}
	local elePool = externalElementPool[sourceRes][eleType]
	local ele = elePool[#elePool]
	if ele then
		elePool[#elePool] = nil
		return ele
	else
		return false
	end
end

function isMaterial(ele)
	local eleType = dgsGetType(ele)
	return eleType == "shader" or eleType == "texture" or eleType == "render-target-texture"
end

dgsElementLogger = {}	--0:Empty texture 1:texture; 2:shader
dgsElementKeeper = {}
function dxCreateEmptyTexture(width,height,sRes)
	local texture
	if sRes ~= false then	--Read the data instead of create from path, and create remotely
		sourceResource = sRes or sourceResource
		if dgsElementKeeper[sourceResource] then
			local sourceResRoot = getResourceRootElement(sourceResource)
			local _sourceResource = sourceResource
			triggerEvent("onDgsRequestCreateRemoteElement",sourceResRoot,"texture",width,height)
			sourceResource = _sourceResource
			texture = dgsPopElement("texture",sourceResource)
		end
	end
	if not texture then
		texture = __dxCreateTexture(width,height)
		dgsElementLogger[texture] = {0,false,texture}	--Log internally created texture
		addEventHandler("onClientElementDestroy",texture,function()
			dgsElementLogger[texture] = nil	--Clear logging
		end,false)
		return texture
	else
		return texture
	end
end

function dxCreateTexture(pathOrData,sRes)
	local texture
	if sRes ~= false then	--Read the data instead of create from path, and create remotely
		sourceResource = sRes or sourceResource
		if dgsElementKeeper[sourceResource] then
			local textureData
			if fileExists(pathOrData) then
				local f = fileOpen(pathOrData,true)
				textureData = fileRead(f,fileGetSize(f))
				fileClose(f)
			else
				textureData = pathOrData
			end
			local sourceResRoot = getResourceRootElement(sourceResource)
			local _sourceResource = sourceResource
			triggerEvent("onDgsRequestCreateRemoteElement",sourceResRoot,"texture",textureData)
			sourceResource = _sourceResource
			texture = dgsPopElement("texture",sourceResource)
		end
	end
	if not texture then
		texture = __dxCreateTexture(pathOrData)
		if not texture then return false end
		dgsElementLogger[texture] = {1,pathOrData,texture}	--Log internally created texture
		addEventHandler("onClientElementDestroy",texture,function()
			dgsElementLogger[texture] = nil	--Clear logging
		end,false)
		return texture
	else
		return texture
	end
end

function dxCreateShader(pathOrData,sRes)
	local shader
	if sRes ~= false then	--Read the data instead of create from path, and create remotely
		sourceResource = sRes or sourceResource
		if dgsElementKeeper[sourceResource] then
			local shaderData
			if fileExists(pathOrData) then
				local f = fileOpen(pathOrData,true)
				shaderData = fileRead(f,fileGetSize(f))
				fileClose(f)
			else
				shaderData = pathOrData
			end
			local sourceResRoot = getResourceRootElement(sourceResource)
			local _sourceResource = sourceResource
			triggerEvent("onDgsRequestCreateRemoteElement",sourceResRoot,"shader",shaderData)
			sourceResource = _sourceResource
			shader = dgsPopElement("shader",sourceResource)
		end
	end
	if not shader then
		shader = __dxCreateShader(pathOrData)
		if not shader then return false end
		dgsElementLogger[shader] = {2,pathOrData,shader}	--Log internally created shader
		addEventHandler("onClientElementDestroy",shader,function()
			dgsElementLogger[shader] = nil	--Clear logging
		end,false)
		return shader
	else
		return shader
	end
end

function dxCreateRenderTarget(w,h,isTransparent,dgsElement,sRes)
	local rt
	if sRes ~= false then	--Create remotely
		sourceResource = sRes or sourceResource
		if dgsElementKeeper[sourceResource] then
			local sourceResRoot = getResourceRootElement(sourceResource)
			local _sourceResource = sourceResource
			triggerEvent("onDgsRequestCreateRemoteElement",sourceResRoot,"rendertarget",w,h,isTransparent)
			sourceResource = _sourceResource
			rt = dgsPopElement("rendertarget",sourceResource)
		end
	end
	local rendertarget = rt or __dxCreateRenderTarget(w,h,isTransparent)
	if not isElement(rendertarget) then
		if w < 1 or h < 1 then return nil end	--Pass
		local videoMemory = dxGetStatus().VideoMemoryFreeForMTA
		local reqSize,reqUnit = getProperUnit(0.0000076*w*h,"MB")
		local freeSize,freeUnit = getProperUnit(videoMemory,"MB")
		local forWhat = dgsElement and (" for "..dgsGetPluginType(dgsElement)) or ""
		return false,"Failed to create render target"..forWhat.." ("..w.."x"..h..") [Expected:"..reqSize..reqUnit.."/Free:"..freeSize..freeUnit.."]"
	end
	return rendertarget
end

function createElement(eleType,sRes)
	local ele
	sourceResource = sRes or sourceResource
	if sourceResource then	--Create remotely
		if dgsElementKeeper[sourceResource] then
			local sourceResRoot = getResourceRootElement(sourceResource)
			local _sourceResource = sourceResource
			triggerEvent("onDgsRequestCreateRemoteElement",sourceResRoot,eleType)
			sourceResource = _sourceResource
			ele = dgsPopElement(eleType,sourceResource)
		end
	end
	return ele or __createElement(eleType)
end

function removeElementData(element,key)
	setElementData(element,key,nil)
end

function dgsAddEventHandler(eventName,element,fncName,...)
	if addEventHandler(eventName,element,_G[fncName],...) then
		dgsElementData[element].eventHandlers = dgsElementData[element].eventHandlers or {}
		local eventHandlers = dgsElementData[element].eventHandlers
		eventHandlers[eventName] = eventHandlers[eventName] or {}
		eventHandlers[eventName][fncName] = {fncName,...}	--Log event handler
		return true
	end
	return false
end

function dgsRemoveEventHandler(eventName,element,fncName)
	eventHandlers[element][eventName][fncName] = nil	--Remove event handler
	return removeEventHandler(eventName,element,_G[fncName])
end
--------------------------------Table Utility
function table.find(tab,ke,num)
	if num then
		for k,v in pairs(tab) do
			if v[num] == ke then
				return k
			end
		end
	else
		for k,v in pairs(tab) do
			if v == ke then
				return k
			end
		end
	end
	return false
end

function table.removeItemFromArray(tab,item)
	local id
	for i=1,#tab do
		if tab[i] == item then
			id = i
			break
		end
	end
	return id and tableRemove(tab,id) or false
end

function table.count(tabl)
	local cnt = 0
	for k,v in pairs(tabl) do
		cnt = cnt + 1
	end
	return cnt
end

function table.deepcount(tabl)
	local cnt = 0
	for k,v in pairs(tabl) do
		cnt = cnt+1
		if type(v) == "table" then
			cnt = cnt+table.deepcount(v)
		end
	end
	return cnt
end

function table.merger(...)
	local tab = {...}
	if #tab > 1 then
		local result = {}
		for k,v in ipairs(tab) do
			if type(v) ~= "table" then
				assert(false,"Bad argument @table.merger at argument "..k..",expect table got "..type(v))
				return false
			end
			for _k,_v in pairs(v) do
				result[_k] = _v
			end
		end
		return result
	else
		return tab[1] or false
	end
end

function table.complement(theall,...)
	assert(type(theall) == "table","Bad argument @table.complement at argument 1,expect table got "..type(theall))
	local remove = table.merger(...)
	local newtable = {}
	for k,v in pairs(theall) do
		if not table.find(remove) then
			tableInsert(newtable,v)
		end
	end
	return newtable
end

function table.deepcopy(obj)
    local InTable = {}
    local function Func(obj)
        if type(obj) ~= "table" then
            return obj
        end
        local NewTable = {}
        InTable[obj] = NewTable
        for k,v in pairs(obj) do
            NewTable[Func(k)] = Func(v)
        end
        return setmetatable(NewTable,getmetatable(obj))
    end
    return Func(obj)
end

function table.shallowCopy(obj)
	local InTable = {}
	for k,v in pairs(obj) do
		InTable[k] = v
	end
	return InTable
end

--------------------------------File Utility
function hashFile(fName)
	local f = fileOpen(fName,true)
	local fSize = fileGetSize(f)
	local fContent = fileRead(f,fSize)
	fileClose(f)
	return hash("sha256",fContent),fSize
end

--------------------------------String Utility
function string.split(s,delim)
	local delimLen = len(delim)
    if type(delim) ~= "string" or delimLen <= 0 then return false end
	local start,index,t = 1,1,{}
	while true do
		local pos = find(s,delim,start,true)
		if not pos then break end
		t[index] = sub(s,start,pos-1)
		start = pos+delimLen
		index = index+1
	end
	t[index] = sub(s,start)
	return t
end
--[[
0: symbol
1: character
]]
function utf8.getCharType(c)
	local cCode = utf8Byte(c)
	local cType = 1
	if cCode <= 47 then
		cType = 0
	elseif cCode <= 57 then
		cType = 1
	elseif cCode <= 64 then
		cType = 0
	elseif cCode <= 90 then
		cType = 1
	elseif cCode <= 96 then
		cType = 0
	elseif cCode <= 122 then
		cType = 1
	elseif cCode <= 127 then
		cType = 0
	end
	return cType
end

local utf8GetCharType = utf8.getCharType
function dgsSearchFullWordType(text,index,side)
	local textLen = utf8Len(text)
	if side == 1 then index = index+1 end
	local startStr = utf8Sub(text,index,index)
	if not startStr or startStr == "" then return 0,textLen end
	local startType = utf8GetCharType(startStr)
	local frontPos = index
	local backPos = index
	while true do
		frontPos = frontPos-1
		if frontPos < 0 then break end
		local searchChar = utf8Sub(text,frontPos,frontPos)
		if not searchChar or searchChar == "" then break end
		if utf8GetCharType(searchChar) ~= startType then break end
	end
	while true do
		backPos = backPos+1
		if backPos > textLen then break end
		local searchChar = utf8Sub(text,backPos,backPos)
		if not searchChar or searchChar == "" then break end
		if utf8GetCharType(searchChar) ~= startType then break end
	end
	return frontPos,backPos-1,startType
end

--------------------------------Math Utility
function findRotation(x1,y1,x2,y2,offsetFix)
	local t = -deg(atan2(x2-x1,y2-y1))+offsetFix
	return t<0 and t+360 or t
end

function math.restrict(value,n_min,n_max)
	if value <= n_min then
		return n_min
	elseif value >= n_max then
		return n_max
	else
		return value
	end
end

function math.inRange(n_min,n_max,value)
	return value >= n_min and value <= n_max
end

function math.lerp(s,a,b)
	return a+s*(b-a)
end

function math.seekEmpty(list)
	local cnt = 1
	while(list[cnt]) do
		cnt = cnt+1
	end
	return cnt
end

function math.factorial(x)
	local a = 1
	for i=2,x do a = a*i end
	return a
end

function math.c(n,r)
	local up,down = 1,1
	for i=n-r+1,n do up = up*i end
	for i=1,r do down = down*i end
	return up/down
end

function math.getBezierPoint(pos,t)
	local retX,retY = 0,0
	local n = #pos-1
	for i=1,n+1 do
		local index = i-1
		local factor = (t)^index*(1-t)^(n-index)*math.c(n,index)
		retX = retX+factor*pos[i][1]
		retY = retY+factor*pos[i][2]
	end
	return retX,retY
end

function getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix(element)
    return offX*m[1][1]+offY*m[2][1]+offZ*m[3][1]+m[4][1],offX*m[1][2]+offY*m[2][2]+offZ*m[3][2]+m[4][2],offX*m[1][3]+offY*m[2][3]+offZ*m[3][3]+m[4][3]
end

function getRotationMatrix(rx,ry,rz)	--Super fast
    local rx,ry,rz = rx*pi180,ry*pi180,rz*pi180
	local rxCos,ryCos,rzCos,rxSin,rySin,rzSin = cos(rx),cos(ry),cos(rz),sin(rx),sin(ry),sin(rz)
	--m11,m12,m13,m21,m22,m23,m31,m32,m33 For extreme performance, using upvalue instead of table
	return rzCos*ryCos-rzSin*rxSin*rySin,ryCos*rzSin+rzCos*rxSin*rySin,-rxCos*rySin,-rxCos*rzSin,rzCos*rxCos,rxSin,rzCos*rySin+ryCos*rzSin*rxSin,rzSin*rySin-rzCos*ryCos*rxSin,rxCos*ryCos
end

function getPositionFromOffsetByRotMat(offx,offy,offz,x,y,z,m11,m12,m13,m21,m22,m23,m31,m32,m33)
	return offx*m11+offy*m21+offz*m31+x,offx*m12+offy*m22+offz*m32+y,offx*m13+offy*m23+offz*m33+z
end

function dgsFindRotationByCenter(dgsEle,x,y,offsetFix)
	local posX,posY = dgsGetGuiLocationOnScreen(dgsEle,false)
	local absSize = dgsElementData[dgsEle].absSize
	local posX,posY = posX+absSize[1]/2,posY+absSize[2]/2
	local rot = findRotation(posX,posY,x,y,offsetFix)
	return rot,(x-posX)/absSize[1],(y-posY)/absSize[2]
end

------------Round Up Functions
defaultRoundUpPoints = 3
function dgsRoundUp(num,points)
	if points then
		assert(type(points) == "number","Bad Argument @dgsRoundUp at argument 2, expect a positive integer got "..dgsGetType(points))
		assert(points%1 == 0,"Bad Argument @dgsRoundUp at argument 2, expect a positive integer got float")
		assert(points > 0,"Bad Argument @dgsRoundUp at argument 2, expect a positive integer got "..points)
	end
	local points = points or defaultRoundUpPoints
	local s_num = tostring(num)
	local from,to = utf8.find(s_num,"%.")
	if from then
		local single = s_num:sub(from+points,from+points)
		local single = tonumber(single) or 0
		local a = s_num:sub(0,from+points-1)
		if single >= 5 then
			a = a+10^(-points+1)
		end
		return tonumber(a)
	end
	return num
end

function dgsGetRoundUpPoints()
	return defaultRoundUpPoints
end

function dgsSetRoundUpPoints(points)
	assert(type(points) == "number","Bad Argument @dgsSetRoundUpPoints at argument 1, expect a positive integer got "..dgsGetType(points))
	assert(points%1 == 0,"Bad Argument @dgsSetRoundUpPoints at argument 1, expect a positive integer got float")
	assert(points > 0,"Bad Argument @dgsSetRoundUpPoints at argument 1, expect a positive integer got 0")
	defaultRoundUpPoints = points
	return true
end
--------------------------------Built-in Utility
HorizontalAlign = {
	left = "left",
	center = "center",
	right = "right",
}

VerticalAlign = {
	top = "top",
	center = "center",
	bottom = "bottom",
}
--------------------------------Color Utility
white = 0xFFFFFFFF
black = 0xFF000000
green = 0xFF00FF00
red = 0xFFFF0000
blue = 0xFF0000FF
yellow = 0xFFFFFF00

function fromcolor(int,useMath,relative)
	local a,r,g,b
	if useMath then
		b = int%256
		local int = (int-b)/256
		g = int%256
		local int = (int-g)/256
		r = int%256
		local int = (int-r)/256
		a = int%256
	else
		a,r,g,b = getColorFromString(format("#%.8x",int))
	end
	if relative then
		a,r,g,b = a/255,r/255,g/255,b/255
	end
	return r,g,b,a
end

function getColorAlpha(color)
	if color < 0 then
		color = 0x100000000+color
	end
	local a = (color-color%0x1000000)/0x1000000
	return a-a%1
end

function setColorAlpha(color,alpha)
	if color < 0 then
		color = 0x100000000+color
	end
	alpha = alpha-alpha%1
	return color%0x1000000+alpha*0x1000000
end

function applyColorAlpha(color,alpha)
	if color < 0 then
		color = 0x100000000+color
	end
	local rgb = color%0x1000000
	local a = (color-rgb)/0x1000000*alpha
	a = a-a%1
	return rgb+a*0x1000000
end

--If you are trying to edit following code...
--You should know that
--HSL and HSV are not the same thing,while HSB is the same as HSV...

function HSL2RGB(H,S,L)
	local H,S,L = H/360,S/100,L/100
	local R,G,B
	if S == 0 then
		R,G,B = L,L,L
	else
		local var_1,var_2
		if L < 0.5 then
			var_2 = L*(1+S)
		else
			var_2 = L+S-S*L
		end
		var_1 = 2*L-var_2
		R = HUE2RGB(var_1,var_2,H+(1/3))
		G = HUE2RGB(var_1,var_2,H)
		B = HUE2RGB(var_1,var_2,H-(1/3))
	end
	return R*255,G*255,B*255
end

function HUE2RGB(v1,v2,vH)
	if vH < 0 then
		vH = vH+1
	elseif vH > 1 then
		vH = vH-1
	end
	if 6*vH < 1 then
		return v1+(v2-v1)*6*vH
	elseif 2*vH < 1 then
		return v2
	elseif 3*vH < 2 then
		return v1+(v2-v1)*((2/3)-vH)*6
	end
	return v1
end

function RGB2HSL(R,G,B)
	local R,G,B = R/255,G/255,B/255
	local min,max = math.min(R,G,B),math.max(R,G,B)
	local delta = max-min
	local L,H,S = (max+min)/2,0,0
	if delta ~= 0 then
		S = L < 0.5 and delta/(max+min) or delta/(2-max-min)
		local dR,dG,dB = ((max-R)/6+delta/2)/delta,((max-G)/6+delta/2)/delta,((max-B)/6+delta/2)/delta
		if R == max then
			H = dB-dG
		elseif G == max then
			H = (1/3)+dR-dB
		else
			H = (2/3)+dG-dR
		end
		if H < 0 then
			H = H+1
		elseif H > 1 then
			H = H-1
		end
	end
	return H*360,S*100,L*100	--{0~360,0~100,0~100} H,S,L
end

function RGB2HSV(R,G,B)
	local R,G,B = R/255,G/255,B/255
	local min,max = math.min(R,G,B),math.max(R,G,B)
	local V,H,S,delta = max,0,0,max - min
	S = max == 0 and 0 or delta / max
	local dR = R/6
	local dG = G/6
	local dB = B/6
	if R == max then
		H = dB-dG
	elseif G == max then
		H = (1/3)+dR-dB
	else
		H = (2/3)+dG-dR
	end
	if H < 0 then
		H = H+1
	elseif H > 1 then
		H = H-1
	end
	return H*360,S*100,V*100
end

function HSV2RGB(H,S,V)
	H,S,V = H/360,S/100,V/100
	H = H*6;
	local chroma = S*V;
	local interm = chroma*(1-math.abs(H%2-1));
	local shift = V - chroma;
	local RGB
	if H < 1 then
		RGB = {shift+chroma,shift+interm,shift}
	elseif H < 2 then
		RGB = {shift+interm,shift+chroma,shift}
	elseif H < 3 then
		RGB = {shift,shift+chroma,shift+interm}
	elseif H < 4 then
		RGB = {shift,shift+interm,shift+chroma}
	elseif H < 5 then
		RGB = {shift+interm,shift,shift+chroma}
	else
		RGB = {shift+chroma,shift,shift+interm}
	end
	return RGB[1]*255,RGB[2]*255,RGB[3]*255
end

function HSV2HSL(H,S,V)
	H,S,V = H/360,S/100,V/100
	local HSL_L = (2 - S) * V / 2
	local HSL_S = HSL_L == 0 and 0 or (HSL_L < 1 and S*V/(HSL_L < 0.5 and HSL_L*2 or 2-HSL_L*2) or S)
	return H*360,HSL_S*100,HSL_L*100
end

function HSL2HSV(H,S,L)
	H,S,L = H/360,S/100,L/100
	local tmp = S*(L<0.5 and L or 1-L)
	local HSV_V = L+tmp
	local HSV_S = L>0 and 2*tmp/HSV_V or S
	return H*360,HSV_S*100,HSV_V*100
end
-----------------Assert Utility
--dgsGenerateAssertString
function dgsGenAsrt(x,funcName,argx,reqType,reqValueStr,appends,ends)
	local reqValue = reqValueStr and "("..reqValueStr..")" or ""
	local appendInfo = appends and " ("..appends..")" or ""
	local inspectV = inspect(x)
	if #inspectV >= 24 then
		inspectV = inspectV:sub(1,24).."..."
	end
	local expected = reqType and " expected "..reqType..reqValue or ""
	local got = reqType and " got "..dgsGetType(x).."("..inspectV..")" or ""
	local ends = ends and (" "..ends) or ""
	local argIndex = argx and (" at argument "..argx) or ""
	local str = "Bad Argument @'"..funcName.."'"..appendInfo..expected..argIndex..","..got..ends
	return str
end
--------------------------------Dx Utility
function dxDrawImageExt(posX,posY,width,height,image,rotation,rotationX,rotationY,color,postGUI,isInRndTgt)
	local dgsBasicType = dgsGetType(image)
	if dgsBasicType == "table" then
		__dxDrawImageSection(posX,posY,width,height,image[2],image[3],image[4],image[5],image[1],rotation,rotationX,rotationY,color,postGUI)
	elseif dgsBasicType == "dgs-dxcustomrenderer" then
		dgsElementData[image].customRenderer(posX,posY,width,height,image,rotation,rotationX,rotationY,color,postGUI,isInRndTgt)
	else
		local pluginType = dgsGetPluginType(image)
		if pluginType == "dgs-dxcanvas" then
			dgsCanvasRender(image)
		elseif pluginType == "dgs-dxblurbox" then
			__dxDrawImageSection(posX,posY,width,height,posX*blurboxFactor,posY*blurboxFactor,width*blurboxFactor,height*blurboxFactor,image,rotation,rotationX,rotationY,color,false)
		else
			local blendMode
			if isInRndTgt and dgsBasicType == "shader" then
				blendMode = dxGetBlendMode()
				dxSetBlendMode("blend")
			end
			if not __dxDrawImage(posX,posY,width,height,image,rotation,rotationX,rotationY,color,postGUI) then
				if debugMode then
					local debugTrace = dgsElementData[self].debugTrace
					local thisTrace = debug.getinfo(2)
					if debugTrace then
						local line,file = debugTrace.line,debugTrace.file
						outputDebugString("dxDrawImage("..thisTrace.source..":"..thisTrace.currentline..") failed at element created at "..file..":"..line,2)
					else
						outputDebugString("dxDrawImage("..thisTrace.source..":"..thisTrace.currentline..") failed unable to trace",2)
					end
				end
			end
			if blendMode then dxSetBlendMode(blendMode) end
		end
	end
	return true
end

function dxDrawImageSectionExt(posX,posY,width,height,u,v,usize,vsize,image,rotation,rotationX,rotationY,color,postGUI)
	local dgsBasicType = dgsGetType(image)
	if dgsBasicType == "dgs-dxcustomrenderer" then
		return dgsElementData[image].customRenderer(posX,posY,width,height,image,rotation,rotationX,rotationY,color,postGUI)
	else
		if dgsGetPluginType(image) == "dgs-dxcanvas" then
			dgsCanvasRender(image)
		end
		return __dxDrawImageSection(posX,posY,width,height,u,v,usize,vsize,image,rotation,rotationX,rotationY,color,postGUI)
	end
end

--------------------------------Other Utility
function urlEncode(s)
    s = gsub(s,"([^%w%.%- ])",function(c)
		return format("%%%02X",c:byte())
	end)
    return gsub(s," ","+")
end

function urlDecode(s)
    s = gsub(s,'%%(%x%x)',function(h)
		return char(tonumber(h,16))
	end)
    return s
end

unitList = {
	{"B",8,1024},	--Go down ratio, Go up ratio
	{"KB",1024,1024},
	{"MB",1024,1024},
	{"GB",1024,1024},
}

function getProperUnit(value,unit)
	local cUID = table.find(unitList,unit,1)
	if not cUID then return value,unit end
	local currentUnit = unitList[cUID]
	while(true) do
		if value < 1 then
			if cUID <= 1 then return value,currentUnit[1] end
			value = value * currentUnit[2]
			cUID = cUID-1
			currentUnit = unitList[cUID]
		elseif value > currentUnit[3] then
			if cUID >= #unitList then return value,currentUnit[1] end
			value = value /currentUnit[3]
			cUID = cUID+1
			currentUnit = unitList[cUID]
		else
			return value,currentUnit[1]
		end
	end
end

keyStateMap = {
	lctrl=getKeyState("lctrl"),
	rctrl=getKeyState("rctrl"),
	lshift=getKeyState("lshift"),
	rshift=getKeyState("rshift"),
	lalt=getKeyState("lalt"),
	ralt=getKeyState("ralt"),
}

_getKeyState = getKeyState
function getKeyState(key)
	if keyStateMap[key] ~= nil then
		return keyStateMap[key]
	else
		return _getKeyState(key)
	end
end

addEventHandler("onClientKey",root,function(but,state)
	if keyStateMap[but] ~= nil then
		keyStateMap[but] = state
	end
end)

--------------------------------Dx Utility
PixelShaderCode = [[
float4 main(float2 Tex : TEXCOORD0):COLOR0 {
	return 0;
}
technique RepTexture {
	pass P0 {
		PixelShader = compile ps_&rep main();
	}
}
]]
PixShaderVersion = {"2_0","2_a","2_b","3_0"}
function checkPixelShaderVersion()
	for i,ver in ipairs(PixShaderVersion) do
		local shaderCode = gsub(PixelShaderCode,"&rep",ver)
		local shader = dxCreateShader(shaderCode)
		if shader then
			ClientInfo.SupportedPixelShader[ver] = true
			destroyElement(shader)
		else
			ClientInfo.SupportedPixelShader[ver] = false
		end
	end
end
checkPixelShaderVersion()

--Render Target Assigner
--[[
RTState:
	state:
		-1: Use Built-in RT
		0: None
		1: Assigning RT
		2: Assigned RT

Assign Priority:
	If queue items have same priority, smaller first
	If queue items have different priority, high priority first
	Priority is determinated by how many children.
	If RT has already been created but priority is low, delete.
]]
--[[
rtAssignQueue = {}
rtUsing = {}

function dgsPushRTAssignQueue(element,w,h,priority)
	local RTState = dgsElementData[element].RTState or {state=0,RT=nil}
	if RTState.state == 0 then
		RTState.state = 1
		table.insert(rtAssignQueue,{element,w,h,w*h,priority})
	end
	dgsElementData[element].RTState = RTState
end

function dgsGetTotalVideoMemoryForMTA()
	local dxStatus = dxGetStatus()
	return dxStatus.VideoMemoryFreeForMTA+dxStatus.VideoMemoryUsedByFonts+dxStatus.VideoMemoryUsedByTextures+dxStatus.VideoMemoryUsedByRenderTargets
end

function dgsAssignRT(index)
	local element,w,h,size,priority = rtAssignQueue[index][1]
	local RTState = dgsElementData[element].RTState or {state=0,RT=nil,priority=priority}
	local vmRemain = dxGetStatus().VideoMemoryFreeForMTA
	if size < vmRemain then
		if RTState.state == 1 then
			local rt = dxCreateRenderTarget(w,h,true)
			table.remove(rtAssignQueue,index)
			if not rt then
				outputDebugString("[DGS]Failed to create render target (Expected:"..size.."MB/"..vmRemain.."MB)")
				RTState.state = 0
				return false
			end
			RTState.state = 2
			RTState.RT = rt
			rtUsing[element] = {element,rt,w,h}
			return true
		end
	end
	return false
end

function dgsRemoveRT(element)
	local RTState = dgsElementData[element].RTState or {state=0,RT=nil}
	if RTState.state == 1 then
		table.remove(rtAssignQueue,index)
	else
		if isElement(RTState.RT) then
			destroyElement(RTState.RT)
		end
		RTState.RT = nil
	end
	RTState.state = 0
end

function dgsGetRTAssignState(element)
	local RTState = dgsElementData[element].RTState or {state=0,RT=nil}
	return RTState.state
end]]
--------------------------------Events
events = {
	"onDgsCursorTypeChange",
	"onDgsMouseLeave",
	"onDgsMouseEnter",
	"onDgsMousePreClick",
	"onDgsMouseClick",
	"onDgsMouseWheel",
	"onDgsMouseClickUp",
	"onDgsMouseClickDown",
	"onDgsMouseDoubleClick",
	"onDgsMouseMultiClick",
	"onDgsMouseDown",
	"onDgsMouseUp",
	"onDgsMouseDrag",
	"onDgsMouseMove",
	"onDgsWindowClose",
	"onDgsPositionChange",
	"onDgsSizeChange",
	"onDgsTextChange",
	"onDgsElementScroll",
	"onDgsDestroy",
	"onDgsSwitchButtonStateChange",
	"onDgsSelectorSelect",
	"onDgsGridListSelect",
	"onDgsGridListHover",
	"onDgsGridListItemDoubleClick",
	"onDgsProgressBarChange",
	"onDgsCreate",
	"onDgsPluginCreate",
	"onDgsPreRender",
	"onDgsRender",
	"onDgsElementRender",
	"onDgsElementLeave",
	"onDgsElementEnter",
	"onDgsElementMove",
	"onDgsElementSize",
	"onDgsFocus",
	"onDgsBlur",
	"onDgsTabSelect",
	"onDgsTabPanelTabSelect",
	"onDgsRadioButtonChange",
	"onDgsCheckBoxChange",
	"onDgsComboBoxSelect",
	"onDgsComboBoxStateChange",
	"onDgsEditPreSwitch",
	"onDgsEditSwitched",
	"onDgsEditAccepted",
	"onDgsStopMoving",
	"onDgsStopSizing",
	"onDgsStopAlphaing",
	"onDgsStopAniming",
	"onDgsDrop",
	"onDgsDrag",
	"onDgsStart",
	"onDgsPaste", --DGS Paste Handler
	-------Plugin events
	"onDgsRemoteImageLoad",
	"onDgsQRCodeLoad",
	-------internal events
	"DGSI_Paste",
	"DGSI_ReceiveIP",
	"DGSI_SendAboutData",
	"DGSI_ReceiveQRCode",
	"DGSI_ReceiveRemoteImage",
	-------
}
local addEvent = addEvent
for i=1,#events do
	addEvent(events[i],true)
end