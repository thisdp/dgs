schemeColor = {}
defcolor = {}
defcolor.button = {}
defcolor.checkbox = {}
defcolor.radiobutton = {}
defcolor.cmd = {}
defcolor.combobox = {}
defcolor.edit = {}
defcolor.memo = {}
defcolor.progressbar = {}
defcolor.gridlist = {}
defcolor.scrollbar = {}
defcolor.tabpanel = {}
defcolor.tab = {}
defcolor.disabledColor = true
defcolor.disabledColorPercent = 0.8
defcolor.button.color = {tocolor(0,120,200,200),tocolor(0,90,255,200),tocolor(50,90,250,200)}
defcolor.button.textcolor = tocolor(255,255,255,255)
defcolor.checkbox.defcolor_f = {tocolor(255,255,255,255),tocolor(255,255,255,255),tocolor(180,180,180,255)}
defcolor.checkbox.defcolor_t = {tocolor(255,255,255,255),tocolor(255,255,255,255),tocolor(180,180,180,255)}
defcolor.checkbox.defcolor_i = {tocolor(255,255,255,255),tocolor(255,255,255,255),tocolor(180,180,180,255)}
defcolor.checkbox.textcolor = tocolor(255,255,255,255)
defcolor.radiobutton.defcolor_f = {tocolor(255,255,255,255),tocolor(255,255,255,255),tocolor(180,180,180,255)}
defcolor.radiobutton.defcolor_t = {tocolor(255,255,255,255),tocolor(255,255,255,255),tocolor(180,180,180,255)}
defcolor.radiobutton.textcolor = tocolor(255,255,255,255)
defcolor.cmd.bgcolor = tocolor(0,0,0,150)
defcolor.combobox.color = {tocolor(0,120,200,200),tocolor(0,90,255,200),tocolor(50,90,250,200)}
defcolor.combobox.itemColor = {tocolor(200,200,200,255),tocolor(160,160,160,255),tocolor(130,130,130,255)}
defcolor.combobox.combobgColor = tocolor(200,200,200,200)
defcolor.combobox.arrowColor = tocolor(255,255,255,255)
defcolor.combobox.arrowOutSideColor = tocolor(255,255,255,255)
defcolor.combobox.textcolor = tocolor(0,0,0,255)
defcolor.combobox.listtextcolor = tocolor(0,0,0,255)
defcolor.window = {}
defcolor.edit.bgcolor = tocolor(200,200,200,255)
defcolor.edit.textcolor = tocolor(0,0,0,255)
defcolor.edit.sidecolor = tocolor(0,0,0,255)
defcolor.edit.caretcolor = tocolor(0,0,0,255)
defcolor.memo.bgcolor = tocolor(200,200,200,255)
defcolor.memo.textcolor = tocolor(0,0,0,255)
defcolor.memo.sidecolor = tocolor(0,0,0,255)
defcolor.memo.caretcolor = tocolor(0,0,0,255)
defcolor.progressbar.bgcolor = tocolor(100,100,100,200)
defcolor.progressbar.barcolor = tocolor(40,60,200,200)
defcolor.gridlist.bgcolor = tocolor(210,210,210,255)
defcolor.gridlist.columncolor = tocolor(220,220,220,255)
defcolor.gridlist.columntextcolor = tocolor(0,0,0,255)
defcolor.gridlist.rowcolor = {tocolor(200,200,200,255),tocolor(150,150,150,255),tocolor(0,170,242,255)}
defcolor.gridlist.rowtextcolor = tocolor(0,0,0,255)
defcolor.scrollbar.colorn = {tocolor(240,240,240,255),tocolor(192,192,192,255),tocolor(240,240,240,255)}
defcolor.scrollbar.colore = {tocolor(218,218,218,255),tocolor(166,166,166,255)}
defcolor.scrollbar.colorc = {tocolor(180,180,180,255),tocolor(96,96,96,255)}
defcolor.tabpanel.defbackground = tocolor(0,0,0,180)
defcolor.tab.textcolor = tocolor(255,255,255,255)
defcolor.tab.bgcolor = tocolor(0,0,0,200)
defcolor.tab.tabcolor = {tocolor(40,40,40,180),tocolor(80,80,80,190),tocolor(0,0,0,200)}
defcolor.window.titnamecolor = tocolor(255,255,255,255)
defcolor.window.titcolor = tocolor(20,20,20,200)
defcolor.window.color = tocolor(20,20,20,150)
defcolor.window.closeButtonColor = {tocolor(200,50,50,255),tocolor(250,20,20,255),tocolor(150,50,50,255)}

function loadColorScheme()
	local schemeIndex = fileOpen("colorSchemeIndex.txt")
	local str = fileRead(schemeIndex,fileGetSize(schemeIndex))
	local fnc = loadstring(str)
	fnc()
	local scheme = fileOpen("colorScheme.txt")
	local schemeColor_ = table.deepcopy(defcolor)
	if scheme then
		local str = fileRead(scheme,fileGetSize(scheme))
		fileClose(scheme)
		local fnc = loadstring(str)
		if not str then outputDebugString("[DGS]Fail to load color scheme (colorScheme.txt)",2) return end
		fnc()
		for k,v in pairs(schemeColor_) do
			if schemeColor[k] == nil then
				schemeColor[k] = v
			end
		end
	end
end

function restoreColorScheme()
	table.remove(schemeColor)
	schemeColor = table.deepcopy(defcolor)
end
loadColorScheme()