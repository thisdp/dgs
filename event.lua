local cos,sin,rad,atan2,deg = math.cos,math.sin,math.rad,math.atan2,math.deg
local gsub,sub,len,find,format = string.gsub,string.sub,string.len,string.find,string.format
local insert = table.insert
ClientInfo = {
	SupportedPixelShader={}
}
dgs = exports[getResourceName(getThisResource())]
addEvent("onDgsMouseLeave",true)
addEvent("onDgsMouseEnter",true)
addEvent("onDgsMouseClick",true)
addEvent("onDgsMouseWheel",true)
addEvent("onDgsMouseClickUp",true)
addEvent("onDgsMouseClickDown",true)
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
addEvent("onDgsPluginCreate",true)
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

function dgsFindRotationByCenter(dgsEle,x,y,offsetFix)
	local posX,posY = dgsGetGuiLocationOnScreen(dgsEle,false)
	local absSize = dgsElementData[dgsEle].absSize
	local posX,posY = posX+absSize[1]/2,posY+absSize[2]/2
	local rot = findRotation(posX,posY,x,y,offsetFix)
	return rot,(x-posX)/absSize[1],(y-posY)/absSize[2]
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
	if color < 0 then
		color = 0x100000000+color
	end
	local rgb = color%0x1000000
	local a = (color-rgb)/0x1000000*alpha
	a = a-a%1
	return a
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
--HSL and HSV are not the same thing, while HSB is the same as HSV...

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
		if L < 0.5 then
			S = delta/(max+min)
		else
			S = delta/(2-max-min)
		end	
		local dR = ((max-R)/6+delta/2)/delta
		local dG = ((max-G)/6+delta/2)/delta
		local dB = ((max-B)/6+delta/2)/delta
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
	local min = math.min(R,G,B)
	local max = math.max(R,G,B)
	local V,H,S = max,0,0
	local delta = max - min
	if max ~= 0 then
		S = delta / max
	else
		S = 0
	end
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
	local HSL_S
	HSL_S = HSL_L == 0 and 0 or (HSL_L < 1 and S*V/(HSL_L < 0.5 and HSL_L*2 or 2-HSL_L*2) or S)
	return H*360,HSL_S*100,HSL_L*100
end

function HSL2HSV(H,S,L)
	H,S,L = H/360,S/100,L/100
	local tmp = S*(L<0.5 and L or 1-L)
	local HSV_V = L+tmp
	local HSV_S = L>0 and 2*tmp/HSV_V or S
	return H*360,HSV_S*100,HSV_V*100
end

--------------------------------Other Utility
function dgsRunString(func,...)
	local fnc = loadstring(func)
	assert(type(fnc) == "function","[DGS]Can't Load Bad Function By dgsRunString")
	return fnc(...)
end

--------------------------------OOP Utility

--------------------------------Dx Utility
PixelShaderCode = [[
	float4 main(float2 Tex : TEXCOORD0):COLOR0
	{
		return 0;
	}
	
	technique RepTexture
	{
		pass P0
		{
			PixelShader = compile ps_&rep main();
		}
	}
]]
PixShaderVersion = {"2_0","2_a","2_b","3_0"}
function checkPixelShaderVersion()
	for i,ver in ipairs(PixShaderVersion) do
		local shaderCode = string.gsub(PixelShaderCode,"&rep",ver)
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