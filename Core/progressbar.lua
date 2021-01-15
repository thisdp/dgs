--Dx Functions
local dxDrawLine = dxDrawLine
local dxDrawImage = dxDrawImageExt
local dxDrawImageSection = dxDrawImageSectionExt
local dxDrawText = dxDrawText
local dxGetFontHeight = dxGetFontHeight
local dxDrawRectangle = dxDrawRectangle
local dxSetShaderValue = dxSetShaderValue
local dxGetPixelsSize = dxGetPixelsSize
local dxGetPixelColor = dxGetPixelColor
local dxSetRenderTarget = dxSetRenderTarget
local dxGetTextWidth = dxGetTextWidth
local dxSetBlendMode = dxSetBlendMode
--
local assert = assert
local type = type
local isElement = isElement

ProgressBarShaders = {}
ProgressBarStyle = {
	["normal-horizontal"] = function(source,x,y,w,h,bgImage,bgColor,indicatorImage,indicatorColor,indicatorMode,padding,percent,rendSet)
		local eleData = dgsElementData[source]
		local iPosX,iPosY,iSizX,iSizY = x+padding[1],y+padding[2],w-padding[1]*2,h-padding[2]*2
		local iSizXPercent = iSizX*percent
		if bgImage then
			dxDrawImage(x,y,w,h,bgImage,0,0,0,bgColor,rendSet,rndtgt)
		else
			dxDrawRectangle(x,y,w,h,bgColor,rendSet)
		end
		if type(indicatorImage) == "table" then
			if type(indicatorColor) ~= "table" then
				indicatorColor = {indicatorColor,indicatorColor}
			end
			if indicatorMode then
				local sx,sy = eleData.indicatorUVSize[1],eleData.indicatorUVSize[2]
				if not sx or not sy then
					sx1,sy1 = dxGetMaterialSize(indicatorImage[1])
					sx2,sy2 = dxGetMaterialSize(indicatorImage[2])
				else
					sx1,sy1,sx2,sy2 = sx,sy,sx,sy
				end
				dxDrawImageSection(iPosX,iPosY,iSizXPercent,iSizY,0,0,sx1*percent,sy1,indicatorImage[1],0,0,0,indicatorColor[1],rendSet,rndtgt)
				dxDrawImageSection(iSizXPercent+iPosX,iPosY,iSizX-iSizXPercent,iSizY,sx2*percent,0,sx2*(1-percent),sy2,indicatorImage[1],0,0,0,indicatorColor[2],rendSet,rndtgt)
			else
				dxDrawImage(iPosX,iPosY,iSizXPercent,iSizY,indicatorImage[1],0,0,0,indicatorColor[1],rendSet,rndtgt)
				dxDrawImage(iSizXPercent+iPosX,iPosY,iSizX-iSizXPercent,iSizY,indicatorImage[2],0,0,0,indicatorColor[2],rendSet,rndtgt)
			end
		elseif isElement(indicatorImage) then
			if type(indicatorColor) == "table" then
				if indicatorMode then
					local sx,sy = eleData.indicatorUVSize[1],eleData.indicatorUVSize[2]
					if not sx or not sy then sx,sy = dxGetMaterialSize(indicatorImage) end
					dxDrawImageSection(iPosX,iPosY,iSizXPercent,iSizY,0,0,sx*percent,sy,indicatorImage,0,0,0,indicatorColor[1],rendSet,rndtgt)
					dxDrawImageSection(iSizXPercent+iPosX,iPosY,iSizX-iSizXPercent,iSizY,sx*percent,0,sx*(1-percent),sy,indicatorImage,0,0,0,indicatorColor[2],rendSet,rndtgt)
				else
					dxDrawImage(iPosX,iPosY,iSizXPercent,iSizY,indicatorImage,0,0,0,indicatorColor[1],rendSet,rndtgt)
					dxDrawImage(iSizXPercent+iPosX,iPosY,iSizX-iSizXPercent,iSizY,indicatorImage,0,0,0,indicatorColor[2],rendSet,rndtgt)
				end
			else
				if indicatorMode then
					local sx,sy = eleData.indicatorUVSize[1],eleData.indicatorUVSize[2]
					if not sx or not sy then sx,sy = dxGetMaterialSize(indicatorImage) end
					dxDrawImageSection(iPosX,iPosY,iSizXPercent,iSizY,0,0,sx*percent,sy,indicatorImage,0,0,0,indicatorColor,rendSet,rndtgt)
				else
					dxDrawImage(iPosX,iPosY,iSizXPercent,iSizY,indicatorImage,0,0,0,indicatorColor,rendSet,rndtgt)
				end
			end
		elseif type(indicatorColor) == "table" then
			dxDrawRectangle(iPosX,iPosY,iSizXPercent,iSizY,indicatorColor[1],rendSet)
			dxDrawRectangle(iSizXPercent+iPosX,iPosY,iSizX-iSizXPercent,iSizY,indicatorColor[2],rendSet)
		else
			dxDrawRectangle(iPosX,iPosY,iSizXPercent,iSizY,indicatorColor,rendSet)
		end
	end,
	["normal-vertical"] = function(source,x,y,w,h,bgImage,bgColor,indicatorImage,indicatorColor,indicatorMode,padding,percent,rendSet)
		local eleData = dgsElementData[source]
		local iPosX,iPosY,iSizX,iSizY = x+padding[1],y+padding[2],w-padding[1]*2,h-padding[2]*2
		local iSizYPercent = iSizY*percent
		local iSizYPercentRev = iSizY*(1-percent)
		if bgImage then
			dxDrawImage(x,y,w,h,bgImage,0,0,0,bgColor,rendSet,rndtgt)
		else
			dxDrawRectangle(x,y,w,h,bgColor,rendSet)
		end
		if type(indicatorImage) == "table" then
			if type(indicatorColor) ~= "table" then
				indicatorColor = {indicatorColor,indicatorColor}
			end
			if indicatorMode then
				local sx,sy = eleData.indicatorUVSize[1],eleData.indicatorUVSize[2]
				if not sx or not sy then
					sx1,sy1 = dxGetMaterialSize(indicatorImage[1])
					sx2,sy2 = dxGetMaterialSize(indicatorImage[2])
				else
					sx1,sy1,sx2,sy2 = sx,sy,sx,sy
				end
				dxDrawImageSection(iPosX,iPosY+iSizYPercentRev,iSizX,iSizYPercent,0,sy1*(1-percent),sx1,sy1*percent,indicatorImage[1],0,0,0,indicatorColor[1],rendSet,rndtgt)
				dxDrawImageSection(iPosX,iPosY,iSizX,iSizY-iSizYPercent,0,sy2,sx2,sy2*(1-percent),indicatorImage[1],0,0,0,indicatorColor[2],rendSet,rndtgt)
			else
				dxDrawImage(iPosX,iPosY,iSizX,iSizYPercent,indicatorImage[1],0,0,0,indicatorColor[1],rendSet,rndtgt)
				dxDrawImage(iPosX,iSizYPercent+iPosY,iSizX,iSizY-iSizYPercent,iSizY,indicatorImage[2],0,0,0,indicatorColor[2],rendSet,rndtgt)
			end
		elseif isElement(indicatorImage) then
			if type(indicatorColor) == "table" then
				if indicatorMode then
					local sx,sy = eleData.indicatorUVSize[1],eleData.indicatorUVSize[2]
					if not sx or not sy then sx,sy = dxGetMaterialSize(indicatorImage) end
					dxDrawImageSection(iPosX,iPosY+iSizYPercentRev,iSizX,iSizYPercent,0,sy*(1-percent),sx,sy*percent,indicatorImage,0,0,0,indicatorColor[1],rendSet,rndtgt)
					dxDrawImageSection(iPosX,iPosY,iSizX,iSizY-iSizYPercent,0,sy,sx,sy*(1-percent),indicatorImage,0,0,0,indicatorColor[2],rendSet,rndtgt)
				else
					dxDrawImage(iPosX,iPosY+iSizYPercentRev,iSizX,iSizYPercent,indicatorImage,0,0,0,indicatorColor[1],rendSet,rndtgt)
					dxDrawImage(iPosX,iPosY,iSizX,iSizY-iSizYPercent,indicatorImage,0,0,0,indicatorColor[2],rendSet,rndtgt)
				end
			else
				if indicatorMode then
					local sx,sy = eleData.indicatorUVSize[1],eleData.indicatorUVSize[2]
					if not sx or not sy then sx,sy = dxGetMaterialSize(indicatorImage) end
					dxDrawImageSection(iPosX,iPosY,iSizX,iSizYPercent,0,0,sx,sy*percent,indicatorImage,0,0,0,indicatorColor,rendSet,rndtgt)
				else
					dxDrawImage(iPosX,iPosY,iSizX,iSizYPercent,indicatorImage,0,0,0,indicatorColor,rendSet,rndtgt)
				end
			end
		elseif type(indicatorColor) == "table" then
			dxDrawRectangle(iPosX,iPosY+iSizYPercentRev,iSizX,iSizYPercent,indicatorColor[1],rendSet)
			dxDrawRectangle(iPosX,iPosY,iSizX,iSizY-iSizYPercent,indicatorColor[2],rendSet)
		else
			dxDrawRectangle(iPosX,iPosY+iSizYPercentRev,iSizX,iSizYPercent,indicatorColor,rendSet)
		end
	end,
	["ring-round"] = function(source,x,y,w,h,bgImage,bgColor,indicatorImage,indicatorColor,indicatorMode,padding,percent)
		local eleData = dgsElementData[source]
		local styleData = eleData.styleData
		local circle = styleData.elements.circleShader
		local startPoint,endPoint = 0,percent
		dxSetShaderValue(circle,"progress",{styleData.isReverse and endPoint or startPoint,not styleData.isReverse and endPoint or startPoint})
		if startPoint == endPoint then
			dxSetShaderValue(circle,"indicatorColor",{0,0,0,0})
		else
			dxSetShaderValue(circle,"indicatorColor",{fromcolor(indicatorColor,true,true)})
		end
		dxSetShaderValue(circle,"thickness",styleData.thickness)
		dxSetShaderValue(circle,"radius",styleData.radius)
		dxSetShaderValue(circle,"antiAliased",styleData.antiAliased)
		dxDrawImage(x,y,w,h,circle,styleData.rotation,0,0,bgColor,rendSet,rndtgt)
	end,
}

function dgsCreateProgressBar(x,y,sx,sy,relative,parent,bgImage,bgColor,indicatorImage,indicatorColor,indicatorMode)
	local xCheck,yCheck,wCheck,hCheck = type (x) == "number",type(y) == "number",type(sx) == "number",type(sy) == "number"
	if not xCheck then assert(false,"Bad argument @dgsCreateProgressBar at argument 1, expect number got "..type(x)) end
	if not yCheck then assert(false,"Bad argument @dgsCreateProgressBar at argument 2, expect number got "..type(y)) end
	if not wCheck then assert(false,"Bad argument @dgsCreateProgressBar at argument 3, expect number got "..type(sx)) end
	if not hCheck then assert(false,"Bad argument @dgsCreateProgressBar at argument 4, expect number got "..type(sy)) end
	if isElement(bgImage) then
		local imgtyp = getElementType(bgImage)
		local imgCheck = imgtyp == "texture" or imgtyp == "shader"
		if not imgCheck then assert(false,"Bad argument @dgsCreateProgressBar at argument 7, expect texture got "..imgtyp) end
	end
	if isElement(indicatorImage) then
		local imgtyp = getElementType(indicatorImage)
		local imgCheck = imgtyp == "texture" or imgtyp == "shader"
		if not imgCheck then assert(false,"Bad argument @dgsCreateProgressBar at argument 9, expect texture got "..imgtyp) end
	end
	local progressbar = createElement("dgs-dxprogressbar")
	dgsSetType(progressbar,"dgs-dxprogressbar")
	dgsSetParent(progressbar,parent,true,true)
	local style = styleSettings.progressbar
	dgsElementData[progressbar] = {
		renderBuffer = {},
		bgColor = bgColor or style.bgColor,
		bgImage = bgImage or dgsCreateTextureFromStyle(style.bgImage),
		indicatorColor = indicatorColor or style.indicatorColor,
		indicatorImage = indicatorImage or dgsCreateTextureFromStyle(style.indicatorImage),
		indicatorMode = indicatorMode and true  or false,
		padding = style.padding,
		styleData = {},
		style = "normal-horizontal",
		progress = 0,
		map = {0,100},
	}
	calculateGuiPositionSize(progressbar,x,y,relative or false,sx,sy,relative or false,true)
	local mx,my = false,false
	if isElement(indicatorImage) then
		mx,my = dxGetMaterialSize(indicatorImage)
	end
	dgsElementData[progressbar].indicatorUVSize = {mx,my}
	triggerEvent("onDgsCreate",progressbar,sourceResource)
	return progressbar
end

function dgsProgressBarSetStyle(progressbar,style,settingTable)
	if type(progressbar) == "table" then
		for i=1,#progressbar do
			dgsProgressBarSetStyle(progressbar[i],style,settingTable)
		end
		return true
	end
	assert(dgsGetType(progressbar) == "dgs-dxprogressbar","Bad argument @dgsProgressBarSetStyle at argument 1, expect dgs-dxprogressbar got "..dgsGetType(progressbar))
	if ProgressBarStyle[style] then
		dgsSetData(progressbar,"style",style)
		for k,v in pairs(dgsElementData[progressbar].styleData.elements or {}) do
			destroyElement(v)
		end
		if style == "normal-horizontal" or style == "normal-vertical" then
			dgsSetData(progressbar,"styleData",{})
		elseif style == "ring-round" then
			dgsSetData(progressbar,"styleData",{})
			local styleData = dgsElementData[progressbar].styleData
			styleData.elements = {}
			styleData.elements.circleShader = dxCreateShader(ProgressBarShaders["ring-round"])
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
	assert(dgsGetType(progressbar) == "dgs-dxprogressbar","Bad argument @dgsProgressBarGetStyle at argument 1, expect dgs-dxprogressbar got "..dgsGetType(progressbar))
	return dgsElementData[progressbar].style
end
function dgsProgressBarGetStyleProperty(progressbar,propertyName)
	assert(dgsGetType(progressbar) == "dgs-dxprogressbar","Bad argument @dgsProgressBarGetStyleProperty at argument 1, expect dgs-dxprogressbar got "..dgsGetType(progressbar))
	return dgsElementData[progressbar].styleData[propertyName]
end

function dgsProgressBarGetStyleProperties(progressbar)
	assert(dgsGetType(progressbar) == "dgs-dxprogressbar","Bad argument @dgsProgressBarGetStyleProperties at argument 1, expect dgs-dxprogressbar got "..dgsGetType(progressbar))
	return dgsElementData[progressbar].styleData
end

function dgsProgressBarSetStyleProperty(progressbar,propertyName,value)
	assert(dgsGetType(progressbar) == "dgs-dxprogressbar","Bad argument @dgsProgressBarSetStyleProperty at argument 1, expect dgs-dxprogressbar got "..dgsGetType(progressbar))
	dgsElementData[progressbar].styleData[propertyName] = value
	return true
end

function dgsProgressBarGetProgress(progressbar,isAbsolute)
	assert(dgsGetType(progressbar) == "dgs-dxprogressbar","Bad argument @dgsProgressBarGetProgress at argument 1, expect dgs-dxprogressbar got "..dgsGetType(progressbar))
	local progress = dgsElementData[progressbar].progress
	local scaler = dgsElementData[progressbar].map
	if not isAbsolute then
		progress = progress/100*(scaler[2]-scaler[1])+scaler[1]
	end
	return progress
end

function dgsProgressBarSetProgress(progressbar,progress,isAbsolute)
	assert(dgsGetType(progressbar) == "dgs-dxprogressbar","Bad argument @dgsProgressBarSetProgress at argument 1, expect dgs-dxprogressbar got "..dgsGetType(progressbar))
	local scaler = dgsElementData[progressbar].map
	if progress < 0 then progress = 0 end
	if progress > 100 then progress = 100 end
	if not isAbsolute then
		progress = (progress-scaler[1])/(scaler[2]-scaler[1])*100
	end
	if progress < 0 then progress = 0 end
	if progress > 100 then progress = 100 end
	if dgsElementData[progressbar].progress ~= progress then
		dgsSetData(progressbar,"progress",progress)
	end
	return true
end

function dgsProgressBarSetMode(progressbar,mode)
	assert(dgsGetType(progressbar) == "dgs-dxprogressbar","Bad argument @dgsProgressBarSetindicatorMode at argument 1, expect dgs-dxprogressbar got "..dgsGetType(progressbar))
	return dgsSetData(progressbar,"indicatorMode",mode and true or false)
end

function dgsProgressBarGetMode(progressbar)
	assert(dgsGetType(progressbar) == "dgs-dxprogressbar","Bad argument @dgsProgressBarSetindicatorMode at argument 1, expect dgs-dxprogressbar got "..dgsGetType(progressbar))
	return dgsElementData[progressbar].indicatorMode
end

----------------Shader
ProgressBarShaders["ring-round"] = [[float borderSoft = 0.02;
float radius = 0.2;
float thickness = 0.02;
float2 progress = float2(0,0.1);
float4 indicatorColor = float4(0,1,1,1);
float PI2 = 6.283185;

float4 blend(float4 c1, float4 c2){
	float alp = c1.a+c2.a-c1.a*c2.a;
	float3 color = (c1.rgb*c1.a*(1.0-c2.a)+c2.rgb*c2.a)/alp;
	return float4(color,alp);
}

float4 myShader(float2 tex:TEXCOORD0,float4 color:COLOR0):COLOR0{
	float2 dxy = float2(length(ddx(tex)),length(ddy(tex)));
	float nBS = borderSoft*sqrt(dxy.x*dxy.y)*100;
	float4 bgColor = color;
	float4 inColor = 0;
	float2 texFixed = tex-0.5;
	float delta = clamp(1-(abs(length(texFixed)-radius)-thickness+nBS)/nBS,0,1);
	bgColor.a *= delta;
	float2 progFixed = progress*PI2;
	float angle = atan2(tex.y-0.5,0.5-tex.x)+0.5*PI2;
	bool tmp1 = angle>progFixed.x;
	bool tmp2 = angle<progFixed.y;
	float dis_ = distance(float2(cos(progFixed.x),-sin(progFixed.x))*radius,texFixed);
	float4 Color1,Color2;
	if(dis_<=thickness){
		float tmpDelta = clamp(1-(dis_-thickness+nBS)/nBS,0,1);
		Color1 = indicatorColor;
		inColor = indicatorColor;
		Color1.a *= tmpDelta;
	}
	dis_ = distance(float2(cos(progFixed.y),-sin(progFixed.y))*radius,texFixed);
	if(dis_<=thickness){
		float tmpDelta = clamp(1-(dis_-thickness+nBS)/nBS,0,1);
		Color2 = indicatorColor;
		inColor = indicatorColor;
		Color2.a *= tmpDelta;
	}
	inColor.a = max(Color1.a,Color2.a);
	if(progress.x>=progress.y){
		if(tmp1+tmp2){
			inColor = indicatorColor;
			inColor.a *= delta;
		}
	}else{
		if(tmp1*tmp2){
			inColor = indicatorColor;
			inColor.a *= delta;
		}
	}
	return blend(bgColor,inColor);
}

technique DrawCircle{
	pass P0	{
		PixelShader = compile ps_2_a myShader();
	}
}
]]

----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxprogressbar"] = function(source,x,y,w,h,mx,my,cx,cy,enabled,eleData,parentAlpha,isPostGUI,rndtgt)
	local bgImage = eleData.bgImage
	local bgColor = applyColorAlpha(eleData.bgColor,parentAlpha)
	local indicatorImage,indicatorColor = eleData.indicatorImage,eleData.indicatorColor
	if type(indicatorColor) == "table" then
		indicatorColor = {applyColorAlpha(indicatorColor[1],parentAlpha),applyColorAlpha(indicatorColor[2],parentAlpha)}
	else
		indicatorColor = applyColorAlpha(indicatorColor,parentAlpha)
	end
	local indicatorMode = eleData.indicatorMode
	local padding = eleData.padding
	local percent = eleData.progress*0.01
	ProgressBarStyle[eleData.style](source,x,y,w,h,bgImage,bgColor,indicatorImage,indicatorColor,indicatorMode,padding,percent,isPostGUI)
	return rndtgt
end