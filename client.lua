------------Copyrights thisdp's DirectX Graphical User Interface
white = tocolor(255,255,255,255)
black = tocolor(0,0,0,255)
sW,sH = guiGetScreenSize()
fontSize = {}
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
systemFont = "default"

function setSystemFont(font,size,bold,quality)
	assert(type(font) == "string","Bad argument @setSystemFont at argument 1, expect a string got "..dgsGetType(font))
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
			assert(fileExists(path),"Bad argument @setSystemFont at argument 1,couldn't find such file '"..path.."'")
			local filename = split(path,"/")
			local pathindgs = ":"..getResourceName(getThisResource()).."/Third/"..filename[#filename]
			fileCopy(path,pathindgs,true)
			local font = dxCreateFont(pathindgs,size,bold,quality)
			if isElement(font) then
				if isElement(systemFont) then
					destroyElement(systemFont)
				end
				systemFont = font
			end
		end
	end
	return false
end

function getSystemFont()
	return systemFont
end

-----------------------------------------------------Core-----------------------------------------------------
dgsElementType = {}
BottomFatherTable = {}		--Store Save Bottom Father Element
FatherTable = {}		--Store Save Father Element
ChildrenTable = {}		--Store Children Element
MaxFatherTable = {}		--Topest
dgsElementData = {}		--Store The Data

function dgsGetType(shenMeGui)
	if isElement(shenMeGui) then
		return tostring(dgsElementType[shenMeGui] or getElementType(shenMeGui))
	else
		return type(shenMeGui)
	end
end

function dgsSetType(shenMeGui,myType)
	if isElement(shenMeGui) and type(myType) == "string" then
		dgsElementType[shenMeGui] = myType
		return true
	end
	return false
end

function dgsSetBottom(shenMeGUI)
	local id = table.find(MaxFatherTable,shenMeGUI)
	if id then
		table.remove(MaxFatherTable,id)
		table.insert(BottomFatherTable,shenMeGUI)
	end
end

function dgsGetChild(baba,id)
	return ChildrenTable[baba][id] or false
end

function dgsGetChildren(baba)
	return ChildrenTable[baba] or {}
end

function dgsGetParent(erzi)
	return FatherTable[erzi] or false
end

function dgsGetDxGUIFromResource(res)
	local res = res or sourceResource
	if res then
		return resourceDxGUI[res] or {}
	end
end

function dgsGetDxGUINoParent(alwaysBottom)
	return alwaysBottom and BottomFatherTable or MaxFatherTable
end

function dgsSetParent(erzi,baba,nocheckfather)
	if isElement(erzi) then
		local parent = FatherTable[erzi]
		local parentTable = isElement(parent) and ChildrenTable[parent] or MaxFatherTable or BottomFatherTable
		if isElement(baba) then
			if not dgsIsDxElement(baba) then return end
			if not nocheckfather then
				local id = table.find(parentTable,erzi)
				if id then
					parentTable[id] = nil
				end
			end
			FatherTable[erzi] = baba
			ChildrenTable[baba] = ChildrenTable[baba] or {}
			table.insert(ChildrenTable[baba],erzi)
		else
			local id = table.find(parentTable,erzi)
			if id then
				table.remove(parentTable,id)
			end
			FatherTable[id] = nil
			table.insert(MaxFatherTable,erzi) 
		end
		return true
	end
	return false
end

function dgsGetData(element,key)
	if isElement(element) then
		if dgsElementData[element] then
			if key then
				if dgsElementData[element][key] then
					return dgsElementData[element][key]
				end
			else
				return dgsElementData[element]
			end
		else
			return getElementType(element)
		end
	else
		return type(element)
	end
end

function dgsSetData(element,key,value,check)
	if isElement(element) and tostring(key) then
		if not dgsElementData[element] then
			dgsElementData[element] = {}
		end
		local dgsType = dgsGetType(element)
		dgsElementData[element][""..key..""] = value
		if not check then
			local oldValue = dgsElementData[element][""..key..""]
			if tostring(key) == "text" then
				triggerEvent("onClientDgsDxGUITextChange",element,value)
			elseif dgsGetType(element) == "dgs-dxscrollbar" and tostring(key) == "length" then
				local w,h = dgsGetSize(element,false)
				local voh = dgsElementData[element]["voh"]
				if (value[2] and value[1]*(voh and w-h*2 or h-w*2) or value[1]) < 20 then
					dgsElementData[element][""..key..""] = {10,false}
				end
			elseif tostring(key) == "position" then
				if oldValue and oldValue ~= value then
					triggerEvent("onClientDgsDxScrollBarScrollPositionChange",element,value,oldValue)
				end
			elseif (dgsType == "dgs-dxgridlist" or dgsType == "dgs-dxscrollpane") then
				if key == "scrollBarThick" then
					assert(type(value) == "number","Bad argument 'dgsSetData' at 3,expect number got"..type(value))
					local scrollbars = dgsElementData[element]["scrollbars"]
					local size = dgsElementData[element]["absSize"]
					dgsSetPosition(scrollbars[1],size[1]-value,0,false)
					dgsSetSize(scrollbars[1],value,size[2]-value,false)
					dgsSetPosition(scrollbars[2],0,size[2]-value,false)
					dgsSetSize(scrollbars[2],size[1]-value,value,false)
					if dgsType == "dgs-dxgridlist" then
						configGridList(element)
					else
						configScrollPane(element)
					end
				elseif key == "columnHeight" then
					configGridList(element)
				elseif key == "mode" then
					configGridList(element)
				end
			elseif dgsType == "dgs-dxcombobox" then
				if key == "scrollBarThick" then
					assert(type(value) == "number","Bad argument 'dgsSetData' at 3,expect number got"..type(value))
					local scrollbar = dgsElementData[element]["scrollbar"]
					configComboBox_Box(dgsElementData[element].myBox)
				elseif key == "listState" then
					triggerEvent("onClientDgsDxComboBoxStateChanged",element,value == 1 and true or false)
				end
			elseif dgsType == "dgs-dxtabpanel" then
				if key == "selected" then
					triggerEvent("onClientDgsDxTabPanelTabSelect",element,dgsElementData[element]["selected"],value)
				elseif key == "tabsidesize" then
					local width = dgsElementData[element]["absSize"][1]
					local change = value[2] and value[1]*width or value[1]
					local old = oldValue[2] and oldValue[1]*width or oldValue[1]
					local tabs = dgsElementData[element]["tabs"]
					local allleng = dgsElementData[element]["allleng"]+(change-old)*#tabs*2
					dgsSetData(element,"allleng",allleng)
				elseif key == "tabgapsize" then
					local width = dgsElementData[element]["absSize"][1]
					local change = value[2] and value[1]*width or value[1]
					local old = oldValue[2] and oldValue[1]*width or oldValue[1]
					local tabs = dgsElementData[element]["tabs"]
					local allleng = dgsElementData[element]["allleng"]+(change-old)*math.max((#tabs-1),1)
					dgsSetData(element,"allleng",allleng)
				end
			elseif dgsType == "dgs-dxedit" then
				if key == "maxLength" then
					local value = tonumber(value)
					local gedit = dgsElementData[element].edit
					if value and isElement(gedit) then
						return guiEditSetMaxLength(gedit,value)
					else
						return false
					end
				elseif key == "readOnly" then
					local gedit = dgsElementData[element].edit
					if value and isElement(gedit) then
						return guiEditSetReadOnly(gedit,value)
					else
						return false
					end
				end
			elseif dgsType == "dgs-dxprogressbar" then
				if key == "progress" then
					triggerEvent("onClientDgsDxProgressBarChange",source,value,oldValue)
				end
			end
		end
		return true
	end
	return false
end

function table.find(tab,ke,num)
	for k,v in pairs(tab) do
		if num then
			if v[num] == ke then
				return k
			end
		else
			if v == ke then
				return k
			end	
		end
	end
	return false
end

function dgsIsDxElement(element)
	if string.sub(dgsGetType(element) or "",1,6) == "dgs-dx" then
		return true
	end
	return false
end
-----------------------------dx-GUI
MouseData = {}
MouseData.enter = false
MouseData.enterData = false
MouseData.scrollPane = false
MouseData.hit = false
MouseData.Timer = {}
MouseData.Timer2 = {}
MouseData.nowShow = false
MouseData.editCursor = false
MouseData.editCursorMoveOffset = false
MouseData.lastPos = {-1,-1}

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

dgsType = {
"dgs-dxbutton",
"dgs-dxcmd",
"dgs-dxedit",
"dgs-dxmemo",
"dgs-dxcyclehitshape",
"dgs-dxgridlist",
"dgs-dximage",
"dgs-dxradiobutton",
"dgs-dxcheckbox",
"dgs-dxlabel",
"dgs-dxscrollbar",
"dgs-dxscrollpane",
"dgs-dxwindow",
"dgs-dxprogressbar",
"dgs-dxtabpanel",
"dgs-dxtab",
"dgs-dxcombobox",
"dgs-dxcombobox-Box",
}

addCommandHandler("debugdgs",function()
	DEBUG_MODE = not getElementData(localPlayer,"DGS-DEBUG")
	setElementData(localPlayer,"DGS-DEBUG",DEBUG_MODE,false)
end)

DEBUG_MODE = getElementData(localPlayer,"DGS-DEBUG")

function GUIRender()
	local tk = getTickCount()
	local mx,my = getCursorPosition()
	mx,my = (mx or -1)*sW,(my or -1)*sH
	if not isCursorShowing() then
		MouseData.Move = false
		MouseData.clickData = false
		MouseData.clickl = false
		MouseData.clickr = false
		MouseData.clickm = false
		MouseData.Scale = false
		MouseData.scrollPane = false
	end
	MouseData.hit = false
	DGSShow = 0
	for k,v in ipairs(BottomFatherTable) do
		renderGUI(v,mx,my,dgsElementData[v].enabled,dgsElementData[v].renderTarget_parent,0,0,1,dgsElementData[v].visible)
	end
	for k,v in ipairs(MaxFatherTable) do
		renderGUI(v,mx,my,dgsElementData[v].enabled,dgsElementData[v].renderTarget_parent,0,0,1,dgsElementData[v].visible)
	end
	dxSetRenderTarget()
	if not isCursorShowing() then
		MouseData.hit = false
		MouseData.Move = false
		MouseData.clickData = false
		MouseData.clickl = false
		MouseData.clickr = false
		MouseData.clickm = false
		MouseData.Scale = false
		MouseData.scrollPane = false
	end
	dgsDxCheckHit(MouseData.hit,mx,my)
	triggerEvent("onClientDgsDxRender",root)
	if DEBUG_MODE then
		dxDrawText("Thisdp's Dx Lib(DGS)",6,sH*0.4-114,sW,sH,tocolor(0,0,0,255))
		dxDrawText("Thisdp's Dx Lib(DGS)",5,sH*0.4-115)
		dxDrawText("Version: 2.88",6,sH*0.4-99,sW,sH,tocolor(0,0,0,255))
		dxDrawText("Version: 2.88",5,sH*0.4-100)
		local ticks = getTickCount()-tk
		dxDrawText("Render Time: "..ticks.." ms",11,sH*0.4-84,sW,sH,tocolor(0,0,0,255))
		dxDrawText("Render Time: "..ticks.." ms",10,sH*0.4-85)
		dxDrawText("Enter: "..tostring(MouseData.hit),11,sH*0.4-69,sW,sH,tocolor(0,0,0,255))
		dxDrawText("Enter: "..tostring(MouseData.hit),10,sH*0.4-70)
		dxDrawText("Click:",11,sH*0.4-54,sW,sH,tocolor(0,0,0,255))
		dxDrawText("Click:",10,sH*0.4-55)
		dxDrawText("  Left: "..tostring(MouseData.clickl),11,sH*0.4-39,sW,sH,tocolor(0,0,0,255))
		dxDrawText("  Left: "..tostring(MouseData.clickl),10,sH*0.4-40)
		dxDrawText("  Right: "..tostring(MouseData.clickr),11,sH*0.4-24,sW,sH,tocolor(0,0,0,255))
		dxDrawText("  Right: "..tostring(MouseData.clickr),10,sH*0.4-25)
		DGSCount = 0
		for k,v in ipairs(dgsType) do
			DGSCount = DGSCount+#getElementsByType(v)
			local x = 15
			if v == "dgs-dxtab" or v == "dgs-dxcombobox-Box" then
				x = 30
			end
			dxDrawText(v.." : "..#getElementsByType(v),x+1,sH*0.4+15*k+6,sW,sH,tocolor(0,0,0,255))
			dxDrawText(v.." : "..#getElementsByType(v),x,sH*0.4+15*k+5)
		end
		dxDrawText("Elements Shows: "..DGSShow,11,sH*0.4-9,sW,sH,tocolor(0,0,0,255))
		dxDrawText("Elements Shows: "..DGSShow,10,sH*0.4-10,sW,sH)
		dxDrawText("Elements Counts: "..DGSCount,11,sH*0.4+6,sW,sH,tocolor(0,0,0,255))	
		dxDrawText("Elements Counts: "..DGSCount,10,sH*0.4+5,sW,sH)
	
		Resource = 0
		ResCount = 0
		for ka,va in pairs(resourceDxGUI) do
			if type(ka) == "userdata" and va then
				Resource = Resource+#va
				ResCount = ResCount +1
				dxDrawText(getResourceName(ka).." : "..#va,201,sH*0.4+15*(ResCount+1)+1,sW,sH,tocolor(0,0,0,255))
				dxDrawText(getResourceName(ka).." : "..#va,200,sH*0.4+15*(ResCount+1))
			end
		end
		dxDrawText("Resource Elements("..ResCount.."):",201,sH*0.4+16,sW,sH,tocolor(0,0,0,255))
		dxDrawText("Resource Elements("..ResCount.."):",200,sH*0.4+15)
	end
	MouseData.hit = false
end

function getColorAlpha(color)
	return bitExtract(color,24,8)
end

function setColorAlpha(color,alpha)
	return bitReplace(color,alpha,24,8)
end

function applyColorAlpha(color,alpha)
	return bitReplace(color,bitExtract(color,24,8)*alpha,24,8)
end

function renderGUI(v,mx,my,enabled,rndtgt,OffsetX,OffsetY,galpha,visible)
	if DEBUG_MODE then
		DGSShow = DGSShow+1
	end
	local enabled = enabled and dgsElementData[v].enabled
	if dgsElementData[v].visible and visible and isElement(v) then
		visible = dgsElementData[v].visible
		local dxType = dgsGetType(v)
		if dxType == "dgs-dxscrollbar" then
			local pnt = dgsElementData[v].parent_sp
			if pnt and not dgsElementData[pnt].visible then
				return
			end
		end
		local parent,children,galpha = FatherTable[v] or false,ChildrenTable[v] or {},dgsElementData[v].alpha*galpha
		dxSetRenderTarget(rndtgt)
		local x,y = dgsGetPosition(v,false,true)
		local w,h = unpack(dgsElementData[v].absSize or {})
		triggerEvent("onClientDgsPreRender",v,x,y,w,h)
		local isRenderTarget = (not rndtgt) and true or false
		self = v
		local rendSet = not DEBUG_MODE and isRenderTarget
		if dxType == "dgs-dxwindow" then
			if x and y then
				local img = dgsElementData[v].image
				local color = dgsElementData[v].color
				color = applyColorAlpha(color,galpha)
				local titimg,titcolor,titsize = dgsElementData[v].titimage,dgsElementData[v].titcolor,dgsElementData[v].titlesize
				titcolor = applyColorAlpha(titcolor,galpha)
				if img then
					dxDrawImage(x,y+titsize,w,h-titsize,img,0,0,0,color,not DEBUG_MODE)
				else
					dxDrawRectangle(x,y+titsize,w,h-titsize,color,not DEBUG_MODE)
				end
				if titimg then
					dxDrawImage(x,y,w,titsize,titimg,0,0,0,titcolor,not DEBUG_MODE)
				else
					dxDrawRectangle(x,y,w,titsize,titcolor,not DEBUG_MODE)
				end
				local font = dgsElementData[v].font or systemFont
				local titnamecolor = dgsElementData[v].titnamecolor
				titnamecolor = applyColorAlpha(titnamecolor,galpha)
				local txtSizX,txtSizY = dgsElementData[v].textsize[1],dgsElementData[v].textsize[2] or dgsElementData[v].textsize[1]
				dxDrawText(dgsElementData[v].text,x,y,x+w,y+titsize,titnamecolor,txtSizX,txtSizY,systemFont,"center","center",true,false,not DEBUG_MODE,dgsElementData[v].colorcoded)
				if enabled then
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
				local colors,imgs = dgsElementData[v].color,dgsElementData[v].image
				local colorimgid = 1
				if MouseData.enter == v then
					colorimgid = 2
					if dgsElementData[v].clickType == 1 then
						if MouseData.clickl == v then
							colorimgid = 3
						end
					elseif dgsElementData[v].clickType == 2 then
						if MouseData.clickr == v then
							colorimgid = 3
						end
					else
						if MouseData.clickl == v or MouseData.clickr == v then
							colorimgid = 3
						end
					end
				end
				if imgs[colorimgid] then
					dxDrawImage(x,y,w,h,imgs[colorimgid],0,0,0,applyColorAlpha(colors[colorimgid],galpha),rendSet)
				else
					dxDrawRectangle(x,y,w,h,applyColorAlpha(colors[colorimgid],galpha),rendSet)
				end
				local text = dgsElementData[v].text
				if #text ~= 0 then
					local font = dgsElementData[v].font or systemFont
					local txtSizX,txtSizY = dgsElementData[v].textsize[1],dgsElementData[v].textsize[2] or dgsElementData[v].textsize[1]
					local txtoffsets = {0,0}
					local clip = dgsElementData[v].clip
					local wordbreak = dgsElementData[v].wordbreak
					local colorcoded = dgsElementData[v].colorcoded
					if colorimgid == 3 then
						txtoffsets = dgsElementData[v].clickoffset
					end
					local tplt = dgsElementData[v].rightbottom
					local shadowoffx,shadowoffy,shadowc = dgsElementData[v].shadow[1],dgsElementData[v].shadow[2],dgsElementData[v].shadow[3]
					if shadowoffx and shadowoffy and shadowc then
						shadowc = applyColorAlpha(shadowc,galpha)
						dxDrawText(text,math.floor(x+txtoffsets[1])+shadowoffx,math.floor(y+txtoffsets[2])+shadowoffy,x+w+shadowoffx-2,y+h+shadowoffy-1,tocolor(0,0,0,255*galpha),txtSizX,txtSizY,font,tplt[1],tplt[2],clip,wordbreak,rendSet,colorcoded)
					end
					dxDrawText(text,math.floor(x+txtoffsets[1]),math.floor(y+txtoffsets[2]),x+w-1,y+h-1,applyColorAlpha(dgsElementData[v].textcolor,galpha),txtSizX,txtSizY,font,tplt[1],tplt[2],clip,wordbreak,rendSet,colorcoded)
				end
				if enabled then
					if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
						MouseData.hit = v
					end
				end
			else
				visible = false
			end
		elseif dxType == "dgs-dxcyclehitshape" then
			local x,y,cx,cy = processPositionOffset(v,x,y,w,h,parent,rndtgt,OffsetX,OffsetY)
			if x and y then
				local radius = dgsElementData[v].radius
				if enabled then
					if dgsDxCheckRadius(cx,cy,radius) then
						MouseData.hit = v
						if dgsElementData[v].debug then
							dxDrawCircle(x,y,radius,2,1,0,360,tocolor(255,0,0,255))
						end
					else
						if dgsElementData[v].debug then
							dxDrawCircle(x,y,radius,2,1,0,360)
						end
					end
				end
			else
				visible = false
			end
		elseif dxType == "dgs-dximage" then
			local x,y,cx,cy = processPositionOffset(v,x,y,w,h,parent,rndtgt,OffsetX,OffsetY)
			if x and y then
				local colors,imgs = dgsElementData[v].color,dgsElementData[v].image
				colors = applyColorAlpha(colors,galpha)
				if imgs then
					local sx,sy = unpack(dgsElementData[v].imagesize)
					local px,py = unpack(dgsElementData[v].imagepos)
					local fnc = dgsElementData[v].functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
					if not sx or not sy or not px or not py then
						dxDrawImage(x,y,w,h,imgs,0,0,0,colors,rendSet)
					else
						dxDrawImageSection(x,y,w,h,px,py,sx,sy,imgs,0,0,0,colors,rendSet)
					end
				else
					dxDrawRectangle(x,y,w,h,colors,rendSet)
				end
				if enabled then
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
				local image_f = dgsElementData[v].image_f
				local color_f = dgsElementData[v].color_f
				local image_t = dgsElementData[v].image_t
				local color_t = dgsElementData[v].color_t
				local rbParent = dgsElementData[v].rbParent
				local image,color
				local _buttonSize = dgsElementData[v].buttonsize
				local buttonSize = _buttonSize[2] and _buttonSize[1]*h or _buttonSize[1]
				if dgsElementData[rbParent].RadioButton == v then
					image = image_t
					color = color_t
				else
					image = image_f
					color = color_f
				end
				local colorimgid = 1
				if MouseData.enter == v then
					colorimgid = 2
					if dgsElementData[v].clickType == 1 then
						if MouseData.clickl == v then
							colorimgid = 3
						end
					elseif dgsElementData[v].clickType == 2 then
						if MouseData.clickr == v then
							colorimgid = 3
						end
					else
						if MouseData.clickl == v or MouseData.clickr == v then
							colorimgid = 3
						end
					end
				end
				if image[colorimgid] then
					dxDrawImage(x,y+h/2-buttonSize/2,buttonSize,buttonSize,image[colorimgid],0,0,0,applyColorAlpha(color[colorimgid],galpha),rendSet)
				else
					dxDrawRectangle(x,y+h/2-buttonSize/2,buttonSize,buttonSize,applyColorAlpha(color[colorimgid],galpha),rendSet)
				end
				local font = dgsElementData[v].font or systemFont
				local txtSizX,txtSizY = dgsElementData[v].textsize[1],dgsElementData[v].textsize[2] or dgsElementData[v].textsize[1]
				local clip = dgsElementData[v].clip
				local wordbreak = dgsElementData[v].wordbreak
				local _textImageSpace = dgsElementData[v].textImageSpace
				local textImageSpace = _textImageSpace[2] and _textImageSpace[1]*w or _textImageSpace[1]
				local colorcoded = dgsElementData[v].colorcoded
				local tplt = dgsElementData[v].rightbottom
 				local shadowoffx,shadowoffy,shadowc = dgsElementData[v].shadow[1],dgsElementData[v].shadow[2],dgsElementData[v].shadow[3]
				local px = x+buttonSize+textImageSpace
				if shadowoffx and shadowoffy and shadowc then
					shadowc = applyColorAlpha(shadowc,galpha)
					dxDrawText(dgsElementData[v].text,px+shadowoffx,y+shadowoffy,px+w+shadowoffx-2,y+h+shadowoffy-1,tocolor(0,0,0,255*galpha),txtSizX,txtSizY,font,tplt[1],tplt[2],clip,wordbreak,rendSet,colorcoded)
				end
				dxDrawText(dgsElementData[v].text,px,y,px+w-1,y+h-1,applyColorAlpha(dgsElementData[v].textcolor,galpha),txtSizX,txtSizY,font,tplt[1],tplt[2],clip,wordbreak,rendSet,colorcoded)
				if enabled then
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
				local image_f = dgsElementData[v].image_f
				local color_f = dgsElementData[v].color_f
				local image_t = dgsElementData[v].image_t
				local color_t = dgsElementData[v].color_t
				local image_i = dgsElementData[v].image_i
				local color_i = dgsElementData[v].color_i
				local image,color
				local _buttonSize = dgsElementData[v].buttonsize
				local buttonSize = _buttonSize[2] and _buttonSize[1]*h or _buttonSize[1]
				if dgsElementData[v].CheckBoxState == true then
					image = image_t
					color = color_t
				elseif dgsElementData[v].CheckBoxState == false then 
					image = image_f
					color = color_f
				else
					image = image_i
					color = color_i
				end
				local colorimgid = 1
				if MouseData.enter == v then
					colorimgid = 2
					if dgsElementData[v].clickType == 1 then
						if MouseData.clickl == v then
							colorimgid = 3
						end
					elseif dgsElementData[v].clickType == 2 then
						if MouseData.clickr == v then
							colorimgid = 3
						end
					else
						if MouseData.clickl == v or MouseData.clickr == v then
							colorimgid = 3
						end
					end
				end
				if image[colorimgid] then
					dxDrawImage(x,y+h/2-buttonSize/2,buttonSize,buttonSize,image[colorimgid],0,0,0,applyColorAlpha(color[colorimgid],galpha),rendSet)
				else
					dxDrawRectangle(x,y+h/2-buttonSize/2,buttonSize,buttonSize,applyColorAlpha(color[colorimgid],galpha),rendSet)
				end
				local font = dgsElementData[v].font or systemFont
				local txtSizX,txtSizY = dgsElementData[v].textsize[1],dgsElementData[v].textsize[2] or dgsElementData[v].textsize[1]
				local clip = dgsElementData[v].clip
				local wordbreak = dgsElementData[v].wordbreak
				local _textImageSpace = dgsElementData[v].textImageSpace
				local textImageSpace = _textImageSpace[2] and _textImageSpace[1]*w or _textImageSpace[1]
				local colorcoded = dgsElementData[v].colorcoded
				local tplt = dgsElementData[v].rightbottom
 				local shadowoffx,shadowoffy,shadowc = dgsElementData[v].shadow[1],dgsElementData[v].shadow[2],dgsElementData[v].shadow[3]
				local px = x+buttonSize+textImageSpace
				if shadowoffx and shadowoffy and shadowc then
					shadowc = applyColorAlpha(shadowc,galpha)
					dxDrawText(dgsElementData[v].text,px+shadowoffx,y+shadowoffy,px+w+shadowoffx-2,y+h+shadowoffy-1,tocolor(0,0,0,255*galpha),txtSizX,txtSizY,font,tplt[1],tplt[2],clip,wordbreak,rendSet,colorcoded)
				end
				dxDrawText(dgsElementData[v].text,px,y,px+w-1,y+h-1,applyColorAlpha(dgsElementData[v].textcolor,galpha),txtSizX,txtSizY,font,tplt[1],tplt[2],clip,wordbreak,rendSet,colorcoded)
				if enabled then
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
				local imagebg = dgsElementData[v].imagebg
				local colorbg = dgsElementData[v].colorbg
				colorbg = applyColorAlpha(colorbg,galpha)
				local edit = dgsElementData[v].edit
				if not isElement(edit) then
					destroyElement(v)
					return
				end
				local _ = isMainMenuActive() and guiSetVisible(edit,false) or guiSetVisible(edit,true)
				guiSetPosition(edit,cx,cy,false)
				guiSetSize(edit,w,h,false)
				local text = dgsElementData[v].text
				local fnc = dgsElementData[v].functions
				if type(fnc) == "table" then
					text = fnc[1](unpack(fnc[2]))
				end
				guiSetText(edit,text)
				if dgsElementData[v].masked then
					text = string.rep(dgsElementData[v].maskText,utf8.len(text))
				end
				if MouseData.nowShow == v then
					if getKeyState("lctrl") and getKeyState("a") then
						dgsSetData(v,"cursorposXY",0)
						dgsSetData(v,"selectfrom",utf8.len(text))
					end
				end
				local cursorPos = dgsElementData[v].cursorpos
				local selectFro = dgsElementData[v].selectfrom
				local selectcolor = dgsElementData[v].selectcolor
				guiEditSetCaretIndex(edit,cursorPos)
				guiSetProperty(edit,"SelectionStart",cursorPos)
				guiSetProperty(edit,"SelectionLength",selectFro-cursorPos)
				local font = dgsElementData[v].font or systemFont
				local txtSizX,txtSizY = dgsElementData[v].textsize[1],dgsElementData[v].textsize[2] or dgsElementData[v].textsize[1]
				local renderTarget = dgsElementData[v].renderTarget
				if isElement(renderTarget) then
					local selectMode = dgsElementData[v].selectmode
					local textcolor = dgsElementData[v].textcolor
					local width = dxGetTextWidth(utf8.sub(text,0,cursorPos),txtSizX,font)
					local selx = 0
					if selectFro-cursorPos > 0 then
						selx = dxGetTextWidth(utf8.sub(text,cursorPos+1,selectFro),txtSizX,font)
					elseif selectFro-cursorPos < 0 then
						selx = -dxGetTextWidth(utf8.sub(text,selectFro+1,cursorPos),txtSizX,font)
					end
					local showPos = dgsElementData[v].showPos
					dxSetRenderTarget(renderTarget,true)
					if selectMode then
						dxDrawRectangle(width+showPos,2,selx,h-4,selectcolor)
					end
					local bools = dxDrawText(text,showPos,0,dxGetTextWidth(text,txtSizX,font),h,textcolor,txtSizX,txtSizY,font,"left","center",true,false,false,false)

					if not selectMode then
						dxDrawRectangle(width+showPos,2,selx,h-4,selectcolor)
					end
					dxSetRenderTarget(rndtgt)
					if imagebg then
						dxDrawImage(x,y,w,h,imagebg,0,0,0,colorbg,rendSet)
					else
						dxDrawRectangle(x,y,w,h,colorbg,rendSet)
					end
					if MouseData.nowShow == v and MouseData.editCursor then
						local cursorStyle = dgsElementData[v].cursorStyle
						if cursorStyle == 0 then
							if -showPos <= width then
								dxDrawLine(x+width+showPos+2,y+2,x+width+showPos+2,y+h-4,black,dgsElementData[v].cursorThick,isRenderTarget)
							end
						elseif cursorStyle == 1 then
							local cursorWidth = dxGetTextWidth(utf8.sub(text,cursorPos+1,cursorPos+1),txtSizX,font)
							if cursorWidth == 0 then
								cursorWidth = txtSizX*8
							end
							if -showPos+cursorWidth <= width then
								local offset = dgsElementData[v].cursorOffset
								dxDrawLine(x+width+showPos+2,y+h-4+offset,x+width+showPos+cursorWidth+2,y+h-4+offset,black,dgsElementData[v].cursorThick,isRenderTarget)
							end
						end
					end
					local px,py,pw,ph = useFloor and math.floor(x+2) or x+2, useFloor and math.floor(y) or y, useFloor and math.floor(w-4) or w-4, useFloor and math.floor(h) or h
					dxDrawImage(px,py,pw,ph,renderTarget,0,0,0,tocolor(255,255,255,255*galpha),rendSet)
				end
				local side = dgsElementData[v].side
				if side ~= 0 then
					local sidecolor = dgsElementData[v].sidecolor
					dxDrawLine(x,y+side/2-1,x+w,y+side/2-1,sidecolor,side,isRenderTarget)
					dxDrawLine(x+side/2-1,y-1,x+side/2-1,y+h,sidecolor,side,isRenderTarget)
					dxDrawLine(x+w-side/2,y,x+w-side/2,y+h,sidecolor,side,isRenderTarget)
					dxDrawLine(x,y+h-side/2,x+w,y+h-side/2,sidecolor,side,isRenderTarget)
				end
				if enabled then
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
				local imagebg = dgsElementData[v].imagebg
				local colorbg = dgsElementData[v].colorbg
				colorbg = setColorAlpha(colorbg,getColorAlpha(colorbg)*galpha)
				local memo = dgsElementData[v].memo
				if not isElement(memo) then
					destroyElement(v)
				end
				local _ = isMainMenuActive() and guiSetVisible(memo,false) or guiSetVisible(memo,true)
				guiSetPosition(memo,cx,cy,false)
				guiSetSize(memo,w,h,false)
				local text = dgsElementData[v].text
				local allLine = #text
				if MouseData.nowShow == v then
					if getKeyState("lctrl") and getKeyState("a") then
						dgsSetData(v,"cursorposXY",{0,1})
						dgsSetData(v,"selectfrom",{utf8.len(text[allLine]),allLine})
					end
				end
				local cursorPos = dgsElementData[v].cursorposXY
				local selectFro = dgsElementData[v].selectfrom
				local selectcolor = dgsElementData[v].selectcolor
				local font = dgsElementData[v].font or systemFont
				local txtSizX,txtSizY = dgsElementData[v].textsize[1],dgsElementData[v].textsize[2]
				local renderTarget = dgsElementData[v].renderTarget
				local fontHeight = dxGetFontHeight(dgsElementData[v].textsize[2],font)
				if isElement(renderTarget) then
					local selectMode = dgsElementData[v].selectmode
					local textcolor = dgsElementData[v].textcolor
					local showLine = dgsElementData[v].showLine
					local canHoldLines = math.floor((h-4)/fontHeight)
					canHoldLines = canHoldLines > allLine and allLine or canHoldLines
					local selPosStart,selPosEnd,selStart,selEnd
					dxSetRenderTarget(renderTarget,true)
					if allLine > 0 then
						local toShowLine = showLine+canHoldLines
						toShowLine = toShowLine > #text and #text or toShowLine
						local offset = dgsElementData[v].showPos
						if cursorPos[2] == selectFro[2] then
							if selectFro[1]>cursorPos[1] then
								selPosStart = cursorPos[1]
								selPosEnd = selectFro[1]
							else
								selPosStart = selectFro[1]
								selPosEnd = cursorPos[1]
							end
							if selectFro[2]>cursorPos[2] then
								selStart = cursorPos[2]
								selEnd = selectFro[2]
							else
								selStart = selectFro[2]
								selEnd = cursorPos[2]
							end
							local startx = dxGetTextWidth(utf8.sub(text[selStart],0,selPosStart),txtSizX,font)
							local selx = dxGetTextWidth(utf8.sub(text[selStart],selPosStart+1,selPosEnd),txtSizX,font)
							dxDrawRectangle(offset+startx,2+(selStart-showLine)*fontHeight,selx,fontHeight-4,selectcolor)
						else
							if selectFro[2]>cursorPos[2] then
								selStart = cursorPos[2]
								selEnd = selectFro[2]
								selPosStart = cursorPos[1]
								selPosEnd = selectFro[1]
							else
								selStart = selectFro[2]
								selEnd = cursorPos[2]
								selPosStart = selectFro[1]
								selPosEnd = cursorPos[1]
							end
							local startx = dxGetTextWidth(utf8.sub(text[selStart],0,selPosStart),txtSizX,font)
							for i=selStart > showLine and selStart or showLine,selEnd < toShowLine and selEnd or toShowLine do
								if i ~= selStart and i ~= selEnd then
									local selx = dxGetTextWidth(text[i],txtSizX,font)
									dxDrawRectangle(offset,2+(i-showLine)*fontHeight,selx,fontHeight-4,selectcolor)
								elseif i == selStart then
									local selx = dxGetTextWidth(utf8.sub(text[i],selPosStart+1),txtSizX,font)
									dxDrawRectangle(offset+startx,2+(i-showLine)*fontHeight,selx,fontHeight-4,selectcolor)
								elseif i == selEnd then
									local selx = dxGetTextWidth(utf8.sub(text[i],0,selPosEnd),txtSizX,font)
									dxDrawRectangle(offset,2+(i-showLine)*fontHeight,selx,fontHeight-4,selectcolor)
								end
							end
						end
						for i=showLine,toShowLine do
							local ypos = (i-showLine)*fontHeight
							dxDrawText(text[i],offset,ypos,dxGetTextWidth(text[i],txtSizX,font),fontHeight+ypos,textcolor,txtSizX,txtSizY,font,"left","top",true,false,false,false)
						end
					end
					dxSetRenderTarget(rndtgt)
					if imagebg then
						dxDrawImage(x,y,w,h,imagebg,0,0,0,colorbg,rendSet)
					else
						dxDrawRectangle(x,y,w,h,colorbg,rendSet)
					end
					dxDrawImageSection(x+2,y,w-4,h,0,0,w-4,h,renderTarget,0,0,0,tocolor(255,255,255,255*galpha),rendSet)
					if MouseData.nowShow == v and MouseData.memoCursor then
						local theText = text[cursorPos[2]]
						local cursorPX = cursorPos[1]
						local showLine = dgsElementData[v].showLine
						local currentLine = dgsElementData[v].cursorposXY[2]
						local lineStart = fontHeight*(currentLine-showLine)
						local width = dxGetTextWidth(utfSub(theText,1,cursorPX),txtSizX,font)
						local showPos = dgsElementData[v].showPos
						local cursorStyle = dgsElementData[v].cursorStyle
						if cursorStyle == 0 then
							dxDrawLine(x+width+showPos+2,y+lineStart+1,x+width+showPos+2,y+lineStart+fontHeight-2,black,dgsElementData[v].cursorThick,isRenderTarget)
						elseif cursorStyle == 1 then
							local cursorWidth = dxGetTextWidth(utf8.sub(theText,cursorPX+1,cursorPX+1),txtSizX,font)
							if cursorWidth == 0 then
								cursorWidth = txtSizX*8
							end
							local offset = dgsElementData[v].cursorOffset
							dxDrawLine(x+width+showPos+2,y+h-4+offset,x+width+showPos+cursorWidth+2,y+h-4+offset,black,dgsElementData[v].cursorThick,isRenderTarget)
						end
					end	
				end
				
				local side = dgsElementData[v].side
				if side ~= 0 then
					local sidecolor = dgsElementData[v].sidecolor
					dxDrawLine(x,y+side/2-1,x+w,y+side/2-1,sidecolor,side,isRenderTarget)
					dxDrawLine(x+side/2-1,y-1,x+side/2-1,y+h,sidecolor,side,isRenderTarget)
					dxDrawLine(x+w-side/2,y,x+w-side/2,y+h,sidecolor,side,isRenderTarget)
					dxDrawLine(x,y+h-side/2,x+w,y+h-side/2,sidecolor,side,isRenderTarget)
				end
				if enabled then
					if mx >= cx-2 and mx<= cx+w-1 and my >= cy-2 and my <= cy+h-1 then
						MouseData.hit = v
					end
				end
			else
				visible = false
			end
		elseif dxType == "dgs-dxscrollpane" then
			local x,y,cx,cy = processPositionOffset(v,x,y,w,h,parent,rndtgt,OffsetX,OffsetY)
			if x and y then
				local postgui = isRenderTarget
				if rndtgt then
					if rndtgt == dgsElementData[v].renderTarget_parent then
						postgui = true
					end
				end
				rndtgt = dgsElementData[v].renderTarget_parent
				dxSetRenderTarget(rndtgt,true)
				dxSetRenderTarget()
				local scrollbar = dgsElementData[v].scrollbars
				local scbThick = dgsElementData[v].scrollBarThick
				local scbstate = {dgsElementData[scrollbar[1]].visible,dgsElementData[scrollbar[2]].visible}
				local xthick = scbstate[1] and scbThick or 0
				local ythick = scbstate[2] and scbThick or 0
				local maxSize = dgsElementData[v].maxChildSize
				local relSizX,relSizY = w-xthick,h-ythick
				local maxX,maxY = (maxSize[1]-relSizX),(maxSize[2]-relSizY)
				maxX,maxY = maxX > 0 and maxX or 0,maxY > 0 and maxY or 0
				OffsetX = scbstate[2] and -maxX*dgsElementData[scrollbar[2]].position/100 or 0
				OffsetY = scbstate[1] and -maxY*dgsElementData[scrollbar[1]].position/100 or 0
				if enabled then
					if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
						MouseData.scrollPane = v
						MouseData.hit = v
						if mx >= cx+relSizX and my >= cy+relSizY and scbstate[1] and scbstate[2] then
							enabled = false
						end
					else
						enabled = false
					end
				end
				dxDrawImage(x,y,relSizX,relSizY,rndtgt,0,0,0,tocolor(255,255,255,255*galpha),postgui)
			end
		elseif dxType == "dgs-dxscrollbar" then
			local x,y,cx,cy = processPositionOffset(v,x,y,w,h,parent,rndtgt,OffsetX,OffsetY)
			if x and y then
				local ax,ay = dgsGetPosition(v,false)
				local voh = dgsElementData[v].voh
				local imgs = dgsElementData[v].imgs
				local pos = dgsElementData[v].position
				local length,lrlt = unpack(dgsElementData[v].length)
				local colors = {dgsElementData[v].colorn,dgsElementData[v].colore,dgsElementData[v].colorc}
				local newColor_a = {}
				for c_k,c_v in pairs(colors) do
					local newColor_b = {}
					for c_kk,c_vv in pairs(c_v) do
						newColor_b[c_kk] = applyColorAlpha(c_vv,galpha)
					end
					newColor_a[c_k] = newColor_b
				end
				colors = newColor_a
				local colorimgid = {1,1,1,1}
				local slotRange
				local scrollArrow =  dgsElementData[v].scrollArrow
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
							colorimgid[MouseData.enterData] = 2
						end
					else
						colorimgid[MouseData.clickData] = 3
						if MouseData.clickData == 2 then
							local position
							local mvx,mvy = unpack(MouseData.Move)
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
				if voh then
					if imgs[3] then
						dxDrawImage(x+arrowPos,y,w-2*arrowPos,h,imgs[3],0,0,0,colors[1][3],rendSet)
					else
						dxDrawRectangle(x+arrowPos,y,w-2*arrowPos,h,colors[1][3],rendSet)
					end
					if scrollArrow then
						dxDrawImage(x,y,h,h,imgs[1],270,0,0,colors[colorimgid[1]][1],rendSet)
						dxDrawImage(x+w-h,y,h,h,imgs[1],90,0,0,colors[colorimgid[4]][1],rendSet)
					end
					if imgs[2] then
						dxDrawImage(x+arrowPos+pos*0.01*csRange,y,cursorRange,h,imgs[2],270,0,0,colors[colorimgid[2]][2],rendSet)
					else
						dxDrawRectangle(x+arrowPos+pos*0.01*csRange,y,cursorRange,h,colors[colorimgid[2]][2],rendSet)
					end
				else
					if imgs[3] then
						dxDrawImage(x,y+arrowPos,w,h-2*arrowPos,imgs[3],0,0,0,colors[1][3],rendSet)
					else
						dxDrawRectangle(x,y+arrowPos,w,h-2*arrowPos,colors[1][3],rendSet)
					end
					if scrollArrow then
						dxDrawImage(x,y,w,w,imgs[1],0,0,0,colors[colorimgid[1]][1],rendSet)
						dxDrawImage(x,y+h-w,w,w,imgs[1],180,0,0,colors[colorimgid[4]][1],rendSet)
					end
					if imgs[2] then
						dxDrawImage(x,y+arrowPos+pos*0.01*csRange,w,cursorRange,imgs[2],270,0,0,colors[colorimgid[2]][2],rendSet)
					else
						dxDrawRectangle(x,y+arrowPos+pos*0.01*csRange,w,cursorRange,colors[colorimgid[2]][2],rendSet)
					end
				end
				if enabled then
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
				local rightbottom = dgsElementData[v].rightbottom
				local colors,imgs = dgsElementData[v].textcolor,dgsElementData[v].image
				colors = applyColorAlpha(colors,galpha)
				local colorimgid = 1
				if MouseData.enter == v then
					colorimgid = 2
					if MouseData.clickl == v then
						colorimgid = 3
					end
				end
				local font = dgsElementData[v].font or systemFont
				local clip = dgsElementData[v].clip
				local wordbreak = dgsElementData[v].wordbreak
				local shadowoffx,shadowoffy,shadowc = unpack(dgsElementData[v].shadow)
				local text
				local fnc = dgsElementData[v].functions
				if type(fnc) == "table" then
					text = fnc[1](unpack(fnc[2]))
				else
					text = dgsElementData[v].text
				end
				local colorcoded = dgsElementData[v].colorcoded
				local txtSizX,txtSizY = dgsElementData[v].textsize[1],dgsElementData[v].textsize[2] or dgsElementData[v].textsize[1]
				if shadowoffx and shadowoffy and shadowc then
					shadowc = applyColorAlpha(shadowc,galpha)
					dxDrawText(colorcoded and text:gsub('#%x%x%x%x%x%x','') or text,x+shadowoffx,y+shadowoffy,x+w,y+h,shadowc,txtSizX,txtSizY,font,rightbottom[1],rightbottom[2],clip,wordbreak,rendSet,false,true)
				end
				dxDrawText(text,x,y,x+w,y+h,colors,txtSizX,txtSizY,font,rightbottom[1],rightbottom[2],clip,wordbreak,rendSet,colorcoded,true)
				if enabled then
					if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
						MouseData.hit = v
					end
				end
			else
				visible = false
			end
		elseif dxType == "dgs-dxgridlist" then
			local x,y,cx,cy = processPositionOffset(v,x,y,w,h,parent,rndtgt,OffsetX,OffsetY)
			if x and y then
				local DataTab = dgsElementData[v]
				local bgcolor,bgimg = DataTab.bgcolor,DataTab.bgimage
				local columncolor,columnimg = DataTab.columncolor,DataTab.columnimage
				columncolor = applyColorAlpha(columncolor,galpha)
				bgcolor = applyColorAlpha(bgcolor,galpha)
				local columnHeight = DataTab.columnHeight
				if MouseData.enter == v then
					colorimgid = 2
					if MouseData.clickl == v then
						colorimgid = 3
					end
					MouseData.enterData = false
				end
				if bgimg then
					dxDrawImage(x,y+columnHeight,w,h-columnHeight,bgimg,0,0,0,bgcolor,rendSet)
				else
					dxDrawRectangle(x,y+columnHeight,w,h-columnHeight,bgcolor,rendSet)
				end
				if columnimg then
					dxDrawImage(x,y,w,columnHeight,columnimg,0,0,0,columncolor,rendSet)
				else
					dxDrawRectangle(x,y,w,columnHeight,columncolor,rendSet)
				end
				local mode = DataTab.mode
				local columnTextColor = DataTab.columntextcolor
				local font = DataTab.font or systemFont
				local columnData = DataTab.columnData
				local columnRelt = DataTab.columnRelative
				local rowData = DataTab.rowData
				local rowHeight = DataTab.rowHeight
				local scbThick = DataTab.scrollBarThick
				local colorcoded = DataTab.colorcoded
				local shadow = DataTab.rowShadow
				dxSetRenderTarget()
				local rowMoveOffset = DataTab.rowMoveOffset
				local columnMoveOffset = DataTab.columnMoveOffset
				local fnc = dgsElementData[v].functions
				local rowtextx,rowtexty = DataTab.rowtextsize[1],DataTab.rowtextsize[2] or DataTab.rowtextsize[1]
				local columntextx,columntexty = DataTab.columntextsize[1],DataTab.columntextsize[2] or DataTab.columntextsize[1]
				if type(fnc) == "table" then
					fnc[1](unpack(fnc[2]))
				end
				if not mode then
					local whichRowToStart = -math.floor((DataTab.rowMoveOffset+rowHeight)/rowHeight)+1
					local whichRowToEnd = whichRowToStart+math.floor((h-columnHeight-scbThick+rowHeight*2)/rowHeight)-1
					DataTab.FromTo = {whichRowToStart > 0 and whichRowToStart or 1,whichRowToEnd <= #rowData and whichRowToEnd or #rowData}
					local renderTarget = DataTab.renderTarget
					local isDraw1,isDraw2 = isElement(renderTarget[1]),isElement(renderTarget[2])
					dxSetRenderTarget(renderTarget[1],true)
						local sizex,sizey = DataTab.columntextsize[1],DataTab.columntextsize[2]
						local cpos = {}
						local multipiler = columnRelt and (w-scbThick) or 1
						for id,data in ipairs(columnData) do
							local textxSize = data[2]*multipiler
							cpos[id] = columnData[id][3]*multipiler
							if isDraw1 then
								if DataTab.columnShadow then
									dxDrawText(data[1],2+cpos[id]+columnMoveOffset,1,sW,columnHeight,black,columntextx,columntexty,font,"left","center",false,false,false,false,true)
								end
								dxDrawText(data[1],1+cpos[id]+columnMoveOffset,0,sW,columnHeight,columnTextColor,columntextx,columntexty,font,"left","center",false,false,false,false,true)
							end
						end
					dxSetRenderTarget(renderTarget[2],true)
						if MouseData.enter == v then		-------PreSelect
							local ypcolumn = cy+columnHeight
							if mx >= cx and mx <= cx+w and my >= ypcolumn and my <= cy+h-scbThick then
								local toffset = (whichRowToStart*rowHeight)+DataTab.rowMoveOffset
								sid = math.floor((my-ypcolumn-toffset)/rowHeight)+whichRowToStart+1
								if sid <= #rowData then
									DataTab.oPreSelect = sid
									if rowData[sid][-2] then
										DataTab.preSelect = sid
										MouseData.enterData = true
									else
										DataTab.preSelect = -1
									end
								else
									DataTab.preSelect = -1
								end
							else
								DataTab.preSelect = -1
							end
						end
						local preSelect = DataTab.preSelect
						local Select = DataTab.select
						local sectionFont = dgsElementData[v].sectionFont or font
						for i=DataTab.FromTo[1],DataTab.FromTo[2] do
							local lc_rowData = rowData[i]
							local image = lc_rowData[-3]
							local columnOffset = lc_rowData[-4]
							local isSection = lc_rowData[-5]
							local color = lc_rowData[0]
							local rowState = 1
							if i == preSelect then
								rowState = 2
							end
							if i == Select then
								rowState = 3
							end
							if isDraw2 then
								local rowpos = i*rowHeight
								local rowpos_1 = rowpos-rowHeight
								local _x,_y,_sx,_sy = columnMoveOffset+columnOffset,rowpos_1+rowMoveOffset,sW,rowpos+rowMoveOffset
								if #image > 0 then
									dxDrawImage(0,_y,w,rowHeight,image[rowState],0,0,0,color[rowState])
								else
									dxDrawRectangle(0,_y,w,rowHeight,color[rowState])
								end
								for id=1,#columnData do
									local text = lc_rowData[id][1]
									local _txtFont = isSection and sectionFont or (lc_rowData[id][3] or font)
									local _txtScalex = lc_rowData[id][4] or rowtextx
									local _txtScaley = lc_rowData[id][5] or rowtexty
									if text then
										local offset = cpos[id]
										local _x = _x+offset
										local colorcoded = lc_rowData[id][3] == nil and colorcoded or lc_rowData[id][3]
										if shadow then
											if colorcoded then
												text = text:gsub("#%x%x%x%x%x%x","") or text
											end
											dxDrawText(text,_x+shadow[1],_y+shadow[2],_sx+shadow[1],_sy+shadow[2],shadow[3],_txtScalex,_txtScaley,_txtFont,"left","center",false,false,false,false,true)
										end
										dxDrawText(lc_rowData[id][1],_x,_y,_sx,_sy,lc_rowData[id][2],_txtScalex,_txtScaley,_txtFont,"left","center",false,false,false,colorcoded,true)
									end
								end
							end
						end
					dxSetRenderTarget(rndtgt)
					if isElement(renderTarget[2]) then
						dxDrawImage(x,y+columnHeight,w,h-columnHeight-scbThick,renderTarget[2],0,0,0,tocolor(255,255,255,255*galpha),rendSet)
					end
					if isElement(renderTarget[1]) then
						dxDrawImage(x,y,w,columnHeight,renderTarget[1],0,0,0,tocolor(255,255,255,255*galpha),rendSet)
					end
				else
					local whichRowToStart = -math.floor((DataTab.rowMoveOffset+rowHeight)/rowHeight)+2
					local whichRowToEnd = whichRowToStart+math.floor((h-columnHeight-scbThick+rowHeight*2)/rowHeight)-3
					DataTab.FromTo = {whichRowToStart > 0 and whichRowToStart or 1,whichRowToEnd <= #rowData and whichRowToEnd or #rowData}
					local _rowMoveOffset = math.floor(rowMoveOffset/rowHeight)*rowHeight
					
					local whichColumnToStart,whichColumnToEnd = 0,0
					local cpos = {}
					local multipiler = columnRelt and (w-scbThick) or 1
					local ypcolumn = cy+columnHeight
					local _y,_sx = ypcolumn+_rowMoveOffset,cx+w-scbThick
					local column_x
					local allColumnWidth = columnData[#columnData][2]+columnData[#columnData][3]
					local scrollbar = dgsElementData[v].scrollbars[2]
					local scrollPos = dgsElementData[scrollbar].position/100
					for id,data in ipairs(columnData) do
						local textxSize = data[2]*multipiler
						cpos[id] = data[3]*multipiler
						local nextone = 0
						if columnData[id+1] then
							nextone = columnData[id+1][3]/multipiler
						end
						if (data[3]+data[2])/allColumnWidth >= scrollPos then
							whichColumnToStart = whichColumnToStart ~= 0 and whichColumnToStart or id
							whichColumnToEnd = whichColumnToEnd <= whichColumnToStart and whichColumnToStart or id
							if cpos[id]+scrollPos*(allColumnWidth-w+scbThick+10) <= w then
								whichColumnToEnd = id
							end
						end
					end
					column_x = cx-cpos[whichColumnToStart]+cpos[1]
					for i=whichColumnToStart,whichColumnToEnd or #columnData do
						local posx = column_x+cpos[i]
						if DataTab.columnShadow then
							dxDrawText(columnData[i][1],1+posx,1+cy,cx+w-scbThick,ypcolumn,black,columntextx,columntexty,font,"left","center",true,false,rendSet,false,true)
						end
						dxDrawText(columnData[i][1],posx,cy,cx+w-scbThick,ypcolumn,columnTextColor,columntextx,columntexty,font,"left","center",true,false,rendSet,false,true)
					end
					if MouseData.enter == v then		-------PreSelect
						if mx >= cx and mx <= cx+w and my >= ypcolumn and my <= cy+h-scbThick then
							local toffset = (whichRowToStart*rowHeight)+_rowMoveOffset
							sid = math.floor((my-ypcolumn-toffset)/rowHeight)+whichRowToStart+1
							if sid <= #rowData then
								DataTab.oPreSelect = sid
								if rowData[sid][-2] then
									DataTab.preSelect = sid
									MouseData.enterData = true
								else
									DataTab.preSelect = -1
								end
							else
								DataTab.preSelect = -1
							end
						else
							DataTab.preSelect = -1
						end
					end
					for i=DataTab.FromTo[1],DataTab.FromTo[2] do
						local lc_rowData = rowData[i]
						local image = lc_rowData[-3]
						local color = lc_rowData[0]
						local columnOffset = lc_rowData[-4]
						local isSection = lc_rowData[-5]
						local rowState = 1
						if i == DataTab.preSelect then
							rowState = 2
						end
						if i == DataTab.select then
							rowState = 3
						end
						local rowpos = i*rowHeight
						local __x,__y,__sx,__sy = column_x+columnOffset,_y+rowpos-rowHeight,_sx,_y+rowpos
						if #image > 0 then
							dxDrawImage(cx,__y,w,rowHeight,image[rowState],0,0,0,color[rowState],rendSet)
						else
							dxDrawRectangle(cx,__y,w,rowHeight,color[rowState],rendSet)
						end
						for id=whichColumnToStart,whichColumnToEnd do
							local text = lc_rowData[id][1]
							local _txtFont = isSection and sectionFont or (lc_rowData[id][3] or font)
							local _txtScalex = lc_rowData[id][4] or rowtextx
							local _txtScaley = lc_rowData[id][5] or rowtexty
							if text ~= "" then
								local offset = cpos[id]
								local __x = __x+offset
								local colorcoded = lc_rowData[id][3] == nil and colorcoded or lc_rowData[id][3]
								if shadow then
									if colorcoded then
										text = text:gsub("#%x%x%x%x%x%x","") or text
									end
									dxDrawText(text,__x+shadow[1],__y+shadow[2],__sx+shadow[1],__sy+shadow[2],shadow[3],_txtScalex,_txtScaley,_txtFont,"left","center",true,false,rendSet,false,true)
								end
								dxDrawText(lc_rowData[id][1],__x,__y,__sx,__sy,lc_rowData[id][2],_txtScalex,_txtScaley,_txtFont,"left","center",true,false,rendSet,colorcoded,true)
							end
						end
					end
				end
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
				local bgcolor = dgsElementData[v].bgcolor
				local barcolor = dgsElementData[v].barcolor
				bgcolor = applyColorAlpha(bgcolor,galpha)
				barcolor = applyColorAlpha(barcolor,galpha)
				local bgimg = dgsElementData[v].bgimg
				local barimg = dgsElementData[v].barimg
				local barmode = dgsElementData[v].barmode
				local udspace = dgsElementData[v].udspace
				local lrspace = dgsElementData[v].lrspace
				local udvalue = udspace[2] and udspace[1]*h or udspace[1]
				local lrvalue = lrspace[2] and lrspace[1]*w or lrspace[1]
				if bgimg then
					local sx,sy = dgsElementData[v].imagesize[1],dgsElementData[v].imagesize[2]
					local px,py = dgsElementData[v].imagepos[1],dgsElementData[v].imagepos[2]
					dxDrawImage(x,y,w,h,bgimg,0,0,0,bgcolor,rendSet)
				else
					dxDrawRectangle(x,y,w,h,bgcolor,rendSet)
				end
				local percent = dgsElementData[v].progress/100
				if barimg then
					local sx,sy = dgsElementData[v].barsize[1],dgsElementData[v].barsize[2]
					local fnc = dgsElementData[v].functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
					if not sx or not sy or not barmode then
						dxDrawImage(x+lrvalue,y+udvalue,(w-lrvalue*2)*percent,h-udvalue*2,barimg,0,0,0,barcolor,rendSet)
					else
						dxDrawImageSection(x+lrvalue,y+udvalue,(w-lrvalue*2)*percent,h-udvalue*2,1,1,sx*percent,sy,barimg,0,0,0,barcolor,rendSet)
					end
				else
					dxDrawRectangle(x+lrvalue,y+udvalue,(w-lrvalue*2)*percent,h-udvalue*2,barcolor,rendSet)
				end
				if enabled then
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
				local postgui = rendSet
				local colors,imgs = dgsElementData[v].color,dgsElementData[v].image
				local colorimgid = 1
				local textbox = dgsElementData[v].textbox
				local buttonLen_t = dgsElementData[v].buttonLen
				local buttonLen
				local bgcolor = dgsElementData[v].combobgColor
				local bgimg = dgsElementData[v].combobgImage
				if textbox then
					buttonLen = buttonLen_t[2] and buttonLen_t[1]*h or buttonLen_t[1]
				else
					buttonLen = w
				end
				if MouseData.enter == v then
					colorimgid = 2
					if dgsElementData[v].clickType == 1 then
						if MouseData.clickl == v then
							colorimgid = 3
						end
					elseif dgsElementData[v].clickType == 2 then
						if MouseData.clickr == v then
							colorimgid = 3
						end
					else
						if MouseData.clickl == v or MouseData.clickr == v then
							colorimgid = 3
						end
					end
				end
				
				if imgs[colorimgid] then
					dxDrawImage(x+w-buttonLen,y,buttonLen,h,imgs[colorimgid],0,0,0,applyColorAlpha(colors[colorimgid],galpha),postgui)
				else
					dxDrawRectangle(x+w-buttonLen,y,buttonLen,h,applyColorAlpha(colors[colorimgid],galpha),postgui)
				end
				local arrowColor = dgsElementData[v].arrowColor
				local arrowWidth = dgsElementData[v].arrowWidth
				local arrowDistance = dgsElementData[v].arrowDistance/2*buttonLen
				local arrowHeight = dgsElementData[v].arrowHeight/2*h
				local textBoxLen = w-buttonLen
				if bgimg then
					dxDrawImage(x,y,textBoxLen,h,bgimg,0,0,0,applyColorAlpha(bgcolor,galpha),postgui)
				else
					dxDrawRectangle(x,y,textBoxLen,h,applyColorAlpha(bgcolor,galpha),postgui)
				end
				local shader = dgsElementData[v].arrow
				local listState = dgsElementData[v].listState
				if dgsElementData[v].listStateAnim ~= listState then
					local stat = dgsElementData[v].listStateAnim+dgsElementData[v].listState*0.08
					dgsElementData[v].listStateAnim = listState == -1 and math.max(stat,listState) or math.min(stat,listState)
				end
				if dgsElementData[v].arrowSettings then
					dxSetShaderValue(shader,dgsElementData[v].arrowSettings[1],dgsElementData[v].arrowSettings[2]*dgsElementData[v].listStateAnim)
				end
				dxSetShaderValue(shader,"_color",{1,1,1,galpha})
				dxSetShaderValue(shader,"ocolor",{1,0,0,galpha})
				dxDrawImage(x+textBoxLen,y,buttonLen,h,shader,0,0,0,applyColorAlpha(arrowColor,galpha),postgui)
				if textbox then
					local textSide = dgsElementData[v].comboTextSide
					local font = dgsElementData[v].font or systemFont
					local textcolor = dgsElementData[v].textcolor
					local rb = dgsElementData[v].rightbottom
					local txtSizX,txtSizY = dgsElementData[v].textsize[1],dgsElementData[v].textsize[2] or dgsElementData[v].textsize[1]
					local colorcoded = dgsElementData[v].colorcoded
					local shadow = dgsElementData[v].shadow
					local wordbreak = dgsElementData[v].wordbreak
					local selection = dgsElementData[v].select
					local itemData = dgsElementData[v].itemData
					local sele = itemData[selection]
					local text = sele and sele[1] or ""
					local nx,ny,nw,nh = x+textSide[1],y,x+textBoxLen-textSide[2],y+h
					if shadow then
						dxDrawText(text:gsub("#%x%x%x%x%x%x",""),nx-shadow[1],ny-shadow[2],nw-shadow[1],nh-shadow[2],applyColorAlpha(shadow[3],galpha),txtSizX,txtSizY,font,rb[1],rb[2],clip,wordbreak,postgui)
					end
					dxDrawText(text,nx,ny,nw,nh,applyColorAlpha(textcolor,galpha),txtSizX,txtSizY,font,rb[1],rb[2],clip,wordbreak,postgui,colorcoded)
				end
				if enabled then
					if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
						MouseData.hit = v
					end
				end
			else
				visible = false
			end
		elseif dxType == "dgs-dxcombobox-Box" then
			local combo = dgsElementData[v].myCombo
			local x,y = dgsGetPosition(v,false,true)
			local w,h = dgsElementData[v].absSize[1],dgsElementData[v].absSize[2]
			local x,y,cx,cy = processPositionOffset(v,x,y,w,h,v,rndtgt,OffsetX,OffsetY)
			if x and y then
				local DataTab = dgsElementData[combo]
				local itemData = DataTab.itemData
				local scbThick = dgsElementData[combo].scrollBarThick
				local itemHeight = DataTab.itemHeight
				local itemMoveOffset = DataTab.itemMoveOffset
				local whichRowToStart = -math.floor((itemMoveOffset+itemHeight)/itemHeight)+1
				local whichRowToEnd = whichRowToStart+math.floor(h/itemHeight)+1
				DataTab.FromTo = {whichRowToStart > 0 and whichRowToStart or 1,whichRowToEnd <= #itemData and whichRowToEnd or #itemData}
				local renderTarget = dgsElementData[combo].renderTarget
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
					local sizex,sizey = DataTab.listtextsize[1],DataTab.listtextsize[2]
					local font = DataTab.font
					local fontsx,fontsy = sizex,sizey or sizex
					local shadow = dgsElementData[combo].shadow
					local colorcoded = dgsElementData[v].colorcoded
					local wordbreak = dgsElementData[v].wordbreak
					local clip = dgsElementData[v].clip
					local textSide = dgsElementData[combo].combo_BoxTextSide
					for i=DataTab.FromTo[1],DataTab.FromTo[2] do
						local lc_rowData = itemData[i]
						local textcolor = lc_rowData[-2]
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
							dxDrawText(text:gsub("#%x%x%x%x%x%x",""),textSide[1]-shadow[1],_y-shadow[2],_sx-shadow[1],_sy-shadow[2],shadow[3],fontsx,fontsy,font,rb_l[1],rb_l[2],clip,wordbreak)
						end
						dxDrawText(text,textSide[1],_y,_sx,_sy,textcolor,fontsx,fontsy,font,rb_l[1],rb_l[2],clip,wordbreak,false,colorcoded)
					end
					dxSetRenderTarget()
					dxDrawImage(x,y,w,h,renderTarget,0,0,0,tocolor(255,255,255,255*galpha),rendSet)
				end
				if enabled then
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
			local hits = MouseData.hit
			if x and y then
				local tabheight,relat = dgsElementData[v]["tabheight"][1],dgsElementData[v]["tabheight"][2]
				local tabheight = relat and tabheight*y or tabheight
				local preselected = -1
				local selected = dgsElementData[v]["selected"]
				local tabs = dgsElementData[v]["tabs"]
				local height = dgsElementData[v]["tabheight"][2] and dgsElementData[v]["tabheight"][1]*h or dgsElementData[v]["tabheight"][1]
				local font = dgsElementData[v].font or systemFont
				if selected == -1 then
					dxDrawRectangle(x,y+height,w,h-height,dgsElementData[v]["defbackground"],not DEBUG_MODE)
				else
					local rendt = dgsElementData[v]["renderTarget"]
					if isElement(rendt) then
						dxSetRenderTarget(rendt,true)
						local tabsidesize = dgsElementData[v]["tabsidesize"][2] and dgsElementData[v]["tabsidesize"][1]*w or dgsElementData[v]["tabsidesize"][1]
						local tabsize = -dgsElementData[v]["taboffperc"]*(dgsElementData[v]["allleng"]-w)
						local gap = dgsElementData[v]["tabgapsize"][2] and dgsElementData[v]["tabgapsize"][1]*w or dgsElementData[v]["tabgapsize"][1]
						for d,t in ipairs(tabs) do
							local width = dgsElementData[t]["width"]+tabsidesize*2
							local _width = 0
							if tabs[d+1] then
								_width = dgsElementData[tabs[d+1]]["width"]+tabsidesize*2
							end
							if tabsize+width >= 0 and tabsize <= w then
								local tabimg = dgsElementData[t]["tabimg"]
								local tabcolor = dgsElementData[t]["tabcolor"]
								if mx >= tabsize+x and mx <= tabsize+x+width and my > y and my < y+height and dgsElementData[t].enabled then
									preselected = d
								end
								local selectstate = 1
								if selected == d then
									selectstate = 3
								elseif dgsElementData[v]["preselect"] == d then
									selectstate = 2
								end
								if tabimg[selectstate] then
									dxDrawImage(tabsize,0,width,height,tabimg[selectstate],0,0,0,tabcolor[selectstate])
								else
									dxDrawRectangle(tabsize,0,width,height,tabcolor[selectstate])
								end
								local textsize = dgsElementData[t]["textsize"]
								dxDrawText(dgsElementData[t]["text"],tabsize,0,tabsize+width,height,dgsElementData[t]["textcolor"],textsize[1],textsize[2],font,"center","center",false,false,false,colorcoded,true)
							end
							tabsize = tabsize+width+gap
						end
						dxSetRenderTarget()
						dxDrawImage(x,y,w,height,rendt,0,0,0,applyColorAlpha(white,galpha),not DEBUG_MODE)
						local colors = applyColorAlpha(dgsElementData[tabs[selected]]["bgcolor"],galpha)
						if dgsElementData[tabs[selected]]["bgimg"] then
							dxDrawImage(x,y+height,w,h-height,dgsElementData[tabs[selected]]["bgimg"],0,0,0,colors,not DEBUG_MODE)
						else
							dxDrawRectangle(x,y+height,w,h-height,colors,not DEBUG_MODE)
						end
						for cid,child in ipairs(dgsGetChildren(tabs[selected])) do
							renderGUI(child,mx,my,enabled,rndtgt,OffsetX,OffsetY,galpha,visible)
						end
					end
				end
				if enabled then
					if MouseData.hit == hits then
						if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
							MouseData.hit = v
							dgsElementData[v]["preselect"] = preselected
						else
							dgsElementData[v]["preselect"] = -1
						end
					else
						dgsElementData[v]["preselect"] = -1
					end
				end
			else
				visible = false
			end
		elseif dxType == "dgs-dxcmd" then
			local x,y,cx,cy = processPositionOffset(v,x,y,w,h,parent,rndtgt,OffsetX,OffsetY)
			if x and y then
				local colors,imgs = dgsElementData[v].bgcolor,dgsElementData[v].bgimage
				colors = applyColorAlpha(colors,galpha)
				if imgs then
					dxDrawImage(x,y,w,h,imgs,0,0,0,colors,rendSet)
				else
					dxDrawRectangle(x,y,w,h,colors,rendSet)
				end
				local hangju,cmdtexts = dgsElementData[v].hangju,dgsElementData[v].texts or {}
				local canshow = math.floor(h/dgsElementData[v].hangju)-1
				local rowoffset = 0
				local readyToRenderTable = {}
				local font = dgsElementData[v].font or dsm
				local txtSizX,txtSizY = dgsElementData[v].textsize[1],dgsElementData[v].textsize[2] or dgsElementData[v].textsize[1]
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
				if enabled then
					if mx >= cx and mx<= cx+w and my >= cy and my <= cy+h then
						MouseData.hit = v
					end
				end
			else
				visible = false
			end
		end
		triggerEvent("onClientDgsRender",v,x,y,w,h)
		if not dgsElementData[v].hitoutofparent then
			if MouseData.hit ~= v then
				enabled = false
			end
		end
		for k,child in ipairs(children) do
			renderGUI(child,mx,my,enabled,rndtgt,OffsetX,OffsetY,galpha,visible)
		end
	end
end
addEventHandler("onClientRender",root,GUIRender)

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
		local psx,psy = unpack(dgsElementData[parent].absSize)
		local sx,sy = unpack(dgsElementData[gui].absSize)
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
				local tabpanel = dgsElementData[parent]["parent"]
				local height = dgsElementData[tabpanel]["tabheight"][2] and dgsElementData[tabpanel]["tabheight"][1]*psx or dgsElementData[tabpanel]["tabheight"][1]
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

function checkEditCursor(button,state)
	if button == "mouse_wheel_up" or button == "mouse_wheel_down" then
		local scroll = button == "mouse_wheel_down" and 1 or -1
		local scrollbar = MouseData.enter
		if dgsGetType(scrollbar) == "dgs-dxscrollbar" then
			scrollScrollBar(scrollbar,button == "mouse_wheel_down" or false)
		elseif dgsGetType(MouseData.enter) == "dgs-dxgridlist" then
			if MouseData.enterData then
				local scrollbar = dgsElementData[MouseData.enter].scrollbars[1]
				if dgsDxGUIGetVisible(scrollbar) then
					scrollScrollBar(scrollbar,button == "mouse_wheel_down" or false)
				end
			end
		elseif isElement(MouseData.scrollPane) then
			local scrollbar1 = dgsElementData[MouseData.scrollPane].scrollbars[1]
			local scrollbar2 = dgsElementData[MouseData.scrollPane].scrollbars[2]
			local sbr
			if dgsDxGUIGetVisible(scrollbar1) then
				sbr = scrollbar1
			end
			if dgsDxGUIGetVisible(scrollbar2) then
				sbr = scrollbar2
			end
			if sbr then
				scrollScrollBar(sbr,button == "mouse_wheel_down" or false)
			end
		elseif dgsGetType(MouseData.enter) == "dgs-dxtabpanel" then
			local width = dgsElementData[MouseData.enter]["allleng"]
			local w,h = dgsElementData[MouseData.enter]["absSize"][1],dgsElementData[MouseData.enter]["absSize"][2]
			if width > w then
				local mx,my = getCursorPosition()
				mx,my = (mx or -1)*sW,(my or -1)*sH
				local y = dgsElementData[MouseData.enter]["absPos"][2]
				local height = dgsElementData[MouseData.enter]["tabheight"][2] and dgsElementData[MouseData.enter]["tabheight"][1]*h or dgsElementData[MouseData.enter]["tabheight"][1]
				if my < y+height then
					local speed = dgsElementData[MouseData.enter]["scrollSpeed"][2] and dgsElementData[MouseData.enter]["scrollSpeed"][1] or dgsElementData[MouseData.enter]["scrollSpeed"][1]/width
					local orgoff = dgsElementData[MouseData.enter]["taboffperc"]
					orgoff = math.max(math.min(orgoff+scroll*speed,1),0)
					dgsSetData(MouseData.enter,"taboffperc",orgoff)
				end
			end
		elseif dgsGetType(MouseData.enter) == "dgs-dxcombobox-Box" then
			local combo = dgsElementData[MouseData.enter].myCombo
			local scrollbar = dgsElementData[combo].scrollbar
			if dgsDxGUIGetVisible(scrollbar) then
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
				dgsDxEditMoveCaret(MouseData.nowShow,-1,shift)
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
								dgsDxEditMoveCaret(MouseData.nowShow,-1,shift)
								MouseData.editCursorMoveOffset = -1
							else
								killTimer(MouseData.Timer["editMove"])
							end
						end,50,0)
					end
				end,500,1)
			elseif button == "arrow_r" then
				dgsDxEditMoveCaret(MouseData.nowShow,1,shift)
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
								dgsDxEditMoveCaret(MouseData.nowShow,1,shift)
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
						dgsDxGUISetText(MouseData.nowShow,history[int])
						dgsDxEditSetCaretPosition(MouseData.nowShow,#history[int])
					end
				end
			elseif button == "arrow_d" then
				if dgsGetType(cmd) == "dgs-dxcmd" then
					local int = dgsElementData[cmd].cmdCurrentHistory
					local history = dgsElementData[cmd].cmdHistory
					if history[int-1] then
						int = int-1
						dgsSetData(cmd,"cmdCurrentHistory",int)
						dgsDxGUISetText(MouseData.nowShow,history[int])
						dgsDxEditSetCaretPosition(MouseData.nowShow,#history[int])
					end
				end
			elseif button == "home" then
				dgsDxEditSetCaretPosition(MouseData.nowShow,0,getKeyState("lshift") or getKeyState("rshift"))
			elseif button == "end" then
				dgsDxEditSetCaretPosition(MouseData.nowShow,#text,getKeyState("lshift") or getKeyState("rshift"))
			end
		else
			if button == "arrow_l" or button == "arrow_r" then
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
				dgsDxMemoMoveCaret(MouseData.nowShow,-1,0,shift)
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
								dgsDxMemoMoveCaret(MouseData.nowShow,-1,0,shift)
							else
								killTimer(MouseData.Timer["memoMove"])
							end
						end,50,0)
					end
				end,500,1)
			elseif button == "arrow_r" then
				dgsDxMemoMoveCaret(MouseData.nowShow,1,0,shift)
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
								dgsDxMemoMoveCaret(MouseData.nowShow,1,0,shift)
							else
								killTimer(MouseData.Timer["memoMove"])
							end
						end,50,0)
					end
				end,500,1)
			elseif button == "arrow_u" then
				dgsDxMemoMoveCaret(MouseData.nowShow,0,-1,shift,true)
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
								dgsDxMemoMoveCaret(MouseData.nowShow,0,-1,shift,true)
							else
								killTimer(MouseData.Timer["memoMove"])
							end
						end,50,0)
					end
				end,500,1)
			elseif button == "arrow_d" then
				dgsDxMemoMoveCaret(MouseData.nowShow,0,1,shift,true)
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
								dgsDxMemoMoveCaret(MouseData.nowShow,0,1,shift,true)
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
				dgsDxMemoSetCaretPosition(MouseData.nowShow,0,tarline,getKeyState("lshift") or getKeyState("rshift"))
			elseif button == "end" then
				local text = dgsElementData[MouseData.nowShow].text
				local line = dgsElementData[MouseData.nowShow].cursorposXY[2]
				local tarline
				if getKeyState("lctrl") or getKeyState("rctrl") then
					tarline = #text
				end
				dgsDxMemoSetCaretPosition(MouseData.nowShow,utf8.len(text[line] or ""),tarline,getKeyState("lshift") or getKeyState("rshift"))
			elseif button == "delete" then
				local cpos = dgsElementData[MouseData.nowShow].cursorposXY
				local spos = dgsElementData[MouseData.nowShow].selectfrom
				if cpos[1] ~= spos[1] or cpos[2] ~= spos[2] then
					dgsDxMemoDeleteText(MouseData.nowShow,cpos[1],cpos[2],spos[1],spos[2])
					dgsElementData[MouseData.nowShow].selectfrom = dgsElementData[MouseData.nowShow].cursorposXY
				else
					local tarindex,tarline = dgsDxMemoSeekPosition(dgsElementData[MouseData.nowShow].text,cpos[1]+1,cpos[2])
					dgsDxMemoDeleteText(MouseData.nowShow,cpos[1],cpos[2],tarindex,tarline)
				end
			elseif button == "backspace" then
				local cpos = dgsElementData[MouseData.nowShow].cursorposXY
				local spos = dgsElementData[MouseData.nowShow].selectfrom
				if cpos[1] ~= spos[1] or cpos[2] ~= spos[2] then
					dgsDxMemoDeleteText(MouseData.nowShow,cpos[1],cpos[2],spos[1],spos[2])
					dgsElementData[MouseData.nowShow].selectfrom = dgsElementData[MouseData.nowShow].cursorposXY
				else
					local tarindex,tarline = dgsDxMemoSeekPosition(dgsElementData[MouseData.nowShow].text,cpos[1]-1,cpos[2])
					dgsDxMemoDeleteText(MouseData.nowShow,tarindex,tarline,cpos[1],cpos[2])
				end
			elseif button == "c" or button == "x" then
				if getKeyState("lctrl") or getKeyState("rctrl") then
					local cpos = dgsElementData[MouseData.nowShow].cursorposXY
					local spos = dgsElementData[MouseData.nowShow].selectfrom
					local theText = dgsDxMemoGetPartOfText(MouseData.nowShow,cpos[1],cpos[2],spos[1],spos[2],button == "x")
					setClipboard(theText)
				end
			end
		else
			if button == "arrow_l" or button == "arrow_r" or button == "arrow_u" or button == "arrow_d" then
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
addEventHandler("onClientKey",root,checkEditCursor)

addEventHandler("onClientGUIFocus",resourceRoot,function()
	local guitype = getElementType(source)
	if guitype == "gui-edit" then
		local edit = dgsElementData[source].dxedit
		if isElement(edit) then
			dgsDxGUIBringToFront(edit,"left")
		end
	elseif guitype == "gui-memo" then
		local memo = dgsElementData[source].dxmemo
		if isElement(memo) then
			dgsDxGUIBringToFront(memo,"left")
		end
	end
end)

addEventHandler("onClientGUIBlur",resourceRoot,function()
	local guitype = getElementType(source)
	if guitype == "gui-edit" then
		local edit = dgsElementData[source].dxedit
		if isElement(edit) then
			if MouseData.nowShow == edit then
				MouseData.nowShow = false
			end
		end
	elseif guitype == "gui-memo" then
		local memo = dgsElementData[source].dxmemo
		if isElement(memo) then
			if MouseData.nowShow == memo then
				MouseData.nowShow = false
			end
		end
	end
end)

function scrollScrollBar(scrollbar,button)
	local length,lrlt = unpack(dgsElementData[scrollbar].length)
	local scrollMultiplier,rltPos = unpack(dgsElementData[scrollbar].scrollmultiplier)
	local pos = dgsElementData[scrollbar].position
	local offsetPos = (rltPos and scrollMultiplier*cursorRange*0.01 or scrollMultiplier)
	local gpos = button and pos+offsetPos or pos-offsetPos
	dgsSetData(scrollbar,"position",(gpos < 0 and 0) or (gpos >100 and 100) or gpos)
end

addEventHandler("onClientDgsDxGUITextChange",root,function(text)
	local gui = dgsElementData[source].edit
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
addEventHandler("onClientGUIChanged",resourceRoot,function()
	if not dgsElementData[source] then return end
	local guitype = getElementType(source)
	if guitype == "gui-edit" then
		local myedit = dgsElementData[source].dxedit
		if isElement(myedit) then
			if source == dgsElementData[myedit].edit then
				MouseData.editCursor = true
				resetTimer(MouseData.EditTimer)
				local text_old = dgsElementData[myedit].text
				local text_new = guiGetText(source)
				local whiteListText = string.gsub(text_new,dgsElementData[myedit].whiteList or "","")
				if whiteListText ~= text_new then
					guiSetText(source,whiteListText)
					return
				end
				local prepos = dgsElementData[myedit].cursorpos
				local prefrom = dgsElementData[myedit].selectfrom
				local presele = prefrom-prepos
				local offset = presele > 0 and 1 or utf8.len(text_new)-utf8.len(text_old)
				dgsSetData(myedit,"text",text_new)
				local pos = dgsElementData[myedit].cursorpos
				local from = dgsElementData[myedit].selectfrom
				local sele = from-pos
				if getKeyState("delete") then
					if sele ~= 0 then
						if sele > 0 then
							dgsDxEditSetCaretPosition(myedit,from-sele)
						else
							dgsDxEditSetCaretPosition(myedit,from)
						end
					end
				elseif getKeyState("backspace") then
					if sele == 0 then
						dgsDxEditSetCaretPosition(myedit,pos+utf8.len(text_new)-utf8.len(text_old))
					else
						if sele > 0 then
							dgsDxEditSetCaretPosition(myedit,pos)
						else
							dgsDxEditSetCaretPosition(myedit,pos+utf8.len(text_new)-utf8.len(text_old))
						end
					end
				else
					dgsDxEditSetCaretPosition(myedit,pos+offset)
				end
				local pos = dgsElementData[myedit].cursorpos
				if pos > utf8.len(text_new) then
					dgsDxEditSetCaretPosition(myedit,utf8.len(text_new))
				end
			end
		end
	elseif guitype == "gui-memo" then
		local mymemo = dgsElementData[source].dxmemo
		if isElement(mymemo) then
			if source == dgsElementData[mymemo].memo then
				local text = guiGetText(source)
				local cool = dgsElementData[mymemo].CoolTime
				if #text ~= 0 and not cool then
					local cursorposXY = dgsElementData[mymemo].cursorposXY
					local selectfrom = dgsElementData[mymemo].selectfrom
					dgsDxMemoDeleteText(mymemo,cursorposXY[1],cursorposXY[2],selectfrom[1],selectfrom[2])
					handleDxMemoText(mymemo,utf8.sub(text,1,utf8.len(text)-1))
					dgsElementData[mymemo].CoolTime = true
					guiSetText(source,"")
					dgsElementData[mymemo].CoolTime = false
				end
			end
		end
	end
end)


function dgsDxCheckHit(hits,mx,my)
	if not isElement(MouseData.clickl) or not (dgsGetType(MouseData.clickl) == "dgs-dxscrollbar" and MouseData.clickData == 2) then
		if MouseData.enter ~= hits then
			if isElement(MouseData.enter) then
				triggerEvent("onClientDgsDxMouseLeave",MouseData.enter,mx,my,hits)
				if dgsGetType(MouseData.clickl) == "dgs-dxscrollbar" then
					if isTimer(MouseData.Timer[MouseData.clickl]) then
						killTimer(MouseData.Timer[MouseData.clickl])
					end
					if isTimer(MouseData.Timer2[MouseData.clickl]) then
						killTimer(MouseData.Timer2[MouseData.clickl])
					end
				end
				if dgsGetType(MouseData.enter) == "dgs-dxgridlist" then
					dgsSetData(MouseData.enter,"preSelect",-1)
				end
			end
			if isElement(hits) then
				triggerEvent("onClientDgsDxMouseEnter",hits,mx,my,MouseData.enter)
			end
			MouseData.enter = hits
		end
	end
	if isElement(MouseData.clickl) then
		if MouseData.lastPos[1] ~= mx or MouseData.lastPos[2] ~= my then
			triggerEvent("onClientDgsDxGUICursorMove",MouseData.clickl,mx,my)
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
				local maxSizeX,maxSizeY = unpack(dgsElementData[MouseData.clickl].maxSize)
				local minSizeX,minSizeY = unpack(dgsElementData[MouseData.clickl].minSize)
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
		end
		if not getKeyState("mouse2") then
			MouseData.clickr = false
		end
	end
end

addEventHandler("onClientDgsDxMouseClick",root,function(button,state)
	local parent = dgsGetParent(source)
	if state == "down" then
		dgsDxGUIBringToFront(source,button)
		local guitype = dgsGetType(source)
		if guitype == "dgs-dxscrollpane" then
			local scrollbar = dgsElementData[source].scrollbars
			dgsDxGUIBringToFront(scrollbar[1],"left")
			dgsDxGUIBringToFront(scrollbar[2],"left")
		end
		if button == "left" then
			if guitype == "dgs-dxwindow" then
				if not checkScale() then
					checkMove()
				end
			end
			if guitype == "dgs-dxscrollbar" then
				local scrollArrow = dgsElementData[source].scrollArrow
				local mx,my = getCursorPosition()
				mx,my = (mx or -1)*sW,(my or -1)*sH
				local x,y = dgsGetPosition(source,false,true)
				local w,h = dgsGetSize(source,false)
				local voh = dgsElementData[source].voh
				local pos = dgsElementData[source].position
				local length,lrlt = unpack(dgsElementData[source].length)
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
						local moveMultiplier,rltPos = unpack(dgsElementData[source].multiplier)
						local movePos = dgsElementData[source].position
						local gpos = movePos-(rltPos and moveMultiplier*cursorRange*0.01 or moveMultiplier)
						dgsSetData(source,"position",(gpos < 0 and 0) or (gpos >100 and 100) or gpos)
						if not isTimer(MouseData.Timer[source]) then
							MouseData.Timer2[source] = setTimer(function(source)
								if MouseData.clickl == source then
									if not isTimer(MouseData.Timer[source]) then
										MouseData.Timer[source] = setTimer(function(source)
											if MouseData.clickData == 1 then
												local moveMultiplier,rltPos = unpack(dgsElementData[source].multiplier)
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
						local moveMultiplier,rltPos = unpack(dgsElementData[source].multiplier)
						local movePos = dgsElementData[source].position
						local gpos = movePos+(rltPos and moveMultiplier*cursorRange*0.01 or moveMultiplier)
						dgsSetData(source,"position",(gpos < 0 and 0) or (gpos >100 and 100) or gpos)
						if not isTimer(MouseData.Timer[source]) then
							MouseData.Timer2[source] = setTimer(function(source)
								if MouseData.clickl == source then
									if not isTimer(MouseData.Timer[source]) then
										MouseData.Timer[source] = setTimer(function(source)
											if MouseData.clickData == 4 then
												local moveMultiplier,rltPos = unpack(dgsElementData[source].multiplier)
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
			elseif guitype == "dgs-dxgridlist" then
				local oPreSelect = dgsElementData[source].oPreSelect
				local rowData = dgsElementData[source].rowData
				if oPreSelect and rowData[oPreSelect] and rowData[oPreSelect][-1] then 
					local preSelect = dgsElementData[source].preSelect
					local oldSelect = dgsElementData[source].select
					dgsElementData[source].select = preSelect
					triggerEvent("onClientDgsDxGridListSelect",source,oldSelect,preSelect)
				end
			elseif guitype == "dgs-dxcombobox-Box" then
				local combobox = dgsElementData[source].myCombo
				local preSelect = dgsElementData[combobox].preSelect
				local oldSelect = dgsElementData[combobox].select
				dgsElementData[combobox].select = preSelect
				triggerEvent("onClientDgsDxComboBoxSelect",combobox,oldSelect,preSelect)
			elseif guitype == "dgs-dxtabpanel" then
				if dgsElementData[source]["preselect"] ~= -1 then
					dgsSetData(source,"selected",dgsElementData[source]["preselect"])
				end
			elseif guitype == "dgs-dxcombobox" then
				dgsSetData(source,"listState",dgsElementData[source].listState == 1 and -1 or 1)
			end
		end
	else
		if button == "left" then
			if MouseData.clickl == source then
				if isElement(parent) then
					local closebutton = dgsElementData[parent].closeButton
					if closebutton == source then
						triggerEvent("onClientDgsDxWindowClose",parent,closebutton)
						if not wasEventCancelled() then
							destroyElement(parent)
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
		triggerEvent("onClientDgsDxGUIDestroy",source)
		local child = ChildrenTable[source] or {}
		for i=1,#child do
			if isElement(child[1]) then
				destroyElement(child[1])
			end
		end
		if dgsGetType(source) == "dgs-dxedit" then
			local edit = dgsElementData[source].edit
			destroyElement(edit)
			local rentarg = dgsElementData[source].renderTarget
			if isElement(rentarg) then
				destroyElement(rentarg)
			end
		elseif dgsGetType(source) == "dgs-dxmemo" then
			local memo = dgsElementData[source].memo
			destroyElement(memo)
			local rentarg = dgsElementData[source].renderTarget
			if isElement(rentarg) then
				destroyElement(rentarg)
			end
		elseif dgsGetType(source) == "dgs-dxgridlist" then
			local rentarg = dgsElementData[source].renderTarget
			if isElement(rentarg[1]) then
				destroyElement(rentarg[1])
			end
			if isElement(rentarg[2]) then
				destroyElement(rentarg[2])
			end
		elseif dgsGetType(source) == "dgs-dxscrollpane" then
			local rentarg = dgsElementData[source].renderTarget_parent
			destroyElement(rentarg)
			local scrollbar = dgsElementData[source].scrollbars
			if isElement(scrollbar[1]) then
				destroyElement(scrollbar[1])
			end
			if isElement(scrollbar[2]) then
				destroyElement(scrollbar[2])
			end
		elseif dgsGetType(source) == "dgs-dxtabpanel" then
			local rentarg = dgsElementData[source].renderTarget
			for k,v in pairs(dgsElementData[source].tabs or {}) do
				destroyElement(v)
			end
			if isElement(rentarg) then
				destroyElement(rentarg)
			end
		elseif dgsGetType(source) == "dgs-dxcombobox" then
			local rentarg = dgsElementData[source].renderTarget
			if isElement(rentarg) then
				destroyElement(rentarg)
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
		local parent = dgsGetParent(source)
		if not isElement(parent) then
			local id = table.find(MaxFatherTable,source)
			if id then
				table.remove(MaxFatherTable,id)
			end
			local id = table.find(BottomFatherTable,source)
			if id then
				table.remove(BottomFatherTable,id)
			end
		else
			local id = table.find(ChildrenTable[parent] or {},source)
			if id then
				table.remove(ChildrenTable[parent] or {},id)
			end
		end
	end
end)

function checkMove()
	local mx,my = getCursorPosition()
	mx,my = (mx or -1)*sW,(my or -1)*sH
	local x,y = unpack(dgsElementData[source].absPos)
	local offsetx,offsety = mx-x,my-y
	if dgsGetType(source) == "dgs-dxwindow" then
		local movable = dgsElementData[source].movable
		if not movable then return end
		local sx,sy = unpack(dgsElementData[source].absSize)
		local titsize = dgsElementData[source].movetyp and sy or dgsElementData[source].titlesize
		if offsety > titsize then return end
	end
	MouseData.Move = {offsetx,offsety}
end

function checkScrollBar(py,sd)
	local mx,my = getCursorPosition()
	mx,my = (mx or -1)*sW,(my or -1)*sH
	local x,y = unpack(dgsElementData[source].absPos)
	local offsetx,offsety = mx-x,my-y
	MouseData.Move = {sd and offsetx-py or offsetx,sd and offsety or offsety-py}
end

function checkScale()
	local mx,my = getCursorPosition()
	mx,my = (mx or -1)*sW,(my or -1)*sH
	local x,y = unpack(dgsElementData[source].absPos)
	local w,h = unpack(dgsElementData[source].absSize)
	local offsets = {mx-x,my-y,mx-x-w,my-y-h}
	local left
	local right
	if dgsGetType(source) == "dgs-dxwindow" then
		local sizable = dgsElementData[source].sizable
		if not sizable then return false end
		local sidesize = dgsElementData[source].sidesize
		if math.abs(offsets[1]) < sidesize then
			offsets[5] = 1
		elseif math.abs(offsets[3]) < sidesize then
			offsets[5] = 3
		end
		if math.abs(offsets[2]) < sidesize then
			offsets[6] = 2
		elseif math.abs(offsets[4]) < sidesize then
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

DoubleClick = false

addEventHandler("onClientClick",root,function(button,state,x,y)
	local guiele = dgsDxGetMouseEnterGUI()
	if isElement(guiele) then
		if state == "down" then
			if button == "left" then
				local gtype = dgsGetType(guiele)
				if gtype == "dgs-dxradiobutton" then
					dgsDxRadioButtonSetSelected(guiele,true)
				elseif gtype == "dgs-dxcheckbox" then
					local state = dgsElementData[guiele].CheckBoxState
					dgsDxCheckBoxSetSelected(guiele,not state)
				end
			end
			if DoubleClick and isTimer(DoubleClick.timer) and DoubleClick.ele == guiele and DoubleClick.but == button then
				triggerEvent("onClientDgsDxMouseDoubleClick",guiele,button,x,y)
				killTimer(DoubleClick.timer)
				DoubleClick.ele = false
			else
				if DoubleClick then
					if isTimer(DoubleClick.timer) then
						killTimer(DoubleClick.timer)
					end
				end
				DoubleClick = {}
				DoubleClick.ele = guiele
				DoubleClick.but = button
				DoubleClick.timer = setTimer(function()
					DGSDoubleClickElement = false
				end,500,1)
			end
		end
		triggerEvent("onClientDgsDxMouseClick",guiele,button,state,x,y)
	elseif state == "down" then
		if dgsGetType(MouseData.nowShow) == "dgs-dxedit" then
			local gui = guiCreateLabel(0,0,0,0,"",false)
			guiBringToFront(gui)
			destroyElement(gui)
		end
		MouseData.nowShow = false
		if isElement(lastFront) then
			triggerEvent("onClientDgsDxBlur",lastFront,false)
			lastFront = false
		end
	end
	if state == "up" then
		if button == "left" then
			MouseData.clickl = false
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

function simulationClick(guiele,button)
	local x,y = dgsGetPosition(guiele,false)
	local sx,sy = dgsGetSize(guiele,false)
	local x,y = x+sx*0.5,y+sy*0.5
	triggerEvent("onClientDgsDxMouseClick",guiele,button,"down",x,y)
	triggerEvent("onClientDgsDxMouseClick",guiele,button,"up",x,y)
end

addEventHandler("onClientDgsDxGUIPositionChange",root,function(oldx,oldy)
	local parent = dgsGetParent(source)
	if isElement(parent) then
		if dgsGetType(parent) == "dgs-dxscrollpane" then
			local abspos = dgsElementData[source].absPos
			local abssize = dgsElementData[source].absSize
			if abspos and abssize then
				local x,y = unpack(abspos)
				local sx,sy = unpack(abssize)
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
		local relativePos,relativeSize = unpack(dgsElementData[v].relative)
		local x,y
		if relativePos then
			x,y = unpack(dgsElementData[v].rltPos)
		end
		calculateGuiPositionSize(v,x,y,relativePos)
	end
end)

addEventHandler("onClientDgsDxGUISizeChange",root,function()
	for k,v in ipairs(ChildrenTable[source] or {}) do
		local relativePos,relativeSize = unpack(dgsElementData[v].relative)
		local x,y,sx,sy
		if relativePos then
			x,y = unpack(dgsElementData[v].rltPos)
		end
		if relativeSize then
			sx,sy = unpack(dgsElementData[v].rltSize)
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

function dgsDxGetMouseEnterGUI()
	return MouseData.enter
end

function dgsDxGetMouseClickGUI(button)
	if button == "left" then
		return MouseData.clickl
	elseif button == "middle" then
		return MouseData.clickm
	else
		return MouseData.clickr
	end
end

dgsElementData[resourceRoot] = {}

function dgsRunString(func,...)
	local fnc = loadstring(func)
	assert(type(fnc) == "function","[DGS]Can't Load Bad Function By dgsRunString")
	return fnc(...)
end
