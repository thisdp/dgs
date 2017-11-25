function createTest()
addEasingFunction("Pre_line",[[
	return math.abs(value^2-0.5)*2
]])

wind = dgsDxCreateWindow(math.floor(0.2*sW),math.floor(0.3*sH),math.floor(0.4*sW),math.floor(0.4*sH),"Example Scroll Pane (exclude this window)",false)
--pane = dgsDxCreateScrollPane(0,0,1,1,true,wind)
gdlt = dgsDxCreateImage(0,0,0.7,0.7,_,true,wind,tocolor(255,255,255,255))
gdlt2 = dgsDxCreateImage(0,0,0.7,0.7,_,true,gdlt,tocolor(0,255,255,255))
dgsSizeTo(wind,0.5*sW,0.5*sH,false,false,"line",1000)
end

function createTest2()
	tabp = dgsDxCreateTabPanel(400,200,400,400,false)
	tab1 = dgsDxCreateTab("DGS",tabp)
	tab2 = dgsDxCreateTab("Tab",tabp)
	for i=1,10 do
		dgsDxCreateTab(i.."Panel",tabp)
	end
	gdlt2 = dgsDxCreateButton(10,0,100,120,"test",false,tab1,tocolor(255,255,255,255))
end

function createTest3()
	local rb1= dgsDxCreateRadioButton(500,500,200,30,"aaaa",false)
	local rb2 = dgsDxCreateRadioButton(500,520,200,30,"bbbb",false)
end

function createTest4()
	rb1 = dgsDxCreateComboBox(500,400,200,30,false)
	for i=1,20 do
		dgsDxComboBoxAddItem(rb1,i)
	end
end

function createTest5()
	local cb1= dgsDxCreateCheckBox(500,500,200,30,"test_indeterminate",false)
	local cb2 = dgsDxCreateCheckBox(500,520,200,30,"test_checked",false)
	local cb2 = dgsDxCreateCheckBox(500,540,200,30,"test_unchecked",false)
	dgsDxCheckBoxSetSelected(cb1,nil)
end

function createTestMemo()
	local memo = dgsDxCreateMemo(500,200,200,300,[[This is a dgs-dxmemo
	
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
	--dgsDxMemoSetReadOnly(memo,true)
end

function editTest() --Test Tab Switch for edit.
	edit = dgsDxCreateEdit(0.3,0.3,0.2,0.05,"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaass",true)
	setTimer(function()
		dgsDxEditSetMaxLength(edit,10,true)
	end,1000,1)
	edit2 = dgsDxCreateEdit(0.3,0.4,0.2,0.05,"123123",true)
	edit3 = dgsDxCreateEdit(0.3,0.5,0.2,0.05,"123123",true)
	edit4 = dgsDxCreateEdit(0.3,0.6,0.2,0.05,"123123",true)
	dgsDxEditSetReadOnly(edit4,true)
	dgsDxGUIBringToFront(edit,"left")
	dgsDxEditSetCaretPosition (edit, 1)
end