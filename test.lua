
local loadstring = loadstring
addEventHandler("onClientResourceStart",resourceRoot,function()
------------Full demo
function createFullDemo()
	local DGSOOPFnc,err = loadstring(dgsImportOOPClass())
	DGSOOPFnc()
	local window = dgsWindow(0,0,600,600,"DGS Full Demo",false)
	window.position.relative = false
	window.position.x = 400
	--Color Picker
	local cp = window:
		dgsColorPicker("HSVRing",300,0,200,200)
	local rSel = window
		:dgsComponentSelector(515,10,10,90,false)
		:bindToColorPicker(cp,"RGB","R",true,true)
	local gSel = window
		:dgsComponentSelector(545,10,10,90,false)
		:bindToColorPicker(cp,"RGB","G",true,true)
	local bSel = window
		:dgsComponentSelector(575,10,10,90,false)
		:bindToColorPicker(cp,"RGB","B",true,true)

	local hSel = window
		:dgsComponentSelector(515,110,10,90,false)
		:bindToColorPicker(cp,"HSV","H",true,true)
	local sSel = window
		:dgsComponentSelector(545,110,10,90,false)
		:bindToColorPicker(cp,"HSV","S",true,true)
	local vSel = window
		:dgsComponentSelector(575,110,10,90,false)
		:bindToColorPicker(cp,"HSV","V",true,true)

	local button = window:dgsButton(10,210,80,50,"Test Button",false)
	button.textColor = {tocolor(255,0,0,255),tocolor(255,255,0,255),tocolor(255,0,255,255)}
	local switchButton1 = window:dgsSwitchButton(100,210,60,20,"On","Off",false)
	local switchButton2 = window:dgsSwitchButton(100,240,60,20,"On","Off",true)
	switchButton2.style = nil
	switchButton2.isReverse = nil
	local gridlist = window
		:dgsGridList(0,0,290,200,false)
		:setMultiSelectionEnabled(true)
		:setProperty("rowTextSize",{1.2,1.2})
		:setProperty("rowHeight",20)
		:setProperty("clip",false)
		:setSelectionMode(3)
		:setProperty("rowTextColor",{tocolor(255,255,255,255),tocolor(0,255,255,255),tocolor(255,0,255,255)})
		:setProperty("defaultSortFunctions",{"longerUpper","longerLower"})
	for i=1,10 do
		gridlist:addColumn("Column "..i,0.5)
	end
	for i=1,100 do
		gridlist:addRow(i,i,string.rep("x",math.random(1,40)))
		--[[if i%5 == 0 then
			gridlist:setRowAsSection(i,true)
		end]]
	end
	gridlist.alpha = 1
	dgsGridListSetItemColor(gridlist.dgsElement,-1,2,{tocolor(255,0,0,255),tocolor(0,255,0,255),tocolor(255,255,0,255)})
	dgsGridListScrollTo(gridlist.dgsElement,50,1)
	dgsGridListSetItemAlignment(gridlist.dgsElement,1,1,"center")
	dgsGridListSetColumnAlignment(gridlist.dgsElement,1,"left")

	local selector = window:dgsSelector(180,210,100,20,false)
	for i=1,100 do
		selector:addItem(i)
	end

	local combobox = window:dgsComboBox(10,270,150,30,"test",false)
	combobox:setEditEnabled(true)
	for i=1,100 do
		combobox:addItem(i)
	end
	local tabPanel = window
		:dgsTabPanel(290,210,280,220,false)
	local tab1 = tabPanel:dgsTab("Tab1")
	local memo = tab1
		:dgsMemo(10,10,260,100,"This is a memo for demo",false)
	local edit1 = tab1
		:dgsEdit(10,120,260,30,"",false)
		:setPlaceHolder("I am the place holder, and this edit is for demo")
	local edit2 = tab1
		:dgsEdit(10,160,260,30,"This is a edit for demo",false)
	local tab2 = tabPanel:dgsTab("Tab2")
	local scp = tab2:dgsScrollPane(0,0,1,1,true)
	local memo2 = scp
		:dgsMemo(10,10,260,1000,"This is a memo for demo",false)
	local edit3 = scp
		:dgsEdit(10,120,2600,30,"",false)
		:setPlaceHolder("I am the place holder, and this edit is for demo")

	-------------Progress Bar
	local progressBar_V = window
		:dgsProgressBar(10,440,20,125,false)
		:setStyle("normal-vertical")
		:setProperty("functions",[[
			local progress = dgsGetProperty(self,"progress")
			dgsSetProperty(self,"progress",(progress+0.5)%100)
			return true
		]])
	local progressBar_H = window
		:dgsProgressBar(35,545,125,20,false)
		:setStyle("normal-horizontal")
		:setProperty("functions",[[
			local progress = dgsGetProperty(self,"progress")
			dgsSetProperty(self,"progress",(progress+0.5)%100)
			return true
		]])

	local progressBar_R = window
		:dgsProgressBar(45,440,100,100,false)
		:setStyle("ring-round")
		:setProperty("functions",[[
			local progress = dgsGetProperty(self,"progress")
			dgsSetProperty(self,"progress",(progress+0.5)%100)
			return true
		]])
		:setStyleProperty("radius",0.4)
		:setStyleProperty("thickness",0.05)
	---------------------
	local RadioButton1 = window:dgsRadioButton(10,380,180,30,"This is a radio button for demo",false)
	local RadioButton2 = window:dgsRadioButton(10,410,180,30,"This is a radio button for demo",false)
	local CheckBox1 = window:dgsCheckBox(10,320,180,30,"This is a check box for demo",true,false)
	local CheckBox2 = window:dgsCheckBox(10,350,180,30,"This is a check box for demo",false,false)
		:on("dgsMouseClick",function(button,state,x,y,isCoolDown)
			print(getTickCount(),isCoolDown)
		end)
		:setProperty("clickCoolDown",1000)
end

function ProgressBarTest()
	local pb= dgsCreateProgressBar(500,200,600,600,false)
	dgsSetProperty(pb,"bgColor",tocolor(0,0,0,255))
	dgsProgressBarSetStyle(pb,"ring-round",{rotation=90})
	local start = 0
	addEventHandler("onClientRender",root,function()
		dgsProgressBarSetProgress(pb,start)
		start = start + 0.1
	end)
end

function MemoTest()
	local sW,sH = dgsGetScreenSize()
	local memo = dgsCreateMemo(10,10,200,300,[[This is a dgs-dxmemo

	Thisdp's DirectX Graphical User Interface System

	Test UTF8: 你好]],false)
	dgsSetFont(memo,"default-bold")
	--dgsSetProperty(memo,"selectVisible",false)
	--dgsSetProperty(memo,"padding",{20,10})
	dgsMemoSetWordWrapState(memo,false)
end

function EditTest() --Test Tab Switch for edit.
	edit = dgsCreateEdit(0.3,0.3,0.2,0.05,"aaaaaaaaaaaaaaaaaaaaaaaaaaaaas",true)
	setTimer(function()
		dgsEditSetMaxLength(edit,10,true)
	end,1000,1)
	edit2 = dgsCreateEdit(0.3,0.4,0.2,0.05,"123123",true)
	edit3 = dgsCreateEdit(0.3,0.5,0.2,0.05,"123123",true)
	edit4 = dgsCreateEdit(0.3,0.6,0.2,0.05,"123123",true)
	dgsEditSetReadOnly(edit4,true)
	dgsBringToFront(edit,"left")
	dgsEditSetCaretPosition(edit, 1)
	dgsSetProperty(edit2,"placeHolder","Type something if you want to tell me")
	dgsSetProperty(edit2,"placeHolderIgnoreRenderTarget",true)
	dgsEditAddAutoComplete(edit3,"mypass",false)
	dgsSetProperty(edit,"bgColor",tocolor(255,255,255,0))
	dgsSetProperty(edit,"bgColorBlur",tocolor(255,255,255,100))
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
			dgsGridListSetItemText(gridlist,row,1,tostring(i).." Test DGS")
		end
		dgsGridListSetSortEnabled(gridlist,false)
		dgsGridListSetSortFunction(gridlist,sortfnc)
		dgsGridListSetSortColumn(gridlist,2)
	end
end

function GridListTest()
    gridlist = dgsCreateGridList(500,50,600,600,false)
    dgsSetProperty(gridlist,"clip",false)
    --dgsSetProperty(gridlist,"leading",10)
    --dgsSetProperty(gridlist,"mode",true)
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

function MediaBrowserTest()
	bro = dgsCreateMediaBrowser(600,600)
	rndRect1 = dgsCreateRoundRect(1,tocolor(255,255,255,255),bro)
	material1 = dgsCreate3DInterface(0,0,4,4,2,800,500,tocolor(255,255,255,255),1,0,0,_,0)
	img = dgsCreateImage(0,0,800,500,rndRect1,false,material1)
	dgsMediaLoadMedia(bro,"a.webm","VIDEO") -- Give a video file PLZ! (Only .webm file)
	--dgsMediaLoadMedia(bro,"test.ogg","AUDIO") -- Give a audio file PLZ! (Only .ogg file)
	dgsMediaPlay(bro)
	dgsMediaSetSpeed(bro,0.5)
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

function _3DInterfaceTest()
	material = dgsCreate3DInterface(4,0,5,4,4,600,600,tocolor(128,128,128,128),1,2,0,_,0)
	dgsSetProperty(material,"faceTo",{-10,-10,0})
	edit1 = dgsCreateMemo(0,0,1,1,"123",true,material)
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
	line = dgsCreate3DLine(0,0,4,0,0,45,tocolor(255,255,255,255),2,100)
	local i = 1
	dgs3DLineAddLine(line,4,0,0,math.cos(i/200*math.pi*2)*4,math.sin(i/200*math.pi*2)*4,0,4,tocolor(i/200*255,255-i/200*255,0,255),true)
	for i=2,200 do
		dgs3DLineAddLine(line,_,_,_,math.cos(i/200*math.pi*2)*4,math.sin(i/200*math.pi*2)*4,0,4,tocolor(i/200*255,255-i/200*255,0,255),true)
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
	dgsSetProperty(text,"shadow",{1,1,tocolor(0,0,0,255),true})
	dgsSetProperty(text,"outline",{"out",1,tocolor(255,255,255,255)})
	dgs3DTextAttachToElement(text,localPlayer,0,5)
end

function _3DImageTest()
	local text = dgsCreate3DImage(0,0,4,_,tocolor(0,128,255,128),10,10)
	dgsSetProperty(text,"fadeDistance",20)
	dgsSetProperty(text,"outline",{"out",1,tocolor(255,255,255,255)})
	dgs3DImageAttachToElement(text,localPlayer,0,5)
end

function ScrollBarTest()
	scrollbar = dgsCreateScrollBar(400,500,20,180,false,false)
	dgsSetProperty(scrollbar,"troughWidth",{0.2,true})
	dgsSetProperty(scrollbar,"scrollArrow",false)
	scrollbar = dgsCreateScrollBar(500,530,180,20,true,false)
end

function SelectorTest()
	selector = dgsCreateSelector(400,500,100,20,false)
	dgsSetProperty(selector,"selectorImageColorLeft",{0x99FF0000,0x99FF0000,0x99FF0000})
	dgsSetProperty(selector,"selectorImageColorRight",{0x9900FF00,0x9900FF00,0x9900FF00})
	dgsSetProperty(selector,"selectorText",{"-","+"})
	for i=1,5000 do
		dgsSelectorAddItem(selector,i)
	end
end

function TabPanelTest()
	tabpanel = dgsCreateTabPanel(200,200,400,400,false)
	dgsSetProperty(tabpanel,"tabHeight",{20,false})
	tab = dgsCreateTab("test1",tabpanel)
	tab = dgsCreateTab("test2",tabpanel)
	tab = dgsCreateTab("test3",tabpanel)
end

---------------Language Test
function LanguageChangeInComboBoxTest()
	languageTab = {wtf="DGS %rep%"}
	languageTab2 = {wtf="Test %rep% %rep%"}
	dgsSetTranslationTable("test",languageTab)
	dgsSetAttachTranslation("test")
	combobox = dgsCreateComboBox(500,400,200,30,{"wtf","1"},false)
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
	local c = dgsCreateCircle()
	local img = dgsCreateImage(300,300,400,400,c,false)
	dgsCircleSetAngle(c,120)
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
end

---------------QRCode
function QRCodeTest()
	local QRCode = dgsRequestQRCode("https://wiki.multitheftauto.com/wiki/Resource:Dgs")
	local image = dgsCreateImage(200,200,128,128,QRCode,false)
	local mask = dgsCreateMask(QRCode,"backgroundFilter")
	local image2 = dgsCreateImage(400,200,128,128,mask,false)
	outputChatBox(dgsGetQRCodeLoaded(QRCode) and "Loaded" or "Loading")
	addEventHandler("onDgsQRCodeLoad",QRCode,function()
		outputChatBox(dgsGetQRCodeLoaded(source) and "Loaded" or "Loading")
	end,false)
end

---------------Blur Box
function BlurBoxTest()
	local blurbox = dgsCreateBlurBox(sW/2,sH,QRCode)
	img = dgsCreateImage(0,0,sW/2,sH,blurbox,false)
	dgsBlurBoxSetIntensity(blurbox,1)
	dgsBlurBoxSetLevel(blurbox,15)
	--local text = dgsCreate3DImage(0,0,4,blurbox,tocolor(0,128,255,128),128,128)
end
---------------Color Picker
function testColorPicker()
	colorPicker_HLDisk = dgsCreateColorPicker("HLDisk",50,50,200,200,false)
	colorPicker_HSDisk = dgsCreateColorPicker("HSDisk",250,50,200,200,false)
	colorPicker_HSLSquare = dgsCreateColorPicker("HSLSquare",50,250,200,200,false)
	colorPicker_HSVRing = dgsCreateColorPicker("HSVRing",250,250,200,200,false)
	r = dgsColorPickerCreateComponentSelector(500,200,200,10,true,false)
	dgsBindToColorPicker(r,colorPicker_HSVRing,"RGB","R",true,true)
	g = dgsColorPickerCreateComponentSelector(500,220,200,10,true,false)
	dgsBindToColorPicker(g,colorPicker_HSVRing,"RGB","G",true,true)
	b = dgsColorPickerCreateComponentSelector(500,240,200,10,true,false)
	dgsBindToColorPicker(b,colorPicker_HSVRing,"RGB","B",true,true)

	H = dgsColorPickerCreateComponentSelector(750,200,200,10,true,false)
	dgsBindToColorPicker(H,colorPicker_HSVRing,"HSL","H",true,true)
	S = dgsColorPickerCreateComponentSelector(750,220,200,10,true,false)
	dgsBindToColorPicker(S,colorPicker_HSVRing,"HSL","S",true,true)
	L = dgsColorPickerCreateComponentSelector(750,240,200,10,true,false)
	dgsBindToColorPicker(L,colorPicker_HSVRing,"HSL","L",true,true)

	H = dgsColorPickerCreateComponentSelector(1000,200,200,10,true,false)
	dgsBindToColorPicker(H,colorPicker_HSVRing,"HSV","H",true,true)
	S = dgsColorPickerCreateComponentSelector(1000,220,200,10,true,false)
	dgsBindToColorPicker(S,colorPicker_HSVRing,"HSV","S",true,true)
	V = dgsColorPickerCreateComponentSelector(1000,240,200,10,true,false)
	dgsBindToColorPicker(V,colorPicker_HSVRing,"HSV","V",true,true)

	A = dgsColorPickerCreateComponentSelector(500,260,10,500,false,false)
	dgsBindToColorPicker(A,colorPicker_HSVRing,"RGB","A",_,true)
end

---------------DGS Object Preview Support Test
function testObjectPreview()
	wind = dgsCreateWindow(0.2*sW,0,0.4*sW,0.4*sH,"Example Scroll Pane (exclude this window)",false)
	local objPrevName = "object_preview"
	dgsLocateObjectPreviewResource(objPrevName)
	local veh = createVehicle(411,0,0,3)
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
---------------------StressTest

function buttonStress()
	for i=1,5000 do
		dgsCreateButton(500,500,200,200,"test",false)
	end
end


function windowStress()
	local tick = getTickCount()
	for i=1,1000 do
		local win = dgsCreateWindow(0, 0, 800, 600, 'Dx Gui Demo')
		destroyElement(win)
	end
	print(getTickCount()-tick)
end

--[[
local sp = dgsCreateScrollPane(300,300,500,500,false)

local tick = getTickCount()
local img = {}
for i=1,40 do
	for j=1,40 do
		img[#img+1] = dgsCreateImage((i-1)*22,(j-1)*22,20,20,_,false,sp)
	end
end
print(getTickCount()-tick)]]

end)