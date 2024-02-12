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
dgsPreRenderer = {}
dgsRenderer = {}
dgsChildRenderer = {}
dgs3DRenderer = {}
dgsCustomTexture = {}
dgsBackEndRenderer = {
	register = function(self,dgsType,theFunction)
		self[dgsType] = theFunction
	end,
}
--On Click Action
dgsOnMouseClickAction = {}
dgsOnMouseScrollAction = {}
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
BottomRootTable = {}		--Store Bottom Root Element
CenterRootTable = {}		--Store Center Root Element (Default)
TopRootTable = {}			--Store Top Root Element
dgsWorld3DTable = {}
dgsScreen3DTable = {}
LayerCastTable = {center=CenterRootTable,top=TopRootTable,bottom=BottomRootTable}
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
				for propertyName in pairs(translationListener) do
					text[propertyName] = dgsElementData[dgsEle][propertyName] or ""
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
	index = mathClamp(index,1,#theTable+1)
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
		return BottomRootTable
	elseif layer:lower() == "top" then
		return TopRootTable
	else
		return CenterRootTable
	end
end

function dgsGetElementsFromResource(res)
	res = res or sourceResource
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

function dgsSetParent(child,newParent,nocheckRoot,noUpdatePosSize)
	if newParent == resourceRoot then newParent = nil end
	if not(dgsIsType(child)) then error(dgsGenAsrt(child,"dgsSetParent",1,"dgs-dxelement")) end
	if not(not dgsElementData[child] or not dgsElementData[child].attachTo) then error(dgsGenAsrt(child,"dgsSetParent",1,_,_,_,"attached dgs element can not have a parent")) end
	if not dgsElementData[child] then dgsElementData[child] = {} end
	local oldParent = dgsElementData[child].parent
	local parentTable = isElement(oldParent) and dgsElementData[oldParent].children or CenterRootTable
	if isElement(newParent) then
		if not dgsIsType(newParent) then return end
		if not nocheckRoot then
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
		tableInsert(CenterRootTable,child)
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

function dgsBringToFront(dgsEle,mouse,dontMoveParent,dontFocus)
	local eleType = dgsIsType(dgsEle)
	if not(eleType) then error(dgsGenAsrt(dgsEle,"dgsBringToFront",1,"dgs-dxelement")) end
	if mouse then
		local mouseButtons = dgsElementData[dgsEle].mouseButtons
		if mouseButtons then
			if (mouse == "left" and not mouseButtons[1])
			or (mouse == "right" and not mouseButtons[2])
			or (mouse == "middle" and not mouseButtons[3]) then
				return
			end
		end
	end
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
				eleType = dgsIsType(uparents)
				if isElement(uparents) then
					local children = dgsElementData[uparents].children
					local id = tableFind(children,parents)
					if id then
						tableRemove(children,id)
						tableInsert(children,parents)
						if dgsElementType[parents] == "dgs-dxscrollpane" then
							local scrollbar = dgsElementData[parents].scrollbars
							local clickedButton = "left"
							local mouseButtons = dgsElementData[parents].mouseButtons
							if mouseButtons and not mouseButtons[1] then
								clickedButton = (mouseButtons[2] and "right") or (mouseButtons[3] and "middle") or "left"
							end
							dgsBringToFront(scrollbar[1],clickedButton,_,true,false)
							dgsBringToFront(scrollbar[2],clickedButton,_,true,false)
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
								local clickedButton = "left"
								local mouseButtons = dgsElementData[parents].mouseButtons
								if mouseButtons and not mouseButtons[1] then
									clickedButton = (mouseButtons[2] and "right") or (mouseButtons[3] and "middle") or "left"
								end
								dgsBringToFront(scrollbar[1],clickedButton,_,true,false)
								dgsBringToFront(scrollbar[2],clickedButton,_,true,false)
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
	elseif mouse == "middle" then
		MouseData.click.middle = dgsEle
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
		visible = function(dgsEle,key,value,oldValue)
			dgsApplyVisibleInherited(dgsEle,value and dgsElementData[dgsEle].visibleInherited)
		end
	},
}

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
		for eleType2 in pairs(_G[eleType]) do
			dgsRegisterProperty(eleType2,propertyName,propertyArgTemplate)
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
		for eleType2 in pairs(_G[eleType]) do
			dgsRegisterProperties(eleType2,propertyList)
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
		for index,dgsEleItem in pairs(dgsEle) do
			dgsAddPropertyListener(dgsEleItem,propertyNames)
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
		for index,dgsEleItem in pairs(dgsEle) do
			dgsRemovePropertyListener(dgsEleItem,propertyNames)
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

local compatibility = {
	["dgs-dxscrollbar"] = {
		length = "cursorLength"
	}
}
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
		for index,dgsEleItem in pairs(dgsEle) do
			dgsSetProperty(dgsEleItem,key,value,...)
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
		dgsEle = dxElements[i]
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

function dgsSetPropertyInherit(dgsEle,key,value,...)
	local isTable = type(dgsEle) == "table"
	if not(dgsIsType(dgsEle) or isTable) then error(dgsGenAsrt(dgsEle,"dgsSetPropertyInherit",1,"dgs-dxelement/table")) end
	local dxElements = isTable and dgsEle or {dgsEle}
	for i=1,#dxElements do
		dgsEle = dxElements[i]
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
	str = SEInterface..str
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

addEventHandler("onClientResourceStop",resourceRoot,function()
	if isElement(GlobalEdit) then
		removeEventHandler("onClientElementDestroy",GlobalEdit,dgsGlobalEditDestroyDetector)	--shutdown global edit destroy detector
	end
	if isElement(GlobalMemo) then
		removeEventHandler("onClientElementDestroy",GlobalMemo,dgsGlobalMemoDestroyDetector)	--shutdown global memo destroy detector
	end
end,false)


addEventHandler("onClientResourceStop",root,function(res)
	if boundResource[res] then
		dgsClear(nil,res)
		resourceTranslation[res] = nil
		boundResource[res] = nil
	end
	if res == resource and CursorData.enabled then --Recover Cursor Alpha
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