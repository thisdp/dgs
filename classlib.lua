--classlib.lua
local loadstring = loadstring
-------OOP
if not getElementData(root,"__DGSRes") then assert(false,"Invalid DGS Resource! Please check whether your dgs resource is started") end
if not dgsImportHead then loadstring(exports[getElementData(root,"__DGSRes")]:dgsImportFunction())() end
if dgsOOP and dgsOOP.dgsRes and isElement(getResourceRootElement(dgsOOP.dgsRes)) then return end
local getmetatable = getmetatable
local setmetatable = setmetatable
local tostring = tostring
local tonumber = tonumber
local _call = call
local setfenv = setfenv
local function call(...)
	local _source = source
	local retValue = {_call(...)}
	source = _source
	return unpack(retValue)
end
-------Utils
local strToIntCache = {
	["1"]=1,
	["2"]=2,
	["3"]=3,
	["4"]=4,
}
dgsOOP = {
	dgsClasses = {},
	dgsInstances = setmetatable({},{__mode="kv"}),
	eventHandler = {},
	dgsRes = getElementData(root,"__DGSRes"),
	dgsRoot = getResourceRootElement(getElementData(root,"__DGSRes")),
	transfromEventName = function(eventName,isReverse)
		return isReverse and (eventName:sub(3,3):lower()..eventName:sub(4)) or ("on"..eventName:sub(1,1):upper()..eventName:sub(2))
	end,
	getVectorType = function(vec)
		local vecData = tostring(vec)
		local typeName = vecData:sub(1,6)
		if typeName == "vector" then
			return strToIntCache[vecData:sub(7,7)] or false
		elseif typeName == "table:" then
			return "table"
		end
		return false
	end,
	deepCopy = function(obj)
		local InTable = {}
		local function Func(obj)
			if type(obj) ~= "table" then
				return obj
			end
			local NewTable = {}
			InTable[obj] = NewTable
			for k,v in pairs(obj) do
				NewTable[Func(k)] = Func(v)
			end
			return setmetatable(NewTable,getmetatable(obj))
		end
		return Func(obj)
	end,
	shallowCopy = function(obj)
		local InTable = {}
		for k,v in pairs(obj) do
			InTable[k] = v
		end
		return InTable
	end,
}
dgsRoot = dgsOOP.dgsRoot

do

local function __eq(self,ele2)
	if type(ele2) == "table" then
		return self.dgsElement == ele2.dgsElement
	end
end

local function class(tab)
	dgsOOP.dgsClasses[tab.dgsType or tab.type] = tab
	local meta = {
		__call = function(self,...)	--can be  optimized with class cache
			local meta = getmetatable(self)
			setmetatable(self,nil)
			local newMeta = dgsOOP.deepCopy(self)
			setmetatable(self,meta)
			local newInstance = {extends=newMeta.extends}
			if newMeta.preInstantiate then
				newInstance.dgsElement = newMeta.preInstantiate(...)	--Pre Instantiate function doesn't include meta table
				dgsOOP.dgsInstances[newInstance.dgsElement] = newInstance
				if isElement(newInstance.dgsElement) then
					addEventHandler("onClientElementDestroy",newInstance.dgsElement,function()
						dgsOOP.dgsInstances[newInstance.dgsElement] = nil
					end,false)
				end
			end
			newInstance.extends = nil
			newMeta.extends = nil
			newMeta.preInstantiate = nil
			newMeta.default = newMeta.default or {}
			newMeta.public = newMeta.public or {}
			newMeta.__index = newMeta.default.__index or newMeta.public.__index
			newMeta.__newindex = newMeta.default.__newindex or newMeta.public.__newindex
			newMeta.__eq = __eq
			newMeta.public.__index = nil
			newMeta.public.__newindex = nil
			newMeta.default.__index = nil
			newMeta.default.__newindex = nil
			for k,v in pairs(newMeta.public) do
				newInstance[k] = v
			end
			for k,v in pairs(newMeta.default) do
				newInstance[k] = v
			end
			newMeta.public = nil
			newMeta.default = nil
			setmetatable(newInstance,newMeta)
			if newMeta.init then
				newMeta.init(newInstance)
			end
			return newInstance
		end,
		__index = function(self,dgsElement)
			local meta = getmetatable(self)
			setmetatable(self,nil)
			local newMeta = dgsOOP.deepCopy(self)
			setmetatable(self,meta)
			local newInstance = {extends=newMeta.extends}
			newInstance.dgsElement = dgsElement	--For converting dgs pop element to oop instance
			dgsOOP.dgsInstances[newInstance.dgsElement] = newInstance
			if isElement(newInstance.dgsElement) then
				addEventHandler("onClientElementDestroy",newInstance.dgsElement,function()
					dgsOOP.dgsInstances[newInstance.dgsElement] = nil
				end,false)
			end
			newInstance.extends = nil
			newMeta.extends = nil
			newMeta.preInstantiate = nil
			newMeta.default = newMeta.default or {}
			newMeta.public = newMeta.public or {}
			newMeta.__index = newMeta.default.__index or newMeta.public.__index
			newMeta.__newindex = newMeta.default.__newindex or newMeta.public.__newindex
			newMeta.public.__index = nil
			newMeta.public.__newindex = nil
			newMeta.default.__index = nil
			newMeta.default.__newindex = nil
			for k,v in pairs(newMeta.public) do
				newInstance[k] = v
			end
			for k,v in pairs(newMeta.default) do
				newInstance[k] = v
			end
			newMeta.public = nil
			newMeta.default = nil
			setmetatable(newInstance,newMeta)
			return newInstance
		end
	}
	if tab.public then
		if tab.public.ailas then
			for name,alias in pairs(tab.public.ailas) do
				tab.public[name] = alias
			end
		end
	end
	if tab.extends then
		tab.public = tab.public or {}
		if type(tab.extends) ~= "table" then
			local extendsClass = dgsOOP[tab.extends]
			for k,v in pairs(extendsClass.public or {}) do
				if not tab.public[k] then	--Don't overwrite child's function when copying parent's functions
					tab.public[k] = v
				end
			end
		else
			for key,extend in ipairs(tab.extends) do
				local extendsClass = dgsOOP[extend]
				for k,v in pairs(extendsClass.public or {}) do
					if not tab.public[k] then	--Don't overwrite child's function when copying parent's functions
						tab.public[k] = v
					end
				end
			end
		end
	end
	if tab.inject then
		for theType,space in pairs(tab.inject) do
			local classData = dgsOOP[theType]
			for name,fnc in pairs(space.default) do
				classData.public[name] = fnc
			end
		end
	end
	setmetatable(tab,meta)
	dgsOOP[tab.dgsType] = tab
	dgsOOP[tab.type] = tab
end
dgsOOP.class = class

function dgsOOP.genInterface(dgsElement,meta)
	local newmeta = dgsOOP.shallowCopy(meta)
	newmeta.dgsElement = dgsElement
	return setmetatable({"DGS OOP: Bad usage"},newmeta)()
end

dgsOOP.genOOPFnc = function(pop,isChain)
	if isChain then
		return function(self,...)
			return call(dgsOOP.dgsRes,pop,self.dgsElement,...) and self or false
		end
	else
		return function(self,...)
			return dgsGetInstance(call(dgsOOP.dgsRes,pop,self.dgsElement,...))
		end
	end
end

dgsOOP.genOOPFncMTA = function(pop,isChain)
	if isChain then
		return function(self,...)
			return _G[pop](self.dgsElement,...) and self or false
		end
	else
		return function(self,...)
			return dgsGetInstance(_G[pop](self.dgsElement,...))
		end
	end
end

dgsOOP.genOOPFncNonObj = function(pop,isChain)
	return function(self,...)
		return dgsGetInstance(call(dgsOOP.dgsRes,pop,...))
	end
end
local gObjFnc = dgsOOP.genOOPFnc
local gObjFncMTA = dgsOOP.genOOPFncMTA
local gNObjFnc = dgsOOP.genOOPFncNonObj
----------------DGS 2D
dgsOOP.position2D = {
	__index=function(self,key)
		local meta = getmetatable(self)
		if not isElement(meta.dgsElement) then return false end
		if key == "relative" then
			return dgsGetProperty(meta.dgsElement,"relative")[1]
		elseif key == "x" then
			local pos = dgsGetProperty(meta.dgsElement,"relative")[1] and dgsGetProperty(meta.dgsElement,"rltPos") or dgsGetProperty(meta.dgsElement,"absPos")
			return pos[1]
		elseif key == "y" then
			local pos = dgsGetProperty(meta.dgsElement,"relative")[1] and dgsGetProperty(meta.dgsElement,"rltPos") or dgsGetProperty(meta.dgsElement,"absPos")
			return pos[2]
		elseif key == "toVector" then
			local pos = dgsGetProperty(meta.dgsElement,"relative")[1] and dgsGetProperty(meta.dgsElement,"rltPos") or dgsGetProperty(meta.dgsElement,"absPos")
			return Vector2(pos)
		end
	end,
	__newindex=function(self,key,value)
		local meta = getmetatable(self)
		if not isElement(meta.dgsElement) then return false end
		if key == "relative" then
			local rlt = dgsGetProperty(meta.dgsElement,"relative")
			rlt[1] = value
			return dgsSetProperty(meta.dgsElement,"relative",rlt)
		elseif key == "x" then
			local rlt = dgsGetProperty(meta.dgsElement,"relative")
			return dgsSetPosition(meta.dgsElement,value,_,rlt[1])
		elseif key == "y" then
			local rlt = dgsGetProperty(meta.dgsElement,"relative")
			return dgsSetPosition(meta.dgsElement,_,value,rlt[1])
		end
	end,
	__call=function(self,key)
		local meta = getmetatable(self)
		setmetatable(self,nil)
		local rlt = dgsGetProperty(meta.dgsElement,"relative")
		self[1],self[2] = dgsGetPosition(meta.dgsElement,rlt[1])
		setmetatable(self,meta)
		return self
	end,
}

dgsOOP.size2D = {
	__isAvailable = true,
	__index=function(self,key)
		local meta = getmetatable(self)
		if not isElement(meta.dgsElement) then return false end
		if key == "relative" then
			return dgsGetProperty(meta.dgsElement,"relative")[2]
		elseif key == "w" or key == "width" then
			local size = dgsGetProperty(meta.dgsElement,"relative")[2] and dgsGetProperty(meta.dgsElement,"rltSize") or dgsGetProperty(meta.dgsElement,"absSize")
			return size[1]
		elseif key == "h" or key == "height" then
			local size = dgsGetProperty(meta.dgsElement,"relative")[2] and dgsGetProperty(meta.dgsElement,"rltSize") or dgsGetProperty(meta.dgsElement,"absSize")
			return size[2]
		elseif key == "toVector" then
			local size = dgsGetProperty(meta.dgsElement,"relative")[2] and dgsGetProperty(meta.dgsElement,"rltSize") or dgsGetProperty(meta.dgsElement,"absSize")
			return Vector2(size)
		end
	end,
	__newindex=function(self,key,value)
		local meta = getmetatable(self)
		if not isElement(meta.dgsElement) then return false end
		if key == "relative" then
			local rlt = dgsGetProperty(meta.dgsElement,"relative")
			rlt[2] = value
			return dgsSetProperty(meta.dgsElement,"relative",rlt)
		elseif key == "w" then
			local rlt = dgsGetProperty(meta.dgsElement,"relative")
			return dgsSetSize(meta.dgsElement,value,_,rlt[2])
		elseif key == "h" then
			local rlt = dgsGetProperty(meta.dgsElement,"relative")
			return dgsSetSize(meta.dgsElement,_,value,rlt[2])
		end
	end,
	__call=function(self,key)
		local meta = getmetatable(self)
		setmetatable(self,nil)
		local rlt = dgsGetProperty(meta.dgsElement,"relative")
		self[1],self[2] = dgsGetSize(meta.dgsElement,rlt[2])
		setmetatable(self,meta)
		return self
	end,
}

--2 Types:
--default: Will not inherit
--public: Will inherit
class {
	type = "dgsRoot";
	dgsType = "resourceRoot";
	preInstantiate = function(self)
		return getResourceRootElement(dgsOOP.dgsRes)
	end;
	init = function(self)
		--Expose Functions
		for k,v in pairs(self) do
			_G[k] = v
		end
	end;
	default = {
		addStyle = gNObjFnc("dgsAddStyle"),
		loadStyle = gNObjFnc("dgsLoadStyle"),
		getLoadedStyleList = gNObjFnc("dgsGetLoadedStyleList"),
		getAddedStyleList = gNObjFnc("dgsGetAddedStyleList"),
		unloadStyle = gNObjFnc("dgsUnloadStyle"),
		setStyle = gNObjFnc("dgsSetStyle"),
		getStyle = gNObjFnc("dgsGetStyle"),
		getValueFromStyle = gNObjFnc("dgsGetValueFromStyle"),
		getScreenSize = function(self) return Vector2(guiGetScreenSize()) end,
		setInputEnabled = function(self,...) return guiSetInputEnabled(...) end,
		getInputEnabled = function(self,...) return guiGetInputEnabled(...) end,
		setInputMode = function(self,...) return guiSetInputMode(...) end,
		getInputMode = function(self,...) return guiGetInputMode(...) end,
		setRenderSetting = gNObjFnc("dgsSetRenderSetting"),
		getRenderSetting = gNObjFnc("dgsGetRenderSetting"),
		getLayerElements = gNObjFnc("dgsGetLayerElements"),
		addEasingFunction = gNObjFnc("dgsAddEasingFunction"),
		easingFunctionExists = gNObjFnc("dgsEasingFunctionExists"),
		removeEasingFunction = gNObjFnc("dgsRemoveEasingFunction"),
		getSystemFont = gNObjFnc("dgsGetSystemFont"),
		setSystemFont = gNObjFnc("dgsSetSystemFont"),
		translationTableExists = gNObjFnc("dgsTranslationTableExists"),
		setTranslationTable = gNObjFnc("dgsSetTranslationTable"),
		setAttachTranslation = gNObjFnc("dgsSetAttachTranslation"),
		setMultiClickInterval = gNObjFnc("dgsSetMultiClickInterval"),
		getMultiClickInterval = gNObjFnc("dgsGetMultiClickInterval"),
		getCursorPosition = function(self,rltE,rlt,fScreen) return dgsGetCursorPosition(rltE and rltE.dgsElement or false,rlt,fScreen) end,
		setCursorImage = gNObjFnc("dgsSetCustomCursorImage"),
		getCursorImage = gNObjFnc("dgsGetCustomCursorImage"),
		setCustomCursorEnabled = gNObjFnc("dgsSetCustomCursorEnabled"),
		getCustomCursorEnabled = gNObjFnc("dgsGetCustomCursorEnabled"),
		setCursorSize = gNObjFnc("dgsSetCursorSize"),
		getCursorSize = gNObjFnc("dgsGetCursorSize"),
		setCursorColor = gNObjFnc("dgsSetCursorColor"),
		getCursorColor = gNObjFnc("dgsGetCursorColor"),
		getCursorType = gNObjFnc("dgsGetCursorType"),
		getElementKeeperEnabled = gNObjFnc("dgsGetElementKeeperEnabled"),
		setElementKeeperEnabled = gNObjFnc("dgsSetElementKeeperEnabled"),
		RGBToHSV = gNObjFnc("dgsRGBToHSV"),
		RGBToHSL = gNObjFnc("dgsRGBToHSL"),
		HSLToRGB = gNObjFnc("dgsHSLToRGB"),
		HSVToRGB = gNObjFnc("dgsHSVToRGB"),
		HSVToHSL = gNObjFnc("dgsHSVToHSL"),
		HSLToHSV = gNObjFnc("dgsHSLToHSV"),
		dgs3DImage = function(...) return dgsOOP.dgs3DImage(dgsRootInstance,...) end,
		dgs3DInterface = function(...) return dgsOOP.dgs3DInterface(dgsRootInstance,...) end,
		dgs3DLine = function(...) return dgsOOP.dgs3DLine(dgsRootInstance,...) end,
		dgs3DText = function(...) return dgsOOP.dgs3DText(dgsRootInstance,...) end,
		dgsBrowser = function(...) return dgsOOP.dgsBrowser(dgsRootInstance,...) end,
		dgsButton = function(...) return dgsOOP.dgsButton(dgsRootInstance,...) end,
		dgsCheckBox = function(...) return dgsOOP.dgsCheckBox(dgsRootInstance,...) end,
		dgsComboBox = function(...) return dgsOOP.dgsComboBox(dgsRootInstance,...) end,
		dgsCustomRenderer = function(...) return dgsOOP.dgsCustomRenderer(dgsRootInstance,...) end,
		dgsDetectArea = function(...) return dgsOOP.dgsDetectArea(dgsRootInstance,...) end,
		dgsEdit = function(...) return dgsOOP.dgsEdit(dgsRootInstance,...) end,
		dgsGridList = function(...) return dgsOOP.dgsGridList(dgsRootInstance,...) end,
		dgsImage = function(...) return dgsOOP.dgsImage(dgsRootInstance,...) end,
		dgsLabel = function(...) return dgsOOP.dgsLabel(dgsRootInstance,...) end,
		dgsLine = function(...) return dgsOOP.dgsLine(dgsRootInstance,...) end,
		dgsMemo = function(...) return dgsOOP.dgsMemo(dgsRootInstance,...) end,
		dgsProgressBar = function(...) return dgsOOP.dgsProgressBar(dgsRootInstance,...) end,
		dgsRadioButton = function(...) return dgsOOP.dgsRadioButton(dgsRootInstance,...) end,
		dgsSelector = function(...) return dgsOOP.dgsSelector(dgsRootInstance,...) end,
		dgsScrollBar = function(...) return dgsOOP.dgsScrollBar(dgsRootInstance,...) end,
		dgsScrollPane = function(...) return dgsOOP.dgsScrollPane(dgsRootInstance,...) end,
		dgsScalePane = function(...) return dgsOOP.dgsScalePane(dgsRootInstance,...) end,
		dgsSwitchButton = function(...) return dgsOOP.dgsSwitchButton(dgsRootInstance,...) end,
		dgsTabPanel = function(...) return dgsOOP.dgsTabPanel(dgsRootInstance,...) end,
		dgsWindow = function(...) return dgsOOP.dgsWindow(dgsRootInstance,...) end,
		dgsGetInstance = function(dgsElement,...)
			local typ = type(dgsElement)
			if typ ~= "table" and typ ~= "userdata" then return dgsElement,... end
			if typ == "table" then
				local t = {}
				for i=1,#dgsElement do
					t[i] = dgsRootInstance.dgsGetInstance(dgsElement[i])
				end
				return t
			end
			local originalClass = dgsOOP.dgsInstances[dgsElement]
			if originalClass and originalClass.dgsElement == dgsElement then
				return originalClass
			else
				local eleType = dgsGetPluginType(dgsElement)
				if dgsOOP[eleType] then
					return dgsOOP[eleType][dgsElement]
				else
					return dgsElement
				end
			end
		end,
		dgsGetInstanceByType = function(dgsElement,instanceType,...)
			local typ = type(dgsElement)
			if typ ~= "table" and typ ~= "userdata" then return dgsElement,... end
			if typ == "table" then
				local t = {}
				for i=1,#dgsElement do
					t[i] = dgsRootInstance.dgsGetInstanceByType(dgsElement[i],instanceType)
				end
				return t
			end
			local originalClass = dgsOOP.dgsInstances[dgsElement]
			if originalClass and originalClass.dgsElement == dgsElement then
				return originalClass
			else
				if dgsOOP[instanceType] then
					return dgsOOP[instanceType][dgsElement]
				else
					return dgsElement
				end
			end
		end,
	};
	public = {
		isDragNDropData = gNObjFnc("dgsIsDragNDropData"),
		retrieveDragNDropData = gNObjFnc("dgsRetrieveDragNDropData"),
		sendDragNDropData = gNObjFnc("dgsSendDragNDropData"),
		on = function(self,eventName,theFnc,p)
			local eventName = dgsOOP.transfromEventName(eventName)
			removeEventHandler(eventName,self.dgsElement,theFnc)
			dgsOOP.eventHandler[eventName] = dgsOOP.eventHandler[eventName] or {}
			dgsOOP.eventHandler[eventName][self.dgsElement] = dgsOOP.eventHandler[eventName][self.dgsElement] or {}
			local eventFncEnv = {}
			setmetatable(eventFncEnv,{__index = _G,__newindex = _G})
			setfenv(theFnc,eventFncEnv)
			local function callBack(...)
				local s = dgsGetInstance(source)
				eventFncEnv.source = s
				eventFncEnv.this = s
				attachedFnc(...)
			end
			local newfenv = {attachedFnc=theFnc}
			setmetatable(newfenv,{__index=_G})
			setfenv(callBack,newfenv)
			dgsOOP.eventHandler[eventName][self.dgsElement][theFnc] = callBack
			return addEventHandler(eventName,self.dgsElement,callBack,p and true or false) and self or false
		end,
		removeOn = function(self,eventName,theFnc)
			local eventName = dgsOOP.transfromEventName(eventName)
			dgsOOP.eventHandler[eventName] = dgsOOP.eventHandler[eventName] or {}
			dgsOOP.eventHandler[eventName][self.dgsElement] = dgsOOP.eventHandler[eventName][self.dgsElement] or {}
			if dgsOOP.eventHandler[eventName][self.dgsElement][theFnc] then
				local oFnc = dgsOOP.eventHandler[eventName][self.dgsElement][theFnc]
				dgsOOP.eventHandler[eventName][self.dgsElement][theFnc] = nil
				return removeEventHandler(eventName,self.dgsElement,oFnc) and self or false
			end
			return true
		end,
		dgsBrowser = function(...) return dgsOOP.dgsBrowser(...) end,
		dgsButton = function(...) return dgsOOP.dgsButton(...) end,
		dgsCheckBox = function(...) return dgsOOP.dgsCheckBox(...) end,
		dgsComboBox = function(...) return dgsOOP.dgsComboBox(...) end,
		dgsDetectArea = function(...) return dgsOOP.dgsDetectArea(...) end,
		dgsEdit = function(...) return dgsOOP.dgsEdit(...) end,
		dgsGridList = function(...) return dgsOOP.dgsGridList(...) end,
		dgsImage = function(...) return dgsOOP.dgsImage(...) end,
		dgsLabel = function(...) return dgsOOP.dgsLabel(...) end,
		dgsLine = function(...) return dgsOOP.dgsLine(...) end,
		dgsMemo = function(...) return dgsOOP.dgsMemo(...) end,
		dgsProgressBar = function(...) return dgsOOP.dgsProgressBar(...) end,
		dgsRadioButton = function(...) return dgsOOP.dgsRadioButton(...) end,
		dgsSelector = function(...) return dgsOOP.dgsSelector(...) end,
		dgsScrollBar = function(...) return dgsOOP.dgsScrollBar(...) end,
		dgsScrollPane = function(...) return dgsOOP.dgsScrollPane(...) end,
		dgsScalePane = function(...) return dgsOOP.dgsScalePane(...) end,
		dgsSwitchButton = function(...) return dgsOOP.dgsSwitchButton(...) end,
		dgsTabPanel = function(...) return dgsOOP.dgsTabPanel(...) end,
		dgsWindow = function(...) return dgsOOP.dgsWindow(...) end,
		attachToAutoDestroy = function(self,element,dgsElement,index)
			if self == dgsRootInstance then
				return dgsAttachToAutoDestroy(type(element) == "table" and element.dgsElement or element,type(dgsElement) == "table" and dgsElement.dgsElement or dgsElement,index) and self
			else
				return dgsAttachToAutoDestroy(self.dgsElement,type(element) == "table" and element.dgsElement or element,dgsElement) and self
			end
		end,
		----------Plugins
		dgsColorPicker = function(...) return dgsOOP.dgsColorPicker(...) end,
		dgsComponentSelector = function(...) return dgsOOP.dgsComponentSelector(...) end,
		dgsSVG = function(...) return dgsOOP.dgsSVG(...) end,
		
		--Alias
		alias = {
			--A = B
			destroyWith = "attachToAutoDestroy",
		},
	};
}

----------------------------------------------------------
-------------------------------------------------DGS Basic
----------------------------------------------------------
class {
	extends = "dgsRoot";
	type = "dgsBasic";
	preInstantiate = nil;
	public = {
		__index=function(self,key)
			if key == "parent" then
				local parent = dgsGetParent(self.dgsElement,key)
				return parent and dgsGetInstance(parent) or false
			elseif key == "children" then
				return self:getChildren()
			end
			return dgsGetProperty(self.dgsElement,key)
		end,
		__newindex=function(self,key,value)
			if key == "parent" then
				local targetEle
				if type(value) == "table" then targetEle = value.dgsElement end
				return dgsSetParent(self.dgsElement,targetEle)
			end
			return dgsSetProperty(self.dgsElement,key,value) and self or false
		end,
		getParent = gObjFnc("dgsGetParent"),
		setParent = function(self,parent)
			if type(parent) == "table" and isElement(parent.dgsElement) then parent = parent.dgsElement	end
			return dgsSetParent(self.dgsElement,parent) and self or false
		end,
		getChild = gObjFnc("dgsGetChild"),
		getChildren = gObjFnc("dgsGetChildren"),
		getType = gObjFnc("dgsGetType"),
		getProperty = gObjFnc("dgsGetProperty"),
		setProperty = gObjFnc("dgsSetProperty",true),
		getProperties = function(self,...) return dgsGetProperties(self.dgsElement,...) end,
		setProperties = gObjFnc("dgsSetProperties",true),
		getVisible = gObjFnc("dgsGetVisible"),
		setVisible = gObjFnc("dgsSetVisible",true),
		getEnabled = gObjFnc("dgsGetEnabled"),
		setEnabled = gObjFnc("dgsSetEnabled",true),
		blur = gObjFnc("dgsBlur",true),
		focus = gObjFnc("dgsFocus",true),
		getAlpha = gObjFnc("dgsGetAlpha"),
		setAlpha = gObjFnc("dgsSetAlpha",true),
		getFont = gObjFnc("dgsGetFont"),
		setFont = gObjFnc("dgsSetFont",true),
		getText = gObjFnc("dgsGetText"),
		setText = gObjFnc("dgsSetText",true),
		simulateClick = gObjFnc("dgsSimulateClick",true),
		animTo = gObjFnc("dgsAnimTo",true),
		isAniming = gObjFnc("dgsIsAniming"),
		stopAniming = gObjFnc("dgsStopAniming",true),
		alphaTo = gObjFnc("dgsAlphaTo",true),
		isAlphaing = gObjFnc("dgsIsAlphaing"),
		stopAlphaing = gObjFnc("dgsStopAlphaing",true),
		getPostGUI = gObjFnc("dgsGetPostGUI"),
		setPostGUI = gObjFnc("dgsSetPostGUI",true),
		destroy = function(self) return destroyElement(self.dgsElement) end;
		isElement = gObjFnc("isElement",true);
		getElement = function(self) return self.dgsElement end,
		addMoveHandler = gObjFnc("dgsAddMoveHandler",true),
		removeMoveHandler = gObjFnc("dgsRemoveMoveHandler",true),
		isMoveHandled = gObjFnc("dgsIsMoveHandled"),
		attachToTranslation = gObjFnc("dgsAttachToTranslation",true),
		detachFromTranslation = gObjFnc("dgsDetachFromTranslation",true),
		getTranslationName = gObjFnc("dgsGetTranslationName"),
		addDragHandler = gObjFnc("dgsAddDragHandler",true),
		removeDragHandler = gObjFnc("dgsRemoveDragHandler",true),
		addDropHandler = gObjFnc("dgsAddDropHandler",true),
		removeDropHandler = gObjFnc("dgsRemoveDropHandler",true),
	};
	default = {

	};
}
----------------------------------------------------------
----------------------------------------------------DGS 2D
----------------------------------------------------------
class {
	extends = "dgsBasic";
	type = "dgs2D";
	preInstantiate = nil;
	public = {
		__index=function(self,key)
			if key == "parent" then
				local parent = dgsGetParent(self.dgsElement,key)
				return parent and dgsGetInstance(parent) or false
			elseif key == "children" then
				return self:getChildren()
			elseif key == "size" then
				return dgsOOP.genInterface(self.dgsElement,dgsOOP.size2D)
			elseif key == "position" then
				return dgsOOP.genInterface(self.dgsElement,dgsOOP.position2D)
			end
			return dgsGetProperty(self.dgsElement,key)
		end,
		__newindex=function(self,key,value)
			if key == "parent" then
				local targetEle
				if type(value) == "table" then targetEle = value.dgsElement end
				return dgsSetParent(self.dgsElement,targetEle)
			elseif key == "size" then
				local vType = dgsOOP.getVectorType(value)
				if vType == "table" then
					local rlt = dgsGetProperty(self.dgsElement,"relative")
					return dgsSetSize(self.dgsElement,value[1],value[2],value[3] ~= nil and value[3] or rlt[2])
				elseif vType == 2 then
					local rlt = dgsGetProperty(self.dgsElement,"relative")
					return dgsSetSize(self.dgsElement,value.x,value.y,rlt[2])
				end
			elseif key == "position" then
				local vType = dgsOOP.getVectorType(value)
				if vType == "table" then
					local rlt = dgsGetProperty(self.dgsElement,"relative")
					return dgsSetPosition(self.dgsElement,value[1] or value.x,value[2] or value.y,value[3] ~= nil and value[3] or rlt[1])
				elseif vType == 2 then
					local rlt = dgsGetProperty(self.dgsElement,"relative")
					return dgsSetPosition(self.dgsElement,value.x,value.y,rlt[1])
				end
			end
			return dgsSetProperty(self.dgsElement,key,value) and self or false
		end,
		getPosition = gObjFnc("dgsGetPosition"),
		setPosition = gObjFnc("dgsSetPosition",true),
		getParent = gObjFnc("dgsGetParent"),
		setParent = function(self,parent)
			if type(parent) == "table" and isElement(parent.dgsElement) then parent = parent.dgsElement	end
			return dgsSetParent(self.dgsElement,parent) and self or false
		end,
		getChild = gObjFnc("dgsGetChild"),
		getChildren = gObjFnc("dgsGetChildren"),
		getSize = gObjFnc("dgsGetSize"),
		setSize = gObjFnc("dgsSetSize",true),
		getType = gObjFnc("dgsGetType"),
		setLayer = gObjFnc("dgsSetLayer",true),
		getLayer = gObjFnc("dgsSetLayer"),
		setCurrentLayerIndex = gObjFnc("dgsSetCurrentLayerIndex",true),
		getCurrentLayerIndex = gObjFnc("dgsGetCurrentLayerIndex"),
		getProperty = gObjFnc("dgsGetProperty"),
		setProperty = gObjFnc("dgsSetProperty",true),
		getProperties = function(self,...) return dgsGetProperties(self.dgsElement,...) end,
		setProperties = gObjFnc("dgsSetProperties",true),
		getVisible = gObjFnc("dgsGetVisible"),
		setVisible = gObjFnc("dgsSetVisible",true),
		getEnabled = gObjFnc("dgsGetEnabled"),
		setEnabled = gObjFnc("dgsSetEnabled",true),
		blur = gObjFnc("dgsBlur",true),
		focus = gObjFnc("dgsFocus",true),
		getPositionAlignment = gObjFnc("dgsGetPositionAlignment"),
		setPositionAlignment = gObjFnc("dgsSetPositionAlignment",true),
		getAlpha = gObjFnc("dgsGetAlpha"),
		setAlpha = gObjFnc("dgsSetAlpha",true),
		getFont = gObjFnc("dgsGetFont"),
		setFont = gObjFnc("dgsSetFont",true),
		getText = gObjFnc("dgsGetText"),
		setText = gObjFnc("dgsSetText",true),
		bringToFront = gObjFnc("dgsBringToFront",true),
		moveToBack = gObjFnc("dgsMoveToBack",true),
		simulateClick = gObjFnc("dgsSimulateClick",true),
		animTo = gObjFnc("dgsAnimTo",true),
		isAniming = gObjFnc("dgsIsAniming"),
		stopAniming = gObjFnc("dgsStopAniming",true),
		moveTo = gObjFnc("dgsMoveTo",true),
		isMoving = gObjFnc("dgsIsMoving"),
		stopMoving = gObjFnc("dgsStopMoving",true),
		sizeTo = gObjFnc("dgsSizeTo",true),
		isSizing = gObjFnc("dgsIsSizing"),
		stopSizing = gObjFnc("dgsStopSizing",true),
		alphaTo = gObjFnc("dgsAlphaTo",true),
		isAlphaing = gObjFnc("dgsIsAlphaing"),
		stopAlphaing = gObjFnc("dgsStopAlphaing",true),
		getPostGUI = gObjFnc("dgsGetPostGUI"),
		setPostGUI = gObjFnc("dgsSetPostGUI",true),
		detachFromGridList = gObjFnc("dgsDetachFromGridList",true),
		getAttachedGridList = gObjFnc("dgsGetAttachedGridList",true),
		attachToGridList = function(self,targetGridList,...) return dgsAttachToGridList(self.dgsElement,targetGridList.dgsElement,...) and self or false end,
		center = gObjFnc("dgsCenterElement",true),
		destroy = function(self) return destroyElement(self.dgsElement) end;
		isElement = gObjFnc("isElement",true);
		getElement = function(self) return self.dgsElement end,
		addMoveHandler = gObjFnc("dgsAddMoveHandler",true),
		removeMoveHandler = gObjFnc("dgsRemoveMoveHandler",true),
		isMoveHandled = gObjFnc("dgsIsMoveHandled"),
		addSizeHandler = gObjFnc("dgsAddSizeHandler",true),
		removeSizeHandler = gObjFnc("dgsRemoveSizeHandler",true),
		isSizeHandled = gObjFnc("dgsIsSizeHandled"),
		attachToTranslation = gObjFnc("dgsAttachToTranslation",true),
		detachFromTranslation = gObjFnc("dgsDetachFromTranslation",true),
		getTranslationName = gObjFnc("dgsGetTranslationName"),
		attach = gObjFnc("dgsAttachElements",true),
		detach = gObjFnc("dgsDetachElements",true),
		isAttached = gObjFnc("dgsElementIsAttached"),
		addDragHandler = gObjFnc("dgsAddDragHandler",true),
		removeDragHandler = gObjFnc("dgsRemoveDragHandler",true),
		addDropHandler = gObjFnc("dgsAddDropHandler",true),
		removeDropHandler = gObjFnc("dgsRemoveDropHandler",true),
		applyDetectArea = function(self,da) return dgsApplyDetectArea(self.dgsElement,da.dgsElement) end,
		removeDetectArea = gObjFnc("dgsRemoveDetectArea",true),
		getDetectArea = gObjFnc("dgsGetDetectArea",true),
	};
	default = {

	};
}

--------------------------Button
class {
	extends = "dgs2D";
	type = "dgsButton";
	dgsType = "dgs-dxbutton";
	preInstantiate = function(parent,x,y,w,h,text,rlt,...)
		return dgsCreateButton(x,y,w,h,text,rlt,parent.dgsElement,...)
	end;
	public = {
		getTextExtent = gObjFnc("dgsButtonGetTextExtent"),
		getFontHeight = gObjFnc("dgsButtonGetFontHeight"),
		getTextSize = gObjFnc("dgsButtonGetTextSize"),
	};
}

--------------------------Browser
class {
	extends = "dgs2D";
	type = "dgsBrowser";
	dgsType = "dgs-dxbrowser";
	preInstantiate = function(parent,x,y,w,h,rlt,...)
		return dgsCreateBrowser(x,y,w,h,rlt,parent.dgsElement,...)
	end;
	public = {
	};
}

--------------------------CheckBox
class {
	extends = "dgs2D";
	type = "dgsCheckBox";
	dgsType = "dgs-dxcheckbox";
	preInstantiate = function(parent,x,y,w,h,text,state,rlt,...)
		return dgsCreateCheckBox(x,y,w,h,text,state,rlt,parent.dgsElement,...)
	end;
	public = {
		getSelected = gObjFnc("dgsCheckBoxGetSelected"),
		setSelected = gObjFnc("dgsCheckBoxSetSelected",true),
		getHorizontalAlign = gObjFnc("dgsCheckBoxGetHorizontalAlign"),
		setHorizontalAlign = gObjFnc("dgsCheckBoxSetHorizontalAlign",true),
		getVerticalAlign = gObjFnc("dgsCheckBoxGetVerticalAlign"),
		setVerticalAlign = gObjFnc("dgsCheckBoxSetVerticalAlign",true),
	};
}

--------------------------ComboBox
class {
	extends = "dgs2D";
	type = "dgsComboBox";
	dgsType = "dgs-dxcombobox";
	preInstantiate = function(parent,x,y,w,h,text,rlt,...)
		return dgsCreateComboBox(x,y,w,h,text,rlt,parent.dgsElement,...)
	end;
	public = {
		addItem = gObjFnc("dgsComboBoxAddItem"),
		removeItem = gObjFnc("dgsComboBoxRemoveItem",true),
		setItemText = gObjFnc("dgsComboBoxSetItemText",true),
		getItemText = gObjFnc("dgsComboBoxGetItemText"),
		clear = gObjFnc("dgsComboBoxClear",true),
		setSelectedItem = gObjFnc("dgsComboBoxSetSelectedItem",true),
		getSelectedItem = gObjFnc("dgsComboBoxGetSelectedItem"),
		setItemColor = gObjFnc("dgsComboBoxSetItemColor",true),
		getItemColor = gObjFnc("dgsComboBoxGetItemColor"),
		setItemData = gObjFnc("dgsComboBoxSetItemData",true),
		getItemData = gObjFnc("dgsComboBoxGetItemData"),
		setItemFont = gObjFnc("dgsComboBoxSetItemFont",true),
		getItemFont = gObjFnc("dgsComboBoxGetItemFont"),
		setItemImage = gObjFnc("dgsComboBoxSetItemImage",true),
		getItemImage = gObjFnc("dgsComboBoxGetItemImage"),
		removeItemImage = gObjFnc("dgsComboBoxRemoveItemImage",true),
		getState = gObjFnc("dgsComboBoxGetState"),
		setState = gObjFnc("dgsComboBoxSetState",true),
		getItemCount = gObjFnc("dgsComboBoxGetItemCount"),
		getBoxHeight = gObjFnc("dgsComboBoxGetBoxHeight"),
		setBoxHeight = gObjFnc("dgsComboBoxSetBoxHeight",true),
		getScrollBar = gObjFnc("dgsComboBoxGetScrollBar"),
		setScrollPosition = gObjFnc("dgsComboBoxSetScrollPosition",true),
		getScrollPosition = gObjFnc("dgsComboBoxGetScrollPosition"),
		setCaptionText = gObjFnc("dgsComboBoxSetCaptionText",true),
		getCaptionText = gObjFnc("dgsComboBoxGetCaptionText"),
		setEditEnabled = gObjFnc("dgsComboBoxSetEditEnabled",true),
		getEditEnabled = gObjFnc("dgsComboBoxGetEditEnabled"),
		setViewCount = gObjFnc("dgsComboBoxSetViewCount",true),
		getViewCount = gObjFnc("dgsComboBoxGetViewCount"),
		getText = gObjFnc("dgsComboBoxGetText"),
	};
}

--------------------------CustomRenderer
class {
	extends = "dgs2D";
	type = "dgsCustomRenderer";
	dgsType = "dgs-dxcustomrenderer";
	preInstantiate = function(parent,customFnc)
		return dgsCreateCustomRenderer(customFnc)
	end;
	public = {
		setFunction = gObjFnc("dgsCustomRendererSetFunction",true),
	};
}

--------------------------DetectArea
class {
	extends = "dgs2D";
	type = "dgsDetectArea";
	dgsType = "dgs-dxdetectarea";
	preInstantiate = function(parent,x,y,w,h,rlt,...)
		return dgsCreateDetectArea(x,y,w,h,rlt,parent.dgsElement,...)
	end;
	public = {
		setFunction = gObjFnc("dgsDetectAreaSetFunction",true),
		setDebugModeEnabled = gObjFnc("dgsDetectAreaSetDebugModeEnabled",true),
		getDebugModeEnabled = gObjFnc("dgsDetectAreaGetDebugModeEnabled"),
	};
}

--------------------------Edit
class {
	extends = "dgs2D";
	type = "dgsEdit";
	dgsType = "dgs-dxedit";
	preInstantiate = function(parent,x,y,w,h,text,rlt,...)
		return dgsCreateEdit(x,y,w,h,text,rlt,parent.dgsElement,...)
	end;
	public = {
		moveCaret = gObjFnc("dgsEditMoveCaret",true),
		setCaretPosition = gObjFnc("dgsEditSetCaretPosition",true),
		getCaretPosition = gObjFnc("dgsEditGetCaretPosition"),
		setCaretStyle = gObjFnc("dgsEditSetCaretStyle",true),
		getCaretStyle = gObjFnc("dgsEditGetCaretStyle"),
		setWhiteList = gObjFnc("dgsEditSetWhiteList",true),
		setMaxLength = gObjFnc("dgsEditSetMaxLength",true),
		getMaxLength = gObjFnc("dgsEditGetMaxLength"),
		setReadOnly = gObjFnc("dgsEditSetReadOnly",true),
		getReadOnly = gObjFnc("dgsEditGetReadOnly"),
		setMasked = gObjFnc("dgsEditSetMasked",true),
		getMasked = gObjFnc("dgsEditGetMasked"),
		setUnderlined = gObjFnc("dgsEditSetUnderlined",true),
		getUnderlined = gObjFnc("dgsEditGetUnderlined"),
		setHorizontalAlign = gObjFnc("dgsEditSetHorizontalAlign",true),
		getHorizontalAlign = gObjFnc("dgsEditGetHorizontalAlign"),
		setVerticalAlign = gObjFnc("dgsEditSetVerticalAlign",true),
		getVerticalAlign = gObjFnc("dgsEditGetVerticalAlign"),
		setAlignment = gObjFnc("dgsEditSetAlignment",true),
		getAlignment = gObjFnc("dgsEditGetAlignment"),
		insertText = gObjFnc("dgsEditInsertText",true),
		deleteText = gObjFnc("dgsEditDeleteText",true),
		getPartOfText = gObjFnc("dgsEditGetPartOfText"),
		clearText = gObjFnc("dgsEditClearText",true),
		replaceText = gObjFnc("dgsEditReplaceText",true),
		setTypingSound = gObjFnc("dgsEditSetTypingSound",true),
		getTypingSound = gObjFnc("dgsEditGetTypingSound"),
		setTypingSoundVolume = gObjFnc("dgsEditSetTypingSoundVolume",true),
		getTypingSoundVolume = gObjFnc("dgsEditGetTypingSoundVolume"),
		setPlaceHolder = gObjFnc("dgsEditSetPlaceHolder",true),
		getPlaceHolder = gObjFnc("dgsEditGetPlaceHolder"),
		setAutoComplete = gObjFnc("dgsEditSetAutoComplete",true),
		getAutoComplete = gObjFnc("dgsEditGetAutoComplete"),
		addAutoComplete = gObjFnc("dgsEditAddAutoComplete",true),
		removeAutoComplete = gObjFnc("dgsEditRemoveAutoComplete",true),
	};
}
--------------------------GridList
class {
	extends = "dgs2D";
	type = "dgsGridList";
	dgsType = "dgs-dxgridlist";
	preInstantiate = function(parent,x,y,w,h,rlt,...)
		return dgsCreateGridList(x,y,w,h,rlt,parent.dgsElement,...)
	end;
	public = {
		getScrollBar = gObjFnc("dgsGridListGetScrollBar"),
		setScrollPosition = gObjFnc("dgsGridListSetScrollPosition",true),
		getScrollPosition = gObjFnc("dgsGridListGetScrollPosition"),
		scollTo = gObjFnc("dgsGridListScrollTo",true),
		setHorizontalScrollPosition = gObjFnc("dgsGridListSetHorizontalScrollPosition",true),
		getHorizontalScrollPosition = gObjFnc("dgsGridListGetHorizontalScrollPosition"),
		setVerticalScrollPosition = gObjFnc("dgsGridListSetVerticalScrollPosition",true),
		getVerticalScrollPosition = gObjFnc("dgsGridListGetVerticalScrollPosition"),
		resetScrollBarPosition = gObjFnc("dgsGridListResetScrollBarPosition",true),
		setColumnRelative = gObjFnc("dgsGridListSetColumnRelative",true),
		getColumnRelative = gObjFnc("dgsGridListGetColumnRelative"),
		addColumn = gObjFnc("dgsGridListAddColumn"),
		getColumnCount = gObjFnc("dgsGridListGetColumnCount"),
		removeColumn = gObjFnc("dgsGridListRemoveColumn",true),
		getColumnAllWidth = gObjFnc("dgsGridListGetColumnAllWidth"),
		getColumnHeight = gObjFnc("dgsGridListGetColumnHeight"),
		setColumnHeight = gObjFnc("dgsGridListSetColumnHeight",true),
		getColumnWidth = gObjFnc("dgsGridListGetColumnWidth"),
		setColumnWidth = gObjFnc("dgsGridListSetColumnWidth",true),
		autoSizeColumn = gObjFnc("dgsGridListAutoSizeColumn",true),
		getColumnTitle = gObjFnc("dgsGridListGetColumnTitle"),
		setColumnTitle = gObjFnc("dgsGridListSetColumnTitle",true),
		getColumnFont = gObjFnc("dgsGridListGetColumnFont"),
		setColumnFont = gObjFnc("dgsGridListSetColumnFont",true),
		getColumnAlignment = gObjFnc("dgsGridListGetColumnAlignment"),
		setColumnAlignment = gObjFnc("dgsGridListSetColumnAlignment",true),
		addRow = gObjFnc("dgsGridListAddRow"),
		insertRowAfter = gObjFnc("dgsGridListInsertRowAfter"),
		removeRow = gObjFnc("dgsGridListRemoveRow",true),
		clearRow = gObjFnc("dgsGridListClearRow",true),
		clearColumn = gObjFnc("dgsGridListClearColumn",true),
		clear = gObjFnc("dgsGridListClear",true),
		getRowCount = gObjFnc("dgsGridListGetRowCount"),
		setItemText = gObjFnc("dgsGridListSetItemText",true),
		getItemText = gObjFnc("dgsGridListGetItemText"),
		setItemTextOffset = gObjFnc("dgsGridListSetItemTextOffset",true),
		getItemTextOffset = gObjFnc("dgsGridListGetItemTextOffset"),
		getItemAlignment = gObjFnc("dgsGridListGetItemAlignment"),
		setItemAlignment = gObjFnc("dgsGridListSetItemAlignment",true),
		getPreselectedItem = gObjFnc("dgsGridListGetPreselectedItem"),
		getSelectedItem = gObjFnc("dgsGridListGetSelectedItem"),
		setSelectedItem = gObjFnc("dgsGridListSetSelectedItem",true),
		setItemColor = gObjFnc("dgsGridListSetItemColor",true),
		getItemColor = gObjFnc("dgsGridListGetItemColor"),
		setItemData = gObjFnc("dgsGridListSetItemData",true),
		getItemData = gObjFnc("dgsGridListGetItemData"),
		setItemImage = gObjFnc("dgsGridListSetItemImage",true),
		getItemImage = gObjFnc("dgsGridListGetItemImage"),
		getItemBackGroundImage = gObjFnc("dgsGridListGetItemBackGroundImage"),
		setItemBackGroundImage = gObjFnc("dgsGridListSetItemBackGroundImage",true),
		getItemBackGroundColor = gObjFnc("dgsGridListGetItemBackGroundColor"),
		setItemBackGroundColor = gObjFnc("dgsGridListSetItemBackGroundColor",true),
		setItemBackGroundColorTemplate = gObjFnc("dgsGridListSetItemBackGroundColorTemplate",true),
		removeItemImage = gObjFnc("dgsGridListRemoveItemImage",true),
		getRowBackGroundImage = gObjFnc("dgsGridListGetRowBackGroundImage"),
		setRowBackGroundImage = gObjFnc("dgsGridListSetRowBackGroundImage",true),
		getRowBackGroundColor = gObjFnc("dgsGridListGetRowBackGroundColor"),
		setRowBackGroundColor = gObjFnc("dgsGridListSetRowBackGroundColor",true),
		setRowAsSection = gObjFnc("dgsGridListSetRowAsSection",true),
		selectItem = gObjFnc("dgsGridListSelectItem",true),
		itemIsSelected = gObjFnc("dgsGridListItemIsSelected"),
		setMultiSelectionEnabled = gObjFnc("dgsGridListSetMultiSelectionEnabled",true),
		getMultiSelectionEnabled = gObjFnc("dgsGridListGetMultiSelectionEnabled"),
		setSelectionMode = gObjFnc("dgsGridListSetSelectionMode",true),
		getSelectionMode = gObjFnc("dgsGridListGetSelectionMode"),
		setSelectedItems = gObjFnc("dgsGridListSetSelectedItems",true),
		getSelectedItems = gObjFnc("dgsGridListGetSelectedItems"),
		getSelectedCount = gObjFnc("dgsGridListGetSelectedCount"),
		setSortFunction = gObjFnc("dgsGridListSetSortFunction",true),
		setAutoSortEnabled = gObjFnc("dgsGridListSetAutoSortEnabled",true),
		getAutoSortEnabled = gObjFnc("dgsGridListGetAutoSortEnabled"),
		setSortEnabled = gObjFnc("dgsGridListSetSortEnabled",true),
		getSortEnabled = gObjFnc("dgsGridListGetSortEnabled"),
		setSortColumn = gObjFnc("dgsGridListSetSortColumn",true),
		getSortColumn = gObjFnc("dgsGridListGetSortColumn"),
		getEnterColumn = gObjFnc("dgsGridListGetEnterColumn"),
		sort = gObjFnc("dgsGridListSort",true),
		setNavigationEnabled = gObjFnc("dgsGridListSetNavigationEnabled",true),
		getNavigationEnabled = gObjFnc("dgsGridListGetNavigationEnabled"),
		setItemTextSize = gObjFnc("dgsGridListSetItemTextSize",true),
		getItemTextSize = gObjFnc("dgsGridListGetItemTextSize"),
		setColumnTextSize = gObjFnc("dgsGridListSetColumnTextSize",true),
		getColumnTextSize = gObjFnc("dgsGridListGetColumnTextSize"),
		setItemFont = gObjFnc("dgsGridListSetItemFont",true),
		getItemFont = gObjFnc("dgsGridListGetItemFont"),
		setRowSelectable = gObjFnc("dgsGridListSetRowSelectable",true),
		getRowSelectable = gObjFnc("dgsGridListGetRowSelectable"),
		setRowHoverable = gObjFnc("dgsGridListSetRowHoverable",true),
		getRowHoverable = gObjFnc("dgsGridListGetRowHoverable"),
		setItemSelectable = gObjFnc("dgsGridListSetItemSelectable",true),
		getItemSelectable = gObjFnc("dgsGridListGetItemSelectable"),
		setItemHoverable = gObjFnc("dgsGridListSetItemHoverable",true),
		getItemHoverable = gObjFnc("dgsGridListGetItemHoverable"),
	};
}

--------------------------Image
class {
	extends = "dgs2D";
	type = "dgsImage";
	dgsType = "dgs-dximage";
	preInstantiate = function(parent,x,y,w,h,image,rlt,...)
		if type(image) == "table" then image = image.dgsElement or image end
		return dgsCreateImage(x,y,w,h,image,rlt,parent.dgsElement,...)
	end;
	public = {
		setImage = gObjFnc("dgsImageSetImage",true),
		getImage = gObjFnc("dgsImageGetImage"),
		setUVSize = gObjFnc("dgsImageSetUVSize",true),
		getUVSize = gObjFnc("dgsImageGetUVSize"),
		setUVPosition = gObjFnc("dgsImageSetUVPosition",true),
		getUVPosition = gObjFnc("dgsImageGetUVPosition"),
	};
}

--------------------------Label
class {
	extends = "dgs2D";
	type = "dgsLabel";
	dgsType = "dgs-dxlabel";
	preInstantiate = function(parent,x,y,w,h,text,rlt,...)
		return dgsCreateLabel(x,y,w,h,text,rlt,parent.dgsElement,...)
	end;
	public = {
		setColor = gObjFnc("dgsLabelSetColor",true),
		getColor = gObjFnc("dgsLabelGetColor"),
		setHorizontalAlign = gObjFnc("dgsLabelSetHorizontalAlign",true),
		getHorizontalAlign = gObjFnc("dgsLabelGetHorizontalAlign"),
		setVerticalAlign = gObjFnc("dgsLabelSetVerticalAlign",true),
		getVerticalAlign = gObjFnc("dgsLabelGetVerticalAlign"),
		getTextExtent = gObjFnc("dgsLabelGetTextExtent"),
		getFontHeight = gObjFnc("dgsLabelGetFontHeight"),
	};
}

--------------------------Line
class {
	extends = "dgs2D";
	type = "dgsLine";
	dgsType="dgs-dxline";
	preInstantiate = function(parent,x,y,w,h,rlt,...)
		return dgsCreateLine(x,y,w,h,rlt,parent.dgsElement,...)
	end;
	public = {
		addItem = gObjFnc("dgsLineAddItem"),
		removeItem = gObjFnc("dgsLineRemoveItem",true),
		getItemWidth = gObjFnc("dgsLineGetItemWidth"),
		setItemWidth = gObjFnc("dgsLineSetItemWidth",true),
		getItemColor = gObjFnc("dgsLineGetItemColor"),
		setItemColor = gObjFnc("dgsLineSetItemColor",true),
		getItemPosition = gObjFnc("dgsLineGetItemPosition"),
		setItemPosition = gObjFnc("dgsLineSetItemPosition",true),
	};
}

--------------------------Memo
class {
	extends = "dgs2D";
	type = "dgsMemo";
	dgsType = "dgs-dxmemo";
	preInstantiate = function(parent,x,y,w,h,text,rlt,...)
		return dgsCreateMemo(x,y,w,h,text,rlt,parent.dgsElement,...)
	end;
	public = {
		moveCaret = gObjFnc("dgsMemoMoveCaret",true),
		seekPosition = gObjFnc("dgsMemoSeekPosition"),
		getScrollBar = gObjFnc("dgsMemoGetScrollBar"),
		setScrollPosition = gObjFnc("dgsMemoSetScrollPosition",true),
		getScrollPosition = gObjFnc("dgsMemoGetScrollPosition"),
		setHorizontalScrollPosition = gObjFnc("dgsMemoSetHorizontalScrollPosition",true),
		getHorizontalScrollPosition = gObjFnc("dgsMemoGetHorizontalScrollPosition"),
		setVerticalScrollPosition = gObjFnc("dgsMemoSetVerticalScrollPosition",true),
		getVerticalScrollPosition = gObjFnc("dgsMemoGetVerticalScrollPosition"),
		setCaretPosition = gObjFnc("dgsMemoSetCaretPosition",true),
		getCaretPosition = gObjFnc("dgsMemoGetCaretPosition"),
		setCaretStyle = gObjFnc("dgsMemoSetCaretStyle",true),
		getCaretStyle = gObjFnc("dgsMemoGetCaretStyle"),
		setReadOnly = gObjFnc("dgsMemoSetReadOnly",true),
		getReadOnly = gObjFnc("dgsMemoGetReadOnly"),
		getPartOfText = gObjFnc("dgsMemoGetPartOfText"),
		deleteText = gObjFnc("dgsMemoDeleteText",true),
		insertText = gObjFnc("dgsMemoInsertText",true),
		appendText = gObjFnc("dgsMemoAppendText",true),
		clearText = gObjFnc("dgsMemoClearText",true),
		getTextBoundingBox = gObjFnc("dgsMemoGetTextBoundingBox"),
		getTypingSound = gObjFnc("dgsMemoGetTypingSound"),
		setTypingSound = gObjFnc("dgsMemoSetTypingSound",true),
		getTypingSoundVolume = gObjFnc("dgsMemoGetTypingSoundVolume"),
		setTypingSoundVolume = gObjFnc("dgsMemoSetTypingSoundVolume",true),
		getLineCount = gObjFnc("dgsMemoGetLineCount"),
		setWordWrapState = gObjFnc("dgsMemoSetWordWrapState",true),
		getWordWrapState = gObjFnc("dgsMemoGetWordWrapState"),
		setScrollBarState = gObjFnc("dgsMemoSetScrollBarState",true),
		getScrollBarState = gObjFnc("dgsMemoGetScrollBarState"),
	};
}

--------------------------ProgressBar
class {
	extends = "dgs2D";
	type = "dgsProgressBar";
	dgsType = "dgs-dxprogressbar";
	preInstantiate = function(parent,x,y,w,h,rlt,...)
		return dgsCreateProgressBar(x,y,w,h,rlt,parent.dgsElement,...)
	end;
	public = {
		getProgress = gObjFnc("dgsProgressBarGetProgress"),
		setProgress = gObjFnc("dgsProgressBarSetProgress",true),
		getMode = gObjFnc("dgsProgressBarGetMode"),
		setMode = gObjFnc("dgsProgressBarSetMode",true),
		getVerticalSide = gObjFnc("dgsProgressBarGetVerticalSide"),
		setVerticalSide = gObjFnc("dgsProgressBarSetVerticalSide",true),
		getHorizontalSide = gObjFnc("dgsProgressBarGetHorizontalSide"),
		setHorizontalSide = gObjFnc("dgsProgressBarSetHorizontalSide",true),
		getStyle = gObjFnc("dgsProgressBarGetStyle"),
		setStyle = gObjFnc("dgsProgressBarSetStyle",true),
		getStyleProperties = gObjFnc("dgsProgressBarGetStyleProperties"),
		setStyleProperty = gObjFnc("dgsProgressBarSetStyleProperty",true),
		getStyleProperty = gObjFnc("dgsProgressBarGetStyleProperty"),
	};
}

--------------------------RadioButton
class {
	extends = "dgs2D";
	type = "dgsRadioButton";
	dgsType = "dgs-dxradiobutton";
	preInstantiate = function(parent,x,y,w,h,text,rlt,...)
		return dgsCreateRadioButton(x,y,w,h,text,rlt,parent.dgsElement,...)
	end;
	public = {
		getSelected = gObjFnc("dgsRadioButtonGetSelected"),
		setSelected = gObjFnc("dgsRadioButtonSetSelected",true),
		getHorizontalAlign = gObjFnc("dgsRadioButtonGetHorizontalAlign"),
		setHorizontalAlign = gObjFnc("dgsRadioButtonSetHorizontalAlign",true),
		getVerticalAlign = gObjFnc("dgsRadioButtonGetVerticalAlign"),
		setVerticalAlign = gObjFnc("dgsRadioButtonSetVerticalAlign",true),
	};
}

--------------------------ScrollBar
class {
	extends = "dgs2D";
	type = "dgsScrollBar";
	dgsType = "dgs-dxscrollbar";
	preInstantiate = function(parent,x,y,w,h,voh,rlt,...)
		return dgsCreateScrollBar(x,y,w,h,voh,rlt,parent.dgsElement,...)
	end;
	public = {
		setScrollPosition = gObjFnc("dgsScrollBarSetScrollPosition",true),
		getScrollPosition = gObjFnc("dgsScrollBarGetScrollPosition"),
		setCursorLength = gObjFnc("dgsScrollBarSetCursorLength",true),
		getCursorLength = gObjFnc("dgsScrollBarGetCursorLength"),
		setLocked = gObjFnc("dgsScrollBarSetLocked",true),
		getLocked = gObjFnc("dgsScrollBarGetLocked"),
		setGrades = gObjFnc("dgsScrollBarSetGrades",true),
		getGrades = gObjFnc("dgsScrollBarGetGrades"),
		setCursorWidth = gObjFnc("dgsScrollBarSetCursorWidth",true),
		getCursorWidth = gObjFnc("dgsScrollBarGetCursorWidth"),
		setTroughWidth = gObjFnc("dgsScrollBarSetTroughWidth",true),
		getTroughWidth = gObjFnc("dgsScrollBarGetTroughWidth"),
		setArrowSize = gObjFnc("dgsScrollBarSetArrowSize",true),
		getArrowSize = gObjFnc("dgsScrollBarGetArrowSize"),
	};
}

--------------------------ScrollPane
class {
	extends = "dgs2D";
	type = "dgsScrollPane";
	dgsType = "dgs-dxscrollpane";
	preInstantiate = function(parent,x,y,w,h,rlt,...)
		return dgsCreateScrollPane(x,y,w,h,rlt,parent.dgsElement,...)
	end;
	public = {
		getScrollBar = gObjFnc("dgsScrollPaneGetScrollBar"),
		setScrollPosition = gObjFnc("dgsScrollPaneSetScrollPosition",true),
		getScrollPosition = gObjFnc("dgsScrollPaneGetScrollPosition"),
		setHorizontalScrollPosition = gObjFnc("dgsScrollPaneSetHorizontalScrollPosition",true),
		getHorizontalScrollPosition = gObjFnc("dgsScrollPaneGetHorizontalScrollPosition"),
		setVerticalScrollPosition = gObjFnc("dgsScrollPaneSetVerticalScrollPosition",true),
		getVerticalScrollPosition = gObjFnc("dgsScrollPaneGetVerticalScrollPosition"),
		setScrollBarState = gObjFnc("dgsScrollPaneSetScrollBarState",true),
		getScrollBarState = gObjFnc("dgsScrollPaneGetScrollBarState"),
		setViewOffset = gObjFnc("dgsScrollPaneSetViewOffset",true),
		getViewOffset = gObjFnc("dgsScrollPaneGetViewOffset"),
	};
}
--------------------------ScalePane
class {
	extends = "dgs2D";
	type = "dgsScalePane";
	dgsType = "dgs-dxscalepane";
	preInstantiate = function(parent,x,y,w,h,rlt,...)
		return dgsCreateScalePane(x,y,w,h,rlt,parent.dgsElement,...)
	end;
	public = {
		getScrollBar = gObjFnc("dgsScalePaneGetScrollBar"),
		setScrollPosition = gObjFnc("dgsScalePaneSetScrollPosition",true),
		getScrollPosition = gObjFnc("dgsScalePaneGetScrollPosition"),
		setHorizontalScrollPosition = gObjFnc("dgsScalePaneSetHorizontalScrollPosition",true),
		getHorizontalScrollPosition = gObjFnc("dgsScalePaneGetHorizontalScrollPosition"),
		setVerticalScrollPosition = gObjFnc("dgsScalePaneSetVerticalScrollPosition",true),
		getVerticalScrollPosition = gObjFnc("dgsScalePaneGetVerticalScrollPosition"),
		setScrollBarState = gObjFnc("dgsScalePaneSetScrollBarState",true),
		getScrollBarState = gObjFnc("dgsScalePaneGetScrollBarState"),
	};
}
--------------------------Selector
class {
	extends = "dgs2D";
	type = "dgsSelector";
	dgsType = "dgs-dxselector";
	preInstantiate = function(parent,x,y,w,h,rlt,...)
		return dgsCreateSelector(x,y,w,h,rlt,parent.dgsElement,...)
	end;
	public = {
		addItem = gObjFnc("dgsSelectorAddItem"),
		removeItem = gObjFnc("dgsSelectorRemoveItem",true),
		setSelectedItem = gObjFnc("dgsSelectorSetSelectedItem",true),
		getSelectedItem = gObjFnc("dgsSelectorGetSelectedItem"),
		setItemText = gObjFnc("dgsSelectorSetItemText",true),
		getItemText = gObjFnc("dgsSelectorGetItemText"),
		setItemData = gObjFnc("dgsSelectorSetItemData",true),
		getItemData = gObjFnc("dgsSelectorGetItemData"),
		setItemColor = gObjFnc("dgsSelectorSetItemColor"),
		getItemColor = gObjFnc("dgsSelectorGetItemColor"),
		setItemFont = gObjFnc("dgsSelectorSetItemFont"),
		getItemFont = gObjFnc("dgsSelectorGetItemFont"),
		setItemTextSize = gObjFnc("dgsSelectorSetItemTextSize"),
		getItemTextSize = gObjFnc("dgsSelectorGetItemTextSize"),
		setItemAlignment = gObjFnc("dgsSelectorSetItemAlignment"),
		getItemAlignment = gObjFnc("dgsSelectorGetItemAlignment"),
		setItemImage = gObjFnc("dgsSelectorSetItemImage"),
		getItemImage = gObjFnc("dgsSelectorGetItemImage"),
		removeItemImage = gObjFnc("dgsSelectorRemoveItemImage"),
	};
}

--------------------------SwitchButton
class {
	extends = "dgs2D";
	type = "dgsSwitchButton";
	dgsType = "dgs-dxswitchbutton";
	preInstantiate = function(parent,x,y,w,h,textOn,textOff,state,rlt,...)
		return dgsCreateSwitchButton(x,y,w,h,textOn,textOff,state,rlt,parent.dgsElement,...)
	end;
	public = {
		setState = gObjFnc("dgsSwitchButtonSetState",true),
		getState = gObjFnc("dgsSwitchButtonGetState"),
		setText = gObjFnc("dgsSwitchButtonSetText",true),
		getText = gObjFnc("dgsSwitchButtonGetText"),
	};
}

--------------------------Tab
class {
	extends = "dgsBasic";
	type = "dgsTab";
	dgsType = "dgs-dxtab";
	preInstantiate = function(parent,text,...)
		return dgsCreateTab(text,parent.dgsElement,...)
	end;
	public = {
		delete = gObjFnc("dgsDeleteTab"),
	};
}

--------------------------TabPanel
class {
	extends = "dgs2D";
	type = "dgsTabPanel";
	dgsType = "dgs-dxtabpanel";
	preInstantiate = function(parent,x,y,w,h,rlt,...)
		return dgsCreateTabPanel(x,y,w,h,rlt,parent.dgsElement,...)
	end;
	public = {
		getSelectedTab = gObjFnc("dgsGetSelectedTab"),
		setSelectedTab = gObjFnc("dgsSetSelectedTab",true),
		getTabFromID = gObjFnc("dgsTabPanelGetTabFromID"),
		moveTab = gObjFnc("dgsTabPanelMoveTab",true),
		getTabID = gObjFnc("dgsTabPanelGetTabID"),
		dgsTab = function(...) return dgsOOP.dgsTab(...) end,
	};
}

--------------------------Window
class {
	extends = "dgs2D";
	type = "dgsWindow";
	dgsType = "dgs-dxwindow";
	preInstantiate = function(parent,...)
		local window = dgsCreateWindow(...)
		dgsSetParent(window,parent.dgsElement)
		return window
	end;
	public = {
		setSizable = gObjFnc("dgsWindowSetSizable",true),
		setMovable = gObjFnc("dgsWindowSetMovable",true),
		getSizable = gObjFnc("dgsWindowGetSizable"),
		getMovable = gObjFnc("dgsWindowGetMovable"),
		close = gObjFnc("dgsCloseWindow"),
		setCloseButtonEnabled = gObjFnc("dgsWindowSetCloseButtonEnabled",true),
		getCloseButtonEnabled = gObjFnc("dgsWindowGetCloseButtonEnabled"),
		setCloseButtonSize = gObjFnc("dgsWindowSetCloseButtonSize",true),
		getCloseButtonSize = gObjFnc("dgsWindowGetCloseButtonSize"),
		getCloseButton = gObjFnc("dgsWindowGetCloseButton"),
		getHorizontalAlign = gObjFnc("dgsWindowGetHorizontalAlign"),
		setHorizontalAlign = gObjFnc("dgsWindowSetHorizontalAlign",true),
		getVerticalAlign = gObjFnc("dgsWindowGetVerticalAlign"),
		setVerticalAlign = gObjFnc("dgsWindowSetVerticalAlign",true),
		getTextExtent = gObjFnc("dgsWindowGetTextExtent"),
		getFontHeight = gObjFnc("dgsWindowGetFontHeight"),
		getTextSize = gObjFnc("dgsWindowGetTextSize"),
	};
}

----------------------------------------------------------
----------------------------------------------------DGS 3D
----------------------------------------------------------
----------------DGS 3D
dgsOOP.position3D = {
	__index=function(self,key)
		local meta = getmetatable(self)
		if not isElement(meta.dgsElement) then return false end
		if key == "x" then
			local pos = dgsGetProperty(meta.dgsElement,"position")
			return pos[1]
		elseif key == "y" then
			local pos = dgsGetProperty(meta.dgsElement,"position")
			return pos[2]
		elseif key == "z" then
			local pos = dgsGetProperty(meta.dgsElement,"position")
			return pos[3]
		elseif key == "toVector" then
			return Vector3(dgsGetProperty(meta.dgsElement,"position"))
		end
	end,
	__newindex=function(self,key,value)
		local meta = getmetatable(self)
		if not isElement(meta.dgsElement) then return false end
		if key == "x" then
			local pos = dgsGetProperty(meta.dgsElement,"position")
			pos[1] = value
			return dgsSetProperty(meta.dgsElement,"position",pos)
		elseif key == "y" then
			local pos = dgsGetProperty(meta.dgsElement,"position")
			pos[2] = value
			return dgsSetProperty(meta.dgsElement,"position",pos)
		elseif key == "z" then
			local pos = dgsGetProperty(meta.dgsElement,"position")
			pos[3] = value
			return dgsSetProperty(meta.dgsElement,"position",pos)
		end
	end,
	__call=function(self,key)
		local meta = getmetatable(self)
		setmetatable(self,nil)
		self[1],self[2],self[3] = dgsGetProperty(meta.dgsElement,"position")
		setmetatable(self,meta)
		return self
	end,
}

class {
	extends = "dgsBasic";
	type = "dgs3D";
	public = {
		__index=function(self,key)
			if key == "children" then
				return self:getChildren()
			elseif key == "position" then
				return dgsOOP.genInterface(self.dgsElement,dgsOOP.position3D)
			end
			return dgsGetProperty(self.dgsElement,key)
		end,
		__newindex=function(self,key,value)
			if key == "position" then
				local vType = dgsOOP.getVectorType(value)
				if vType == "table" then
					return dgsSetProperty(self.dgsElement,"position",value[1] or value.x,value[2] or value.y,value[3] or value.z)
				elseif vType == 3 then
					return dgsSetProperty(self.dgsElement,"position",value.x,value.y,value.z)
				end
			end
			return dgsSetProperty(self.dgsElement,key,value) and self or false
		end,
		getChild = gObjFnc("dgsGetChild"),
		getChildren = gObjFnc("dgsGetChildren"),
		getType = gObjFnc("dgsGetType"),
		getProperty = gObjFnc("dgsGetProperty"),
		setProperty = gObjFnc("dgsSetProperty",true),
		getProperties = function(self,...) return dgsGetProperties(self.dgsElement,...) end,
		setProperties = gObjFnc("dgsSetProperties",true),
		getVisible = gObjFnc("dgsGetVisible"),
		setVisible = gObjFnc("dgsSetVisible",true),
		getEnabled = gObjFnc("dgsGetEnabled"),
		setEnabled = gObjFnc("dgsSetEnabled",true),
		blur = gObjFnc("dgsBlur",true),
		focus = gObjFnc("dgsFocus",true),
		getAlpha = gObjFnc("dgsGetAlpha"),
		setAlpha = gObjFnc("dgsSetAlpha",true),
		bringToFront = gObjFnc("dgsBringToFront",true),
		moveToBack = gObjFnc("dgsMoveToBack",true),
		simulateClick = gObjFnc("dgsSimulateClick",true),
		animTo = gObjFnc("dgsAnimTo",true),
		isAniming = gObjFnc("dgsIsAniming"),
		stopAniming = gObjFnc("dgsStopAniming",true),
		alphaTo = gObjFnc("dgsAlphaTo",true),
		isAlphaing = gObjFnc("dgsIsAlphaing"),
		stopAlphaing = gObjFnc("dgsStopAlphaing",true),
		getPostGUI = gObjFnc("dgsGetPostGUI"),
		setPostGUI = gObjFnc("dgsSetPostGUI",true),
		destroy = function(self) return destroyElement(self.dgsElement) end,
		isElement = gObjFnc("isElement",true),
		getElement = function(self) return self.dgsElement end,
		attachToTranslation = gObjFnc("dgsAttachToTranslation",true),
		detachFromTranslation = gObjFnc("dgsDetachFromTranslation",true),
		getTranslationName = gObjFnc("dgsGetTranslationName"),
		getPosition = gObjFnc("dgs3DGetPosition"),
		setPosition = gObjFnc("dgs3DSetPosition",true),
		getDimension = gObjFnc("dgs3DGetDimension"),
		setDimension = gObjFnc("dgs3DSetDimension",true),
		getInterior = gObjFnc("dgs3DGetInterior"),
		setInterior = gObjFnc("dgs3DSetInterior",true),
	};
}

class {
	extends = "dgs3D";
	type = "dgs3DInterface";
	dgsType="dgs-dx3dinterface";
	preInstantiate = function(parent,...)
		return dgsCreate3DInterface(...)
	end;
	public = {
		getBlendMode = gObjFnc("dgs3DInterfaceGetBlendMode"),
		setBlendMode = gObjFnc("dgs3DInterfaceSetBlendMode",true),
		getSize = gObjFnc("dgs3DInterfaceGetSize"),
		setSize = gObjFnc("dgs3DInterfaceSetSize",true),
		getResolution = gObjFnc("dgs3DInterfaceGetResolution"),
		setResolution = gObjFnc("dgs3DInterfaceSetResolution",true),
		attachToElement = gObjFnc("dgs3DInterfaceAttachToElement",true),
		isAttached = gObjFnc("dgs3DInterfaceIsAttached",true),
		getResolution = gObjFnc("dgs3DInterfaceGetResolution"),
		setResolution = gObjFnc("dgs3DInterfaceSetResolution",true),
		detachFromElement = gObjFnc("dgs3DInterfaceDetachFromElement",true),
		setAttachedOffsets = gObjFnc("dgs3DInterfaceSetAttachedOffsets",true),
		getAttachedOffsets = gObjFnc("dgs3DInterfaceGetAttachedOffsets"),
		setRoll = gObjFnc("dgs3DInterfaceSetRoll",true),
		getRoll = gObjFnc("dgs3DInterfaceGetRoll"),
		setFaceTo = gObjFnc("dgs3DInterfaceSetFaceTo",true),
		getFaceTo = gObjFnc("dgs3DInterfaceGetFaceTo"),
	};
}

class {
	extends = "dgs3D";
	type = "dgs3DText";
	dgsType="dgs-dx3dtext";
	preInstantiate = function(parent,...)
		return dgsCreate3DText(...)
	end;
	public = {
		attachToElement = gObjFnc("dgs3DTextAttachToElement",true),
		detachFromElement = gObjFnc("dgs3DTextDetachFromElement",true),
		isAttached = gObjFnc("dgs3DTextIsAttached"),
		setAttachedOffsets = gObjFnc("dgs3DTextSetAttachedOffsets",true),
		getAttachedOffsets = gObjFnc("dgs3DTextGetAttachedOffsets"),
		getText = gObjFnc("dgsGetText"),
		setText = gObjFnc("dgsSetText",true),
	};
}

class {
	extends = "dgs3D";
	type = "dgs3DImage";
	dgsType="dgs-dx3dimage";
	preInstantiate = function(parent,...)
		return dgsCreate3DImage(...)
	end;
	public = {
		getSize = gObjFnc("dgs3DImageGetSize"),
		setSize = gObjFnc("dgs3DImageSetSize",true),
		getImage = gObjFnc("dgs3DImageGetImage"),
		setImage = gObjFnc("dgs3DImageSetImage",true),
		attachToElement = gObjFnc("dgs3DImageAttachToElement",true),
		detachFromElement = gObjFnc("dgs3DImageDetachFromElement",true),
		isAttached = gObjFnc("dgs3DImageIsAttached"),
		setAttachedOffsets = gObjFnc("dgs3DImageSetAttachedOffsets",true),
		getAttachedOffsets = gObjFnc("dgs3DImageGetAttachedOffsets"),
	};
}

class {
	extends = "dgs3D";
	type = "dgs3DLine";
	dgsType="dgs-dx3dline";
	preInstantiate = function(parent,...)
		return dgsCreate3DLine(...)
	end;
	public = {
		addItem = gObjFnc("dgs3DLineAddItem"),
		removeItem = gObjFnc("dgs3DLineRemoveItem",true),
		getItemWidth = gObjFnc("dgs3DLineGetItemWidth"),
		setItemWidth = gObjFnc("dgs3DLineSetItemWidth",true),
		getItemColor = gObjFnc("dgs3DLineGetItemColor"),
		setItemColor = gObjFnc("dgs3DLineSetItemColor",true),
		attachToElement = gObjFnc("dgs3DLineAttachToElement",true),
		detachFromElement = gObjFnc("dgs3DLineDetachFromElement",true),
		isAttached = gObjFnc("dgs3DLineIsAttached"),
		setAttachedOffsets = gObjFnc("dgs3DLineSetAttachedOffsets",true),
		getAttachedOffsets = gObjFnc("dgs3DLineGetAttachedOffsets"),
		setRotation = gObjFnc("dgs3DLineSetRotation",true),
		getRotation = gObjFnc("dgs3DLineGetRotation"),
	};
}
----------------------------------------------------------
--------------------------------------DGS Built-in Plugins
----------------------------------------------------------
----------------DGS Plugins
class {
	extends = "dgsRoot";
	type = "dgsPlugin";
	public = {
		__index=function(self,key)
			return dgsGetProperty(self.dgsElement,key)
		end,
		__newindex=function(self,key,value)
			return dgsSetProperty(self.dgsElement,key,value) and self or false
		end,
		getPluginType = gObjFnc("dgsGetPluginType"),
		getProperty = gObjFnc("dgsGetProperty"),
		setProperty = gObjFnc("dgsSetProperty",true),
		getProperties = function(self,...) return dgsGetProperties(self.dgsElement,...) end,
		setProperties = gObjFnc("dgsSetProperties",true),
		destroy = function(self) return destroyElement(self.dgsElement) end;
		isElement = gObjFnc("isElement",true);
		getElement = function(self) return self.dgsElement end,
	};
}

--------------------------SVG
-----------------Utils
class {
	type = "xmlNode";
	dgsType = "xml-node";
	public = {
		getAttribute = gObjFncMTA("xmlNodeGetAttribute"),
		getAttributes = gObjFncMTA("xmlNodeGetAttributes"),
		getChildren = gObjFncMTA("xmlNodeGetChildren"),
		getName = gObjFncMTA("xmlNodeGetName"),
		getParent = gObjFncMTA("xmlNodeGetParent"),
		getValue = gObjFncMTA("xmlNodeGetValue"),
		setAttribute = gObjFncMTA("xmlNodeSetAttribute"),
		setName = gObjFncMTA("xmlNodeSetName"),
		setValue = gObjFncMTA("xmlNodeSetValue"),
		destroy = gObjFncMTA("xmlDestroyNode"),
		create = gObjFncMTA("xmlCreateChild"),
	};
}

class {
	type = "dgsSVG";
	dgsType = "dgs-dxsvg";
	preInstantiate = function(...)
		return dgsCreateSVG(...)
	end;
	public = {
		getDocument = function(self)
			return dgsGetInstanceByType(dgsGetProperty(self.dgsElement,"svgDocument"),"dgs-dxsvgnode")
		end
	};
}

class {
	extends = {"xmlNode"};
	type = "dgsSVGNode";
	dgsType = "dgs-dxsvgnode";
	public = {
		getAttribute = gObjFnc("dgsSVGNodeGetAttribute"),
		setAttribute = gObjFnc("dgsSVGNodeSetAttribute",true),
		getAttributes = gObjFnc("dgsSVGNodeGetAttributes"),
		setAttributes = gObjFnc("dgsSVGNodeSetAttributes",true),
		__index=function(self,key)
			if key == "parent" then
				return dgsGetInstanceByType(self:getParent(),"dgs-dxsvgnode")
			elseif key == "children" then
				return dgsGetInstanceByType(self:getChildren(),"dgs-dxsvgnode")
			elseif key == "name" then
				return self:getName()
			elseif key == "value" then
				return self:getValue()
			else
				local name = self:getName()
				local fnc = self.attrFunctions[name] and self.attrFunctions[name][key] or self.attrFunctions.default[key]
				if fnc then
					return fnc
				end
			end
			return dgsSVGNodeGetAttribute(self.dgsElement,key)
		end,
		__newindex=function(self,key,value)
			if key == "name" then
				return self:setName(value) and self or false
			elseif key == "value" then
				return self:setValue(value) and self or false
			end
			return dgsSVGNodeSetAttribute(self.dgsElement,key,value) and self or false
		end,
	};
	default = {
		attrFunctions = {
			default = {
				fill = function(self,...)
					self:setAttribute("fill",...)
					return self
				end,
				stroke = function(self,t)
					if type(t) == "table" then
						if t.width then
							self:setAttribute("stroke-width",t.width)
						end
						if t.color then
							self:setAttribute("stroke",t.color)
						end
					else
						self:setAttribute("stroke",t)
					end
					return self
				end,
			},
			svg = {
				rect = function(self,...) return dgsGetInstanceByType(dgsSVGCreateNode(self.dgsElement,"rect",...),"dgs-dxsvgnode") end,
				circle = function(self,...) return dgsGetInstanceByType(dgsSVGCreateNode(self.dgsElement,"circle",...),"dgs-dxsvgnode") end,
				ellipse = function(self,...) return dgsGetInstanceByType(dgsSVGCreateNode(self.dgsElement,"ellipse",...),"dgs-dxsvgnode") end,
				line = function(self,...) return dgsGetInstanceByType(dgsSVGCreateNode(self.dgsElement,"line",...),"dgs-dxsvgnode") end,
				polygon = function(self,...) return dgsGetInstanceByType(dgsSVGCreateNode(self.dgsElement,"polygon",...),"dgs-dxsvgnode") end,
				polyline = function(self,...) return dgsGetInstanceByType(dgsSVGCreateNode(self.dgsElement,"polyline",...),"dgs-dxsvgnode") end,
				path = function(self,...) return dgsGetInstanceByType(dgsSVGCreateNode(self.dgsElement,"path",...),"dgs-dxsvgnode") end,
				text = function(self,...) return dgsGetInstanceByType(dgsSVGCreateNode(self.dgsElement,"text",...),"dgs-dxsvgnode") end,
			},
			rect = {
				move = function(self,...)
					self:setAttribute("x",x)
					self:setAttribute("y",y)
					return self
				end,
				radius = function(self,rx,ry)
					self:setAttribute("rx",rx)
					self:setAttribute("ry",ry)
					return self
				end,
			},
			circle = {
				move = function(self,x,y)
					self:setAttribute("cx",x)
					self:setAttribute("cy",y)
					return self
				end,
				radius = function(self,r)
					self:setAttribute("r",r)
					return self
				end,
			},
			ellipse = {
				move = function(self,x,y)
					self:setAttribute("cx",x)
					self:setAttribute("cy",y)
					return self
				end,
				radius = function(self,rx,ry)
					self:setAttribute("rx",rx)
					self:setAttribute("ry",ry)
					return self
				end,
			},
			text = {
				text = function(self,text)
					self:setValue(text)
					return self
				end,
				tspan = function(self,...) return dgsGetInstanceByType(dgsSVGCreateNode(self.dgsElement,"tspan",...),"dgs-dxsvgnode") end,
			}
		}
	};
}

--------------------------Color Picker
class {
	extends = {"dgsPlugin","dgsImage"};
	type = "dgsColorPicker";
	dgsType = "dgs-dxcolorpicker";
	preInstantiate = function(parent,style,x,y,w,h,rlt,...)
		return dgsCreateColorPicker(style,x,y,w,h,rlt,parent.dgsElement,...)
	end;
	public = {
		getColor = gObjFnc("dgsColorPickerGetColor"),
		setColor = gObjFnc("dgsColorPickerSetColor",true),
	};
}

class {
	extends = {"dgsPlugin","dgsImage"};
	type = "dgsComponentSelector";
	dgsType = "dgs-dxcomponentselector";
	preInstantiate = function(parent,x,y,w,h,voh,rlt,...)
		return dgsColorPickerCreateComponentSelector(x,y,w,h,voh,rlt,parent.dgsElement,...)
	end;
	public = {
		getCursorThickness = gObjFnc("dgsComponentSelectorGetCursorThickness"),
		setCursorThickness = gObjFnc("dgsComponentSelectorSetCursorThickness",true),
		getValue = gObjFnc("dgsColorPickerGetComponentSelectorValue"),
		setValue = gObjFnc("dgsColorPickerSetComponentSelectorValue",true),
		bindToColorPicker = function(self,colorPicker,...)
			return dgsBindToColorPicker(self.dgsElement,colorPicker.dgsElement,...)
		end,
		unbindFromColorPicker = gObjFnc("dgsUnbindFromColorPicker",true),
	};
	inject = {
		dgsScrollBar = {
			default = {
				bindToColorPicker = function(self,colorPicker,...)
					return dgsBindToColorPicker(self.dgsElement,colorPicker.dgsElement,...)
				end,
				unbindFromColorPicker = gObjFnc("dgsUnbindFromColorPicker",true),
			}
		},
		dgsEdit = {
			default = {
				bindToColorPicker = function(self,colorPicker,...)
					return dgsBindToColorPicker(self.dgsElement,colorPicker.dgsElement,...)
				end,
				unbindFromColorPicker = gObjFnc("dgsUnbindFromColorPicker",true),
			}
		},
		dgsLabel = {
			default = {
				bindToColorPicker = function(self,colorPicker,...)
					return dgsBindToColorPicker(self.dgsElement,colorPicker.dgsElement,...)
				end,
				unbindFromColorPicker = gObjFnc("dgsUnbindFromColorPicker",true),
			}
		}
	}
}

------------------------------------------------
dgsRootInstance = dgsOOP.dgsRoot()
rootInstance = dgsOOP.dgsRoot()

function _onDgsStart(dResN)
	dgsRootInstance.dgsElement = dgsRoot
	rootInstance.dgsElement = dgsRoot
	dgsOOP.dgsRoot = dgsRoot
	dgsOOP.dgsRes = dgsImportHead.dgsResource
end
addEventHandler("onDgsStart",root,_onDgsStart,true,"low-1000")
end