dgs = exports[getResourceName(getThisResource())]
addEvent("onDgsMouseLeave",true)
addEvent("onDgsMouseEnter",true)
addEvent("onDgsMouseClick",true)
addEvent("onDgsMouseDoubleClick",true)
addEvent("onDgsWindowClose",true)
addEvent("onDgsPositionChange",true)
addEvent("onDgsSizeChange",true)
addEvent("onDgsTextChange",true)
addEvent("onDgsScrollBarScrollPositionChange",true)
addEvent("onDgsDestroy",true)
addEvent("onDgsGridListSelect",true)
addEvent("onDgsGridListItemDoubleClick",true)
addEvent("onDgsProgressBarChange",true)
addEvent("onDgsCreate",true)
addEvent("onDgsPreCreate",true)
addEvent("onDgsPreRender",true)
addEvent("onDgsRender",true)
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

-------
addEvent("giveIPBack",true)


-------
GlobalEditParent = guiCreateLabel(0,0,0,0,"",false)
function table.find(tabl,value)
	for k,v in pairs(tabl) do
		if v == value then
			return k
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

function string.count(str)
	local _,count = string.gsub(str,"[^\128-\193]","")
	return count
end

function findRotation(x1,y1,x2,y2) 
	local t = -math.deg(math.atan2(x2-x1,y2-y1))
	return t<0 and t+360 or t
end

function string.split(s, delim, mode)
    if type(delim) ~= "string" or string.len(delim) <= 0 then
        return
    end
	if mode then
		local start = 1
		local t = {}
		local index = 1
		while true do
			local pos = string.find (s, delim, start, true)
			if not pos then
			  break
			end
			t[index] = string.sub(s,start,pos-1)
			start = pos + string.len(delim)
			index = index+1
		end
		t[index] = string.sub(s,start)
		return t
	else
		local start = 1
		local t = {}
		while true do
			local pos = string.find (s, delim, start, true)
			if not pos then
			  break
			end
			table.insert (t, string.sub (s, start, pos - 1))
			start = pos + string.len (delim)
		end
		table.insert (t, string.sub (s, start))
		return t
	end
end

function fromcolor(int,useMath)
	local a,r,g,b
	if useMath then
		b,g,r,a = bitExtract(int,0,8),bitExtract(int,8,8),bitExtract(int,16,8),bitExtract(int,24,8)
	else
		a,r,g,b = getColorFromString(string.format("#%.8x",int))
	end
	return r,g,b,a
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
