local cos,sin,rad,atan2,deg = math.cos,math.sin,math.rad,math.atan2,math.deg
local gsub,sub,len,find,format = string.gsub,string.sub,string.len,string.find,string.format
local insert = table.insert
dgs = exports[getResourceName(getThisResource())]
addEvent("onDgsMouseLeave",true)
addEvent("onDgsMouseEnter",true)
addEvent("onDgsMouseClick",true)
addEvent("onDgsMouseWheel",true)
addEvent("onDgsMouseDoubleClick",true)
addEvent("onDgsWindowClose",true)
addEvent("onDgsPositionChange",true)
addEvent("onDgsSizeChange",true)
addEvent("onDgsTextChange",true)
addEvent("onDgsScrollBarScrollPositionChange",true)
addEvent("onDgsScrollPaneScroll",true)
addEvent("onDgsDestroy",true)
addEvent("onDgsSwitchButtonStateChange",true)
addEvent("onDgsGridListSelect",true)
addEvent("onDgsGridListItemDoubleClick",true)
addEvent("onDgsProgressBarChange",true)
addEvent("onDgsCreate",true)
addEvent("onDgsPreRender",true)
addEvent("onDgsRender",true)
addEvent("onDgsElementRender",true)
addEvent("onDgsFocus",true)
addEvent("onDgsBlur",true)
addEvent("onDgsCursorMove",true)
addEvent("onDgsTabSelect",true)
addEvent("onDgsTabPanelTabSelect",true)
addEvent("onDgsRadioButtonChange",true)
addEvent("onDgsCheckBoxChange",true)
addEvent("onDgsComboBoxSelect",true)
addEvent("onDgsComboBoxStateChange",true)
addEvent("onDgsEditPreSwitch",true)
addEvent("onDgsEditSwitched",true)
addEvent("onDgsEditAccepted",true)
addEvent("onDgsComboBoxAccepted",true)
addEvent("onDgsStopMoving",true)
addEvent("onDgsStopSizing",true)
addEvent("onDgsStopAlphaing",true)
addEvent("onDgsStopAniming",true)
addEvent("onDgsArrowListValueChange",true)
addEvent("onDgsCursorDrag",true)
-------
addEvent("giveIPBack",true)

-------
fontDxHave = {
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

builtins = {
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
-------DEBUG
addCommandHandler("debugdgs",function(command,arg)
	if not arg then
		debugMode = (not getElementData(localPlayer,"DGS-DEBUG")) and 1 or false
		setElementData(localPlayer,"DGS-DEBUG",debugMode,false)
	elseif arg == "2" then
		debugMode = 2
		setElementData(localPlayer,"DGS-DEBUG",2,false)
	elseif arg == "c" then
		debugMode_CompatibilityCheck = not getElementData(localPlayer,"DGS-DEBUG-CompatibilityCheck")
		setElementData(localPlayer,"DGS-DEBUG-CompatibilityCheck",debugMode_CompatibilityCheck,false)
		outputChatBox("[DGS]Compatibility Check is "..(debugMode_CompatibilityCheck and "enabled" or "disabled"),0,255,0)
	end
end)

debugMode = getElementData(localPlayer,"DGS-DEBUG")
debugMode_CompatibilityCheck = getElementData(localPlayer,"DGS-DEBUG-CompatibilityCheck")
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

function table.arrayFind(tab,ke,num)
	if num then
		for i=1,#tab do
			if tab[i][num] == ke then
				return i
			end
		end
	else
		for i=1,#tab do
			if tab[i] == ke then
				return i
			end
		end
	end
	return false
end

function table.count(tabl)
	local cnt = 0
	for k,v in pairs(tabl) do
		cnt = cnt + 1
	end
	return cnt
end

function table.merger(...)
	local tab = {...}
	if #tab > 1 then
		local result = {}
		for k,v in ipairs(tab) do
			if type(v) ~= "table" then
				assert(false,"@table.merger argument "..k..",expect table got "..type(v))
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
	assert(type(theall) == "table","@table.complement argument 1,expect table got "..type(theall))
	local remove = table.merger(...)
	local newtable = {}
	for k,v in pairs(theall) do
		if not table.find(remove) then
			table.insert(newtable,v)
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
        return setmetatable(NewTable, getmetatable(obj))
    end
    return Func(obj)
end

--------------------------------String Utility
function string.count(str)
	local _,count = gsub(str,"[^\128-\193]","")
	return count
end

function string.split(s, delim)
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

--------------------------------Math Utility
function findRotation(x1,y1,x2,y2) 
	local t = -deg(atan2(x2-x1,y2-y1))
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
	if value >= n_min and value <= n_max then
		return true
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
--------------------------------Color Utility
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
	local b = color%256
	local color = (color-b)/256
	local g = color%256
	local color = (color-g)/256
	local r = color%256
	local color = (color-r)/256
	local a = color%256
	return a
end

function setColorAlpha(color,alpha)
	local b = color%256
	local color = (color-b)/256
	local g = color%256
	local color = (color-g)/256
	local r = color%256
	alpha = alpha-alpha%1
	return b+g*256+r*65536+alpha*16777216
end

function applyColorAlpha(color,alpha)
	local b = color%256
	local color = (color-b)/256
	local g = color%256
	local color = (color-g)/256
	local r = color%256
	local color = (color-r)/256
	local a = color%256*alpha
	a = a-a%1
	return b+g*256+r*65536+a*16777216
end

--------------------------------Other Utility
function dgsRunString(func,...)
	local fnc = loadstring(func)
	assert(type(fnc) == "function","[DGS]Can't Load Bad Function By dgsRunString")
	return fnc(...)
end

--------------------------------OOP Utility
