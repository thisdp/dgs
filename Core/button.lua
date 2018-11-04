function dgsCreateButton(x,y,sx,sy,text,relative,parent,textColor,scalex,scaley,norimg,selimg,cliimg,norcolor,hovcolor,clicolor)
	assert(tonumber(x),"Bad argument @dgsCreateButton at argument 1, expect number got "..type(x))
	assert(tonumber(y),"Bad argument @dgsCreateButton at argument 2, expect number got "..type(y))
	assert(tonumber(sx),"Bad argument @dgsCreateButton at argument 3, expect number got "..type(sx))
	assert(tonumber(sy),"Bad argument @dgsCreateButton at argument 4, expect number got "..type(sy))
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"Bad argument @dgsCreateButton at argument 7, expect dgs-dxgui got "..dgsGetType(parent))
	end
	local button = createElement("dgs-dxbutton")
	dgsSetType(button,"dgs-dxbutton")
	local _x = dgsIsDxElement(parent) and dgsSetParent(button,parent,true,true) or table.insert(CenterFatherTable,1,button)
	local norcolor = norcolor or styleSettings.button.color[1]
	local hovcolor = hovcolor or styleSettings.button.color[2]
	local clicolor = clicolor or styleSettings.button.color[3]
	dgsSetData(button,"color",{norcolor,hovcolor,clicolor})
	local norimg = norimg or dgsCreateTextureFromStyle(styleSettings.button.image[1])
	local hovimg = selimg or dgsCreateTextureFromStyle(styleSettings.button.image[2])
	local cliimg = cliimg or dgsCreateTextureFromStyle(styleSettings.button.image[3])
	dgsSetData(button,"image",{norimg,selimg,cliimg})
	dgsAttachToTranslation(button,resourceTranslation[sourceResource or getThisResource()])
	if type(text) == "table" then
		dgsElementData[button]._translationText = text
		text = dgsTranslate(button,text,sourceResource)
	end
	dgsSetData(button,"text",tostring(text))
	dgsSetData(button,"textColor",tonumber(textColor) or styleSettings.button.textColor)
	local textSizeX,textSizeY = tonumber(scalex) or styleSettings.button.textSize[1], tonumber(scaley) or styleSettings.button.textSize[2]
	dgsSetData(button,"textSize",{textSizeX,textSizeY})
	dgsSetData(button,"shadow",{_,_,_})
	dgsSetData(button,"font",systemFont)
	dgsSetData(button,"clickoffset",{0,0})
	dgsSetData(button,"textOffset",{0,0,false})
	dgsSetData(button,"clip",false)
	dgsSetData(button,"clickType",1)	--1:LMB;2:Wheel;3:RMB
	dgsSetData(button,"wordbreak",false)
	dgsSetData(button,"colorcoded",false)
	dgsSetData(button,"rightbottom",{"center","center"})
	dgsSetData(button,"buttonImage",false)
	insertResourceDxGUI(sourceResource,button)
	calculateGuiPositionSize(button,x,y,relative or false,sx,sy,relative or false,true)
	triggerEvent("onDgsCreate",button)
	return button
end

function dgsSetButtonImage(gui,image,x,y,sx,sy,u,v,us,vs)
	assert(dgsGetType(gui) == "dgs-dxbutton","Bad argument @dgsSetButtonImage at argument 1, expect dgs-dxbutton got "..(dgsGetType(gui) or type(gui)))
	local mus, mvs = image and dxGetMaterialSize( image )	
	x,y   = tonumber(x) or 0, tonumber(y) or 0
	sx,sy = tonumber(sx) or 1, tonumber(sy) or 1
	u,v   = tonumber(u) or 0, tonumber(v) or 0
	us,vs = tonumber(us) or mus, tonumber(vs) or mvs
	return dgsSetData(gui,"buttonImage",image and {image,x,y,sx,sy,u,v,us,vs})
end

function dgsGetButtonImage(gui)
	assert(dgsGetType(gui) == "dgs-dxbutton","Bad argument @dgsGetButtonImage at argument 1, expect dgs-dxbutton got "..(dgsGetType(gui) or type(gui)))
	if not dgsElementData[gui].buttonImage then return end
	return unpack(dgsElementData[gui].buttonImage)
end
