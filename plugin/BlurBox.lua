BlurBoxGlobalScreenSource = false
blurboxShaders = 0
blurboxFactor = 1/2
local blurBoxShader 

function _dgsCreateBlurBox()
	if not getElementData(localPlayer,"DGS-DEBUG-C") then
		outputDebugString("Deprecated usage of function @dgsCreateBlurBox, please check wiki, and run it again with command /debugdgs c",2)
	else
		assert(false,"Deprecated usage of function @dgsCreateBlurBox")
	end
	if not isElement(BlurBoxGlobalScreenSource) then
		BlurBoxGlobalScreenSource = dxCreateScreenSource(sW*blurboxFactor,sH*blurboxFactor)
	end
	local shader = dxCreateShader(blurBoxShader)
	dgsSetData(shader,"asPlugin","dgs-dxblurbox")
	dxSetShaderValue(shader,"screenSource",BlurBoxGlobalScreenSource)
	blurboxShaders = blurboxShaders+1
	triggerEvent("onDgsPluginCreate",shader,sourceResource)
	return shader
end

function dgsBlurBoxRender(blurBox,x,y,w,h,postGUI,updateScreenSource)
	if updateScreenSource then
		dxUpdateScreenSource(BlurBoxGlobalScreenSource,true)
	end
	dxDrawImageSection(x,y,w,h,x*blurboxFactor,y*blurboxFactor,w*blurboxFactor,h*blurboxFactor,blurBox,0,0,0,0xFFFFFFFF,postGUI or false)
end

----------------Shader
blurBoxShader = [[
texture screenSource;
float brightness = 1;

sampler2D Sampler0 = sampler_state{
    Texture         = screenSource;
    MinFilter       = Linear;
    MagFilter       = Linear;
    MipFilter       = Linear;
    AddressU        = Mirror;
    AddressV        = Mirror;
};

float4 PixelShaderFunction(float2 tex : TEXCOORD0, float4 diffuse : COLOR0 ) : COLOR0{
    float4 Color = 0;
    float4 Texel = tex2D(Sampler0,tex);
    for(int i = -3; i <= 3; i++)
		for(int j = -3; j <= 3; j++)
			Color += tex2D(Sampler0,tex+float2(i*ddx(tex.x),j*ddy(tex.y))) *(1.0/49.0)*brightness;
    Color.a *= diffuse.a;
	return Color;
}

technique fxBlur{
    pass P0{
        PixelShader = compile ps_2_a PixelShaderFunction();
    }
}
]]

function dgsBlurBoxDraw(x,y,w,h,self,rotation,rotationCenterOffsetX,rotationCenterOffsetY,color,postGUI)
	local isUpdateScrSource = dgsElementData[self].updateScreenSource
	if isUpdateScrSource then
		dxUpdateScreenSource(BlurBoxGlobalScreenSource,true)
	end
	local rt = dgsElementData[self].rt
	local shader = dgsElementData[self].shaders
	local box = BlurBoxGlobalScreenSource
	local resolution = dgsElementData[self].resolution
	dxSetRenderTarget(rt)
	dxSetShaderValue(shader[1],"screenSource",BlurBoxGlobalScreenSource)
	dxDrawImageSection(0,0,resolution[1],resolution[2],x*blurboxFactor,y*blurboxFactor,w*blurboxFactor,h*blurboxFactor,shader[1],0,0,0,0xFFFFFFFF)
	dxSetRenderTarget()
	dxSetShaderValue(shader[2],"screenSource",rt)
	dxDrawImageSection(x,y,w,h,0,0,resolution[1],resolution[2],shader[2],0,0,0,0xFFFFFFFF,postGUI or false)
end

function dgsCreateBlurBox(w,h,blursource)
	if not w and not h then
		return _dgsCreateBlurBox()
	end
	local bb = dgsCreateCustomRenderer(dgsBlurBoxDraw)
	if isElement(blursource) then
		dgsSetData(bb,"blurSource",blursource)
	else
		if not isElement(BlurBoxGlobalScreenSource) then
			BlurBoxGlobalScreenSource = dxCreateScreenSource(sW*blurboxFactor,sH*blurboxFactor)
		end
	end
	local horz,vert = getBlurBoxShader(5)
	local shaderH = dxCreateShader(horz)
	local shaderV = dxCreateShader(vert)
	dgsAttachToAutoDestroy(shaderH,bb,1)
	dgsAttachToAutoDestroy(shaderV,bb,2)
	dgsSetData(bb,"asPlugin","dgs-dxblurbox")
	dgsSetData(bb,"shaders",{shaderH,shaderV})
	local rt = dxCreateRenderTarget(w,h,true,bb)
	dgsAttachToAutoDestroy(rt,bb,3)
	dgsSetData(bb,"rt",rt)
	dgsSetData(bb,"intensity",1)
	dgsSetData(bb,"resolution",{w,h})
	dgsSetData(bb,"level",5)
	blurboxShaders = blurboxShaders+1
	triggerEvent("onDgsPluginCreate",bb,sourceResource)
	return bb
end

function dgsBlurBoxSetResolution(bb,w,h)
	assert(dgsGetPluginType(bb) == "dgs-dxblurbox","Bad argument @dgsBlurBoxSetResolution at argument 1, expect dgs-dxblurbox got "..dgsGetPluginType(bb))
	assert(type(w) == "number","Bad argument @dgsBlurBoxSetResolution at argument 2, expect number got "..dgsGetPluginType(w))
	assert(type(h) == "number","Bad argument @dgsBlurBoxSetResolution at argument 3, expect number got "..dgsGetPluginType(h))
	local shaders = dgsElementData[bb].shaders
	local rt = dgsElementData[bb].rt
	if isElement(rt) then destroyElement(rt) end
	local rt = dxCreateRenderTarget(w,h,true,bb)
	dgsAttachToAutoDestroy(rt,bb,3)
	dgsSetData(bb,"resolution",{w,h})
	dgsSetData(bb,"rt",rt)
	return true
end

function dgsBlurBoxSetIntensity(bb,intensity)
	assert(dgsGetPluginType(bb) == "dgs-dxblurbox","Bad argument @dgsBlurBoxSetIntensity at argument 1, expect dgs-dxblurbox got "..dgsGetPluginType(bb))
	assert(type(intensity) == "number","Bad argument @dgsBlurBoxSetIntensity at argument 2, expect number got "..dgsGetPluginType(intensity))
	local shaders = dgsElementData[bb].shaders
	dgsSetData(bb,"intensity",intensity)
	dxSetShaderValue(shaders[1],"intensity",intensity)
	dxSetShaderValue(shaders[2],"intensity",intensity)
	return true
end

function dgsBlurBoxSetLevel(bb,level)
	assert(dgsGetPluginType(bb) == "dgs-dxblurbox","Bad argument @dgsBlurBoxSetLevel at argument 1, expect dgs-dxblurbox got "..dgsGetPluginType(bb))
	assert(type(level) == "number","Bad argument @dgsBlurBoxSetLevel at argument 2, expect number got "..dgsGetPluginType(intensity))
	assert(level>=0 and level <=15,"Bad argument @dgsBlurBoxSetLevel at argument 2, expect number in 0~15, got "..level.." (out of range)")
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
	dgsSetData(bb,"updateScreenSource",false)
	return true
end

function dgsBlurBoxGetResolution(bb)
	assert(dgsGetPluginType(bb) == "dgs-dxblurbox","Bad argument @dgsBlurBoxSetResolution at argument 1, expect dgs-dxblurbox got "..dgsGetPluginType(bb))
	return dgsElementData[bb].resolution[1],dgsElementData[bb].resolution[2]
end

function dgsBlurBoxGetIntensity(bb,level)
	assert(dgsGetPluginType(bb) == "dgs-dxblurbox","Bad argument @dgsBlurBoxGetIntensity at argument 1, expect dgs-dxblurbox got "..dgsGetPluginType(bb))
	return dgsElementData[bb].intensity
end

function dgsBlurBoxGetLevel(bb,level)
	assert(dgsGetPluginType(bb) == "dgs-dxblurbox","Bad argument @dgsBlurBoxGetLevel at argument 1, expect dgs-dxblurbox got "..dgsGetPluginType(bb))
	return dgsElementData[bb].level
end

----------------Shader
function getBlurBoxShader(level)
	local blurBoxShaderHorizontal = [[
	texture screenSource;
	float intensity = 1;
	#define Level ]]..level..[[
	
	#define Brightness 1.0/(Level*2+1)
	sampler2D Sampler0 = sampler_state{
		Texture         = screenSource;
		AddressU        = Mirror;
		AddressV        = Mirror;
	};
	
	float blur(float i){
		return (1-abs(i/Level))/Level;
	}

	float4 HorizontalBlur(float2 tex : TEXCOORD0, float4 diffuse : COLOR0 ) : COLOR0{
		float4 Color = 0;
		for(int i = -Level; i <= Level; i++)
			Color += tex2D(Sampler0,float2(tex.x+i*intensity*ddx(tex.x),tex.y))*blur(i);
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
	#define Level ]]..level..[[
	
	#define Brightness 1.0/(Level*2+1)
	sampler2D Sampler0 = sampler_state{
		Texture         = screenSource;
		AddressU        = Mirror;
		AddressV        = Mirror;
	};
	
	float blur(float i){
		return (1-abs(i/Level))/Level;
	}

	float4 VerticalBlur(float2 tex : TEXCOORD0, float4 diffuse : COLOR0 ) : COLOR0{
		float4 Color = 0;
		for(int i = -Level; i <= Level; i++)
			Color += tex2D(Sampler0,float2(tex.x,tex.y+i*intensity*ddy(tex.y)))*blur(i);
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