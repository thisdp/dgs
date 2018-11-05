function dgsCreateRadioButton(x,y,sx,sy,text,relative,parent,textColor,scalex,scaley,norimg_f,hovimg_f,cliimg_f,norcolor_f,hovcolor_f,clicolor_f,norimg_t,hovimg_t,cliimg_t,norcolor_t,hovcolor_t,clicolor_t)
	assert(tonumber(x),"Bad argument @dgsCreateRadioButton at argument 1, expect number got "..type(x))
	assert(tonumber(y),"Bad argument @dgsCreateRadioButton at argument 2, expect number got "..type(y))
	assert(tonumber(sx),"Bad argument @dgsCreateRadioButton at argument 3, expect number got "..type(sx))
	assert(tonumber(sy),"Bad argument @dgsCreateRadioButton at argument 4, expect number got "..type(sy))
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"Bad argument @dgsCreateRadioButton at argument 7, expect dgs-dxgui got "..dgsGetType(parent))
	end
	local rb = createElement("dgs-dxradiobutton")
	local _x = dgsIsDxElement(parent) and dgsSetParent(rb,parent,true,true) or table.insert(CenterFatherTable,1,rb)
	dgsSetType(rb,"dgs-dxradiobutton")
	dgsSetData(rb,"renderBuffer",{})
	
	local imageUnchecked = styleSettings.radiobutton.image_f
	norimg_f = norimg_f or dgsCreateTextureFromStyle(imageUnchecked[1])
	hovimg_f = hovimg_f or dgsCreateTextureFromStyle(imageUnchecked[2])
	cliimg_f = cliimg_f or dgsCreateTextureFromStyle(imageUnchecked[3])
	dgsSetData(rb,"image_f",{norimg_f,hovimg_f,cliimg_f})
	local colorUnchecked = styleSettings.radiobutton.color_f
	norcolor_f = norcolor_f or colorUnchecked[1]
	hovcolor_f = hovcolor_f or colorUnchecked[2]
	clicolor_f = clicolor_f or colorUnchecked[3]
	dgsSetData(rb,"color_f",{norcolor_f,hovcolor_f,clicolor_f})
	
	local imageChecked = styleSettings.radiobutton.image_t
	norimg_t = norimg_t or dgsCreateTextureFromStyle(imageChecked[1])
	hovimg_t = hovimg_t or dgsCreateTextureFromStyle(imageChecked[2])
	cliimg_t = cliimg_t or dgsCreateTextureFromStyle(imageChecked[3])
	dgsSetData(rb,"image_t",{norimg_t,hovimg_t,cliimg_t})
	local colorChecked = styleSettings.radiobutton.color_t
	norcolor_t = norcolor_t or colorChecked[1]
	hovcolor_t = hovcolor_t or colorChecked[2]
	clicolor_t = clicolor_t or colorChecked[3]
	dgsSetData(rb,"color_t",{norcolor_t,hovcolor_t,clicolor_t})
	
	dgsSetData(rb,"rbParent",dgsIsDxElement(parent) and parent or resourceRoot)
	dgsAttachToTranslation(rb,resourceTranslation[sourceResource or getThisResource()])
	if type(text) == "table" then
		dgsElementData[rb]._translationText = text
		text = dgsTranslate(rb,text,sourceResource)
	end
	dgsSetData(rb,"text",tostring(text))
	dgsSetData(rb,"textColor",textColor or styleSettings.radiobutton.textColor)
	local textSizeX,textSizeY = tonumber(scalex) or styleSettings.radiobutton.textSize[1], tonumber(scaley) or styleSettings.radiobutton.textSize[2]
	dgsSetData(rb,"textSize",{textSizeX,textSizeY})
	dgsSetData(rb,"textImageSpace",styleSettings.radiobutton.textImageSpace)
	dgsSetData(rb,"buttonSize",styleSettings.radiobutton.buttonSize)
	dgsSetData(rb,"shadow",{_,_,_})
	dgsSetData(rb,"font",systemFont)
	dgsSetData(rb,"clip",false)
	dgsSetData(rb,"wordbreak",false)
	dgsSetData(rb,"colorcoded",false)
	dgsSetData(rb,"rightbottom",{"left","center"})
	insertResourceDxGUI(sourceResource,rb)
	calculateGuiPositionSize(rb,x,y,relative or false,sx,sy,relative or false,true)
	triggerEvent("onDgsCreate",rb)
	return rb
end

function dgsRadioButtonGetSelected(rb)
	assert(dgsGetType(rb) == "dgs-dxradiobutton","Bad argument @dgsRadioButtonGetSelected at argument 1, expect dgs-dxradiobutton got "..dgsGetType(rb))
	local _parent = dgsGetParent(rb)
	local parent = dgsIsDxElement(_parent) and _parent or resourceRoot
	return dgsGetData(parent,"RadioButton") == rb
end

function dgsRadioButtonSetSelected(rb,state)
	assert(dgsGetType(rb) == "dgs-dxradiobutton","Bad argument @dgsRadioButtonSetSelected at argument 1, expect dgs-dxradiobutton got "..dgsGetType(rb))
	state = state and true or false
	local _parent = dgsGetParent(rb)
	local parent = dgsIsDxElement(_parent) and _parent or resourceRoot
	local _rb = dgsGetData(parent,"RadioButton")
	if state then
		if rb ~= _rb then
			dgsSetData(parent,"RadioButton",rb)
			if dgsIsDxElement(_rb) then
				triggerEvent("onDgsRadioButtonChange",_rb,false)
			end
			triggerEvent("onDgsRadioButtonChange",rb,true)
		end
		return true
	else
		dgsSetData(parent,"RadioButton",false)
		triggerEvent("onDgsRadioButtonChange",rb,false)
		return true
	end
end