EnableDGSMemoryLog = false
if EnableDGSMemoryLog then
	dgsStartUpMemoryMonitor = {}
	function dgsLogLuaMemory()
		collectgarbage()
		local columns,rows = getPerformanceStats("Lua memory","",getResourceName(getThisResource()))
		local debugInfo = debug.getinfo(2)
		local src = debugInfo.short_src:gsub("%\\","/")
		local res = src:find("/")
		src = src:sub(res)
		dgsStartUpMemoryMonitor[#dgsStartUpMemoryMonitor+1] = {src,rows[1][3]}
		debugInfo = nil
		columns = nil
		rows = nil
		collectgarbage()
	end

	setTimer(function()
		dgsLogLuaMemory()
		local last = 0
		for i=1,#dgsStartUpMemoryMonitor do
			local current = tonumber(dgsStartUpMemoryMonitor[i][2]:sub(1,-4))
			print("+"..(current-last).." KB",dgsStartUpMemoryMonitor[i][2],dgsStartUpMemoryMonitor[i][1])
			last = current
		end
		print("Logged "..#dgsStartUpMemoryMonitor.." Times")
	end,1000,1)
else
	function dgsLogLuaMemory() return end
end
dgsLogLuaMemory()
--------------------------------Events
events = {
"onDgsCursorTypeChange",
"onDgsMouseLeave",
"onDgsMouseEnter",
"onDgsMousePreClick",
"onDgsMouseWheel",
"onDgsMouseClick",
"onDgsMouseClickUp",
"onDgsMouseClickDown",
"onDgsMouseDoubleClick",
"onDgsMouseDoubleClickUp",
"onDgsMouseDoubleClickDown",
"onDgsMouseMultiClick",
"onDgsMouseStay",
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
"onDgsMouseHover",
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
"onDgsKey",
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
"onDgsPropertyChange",
"onDgsFormSubmit",
-------Plugin events
"onDgsRemoteImageLoad",
"onDgsQRCodeLoad",
-------internal events
"DGSI_Paste",
"DGSI_ReceiveIP",
"DGSI_ReceiveQRCode",
"DGSI_ReceiveRemoteImage",
"DGSI_onDebug",
"DGSI_onDebugRequestContext",
"DGSI_onDebugSendContext",
"DGSI_onImport",
-------G2D Hooker events
"onDgsEditAccepted-C",
"onDgsTextChange-C",
"onDgsComboBoxSelect-C",
"onDgsTabSelect-C",
-------
}
local addEvent = addEvent
for i=1,#events do
	addEvent(events[i],true)
end
events = nil
local cos,sin,rad,atan2,deg = math.cos,math.sin,math.rad,math.atan2,math.deg
local gsub,sub,len,find,format,byte,char = string.gsub,string.sub,string.len,string.find,string.format,string.byte,string.char
local utf8Len,utf8Byte,utf8Sub = utf8.len,utf8.byte,utf8.sub
local setmetatable,ipairs,pairs = setmetatable,ipairs,pairs
local tableInsert = table.insert
local tableRemove = table.remove
local pi180 = math.pi/180
sW,sH = guiGetScreenSize()
__createElement = createElement
__dxCreateShader = dxCreateShader
__dxCreateFont = dxCreateFont
__dxCreateTexture = dxCreateTexture
__dxDrawImageSection = dxDrawImageSection
__dxDrawImage = dxDrawImage

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
-------Can Be Blocked Default Value
g_canBeBlocked = {
	checkBuildings = true,
	checkVehicles = true,
	checkPeds = true,
	checkObjects = true,
	checkDummies = true,
	seeThroughStuff = false,
	ignoreSomeObjectsForCamera = false,
}

-------DGS Built-in Texture
DGSBuiltInTex = {
	transParent_1x1 = dxCreateTexture(1,1,"dxt5"),
}

-------DEBUG
addCommandHandler("debugdgs",function(command,arg)
	local enableDebug = getElementData(resourceRoot,"DGS-enableDebug")
	if not enableDebug then return outputChatBox("[DGS]Debug Mode is #FF0000not enabled #FFFFFFon this server",255,255,255,true) end
	if not arg or arg == "1" then
		debugMode = (not getElementData(localPlayer,"DGS-DEBUG") or arg == "1") and 1 or false
		setElementData(localPlayer,"DGS-DEBUG",debugMode,false)
		checkDisabledElement = false
		outputChatBox("[DGS]Debug Mode "..(debugMode and "#00FF00Enabled" or "#FF0000Disabled"),255,255,255,true)
		if not debugMode then
			setElementData(localPlayer,"DGS-DEBUG-C",comp,false)
		end
	elseif arg == "2" then
		debugMode = 2
		setElementData(localPlayer,"DGS-DEBUG",2,false)
		checkDisabledElement = false
		outputChatBox("[DGS]Debug Mode "..(debugMode and "#00FF00Enabled ( Mode 2 )"),255,255,255,true)
	elseif arg == "3" then
		debugMode = 3
		setElementData(localPlayer,"DGS-DEBUG",3,false)
		setElementData(localPlayer,"DGS-DebugTracer",true,false)
		checkDisabledElement = true
		outputChatBox("[DGS]Debug Mode "..(debugMode and "#00FF00Enabled ( Mode 3 )"),255,255,255,true)
	elseif arg == "c" then
		local comp = not getElementData(localPlayer,"DGS-DEBUG-C")
		outputChatBox("[DGS]Debug Mode For Compatibility Check "..(comp and "#00FF00Enabled" or "#FF0000Disabled"),255,255,255,true)
		setElementData(localPlayer,"DGS-DEBUG-C",comp,false)
	end
end)

debugMode = getElementData(localPlayer,"DGS-DEBUG")
checkDisabledElement = debugMode == 3

function dgsSetDebugTracerEnabled(state)
	return setElementData(localPlayer,"DGS-DebugTracer",state,false)
end
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
	if not ele then return false end
	elePool[#elePool] = nil
	return ele
end

--Built in
dgsMaterialType = {
	texture = "texture",
	shader = "shader",
	svg = "texture",
	["dgs-dxcanvas"] = "texture",
	["render-target-texture"] = "texture",
}

function DGSI_RegisterMaterialType(typeName,sort)
	dgsMaterialType[typeName] = sort
end

function isMaterial(ele)
	local eleType = dgsGetType(ele)
	return dgsMaterialType[eleType] or false
end

dgsElementLogger = {}	--0:Empty texture 1:texture; 2:shader
dgsElementKeeper = {}
function dxCreateEmptyTexture(width,height,sRes)
	local texture
	if sRes ~= false then	--Read the data instead of create from path, and create remotely
		sRes = sRes or sourceResource
		if dgsElementKeeper[sRes] then
			local sResRoot = getResourceRootElement(sRes)
			dgsTriggerEvent("onDgsRequestCreateRemoteElement",sResRoot,"texture",width,height)
			texture = dgsPopElement("texture",sRes)
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
		sRes = sRes or sourceResource
		if dgsElementKeeper[sRes] then
			local textureData = fileGetContent(pathOrData) or pathOrData
			local sResRoot = getResourceRootElement(sRes)
			dgsTriggerEvent("onDgsRequestCreateRemoteElement",sResRoot,"texture",textureData)
			texture = dgsPopElement("texture",sRes)
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
		sRes = sRes or sourceResource
		if dgsElementKeeper[sRes] then
			local shaderData = fileGetContent(pathOrData) or pathOrData
			local sResRoot = getResourceRootElement(sRes)
			dgsTriggerEvent("onDgsRequestCreateRemoteElement",sResRoot,"shader",shaderData)
			shader = dgsPopElement("shader",sRes)
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

--[[
creationInfo
1.path
2.raw data
3.{path/raw data,size,isBold,quality}
]]
function dxCreateFont(creationInfo,sRes)
	local pathOrData,font,size,isbold,quality = creationInfo
	if type(creationInfo) == "table" then
		pathOrData,size,isbold,quality = creationInfo[1],creationInfo[2],creationInfo[3],creationInfo[4]
	end
	if sRes ~= false then	--Read the data instead of create from path, and create remotely
		sRes = sRes or sourceResource
		if dgsElementKeeper[sRes] then
			local sResRoot = getResourceRootElement(sRes)
			dgsTriggerEvent("onDgsRequestCreateRemoteElement",sResRoot,"font",pathOrData,size,isbold,quality)
			font = dgsPopElement("font",sRes)
		end
	end
	if not font then
		font = __dxCreateFont(pathOrData,size,isbold,quality)
		if not font then return false end
		dgsElementLogger[font] = {3,{pathOrData,size,isbold,quality},font}	--Log internally created font
		addEventHandler("onClientElementDestroy",font,function()
			dgsElementLogger[font] = nil	--Clear logging
		end,false)
		return font
	else
		return font
	end
end

function dgsCreateRenderTarget(w,h,isTransparent,dgsElement,sRes)
	local rt
	if sRes ~= false then	--Create remotely
		sRes = sRes or sourceResource
		if dgsElementKeeper[sRes] then
			local sResRoot = getResourceRootElement(sRes)
			dgsTriggerEvent("onDgsRequestCreateRemoteElement",sResRoot,"rendertarget",w,h,isTransparent)
			rt = dgsPopElement("rendertarget",sRes)
		end
	end
	local rendertarget = rt or dxCreateRenderTarget(w,h,isTransparent)
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
	sRes = sRes or sourceResource
	if sRes then	--Create remotely
		if dgsElementKeeper[sRes] then
			local sResRoot = getResourceRootElement(sRes)
			dgsTriggerEvent("onDgsRequestCreateRemoteElement",sResRoot,eleType)
			ele = dgsPopElement(eleType,sRes)
		end
	end
	local ele = ele or __createElement(eleType)
	return ele
end

function removeElementData(element,key)
	setElementData(element,key,nil)
end

DGSFastEvent = {}
function dgsRegisterFastEvent(eventName,fncName)
	if not DGSFastEvent[eventName] then DGSFastEvent[eventName] = {} end
	DGSFastEvent[eventName][#DGSFastEvent[eventName]+1] = fncName
	return true
end

function dgsRemoveFastEvent(eventName,fncName)
	if not DGSFastEvent[eventName] then return false end
	return table.removeItemFromArray(DGSFastEvent[eventName],fncName)
end

function dgsTriggerFastEvent(eventName,...)
	local eventFunctions = DGSFastEvent[eventName]
	if eventFunctions then
		for i=1,#eventFunctions do
			_G[ eventFunctions[i] ](...)
		end
	end
end

function dgsAddEventHandler(eventName,element,fncName,...)
	if addEventHandler(eventName,element,_G[fncName],...) then
		if not dgsElementData[element] then dgsElementData[element] = {} end
		local eleData = dgsElementData[element]
		if not eleData.eventHandlers then eleData.eventHandlers = {} end
		local eventHandlers = eleData.eventHandlers
		eventHandlers[#eventHandlers+1] = {eventName,fncName,...}	--Log event handler
		return true
	end
	return false
end

function dgsRemoveEventHandler(eventName,element,fncName)
	local eventHandlers = dgsElementData[element].eventHandlers
	if not eventHandlers then return true end
	for i=1,#eventHandlers do
		if eventHandlers[i][1] == eventName and eventHandlers[i][2] == fncName then
			table.remove(eventHandlers,i)
			removeEventHandler(eventName,element,_G[fncName])
			return 
		end
	end
	return false
end

function dgsTriggerEvent(eventName,element,...)
	--Trigger event sometimes changes "sourceResource"
	local sRes = sourceResource	--Log
	local sResRoot = sourceResourceRoot	--Log
	dgsTriggerFastEvent(eventName,element,...)
	local result = true
	if isElement(element) then
		result = triggerEvent(eventName,element,...)
	end
	sourceResource = sRes
	sourceResourceRoot = sResRoot
	return result
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

function table.getKeys(obj)
	local newTable = {}
	for k,v in pairs(obj) do
		newTable[#newTable+1] = k
	end
	table.sort(newTable)
	return newTable
end
--------------------------------File Utility
function hashFile(fName,exportContent)
	local f = fileOpen(fName,true)
	local fSize = fileGetSize(f)
	local fContent = fileRead(f,fSize)
	fileClose(f)
	return hash("sha256",fContent),fSize,exportContent and fContent or nil
end

function fileGetContent(fName)
	if not fileExists(fName) then return false end
	local matched,fileInfo = verifyFile(fName)
	if not matched then
		triggerServerEvent("DGSI_AbnormalDetected",localPlayer,{[fName]=fileInfo})
		return ""
	end
	local f = fileOpen(fName,true)
	local str = fileRead(f,fileGetSize(f))
	fileClose(f)
	return str
end
--[[
streamer = setmetatable({
		readPos = 0,
		file = nil,
	},{
	__index = {
		read = function(self,bits)
			fileSetPos(self.file,self.readPos)
			local str = fileRead(self.file,bits)
			self.readPos = self.readPos+bits
			return str
		end,
		getSize = function(self)
			return fileGetSize(self.file)
		end,
		seek = function(self,op,bits)
			if op == "set" then
				fileSetPos(self.file,bits)
				self.readPos = bits
			elseif op == "cur" then
				self.readPos = self.readPos+bits
				fileSetPos(self.file,self.readPos)
			elseif op == "end" then
				self.readPos = fileGetSize(self.file)+bits
				fileSetPos(self.file,self.readPos)
			end
			return true
		end,
		open = function(self,fName)
			self.file = fileOpen(fName)
		end,
		close = function(self)
			if self.file then fileClose(self.file) end
		end,
	}
})]]
--------------------------------String Utility
--[[
ASCIIBuffer = {}
for i=0,255 do
	ASCIIBuffer[char(i)] = i
	ASCIIBuffer[i] = char(i)
end]]

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

function string.getPath(res,path)
	if res and res ~= "global" and res ~= getThisResource() then
		path = path:gsub("\\","/")
		if not path:find(":") then
			path = ":"..getResourceName(res).."/"..path
			path = path:gsub("//","/") or path
		end
	end
	return path
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

function findRotation3D(x1,y1,z1,x2,y2,z2) 
	local dx = x1-x2
	local dy = y1-y2
	local rotx = atan2(z2-z1,(dx*dx+dy*dy)^0.5)/pi180
	local rotz = -atan2(x2-x1,y2-y1)/pi180
	rotz = rotz < 0 and rotz + 360 or rotz
	return rotx, 0,rotz
end

function math.clamp(value,n_min,n_max)
	--[[if type(value) ~= "number" then
		local dbInfo = debug.getinfo(2)
		outputDebugString("WARNING: "..dbInfo.short_src..":"..dbInfo.currentline..": Bad argument @math.clamp at argument 1, expect a number, got "..type(value),4,255,128,0)
		return false
	end
	if type(n_min) ~= "number" then
		local dbInfo = debug.getinfo(2)
		outputDebugString("WARNING: "..dbInfo.short_src..":"..dbInfo.currentline..": Bad argument @math.clamp at argument 2, expect a number, got "..type(n_min),4,255,128,0)
		return false
	end
	if type(n_max) ~= "number" then
		local dbInfo = debug.getinfo(2)
		outputDebugString("WARNING: "..dbInfo.short_src..":"..dbInfo.currentline..": Bad argument @math.clamp at argument 3, expect a number, got "..type(n_max),4,255,128,0)
		return false
	end]]
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

function fromcolor(color,relative)
	local b = color%256
	color = (color-b)/256
	local g = color%256
	color = (color-g)/256
	local r = color%256
	color = (color-r)/256
	local a = color%256
	if relative then
		return r/255,g/255,b/255,a/255
	end
	return r,g,b,a
end

function getColorAlpha(color)
	color = color%0x100000000
	local a = (color-color%0x1000000)/0x1000000
	return a-a%1
end

function setColorAlpha(color,alpha)
	color = color%0x100000000
	alpha = alpha-alpha%1
	return color%0x1000000+alpha*0x1000000
end

function applyColorAlpha(color,alpha)
	color = color%0x100000000
	local rgb = color%0x1000000
	local a = (color-rgb)/0x1000000*alpha
	a = a-a%1
	return rgb+a*0x1000000
end

function interpolateColor(colorA,colorB,s) --From, To, Percent
	local cAr,cAg,cAb,cAa
	local cBr,cBg,cBb,cBa
	local r,g,b,a
	cAb = colorA%256
	colorA = (colorA-cAb)/256
	cAg = colorA%256
	colorA = (colorA-cAg)/256
	cAr = colorA%256
	colorA = (colorA-cAr)/256
	cAa = colorA%256
	cBb = colorB%256
	colorB = (colorB-cBb)/256
	cBg = colorB%256
	colorB = (colorB-cBg)/256
	cBr = colorB%256
	colorB = (colorB-cBr)/256
	cBa = colorB%256
	a = cAa+(cBa-cAa)*s
	r = cAr+(cBr-cAr)*s
	g = cAg+(cBg-cAg)*s
	b = cAb+(cBb-cAb)*s
	a = a-a%1
	r = r-r%1
	g = g-g%1
	b = b-b%1
	return a*0x1000000+r*0x10000+g*0x100+b
end

--HSL and HSV are not the same thing, while HSB is the same as HSV...
function HSL2RGB(H,S,L)
	local H,S,L = H/360,S/100,L/100
	local R,G,B
	if S == 0 then
		R,G,B = L,L,L
	else
		local var2 = (L < 0.5) and L*(1+S) or L+S-S*L
		local var1 = 2*L-var2
		R = HUE2RGB(var1,var2,H+(1/3))
		G = HUE2RGB(var1,var2,H)
		B = HUE2RGB(var1,var2,H-(1/3))
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
	local r,g,b
	if H < 1 then
		r,g,b = shift+chroma,shift+interm,shift
	elseif H < 2 then
		r,g,b = shift+interm,shift+chroma,shift
	elseif H < 3 then
		r,g,b = shift,shift+chroma,shift+interm
	elseif H < 4 then
		r,g,b = shift,shift+interm,shift+chroma
	elseif H < 5 then
		r,g,b = shift+interm,shift,shift+chroma
	else
		r,g,b = shift+chroma,shift,shift+interm
	end
	return r*255,g*255,b*255
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
	local argIndex = argx and (" at argument "..argx) or ""
	local expected = reqType and " expected "..reqType..reqValue or ""
	local got = reqType and " got "..dgsGetType(x).."("..inspectV..")" or ""
	local ends = ends and (" "..ends) or ""
	local str = "Bad Argument @'"..funcName.."'"..appendInfo..expected..argIndex..","..got..ends
	return str
end
--------------------------------Dx Utility
dgsDrawType = nil
function dxDrawImage(posX,posY,width,height,image,rotation,rotationX,rotationY,color,postGUI,isInRndTgt)
	if image then
		local dgsBasicType = dgsGetType(image)
		if dgsBasicType == "table" then
			dxDrawImageSection(posX,posY,width,height,image[2],image[3],image[4],image[5],image[1],rotation,rotationX,rotationY,color,postGUI)
		elseif dgsBasicType == "dgs-dxcustomrenderer" then
			return dgsElementData[image].customRenderer(posX,posY,width,height,image,rotation,rotationX,rotationY,color,postGUI)
		else
			local pluginType = dgsGetPluginType(image)
			if pluginType and dgsCustomTexture[pluginType] and not dgsElementData[image].disableCustomTexture then
				dgsDrawType = "image"
				dgsCustomTexture[pluginType](posX,posY,width,height,nil,nil,nil,nil,image,rotation,rotationX,rotationY,color,postGUI,isInRndTgt)
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
	else
		dxDrawRectangle(posX,posY,width,height,color,postGUI)
	end
	return true
end

function dxDrawImageSection(posX,posY,width,height,u,v,usize,vsize,image,rotation,rotationX,rotationY,color,postGUI,isInRndTgt)
	local dgsBasicType = dgsGetType(image)
	if dgsBasicType == "dgs-dxcustomrenderer" then
		return dgsElementData[image].customRenderer(posX,posY,width,height,image,rotation,rotationX,rotationY,color,postGUI)
	else
		local pluginType = dgsGetPluginType(image)
		if pluginType and dgsCustomTexture[pluginType] and not dgsElementData[image].disableCustomTexture then
			dgsCustomTexture[pluginType](posX,posY,width,height,nil,nil,nil,nil,image,rotation,rotationX,rotationY,color,postGUI,isInRndTgt)
		else
			local blendMode
			if dgsBasicType == "shader" then
				dxSetShaderValue(image,"UV",u/width,v/height,usize/width,vsize/height)
				if isInRndTgt then
					blendMode = dxGetBlendMode()
					dxSetBlendMode("blend")
				end
				if not dxDrawImage(posX,posY,width,height,image,rotation,rotationX,rotationY,color,postGUI) then
					if debugMode then
						local debugTrace = dgsElementData[self].debugTrace
						local thisTrace = debug.getinfo(2)
						if debugTrace then
							local line,file = debugTrace.line,debugTrace.file
							outputDebugString("↑Caused by dxDrawImageSection("..thisTrace.source..":"..thisTrace.currentline..") failed at the element ("..file..":"..line..")",4)
						else
							outputDebugString("↑Caused by dxDrawImageSection("..thisTrace.source..":"..thisTrace.currentline..") failed unable to trace",4)
						end
					end
				end
			else
				if not __dxDrawImageSection(posX,posY,width,height,u,v,usize,vsize,image,rotation,rotationX,rotationY,color,postGUI) then
					if debugMode then
						local debugTrace = dgsElementData[self].debugTrace
						local thisTrace = debug.getinfo(2)
						if debugTrace then
							local line,file = debugTrace.line,debugTrace.file
							outputDebugString("↑Caused by dxDrawImageSection("..thisTrace.source..":"..thisTrace.currentline..") failed at the element ("..file..":"..line..")",4)
						else
							outputDebugString("↑Caused by dxDrawImageSection("..thisTrace.source..":"..thisTrace.currentline..") failed unable to trace",4)
						end
					end
				end
			end
			if blendMode then dxSetBlendMode(blendMode) end
		end
	end
	return true
end

function dgsDrawText(text,leftX,topY,rightX,bottomY,color,scaleX,scaleY,font,alignX,alignY,clip,wordBreak,postGUI,colorCoded,subPixelPositioning,fRot,fRotCenterX,fRotCenterY,flineSpacing,shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont)
	if type(text) ~= "string" then
		local pluginType = dgsGetPluginType(text)
		if pluginType and dgsCustomTexture[pluginType] and not dgsElementData[text].disableCustomTexture then
			dgsDrawType = "text"
			return dgsCustomTexture[pluginType](text,leftX,topY,rightX,bottomY,color,scaleX,scaleY,font,alignX,alignY,clip,wordBreak,postGUI,colorCoded,subPixelPositioning,fRot,fRotCenterX,fRotCenterY,flineSpacing)
		end
	end
	if shadowOffsetX then
		local shadowText = text
		if colorCoded then
			shadowText = shadowText:gsub("#%x%x%x%x%x%x","") or shadowText
		end
		shadowFont = shadowFont or font or "default"
		if not shadowIsOutline or shadowIsOutline == 0 then
			dgsDrawText(shadowText,leftX+shadowOffsetX,topY+shadowOffsetY,rightX+shadowOffsetX,bottomY+shadowOffsetY,shadowColor,scaleX or 1,scaleY or 1,shadowFont,alignX or "left",alignY or "top",clip,wordBreak,postGUI,false,subPixelPositioning,fRot,fRotCenterX,fRotCenterY,flineSpacing)
		elseif shadowIsOutline == true or shadowIsOutline == 1 then
			dgsDrawText(shadowText,leftX+shadowOffsetX,topY+shadowOffsetY,rightX+shadowOffsetX,bottomY+shadowOffsetY,shadowColor,scaleX or 1,scaleY or 1,shadowFont,alignX or "left",alignY or "top",clip,wordBreak,postGUI,false,subPixelPositioning,fRot,fRotCenterX,fRotCenterY,flineSpacing)
			dgsDrawText(shadowText,leftX-shadowOffsetX,topY+shadowOffsetY,rightX-shadowOffsetX,bottomY+shadowOffsetY,shadowColor,scaleX or 1,scaleY or 1,shadowFont,alignX or "left",alignY or "top",clip,wordBreak,postGUI,false,subPixelPositioning,fRot,fRotCenterX,fRotCenterY,flineSpacing)
			dgsDrawText(shadowText,leftX-shadowOffsetX,topY-shadowOffsetY,rightX-shadowOffsetX,bottomY-shadowOffsetY,shadowColor,scaleX or 1,scaleY or 1,shadowFont,alignX or "left",alignY or "top",clip,wordBreak,postGUI,false,subPixelPositioning,fRot,fRotCenterX,fRotCenterY,flineSpacing)
			dgsDrawText(shadowText,leftX+shadowOffsetX,topY-shadowOffsetY,rightX+shadowOffsetX,bottomY-shadowOffsetY,shadowColor,scaleX or 1,scaleY or 1,shadowFont,alignX or "left",alignY or "top",clip,wordBreak,postGUI,false,subPixelPositioning,fRot,fRotCenterX,fRotCenterY,flineSpacing)
		elseif shadowIsOutline == 2 then
			dgsDrawText(shadowText,leftX+shadowOffsetX,topY+shadowOffsetY,rightX+shadowOffsetX,bottomY+shadowOffsetY,shadowColor,scaleX or 1,scaleY or 1,shadowFont,alignX or "left",alignY or "top",clip,wordBreak,postGUI,false,subPixelPositioning,fRot,fRotCenterX,fRotCenterY,flineSpacing)
			dgsDrawText(shadowText,leftX-shadowOffsetX,topY+shadowOffsetY,rightX-shadowOffsetX,bottomY+shadowOffsetY,shadowColor,scaleX or 1,scaleY or 1,shadowFont,alignX or "left",alignY or "top",clip,wordBreak,postGUI,false,subPixelPositioning,fRot,fRotCenterX,fRotCenterY,flineSpacing)
			dgsDrawText(shadowText,leftX-shadowOffsetX,topY-shadowOffsetY,rightX-shadowOffsetX,bottomY-shadowOffsetY,shadowColor,scaleX or 1,scaleY or 1,shadowFont,alignX or "left",alignY or "top",clip,wordBreak,postGUI,false,subPixelPositioning,fRot,fRotCenterX,fRotCenterY,flineSpacing)
			dgsDrawText(shadowText,leftX+shadowOffsetX,topY-shadowOffsetY,rightX+shadowOffsetX,bottomY-shadowOffsetY,shadowColor,scaleX or 1,scaleY or 1,shadowFont,alignX or "left",alignY or "top",clip,wordBreak,postGUI,false,subPixelPositioning,fRot,fRotCenterX,fRotCenterY,flineSpacing)
			dgsDrawText(shadowText,leftX,topY+shadowOffsetY,rightX,bottomY+shadowOffsetY,shadowColor,scaleX or 1,scaleY or 1,shadowFont,alignX or "left",alignY or "top",clip,wordBreak,postGUI,false,subPixelPositioning,fRot,fRotCenterX,fRotCenterY,flineSpacing)
			dgsDrawText(shadowText,leftX-shadowOffsetX,topY,rightX-shadowOffsetX,bottomY,shadowColor,scaleX or 1,scaleY or 1,shadowFont,alignX or "left",alignY or "top",clip,wordBreak,postGUI,false,subPixelPositioning,fRot,fRotCenterX,fRotCenterY,flineSpacing)
			dgsDrawText(shadowText,leftX,topY-shadowOffsetY,rightX,bottomY-shadowOffsetY,shadowColor,scaleX or 1,scaleY or 1,shadowFont,alignX or "left",alignY or "top",clip,wordBreak,postGUI,false,subPixelPositioning,fRot,fRotCenterX,fRotCenterY,flineSpacing)
			dgsDrawText(shadowText,leftX+shadowOffsetX,topY,rightX+shadowOffsetX,bottomY,shadowColor,scaleX or 1,scaleY or 1,shadowFont,alignX or "left",alignY or "top",clip,wordBreak,postGUI,false,subPixelPositioning,fRot,fRotCenterX,fRotCenterY,flineSpacing)
		end
	end
	if not dxDrawText(text,leftX,topY,rightX,bottomY,color,scaleX or 1,scaleY or 1,font or "default",alignX or "left",alignY or "top",clip,wordBreak,postGUI,colorCoded,subPixelPositioning,fRot,fRotCenterX,fRotCenterY,flineSpacing) then
		if debugMode then
			local debugTrace = dgsElementData[self].debugTrace
			local thisTrace = debug.getinfo(2)
			if debugTrace then
				local line,file = debugTrace.line,debugTrace.file
				outputDebugString("↑Caused by dgsDrawText("..thisTrace.source..":"..thisTrace.currentline..") failed at the element("..file..":"..line..")",4,255,200,100)
			else
				outputDebugString("↑Caused by dgsDrawText("..thisTrace.source..":"..thisTrace.currentline..") failed unable to trace",4,255,140,50)
			end
		end
		return false
	end
	return true
end
--[[
function dgsCreateTextBuffer(text,leading,textSizeX,textSizeY,font,isColorCoded,isWordWrap,lineSpacing,tabSpacing)
	local textTable = {}
	local _h = 0
	local tabSpacing = tabSpacing or 4
	local tHei = lineSpacing or dxGetFontHeight(1,"default")
	local lineStart = -1
	local blockStart,_w,colorBlockStart
	local color = 0xFFFFFFFF
	while true do	--\n
		local _n = text:find(_n,lineStart+2)
		_n = _n and _n-1 or nil
		local line = text:sub(lineStart+2,_n)
		lineStart = _n
		blockStart,_w = -1,0
		textTable[#textTable+1] = {[0]=line}
		local textTableLine = textTable[#textTable]
		if line ~= "" then
			while true do	--\t
				local _t = line:find(_t,blockStart+2)
				_t = _t and _t-1 or nil
				local block = line:sub(blockStart+2,_t)
				blockStart = _t
				colorBlockStart = -7
				if block ~= "" then
					while true do	--#RRGGBB
						local _c
						if isColorCoded then
							_c = block:find("#%x%x%x%x%x%x",colorBlockStart+8)
						end
						_c = _c and _c-1 or nil
						local c
						if _c then
							c = "0xFF"..block:sub(_c+2,_c+7)
						end
						local cblock = block:sub(colorBlockStart+8,_c)
						colorBlockStart = _c
						textTableLine[#textTableLine+1] = {cblock,_w,_h,color}
						_w = _w+dxGetTextWidth(cblock,1,"default")
						color = c or color
						if not _c then break end
					end
				end
				_w = _w-_w%tabSpace+tabSpace
				if not _t then break end
			end
		end
		_h = _h+tHei+lineSpace
		if not _n then break end
	end
	return textTable
end]]
--[[
local richTextMeta = {
	insert = function(text,isColorCoded,textSizeX,textSizeY,font)
		while text do
			
		end
	end,
}
function dgsCreateRichText(defaultTextSizeX,defaultTextSizeY,defaultFont,defaultColor)
	return {
		textSizeX = defaultTextSizeX or 1,
		textSizeY = defaultTextSizeY or 1,
		font = defaultFont or "default",
		color = defaultColor or white,
	}
end

function dgsDrawRichText(buffer,x,y)
	for line=1,#buffer do
		local l = buffer[line]
		for index=1,#l do
			local block = l[index]
			local text,offx,offy,color = block[1],block[2],block[3],block[4]
			dxDrawText(text,x+offx,y+offy,_,_,color)
		end
	end	
end
local rt = dgsCreateTextBuffer("123#FF0000123")
addEventHandler("onClientRender",root,function()
	dgsDrawRichText(rt,10,10)
end)]]
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
function dgsIsPixelPNG(pixel)
	local pngHeader = string.char(0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A)
	local pngTail = string.char(0xAE, 0x42, 0x60, 0x82)
	return #pixel >= 12 and pixel:sub(1,8) == pngHeader and pixel:sub(-4) == pngTail
end

function dgsIsPixelJPEG(pixel)
	local JpegHeader = string.char(0xFF, 0xD8, 0xFF)
	local JpegTail = string.char(0xFF, 0xD9)
	if #pixel >= 5 and pixel:sub(1,3) == JpegHeader and pixel:sub(-2) == JpegTail then
		local uiSeg1Size = pixel:sub(5,5):byte()*256+pixel:sub(6,6):byte()
		return uiSeg1Size + 5 < #pixel and pixel:sub(5+uiSeg1Size,5+uiSeg1Size):byte() == 0xFF
	end
    return false
end

function dgsIsPixelDDS(pixel)
	local ddsHeader = string.char(0x44, 0x44, 0x53, 0x20)
	return #pixel >= 4 and pixel:sub(1,4) == ddsHeader
end

function dgsGetPixelsFormat(pixels)
    if dgsIsPixelPNG(pixels) then return "png" end
    if dgsIsPixelJPEG(pixels) then return "jpeg" end
    if dgsIsPixelDDS(pixels) then return "dds" end
    if (#pixels >= 8) then
		local widA,widB = pixels:sub(-4,-3):byte(1,2)
		local width = widA*256+widB
		local heiA,heiB = pixels:sub(-2,-1):byte(1,2)
		local height = heiA*256+heiB
		if #pixels == width * height * 4 + 4 then return "plain" end
    end
	return false
end
--Render Target Assigner [Project AI]
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

function dgsAssignRTQueued(index)
	local element,w,h,size,priority = rtAssignQueue[index][1]
	local RTState = dgsElementData[element].RTState or {state=0,RT=nil,priority=priority}
	local vmRemain = dxGetStatus().VideoMemoryFreeForMTA
	if size < vmRemain then
		if RTState.state == 1 then
			local rt = dxCreateRenderTarget(w,h,true)
			table.remove(rtAssignQueue,index)
			if not rt then
				outputDebugString("[DGS]Failed to create render target for "..dgsGetType(element).." (Expected:"..size.."MB/"..vmRemain.."MB)")
				RTState.state = 0
				return false
			end
			RTState.state = 2
			RTState.RT = rt
			--AssignFor, Render Target, width, height, last used tick
			rtUsing[element] = {element,rt,w,h,0}
			return rtUsing[element]
		end
	end
end

function dgsAssignRT(element,w,h)
	local rt = dxCreateRenderTarget(w,h,true)
	if not rt then
		outputDebugString("[DGS]Failed to create render target for "..dgsGetType(element).." (Expected:"..size.."MB/"..vmRemain.."MB)")
		return false
	end
	--AssignFor, Render Target, width, height, last used tick
	rtUsing[element] = {element,rt,w,h,0}
	return rtUsing[element]
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
end
]]
--------------------------------DEBUG
local resourceDebugRegistered = {}
local debugContextQueue = {}

function onDGSRemoveImports()
	resourceDebugRegistered[source] = false
end

function onDGSLogImports(resRoot)
	resourceDebugRegistered[resRoot] = true
	removeEventHandler("onClientResourceStop",resRoot,onDGSRemoveImports)
	addEventHandler("onClientResourceStop",resRoot,onDGSRemoveImports,false)
end
addEventHandler("DGSI_onImport",root,onDGSLogImports)
triggerEvent("DGSI_onImport",root,resourceRoot)

function dgsDebugGetContext(resRoot,callBack)
	if resourceDebugRegistered[resRoot] then
		table.insert(debugContextQueue,{resRoot,callBack})
		triggerEvent("DGSI_onDebugRequestContext",resRoot)
		return true
	end
	return false
end

addEventHandler("DGSI_onDebugSendContext",root,function(context)
	if #debugContextQueue > 0 then
		debugContextQueue[1][2](context)
		table.remove(debugContextQueue,1)
	end
end)

-----------------------------SECURITY
DGSFileVerify = false
DGSFileInfo = getElementData(resourceRoot,"DGSI_FileInfo")
function verifyFile(fName,exportContent)
	if fileExists(fName) then
		local _hash,_size,_content = hashFile(fName,exportContent)
		local localFileInfo = {_hash,_size}
		local targetFileInfo = DGSFileInfo[fName]
		if localFileInfo[1] ~= targetFileInfo[1] or localFileInfo[2] ~= targetFileInfo[2] then
			return false,localFileInfo
		end
		return true,_content
	end
	return true
end

function verifyFiles()
	local mismatched = {}
	for fName,fData in pairs(DGSFileInfo) do
		local matched,fileInfo = verifyFile(fName)
		if not matched then
			mismatched[fName] = fileInfo
		end
	end
	if table.count(mismatched) > 0 then
		triggerServerEvent("DGSI_AbnormalDetected",localPlayer,mismatched)
	end
	setTimer(collectgarbage,1000,1)
end
addEventHandler("onDgsStart",resourceRoot,verifyFiles)