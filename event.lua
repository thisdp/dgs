addEvent("onClientDgsDxMouseLeave",true)
addEvent("onClientDgsDxMouseEnter",true)
addEvent("onClientDgsDxMouseClick",true)
addEvent("onClientDgsDxMouseDoubleClick",true)
addEvent("onClientDgsDxWindowClose",true)
addEvent("onClientDgsDxGUIPositionChange",true)
addEvent("onClientDgsDxGUISizeChange",true)
addEvent("onClientDgsDxGUITextChange",true)
addEvent("onClientDgsDxScrollBarScrollPositionChange",true)
addEvent("onClientDgsDxGUIDestroy",true)
addEvent("onClientDgsDxGridListSelect",true)
addEvent("onClientDgsDxProgressBarChange",true)
addEvent("onClientDgsDxGUICreate",true)
addEvent("onClientDgsDxGUIPreCreate",true)
addEvent("onClientDgsDxPreRender",true)
addEvent("onClientDgsDxRender",true)
addEvent("onClientDgsDxFocus",true)
addEvent("onClientDgsDxBlur",true)
addEvent("onClientDgsDxGUICursorMove",true)
addEvent("onClientDgsDxTabPanelTabSelect",true)
addEvent("onClientDgsDxRadioButtonChanged",true)
addEvent("onClientDgsDxComboBoxSelect",true)
addEvent("onClientDgsDxComboBoxStateChanged",true)

-------
addEvent("giveIPBack",true)


-------
function table.find(tabl,value)
	for k,v in pairs(tabl) do
		if v == value then
			return k
		end
	end
	return false
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

--[[_dxSetRenderTarget = dxSetRenderTarget
nowRenderTarget = false
function dxSetRenderTarget(a,b)
	nowRenderTarget = a
	return _dxSetRenderTarget(a,b)
end

function dxClearRenderTarget(rndtgt)
	dxSetRenderTarget(rndtgt,true)
	dxSetRenderTarget(nowRenderTarget)
end]]