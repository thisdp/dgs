dgsLogLuaMemory()
local loadstring = loadstring
-------------------------------------------------Parent/Layer Manager
--Speed Up
local tableInsert = table.insert
local tableRemove = table.remove
local tableFind = table.find
local isElement = isElement
local assert = assert
local tostring = tostring
local tonumber = tonumber
local type = type
local mathMin = math.min
local mathMax = math.max
local mathClamp = math.clamp
local getElementType = getElementType
-------------------------------------------------------Table Defines
--Animations
animQueue = {}
--Render Info
dgsRenderInfo = {
	frames = 0,
	RTRestoreNeed = false,
	renderingResource = {},
}
--Render Settings
dgsRenderSetting = {
	postGUI = false,
	renderPriority = "normal",
}
--Render Functions
dgsRenderer = {}
dgsChildRenderer = {}
dgs3DRenderer = {}
dgsCustomTexture = {}
dgsBackEndRenderer = {
	register = function(self,dgsType,theFunction)
		self[dgsType] = theFunction
	end,
}
--Collider
dgsCollider = {
	default = function(source,mx,my,x,y,w,h)
		if mx >= x and mx <= x+w and my >= y and my <= y+h then
			return source
		end
	end,
}
--Visibility
dgsOnVisibilityChange = {}
--Plugin System
dgsPluginTable = {}
--Parent System
BackEndTable = {}			--Store Back-end Render Element (If it has back-end renderer)
BottomFatherTable = {}		--Store Bottom Father Element
CenterFatherTable = {}		--Store Center Father Element (Default)
TopFatherTable = {}			--Store Top Father Element
dgsWorld3DTable = {}
dgsScreen3DTable = {}
LayerCastTable = {center=CenterFatherTable,top=TopFatherTable,bottom=BottomFatherTable}
--
--Element Data System
dgsElementData = {[resourceRoot] = {}}		----The Global BuiltIn DGS Element Data Table
--Property List
dgsElementPropertyList = {}					----The Registered exported property list
--
--Element Type
dgsElementType = {}
--
--TranslationUpdater
dgsOnTranslationUpdate = {
	default = function(dgsEle,key,value)
		local text = dgsElementData[dgsEle]._translation_text
		local translationListener = dgsElementData[dgsEle].translationListener
		if text then
			if key then
				text[key] = value
			elseif translationListener then
				for key,value in pairs(translationListener) do
					text[key] = value
				end
			end
			dgsSetData(dgsEle,"text",text)
		end
		local font = dgsElementData[dgsEle]._translation_font
		if font then
			dgsSetData(dgsEle,"font",font)
		end
	end,
}
--
--Plugin Creation Manager
addEventHandler("onDgsPluginCreate",resourceRoot,function(theResource)
	insertResource(theResource,source)
	local typ = dgsElementData[source].asPlugin
	dgsPluginTable[typ] = dgsPluginTable[typ] or {}
	table.insert(dgsPluginTable[typ],source)
	addEventHandler("onDgsDestroy",source,function()
		local id = table.find(dgsPluginTable[typ],source)
		if id then
			table.remove(dgsPluginTable[typ],id)
		end
	end,false)
end)

--------------------------------------------------------Layer System
function dgsSetLayer(dgsEle,layer,forceDetatch)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsSetLayer",1,"dgs-dxelement")) end
	if dgsElementType[dgsEle] == "dgs-dxtab" then return false end
	if not(layerBuiltIn[layer]) then error(dgsGenAsrt(layer,"dgsSetLayer",2,"string","top/center/bottom")) end
	local parent = dgsElementData[dgsEle].parent
	local hasParent = isElement(parent)
	if hasParent and not forceDetatch then return false end
	if hasParent then
		local id = tableFind(dgsElementData[parent].children,dgsEle)
		if id then
			tableRemove(dgsElementData[parent].children,id)
		end
		dgsElementData[dgsEle].parent = nil
	end
	local oldLayer = dgsElementData[dgsEle].alwaysOn or "center"
	if oldLayer == layer then return false end
	local id = tableFind(LayerCastTable[oldLayer],dgsEle)
	if id then
		tableRemove(LayerCastTable[oldLayer],id)
	end
	dgsSetData(dgsEle,"alwaysOn",layer == "center" and false or layer)
	tableInsert(LayerCastTable[layer],dgsEle)
	return true
end

function dgsGetLayer(dgsEle)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsGetLayer",1,"dgs-dxelement")) end
	return dgsElementData[dgsEle].alwaysOn or "center"
end

function dgsSetCurrentLayerIndex(dgsEle,index)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsSetCurrentLayerIndex",1,"dgs-dxelement")) end
	if not(type(index) == "number") then error(dgsGenAsrt(index,"dgsSetCurrentLayerIndex",2,"number")) end
	local layer = dgsElementData[dgsEle].alwaysOn or "center"
	local parent = dgsElementData[dgsEle].parent
	local theTable = isElement(parent) and dgsElementData[parent].children or LayerCastTable[layer]
	local index = mathClamp(index,1,#theTable+1)
	local id = tableFind(theTable,dgsEle)
	if id then
		tableRemove(theTable,id)
	end
	tableInsert(theTable,index,dgsEle)
	return true
end

function dgsGetCurrentLayerIndex(dgsEle)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsGetCurrentLayerIndex",1,"dgs-dxelement")) end
	local layer = dgsElementData[dgsEle].alwaysOn or "center"
	local parent = dgsElementData[dgsEle].parent
	local theTable = isElement(parent) and dgsElementData[parent].children or LayerCastTable[layer]
	return tableFind(theTable,dgsEle) or false
end

function dgsGetLayerElements(layer)
	if not(layerBuiltIn[layer]) then error(dgsGenAsrt(layer,"dgsGetLayerElements",1,"string","top/center/bottom")) end
	return #LayerCastTable[layer] or false
end

function dgsGetElementsInLayer(layer)
	if layer == true or layer:lower() == "bottom" then
		return BottomFatherTable
	elseif layer:lower() == "top" then
		return TopFatherTable
	else
		return CenterFatherTable
	end
end

function dgsGetElementsFromResource(res)
	local res = res or sourceResource
	if res == "all" then
		local serialized,cnt = {},0
		for r,storeTable in pairs(boundResource) do
			for k,v in pairs(boundResource[r] or {}) do
				cnt = cnt+1
				serialized[cnt] = k
			end
		end
		return serialized
	else
		local serialized,cnt = {},0
		for k,v in pairs(boundResource[res] or {}) do
			cnt = cnt+1
			serialized[cnt] = k
		end
		return serialized
	end
	return false
end

function dgsGetChild(dgsEle,id)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsGetChild",1,"dgs-dxelement")) end
	if not(type(id) == "number") then error(dgsGenAsrt(id,"dgsGetChild",2,"number")) end
	if dgsElementData[dgsEle].children then
		return dgsElementData[dgsEle].children[id] or false
	end
	return false
end

function dgsGetChildren(dgsEle)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsGetChildren",1,"dgs-dxelement")) end
	return dgsElementData[dgsEle].children or {}
end

function dgsGetParent(dgsEle)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsGetParent",1,"dgs-dxelement")) end
	return dgsElementData[dgsEle] and dgsElementData[dgsEle].parent or false
end

function dgsSetParent(child,newParent,nocheckfather,noUpdatePosSize)
	if newParent == resourceRoot then newParent = nil end
	if not(dgsIsType(child)) then error(dgsGenAsrt(child,"dgsSetParent",1,"dgs-dxelement")) end
	if not(not dgsElementData[child] or not dgsElementData[child].attachTo) then error(dgsGenAsrt(child,"dgsSetParent",1,_,_,_,"attached dgs element can not have a parent")) end
	if not dgsElementData[child] then dgsElementData[child] = {} end
	local oldParent = dgsElementData[child].parent
	local parentTable = isElement(oldParent) and dgsElementData[oldParent].children or CenterFatherTable
	if isElement(newParent) then
		if not dgsIsType(newParent) then return end
		if not nocheckfather then
			local id = tableFind(parentTable,child)
			if id then
				tableRemove(parentTable,id)
			end
		end
		dgsElementData[child].parent = newParent
		if not dgsElementData[newParent].children then dgsElementData[newParent].children = {} end
		tableInsert(dgsElementData[newParent].children,child)
		setElementParent(child,newParent)
	else
		local id = tableFind(parentTable,child)
		if id then
			tableRemove(parentTable,id)
		end
		dgsElementData[child].parent = nil
		tableInsert(CenterFatherTable,child)
		setElementParent(child,resourceRoot)
	end
	---Update Position and Size
	if not noUpdatePosSize then
		local rlt = dgsElementData[child].relative
		local pos = rlt[1] and dgsElementData[child].rltPos or dgsElementData[child].absPos
		local size = rlt[2] and dgsElementData[child].rltSize or dgsElementData[child].absSize
		calculateGuiPositionSize(child,pos[1],pos[2],rlt[1] and true or false,size[1],size[2],rlt[2] and true or false)
	end
	if dgsElementType[child] == "dgs-dxscrollpane" then
		local scrollbars = (dgsElementData[child] or {}).scrollbars
		if scrollbars then
			dgsSetParent(scrollbars[1],newParent)
			dgsSetParent(scrollbars[2],newParent)
			configScrollPane(child)
		end
	end
	return true
end

function blurEditMemo(dgsEle)
	local dgsType = dgsGetType(dgsEle or MouseData.focused)
	if dgsType == "dgs-dxedit" then
		guiBlur(GlobalEdit)
		if not dgsElementData[GlobalEdit] then dgsElementData[GlobalEdit] = {} end
		dgsElementData[GlobalEdit].linkedDxEdit = nil
	elseif dgsType == "dgs-dxmemo" then
		guiBlur(GlobalMemo)
		if not dgsElementData[GlobalMemo] then dgsElementData[GlobalMemo] = {} end
		dgsElementData[GlobalMemo].linkedDxMemo = nil
	end
end

function dgsBringToFront(dgsEle,mouse,dontMoveParent,dontFocus)
	local eleType = dgsIsType(dgsEle)
	if not(eleType) then error(dgsGenAsrt(dgsEle,"dgsBringToFront",1,"dgs-dxelement")) end
	local parent = dgsElementData[dgsEle].parent	--Get Parent
	if not dontFocus then dgsFocus(dgsEle) end
	if dgsElementData[dgsEle].changeOrder then
		if not isElement(parent) then
			if dgsTypeScreen3D[eleType] then
				local id = tableFind(dgsScreen3DTable,dgsEle)
				if id then
					tableRemove(dgsScreen3DTable,id)
					tableInsert(dgsScreen3DTable,dgsEle)
				end
			elseif dgsTypeWorld3D[eleType] then
				local id = tableFind(dgsWorld3DTable,dgsEle)
				if id then
					tableRemove(dgsWorld3DTable,id)
					tableInsert(dgsWorld3DTable,dgsEle)
				end
			else
				local layer = dgsElementData[dgsEle].alwaysOn or "center"
				local layerTable = LayerCastTable[layer]
				local id = tableFind(layerTable,dgsEle)
				if id then
					tableRemove(layerTable,id)
					tableInsert(layerTable,dgsEle)
				end
			end
		else
			local parents = dgsEle
			while true do
				local uparents = dgsElementData[parents].parent	--Get Parent
				local eleType = dgsIsType(uparents)
				if isElement(uparents) then
					local children = dgsElementData[uparents].children
					local id = tableFind(children,parents)
					if id then
						tableRemove(children,id)
						tableInsert(children,parents)
						if dgsElementType[parents] == "dgs-dxscrollpane" then
							local scrollbar = dgsElementData[parents].scrollbars
							dgsBringToFront(scrollbar[1],"left",_,true,false)
							dgsBringToFront(scrollbar[2],"left",_,true,false)
						end
					end
					parents = uparents
				else
					if dgsTypeScreen3D[eleType] then
						local id = tableFind(dgsScreen3DTable,parents)
						if id then
							tableRemove(dgsScreen3DTable,id)
							tableInsert(dgsScreen3DTable,parents)
						end
						break
					elseif dgsTypeWorld3D[eleType] then
						local id = tableFind(dgsWorld3DTable,parents)
						if id then
							tableRemove(dgsWorld3DTable,id)
							tableInsert(dgsWorld3DTable,parents)
						end
						break
					else
						local layer = dgsElementData[parents].alwaysOn or "center"
						local layerTable = LayerCastTable[layer]
						local id = tableFind(layerTable,parents)
						if id then
							tableRemove(layerTable,id)
							tableInsert(layerTable,parents)
							if dgsElementType[parents] == "dgs-dxscrollpane" then
								local scrollbar = dgsElementData[parents].scrollbars
								dgsBringToFront(scrollbar[1],"left",_,true,false)
								dgsBringToFront(scrollbar[2],"left",_,true,false)
							end
						end
						break
					end
				end
				if dontMoveParent then
					break
				end
			end
		end
	end
	if mouse == "left" then
		MouseData.click.left = dgsEle
		if not MouseData.hitData2D[0] and MouseData.hitData3D[0] and MouseData.hitData3D[5] then
			MouseData.lock3DInterface = MouseData.hitData3D[5]
		end
		MouseData.clickData = nil
	elseif mouse == "right" then
		MouseData.click.right = dgsEle
	end
	return true
end

function dgsMoveToBack(dgsEle)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsMoveToBack",1,"dgs-dxelement")) end
	if dgsElementData[dgsEle].changeOrder then
		local parent = dgsElementData[dgsEle].parent	--Get Parent
		if isElement(parent) then
			local children = dgsElementData[parent].children
			local id = tableFind(children,dgsEle)
			if id then
				tableRemove(children,id)
				tableInsert(children,1,dgsEle)
				return true
			end
			return false
		else
			local layer = dgsElementData[dgsEle].alwaysOn or "center"
			local layerTable = LayerCastTable[layer]
			local id = tableFind(layerTable,dgsEle)
			if id then
				tableRemove(layerTable,id)
				tableInsert(layerTable,1,dgsEle)
				return true
			end
			return false
		end
	end
end

------------------------------------------------Type Manager
dgsType,dgsPluginType = {},{}

---Userdata Type
MTAUserDataType = {
	["resource-data"] = true,
	["xml-node"] = true,
	["lua-timer"] = true,
	["vector2"] = true,
	["vector3"] = true,
	["vector4"] = true,
	["matrix"] = true,
}

function dgsRegisterType(typeName,...)
	for i=1,select("#",...) do
		local tag = select(i,...)
		if not _G[tag] then _G[tag] = {} end
		_G[tag][typeName] = typeName
	end
	dgsType[typeName] = typeName
	return true
end

function dgsRegisterPluginType(typeName)
	dgsPluginType[typeName] = typeName
end

function dgsGetType(dgsEle,dgsTypeOnly)
	if dgsTypeOnly then
		if isElement(dgsEle) then return dgsElementType[dgsEle],dgsType[dgsElementType[dgsEle] or ""] end
	else
		if isElement(dgsEle) then return tostring(dgsElementType[dgsEle] or getElementType(dgsEle)) end
		local theType = type(dgsEle)
		if theType == "userdata" then
			local userdataType = getUserdataType(dgsEle)
			if MTAUserDataType[userdataType] then
				return userdataType
			else
				return "destroyed element"
			end
		end
		return theType
	end
	return false
end

function dgsIsType(dgsEle,isType)
	if isType then
		if isElement(dgsEle) then
			local eleData = dgsElementData[dgsEle]
			if isType == (eleData and eleData.asPlugin) then return true end
			if isType == dgsElementType[dgsEle] then return true end
			if _G[isType] and _G[isType][dgsElementType[dgsEle]] then return true end
			return getElementType(dgsEle) == isType
		else
			return type(dgsEle) == isType
		end
	else
		if not isElement(dgsEle) then return false end
		local eleData = dgsElementData[dgsEle]
		if eleData and eleData.asPlugin then
			return dgsPluginType[eleData.asPlugin]
		end
		return dgsType[dgsElementType[dgsEle] or getElementType(dgsEle)]
	end
	return false
end

function dgsGetPluginType(dgsEle) return dgsEle and (dgsElementData[dgsEle] and dgsElementData[dgsEle].asPlugin or false) or dgsGetType(dgsEle) end

function dgsSetType(dgsEle,myType)
	if isElement(dgsEle) and type(myType) == "string" then
		dgsElementType[dgsEle] = myType
		return true
	end
	return false
end

function dgsRegisterDeprecatedFunction(fncNameOld,fncNameNew)
	_G[fncNameOld] = function(...)
		if not getElementData(resourceRoot,"DGS-enableCompatibilityCheck") then
			if not getElementData(localPlayer,"DGS-DEBUG-C") then
				outputDebugString("Deprecated function @'"..fncNameOld.."', replace with '"..fncNameNew.."'. See information below, or run again with command /debugdgs c",2)
				if getElementData(localPlayer,"DGS-DEBUG") == 3 then
					dgsTriggerEvent("DGSI_onDebug",sourceResourceRoot or resourceRoot,"FunctionCompatibility",fncNameOld,fncNameNew)
				end
			else
				if getElementData(localPlayer,"DGS-DEBUG") == 3 then
					dgsTriggerEvent("DGSI_onDebug",sourceResourceRoot or resourceRoot,"FunctionCompatibility",fncNameOld,fncNameNew)
				end
				error("Found deprecated function @'"..fncNameOld.."', replace with '"..fncNameNew.."'")
			end
		end
		return _G[fncNameNew](...)
	end
end

------------------------------------------------Property Manager
dgsOnPropertyChange = {
	["default"] = {
		text = function(dgsEle,key,value,oldValue)
			if type(value) == "table" then
				dgsElementData[dgsEle]._translation_text = value
				value = dgsTranslate(dgsEle,value,sourceResource)
			else
				dgsElementData[dgsEle]._translation_text = nil
			end
			dgsElementData[dgsEle].text = tostring(value)
			dgsTriggerEvent("onDgsTextChange",dgsEle)
		end,
		font = function(dgsEle,key,value,oldValue)
			--Multilingual
			if type(value) == "table" then
				dgsElementData[dgsEle]._translation_font = value
				value = dgsGetTranslationFont(dgsEle,value,sourceResource)
			else
				dgsElementData[dgsEle]._translation_font = nil
			end
			dgsElementData[dgsEle].font = value
		end,
		caption = function(dgsEle,key,value,oldValue)
			if type(value) == "table" then
				dgsElementData[dgsEle]._translation_text = value
				value = dgsTranslate(dgsEle,value,sourceResource)
			else
				dgsElementData[dgsEle]._translation_text = nil
			end
			dgsElementData[dgsEle].caption = tostring(value)
		end,
		ignoreParentTitle = function(dgsEle,key,value,oldValue)
			configPosSize(dgsEle,false,true)
		end,
		ignoreTitle = function(dgsEle,key,value,oldValue)
			local children = dgsGetChildren(dgsEle)
			for i=1,#children do
				if not dgsElementData[children[i]].ignoreParentTitle then
					configPosSize(children[i],false,true)
					if dgsElementType[children[i]] == "dgs-dxscrollpane" then
						configScrollPane(children[i])
					end
				end
			end
		end,
		asPlugin = function(dgsEle,key,value,oldValue)
			dgsRegisterPluginType(value)
		end,
	},
}
--------------Edit/Memo Blur Check
function GlobalEditMemoBlurCheck()
	local dxChild = source == GlobalEdit and dgsElementData[source].linkedDxEdit or dgsElementData[source].linkedDxMemo
	if isElement(dxChild) and MouseData.focused == dxChild then
		dgsBlur(dxChild,true)
	end
end

--[[
{}: table with item checked
1:nil
2:number
4:bool
8.string
16.table without item checked
32.font
64.material
128.color
]]
PArg = {
	"Nil",
	"Number",
	"Bool",
	"String",
	"Table",
	"Font",
	"Material",
	"Color",
	"Text",
}
for i=1,#PArg do
	PArg[ PArg[i] ] = 2^(i-1)
end

function dgsRegisterProperty(eleType,propertyName,propertyArgTemplate)
	if not(type(eleType) == "string") then error(dgsGenAsrt(eleType,"dgsRegisterProperty",1,"string")) end
	if not(type(propertyName) == "string") then error(dgsGenAsrt(propertyName,"dgsRegisterProperty",2,"string")) end
	if not(type(propertyArgTemplate) == "table") then error(dgsGenAsrt(propertyArgTemplate,"dgsRegisterProperty",3,"table")) end
	if _G[eleType] then
		for eleType in pairs(_G[eleType]) do
			dgsRegisterProperty(eleType,propertyName,propertyArgTemplate)
		end
	else
		if not dgsElementPropertyList[eleType] then dgsElementPropertyList[eleType] = {} end
		dgsElementPropertyList[eleType][propertyName] = propertyArgTemplate
	end
	return true
end

function dgsRegisterProperties(eleType,propertyList)
	if not(type(eleType) == "string") then error(dgsGenAsrt(eleType,"dgsRegisterProperties",1,"string")) end
	if not(type(propertyList) == "table") then error(dgsGenAsrt(propertyList,"dgsRegisterProperties",2,"table")) end
	if _G[eleType] then
		for eleType in pairs(_G[eleType]) do
			dgsRegisterProperties(eleType,propertyList)
		end
	else
		if not dgsElementPropertyList[eleType] then dgsElementPropertyList[eleType] = {} end
		for propertyName,propertyArgTemplate in pairs(propertyList) do
			dgsElementPropertyList[eleType][propertyName] = propertyArgTemplate
		end
	end
	return true
end

function dgsListPropertyTypes(propertyTemplateValue)
	if type(propertyTemplateValue) ~= "number" then return type(propertyTemplateValue) end
	local pTypeList = {}
	local index = 0
	while(propertyTemplateValue ~= 0) do
		index = index+1
		local pType = propertyTemplateValue%2
		propertyTemplateValue = math.floor(propertyTemplateValue/2)
		if pType == 1 then
			pTypeList[#pTypeList+1] = PArg[index]
		end
	end
	return pTypeList
end

function dgsCheckPropertyByTemplate(propertyTemplate,propretyValue)
	-- todo
end

function dgsCheckProperty(dgsElement,propertyName,propertyValue)
	local eleType = dgsElementType[dgsElement]
	local propertyCheck = dgsElementPropertyList[eleType]
	if not propertyCheck then return true end
	if propertyCheck[propertyName] then
		return dgsCheckPropertyByTemplate(propertyCheck[propertyName],propertyValue)
	else
		local specialProperties = propertyCheck.__Special
		if not propertyCheck.__Special then return true end
		for i=1,#specialProperties do
			local specialProperty = specialProperties[i]
			local basis = specialProperty.__Basis
			if basis then
				local basisData = dgsElementData[eleType][basis]
				if basisData then
					if specialProperty[basisData] then
						return dgsCheckPropertyByTemplate(specialProperty[basisData][propertyName],propertyValue)
					end
				end
			end
		end
	end
	return true
end

function dgsGetRegisteredProperties(eleType,withArgTemplate)
	if not(type(eleType) == "string") then error(dgsGenAsrt(eleType,"dgsGetRegisteredProperties",1,"string")) end
	if not dgsElementPropertyList[eleType] then return false end
	if withArgTemplate then
		return dgsElementPropertyList[eleType]
	else
		local propertyList = {}
		for propType in pairs(dgsElementPropertyList[eleType]) do
			propertyList[#propertyList+1] = propType
		end
		return propertyList
	end
end

function dgsGetData(dgsEle,key)
	return dgsElementData[dgsEle] and dgsElementData[dgsEle][key] or false
end

function dgsSetData(dgsEle,key,value,nocheck)
	local dgsType = dgsGetType(dgsEle)
	if not (isElement(dgsEle) and dgsType and key) then return false end
	if not dgsElementData[dgsEle] then dgsElementData[dgsEle] = {} end
	local eleData = dgsElementData[dgsEle]
	local oldValue = eleData[key]
	if oldValue == value then return true end
	eleData[key] = value
	if nocheck then return true end
	local dataHandlerList = dgsOnPropertyChange[dgsType] or dgsOnPropertyChange.default
	local dataHandler = dataHandlerList[key] or dgsOnPropertyChange.default[key]
	local translationListener = eleData.translationListener
	if translationListener and translationListener[key] then
		if dgsOnTranslationUpdate[dgsEle] then dgsOnTranslationUpdate[dgsType](dgsEle,key,value,translationListener[key]) else dgsOnTranslationUpdate.default(dgsEle,key,value,translationListener[key]) end
	end
	if dataHandler then dataHandler(dgsEle,key,value,oldValue) end
	if eleData.propertyListener and eleData.propertyListener[key] then dgsTriggerEvent("onDgsPropertyChange",dgsEle,key,value,oldValue) end
	return true
end

function dgsAddPropertyListener(dgsEle,propertyNames)
	local isTable = type(dgsEle) == "table"
	if not(dgsIsType(dgsEle) or isTable) then error(dgsGenAsrt(dgsEle,"dgsAddPropertyListener",1,"dgs-dxelement/table")) end
	if isTable then
		for i=1,#dgsEle do
			dgsAddPropertyListener(dgsEle[i],propertyNames)
		end
		return true
	else
		local eleData = dgsElementData[dgsEle]
		eleData.propertyListener = eleData.propertyListener or {}
		if type(propertyNames) == "table" then
			for i=1,#propertyNames do
				eleData.propertyListener[propertyNames[i]] = true
			end
		else
			eleData.propertyListener[propertyNames] = true
		end
	end
end

function dgsRemovePropertyListener(dgsEle,propertyNames)
	local isTable = type(dgsEle) == "table"
	if not(dgsIsType(dgsEle) or isTable) then error(dgsGenAsrt(dgsEle,"dgsRemovePropertyListener",1,"dgs-dxelement/table")) end
	if isTable then
		for i=1,#dgsEle do
			dgsRemovePropertyListener(dgsEle[i],propertyNames)
		end
		return true
	else
		local eleData = dgsElementData[dgsEle]
		eleData.propertyListener = eleData.propertyListener or {}
		if type(propertyNames) == "table" then
			for i=1,#propertyNames do
				eleData.propertyListener[propertyNames[i]] = false
			end
		else
			eleData.propertyListener[propertyNames] = false
		end
	end
end

function dgsGetListenedProperties(dgsEle)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsGetListenedProperties",1,"dgs-dxelement")) end
	local eleData = dgsElementData[dgsEle]
	eleData.propertyListener = eleData.propertyListener or {}
	local listening = {}
	for k,v in pairs(eleData.propertyListener) do
		listening[#listening+1] = k
	end
	return listening
end

local compatibility = {}
function checkCompatibility(dgsEle,key,sResRoot)
	local eleTyp = dgsGetType(dgsEle)
	if getElementData(resourceRoot,"DGS-enableCompatibilityCheck") then return (compatibility[eleTyp] and compatibility[eleTyp][key]) or compatibility[key] or key end
	if compatibility[eleTyp] and compatibility[eleTyp][key] then
		if not getElementData(localPlayer,"DGS-DEBUG-C") then
			outputDebugString("[DGS]Deprecated property '"..key.."' @dgsSetProperty with "..eleTyp..", replace with '"..compatibility[eleTyp][key].."'. See information below, or run again with command /debugdgs c",4,254,128,0)
			if getElementData(localPlayer,"DGS-DEBUG") == 3 then
				dgsTriggerEvent("DGSI_onDebug",sResRoot,"PropertyCompatibility",key,compatibility[eleTyp][key])
			end
			return compatibility[eleTyp][key]
		else
			if getElementData(localPlayer,"DGS-DEBUG") == 3 then
				dgsTriggerEvent("DGSI_onDebug",sResRoot,"PropertyCompatibility",key,compatibility[eleTyp][key])
			end
			outputDebugString("Found deprecated '"..key.."' @dgsSetProperty with "..eleTyp..", replace with "..compatibility[eleTyp][key],2)
			return false
		end
	end
	if compatibility[key] then
		if not getElementData(localPlayer,"DGS-DEBUG-C") then
			outputDebugString("[DGS]Deprecated property '"..key.."' @dgsSetProperty with all dgs elements, replace with '"..compatibility[key].."'. See information below, or run again with command /debugdgs c",4,254,128,0)
			if getElementData(localPlayer,"DGS-DEBUG") == 3 then
				dgsTriggerEvent("DGSI_onDebug",sResRoot,"PropertyCompatibility",key,compatibility[key])
			end
			return compatibility[key]
		else
			if getElementData(localPlayer,"DGS-DEBUG") == 3 then
				dgsTriggerEvent("DGSI_onDebug",sResRoot,"PropertyCompatibility",key,compatibility[key])
			end
			outputDebugString("Found deprecated property '"..key.."' @dgsSetProperty with all dgs elements, replace with "..compatibility[key],2)
			return false
		end
	end
	return key
end

local _dgsSetData = dgsSetData
function dgsSetProperty(dgsEle,key,value,...)
	local isTable = type(dgsEle) == "table"
	if not(dgsIsType(dgsEle) or isTable) then error(dgsGenAsrt(dgsEle,"dgsSetProperty",1,"dgs-dxelement/table")) end
	if isTable then
		for i=1,#dgsEle do
			dgsSetProperty(dgsEle[i],key,value,...)
		end
		return true
	else
		if #compatibility ~= 0 then
			local newKey = checkCompatibility(dgsEle,key,sourceResourceRoot or resourceRoot)
			if newKey == false then
				error("DGS Compatibility Check")
			end
			key = newKey
		end
		if key == "functions" then
			if value then
				local fnc,err
				if type(value) == "function" then
					fnc = value
				else
					fnc,err = loadstring(value)
					dgsElementData[dgsEle].functions_string = {value,{...}}
				end
				if not fnc then error("Bad argument @dgsSetProperty at argument 2, failed to load function ("..err..")") end
				value = {fnc,{...}}
			end
		elseif key == "absPos" then
			dgsSetPosition(dgsEle,value[1],value[2],false)
		elseif key == "rltPos" then
			dgsSetPosition(dgsEle,value[1],value[2],true)
		elseif key == "absSize" then
			dgsSetSize(dgsEle,value[1],value[2],false)
		elseif key == "rltSize" then
			dgsSetSize(dgsEle,value[1],value[2],true)
		end
		return _dgsSetData(dgsEle,key,value)
	end
end

function dgsGetProperty(dgsEle,key)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsGetProperty",1,"dgs-dxelement")) end
	return (dgsElementData[dgsEle] or {})[key] or false
end

function dgsSetProperties(dgsEle,theTable)
	local isTable = type(dgsEle) == "table"
	if not(dgsIsType(dgsEle) or isTable) then error(dgsGenAsrt(dgsEle,"dgsSetProperties",1,"dgs-dxelement/table")) end
	if not(type(theTable) == "table") then error(dgsGenAsrt(theTable,"dgsSetProperties",2,"table")) end
	local dxElements = isTable and dgsEle or {dgsEle}
	for i=1,#dxElements do
		local dgsEle = dxElements[i]
		for key,value in pairs(theTable) do
			dgsSetProperty(dgsEle,key,value)
		end
	end
	return true
end

function dgsGetProperties(dgsEle,properties)
	if not(dgsIsType(dgsEle) or isTable) then error(dgsGenAsrt(dgsEle,"dgsGetProperties",1,"dgs-dxelement/table")) end
	if not(not properties or type(properties) == "table") then error(dgsGenAsrt(properties,"dgsGetProperties",2,"table/none")) end
	local eleData = dgsElementData[dgsEle]
	if not eleData then return false end
	if not properties then return eleData end
	local data = {}
	for k,key in ipairs(properties) do
		data[key] = eleData[key]
	end
	return data
end

function dgsSetPropertyInherit(dxgui,key,value,...)
	local isTable = type(dxgui) == "table"
	if not(dgsIsType(dgsEle) or isTable) then error(dgsGenAsrt(dgsEle,"dgsSetPropertyInherit",1,"dgs-dxelement/table")) end
	local dxElements = isTable and dxgui or {dxgui}
	for i=1,#dxElements do
		local dgsEle = dxElements[i]
		dgsSetProperty(dgsEle,key,value)
		for index,child in ipairs(dgsGetChildren(dgsEle)) do
			dgsSetPropertyInherit(child,key,value,...)
		end
	end
	return true
end
------------------------Custom Easing Function
resourceTranslation = {}
LanguageTranslation = {}
LanguageTranslationAttach = {}
boundResource = {}
dgsEasingFunction = {}
dgsEasingFunctionOrg = {}
SEInterface = [[
local progress,setting,self = ...
local propertyTable = dgsElementData[self]
]]
function dgsAddEasingFunction(name,str,isOverWrite)
	if not(type(name) == "string") then error(dgsGenAsrt(name,"dgsAddEasingFunction",1,"string")) end
	if not(type(str) == "string") then error(dgsGenAsrt(str,"dgsAddEasingFunction",2,"string")) end
	if easingBuiltIn[name] then error(dgsGenAsrt(name,"dgsAddEasingFunction",1,_,_,"duplicated name with built-in easing function ("..name..")")) end
	if not isOverWrite and dgsEasingFunction[name] then error(dgsGenAsrt(name,"dgsAddEasingFunction",1,_,_,"this name has been used ("..name..")")) end
	local str = SEInterface..str
	local fnc,err = loadstring(str)
	if not fnc then error(dgsGenAsrt(fnc,"dgsAddEasingFunction",2,_,_,_,"Failed to load function:"..err)) end
	dgsEasingFunction[name] = fnc
	dgsEasingFunctionOrg[name] = str
	return true
end

function dgsRemoveEasingFunction(name)
	if not(type(name) == "string") then error(dgsGenAsrt(name,"dgsRemoveEasingFunction",1,"string")) end
	if dgsEasingFunction[name] then
		dgsEasingFunction[name] = nil
		dgsEasingFunctionOrg[name] = nil
		return true
	end
	return false
end

function dgsEasingFunctionExists(name)
	if not(type(name) == "string") then error(dgsGenAsrt(name,"dgsEasingFunctionExists",1,"string")) end
	return easingBuiltIn[name] or (dgsEasingFunction[name] and true)
end

------------------------DGS Property Saver
dgsElementKeeper = {}
function dgsSetElementKeeperEnabled(state)
	if sourceResource then
		dgsElementKeeper[sourceResource] = state and true or nil
		return true
	end
	return false
end

function dgsGetElementKeeperEnabled()
	if sourceResource then
		return dgsElementKeeper[sourceResource]
	end
	return false
end

function DGSI_SaveData()
	--Properties
	setElementData(root,"DGSI_Properties",dgsElementData,false)
	--Types
	setElementData(root,"DGSI_ElementType",dgsElementType,false)
	--Bound Resource
	setElementData(root,"DGSI_BoundResource",boundResource,false)
	--Translations
	setElementData(root,"DGSI_TranslationResRegister",resourceTranslation,false)
	setElementData(root,"DGSI_TranslationLanguage",LanguageTranslation,false)
	setElementData(root,"DGSI_TranslationLanguageAttach",LanguageTranslationAttach,false)
	--Easing Functions
	setElementData(root,"DGSI_EasingFunctions",dgsEasingFunctionOrg,false)
	--Element Keeper
	setElementData(root,"DGSI_ElementKeeper",dgsElementKeeper,false)
	--Layer Data
	setElementData(root,"DGSI_LayerData",{
		bottom=BottomFatherTable,
		center=CenterFatherTable,
		top=TopFatherTable,
		world3d=dgsWorld3DTable,
		screen3d=dgsScreen3DTable,
	},false)
	--Animations
	setElementData(root,"DGSI_Animations",animQueue,false)
	--Others
	setElementData(root,"DGSI_SaveData",true,false)
end

--[[
Logger type:
1.Texutre
2.Shader
3.Font
]]
function DGSI_AllocateDxElement(e,oldDgsElementLogger)
	if oldDgsElementLogger[e] then
		if isElement(oldDgsElementLogger[e][3]) then
			return oldDgsElementLogger[e][3]
		else
			local dxElement
			if oldDgsElementLogger[e][1] == 1 then
				dxElement = __dxCreateTexture(oldDgsElementLogger[e][2])
			elseif oldDgsElementLogger[e][1] == 2 then 
				dxElement = __dxCreateShader(oldDgsElementLogger[e][2])
			elseif oldDgsElementLogger[e][1] == 3 then 
				dxElement = __dxCreateFont(unpack(oldDgsElementLogger[e][2]))
			end
			if dxElement then
				oldDgsElementLogger[e][3] = dxElement
				dgsElementLogger[dxElement] = oldDgsElementLogger[e]
				return dxElement
			end
		end
	end
	return nil
end

function DGSI_ReadData()
	local SaveData = getElementData(root,"DGSI_SaveData")
	if SaveData == true then
		--Element Logger
		local oldDgsElementLogger = getElementData(root,"DGSI_ElementLogger") or {}
		--Properties
		local _dgsElementData = getElementData(root,"DGSI_Properties") or {}
		for dgsElement,data in pairs(_dgsElementData) do
			if not isElement(dgsElement) then
				_dgsElementData[dgsElement] = nil
			else
				if data.functions_string then
					local fnc = loadstring(data.functions_string[1])
					data.functions = {fnc,data.functions_string[2]}
				end
				if data.eventHandlers then
					local eventHandlers = data.eventHandlers
					if eventHandlers then 
						for i=1,#eventHandlers do
							addEventHandler(eventHandlers[i][1],dgsElement,_G[ eventHandlers[i][2] ],eventHandlers[i][3],eventHandlers[i][4])
						end
					end
				end
				for key,value in pairs(data) do
					local dataType = type(value)
					if dataType == "table" then
						for i,e in pairs(value) do
							local eType = type(e)
							if eType == "userdata" and not isElement(e) then
								value[i] = DGSI_AllocateDxElement(e,oldDgsElementLogger)
							end
						end
					elseif dataType == "userdata" and not isElement(value) then
						data[key] = DGSI_AllocateDxElement(value,oldDgsElementLogger)
					end
				end
			end
		end
		removeElementData(root,"DGSI_Properties")
		dgsElementData = table.merger(dgsElementData,_dgsElementData)
		--Types
		local _dgsElementType = getElementData(root,"DGSI_ElementType") or {}
		for dgsElement,data in pairs(_dgsElementType) do
			if not isElement(dgsElement) then _dgsElementType[dgsElement] = nil end
		end
		dgsElementType = table.merger(dgsElementType,_dgsElementType)
		removeElementData(root,"DGSI_ElementType")
		--Bound Resource
		local _boundResource = getElementData(root,"DGSI_BoundResource") or {}
		for res,t in pairs(_boundResource) do
			local resType = type(res)
			if resType ~= "userdata" then
				_boundResource[res] = nil
			elseif getUserdataType(res) ~= "resource-data" then
				_boundResource[res] = nil
			end
		end
		boundResource = table.merger(boundResource,_boundResource)
		removeElementData(root,"DGSI_BoundResource")
		--Translations
		resourceTranslation = getElementData(root,"DGSI_TranslationResRegister") or {}
		removeElementData(root,"DGSI_TranslationResRegister")
		
		LanguageTranslation = getElementData(root,"DGSI_TranslationLanguage") or {}
		removeElementData(root,"DGSI_TranslationLanguage")
		
		LanguageTranslationAttach = getElementData(root,"DGSI_TranslationLanguageAttach") or {}
		removeElementData(root,"DGSI_TranslationLanguageAttach")
		--Easing Functions
		local easingOrg = getElementData(root,"DGSI_EasingFunctions") or {}
		for name,data in pairs(easingOrg) do
			local fnc = loadstring(data)
			dgsEasingFunction[name] = fnc
		end
		removeElementData(root,"DGSI_EasingFunctions")
		--Element Keeper
		dgsElementKeeper = getElementData(root,"DGSI_ElementKeeper") or {}
		for res,t in pairs(dgsElementKeeper) do
			local resType = type(res)
			if resType ~= "userdata" then
				dgsElementKeeper[res] = nil
			elseif getUserdataType(res) ~= "resource-data" then
				dgsElementKeeper[res] = nil
			end
		end
		removeElementData(root,"DGSI_ElementKeeper")
		--Layer Data
		local layerData = getElementData(root,"DGSI_LayerData") or {}
		local _BottomFatherTable = layerData.bottom
		local _CenterFatherTable = layerData.center
		local _TopFatherTable = layerData.top
		for index,dgsElement in pairs(_BottomFatherTable) do
			if not isElement(dgsElement) then _BottomFatherTable[index] = nil end
		end
		for index,dgsElement in pairs(_CenterFatherTable) do
			if not isElement(dgsElement) then _CenterFatherTable[index] = nil end
		end
		for index,dgsElement in pairs(_TopFatherTable) do
			if not isElement(dgsElement) then _TopFatherTable[index] = nil end
		end
		BottomFatherTable = table.merger(BottomFatherTable,_BottomFatherTable)
		CenterFatherTable = table.merger(CenterFatherTable,_CenterFatherTable)
		TopFatherTable = table.merger(TopFatherTable,_TopFatherTable)
		LayerCastTable = {bottom=BottomFatherTable,center=CenterFatherTable,top=TopFatherTable}
		local _dgsWorld3DTable = layerData.world3d
		for index,dgsElement in pairs(_dgsWorld3DTable) do
			if not isElement(dgsElement) then _dgsWorld3DTable[index] = nil end
		end
		local _dgsScreen3DTable = layerData.screen3d
		for index,dgsElement in pairs(_dgsScreen3DTable) do
			if not isElement(dgsElement) then _dgsScreen3DTable[index] = nil end
		end
		dgsWorld3DTable = table.merger(dgsWorld3DTable,_dgsWorld3DTable)
		dgsScreen3DTable = table.merger(dgsScreen3DTable,_dgsScreen3DTable)
		removeElementData(root,"DGSI_LayerData")
		
		--Animations
		animQueue = getElementData(root,"DGSI_Animations") or {}
		removeElementData(root,"DGSI_Animations")
	end
	--Others

	setElementData(root,"DGSI_SaveData",false,false)
end

addEventHandler("onClientResourceStop",resourceRoot,function()
	--Element Logger
	setElementData(root,"DGSI_ElementLogger",dgsElementLogger,false)
	destroyElement(GlobalEdit)
	destroyElement(GlobalMemo)
	local terminator = createElement("dgs-dxterminator")
	addEventHandler("onClientElementDestroy",terminator,function()
		DGSI_SaveData()
	end,false)
end,false)

addEventHandler("onClientResourceStart",resourceRoot,DGSI_ReadData,false)

addEventHandler("onClientResourceStop",root,function(res)
	if boundResource[res] then
		dgsClear(nil,res)
		resourceTranslation[res] = nil
	end
	externalElementPool[res] = nil	--Clear external element pool
	if dgsElementKeeper[res] then dgsElementKeeper[res] = nil end
	if res == getThisResource() then	--Recover Cursor Alpha
		setCursorAlpha(255)
	end
	if G2DHookerEvents[res] then -- G2D Hooker
		G2DHookerEvents[res] = nil 
		if table.count(G2DHookerEvents) == 0 then 
			removeEventHandler("onDgsEditAccepted",root,handleHookerEvents)
			removeEventHandler("onDgsTextChange",root,handleHookerEvents)
			removeEventHandler("onDgsComboBoxSelect",root,handleHookerEvents)
			removeEventHandler("onDgsTabSelect",root,handleHookerEvents)
		end
	end
end)