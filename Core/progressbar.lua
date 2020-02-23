ProgressBarStyle = {
	["normal"] = function(source,x,y,w,h,bgImage,bgColor,indicatorImage,indicatorColor,indicatorMode,padding,percent,rendSet)
		local eleData = dgsElementData[source]
		local iPosX,iPosY,iSizX,iSizY = x+padding[1],y+padding[2],(w-padding[1]*2)*percent,h-padding[2]*2
		if bgImage then
			dxDrawImage(x,y,w,h,bgImage,0,0,0,bgColor,rendSet)
		else
			dxDrawRectangle(x,y,w,h,bgColor,rendSet)
		end
		if isElement(indicatorImage) then
			local sx,sy = eleData.indicatorUVSize[1],eleData.indicatorUVSize[2]
			if indicatorMode then
				if not sx or not sy then
					sx,sy = dxGetMaterialSize(indicatorImage)
				end
				dxDrawImageSection(iPosX,iPosY,iSizX,iSizY,1,1,sx*percent,sy,indicatorImage,0,0,0,indicatorColor,rendSet)
			else
				dxDrawImage(iPosX,iPosY,iSizX,iSizY,indicatorImage,0,0,0,indicatorColor,rendSet)
			end
		else
			dxDrawRectangle(iPosX,iPosY,iSizX,iSizY,indicatorColor,rendSet)
		end
		
	end,
	["ring-round"] = function(source,x,y,w,h,bgImage,bgColor,indicatorImage,indicatorColor,indicatorMode,padding,percent)
		local eleData = dgsElementData[source]
		local styleData = eleData.styleData
		local circle = styleData.elements.circleShader
		local startPoint,endPoint = 0,percent
		dxSetShaderValue(circle,"progress",{styleData.isReverse and endPoint or startPoint,not styleData.isReverse and endPoint or startPoint})
		dxSetShaderValue(circle,"indicatorColor",{fromcolor(indicatorColor,true,true)})
		dxSetShaderValue(circle,"thickness",styleData.thickness)
		dxSetShaderValue(circle,"radius",styleData.radius)
		dxSetShaderValue(circle,"antiAliased",styleData.antiAliased)
		dxDrawImage(x,y,w,h,circle,styleData.rotation,0,0,bgColor,rendSet)
	end,
}

function dgsCreateProgressBar(x,y,sx,sy,relative,parent,bgImage,bgColor,indicatorImage,indicatorColor,indicatorMode)
	assert(tonumber(x),"Bad argument @dgsCreateProgressBar at argument 1, expect number got "..type(x))
	assert(tonumber(y),"Bad argument @dgsCreateProgressBar at argument 2, expect number got "..type(y))
	assert(tonumber(sx),"Bad argument @dgsCreateProgressBar at argument 3, expect number got "..type(sx))
	assert(tonumber(sy),"Bad argument @dgsCreateProgressBar at argument 4, expect number got "..type(sy))
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"Bad argument @dgsCreateProgressBar at argument 6, expect dgs-dxprogressbar got "..dgsGetType(parent))
	end
	if isElement(bgImage) then
		local imgtyp = getElementType(bgImage)
		assert(imgtyp == "texture" or imgtyp == "shader","Bad argument @dgsCreateProgressBar at argument 7, expect texture got "..getElementType(bgImage))
	end
	if isElement(indicatorImage) then
		local imgtyp = getElementType(indicatorImage)
		assert(imgtyp == "texture" or imgtyp == "shader","Bad argument @dgsCreateProgressBar at argument 9, expect texture got "..getElementType(indicatorImage))
	end
	local progressbar = createElement("dgs-dxprogressbar")
	local _ = dgsIsDxElement(parent) and dgsSetParent(progressbar,parent,true,true) or table.insert(CenterFatherTable,progressbar)
	dgsSetType(progressbar,"dgs-dxprogressbar")
	dgsSetData(progressbar,"renderBuffer",{})
	dgsSetData(progressbar,"bgColor",bgColor or styleSettings.progressbar.bgColor)
	dgsSetData(progressbar,"bgImage",bgImage or dgsCreateTextureFromStyle(styleSettings.progressbar.bgImage))
	dgsSetData(progressbar,"indicatorColor",indicatorColor or styleSettings.progressbar.indicatorColor)
	dgsSetData(progressbar,"indicatorImage",indicatorImage or dgsCreateTextureFromStyle(styleSettings.progressbar.indicatorImage))
	dgsSetData(progressbar,"indicatorMode",indicatorMode and true or false)
	dgsSetData(progressbar,"padding",styleSettings.progressbar.padding)
	dgsSetData(progressbar,"styleData",{})
	dgsSetData(progressbar,"style","normal")
	dgsSetData(progressbar,"progress",0)
	calculateGuiPositionSize(progressbar,x,y,relative or false,sx,sy,relative or false,true)
	local mx,my = false,false
	if isElement(indicatorImage) then
		mx,my = dxGetMaterialSize(indicatorImage)
	end
	dgsSetData(progressbar,"indicatorUVSize",{mx,my})
	triggerEvent("onDgsCreate",progressbar,sourceResource)
	return progressbar
end

function dgsProgressBarSetStyle(progressbar,style,settingTable)
	assert(dgsGetType(progressbar) == "dgs-dxprogressbar","Bad argument @dgsProgressBarSetStyle at argument 1, expect dgs-dxprogressbar got "..(dgsGetType(progressbar) or type(progressbar)))
	if ProgressBarStyle[style] then
		dgsSetData(progressbar,"style",style)
		for k,v in pairs(dgsElementData[progressbar].styleData.elements or {}) do
			destroyElement(v)
		end
		if style == "normal" then
			dgsSetData(progressbar,"styleData",{})
		elseif style == "ring-round" then
			dgsSetData(progressbar,"styleData",{})
			local styleData = dgsElementData[progressbar].styleData
			styleData.elements = {}
			styleData.elements.circleShader = dxCreateShader("shaders/ring-round.fx")
			styleData.isReverse = false
			styleData.rotation = 0
			styleData.antiAliased = 0.005
			styleData.radius = 0.2
			styleData.thickness = 0.02
		end
		for k,v in pairs(settingTable or {}) do
			dgsElementData[progressbar].styleData[k] = v
		end
		return true
	end
	return false
end

function dgsProgressBarGetStyle(progressbar)
	assert(dgsGetType(progressbar) == "dgs-dxprogressbar","Bad argument @dgsProgressBarGetStyle at argument 1, expect dgs-dxprogressbar got "..(dgsGetType(progressbar) or type(progressbar)))
	return dgsElementData[progressbar].style
end
function dgsProgressBarGetStyleProperty(progressbar,propertyName)
	assert(dgsGetType(progressbar) == "dgs-dxprogressbar","Bad argument @dgsProgressBarGetStyleProperty at argument 1, expect dgs-dxprogressbar got "..(dgsGetType(progressbar) or type(progressbar)))
	return dgsElementData[progressbar].styleData[propertyName]
end

function dgsProgressBarGetStyleProperties(progressbar)
	assert(dgsGetType(progressbar) == "dgs-dxprogressbar","Bad argument @dgsProgressBarGetStyleProperties at argument 1, expect dgs-dxprogressbar got "..(dgsGetType(progressbar) or type(progressbar)))
	return dgsElementData[progressbar].styleData
end

function dgsProgressBarSetStyleProperty(progressbar,propertyName,value)
	assert(dgsGetType(progressbar) == "dgs-dxprogressbar","Bad argument @dgsProgressBarSetStyleProperty at argument 1, expect dgs-dxprogressbar got "..(dgsGetType(progressbar) or type(progressbar)))
	dgsElementData[progressbar].styleData[propertyName] = value
	return true
end

function dgsProgressBarGetProgress(progressbar,easing)
	assert(dgsGetType(progressbar) == "dgs-dxprogressbar","Bad argument @dgsProgressBarGetProgress at argument 1, expect dgs-dxprogressbar got "..(dgsGetType(progressbar) or type(progressbar)))
	return dgsElementData[progressbar].progress
end

function dgsProgressBarSetProgress(progressbar,progress)
	assert(dgsGetType(progressbar) == "dgs-dxprogressbar","Bad argument @dgsProgressBarSetProgress at argument 1, expect dgs-dxprogressbar got "..(dgsGetType(progressbar) or type(progressbar)))
	if progress < 0 then progress = 0 end
	if progress > 100 then progress = 100 end
	if dgsElementData[progressbar].progress ~= progress then
		dgsSetData(progressbar,"progress",progress)
	end
	return true
end

function dgsProgressBarSetMode(progressbar,mode)
	assert(dgsGetType(progressbar) == "dgs-dxprogressbar","Bad argument @dgsProgressBarSetindicatorMode at argument 1, expect dgs-dxprogressbar got "..(dgsGetType(progressbar) or type(progressbar)))
	return dgsSetData(progressbar,"indicatorMode",mode and true or false)
end

function dgsProgressBarGetMode(progressbar)
	assert(dgsGetType(progressbar) == "dgs-dxprogressbar","Bad argument @dgsProgressBarSetindicatorMode at argument 1, expect dgs-dxprogressbar got "..(dgsGetType(progressbar) or type(progressbar)))
	return dgsElementData[progressbar].indicatorMode
end
