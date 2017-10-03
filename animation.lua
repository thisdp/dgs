local moveGUIList = {}
function dgsIsMoving(gui)
	assert(dgsIsDxElement(gui),"@dgsIsMoving argument 1,expect dgs-dxgui got "..tostring(isElement(gui) and dgsGetType(gui)) or type(gui))
	return moveGUIList[gui]
end

function dgsMoveTo(gui,x,y,relative,movetype,easing,torvx,vy,tab)
	assert(dgsIsDxElement(gui),"@dgsMoveTo argument 1,expect dgs-dxgui got "..tostring(isElement(gui) and dgsGetType(gui)) or type(gui))
	assert(tonumber(x),"@dgsMoveTo argument 2,expect number got "..type(x))
	assert(tonumber(y),"@dgsMoveTo argument 3,expect number got "..type(y))
	assert(tonumber(torvx),"@dgsMoveTo argument 7,expect number got "..type(torvx))
	x = tonumber(x)
	y = tonumber(y)
	torvx = tonumber(torvx)
	local ox,oy = dgsGetPosition(gui,relative or false)
	dgsSetData(gui,"move",{[-1]=tab,[0]=getTickCount(),getDistanceBetweenPoints2D(ox,oy,x,y),ox,oy,x,y,relative or false,movetype,easing or "Linear",torvx,vy or torvx})
	if not moveGUIList[gui] then
		moveGUIList[gui] = true
		return true
	end
	return false
end

function dgsStopMoving(gui)
	assert(dgsIsDxElement(gui),"@dgsStopMoving argument 1,expect dgs-dxgui got "..tostring(isElement(gui) and dgsGetType(gui)) or type(gui))
	if moveGUIList[gui] then
		dgsSetData(gui,"move",false)
		moveGUIList[gui] = nil
		return true
	end
	return false
end

local sizeGUIList = {}
function dgsIsSizing(gui)
	assert(dgsIsDxElement(gui),"@dgsIsSizing argument 1,expect dgs-dxgui got "..tostring(isElement(gui) and dgsGetType(gui)) or type(gui))
	return sizeGUIList[gui]
end

function dgsSizeTo(gui,x,y,relative,movetype,easing,torvx,vy,tab)
	assert(dgsIsDxElement(gui),"@dgsSizeTo argument 1,expect dgs-dxgui got "..tostring(isElement(gui) and dgsGetType(gui)) or type(gui))
	assert(tonumber(x),"@dgsSizeTo argument 2,expect number got "..type(x))
	assert(tonumber(y),"@dgsSizeTo argument 3,expect number got "..type(y))
	assert(tonumber(torvx),"@dgsSizeTo argument 7,expect number got "..type(torvx))
	x = tonumber(x)
	y = tonumber(y)
	torvx = tonumber(torvx)
	local ox,oy = dgsGetSize(gui,relative or false)
	dgsSetData(gui,"size",{[-1]=tab,[0]=getTickCount(),getDistanceBetweenPoints2D(ox,oy,x,y),ox,oy,x,y,relative or false,movetype,easing or "Linear",torvx,vy or torvx})
	if not sizeGUIList[gui] then
		sizeGUIList[gui] = true
		return true
	end
	return false
end

function dgsStopSizing(gui)
	assert(dgsIsDxElement(gui),"@dgsStopSizing argument 1,expect dgs-dxgui got "..tostring(isElement(gui) and dgsGetType(gui)) or type(gui))
	if sizeGUIList[gui] then
		dgsSetData(gui,"size",false)
		sizeGUIList[gui] = nil
		return true
	end
	return false
end

local alphaGUIList = {}
function dgsIsAlphaing(gui)
	assert(dgsIsDxElement(gui),"@dgsIsAlphaing argument 1,expect dgs-dxgui got "..tostring(isElement(gui) and dgsGetType(gui)) or type(gui))
	return alphaGUIList[gui]
end

function dgsAlphaTo(gui,toalpha,movetype,easing,torv,tab)
	assert(dgsIsDxElement(gui),"@dgsAlphaTo argument 1,expect dgs-dxgui got "..(isElement(gui) and dgsGetType(gui)) or type(gui))
	assert(tonumber(toalpha),"@dgsAlphaTo argument 2,expect number got "..type(toalpha))
	assert(tonumber(torv),"@dgsAlphaTo argument 5,expect number got "..type(torv))
	toalpha = tonumber(toalpha)
	torv = tonumber(torv)
	local toalpha = (toalpha > 1 and 1) or (toalpha < 0 and 0) or toalpha
	dgsSetData(gui,"calpha",{[-1]=tab,[0]=getTickCount(),dgsGetData(gui,"alpha")-toalpha,toalpha,movetype,easing or "Linear",torv})
	if not alphaGUIList[gui] then
		alphaGUIList[gui] = true
		return true
	end
	return
end

function dgsStopAlphaing(gui)
	assert(dgsIsDxElement(gui),"@dgsStopAlphaing argument 1,expect dgs-dxgui got "..tostring(isElement(gui) and dgsGetType(gui)) or type(gui))
	if alphaGUIList[gui] then
		dgsSetData(gui,"calpha",false)
		alphaGUIList[gui] = nil
		return true
	end
	return false
end

addEventHandler("onClientRender",root,function()
	local tickCount = getTickCount()
	for v,value in pairs(moveGUIList) do
		if not isElement(v) or not value then moveGUIList[v] = nil end
		local datas = dgsElementData[v].move
		if not datas then moveGUIList[v] = nil end
		local allDistance,ox,oy,x,y,rlt,mtype,easing,torvx,vy,settings = datas[1],datas[2],datas[3],datas[4],datas[5],datas[6],datas[7],datas[8],datas[9],datas[-1]
		local nx,ny = dgsGetPosition(v,rlt)
		local tx,ty
		local compMove = false
		local percentx,percenty
		if mtype then
			local disx,disy = x-ox,y-oy
			local percentxo,percentyo = disx~=0 and (nx-ox)/disx or 1,disy ~= 0 and (ny-oy)/disy or 1
			if builtins[easing] then
				percentx,percenty = getEasingValue(percentxo,easing)*percentxo,getEasingValue(percentyo,easing)*percentyo
			else
				percentx,percenty = getEasingValue2(percentxo,easing,settings)*percentxo,getEasingValue2(percentyo,easing,settings)*percentyo
			end
			if percentxo >= 1 and percentyo >= 1 then
				compMove = true
				tx,ty = x,y
			else
				tx,ty = nx+torvx,ny+vy
			end
		else
			local changeTime = tickCount-datas[0]
			local temp = changeTime/torvx
			if builtins[easing] then
				percentx,percenty = interpolateBetween(ox,oy,0,x,y,0,temp,easing)
			else
				percentx,percenty = interpolateBetween2(ox,oy,0,x,y,0,temp,easing,settings)
			end
			if temp >= 1 then
				compMove = true
				tx,ty = x,y
			else
				tx,ty = percentx,percenty
			end
		end
		dgsSetPosition(v,tx,ty,rlt)
		if compMove then
			dgsStopMoving(v)
		end
	end
	for v,value in pairs(sizeGUIList) do
		if not isElement(v) or not value then sizeGUIList[v] = nil end
		local datas = dgsGetData(v,"size")
		if not datas then sizeGUIList[v] = nil end
		local allDistance,ox,oy,x,y,rlt,mtype,easing,torvx,vy,settings = datas[1],datas[2],datas[3],datas[4],datas[5],datas[6],datas[7],datas[8],datas[9],datas[-1]
		local nx,ny = dgsGetSize(v,rlt)
		local tx,ty
		local compSize = false
		local percentx,percenty
		if mtype then
			local disx,disy = x-ox,y-oy
			local percentxo,percentyo = disx~=0 and (nx-ox)/disx or 1,disy ~= 0 and (ny-oy)/disy or 1
			if builtins[easing] then
				percentx,percenty = getEasingValue(percentxo,easing)*percentxo,getEasingValue(percentyo,easing)*percentyo
			else
				percentx,percenty = getEasingValue2(percentxo,easing,settings)*percentxo,getEasingValue2(percentyo,easing,settings)*percentyo
			end
			if percentxo >= 1 and percentyo >= 1 then
				compSize = true
				tx,ty = x,y
			else
				tx,ty = nx+torvx,ny+vy
			end
		else
			local changeTime = tickCount-datas[0]
			local temp = changeTime/torvx
			if builtins[easing] then
				percentx,percenty = interpolateBetween(ox,oy,0,x,y,0,temp,easing)
			else
				percentx,percenty = interpolateBetween2(ox,oy,0,x,y,0,temp,easing,settings)
			end
			if temp >= 1 then
				compSize = true
				tx,ty = x,y
			else
				tx,ty = percentx,percenty
			end
		end
		dgsSetSize(v,tx,ty,rlt)
		if compSize then
			dgsStopSizing(v)
		end
	end
	for v,value in pairs(alphaGUIList) do
		if not isElement(v) or not value then alphaGUIList[v] = nil end
		local datas = dgsElementData[v].calpha
		if not datas then alphaGUIList[v] = nil end
		local allDistance,endalpha,mtype,easing,torv,settings = datas[1],datas[2],datas[3],datas[4],datas[5],datas[-1]
		local alp = dgsElementData[v].alpha
		if not alp then alphaGUIList[v] = nil end
		local talp
		local compAlpha = false
		local percentalp
		if mtype then
			local percentalpo = alp-(endalpha+allDistance)/allDistance
			if builtins[easing] then
				percentalp = getEasingValue(percentalpo,easing or "Linear")*percentalpo
			else
				percentalp = getEasingValue2(percentalpo,easing,settings)*percentalpo
			end
			if percentalpo >= 1 then
				compAlpha = true
				talp = endalpha
			else
				talp = talp+torv+percentalp*torv
			end
		else
			local changeTime = tickCount-datas[0]
			local temp = changeTime/torv
			if builtins[easing] then
				percentalp = interpolateBetween(endalpha+allDistance,0,0,endalpha,0,0,temp,easing or "Linear")
			else
				percentalp = interpolateBetween2(endalpha+allDistance,0,0,endalpha,0,0,temp,easing,settings)
			end
			if temp >= 1 then
				compAlpha = true
				talp = endalpha
			else
				talp = percentalp
			end
		end
		dgsSetData(v,"alpha",talp)
		if compAlpha then
			dgsStopAlphaing(v)
		end
	end
	tickCount = getTickCount()
end)

function interpolateBetween2(x,y,z,tx,ty,tz,percent,easing,settings)
	if SelfEasing[easing] then
		local nx,ny,nz = 0,0,0
		local temp = SelfEasing[easing](percent,settings)
		local diff = {tx-x,ty-y,tz-z}
		if diff[1] ~= 0 then
			nx = temp*diff[1]+x
		end
		if diff[2] ~= 0 then
			ny = temp*diff[2]+y
		end
		if diff[3] ~= 0 then
			ny = temp*diff[3]+z
		end
		return nx,ny,nz
	end
	return false
end

function getEasingValue2(percent,easing,settings)
	if SelfEasing[easing] then
		return SelfEasing[easing](percent,settings)
	end
end