dgsLogLuaMemory()
dgsRegisterType("dgs-dx3dtext","dgsBasic","dgsType3D","dgsTypeScreen3D")
dgsRegisterProperties("dgs-dx3dtext",{
	alignment = 			{	{ PArg.String, PArg.String }	},
	canBeBlocked = 			{	PArg.Bool, {
											checkBuildings = PArg.Nil+PArg.Bool,
											checkVehicles = PArg.Nil+PArg.Bool,
											checkPeds = PArg.Nil+PArg.Bool,
											checkObjects = PArg.Nil+PArg.Bool,
											checkDummies = PArg.Nil+PArg.Bool,
											seeThroughStuff = PArg.Nil+PArg.Bool,
											ignoreSomeObjectsForCamera = PArg.Nil+PArg.Bool,
											}
							},
	color = 				{	PArg.Color	},
	colorCoded = 			{	PArg.Bool	},
	dimension = 			{	PArg.Number	},
	fadeDistance = 			{	PArg.Number	},
	fixTextSize = 			{	PArg.Bool	},
	font = 					{	PArg.Font+PArg.String	},
	interior = 				{	PArg.Number	},
	isBlocked = 			{	PArg.Bool, readOnly = true	},
	isOnScreen = 			{	PArg.Bool, readOnly = true	},
	maxDistance = 			{	PArg.Number	},
	position = 				{	{ PArg.Number, PArg.Number, PArg.Number }	},
	text = 					{	PArg.Text	},
	textOffset = 			{	{ PArg.Number, PArg.Number }	},
	textSize = 				{	{ PArg.Number, PArg.Number }	},
	shadow = 				{	{ PArg.Number, PArg.Number, PArg.Color, PArg.Number+PArg.Bool+PArg.Nil, PArg.Font+PArg.Nil }, PArg.Nil	},
})
--Dx Functions
local dxDrawLine = dxDrawLine
local dgsDrawText = dgsDrawText
local dxGetFontHeight = dxGetFontHeight
local dxGetTextWidth = dxGetTextWidth
--
local getScreenFromWorldPosition = getScreenFromWorldPosition
local assert = assert
local type = type
local tableInsert = table.insert

function dgsCreate3DText(...)
	local sRes = sourceResource or resource
	local x,y,z,text,color,font,sizeX,sizeY,maxDistance,colorCoded
	if select("#",...) == 1 and type(select(1,...)) == "table" then
		local argTable = ...
		x = argTable.x or argTable[1]
		y = argTable.y or argTable[2]
		z = argTable.z or argTable[3]
		text = argTable.txt or argTable.text or argTable[4]
		color = argTable.color or argTable[5]
		font = argTable.font or argTable[6]
		scaleX = argTable.scaleX or argTable[7]
		scaleX = argTable.scaleY or argTable[8]
		maxDistance = argTable.maxDistance or argTable[9]
		colorCoded = argTable.colorCoded or argTable[10]
	else
		x,y,z,text,color,font,scaleX,scaleY,maxDistance,colorCoded = ...
	end
	if not(type(x) == "number") then error(dgsGenAsrt(x,"dgsCreate3DText",1,"number")) end
	if not(type(y) == "number") then error(dgsGenAsrt(y,"dgsCreate3DText",2,"number")) end
	if not(type(z) == "number") then error(dgsGenAsrt(z,"dgsCreate3DText",3,"number")) end
	local text3d = createElement("dgs-dx3dtext")
	tableInsert(dgsScreen3DTable,text3d)
	dgsSetType(text3d,"dgs-dx3dtext")
	
	local res = sRes ~= resource and sRes or "global"
	local style = styleManager.styles[res]
	local using = style.using
	style = style.loaded[using]
	local systemFont = style.systemFontElement
	
	style = style.text3D
	dgsElementData[text3d] = {
		alignment = {"center", "center"},
		renderBuffer = {},
		position = {x,y,z},
		textSize = {scaleX or 1,scaleY or 1},
		textOffset = {0,0},
		fixTextSize = false,
		font = font or style.font or systemFont,
		color = color or 0xFFFFFFFF,
		colorCoded = colorCoded or false,
		maxDistance = maxDistance or 80,
		fadeDistance = maxDistance or 80,
		dimension = -1,
		interior = -1,
		canBeBlocked = false,
		subPixelPositioning = true,
		isBlocked = false,
		isOnScreen = false,
	}
	dgsAttachToTranslation(text3d,resourceTranslation[sRes or getThisResource()])
	if type(text) == "table" then
		dgsElementData[text3d]._translation_text = text
		dgsSetData(text3d,"text",text)
	else
		dgsSetData(text3d,"text",tostring(text or ""))
	end
	onDGSElementCreate(text3d,sRes)
	return text3d
end

function dgs3DTextAttachToElement(text,element,offX,offY,offZ)
	if not(dgsGetType(text) == "dgs-dx3dtext") then error(dgsGenAsrt(text,"dgs3DTextAttachToElement",1,"dgs-dx3dtext")) end
	if not isElement(element) then error(dgsGenAsrt(element,"dgs3DTextAttachToElement",2,"element")) end
	local offX,offY,offZ = offX or 0,offY or 0,offZ or 0
	return dgsSetData(text,"attachTo",{element,offX,offY,offZ})
end

function dgs3DTextIsAttached(text)
	if not(dgsGetType(text) == "dgs-dx3dtext") then error(dgsGenAsrt(text,"dgs3DTextIsAttached",1,"dgs-dx3dtext")) end
	return dgsElementData[text].attachTo
end

function dgs3DTextDetachFromElement(text)
	if not(dgsGetType(text) == "dgs-dx3dtext") then error(dgsGenAsrt(text,"dgs3DTextDetachFromElement",1,"dgs-dx3dtext")) end
	return dgsSetData(text,"attachTo",false)
end

function dgs3DTextSetAttachedOffsets(text,offX,offY,offZ)
	if not(dgsGetType(text) == "dgs-dx3dtext") then error(dgsGenAsrt(text,"dgs3DTextSetAttachedOffsets",1,"dgs-dx3dtext")) end
	local attachTable = dgsElementData[text].attachTo
	if attachTable then
		local offX,offY,offZ = offX or attachTable[2],offY or attachTable[3],offZ or attachTable[4]
		return dgsSetData(text,"attachTo",{attachTable[1],offX,offY,offZ})
	end
	return false
end

function dgs3DTextGetAttachedOffsets(text,offX,offY,offZ)
	if not(dgsGetType(text) == "dgs-dx3dtext") then error(dgsGenAsrt(text,"dgs3DTextGetAttachedOffsets",1,"dgs-dx3dtext")) end
	local attachTable = dgsElementData[text].attachTo
	if attachTable then
		local offX,offY,offZ = attachTable[2],attachTable[3],attachTable[4]
		return offX,offY,offZ
	end
	return false
end

----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------

dgsRenderer["dgs-dx3dtext"] = function(source,x,y,w,h,mx,my,cx,cy,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt)
	local attachTable = eleData.attachTo
	local posTable = eleData.position
	local wx,wy,wz = posTable[1],posTable[2],posTable[3]
	local isRender = true
	if attachTable then
		if isElement(attachTable[1]) then
			wx,wy,wz = getPositionFromElementOffset(attachTable[1],attachTable[2],attachTable[3],attachTable[4])
			posTable[1],posTable[2],posTable[3] = wx,wy,wz
		else
			eleData.attachTo = false
		end
	end
	local camX,camY,camZ = cameraPos[1],cameraPos[2],cameraPos[3]
	local dx,dy,dz = camX-wx,camY-wy,camZ-wz
	local distance = (dx*dx+dy*dy+dz*dz)^0.5
	local maxDistance = eleData.maxDistance
	if distance <= maxDistance and distance > 0 then
		local canBeBlocked = eleData.canBeBlocked
		if canBeBlocked then
			if canBeBlocked == true then
				canBeBlocked = g_canBeBlocked
			end
			if canBeBlocked.checkBuildings == nil then canBeBlocked.checkBuildings = g_canBeBlocked.checkBuildings end
			if canBeBlocked.checkVehicles == nil then canBeBlocked.checkVehicles = g_canBeBlocked.checkVehicles end
			if canBeBlocked.checkPeds == nil then canBeBlocked.checkPeds = g_canBeBlocked.checkPeds end
			if canBeBlocked.checkObjects == nil then canBeBlocked.checkObjects = g_canBeBlocked.checkObjects end
			if canBeBlocked.checkDummies == nil then canBeBlocked.checkDummies = g_canBeBlocked.checkDummies end
			if canBeBlocked.seeThroughStuff == nil then canBeBlocked.seeThroughStuff = g_canBeBlocked.seeThroughStuff end
			if canBeBlocked.ignoreSomeObjectsForCamera == nil then canBeBlocked.ignoreSomeObjectsForCamera = g_canBeBlocked.ignoreSomeObjectsForCamera end
		end
		local fadeDistance = eleData.fadeDistance
		local res = eleData.resource or "global"
		local style = styleManager.styles[res]
		local using = style.using
		style = style.loaded[style.using]
		local systemFont = style.systemFontElement
		eleData.isBlocked = (not canBeBlocked or (canBeBlocked and isLineOfSightClear(wx, wy, wz, camX, camY, camZ, canBeBlocked.checkBuildings, canBeBlocked.checkVehicles, canBeBlocked.checkPeds, canBeBlocked.checkObjects, canBeBlocked.checkDummies, canBeBlocked.seeThroughStuff,canBeBlocked.ignoreSomeObjectsForCamera)))
		if eleData.isBlocked then
			local fadeMulti = 1
			if maxDistance > fadeDistance and distance >= fadeDistance then
				fadeMulti = 1-(distance-fadeDistance)/(maxDistance-fadeDistance)
			end
			local x,y = getScreenFromWorldPosition(wx,wy,wz,0.5)
			eleData.isOnScreen = x and y
			if eleData.isOnScreen then
				local offsetX,offsetY = eleData.textOffset[1],eleData.textOffset[2]
				local subPixelPositioning = eleData.subPixelPositioning
				local colorCoded = eleData.colorCoded
				local text = eleData.text
				local textSizeX,textSizeY = eleData.textSize[1],eleData.textSize[2]
				local font = eleData.font or systemFont
				local alignment = eleData.alignment
				local x,y = x+offsetX-x%1,y+offsetY-y%1
				if eleData.fixTextSize then
					distance = 50
				end
				local antiDistance = 1/distance
				local sizeX = textSizeX*textSizeX/distance*50
				local sizeY = textSizeY*textSizeY/distance*50
				local color = applyColorAlpha(eleData.color,parentAlpha*fadeMulti)
				local shadow = eleData.shadow
				local shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont
				if shadow then
					shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont = shadow[1]*antiDistance*50,shadow[2]*antiDistance*50,shadow[3],shadow[4],shadow[5]
					shadowColor = applyColorAlpha(shadowColor or white,parentAlpha*fadeMulti)
				end
				dgsDrawText(text,x,y,x,y,color,sizeX,sizeY,font,alignment[1],alignment[2],false,false,false,colorCoded,subPixelPositioning,0,0,0,0,shadowOffsetX,shadowOffsetY,shadowColor,shadowIsOutline,shadowFont)
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local shadowText = colorCoded and text:gsub('#%x%x%x%x%x%x','') or text
					local w,h = dxGetTextWidth(shadowText,sizeX,font),dxGetFontHeight(sizeY,font)
					local x,y=x-w*0.5,y-h*0.5
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]*antiDistance*25
					local hSideSize = sideSize*0.5
					sideColor = applyColorAlpha(sideColor,parentAlpha*fadeMulti)
					local side = outlineData[1]
					if side == "in" then
						if outlineData[6] ~= false then
							dxDrawLine(x,y+hSideSize,x+w,y+hSideSize,sideColor,sideSize)
						end
						if outlineData[4] ~= false then
							dxDrawLine(x+hSideSize,y,x+hSideSize,y+h,sideColor,sideSize)
						end
						if outlineData[5] ~= false then
							dxDrawLine(x+w-hSideSize,y,x+w-hSideSize,y+h,sideColor,sideSize)
						end
						if outlineData[7] ~= false then
							dxDrawLine(x,y+h-hSideSize,x+w,y+h-hSideSize,sideColor,sideSize)
						end
					elseif side == "center" then
						if outlineData[6] ~= false then
							dxDrawLine(x-hSideSize,y,x+w+hSideSize,y,sideColor,sideSize)
						end
						if outlineData[4] ~= false then
							dxDrawLine(x,y+hSideSize,x,y+h-hSideSize,sideColor,sideSize)
						end
						if outlineData[5] ~= false then 
							dxDrawLine(x+w,y+hSideSize,x+w,y+h-hSideSize,sideColor,sideSize)
						end
						if outlineData[7] ~= false then
							dxDrawLine(x-hSideSize,y+h,x+w+hSideSize,y+h,sideColor,sideSize)
						end
					elseif side == "out" then
						if outlineData[6] ~= false then
							dxDrawLine(x-sideSize,y-hSideSize,x+w+sideSize,y-hSideSize,sideColor,sideSize)
						end
						if outlineData[4] ~= false then
							dxDrawLine(x-hSideSize,y,x-hSideSize,y+h,sideColor,sideSize)
						end
						if outlineData[5] ~= false then 
							dxDrawLine(x+w+hSideSize,y,x+w+hSideSize,y+h,sideColor,sideSize)
						end
						if outlineData[7] ~= false then
							dxDrawLine(x-sideSize,y+h+hSideSize,x+w+sideSize,y+h+hSideSize,sideColor,sideSize)
						end
					end
				end
			end
		else
			eleData.isOnScreen = false
		end
	end
	return rndtgt,true,mx,my
end