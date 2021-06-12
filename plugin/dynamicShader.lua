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
	})
	triggerEvent("onDgsPluginCreate",dynamicShader,sourceResource)
	
	return dynamicShader
end

function dgsDynamicShaderGenerate(dynamicShader)
	local shaderData = dgsElementData[dynamicShader].shaderData
	local shaderString = ""
	--Macros
	local macroString = ""
	for macroKey,macroValue in pairs(shaderData.macros) do
		macroString = macroString.."#define "..macroKey.." "..macroValue.."\n"
	end
	shaderString = shaderString..macroString
	--Constants
	local constantString = ""
	for name,constant in pairs(shaderData.consts) do
		constantString = constantString..constant.type.." "..name
		if constant.value == nil then
			constantString = constantString..";\n"
		else
			constantString = constantString.." = "..constant.value..";\n"
		end
	end
	shaderString = shaderString..constantString
	--Classes
	local classString = ""
	for name,class in pairs(shaderData.classes) do
		classString = classString..class.type.." "..name.."{\n"..class.data.."\n};"
	end
	shaderString = shaderString..classString
	--Functions
	local fncString = ""
	for name,fnc in pairs(shaderData.functions) do
		if fnc.register then
			fncString = fncString..fnc.type.." "..name.."("..fnc.argument.."):"..fnc.register.."{\n"..fnc.body.."\n};"
		else
			fncString = fncString..fnc.type.." "..name.."("..fnc.argument.."){\n"..fnc.body.."\n};"
		end
	end
	shaderString = shaderString..fncString
	--Techniques
	local techniqueString = ""
	for techniqueID,techniqueData in ipairs(shaderData.techniques) do
		local passString = ""
		for passID,passData in ipairs(techniqueData.passes) do
			--[[
			pass px{
				PixelShader = compile xxx
				VertexShader = compile xxx
				RenderState = 
			}
			]]
			passString = passString.."pass p"..passID.."{\n"
			for index,passSentence in ipairs(passData.item) do
				passString = passString..passSentence..";\n"
			end
			passString = passString.."}\n"
		end
		
		shaderString = shaderString.."\ntechnique "..techniqueData.name.."{\n"..passString.."}"
	end
	print(shaderString)
	return shaderString
end

function dgsDynamicShaderSetMacro(dynamicShader,key,value)
	local shaderData = dgsElementData[dynamicShader].shaderData
	local macros = shaderData.macros
	macros[key] = value
	return true
end

function dgsDynamicShaderSetConstant(dynamicShader,theType,constant,value)
	local shaderData = dgsElementData[dynamicShader].shaderData
	local consts = shaderData.consts
	consts[constant] = {type=theType,value=value}
	return true
end

function dgsDynamicShaderSetClass(dynamicShader,classType,className,classData)
	local shaderData = dgsElementData[dynamicShader].shaderData
	local classes = shaderData.classes
	classes[className] = {type=classType,data=classData}
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
	return newIndex
end

function dgsDynamicShaderSetFunction(dynamicShader,retType,functionName,args,functionBody,outputRegister)
	local shaderData = dgsElementData[dynamicShader].shaderData
	local functions = shaderData.functions
	functions[functionName] = {type=retType,argument=args,body=functionBody,register=outputRegister}
	return true
end

function dgsDynamicShaderRemoveTechnique(dynamicShader,techniqueName)
	
end

function dgsDynamicShaderGetTechniqueID(dynamicShader,techniqueName)
	local shaderData = dgsElementData[dynamicShader].shaderData
	local techniques = shaderData.techniques
	local id = table.find(techniques,techniqueName,"name")
	return id
end

function dgsDynamicShaderAddPassToTechnique(dynamicShader,techniqueID,passName,passPos)
	local shaderData = dgsElementData[dynamicShader].shaderData
	local shaderTechnique = shaderData.techniques[techniqueID]
	if shaderTechnique then
		local passes = shaderTechnique.passes
		local id = table.find(passes,passName,"name")
		if id then return false end
		local newIndex = passPos or (#passes+1)
		table.insert(passes,newIndex,{
			name = passName,
			item = {},
		})
		return newIndex
	end
	return false
end

function dgsDynamicShaderAddItemToPass(dynamicShader,techniqueID,passID,item)
	local shaderData = dgsElementData[dynamicShader].shaderData
	local shaderTechnique = shaderData.techniques[techniqueID]
	if shaderTechnique then
		local pass = shaderTechnique.passes[passID]
		if pass then
			local passItem = pass.item
			table.insert(passItem,item)
			return true
		end
	end
	return false
end

function dgsDynamicShaderFindPassFromTechnique(dynamicShader,techniqueID,passName)
	local shaderTechnique = shaderData.techniques[techniqueID]
	if shaderTechnique then
		local passes = shaderTechnique.passes
		

	end
end
--[[
local dynamicShader = dgsCreateDynamicShader()
dgsDynamicShaderSetConstant(dynamicShader,"texture","sourceTexture")
dgsDynamicShaderSetConstant(dynamicShader,"texture","maskTexture")
dgsDynamicShaderSetClass(dynamicShader,"SamplerState","sourceSampler",[[
	Texture = sourceTexture;
]])
dgsDynamicShaderSetClass(dynamicShader,"SamplerState","maskSampler",[[
	Texture = maskTexture;
]])
dgsDynamicShaderSetFunction(dynamicShader,"float4","texMask","float2 tex:TEXCOORD0,float4 color:COLOR0",[[
	float4 sourceColor = tex2D(sourceSampler,tex);
    float4 maskColor = tex2D(maskSampler,tex);
	sourceColor.a = (maskColor.r+maskColor.g+maskColor.b)/3.0f;
	return sourceColor*color;
]],"COLOR0")

local techniqueA = dgsDynamicShaderAddTechnique(dynamicShader,"texMaskTech")
local pass1 = dgsDynamicShaderAddPassToTechnique(dynamicShader,techniqueA,"Pass1")
dgsDynamicShaderAddItemToPass(dynamicShader,techniqueA,pass1,"PixelShader = compile ps_2_0 texMask()")
local shader = dxCreateShader(dgsDynamicShaderGenerate(dynamicShader))
print(shader)]]