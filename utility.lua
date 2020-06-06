local cos,sin,rad,atan2,deg = math.cos,math.sin,math.rad,math.atan2,math.deg
local gsub,sub,len,find,format,byte = string.gsub,string.sub,string.len,string.find,string.format,byte
local setmetatable,ipairs,pairs = setmetatable,ipairs,pairs
local tableInsert = table.insert
local tableRemove = table.remove
local _dxDrawImageSection = dxDrawImageSection
local _dxDrawImage = dxDrawImage
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

-------DGS Built-in Texture
DGSBuiltInTex = {
	transParent_1x1 = dxCreateTexture(1,1,"dxt5"),
}

-------DEBUG
addCommandHandler("debugdgs",function(command,arg)
	if not arg then
		debugMode = (not getElementData(localPlayer,"DGS-DEBUG")) and 1 or false
		setElementData(localPlayer,"DGS-DEBUG",debugMode,false)
		outputChatBox("[DGS]Debug Mode "..(debugMode and "#00FF00Enabled" or "#FF0000Disabled"),255,255,255,true)
	elseif arg == "2" then
		debugMode = 2
		setElementData(localPlayer,"DGS-DEBUG",2,false)
		outputChatBox("[DGS]Debug Mode "..(debugMode and "#00FF00Enabled ( Mode 2 )"),255,255,255,true)
	elseif arg == "c" then
		local comp = not getElementData(localPlayer,"DGS-DEBUG-C")
		outputChatBox("[DGS]Debug Mode For Compatibility Check "..(comp and "#00FF00Enabled" or "#FF0000Disabled"),255,255,255,true)
		setElementData(localPlayer,"DGS-DEBUG-C",comp,false)
	end
end)

debugMode = getElementData(localPlayer,"DGS-DEBUG")
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
	return a + s * (b - a)
end

function math.seekEmpty(list)
	local cnt = 1
	while(list[cnt]) do
		cnt = cnt+1
	end
	return cnt
end

function getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix ( element )
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x,y,z
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
	left = true,
	center = true,
	right = true,
}

VerticalAlign = {
	top = true,
	center = true,
	bottom = true,
}
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
--------------------------------Dx Utility
function dxDrawImageExt(posX,posY,width,height,image,rotation,rotationX,rotationY,color,postGUI)
	local dgsBasicType = dgsGetType(image)
	if dgsBasicType == "table" then
		return _dxDrawImageSection(posX,posY,width,height,image[2],image[3],image[4],image[5],image[1],rotation,rotationX,rotationY,color,postGUI)
	elseif dgsBasicType == "dgs-dxcustomrenderer" then
		return dgsElementData[image].customRenderer(posX,posY,width,height,image,rotation,rotationX,rotationY,color,postGUI)
	else
		local pluginType = dgsGetPluginType(image)
		if pluginType == "dgs-dxcanvas" then
			dgsCanvasRender(image)
		elseif pluginType == "dgs-dxblurbox" then
			return _dxDrawImageSection(posX,posY,width,height,posX*blurboxFactor,posY*blurboxFactor,width*blurboxFactor,height*blurboxFactor,image,rotation,rotationX,rotationY,color,false)
		end
		return _dxDrawImage(posX,posY,width,height,image,rotation,rotationX,rotationY,color,postGUI)
	end
end

function dxDrawImageSectionExt(posX,posY,width,height,u,v,usize,vsize,image,rotation,rotationX,rotationY,color,postGUI)
	local dgsBasicType = dgsGetType(image)
	if dgsBasicType == "dgs-dxcustomrenderer" then
		return dgsElementData[image].customRenderer(posX,posY,width,height,image,rotation,rotationX,rotationY,color,postGUI)
	else
		if dgsGetPluginType(image) == "dgs-dxcanvas" then
			dgsCanvasRender(image)
		end
		return _dxDrawImageSection(posX,posY,width,height,u,v,usize,vsize,image,rotation,rotationX,rotationY,color,postGUI)
	end
end

_dxCreateRenderTarget = dxCreateRenderTarget
function dxCreateRenderTarget(w,h,isTransparent,dgsElement)
	local rt = _dxCreateRenderTarget(w,h,isTransparent)
	if not isElement(rt) then
		if w*h == 0 then return nil end	--Pass
		local videoMemory = dxGetStatus().VideoMemoryFreeForMTA
		local reqSize,reqUnit = getProperUnit(0.0000076*w*h,"MB")
		local freeSize,freeUnit = getProperUnit(videoMemory,"MB")
		local forWhat = dgsElement and (" for "..dgsGetPluginType(dgsElement)) or ""
		return false,"Failed to create render target"..forWhat.." [Expected:"..reqSize..reqUnit.."/Free:"..freeSize..freeUnit.."]"
	end
	return rt
end
--------------------------------Other Utility
function urlEncode(s)
    s = gsub(s,"([^%w%.%- ])",function(c)
		return string.format("%%%02X",c:byte())
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
--------------------------------Other Utility
function dgsRunString(func,...)
	local fnc = loadstring(func)
	assert(type(fnc) == "function","[DGS]Can't Load Bad Function By dgsRunString")
	return fnc(...)
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

--------------------------------Events
events = {
	"onDgsMouseLeave",
	"onDgsMouseEnter",
	"onDgsMouseClick",
	"onDgsMouseWheel",
	"onDgsMouseClickUp",
	"onDgsMouseClickDown",
	"onDgsMouseDoubleClick",
	"onDgsWindowClose",
	"onDgsPositionChange",
	"onDgsSizeChange",
	"onDgsTextChange",
	"onDgsElementScroll",
	"onDgsDestroy",
	"onDgsSwitchButtonStateChange",
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
	"onDgsMouseMove",
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
	"onDgsMouseDrag",
	"onDgsStart",
	-------Plugin events
	"onDgsRemoteImageLoad",
	"onDgsQRCodeLoad",
	-------internal events
	"DGSI_ReceiveIP",
	"DGSI_SendAboutData",
	"DGSI_ReceiveQRCode",
	"DGSI_ReceiveRemoteImage",
	-------
}
for i=1,#events do
	addEvent(events[i],true)
end
