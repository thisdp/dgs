function dgsDxCreateCycleHitShape(x,y,radius,relative,parent)
	assert(type(x) == "number","@dgsDxCreateCycleHitShape argument 1,expect number got "..type(x))
	assert(type(y) == "number","@dgsDxCreateCycleHitShape argument 2,expect number got "..type(y))
	assert(type(radius) == "number","@dgsDxCreateCycleHitShape argument 3,expect number got "..type(radius))
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"@dgsDxCreateCycleHitShape argument 5,expect dgs-dxgui got "..dgsGetType(parent))
	end
	local chs = createElement("dgs-dxcyclehitshape")
	dgsSetType(chs,"dgs-dxcyclehitshape")
	if isElement(parent) then
		dgsSetParent(chs,parent)
	else
		table.insert(MaxFatherTable,chs)
	end
	insertResourceDxGUI(sourceResource,chs)
	triggerEvent("onClientDgsDxGUIPreCreate",chs)
	calculateGuiPositionSize(chs,x,y,relative or false,radius*2,radius*2,relative or false,true)
	local sx = unpack(dgsGetData(chs,"absSize"))
	dgsSetData(chs,"radius",sx)
	triggerEvent("onClientDgsDxGUICreate",chs)
	return chs
end

function dgsDxSetCycleHitShapeRadius(chs,radius,relative)
	assert(dgsGetType(chs) == "dgs-dxcyclehitshape","@dgsDxSetCycleHitShapeRadius argument 1,expect dgs-dxcyclehitshape got "..(dgsGetType(chs) or type(chs)))
	assert(type(radius) == "number","@dgsDxSetCycleHitShapeRadius argument 2,expect number got "..type(radius))
	calculateGuiPositionSize(chs,_,_,_,radius*2,radius*2,relative or false,true)
	local sx = unpack(dgsGetData(chs,"absSize"))
	return dgsSetData(chs,"radius",sx)
end

function dgsDxGetCycleHitShapeRadius(chs,relative)
	assert(dgsGetType(chs) == "dgs-dxcyclehitshape","@dgsDxGetCycleHitShapeRadius argument 1,expect dgs-dxcyclehitshape got "..(dgsGetType(chs) or type(chs)))
	local sx = unpack(dgsGetData(chs,relative and "rltSize" or "absSize"))
	return sx
end

function dgsDxCycleHitShapeSetDebugMode(chs,debug)
	assert(dgsGetType(chs) == "dgs-dxcyclehitshape","@dgsDxCycleHitShapeSetDebugMode argument 1,expect dgs-dxcyclehitshape got "..(dgsGetType(chs) or type(chs)))
	dgsSetData(chs,"debug",debug and debug or false)
	return true
end

function dxDrawCircle(posX,posY,radius,width,angleAmount,startAngle,stopAngle,color,postGUI)
	if type(posX) ~= "number" or type(posY) ~= "number" then
		return false
	end
 	posX,posY = posX+radius/2,posY+radius/2
	local function clamp(val,lower,upper)
		if lower > upper then lower,upper = upper,lower end
		return math.max(lower,math.min(upper,val))
	end
	radius = type(radius) == "number" and radius or 50
	width = type(width) == "number" and width or 5
	angleAmount = type(angleAmount) == "number" and angleAmount or 1
	startAngle = clamp(type(startAngle) == "number" and startAngle or 0,0,360)
	stopAngle = clamp(type(stopAngle) == "number" and stopAngle or 360,0,360)
	color = color or white
	postGUI = type(postGUI) == "boolean" and postGUI or false
	if stopAngle < startAngle then
		local tempAngle = stopAngle
		stopAngle = startAngle
		startAngle = tempAngle
	end
	for i=startAngle,stopAngle,angleAmount do
		local angle = math.rad(i)
		local hradius = radius/2
		local startX = math.cos(angle)*(hradius-width)
		local startY = math.sin(angle)*(hradius-width)
		local endX = math.cos(angle)*(hradius+width)
		local endY = math.sin(angle)*(hradius+width)
		dxDrawLine(startX+posX,startY+posY,endX+posX,endY+posY,color,width,postGUI)
	end
	return true
end

function dgsDxCheckRadius(x,y,radius)
	local ahit
	local mx,my = getCursorPosition()
	if mx then
		local x,y = x+radius/2,y+radius/2
		mx,my = mx*sW,my*sH
		local rot = math.rad(findRotation(x,y,mx,my)+90)
		local tx = math.cos(rot)*radius/2
		local ty = math.sin(rot)*radius/2
		if my >= y-math.abs(ty) and my <= y+math.abs(ty) then
			ahit = true
		end
		return ahit
	end
end
