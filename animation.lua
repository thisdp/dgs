local moveGUIList = {}
function dgsIsMoving(gui)
	assert(dgsIsDxElement(gui),"@dgsIsMoving argument 1,expect dgs-dxgui got "..tostring(isElement(gui) and dgsGetType(gui)) or type(gui))
	return moveGUIList[gui]
end

function dgsMoveTo(gui,x,y,relative,movetype,easing,torvx,vy)
	assert(dgsIsDxElement(gui),"@dgsMoveTo argument 1,expect dgs-dxgui got "..tostring(isElement(gui) and dgsGetType(gui)) or type(gui))
	assert(tonumber(x),"@dgsMoveTo argument 2,expect number got "..type(x))
	assert(tonumber(y),"@dgsMoveTo argument 3,expect number got "..type(y))
	assert(tonumber(torvx),"@dgsMoveTo argument 7,expect number got "..type(torvx))
	x = tonumber(x)
	y = tonumber(y)
	torvx = tonumber(torvx)
	local ox,oy = dgsGetPosition(gui,relative or false)
	dgsSetData(gui,"move",{[0]=getTickCount(),getDistanceBetweenPoints2D(ox,oy,x,y),ox,oy,x,y,relative or false,movetype,easing,torvx,vy or torvx})
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

function dgsSizeTo(gui,x,y,relative,movetype,easing,torvx,vy)
	assert(dgsIsDxElement(gui),"@dgsSizeTo argument 1,expect dgs-dxgui got "..tostring(isElement(gui) and dgsGetType(gui)) or type(gui))
	assert(tonumber(x),"@dgsSizeTo argument 2,expect number got "..type(x))
	assert(tonumber(y),"@dgsSizeTo argument 3,expect number got "..type(y))
	assert(tonumber(torvx),"@dgsSizeTo argument 7,expect number got "..type(torvx))
	x = tonumber(x)
	y = tonumber(y)
	torvx = tonumber(torvx)
	local ox,oy = dgsGetSize(gui,relative or false)
	dgsSetData(gui,"size",{[0]=getTickCount(),getDistanceBetweenPoints2D(ox,oy,x,y),ox,oy,x,y,relative or false,movetype,easing,torvx,vy or torvx})
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

function dgsAlphaTo(gui,toalpha,movetype,easing,torv)
	assert(dgsIsDxElement(gui),"@dgsAlphaTo argument 1,expect dgs-dxgui got "..(isElement(gui) and dgsGetType(gui)) or type(gui))
	assert(tonumber(toalpha),"@dgsAlphaTo argument 2,expect number got "..type(toalpha))
	assert(tonumber(torv),"@dgsAlphaTo argument 5,expect number got "..type(torv))
	toalpha = tonumber(toalpha)
	torv = tonumber(torv)
	local toalpha = (toalpha > 1 and 1) or (toalpha < 0 and 0) or toalpha
	dgsSetData(gui,"calpha",{[0]=getTickCount(),dgsGetData(gui,"alpha")-toalpha,toalpha,movetype,easing,torv})
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
		if isElement(v) and value then
			local datas = dgsGetData(v,"move")
			if datas then
				local allDistance,ox,oy,x,y,rlt,mtype,easing,torvx,vy = unpack(datas)
				local nx,ny = dgsGetPosition(v,rlt)
				local tx,ty
				local compMove = false
				if mtype then
					local percentxo = (nx-ox)/(x-ox)
					local percentyo = (ny-oy)/(y-oy)
					local percentx,percenty = getEasingValue(percentxo,easing or "Linear")*percentxo,getEasingValue(percentyo,easing or "Linear")*percentyo
					if percentxo >= 1 and percentyo >= 1 then
						compMove = true
						tx,ty = x,y
					else
						tx,ty = nx+torvx+percentx*torvx,ny+vy+percenty*vy
					end
				else
					local changeTime = tickCount-datas[0]
					local temp = changeTime/torvx
					local percentx,percenty = interpolateBetween(ox,oy,0,x,y,0,temp,easing or "Linear")
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
			else
				moveGUIList[v] = nil
			end
		else
			moveGUIList[v] = nil
		end
	end
	for v,value in pairs(sizeGUIList) do
		if isElement(v) and value then
			local datas = dgsGetData(v,"size")
			if datas then
				local allDistance,ox,oy,x,y,rlt,mtype,easing,torvx,vy = unpack(datas)
				local nx,ny = dgsGetSize(v,rlt)
				local tx,ty
				local compSize = false
				if mtype then
					local percentxo,percentyo
					local disx = x-ox
					if disx ~= 0 then
						percentxo = (nx-ox)/disx
					else
						percentxo = 1
					end
					local disy = y-oy
					if disy ~= 0 then
						percentyo = (ny-oy)/disy
					else
						percentyo = 1
					end
					local percentx,percenty = getEasingValue(percentxo,easing or "Linear")*percentxo,getEasingValue(percentyo,easing or "Linear")*percentyo
					if percentxo >= 1 and percentyo >= 1 then
						compSize = true
						tx,ty = x,y
					else
						tx,ty = nx+torvx+percentx*torvx,ny+vy+percenty*vy
					end
				else
					local changeTime = tickCount-datas[0]
					local temp = changeTime/torvx
					local percentx,percenty = interpolateBetween(ox,oy,0,x,y,0,temp,easing or "Linear")
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
			else
				sizeGUIList[v] = nil
			end
		else
			sizeGUIList[v] = nil
		end
	end
	for v,value in pairs(alphaGUIList) do
		if isElement(v) and value then
			local datas = dgsGetData(v,"calpha")
			if datas then
				local allDistance,endalpha,mtype,easing,torv = unpack(datas)
				local alp = dgsGetData(v,"alpha")
				if alp then
					local talp
					local compAlpha = false
					if mtype then
						local percentalpo = (alp-(endalpha+allDistance)/allDistance)
						local percentalp = getEasingValue(percentalpo,easing or "Linear")*percentalpo
						if percentalpo >= 1 then
							compAlpha = true
							talp = endalpha
						else
							talp = talp+torv+percentalp*torv
						end
					else
						local changeTime = tickCount-datas[0]
						local temp = changeTime/torv
						local percentalp = interpolateBetween(endalpha+allDistance,0,0,endalpha,0,0,temp,easing or "Linear")
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
				else
					alphaGUIList[v] = nil
				end
			else
				alphaGUIList[v] = nil
			end
		else
			alphaGUIList[v] = nil
		end
	end
	tickCount = getTickCount()
end)