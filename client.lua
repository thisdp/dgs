focusBrowser()
------------Copyrights thisdp's DirectX Graphical User Interface System
sW,sH = guiGetScreenSize()
white = tocolor(255,255,255,255)
black = tocolor(0,0,0,255)
fontSize = {}
systemFont = "default"
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
dgsRenderSetting = {
	postGUI = nil,
	renderPriority = "normal",
}

function dgsSetSystemFont(font,size,bold,quality)
	assert(type(font) == "string","Bad argument @dgsSetSystemFont at argument 1, expect a string got "..dgsGetType(font))
	if isElement(systemFont) then
		destroyElement(systemFont)
	end
	if fontDxHave[font] then
		systemFont = font
		return true
	else
		if sourceResource then
			local path
			if not string.find(font,":") then
				local resname = getResourceName(sourceResource)
				path = ":"..resname.."/"..font
			else
				path = font
			end
			assert(fileExists(path),"Bad argument @dgsSetSystemFont at argument 1,couldn't find such file '"..path.."'")
			
			local filename = string.sub(path,2)
			local pathindgs = ":"..getResourceName(getThisResource()).."/Third/"..filename
			if fileExists(pathindgs) then
				fileDelete(pathindgs)
			end
			fileCopy(path,pathindgs,true)
			local font = dxCreateFont(pathindgs,size,bold,quality)
			if isElement(font) then
				systemFont = font
			end
		end
	end
	return false
end

function dgsGetSystemFont()
	return systemFont
end


function dgsGetRenderSetting(name)
	return dgsRenderSetting[name]
end

function dgsSetRenderSetting(name,value)
	if name == "renderPriority" then
		assert(type(value)=="string","Bad Argument @dgsSetRenderSetting at argument 2, expected a string got "..dgsGetType(value))
		removeEventHandler("onClientRender",root,dgsCoreRender)
		local success = addEventHandler("onClientRender",root,dgsCoreRender,false,value)
		if not success then
			addEventHandler("onClientRender",root,dgsCoreRender,false,dgsRenderSetting.renderPriority)
		end
		assert(success,"Bad Argument @dgsSetRenderSetting at argument 2, failed to set the priority")
	end
	dgsRenderSetting[name] = value
	return true
end

-----------------------------dx-GUI
MouseData = {}
MouseData.enter = false
MouseData.lastEnter = false
MouseData.enterData = false
MouseData.scrollPane = false
MouseData.hit = false
MouseData.Timer = {}
MouseData.Timer2 = {}
MouseData.nowShow = false
MouseData.arrowListEnter = false
MouseData.editCursor = false
MouseData.editCursorMoveOffset = false
MouseData.gridlistMultiSelection = false
MouseData.lastPos = {-1,-1}
MouseData.interfaceHit = {}
MouseData.lock3DInterface = false

MouseData.EditTimer = setTimer(function()
	if isElement(MouseData.nowShow) then
		if dgsGetType(MouseData.nowShow) == "dgs-dxedit" then
			MouseData.editCursor = not MouseData.editCursor
		end
	end
end,500,0)

MouseData.MemoTimer = setTimer(function()
	if isElement(MouseData.nowShow) then
		if dgsGetType(MouseData.nowShow) == "dgs-dxmemo" then
			MouseData.memoCursor = not MouseData.memoCursor
		end
	end
end,500,0)

function dgsCoreRender()
	triggerEvent("onDgsPreRender",resourceRoot)
	MouseData.hit = false
	local bottomTableSize = #BottomFatherTable
	local centerTableSize = #CenterFatherTable
	local topTableSize = #TopFatherTable
	local dx3DInterfaceTableSize = #dx3DInterfaceTable
	local tk = getTickCount()
	MouseData.hit = false
	DGSShow = 0
	wX,wY,wZ = nil,nil,nil
	local mx,my = -1000,-1000
	if isCursorShowing() then
		mx,my = getCursorPosition()
		mx,my = mx*sW,my*sH
		wX,wY,wZ = getWorldFromScreenPosition(mx,my,1)
		MouseX,MouseY = mx,my
	else
		MouseData.Move = false
		MouseData.clickData = false
		MouseData.clickl = false
		MouseData.clickr = false
		MouseData.clickm = false
		MouseData.lock3DInterface = false
		MouseData.Scale = false
		MouseData.scrollPane = false
		if MouseData.arrowListEnter then
			if isElement(MouseData.arrowListEnter[1]) then
				dgsSetData(MouseData.arrowListEnter[1],"arrowListClick",false)
			end
		end
		MouseData.arrowListEnter = false
	end
	local normalMx,normalMy = mx,my
	if bottomTableSize+centerTableSize+topTableSize+dx3DInterfaceTableSize ~= 0 then
		local dgsData = dgsElementData
		dxSetRenderTarget()
		MouseData.interfaceHit = {}
		local dxInterfaceHitElement = false
		local intfaceClickElementl = false
		for i=1,dx3DInterfaceTableSize do
			local v = dx3DInterfaceTable[i]
			local eleData = dgsData[v]
			dxSetBlendMode(eleData.blendMode)
			if renderGUI(v,mx,my,{eleData.enabled,eleData.enabled},eleData.renderTarget_parent,0,0,1,eleData.visible,MouseData.clickl) then
				intfaceClickElementl = true
			end
			dxSetBlendMode("blend")
		end
		local intfaceMx,intfaceMy = MouseX,MouseY
		local intfaceHitElement = MouseData.hit
		dxSetRenderTarget()
		local mx,my = normalMx,normalMy
		for i=1,bottomTableSize do
			local v = BottomFatherTable[i]
			local eleData = dgsData[v]
			renderGUI(v,mx,my,{eleData.enabled,eleData.enabled},eleData.renderTarget_parent,0,0,1,eleData.visible)
		end
		for i=1,centerTableSize do
			local v = CenterFatherTable[i]
			local eleData = dgsData[v]
			renderGUI(v,mx,my,{eleData.enabled,eleData.enabled},eleData.renderTarget_parent,0,0,1,eleData.visible)
		end
		for i=1,topTableSize do
			local v = TopFatherTable[i]
			local eleData = dgsData[v]
			renderGUI(v,mx,my,{eleData.enabled,eleData.enabled},eleData.renderTarget_parent,0,0,1,eleData.visible)
		end
		if intfaceClickElementl then
			MouseX,MouseY = intfaceMx,intfaceMy
		else
			if MouseData.clickl then
				MouseX,MouseY = normalMx,normalMy
			elseif MouseData.hit == intfaceHitElement then
				MouseX,MouseY = intfaceMx,intfaceMy
			else
				MouseX,MouseY = normalMx,normalMy
			end
		end
		dxSetRenderTarget()
		if not isCursorShowing() then
			MouseData.hit = false
			MouseData.Move = false
			MouseData.clickData = false
			MouseData.clickl = false
			MouseData.clickr = false
			MouseData.clickm = false
			MouseData.lock3DInterface = false
			MouseData.Scale = false
			MouseData.scrollPane = false
			if MouseData.arrowListEnter then
				if isElement(MouseData.arrowListEnter[1]) then
					dgsSetData(MouseData.arrowListEnter[1],"arrowListClick",false)
				end
			end
			MouseData.arrowListEnter = false
			MouseX,MouseY = nil,nil
		end
		triggerEvent("onDgsRender",resourceRoot)
		dgsCheckHit(MouseData.hit,MouseX,MouseY)
	end
	if debugMode then
		local ticks = getTickCount()-tk
		local version = getElementData(resourceRoot,"Version")
		dxDrawText("Thisdp's Dx Lib(DGS)",6,sH*0.4-114,sW,sH,black)
		dxDrawText("Thisdp's Dx Lib(DGS)",5,sH*0.4-115)
		dxDrawText("Version: "..version,6,sH*0.4-99,sW,sH,black)
		dxDrawText("Version: "..version,5,sH*0.4-100)
		dxDrawText("Render Time: "..ticks.." ms",11,sH*0.4-84,sW,sH,black)
		dxDrawText("Render Time: "..ticks.." ms",10,sH*0.4-85)
		local enterStr = MouseData.hit and dgsGetType(MouseData.hit).."("..tostring(MouseData.hit)..")" or "None"
		dxDrawText("Enter: "..enterStr,11,sH*0.4-69,sW,sH,black)
		dxDrawText("Enter: "..enterStr,10,sH*0.4-70)
		dxDrawText("Click:",11,sH*0.4-54,sW,sH,black)
		dxDrawText("Click:",10,sH*0.4-55)
		local leftStr = MouseData.clickl and dgsGetType(MouseData.clickl).."("..tostring(MouseData.clickl)..")" or "None"
		local rightStr = MouseData.clickr and dgsGetType(MouseData.clickr).."("..tostring(MouseData.clickr)..")" or "None"
		dxDrawText("  Left: "..leftStr,11,sH*0.4-39,sW,sH,black)
		dxDrawText("  Left: "..leftStr,10,sH*0.4-40)
		dxDrawText("  Right: "..rightStr,11,sH*0.4-24,sW,sH,black)
		dxDrawText("  Right: "..rightStr,10,sH*0.4-25)
		DGSCount = 0
		for k,v in ipairs(dgsType) do
			DGSCount = DGSCount+#getElementsByType(v)
			local x = 15
			if v == "dgs-dxtab" or v == "dgs-dxcombobox-Box" then
				x = 30
			end
			dxDrawText(v.." : "..#getElementsByType(v),x+1,sH*0.4+15*k+6,sW,sH,black)
			dxDrawText(v.." : "..#getElementsByType(v),x,sH*0.4+15*k+5)
		end
		dxDrawText("Elements Shows: "..DGSShow,11,sH*0.4-9,sW,sH,black)
		dxDrawText("Elements Shows: "..DGSShow,10,sH*0.4-10,sW,sH)
		dxDrawText("Elements Counts: "..DGSCount,11,sH*0.4+6,sW,sH,black)	
		dxDrawText("Elements Counts: "..DGSCount,10,sH*0.4+5,sW,sH)
		local anim = table.count(animGUIList)
		local move = table.count(moveGUIList)
		local size = table.count(sizeGUIList)
		local alp = table.count(alphaGUIList)
		local all = anim+move+size+alp
		dxDrawText("Running Animation("..all.."):",301,sH*0.4-114,sW,sH,black)
		dxDrawText("Running Animation("..all.."):",300,sH*0.4-115)
		
		dxDrawText("Anim:"..anim,301,sH*0.4-99,sW,sH,black)
		dxDrawText("Anim:"..anim,300,sH*0.4-100)
		dxDrawText("Move:"..move,301,sH*0.4-84,sW,sH,black)
		dxDrawText("Move:"..move,300,sH*0.4-85)
		dxDrawText("Size:"..size,301,sH*0.4-69,sW,sH,black)
		dxDrawText("Size:"..size,300,sH*0.4-70)
		dxDrawText("Alpha:"..alp,301,sH*0.4-54,sW,sH,black)
		dxDrawText("Alpha:"..alp,300,sH*0.4-55)
		
		Resource = 0
		ResCount = 0
		for ka,va in pairs(resourceDxGUI) do
			if type(ka) == "userdata" and va then
				Resource = Resource+#va
				ResCount = ResCount +1
				dxDrawText(getResourceName(ka).." : "..#va,301,sH*0.4+15*(ResCount+1)+1,sW,sH,black)
				dxDrawText(getResourceName(ka).." : "..#va,300,sH*0.4+15*(ResCount+1))
			end
		end
		dxDrawText("Resource Elements("..ResCount.."):",301,sH*0.4+16,sW,sH,black)
		dxDrawText("Resource Elements("..ResCount.."):",300,sH*0.4+15)
	end	
end

function interfaceRender()
	for i=1,#dx3DInterfaceTable do
		local v = dx3DInterfaceTable[i]
		local eleData = dgsElementData[v]
		if eleData.visible then
			
			local attachTable = eleData.attachTo
			if attachTable then
				local element,offX,offY,offZ,offFaceX,offFaceY,offFaceZ = attachTable[1],attachTable[2],attachTable[3],attachTable[4],attachTable[5],attachTable[6],attachTable[7]
				if not isElement(element) then
					eleData.attachTo = false
				else
					local ex,ey,ez = getElementPosition(element)
					local tmpX,tmpY,tmpZ = getPositionFromElementOffset(element,offFaceX,offFaceY,offFaceZ)
					eleData.position = {getPositionFromElementOffset(element,offX,offY,offZ)}
					eleData.faceTo = {tmpX-ex,tmpY-ey,tmpZ-ez}
				end
			end
			
			local pos = eleData.position
			local size = eleData.size
			local faceTo = eleData.faceTo
			local x,y,z,w,h,fx,fy,fz = pos[1],pos[2],pos[3],size[1],size[2],faceTo[1],faceTo[2],faceTo[3]
			eleData.hit = false
			if x and y and z and w and h then
				local colors = eleData.color
				colors = applyColorAlpha(colors,eleData.alpha)
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				local lnVec,lnPnt
				local camX,camY,camZ = getCameraMatrix()
				if not fx or not fy or not fz then
					fx,fy,fz = camX,camY,camZ
				end
				if wX and wY and wZ then
					lnVec = {wX-camX,wY-camY,wZ-camZ}
					lnPnt = {camX,camY,camZ}
				end
				local hit,hitX,hitY
				local cameraDistance = ((camX-x)^2+(camY-y)^2+(camZ-z)^2)^0.5
				eleData.cameraDistance = cameraDistance
				if cameraDistance <= eleData.maxDistance then
					local filter = eleData.filterShader
					local renderThing = eleData.renderTarget_parent
					if isElement(filter) then
						dxSetShaderValue(filter,"gTexture",renderThing)
						renderThing = filter
					end
					eleData.hit = {dgsDrawMaterialLine3D(x,y,z,fx,fy,fz,renderThing,w,h,colors,lnVec,lnPnt)}
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
			end
		end
	end
end
addEventHandler("onClientPreRender",root,interfaceRender)

function renderGUI(v,mx,my,enabled,rndtgt,OffsetX,OffsetY,galpha,visible,checkElement)
	local isElementInside = false
	if debugMode then
		DGSShow = DGSShow+1
	end
	local eleData = dgsElementData[v]
	local enabled = {enabled[1] and eleData.enabled,eleData.enabled}
	if eleData.visible and visible and isElement(v) then
		visible = eleData.visible
		local dxType = dgsGetType(v)
		if dxType == "dgs-dxscrollbar" then
			local pnt = eleData.attachedToParent
			if pnt and not dgsElementData[pnt].visible then
				return
			end
		end
		local parent,children,galpha = FatherTable[v] or false,ChildrenTable[v] or {},eleData.alpha*galpha
		dxSetRenderTarget(rndtgt)
		local x,y
		if eleData.absPos then
			x,y = dgsGetPosition(v,false,true)
		end
		local siz = eleData.absSize or {}
		local w,h = siz[1],siz[2]
		local isRenderTarget = (not rndtgt) and true or false
		self = v
		local interrupted = false
		local rendSet = not debugMode and isRenderTarget and (dgsRenderSetting.postGUI == nil and eleData.postGUI) or dgsRenderSetting.postGUI
		if dxType == "dgs-dxwindow" then
			if x and y then
				if eleData.PixelInt then
					x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
				end
				local img = eleData.image
				local color = eleData.color
				color = applyColorAlpha(color,galpha)
				local titimg,titleColor,titsize = eleData.titleImage,eleData.titleColor,eleData.titleHeight
				titleColor = applyColorAlpha(titleColor,galpha)
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if img then
					dxDrawImage(x,y+titsize,w,h-titsize,img,0,0,0,color,rendSet)
				else
					dxDrawRectangle(x,y+titsize,w,h-titsize,color,rendSet)
				end
				if titimg then
					dxDrawImage(x,y,w,titsize,titimg,0,0,0,titleColor,rendSet)
				else
					dxDrawRectangle(x,y,w,titsize,titleColor,rendSet)
				end
				local rightbottom = eleData.rightbottom
				local font = eleData.font or systemFont
				local textColor = applyColorAlpha(eleData.textColor,galpha)
				local txtSizX,txtSizY = eleData.textSize[1],eleData.textSize[2] or eleData.textSize[1]
				local clip,wordbreak,colorcoded = eleData.clip,eleData.wordbreak,eleData.colorcoded
				local text = eleData.text
				if eleData.shadow then
					local shadowoffx,shadowoffy,shadowc,shadowIsOutline = eleData.shadow[1],eleData.shadow[2],eleData.shadow[3],eleData.shadow[4]
					local textX,textY = x,y
					if shadowoffx and shadowoffy and shadowc then
						local shadowText = colorcoded and text:gsub('#%x%x%x%x%x%x','') or text
						shadowc = applyColorAlpha(shadowc,galpha)
						dxDrawText(text,textX+shadowoffx,textY+shadowoffy,textX+w+shadowoffx,textY+titsize+shadowoffy,shadowc,txtSizX,txtSizY,font,rightbottom[1],rightbottom[2],clip,wordbreak,rendSet,colorcoded)
						if shadowIsOutline then
							dxDrawText(text,textX-shadowoffx,textY+shadowoffy,textX+w-shadowoffx,textY+titsize+shadowoffy,shadowc,txtSizX,txtSizY,font,rightbottom[1],rightbottom[2],clip,wordbreak,rendSet,colorcoded)
							dxDrawText(text,textX-shadowoffx,textY-shadowoffy,textX+w-shadowoffx,textY+titsize-shadowoffy,shadowc,txtSizX,txtSizY,font,rightbottom[1],rightbottom[2],clip,wordbreak,rendSet,colorcoded)
							dxDrawText(text,textX+shadowoffx,textY-shadowoffy,textX+w+shadowoffx,textY+titsize-shadowoffy,shadowc,txtSizX,txtSizY,font,rightbottom[1],rightbottom[2],clip,wordbreak,rendSet,colorcoded)
						end
					end
				end
				dxDrawText(text,x,y,x+w,y+titsize,textColor,txtSizX,txtSizY,systemFont,rightbottom[1],rightbottom[2],clip,wordbreak,rendSet,eleData.colorcoded)
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					sideSize = applyColorAlpha(sideSize,galpha)
					local side = outlineData[1]
					local x,y = x-1,y-1
					if side == "in" then
						dxDrawLine(x,y+sideSize/2,x+w,y+sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x+sideSize/2,y,x+sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w-sideSize/2,y,x+w-sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+h-sideSize/2,x+w,y+h-sideSize/2,sideColor,sideSize,rendSet)
					elseif side == "center" then
						dxDrawLine(x-sideSize/2,y,x+w+sideSize/2,y,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+sideSize/2,x,y+h-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x+w,y+sideSize/2,x+w,y+h-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize/2,y+h,x+w+sideSize/2,y+h,sideColor,sideSize,rendSet)
					elseif side == "out" then
						dxDrawLine(x-sideSize,y-sideSize/2,x+w+sideSize,y-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize/2,y,x-sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w+sideSize/2,y,x+w+sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize,y+h+sideSize/2,x+w+sideSize,y+h+sideSize/2,sideColor,sideSize,rendSet)
					end
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if enabled[1] and mx and mx then
					if mx >= x and mx<= x+w and my >= y and my <= y+h then
						MouseData.hit = v
					end
				end
			else
				visible = false
			end
		elseif dxType == "dgs-dxbutton" then
			local x,y,cx,cy = processPositionOffset(v,x,y,w,h,parent,rndtgt,OffsetX,OffsetY)
			if x and y then
				if eleData.PixelInt then
					x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
				end
				local colors,imgs = eleData.color,eleData.image
				local colorimgid = 1
				if MouseData.enter == v then
					colorimgid = 2
					if eleData.clickType == 1 then
						if MouseData.clickl == v then
							colorimgid = 3
						end
					elseif eleData.clickType == 2 then
						if MouseData.clickr == v then
							colorimgid = 3
						end
					else
						if MouseData.clickl == v or MouseData.clickr == v then
							colorimgid = 3
						end
					end
				end
				local finalcolor
				if not enabled[1] and not enabled[2] then
					if type(eleData.disabledColor) == "number" then
						finalcolor = applyColorAlpha(eleData.disabledColor,galpha)
					elseif eleData.disabledColor == true then
						local r,g,b,a = fromcolor(colors[1],true)
						local average = (r+g+b)/3*eleData.disabledColorPercent
						finalcolor = tocolor(average,average,average,a*galpha)
					else
						finalcolor = colors[colorimgid]
					end
				else
					finalcolor = applyColorAlpha(colors[colorimgid],galpha)
				end
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if imgs[colorimgid] then
					dxDrawImage(x,y,w,h,imgs[colorimgid],0,0,0,finalcolor,rendSet)
				else
					dxDrawRectangle(x,y,w,h,finalcolor,rendSet)
				end
				local text = eleData.text
				if #text ~= 0 then
					local font = eleData.font or systemFont
					local txtSizX,txtSizY = eleData.textSize[1],eleData.textSize[2] or eleData.textSize[1]
					local clip = eleData.clip
					local wordbreak = eleData.wordbreak
					local colorcoded = eleData.colorcoded
					local rightbottom = eleData.rightbottom
					local textOffset = eleData.textOffset
					local txtoffsetsX = textOffset[3] and textOffset[1]*w or textOffset[1]
					local txtoffsetsY = textOffset[3] and textOffset[2]*h or textOffset[2]
					if colorimgid == 3 then
						txtoffsetsX,txtoffsetsY = txtoffsetsX+eleData.clickoffset[1],txtoffsetsY+eleData.clickoffset[2]
					end
					local textX,textY = x+txtoffsetsX,y+txtoffsetsY
					if eleData.shadow then
						local shadowoffx,shadowoffy,shadowc,shadowIsOutline = eleData.shadow[1],eleData.shadow[2],eleData.shadow[3],eleData.shadow[4]
						if shadowoffx and shadowoffy and shadowc then
							local shadowText = colorcoded and text:gsub('#%x%x%x%x%x%x','') or text
							shadowc = applyColorAlpha(shadowc,galpha)
							dxDrawText(shadowText,textX+shadowoffx,textY+shadowoffy,textX+w+shadowoffx,textY+h+shadowoffy,shadowc,txtSizX,txtSizY,font,rightbottom[1],rightbottom[2],clip,wordbreak,rendSet,colorcoded)
							if shadowIsOutline then
								dxDrawText(shadowText,textX-shadowoffx,textY+shadowoffy,textX+w-shadowoffx,textY+h+shadowoffy,shadowc,txtSizX,txtSizY,font,rightbottom[1],rightbottom[2],clip,wordbreak,rendSet,colorcoded)
								dxDrawText(shadowText,textX-shadowoffx,textY-shadowoffy,textX+w-shadowoffx,textY+h-shadowoffy,shadowc,txtSizX,txtSizY,font,rightbottom[1],rightbottom[2],clip,wordbreak,rendSet,colorcoded)
								dxDrawText(shadowText,textX+shadowoffx,textY-shadowoffy,textX+w+shadowoffx,textY+h-shadowoffy,shadowc,txtSizX,txtSizY,font,rightbottom[1],rightbottom[2],clip,wordbreak,rendSet,colorcoded)
							end
						end
					end
					dxDrawText(text,textX,textY,textX+w-1,textY+h-1,applyColorAlpha(eleData.textColor,galpha),txtSizX,txtSizY,font,rightbottom[1],rightbottom[2],clip,wordbreak,rendSet,colorcoded)
				end
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					sideSize = applyColorAlpha(sideSize,galpha)
					local side = outlineData[1]
					local x,y = x-1,y-1
					if side == "in" then
						dxDrawLine(x,y+sideSize/2,x+w,y+sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x+sideSize/2,y,x+sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w-sideSize/2,y,x+w-sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+h-sideSize/2,x+w,y+h-sideSize/2,sideColor,sideSize,rendSet)
					elseif side == "center" then
						dxDrawLine(x-sideSize/2,y,x+w+sideSize/2,y,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+sideSize/2,x,y+h-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x+w,y+sideSize/2,x+w,y+h-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize/2,y+h,x+w+sideSize/2,y+h,sideColor,sideSize,rendSet)
					elseif side == "out" then
						dxDrawLine(x-sideSize,y-sideSize/2,x+w+sideSize,y-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize/2,y,x-sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w+sideSize/2,y,x+w+sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize,y+h+sideSize/2,x+w+sideSize,y+h+sideSize/2,sideColor,sideSize,rendSet)
					end
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if enabled[1] and mx then
					if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
						MouseData.hit = v
					end
				end
			else
				visible = false
			end
		elseif dxType == "dgs-dxeda" then
			local x,y,cx,cy = processPositionOffset(v,x,y,w,h,parent,rndtgt,OffsetX,OffsetY)
			if x and y then
				if eleData.PixelInt then
					x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
				end
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if enabled[1] and mx then
					if dgsCheckRadius(v,mx,my) then
						MouseData.hit = v
					end
					if eleData.debug then
						local debugShader = eleData.debugShader
						if debugShader ~= "Error" then
							if not isElement(debugShader) then
								debugShader = dxCreateShader("image/eda/ellipse.fx")
								if isElement(debugShader) then
									eleData.debugShader = debugShader
								else
									outputChatBox("[DGS]Couldn't create ellipse shader (Maybe video memory isn't enough or your video card isn't support the shader)",255,0,0)
									eleData.debugShader = "Error"
								end
							end
							if MouseData.hit == v then
								dxSetShaderValue(debugShader,"tcolor",{1,0,0,0.5})
							else
								dxSetShaderValue(debugShader,"tcolor",{1,1,1,0.5})
							end
							dxDrawImage(x,y,w,h,debugShader,0,0,0,white,rendSet)
						end
					end
				end
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					sideSize = applyColorAlpha(sideSize,galpha)
					local side = outlineData[1]
					local x,y = x-1,y-1
					if side == "in" then
						dxDrawLine(x,y+sideSize/2,x+w,y+sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x+sideSize/2,y,x+sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w-sideSize/2,y,x+w-sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+h-sideSize/2,x+w,y+h-sideSize/2,sideColor,sideSize,rendSet)
					elseif side == "center" then
						dxDrawLine(x-sideSize/2,y,x+w+sideSize/2,y,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+sideSize/2,x,y+h-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x+w,y+sideSize/2,x+w,y+h-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize/2,y+h,x+w+sideSize/2,y+h,sideColor,sideSize,rendSet)
					elseif side == "out" then
						dxDrawLine(x-sideSize,y-sideSize/2,x+w+sideSize,y-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize/2,y,x-sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w+sideSize/2,y,x+w+sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize,y+h+sideSize/2,x+w+sideSize,y+h+sideSize/2,sideColor,sideSize,rendSet)
					end
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
			else
				visible = false
			end
		elseif dxType == "dgs-dxdetectarea" then
			local x,y,cx,cy = processPositionOffset(v,x,y,w,h,parent,rndtgt,OffsetX,OffsetY)
			if x and y then
				if eleData.PixelInt then
					x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
				end
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if enabled[1] and mx then
					local checkPixel = eleData.checkFunction
					if checkPixel then
						local color = 0xFFFFFFFF
						local _mx,_my = (mx-x)/w,(my-y)/h
						if _mx > 0 and _my > 0 and _mx <= 1 and _my <= 1 then
							if type(checkPixel) == "function" then
								local checkFnc = eleData.checkFunction
								if checkFnc((mx-x)/w,(my-y)/h,mx,my) then
									MouseData.hit = v
								end
							else
								local px,py = dxGetPixelsSize(checkPixel)
								local pixX,pixY = _mx*px,_my*py
								local r,g,b = dxGetPixelColor(checkPixel,pixX-1,pixY-1)
								if r then
									local gray = (r+g+b)/3
									if gray >= 128 then
										MouseData.hit = v
										color = 0xFFFF0000
									end
								end
								local detectAreaImage = eleData.checkFunctionImage
								if eleData.debug and isElement(detectAreaImage) then
									dxDrawImage(x,y,w,h,detectAreaImage,0,0,0,color,rendSet)
								end
							end
						end
					end
				end
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					sideSize = applyColorAlpha(sideSize,galpha)
					local side = outlineData[1]
					local x,y = x-1,y-1
					if side == "in" then
						dxDrawLine(x,y+sideSize/2,x+w,y+sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x+sideSize/2,y,x+sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w-sideSize/2,y,x+w-sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+h-sideSize/2,x+w,y+h-sideSize/2,sideColor,sideSize,rendSet)
					elseif side == "center" then
						dxDrawLine(x-sideSize/2,y,x+w+sideSize/2,y,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+sideSize/2,x,y+h-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x+w,y+sideSize/2,x+w,y+h-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize/2,y+h,x+w+sideSize/2,y+h,sideColor,sideSize,rendSet)
					elseif side == "out" then
						dxDrawLine(x-sideSize,y-sideSize/2,x+w+sideSize,y-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize/2,y,x-sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w+sideSize/2,y,x+w+sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize,y+h+sideSize/2,x+w+sideSize,y+h+sideSize/2,sideColor,sideSize,rendSet)
					end
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
			else
				visible = false
			end
		elseif dxType == "dgs-dximage" then
			local x,y,cx,cy = processPositionOffset(v,x,y,w,h,parent,rndtgt,OffsetX,OffsetY)
			if x and y then
				if eleData.PixelInt then
					x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
				end
				local colors,imgs = eleData.color,eleData.image
				colors = applyColorAlpha(colors,galpha)
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if colors >= 16777216 or colors < 0 then
					if imgs then
						local sx,sy = eleData.imageUVSize[1],eleData.imageUVSize[2]
						local px,py = eleData.imageUVPos[1],eleData.imageUVPos[2]
						local rotOffx,rotOffy = eleData.rotationCenter[1],eleData.rotationCenter[2]
						local rot = eleData.rotation or 0
						if not sx or not sy or not px or not py then
							dxDrawImage(x,y,w,h,imgs,rot,rotOffx,rotOffy,colors,rendSet)
						else
							dxDrawImageSection(x,y,w,h,px,py,sx,sy,imgs,rot,rotOffy,rotOffy,colors,rendSet)
						end
					else
						dxDrawRectangle(x,y,w,h,colors,rendSet)
					end
				end
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					sideSize = applyColorAlpha(sideSize,galpha)
					local side = outlineData[1]
					local x,y = x-1,y-1
					if side == "in" then
						dxDrawLine(x,y+sideSize/2,x+w,y+sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x+sideSize/2,y,x+sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w-sideSize/2,y,x+w-sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+h-sideSize/2,x+w,y+h-sideSize/2,sideColor,sideSize,rendSet)
					elseif side == "center" then
						dxDrawLine(x-sideSize/2,y,x+w+sideSize/2,y,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+sideSize/2,x,y+h-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x+w,y+sideSize/2,x+w,y+h-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize/2,y+h,x+w+sideSize/2,y+h,sideColor,sideSize,rendSet)
					elseif side == "out" then
						dxDrawLine(x-sideSize,y-sideSize/2,x+w+sideSize,y-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize/2,y,x-sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w+sideSize/2,y,x+w+sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize,y+h+sideSize/2,x+w+sideSize,y+h+sideSize/2,sideColor,sideSize,rendSet)
					end
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if enabled[1] and mx then
					if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
						MouseData.hit = v
					end
				end
			else
				visible = false
			end
		elseif dxType == "dgs-dxradiobutton" then
			local x,y,cx,cy = processPositionOffset(v,x,y,w,h,parent,rndtgt,OffsetX,OffsetY)
			if x and y then
				if eleData.PixelInt then
					x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
				end
				local image_f,image_t = eleData.image_f,eleData.image_t
				local color_f,color_t = eleData.color_f,eleData.color_t
				local rbParent = eleData.rbParent
				local image,color
				local _buttonSize = eleData.buttonSize
				local buttonSizeX,buttonSizeY
				if tonumber(_buttonSize[2]) then
					buttonSizeX = _buttonSize[3] and _buttonSize[1]*w or _buttonSize[1]
					buttonSizeY = _buttonSize[3] and _buttonSize[2]*h or _buttonSize[2]
				else
					buttonSizeX = _buttonSize[2] and _buttonSize[1]*h or _buttonSize[1]
					buttonSizeY = buttonSizeX
				end
				if dgsElementData[rbParent].RadioButton == v then
					image,color = image_t,color_t
				else
					image,color = image_f,color_f
				end
				local colorimgid = 1
				if MouseData.enter == v then
					colorimgid = 2
					if eleData.clickType == 1 then
						if MouseData.clickl == v then
							colorimgid = 3
						end
					elseif eleData.clickType == 2 then
						if MouseData.clickr == v then
							colorimgid = 3
						end
					else
						if MouseData.clickl == v or MouseData.clickr == v then
							colorimgid = 3
						end
					end
				end
				local finalcolor
				if not enabled[1] and not enabled[2] then
					if type(eleData.disabledColor) == "number" then
						finalcolor = applyColorAlpha(eleData.disabledColor,galpha)
					elseif eleData.disabledColor == true then
						local r,g,b,a = fromcolor(color[1],true)
						local average = (r+g+b)/3*eleData.disabledColorPercent
						finalcolor = tocolor(average,average,average,a*galpha)
					else
						finalcolor = color[colorimgid]
					end
				else
					finalcolor = applyColorAlpha(color[colorimgid],galpha)
				end
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if image[colorimgid] then
					dxDrawImage(x,y+h/2-buttonSizeY/2,buttonSizeX,buttonSizeY,image[colorimgid],0,0,0,finalcolor,rendSet)
				else
					dxDrawRectangle(x,y+h/2-buttonSizeY/2,buttonSizeX,buttonSizeY,finalcolor,rendSet)
				end
				local font = eleData.font or systemFont
				local txtSizX,txtSizY = eleData.textSize[1],eleData.textSize[2] or eleData.textSize[1]
				local clip = eleData.clip
				local wordbreak = eleData.wordbreak
				local _textImageSpace = eleData.textImageSpace
				local text = eleData.text
				local textImageSpace = _textImageSpace[2] and _textImageSpace[1]*w or _textImageSpace[1]
				local colorcoded = eleData.colorcoded
				local rightbottom = eleData.rightbottom
 				local shadowoffx,shadowoffy,shadowc = eleData.shadow[1],eleData.shadow[2],eleData.shadow[3]
				local px = x+buttonSizeX+textImageSpace
				if eleData.PixelInt then
					px,y,w,h = px-px%1,y-y%1,w-w%1,h-h%1
				end			
				if eleData.shadow then
					local shadowoffx,shadowoffy,shadowc,shadowIsOutline = eleData.shadow[1],eleData.shadow[2],eleData.shadow[3],eleData.shadow[4]
					local textX,textY = px,y
					if shadowoffx and shadowoffy and shadowc then
						shadowc = applyColorAlpha(shadowc,galpha)
						local shadowText = colorcoded and text:gsub('#%x%x%x%x%x%x','') or text
						dxDrawText(shadowText,textX+shadowoffx,textY+shadowoffy,textX+w+shadowoffx,textY+h+shadowoffy,shadowc,txtSizX,txtSizY,font,rightbottom[1],rightbottom[2],clip,wordbreak,rendSet,colorcoded)
						if shadowIsOutline then
							dxDrawText(shadowText,textX-shadowoffx,textY+shadowoffy,textX+w-shadowoffx,textY+h+shadowoffy,shadowc,txtSizX,txtSizY,font,rightbottom[1],rightbottom[2],clip,wordbreak,rendSet,colorcoded)
							dxDrawText(shadowText,textX-shadowoffx,textY-shadowoffy,textX+w-shadowoffx,textY+h-shadowoffy,shadowc,txtSizX,txtSizY,font,rightbottom[1],rightbottom[2],clip,wordbreak,rendSet,colorcoded)
							dxDrawText(shadowText,textX+shadowoffx,textY-shadowoffy,textX+w+shadowoffx,textY+h-shadowoffy,shadowc,txtSizX,txtSizY,font,rightbottom[1],rightbottom[2],clip,wordbreak,rendSet,colorcoded)
						end
					end
				end
				dxDrawText(eleData.text,px,y,px+w-1,y+h-1,applyColorAlpha(eleData.textColor,galpha),txtSizX,txtSizY,font,rightbottom[1],rightbottom[2],clip,wordbreak,rendSet,colorcoded)
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					sideSize = applyColorAlpha(sideSize,galpha)
					local side = outlineData[1]
					local x,y = x-1,y-1
					if side == "in" then
						dxDrawLine(x,y+sideSize/2,x+w,y+sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x+sideSize/2,y,x+sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w-sideSize/2,y,x+w-sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+h-sideSize/2,x+w,y+h-sideSize/2,sideColor,sideSize,rendSet)
					elseif side == "center" then
						dxDrawLine(x-sideSize/2,y,x+w+sideSize/2,y,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+sideSize/2,x,y+h-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x+w,y+sideSize/2,x+w,y+h-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize/2,y+h,x+w+sideSize/2,y+h,sideColor,sideSize,rendSet)
					elseif side == "out" then
						dxDrawLine(x-sideSize,y-sideSize/2,x+w+sideSize,y-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize/2,y,x-sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w+sideSize/2,y,x+w+sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize,y+h+sideSize/2,x+w+sideSize,y+h+sideSize/2,sideColor,sideSize,rendSet)
					end
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if enabled[1] and mx then
					if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
						MouseData.hit = v
					end
				end
			else
				visible = false
			end
		elseif dxType == "dgs-dxcheckbox" then
			local x,y,cx,cy = processPositionOffset(v,x,y,w,h,parent,rndtgt,OffsetX,OffsetY)
			if x and y then
				if eleData.PixelInt then
					x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
				end
				local image_f,image_t,image_i = eleData.image_f,eleData.image_t,eleData.image_i
				local color_f,color_t,color_i = eleData.color_f,eleData.color_t,eleData.color_i
				local image,color
				local _buttonSize = eleData.buttonSize
				local buttonSizeX,buttonSizeY
				if tonumber(_buttonSize[2]) then
					buttonSizeX = _buttonSize[3] and _buttonSize[1]*w or _buttonSize[1]
					buttonSizeY = _buttonSize[3] and _buttonSize[2]*h or _buttonSize[2]
				else
					buttonSizeX = _buttonSize[2] and _buttonSize[1]*h or _buttonSize[1]
					buttonSizeY = buttonSizeX
				end
				if eleData.CheckBoxState == true then
					image,color = image_t,color_t
				elseif eleData.CheckBoxState == false then 
					image,color = image_f,color_f
				else
					image,color = image_i,color_i
				end
				local colorimgid = 1
				if MouseData.enter == v then
					colorimgid = 2
					if eleData.clickType == 1 then
						if MouseData.clickl == v then
							colorimgid = 3
						end
					elseif eleData.clickType == 2 then
						if MouseData.clickr == v then
							colorimgid = 3
						end
					else
						if MouseData.clickl == v or MouseData.clickr == v then
							colorimgid = 3
						end
					end
				end
				local finalcolor
				if not enabled[1] and not enabled[2] then
					if type(eleData.disabledColor) == "number" then
						finalcolor = applyColorAlpha(eleData.disabledColor,galpha)
					elseif eleData.disabledColor == true then
						local r,g,b,a = fromcolor(color[1],true)
						local average = (r+g+b)/3*eleData.disabledColorPercent
						finalcolor = tocolor(average,average,average,a*galpha)
					else
						finalcolor = color[colorimgid]
					end
				else
					finalcolor = applyColorAlpha(color[colorimgid],galpha)
				end
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if image[colorimgid] then
					dxDrawImage(x,y+h/2-buttonSizeY/2,buttonSizeX,buttonSizeY,image[colorimgid],0,0,0,finalcolor,rendSet)
				else
					dxDrawRectangle(x,y+h/2-buttonSizeY/2,buttonSizeX,buttonSizeY,finalcolor,rendSet)
				end
				local font = eleData.font or systemFont
				local txtSizX,txtSizY = eleData.textSize[1],eleData.textSize[2] or eleData.textSize[1]
				local clip = eleData.clip
				local wordbreak = eleData.wordbreak
				local _textImageSpace = eleData.textImageSpace
				local textImageSpace = _textImageSpace[2] and _textImageSpace[1]*w or _textImageSpace[1]
				local text = eleData.text
				local colorcoded = eleData.colorcoded
				local rightbottom = eleData.rightbottom
 				local shadowoffx,shadowoffy,shadowc = eleData.shadow[1],eleData.shadow[2],eleData.shadow[3]
				local px = x+buttonSizeX+textImageSpace
				if eleData.PixelInt then
					px,y,w,h = px-px%1,y-y%1,w-w%1,h-h%1
				end
				if eleData.shadow then
					local shadowoffx,shadowoffy,shadowc,shadowIsOutline = eleData.shadow[1],eleData.shadow[2],eleData.shadow[3],eleData.shadow[4]
					local textX,textY = px,y
					if shadowoffx and shadowoffy and shadowc then
						shadowc = applyColorAlpha(shadowc,galpha)
						local shadowText = colorcoded and text:gsub('#%x%x%x%x%x%x','') or text
						dxDrawText(shadowText,textX+shadowoffx,textY+shadowoffy,textX+w+shadowoffx,textY+h+shadowoffy,shadowc,txtSizX,txtSizY,font,rightbottom[1],rightbottom[2],clip,wordbreak,rendSet,colorcoded)
						if shadowIsOutline then
							dxDrawText(shadowText,textX-shadowoffx,textY+shadowoffy,textX+w-shadowoffx,textY+h+shadowoffy,shadowc,txtSizX,txtSizY,font,rightbottom[1],rightbottom[2],clip,wordbreak,rendSet,colorcoded)
							dxDrawText(shadowText,textX-shadowoffx,textY-shadowoffy,textX+w-shadowoffx,textY+h-shadowoffy,shadowc,txtSizX,txtSizY,font,rightbottom[1],rightbottom[2],clip,wordbreak,rendSet,colorcoded)
							dxDrawText(shadowText,textX+shadowoffx,textY-shadowoffy,textX+w+shadowoffx,textY+h-shadowoffy,shadowc,txtSizX,txtSizY,font,rightbottom[1],rightbottom[2],clip,wordbreak,rendSet,colorcoded)
						end
					end
				end
				dxDrawText(text,px,y,px+w-1,y+h-1,applyColorAlpha(eleData.textColor,galpha),txtSizX,txtSizY,font,rightbottom[1],rightbottom[2],clip,wordbreak,rendSet,colorcoded)
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					sideSize = applyColorAlpha(sideSize,galpha)
					local side = outlineData[1]
					local x,y = x-1,y-1
					if side == "in" then
						dxDrawLine(x,y+sideSize/2,x+w,y+sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x+sideSize/2,y,x+sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w-sideSize/2,y,x+w-sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+h-sideSize/2,x+w,y+h-sideSize/2,sideColor,sideSize,rendSet)
					elseif side == "center" then
						dxDrawLine(x-sideSize/2,y,x+w+sideSize/2,y,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+sideSize/2,x,y+h-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x+w,y+sideSize/2,x+w,y+h-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize/2,y+h,x+w+sideSize/2,y+h,sideColor,sideSize,rendSet)
					elseif side == "out" then
						dxDrawLine(x-sideSize,y-sideSize/2,x+w+sideSize,y-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize/2,y,x-sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w+sideSize/2,y,x+w+sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize,y+h+sideSize/2,x+w+sideSize,y+h+sideSize/2,sideColor,sideSize,rendSet)
					end
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if enabled[1] and mx then
					if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
						MouseData.hit = v
					end
				end
			else
				visible = false
			end
		elseif dxType == "dgs-dxedit" then
			local x,y,cx,cy = processPositionOffset(v,x,y,w,h,parent,rndtgt,OffsetX,OffsetY)
			if x and y then
				if eleData.PixelInt then
					x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
				end
				local bgImage = eleData.bgImage
				local bgColor = eleData.bgColor
				bgColor = applyColorAlpha(bgColor,galpha)
				local edit = eleData.edit
				if not isElement(edit) then
					destroyElement(v)
					return
				end
				if MouseData.nowShow == v then
					if isConsoleActive() or isMainMenuActive() or isChatBoxInputActive() then
						MouseData.nowShow = false
					end
				end
				local text = eleData.text
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						text = fnc[1](unpack(fnc[2])) or text
					end
				end
				------------------------------------
				guiSetText(edit,text)
				if eleData.masked then
					text = string.rep(eleData.maskText,utf8.len(text))
				end
				if MouseData.nowShow == v then
					if getKeyState("lctrl") and getKeyState("a") then
						dgsSetData(v,"caretPos",0)
						dgsSetData(v,"selectFrom",utf8.len(text))
					end
				end
				local caretPos = eleData.caretPos
				local selectFro = eleData.selectFrom
				local selectColor = eleData.selectColor
				guiEditSetCaretIndex(edit,caretPos)
				guiSetProperty(edit,"SelectionStart",caretPos)
				guiSetProperty(edit,"SelectionLength",selectFro-caretPos)
				guiSetVisible(edit,visible)
				local font = eleData.font or systemFont
				local txtSizX,txtSizY = eleData.textSize[1],eleData.textSize[2] or eleData.textSize[1]
				local renderTarget = eleData.renderTarget
				if isElement(renderTarget) then
					local textColor = eleData.textColor
					local width = dxGetTextWidth(utf8.sub(text,0,caretPos),txtSizX,font)
					local selx = 0
					if selectFro-caretPos > 0 then
						selx = dxGetTextWidth(utf8.sub(text,caretPos+1,selectFro),txtSizX,font)
					elseif selectFro-caretPos < 0 then
						selx = -dxGetTextWidth(utf8.sub(text,selectFro+1,caretPos),txtSizX,font)
					end
					local showPos = eleData.showPos
					dxSetRenderTarget(renderTarget,true)
					local padding = eleData.padding
					local sidelength,sideheight = padding[1]-padding[1]%1,padding[2]-padding[2]%1
					local selectRectOffset = 0
					if eleData.center then
						selectRectOffset = dxGetTextWidth(text,txtSizX,font)
						selectRectOffset = w/2-sidelength/2-showPos/2
					end
					if selx ~= 0 then
						local caretHeight = eleData.caretHeight
						local selStartY = sideheight+(h-sideheight*2)*(1-caretHeight)
						local selEndY = (h-sideheight*2)*caretHeight-sideheight
						dxDrawRectangle(width+showPos+selectRectOffset,selStartY,selx,selEndY,selectColor)
					end
					dxDrawText(text,showPos,0,w,h,textColor,txtSizX,txtSizY,font,eleData.center and "center" or "left","center",false,false,false,false)
					if eleData.underline then
						local textHeight = dxGetFontHeight(txtSizY,font)
						local lineOffset = eleData.underlineOffset+h/2+textHeight/2
						local lineWidth = eleData.underlineWidth
						local textFontLen = eleData.textFontLen
						dxDrawLine(showPos,lineOffset,showPos+textFontLen,lineOffset,textColor,lineWidth)
					end
					dxSetRenderTarget(rndtgt)
					local finalcolor
					if not enabled[1] and not enabled[2] then
						if type(eleData.disabledColor) == "number" then
							finalcolor = eleData.disabledColor
						elseif eleData.disabledColor == true then
							local r,g,b,a = fromcolor(bgColor,true)
							local average = (r+g+b)/3*eleData.disabledColorPercent
							finalcolor = tocolor(average,average,average,a)
						else
							finalcolor = bgColor
						end
					else
						finalcolor = bgColor
					end
					if bgImage then
						dxDrawImage(x,y,w,h,bgImage,0,0,0,finalcolor,rendSet)
					else
						dxDrawRectangle(x,y,w,h,finalcolor,rendSet)
					end
					local px,py,pw,ph = x+sidelength,y+sideheight,w-sidelength*2,h-sideheight*2
					dxDrawImage(px,py,pw,ph,renderTarget,0,0,0,tocolor(255,255,255,255*galpha),rendSet)
					
					if MouseData.nowShow == v and MouseData.editCursor then
						local CaretShow = true
						if eleData.readOnly then
							CaretShow = eleData.readOnlyCaretShow
						end
						if CaretShow then
							local caretHeight = eleData.caretHeight
							local caretStyle = eleData.caretStyle
							local selStartX = x+width+showPos+sidelength
							if caretStyle == 0 then
								if -showPos <= width then
									local selStartY = y+sideheight+(h-sideheight*2)*(1-caretHeight)
									local selEndY = (h-sideheight*2)*caretHeight
									dxDrawLine(selStartX-1,selStartY,selStartX-1,selEndY+selStartY,eleData.caretColor,eleData.caretThick,isRenderTarget)
								end
							elseif caretStyle == 1 then
								local cursorWidth = dxGetTextWidth(utf8.sub(text,caretPos+1,caretPos+1),txtSizX,font)
								if cursorWidth == 0 then
									cursorWidth = txtSizX*8
								end
								if -showPos-cursorWidth <= width then
									local offset = eleData.caretOffset
									local selStartY = y+h-sideheight*2
									dxDrawLine(selStartX-1,selStartY-offset,selStartX+cursorWidth-1,selStartY-offset,eleData.caretColor,eleData.caretThick,isRenderTarget)
								end
							end
						end
					end
				end
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					sideSize = applyColorAlpha(sideSize,galpha)
					local side = outlineData[1]
					local x,y = x-1,y-1
					if side == "in" then
						dxDrawLine(x,y+sideSize/2,x+w,y+sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x+sideSize/2,y,x+sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w-sideSize/2,y,x+w-sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+h-sideSize/2,x+w,y+h-sideSize/2,sideColor,sideSize,rendSet)
					elseif side == "center" then
						dxDrawLine(x-sideSize/2,y,x+w+sideSize/2,y,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+sideSize/2,x,y+h-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x+w,y+sideSize/2,x+w,y+h-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize/2,y+h,x+w+sideSize/2,y+h,sideColor,sideSize,rendSet)
					elseif side == "out" then
						dxDrawLine(x-sideSize,y-sideSize/2,x+w+sideSize,y-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize/2,y,x-sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w+sideSize/2,y,x+w+sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize,y+h+sideSize/2,x+w+sideSize,y+h+sideSize/2,sideColor,sideSize,rendSet)
					end
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if enabled[1] and mx then
					if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
						MouseData.hit = v
					end
				end
			else
				visible = false
			end
		elseif dxType == "dgs-dxmemo" then
			local x,y,cx,cy = processPositionOffset(v,x,y,w,h,parent,rndtgt,OffsetX,OffsetY)
			if x and y then
				if eleData.PixelInt then
					x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
				end
				local bgImage = eleData.bgImage
				local bgColor = eleData.bgColor
				bgColor = setColorAlpha(bgColor,getColorAlpha(bgColor)*galpha)
				local memo = eleData.memo
				if not isElement(memo) then
					destroyElement(v)
				end
				if MouseData.nowShow == v then
					if isConsoleActive() or isMainMenuActive() or isChatBoxInputActive() then
						MouseData.nowShow = false
					end
				end
				local text = eleData.text
				local allLine = #text
				if MouseData.nowShow == v then
					if getKeyState("lctrl") and getKeyState("a") then
						dgsSetData(v,"caretPos",{0,1})
						dgsSetData(v,"selectFrom",{utf8.len(text[allLine]),allLine})
					end
				end
				local caretPos = eleData.caretPos
				local selectFro = eleData.selectFrom
				local selectColor = eleData.selectColor
				local font = eleData.font or systemFont
				local txtSizX,txtSizY = eleData.textSize[1],eleData.textSize[2]
				local renderTarget = eleData.renderTarget
				local fontHeight = dxGetFontHeight(eleData.textSize[2],font)
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if isElement(renderTarget) then
					local textColor = eleData.textColor
					local showLine = eleData.showLine
					local caretHeight = eleData.caretHeight-1
					local canHoldLines = math.floor((h-4)/fontHeight)
					canHoldLines = canHoldLines > allLine and allLine or canHoldLines
					local selPosStart,selPosEnd,selStart,selEnd
					dxSetRenderTarget(renderTarget,true)
					if allLine > 0 then
						local toShowLine = showLine+canHoldLines
						toShowLine = toShowLine > #text and #text or toShowLine
						local offset = eleData.showPos
						if caretPos[2] == selectFro[2] then
							if selectFro[1]>caretPos[1] then
								selPosStart = caretPos[1]
								selPosEnd = selectFro[1]
							else
								selPosStart = selectFro[1]
								selPosEnd = caretPos[1]
							end
							if selectFro[2]>caretPos[2] then
								selStart = caretPos[2]
								selEnd = selectFro[2]
							else
								selStart = selectFro[2]
								selEnd = caretPos[2]
							end
							local startx = dxGetTextWidth(utf8.sub(text[selStart],0,selPosStart),txtSizX,font)
							local selx = dxGetTextWidth(utf8.sub(text[selStart],selPosStart+1,selPosEnd),txtSizX,font)
							dxDrawRectangle(offset+startx,2+(selStart-showLine)*fontHeight-fontHeight*caretHeight,selx,fontHeight*(caretHeight+1)-4,selectColor)
						else
							if selectFro[2]>caretPos[2] then
								selStart = caretPos[2]
								selEnd = selectFro[2]
								selPosStart = caretPos[1]
								selPosEnd = selectFro[1]
							else
								selStart = selectFro[2]
								selEnd = caretPos[2]
								selPosStart = selectFro[1]
								selPosEnd = caretPos[1]
							end
							local startx = dxGetTextWidth(utf8.sub(text[selStart],0,selPosStart),txtSizX,font)
							for i=selStart > showLine and selStart or showLine,selEnd < toShowLine and selEnd or toShowLine do
								if i ~= selStart and i ~= selEnd then
									local selx = dxGetTextWidth(text[i],txtSizX,font)
									dxDrawRectangle(offset,2+(i-showLine)*fontHeight-fontHeight*caretHeight,selx,fontHeight*(caretHeight+1)-4,selectColor)
								elseif i == selStart then
									local selx = dxGetTextWidth(utf8.sub(text[i],selPosStart+1),txtSizX,font)
									dxDrawRectangle(offset+startx,2+(i-showLine)*fontHeight-fontHeight*caretHeight,selx,fontHeight*(caretHeight+1)-4,selectColor)
								elseif i == selEnd then
									local selx = dxGetTextWidth(utf8.sub(text[i],0,selPosEnd),txtSizX,font)
									dxDrawRectangle(offset,2+(i-showLine)*fontHeight-fontHeight*caretHeight,selx,fontHeight*(caretHeight+1)-4,selectColor)
								end
							end
						end
						for i=showLine,toShowLine do
							local ypos = (i-showLine)*fontHeight
							dxDrawText(text[i],offset,ypos,dxGetTextWidth(text[i],txtSizX,font),fontHeight+ypos,textColor,txtSizX,txtSizY,font,"left","top",true,false,false,false)
						end
					end
					dxSetRenderTarget(rndtgt)
					local finalcolor
					if not enabled[1] and not enabled[2] then
						if type(eleData.disabledColor) == "number" then
							finalcolor = eleData.disabledColor
						elseif eleData.disabledColor == true then
							local r,g,b,a = fromcolor(bgColor,true)
							local average = (r+g+b)/3*eleData.disabledColorPercent
							finalcolor = tocolor(average,average,average,a)
						else
							finalcolor = bgColor
						end
					else
						finalcolor = bgColor
					end
					if bgImage then
						dxDrawImage(x,y,w,h,bgImage,0,0,0,finalcolor,rendSet)
					else
						dxDrawRectangle(x,y,w,h,finalcolor,rendSet)
					end
					local scbThick = eleData.scrollBarThick
					local scrollbars = eleData.scrollbars
					local scbTakes1,scbTakes2 = dgsElementData[scrollbars[1]].visible and scbThick+2 or 4,dgsElementData[scrollbars[2]].visible and scbThick or 0
					dxDrawImageSection(x+2,y,w-scbTakes1,h-scbTakes2,0,0,w-scbTakes1,h-scbTakes2,renderTarget,0,0,0,tocolor(255,255,255,255*galpha),rendSet)
					if MouseData.nowShow == v and MouseData.memoCursor then
						local CaretShow = true
						if eleData.readOnly then
							CaretShow = eleData.readOnlyCaretShow
						end
						if CaretShow then
							local showLine = eleData.showLine
							local currentLine = eleData.caretPos[2]
							if currentLine >= showLine and currentLine <= showLine+canHoldLines then
								local lineStart = fontHeight*(currentLine-showLine)
								local theText = text[caretPos[2]] or ""
								local cursorPX = caretPos[1]
								local width = dxGetTextWidth(utfSub(theText,1,cursorPX),txtSizX,font)
								local showPos = eleData.showPos
								local caretStyle = eleData.caretStyle
								if caretStyle == 0 then
									local selStartY = y+lineStart+1+fontHeight*(1-caretHeight)
									local selEndY = y+lineStart+fontHeight*caretHeight-2
									dxDrawLine(x+width+showPos+1,selStartY,x+width+showPos+1,selEndY,eleData.caretColor,eleData.caretThick,isRenderTarget)
								elseif caretStyle == 1 then
									local cursorWidth = dxGetTextWidth(utf8.sub(theText,cursorPX+1,cursorPX+1),txtSizX,font)
									if cursorWidth == 0 then
										cursorWidth = txtSizX*8
									end
									local offset = eleData.caretOffset
									dxDrawLine(x+width+showPos+1,y+h-4+offset,x+width+showPos+cursorWidth+2,y+h-4+offset,eleData.caretColor,eleData.caretThick,isRenderTarget)
								end
							end
						end
					end	
				end
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					sideSize = applyColorAlpha(sideSize,galpha)
					local side = outlineData[1]
					local x,y = x-1,y-1
					if side == "in" then
						dxDrawLine(x,y+sideSize/2,x+w,y+sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x+sideSize/2,y,x+sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w-sideSize/2,y,x+w-sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+h-sideSize/2,x+w,y+h-sideSize/2,sideColor,sideSize,rendSet)
					elseif side == "center" then
						dxDrawLine(x-sideSize/2,y,x+w+sideSize/2,y,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+sideSize/2,x,y+h-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x+w,y+sideSize/2,x+w,y+h-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize/2,y+h,x+w+sideSize/2,y+h,sideColor,sideSize,rendSet)
					elseif side == "out" then
						dxDrawLine(x-sideSize,y-sideSize/2,x+w+sideSize,y-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize/2,y,x-sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w+sideSize/2,y,x+w+sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize,y+h+sideSize/2,x+w+sideSize,y+h+sideSize/2,sideColor,sideSize,rendSet)
					end
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if enabled[1] and mx then
					if mx >= cx-2 and mx<= cx+w-1 and my >= cy-2 and my <= cy+h-1 then
						MouseData.hit = v
					end
				end
			else
				visible = false
			end
		elseif dxType == "dgs-dxscrollpane" then
			local x,y,cx,cy = processPositionOffset(v,x,y,w,h,parent,rndtgt,OffsetX,OffsetY)
			if eleData.configNextFrame then
				configScrollPane(v)
				dgsSetData(v,"configNextFrame",false)
			end
			if x and y then
				if eleData.PixelInt then
					x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
				end
				local postgui = isRenderTarget
				if rndtgt then
					if rndtgt == eleData.renderTarget_parent then
						postgui = true
					end
				end
				rndtgt = eleData.renderTarget_parent
				dxSetRenderTarget(rndtgt,true)
				dxSetRenderTarget()
				local scrollbar = eleData.scrollbars
				local scbThick = eleData.scrollBarThick
				local scbstate = {dgsElementData[scrollbar[1]].visible,dgsElementData[scrollbar[2]].visible}
				local xthick = scbstate[1] and scbThick or 0
				local ythick = scbstate[2] and scbThick or 0
				local maxSize = eleData.maxChildSize
				local relSizX,relSizY = w-xthick,h-ythick
				local maxX,maxY = (maxSize[1]-relSizX),(maxSize[2]-relSizY)
				maxX,maxY = maxX > 0 and maxX or 0,maxY > 0 and maxY or 0
				OffsetX = scbstate[2] and -maxX*dgsElementData[scrollbar[2]].position/100 or 0
				OffsetY = scbstate[1] and -maxY*dgsElementData[scrollbar[1]].position/100 or 0
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				dxDrawImage(x,y,relSizX,relSizY,rndtgt,0,0,0,tocolor(255,255,255,255*galpha),postgui)
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					sideSize = applyColorAlpha(sideSize,galpha)
					local side = outlineData[1]
					local x,y = x-1,y-1
					if side == "in" then
						dxDrawLine(x,y+sideSize/2,x+w,y+sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x+sideSize/2,y,x+sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w-sideSize/2,y,x+w-sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+h-sideSize/2,x+w,y+h-sideSize/2,sideColor,sideSize,rendSet)
					elseif side == "center" then
						dxDrawLine(x-sideSize/2,y,x+w+sideSize/2,y,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+sideSize/2,x,y+h-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x+w,y+sideSize/2,x+w,y+h-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize/2,y+h,x+w+sideSize/2,y+h,sideColor,sideSize,rendSet)
					elseif side == "out" then
						dxDrawLine(x-sideSize,y-sideSize/2,x+w+sideSize,y-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize/2,y,x-sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w+sideSize/2,y,x+w+sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize,y+h+sideSize/2,x+w+sideSize,y+h+sideSize/2,sideColor,sideSize,rendSet)
					end
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if enabled[1] and mx then
					if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
						MouseData.scrollPane = v
						MouseData.hit = v
						if mx >= cx+relSizX and my >= cy+relSizY and scbstate[1] and scbstate[2] then
							enabled[1] = false
						end
					else
						enabled[1] = false
					end
				end
			end
		elseif dxType == "dgs-dxscrollbar" then
			local x,y,cx,cy = processPositionOffset(v,x,y,w,h,parent,rndtgt,OffsetX,OffsetY)
			if x and y then
				if eleData.PixelInt then
					x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
				end
				local ax,ay = dgsGetPosition(v,false)
				local voh = eleData.voh
				local image = eleData.image
				local pos = eleData.position
				local length,lrlt = eleData.length[1],eleData.length[2]
				local colors = {eleData.colorn,eleData.colore,eleData.colorc}
				local cursorColor,arrowColor,troughColor = eleData.cursorColor,eleData.arrowColor,eleData.troughColor
				local tempCursorColor = {}
				local tempArrowColor = {}
				for key,color in pairs(cursorColor) do
					tempCursorColor[key] = applyColorAlpha(color,galpha)
				end
				for key,color in pairs(arrowColor) do
					tempArrowColor[key] = applyColorAlpha(color,galpha)
				end
				local tempTroughColor = applyColorAlpha(troughColor,galpha)
				local colorImageIndex = {1,1,1,1}
				local slotRange
				local scrollArrow =  eleData.scrollArrow
				local arrowPos = 0
				if voh then
					if scrollArrow then
						arrowPos = h
					end
					slotRange = w-arrowPos*2
				else
					if scrollArrow then
						arrowPos = w
					end
					slotRange = h-arrowPos*2
				end
				local cursorRange = lrlt and length*slotRange or (length <= slotRange and length or 0)
				local csRange = slotRange-cursorRange
				if MouseData.enter == v then
					if not MouseData.clickData then
						MouseData.enterData = false
						if voh then
							if my >= cy-2 and my <= cy+h-1 then
								if mx >= cx-2 and mx <= cx+arrowPos-1 then			------left
									MouseData.enterData = 1
								elseif mx >= cx+w-arrowPos-2 and mx <= cx+w-1 then		------right
									MouseData.enterData = 4
								elseif mx >= cx+arrowPos+pos*0.01*csRange and mx <= cx+arrowPos+pos*0.01*csRange+cursorRange then
									MouseData.enterData = 2
								end
							end
						else
							if mx >= cx-2 and mx <= cx+w-1 then
								if my >= cy-1 and my <= cy+arrowPos then			------up
									MouseData.enterData = 1
								elseif my >= cy+h-arrowPos and my <= cy+h then			------down
									MouseData.enterData = 4
								elseif my >= cy+arrowPos+pos*0.01*csRange and my <= cy+arrowPos+pos*0.01*csRange+cursorRange then
									MouseData.enterData = 2
								end
							end
						end
						if MouseData.enterData then
							colorImageIndex[MouseData.enterData] = 2
						end
					else
						colorImageIndex[MouseData.clickData] = 3
						if MouseData.clickData == 2 then
							local position
							local mvx,mvy = MouseData.Move[1],MouseData.Move[2]
							if voh then
								local gx = (mx-mvx-ax)/csRange
								position = (gx < 0 and 0) or (gx > 1 and 1) or gx
							else
								local gy = (my-mvy-ay)/csRange
								position = (gy < 0 and 0) or (gy > 1 and 1) or gy
							end
							dgsSetData(v,"position",position*100)
						end
					end
				end
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if voh then
					if image[3] then
						dxDrawImage(x+arrowPos,y,w-2*arrowPos,h,image[3],0,0,0,tempTroughColor,rendSet)
					else
						dxDrawRectangle(x+arrowPos,y,w-2*arrowPos,h,tempTroughColor,rendSet)
					end
					if scrollArrow then
						dxDrawImage(x,y,h,h,image[1],270,0,0,tempArrowColor[colorImageIndex[1]],rendSet)
						dxDrawImage(x+w-h,y,h,h,image[1],90,0,0,tempArrowColor[colorImageIndex[4]],rendSet)
					end
					if image[2] then
						dxDrawImage(x+arrowPos+pos*0.01*csRange,y,cursorRange,h,image[2],270,0,0,tempCursorColor[colorImageIndex[2]],rendSet)
					else
						dxDrawRectangle(x+arrowPos+pos*0.01*csRange,y,cursorRange,h,tempCursorColor[colorImageIndex[2]],rendSet)
					end
				else
					if image[3] then
						dxDrawImage(x,y+arrowPos,w,h-2*arrowPos,image[3],0,0,0,tempTroughColor,rendSet)
					else
						dxDrawRectangle(x,y+arrowPos,w,h-2*arrowPos,tempTroughColor,rendSet)
					end
					if scrollArrow then
						dxDrawImage(x,y,w,w,image[1],0,0,0,tempArrowColor[colorImageIndex[1]],rendSet)
						dxDrawImage(x,y+h-w,w,w,image[1],180,0,0,tempArrowColor[colorImageIndex[4]],rendSet)
					end
					if image[2] then
						dxDrawImage(x,y+arrowPos+pos*0.01*csRange,w,cursorRange,image[2],270,0,0,tempCursorColor[colorImageIndex[2]],rendSet)
					else
						dxDrawRectangle(x,y+arrowPos+pos*0.01*csRange,w,cursorRange,tempCursorColor[colorImageIndex[2]],rendSet)
					end
				end
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					sideSize = applyColorAlpha(sideSize,galpha)
					local side = outlineData[1]
					local x,y = x-1,y-1
					if side == "in" then
						dxDrawLine(x,y+sideSize/2,x+w,y+sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x+sideSize/2,y,x+sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w-sideSize/2,y,x+w-sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+h-sideSize/2,x+w,y+h-sideSize/2,sideColor,sideSize,rendSet)
					elseif side == "center" then
						dxDrawLine(x-sideSize/2,y,x+w+sideSize/2,y,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+sideSize/2,x,y+h-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x+w,y+sideSize/2,x+w,y+h-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize/2,y+h,x+w+sideSize/2,y+h,sideColor,sideSize,rendSet)
					elseif side == "out" then
						dxDrawLine(x-sideSize,y-sideSize/2,x+w+sideSize,y-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize/2,y,x-sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w+sideSize/2,y,x+w+sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize,y+h+sideSize/2,x+w+sideSize,y+h+sideSize/2,sideColor,sideSize,rendSet)
					end
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if enabled[1] and mx then
					if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
						MouseData.hit = v
					end
				end
			else
				visible = false
			end
		elseif dxType == "dgs-dxlabel" then
			local x,y,cx,cy = processPositionOffset(v,x,y,w,h,parent,rndtgt,OffsetX,OffsetY)
			if x and y then
				if eleData.PixelInt then
					x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
				end
				local rightbottom = eleData.rightbottom
				local colors,imgs = eleData.textColor,eleData.image
				colors = applyColorAlpha(colors,galpha)
				local colorimgid = 1
				if MouseData.enter == v then
					colorimgid = 2
					if MouseData.clickl == v then
						colorimgid = 3
					end
				end
				local font = eleData.font or systemFont
				local clip = eleData.clip
				local wordbreak = eleData.wordbreak
				local text = eleData.text
				local txtSizX,txtSizY = eleData.textSize[1],eleData.textSize[2]
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						text = fnc[1](unpack(fnc[2])) or text
					end
				end
				------------------------------------
				local colorcoded = eleData.colorcoded
				if eleData.shadow then
					local shadowoffx,shadowoffy,shadowc,shadowIsOutline = eleData.shadow[1],eleData.shadow[2],eleData.shadow[3],eleData.shadow[4]
					local textX,textY = x,y
					if shadowoffx and shadowoffy and shadowc then
						shadowc = applyColorAlpha(shadowc,galpha)
						local shadowText = colorcoded and text:gsub('#%x%x%x%x%x%x','') or text
						dxDrawText(shadowText,textX+shadowoffx,textY+shadowoffy,textX+w+shadowoffx,textY+h+shadowoffy,shadowc,txtSizX,txtSizY,font,rightbottom[1],rightbottom[2],clip,wordbreak,rendSet,colorcoded)
						if shadowIsOutline then
							dxDrawText(shadowText,textX-shadowoffx,textY+shadowoffy,textX+w-shadowoffx,textY+h+shadowoffy,shadowc,txtSizX,txtSizY,font,rightbottom[1],rightbottom[2],clip,wordbreak,rendSet,colorcoded)
							dxDrawText(shadowText,textX-shadowoffx,textY-shadowoffy,textX+w-shadowoffx,textY+h-shadowoffy,shadowc,txtSizX,txtSizY,font,rightbottom[1],rightbottom[2],clip,wordbreak,rendSet,colorcoded)
							dxDrawText(shadowText,textX+shadowoffx,textY-shadowoffy,textX+w+shadowoffx,textY+h-shadowoffy,shadowc,txtSizX,txtSizY,font,rightbottom[1],rightbottom[2],clip,wordbreak,rendSet,colorcoded)
						end
					end
				end
				dxDrawText(text,x,y,x+w,y+h,colors,txtSizX,txtSizY,font,rightbottom[1],rightbottom[2],clip,wordbreak,rendSet,colorcoded,true)
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					sideSize = applyColorAlpha(sideSize,galpha)
					local side = outlineData[1]
					local x,y = x-1,y-1
					if side == "in" then
						dxDrawLine(x,y+sideSize/2,x+w,y+sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x+sideSize/2,y,x+sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w-sideSize/2,y,x+w-sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+h-sideSize/2,x+w,y+h-sideSize/2,sideColor,sideSize,rendSet)
					elseif side == "center" then
						dxDrawLine(x-sideSize/2,y,x+w+sideSize/2,y,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+sideSize/2,x,y+h-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x+w,y+sideSize/2,x+w,y+h-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize/2,y+h,x+w+sideSize/2,y+h,sideColor,sideSize,rendSet)
					elseif side == "out" then
						dxDrawLine(x-sideSize,y-sideSize/2,x+w+sideSize,y-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize/2,y,x-sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w+sideSize/2,y,x+w+sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize,y+h+sideSize/2,x+w+sideSize,y+h+sideSize/2,sideColor,sideSize,rendSet)
					end
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if enabled[1] and mx then
					if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
						MouseData.hit = v
					end
				end
			else
				visible = false
			end
		elseif dxType == "dgs-dxgridlist" then
			local x,y,cx,cy = processPositionOffset(v,x,y,w,h,parent,rndtgt,OffsetX,OffsetY)
			if eleData.configNextFrame then
				configGridList(v)
				dgsSetData(v,"configNextFrame",false)
			end
			if x and y then
				local nx,ny,nw,nh = x,y,w,h
				if eleData.PixelInt then
					x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
				end
				local DataTab = eleData
				local bgColor,bgImage = DataTab.bgColor,DataTab.bgImage
				local columncolor,columnimg = DataTab.columnColor,DataTab.columnImage
				local font = DataTab.font or systemFont
				columncolor = applyColorAlpha(columncolor,galpha)
				bgColor = applyColorAlpha(bgColor,galpha)
				local columnHeight = DataTab.columnHeight
				if MouseData.enter == v then
					colorimgid = 2
					if MouseData.clickl == v then
						colorimgid = 3
					end
					MouseData.enterData = false
				end
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if bgImage then
					dxDrawImage(x,y+columnHeight,w,h-columnHeight,bgImage,0,0,0,bgColor,rendSet)
				else
					dxDrawRectangle(x,y+columnHeight,w,h-columnHeight,bgColor,rendSet)
				end
				if columnimg then
					dxDrawImage(x,y,w,columnHeight,columnimg,0,0,0,columncolor,rendSet)
				else
					dxDrawRectangle(x,y,w,columnHeight,columncolor,rendSet)
				end
				local columnData = DataTab.columnData
				local sortColumn = DataTab.sortColumn
				if sortColumn and columnData[sortColumn] then
					if DataTab.nextRenderSort then
						dgsGridListSort(v)
						dgsElementData[v].nextRenderSort = false
					end
				end
				local mode = DataTab.mode
				local columnTextColor = DataTab.columnTextColor
				local columnRelt = DataTab.columnRelative
				local rowData = DataTab.rowData
				local rowHeight = DataTab.rowHeight
				local scbThick = DataTab.scrollBarThick
				local scrollbars = DataTab.scrollbars
				local scbThickV,scbThickH = dgsElementData[ scrollbars[1] ].visible and scbThick or 0,dgsElementData[ scrollbars[2] ].visible and scbThick or 0
				local colorcoded = DataTab.colorcoded
				local shadow = DataTab.rowShadow
				local columnCount = #columnData
				local rowCount = #rowData
				dxSetRenderTarget()
				local rowMoveOffset = DataTab.rowMoveOffset
				local columnOffset = DataTab.columnOffset
				local columnMoveOffset = eleData.PixelInt and DataTab.columnMoveOffset-DataTab.columnMoveOffset%1
				local fnc = eleData.functions
				local rowTextSx,rowTextSy = DataTab.rowTextSize[1],DataTab.rowTextSize[2] or DataTab.rowTextSize[1]
				local columnTextSx,columnTextSy = DataTab.columnTextSize[1],DataTab.columnTextSize[2] or DataTab.columnTextSize[1]
				local selectionMode = DataTab.selectionMode
				local clip = eleData.clip
				local mouseInsideGridList = mx >= cx and mx <= cx+w and my >= cy and my <= cy+h-scbThickH
				local mouseInsideColumn = mouseInsideGridList and my <= cy+columnHeight
				local mouseInsideRow = mouseInsideGridList and my > cy+columnHeight
				DataTab.selectedColumn = -1
				local sortIcon = DataTab.sortFunction == sortFunctions_lower and "▼" or (DataTab.sortFunction == sortFunctions_upper and "▲") or nil
				local sortColumn = DataTab.sortColumn
				if not mode then
					local whichRowToStart = -math.floor((DataTab.rowMoveOffset+rowHeight)/rowHeight)+1
					local whichRowToEnd = whichRowToStart+math.floor((h-columnHeight-scbThickH+rowHeight*2)/rowHeight)-1
					DataTab.FromTo = {whichRowToStart > 0 and whichRowToStart or 1,whichRowToEnd <= rowCount and whichRowToEnd or rowCount}
					local renderTarget = DataTab.renderTarget
					local isDraw1,isDraw2 = isElement(renderTarget[1]),isElement(renderTarget[2])
					dxSetRenderTarget(renderTarget[1],true)
						local cpos = {}
						local cend = {}
						local multiplier = columnRelt and (w-scbThickV) or 1
						local tempColumnOffset = columnMoveOffset+columnOffset
						local mouseColumnPos = mx-cx
						local mouseSelectColumn = -1
						for id,data in ipairs(columnData) do
							local _columnTextColor = data[5] or columnTextColor
							local _columnTextColorCoded = data[6] or colorcoded
							local _columnTextSx,_columnTextSy = data[7] or columnTextSx,data[8] or columnTextSy
							local _columnFont = data[9] or font
							local tempCpos = data[3]*multiplier
							local _tempStartx = tempCpos+tempColumnOffset
							local _tempEndx = _tempStartx+data[2]*multiplier
							if _tempStartx <= w and _tempEndx >= 0 then
								cpos[id] = tempCpos
								cend[id] = _tempEndx
								if isDraw1 then
									local _tempStartx = eleData.PixelInt and _tempStartx-_tempStartx%1 or _tempStartx
									if sortColumn == id and sortIcon then
										if DataTab.columnShadow then
											dxDrawText(sortIcon,_tempStartx+1-10,1,_tempEndx,columnHeight,black,_columnTextSx,_columnTextSy,_columnFont,"left","center",clip,false,false,false,true)
										end
										dxDrawText(sortIcon,_tempStartx-10,0,_tempEndx,columnHeight,_columnTextColor,_columnTextSx,_columnTextSy,_columnFont,"left","center",clip,false,false,false,true)
									end
									if DataTab.columnShadow then
										dxDrawText(data[1],_tempStartx+1,1,_tempEndx,columnHeight,black,_columnTextSx,_columnTextSy,_columnFont,data[4],"center",clip,false,false,false,true)
									end
									dxDrawText(data[1],_tempStartx,0,_tempEndx,columnHeight,_columnTextColor,_columnTextSx,_columnTextSy,_columnFont,data[4],"center",clip,false,false,_columnTextColorCoded,true)
								end
								if mouseInsideGridList and mouseSelectColumn == -1 then
									if mouseColumnPos >= _tempStartx and mouseColumnPos <= _tempEndx then
										mouseSelectColumn = id
									end
								end
							end
						end
					dxSetRenderTarget(renderTarget[2],true)
						if MouseData.enter == v then		-------PreSelect
							if mouseInsideRow then
								local toffset = (whichRowToStart*rowHeight)+DataTab.rowMoveOffset
								sid = math.floor((my-cy-columnHeight-toffset)/rowHeight)+whichRowToStart+1
								if sid >= 1 and sid <= rowCount then
									DataTab.oPreSelect = sid
									if rowData[sid][-2] then
										DataTab.preSelect = {sid,mouseSelectColumn}
									else
										DataTab.preSelect = {-1,mouseSelectColumn}
									end
									MouseData.enterData = true
								else
									DataTab.preSelect = {-1,mouseSelectColumn}
								end
							elseif mouseInsideColumn then
								DataTab.selectedColumn = mouseSelectColumn
								DataTab.preSelect = {}
							else
								DataTab.preSelect = {-1,-1}
							end
						end
						local preSelect = DataTab.preSelect
						local Select = DataTab.rowSelect
						local sectionFont = eleData.sectionFont or font
						for i=DataTab.FromTo[1],DataTab.FromTo[2] do
							local lc_rowData = rowData[i]
							local image,columnOffset,isSection,color = lc_rowData[-3],lc_rowData[-4],lc_rowData[-5],lc_rowData[0]
							if isDraw2 then
								local rowpos = i*rowHeight
								local rowpos_1 = rowpos-rowHeight
								local _x,_y,_sx,_sy = tempColumnOffset+columnOffset,rowpos_1+rowMoveOffset,sW,rowpos+rowMoveOffset
								if eleData.PixelInt then
									_x,_y,_sx,_sy = _x-_x%1,_y-_y%1,_sx-_sx%1,_sy-_sy%1
								end
								local textBuffer = {}
								for id,v in pairs(cpos) do
									local text = lc_rowData[id][1]
									local _txtFont = isSection and sectionFont or (lc_rowData[id][6] or font)
									local _txtScalex = lc_rowData[id][4] or rowTextSx
									local _txtScaley = lc_rowData[id][5] or rowTextSy
									local rowState = 1
									if selectionMode == 1 then
										if i == preSelect[1] then
											rowState = 2
										end
										if Select[i] and Select[i][1] then
											rowState = 3
										end
									elseif selectionMode == 2 then
										if id == preSelect[2] then
											rowState = 2
										end
										if Select[1] and Select[1][id] then
											rowState = 3
										end
									elseif selectionMode == 3 then
										if i == preSelect[1] and id == preSelect[2] then
											rowState = 2
										end
										if Select[i] and Select[i][id] then
											rowState = 3
										end
									end
									local offset = cpos[id]
									local _x = _x+offset
									local _sx = cend[id]
									local _backgroundWidth = columnData[id][2]*multiplier
									local _bgX = _x
									local backgroundWidth = _backgroundWidth
									if id == 1 then
										_bgX = _x+DataTab.backgroundOffset
										backgroundWidth = _backgroundWidth-DataTab.backgroundOffset
									elseif backgroundWidth+_x-x >= w or columnCount == id then
										backgroundWidth = w-_x+x
									end
									if #image > 0 then
										dxDrawImage(_bgX,_y,backgroundWidth,rowHeight,image[rowState],0,0,0,color[rowState])
									else
										dxDrawRectangle(_bgX,_y,backgroundWidth,rowHeight,color[rowState])
									end
									if text then
										local colorcoded = lc_rowData[id][3] == nil and colorcoded or lc_rowData[id][3]
										if lc_rowData[id][7] then
											local imageData = lc_rowData[id][7]
											if isElement(imageData[1]) then
												dxDrawImage(_x+imageData[3],_y+imageData[4],imageData[5],imageData[6],imageData[1],0,0,0,imageData[2])
											else
												dxDrawRectangle(_x+imageData[3],_y+imageData[4],imageData[5],imageData[6],imageData[2])
											end
										end
										textBuffer[id] = {lc_rowData[id][1],_x-_x%1,_sx-_sx%1,lc_rowData[id][2],_txtScalex,_txtScaley,_txtFont,clip,colorcoded,columnData[id][4]}
									end
								end
								for k,v in pairs(textBuffer) do
									local colorcoded = v[9]
									local text = v[1]
									if shadow then
										if colorcoded then
											text = text:gsub("#%x%x%x%x%x%x","") or text
										end
										dxDrawText(text,v[2]+shadow[1],_y+shadow[2],v[3]+shadow[1],_sy+shadow[2],shadow[3],v[5],v[6],v[7],v[10],"center",v[8],false,false,false,true)
									end
									dxDrawText(v[1],v[2],_y,v[3],_sy,v[4],v[5],v[6],v[7],v[10],"center",v[8],false,false,colorcoded,true)
								end
							end
						end
					dxSetRenderTarget(rndtgt)
					if isElement(renderTarget[2]) then
						dxDrawImage(x,y+columnHeight,w-scbThickV,h-columnHeight-scbThickH,renderTarget[2],0,0,0,tocolor(255,255,255,255*galpha),rendSet)
					end
					if isElement(renderTarget[1]) then
						dxDrawImage(x,y,w-scbThickV,columnHeight,renderTarget[1],0,0,0,tocolor(255,255,255,255*galpha),rendSet)
					end
				elseif columnCount >= 1 then
					local whichRowToStart = -math.floor((DataTab.rowMoveOffset+rowHeight)/rowHeight)+2
					local whichRowToEnd = whichRowToStart+math.floor((h-columnHeight-scbThickH+rowHeight*2)/rowHeight)-3
					DataTab.FromTo = {whichRowToStart > 0 and whichRowToStart or 1,whichRowToEnd <= rowCount and whichRowToEnd or rowCount}
					local _rowMoveOffset = math.floor(rowMoveOffset/rowHeight)*rowHeight
					local whichColumnToStart,whichColumnToEnd = -1,-1
					local cpos = {}
					local multiplier = columnRelt and (w-scbThickV) or 1
					local ypcolumn = cy+columnHeight
					local _y,_sx = ypcolumn+_rowMoveOffset,cx+w-scbThickV
					local column_x = columnOffset
					local allColumnWidth = columnData[columnCount][2]+columnData[columnCount][3]
					local scrollbar = eleData.scrollbars[2]
					local scrollPos = dgsElementData[scrollbar].position/100
					local mouseSelectColumn = -1
					local does = false
					for id,data in pairs(columnData) do
						cpos[id] = data[3]*multiplier
						if (data[3]+data[2])*multiplier-columnOffset >= scrollPos*allColumnWidth*multiplier then
							if (data[3]+data[2])*multiplier-scrollPos*allColumnWidth*multiplier <= w-scbThickV then
								whichColumnToStart = whichColumnToStart ~= -1 and whichColumnToStart or id
								whichColumnToEnd = whichColumnToEnd <= whichColumnToStart and whichColumnToStart or id
								whichColumnToEnd = id
								does = true
							end
						end
					end
					if not does then
						whichColumnToStart,whichColumnToEnd = columnCount,columnCount
					end
					column_x = cx-cpos[whichColumnToStart]+columnOffset
					for i=whichColumnToStart,whichColumnToEnd or columnCount do
						local data = columnData[i]
						local _columnTextColor = data[5] or columnTextColor
						local _columnTextColorCoded = data[6] or colorcoded
						local _columnTextSx,_columnTextSy = data[7] or columnTextSx,data[8] or columnTextSy
						local _columnFont = data[9] or font
						local column_sx = column_x+cpos[i]+data[2]*multiplier-scbThickV
						local posx = column_x+cpos[i]
						local tPosX = posx-posx%1
						if sortColumn == i and sortIcon then
							if DataTab.columnShadow then
								dxDrawText(sortIcon,tPosX+1-10,1+cy,column_sx,ypcolumn,black,_columnTextSx,_columnTextSy,_columnFont,"left","center",clip,false,rendSet,false,true)
							end
							dxDrawText(sortIcon,tPosX-10,cy,column_sx,ypcolumn,_columnTextColor,_columnTextSx,_columnTextSy,_columnFont,"left","center",clip,false,rendSet,false,true)
						end
						if DataTab.columnShadow then
							dxDrawText(data[1],1+tPosX,1+cy,column_sx,ypcolumn,black,_columnTextSx,_columnTextSy,_columnFont,data[4],"center",clip,false,rendSet,false,true)
						end
						dxDrawText(data[1],tPosX,cy,column_sx,ypcolumn,_columnTextColor,_columnTextSx,_columnTextSy,_columnFont,data[4],"center",clip,false,rendSet,false,true)
						if mouseInsideGridList and mouseSelectColumn == -1 then
							backgroundWidth = data[2]*multiplier
							if backgroundWidth+posx-x >= w or whichColumnToEnd == i then
								backgroundWidth = w-posx+x
							end
							local _tempStartx = posx
							local _tempEndx = _tempStartx+backgroundWidth
							if mx >= _tempStartx and mx <= _tempEndx then
								mouseSelectColumn = i
							end
						end
					end
					if MouseData.enter == v then		-------PreSelect
						if mouseInsideRow then
							local toffset = (whichRowToStart*rowHeight)+_rowMoveOffset
							sid = math.floor((my-cy-columnHeight-toffset)/rowHeight)+whichRowToStart+1
							if sid >= 1 and sid <= rowCount then
								DataTab.oPreSelect = sid
								if rowData[sid][-2] then
									DataTab.preSelect = {sid,mouseSelectColumn}
								else
									DataTab.preSelect = {-1,mouseSelectColumn}
								end
								MouseData.enterData = true
							else
								DataTab.preSelect = {-1,mouseSelectColumn}
							end
						elseif mouseInsideColumn then
							DataTab.selectedColumn = mouseSelectColumn
							DataTab.preSelect = {}
						else
							DataTab.preSelect = {-1,-1}
						end
					end
					local preSelect = DataTab.preSelect
					local Select = DataTab.rowSelect
					local sectionFont = eleData.sectionFont or font
					for i=DataTab.FromTo[1],DataTab.FromTo[2] do
						local lc_rowData = rowData[i]
						local image = lc_rowData[-3]
						local color = lc_rowData[0]
						local columnOffset = lc_rowData[-4]
						local isSection = lc_rowData[-5]
						local rowpos = i*rowHeight
						local _x,_y,_sx,_sy = column_x+columnOffset,_y+rowpos-rowHeight,_sx,_y+rowpos
						if eleData.PixelInt then
							_x,_y,_sx,_sy = _x-_x%1,_y-_y%1,_sx-_sx%1,_sy-_sy%1
						end
						local textBuffer = {}
						for id=whichColumnToStart,whichColumnToEnd do
							local text = lc_rowData[id][1]
							local _txtFont = isSection and sectionFont or (lc_rowData[id][6] or font)
							local _txtScalex = lc_rowData[id][4] or rowTextSx
							local _txtScaley = lc_rowData[id][5] or rowTextSy
							local rowState = 1
							if selectionMode == 1 then
								if i == preSelect[1] then
									rowState = 2
								end
								if Select[i] and Select[i][1] then
									rowState = 3
								end
							elseif selectionMode == 2 then
								if id == preSelect[2] then
									rowState = 2
								end
								if Select[1] and Select[1][id] then
									rowState = 3
								end
							elseif selectionMode == 3 then
								if i == preSelect[1] and id == preSelect[2] then
									rowState = 2
								end
								if Select[i] and Select[i][id] then
									rowState = 3
								end
							end
							local offset = cpos[id]
							local _x = _x+offset
							local _sx = cpos[id+1] or (columnData[id][2])*multiplier
							local backgroundWidth = columnData[id][2]*multiplier
							local _bgX = _x
							if id == 1 then
								_bgX = _x+DataTab.backgroundOffset
								backgroundWidth = backgroundWidth-DataTab.backgroundOffset
							elseif backgroundWidth+_x-x >= w or whichColumnToEnd == id then
								backgroundWidth = w-_x+x-scbThickV
							end
							if #image > 0 then
								dxDrawImage(_bgX,_y,backgroundWidth,rowHeight,image[rowState],0,0,0,color[rowState],rendSet)
							else
								dxDrawRectangle(_bgX,_y,backgroundWidth,rowHeight,color[rowState],rendSet)
							end
							if text ~= "" then
								local colorcoded = lc_rowData[id][3] == nil and colorcoded or lc_rowData[id][3]
								if lc_rowData[id][7] then
									local imageData = lc_rowData[id][7]
									if isElement(imageData[1]) then
										dxDrawImage(_x+imageData[3],_y+imageData[4],imageData[5],imageData[6],imageData[1],0,0,0,imageData[2])
									else
										dxDrawRectangle(_x+imageData[3],_y+imageData[4],imageData[5],imageData[6],imageData[2])
									end
								end
								textBuffer[id] = {lc_rowData[id][1],_x,_sx+_x,lc_rowData[id][2],_txtScalex,_txtScaley,_txtFont,clip,colorcoded,columnData[id][4]}
							end
						end
						for k,v in pairs(textBuffer) do
							local colorcoded = v[9]
							local text = v[1]
							if shadow then
								if colorcoded then
									text = text:gsub("#%x%x%x%x%x%x","") or text
								end
								dxDrawText(text,v[2]+shadow[1],_y+shadow[2],v[3]+shadow[1],_sy+shadow[2],shadow[3],v[5],v[6],v[7],v[10],"center",v[8],false,true,false,true)
							end
							dxDrawText(v[1],v[2],_y,v[3],_sy,v[4],v[5],v[6],v[7],v[10],"center",v[8],false,true,colorcoded,true)
						end
					end
				end
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					sideSize = applyColorAlpha(sideSize,galpha)
					local side = outlineData[1]
					local x,y = x-1,y-1
					if side == "in" then
						dxDrawLine(x,y+sideSize/2,x+w,y+sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x+sideSize/2,y,x+sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w-sideSize/2,y,x+w-sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+h-sideSize/2,x+w,y+h-sideSize/2,sideColor,sideSize,rendSet)
					elseif side == "center" then
						dxDrawLine(x-sideSize/2,y,x+w+sideSize/2,y,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+sideSize/2,x,y+h-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x+w,y+sideSize/2,x+w,y+h-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize/2,y+h,x+w+sideSize/2,y+h,sideColor,sideSize,rendSet)
					elseif side == "out" then
						dxDrawLine(x-sideSize,y-sideSize/2,x+w+sideSize,y-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize/2,y,x-sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w+sideSize/2,y,x+w+sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize,y+h+sideSize/2,x+w+sideSize,y+h+sideSize/2,sideColor,sideSize,rendSet)
					end
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if enabled then
					if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
						MouseData.hit = v
					end
				end
			else
				visible = false
			end
		elseif dxType == "dgs-dxprogressbar" then
			local x,y,cx,cy = processPositionOffset(v,x,y,w,h,parent,rndtgt,OffsetX,OffsetY)
			if x and y then
				if eleData.PixelInt then
					x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
				end
				local bgColor = eleData.bgColor
				local indicatorColor = eleData.indicatorColor
				bgColor = applyColorAlpha(bgColor,galpha)
				indicatorColor = applyColorAlpha(indicatorColor,galpha)
				local bgImage = eleData.bgImage
				local indicatorImage = eleData.indicatorImage
				local indicatorMode = eleData.indicatorMode
				local padding = eleData.padding
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if bgImage then
					dxDrawImage(x,y,w,h,bgImage,0,0,0,bgColor,rendSet)
				else
					dxDrawRectangle(x,y,w,h,bgColor,rendSet)
				end
				local percent = eleData.progress/100
				if isElement(indicatorImage) then
					local sx,sy = eleData.indicatorUVSize[1],eleData.indicatorUVSize[2]
					if indicatorMode then
						if not sx or not sy then
							sx,sy = dxGetMaterialSize(indicatorImage)
						end
						dxDrawImageSection(x+padding[1],y+padding[2],(w-padding[1]*2)*percent,h-padding[2]*2,1,1,sx*percent,sy,indicatorImage,0,0,0,indicatorColor,rendSet)
					else
						dxDrawImage(x+padding[1],y+padding[2],(w-padding[1]*2)*percent,h-padding[2]*2,indicatorImage,0,0,0,indicatorColor,rendSet)
					end
				else
					dxDrawRectangle(x+padding[1],y+padding[2],(w-padding[1]*2)*percent,h-padding[2]*2,indicatorColor,rendSet)
				end
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					sideSize = applyColorAlpha(sideSize,galpha)
					local side = outlineData[1]
					local x,y = x-1,y-1
					if side == "in" then
						dxDrawLine(x,y+sideSize/2,x+w,y+sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x+sideSize/2,y,x+sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w-sideSize/2,y,x+w-sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+h-sideSize/2,x+w,y+h-sideSize/2,sideColor,sideSize,rendSet)
					elseif side == "center" then
						dxDrawLine(x-sideSize/2,y,x+w+sideSize/2,y,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+sideSize/2,x,y+h-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x+w,y+sideSize/2,x+w,y+h-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize/2,y+h,x+w+sideSize/2,y+h,sideColor,sideSize,rendSet)
					elseif side == "out" then
						dxDrawLine(x-sideSize,y-sideSize/2,x+w+sideSize,y-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize/2,y,x-sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w+sideSize/2,y,x+w+sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize,y+h+sideSize/2,x+w+sideSize,y+h+sideSize/2,sideColor,sideSize,rendSet)
					end
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if enabled[1] and mx then
					if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
						MouseData.hit = v
					end
				end
			else
				visible = false
			end
		elseif dxType =="dgs-dxcombobox" then
			local x,y,cx,cy = processPositionOffset(v,x,y,w,h,parent,rndtgt,OffsetX,OffsetY)
			if x and y then
				if eleData.PixelInt then
					x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
				end
				local postgui = rendSet
				local colors,imgs = eleData.color,eleData.image
				local colorimgid = 1
				local textBox = eleData.textBox
				local buttonLen_t = eleData.buttonLen
				local buttonLen
				local bgColor = eleData.bgColor
				local bgImage = eleData.bgImage
				if textBox then
					buttonLen = buttonLen_t[2] and buttonLen_t[1]*h or buttonLen_t[1]
				else
					buttonLen = w
				end
				if MouseData.enter == v then
					colorimgid = 2
					if eleData.clickType == 1 then
						if MouseData.clickl == v then
							colorimgid = 3
						end
					elseif eleData.clickType == 2 then
						if MouseData.clickr == v then
							colorimgid = 3
						end
					else
						if MouseData.clickl == v or MouseData.clickr == v then
							colorimgid = 3
						end
					end
				end
				local finalcolor
				if not enabled[1] and not enabled[2] then
					if type(eleData.disabledColor) == "number" then
						finalcolor = applyColorAlpha(eleData.disabledColor,galpha)
					elseif eleData.disabledColor == true then
						local r,g,b,a = fromcolor(colors[1],true)
						local average = (r+g+b)/3*eleData.disabledColorPercent
						finalcolor = tocolor(average,average,average,a*galpha)
					else
						finalcolor = colors[colorimgid]
					end
				else
					finalcolor = applyColorAlpha(colors[colorimgid],galpha)
				end
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if imgs[colorimgid] then
					dxDrawImage(x+w-buttonLen,y,buttonLen,h,imgs[colorimgid],0,0,0,finalcolor,postgui)
				else
					dxDrawRectangle(x+w-buttonLen,y,buttonLen,h,finalcolor,postgui)
				end
				local arrowColor = eleData.arrowColor
				local arrowOutSideColor = eleData.arrowOutSideColor
				local textBoxLen = w-buttonLen
				if bgImage then
					dxDrawImage(x,y,textBoxLen,h,bgImage,0,0,0,applyColorAlpha(bgColor,galpha),postgui)
				else
					dxDrawRectangle(x,y,textBoxLen,h,applyColorAlpha(bgColor,galpha),postgui)
				end
				local shader = eleData.arrow
				local listState = eleData.listState
				if eleData.listStateAnim ~= listState then
					local stat = eleData.listStateAnim+eleData.listState*0.08
					eleData.listStateAnim = listState == -1 and math.max(stat,listState) or math.min(stat,listState)
				end
				if eleData.arrowSettings then
					dxSetShaderValue(shader,eleData.arrowSettings[1],eleData.arrowSettings[2]*eleData.listStateAnim)
				end
				local r,g,b,a = fromcolor(arrowColor,true)
				dxSetShaderValue(shader,"_color",{r/255,g/255,b/255,a/255*galpha})
				local r,g,b,a = fromcolor(arrowOutSideColor,true)
				dxSetShaderValue(shader,"ocolor",{r/255,g/255,b/255,a/255*galpha})
				dxDrawImage(x+textBoxLen,y,buttonLen,h,shader,0,0,0,white,postgui)
				if textBox then
					local textSide = eleData.comboTextSide
					local font = eleData.font or systemFont
					local textColor = eleData.textColor
					local rb = eleData.rightbottom
					local txtSizX,txtSizY = eleData.textSize[1],eleData.textSize[2] or eleData.textSize[1]
					local colorcoded = eleData.colorcoded
					local shadow = eleData.shadow
					local wordbreak = eleData.wordbreak
					local selection = eleData.select
					local itemData = eleData.itemData
					local sele = itemData[selection]
					local text = sele and sele[1] or eleData.caption
					local nx,ny,nw,nh = x+textSide[1],y,x+textBoxLen-textSide[2],y+h
					if shadow then
						dxDrawText(text:gsub("#%x%x%x%x%x%x",""),nx-shadow[1],ny-shadow[2],nw-shadow[1],nh-shadow[2],applyColorAlpha(shadow[3],galpha),txtSizX,txtSizY,font,rb[1],rb[2],clip,wordbreak,postgui)
					end
					dxDrawText(text,nx,ny,nw,nh,applyColorAlpha(textColor,galpha),txtSizX,txtSizY,font,rb[1],rb[2],clip,wordbreak,postgui,colorcoded)
				end
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					sideSize = applyColorAlpha(sideSize,galpha)
					local side = outlineData[1]
					local x,y = x-1,y-1
					if side == "in" then
						dxDrawLine(x,y+sideSize/2,x+w,y+sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x+sideSize/2,y,x+sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w-sideSize/2,y,x+w-sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+h-sideSize/2,x+w,y+h-sideSize/2,sideColor,sideSize,rendSet)
					elseif side == "center" then
						dxDrawLine(x-sideSize/2,y,x+w+sideSize/2,y,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+sideSize/2,x,y+h-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x+w,y+sideSize/2,x+w,y+h-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize/2,y+h,x+w+sideSize/2,y+h,sideColor,sideSize,rendSet)
					elseif side == "out" then
						dxDrawLine(x-sideSize,y-sideSize/2,x+w+sideSize,y-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize/2,y,x-sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w+sideSize/2,y,x+w+sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize,y+h+sideSize/2,x+w+sideSize,y+h+sideSize/2,sideColor,sideSize,rendSet)
					end
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if enabled[1] and mx then
					if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
						MouseData.hit = v
					end
				end
			else
				visible = false
			end
		elseif dxType == "dgs-dxcombobox-Box" then
			local combo = eleData.myCombo
			local x,y = dgsGetPosition(v,false,true)
			local w,h = eleData.absSize[1],eleData.absSize[2]
			local x,y,cx,cy = processPositionOffset(v,x,y,w,h,v,rndtgt,OffsetX,OffsetY)
			if x and y then
				if eleData.PixelInt then
					x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
				end
				local DataTab = dgsElementData[combo]
				local itemData = DataTab.itemData
				local scbThick = dgsElementData[combo].scrollBarThick
				local itemHeight = DataTab.itemHeight
				local itemMoveOffset = DataTab.itemMoveOffset
				local whichRowToStart = -math.floor((itemMoveOffset+itemHeight)/itemHeight)+1
				local whichRowToEnd = whichRowToStart+math.floor(h/itemHeight)+1
				DataTab.FromTo = {whichRowToStart > 0 and whichRowToStart or 1,whichRowToEnd <= #itemData and whichRowToEnd or #itemData}
				local renderTarget = dgsElementData[combo].renderTarget
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if isElement(renderTarget) then
					dxSetRenderTarget(renderTarget,true)
					local rb_l = dgsElementData[combo].rightbottomList
					local scrollbar = dgsElementData[combo].scrollbar
					local scbcheck = dgsElementData[scrollbar].visible and scbThick or 0
					if mx >= cx and mx <= cx+w-scbcheck and my >= cy and my <= cy+h then
						local toffset = (whichRowToStart*itemHeight)+itemMoveOffset
						sid = math.floor((my+2-cy-toffset)/itemHeight)+whichRowToStart+1
						if sid <= #itemData then
							DataTab.preSelect = sid
							MouseData.enterData = true
						else
							DataTab.preSelect = -1
						end
					else
						DataTab.preSelect = -1
					end
					local preSelect = DataTab.preSelect
					local Select = DataTab.select
					local font = DataTab.font
					local shadow = dgsElementData[combo].shadow
					local colorcoded = eleData.colorcoded
					local wordbreak = eleData.wordbreak
					local clip = eleData.clip
					local textSide = dgsElementData[combo].itemTextSide
					for i=DataTab.FromTo[1],DataTab.FromTo[2] do
						local lc_rowData = itemData[i]
						local textSize = lc_rowData[-3]
						local textColor = lc_rowData[-2]
						local image = lc_rowData[-1]
						local color = lc_rowData[0]
						local itemState = 1
						if i == preSelect then
							itemState = 2
						end
						if i == Select then
							itemState = 3
						end
						local rowpos = i*itemHeight
						local rowpos_1 = (i-1)*itemHeight
						if image[itemState] then
							dxDrawImage(0,rowpos_1+itemMoveOffset,w,itemHeight,image[itemState],0,0,0,color[itemState])
						else
							dxDrawRectangle(0,rowpos_1+itemMoveOffset,w,itemHeight,color[itemState])
						end
						local _y,_sx,_sy = rowpos_1+itemMoveOffset,sW-textSide[2],rowpos+itemMoveOffset
						local text = itemData[i][1]
						if shadow then
							dxDrawText(text:gsub("#%x%x%x%x%x%x",""),textSide[1]-shadow[1],_y-shadow[2],_sx-shadow[1],_sy-shadow[2],shadow[3],textSize[1],textSize[2],font,rb_l[1],rb_l[2],clip,wordbreak)
						end
						dxDrawText(text,textSide[1],_y,_sx,_sy,textColor,textSize[1],textSize[2],font,rb_l[1],rb_l[2],clip,wordbreak,false,colorcoded)
					end
					dxSetRenderTarget()
					dxDrawImage(x,y,w,h,renderTarget,0,0,0,tocolor(255,255,255,255*galpha),rendSet)
				end
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					sideSize = applyColorAlpha(sideSize,galpha)
					local side = outlineData[1]
					local x,y = x-1,y-1
					if side == "in" then
						dxDrawLine(x,y+sideSize/2,x+w,y+sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x+sideSize/2,y,x+sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w-sideSize/2,y,x+w-sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+h-sideSize/2,x+w,y+h-sideSize/2,sideColor,sideSize,rendSet)
					elseif side == "center" then
						dxDrawLine(x-sideSize/2,y,x+w+sideSize/2,y,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+sideSize/2,x,y+h-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x+w,y+sideSize/2,x+w,y+h-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize/2,y+h,x+w+sideSize/2,y+h,sideColor,sideSize,rendSet)
					elseif side == "out" then
						dxDrawLine(x-sideSize,y-sideSize/2,x+w+sideSize,y-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize/2,y,x-sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w+sideSize/2,y,x+w+sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize,y+h+sideSize/2,x+w+sideSize,y+h+sideSize/2,sideColor,sideSize,rendSet)
					end
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if enabled[1] and mx then
					local height = #itemData*itemHeight
					if height > h then
						height = h
					end
					if mx >= cx and mx<= cx+w and my >= cy and my <= cy+height then
						MouseData.hit = v
					end
				end
			else
				visible = false
			end
		elseif dxType == "dgs-dxtabpanel" then
			local x,y,cx,cy = processPositionOffset(v,x,y,w,h,parent,rndtgt,OffsetX,OffsetY)
			if x and y then
				if eleData.PixelInt then
					x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
				end
				local tabHeight,relat = eleData["tabHeight"][1],eleData["tabHeight"][2]
				local tabHeight = relat and tabHeight*y or tabHeight
				eleData.rndPreSelect = -1
				local selected = eleData["selected"]
				local tabs = eleData["tabs"]
				local height = eleData["tabHeight"][2] and eleData["tabHeight"][1]*h or eleData["tabHeight"][1]
				local bgColor = eleData.bgColor
				local font = eleData.font or systemFont
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if enabled[1] and mx then
					if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
						MouseData.hit = v
					end
				end
				if selected == -1 then
					dxDrawRectangle(x,y+height,w,h-height,eleData.bgColor,rendSet)
				else
					local rendt = eleData.renderTarget
					if isElement(rendt) then
						dxSetRenderTarget(rendt,true)
						local tabSideSize = eleData.tabSideSize[2] and eleData.tabSideSize[1]*w or eleData.tabSideSize[1]
						local tabsize = -eleData.taboffperc*(dgsTabPanelGetWidth(v)-w)
						local gap = eleData.tabGapSize[2] and eleData.tabGapSize[1]*w or eleData.tabGapSize[1]
						if eleData.PixelInt then
							x,y,w,height = x-x%1,y-y%1,w-w%1,height-height%1
						end
						for d,t in ipairs(tabs) do
							if dgsElementData[t].visible then
								local width = dgsElementData[t].width+tabSideSize*2
								local _width = 0
								if tabs[d+1] then
									_width = dgsElementData[tabs[d+1]].width+tabSideSize*2
								end
								if tabsize+width >= 0 and tabsize <= w then
									local tabImage = dgsElementData[t].tabImage
									local tabColor = dgsElementData[t].tabColor
									local selectstate = 1
									if selected == d then
										selectstate = 3
									elseif eleData.preSelect == d then
										selectstate = 2
									end
									local finalcolor
									if not enabled[2] then
										if type(eleData.disabledColor) == "number" then
											finalcolor = applyColorAlpha(eleData.disabledColor,galpha)
										elseif eleData.disabledColor == true then
											local r,g,b,a = fromcolor(tabColor[1],true)
											local average = (r+g+b)/3*eleData.disabledColorPercent
											finalcolor = tocolor(average,average,average,a*galpha)
										else
											finalcolor = tabColor[selectstate]
										end
									else
										finalcolor = applyColorAlpha(tabColor[selectstate],galpha)
									end
									if tabImage[selectstate] then
										dxDrawImage(tabsize,0,width,height,tabImage[selectstate],0,0,0,finalcolor)
									else
										dxDrawRectangle(tabsize,0,width,height,finalcolor)
									end
									local textSize = dgsElementData[t].textSize
									if eleData.PixelInt then
										_tabsize,_width = tabsize-tabsize%1,math.floor(width+tabsize)
									end
									dxDrawText(dgsElementData[t].text,_tabsize,0,_width,height,dgsElementData[t].textColor,textSize[1],textSize[2],font,"center","center",false,false,false,colorcoded,true)
									if mx >= tabsize+x and mx <= tabsize+x+width and my > y and my < y+height and dgsElementData[t].enabled and enabled[2] then
										eleData.rndPreSelect = d
										MouseData.hit = t
									end
								end
								tabsize = tabsize+width+gap
							end
						end
						eleData.preSelect = -1
						dxSetRenderTarget()
						dxDrawImage(x,y,w,height,rendt,0,0,0,applyColorAlpha(white,galpha),rendSet)
						local colors = applyColorAlpha(dgsElementData[tabs[selected]].bgColor,galpha)
						if dgsElementData[tabs[selected]].bgImage then
							dxDrawImage(x,y+height,w,h-height,dgsElementData[tabs[selected]].bgImage,0,0,0,colors,rendSet)
						else
							dxDrawRectangle(x,y+height,w,h-height,colors,rendSet)
						end
						for cid,child in ipairs(dgsGetChildren(tabs[selected])) do
							renderGUI(child,mx,my,enabled,rndtgt,OffsetX,OffsetY,galpha,visible)
						end
					end
				end
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					sideSize = applyColorAlpha(sideSize,galpha)
					local side = outlineData[1]
					local x,y = x-1,y-1
					if side == "in" then
						dxDrawLine(x,y+sideSize/2,x+w,y+sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x+sideSize/2,y,x+sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w-sideSize/2,y,x+w-sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+h-sideSize/2,x+w,y+h-sideSize/2,sideColor,sideSize,rendSet)
					elseif side == "center" then
						dxDrawLine(x-sideSize/2,y,x+w+sideSize/2,y,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+sideSize/2,x,y+h-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x+w,y+sideSize/2,x+w,y+h-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize/2,y+h,x+w+sideSize/2,y+h,sideColor,sideSize,rendSet)
					elseif side == "out" then
						dxDrawLine(x-sideSize,y-sideSize/2,x+w+sideSize,y-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize/2,y,x-sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w+sideSize/2,y,x+w+sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize,y+h+sideSize/2,x+w+sideSize,y+h+sideSize/2,sideColor,sideSize,rendSet)
					end
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
			else
				visible = false
			end
		elseif dxType == "dgs-dxbrowser" then
			local x,y,cx,cy = processPositionOffset(v,x,y,w,h,parent,rndtgt,OffsetX,OffsetY)
			if x and y then
				if eleData.PixelInt then
					x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
				end
				local color = applyColorAlpha(eleData.color,galpha)
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						text = fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				dxDrawImage(x,y,w,h,v,0,0,0,color,rendSet)
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					sideSize = applyColorAlpha(sideSize,galpha)
					local side = outlineData[1]
					local x,y = x-1,y-1
					if side == "in" then
						dxDrawLine(x,y+sideSize/2,x+w,y+sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x+sideSize/2,y,x+sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w-sideSize/2,y,x+w-sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+h-sideSize/2,x+w,y+h-sideSize/2,sideColor,sideSize,rendSet)
					elseif side == "center" then
						dxDrawLine(x-sideSize/2,y,x+w+sideSize/2,y,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+sideSize/2,x,y+h-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x+w,y+sideSize/2,x+w,y+h-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize/2,y+h,x+w+sideSize/2,y+h,sideColor,sideSize,rendSet)
					elseif side == "out" then
						dxDrawLine(x-sideSize,y-sideSize/2,x+w+sideSize,y-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize/2,y,x-sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w+sideSize/2,y,x+w+sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize,y+h+sideSize/2,x+w+sideSize,y+h+sideSize/2,sideColor,sideSize,rendSet)
					end
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if enabled[1] and mx then
					if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
						MouseData.hit = v
					end
				end
			else
				visible = false
			end
		elseif dxType == "dgs-dxcmd" then
			local x,y,cx,cy = processPositionOffset(v,x,y,w,h,parent,rndtgt,OffsetX,OffsetY)
			if x and y then
				if eleData.PixelInt then
					x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
				end
				local colors,imgs = eleData.bgColor,eleData.bgImage
				colors = applyColorAlpha(colors,galpha)
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if imgs then
					dxDrawImage(x,y,w,h,imgs,0,0,0,colors,rendSet)
				else
					dxDrawRectangle(x,y,w,h,colors,rendSet)
				end
				local hangju,cmdtexts = eleData.hangju,eleData.texts or {}
				local canshow = math.floor(h/eleData.hangju)-1
				local rowoffset = 0
				local readyToRenderTable = {}
				local font = eleData.font
				local txtSizX,txtSizY = eleData.textSize[1],eleData.textSize[2] or eleData.textSize[1]
				for i=1,#cmdtexts do
					local movex = 0
					local rndStr = ""
					for key,letter in ipairs(cmdtexts[i]) do
						rndStr = rndStr..letter
						local width = dxGetTextWidth(letter,txtSizX,font)
						movex = movex+width
						if movex+25 >= w then
							table.insert(readyToRenderTable,1,rndStr)
							rndStr = ""
							movex = 0
						end
					end
					table.insert(readyToRenderTable,1,rndStr)
					if #readyToRenderTable >= canshow then
						break
					end
				end
				for i=#readyToRenderTable,1,-1 do
					local width = dxGetTextWidth(readyToRenderTable[i],txtSizX,font)
					dxDrawText(readyToRenderTable[i],x+5,y+(i-1)*hangju,x+width+5,y+i*hangju,white,txtSizX,txtSizY,font,"left","bottom",false,true,rendSet)
				end
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					sideSize = applyColorAlpha(sideSize,galpha)
					local side = outlineData[1]
					local x,y = x-1,y-1
					if side == "in" then
						dxDrawLine(x,y+sideSize/2,x+w,y+sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x+sideSize/2,y,x+sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w-sideSize/2,y,x+w-sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+h-sideSize/2,x+w,y+h-sideSize/2,sideColor,sideSize,rendSet)
					elseif side == "center" then
						dxDrawLine(x-sideSize/2,y,x+w+sideSize/2,y,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+sideSize/2,x,y+h-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x+w,y+sideSize/2,x+w,y+h-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize/2,y+h,x+w+sideSize/2,y+h,sideColor,sideSize,rendSet)
					elseif side == "out" then
						dxDrawLine(x-sideSize,y-sideSize/2,x+w+sideSize,y-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize/2,y,x-sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w+sideSize/2,y,x+w+sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize,y+h+sideSize/2,x+w+sideSize,y+h+sideSize/2,sideColor,sideSize,rendSet)
					end
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if enabled[1] and mx then
					if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
						MouseData.hit = v
					end
				end
			else
				visible = false
			end
		elseif dxType == "dgs-dx3dinterface" then
			local pos = eleData.position
			local size = eleData.size
			local faceTo = eleData.faceTo
			local x,y,z,w,h,fx,fy,fz = pos[1],pos[2],pos[3],size[1],size[2],faceTo[1],faceTo[2],faceTo[3]
			rndtgt = eleData.renderTarget_parent
			if x and y and z and w and h then
				local intfaceHit = eleData.hit
				local hit,hitX,hitY
				if intfaceHit then
					hit,hitX,hitY,x,y,z = intfaceHit[1],intfaceHit[2],intfaceHit[3],intfaceHit[4],intfaceHit[5]
				end
				dxSetRenderTarget(rndtgt,true)
				dxSetRenderTarget()
				if enabled[1] and mx then
					if hit then
						local oldPos = MouseData.interfaceHit
						local distance = eleData.cameraDistance
						if isElement(MouseData.lock3DInterface) then
							if MouseData.lock3DInterface == v then
								MouseData.hit = v
								mx,my = hitX*eleData.resolution[1],hitY*eleData.resolution[2]
								MouseX,MouseY = mx,my
								MouseData.interfaceHit = {x,y,z,distance,v}
							end
						elseif not oldPos[4] or distance <= oldPos[4] then
							MouseData.hit = v
							mx,my = hitX*eleData.resolution[1],hitY*eleData.resolution[2]
							MouseX,MouseY = mx,my
							MouseData.interfaceHit = {x,y,z,distance,v}
						end
					end
				end
			else
				visible = false
			end
		elseif dxType == "dgs-dxarrowlist" then
			local x,y,cx,cy = processPositionOffset(v,x,y,w,h,parent,rndtgt,OffsetX,OffsetY)
			if eleData.configNextFrame then
				configArrowList(v)
				dgsSetData(v,"configNextFrame",false)
			end
			if x and y then
				if eleData.PixelInt then
					x,y,w,h = x-x%1,y-y%1,w-w%1,h-h%1
				end
				local color = applyColorAlpha(eleData.bgColor,galpha)
				------------------------------------
				if eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						text = fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				local rendTarget = eleData.renderTarget
				if isElement(eleData.bgImage) then
					dxDrawImage(x,y,h,w,eleData.bgImage,0,0,0,color,rendSet)
				else
					dxDrawRectangle(x,y,w,h,color,rendSet)
				end
				local sid
				local itemData = eleData.itemData
				if not eleData.mode then
					dxSetRenderTarget(rendTarget,true)
					local leading = eleData.leading
					local itemHeight = eleData.itemHeight
					local itemMoveOffset = eleData.itemMoveOffset
					local whichRowToStart = -math.floor((itemMoveOffset+itemHeight+leading)/itemHeight)+1
					local whichRowToEnd = whichRowToStart+math.floor(h/(itemHeight+leading))+1
					eleData.FromTo = {whichRowToStart > 0 and whichRowToStart or 1,whichRowToEnd <= #itemData and whichRowToEnd or #itemData}
					local scbThick = eleData.scrollBarThick
					local scrollbar = eleData.scrollbar
					local scbcheck = eleData.visible and scbThick or 0
					if mx >= cx and mx <= cx+w-scbcheck and my >= cy and my <= cy+h then
						local toffset = (whichRowToStart*itemHeight+(whichRowToStart-1)*leading)+itemMoveOffset
						local mouseTemp = (my-cy-toffset)
						sid = math.floor(mouseTemp/(itemHeight+leading))+whichRowToStart+1
						if sid <= #itemData and my-cy > (sid-1)*(itemHeight+leading)+itemMoveOffset then
							eleData.select = sid
							MouseData.enterData = true
						else
							eleData.select = -1
						end
					else
						eleData.select = -1
					end
					local arrowListSelect = eleData.select
					local rndtgtWidth = w - scbcheck
					for i=eleData.FromTo[1],eleData.FromTo[2] do
						local iData = itemData[i]
						local iConfig = iData[7]
						local itemY = itemMoveOffset+(i-1)*(itemHeight+leading)
						local colorImgID = arrowListSelect == i and 2 or 1
						if iConfig[2][colorImgID] then
							dxDrawImage(0,itemY,rndtgtWidth,itemHeight,iConfig[2][colorImgID],0,0,0,iConfig[1][colorImgID],false)
						else
							dxDrawRectangle(0,itemY,rndtgtWidth,itemHeight,iConfig[1][colorImgID],false)
						end
						if iConfig[8] then
							dxDrawText(iData[1],iConfig[7],itemY,rndtgtWidth,itemY+itemHeight,tocolor(0,0,0,255),iConfig[4][1],iConfig[4][2],iConfig[11],iConfig[6],"center")
						end
						dxDrawText(iData[1],iConfig[7],itemY,rndtgtWidth,itemY+itemHeight,iConfig[3],iConfig[4][1],iConfig[4][2],iConfig[11],iConfig[6],"center")
						local operatorLen = dxGetTextWidth("<",iConfig[4][1],"default-bold")
						if iConfig[12] == "right" then
							local currentSelected = iData[6]
							if iData[5] and iData[5][currentSelected] then
								currentSelected = iData[5][currentSelected]
							end
							local textLength = iConfig[14] or dxGetTextWidth(currentSelected,iConfig[10][1],iConfig[11])
							local initialXPos = rndtgtWidth-iConfig[13]-operatorLen
							local distance = iConfig[16]
							local selectorR_sx,selectorR_ex = initialXPos,initialXPos+operatorLen
							local selectorL_sx,selectorL_ex = initialXPos-textLength-operatorLen-distance*2,initialXPos-textLength-distance*2
							local selectorText_sx,selectorText_ex = initialXPos-textLength-distance,initialXPos-distance
							local selectStateL,selectStateR = 1,1
							if eleData.select == i then
								local mouseX,mouseY = mx-cx,my-cy
								if mouseX > selectorL_sx and mouseX < selectorL_ex then
									selectStateL = 2
									MouseData.arrowListEnter = {v,i,"left"}
									if eleData.arrowListClick and eleData.arrowListClick[1] == i and eleData.arrowListClick[2] == "left" then
										selectStateL = 3
									end
								elseif mouseX > selectorR_sx and mouseX < selectorR_ex then
									selectStateR = 2
									MouseData.arrowListEnter = {v,i,"right"}
									if eleData.arrowListClick and eleData.arrowListClick[1] == i and eleData.arrowListClick[2] == "right" then
										selectStateR = 3
									end
								else
									MouseData.arrowListEnter = {v,i}
								end
							end
							local selectorColorLeft = iConfig[9][selectStateL]
							local selectorColorRight = iConfig[9][selectStateR]
							dxDrawText(">",selectorR_sx,itemY,selectorR_ex,itemY+itemHeight,selectorColorRight,iConfig[4][1],iConfig[4][2],"default-bold","center","center")
							dxDrawText(currentSelected,selectorText_sx,itemY,selectorText_ex,itemY+itemHeight,iConfig[17],iConfig[4][1],iConfig[4][2],iConfig[11],"center","center")
							dxDrawText("<",selectorL_sx,itemY,selectorL_ex,itemY+itemHeight,selectorColorLeft,iConfig[4][1],iConfig[4][2],"default-bold","center","center")
						elseif iConfig[12] == "left" then
							
						end
					end
					dxSetRenderTarget()
					dxDrawImage(x,y,rndtgtWidth,h,rendTarget,0,0,0,tocolor(255,255,255,galpha*255),rendSet)
				else
				
				end
				------------------------------------OutLine
				local outlineData = eleData.outline
				if outlineData then
					local sideColor = outlineData[3]
					local sideSize = outlineData[2]
					sideSize = applyColorAlpha(sideSize,galpha)
					local side = outlineData[1]
					local x,y = x-1,y-1
					if side == "in" then
						dxDrawLine(x,y+sideSize/2,x+w,y+sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x+sideSize/2,y,x+sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w-sideSize/2,y,x+w-sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+h-sideSize/2,x+w,y+h-sideSize/2,sideColor,sideSize,rendSet)
					elseif side == "center" then
						dxDrawLine(x-sideSize/2,y,x+w+sideSize/2,y,sideColor,sideSize,rendSet)
						dxDrawLine(x,y+sideSize/2,x,y+h-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x+w,y+sideSize/2,x+w,y+h-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize/2,y+h,x+w+sideSize/2,y+h,sideColor,sideSize,rendSet)
					elseif side == "out" then
						dxDrawLine(x-sideSize,y-sideSize/2,x+w+sideSize,y-sideSize/2,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize/2,y,x-sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x+w+sideSize/2,y,x+w+sideSize/2,y+h,sideColor,sideSize,rendSet)
						dxDrawLine(x-sideSize,y+h+sideSize/2,x+w+sideSize,y+h+sideSize/2,sideColor,sideSize,rendSet)
					end
				end
				------------------------------------
				if not eleData.functionRunBefore then
					local fnc = eleData.functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
				end
				------------------------------------
				if enabled[1] and mx then
					if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
						MouseData.hit = v
					end
				end
			else
				visible = false
			end
		else
			interrupted = true
		end
		if eleData.renderEventCall then
			triggerEvent("onDgsElementRender",v,x,y,w,h)
		end
		if not eleData.hitoutofparent then
			if MouseData.hit ~= v then
				enabled[1] = false
			end
		end
		if not interrupted then
			for i=1,#children do
				local child = children[i]
				isElementInside = isElementInside or renderGUI(child,mx,my,enabled,rndtgt,OffsetX,OffsetY,galpha,visible,checkElement)
			end
		end
	end
	return isElementInside or v == checkElement
end
addEventHandler("onClientRender",root,dgsCoreRender,false,dgsRenderSetting.renderPriority)

function removeColorCodeFromString(str)
	repeat
		local temp = str
		str = string.gsub(str,'#%x%x%x%x%x%x','')
		if str == temp then
			return temp
		end
	until(false)
end

ccax = 0
function processPositionOffset(gui,x,y,w,h,parent,rndtgt,offsetx,offsety)
	local ax,ay = getParentLocation(gui,true,dgsElementData[gui].absPos[1],dgsElementData[gui].absPos[2])
	local cx,cy = getParentLocation(gui,false,dgsElementData[gui].absPos[1],dgsElementData[gui].absPos[2])
	x,y = rndtgt and ax or x,rndtgt and ay or y
	local P_dgsType = dgsElementType[parent]
	if P_dgsType == "dgs-dxscrollpane" then
		local psiz = dgsElementData[parent].absSize
		local siz = dgsElementData[gui].absSize
		local psx,psy,sx,sy = psiz[1],psiz[2],siz[1],siz[2]
		if x > psx-offsetx or y > psy-offsety or x+sx < -offsetx or y+sy < -offsety then
			ccax = ccax+1
			return false,false
		end
	end
	local hasParent = isElement(parent)
	if dgsElementData[gui].lor == "right" then
		local px,psx = 0,sW
		if hasParent then
			px = dgsElementData[parent].absPos[1]
			psx = dgsElementData[parent].absSize[1]
		end
		x = px*2+psx-x
	end
	if dgsElementData[gui].tob == "bottom" then
		local py,psy = 0,sH
		if hasParent then
			if P_dgsType == "dgs-dxtab" then
				local tabpanel = dgsElementData[parent].parent
				local height = dgsElementData[tabpanel].tabHeight[2] and dgsElementData[tabpanel].tabHeight[1]*psx or dgsElementData[tabpanel].tabHeight[1]
				psy = dgsElementData[tabpanel].absSize[2]-height
				py = dgsElementData[parent].absPos[2]+height
			else
				py = dgsElementData[parent].absPos[2]
				psy = dgsElementData[parent].absSize[2]
			end
		end
		y = py*2+psy-y
	end
	return x+offsetx,y+offsety,(rndtgt and cx or x)+offsetx,(rndtgt and cy or y)+offsety
end

function onClientKeyCheck(button,state)
	if button == "mouse_wheel_up" or button == "mouse_wheel_down" then
		local dgsType = dgsGetType(MouseData.enter)
		if isElement(MouseData.enter) then
			triggerEvent("onDgsMouseWheel",MouseData.enter,button == "mouse_wheel_down" and -1 or 1)
		end
		local scroll = button == "mouse_wheel_down" and 1 or -1
		local scrollbar = MouseData.enter
		if dgsGetType(scrollbar) == "dgs-dxscrollbar" then
			scrollScrollBar(scrollbar,button == "mouse_wheel_down" or false)
		elseif dgsType == "dgs-dxgridlist" then
			if MouseData.enterData then
				local scrollbar
				local scrollbar1,scrollbar2 = dgsElementData[MouseData.enter].scrollbars[1],dgsElementData[MouseData.enter].scrollbars[2]
				local visibleScb1,visibleScb2 = dgsGetVisible(scrollbar1),dgsGetVisible(scrollbar2)
				if visibleScb1 and not visibleScb2 then
					scrollbar = scrollbar1
				elseif visibleScb2 and not visibleScb1 then
					scrollbar = scrollbar2
				elseif visibleScb1 and visibleScb2 then
					local whichScrollBar = dgsElementData[MouseData.enter].mouseWheelScrollBar and 2 or 1
					scrollbar = dgsElementData[MouseData.enter].scrollbars[whichScrollBar]
				end
				if scrollbar then
					scrollScrollBar(scrollbar,button == "mouse_wheel_down" or false)
				end
			end
		elseif dgsType == "dgs-dxmemo" then
			local scrollbar = dgsElementData[MouseData.enter].scrollbars[1]
			if dgsGetVisible(scrollbar) then
				scrollScrollBar(scrollbar,button == "mouse_wheel_down" or false)
			end
		elseif isElement(MouseData.scrollPane) then
			local scrollbar
			local scrollbar1,scrollbar2 = dgsElementData[MouseData.scrollPane].scrollbars[1],dgsElementData[MouseData.scrollPane].scrollbars[2]
			local visibleScb1,visibleScb2 = dgsGetVisible(scrollbar1),dgsGetVisible(scrollbar2)
			if visibleScb1 and not visibleScb2 then
				scrollbar = scrollbar1
			elseif visibleScb2 and not visibleScb1 then
				scrollbar = scrollbar2
			elseif visibleScb1 and visibleScb2 then
				local whichScrollBar = dgsElementData[MouseData.scrollPane].mouseWheelScrollBar and 2 or 1
				scrollbar = dgsElementData[MouseData.scrollPane].scrollbars[whichScrollBar]
			end
			if scrollbar then
				scrollScrollBar(scrollbar,button == "mouse_wheel_down" or false)
			end
		elseif dgsType == "dgs-dxtabpanel" or dgsType == "dgs-dxtab" then
			local tabpanel = MouseData.enter
			if dgsType == "dgs-dxtab" then
				tabpanel = dgsElementData[MouseData.enter].parent
			end
			local width = dgsTabPanelGetWidth(tabpanel)
			local w,h = dgsElementData[tabpanel].absSize[1],dgsElementData[tabpanel].absSize[2]
			if width > w then
				local mx,my = getCursorPosition()
				mx,my = (mx or -1)*sW,(my or -1)*sH
				local _,y = dgsGetPosition(tabpanel,false,true)
				local height = dgsElementData[tabpanel].tabHeight[2] and dgsElementData[tabpanel].tabHeight[1]*h or dgsElementData[tabpanel].tabHeight[1]
				if my < y+height then
					local speed = dgsElementData[tabpanel].scrollSpeed[2] and dgsElementData[tabpanel].scrollSpeed[1] or dgsElementData[tabpanel].scrollSpeed[1]/width
					local orgoff = dgsElementData[tabpanel].taboffperc
					orgoff = math.restrict(0,1,orgoff+scroll*speed)
					dgsSetData(tabpanel,"taboffperc",orgoff)
				end
			end
		elseif dgsType == "dgs-dxcombobox-Box" then
			local combo = dgsElementData[MouseData.enter].myCombo
			local scrollbar = dgsElementData[combo].scrollbar
			if dgsGetVisible(scrollbar) then
				scrollScrollBar(scrollbar,button == "mouse_wheel_down" or false)
			end
		elseif dgsType == "dgs-dxarrowlist" then
			local scrollbar = dgsElementData[MouseData.enter].scrollbar
			if dgsGetVisible(scrollbar) then
				scrollScrollBar(scrollbar,button == "mouse_wheel_down" or false)
			end
		end
	end
	if dgsGetType(MouseData.nowShow) == "dgs-dxedit" then
		local edit = dgsElementData[MouseData.nowShow].edit
		local text = guiGetText(edit)
		if state then
			local cmd = dgsElementData[MouseData.nowShow].mycmd
			local shift = getKeyState("lshift") or getKeyState("rshift")
			if button == "arrow_l" then
				dgsEditMoveCaret(MouseData.nowShow,-1,shift)
				if isTimer(MouseData.Timer["editMove"]) then
					killTimer(MouseData.Timer["editMove"])
				end
				if isTimer(MouseData.Timer["editMoveDelay"]) then
					killTimer(MouseData.Timer["editMoveDelay"])
				end
				MouseData.Timer["editMoveDelay"] = setTimer(function()
					if dgsGetType(MouseData.nowShow) == "dgs-dxedit" then
						MouseData.Timer["editMove"] = setTimer(function()
							local shift = getKeyState("lshift") or getKeyState("rshift")
							if dgsGetType(MouseData.nowShow) == "dgs-dxedit" then
								dgsEditMoveCaret(MouseData.nowShow,-1,shift)
								MouseData.editCursorMoveOffset = -1
							else
								killTimer(MouseData.Timer["editMove"])
							end
						end,50,0)
					end
				end,500,1)
			elseif button == "arrow_r" then
				dgsEditMoveCaret(MouseData.nowShow,1,shift)
				if isTimer(MouseData.Timer["editMove"]) then
					killTimer(MouseData.Timer["editMove"])
				end
				if isTimer(MouseData.Timer["editMoveDelay"]) then
					killTimer(MouseData.Timer["editMoveDelay"])
				end
				MouseData.Timer["editMoveDelay"] = setTimer(function()
					if dgsGetType(MouseData.nowShow) == "dgs-dxedit" then
						MouseData.Timer["editMove"] = setTimer(function()
							if dgsGetType(MouseData.nowShow) == "dgs-dxedit" then
							local shift = getKeyState("lshift") or getKeyState("rshift")
								dgsEditMoveCaret(MouseData.nowShow,1,shift)
								MouseData.editCursorMoveOffset = 1
							else
								killTimer(MouseData.Timer["editMove"])
							end
						end,50,0)
					end
				end,500,1)
			elseif button == "arrow_u" then
				if dgsGetType(cmd) == "dgs-dxcmd" then
					local int = dgsElementData[cmd].cmdCurrentHistory
					local history = dgsElementData[cmd].cmdHistory
					if history[int+1] then
						int = int+1
						dgsSetData(cmd,"cmdCurrentHistory",int)
						dgsSetText(MouseData.nowShow,history[int])
						dgsEditSetCaretPosition(MouseData.nowShow,#history[int])
					end
				end
			elseif button == "arrow_d" then
				if dgsGetType(cmd) == "dgs-dxcmd" then
					local int = dgsElementData[cmd].cmdCurrentHistory
					local history = dgsElementData[cmd].cmdHistory
					if history[int-1] then
						int = int-1
						dgsSetData(cmd,"cmdCurrentHistory",int)
						dgsSetText(MouseData.nowShow,history[int])
						dgsEditSetCaretPosition(MouseData.nowShow,#history[int])
					end
				end
			elseif button == "home" then
				dgsEditSetCaretPosition(MouseData.nowShow,0,getKeyState("lshift") or getKeyState("rshift"))
			elseif button == "end" then
				dgsEditSetCaretPosition(MouseData.nowShow,#text,getKeyState("lshift") or getKeyState("rshift"))
			elseif button == "tab" then
				cancelEvent()
				triggerEvent("onDgsEditPreSwitch",MouseData.nowShow)
				if isTimer(MouseData.Timer["editMove"]) then
					killTimer(MouseData.Timer["editMove"])
				end
				if isTimer(MouseData.Timer["editMoveDelay"]) then
					killTimer(MouseData.Timer["editMoveDelay"])
				end
				MouseData.Timer["editMoveDelay"] = setTimer(function()
					if dgsGetType(MouseData.nowShow) == "dgs-dxedit" then
						MouseData.Timer["editMove"] = setTimer(function()
							if dgsGetType(MouseData.nowShow) == "dgs-dxedit" then
								triggerEvent("onDgsEditPreSwitch",MouseData.nowShow)
							else
								killTimer(MouseData.Timer["editMove"])
							end
						end,50,0)
					end
				end,500,1)
			end
		else
			if button == "arrow_l" or button == "arrow_r" or button == "tab" then
				if isTimer(MouseData.Timer["editMove"]) then
					killTimer(MouseData.Timer["editMove"])
				end
				if isTimer(MouseData.Timer["editMoveDelay"]) then
					killTimer(MouseData.Timer["editMoveDelay"])
				end
				MouseData.editCursorMoveOffset = false
			end
		end
	elseif dgsGetType(MouseData.nowShow) == "dgs-dxmemo" then
		if state then
			local cmd = dgsElementData[MouseData.nowShow].mycmd
			local shift = getKeyState("lshift") or getKeyState("rshift")
			if button == "arrow_l" then
				dgsMemoMoveCaret(MouseData.nowShow,-1,0,shift)
				if isTimer(MouseData.Timer["memoMove"]) then
					killTimer(MouseData.Timer["memoMove"])
				end
				if isTimer(MouseData.Timer["memoMoveDelay"]) then
					killTimer(MouseData.Timer["memoMoveDelay"])
				end
				MouseData.Timer["memoMoveDelay"] = setTimer(function()
					if dgsGetType(MouseData.nowShow) == "dgs-dxmemo" then
						MouseData.Timer["memoMove"] = setTimer(function()
							local shift = getKeyState("lshift") or getKeyState("rshift")
							if dgsGetType(MouseData.nowShow) == "dgs-dxmemo" then
								dgsMemoMoveCaret(MouseData.nowShow,-1,0,shift)
							else
								killTimer(MouseData.Timer["memoMove"])
							end
						end,50,0)
					end
				end,500,1)
			elseif button == "arrow_r" then
				dgsMemoMoveCaret(MouseData.nowShow,1,0,shift)
				if isTimer(MouseData.Timer["memoMove"]) then
					killTimer(MouseData.Timer["memoMove"])
				end
				if isTimer(MouseData.Timer["memoMoveDelay"]) then
					killTimer(MouseData.Timer["memoMoveDelay"])
				end
				MouseData.Timer["memoMoveDelay"] = setTimer(function()
					if dgsGetType(MouseData.nowShow) == "dgs-dxmemo" then
						MouseData.Timer["memoMove"] = setTimer(function()
							if dgsGetType(MouseData.nowShow) == "dgs-dxmemo" then
							local shift = getKeyState("lshift") or getKeyState("rshift")
								dgsMemoMoveCaret(MouseData.nowShow,1,0,shift)
							else
								killTimer(MouseData.Timer["memoMove"])
							end
						end,50,0)
					end
				end,500,1)
			elseif button == "arrow_u" then
				dgsMemoMoveCaret(MouseData.nowShow,0,-1,shift,true)
				if isTimer(MouseData.Timer["memoMove"]) then
					killTimer(MouseData.Timer["memoMove"])
				end
				if isTimer(MouseData.Timer["memoMoveDelay"]) then
					killTimer(MouseData.Timer["memoMoveDelay"])
				end
				MouseData.Timer["memoMoveDelay"] = setTimer(function()
					if dgsGetType(MouseData.nowShow) == "dgs-dxmemo" then
						MouseData.Timer["memoMove"] = setTimer(function()
							if dgsGetType(MouseData.nowShow) == "dgs-dxmemo" then
							local shift = getKeyState("lshift") or getKeyState("rshift")
								dgsMemoMoveCaret(MouseData.nowShow,0,-1,shift,true)
							else
								killTimer(MouseData.Timer["memoMove"])
							end
						end,50,0)
					end
				end,500,1)
			elseif button == "arrow_d" then
				dgsMemoMoveCaret(MouseData.nowShow,0,1,shift,true)
				if isTimer(MouseData.Timer["memoMove"]) then
					killTimer(MouseData.Timer["memoMove"])
				end
				if isTimer(MouseData.Timer["memoMoveDelay"]) then
					killTimer(MouseData.Timer["memoMoveDelay"])
				end
				MouseData.Timer["memoMoveDelay"] = setTimer(function()
					if dgsGetType(MouseData.nowShow) == "dgs-dxmemo" then
						MouseData.Timer["memoMove"] = setTimer(function()
							if dgsGetType(MouseData.nowShow) == "dgs-dxmemo" then
							local shift = getKeyState("lshift") or getKeyState("rshift")
								dgsMemoMoveCaret(MouseData.nowShow,0,1,shift,true)
							else
								killTimer(MouseData.Timer["memoMove"])
							end
						end,50,0)
					end
				end,500,1)
			elseif button == "home" then
				local tarline
				if getKeyState("lctrl") or getKeyState("rctrl") then
					tarline = 1
				end
				dgsMemoSetCaretPosition(MouseData.nowShow,0,tarline,getKeyState("lshift") or getKeyState("rshift"))
			elseif button == "end" then
				local text = dgsElementData[MouseData.nowShow].text
				local line = dgsElementData[MouseData.nowShow].caretPos[2]
				local tarline
				if getKeyState("lctrl") or getKeyState("rctrl") then
					tarline = #text
				end
				dgsMemoSetCaretPosition(MouseData.nowShow,utf8.len(text[line] or ""),tarline,getKeyState("lshift") or getKeyState("rshift"))
			elseif button == "delete" then
				if not dgsElementData[MouseData.nowShow].readOnly then
					local cpos = dgsElementData[MouseData.nowShow].caretPos
					local spos = dgsElementData[MouseData.nowShow].selectFrom
					if cpos[1] ~= spos[1] or cpos[2] ~= spos[2] then
						dgsMemoDeleteText(MouseData.nowShow,cpos[1],cpos[2],spos[1],spos[2])
						dgsElementData[MouseData.nowShow].selectFrom = dgsElementData[MouseData.nowShow].caretPos
					else
						local tarindex,tarline = dgsMemoSeekPosition(dgsElementData[MouseData.nowShow].text,cpos[1]+1,cpos[2])
						dgsMemoDeleteText(MouseData.nowShow,cpos[1],cpos[2],tarindex,tarline)
						MouseData.Timer["memoMoveDelay"] = setTimer(function()
							if dgsGetType(MouseData.nowShow) == "dgs-dxmemo" then
								MouseData.Timer["memoMove"] = setTimer(function()
									if dgsGetType(MouseData.nowShow) == "dgs-dxmemo" then
										local cpos = dgsElementData[MouseData.nowShow].caretPos
										local spos = dgsElementData[MouseData.nowShow].selectFrom
										local tarindex,tarline = dgsMemoSeekPosition(dgsElementData[MouseData.nowShow].text,cpos[1]+1,cpos[2])
										dgsMemoDeleteText(MouseData.nowShow,cpos[1],cpos[2],tarindex,tarline)
									else
										killTimer(MouseData.Timer["memoMove"])
									end
								end,50,0)
							end
						end,500,1)
					end
				end
			elseif button == "backspace" then
				if not dgsElementData[MouseData.nowShow].readOnly then
					local cpos = dgsElementData[MouseData.nowShow].caretPos
					local spos = dgsElementData[MouseData.nowShow].selectFrom
					if cpos[1] ~= spos[1] or cpos[2] ~= spos[2] then
						dgsMemoDeleteText(MouseData.nowShow,cpos[1],cpos[2],spos[1],spos[2])
						dgsElementData[MouseData.nowShow].selectFrom = dgsElementData[MouseData.nowShow].caretPos
					else
						local tarindex,tarline = dgsMemoSeekPosition(dgsElementData[MouseData.nowShow].text,cpos[1]-1,cpos[2])
						dgsMemoDeleteText(MouseData.nowShow,tarindex,tarline,cpos[1],cpos[2])
						MouseData.Timer["memoMoveDelay"] = setTimer(function()
							if dgsGetType(MouseData.nowShow) == "dgs-dxmemo" then
								MouseData.Timer["memoMove"] = setTimer(function()
									if dgsGetType(MouseData.nowShow) == "dgs-dxmemo" then
										local cpos = dgsElementData[MouseData.nowShow].caretPos
										local spos = dgsElementData[MouseData.nowShow].selectFrom
										local tarindex,tarline = dgsMemoSeekPosition(dgsElementData[MouseData.nowShow].text,cpos[1]-1,cpos[2])
										dgsMemoDeleteText(MouseData.nowShow,tarindex,tarline,cpos[1],cpos[2])
									else
										killTimer(MouseData.Timer["memoMove"])
									end
								end,50,0)
							end
						end,500,1)
					end
				end
			elseif button == "c" or button == "x" then
				if getKeyState("lctrl") or getKeyState("rctrl") then
					local deleteText = button == "x" and not dgsElementData[MouseData.nowShow].readOnly
					local cpos = dgsElementData[MouseData.nowShow].caretPos
					local spos = dgsElementData[MouseData.nowShow].selectFrom
					local theText = dgsMemoGetPartOfText(MouseData.nowShow,cpos[1],cpos[2],spos[1],spos[2],deleteText)
					setClipboard(theText)
				end
			end
		else
			if button == "arrow_l" or button == "arrow_r" or button == "arrow_u" or button == "arrow_d" or button == "backspace" or button == "delete" then
				if isTimer(MouseData.Timer["memoMove"]) then
					killTimer(MouseData.Timer["memoMove"])
				end
				if isTimer(MouseData.Timer["memoMoveDelay"]) then
					killTimer(MouseData.Timer["memoMoveDelay"])
				end
			end
		end
	end
end
addEventHandler("onClientKey",root,onClientKeyCheck)

addEventHandler("onClientGUIBlur",resourceRoot,function()
	local guitype = getElementType(source)
	if dgsElementData[source] then
		if guitype == "gui-edit" then
			local edit = dgsElementData[source].dxedit
			if isElement(edit) then
				if MouseData.nowShow == edit then
					if dgsElementData[edit].clearSelection then
						dgsSetData(edit,"selectFrom",dgsElementData[edit].caretPos)
					end
					MouseData.nowShow = false
				end
			end
		elseif guitype == "gui-memo" then
			local memo = dgsElementData[source].dxmemo
			if isElement(memo) then
				if MouseData.nowShow == memo then
					if dgsElementData[memo].clearSelection then
						dgsSetData(memo,"selectFrom",dgsElementData[memo].caretPos)
					end
					MouseData.nowShow = false
				end
			end
		end
	end
end)

addEventHandler("onDgsTextChange",root,function()
	local gui = dgsElementData[source].edit
	local text = dgsElementData[source].text
	if isElement(gui) then
		local gtext = guiGetText(gui)
		if gtext ~= text then
			guiSetText(gui,text)
		end
		local parent = dgsElementData[source].mycmd
		if isElement(parent) then
			if dgsGetType(parent) == "dgs-dxcmd" then
				local hisid = dgsElementData[parent].cmdCurrentHistory
				local history = dgsElementData[parent].cmdHistory
				if history[hisid] ~= text then
					dgsSetData(parent,"cmdCurrentHistory",0)
				end
			end
		end
	end
end)

function dgsCheckHit(hits,mx,my)
	if not isElement(MouseData.clickl) or not (dgsGetType(MouseData.clickl) == "dgs-dxscrollbar" and MouseData.clickData == 2) then
		if MouseData.enter ~= hits then
			if isElement(MouseData.enter) then
				triggerEvent("onDgsMouseLeave",MouseData.enter,mx,my,hits)
				if dgsGetType(MouseData.clickl) == "dgs-dxscrollbar" then
					if isTimer(MouseData.Timer[MouseData.clickl]) then
						killTimer(MouseData.Timer[MouseData.clickl])
					end
					if isTimer(MouseData.Timer2[MouseData.clickl]) then
						killTimer(MouseData.Timer2[MouseData.clickl])
					end
				end
				if dgsGetType(MouseData.enter) == "dgs-dxgridlist" then
					dgsSetData(MouseData.enter,"preSelect",{-1,-1})
				end
			end
			if isElement(hits) then
				triggerEvent("onDgsMouseEnter",hits,mx,my,MouseData.enter)
			end
			MouseData.lastEnter = MouseData.enter
			MouseData.enter = hits
		end
	end
	if dgsElementType[hits] == "dgs-dxtab" then
		local parent = dgsElementData[hits].parent
		dgsElementData[parent].preSelect = dgsElementData[parent].rndPreSelect
	end
	if isElement(hits) then
		if MouseData.lastPos[1] ~= mx or MouseData.lastPos[2] ~= my then
			triggerEvent("onDgsCursorMove",hits,mx,my)
		end
	end
	if isElement(MouseData.clickl) then
		if MouseData.lastPos[1] ~= mx or MouseData.lastPos[2] ~= my then
			triggerEvent("onDgsCursorDrag",MouseData.clickl,mx,my)
		end
		if MouseData.Move then
			if dgsGetType(MouseData.clickl) == "dgs-dxwindow" then
				local pos = dgsElementData[MouseData.clickl].absPos
				pos[1] = (mx-MouseData.Move[1])
				pos[2] = (my-MouseData.Move[2])
				calculateGuiPositionSize(MouseData.clickl,pos[1],pos[2],false)
			end
		end
		if MouseData.Scale then
			if dgsGetType(MouseData.clickl) == "dgs-dxwindow" then
				local pos = dgsElementData[MouseData.clickl].absPos
				local siz = dgsElementData[MouseData.clickl].absSize
				local relat = {1,1}
				pos[1] = pos[1]*relat[1]
				pos[2] = pos[2]*relat[2]
				siz[1] = siz[1]*relat[1]
				siz[2] = siz[2]*relat[2]
				local endr = pos[1] + siz[1]
				local endd = pos[2] + siz[2]
				local minSizeX,minSizeY = dgsElementData[MouseData.clickl].minSize[1],dgsElementData[MouseData.clickl].minSize[2]
				if MouseData.Scale[5] == 1 then
					local old = pos[1]
					siz[1] = (siz[1]-(mx-MouseData.Scale[1]-old))
					if siz[1] < minSizeX then
						siz[1] = minSizeX
						pos[1] = endr-siz[1]
					else
						pos[1] = (mx-MouseData.Scale[1])
					end
					pos[1] = pos[1]/relat[1]
					siz[1] = siz[1]/relat[1]
				end
				if MouseData.Scale[5] == 3 then
					siz[1] = (mx-pos[1]-MouseData.Scale[3])
					if siz[1] < minSizeX then
						siz[1] = minSizeX
					end
					siz[1] = siz[1]/relat[2]
				end
				if MouseData.Scale[6] == 2 then
					local old = pos[2]
					siz[2] = (siz[2]-(my-MouseData.Scale[2]-old))/relat[1]
					if siz[2] < minSizeY then
						siz[2] = minSizeY
						pos[2] = endd-siz[2]
					else
						pos[2] = (my-MouseData.Scale[2])
					end
					pos[2] = pos[2]/relat[1]
					siz[2] = siz[2]/relat[1]
				end
				if MouseData.Scale[6] == 4 then
					siz[2] = (my-pos[2]-MouseData.Scale[4])/relat[2]
					if siz[2] < minSizeY then
						siz[2] = minSizeY
					end
					siz[2] = siz[2]/relat[2]
				end
				calculateGuiPositionSize(MouseData.clickl,pos[1],pos[2],false,siz[1],siz[2],false)
			end
		else
			MouseData.lastPos = {-1,-1}
		end
		if not getKeyState("mouse1") then
			MouseData.clickl = false
			MouseData.clickData = false
			MouseData.Move = false
			MouseData.Scale = false
			MouseData.lock3DInterface = false
		end
		if not getKeyState("mouse2") then
			MouseData.clickr = false
		end
	end
	MouseData.lastPos = {mx,my}
end

addEventHandler("onDgsMouseClick",resourceRoot,function(button,state,mx,my)
	if not isElement(source) then return end
	local parent = dgsGetParent(source)
	local guitype = dgsGetType(source)
	if state == "down" then
		dgsBringToFront(source,button)
		if guitype == "dgs-dxscrollpane" then
			local scrollbar = dgsElementData[source].scrollbars
			dgsBringToFront(scrollbar[1],"left",_,true)
			dgsBringToFront(scrollbar[2],"left",_,true)
		end
		if button == "left" then
			if guitype == "dgs-dxwindow" then
				if not checkScale() then
					checkMove()
				end
			end
			if guitype == "dgs-dxscrollbar" then
				local scrollArrow = dgsElementData[source].scrollArrow
				local x,y = dgsGetPosition(source,false,true)
				local w,h = dgsGetSize(source,false)
				local voh = dgsElementData[source].voh
				local pos = dgsElementData[source].position
				local length,lrlt = dgsElementData[source].length[1],dgsElementData[source].length[2]
				local slotRange
				local arrowPos = 0
				if voh then
					if scrollArrow then
						arrowPos = h
					end
					slotRange = w-arrowPos*2
				else
					if scrollArrow then
						arrowPos = w
					end
					slotRange = h-arrowPos*2
				end
				local cursorRange = (lrlt and length*slotRange) or (length <= slotRange and length or slotRange*0.01)
				if MouseData.enterData then
					MouseData.clickData = MouseData.enterData
				end
				if scrollArrow then
					if MouseData.clickData == 1 then
						local moveMultiplier,rltPos = dgsElementData[source].multiplier[1],dgsElementData[source].multiplier[2]
						local movePos = dgsElementData[source].position
						local gpos = movePos-(rltPos and moveMultiplier*cursorRange*0.01 or moveMultiplier)
						dgsSetData(source,"position",(gpos < 0 and 0) or (gpos >100 and 100) or gpos)
						if not isTimer(MouseData.Timer[source]) then
							MouseData.Timer2[source] = setTimer(function(source)
								if MouseData.clickl == source then
									if not isTimer(MouseData.Timer[source]) then
										MouseData.Timer[source] = setTimer(function(source)
											if MouseData.clickData == 1 then
												local moveMultiplier,rltPos = dgsElementData[source].multiplier[1],dgsElementData[source].multiplier[2]
												local movePos = dgsElementData[source].position
												local gpos = movePos-(rltPos and moveMultiplier*cursorRange*0.01 or moveMultiplier)
												dgsSetData(source,"position",(gpos < 0 and 0) or (gpos >100 and 100) or gpos)
											else
												killTimer(MouseData.Timer[source])
											end
										end,50,0,source)
									end
								end
							end,400,1,source)
						end
					end
					if MouseData.clickData == 4 then
						local moveMultiplier,rltPos = dgsElementData[source].multiplier[1],dgsElementData[source].multiplier[2]
						local movePos = dgsElementData[source].position
						local gpos = movePos+(rltPos and moveMultiplier*cursorRange*0.01 or moveMultiplier)
						dgsSetData(source,"position",(gpos < 0 and 0) or (gpos >100 and 100) or gpos)
						if not isTimer(MouseData.Timer[source]) then
							MouseData.Timer2[source] = setTimer(function(source)
								if MouseData.clickl == source then
									if not isTimer(MouseData.Timer[source]) then
										MouseData.Timer[source] = setTimer(function(source)
											if MouseData.clickData == 4 then
												local moveMultiplier,rltPos = dgsElementData[source].multiplier[1],dgsElementData[source].multiplier[2]
												local movePos = dgsElementData[source].position
												local gpos = movePos+(rltPos and moveMultiplier*cursorRange*0.01 or moveMultiplier)
												dgsSetData(source,"position",(gpos < 0 and 0) or (gpos >100 and 100) or gpos)
											else
												killTimer(MouseData.Timer[source])
											end
										end,50,0,source)
									end
								end
							end,400,1,source)
						end
					end
				end
				local py =  pos*0.01*(slotRange-cursorRange)
				checkScrollBar(py,voh)
				local parent = dgsElementData[source].attachedToParent
				if isElement(parent) then
					if source == dgsElementData[parent].scrollbars[1] then
						dgsSetData(parent,"mouseWheelScrollBar",false)
					elseif source == dgsElementData[parent].scrollbars[2] then
						dgsSetData(parent,"mouseWheelScrollBar",true)
					end
				end
			elseif guitype == "dgs-dxgridlist" then
				local oPreSelect = dgsElementData[source].oPreSelect
				local rowData = dgsElementData[source].rowData
				----Sort
				if dgsElementData[source].sortEnabled then
					local column = dgsElementData[source].selectedColumn
					if column and column >= 1 then
						local sortFunction = dgsElementData[source].sortFunction
						local targetfunction = sortFunction == sortFunctions_upper and sortFunctions_lower or sortFunctions_upper
						dgsGridListSetSortFunction(source,targetfunction)
						dgsGridListSetSortColumn(source,column)
					end
				end
				--------
				if oPreSelect and rowData[oPreSelect] and rowData[oPreSelect][-1] then 
					local old1,old2
					local selectionMode = dgsElementData[source].selectionMode
					local multiSelection = dgsElementData[source].multiSelection
					local preSelect = dgsElementData[source].preSelect
					local clicked = dgsElementData[source].itemClick
					local pass = true
					local shift,ctrl = getKeyState("lshift") or getKeyState("rshift"),getKeyState("lctrl") or getKeyState("rctrl")
					if #preSelect == 2 then
						if selectionMode == 1 then
							if multiSelection then
								if ctrl then
									local selected = dgsGridListItemIsSelected(source,preSelect[1],1)
									dgsGridListSelectItem(source,preSelect[1],1,not selected)
								elseif shift then
									if clicked and #clicked == 2 then
										dgsGridListSetSelectedItem(source,-1,-1)
										local startRow,endRow = math.min(clicked[1],preSelect[1]),math.max(clicked[1],preSelect[1])
										for row = startRow,endRow do
											dgsGridListSelectItem(source,row,1,true)
										end
										dgsElementData[source].itemClick = clicked
									end
								else
									dgsGridListSetSelectedItem(source,preSelect[1],1)
									dgsElementData[source].itemClick = preSelect
								end
							else
								dgsGridListSetSelectedItem(source,preSelect[1],1)
								dgsElementData[source].itemClick = preSelect
							end
						elseif selectionMode == 2 then
							if multiSelection then
								if ctrl then
									local selected = dgsGridListItemIsSelected(source,1,preSelect[2])
									dgsGridListSelectItem(source,1,preSelect[2],not selected)
								elseif shift then
									if clicked and #clicked == 2 then
										dgsGridListSetSelectedItem(source,-1,-1)
										local startColumn,endColumn = math.min(clicked[2],preSelect[2]),math.max(clicked[2],preSelect[2])
										for column = startColumn, endColumn do
											dgsGridListSelectItem(source,1,column,true)
										end
										dgsElementData[source].itemClick = clicked
									end
								else
									dgsGridListSetSelectedItem(source,1,preSelect[2])
									dgsElementData[source].itemClick = preSelect
								end
							else
								dgsGridListSetSelectedItem(source,1,preSelect[2])
								dgsElementData[source].itemClick = preSelect
							end
						elseif selectionMode == 3 then
							if multiSelection then
								if ctrl then
									local selected = dgsGridListItemIsSelected(source,preSelect[1],preSelect[2])
									dgsGridListSelectItem(source,preSelect[1],preSelect[2],not selected)
								elseif shift then
									if clicked and #clicked == 2 then
										dgsGridListSetSelectedItem(source,-1,-1)
										local startRow,endRow = math.min(clicked[1],preSelect[1]),math.max(clicked[1],preSelect[1])
										local startColumn,endColumn = math.min(clicked[2],preSelect[2]),math.max(clicked[2],preSelect[2])
										for row = startRow,endRow do
											for column = startColumn, endColumn do
												dgsGridListSelectItem(source,row,column,true)
											end
										end
										dgsElementData[source].itemClick = clicked
									end
								else
									dgsGridListSetSelectedItem(source,preSelect[1],preSelect[2])
									dgsElementData[source].itemClick = preSelect
								end
							else
								dgsGridListSetSelectedItem(source,preSelect[1],preSelect[2])
								dgsElementData[source].itemClick = preSelect
							end
						end
					end
				end
			elseif guitype == "dgs-dxcombobox-Box" then
				local combobox = dgsElementData[source].myCombo
				local preSelect = dgsElementData[combobox].preSelect
				local oldSelect = dgsElementData[combobox].select
				dgsElementData[combobox].select = preSelect
				triggerEvent("onDgsComboBoxSelect",combobox,preSelect,oldSelect)
				if dgsElementData[combobox].autoHideWhenSelecting then
					dgsSetData(combobox,"listState",-1)
				end
			elseif guitype == "dgs-dxarrowlist" then
				local alEnter = MouseData.arrowListEnter
				if alEnter and alEnter[1] == source then
					dgsSetData(source,"arrowListClick",{alEnter[2],alEnter[3]})
					local id = alEnter[2]
					local itemData = dgsElementData[source].itemData
					local sItemData = itemData[id]
					if alEnter[3] then
						local mathSymbol = alEnter[3] == "left" and -1 or 1
						local old = sItemData[6]
						sItemData[6] = math.restrict(sItemData[2],sItemData[3],sItemData[6]+sItemData[4]*mathSymbol)
						triggerEvent("onDgsArrowListValueChange",source,id,sItemData[6],old)
					end
				end
			elseif guitype == "dgs-dxtab" then
				local tabpanel = dgsElementData[source].parent
				dgsBringToFront(tabpanel)
				if dgsElementData[tabpanel]["preSelect"] ~= -1 then
					dgsSetData(tabpanel,"selected",dgsElementData[tabpanel]["preSelect"])
				end
			elseif guitype == "dgs-dxcombobox" then
				dgsSetData(source,"listState",dgsElementData[source].listState == 1 and -1 or 1)
			end
		end
	else
		if button == "left" then
			if MouseData.arrowListEnter then
				if isElement(MouseData.arrowListEnter[1]) then
					dgsSetData(MouseData.arrowListEnter[1],"arrowListClick",false)
				end
			end
			MouseData.arrowListEnter = false
			if MouseData.clickl == source then
				if isElement(parent) then
					local closebutton = dgsElementData[parent].closeButton
					if closebutton == source then
						triggerEvent("onDgsWindowClose",parent,closebutton)
						local canceled = wasEventCancelled()
						triggerEvent("onClientDgsDxWindowClose",parent,closebutton)
						local canceled2 = wasEventCancelled()
						if not canceled and not canceled2 then
							return destroyElement(parent)
						end
					end
				end	
			end
		end
	end
end)

addEventHandler("onClientElementDestroy",resourceRoot,function()
	local parent = dgsGetParent(source) or root
	if dgsIsDxElement(source) then
		triggerEvent("onDgsDestroy",source)
		local child = ChildrenTable[source] or {}
		for i=1,#child do
			if isElement(child[1]) then
				destroyElement(child[1])
			end
		end
		local dgsType = dgsGetType(source)
		if dgsType == "dgs-dxedit" then
			local edit = dgsElementData[source].edit
			destroyElement(edit)
			local rentarg = dgsElementData[source].renderTarget
			if isElement(rentarg) then
				destroyElement(rentarg)
			end
		elseif dgsType == "dgs-dxmemo" then
			local memo = dgsElementData[source].memo
			destroyElement(memo)
			local rentarg = dgsElementData[source].renderTarget
			if isElement(rentarg) then
				destroyElement(rentarg)
			end
		elseif dgsType == "dgs-dxgridlist" then
			local rentarg = dgsElementData[source].renderTarget
			if isElement(rentarg[1]) then
				destroyElement(rentarg[1])
			end
			if isElement(rentarg[2]) then
				destroyElement(rentarg[2])
			end
		elseif dgsType == "dgs-dxscrollpane" then
			local rentarg = dgsElementData[source].renderTarget_parent
			destroyElement(rentarg)
			local scrollbar = dgsElementData[source].scrollbars or {}
			if isElement(scrollbar[1]) then
				destroyElement(scrollbar[1])
			end
			if isElement(scrollbar[2]) then
				destroyElement(scrollbar[2])
			end
		elseif dgsType == "dgs-dxtabpanel" then
			local rentarg = dgsElementData[source].renderTarget
			for k,v in pairs(dgsElementData[source].tabs or {}) do
				destroyElement(v)
			end
			if isElement(rentarg) then
				destroyElement(rentarg)
			end
		elseif dgsType == "dgs-dxtab" then
			local isRemove = dgsElementData[source].isRemove
			if not isRemove then
				local tabpanel = dgsElementData[source].parent
				if dgsGetType(tabpanel) == "dgs-dxtabpanel" then
					local tp_w = dgsElementData[tabpanel].absSize[1]
					local wid = dgsElementData[source].width
					local tabs = dgsElementData[tabpanel].tabs
					local t_sideSize = dgsElementData[tabpanel].tabSideSize
					local sidesize = t_sideSize[2] and t_sideSize[1]*tp_w or t_sideSize[1]
					local t_gapSize = dgsElementData[tabpanel].tabGapSize
					local gapsize = t_gapSize[2] and t_gapSize[1]*tp_w or t_gapSize[1]
					dgsSetData(tabpanel,"allleng",dgsElementData[tabpanel].allleng-wid-sidesize*2-gapsize*math.min(#tabs,1))
					local id = dgsElementData[source].id
					for i=id,#tabs do
						dgsElementData[tabs[i]].id = dgsElementData[tabs[i]].id-1
					end
					table.remove(tabs,id)
				end
			end
		elseif dgsType == "dgs-dxcombobox" then
			local rentarg = dgsElementData[source].renderTarget
			if isElement(rentarg) then
				destroyElement(rentarg)
			end
		elseif dgsType == "dgs-dxarrowlist" then
			local rentarg = dgsElementData[source].renderTarget
			if isElement(rentarg) then
				destroyElement(rentarg)
			end
		elseif dgsType == "dgs-dx3dinterface" then
			local rentarg = dgsElementData[source].renderTarget_parent
			if isElement(rentarg) then
				destroyElement(rentarg)
			end
		elseif dgsType == "dgs-dximage" then
			local image = dgsElementData[source].image
			if isElement(image) then
				if dgsElementData[image] and dgsElementData[image].parent == image then
					destroyElement(image)
				end
			end
		end
		table.remove(ChildrenTable[source] or {})
		local tresource = getElementData(source,"resource")
		if tresource then
			local id = table.find(resourceDxGUI[tresource] or {},source)
			if id then
				table.remove(resourceDxGUI[tresource],id)
			end
		end
		dgsStopAniming(source)
		dgsStopMoving(source)
		dgsStopSizing(source)
		dgsStopAlphaing(source)
		dgsElementData[source] = nil
		if dgsType == "dgs-dx3dinterface" then
			local id = table.find(dx3DInterfaceTable,source)
			if id then
				table.remove(dx3DInterfaceTable,id)
			end
		else
			local parent = dgsGetParent(source)
			if not isElement(parent) then
				local id = table.find(CenterFatherTable,source)
				if id then
					table.remove(CenterFatherTable,id)
					return
				end
				local id = table.find(BottomFatherTable,source)
				if id then
					table.remove(BottomFatherTable,id)
					return
				end
				local id = table.find(TopFatherTable,source)
				if id then
					table.remove(TopFatherTable,id)
					return
				end
			else
				local id = table.find(ChildrenTable[parent] or {},source)
				if id then
					table.remove(ChildrenTable[parent] or {},id)
				end
			end
		end
	end
end)

function checkMove()
	local mx,my = getCursorPosition()
	mx,my = MouseX or (mx or -1)*sW,MouseY or (my or -1)*sH
	local x,y = dgsElementData[source].absPos[1],dgsElementData[source].absPos[2]
	local offsetx,offsety = mx-x,my-y
	if dgsGetType(source) == "dgs-dxwindow" then
		local movable = dgsElementData[source].movable
		if not movable then return end
		local sx,sy = dgsElementData[source].absSize[1],dgsElementData[source].absSize[2]
		local titsize = dgsElementData[source].movetyp and sy or dgsElementData[source].titleHeight
		if offsety > titsize then return end
	end
	MouseData.Move = {offsetx,offsety}
end

function checkScrollBar(py,sd)
	local mx,my = getCursorPosition()
	mx,my = MouseX or (mx or -1)*sW,MouseY or (my or -1)*sH
	local x,y = dgsElementData[source].absPos[1],dgsElementData[source].absPos[2]
	local offsetx,offsety = mx-x,my-y
	MouseData.Move = {sd and offsetx-py or offsetx,sd and offsety or offsety-py}
end

function checkScale()
	local mx,my = getCursorPosition()
	mx,my = (mx or -1)*sW,(my or -1)*sH
	local x,y = dgsElementData[source].absPos[1],dgsElementData[source].absPos[2]
	local w,h = dgsElementData[source].absSize[1],dgsElementData[source].absSize[2]
	local offsets = {mx-x,my-y,mx-x-w,my-y-h}
	local left
	local right
	if dgsGetType(source) == "dgs-dxwindow" then
		local sizable = dgsElementData[source].sizable
		if not sizable then return false end
		local borderSize = dgsElementData[source].borderSize
		if math.abs(offsets[1]) < borderSize then
			offsets[5] = 1
		elseif math.abs(offsets[3]) < borderSize then
			offsets[5] = 3
		end
		if math.abs(offsets[2]) < borderSize then
			offsets[6] = 2
		elseif math.abs(offsets[4]) < borderSize then
			offsets[6] = 4
		end
		if not offsets[5] and not offsets[6] then
			MouseData.Scale = false
			return false
		end
	end
	MouseData.Scale = offsets
	return true
end
DoubleClick = {}
DoubleClick.down = false
DoubleClick.up = false
GirdListDoubleClick = {}
GirdListDoubleClick.down = false
GirdListDoubleClick.up = false

addEventHandler("onClientClick",root,function(button,state,x,y)
	local guiele = dgsGetMouseEnterGUI()
	if isElement(guiele) then
		local gtype = dgsGetType(guiele)
		if state == "down" then
			if button == "left" then
				if gtype == "dgs-dxradiobutton" then
					dgsRadioButtonSetSelected(guiele,true)
				elseif gtype == "dgs-dxcheckbox" then
					local state = dgsElementData[guiele].CheckBoxState
					dgsCheckBoxSetSelected(guiele,not state)
				end
			end
			if isElement(lastFront) then
				if guiele ~= lastFront then
					local theType = dgsGetType(lastFront)
					if theType == "dgs-dxcombobox" then
						if dgsElementData[guiele].myCombo ~= lastFront then
							dgsComboBoxSetState(lastFront,false)
						end
					else
						local combobox = dgsElementData[lastFront].myCombo
						if isElement(combobox) and dgsElementData[guiele].myCombo ~= combobox then
							dgsComboBoxSetState(combobox,false)
						end
					end
				end
			end
		end
		if gtype == "dgs-dxbrowser" then
			focusBrowser(guiele)
		else
			focusBrowser()
		end
		triggerEvent("onDgsMouseClick",guiele,button,state,MouseX or x,MouseY or y)
		if not isElement(guiele) then return end
		if DoubleClick[state] and isTimer(DoubleClick[state].timer) and DoubleClick[state].ele == guiele and DoubleClick[state].but == button then
			triggerEvent("onDgsMouseDoubleClick",guiele,button,state,x,y)
			killTimer(DoubleClick[state].timer)
			DoubleClick[state] = {}
		else
			if DoubleClick[state] then
				if isTimer(DoubleClick[state].timer) then
					killTimer(DoubleClick[state].timer)
				end
			end
			DoubleClick[state] = {}
			DoubleClick[state].ele = guiele
			DoubleClick[state].but = button
			DoubleClick[state].timer = setTimer(function()
				DoubleClick[state] = false
			end,500,1)
		end
		if not isElement(guiele) then return end
		if GirdListDoubleClick[state] and isTimer(GirdListDoubleClick[state].timer) then
			local clicked = dgsElementData[guiele].itemClick
			local selectionMode = dgsElementData[guiele].selectionMode
			if dgsGetType(guiele) == "dgs-dxgridlist" and GirdListDoubleClick[state].gridlist == guiele and GirdListDoubleClick[state].but == button then
				local pass = true
				if selectionMode == 1 then
					if GirdListDoubleClick[state].item ~= clicked[1] then
						pass = false
					end
				elseif selectionMode == 2 then
					if GirdListDoubleClick[state].column ~= clicked[2] then
						pass = false
					end
				elseif selectionMode == 3 then
					if GirdListDoubleClick[state].item ~= clicked[1] or GirdListDoubleClick[state].column ~= clicked[2] then
						pass = false
					end
				end
				if pass then
					triggerEvent("onDgsGridListItemDoubleClick",guiele,GirdListDoubleClick[state].but,state,clicked[1],clicked[2])
				end
			end
			killTimer(GirdListDoubleClick[state].timer)
			GirdListDoubleClick[state] = {}
		else
			if GirdListDoubleClick[state] then
				if isTimer(GirdListDoubleClick[state].timer) then
					killTimer(GirdListDoubleClick[state].timer)
				end
			end
			if dgsGetType(guiele) == "dgs-dxgridlist" then
				local clicked = dgsElementData[guiele].itemClick
				if clicked[1] ~= -1 and clicked[2] ~= -1 then
					GirdListDoubleClick[state] = {}
					GirdListDoubleClick[state].item,GirdListDoubleClick[state].column = clicked[1],clicked[2]
					GirdListDoubleClick[state].gridlist = guiele
					GirdListDoubleClick[state].but = button
					GirdListDoubleClick[state].timer = setTimer(function()
						GirdListDoubleClick[state].gridlist = false
					end,500,1)
				end
			end
		end
	elseif state == "down" then
		local dgsType = dgsGetType(MouseData.nowShow)
		if dgsType == "dgs-dxedit" or dgsType == "dgs-dxmemo" then
			blurEditMemo()
		end
		MouseData.nowShow = false
		if isElement(lastFront) then
			local theType = dgsGetType(lastFront)
			if theType == "dgs-dxcombobox" then
				dgsComboBoxSetState(lastFront,false)
			else
				local combobox = dgsElementData[lastFront].myCombo
				if isElement(combobox) then
					dgsComboBoxSetState(combobox,false)
				end
			end
			triggerEvent("onDgsBlur",lastFront,false)
			lastFront = false
		end
	end
	if state == "up" then
		if button == "left" then
			MouseData.clickl = false
			MouseData.lock3DInterface = false
		elseif button == "right" then
			MouseData.clickr = false
		end
		MouseData.Move = false
		MouseData.Scale = false
		MouseData.clickData = nil
		if isTimer(MouseData.Timer[button]) then
			killTimer(MouseData.Timer[button])
		end
		if isTimer(MouseData.Timer2[button]) then
			killTimer(MouseData.Timer2[button])
		end
	end
end)

addEventHandler("onDgsPositionChange",root,function(oldx,oldy)
	local parent = dgsGetParent(source)
	if isElement(parent) then
		if dgsGetType(parent) == "dgs-dxscrollpane" then
			local abspos = dgsElementData[source].absPos
			local abssize = dgsElementData[source].absSize
			if abspos and abssize then
				local x,y = abspos[1],abspos[2]
				local sx,sy = abssize[1],abssize[2]
				local maxSize = dgsElementData[parent].maxChildSize
				local ntempx,ntempy
				if maxSize[1] <= sx then
					ntempx = 0
					for k,v in ipairs(ChildrenTable[parent] or {}) do
						local pos = dgsElementData[source].absPos
						local size = dgsElementData[source].absSize
						ntempx = ntempx > pos[1]+size[1] and ntempx or pos[1]+size[1]
					end
				end
				if maxSize[2] <= sy then
					ntempy = 0
					for k,v in ipairs(ChildrenTable[parent] or {}) do
						local pos = dgsElementData[source].absPos
						local size = dgsElementData[source].absSize
						ntempy = ntempy > pos[2]+size[2] and ntempy or pos[2]+size[2]	
					end
				end
				dgsSetData(parent,"maxChildSize",{ntempx or maxSize[1],ntempy or maxSize[2]})
			end
		end
	end
	for k,v in ipairs(ChildrenTable[source] or {}) do
		local relt = dgsElementData[v].relative
		local relativePos,relativeSize = relt[1],relt[2]
		local x,y
		if relativePos then
			x,y = dgsElementData[v].rltPos[1],dgsElementData[v].rltPos[2]
		end
		calculateGuiPositionSize(v,x,y,relativePos)
	end
end)

addEventHandler("onDgsSizeChange",root,function()
	for k,v in ipairs(ChildrenTable[source] or {}) do
		local relt = dgsElementData[v].relative
		local relativePos,relativeSize = relt[1],relt[2]
		local x,y,sx,sy
		if relativePos then
			x,y = dgsElementData[v].rltPos[1],dgsElementData[v].rltPos[2]
		end
		if relativeSize then
			sx,sy = dgsElementData[v].rltSize[1],dgsElementData[v].rltSize[2]
		end
		calculateGuiPositionSize(v,x,y,relativePos,sx,sy,relativeSize)
	end
	local typ = dgsGetType(source)
	if typ == "dgs-dxgridlist" then
		configGridList(source)
	elseif typ == "dgs-dxcmd" then
		configCMD(source)
	elseif typ == "dgs-dxedit" then
		configEdit(source)
	elseif typ == "dgs-dxscrollpane" then
		configScrollPane(source)
	elseif typ == "dgs-dxtabpanel" then
		configTabPanel(source)
	elseif typ == "dgs-dxcombobox-Box" then
		configComboBox_Box(source)
	end
	local parent = dgsGetParent(source)
	if isElement(parent) then
		if dgsGetType(parent) == "dgs-dxscrollpane" then
			sortScrollPane(source,parent)
		end
	end
end)

dgsElementData[resourceRoot] = {}
