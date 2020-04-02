function dgsCreateSwitchButton(x,y,sx,sy,textOn,textOff,state,relative,parent,textColorOn,textColorOff,scalex,scaley)
	assert(tonumber(x),"Bad argument @dgsCreateSwitchButton at argument 1, expect number got "..type(x))
	assert(tonumber(y),"Bad argument @dgsCreateSwitchButton at argument 2, expect number got "..type(y))
	assert(tonumber(sx),"Bad argument @dgsCreateSwitchButton at argument 3, expect number got "..type(sx))
	assert(tonumber(sy),"Bad argument @dgsCreateSwitchButton at argument 4, expect number got "..type(sy))
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"Bad argument @dgsCreateSwitchButton at argument 9, expect dgs-dxgui got "..dgsGetType(parent))
	end
	local switchbutton = createElement("dgs-dxswitchbutton")
	local _x = dgsIsDxElement(parent) and dgsSetParent(switchbutton,parent,true,true) or table.insert(CenterFatherTable,switchbutton)
	dgsSetType(switchbutton,"dgs-dxswitchbutton")
	dgsSetData(switchbutton,"renderBuffer",{})

	dgsSetData(switchbutton,"colorOn",styleSettings.switchbutton.colorOn)
	dgsSetData(switchbutton,"colorOff",styleSettings.switchbutton.colorOff)
	dgsSetData(switchbutton,"cursorColor",styleSettings.switchbutton.cursorColor)
	
	local imageOn = styleSettings.switchbutton.imageOn
	local imageNormalOn = dgsCreateTextureFromStyle(imageOn[1])
	local imageHoverOn = dgsCreateTextureFromStyle(imageOn[2])
	local imageClickOn = dgsCreateTextureFromStyle(imageOn[3])
	
	--[[local imageNormalOn = dgsCreateTextureFromStyle(styleSettings.scrollbar.arrowImage)
	local imageHoverOn = dgsCreateTextureFromStyle(styleSettings.scrollbar.arrowImage)
	local imageClickOn = dgsCreateTextureFromStyle(styleSettings.scrollbar.arrowImage)]]
	dgsSetData(switchbutton,"imageOn",{imageNormalOn,imageHoverOn,imageClickOn})
	
	local imageOff = styleSettings.switchbutton.imageOff
	local imageNormalOff = dgsCreateTextureFromStyle(imageOff[1])
	local imageHoverOff = dgsCreateTextureFromStyle(imageOff[2])
	local imageClickOff = dgsCreateTextureFromStyle(imageOff[3])
	
	--[[local imageNormalOff = dgsCreateTextureFromStyle(styleSettings.scrollbar.arrowImage)
	local imageHoverOff = dgsCreateTextureFromStyle(styleSettings.scrollbar.arrowImage)
	local imageClickOff = dgsCreateTextureFromStyle(styleSettings.scrollbar.arrowImage)]]
	dgsSetData(switchbutton,"imageOff",{imageNormalOff,imageHoverOff,imageClickOff})
	
	local cursorImage = styleSettings.switchbutton.cursorImage
	local norimg_c = dgsCreateTextureFromStyle(cursorImage[1])
	local hovimg_c = dgsCreateTextureFromStyle(cursorImage[2])
	local cliimg_c = dgsCreateTextureFromStyle(cursorImage[3])
	dgsSetData(switchbutton,"cursorImage",{norimg_c,selimg_c,cliimg_c})
	
	dgsAttachToTranslation(switchbutton,resourceTranslation[sourceResource or getThisResource()])
	if type(textOn) == "table" then
		dgsElementData[switchbutton]._translationtextOn = textOn
		textOn = dgsTranslate(switchbutton,textOn,sourceResource)
	end
	if type(textOff) == "table" then
		dgsElementData[switchbutton]._translationtextOff = textOff
		textOff = dgsTranslate(switchbutton,textOff,sourceResource)
	end
	dgsSetData(switchbutton,"textOn",tostring(textOn))
	dgsSetData(switchbutton,"textOff",tostring(textOff))
	dgsSetData(switchbutton,"textColorOn",tonumber(textColorOn) or styleSettings.switchbutton.textColorOn)
	dgsSetData(switchbutton,"textColorOff",tonumber(textColorOff) or styleSettings.switchbutton.textColorOff)
	
	local textSizeX,textSizeY = tonumber(scalex) or styleSettings.switchbutton.textSize[1], tonumber(scaley) or styleSettings.switchbutton.textSize[2]
	dgsSetData(switchbutton,"textSize",{textSizeX,textSizeY})
	dgsSetData(switchbutton,"shadow",{_,_,_})
	dgsSetData(switchbutton,"font",styleSettings.switchbutton.font or systemFont)
	dgsSetData(switchbutton,"textOffset",{0.25,true})
	dgsSetData(switchbutton,"state",state and true or false)
	dgsSetData(switchbutton,"cursorMoveSpeed",0.2)
	dgsSetData(switchbutton,"stateAnim",state and 1 or -1)
	dgsSetData(switchbutton,"clickButton","left")	--"left":LMB;"middle":Wheel;"right":RMB
	dgsSetData(switchbutton,"clickState","up")	--"down":Down;"up":Up
	dgsSetData(switchbutton,"cursorWidth",styleSettings.switchbutton.cursorWidth)
	dgsSetData(switchbutton,"clip",false)
	dgsSetData(switchbutton,"wordbreak",false)
	dgsSetData(switchbutton,"colorcoded",false)
	dgsSetData(switchbutton,"style",1)	--default
	calculateGuiPositionSize(switchbutton,x,y,relative or false,sx,sy,relative or false,true)
	triggerEvent("onDgsCreate",switchbutton,sourceResource)
	return switchbutton
end

function dgsSwitchButtonGetState(switchbutton)
	assert(dgsGetType(switchbutton) == "dgs-dxswitchbutton","Bad argument @dgsSwitchButtonGetState at argument at 1, expect dgs-dxswitchbutton got "..dgsGetType(switchbutton))
	return dgsElementData[switchbutton].state
end

function dgsSwitchButtonSetState(switchbutton,state)
	assert(dgsGetType(switchbutton) == "dgs-dxswitchbutton","Bad argument @dgsSwitchButtonSetState at argument at 1, expect dgs-dxswitchbutton got "..dgsGetType(switchbutton))
	return dgsSetData(switchbutton,"state",state and true or false)
end

function dgsSwitchButtonSetText(switchbutton,textOn,textOff)
	assert(dgsGetType(switchbutton) == "dgs-dxswitchbutton","Bad argument @dgsSwitchButtonSetText at argument at 1, expect dgs-dxswitchbutton got "..dgsGetType(switchbutton))
	if type(textOn) == "table" then
		dgsElementData[switchbutton]._translationtextOn = textOn
		textOn = dgsTranslate(switchbutton,textOn,sourceResource)
	else
		dgsElementData[switchbutton]._translationtextOn = nil
	end
	if type(textOff) == "table" then
		dgsElementData[switchbutton]._translationtextOff = textOff
		textOff = dgsTranslate(switchbutton,textOff,sourceResource)
	else
		dgsElementData[switchbutton]._translationtextOff = nil
	end
	textOn = textOn or dgsElementData[switchbutton].textOn
	textOff = textOff or dgsElementData[switchbutton].textOff
	dgsSetData(switchbutton,"textOn",tostring(textOn))
	dgsSetData(switchbutton,"textOff",tostring(textOff))
end

function dgsSwitchButtonGetText(switchbutton)
	assert(dgsGetType(switchbutton) == "dgs-dxswitchbutton","Bad argument @dgsSwitchButtonGetText at argument at 1, expect dgs-dxswitchbutton got "..dgsGetType(switchbutton))
	return dgsElementData[switchbutton].textOn,dgsElementData[switchbutton].textOff
end