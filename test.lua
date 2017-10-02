function createTest()
wind = dgsDxCreateWindow(math.floor(0.2*sW),math.floor(0.3*sH),math.floor(0.4*sW),math.floor(0.4*sH),"Example Scroll Pane (exclude this window)",false)
pane = dgsDxCreateScrollPane(0,0,1,1,true,wind)
gdlt = dgsDxCreateImage(0,0,0.7,0.7,_,true,pane,tocolor(255,255,255,255))
gdlt2 = dgsDxCreateImage(0,0,0.7,0.7,_,true,gdlt,tocolor(0,255,255,255))
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