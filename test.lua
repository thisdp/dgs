function createTest()
addEasingFunction("Pre_line",[[
	return math.abs(value^2-0.5)*2
]])

wind = dgsCreateWindow(math.floor(0.2*sW),math.floor(0.3*sH),math.floor(0.4*sW),math.floor(0.4*sH),"Example Scroll Pane (exclude this window)",false)
--pane = dgsCreateScrollPane(0,0,1,1,true,wind)
gdlt = dgsCreateImage(0,0,0.7,0.7,_,true,wind,tocolor(255,255,255,255))
gdlt2 = dgsCreateImage(0,0,0.7,0.7,_,true,gdlt,tocolor(0,255,255,255))
dgsSizeTo(wind,0.5*sW,0.5*sH,false,false,"line",1000)
end

function createTest2()
	tabp = dgsCreateTabPanel(400,200,400,400,false)
	tab1 = dgsCreateTab("DGS",tabp)
	tab2 = dgsCreateTab("Tab",tabp)
	for i=1,10 do
		dgsCreateTab(i.."Panel",tabp)
	end
	gdlt2 = dgsCreateButton(10,0,100,120,"test",false,tab1,tocolor(255,255,255,255))
end

function createTest3()
	local rb1= dgsCreateRadioButton(500,500,200,30,"aaaa",false)
	local rb2 = dgsCreateRadioButton(500,520,200,30,"bbbb",false)
end

function createTest4()
	rb1 = dgsCreateComboBox(500,400,200,30,false)
	for i=1,20 do
		dgsComboBoxAddItem(rb1,i)
	end
end

function createTest5()
	local cb1= dgsCreateCheckBox(500,500,200,30,"test_indeterminate",false)
	local cb2 = dgsCreateCheckBox(500,520,200,30,"test_checked",false)
	local cb2 = dgsCreateCheckBox(500,540,200,30,"test_unchecked",false)
	dgsCheckBoxSetSelected(cb1,nil)
end

function testButtonDisable()
	local button = dgsCreateButton(500,500,200,80,"test",false)
	dgsSetEnabled(button,false)
end

function testButtonPerformance()
	for i=1,1000 do
		local button = dgsCreateButton(500,500,200,80,"test",false)
	end
end

function createTestMemo()
	local memo = dgsCreateMemo(500,200,200,300,[[This is a dgs-dxmemo
	
	Thisdp's
	DirectX
	Graphical User Interface
	System
	
	MTA DxLib
	Version 2.88
	Test UTF8: 你好
	Test Selection
	
	DGS Memo Updates
	1.Added Scroll Bars
	2.Fix backspace and delete doesn't works well
	
	Very looooooooooong
	Test Scroll Bars
	1
	2
	3
	4
	5
	6
	7
	8
	9
	10]],false)
	--dgsMemoSetReadOnly(memo,true)
end

function editTest() --Test Tab Switch for edit.
	edit = dgsCreateEdit(0.3,0.3,0.2,0.05,"aaaaaaaaaaaaaaaaaaaaaaaaaaaaas",true)
	setTimer(function()
		dgsEditSetMaxLength(edit,10,true)
	end,1000,1)
	edit2 = dgsCreateEdit(0.3,0.4,0.2,0.05,"123123",true)
	edit3 = dgsCreateEdit(0.3,0.5,0.2,0.05,"123123",true)
	edit4 = dgsCreateEdit(0.3,0.6,0.2,0.05,"123123",true)
	dgsEditSetReadOnly(edit4,true)
	dgsBringToFront(edit,"left")
	dgsEditSetCaretPosition (edit, 1)
end

function editTest4()
	window = dgsCreateWindow(200,200,800,600,"",false)
	tabp = dgsCreateTabPanel(400,200,400,400,false,window)
	tab1 = dgsCreateTab("DGS",tabp)
	edit = dgsCreateEdit(0.1,0.3,0.8,0.5,"123123",true,tab1)
	setTimer(function()
		dgsSetVisible(window,false)
	end,1000,1)
	setTimer(function()
		dgsSetVisible(window,true)
	end,2000,1)
end

function edatest()
	local eda = dgsCreateEDA(400,400,300,100,false)
	dgsEDASetDebugMode(eda,true)
end
function gridlistTest()
	gridlist = dgsCreateGridList(300,50,600,600,false)
	dgsSetProperty(gridlist,"mode",true)
	dgsGridListAddColumn(gridlist,"test1",0.3)
	dgsGridListAddColumn(gridlist,"test2",0.1)
	dgsGridListAddColumn(gridlist,"test3",0.3)
	dgsGridListAddColumn(gridlist,"test4",0.2)
	dgsGridListAddColumn(gridlist,"test5",0.5)
	dgsGridListAddColumn(gridlist,"test6",0.1)
	dgsGridListAddColumn(gridlist,"test7",0.4)
	for i=1,50 do
		local row = dgsGridListAddRow(gridlist)
		dgsGridListSetItemText(gridlist,row,1,tostring(i).."aaaaa")
	end
	dgsGridListSetSelectionMode(gridlist,3)
	dgsGridListSetMultiSelectionEnabled(gridlist,true)
	dgsGridListSetSelectedItems(gridlist,{{true,true,true}})
	setTimer(function()
	local items = dgsGridListGetSelectedItems(gridlist)
		iprint(items)
	end,1000,0)
end

function centerEdit()
	edit = dgsCreateEdit(300,300,300,100,"Test",false)
	--dgsSetProperty(edit,"center",true)
end
--centerEdit()

function mediaTest()
	local media = dgsCreateMedia(600,600)
	--local image = dgsCreateImage(200,100,400,400,media,false)
	dgsMediaLoadMedia(media,"liquicity.mp4","VIDEO")
end

function gridlistImageTest()
	gridlist = dgsCreateGridList(300,200,300,400,false)
	dgsGridListAddColumn(gridlist,"test",0.7)
	for i=1,10 do
		local row = dgsGridListAddRow(gridlist)
		dgsGridListSetItemText(gridlist,row,1,tostring(i))
		dgsGridListSetItemImage(gridlist,row,1,checkBox.inde_)
		dgsGridListRemoveItemImage(gridlist,row,1)
	end
	iprint(dgsElementData[gridlist].rowData[1][1][7])
end

function dgsAnimTest()
	if not isEasingFunctionExists("shadowOffset") then
		addEasingFunction("shadowOffset",[[
			local old = setting[3] or {}
			local new = setting[2]
			local offsetX = old[1] or 0
			local offsetY = old[2] or 0
			local offsetColor = old[3] or tocolor(0,0,0,255)
			local tofX,tofY = new[1],new[2]
			return {offsetX+(tofX-offsetX)*value,offsetY+(tofY-offsetY)*value,new[3]}
		]])
	end
	
	local label = dgsCreateLabel(500,500,400,20,"Testttttttttttttttttttt",false)
	dgsAnimTo(label,"shadow",{100,100,tocolor(0,0,0,255)},"shadowOffset",10000)
end