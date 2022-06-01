dgsLogLuaMemory()
local loadstring = loadstring


function executeTest()

function random(n, m)
    math.randomseed(os.clock()*math.random(1000000,90000000)+math.random(1000000,90000000))
    return math.random(n, m)
end

function randomNumber(len)
    local rt = ""
    for i=1,len,1 do
        if i == 1 then
            rt = rt..random(1,9)
        else
            rt = rt..random(0,9)
        end
    end
    return rt
end

function randomLetter(len)
    local rt = ""
    for i = 1, len, 1 do
        rt = rt..string.char(random(97,122))
    end
    return rt
end
------------Full demo
function createFullDemoOOP()
	local DGSOOPFnc,err = loadstring(dgsImportOOPClass())
	DGSOOPFnc()
	local demoUI = { page = {} }
	
	local demoFunction = {
		["Button"] = function(parent)
			local nBtn = parent:dgsButton(10,10,120,60,"Normal\nButton",false)
			local tBtn = parent:dgsButton(140,10,120,60,"Button\nTransition",false)
				:setProperty("colorTransitionPeriod",100)
			if dgsCreateRoundRect then
				local rndRect = dgsCreateRoundRect(10,false,tocolor(255,255,255,255))
				dgsRoundRectSetColorOverwritten(rndRect,false)
				local rndBtn = parent:dgsButton(270,10,120,60,"Button\nRounded",false)
					:setProperty("image",rndRect)
				local rndtBtn = parent:dgsButton(400,10,120,60,"Button\nRounded\nTransition",false)
					:setProperty("image",rndRect)
					:setProperty("colorTransitionPeriod",100)
					
			local iBtn = parent:dgsButton(10,80,120,60,"Button\nText\nColor",false)
				:setProperty("iconImage",rndRect)
				:setProperty("iconOffset",{0,0,true})
				:setProperty("iconRelative",false)
				:setProperty("iconAlignment",{"right","center"})
			end
			if dgsCreateCircle then
				local circle = dgsCreateCircle(0.49,0)
				dgsCircleSetColorOverwritten(circle,false)
				local cirBtn = parent:dgsButton(530,10,60,60,"Button\nCircle",false)
					:setProperty("image",circle)
			end
			local sBtn0 = parent:dgsButton(10,150,120,60,"Button\nShadow",false)
				:setProperty("shadow",{1,1,tocolor(0,0,0,255)})
			local sBtn1 = parent:dgsButton(140,150,120,60,"Button\nShadow1",false)
				:setProperty("shadow",{1,1,tocolor(0,0,0,255),1})
			local sBtn2 = parent:dgsButton(270,150,120,60,"Button\nShadow2",false)
				:setProperty("shadow",{1,1,tocolor(0,0,0,255),2})
			local sBtn2 = parent:dgsButton(400,150,120,60,"Button\nText\nColor",false)
				:setProperty("textColor",{tocolor(255,255,255,255),tocolor(255,0,0,255),tocolor(0,255,255,255)})
				
		end,
		["ColorPicker"] = dgsCreateColorPicker and function(parent)
			--Color Picker HSVRing
			local cpRing = parent:dgsColorPicker("HSVRing",200,40,200,200)
			local rSel = parent:dgsComponentSelector(40,260,150,10,true)
				:bindToColorPicker(cpRing,"RGB","R",true)
			local rSelEdit = parent:dgsEdit(200,255,40,20)
				:bindToColorPicker(cpRing,"RGB","R",true)
			local gSel = parent:dgsComponentSelector(40,290,150,10,true)
				:bindToColorPicker(cpRing,"RGB","G",true)
			local gSelEdit = parent:dgsEdit(200,285,40,20)
				:bindToColorPicker(cpRing,"RGB","G",true)
			local bSel = parent:dgsComponentSelector(40,320,150,10,true)
				:bindToColorPicker(cpRing,"RGB","B",true)
			local bSelEdit = parent:dgsEdit(200,315,40,20)
				:bindToColorPicker(cpRing,"RGB","B",true)
			local hSel = parent:dgsComponentSelector(280,260,150,10,true)
				:bindToColorPicker(cpRing,"HSV","H",true)
			local hSelEdit = parent:dgsEdit(440,255,40,20)
				:bindToColorPicker(cpRing,"HSV","H",true)
			local sSel = parent:dgsComponentSelector(280,290,150,10,true)
				:bindToColorPicker(cpRing,"HSV","S",true)
			local sSelEdit = parent:dgsEdit(440,285,40,20)
				:bindToColorPicker(cpRing,"HSV","S",true)
			local vSel = parent:dgsComponentSelector(280,320,150,10,true)
				:bindToColorPicker(cpRing,"HSV","V",true)
			local vSelEdit = parent:dgsEdit(440,315,40,20)
				:bindToColorPicker(cpRing,"HSV","V",true)
			local aSel = parent:dgsComponentSelector(40,350,390,10,true)
				:bindToColorPicker(cpRing,"RGB","A")
			local aSelEdit = parent:dgsEdit(440,345,40,20)
				:bindToColorPicker(cpRing,"RGB","A",true)
			local demo = parent:dgsImage(530,255,80,80,_,false)
			local rgbaSelEdit = parent:dgsEdit(530,345,80,20)
				:bindToColorPicker(cpRing,"#RGBAHEX","RGBA",true)
			cpRing:on("dgsColorPickerChange",function(oldRGB,oldHSL,oldHSV,oldAlp)
				local R,G,B,A = cpRing:getColor("RGB")
				demo:setProperty("color",tocolor(R,G,B,A))
			end)
		end,
		["ComboBox"] = function(parent)
			local nCombobox = parent:dgsComboBox(10,10,150,30,"ComboBox1",false)
				:setBoxHeight(200)
				:setProperty("shadow",{1,1,tocolor(0,0,0,255)})
				:setProperty("itemTextColor",{tocolor(255,255,255,255),tocolor(255,0,0,255),tocolor(0,255,255,255)})
			for i=1,100 do
				nCombobox:addItem(i)
			end
			
			local cCombobox = parent:dgsComboBox(180,10,150,30,"ComboBox2",false)
				:setEditEnabled(true)
				:setBoxHeight(200)
			for i=1,100 do
				cCombobox:addItem(i)
			end
			
			local strangeComboboxA = parent:dgsComboBox(360,10,60,30,"ComboBox2",false)
				:setProperty("textBox",false)
				:setBoxHeight(200)
			for i=1,100 do
				strangeComboboxA:addItem(i)
			end
			
			local strangeComboboxB = parent:dgsComboBox(450,10,150,30,"ComboBox2",false)
				:setProperty("buttonLen",{2,true})
				:setBoxHeight(200)
			for i=1,100 do
				strangeComboboxB:addItem(i)
			end
		end,
		["Image"] = function(parent)
			local nImage = parent:dgsImage(10,10,100,100,_,false)
			local pImage = parent:dgsImage(120,10,100,100,"styleManager/Default/Images/cursor/CursorMove.png",false)
			local texture = dxCreateTexture("styleManager/Default/Images/cursor/CursorArrow.png")
			local tImage = parent:dgsImage(230,10,100,100,texture,false)
			
			if dgsCreateRoundRect then
				local rndRect = dgsCreateRoundRect(10,false,tocolor(255,255,255,255))
				dgsRoundRectSetColorOverwritten(rndRect,false)
				local rndImage = parent:dgsImage(10,120,100,100,rndRect,false)
					:setProperty("color",tocolor(86,98,246,255))
			end
			if dgsCreateCircle then
				local circle = dgsCreateCircle(0.49,0)
				dgsCircleSetColorOverwritten(circle,false)
				local cirImage = parent:dgsImage(120,120,100,100,circle,false)
					:setProperty("color",tocolor(118,47,156,255))
			end
		end,
		["Label"] = function(parent)
			local nLabel = parent:dgsLabel(10,10,200,20,"This is a DGS Label",false)
			local ccLabel = parent:dgsLabel(10,40,200,20,"This is a #FF0000DGS #FFFFFFLabel with #00FF00Color #00FFFFCode",false)
				:setProperty("colorCoded",true)
			local sLabel1 = parent:dgsLabel(10,70,200,20,"This is a DGS Label with shadow",false)
				:setProperty("shadow",{1,1,tocolor(128,128,128,255)})
			local sLabel2 = parent:dgsLabel(10,100,200,20,"This is a DGS Label with shadow outline 1",false)
				:setProperty("shadow",{1,1,tocolor(128,128,128,255),1})
			local sLabel3 = parent:dgsLabel(10,130,200,20,"This is a DGS Label with shadow outline 2",false)
				:setProperty("shadow",{1,1,tocolor(128,128,128,255),2})
			local wbLabel = parent:dgsLabel(10,160,240,20,"This is a DGS Label with word break, this can not be used together with colorCoded",false)
				:setProperty("wordBreak",true)
			local rLabel = parent:dgsLabel(10,220,200,20,"Do you want a rotation?",false)
				:setProperty("rotation",45)
				:setProperty("rotationCenter",{10,10})
		end,
		["Memo"] = function(parent)
			local memo = parent
				:dgsMemo(10,10,630,555,"",false)
				:setText(dgsImportOOPClass())
				:setCaretPosition(10,20)
				:setProperty("shadow",{1,1,tocolor(0,0,0,255)})
		end,
		["Edit"] = function(parent)
			--Normal
			local edit = parent:dgsEdit(50,40,400,40,"DGS Edit Box",false)
				:setProperty("textSize",{2,2})
			--Caret
			local edit2 = parent:dgsEdit(50,120,400,40,"DGS Edit Box",false)
				:setProperty("textSize",{2,2})
				:setProperty("caretStyle",1)
			--PlaceHolder With AutoComplete
			local edit3 = parent:dgsEdit(50,200,400,40,"",false)
				:setProperty("textSize",{2,2})
				:setProperty("placeHolder","Type 'Hello'")
				:addAutoComplete("HelloWorld",true)
			--Alignment
			local edit4 = parent:dgsEdit(50,280,400,40,"DGS Edit Box",false)
				:setProperty("textSize",{2,2})
				:setProperty("alignment",{"center", "center"})
			--dgsEditSetMasked (edit4, true)
		end,
		["GridList"] = function(parent)
			--[[local colorA = {tocolor(255,0,0,255),tocolor(255,0,0,255),tocolor(255,0,0,255)}
			local colorB = {tocolor(0,255,0,255),tocolor(0,255,0,255),tocolor(0,255,0,255)}
			local colorC = {tocolor(0,0,255,255),tocolor(0,0,255,255),tocolor(0,0,255,255)}]]
			local gridlist = parent
				:dgsGridList(10,10,630,250,false)
				:setMultiSelectionEnabled(true)
				:setProperty("columnShadow",{1,1,tocolor(0,0,0,255),2})
				:setProperty("rowTextSize",{1.2,1.2})
				:setProperty("rowHeight",20)
				--[[:setProperty("itemColorTemplate",{
					{colorA,colorB,colorC},
					{colorB,colorC,colorA},
					{colorC,colorA,colorB},
				})]]
				:setProperty("clip",true)
				:setProperty("rowWordBreak",true)
				:setProperty("rowShadow",{1,1,tocolor(0,0,0,255),2})
				:setSelectionMode(3)
				:setProperty("rowTextColor",{tocolor(255,255,255,255),tocolor(0,255,255,255),tocolor(255,0,255,255)})
				:setProperty("defaultSortFunctions",{"longerUpper","longerLower"})
			for i=1,10 do
				gridlist:addColumn("Column "..i,0.2)
			end
			for i=1,100 do
				gridlist:addRow(i,i,string.rep("x",math.random(1,40)))
			end
			gridlist
				:setItemColor(-1,2,{tocolor(255,0,0,255),tocolor(0,255,0,255),tocolor(255,255,0,255)})
				:scollTo(50,1)
				:setItemAlignment(1,1,"center")
				:setColumnAlignment(1,"left")
				
			
			local gridlistAttach = parent
				:dgsGridList(10,270,630,250,false)
				:setMultiSelectionEnabled(true)
				:setProperty("rowHeight",40)
				:setProperty("clip",true)
			gridlistAttach:addColumn("Column1",0.5)
			gridlistAttach:addColumn("Column2",0.5)
			for i=1,10 do
				gridlistAttach:addRow(_,"Row "..i)
				local edit = dgsEdit(10,10,40,20,i,false)
				edit:attachToGridList(gridlistAttach,i,2)
			end
		end,
		["ProgressBar"] = function(parent)
			local autoProgress = [[
					local progress = dgsGetProperty(self,"progress")
					dgsSetProperty(self,"progress",(progress+0.5)%100)
					return true
				]]
			local progressBar_V1 = parent
				:dgsProgressBar(40,40,40,200,false)
				:setStyle("normal-vertical")
				:setProperty("functions",autoProgress)
			local progressBar_V2 = parent
				:dgsProgressBar(120,40,40,200,false)
				:setStyle("normal-vertical")
				:setProperty("functions",autoProgress)
				:setProperty("indicatorColor",{tocolor(65,113,170,255),tocolor(221,80,68,255)})
			local progressBar_H1 = parent
				:dgsProgressBar(200,40,200,40,false)
				:setStyle("normal-horizontal")
				:setProperty("functions",autoProgress)
			local progressBar_H2 = parent
				:dgsProgressBar(200,120,200,40,false)
				:setStyle("normal-horizontal")
				:setProperty("functions",autoProgress)
				:setProperty("indicatorColor",{tocolor(65,113,170,255),tocolor(221,80,68,255)})
			if dgsCreateRoundRect then
				local rndRect1 = dgsCreateRoundRect(10,false,tocolor(255,255,255,255))
				local rndRect2 = dgsCreateRoundRect(8,false,tocolor(255,255,255,255))
				dgsRoundRectSetColorOverwritten(rndRect1,false)
				dgsRoundRectSetColorOverwritten(rndRect2,false)
				local progressBar_H3 = parent
					:dgsProgressBar(200,200,200,40,false)
					:setStyle("normal-horizontal")
					:setProperty("functions",autoProgress)
					:setProperty("bgImage",rndRect1)
					:setProperty("indicatorImage",rndRect2)
			end
			local progressBar_RR = parent
				:dgsProgressBar(40,280,200,200,false)
				:setStyle("ring-round")
				:setProperty("functions",autoProgress)
				:setProperty("radius",0.4)
				:setProperty("thickness",0.05)
			local progressBar_RP = parent
				:dgsProgressBar(260,280,200,200,false)
				:setStyle("ring-plain")
				:setProperty("functions",autoProgress)
				:setProperty("radius",0.4)
				:setProperty("thickness",0.05)
		end,
		["RadioButton"] = function(parent)
			local RadioButton1 = parent:dgsRadioButton(10,10,180,30,"This is a radio button for demo",false)
			local RadioButton2 = parent:dgsRadioButton(10,50,180,30,"This is a #FF0000radio #00FF00button #FFFFFFfor #0000FFdemo",false)
				:setProperty("colorCoded",true)
			local RadioButton3 = parent:dgsRadioButton(10,90,180,30,"This is a is a bigger radio button",false)
				:setProperty("buttonSize",{1,true})
			local RadioButton4 = parent:dgsRadioButton(10,130,180,30,"This is a is a farther radio button",false)
				:setProperty("textPadding",{0.5,true})
		end,
		["CheckBox"] = function(parent)
			local CheckBox1 = parent:dgsCheckBox(10,10,180,30,"This is a check box for demo",false)
			local CheckBox2 = parent:dgsCheckBox(10,50,180,30,"This is a #FF0000check #00FF00box #FFFFFFfor #0000FFdemo",false)
				:setProperty("colorCoded",true)
			local CheckBox3 = parent:dgsCheckBox(10,90,180,30,"This is a is a bigger check box",false)
				:setProperty("buttonSize",{1,true})
			local CheckBox4 = parent:dgsCheckBox(10,130,180,30,"This is a is a farther check box",false)
				:setProperty("textPadding",{0.5,true})
		end,
		["ScrollBar"] = function(parent)
			local scbV = parent:dgsScrollBar(10,10,30,400,false,false)
			local scbH = parent:dgsScrollBar(50,10,400,30,true,false)
			local scbHDiff = parent:dgsScrollBar(50,50,400,30,true,false)
				:setProperty("troughWidth",{10,false})
				:setProperty("arrowWidth",{20,false})
			local scbHNoArrow = parent:dgsScrollBar(50,90,400,30,true,false)
				:setProperty("scrollArrow",false)
			if dgsCreateCircle then
				local circle = dgsCreateCircle(0.49,0)
				local rndRectR = dgsCreateRoundRect({{0,false},{15,false},{15,false},{0,false}},tocolor(255,255,255,255))
				local rndRectL = dgsCreateRoundRect({{15,false},{0,false},{0,false},{15,false}},tocolor(255,255,255,255))
				dgsRoundRectSetColorOverwritten(rndRectL,false)
				dgsRoundRectSetColorOverwritten(rndRectR,false)
				dgsCircleSetColorOverwritten(circle,false)
				local scbHCir = parent:dgsScrollBar(50,130,400,30,true,false)
					:setProperty("scrollArrow",false)
					:setProperty("cursorImage",circle)
					:setProperty("troughImage",{rndRectL,rndRectR})
			end
		end,
		["ScrollPane"] = function(parent)
			local scp = parent:dgsScrollPane(10,10,630,555,false)
			for row=0,10 do
				for column=0,10 do
					scp:dgsButton(row*80,column*80,70,70,row.."-"..column,false)
				end
			end
		end,
		["SwitchButton"] = function(parent)
			local switchBtn = parent:dgsSwitchButton(10,10,100,30,"on","off",false)
				:setProperty("shadow",{1,1,tocolor(0,0,0,255),2})
			local switchBtnR = parent:dgsSwitchButton(120,10,100,30,"on","off",false)
				:setProperty("isReverse",true)
			local switchBtnM = parent:dgsSwitchButton(230,10,100,30,"on","off",false)
				:setProperty("style",3)
			local switchBtnT = parent:dgsSwitchButton(10,50,100,30,"on","off",false)
				:setProperty("troughWidth",{20,false})
			local switchBtnC = parent:dgsSwitchButton(120,50,100,30,"on","off",false)
				:setProperty("cursorWidth",{20,false})
		end,
		["TabPanel"] = function(parent)
			local tabPanelA = parent
				:dgsTabPanel(10,10,630,250,false)
			local tab1 = tabPanelA:dgsTab("Tab1")
			tab1:dgsLabel(10,10,100,20,"This is tab 1",false)
				:setProperty("textSize",{1.5,1.5})
			local tab2 = tabPanelA:dgsTab("Tab2")
			tab2:dgsLabel(10,10,100,20,"This is tab 2",false)
				:setProperty("textSize",{1.5,1.5})
			
			local tabPanelB = parent
				:dgsTabPanel(10,280,630,250,false)
				:setProperty("tabAlignment","center")
				:setProperty("tabHeight",{40,false})
			local tab1 = tabPanelB:dgsTab("Tab1")
				:setProperty("textSize",{2,2})
			tab1:dgsLabel(10,10,100,20,"This is tab 1",false)
				:setProperty("textSize",{1.5,1.5})
			local tab2 = tabPanelB:dgsTab("Tab2")
				:setProperty("textSize",{2,2})
				:setProperty("shadow",{1,1,tocolor(0,0,0,255),2})
			tab2:dgsLabel(10,10,100,20,"This is tab 2",false)
				:setProperty("textSize",{1.5,1.5})
		end,
		["Selector"] = function(parent)
			local selectorA = parent:dgsSelector(10,10,100,20,false)
			for i=1,50 do
				selectorA:addItem(i)
			end
			local selectorB = parent:dgsSelector(10,40,100,20,false)
			local selectorC = parent:dgsSelector(10,70,100,20,false)
				:setProperty("selectorImageColorLeft",{tocolor(200,20,20,255),tocolor(250,20,20,255),tocolor(150,50,50,255)})
				:setProperty("selectorImageColorRight",{tocolor(20,200,20,255),tocolor(20,250,20,255),tocolor(50,150,50,255)})
			for i=1,50 do
				selectorC:addItem(i)
			end
			local selectorD = parent:dgsSelector(10,100,100,20,false)
				:setProperty("selectorText",{"-","+"})
			for i=1,50 do
				selectorD:addItem(i)
			end
		end,
	}
	demoUI.window = dgsWindow(0,0,800,600,"DGS Full Demo",false)
		:setProperty("textSize",{1.5,1.5})
	demoUI.window.position.relative = false
	demoUI.window.position.x = sW/2-400
	demoUI.window.position.y = sH/2-300
	demoUI.demoList = demoUI.window:dgsGridList(0,0,150,600-25,false)
		:setProperties({
			columnHeight = 0,
			rowHeight = 40,
			rowTextSize = {2,2},
			sortEnabled = false,
		})
	demoUI.demoList:addColumn("",1)
	for i,name in pairs(table.getKeys(demoFunction)) do
		demoUI.demoList:addRow(_,name)
		demoUI.page[i] = demoUI.window:dgsLabel(150,0,800-150,600-25,"",false)
			:setVisible(false)
		demoFunction[name](demoUI.page[i])
	end
	demoUI.demoList:on("dgsGridListSelect",function(r,c,oldr,oldc)
		if oldr ~= -1 then
			if demoUI.page[oldr] then
				demoUI.page[oldr]:setVisible(false)
			end
		end
		if r ~= -1 then
			if demoUI.page[r] then
				demoUI.page[r]:setVisible(true)
			end
		end
	end)
	demoUI.window.alpha = 1
end
--createFullDemoOOP()

function ProgressBarTest()
	local pb= dgsCreateProgressBar(500,200,600,600,false)
	dgsSetProperty(pb,"bgColor",tocolor(0,0,0,255))
	dgsProgressBarSetStyle(pb,"ring-plain")
	dgsSetProperty(pb,"isReverse",true)
	dgsSetAlpha(pb,0.5)
	local start = 0
	addEventHandler("onClientRender",root,function()
		dgsProgressBarSetProgress(pb,start)
		start = start + 0.1
	end)
end

function MemoTest()
	local sW,sH = dgsGetScreenSize()
	local memo = dgsCreateMemo(200,200,500,500,[[]],false)
	--dgsSetFont(memo,"default-bold")
	--dgsSetProperty(memo,"selectVisible",false)
	--dgsSetProperty(memo,"padding",{20,10})
	--dgsMemoSetWordWrapState(memo,true)
	--local x,y = dgsMemoGetTextBoundingBox(memo)
	--dgsSetSize(memo,x,y)
	dgsSetText(memo,[[
	This is a dgs-dxmemo

	Thisdp's DirectX Graphical User Interface System, Thisdp's DirectX Graphical User Interface System
	Thisdp's DirectX Graphical User Interface System, Thisdp's DirectX Graphical User Interface System
	Thisdp's DirectX Graphical User Interface System, Thisdp's DirectX Graphical User Interface System
	Thisdp's DirectX Graphical User Interface System, Thisdp's DirectX Graphical User Interface System
	Thisdp's DirectX Graphical User Interface System, Thisdp's DirectX Graphical User Interface System
	Thisdp's DirectX Graphical User Interface System, Thisdp's DirectX Graphical User Interface System
	Thisdp's DirectX Graphical User Interface System, Thisdp's DirectX Graphical User Interface System
	Thisdp's DirectX Graphical User Interface System, Thisdp's DirectX Graphical User Interface System
	Thisdp's DirectX Graphical User Interface System, Thisdp's DirectX Graphical User Interface System
	Thisdp's DirectX Graphical User Interface System, Thisdp's DirectX Graphical User Interface System
	Thisdp's DirectX Graphical User Interface System, Thisdp's DirectX Graphical User Interface System
	Thisdp's DirectX Graphical User Interface System, Thisdp's DirectX Graphical User Interface System
	Thisdp's DirectX Graphical User Interface System, Thisdp's DirectX Graphical User Interface System
	Thisdp's DirectX Graphical User Interface System, Thisdp's DirectX Graphical User Interface System
	Thisdp's DirectX Graphical User Interface System, Thisdp's DirectX Graphical User Interface System
	Thisdp's DirectX Graphical User Interface System, Thisdp's DirectX Graphical User Interface System
	Thisdp's DirectX Graphical User Interface System, Thisdp's DirectX Graphical User Interface System
	Thisdp's DirectX Graphical User Interface System, Thisdp's DirectX Graphical User Interface System
	Thisdp's DirectX Graphical User Interface System, Thisdp's DirectX Graphical User Interface System
	Thisdp's DirectX Graphical User Interface System, Thisdp's DirectX Graphical User Interface System
	Thisdp's DirectX Graphical User Interface System, Thisdp's DirectX Graphical User Interface System
	Thisdp's DirectX Graphical User Interface System, Thisdp's DirectX Graphical User Interface System
	Thisdp's DirectX Graphical User Interface System, Thisdp's DirectX Graphical User Interface System
	Thisdp's DirectX Graphical User Interface System, Thisdp's DirectX Graphical User Interface System
	Thisdp's DirectX Graphical User Interface System, Thisdp's DirectX Graphical User Interface System
	Thisdp's DirectX Graphical User Interface System, Thisdp's DirectX Graphical User Interface System
	Thisdp's DirectX Graphical User Interface System, Thisdp's DirectX Graphical User Interface System

	Test UTF8: 你好]])
	dgsMemoSetCaretPosition(memo,10,20)
	dgsSetProperty(memo,"shadow",{1,1,tocolor(0,0,0,255)})
	setTimer(function()
		guiMoveToBack(guiCreateLabel(0,0,100,100,"a",false))
	end,5000,1)
end

--[[
local arabicUnicode = {{0x0600,0x06FF},{0x08A0,0x08FF},{0x0750,0x077F},{0xFB50,0xFDFF},{0xFE70,0xFEFF},{0x1EE00,0x1EEFF}}
local arabicPattern = ""
for i=1,#arabicUnicode do
	arabicPattern = arabicPattern..utf8.char(arabicUnicode[i][1]).."-"..utf8.char(arabicUnicode[i][2])
end
arabicPattern = "["..arabicPattern.."]"
function hasArabicCharacters(text)
	return utf8.find(text,arabicPattern)
end

function isArabicCharacters(character)
	local code = utf8.byte(character)
	local isArabic = code >= arabicUnicode[1][1] and code <= arabicUnicode[1][2]
	isArabic = isArabic or (code >= arabicUnicode[2][1] and code <= arabicUnicode[2][2])
	isArabic = isArabic or (code >= arabicUnicode[3][1] and code <= arabicUnicode[3][2])
	isArabic = isArabic or (code >= arabicUnicode[4][1] and code <= arabicUnicode[4][2])
	isArabic = isArabic or (code >= arabicUnicode[5][1] and code <= arabicUnicode[5][2])
	isArabic = isArabic or (code >= arabicUnicode[6][1] and code <= arabicUnicode[6][2])
	return isArabic
end
print(hasArabicCharacters("aلعت القياسا"))

0x08A0-0x08FF
0x0750-0x077F
0xFB50-0xFDFF
0xFE70-0xFEFF
0x1EE00-0x1EEFF
]]
function AnimTest()
	if not dgsEasingFunctionExists("shadowOffset") then
		dgsAddEasingFunction("shadowOffset",[[
			local old = setting[3] or {}
			local new = setting[2]
			local offsetX = old[1] or 0
			local offsetY = old[2] or 0
			local offsetColor = old[3] or tocolor(0,0,0,255)
			local tofX,tofY = new[1],new[2]
			return {offsetX+(tofX-offsetX)*progress,offsetY+(tofY-offsetY)*progress,new[3]}
		]])
	end
	local label = dgsCreateLabel(500,500,400,20,"Testttttttttttttttttttt",false)
	dgsAnimTo(label,"shadow",{100,100,tocolor(0,0,0,255)},"shadowOffset",10000)
end

function GridListSortingTest()
	for x=1,10 do
		local sortfnc = [[
			local arg = {...}
			local column = dgsElementData[self].sortColumn
			return arg[1][column][1] < arg[2][column][1]
		]]

		--Be More Clear
		local sortfnc = [[
			local arg = {...}
			local a = arg[1]
			local b = arg[2]
			local column = dgsElementData[self].sortColumn
			local texta,textb = a[column][1],b[column][1]
			return texta < textb
		]]

		gridlist = dgsCreateGridList(200,50,600,600,false)
		dgsGridListAddColumn(gridlist,"test1",0.2)
		dgsSetProperty(gridlist,"mode",false)
		for i=1,30 do
			local row = dgsGridListAddRow(gridlist)
			dgsGridListSetItemText(gridlist,row,1,randomLetter(10)..tostring(i).." Test DGS")
		end
		for i=1,30 do
			local row = dgsGridListAddRow(gridlist)
			dgsGridListSetItemText(gridlist,row,1,tostring(i))
		end
		dgsSetProperty(gridlist,"defaultSortFunctions",{"numGreaterLowerStrFirst","numGreaterUpperStrFirst"})
		--dgsGridListSetSortEnabled(gridlist,false)
		--dgsGridListSetSortFunction(gridlist,sortfnc)
		--dgsGridListSetSortColumn(gridlist,2)
		dgsGridListSetVerticalScrollPosition(gridlist,45)
		dgsSetProperty(gridlist,"columnShadow",{1,1,tocolor(255,0,0,255)})
	end
	dgsBringToFront(gridlist)
end

function ComboBoxSortingTest()
	combobox = dgsCreateComboBox(200,50,600,50,false)
	for i=1,30 do
		dgsComboBoxAddItem(combobox,randomLetter(10)..tostring(i).." Test DGS")
	end
	for i=1,30 do
		dgsComboBoxAddItem(combobox,tostring(i))
	end
	dgsComboBoxSetSortFunction(combobox,"greaterUpper")
end

function GridListTest()
	gridlist = dgsCreateGridList(500,50,600,600,false)
	dgsSetProperty(gridlist,"scrollBarCoverColumn",false)
	dgsSetProperty(gridlist,"clip",false)
	--dgsSetProperty(gridlist,"leading",10)
	--dgsSetProperty(gridlist,"mode",true)
	dgsGridListAddColumn(gridlist,"test1",0.6)
	dgsGridListAddColumn(gridlist,"test2",0.4)
	dgsGridListAddColumn(gridlist,"test3",0.6)
	local tick = getTickCount()
	dgsSetProperty(gridlist,"rowHeight",200)
	dgsSetProperty(gridlist,"rowTextSize",{1.3,1.3})
	for i=1,10 do
		local row = dgsGridListAddRow(gridlist)
		local window = dgsCreateGridList(0,1,400,198,false)
		dgsGridListAddColumn(window,"t1",0.2)
		dgsGridListAddColumn(window,"t2",0.6)
		for x=1,100 do
			local row = dgsGridListAddRow(window)
			dgsGridListSetItemText(window,row,1,x.."xx")
			dgsGridListSetItemText(window,row,2,tostring(50-x).." Test DGS")
		end
		dgsAttachToGridList(window,gridlist,row,3)
		dgsGridListSetItemText(gridlist,row,1,i.."xx")
		dgsGridListSetItemText(gridlist,row,2,tostring(50-i).." Test DGS")
	end
	--dgsGridListAutoSizeColumn(gridlist,1,0,false,true)
	dgsGridListSetItemFont(gridlist,2,2,"default-bold")
end

function MediaBrowserTest()
	setDevelopmentMode(true,true)
	bro = dgsCreateMediaBrowser(600,600)
	mask = dgsCreateMask(bro,"backgroundFilter")
	toggleBrowserDevTools(bro,true)
	--rndRect1 = dgsCreateRoundRect(1,tocolor(255,255,255,255),bro)
	--material1 = dgsCreate3DInterface(0,0,4,4,2,800,500,tocolor(255,255,255,255),1,0,0,_,0)
	img = dgsCreateImage(400,200,600,600,bro,false)
	dgsMediaLoadMedia(bro,"a.webm","VIDEO") -- Give a video file PLZ! (Only .webm file)
	--dgsMediaLoadMedia(bro,"test.ogg","AUDIO") -- Give a audio file PLZ! (Only .ogg file)
	dgsMediaPlay(bro)
	--dgsMediaSetSpeed(bro,2)

end

function browserTest()
	local webBrowser = dgsCreateBrowser(200,200,400,400,false)
	requestBrowserDomains({"bilibili.com"}, false, function(accepted, newDomains)
		if (accepted == true) then
			reloadBrowserPage(webBrowser)
		end
	end)
	addEventHandler("onClientBrowserResourceBlocked", webBrowser, function(url, domain, reason)
		if (reason == 0) then
			requestBrowserDomains({domain}, false, function(accepted, newDomains)
				if (accepted == true) then
					reloadBrowserPage(webBrowser)
				end
			end)
		end
	end)
	addEventHandler("onClientBrowserCreated", webBrowser, function()
		loadBrowserURL(webBrowser, "https://bilibili.com")
	end)
end

function PasteHandlerTest()
	dgsEnablePasteHandler()
	dgsFocusPasteHandler()
	local image = false
	addEventHandler("onDgsPaste",root,function(data,typ)
		if isElement(image) then destroyElement(image) end
		if typ == "file" then
			image = dgsCreateImage(100,100,200,200,data,false)
		else
			print(data)
		end
	end)
end

function _3DInterfaceAttachTest()
	material = dgsCreate3DInterface(0,0,2,2,2,600,600,tocolor(255,255,255,255),1,0,0,_,0)
	dgs3DInterfaceAttachToElement(material,localPlayer,0,0,1)
	dgsSetProperty(material,"faceRelativeTo","world")
	dgsSetProperty(material,"maxDistance",1000)
	dgsSetProperty(material,"fadeDistance",1000)
	local window = dgsCreateWindow(0,0,600,600,"test",false)
	dgsSetParent(window,material)
end

function _3DLineTest()
	line = dgsCreate3DLine(0,0,4,0,0,45,tocolor(255,255,255,255),1,100)
	local i = 1
	dgs3DLineAddItem(line,4,0,0,math.cos(i/200*math.pi*2)*4,math.sin(i/200*math.pi*2)*4,0,4,tocolor(i/200*255,255-i/200*255,0,255),true)
	for i=2,200 do
		dgs3DLineAddItem(line,_,_,_,math.cos(i/200*math.pi*2)*4,math.sin(i/200*math.pi*2)*4,0,4,tocolor(i/200*255,255-i/200*255,0,255),true)
	end
	local veh = getPedOccupiedVehicle(localPlayer)
	dgs3DLineAttachToElement(line,veh)
end

function DetectAreaApplyingTest()
	local da = dgsCreateDetectArea()
	dgsDetectAreaSetDebugModeEnabled(da,true)
	dgsDetectAreaSetFunction(da,[[return (mxRlt-0.5)^2+(myRlt-0.5)^2 < 0.25]])
	local image1 = dgsCreateImage(200,200,100,100,_,false,_,tocolor(255,255,255,128))
	dgsApplyDetectArea(image1,da)
end

function DetectAreaAsParentTest()
	local da = dgsCreateDetectArea(100,100,100,100,false)
	dgsDetectAreaSetDebugModeEnabled(da,true)
	dgsDetectAreaSetFunction(da,[[return (mxRlt-0.5)^2+(myRlt-0.5)^2 < 0.25]])
	local image1 = dgsCreateImage(0,0,100,100,_,false,da,tocolor(255,255,255,128))
end

function _3DTextTest()
	local text = dgsCreate3DText(0,0,4,"DGS 3D Text Test",white)
	dgsSetProperty(text,"fadeDistance",20)
	dgsSetProperty(text,"shadow",{1,1,tocolor(0,0,0,255),2})
	dgsSetProperty(text,"outline",{"out",1,tocolor(255,255,255,255)})
	dgs3DTextAttachToElement(text,localPlayer,0,5)
	local label = dgsCreateLabel(0,0,0,0,"",false)
	dgsAttachToAutoDestroy(text,label)
	--destroyElement(label)
end

function _3DImageTest()
	local image1 = dgsCreate3DImage(0,0,10,_,tocolor(255,0,0,255),2,400)
	local image = dgsCreate3DImage(0,0,20,_,tocolor(0,128,255,128),10,10)
	dgsSetProperty(image,"fadeDistance",20000)
	dgsSetProperty(image,"maxDistance",20000)
	dgsSetProperty(image,"outline",{"out",1,tocolor(255,255,255,255)})
	--dgs3DImageAttachToElement(image,localPlayer,0,5)
	dgsBringToFront(image1)
end

function ScrollBarTest()
	scrollbar = dgsCreateScrollBar(400,500,20,180,false,false)
	--dgsSetProperty(scrollbar,"troughWidth",{0.2,true})
	--dgsSetProperty(scrollbar,"scrollArrow",false)
	scrollbar = dgsCreateScrollBar(500,530,180,20,true,false)
end

function ScalePaneTest()
	local sp = dgsCreateScalePane(0,0,500,800,false,_,2000,1000)
	dgsSetProperty(sp,"bgColor",tocolor(128,128,128,128))
	gridlist = dgsCreateGridList(20,20,600,600,false,sp)
	dgsSetProperty(gridlist,"clip",false)
	dgsGridListAddColumn(gridlist,"test1",0.4)
	dgsGridListAddColumn(gridlist,"test2",0.8)
	local tick = getTickCount()
	bg = dgsCreateRoundRect(10, false, tocolor(31, 31, 31, 255))
	dgsSetProperty(gridlist,"rowHeight",200)
	for i=1,10 do
		local row = dgsGridListAddRow(gridlist)
		local window = dgsCreateMemo(0,1,400,198,"",false)
		dgsAttachToGridList(window,gridlist,row,2)
		dgsGridListSetItemText(gridlist,row,1,i)
		dgsGridListSetItemText(gridlist,row,2,tostring(50-i).." Test DGS")
	end
end

function LayoutTest()
	layout = dgsCreateLayout(400,400,200,200,"horizontal",false)
	local image = {}
	for i=1,20 do
		image[i] = dgsCreateImage(0,0,20,20,_,false,layout,tocolor(math.random(0,255),math.random(0,255),math.random(0,255),255))
	end
	--dgsLayoutAddItem(layout,image)
	
	layout = dgsCreateLayout(400,500,200,200,"horizontal",false)
	local image = {}
	for i=1,20 do
		image[i] = dgsCreateImage(0,0,math.random(15,20),20,_,false,layout,tocolor(math.random(0,255),math.random(0,255),math.random(0,255),255))
	end
end

function SelectorTest()
	local window = dgsCreateWindow(300,300,400,400,"test",false)
	selector = dgsCreateSelector(10,10,100,20,false,window)
	dgsSetProperty(selector,"selectorImageColorLeft",{0x99FF0000,0x99FF0000,0x99FF0000})
	dgsSetProperty(selector,"selectorImageColorRight",{0x9900FF00,0x9900FF00,0x9900FF00})
	dgsSetProperty(selector,"selectorText",{"-","+"})
	--dgsSetProperty(selector,"isHorizontal",false)
	dgsSetProperty(selector,"isReversed",false)
	for i=1,5000 do
		dgsSelectorAddItem(selector,i)
	end
	dgsSelectorSetItemData(selector,dgsSelectorGetSelectedItem(selector),123)
end

function TabPanelTest()
	tabpanel = dgsCreateTabPanel(200,200,400,400,false)
	dgsSetProperty(tabpanel,"tabHeight",{20,false})
	tab = dgsCreateTab("test1",tabpanel)
	tab = dgsCreateTab("test2",tabpanel)
	tab = dgsCreateTab("test3",tabpanel)
	dgsSetProperty(tabpanel,"shadow",{1,1,tocolor(0,0,0,255)})
end

function Line2DTest()
	local line = dgsCreateLine(400,200,600,400)
	local sinX = math.sin(0/500*4*math.pi)
	dgsLineAddItem(line,0/500,sinX/2+0.5,0/500,sinX/2+0.5,2,tocolor(0,255,0,255),true)
	for i=1,100 do
		local sinX = math.sin(i/100*4*math.pi)
		dgsLineAddItem(line,_,_,i/100,sinX/2+0.5,2,tocolor(i/100*255,255-i/100*255,0,255),true)
	end
end
---------------Property Listener Test
function propertyListenerTest()
	local win = dgsCreateWindow(200,200,400,400,"Property Listener Test",false)
	dgsAddPropertyListener(win,"absPos")
	addEventHandler("onDgsPropertyChange",win,function(key,newValue,oldValue)
		print(key,newValue,oldValue)
	end,false)
end

---------------Drag And Drop Test
--Static Example
function dragNdropStatic()
	local btn1 = dgsCreateButton(200,200,200,200,"Button1",false)
	local btn2 = dgsCreateButton(200,500,200,200,"Button2",false)
	local btn3 = dgsCreateButton(500,500,200,200,"Receive",false)
	
	dgsAddDragHandler(btn1,{"From Button 1"})
	dgsAddDragHandler(btn2,{"From Button 2"})

	addEventHandler("onDgsDrop",btn3,function(data)
		iprint("Drop","Data:",data)
	end,false)
end
--Dynamic Example
function dragNdropDynamic()
	local btn1 = dgsCreateButton(200,200,200,200,"Button1",false)
	local btn2 = dgsCreateButton(200,500,200,200,"Button2",false)
	local btn3 = dgsCreateButton(500,500,200,200,"Receive",false)
	addEventHandler("onDgsDrag",btn1,function(data)
		dgsSendDragNDropData({"From Button 1",getTickCount()})
	end,false)
	addEventHandler("onDgsDrag",btn2,function(data)
		dgsSendDragNDropData({"From Button 2",getTickCount()})
	end,false)

	addEventHandler("onDgsDrop",btn3,function(data)
		iprint("Drop","Data:",data)
	end,false)
end

---------------Language Test
function LanguageChangeInComboBoxTest()
	languageTab = {
		wtf="DGS %rep%",
		fontX = "default",
	}
	languageTab2 = {
		wtf="Test %rep% %rep%",
		fontX = "default",
	}
	dgsSetTranslationTable("test",languageTab)
	dgsSetAttachTranslation("test")
	combobox = dgsCreateComboBox(500,400,200,30,{"wtf","1"},false)
	dgsSetFont(combobox,{"fontX"})
	for i=1,20 do
		dgsComboBoxAddItem(combobox,{"wtf",i})
	end
	dgsSetProperty(combobox,"scrollBarThick",15)
	setTimer(function()
		dgsSetTranslationTable("test",languageTab2)
	end,1000,1)
end

function LanguageChangeInGridListTest()
	languageTab = {wtf="DGS %rep%",test="Test Lang1"}
	languageTab2 = {wtf="Test %rep% %rep%",test="Test Lang2"}
	dgsSetTranslationTable("test",languageTab)
	dgsSetAttachTranslation("test")
	gridlist = dgsCreateGridList (0.51, 0.54, 0.16, 0.14, true )
	dgsGridListAddColumn(gridlist,{"test"},0.5)
	dgsGridListAddColumn(gridlist,{"test"},0.5)
	for i=1,5000 do
		local row = dgsGridListAddRow(gridlist)
		dgsGridListSetItemText(gridlist,row,1,{"wtf",i,i})
		dgsGridListSetItemText(gridlist,row,2,tostring(50-i).." Test DGS")
	end
	setTimer(function()
		dgsSetTranslationTable("test",languageTab2)
	end,1000,1)
end

function LanguageInLabelTest()
	languageTab = {wot="D-G-S %rep%"}
	dgsSetTranslationTable("test",languageTab)
	dgsSetAttachTranslation("test")
	label = dgsCreateLabel (0.51, 0.54, 0.16, 0.14, {"wtf"}, true )
	dgsSetText(label,{"wot","1"})
end

function LanguageChangeInTabPanelTest()
	languageTab = {wtf="DGS %rep%",test="Test Lang1"}
	languageTab2 = {wtf="Test %rep% %rep%",test="Test Lang2"}
	dgsSetTranslationTable("test",languageTab)
	dgsSetAttachTranslation("test")
	tabp = dgsCreateTabPanel(400,200,400,400,false)
	tab1 = dgsCreateTab({"wtf"},tabp)
	tab2 = dgsCreateTab("Tab",tabp)
	for i=1,10 do
		dgsCreateTab(i.."Panel",tabp)
	end
	gdlt2 = dgsCreateButton(10,0,100,120,"test",false,tab1,tocolor(255,255,255,255))
	dgsSetProperty(gdlt2,"shadow",{1,1,tocolor(0,0,0,255),true})
	setTimer(function()
		dgsSetTranslationTable("test",languageTab2)
	end,1000,1)
end

---------------Plugin Test
function dgsRoundRectTest()
	local rndRect = dgsCreateRoundRect(0.5,true,tocolor(0,0,0,150),_,false,true)
	local button = dgsCreateButton(200,200,800,400,"text",false)
	dgsSetProperty(button,"image",{rndRect,rndRect,rndRect})
end

function dgsRoundRectWithWindowText()
	local titleRoundRect = dgsCreateRoundRect({{10,false},{10,false}},tocolor(0,0,0,255))
	local bgRoundRect = dgsCreateRoundRect({_,_,{10,false},{10,false}},tocolor(0,0,0,255))
	local window = dgsCreateWindow(0.2*sW,0,0.4*sW,0.4*sH,"Example window",false)
	dgsRoundRectSetColorOverwritten(titleRoundRect,false)
	dgsRoundRectSetColorOverwritten(bgRoundRect,false)
	dgsSetProperty(window,"titleImage",titleRoundRect)
	dgsSetProperty(window,"image",bgRoundRect)
end

function dgsCircleTest()
	local c = dgsCreateCircle(0.5,0.3)
	local img = dgsCreateImage(300,200,200,200,c,false)
	dgsCircleSetAngle(c,10)
	dgsCircleSetDirection(c,false)
end

function test9SliceScale()
	local img = dxCreateTexture("palette.png")
	local nSli = dgsCreateNineSlice(img,0.2,0.8,0.4,0.6,true)
	local image = dgsCreateImage(400,400,400,400,nSli,false)
end

function ScrollPane3DEffectTest()
	material = dgsCreate3DInterface(0,0,4,4,4,500,500,tocolor(255,255,255,255),1,0,0,_,0)
	dgsSetProperty(material,"maxDistance",1000)
	dgsSetProperty(material,"fadeDistance",1000)
	local img = dgsCreateImage(0,0,1,1,_,true,material,tocolor(0,0,0,180))
	edit1 = dgsCreateEdit(0,0,200,100,"DGS 3D Interface Edit 1",false,img)
	edit2 = dgsCreateEdit(0,400,200,50,"DGS 3D Interface Edit 2",false,img)

	local effect3d = dgsCreateEffect3D(20)
	local sp = dgsCreateScrollPane(300,300,500,500,false)
	local img = dgsCreateImage(0,0,1,1,_,true,sp,tocolor(0,0,0,180))
	dgsEffect3DApplyToScrollPane(effect3d,sp)
	edit1 = dgsCreateEdit(0,0,200,100,"DGS 3D Effect Edit 1",false,img)
	edit2 = dgsCreateEdit(0,400,200,50,"DGS 3D Effect Edit 2",false,img)
	
	local pb = dgsCreateProgressBar(100,100,400,400,false)
	dgsSetProperty(pb,"bgColor",tocolor(0,0,0,255))
	dgsProgressBarSetStyle(pb,"ring-plain")
end

---------------QRCode
function QRCodeTest()
	
	local blurbox = dgsCreateBlurBox(sW/2,sH)
	dgsSetProperty(blurbox,"updateScreenSource",true)
	img = dgsCreateImage(0,0,sW/2,sH,blurbox,false)
	local roundedRect = dgsCreateRoundRect(300, false, tocolor(255,255,255,255))
	dgsBlurBoxSetFilter(blurbox,roundedRect)

	local QRCode = dgsRequestQRCode("https://wiki.multitheftauto.com/wiki/Resource:Dgs")
	local image = dgsCreateImage(200,200,128,128,QRCode,false)
	local mask = dgsCreateMask(QRCode,"backgroundFilter")
	local image2 = dgsCreateImage(400,200,128,128,mask,false)
	local roundedRect = dgsCreateRoundRect(10, false, tocolor(255,255,255,255))
	local rt = dxCreateRenderTarget(128,128,true)
	dgsRoundRectSetTexture(roundedRect,rt)
	local image3 = dgsCreateImage(600,200,128,128,roundedRect,false)
	
	outputChatBox(dgsGetQRCodeLoaded(QRCode) and "Loaded" or "Loading")
	addEventHandler("onDgsQRCodeLoad",QRCode,function()
		outputChatBox(dgsGetQRCodeLoaded(source) and "Loaded" or "Loading")
		
		dxSetRenderTarget(rt,true)
		dxDrawImage(0,0,128,128,QRCode)
		dxSetRenderTarget()
	end,false)
	
end

---------------Blur Box
function BlurBoxTest()
	local blurbox = dgsCreateBlurBox(sW/2,sH)
	dgsSetProperty(blurbox,"updateScreenSource",true)
	img = dgsCreateImage(0,0,sW/2,sH,blurbox,false)
	dgsBlurBoxSetIntensity(blurbox,1)
	dgsBlurBoxSetLevel(blurbox,15)
	--local text = dgsCreate3DImage(0,0,4,blurbox,tocolor(0,128,255,128),128,128)
end

function ScreenSourceTest()
	local ss = dgsCreateScreenSource()
	img = dgsCreateImage(0,0,sW/2,sH,ss,false,_,tocolor(255,255,255,255))
end

---------------DGS Object Preview Support Test
function testObjectPreview()
	wind = dgsCreateWindow(0.2*sW,0,0.4*sW,0.4*sH,"Example Object Preview",false)
	local objPrevName = "object_preview"
	dgsLocateObjectPreviewResource(objPrevName)
	local veh = createPed(0,0,0,3)
	local objPrev = dgsCreateObjectPreviewHandle(veh,0,0,0)
	local image = dgsCreateImage(20,20,300,300,_,false,wind)
	dgsAttachObjectPreviewToImage(objPrev,image)
end

---------------DGS Animation With Shader Example
--Example 1, Simple Button Effect
function testButtonEffect()
	local bEffect = dxCreateShader([[
		float antiAliased = 0.02;
		float radius = 0;
		float2 circlePos = float2(0.5,0.5);
		float4 baseColor = float4(0.5,0.5,0.5,1);
		float4 focusColor = float4(0,0.4,0.8,1);
		float2 UVPos = float2(0,0);
		float2 UVSize = float2(1,1);
		float ratio = 2;

		float4 myShader(float2 tex:TEXCOORD0):COLOR0{
			float2 UVScaler = UVPos+float2(tex.x*UVSize.x,tex.y*UVSize.y);
			float4 color = focusColor;
			float2 texPosScaler = float2((tex.x-circlePos.x)*ratio,(tex.y-circlePos.y));
			float dis = texPosScaler.x*texPosScaler.x+texPosScaler.y*texPosScaler.y;
			color = focusColor+(baseColor-focusColor)*clamp((dis-radius+antiAliased)/antiAliased/radius,0,1);
			return color;
		}
		technique DrawCircle{
			pass P0{
				PixelShader = compile ps_2_0 myShader();
			}
		}
	]])				--Create our shader
	local button = dgsCreateButton(300,300,200,100,"Button",false)			--Create our dgs button
	dgsSetProperty(button,"image",{bEffect,bEffect,bEffect})				--Set all image of dgs button as shader
	dgsAddEasingFunction("ButtonEffect_1",[[								--Define our custom easing function that can be only used in dgs
		local shader = propertyTable.image[1]								--Get the shader
		local circleRadius = dgsGetProperty(self,"circleRadius") or 0		--Get the property value
		circleRadius = circleRadius+(setting[2]-circleRadius)*progress		--Calculate the changing
		if dgsGetType(shader) == "shader" then								--Is the shader existing?
			dxSetShaderValue(shader,"radius",circleRadius*8)				--If so, then set shader value
		end
		return circleRadius													--Return the property value
	]])

	function dgsButtonEffectHandler(mx,my)
		if dgsIsAniming(source) then dgsStopAniming(source) end				--If it is animating, then suspend it
		local wid,hei = dgsGetSize(source,false)							--Get the size of the dgs button to calculate the ratio and the mouse relative position
		local x,y = dgsGetPosition(source,false)							--Get the position of the dgs button to calculate the mouse relative position
		local ratio = wid/hei												--Calculate the ratio
		local shader = dgsGetProperty(source,"image")[1]					--Get the shader
		if not isElement(shader) then return false end						--If there is no shader, then jump out
		dxSetShaderValue(shader,"ratio",ratio)								--Set ratio
		local mouseRltX,mouseRltY = (mx-x)/wid,(my-y)/hei					--Get mouse relative position
		dxSetShaderValue(shader,"circlePos",{mouseRltX,mouseRltY})			--Push in to shader
		if eventName == "onDgsMouseEnter" then								--Animation in onDgsMouseEnter
			dgsAnimTo(source,"circleRadius",1,"ButtonEffect_1",800)				--Let's Do It!
		else																--Animation in onDgsMouseLeave
			dgsAnimTo(source,"circleRadius",0,"ButtonEffect_1",600)				--Let's Do It Reverse!
		end
	end
	addEventHandler("onDgsMouseEnter",button,dgsButtonEffectHandler,false)
	addEventHandler("onDgsMouseLeave",button,dgsButtonEffectHandler,false)
end

--[[
function clampIntoSuperEllipse(orgX,orgY,x,y,w,h,times)
	local result = (math.abs((orgX-x)/w)^times+math.abs((orgY-y)/h)^times)^(1/times)
	if result > 1 then
		orgX = (orgX-x)/result+x
		orgY = (orgY-y)/result+y
	end
	return orgX,orgY
end

e = dgsCreateImage(200,200,200,200,z,false)
dgsAddMoveHandler(e,0,0,1,1)
addEventHandler("onClientRender",root,function()
	local x,y = dgsGetPosition(e,false)
	local w,h = dgsGetSize(e,false)
	local _x,_y = clampIntoSuperEllipse(x+w/2,y+h/2,sW/2,sH/2,600,300,4)
	dgsSetPosition(e,_x-w/2,_y-h/2,false)
end)]]
---------------------StressTest
function animStress()
	for i=1,1000 do
		local image = dgsCreateImage(200,i*1,30,1,_,false)
		dgsSizeTo(image,300,1,false,"Linear",10000)
	end
end

function labelStress()
	for i=1,1000 do
		local l = dgsCreateLabel(500,500,200,200,"test",false)
		dgsSetProperty(l,"shadow",{1,1,tocolor(0,0,0,255)})
		dgsSetProperty(l,"colorCoded",true)
	end
end

function buttonStress()
	for i=1,100 do
		dgsCreateButton(500,500,200,200,"test",false)
	end
end


function editStress()
	for i=1,100 do
		edit = dgsCreateEdit(0.3,0.3,0.2,0.05,"aaaaaaaaaaaaaaaaaaaaaaaaaaaaas",true)
	end
end

function windowStress()
	local tick = getTickCount()
	for i=1,100 do
		local win = dgsCreateWindow(0, 0, 800, 600, 'Dx Gui Demo')
		--destroyElement(win)
	end
	print(getTickCount()-tick)
end

function gridlistStress()
	local tick = getTickCount()
	for i=1,200 do
		local win = dgsCreateGridList(0, 0, 800, 600)
		dgsGridListAddColumn(win,"test",0.8)
		for k=1,50 do
			dgsGridListAddRow(win,_,k)
		end
		--destroyElement(win)
	end
	print(getTickCount()-tick)
end

function dgsSetPropertyTest()
	local img = dgsCreateImage(0, 0, 800, 600, _,false)
	local tick = getTickCount()
	for i=1,100000 do
		dgsSetProperty(img,"color",0xFFFFFFFF)
	end
	print(getTickCount()-tick)
	destroyElement(img)
end

function dgsScrollPaneTest()
	local ele = dgsCreateScrollPane(760, 140, 400, 600, false, nil)
	local tex = dgsCreateRoundRect(10, false, tocolor(31, 31, 31, 255))
	local y = 0
	
	for i = 1, 500 do
		y = ((i - 1) * 45)
		local button = dgsCreateButton(0, y, 380, 40, "", false, ele)
	end

	--[[for i = 1, 1000 do
		y = ((i - 1) * 45)
		dgsCreateButton(405, y, 380, 40, "", false, ele)
	end]]
	dgsScrollPaneSetScrollPosition(ele,50,0)
end

function SVGTest()
	local svg = dgsCreateSVG(500,500)
	local svgDoc = dgsSVGGetDocument(svg)
	local rect = dgsSVGCreateNode(svgDoc,"rect",50,50,50,50)
	dgsSVGNodeSetAttributes(rect,{
		["stroke"] = {255,255,0},
		["stroke-width"] = "5px",
		["fill"] = "rgb(255,0,0)",
	})

	local circle = dgsSVGCreateNode(svgDoc,"circle",10,10,20)
	dgsSVGNodeSetAttributes(rect,{
		["stroke"] = {255,255,0},
		["stroke-width"] = "5px",
		["fill"] = "rgb(255,0,0)",
	})

	local polyline = dgsSVGCreateNode(svgDoc,"polyline",{100,100,200,200,100,200})
	dgsSVGNodeSetAttributes(polyline,{
		["stroke"] = {255,255,0},
		["stroke-width"] = "5px",
		["fill"] = "rgb(255,0,0)",
	})

	local path = dgsSVGCreateNode(svgDoc,"path",{
		{"M",153,334},
		{"C",153, 334, 151, 334, 151, 334},
		{"C",151, 339, 153, 344, 156, 344},
		{"C",164, 344, 171, 339, 171, 334},
		{"C",171, 322, 164, 314, 156, 314},
		{"C",142, 314, 131, 322, 131, 334},
		{"C",131, 350, 142, 364, 156, 364},
		{"C",175, 364, 191, 350, 191, 334},
	})

	dgsSVGNodeSetAttributes(path,{
		["stroke"] = {255,255,0},
		["stroke-width"] = "5px",
		["fill"] = "rgb(255,0,0)",
	})
	local d = dgsSVGNodeSetAttribute(path,"d","table")
	dgsSVGNodeSetAttribute(path,"d",d)
	local btn1 = dgsCreateImage(200,200,500,500,svg,false)
	
	setClipboard(dgsSVGGetRawDocument(svg))
end


function SVGTest_OOP()
	local DGSOOPFnc,err = loadstring(dgsImportOOPClass())
	print(err)
	DGSOOPFnc()

	svg = dgsSVG(500,500)
	doc = svg:getDocument()
	path = doc:path({
		{"M",153, 334},
		{"C",153, 334, 151, 334, 151, 334},
		{"C",151, 339, 153, 344, 156, 344},
		{"C",164, 344, 171, 339, 171, 334},
		{"C",171, 322, 164, 314, 156, 314},
		{"C",142, 314, 131, 322, 131, 334},
		{"C",131, 350, 142, 364, 156, 364},
		{"C",175, 364, 191, 350, 191, 334},
		})
		:fill("#FFFF00")
		:stroke({width=5,color=0xFF0000})
	rect = doc:rect(40,40,200,200)
		:radius(20,20)
		:fill("#ff0")
		:stroke({width=5,color="rgb(128,128,0)"})

	--[[doc:text("123",100,100)
		:fill("#00FF00")
		:stroke({width=5,color=0xFF0000})]]

	--setClipboard(dgsSVGGetRawDocument(doc.dgsElement))
	img = dgsImage(200,200,500,500,svg,false)
end

function ChartTest()
	material = dgsCreate3DInterface(0,0,4,4,2,600,300,tocolor(255,255,255,255),1,0,0,_,0)
	local chart = dgsCreateChart(0,0,600,300,"line",false,material)
	dgsChartSetLabels(chart,"Month",{"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"})
	dgsSetProperty(chart,"axisYScaler",{0,100})
	dgsSetProperty(chart,"gridLineWidth",2)
	dgsSetProperty(chart,"axisLineWidth",4)
	dgsSetProperty(chart,"axisTextOffsetFromGrid",10)
	dgsSetProperty(chart,"chartPadding",{40,40,40,40,false}) --Top Botton Left Right
	local datasetID = dgsChartAddDataset(chart,"Counts")
	dgsChartDatasetSetStyle(chart,datasetID,{
			color = tocolor(255,0,0,255),
			width = 2,
		}
	)
	local setdata = {}
	for i=1,12 do
		setdata[i] = math.random()
	end
	dgsChartDatasetSetData(chart,datasetID,setdata)

	local datasetID = dgsChartAddDataset(chart,"Counts")
	dgsChartDatasetSetStyle(chart,datasetID,{
			color = tocolor(255,255,0,255),
			width = 2,
		}
	)
	local setdata = {}
	for i=1,12 do
		setdata[i] = math.random(1,10)
	end
	dgsChartDatasetSetData(chart,datasetID,setdata)
end

function multilingualTest()
	local Dict = {
		TestText={
			"health == 'Superman'",				"You are a superman",
			"find({0}, health)",				"Your health is 0",
			"health <= 20",						"Your health is low",
			"health <= 40",						"Your health is medium",
			"health > 40",						"Your health is high",
			"Your health is $health",
		},
		wtf = "Superman",
	}
	dgsSetTranslationTable("Main",Dict)
	dgsSetAttachTranslation("Main")
	label = dgsCreateLabel (0.51, 0.54, 0.16, 0.14, {"TestText"}, true )
	dgsTranslationAddPropertyListener(label,"health")
	dgsSetProperty(label,"health",{"wtf"})
end

end
addEventHandler("onClientResourceStart",resourceRoot,executeTest)
executeTest = nil