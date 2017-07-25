------------Copyrights thisdp's DirectX Graphical User Interface
white = tocolor(255,255,255,255)
black = tocolor(0,0,0,255)
sW,sH = guiGetScreenSize()
fontSize = {}
textFontSize = {}
fontSize["msyh"] = 12
fontSize["dsm"] = 10
msyh = dxCreateFont("msyh.ttf",fontSize["msyh"])
textFontSize[msyh] = 12/fontSize["msyh"]

fontSize["msyh_s"] = 12
msyh_s = dxCreateFont("msyh.ttf",fontSize["msyh_s"])
textFontSize[msyh_s] = 12/fontSize["msyh_s"]

dsm = dxCreateFont("dsm.ttf",fontSize["dsm"])
textFontSize[dsm] = 10/fontSize["dsm"]

fontSize["msyh_18"] = 18
msyh_18 = dxCreateFont("msyh.ttf",fontSize["msyh_18"])
textFontSize[msyh_18] = 12/fontSize["msyh_18"]


fontSize["msyh_32"] = 32
msyh_32 = dxCreateFont("msyh.ttf",fontSize["msyh_32"])
textFontSize[msyh_32] = 12/fontSize["msyh_32"]

fontSize["msyh_10"] = 10
msyh_10 = dxCreateFont("msyh.ttf",fontSize["msyh_10"])
textFontSize[msyh_10] = 12/fontSize["msyh_10"]

setElementData(root,"system_font_10",msyh_10,false)
setElementData(root,"system_font",msyh,false)
setElementData(root,"system_font_dsm",dsm,false)
setElementData(root,"system_font_18",msyh_18,false)
setElementData(root,"system_font_12",msyh_s,false)
setElementData(root,"system_font_32",msyh_32,false)

-----------------------------------------------------Core-----------------------------------------------------
dgsElementType = {}
BottomFatherTable = {}		--Store Save Bottom Father Element
FatherTable = {}		--Store Save Father Element
ChildrenTable = {}		--Store Children Element
MaxFatherTable = {}		--Topest
dgsElementData = {}		--Store The Data

function dgsGetType(shenMeGui)
	if isElement(shenMeGui) then
		return dgsElementType[shenMeGui] or getElementType(shenMeGui)
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
		local oldValue = dgsElementData[element][""..key..""]
		dgsElementData[element][""..key..""] = value
		if not check then
		    local dgsType = dgsGetType(element)
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
						configGirdList(element)
					else
						configScrollPane(element)
					end
				elseif key == "columnHeight" then
					configGirdList(element)
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

dgsType = {
"dgs-dxbutton",
"dgs-dxcmd",
"dgs-dxedit",
--"dgs-dxmemo",
"dgs-dxcyclehitshape",
"dgs-dxgridlist",
"dgs-dximage",
"dgs-dxradiobutton",
"dgs-dxlabel",
"dgs-dxscrollbar",
"dgs-dxscrollpane",
"dgs-dxwindow",
"dgs-dxprogressbar",
"dgs-dxtabpanel",
"dgs-dxtab",
}

addCommandHandler("debugdgs",function()
	DEBUG_MODE = not DEBUG_MODE
end)

DEBUG_MODE = false

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
	for k,v in pairs(BottomFatherTable) do
		renderGUI(v,mx,my,dgsElementData[v].enabled,dgsElementData[v].renderTarget_parent,0,0,1,dgsElementData[v].visible)
	end
	for k,v in pairs(MaxFatherTable) do
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
		dxDrawText("DGS:",5,sH*0.4-60)
		dxDrawText("Render Time: "..getTickCount()-tk.." ms",10,sH*0.4-45)
		dxDrawText("Enter:"..tostring(MouseData.hit),10,sH*0.4-30)
		dxDrawText("Click Left:"..tostring(MouseData.clickl).." ;Right:"..tostring(MouseData.clickr),10,sH*0.4-15)
		DGSCount = 0
		for k,v in pairs(dgsType) do
			DGSCount = DGSCount+#getElementsByType(v)
			local x = 15
			if v == "dgs-dxtab" then
				x = 30
			end
			dxDrawText(v.." : "..#getElementsByType(v),x,sH*0.4+15*(k+1))
		end
		dxDrawText("Elements Shows: "..DGSShow,10,sH*0.4)
		dxDrawText("Elements Counts: "..DGSCount,10,sH*0.4+15)	
	
		dxDrawText("Resource Elements:",200,sH*0.4+15)
		Resource = 0
		ResCount = 0
		for ka,va in pairs(resourceDxGUI) do
			if type(ka) == "userdata" and va then
				Resource = Resource+#va
				ResCount = ResCount +1
				dxDrawText(getResourceName(ka).." : "..#va,200,sH*0.4+15*(ResCount+1))
			end
		end
	end
	MouseData.hit = false
end

function getColorAlpha(color)
	return bitExtract(color,24,8)
end

function setColorAlpha(color,alpha)
	return bitReplace(color,alpha,24,8)
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
		if dxType == "dgs-dxwindow" then
			if x and y then
				local img = dgsElementData[v].image
				local color = dgsElementData[v].color
				color = setColorAlpha(color,getColorAlpha(color)*galpha)
				local titimg,titcolor,titsize = dgsElementData[v].titimage,dgsElementData[v].titcolor,dgsElementData[v].titlesize
				titcolor = setColorAlpha(titcolor,getColorAlpha(titcolor)*galpha)
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
				local font = dgsElementData[v].font or msyh
				local titnamecolor = dgsElementData[v].titnamecolor
				titnamecolor = setColorAlpha(titnamecolor,getColorAlpha(titnamecolor)*galpha)
				dxDrawText(dgsElementData[v].text,x,y,x+w,y+titsize,titnamecolor,1*(textFontSize[font] or 1),msyh,"center","center",true,false,not DEBUG_MODE,dgsElementData[v].titleColorCoded)
				if enabled then
					if mx >= x-2 and mx<= x+w-1 and my >= y-2 and my <= y+h-1 then
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
					dxDrawImage(x,y,w,h,imgs[colorimgid],0,0,0,setColorAlpha(colors[colorimgid],getColorAlpha(colors[colorimgid])*galpha),not DEBUG_MODE and isRenderTarget)
				else
					dxDrawRectangle(x,y,w,h,setColorAlpha(colors[colorimgid],getColorAlpha(colors[colorimgid])*galpha),not DEBUG_MODE and isRenderTarget)
				end
				local font = dgsElementData[v].font or msyh
				local txtSizX = dgsElementData[v].textsize[1]*(textFontSize[font] or 1)
				local txtSizY = dgsElementData[v].textsize[2]*(textFontSize[font] or 1)
				local txtoffsets = {0,0}
				local clip = dgsElementData[v].clip
				local wordbreak = dgsElementData[v].wordbreak
				local colorcoded = dgsElementData[v].colorcoded
				if colorimgid == 3 then
					txtoffsets = dgsElementData[v].clickoffset
				end
				local tplt = dgsElementData[v].rightbottom
 				local shadowoffx,shadowoffy,shadowc = unpack(dgsElementData[v].shadow)
				if shadowoffx and shadowoffy and shadowc then
					shadowc = setColorAlpha(shadowc,getColorAlpha(shadowc)*galpha)
					dxDrawText(dgsElementData[v].text,math.floor(x+txtoffsets[1])+shadowoffx,math.floor(y+txtoffsets[2])+shadowoffy,x+w+shadowoffx-2,y+h+shadowoffy-1,tocolor(0,0,0,255*galpha),txtSizX,txtSizY,font,tplt[1],tplt[2],clip,wordbreak,not DEBUG_MODE and isRenderTarget,colorcoded)
				end
				dxDrawText(dgsElementData[v].text,math.floor(x+txtoffsets[1]),math.floor(y+txtoffsets[2]),x+w-1,y+h-1,setColorAlpha(dgsElementData[v].textcolor,getColorAlpha(dgsElementData[v].textcolor)*galpha),txtSizX,txtSizY,font,tplt[1],tplt[2],clip,wordbreak,not DEBUG_MODE and isRenderTarget,colorcoded)
				if enabled then
					if mx >= cx-2 and mx<= cx+w-1 and my >= cy-2 and my <= cy+h-1 then
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
				colors = setColorAlpha(colors,getColorAlpha(colors)*galpha)
				if imgs then
					local sx,sy = unpack(dgsElementData[v].imagesize)
					local px,py = unpack(dgsElementData[v].imagepos)
					local fnc = dgsElementData[v].functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
					if not sx or not sy or not px or not py then
						dxDrawImage(x,y,w,h,imgs,0,0,0,colors,not DEBUG_MODE and isRenderTarget)
					else
						dxDrawImageSection(x,y,w,h,px,py,sx,sy,imgs,0,0,0,colors,not DEBUG_MODE and isRenderTarget)
					end
				else
					dxDrawRectangle(x,y,w,h,colors,not DEBUG_MODE and isRenderTarget)
				end
				if enabled then
					if mx >= cx-2 and mx<= cx+w and my >= cy-0.5 and my <= cy+h then
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
					dxDrawImage(x,y+h/2-buttonSize/2,buttonSize,buttonSize,image[colorimgid],0,0,0,setColorAlpha(color[colorimgid],getColorAlpha(color[colorimgid])*galpha),not DEBUG_MODE and isRenderTarget)
				else
					dxDrawRectangle(x,y+h/2-buttonSize/2,buttonSize,buttonSize,setColorAlpha(color[colorimgid],getColorAlpha(color[colorimgid])*galpha),not DEBUG_MODE and isRenderTarget)
				end
				local font = dgsElementData[v].font or msyh
				local txtSizX = dgsElementData[v].textsize[1]*(textFontSize[font] or 1)
				local txtSizY = dgsElementData[v].textsize[2]*(textFontSize[font] or 1)
				local clip = dgsElementData[v].clip
				local wordbreak = dgsElementData[v].wordbreak
				local _textImageSpace = dgsElementData[v].textImageSpace
				local textImageSpace = _textImageSpace[2] and _textImageSpace[1]*w or _textImageSpace[1]
				local colorcoded = dgsElementData[v].colorcoded
				local tplt = dgsElementData[v].rightbottom
 				local shadowoffx,shadowoffy,shadowc = unpack(dgsElementData[v].shadow)
				local px = x+buttonSize+textImageSpace
				if shadowoffx and shadowoffy and shadowc then
					shadowc = setColorAlpha(shadowc,getColorAlpha(shadowc)*galpha)
					dxDrawText(dgsElementData[v].text,px+shadowoffx,y+shadowoffy,px+w+shadowoffx-2,y+h+shadowoffy-1,tocolor(0,0,0,255*galpha),txtSizX,txtSizY,font,tplt[1],tplt[2],clip,wordbreak,not DEBUG_MODE and isRenderTarget,colorcoded)
				end
				dxDrawText(dgsElementData[v].text,px,y,px+w-1,y+h-1,setColorAlpha(dgsElementData[v].textcolor,getColorAlpha(dgsElementData[v].textcolor)*galpha),txtSizX,txtSizY,font,tplt[1],tplt[2],clip,wordbreak,not DEBUG_MODE and isRenderTarget,colorcoded)
				if enabled then
					if mx >= cx-2 and mx<= cx+w-1 and my >= cy-2 and my <= cy+h-1 then
						MouseData.hit = v
					end
				end
			else
				visible = false
			end
		elseif dxType == "dgs-dxedit" then
			local x,y,cx,cy = processPositionOffset(v,x,y,w,h,parent,rndtgt,OffsetX,OffsetY)
			if x and y then
				local pos = dgsElementData[v].position
				local imagebg = dgsElementData[v].imagebg
				local colorbg = dgsElementData[v].colorbg
				colorbg = setColorAlpha(colorbg,getColorAlpha(colorbg)*galpha)
				local edit = dgsElementData[v].edit
				if not isElement(edit) then
					destroyElement(source)
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
					text = string.rep(dgsElementData[v].maskText,string.count(text))
				end
				if MouseData.nowShow == v then
					if getKeyState("lctrl") and getKeyState("a") then
						dgsSetData(v,"cursorpos",0)
						dgsSetData(v,"selectfrom",string.count(text))
					end
				end
				local cursorPos = dgsElementData[v].cursorpos
				local selectFro = dgsElementData[v].selectfrom
				local selectcolor = dgsElementData[v].selectcolor
				guiEditSetCaretIndex(edit,cursorPos)
				guiSetProperty(edit,"SelectionStart",cursorPos)
				guiSetProperty(edit,"SelectionLength",selectFro-cursorPos)
				local font = dgsElementData[v].font or msyh
				local txtSizX = dgsElementData[v].textsize[1]*(textFontSize[font] or 1)
				local txtSizY = dgsElementData[v].textsize[2]*(textFontSize[font] or 1)
				local renderTarget = dgsElementData[v].renderTarget
				if isElement(renderTarget) then
					local selectMode = dgsElementData[v].selectmode
					local textcolor = dgsElementData[v].textcolor
					local startx = dxGetTextWidth(utfSub(text,0,cursorPos),txtSizX,font)
					local selx = 0
					if selectFro-cursorPos > 0 then
						selx = dxGetTextWidth(utfSub(text,cursorPos+1,selectFro),txtSizX,font)
					elseif selectFro-cursorPos < 0 then
						selx = -dxGetTextWidth(utfSub(text,selectFro+1,cursorPos),txtSizX,font)
					end
					local offset = dgsElementData[v].showPos
					dxSetRenderTarget(renderTarget,true)
					if selectMode then
						dxDrawRectangle(startx+offset,2,selx,h-4,selectcolor)
					end
					local bools = dxDrawText(text,offset,0,dxGetTextWidth(text,txtSizX,font),h,textcolor,txtSizX,txtSizY,font,"left","center",true,false,false,false)

					if not selectMode then
						dxDrawRectangle(startx+offset,2,selx,h-4,selectcolor)
					end
					dxSetRenderTarget(rndtgt)
					if imagebg then
						dxDrawImage(x,y,w,h,imagebg,0,0,0,colorbg,not DEBUG_MODE and isRenderTarget)
					else
						dxDrawRectangle(x,y,w,h,colorbg,not DEBUG_MODE and isRenderTarget)
					end
					if MouseData.nowShow == v and MouseData.editCursor then
						local width = dxGetTextWidth(utfSub(text,0,cursorPos),txtSizX,font)
						local showPos = dgsElementData[v].showPos
						local cursorStyle = dgsElementData[v].cursorStyle
						if cursorStyle == 0 then
							dxDrawLine(x+width+showPos+2,y+2,x+width+showPos+2,y+h-4,black,dgsElementData[v].cursorThick,isRenderTarget)
						elseif cursorStyle == 1 then
							local cursorWidth = dxGetTextWidth(utfSub(text,cursorPos+1,cursorPos+1),txtSizX,font)
							if cursorWidth == 0 then
								cursorWidth = txtSizX*8
							end
							local offset = dgsElementData[v].cursorOffset
							dxDrawLine(x+width+showPos+2,y+h-4+offset,x+width+showPos+cursorWidth+2,y+h-4+offset,black,dgsElementData[v].cursorThick,isRenderTarget)
						end
					end	
					dxDrawImageSection(x+2,y,w-4,h,0,0,w-4,h,renderTarget,0,0,0,tocolor(255,255,255,255*galpha),not DEBUG_MODE and isRenderTarget)
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
		--[[elseif dxType == "dgs-dxmemo" then
			local x,y,cx,cy = processPositionOffset(v,x,y,w,h,parent,rndtgt,OffsetX,OffsetY)
			if x and y then
				local pos = dgsElementData[v].position
				local imagebg = dgsElementData[v].imagebg
				local colorbg = dgsElementData[v].colorbg
				colorbg = setColorAlpha(colorbg,getColorAlpha(colorbg)*galpha)
				local memo = dgsElementData[v].memo
				if not isElement(memo) then
					destroyElement(source)
					return
				end
				local _ = isMainMenuActive() and guiSetVisible(memo,false) or guiSetVisible(memo,true)
				guiSetPosition(memo,cx,cy,false)
				guiSetSize(memo,w,h,false)
				local text = dgsElementData[v].text
				local fnc = dgsElementData[v].functions
				if type(fnc) == "table" then
					text = fnc[1](unpack(fnc[2]))
				end
				guiSetText(memo,text)
				if dgsElementData[v].masked then
					text = string.rep(dgsElementData[v].maskText,string.count(text))
				end
				if MouseData.nowShow == v then
					if getKeyState("lctrl") and getKeyState("a") then
						dgsSetData(v,"cursorpos",0)
						dgsSetData(v,"selectfrom",string.count(text))
					end
				end
				local cursorPos = dgsElementData[v].cursorpos
				local selectFro = dgsElementData[v].selectfrom
				local selectcolor = dgsElementData[v].selectcolor
				guiEditSetCaretIndex(memo,cursorPos)
				guiSetProperty(memo,"SelectionStart",cursorPos)
				guiSetProperty(memo,"SelectionLength",selectFro-cursorPos)
				local font = dgsElementData[v].font or msyh
				local txtSizX = dgsElementData[v].textsize[1]*(textFontSize[font] or 1)
				local txtSizY = dgsElementData[v].textsize[2]*(textFontSize[font] or 1)
				local renderTarget = dgsElementData[v].renderTarget
				if isElement(renderTarget) then
					local selectMode = dgsElementData[v].selectmode
					local textcolor = dgsElementData[v].textcolor
					local startx = dxGetTextWidth(utfSub(text,0,cursorPos),txtSizX,font)
					local selx = 0
					if selectFro-cursorPos > 0 then
						selx = dxGetTextWidth(utfSub(text,cursorPos+1,selectFro),txtSizX,font)
					elseif selectFro-cursorPos < 0 then
						selx = -dxGetTextWidth(utfSub(text,selectFro+1,cursorPos),txtSizX,font)
					end
					local offset = dgsElementData[v].showPos
					dxSetRenderTarget(renderTarget,true)
					if selectMode then
						dxDrawRectangle(startx+offset,2,selx,h-4,selectcolor)
					end
					local bools = dxDrawText(text,offset,0,dxGetTextWidth(text,txtSizX,font),h,textcolor,txtSizX,txtSizY,font,"left","center",true,false,false,false)

					if not selectMode then
						dxDrawRectangle(startx+offset,2,selx,h-4,selectcolor)
					end
					dxSetRenderTarget(rndtgt)
					if imagebg then
						dxDrawImage(x,y,w,h,imagebg,0,0,0,colorbg,not DEBUG_MODE and isRenderTarget)
					else
						dxDrawRectangle(x,y,w,h,colorbg,not DEBUG_MODE and isRenderTarget)
					end
					if MouseData.nowShow == v and MouseData.editCursor then
						local width = dxGetTextWidth(utfSub(text,0,cursorPos),txtSizX,font)
						local showPos = dgsElementData[v].showPos
						local cursorStyle = dgsElementData[v].cursorStyle
						if cursorStyle == 0 then
							dxDrawLine(x+width+showPos+2,y+2,x+width+showPos+2,y+h-4,black,dgsElementData[v].cursorThick,isRenderTarget)
						elseif cursorStyle == 1 then
							local cursorWidth = dxGetTextWidth(utfSub(text,cursorPos+1,cursorPos+1),txtSizX,font)
							if cursorWidth == 0 then
								cursorWidth = txtSizX*8
							end
							local offset = dgsElementData[v].cursorOffset
							dxDrawLine(x+width+showPos+2,y+h-4+offset,x+width+showPos+cursorWidth+2,y+h-4+offset,black,dgsElementData[v].cursorThick,isRenderTarget)
						end
					end	
					dxDrawImageSection(x+2,y,w-4,h,0,0,w-4,h,renderTarget,0,0,0,tocolor(255,255,255,255*galpha),not DEBUG_MODE and isRenderTarget)
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
			end]]
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
					if mx >= cx-2 and mx<= cx+w-1 and my >= cy-2 and my <= cy+h-1 then
						MouseData.scrollPane = v
						MouseData.hit = v
						if mx >= cx-1+relSizX and my >= cy-1+relSizY and scbstate[1] and scbstate[2] then
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
						newColor_b[c_kk] = setColorAlpha(c_vv,getColorAlpha(c_vv)*galpha)
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
						dxDrawImage(x+arrowPos,y,w-2*arrowPos,h,imgs[3],0,0,0,colors[1][3],not DEBUG_MODE and isRenderTarget)
					else
						dxDrawRectangle(x+arrowPos,y,w-2*arrowPos,h,colors[1][3],not DEBUG_MODE and isRenderTarget)
					end
					if scrollArrow then
						dxDrawImage(x,y,h,h,imgs[1],270,0,0,colors[colorimgid[1]][1],not DEBUG_MODE and isRenderTarget)
						dxDrawImage(x+w-h,y,h,h,imgs[1],90,0,0,colors[colorimgid[4]][1],not DEBUG_MODE and isRenderTarget)
					end
					if imgs[2] then
						dxDrawImage(x+arrowPos+pos*0.01*csRange,y,cursorRange,h,imgs[2],270,0,0,colors[colorimgid[2]][2],not DEBUG_MODE and isRenderTarget)
					else
						dxDrawRectangle(x+arrowPos+pos*0.01*csRange,y,cursorRange,h,colors[colorimgid[2]][2],not DEBUG_MODE and isRenderTarget)
					end
				else
					if imgs[3] then
						dxDrawImage(x,y+arrowPos,w,h-2*arrowPos,imgs[3],0,0,0,colors[1][3],not DEBUG_MODE and isRenderTarget)
					else
						dxDrawRectangle(x,y+arrowPos,w,h-2*arrowPos,colors[1][3],not DEBUG_MODE and isRenderTarget)
					end
					if scrollArrow then
						dxDrawImage(x,y,w,w,imgs[1],0,0,0,colors[colorimgid[1]][1],not DEBUG_MODE and isRenderTarget)
						dxDrawImage(x,y+h-w,w,w,imgs[1],180,0,0,colors[colorimgid[4]][1],not DEBUG_MODE and isRenderTarget)
					end
					if imgs[2] then
						dxDrawImage(x,y+arrowPos+pos*0.01*csRange,w,cursorRange,imgs[2],270,0,0,colors[colorimgid[2]][2],not DEBUG_MODE and isRenderTarget)
					else
						dxDrawRectangle(x,y+arrowPos+pos*0.01*csRange,w,cursorRange,colors[colorimgid[2]][2],not DEBUG_MODE and isRenderTarget)
					end
				end
				if enabled then
					if mx >= cx-2 and mx<= cx+w-1 and my >= cy-2 and my <= cy+h-1 then
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
				colors = setColorAlpha(colors,getColorAlpha(colors)*galpha)
				local colorimgid = 1
				if MouseData.enter == v then
					colorimgid = 2
					if MouseData.clickl == v then
						colorimgid = 3
					end
				end
				local font = dgsElementData[v].font or msyh
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
				local txtSizX = dgsElementData[v].textsize[1]*(textFontSize[font] or 1)
				local txtSizY = dgsElementData[v].textsize[2]*(textFontSize[font] or 1)
				if shadowoffx and shadowoffy and shadowc then
					shadowc = setColorAlpha(shadowc,getColorAlpha(shadowc)*galpha)
					dxDrawText(colorcoded and removeColorCodeFromString(text) or text,x+shadowoffx,y+shadowoffy,x+w,y+h,shadowc,txtSizX,txtSizY,font,rightbottom[1],rightbottom[2],clip,wordbreak,not DEBUG_MODE and isRenderTarget)
				end
				dxDrawText(text,x,y,x+w,y+h,colors,txtSizX,txtSizY,font,rightbottom[1],rightbottom[2],clip,wordbreak,not DEBUG_MODE and isRenderTarget,colorcoded)
				if enabled then
					if mx >= cx-2 and mx<= cx+w-1 and my >= cy-2 and my <= cy+h-1 then
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
				columncolor = setColorAlpha(columncolor,getColorAlpha(columncolor)*galpha)
				bgcolor = setColorAlpha(bgcolor,getColorAlpha(bgcolor)*galpha)
				local columnHeight = DataTab.columnHeight
				if MouseData.enter == v then
					colorimgid = 2
					if MouseData.clickl == v then
						colorimgid = 3
					end
					MouseData.enterData = false
				end
				if bgimg then
					dxDrawImage(x,y+columnHeight,w,h-columnHeight,bgimg,0,0,0,bgcolor,not DEBUG_MODE and isRenderTarget)
				else
					dxDrawRectangle(x,y+columnHeight,w,h-columnHeight,bgcolor,not DEBUG_MODE and isRenderTarget)
				end
				if columnimg then
					dxDrawImage(x,y,w,columnHeight,columnimg,0,0,0,columncolor,not DEBUG_MODE and isRenderTarget)
				else
					dxDrawRectangle(x,y,w,columnHeight,columncolor,not DEBUG_MODE and isRenderTarget)
				end
				local columnTextColor = DataTab.columntextcolor
				local font = DataTab.font or msyh_ms
				local renderTarget = DataTab.renderTarget
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
				local whichRowToStart = -math.floor((DataTab.rowMoveOffset+rowHeight)/rowHeight)+1
				local whichRowToEnd = whichRowToStart+math.floor((h-columnHeight-scbThick+rowHeight*2)/rowHeight)-1
				DataTab.FromTo = {whichRowToStart > 0 and whichRowToStart or 1,whichRowToEnd <= #rowData and whichRowToEnd or #rowData}
				local fnc = dgsElementData[v].functions
				if type(fnc) == "table" then
					fnc[1](unpack(fnc[2]))
				end
				local isDraw1,isDraw2 = isElement(renderTarget[1]),isElement(renderTarget[2])
				dxSetRenderTarget(renderTarget[1],true)
					local sizex,sizey = DataTab.columntextsize[1],DataTab.columntextsize[2]
					local tempFont = textFontSize[font] or 1
					local fontSizex = sizex*tempFont
					local fontSizey = (sizey or sizex)*tempFont
					local cpos = {}
					local multipiler = columnRelt and (w-scbThick) or 1
					for id,data in ipairs(columnData) do
						local textxSize = data[2]*multipiler
						cpos[id] = columnData[id][3]*multipiler
						if isDraw1 then
							if DataTab.columnShadow then
								dxDrawText(data[1],2+cpos[id]+columnMoveOffset,1,sW,columnHeight,black,fontSizex,fontSizey,font,"left","center",false,false,false,false,true)
							end
							dxDrawText(data[1],1+cpos[id]+columnMoveOffset,0,sW,columnHeight,columnTextColor,fontSizex,fontSizey,font,"left","center",false,false,false,false,true)
						end
					end
				dxSetRenderTarget(renderTarget[2],true)
					if MouseData.enter == v then		-------PreSelect
						local ypcolumn = cy+columnHeight
						if mx >= cx-2 and mx <= cx+w-1 and my >= ypcolumn and my <= cy+h-scbThick-1 then
							local toffset = (whichRowToStart*rowHeight)+DataTab.rowMoveOffset
							sid = math.floor((my-ypcolumn-toffset)/rowHeight)+whichRowToStart+1
							if sid <= #rowData then
								DataTab.preSelect = sid
								MouseData.enterData = true
							else
								DataTab.preSelect = -1
							end
						else
							DataTab.preSelect = -1
						end
					end
					local preSelect = DataTab.preSelect
					local Select = DataTab.select
					local sizex,sizey = DataTab.rowtextsize[1],DataTab.rowtextsize[2]
					local fontsx,fontsy = sizex*(textFontSize[font] or 1),(sizey or sizex)*(textFontSize[font] or 1)
					for i=DataTab.FromTo[1],DataTab.FromTo[2] do
						local lc_rowData = rowData[i]
						local image = lc_rowData[-3]
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
							local rowpos_1 = (i-1)*rowHeight
							if #image > 0 then
								dxDrawImage(0,1+rowpos_1+rowMoveOffset,w,rowHeight,image[rowState],0,0,0,color[rowState])
							else
								dxDrawRectangle(0,1+rowpos_1+rowMoveOffset,w,rowHeight,color[rowState])
							end
							local _x,_y,_sx,_sy = 1+columnMoveOffset,rowpos_1+rowMoveOffset,sW,rowpos+rowMoveOffset
							for id=1,#columnData do
								local offset = cpos[id]
								local _x = _x+offset
								if shadow then
									dxDrawText(string.gsub(lc_rowData[id][1], "#%x%x%x%x%x%x", "") or lc_rowData[id][1],_x+shadow[1],_y+shadow[2],_sx+shadow[1],_sy+shadow[2],shadow[3],fontsx,fontsy,font,"left","center",false,false,false,false,true)
								end
								dxDrawText(lc_rowData[id][1],_x,_y,_sx,_sy,lc_rowData[id][2],fontsx,fontsy,font,"left","center",false,false,false,colorcoded,true)
							end
						end
					end
				dxSetRenderTarget(rndtgt)
				if isElement(renderTarget[2]) then
					dxDrawImage(x,y+columnHeight,w,h-columnHeight-scbThick,renderTarget[2],0,0,0,tocolor(255,255,255,255*galpha),not DEBUG_MODE and isRenderTarget)
				end
				if isElement(renderTarget[1]) then
					dxDrawImage(x,y,w,columnHeight,renderTarget[1],0,0,0,tocolor(255,255,255,255*galpha),not DEBUG_MODE and isRenderTarget)
				end
				if enabled then
					if mx >= cx-2 and mx<= cx+w-1 and my >= cy-2 and my <= cy+h-1 then
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
				bgcolor = setColorAlpha(bgcolor,getColorAlpha(bgcolor)*galpha)
				barcolor = setColorAlpha(barcolor,getColorAlpha(barcolor)*galpha)
				local bgimg = dgsElementData[v].bgimg
				local barimg = dgsElementData[v].barimg
				local barmode = dgsElementData[v].barmode
				local udspace = dgsElementData[v].udspace
				local lrspace = dgsElementData[v].lrspace
				local udvalue = udspace[2] and udspace[1]*h or udspace[1]
				local lrvalue = lrspace[2] and lrspace[1]*w or lrspace[1]
				if bgimg then
					local sx,sy = unpack(dgsElementData[v].imagesize)
					local px,py = unpack(dgsElementData[v].imagepos)
					dxDrawImage(x,y,w,h,bgimg,0,0,0,bgcolor,not DEBUG_MODE and isRenderTarget)
				else
					dxDrawRectangle(x,y,w,h,bgcolor,not DEBUG_MODE and isRenderTarget)
				end
				local percent = dgsElementData[v].progress/100
				if barimg then
					local sx,sy = dgsElementData[v].barsize[1],dgsElementData[v].barsize[2]
					local fnc = dgsElementData[v].functions
					if type(fnc) == "table" then
						fnc[1](unpack(fnc[2]))
					end
					if not sx or not sy or not barmode then
						dxDrawImage(x+lrvalue,y+udvalue,(w-lrvalue*2)*percent,h-udvalue*2,barimg,0,0,0,barcolor,not DEBUG_MODE and isRenderTarget)
					else
						dxDrawImageSection(x+lrvalue,y+udvalue,(w-lrvalue*2)*percent,h-udvalue*2,1,1,sx*percent,sy,barimg,0,0,0,barcolor,not DEBUG_MODE and isRenderTarget)
					end
				else
					dxDrawRectangle(x+lrvalue,y+udvalue,(w-lrvalue*2)*percent,h-udvalue*2,barcolor,not DEBUG_MODE and isRenderTarget)
				end
				if enabled then
					if mx >= cx-2 and mx<= cx+w-1 and my >= cy-2 and my <= cy+h-1 then
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
				local font = dgsElementData[v].font or msyh_ms
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
						dxDrawImage(x,y,w,height,rendt,0,0,0,setColorAlpha(white,getColorAlpha(white)*galpha),not DEBUG_MODE)
						local colors = setColorAlpha(dgsElementData[tabs[selected]]["bgcolor"],getColorAlpha(dgsElementData[tabs[selected]]["bgcolor"])*galpha)
						if dgsElementData[tabs[selected]]["bgimg"] then
							dxDrawImage(x,y+height,w,h-height,dgsElementData[tabs[selected]]["bgimg"],0,0,0,colors,not DEBUG_MODE)
						else
							dxDrawRectangle(x,y+height,w,h-height,colors,not DEBUG_MODE)
						end
						for cid,child in pairs(dgsGetChildren(tabs[selected])) do
							renderGUI(child,mx,my,enabled,rndtgt,OffsetX,OffsetY,galpha,visible)
						end
					end
				end
				if enabled then
					if MouseData.hit == hits then
						if mx >= cx-2 and mx<= cx+w-1 and my >= cy-2 and my <= cy+h-1 then
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
				colors = setColorAlpha(colors,getColorAlpha(colors)*galpha)
				if imgs then
					dxDrawImage(x,y,w,h,imgs,0,0,0,colors,not DEBUG_MODE and isRenderTarget)
				else
					dxDrawRectangle(x,y,w,h,colors,not DEBUG_MODE and isRenderTarget)
				end
				local hangju,cmdtexts = dgsElementData[v].hangju,dgsElementData[v].text or {}
				local canshow = math.floor(h/dgsElementData[v].hangju)-1
				local rowoffset = 0
				local readyToRenderTable = {}
				local font = dgsElementData[v].font or dsm
				local txtSizX,txtSizY = dgsElementData[v].textsize[1]*(textFontSize[font] or 1),dgsElementData[v].textsize[2]*(textFontSize[font] or 1)
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
					dxDrawText(readyToRenderTable[i],x+5,y+(i-1)*hangju,x+width+5,y+i*hangju,white,txtSizX,txtSizY,font,"left","bottom",false,true,not DEBUG_MODE and isRenderTarget)
				end
				if enabled then
					if mx >= cx-2 and mx<= cx+w-1 and my >= cy-2 and my <= cy+h-1 then
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
		for k,child in pairs(children) do
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
	local lor = dgsElementData[gui].lor
	local tob = dgsElementData[gui].tob
	local ax,ay = dgsGetPosition(gui,false,true,true)
	local cx,cy = dgsGetPosition(gui,false,true)
	x,y = rndtgt and ax or x,rndtgt and ay or y
	if dgsGetType(parent) == "dgs-dxscrollpane" then
		local psx,psy = unpack(dgsElementData[parent].absSize)
		local sx,sy = unpack(dgsElementData[gui].absSize)
		if x > psx-offsetx or y > psy-offsety or x+sx < -offsetx or y+sy < -offsety then
			ccax = ccax+1
			return false,false
		end
	end
	if lor == "right" then
		local px = 0
		local psx = sW
		if isElement(parent) then
			px = dgsElementData[parent].absPos[1]
			psx = dgsElementData[parent].absSize[1]
		end
		x = px*2+psx-x
	end
	if tob == "bottom" then
		local py = 0
		local psy = sH
		if isElement(parent) then
			if dgsGetType(parent) == "dgs-dxtab" then
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
	end
end
addEventHandler("onClientKey",root,checkEditCursor)

addEventHandler("onClientGUIFocus",resourceRoot,function()
	if getElementType(source) == "gui-edit" then
		local edit = dgsElementData[source].dxedit
		if isElement(edit) then
			dgsDxGUIBringToFront(edit,"left")
		end
	end
end)

addEventHandler("onClientGUIBlur",resourceRoot,function()
	if getElementType(source) == "gui-edit" then
		local edit = dgsElementData[source].dxedit
		if isElement(edit) then
			if MouseData.nowShow == edit then
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

addEventHandler("onClientGUIChanged",root,function()
	if getElementType(source) == "gui-edit" then
		if not dgsElementData[source] then return end
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
				local offset = presele > 0 and 1 or string.count(text_new)-string.count(text_old)
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
						dgsDxEditSetCaretPosition(myedit,pos+string.count(text_new)-string.count(text_old))
					else
						if sele > 0 then
							dgsDxEditSetCaretPosition(myedit,pos)
						else
							dgsDxEditSetCaretPosition(myedit,pos+string.count(text_new)-string.count(text_old))
						end
					end
				else
					dgsDxEditSetCaretPosition(myedit,pos+offset)
				end
				local pos = dgsElementData[myedit].cursorpos
				if pos > string.count(text_new) then
					dgsDxEditSetCaretPosition(myedit,string.count(text_new))
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
			end
			if guitype == "dgs-dxgridlist" then
				local preSelect = dgsElementData[source].preSelect
				local oldSelect = dgsElementData[source].select
				dgsElementData[source].select = preSelect
				triggerEvent("onClientDgsDxGridListSelect",source,oldSelect,preSelect)
			end
			if guitype == "dgs-dxtabpanel" then
				if dgsElementData[source]["preselect"] ~= -1 then
					dgsSetData(source,"selected",dgsElementData[source]["preselect"])
				end
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
		triggerEvent("onClientDgsDxGuiDestroy",source)
		local child = ChildrenTable[source] or {}
		for k=1,#child do
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
			destroyElement(rentarg)
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

addEventHandler("onClientClick",root,function(button,state,x,y)
	local guiele = dgsDxGetMouseEnterGUI()
	if isElement(guiele) then
		if button == "left" and state == "down" then
			if dgsGetType(guiele) == "dgs-dxradiobutton" then
				dgsDxRadioButtonSetSelected(guiele,true)
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
	for k,v in pairs(ChildrenTable[source] or {}) do
		local relativePos,relativeSize = unpack(dgsElementData[v].relative)
		local x,y
		if relativePos then
			x,y = unpack(dgsElementData[v].rltPos)
		end
		calculateGuiPositionSize(v,x,y,relativePos)
	end
end)

addEventHandler("onClientDgsDxGUISizeChange",root,function()
	for k,v in pairs(ChildrenTable[source] or {}) do
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
		configGirdList(source)
	elseif typ == "dgs-dxcmd" then
		configCMD(source)
	elseif typ == "dgs-dxedit" then
		configEdit(source)
	elseif typ == "dgs-dxscrollpane" then
		configScrollPane(source)
	elseif typ == "dgs-dxtabpanel" then
		configTabPanel(source)
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