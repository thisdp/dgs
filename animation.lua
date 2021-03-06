local loadstring = loadstring
---------------Speed Up
local assert = assert
local type = type
local tonumber = tonumber
local triggerEvent = triggerEvent

function dgsIsAniming(gui)
	assert(dgsIsType(gui),"Bad argument @dgsIsAniming at argument 1, expect dgs-dxgui got "..dgsGetType(gui))
	return animGUIList[gui] or false
end

function dgsAnimTo(gui,property,value,easing,thetime,delay,callback,reverseProgress)
	delay = delay or 0
	if type(gui) == "table" then
		for i=1,#gui do
			dgsAnimTo(gui[i],property,value,easing,thetime,delay,callback,reverseProgress)
		end
		return true
	end
	assert(dgsIsType(gui),"Bad argument @dgsAnimTo at argument 1, expect dgs-dxgui got "..dgsGetType(gui))
	local thetime = tonumber(thetime)
	assert(type(property) == "string","Bad argument @dgsAnimTo at argument 2, expect string got "..type(property))
	assert(thetime,"Bad argument @dgsAnimTo at argument 6, expect number got "..type(thetime))
	local easing = easing or "Linear"
	assert(dgsEasingFunctionExists(easing),"Bad argument @dgsAnimTo at argument 4, easing function doesn't exist ("..tostring(easing)..")")
	assert(not(type(value) ~= "number" and easingBuiltIn[easing]),"Bad argument @dgsAnimTo, only number can be passed with mta built-in easing type")
	if not dgsElementData[gui].anim then
		dgsElementData[gui].anim = {}
	end
	if not dgsElementData[gui].anim[property] then
		dgsElementData[gui].anim[property] = {[-2]=delay,[-1]=index,[0]=getTickCount(),property, value, dgsElementData[gui][property],easing,thetime,callback = callback,reverseProgress=reverseProgress}
		if not animGUIList[gui] then
			animGUIList[gui] = true
		end
		return true
	end
	return false
end

function dgsStopAniming(gui,property)
	if type(gui) == "table" then
		for i=1,#gui do
			dgsStopAniming(gui,property)
		end
		return true
	end
	assert(dgsIsType(gui),"Bad argument @dgsStopAniming at argument 1, expect dgs-dxgui got "..dgsGetType(gui))
	if animGUIList[gui] then
		local animList = dgsElementData[gui].anim or {}
		if property then
			if animList[property] then
				local callback = animList[property]["callback"]
				triggerEvent("onDgsStopAniming",gui,property)
				animList[property] = nil
				if not next(animList) then
					animGUIList[gui] = nil
				end
				if callback then callback(gui) end
			end
		else
			animGUIList[gui] = nil
			for k,v in pairs(animList) do
				local callback = v["callback"]
				triggerEvent("onDgsStopAniming",gui,k)
				if callback then callback() end
			end
			dgsSetData(gui,"anim",nil)
		end
		return true
	end
	return false
end

function dgsIsMoving(gui)
	assert(dgsIsType(gui),"Bad argument @dgsIsMoving at argument 1, expect dgs-dxgui got "..dgsGetType(gui))
	return moveGUIList[gui] or false
end

function dgsMoveTo(gui,x,y,relative,movetype,easing,torvx,vy,delay,tab)
	delay = delay or 0
	if type(gui) == "table" then
		for i=1,#gui do
			dgsMoveTo(gui[i],x,y,relative,movetype,easing,torvx,vy,delay,tab)
		end
		return true
	end
	assert(dgsIsType(gui),"Bad argument @dgsMoveTo at argument 1, expect dgs-dxgui got "..dgsGetType(gui))
	local x,y,torvx = tonumber(x),tonumber(y),tonumber(torvx)
	assert(x,"Bad argument @dgsMoveTo at argument 2, expect number got "..type(x))
	assert(y,"Bad argument @dgsMoveTo at argument 3, expect number got "..type(y))
	assert(torvx,"Bad argument @dgsMoveTo at argument 7, expect positive number got "..type(torvx))
	assert(torvx >= 0,"Bad argument @dgsMoveTo at argument 7, expect positive number got "..torvx)
	local easing = easing or "Linear"
	assert(dgsEasingFunctionExists(easing),"Bad argument @dgsMoveTo at argument 6, easing function doesn't exist ("..tostring(easing)..")")
	local ox,oy = dgsGetPosition(gui,relative or false)
	dgsSetData(gui,"move",{[-2]=delay,[-1]=tab,[0]=getTickCount(),ox,oy,x,y,relative or false,movetype,easing,torvx,vy or torvx})
	if not moveGUIList[gui] then
		moveGUIList[gui] = true
		return true
	end
	return false
end

function dgsStopMoving(gui)
	if type(gui) == "table" then
		for i=1,#gui do
			dgsStopMoving(gui)
		end
		return true
	end
	assert(dgsIsType(gui),"Bad argument @dgsStopMoving at argument 1, expect dgs-dxgui got "..dgsGetType(gui))
	if moveGUIList[gui] then
		dgsSetData(gui,"move",nil)
		moveGUIList[gui] = nil
		triggerEvent("onDgsStopMoving",gui)
		return true
	end
	return false
end

function dgsIsSizing(gui)
	assert(dgsIsType(gui),"Bad argument @dgsIsSizing at argument 1, expect dgs-dxgui got "..dgsGetType(gui))
	return sizeGUIList[gui] or false
end

function dgsSizeTo(gui,x,y,relative,movetype,easing,torvx,vy,delay,tab)
	delay = delay or 0
	if type(gui) == "table" then
		for i=1,#gui do
			dgsSizeTo(gui[i],x,y,relative,movetype,easing,torvx,vy,delay,tab)
		end
		return true
	end
	assert(dgsIsType(gui),"Bad argument @dgsSizeTo at argument 1, expect dgs-dxgui got "..dgsGetType(gui))
	local x,y,torvx = tonumber(x),tonumber(y),tonumber(torvx)
	assert(x,"Bad argument @dgsSizeTo at argument 2, expect number got "..type(x))
	assert(y,"Bad argument @dgsSizeTo at argument 3, expect number got "..type(y))
	assert(torvx,"Bad argument @dgsSizeTo at argument 7, expect number got "..type(torvx))
	assert(torvx >= 0,"Bad argument @dgsSizeTo at argument 7, expect positive number got "..torvx)
	local easing = easing or "Linear"
	assert(dgsEasingFunctionExists(easing),"Bad argument @dgsSizeTo at argument 6, easing function doesn't exist ("..tostring(easing)..")")
	local ox,oy = dgsGetSize(gui,relative or false)
	dgsSetData(gui,"size",{[-2]=delay,[-1]=tab,[0]=getTickCount(),ox,oy,x,y,relative or false,movetype,easing,torvx,vy or torvx})
	if not sizeGUIList[gui] then
		sizeGUIList[gui] = true
		return true
	end
	return false
end

function dgsStopSizing(gui)
	if type(gui) == "table" then
		for i=1,#gui do
			dgsStopSizing(gui)
		end
		return true
	end
	assert(dgsIsType(gui),"Bad argument @dgsStopSizing at argument 1, expect dgs-dxgui got "..dgsGetType(gui))
	if sizeGUIList[gui] then
		dgsSetData(gui,"size",nil)
		sizeGUIList[gui] = nil
		triggerEvent("onDgsStopSizing",gui)
		return true
	end
	return false
end

function dgsIsAlphaing(gui)
	assert(dgsIsType(gui),"Bad argument @dgsIsAlphaing at argument 1, expect dgs-dxgui got "..dgsGetType(gui))
	return alphaGUIList[gui] or false
end

function dgsAlphaTo(gui,toalpha,movetype,easing,torv,delay,tab)
	delay = delay or 0
	if type(gui) == "table" then
		for i=1,#gui do
			dgsAlphaTo(gui[i],toalpha,movetype,easing,torv,delay,tab)
		end
		return true
	end
	assert(dgsIsType(gui),"Bad argument @dgsAlphaTo at argument 1, expect dgs-dxgui got "..dgsGetType(gui))
	local toalpha,torv = tonumber(toalpha),tonumber(torv)
	assert(toalpha,"Bad argument @dgsAlphaTo at argument 2, expect number got "..type(toalpha))
	assert(torv,"Bad argument @dgsAlphaTo at argument 5, expect number got "..type(torv))
	assert(torv >= 0,"Bad argument @dgsAlphaTo at argument 7, expect positive number got "..torv)
	local easing = easing or "Linear"
	assert(dgsEasingFunctionExists(easing),"Bad argument @dgsAlphaTo at argument 4, easing function doesn't exist ("..tostring(easing)..")")
	local toalpha = (toalpha > 1 and 1) or (toalpha < 0 and 0) or toalpha
	dgsSetData(gui,"calpha",{[-2]=delay,[-1]=tab,[0]=getTickCount(),dgsElementData[gui].alpha,toalpha,movetype,easing,torv})
	if not alphaGUIList[gui] then
		alphaGUIList[gui] = true
		return true
	end
	return
end

function dgsStopAlphaing(gui)
	assert(dgsIsType(gui),"Bad argument @dgsStopAlphaing at argument 1, expect dgs-dxgui got "..dgsGetType(gui))
	if alphaGUIList[gui] then
		dgsSetData(gui,"calpha",nil)
		alphaGUIList[gui] = nil
		triggerEvent("onDgsStopAlphaing",gui)
		return true
	end
	return false
end

local animGarbage = {}
local moveGarbage = {[0]=0}
local sizeGarbage = {[0]=0}
local alphaGarbage = {[0]=0}
tickCount = getTickCount()
addEventHandler("onClientRender",root,function()
	local tick = getTickCount()
	local diff = tick-tickCount
	tickCount = tick
	for v,value in pairs(animGUIList) do
		if not dgsIsType(v) or not value then
			--animGarbage[#animGarbage+1] = v
		else
			local animList = dgsElementData[v].anim
			if animGUIList[v] then
				for _,data in pairs(animList) do
					local propertyName,targetValue,oldValue,easing,thetime,isReversed,delay = data[1],data[2],data[3],data[4],data[5],data.reverseProgress,data[-2]
					local changeTime = tickCount-data[0]
					local changeTime = (tickCount-delay)-data[0]
					local ctPercent = changeTime/thetime
					ctPercent = ctPercent <= 0 and 0 or ctPercent
					local linearProgress = ctPercent >= 1 and 1 or ctPercent
					linearProgress = isReversed and 1-linearProgress or linearProgress
					if easingBuiltIn[easing] then
						local percent = oldValue+getEasingValue(linearProgress,easing)*(targetValue-oldValue)
						dgsSetProperty(v,propertyName,percent)
					else
						if dgsEasingFunction[easing] then
							local value = dgsEasingFunction[easing](linearProgress,{propertyName,targetValue,oldValue},v)
							dgsSetProperty(v,propertyName,value)
						else
							dgsStopAniming(v,propertyName)
							assert(false,"Bad argument @dgsAnimTo, easing function is missing during running easing funcition("..easing..")")
						end
					end
					if ctPercent >= 1 then
						dgsStopAniming(v,propertyName)
					end
				end
			end
		end
	end
	for v,value in pairs(moveGUIList) do
		if not dgsIsType(v) or not value then
			moveGarbage[0] = moveGarbage[0]+1
			moveGarbage[moveGarbage[0]] = v
		else
			local data = dgsElementData[v].move
			if not data then moveGUIList[v] = nil end
			if moveGUIList[v] then
				local ox,oy,x,y,rlt,mtype,easing,torvx,vy,settings,delay = data[1],data[2],data[3],data[4],data[5],data[6],data[7],data[8],data[9],data[-1],data[-2]
				local nx,ny = dgsGetPosition(v,rlt)
				local compMove = false
				local percentx,percenty
				if mtype then
					local disx,disy = x-ox,y-oy
					local symbolX,symbolY = disx < 0 and -1 or 1,disy < 0 and -1 or 1
					local speedX,speedY = torvx*diff*symbolX*0.001,vy*diff*symbolY*0.001
					local finishX,finishY = false,false
					if disx ~= 0 then
						local progress = (nx-ox)/disx
						if easingBuiltIn[easing] then
							percentx = getEasingValue(progress,easing)
						else
							percentx = getEasingValue2(progress,easing,settings,v)
						end
						if progress < 1 then
							nx = nx+speedX
							if nx*symbolX > x*symbolX then
								nx = x
							end
						else
							nx = x
							finishX = true
						end
					end
					if disy ~= 0 then
						local progress = (ny-oy)/disy
						if easingBuiltIn[easing] then
							percenty = getEasingValue(progress,easing)
						else
							percenty = getEasingValue2(progress,easing,settings,v)
						end
						if progress < 1 then
							ny = ny+speedY
							if ny*symbolY > y*symbolY then
								ny = y
							end
						else
							ny = y
							finishY = true
						end
					end
					compMove = finishX and finishY
				else
					local changeTime = (tickCount-delay)-data[0]
					local temp = changeTime/torvx
					temp = temp <= 0 and 0 or temp
					if easingBuiltIn[easing] then
						percentx,percenty = interpolateBetween(ox,oy,0,x,y,0,temp,easing)
					else
						percentx,percenty = interpolateBetween2(ox,oy,0,x,y,0,temp,easing,settings,v)
					end
					if temp >= 1 then
						compMove = true
						nx,ny = x,y
					else
						nx,ny = percentx,percenty
					end
				end
				dgsSetPosition(v,nx,ny,rlt)
				if compMove then
					dgsSetData(v,"move",nil)
					moveGarbage[0] = moveGarbage[0]+1
					moveGarbage[moveGarbage[0]] = v
				end
			end
		end
	end
	for v,value in pairs(sizeGUIList) do
		if not dgsIsType(v) or not value then
			sizeGarbage[#sizeGarbage+1] = v
		else
			local data = dgsElementData[v].size
			if not data then sizeGUIList[v] = nil end
			if sizeGUIList[v] then
				local ox,oy,x,y,rlt,mtype,easing,torvx,vy,settings,delay = data[1],data[2],data[3],data[4],data[5],data[6],data[7],data[8],data[9],data[-1],data[-2]
				local nx,ny = dgsGetSize(v,rlt)
				local compSize = false
				local percentx,percenty
				if mtype then
					local disx,disy = x-ox,y-oy
					local symbolX,symbolY = disx < 0 and -1 or 1,disy < 0 and -1 or 1
					local speedX,speedY = torvx*diff*symbolX*0.001,vy*diff*symbolY*0.001
					local finishX,finishY = false,false
					if disx ~= 0 then
						local progress = (nx-ox)/disx
						if easingBuiltIn[easing] then
							percentx = getEasingValue(progress,easing)
						else
							percentx = getEasingValue2(progress,easing,settings,v)
						end
						if progress < 1 then
							nx = nx+speedX
							if nx*symbolX > x*symbolX then
								nx = x
							end
						else
							nx = x
							finishX = true
						end
					end
					if disy ~= 0 then
						local progress = (ny-oy)/disy
						if easingBuiltIn[easing] then
							percenty = getEasingValue(progress,easing)
						else
							percenty = getEasingValue2(progress,easing,settings,v)
						end
						if progress < 1 then
							ny = ny+speedY
							if ny*symbolY > y*symbolY then
								ny = y
							end
						else
							ny = y
							finishY = true
						end
					end
					compSize = finishX and finishY
				else
					local changeTime = (tickCount-delay)-data[0]
					local temp = changeTime/torvx
					temp = temp <= 0 and 0 or temp
					if easingBuiltIn[easing] then
						percentx,percenty = interpolateBetween(ox,oy,0,x,y,0,temp,easing)
					else
						percentx,percenty = interpolateBetween2(ox,oy,0,x,y,0,temp,easing,settings,v)
					end
					if temp >= 1 then
						compSize = true
						nx,ny = x,y
					else
						nx,ny = percentx,percenty
					end
				end
				dgsSetSize(v,nx,ny,rlt)
				if compSize then
					dgsSetData(v,"size",nil)
					sizeGarbage[0] = sizeGarbage[0]+1
					sizeGarbage[sizeGarbage[0]] = v
				end
			end
		end
	end
	for v,value in pairs(alphaGUIList) do
		if not dgsIsType(v) or not value then
			alphaGarbage[#alphaGarbage+1] = v
		else
			local data = dgsElementData[v].calpha
			if not data then alphaGUIList[v] = nil end
			local oldAlpha,endalpha,mtype,easing,torv,settings,delay = data[1],data[2],data[3],data[4],data[5],data[-1],data[-2]
			local alp = dgsElementData[v].alpha
			if not alp then alphaGUIList[v] = nil end
			if alphaGUIList[v] then
				local compAlpha = false
				local percentalp
				if mtype then
					local disAlpha = endalpha-oldAlpha
					local symbolAlpha = disAlpha < 0 and -1 or 1
					local speed = torv*diff*symbolAlpha*0.001
					if disAlpha ~= 0 then
						local progress = (alp-oldAlpha)/disAlpha
						if easingBuiltIn[easing] then
							percentx = getEasingValue(progress,easing)
						else
							percentx = getEasingValue2(progress,easing,settings,v)
						end
						if progress < 1 then
							alp = alp+speed
							if alp*symbolAlpha > endalpha*symbolAlpha then
								alp = endalpha
							end
						else
							alp = endalpha
							compAlpha = true
						end
					end
				else
					local changeTime = (tickCount-delay)-data[0]
					local temp = changeTime/torv
					temp = temp <= 0 and 0 or temp
					if easingBuiltIn[easing] then
						percentalp = interpolateBetween(oldAlpha,0,0,endalpha,0,0,temp,easing or "Linear")
					else
						percentalp = interpolateBetween2(oldAlpha,0,0,endalpha,0,0,temp,easing,settings,v)
					end
					if temp >= 1 then
						compAlpha = true
						alp = endalpha
					else
						alp = percentalp
					end
				end
				dgsSetData(v,"alpha",alp)
				if compAlpha then
					dgsSetData(v,"calpha",nil)
					alphaGarbage[0] = alphaGarbage[0]+1
					alphaGarbage[alphaGarbage[0]] = v
				end
			end
		end
	end
	--for i=1,animGarbage[0] do
		--animGUIList[animGarbage[i]] = nil
		--triggerEvent("onDgsStopAniming",animGarbage[i],true)
	--end
	for i=1,moveGarbage[0] do
		moveGUIList[moveGarbage[i]] = nil
		triggerEvent("onDgsStopMoving",moveGarbage[i],true)
	end
	for i=1,sizeGarbage[0] do
		sizeGUIList[sizeGarbage[i]] = nil
		triggerEvent("onDgsStopSizing",sizeGarbage[i],true)
	end
	for i=1,alphaGarbage[0] do
		alphaGUIList[alphaGarbage[i]] = nil
		triggerEvent("onDgsStopAlphaing",alphaGarbage[i],true)
	end
	moveGarbage[0] = 0
	sizeGarbage[0] = 0
	alphaGarbage[0] = 0
end)

function interpolateBetween2(x,y,z,tx,ty,tz,percent,easing,settings,self)
	if dgsEasingFunction[easing] then
		local nx,ny,nz = x,y,z
		local temp = dgsEasingFunction[easing](percent,settings,self)
		local diff = {tx-x,ty-y,tz-z}
		if diff[1] ~= 0 then nx = temp*diff[1]+x end
		if diff[2] ~= 0 then ny = temp*diff[2]+y end
		if diff[3] ~= 0 then ny = temp*diff[3]+z end
		return nx,ny,nz
	end
	return false
end

function getEasingValue2(percent,easing,settings,self)
	if dgsEasingFunction[easing] then
		return dgsEasingFunction[easing](percent,settings,self)
	end
end
