local cos,sin,rad,atan2 = math.cos,math.sin,math.rad,math.atan2
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
addEvent("onDgsGridListSelect",true)
addEvent("onDgsGridListItemDoubleClick",true)
addEvent("onDgsProgressBarChange",true)
addEvent("onDgsCreate",true)
addEvent("onDgsPreRender",true)
addEvent("onDgsRender",true)
addEvent("onDgsElementRender",true)
addEvent("onDgsElementRender",true)
addEvent("onDgsFocus",true)
addEvent("onDgsBlur",true)
addEvent("onDgsCursorMove",true)
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


-------DEBUG
addCommandHandler("debugdgs",function(command,arg)
	if not arg then
		debugMode = not getElementData(localPlayer,"DGS-DEBUG")
		setElementData(localPlayer,"DGS-DEBUG",debugMode,false)
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
	for k,v in pairs(tab) do
		if num then
			if v[num] == ke then
				return k
			end
		else
			if v == ke then
				return k
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

function string.split(s, delim, mode)
    if type(delim) ~= "string" or len(delim) <= 0 then
        return
    end
	if mode then
		local start = 1
		local t = {}
		local index = 1
		while true do
			local pos = find (s, delim, start, true)
			if not pos then
			  break
			end
			t[index] = sub(s,start,pos-1)
			start = pos + len(delim)
			index = index+1
		end
		t[index] = sub(s,start)
		return t
	else
		local start = 1
		local t = {}
		while true do
			local pos = find (s, delim, start, true)
			if not pos then
			  break
			end
			insert (t, sub (s, start, pos - 1))
			start = pos + len (delim)
		end
		insert (t, sub (s, start))
		return t
	end
end

--------------------------------Math Utility
function findRotation(x1,y1,x2,y2) 
	local t = -math.deg(math.atan2(x2-x1,y2-y1))
	return t<0 and t+360 or t
end

function math.restrict(n_min,n_max,value)
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
--------------------------------Color Utility
function fromcolor(int,useMath)
	local a,r,g,b
	if useMath then
		b,g,r,a = bitExtract(int,0,8),bitExtract(int,8,8),bitExtract(int,16,8),bitExtract(int,24,8)
	else
		a,r,g,b = getColorFromString(format("#%.8x",int))
	end
	return r,g,b,a
end

function getColorAlpha(color)
	return bitExtract(color,24,8)
end

function setColorAlpha(color,alpha)
	return bitReplace(color,alpha,24,8)
end

function applyColorAlpha(color,alpha)
	return bitReplace(color,bitExtract(color,24,8)*alpha,24,8)
end
--------------------------------Other Utility
function dgsRunString(func,...)
	local fnc = loadstring(func)
	assert(type(fnc) == "function","[DGS]Can't Load Bad Function By dgsRunString")
	return fnc(...)
end

--------------------------------OOP Utility
