dgsLogLuaMemory()
dgsRegisterPluginType("dgs-dxblurbox")
local dxSetRenderTarget = dxSetRenderTarget
local dxSetShaderValue = dxSetShaderValue
local dxDrawImage = __dxDrawImage
local dxDrawImageSection = __dxDrawImageSection
BlurBoxGlobalScreenSource = false
blurboxShaders = 0
blurboxFactor = 1/2

function dgsBlurBoxDraw(x,y,w,h,self,rotation,rotationCenterOffsetX,rotationCenterOffsetY,color,postGUI)
	local eleData = dgsElementData[self]
	local bufferRTH = eleData.bufferRTH
	local bufferRTV = eleData.bufferRTV
	if bufferRTH and bufferRTV then
		local shader = eleData.shaders
		local resolution = eleData.resolution
		local renderSource
		local savedBlendMode = dxGetBlendMode()
		if eleData.blendMode then dxSetBlendMode(eleData.blendMode) end
		if not eleData.sourceTexture then
			local isUpdateScrSource = eleData.updateScreenSource
			if isUpdateScrSource then
				dxUpdateScreenSource(BlurBoxGlobalScreenSource,true)
			end
			renderSource = BlurBoxGlobalScreenSource
			dxSetShaderValue(shader[1],"screenSource",renderSource)
			dxSetRenderTarget(bufferRTH,true)
			dxDrawImageSection(0,0,resolution[1],resolution[2],x*blurboxFactor,y*blurboxFactor,w*blurboxFactor,h*blurboxFactor,shader[1],0,0,0,0xFFFFFFFF)
		else
			renderSource = eleData.sourceTexture
			dxSetShaderValue(shader[1],"screenSource",renderSource)
			dxSetRenderTarget(bufferRTH,true)
			dxDrawImage(0,0,resolution[1],resolution[2],shader[1],0,0,0,0xFFFFFFFF)
		end
		dxSetShaderValue(shader[2],"screenSource",bufferRTH)
		dxSetRenderTarget(bufferRTV,true)
		dxDrawImage(0,0,resolution[1],resolution[2],shader[2],0,0,0,0xFFFFFFFF)
		dxSetRenderTarget()
		local filter = eleData.filter
		if filter then
			dxSetShaderValue(filter,"sourceTexture",bufferRTV)
			dxSetShaderValue(filter,"textureLoad",true)
			dgsSetData(filter,"sourceTexture",bufferRTV)
			bufferRTV = filter
		end
		dxDrawImage(x,y,w,h,bufferRTV,0,0,0,color,postGUI or false)
		dxSetBlendMode(savedBlendMode)
	end
end

function dgsCreateBlurBox(w,h,sourceTexture)
	if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsCreateBlurBox",1,"number")) end
	if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsCreateBlurBox",2,"number")) end
	local bb = dgsCreateCustomRenderer(dgsBlurBoxDraw)
	if isElement(sourceTexture) then
		dgsSetData(bb,"sourceTexture",sourceTexture)
		dgsSetData(sourceTexture,"blurBox",bb)
	else
		if not isElement(BlurBoxGlobalScreenSource) then
			BlurBoxGlobalScreenSource = dxCreateScreenSource(sW*blurboxFactor,sH*blurboxFactor)
		end
	end
	local horz,vert = getBlurBoxShader(5)
	local shaderH = dxCreateShader(horz)
	local shaderV = dxCreateShader(vert)
	dgsAttachToAutoDestroy(shaderH,bb,-1)
	dgsAttachToAutoDestroy(shaderV,bb,-2)
	dgsSetData(bb,"asPlugin","dgs-dxblurbox")
	dgsSetData(bb,"shaders",{shaderH,shaderV})
	local bufferRTH = dgsCreateRenderTarget(w,h,true,bb)
	local bufferRTV = dgsCreateRenderTarget(w,h,true,bb)
	if bufferRTH then
		dxSetTextureEdge(bufferRTH,"mirror")
		dgsAttachToAutoDestroy(bufferRTH,bb,-3)
		dgsSetData(bb,"bufferRTH",bufferRTH)
	end
	if bufferRTV then
		dxSetTextureEdge(bufferRTV,"mirror")
		dgsAttachToAutoDestroy(bufferRTV,bb,-4)
		dgsSetData(bb,"bufferRTV",bufferRTV)
	end
	dgsSetData(bb,"intensity",1)
	dgsSetData(bb,"resolution",{w,h})
	dgsSetData(bb,"level",5)
	dgsSetData(bb,"blendMode","blend")
	blurboxShaders = blurboxShaders+1
	dgsTriggerEvent("onDgsPluginCreate",bb,sourceResource)
	return bb
end

function dgsBlurBoxSetFilter(bb,shader)
	if not(dgsGetPluginType(bb) == "dgs-dxblurbox") then error(dgsGenAsrt(bb,"dgsBlurBoxSetResolution",1,"dgs-dxblurbox")) end
	dgsSetData(bb,"filter",shader)
	return true
end

function dgsBlurBoxSetResolution(bb,w,h)
	if not(dgsGetPluginType(bb) == "dgs-dxblurbox") then error(dgsGenAsrt(bb,"dgsBlurBoxSetResolution",1,"dgs-dxblurbox")) end
	if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsBlurBoxSetResolution",2,"number")) end
	if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsBlurBoxSetResolution",3,"number")) end
	local shaders = dgsElementData[bb].shaders
	local bufferRTH = dgsElementData[bb].bufferRTH
	local bufferRTV = dgsElementData[bb].bufferRTV
	if isElement(bufferRTH) then destroyElement(bufferRTH) end
	if isElement(bufferRTV) then destroyElement(bufferRTV) end
	local bufferRTH = dgsCreateRenderTarget(w,h,true,bb)
	local bufferRTV = dgsCreateRenderTarget(w,h,true,bb)
	if bufferRTH then
		dxSetTextureEdge(bufferRTH,"mirror")
		dgsAttachToAutoDestroy(bufferRTH,bb,-3)
		dgsSetData(bb,"bufferRTH",bufferRTH)
	end
	if bufferRTV then
		dxSetTextureEdge(bufferRTV,"mirror")
		dgsAttachToAutoDestroy(bufferRTV,bb,-4)
		dgsSetData(bb,"bufferRTV",bufferRTV)
	end
	dgsSetData(bb,"resolution",{w,h})
	return true
end

function dgsBlurBoxSetIntensity(bb,intensity)
	if not(dgsGetPluginType(bb) == "dgs-dxblurbox") then error(dgsGenAsrt(bb,"dgsBlurBoxSetIntensity",1,"dgs-dxblurbox")) end
	if not(type(intensity) == "number") then error(dgsGenAsrt(intensity,"dgsBlurBoxSetIntensity",2,"number")) end
	local shaders = dgsElementData[bb].shaders
	dgsSetData(bb,"intensity",intensity)
	dxSetShaderValue(shaders[1],"intensity",intensity)
	dxSetShaderValue(shaders[2],"intensity",intensity)
	return true
end

function dgsBlurBoxSetLevel(bb,level)
	if not(dgsGetPluginType(bb) == "dgs-dxblurbox") then error(dgsGenAsrt(bb,"dgsBlurBoxSetLevel",1,"dgs-dxblurbox")) end
	local inRange = level>=0 and level <=15
	if not(type(level) == "number" and inRange) then error(dgsGenAsrt(level,"dgsBlurBoxSetLevel",2,"number","0~15",not inRange and "Out of range")) end
	local level = level-level%1
	local shaders = dgsElementData[bb].shaders
	destroyElement(shaders[1])
	destroyElement(shaders[2])
	local horz,vert = getBlurBoxShader(level)
	local shaderH = dxCreateShader(horz)
	local shaderV = dxCreateShader(vert)
	dgsAttachToAutoDestroy(shaderH,bb,1)
	dgsAttachToAutoDestroy(shaderV,bb,2)
	dxSetShaderValue(shaderH,"intensity",dgsElementData[bb].intensity)
	dxSetShaderValue(shaderV,"intensity",dgsElementData[bb].intensity)
	dgsSetData(bb,"shaders",{shaderH,shaderV})
	dgsSetData(bb,"level",level)
	return true
end

function dgsBlurBoxGetResolution(bb)
	if not(dgsGetPluginType(bb) == "dgs-dxblurbox") then error(dgsGenAsrt(bb,"dgsBlurBoxGetResolution",1,"dgs-dxblurbox")) end
	return dgsElementData[bb].resolution[1],dgsElementData[bb].resolution[2]
end

function dgsBlurBoxGetIntensity(bb)
	if not(dgsGetPluginType(bb) == "dgs-dxblurbox") then error(dgsGenAsrt(bb,"dgsBlurBoxGetIntensity",1,"dgs-dxblurbox")) end
	return dgsElementData[bb].intensity
end

function dgsBlurBoxGetLevel(bb)
	if not(dgsGetPluginType(bb) == "dgs-dxblurbox") then error(dgsGenAsrt(bb,"dgsBlurBoxGetLevel",1,"dgs-dxblurbox")) end
	return dgsElementData[bb].level
end

function dgsBlurBoxSetBrightness(bb,brt)
	if not(type(brt) == "number") then error(dgsGenAsrt(brt,"dgsBlurBoxSetBrightness",2,"number")) end
	if not(dgsGetPluginType(bb) == "dgs-dxblurbox") then error(dgsGenAsrt(bb,"dgsBlurBoxSetBrightness",1,"dgs-dxblurbox")) end
	local shaders = dgsElementData[bb].shaders
	dgsSetData(bb,"brightness",brt)
	dxSetShaderValue(shaders[1],"brightness",brt)
	dxSetShaderValue(shaders[2],"brightness",brt)
end

function dgsBlurBoxGetBrightness(bb)
	if not(dgsGetPluginType(bb) == "dgs-dxblurbox") then error(dgsGenAsrt(bb,"dgsBlurBoxGetBrightness",1,"dgs-dxblurbox")) end
	return dgsElementData[bb].brightness
end

function dgsBlurBoxSetTexture(bb,texture)
	if not(dgsGetPluginType(bb) == "dgs-dxblurbox") then error(dgsGenAsrt(bb,"dgsBlurBoxSetTexture",1,"plugin dgs-dxblurbox")) end
	return dgsSetData(bb,"sourceTexture",texture)
end

function dgsBlurBoxGetTexture(bb)
	if not(dgsGetPluginType(bb) == "dgs-dxblurbox") then error(dgsGenAsrt(bb,"dgsBlurBoxGetTexture",1,"plugin dgs-dxblurbox")) end
	return dgsElementData[bb].sourceTexture
end

dgsCustomTexture["dgs-dxblurbox"] = function(posX,posY,width,height,u,v,usize,vsize,image,rotation,rotationX,rotationY,color,postGUI)
	return dgsElementData[image].customRenderer(posX,posY,width,height,image,rotation,rotationX,rotationY,color,postGUI)
end

----------------Shader
function getBlurBoxShader(level)
	local blurBoxShaderHorizontal = [[
	texture screenSource;
	float intensity = 1;
	float brightness = 1;
	#define Level ]]..level..[[

	sampler2D Sampler0 = sampler_state{
		Texture  = screenSource;
		AddressU = Mirror;
		AddressV  = Mirror;
	};

	float4 HorizontalBlur( float2 tex : TEXCOORD0, float4 diffuse : COLOR0 ) : COLOR0{
		float4 Color = 0;
		float2 dx = ddx(tex);
		float2 dy = ddy(tex);
		float2 dd = float2(length(float2(dx.x,dy.x)),length(float2(dx.y,dy.y)));
		for(float i = -Level; i <= Level; i++)
			Color += tex2D(Sampler0,float2(tex.x+i*intensity*dd.x,tex.y))*(1-abs(i/Level))/Level*brightness;
		return Color*diffuse;
	}

	technique fxBlur{
		pass P0{
			PixelShader = compile ps_2_a HorizontalBlur();
		}
	}
	]]
	local blurBoxShaderVertical = [[
	texture screenSource;
	float intensity = 1;
	float brightness = 1;
	#define Level ]]..level..[[

	sampler2D Sampler0 = sampler_state{
		Texture  = screenSource;
		AddressU = Mirror;
		AddressV  = Mirror;
	};

	float4 VerticalBlur(float2 tex : TEXCOORD0, float4 diffuse : COLOR0 ) : COLOR0{
		float4 Color = 0;
		float2 dx = ddx(tex);
		float2 dy = ddy(tex);
		float2 dd = float2(length(float2(dx.x,dy.x)),length(float2(dx.y,dy.y)));
		for(float i = -Level; i <= Level; i++)
			Color += tex2D(Sampler0,float2(tex.x,tex.y+i*intensity*dd.y))*(1-abs(i/Level))/Level*brightness;
		return Color*diffuse;
	}

	technique fxBlur{
		pass P0{
			PixelShader = compile ps_2_a VerticalBlur();
		}
	}
	]]
	return blurBoxShaderHorizontal,blurBoxShaderVertical
end
