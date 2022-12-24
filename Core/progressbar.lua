dgsLogLuaMemory()
dgsRegisterType("dgs-dxprogressbar","dgsBasic","dgsType2D")
dgsRegisterProperties("dgs-dxprogressbar",{
	bgColor = 			{	PArg.Color	},
	bgImage = 			{	PArg.Material+PArg.Nil	},
	indicatorColor = 	{	{ PArg.Color, PArg.Color }, PArg.Color	},
	indicatorImage = 	{	{ PArg.Material+PArg.Nil,PArg.Material+PArg.Nil }, PArg.Material+PArg.Nil	},
	indicatorMode = 	{	PArg.Bool	},
	map = 				{	{ PArg.Number, PArg.Number } },
	padding = 			{	{ PArg.Number, PArg.Number } },
	progress = 			{	PArg.Number },
	style = 			{	PArg.String },
	
	__Special = 		{	
		{	__Basis  = "style",
			["normal-horizontal"] = {},
			["normal-vertical"] = {},
			["ring-round"] = {
				isClockwise = 	{	PArg.Nil+PArg.Bool	},
				antiAliased = 	{	PArg.Number	},
				rotation = 		{	PArg.Number	},
				radius = 		{	PArg.Number	},
				thickness = 	{	PArg.Number	},
				bgRotation = 	{	PArg.Nil+PArg.Number	},
				bgRadius = 		{	PArg.Nil+PArg.Number	},
				bgThickness = 	{	PArg.Nil+PArg.Number	},
				bgProgress = 	{	PArg.Nil+PArg.Number	},
			},
			["ring-plain"] = {
				isClockwise = 	{	PArg.Nil+PArg.Bool	},
				rotation = 		{	PArg.Number	},
				antiAliased = 	{	PArg.Number	},
				radius = 		{	PArg.Number	},
				thickness = 	{	PArg.Number	},
				bgRotation = 	{	PArg.Nil+PArg.Number	},
				bgRadius = 		{	PArg.Nil+PArg.Number	},
				bgThickness = 	{	PArg.Nil+PArg.Number	},
				bgProgress = 	{	PArg.Nil+PArg.Number	},
			},
		},
	}
})
--Dx Functions
local dxDrawImage = dxDrawImage
local dxDrawImageSection = dxDrawImageSection
local dxDrawRectangle = dxDrawRectangle
local dxSetShaderValue = dxSetShaderValue
local dxSetRenderTarget = dxSetRenderTarget
local dxGetMaterialSize = dxGetMaterialSize
--DGS Functions
local dgsSetType = dgsSetType
local dgsGetType = dgsGetType
local dgsSetParent = dgsSetParent
local dgsSetData = dgsSetData
local applyColorAlpha = applyColorAlpha
local calculateGuiPositionSize = calculateGuiPositionSize
local dgsCreateTextureFromStyle = dgsCreateTextureFromStyle
--Utilities
local dgsTriggerEvent = dgsTriggerEvent
local createElement = createElement
local isElement = isElement
local assert = assert
local tonumber = tonumber
local type = type
local PI = math.pi
local PI2 = math.pi*2

ProgressBarShaders = {}
local ProgressBarStyle = {
	["normal-horizontal"] = function(source,x,y,w,h,bgImage,bgColor,indicatorImage,indicatorColor,indicatorMode,padding,percent,isPostGUI,hasRT)
		local eleData = dgsElementData[source]
		local iPosX,iPosY,iSizX,iSizY = x+padding[1],y+padding[2],w-padding[1]*2,h-padding[2]*2
		local iSizXPercent = iSizX*percent
		dxDrawImage(x,y,w,h,bgImage,0,0,0,bgColor,isPostGUI)
		if type(indicatorImage) == "table" then
			local indicatorColor1,indicatorColor2
			if type(indicatorColor) == "table" then
				indicatorColor1,indicatorColor2 = indicatorColor[1],indicatorColor[2]
			else
				indicatorColor1,indicatorColor2 = indicatorColor
			end
			if indicatorMode then
				local sx,sy = eleData.indicatorUVSize[1],eleData.indicatorUVSize[2]
				if not sx or not sy then
					sx1,sy1 = dxGetMaterialSize(indicatorImage[1])
					sx2,sy2 = dxGetMaterialSize(indicatorImage[2])
				else
					sx1,sy1,sx2,sy2 = sx,sy,sx,sy
				end
				dxDrawImageSection(iPosX,iPosY,iSizXPercent,iSizY,0,0,sx1*percent,sy1,indicatorImage[1],0,0,0,indicatorColor1,isPostGUI)
				dxDrawImageSection(iSizXPercent+iPosX,iPosY,iSizX-iSizXPercent,iSizY,sx2*percent,0,sx2*(1-percent),sy2,indicatorImage[1],0,0,0,indicatorColor2,isPostGUI)
			else
				dxDrawImage(iPosX,iPosY,iSizXPercent,iSizY,indicatorImage[1],0,0,0,indicatorColor1,isPostGUI)
				dxDrawImage(iSizXPercent+iPosX,iPosY,iSizX-iSizXPercent,iSizY,indicatorImage[2],0,0,0,indicatorColor2,isPostGUI)
			end
		elseif isElement(indicatorImage) then
			if type(indicatorColor) == "table" then
				if indicatorMode then
					local sx,sy = eleData.indicatorUVSize[1],eleData.indicatorUVSize[2]
					if not sx or not sy then sx,sy = dxGetMaterialSize(indicatorImage) end
					dxDrawImageSection(iPosX,iPosY,iSizXPercent,iSizY,0,0,sx*percent,sy,indicatorImage,0,0,0,indicatorColor[1],isPostGUI)
					dxDrawImageSection(iSizXPercent+iPosX,iPosY,iSizX-iSizXPercent,iSizY,sx*percent,0,sx*(1-percent),sy,indicatorImage,0,0,0,indicatorColor[2],isPostGUI)
				else
					dxDrawImage(iPosX,iPosY,iSizXPercent,iSizY,indicatorImage,0,0,0,indicatorColor[1],isPostGUI)
					dxDrawImage(iSizXPercent+iPosX,iPosY,iSizX-iSizXPercent,iSizY,indicatorImage,0,0,0,indicatorColor[2],isPostGUI)
				end
			else
				if indicatorMode then
					local sx,sy = eleData.indicatorUVSize[1],eleData.indicatorUVSize[2]
					if not sx or not sy then sx,sy = dxGetMaterialSize(indicatorImage) end
					dxDrawImageSection(iPosX,iPosY,iSizXPercent,iSizY,0,0,sx*percent,sy,indicatorImage,0,0,0,indicatorColor,isPostGUI)
				else
					dxDrawImage(iPosX,iPosY,iSizXPercent,iSizY,indicatorImage,0,0,0,indicatorColor,isPostGUI)
				end
			end
		elseif type(indicatorColor) == "table" then
			dxDrawRectangle(iPosX,iPosY,iSizXPercent,iSizY,indicatorColor[1],isPostGUI)
			dxDrawRectangle(iSizXPercent+iPosX,iPosY,iSizX-iSizXPercent,iSizY,indicatorColor[2],isPostGUI)
		else
			dxDrawRectangle(iPosX,iPosY,iSizXPercent,iSizY,indicatorColor,isPostGUI)
		end
	end,
	["normal-vertical"] = function(source,x,y,w,h,bgImage,bgColor,indicatorImage,indicatorColor,indicatorMode,padding,percent,isPostGUI,hasRT)
		local eleData = dgsElementData[source]
		local iPosX,iPosY,iSizX,iSizY = x+padding[1],y+padding[2],w-padding[1]*2,h-padding[2]*2
		local iSizYPercent = iSizY*percent
		local iSizYPercentRev = iSizY*(1-percent)
		dxDrawImage(x,y,w,h,bgImage,0,0,0,bgColor,isPostGUI)
		if type(indicatorImage) == "table" then
			local indicatorColor1,indicatorColor2
			if type(indicatorColor) == "table" then
				indicatorColor1,indicatorColor2 = indicatorColor[1],indicatorColor[2]
			else
				indicatorColor1,indicatorColor2 = indicatorColor
			end
			if indicatorMode then
				local sx,sy = eleData.indicatorUVSize[1],eleData.indicatorUVSize[2]
				if not sx or not sy then
					sx1,sy1 = dxGetMaterialSize(indicatorImage[1])
					sx2,sy2 = dxGetMaterialSize(indicatorImage[2])
				else
					sx1,sy1,sx2,sy2 = sx,sy,sx,sy
				end
				dxDrawImageSection(iPosX,iPosY+iSizYPercentRev,iSizX,iSizYPercent,0,sy1*(1-percent),sx1,sy1*percent,indicatorImage[1],0,0,0,indicatorColor1,isPostGUI)
				dxDrawImageSection(iPosX,iPosY,iSizX,iSizY-iSizYPercent,0,sy2,sx2,sy2*(1-percent),indicatorImage[1],0,0,0,indicatorColor2,isPostGUI)
			else
				dxDrawImage(iPosX,iPosY,iSizX,iSizYPercent,indicatorImage[1],0,0,0,indicatorColor1,isPostGUI)
				dxDrawImage(iPosX,iSizYPercent+iPosY,iSizX,iSizY-iSizYPercent,iSizY,indicatorImage[2],0,0,0,indicatorColor[2],isPostGUI)
			end
		elseif isElement(indicatorImage) then
			if type(indicatorColor) == "table" then
				if indicatorMode then
					local sx,sy = eleData.indicatorUVSize[1],eleData.indicatorUVSize[2]
					if not sx or not sy then sx,sy = dxGetMaterialSize(indicatorImage) end
					dxDrawImageSection(iPosX,iPosY+iSizYPercentRev,iSizX,iSizYPercent,0,sy*(1-percent),sx,sy*percent,indicatorImage,0,0,0,indicatorColor[1],isPostGUI)
					dxDrawImageSection(iPosX,iPosY,iSizX,iSizY-iSizYPercent,0,sy,sx,sy*(1-percent),indicatorImage,0,0,0,indicatorColor[2],isPostGUI)
				else
					dxDrawImage(iPosX,iPosY+iSizYPercentRev,iSizX,iSizYPercent,indicatorImage,0,0,0,indicatorColor[1],isPostGUI)
					dxDrawImage(iPosX,iPosY,iSizX,iSizY-iSizYPercent,indicatorImage,0,0,0,indicatorColor[2],isPostGUI)
				end
			else
				if indicatorMode then
					local sx,sy = eleData.indicatorUVSize[1],eleData.indicatorUVSize[2]
					if not sx or not sy then sx,sy = dxGetMaterialSize(indicatorImage) end
					dxDrawImageSection(iPosX,iPosY+iSizYPercentRev,iSizX,iSizYPercent,0,0,sx,sy*percent,indicatorImage,0,0,0,indicatorColor,isPostGUI)
				else
					dxDrawImage(iPosX,iPosY+iSizYPercentRev,iSizX,iSizYPercent,indicatorImage,0,0,0,indicatorColor,isPostGUI)
				end
			end
		elseif type(indicatorColor) == "table" then
			dxDrawRectangle(iPosX,iPosY+iSizYPercentRev,iSizX,iSizYPercent,indicatorColor[1],isPostGUI)
			dxDrawRectangle(iPosX,iPosY,iSizX,iSizY-iSizYPercent,indicatorColor[2],isPostGUI)
		else
			dxDrawRectangle(iPosX,iPosY+iSizYPercentRev,iSizX,iSizYPercent,indicatorColor,isPostGUI)
		end
	end,
	["ring-round"] = function(source,x,y,w,h,bgImage,bgColor,indicatorImage,indicatorColor,indicatorMode,padding,percent,isPostGUI,hasRT)
		local eleData = dgsElementData[source]
		local startPoint,endPoint = 0,percent
		local bgStartPoint,bgEndPoint = 0,eleData.bgProgress or 1
		if eleData.isClockwise then
			bgStartPoint,bgEndPoint = 1-bgEndPoint,1-bgStartPoint
			startPoint,endPoint = 1-endPoint,1-startPoint
		end
		local circle = eleData.elements.circleShader
		local circleBG = eleData.elements.circleShaderBG
		dxSetShaderValue(circle,"progress",startPoint,endPoint)
		if startPoint == endPoint then
			dxSetShaderValue(circle,"indicatorColor",0,0,0,0)
		else
			dxSetShaderValue(circle,"indicatorColor",fromcolor(indicatorColor,true))
		end
		dxSetShaderValue(circle,"thickness",eleData.thickness)
		dxSetShaderValue(circle,"radius",eleData.radius)
		dxSetShaderValue(circle,"antiAliased",eleData.antiAliased)
		
		dxSetShaderValue(circleBG,"progress",bgStartPoint,bgEndPoint)
		if bgStartPoint == bgEndPoint then
			dxSetShaderValue(circleBG,"indicatorColor",0,0,0,0)
		else
			dxSetShaderValue(circleBG,"indicatorColor",fromcolor(bgColor,true))
		end
		dxSetShaderValue(circleBG,"thickness",eleData.bgThickness or eleData.thickness)
		dxSetShaderValue(circleBG,"radius",eleData.bgRadius or eleData.radius)
		dxSetShaderValue(circleBG,"antiAliased",eleData.antiAliased)
		dxDrawImage(x,y,w,h,circleBG,eleData.bgRotation or eleData.rotation,0,0,0,isPostGUI)

		dxDrawImage(x,y,w,h,circle,eleData.rotation,0,0,0,isPostGUI)
	end,
	["ring-plain"] = function(source,x,y,w,h,bgImage,bgColor,indicatorImage,indicatorColor,indicatorMode,padding,percent,isPostGUI,hasRT)
		local eleData = dgsElementData[source]
		local circle = eleData.elements.circleShader
		local circleBG = eleData.elements.circleShaderBG
		local bgProgress = eleData.bgProgress or 1
		local progress = percent
		if eleData.isClockwise then
			bgProgress = 1-bgProgress
			progress = 1-progress
		end
		dxSetShaderValue(circleBG,"progress",bgProgress)
		dxSetShaderValue(circleBG,"isClockwise",eleData.isClockwise)
		dxSetShaderValue(circleBG,"indicatorColor",fromcolor(bgColor,true))
		dxSetShaderValue(circleBG,"thickness",eleData.bgThickness or eleData.thickness)
		dxSetShaderValue(circleBG,"radius",eleData.bgRadius or eleData.radius)
		dxSetShaderValue(circleBG,"antiAliased",eleData.antiAliased)
		dxDrawImage(x,y,w,h,circleBG,eleData.bgRotation or eleData.rotation,0,0,0,isPostGUI)
		
		dxSetShaderValue(circle,"progress",progress)
		dxSetShaderValue(circle,"isClockwise",eleData.isClockwise)
		dxSetShaderValue(circle,"indicatorColor",fromcolor(indicatorColor,true))
		dxSetShaderValue(circle,"thickness",eleData.thickness)
		dxSetShaderValue(circle,"radius",eleData.radius)
		dxSetShaderValue(circle,"antiAliased",eleData.antiAliased)
		dxDrawImage(x,y,w,h,circle,eleData.rotation,0,0,0,isPostGUI)
	end,
}

function dgsCreateProgressBar(...)
	local sRes = sourceResource or resource
	local x,y,w,h,relative,parent,bgImage,bgColor,indicatorImage,indicatorColor,indicatorMode
	if select("#",...) == 1 and type(select(1,...)) == "table" then
		local argTable = ...
		x = argTable.x or argTable[1]
		y = argTable.y or argTable[2]
		w = argTable.width or argTable.w or argTable[3]
		h = argTable.height or argTable.h or argTable[4]
		relative = argTable.relative or argTable.rlt or argTable[5]
		parent = argTable.parent or argTable.p or argTable[6]
		bgImage = argTable.bgImage or argTable[7]
		bgColor = argTable.bgColor or argTable[8]
		indicatorImage = argTable.indicatorImage or argTable[9]
		indicatorColor = argTable.indicatorColor or argTable[10]
		indicatorMode = argTable.indicatorMode or argTable[11]
	else
		x,y,w,h,relative,parent,bgImage,bgColor,indicatorImage,indicatorColor,indicatorMode = ...
	end
	if not(type(x) == "number") then error(dgsGenAsrt(x,"dgsCreateProgressBar",1,"number")) end
	if not(type(y) == "number") then error(dgsGenAsrt(y,"dgsCreateProgressBar",2,"number")) end
	if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsCreateProgressBar",3,"number")) end
	if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsCreateProgressBar",4,"number")) end
	if isElement(bgImage) then
		if not isMaterial(bgImage) then error(dgsGenAsrt(bgImage,"dgsCreateProgressBar",7,"texture")) end
	end
	if isElement(indicatorImage) then
		if not isMaterial(indicatorImage) then error(dgsGenAsrt(indicatorImage,"dgsCreateProgressBar",9,"material")) end
	end
	local progressbar = createElement("dgs-dxprogressbar")
	dgsSetType(progressbar,"dgs-dxprogressbar")
	
	local res = sRes ~= resource and sRes or "global"
	local style = styleManager.styles[res]
	local using = style.using
	style = style.loaded[using]
	
	style = style.progressbar
	dgsElementData[progressbar] = {
		renderBuffer = {},
		bgColor = bgColor or style.bgColor,
		bgImage = bgImage or dgsCreateTextureFromStyle(using,res,style.bgImage),
		indicatorColor = indicatorColor or style.indicatorColor,
		indicatorImage = indicatorImage or dgsCreateTextureFromStyle(using,res,style.indicatorImage),
		indicatorMode = indicatorMode and true or false,
		padding = style.padding,
		style = "normal-horizontal",
		progress = 0,
		map = {0,100},
	}
	dgsSetParent(progressbar,parent,true,true)
	calculateGuiPositionSize(progressbar,x,y,relative or false,w,h,relative or false,true)
	local mx,my = false,false
	if isElement(indicatorImage) then
		mx,my = dxGetMaterialSize(indicatorImage)
	end
	dgsElementData[progressbar].indicatorUVSize = {mx,my}
	onDGSElementCreate(progressbar,sRes)
	return progressbar
end

function dgsProgressBarSetStyle(progressbar,style,settingTable)
	if type(progressbar) == "table" then
		for i=1,#progressbar do
			dgsProgressBarSetStyle(progressbar[i],style,settingTable)
		end
		return true
	end
	if not dgsIsType(progressbar,"dgs-dxprogressbar") then error(dgsGenAsrt(progressbar,"dgsProgressBarSetStyle",1,"dgs-dxprogressbar")) end
	if ProgressBarStyle[style] then
		dgsSetData(progressbar,"style",style)
		local eleData = dgsElementData[progressbar]
		for k,v in pairs(eleData.elements or {}) do
			destroyElement(v)
		end
		if style == "normal-horizontal" or style == "normal-vertical" then
		elseif style == "ring-round" then
			eleData.elements = {}
			eleData.elements.circleShader = dxCreateShader(ProgressBarShaders["ring-round"])
			eleData.elements.circleShaderBG = dxCreateShader(ProgressBarShaders["ring-round"])
			eleData.isClockwise = false
			eleData.antiAliased = 0.005
			eleData.rotation = 0
			eleData.radius = 0.2
			eleData.thickness = 0.02
			eleData.bgRotation = nil
			eleData.bgRadius = nil
			eleData.bgThickness = nil
			eleData.bgProgress = nil
		elseif style == "ring-plain" then
			eleData.elements = {}
			eleData.elements.circleShader = dxCreateShader(ProgressBarShaders["ring-plain"])
			eleData.elements.circleShaderBG = dxCreateShader(ProgressBarShaders["ring-plain"])
			eleData.isClockwise = false
			eleData.rotation = 0
			eleData.antiAliased = 0.005
			eleData.radius = 0.2
			eleData.thickness = 0.02
			eleData.bgRotation = nil
			eleData.bgRadius = nil
			eleData.bgThickness = nil
			eleData.bgProgress = nil
		end
		for k,v in pairs(settingTable or {}) do
			dgsElementData[progressbar][k] = v
		end
		return true
	end
	return false
end

function dgsProgressBarGetStyle(progressbar)
	if not dgsIsType(progressbar,"dgs-dxprogressbar") then error(dgsGenAsrt(progressbar,"dgsProgressBarGetStyle",1,"dgs-dxprogressbar")) end
	return dgsElementData[progressbar].style
end

function dgsProgressBarGetProgress(progressbar,isAbsolute)
	if not dgsIsType(progressbar,"dgs-dxprogressbar") then error(dgsGenAsrt(progressbar,"dgsProgressBarGetProgress",1,"dgs-dxprogressbar")) end
	local progress = dgsElementData[progressbar].progress
	local scaler = dgsElementData[progressbar].map
	if not isAbsolute then
		progress = progress/100*(scaler[2]-scaler[1])+scaler[1]
	end
	return progress
end

function dgsProgressBarSetProgress(progressbar,progress,isAbsolute)
	if not dgsIsType(progressbar,"dgs-dxprogressbar") then error(dgsGenAsrt(progressbar,"dgsProgressBarSetProgress",1,"dgs-dxprogressbar")) end
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
	if not dgsIsType(progressbar,"dgs-dxprogressbar") then error(dgsGenAsrt(progressbar,"dgsProgressBarSetMode",1,"dgs-dxprogressbar")) end
	return dgsSetData(progressbar,"indicatorMode",mode and true or false)
end

function dgsProgressBarGetMode(progressbar)
	if not dgsIsType(progressbar,"dgs-dxprogressbar") then error(dgsGenAsrt(progressbar,"dgsProgressBarGetMode",1,"dgs-dxprogressbar")) end
	return dgsElementData[progressbar].indicatorMode
end

----------------Shader
ProgressBarShaders["ring-round"] = [[
#define PI2 6.283185307179586476925286766559
float borderSoft = 0.02;
float radius = 0.2;
float thickness = 0.02;
float2 progress = float2(0,0.1);
float4 indicatorColor = float4(1,1,1,1);

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
		//Solve Render Issues
		SeparateAlphaBlendEnable = true;
		SrcBlendAlpha = One;
		DestBlendAlpha = InvSrcAlpha;
		PixelShader = compile ps_2_a myShader();
	}
}
]]

ProgressBarShaders["ring-plain"] = [[
#define PI2 6.283185307179586476925286766559
float4 indicatorColor = float4(1,1,1,1);
float borderSoft = 0.02;
float progress = PI2;
float radius = 0.2;
float thickness = 0.02;
bool isClockwise = false; //antiClockwise

float4 blend(float4 c1, float4 c2){
	float alp = c1.a+c2.a-c1.a*c2.a;
	float3 color = (c1.rgb*c1.a*(1.0-c2.a)+c2.rgb*c2.a)/alp;
	return float4(color,alp);
}

float4 circleShader(float2 tex:TEXCOORD0,float4 color:COLOR0):COLOR0{
	float4 result = indicatorColor;
	float4 bgColor = color;
	float2 dxy = float2(length(ddx(tex)),length(ddy(tex)));
	float nBS = borderSoft*sqrt(dxy.x*dxy.y)*100;
	float xDistance = tex.x-0.5,yDistance = 0.5-tex.y;
	float angle_p = atan2(yDistance,xDistance);	//angle_p
	float delta = clamp(1-(abs(length(float2(xDistance,yDistance))-radius)-thickness+nBS)/nBS,0,1);
	if(angle_p>PI2) angle_p -= PI2;
	if(angle_p<0) angle_p += PI2;
	float2 P = float2(xDistance,yDistance);
	float angle = progress*PI2;
	float2 Q = float2(cos(angle),sin(angle));
	float2 N = float2(-Q.y,Q.x)*nBS;
	float oRadius = 1-(radius+thickness);
	Q *= oRadius;
	float2 Start = float2(oRadius,0);
	float2 StartN = float2(-Start.y,Start.x);
	float alpha = isClockwise;
	if(angle_p<angle) alpha = !isClockwise;
	if(!isClockwise){
		float2 P1 = P-N;
		float len0P = length(P1);
		float len0Q = length(Q);
		float lenPQ = distance(P1,Q);
		float a = dot(Q,P1)/(len0Q*len0P);
		float halfC1 = 0.5*(len0P+len0Q+lenPQ);
		float dis1 = 2*sqrt(halfC1*(halfC1-len0P)*(halfC1-len0Q)*(halfC1-lenPQ))/len0Q;
		float _a = dot(N,P1)/(nBS*len0P);
		P.y += nBS;
		len0P = length(P);
		float len0S = oRadius;
		float lenPS = distance(P,Start);
		float b = dot(Start,P)/(len0S*len0P);
		float halfC2 = 0.5*(len0P+len0S+lenPS);
		float dis2 = 2*sqrt(halfC2*(halfC2-len0P)*(halfC2-len0S)*(halfC2-lenPS))/len0S;
		float _b = dot(StartN,P)/(length(StartN)*len0P);
		if(a >= 0 && dis1 < nBS && _a<=0) alpha = max(alpha,clamp(dis1/nBS,0,1));
		if(b >= 0 && dis2 < nBS && _b>=0) alpha = max(alpha,clamp(dis2/nBS,0,1));
	}else{
		float2 P1 = P+N;
		float len0P = length(P1);
		float len0Q = length(Q);
		float lenPQ = distance(P1,Q);
		float a = dot(Q,P1)/(len0Q*len0P);
		float halfC1 = 0.5*(len0P+len0Q+lenPQ);
		float dis1 = 2*sqrt(halfC1*(halfC1-len0P)*(halfC1-len0Q)*(halfC1-lenPQ))/len0Q;
		float _a = dot(N,P1)/(nBS*len0P);
		P.y -= nBS;
		len0P = length(P);
		float len0S = oRadius;
		float lenPS = distance(P,Start);
		float b = dot(Start,P)/(len0S*len0P);
		float halfC2 = 0.5*(len0P+len0S+lenPS);
		float dis2 = 2*sqrt(halfC2*(halfC2-len0P)*(halfC2-len0S)*(halfC2-lenPS))/len0S;
		float _b = dot(StartN,P)/(length(StartN)*len0P);
		if(a >= 0 && dis1 < nBS && _a>=0) alpha = max(alpha,clamp(dis1/nBS,0,1));
		if(b >= 0 && dis2 < nBS && _b<=0) alpha = max(alpha,clamp(dis2/nBS,0,1));
	}
	alpha *= clamp((1-distance(tex,0.5)-oRadius)/nBS,0,1);
	alpha *= clamp((distance(tex,0.5)-radius+thickness)/nBS,0,1);
	result.a *= clamp(alpha,0,1);
	bgColor.a *= delta;
	return blend(bgColor,result);
}

technique circleTechnique{
	pass p0{
		//Solve Render Issues
		SeparateAlphaBlendEnable = true;
		SrcBlendAlpha = One;
		DestBlendAlpha = InvSrcAlpha;
		PixelShader = compile ps_2_a circleShader();
	}
}
]]

----------------------------------------------------------------
-----------------------PropertyListener-------------------------
----------------------------------------------------------------
dgsOnPropertyChange["dgs-dxprogressbar"] = {
	progress = function(dgsEle,key,value,oldValue)
		dgsTriggerEvent("onDgsProgressBarChange",dgsEle,value,oldValue)
	end
}
----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxprogressbar"] = function(source,x,y,w,h,mx,my,cx,cy,enabledInherited,enabledSelf,eleData,parentAlpha,rendSet,rndtgt)
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
	dxSetBlendMode("blend")
	ProgressBarStyle[eleData.style](source,x,y,w,h,bgImage,bgColor,indicatorImage,indicatorColor,indicatorMode,padding,percent,rendSet,rndtgt)
	return rndtgt,false,mx,my,0,0
end