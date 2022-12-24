dgsLogLuaMemory()
dgsRegisterPluginType("dgs-dxdynamicshader")
dgsGlobalShaderTemplate = {}

function dgsCreateDynamicShader()
	local dynamicShader = createElement("dgs-dxdynamicshader")
	dgsSetData(dynamicShader,"asPlugin","dgs-dxdynamicshader")
	dgsSetData(dynamicShader,"shaderData",{
		macros = {},
		consts = {},
		classes = {},
		functions = {},
		techniques = {},
		mainRenderFunction = nil,
	})
	dgsSetData(dynamicShader,"regenerateNeeded",true)
	dgsSetData(dynamicShader,"shader",false)
	dgsTriggerEvent("onDgsPluginCreate",dynamicShader,sourceResource)
	return dynamicShader
end

function dgsDynamicShaderGenerate(dynamicShader)
	local shaderData = dgsElementData[dynamicShader].shaderData
	local shaderString = ""
	--Macros
	local macroString = "//-----------Macros\n"
	for macroKey,macroValue in pairs(shaderData.macros) do
		macroString = macroString.."#define "..macroKey.." "..macroValue.."\n"
	end
	shaderString = shaderString..macroString.."\n"
	--Constants
	local constantString = "//-----------Constants\n"
	for name,constant in pairs(shaderData.consts) do
		constantString = constantString..constant.type.." "..name
		if constant.value == nil then
			constantString = constantString..";\n"
		else
			constantString = constantString.." = "..constant.value..";\n"
		end
	end
	shaderString = shaderString..constantString.."\n"
	--Classes
	local classString = "//-----------Classes\n"
	classString = classString..[[
struct PSInput{
    float4 Position : POSITION0;
    float2 TexCoord : TEXCOORD0;
    float2 PixPos : TEXCOORD1;
    float4 UvToView : TEXCOORD2;
    float4 Diffuse : COLOR0;
};

struct VSInput{
    float3 Position : POSITION0;
    float2 TexCoord : TEXCOORD0;
    float4 Diffuse : COLOR0;
};
]]	--Default PSInput
	for name,class in pairs(shaderData.classes) do
		classString = classString..class.type.." "..name.."{\n"..class.data.."\n};\n\n"
	end
	shaderString = shaderString..classString.."\n"
	--Functions
	local fncString = "//-----------Functions\n"
	for name,fnc in pairs(shaderData.functions) do
		if fnc.register then
			fncString = fncString..fnc.type.." "..name.."("..fnc.argument.."):"..fnc.register.."{\n"..fnc.body.."};\n\n"
		else
			fncString = fncString..fnc.type.." "..name.."("..fnc.argument.."){\n"..fnc.body.."};\n\n"
		end
	end
	shaderString = shaderString..fncString.."\n"
	--Main Render (If Enabled)
	local mainRenderFunction = shaderData.mainRenderFunction
	if mainRenderFunction then
		local fncString = "//-----------Main Render Function\n"
		fncString = fncString.."float4 Main(PSInput PS):COLOR0{\n"
		for index,fncName in ipairs(mainRenderFunction) do
			fncString = fncString.."	PS = "..fncName.."(PS);\n"
		end
		fncString = fncString.."	return PS.Diffuse;\n"
		fncString = fncString.."}\n"
		shaderString = shaderString..fncString.."\n"
	end
	--Techniques
	local techniqueString = "//-----------Techniques\n"
	for techniqueID,techniqueData in ipairs(shaderData.techniques) do
		local passString = ""
		for passID,passData in ipairs(techniqueData.passes) do
			local pX = passID-1
			--[[
			pass px{
				PixelShader = compile xxx
				VertexShader = compile xxx
				RenderState = xxx
			}
			]]
			passString = passString.."	pass p"..pX.."{\n"
			for index,passSentence in ipairs(passData) do
				passString = passString.."		"..passSentence[1].." = "..passSentence[2]..";\n"
			end
			passString = passString.."	}\n"
		end
		techniqueString = techniqueString.."technique "..techniqueData.name.."{\n"..passString.."}"
	end
	shaderString = shaderString..techniqueString
	return shaderString
end

function dgsDynamicShaderSetMacro(dynamicShader,key,value)
	local shaderData = dgsElementData[dynamicShader].shaderData
	local macros = shaderData.macros
	macros[key] = value
	shaderData.regenerateNeeded = true
	return true
end

function dgsDynamicShaderSetConstant(dynamicShader,theType,constant,value)
	local shaderData = dgsElementData[dynamicShader].shaderData
	local consts = shaderData.consts
	consts[constant] = {type=theType,value=value}
	shaderData.regenerateNeeded = true
	return true
end

function dgsDynamicShaderSetClass(dynamicShader,classType,className,classData)
	local shaderData = dgsElementData[dynamicShader].shaderData
	local classes = shaderData.classes
	classes[className] = {type=classType,data=classData}
	shaderData.regenerateNeeded = true
	return true
end

function dgsDynamicShaderAddTechnique(dynamicShader,techniqueName)
	local shaderData = dgsElementData[dynamicShader].shaderData
	local techniques = shaderData.techniques
	local id = table.find(techniques,techniqueName,"name")
	if id then return false end
	local newIndex = #techniques+1
	techniques[newIndex] = {
		name = techniqueName,
		passes = {},
	}
	shaderData.regenerateNeeded = true
	return newIndex
end

function dgsDynamicShaderRemoveTechnique(dynamicShader,techniqueName)
	local shaderData = dgsElementData[dynamicShader].shaderData
	local techniques = shaderData.techniques
	local id = table.find(techniques,techniqueName,"name")
	if id then
		table.remove(techniques,id)
		return true
	end
	shaderData.regenerateNeeded = true
	return newIndex
end

function dgsDynamicShaderSetFunction(dynamicShader,retType,functionName,args,functionBody,outputRegister)
	local shaderData = dgsElementData[dynamicShader].shaderData
	local functions = shaderData.functions
	functions[functionName] = {type=retType,argument=args,body=functionBody,register=outputRegister}
	shaderData.regenerateNeeded = true
	return true
end

function dgsDynamicShaderRemoveFunction(dynamicShader,functionName)
	local shaderData = dgsElementData[dynamicShader].shaderData
	local functions = shaderData.functions
	functions[functionName] = nil
	shaderData.regenerateNeeded = true
	return true
end

function dgsDynamicShaderAddFunctionToMain(dynamicShader,functionName)
	local shaderData = dgsElementData[dynamicShader].shaderData
	shaderData.mainRenderFunction = shaderData.mainRenderFunction or {}
	local functions = shaderData.mainRenderFunction
	table.insert(functions,functionName)
	shaderData.regenerateNeeded = true
	return true
end

function dgsDynamicShaderRemoveFunctionFromMain(dynamicShader,functionName)
	local shaderData = dgsElementData[dynamicShader].shaderData
	shaderData.mainRenderFunction = shaderData.mainRenderFunction or {}
	local functions = shaderData.mainRenderFunction
	local id = table.find(functions,functionName)
	if id then
		table.remove(functions,id)
	end
	shaderData.regenerateNeeded = true
	return true
end

function dgsDynamicShaderGetTechniqueID(dynamicShader,techniqueName)
	local shaderData = dgsElementData[dynamicShader].shaderData
	local techniques = shaderData.techniques
	local id = table.find(techniques,techniqueName,"name")
	shaderData.regenerateNeeded = true
	return id
end

function dgsDynamicShaderAddPassToTechnique(dynamicShader,techniqueID)
	local shaderData = dgsElementData[dynamicShader].shaderData
	local shaderTechnique = shaderData.techniques[techniqueID]
	if shaderTechnique then
		local passes = shaderTechnique.passes
		local newIndex = #passes+1
		passes[newIndex] = {}
		shaderData.regenerateNeeded = true
		return newIndex
	end
	return false
end

function dgsDynamicShaderSetPassValue(dynamicShader,techniqueID,passID,variaible,value)
	local shaderData = dgsElementData[dynamicShader].shaderData
	local shaderTechnique = shaderData.techniques[techniqueID]
	if shaderTechnique then
		if shaderTechnique.passes then
			local pass = shaderTechnique.passes[passID]
			if pass then
				table.insert(pass,{variaible,value})
				shaderData.regenerateNeeded = true
				return true
			end
		end
	end
	return false
end

dgsCustomTexture["dgs-dxdynamicshader"] = function(posX,posY,width,height,u,v,usize,vsize,dynamicShader,rotation,rotationX,rotationY,color,postGUI)
	local shaderData = dgsElementData[dynamicShader].shaderData
	if shaderData.regenerateNeeded then
		if isElement(shaderData.shader) then destroyElement(shaderData.shader) end
		shaderData.shader = dxCreateShader(dgsDynamicShaderGenerate(dynamicShader))
		if not shaderData.shader then
			outputDebugString("[DGS]Failed to generate dynamic shader")
		end
		shaderData.regenerateNeeded = false
	end
	if shaderData.shader then
		__dxDrawImage(posX,posY,width,height,shaderData.shader,rotation,rotationX,rotationY,color,postGUI)
	end
	return true
end

-- local dynamicShader = dgsCreateDynamicShader()
-- dgsDynamicShaderSetFunction(dynamicShader,"PSInput","texMask1","PSInput PS",
-- [[
	-- PS.Diffuse.r = PS.TexCoord.x;
	-- return PS;
-- ]])

-- dgsDynamicShaderSetFunction(dynamicShader,"PSInput","texMask2","PSInput PS",
-- [[
	-- PS.Diffuse.g = 1-PS.TexCoord.x;
	-- return PS;
-- ]])
-- dgsDynamicShaderAddFunctionToMain(dynamicShader,"texMask1")
-- dgsDynamicShaderAddFunctionToMain(dynamicShader,"texMask2")

-- local techniqueA = dgsDynamicShaderAddTechnique(dynamicShader,"texMaskTech")
-- local pass = dgsDynamicShaderAddPassToTechnique(dynamicShader,techniqueA)
-- dgsDynamicShaderSetPassValue(dynamicShader,techniqueA,pass,"PixelShader","compile ps_2_0 Main()")

-- setTimer(function()
	-- local memo = dgsCreateMemo(300,300,500,500,dgsDynamicShaderGenerate(dynamicShader),false)
	-- dgsSetAlpha({memo,123},1)
	-- dgsCreateImage(100,300,200,200,dynamicShader,false)
	-- setTimer(function()
		-- dgsDynamicShaderRemoveFunctionFromMain(dynamicShader,"texMask1")
	-- end,2000,1)
-- end,50,1)