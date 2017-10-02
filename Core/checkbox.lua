local checkBox = {}
checkBox.false_ = dxCreateTexture("image/checkbox/cb_f.png")
checkBox.true_ = dxCreateTexture("image/checkbox/cb_t.png")
checkBox.inde_ = dxCreateTexture("image/checkbox/cb_i.png")
checkBox.false_cli = dxCreateTexture("image/checkbox/cb_f_s.png")
checkBox.true_cli = dxCreateTexture("image/checkbox/cb_t_s.png")
checkBox.inde_cli = dxCreateTexture("image/checkbox/cb_i_s.png")

--CheckBox State : true->checked; false->unchecked; nil->indeterminate;
function dgsDxCreateCheckBox(x,y,sx,sy,text,relative,parent,textcolor,scalex,scaley,defimg_f,hovimg_f,cliimg_f,defcolor_f,hovcolor_f,clicolor_f,defimg_t,hovimg_t,cliimg_t,defcolor_t,hovcolor_t,clicolor_t,defimg_i,hovimg_i,cliimg_i,defcolor_i,hovcolor_i,clicolor_i)
	assert(tonumber(x),"@dgsDxCreateCheckBox argument 1,expect number got "..type(x))
	assert(tonumber(y),"@dgsDxCreateCheckBox argument 2,expect number got "..type(y))
	assert(tonumber(sx),"@dgsDxCreateCheckBox argument 3,expect number got "..type(sx))
	assert(tonumber(sy),"@dgsDxCreateCheckBox argument 4,expect number got "..type(sy))
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"@dgsDxCreateCheckBox argument 7,expect dgs-dxgui got "..dgsGetType(parent))
	end
	local cb = createElement("dgs-dxcheckbox")
	dgsSetType(cb,"dgs-dxcheckbox")
	local _x = dgsIsDxElement(parent) and dgsSetParent(cb,parent,true) or table.insert(MaxFatherTable,1,cb)
	defimg_f = defimg_f or checkBox.false_
	hovimg_f = hovimg_f or checkBox.false_cli
	cliimg_f = cliimg_f or hovimg_f
	
	defcolor_f = defcolor_f or tocolor(255,255,255,255)
	hovcolor_f = hovcolor_f or tocolor(255,255,255,255)
	clicolor_f = clicolor_f or tocolor(180,180,180,255)
	
	defimg_t = defimg_t or checkBox.true_
	hovimg_t = hovimg_t or checkBox.true_cli
	cliimg_t = cliimg_t or hovimg_t
	
	defcolor_t = defcolor_t or tocolor(255,255,255,255)
	hovcolor_t = hovcolor_t or tocolor(255,255,255,255)
	clicolor_t = clicolor_t or tocolor(180,180,180,255)
	
	defimg_i = defimg_i or checkBox.inde_
	hovimg_i = hovimg_i or checkBox.inde_cli
	cliimg_i = cliimg_i or hovimg_i
	
	defcolor_i = defcolor_i or tocolor(255,255,255,255)
	hovcolor_i = hovcolor_i or tocolor(255,255,255,255)
	clicolor_i = clicolor_i or tocolor(180,180,180,255)
	
	dgsSetData(cb,"cbParent",dgsIsDxElement(parent) and parent or resourceRoot)
	dgsSetData(cb,"image_f",{defimg_f,hovimg_f,cliimg_f})
	dgsSetData(cb,"image_t",{defimg_t,hovimg_t,cliimg_t})
	dgsSetData(cb,"image_i",{defimg_i,hovimg_i,cliimg_i})
	dgsSetData(cb,"color_f",{defcolor_f,hovcolor_f,clicolor_f})
	dgsSetData(cb,"color_t",{defcolor_t,hovcolor_t,clicolor_t})
	dgsSetData(cb,"color_i",{defcolor_i,hovcolor_i,clicolor_i})
	dgsSetData(cb,"text",tostring(text))
	dgsSetData(cb,"textcolor",textcolor or tocolor(255,255,255,255))
	dgsSetData(cb,"textsize",{tonumber(scalex) or 1,tonumber(scaley) or 1})
	dgsSetData(cb,"textImageSpace",{2,false})
	dgsSetData(cb,"shadow",{_,_,_})
	dgsSetData(cb,"font",systemFont)
	dgsSetData(cb,"buttonsize",{16,false})
	dgsSetData(cb,"clip",false)
	dgsSetData(cb,"wordbreak",false)
	dgsSetData(cb,"colorcoded",false)
	dgsSetData(cb,"CheckBoxState",false)
	dgsSetData(cb,"rightbottom",{"left","center"})
	insertResourceDxGUI(sourceResource,cb)
	triggerEvent("onClientDgsDxGUIPreCreate",cb)
	calculateGuiPositionSize(cb,x,y,relative or false,sx,sy,relative or false,true)
	triggerEvent("onClientDgsDxGUICreate",cb)
	return cb
end

function dgsDxCheckBoxGetSelected(cb)
	assert(dgsGetType(cb) == "dgs-dxcheckbox","@dgsDxCheckBoxGetSelected argument 1,expect number got "..dgsGetType(cb))
	return dgsElementData[cb].CheckBoxState
end

function dgsDxCheckBoxSetSelected(cb,state)
	assert(dgsGetType(cb) == "dgs-dxcheckbox","@dgsDxCheckBoxSetSelected argument 1,expect number got "..dgsGetType(cb))
	assert(not state or state == true,"@dgsDxCheckBoxSetSelected argument 2,expect boolean/nil got "..type(state))
	local oldState = dgsElementData[cb].CheckBoxState
	if state ~= oldState then
		triggerEvent("onClientDgsDxCheckBoxChanged",cb,state,oldState)
	end
	return true
end

addEventHandler("onClientDgsDxCheckBoxChanged",resourceRoot,function(state)
	if not wasEventCancelled() then
		dgsSetData(source,"CheckBoxState",state)
	end
end)

