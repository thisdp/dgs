--CheckBox State : true->checked; false->unchecked; nil->indeterminate;
function dgsCreateCheckBox(x,y,sx,sy,text,state,relative,parent,textColor,scalex,scaley,norimg_f,hovimg_f,cliimg_f,norcolor_f,hovcolor_f,clicolor_f,norimg_t,hovimg_t,cliimg_t,norcolor_t,hovcolor_t,clicolor_t,norimg_i,hovimg_i,cliimg_i,norcolor_i,hovcolor_i,clicolor_i)
	assert(tonumber(x),"Bad argument @dgsCreateCheckBox at argument 1, expect number got "..type(x))
	assert(tonumber(y),"Bad argument @dgsCreateCheckBox at argument 2, expect number got "..type(y))
	assert(tonumber(sx),"Bad argument @dgsCreateCheckBox at argument 3, expect number got "..type(sx))
	assert(tonumber(sy),"Bad argument @dgsCreateCheckBox at argument 4, expect number got "..type(sy))
	assert(tonumber(sy),"Bad argument @dgsCreateCheckBox at argument 4, expect number got "..type(sy))
	assert(not state or state == true,"@dgsCreateCheckBox at argument 6, expect boolean/nil got "..type(state))
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"Bad argument @dgsCreateCheckBox at argument 8,expect dgs-dxgui got "..dgsGetType(parent))
	end
	local cb = createElement("dgs-dxcheckbox")
	local _x = dgsIsDxElement(parent) and dgsSetParent(cb,parent,true,true) or table.insert(CenterFatherTable,1,cb)
	dgsSetType(cb,"dgs-dxcheckbox")
	dgsSetData(cb,"renderBuffer",{})
	
	local imageUnchecked = styleSettings.checkbox.image_f
	norimg_f = norimg_f or dgsCreateTextureFromStyle(imageUnchecked[1])
	hovimg_f = hovimg_f or dgsCreateTextureFromStyle(imageUnchecked[2])
	cliimg_f = cliimg_f or dgsCreateTextureFromStyle(imageUnchecked[3])
	dgsSetData(cb,"image_f",{norimg_f,hovimg_f,cliimg_f})
	local colorUnchecked = styleSettings.checkbox.color_f
	norcolor_f = norcolor_f or colorUnchecked[1]
	hovcolor_f = hovcolor_f or colorUnchecked[2]
	clicolor_f = clicolor_f or colorUnchecked[3]
	dgsSetData(cb,"color_f",{norcolor_f,hovcolor_f,clicolor_f})
	
	local imageChecked = styleSettings.checkbox.image_t
	norimg_t = norimg_t or dgsCreateTextureFromStyle(imageChecked[1])
	hovimg_t = hovimg_t or dgsCreateTextureFromStyle(imageChecked[2])
	cliimg_t = cliimg_t or dgsCreateTextureFromStyle(imageChecked[3])
	dgsSetData(cb,"image_t",{norimg_t,hovimg_t,cliimg_t})
	local colorChecked = styleSettings.checkbox.color_t
	norcolor_t = norcolor_t or colorChecked[1]
	hovcolor_t = hovcolor_t or colorChecked[2]
	clicolor_t = clicolor_t or colorChecked[3]
	dgsSetData(cb,"color_t",{norcolor_t,hovcolor_t,clicolor_t})
	
	local imageIndeterminate = styleSettings.checkbox.image_i
	norimg_i = norimg_i or dgsCreateTextureFromStyle(imageIndeterminate[1])
	hovimg_i = hovimg_i or dgsCreateTextureFromStyle(imageIndeterminate[2])
	cliimg_i = cliimg_i or dgsCreateTextureFromStyle(imageIndeterminate[3])
	dgsSetData(cb,"image_i",{norimg_i,hovimg_i,cliimg_i})
	local colorIndeterminate = styleSettings.checkbox.color_i
	norcolor_i = norcolor_i or colorIndeterminate[1]
	hovcolor_i = hovcolor_i or colorIndeterminate[2]
	clicolor_i = clicolor_i or colorIndeterminate[3]
	dgsSetData(cb,"color_i",{norcolor_i,hovcolor_i,clicolor_i})
	
	dgsSetData(cb,"cbParent",dgsIsDxElement(parent) and parent or resourceRoot)
	dgsAttachToTranslation(cb,resourceTranslation[sourceResource or getThisResource()])
	if type(text) == "table" then
		dgsElementData[cb]._translationText = text
		text = dgsTranslate(cb,text,sourceResource)
	end
	dgsSetData(cb,"text",tostring(text))
	dgsSetData(cb,"textColor",textColor or styleSettings.checkbox.textColor)
	local textSizeX,textSizeY = tonumber(scalex) or styleSettings.checkbox.textSize[1], tonumber(scaley) or styleSettings.checkbox.textSize[2]
	dgsSetData(cb,"textSize",{textSizeX,textSizeY})
	dgsSetData(cb,"textImageSpace",styleSettings.checkbox.textImageSpace)
	dgsSetData(cb,"buttonSize",styleSettings.checkbox.buttonSize)
	dgsSetData(cb,"shadow",{_,_,_})
	dgsSetData(cb,"font",systemFont)
	dgsSetData(cb,"clip",false)
	dgsSetData(cb,"wordbreak",false)
	dgsSetData(cb,"colorcoded",false)
	dgsSetData(cb,"CheckBoxState",state)
	dgsSetData(cb,"rightbottom",{"left","center"})
	insertResourceDxGUI(sourceResource,cb)
	calculateGuiPositionSize(cb,x,y,relative or false,sx,sy,relative or false,true)
	triggerEvent("onDgsCreate",cb)
	return cb
end

function dgsCheckBoxGetSelected(cb)
	assert(dgsGetType(cb) == "dgs-dxcheckbox","Bad argument @dgsCheckBoxGetSelected at argument 1,expect dgs-dxcheckbox got "..dgsGetType(cb))
	return dgsElementData[cb].CheckBoxState
end

function dgsCheckBoxSetSelected(cb,state)
	assert(dgsGetType(cb) == "dgs-dxcheckbox","Bad argument @dgsCheckBoxSetSelected at argument 1,expect dgs-dxcheckbox got "..dgsGetType(cb))
	assert(not state or state == true,"Bad argument @dgsCheckBoxSetSelected at argument 2,expect boolean/nil got "..type(state))
	local oldState = dgsElementData[cb].CheckBoxState
	if state ~= oldState then
		triggerEvent("onDgsCheckBoxChange",cb,state,oldState)
	end
	return true
end

addEventHandler("onDgsCheckBoxChange",resourceRoot,function(state)
	if not wasEventCancelled() then
		dgsSetData(source,"CheckBoxState",state)
	end
end)