dgsLogLuaMemory()
---------------Speed Up
local type = type
local tonumber = tonumber
local dgsTriggerEvent = dgsTriggerEvent
local isElement = isElement
local getEasingValue = getEasingValue
local animationID = 0

function dgsAnimTo(...)
	local dgsEle,property,targetValue,easing,duration,delay,reversedProgress,splitTable
	if select("#",...) == 1 and type(select(1,...)) == "table" then
		local argTable = ...
		dgsEle = argTable.ele or argTable.dgsEle or argTable.element or argTable.dgsElement or argTable.source or argTable[1]
		property = argTable.property or argTable[2]
		targetValue = argTable.target or argTable.targetValue or argTable[3]
		easing = argTable.easing or argTable.easingFunction or argTable[4]
		duration = argTable.duration or argTable.time or argTable[5]
		delay = argTable.delay or argTable[6]
		reversedProgress = argTable.reversed or argTable[7]
		splitTable = argTable[8]
	else
		dgsEle,property,targetValue,easing,duration,delay,reversedProgress,splitTable = ...
	end
	local delay = tonumber(delay) or 0
	if not(type(dgsEle) == "table" or dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsAnimTo",1,"dgs-dxelement/table")) end
	if not(type(property) == "string") then error(dgsGenAsrt(property,"dgsAnimTo",2,"string")) end
	local easing = easing or "Linear"
	if not(dgsEasingFunctionExists(easing)) then error(dgsGenAsrt(easing,"dgsAnimTo",4,_,"easing function doesn't exist ("..tostring(easing)..")")) end
	if not(type(duration) == "number") then error(dgsGenAsrt(duration,"dgsAnimTo",5,"number")) end
	if type(dgsEle) == "table" then
		local animIDs = {}
		for i=1,#dgsEle do
			animIDs[i] = dgsAnimTo(dgsEle[i],property,targetValue,easing,duration,delay,reversedProgress,splitTable)
		end
		return animIDs
	else
		animationID = animationID+1
		local animTable = {
			[-3]=nil,
			[-2]=animationID,
			[-1]=sourceResourceRoot,
			[0]=nil, --Result
			[1]=dgsEle,
			[2]=property,
			[3]=nil, --Start Value
			[4]=targetValue,
			[5]=easing,
			[6]=duration,
			[7]=getTickCount()+delay,
			[8]=reversedProgress,
			[9]=splitTable,
		}
		--Debugging
		local isTraceDebug = getElementData(localPlayer,"DGS-DebugTracer") or (getElementData(localPlayer,"DGS-DEBUG") == 3)
		if isTraceDebug then
			dgsDebugGetContext(sourceResourceRoot,function(context)
				animTable[-3] = context
			end)
		end
		--
		table.insert(animQueue,animTable)
		return animationID
	end
end

function dgsStopAniming(...)
	local dgsEle,property
	local stopTick = getTickCount()
	if select("#",...) == 1 and type(select(1,...)) == "table" then
		local argTable = ...
		dgsEle = argTable.ele or argTable.dgsEle or argTable.element or argTable.dgsElement or argTable.source or argTable.index or argTable[1]
		property = argTable.property or argTable[2]
	else
		dgsEle,property = ...
	end
	if not(dgsIsType(dgsEle) or type(dgsEle) == "number") then error(dgsGenAsrt(dgsEle,"dgsStopAniming",1,"dgs-dxelement/number")) end
	if type(dgsEle) == "number" then
	--Kill the specific animation
		local index = 1
		while index <= #animQueue do
			local anim = animQueue[index]
			if anim[-2] == dgsEle  then --Confirm by unique animation ID
				local theEle = anim[1]
				table.remove(animQueue,index)	--Remove
				local property = anim[2]
				dgsTriggerEvent("onDgsStopAniming",theEle,anim[-2],property,anim[3],anim[4],anim[5],anim[7],anim[6],stopTick)
				if property == "rltPos" or property == "absPos" then
					dgsTriggerEvent("onDgsStopMoving",theEle,anim[-2])
				elseif property == "rltSize" or property == "absSize" then
					dgsTriggerEvent("onDgsStopSizing",theEle,anim[-2])
				elseif property == "alpha" then
					dgsTriggerEvent("onDgsStopAlphaing",theEle,anim[-2])
				end
				return true
			else
				index = index+1
			end
		end
	elseif type(property) == "string" then
		--Kill all animations of the specific property
		local index = 1
		while index <= #animQueue do
			local anim = animQueue[index]
			if anim[1] == dgsEle and anim[2] == property then --Confirm
				table.remove(animQueue,index)	--Remove
				dgsTriggerEvent("onDgsStopAniming",dgsEle,anim[-2],property,anim[3],anim[4],anim[5],anim[7],anim[6],stopTick)
				if property == "rltPos" or property == "absPos" then
					dgsTriggerEvent("onDgsStopMoving",dgsEle,anim[-2])
				elseif property == "rltSize" or property == "absSize" then
					dgsTriggerEvent("onDgsStopSizing",dgsEle,anim[-2])
				elseif property == "alpha" then
					dgsTriggerEvent("onDgsStopAlphaing",dgsEle,anim[-2])
				end
			else
				index = index+1
			end
		end
		return true
	elseif type(property) == "table" then
		local index = 1
		while index <= #animQueue do
			local anim = animQueue[index]
			if anim[1] == dgsEle then --Confirm
				for i=1,#property do
					if anim[2] == property[i] then
						table.remove(animQueue,index)	--Remove
						dgsTriggerEvent("onDgsStopAniming",dgsEle,anim[-2],property[i],anim[3],anim[4],anim[5],anim[7],anim[6],stopTick)
						if property[i] == "rltPos" or property[i] == "absPos" then
							dgsTriggerEvent("onDgsStopMoving",dgsEle,anim[-2])
						elseif property[i] == "rltSize" or property[i] == "absSize" then
							dgsTriggerEvent("onDgsStopSizing",dgsEle,anim[-2])
						elseif property[i] == "alpha" then
							dgsTriggerEvent("onDgsStopAlphaing",dgsEle,anim[-2])
						end
						break
					end
				end
			end
			index = index+1
		end
	else
		local index = 1
		while index <= #animQueue do
			local anim = animQueue[index]
			if anim[1] == dgsEle then --Confirm
				table.remove(animQueue,index)	--Remove
				dgsTriggerEvent("onDgsStopAniming",dgsEle,anim[-2],anim[2],anim[3],anim[4],anim[5],anim[7],anim[6],stopTick)
				if anim[2] == "rltPos" or anim[2] == "absPos" then
					dgsTriggerEvent("onDgsStopMoving",dgsEle,anim[-2])
				elseif anim[2] == "rltSize" or anim[2] == "absSize" then
					dgsTriggerEvent("onDgsStopSizing",dgsEle,anim[-2])
				elseif anim[2] == "alpha" then
					dgsTriggerEvent("onDgsStopAlphaing",dgsEle,anim[-2])
				end
			else
				index = index+1
			end
		end
	end
end

function dgsIsAniming(dgsEle,property)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsIsAniming",1,"dgs-dxelement")) end
	if type(property) == "string" then
		for i=1,#animQueue do
			if animQueue[i][1] == dgsEle and animQueue[i][2] == property then
				return true
			end
		end
	elseif type(property) == "table" then
		for i=1,#animQueue do
			if animQueue[i][1] == dgsEle then
				for p=1,#property do
					if animQueue[i][2] == property[p] then
						return true
					end
				end
			end
		end
	else
		for i=1,#animQueue do
			if animQueue[i][1] == dgsEle then
				return true
			end
		end
	end
end

local easingSettings = {}
function onAnimQueueProcess()
	local animIndex,animItem = 1
	local dgsEle,property,startValue,targetValue,easing,duration,startTick
	local rTick,rProgress = getTickCount()
	local dbgResult,dbgErr
	while animIndex <= #animQueue do
		animItem = animQueue[animIndex]
		dgsEle = animItem[1]
		if isElement(dgsEle) then
			startTick = animItem[7]
			if rTick >= startTick then
				if animItem[3] == nil then animItem[3] = dgsElementData[dgsEle][ animItem[2] ] end
				property,startValue,targetValue,easing,duration,reversedProgress,splitTable = animItem[2],animItem[3],animItem[4],animItem[5],animItem[6],animItem[8],animItem[9]
				rProgress = (rTick-startTick)/duration
				if rProgress >= 1 then rProgress = 1 end
				if reversedProgress then rProgress = 1-rProgress end
				if dgsEasingFunction[easing] then
					if splitTable and type(startValue) == "table" then
						animItem[0] = {}
						for i=1,#startValue do
							easingSettings[1],easingSettings[2],easingSettings[3],easingSettings[4] = property,targetValue,startValue,i
							animItem[0][i] = startValue[i]+(targetValue[i]-startValue[i])*dgsEasingFunction[easing](rProgress,easingSettings,dgsEle)
						end
						easingSettings[4] = nil
					else
						easingSettings[1],easingSettings[2],easingSettings[3] = property,targetValue,startValue
						animItem[0] = dgsEasingFunction[easing](rProgress,easingSettings,dgsEle)
					end
				else
					local easingValue = getEasingValue(rProgress,easing)
					if type(startValue) == "table" then
						animItem[0] = {}
						for i=1,#startValue do
							animItem[0][i] = startValue[i]+(targetValue[i]-startValue[i])*easingValue
						end
					else
						animItem[0] = startValue+(targetValue-startValue)*easingValue
					end
				end
				dbgResult,dbgErr = pcall(dgsSetProperty,dgsEle,property,animItem[0])
				if not dbgResult then
					outputDebugString("DGS runtime error: Animation",4,255,180,100)
					if animItem[-1] and animItem[-3] then
						local debugContext = animItem[-3] 
						if type(debugContext) == "table" then
							dgsTriggerEvent("DGSI_onDebug",animItem[-1],"AnimationError",property,debugContext.file,debugContext.line,debugContext.fncName)
						end
					end
				end
				if rProgress == 1 then
					dgsStopAniming(animItem[-2])
				else
					animIndex = animIndex+1
				end
			else
				animIndex = animIndex+1
			end
		else
			table.remove(animItem,animIndex)
		end
	end
end

--[[
if not getElementData(resourceRoot,"DGS-disableCompatibilityCheck") then
	if not getElementData(localPlayer,"DGS-DEBUG-C") then
		outputDebugString("Deprecated usage of @'dgsMoveTo' at argument 5, 'moveType' is no longer supported, use '/debugdgs c' to find",2)
		if getElementData(localPlayer,"DGS-DEBUG") == 3 then
			dgsTriggerEvent("DGSI_onDebug",sourceResourceRoot or resourceRoot,"ArgumentCompatibility",5,"'moveType' is no longer supported")
		end
	else
		error("Found deprecated usage of @'dgsMoveTo' at argument 5, 'moveType' is no longer supported")
	end
end]]

function dgsMoveTo(...)
	local dgsEle,x,y,relative,easing,duration,delay,reversedProgress
	if select("#",...) == 1 and type(select(1,...)) == "table" then
		local argTable = ...
		dgsEle = argTable.ele or argTable.dgsEle or argTable.element or argTable.dgsElement or argTable.source or argTable[1]
		x = argTable.x or argTable[2]
		y = argTable.y or argTable[3]
		relative = argTable.rlt or argTable.relative or argTable[4]
		easing = argTable.easing or argTable.easingFunction or argTable[5]
		duration = argTable.duration or argTable.time or argTable[6]
		delay = argTable.delay or argTable[7]
		reversedProgress = argTable.reversed or argTable[8]
	else
		dgsEle,x,y,relative,easing,duration,delay,reversedProgress = ...
	end
	local delay = tonumber(delay) or 0
	if not(type(dgsEle) == "table" or dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsMoveTo",1,"dgs-dxelement/table")) end
	if not(type(x) == "number") then error(dgsGenAsrt(x,"dgsMoveTo",2,"number")) end
	if not(type(y) == "number") then error(dgsGenAsrt(y,"dgsMoveTo",3,"number")) end
	local easing = easing or "Linear"
	if not(dgsEasingFunctionExists(easing)) then error(dgsGenAsrt(easing,"dgsMoveTo",5,"easing function doesn't exist ("..tostring(easing)..")")) end
	if not(type(duration) == "number") then error(dgsGenAsrt(duration,"dgsMoveTo",6,"number")) end
	return dgsAnimTo(dgsEle,relative and "rltPos" or "absPos",{x,y},easing,duration,delay,reversedProgress,true)
end

function dgsStopMoving(dgsEle)
	if not(type(dgsEle) == "table" or dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsStopMoving",1,"dgs-dxelement/table")) end
	if type(dgsEle) == "table" then
		for i=1,#dgsEle do dgsStopMoving(dgsEle[i]) end
	else
		dgsStopAniming(dgsEle,{"absPos","rltPos"})
	end
	return true
end

function dgsIsMoving(dgsEle)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsIsMoving",1,"dgs-dxelement")) end
	return dgsIsAniming(dgsEle,{"absPos","rltPos"})
end

function dgsSizeTo(...)
	local dgsEle,w,h,relative,easing,duration,delay,reversedProgress
	if select("#",...) == 1 and type(select(1,...)) == "table" then
		local argTable = ...
		dgsEle = argTable.ele or argTable.dgsEle or argTable.element or argTable.dgsElement or argTable.source or argTable[1]
		w = argTable.w or argTable.width or argTable[2]
		h = argTable.h or argTable.height or argTable[3]
		relative = argTable.rlt or argTable.relative or argTable[4]
		easing = argTable.easing or argTable.easingFunction or argTable[5]
		duration = argTable.duration or argTable.time or argTable[6]
		delay = argTable.delay or argTable[7]
		reversedProgress = argTable.reversed or argTable[8]
	else
		dgsEle,w,h,relative,easing,duration,delay,reversedProgress = ...
	end
	local delay = tonumber(delay) or 0
	if not(type(dgsEle) == "table" or dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsSizeTo",1,"dgs-dxelement/table")) end
	if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsSizeTo",2,"number")) end
	if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsSizeTo",3,"number")) end
	local easing = easing or "Linear"
	if not(dgsEasingFunctionExists(easing)) then error(dgsGenAsrt(easing,"dgsSizeTo",5,"easing function doesn't exist ("..tostring(easing)..")")) end
	if not(type(duration) == "number") then error(dgsGenAsrt(duration,"dgsSizeTo",6,"number")) end
	return dgsAnimTo(dgsEle,relative and "rltSize" or "absSize",{w,h},easing,duration,delay,reversedProgress,true)
end

function dgsStopSizing(dgsEle)
	if not(type(dgsEle) == "table" or dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsStopSizing",1,"dgs-dxelement/table")) end
	if type(dgsEle) == "table" then
		for i=1,#dgsEle do dgsStopMoving(dgsEle[i]) end
	else
		dgsStopAniming(dgsEle,{"absSize","rltSize"})
	end
	return true
end

function dgsIsSizing(dgsEle)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsIsSizing",1,"dgs-dxelement")) end
	return dgsIsAniming(dgsEle,{"absSize","rltSize"})
end

function dgsAlphaTo(...)
	local dgsEle,alpha,relative,easing,duration,delay,reversedProgress
	if select("#",...) == 1 and type(select(1,...)) == "table" then
		local argTable = ...
		dgsEle = argTable.ele or argTable.dgsEle or argTable.element or argTable.dgsElement or argTable.source or argTable[1]
		alpha = argTable.a or argTable.alpha or argTable[2]
		easing = argTable.easing or argTable.easingFunction or argTable[3]
		duration = argTable.duration or argTable.time or argTable[4]
		delay = argTable.delay or argTable[5]
		reversedProgress = argTable.reversed or argTable[6]
	else
		dgsEle,alpha,easing,duration,delay,reversedProgress = ...
	end
	local delay = tonumber(delay) or 0
	if not(type(dgsEle) == "table" or dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsAlphaTo",1,"dgs-dxelement/table")) end
	if not(type(alpha) == "number") then error(dgsGenAsrt(alpha,"dgsAlphaTo",2,"number")) end
	local easing = easing or "Linear"
	if not(dgsEasingFunctionExists(easing)) then error(dgsGenAsrt(easing,"dgsAlphaTo",3,_,"easing function doesn't exist ("..tostring(easing)..")")) end
	if not(type(duration) == "number") then error(dgsGenAsrt(duration,"dgsAlphaTo",4,"number")) end
	return dgsAnimTo(dgsEle,"alpha",alpha,easing,duration,delay,reversedProgress,true)
end

function dgsStopAlphaing(dgsEle)
	if not(type(dgsEle) == "table" or dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsStopAlphaing",1,"dgs-dxelement/table")) end
	if type(dgsEle) == "table" then
		for i=1,#dgsEle do dgsStopMoving(dgsEle[i]) end
	else
		dgsStopAniming(dgsEle,"alpha")
	end
	return true
end

function dgsIsAlphaing(dgsEle)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsIsAlphaing",1,"dgs-dxelement")) end
	return dgsIsAniming(dgsEle,"alpha")
end
