-------OOP
if not getElementData(root,"__DGSRes") then assert(false,"Invalid DGS Resource! Please check whether your dgs resource is started") end
if not dgsImportHead then loadstring(exports[getElementData(root,"__DGSRes")]:dgsImportFunction())() end
if dgsOOP and dgsOOP.dgsRes and isElement(getResourceRootElement(dgsOOP.dgsRes)) then return end
dgsOOP = {
	dgsClasses = {},
	dgsInstances = {},
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
-------Utils
local strToIntCache = {
	["1"]=1,
	["2"]=2,
	["3"]=3,
	["4"]=4,
}

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
			if newMeta.preInstantiate then
				newInstance.dgsElement = dgsElement	--For converting dgs pop element to oop instance
				dgsOOP.dgsInstances[newInstance.dgsElement] = newInstance
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
	if tab.extends then
		tab.public = tab.public or {}
		local extendsClass = dgsOOP[tab.extends]
		for k,v in pairs(extendsClass.public or {}) do
			tab.public[k] = v
		end
	end
	setmetatable(tab,meta)
	dgsOOP[tab.type] = tab
end
dgsOOP.class = class

function dgsOOP.generateInterface(dgsElement,meta)
	local newmeta = dgsOOP.shallowCopy(meta)
	newmeta.dgsElement = dgsElement
	return setmetatable({"DGS OOP: Bad usage"},newmeta)()
end

dgsOOP.genOOPFnc = function(pop,isChain) return isChain and (function(self,...) return call(dgsOOP.dgsRes,pop,self.dgsElement,...) and self or false end) or (function(self,...) return dgsGetInstance(call(dgsOOP.dgsRes,pop,self.dgsElement,...)) end) end
dgsOOP.genOOPFncNonObj = function(pop,isChain) return (function(self,...) return dgsGetInstance(call(dgsOOP.dgsRes,pop,...)) end) end

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
--default
--public

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
		isStyleAvailable = dgsOOP.genOOPFncNonObj("dgsIsStyleAvailable"),
		getLoadedStyleList = dgsOOP.genOOPFncNonObj("dgsGetLoadedStyleList"),
		setCurrentStyle = dgsOOP.genOOPFncNonObj("dgsSetCurrentStyle"),
		getCurrentStyle = dgsOOP.genOOPFncNonObj("dgsGetCurrentStyle"),
		getScreenSize = function(self) return Vector2(guiGetScreenSize()) end,
		setInputEnabled = function(self,...) return guiSetInputEnabled(...) end,
		getInputEnabled = function(self,...) return guiGetInputEnabled(...) end,
		setInputMode = function(self,...) return guiSetInputMode(...) end,
		getInputMode = function(self,...) return guiGetInputMode(...) end,
		setRenderSetting = dgsOOP.genOOPFncNonObj("dgsSetRenderSetting"),
		getRenderSetting = dgsOOP.genOOPFncNonObj("dgsGetRenderSetting"),
		getLayerElements = dgsOOP.genOOPFncNonObj("dgsGetLayerElements"),
		addEasingFunction = dgsOOP.genOOPFncNonObj("dgsAddEasingFunction"),
		easingFunctionExists = dgsOOP.genOOPFncNonObj("dgsEasingFunctionExists"),
		removeEasingFunction = dgsOOP.genOOPFncNonObj("dgsRemoveEasingFunction"),
		getSystemFont = dgsOOP.genOOPFncNonObj("dgsGetSystemFont"),
		setSystemFont = dgsOOP.genOOPFncNonObj("dgsSetSystemFont"),
		translationTableExists = dgsOOP.genOOPFncNonObj("dgsTranslationTableExists"),
		setTranslationTable = dgsOOP.genOOPFncNonObj("dgsSetTranslationTable"),
		setAttachTranslation = dgsOOP.genOOPFncNonObj("dgsSetAttachTranslation"),
		setDoubleClickInterval = dgsOOP.genOOPFncNonObj("dgsSetDoubleClickInterval"),
		getDoubleClickInterval = dgsOOP.genOOPFncNonObj("dgsGetDoubleClickInterval"),
		RGBToHSV = dgsOOP.genOOPFncNonObj("dgsRGBToHSV"),
		RGBToHSL = dgsOOP.genOOPFncNonObj("dgsRGBToHSL"),
		HSLToRGB = dgsOOP.genOOPFncNonObj("dgsHSLToRGB"),
		HSVToRGB = dgsOOP.genOOPFncNonObj("dgsHSVToRGB"),
		HSVToHSL = dgsOOP.genOOPFncNonObj("dgsHSVToHSL"),
		HSLToHSV = dgsOOP.genOOPFncNonObj("dgsHSLToHSV"),
		dgs3DInterface = function(...) return dgsOOP.dgs3DInterface(dgsRootInstance,...) end,
		dgs3DText = function(...) return dgsOOP.dgs3DText(dgsRootInstance,...) end,
		dgsWindow = function(...) return dgsOOP.dgsWindow(dgsRootInstance,...) end,
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
		dgsMemo = function(...) return dgsOOP.dgsMemo(dgsRootInstance,...) end,
		dgsProgressBar = function(...) return dgsOOP.dgsProgressBar(dgsRootInstance,...) end,
		dgsRadioButton = function(...) return dgsOOP.dgsRadioButton(dgsRootInstance,...) end,
		dgsScrollBar = function(...) return dgsOOP.dgsScrollBar(dgsRootInstance,...) end,
		dgsScrollPane = function(...) return dgsOOP.dgsScrollPane(dgsRootInstance,...) end,
		dgsSwitchButton = function(...) return dgsOOP.dgsSwitchButton(dgsRootInstance,...) end,
		dgsTabPanel = function(...) return dgsOOP.dgsTabPanel(dgsRootInstance,...) end,
		dgsGetInstance = function(dgsElement,...)
			local typ = type(dgsElement)
			if typ ~= "table" and typ ~= "userdata" then return dgsElement end
			if typ == "table" then
				local t = {}
				for i=1,#dgsElement do
					t[i] = dgsRootInstance.dgsGetInstance(dgsElement[i])
				end
				return t
			end
			if not isElement(dgsElement) then return dgsElement end
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
		end
	};
	public = {
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
		dgs3DInterface = function(...) return dgsGetInstance(call(dgsOOP.dgsRes,"dgsCreate3DInterface",...)) end,
		dgs3DText = function(...) return dgsGetInstance(call(dgsOOP.dgsRes,"dgsCreate3DText",...)) end,

	};
}

----------------------------------------------------------
----------------------------------------------------DGS 2D
----------------------------------------------------------
class {
	extends = "dgsRoot";
	type = "dgs2D";
	preInstantiate = nil;
	public = {
		__index=function(self,key)
			if key == "parent" then
				local parent = call(dgsOOP.dgsRes,"dgsGetParent",self.dgsElement,key)
				return parent and dgsGetInstance(parent) or false
			elseif key == "children" then
				return self:getChildren()
			elseif key == "size" then
				return dgsOOP.generateInterface(self.dgsElement,dgsOOP.size2D)
			elseif key == "position" then
				return dgsOOP.generateInterface(self.dgsElement,dgsOOP.position2D)
			end
			return call(dgsOOP.dgsRes,"dgsGetProperty",self.dgsElement,key)
		end,
		__newindex=function(self,key,value)
			if key == "parent" then
				local targetEle
				if type(value) == "table" then targetEle = value.dgsElement end
				return call(dgsOOP.dgsRes,"dgsSetParent",self.dgsElement,targetEle)
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
			return call(dgsOOP.dgsRes,"dgsSetProperty",self.dgsElement,key,value) and self or false
		end,
		getPosition = dgsOOP.genOOPFnc("dgsGetPosition"),
		setPosition = dgsOOP.genOOPFnc("dgsSetPosition",true),
		getParent = dgsOOP.genOOPFnc("dgsGetParent"),
		setParent = function(self,parent)
			if type(parent) == "table" and isElement(parent.dgsElement) then parent = parent.dgsElement	end
			return call(dgsOOP.dgsRes,"dgsSetParent",self.dgsElement,parent) and self or false
		end,
		getChild = dgsOOP.genOOPFnc("dgsGetChild"),
		getChildren = dgsOOP.genOOPFnc("dgsGetChildren"),
		getSize = dgsOOP.genOOPFnc("dgsGetSize"),
		setSize = dgsOOP.genOOPFnc("dgsSetSize",true),
		getType = dgsOOP.genOOPFnc("dgsGetType"),
		setLayer = dgsOOP.genOOPFnc("dgsSetLayer",true),
		getLayer = dgsOOP.genOOPFnc("dgsSetLayer"),
		setCurrentLayerIndex = dgsOOP.genOOPFnc("dgsSetCurrentLayerIndex",true),
		getCurrentLayerIndex = dgsOOP.genOOPFnc("dgsGetCurrentLayerIndex"),
		getProperty = dgsOOP.genOOPFnc("dgsGetProperty"),
		setProperty = dgsOOP.genOOPFnc("dgsSetProperty",true),
		getProperties = function(self,...) return call(dgsOOP.dgsRes,"dgsGetProperties",self.dgsElement,...) end,
		setProperties = dgsOOP.genOOPFnc("dgsSetProperties",true),
		getVisible = dgsOOP.genOOPFnc("dgsGetVisible"),
		setVisible = dgsOOP.genOOPFnc("dgsSetVisible",true),
		getEnabled = dgsOOP.genOOPFnc("dgsGetEnabled"),
		setEnabled = dgsOOP.genOOPFnc("dgsSetEnabled",true),
		blur = dgsOOP.genOOPFnc("dgsBlur",true),
		focus = dgsOOP.genOOPFnc("dgsFocus",true),
		getSide = dgsOOP.genOOPFnc("dgsGetSide"),
		setSide = dgsOOP.genOOPFnc("dgsSetSide",true),
		getAlpha = dgsOOP.genOOPFnc("dgsGetAlpha"),
		setAlpha = dgsOOP.genOOPFnc("dgsSetAlpha",true),
		getFont = dgsOOP.genOOPFnc("dgsGetFont"),
		setFont = dgsOOP.genOOPFnc("dgsSetFont",true),
		getText = dgsOOP.genOOPFnc("dgsGetText"),
		setText = dgsOOP.genOOPFnc("dgsSetText",true),
		bringToFront = dgsOOP.genOOPFnc("dgsBringToFront",true),
		moveToBack = dgsOOP.genOOPFnc("dgsMoveToBack",true),
		simulateClick = dgsOOP.genOOPFnc("dgsSimulateClick",true),
		animTo = dgsOOP.genOOPFnc("dgsAnimTo",true),
		isAniming = dgsOOP.genOOPFnc("dgsIsAniming"),
		stopAniming = dgsOOP.genOOPFnc("dgsStopAniming",true),
		moveTo = dgsOOP.genOOPFnc("dgsMoveTo",true),
		isMoving = dgsOOP.genOOPFnc("dgsIsMoving"),
		stopMoving = dgsOOP.genOOPFnc("dgsStopMoving",true),
		sizeTo = dgsOOP.genOOPFnc("dgsSizeTo",true),
		isSizing = dgsOOP.genOOPFnc("dgsIsSizing"),
		stopSizing = dgsOOP.genOOPFnc("dgsStopSizing",true),
		alphaTo = dgsOOP.genOOPFnc("dgsAlphaTo",true),
		isAlphaing = dgsOOP.genOOPFnc("dgsIsAlphaing"),
		stopAlphaing = dgsOOP.genOOPFnc("dgsStopAlphaing",true),
		getPostGUI = dgsOOP.genOOPFnc("dgsGetPostGUI"),
		setPostGUI = dgsOOP.genOOPFnc("dgsGetPostGUI",true),
		detachFromGridList = dgsOOP.genOOPFnc("dgsDetachFromGridList",true),
		getAttachedGridList = dgsOOP.genOOPFnc("dgsGetAttachedGridList",true),
		attachToGridList = dgsOOP.genOOPFnc("dgsAttachToGridList",true),
		center = dgsOOP.genOOPFnc("dgsCenterElement",true),
		destroy = function(self) return destroyElement(self.dgsElement) end;
		isElement = dgsOOP.genOOPFnc("isElement",true);
		getElement = function(self) return self.dgsElement end,
		addMoveHandler = dgsOOP.genOOPFnc("dgsAddMoveHandler",true),
		removeMoveHandler = dgsOOP.genOOPFnc("dgsRemoveMoveHandler",true),
		isMoveHandled = dgsOOP.genOOPFnc("dgsIsMoveHandled"),
		addSizeHandler = dgsOOP.genOOPFnc("dgsAddSizeHandler",true),
		removeSizeHandler = dgsOOP.genOOPFnc("dgsRemoveSizeHandler",true),
		isSizeHandled = dgsOOP.genOOPFnc("dgsIsSizeHandled"),
		attachToTranslation = dgsOOP.genOOPFnc("dgsAttachToTranslation",true),
		detachFromTranslation = dgsOOP.genOOPFnc("dgsDetachFromTranslation",true),
		getTranslationName = dgsOOP.genOOPFnc("dgsGetTranslationName"),
		attach = dgsOOP.genOOPFnc("dgsAttachElements",true),
		detach = dgsOOP.genOOPFnc("dgsDetachElements",true),
		isAttached = dgsOOP.genOOPFnc("dgsElementIsAttached"),

		dgsBrowser = function(...) return dgsOOP.dgsBrowser(...) end,
		dgsButton = function(...) return dgsOOP.dgsButton(...) end,
		dgsCheckBox = function(...) return dgsOOP.dgsCheckBox(...) end,
		dgsComboBox = function(...) return dgsOOP.dgsComboBox(...) end,
		dgsCustomRenderer = function(...) return dgsOOP.dgsCustomRenderer(...) end,
		dgsDetectArea = function(...) return dgsOOP.dgsDetectArea(...) end,
		dgsEdit = function(...) return dgsOOP.dgsEdit(...) end,
		dgsGridList = function(...) return dgsOOP.dgsGridList(...) end,
		dgsImage = function(...) return dgsOOP.dgsImage(...) end,
		dgsLabel = function(...) return dgsOOP.dgsLabel(...) end,
		dgsMemo = function(...) return dgsOOP.dgsMemo(...) end,
		dgsProgressBar = function(...) return dgsOOP.dgsProgressBar(...) end,
		dgsRadioButton = function(...) return dgsOOP.dgsRadioButton(...) end,
		dgsScrollBar = function(...) return dgsOOP.dgsScrollBar(...) end,
		dgsScrollPane = function(...) return dgsOOP.dgsScrollPane(...) end,
		dgsSwitchButton = function(...) return dgsOOP.dgsSwitchButton(...) end,
		dgsTabPanel = function(...) return dgsOOP.dgsTabPanel(...) end,
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
		return call(dgsOOP.dgsRes,"dgsCreateButton",x,y,w,h,text,rlt,parent.dgsElement,...)
	end;
	public = {
	};
}

--------------------------Browser
class {
	extends = "dgs2D";
	type = "dgsBrowser";
	dgsType = "dgs-dxbrowser";
	preInstantiate = function(parent,x,y,w,h,rlt,...)
		return call(dgsOOP.dgsRes,"dgsCreateBrowser",x,y,w,h,rlt,parent.dgsElement,...)
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
		return call(dgsOOP.dgsRes,"dgsCreateCheckBox",x,y,w,h,text,state,rlt,parent.dgsElement,...)
	end;
	public = {
		getSelected = dgsOOP.genOOPFnc("dgsCheckBoxGetSelected"),
		setSelected = dgsOOP.genOOPFnc("dgsCheckBoxSetSelected",true),
		getHorizontalAlign = dgsOOP.genOOPFnc("dgsCheckBoxGetHorizontalAlign"),
		setHorizontalAlign = dgsOOP.genOOPFnc("dgsCheckBoxSetHorizontalAlign",true),
		getVerticalAlign = dgsOOP.genOOPFnc("dgsCheckBoxGetVerticalAlign"),
		setVerticalAlign = dgsOOP.genOOPFnc("dgsCheckBoxSetVerticalAlign",true),
	};
}

--------------------------ComboBox
class {
	extends = "dgs2D";
	type = "dgsComboBox";
	dgsType = "dgs-dxcombobox";
	preInstantiate = function(parent,x,y,w,h,text,rlt,...)
		return call(dgsOOP.dgsRes,"dgsCreateComboBox",x,y,w,h,text,rlt,parent.dgsElement,...)
	end;
	public = {
		addItem = dgsOOP.genOOPFnc("dgsComboBoxAddItem"),
		removeItem = dgsOOP.genOOPFnc("dgsComboBoxRemoveItem",true),
		setItemText = dgsOOP.genOOPFnc("dgsComboBoxSetItemText",true),
		getItemText = dgsOOP.genOOPFnc("dgsComboBoxGetItemText"),
		clear = dgsOOP.genOOPFnc("dgsComboBoxClear",true),
		setSelectedItem = dgsOOP.genOOPFnc("dgsComboBoxSetSelectedItem",true),
		getSelectedItem = dgsOOP.genOOPFnc("dgsComboBoxGetSelectedItem"),
		setItemColor = dgsOOP.genOOPFnc("dgsComboBoxSetItemColor",true),
		getItemColor = dgsOOP.genOOPFnc("dgsComboBoxGetItemColor"),
		getState = dgsOOP.genOOPFnc("dgsComboBoxGetState"),
		setState = dgsOOP.genOOPFnc("dgsComboBoxSetState",true),
		getItemCount = dgsOOP.genOOPFnc("dgsComboBoxGetItemCount"),
		getBoxHeight = dgsOOP.genOOPFnc("dgsComboBoxGetBoxHeight"),
		setBoxHeight = dgsOOP.genOOPFnc("dgsComboBoxSetBoxHeight",true),
		getScrollBar = dgsOOP.genOOPFnc("dgsComboBoxGetScrollBar"),
		setScrollPosition = dgsOOP.genOOPFnc("dgsComboBoxSetScrollPosition",true),
		getScrollPosition = dgsOOP.genOOPFnc("dgsComboBoxGetScrollPosition"),
		setCaptionText = dgsOOP.genOOPFnc("dgsComboBoxSetCaptionText",true),
		getCaptionText = dgsOOP.genOOPFnc("dgsComboBoxGetCaptionText"),
		setEditEnabled = dgsOOP.genOOPFnc("dgsComboBoxSetEditEnabled",true),
		getEditEnabled = dgsOOP.genOOPFnc("dgsComboBoxGetEditEnabled"),
		getText = dgsOOP.genOOPFnc("dgsComboBoxGetText"),
	};
}

--------------------------CustomRenderer
class {
	extends = "dgs2D";
	type = "dgsCustomRenderer";
	dgsType = "dgs-dxcustomrenderer";
	preInstantiate = function(parent,customFnc)
		return call(dgsOOP.dgsRes,"dgsCreateCustomRenderer",customFnc)
	end;
	public = {
		setFunction = dgsOOP.genOOPFnc("dgsCustomRendererSetFunction",true),
	};
}

--------------------------DetectArea
class {
	extends = "dgs2D";
	type = "dgsDetectArea";
	dgsType = "dgs-dxdetectarea";
	preInstantiate = function(parent,x,y,w,h,rlt,...)
		return call(dgsOOP.dgsRes,"dgsCreateDetectArea",x,y,w,h,text,rlt,parent.dgsElement,...)
	end;
	public = {
		setFunction = dgsOOP.genOOPFnc("dgsDetectAreaSetFunction",true),
		setDebugModeEnabled = dgsOOP.genOOPFnc("dgsDetectAreaSetDebugModeEnabled",true),
		getDebugModeEnabled = dgsOOP.genOOPFnc("dgsDetectAreaGetDebugModeEnabled"),
	};
}

--------------------------Edit
class {
	extends = "dgs2D";
	type = "dgsEdit";
	dgsType = "dgs-dxedit";
	preInstantiate = function(parent,x,y,w,h,text,rlt,...)
		return call(dgsOOP.dgsRes,"dgsCreateEdit",x,y,w,h,text,rlt,parent.dgsElement,...)
	end;
	public = {
		moveCaret = dgsOOP.genOOPFnc("dgsEditMoveCaret",true),
		setCaretPosition = dgsOOP.genOOPFnc("dgsEditSetCaretPosition",true),
		getCaretPosition = dgsOOP.genOOPFnc("dgsEditGetCaretPosition"),
		setCaretStyle = dgsOOP.genOOPFnc("dgsEditSetCaretStyle",true),
		getCaretStyle = dgsOOP.genOOPFnc("dgsEditGetCaretStyle"),
		setWhiteList = dgsOOP.genOOPFnc("dgsEditSetWhiteList",true),
		setMaxLength = dgsOOP.genOOPFnc("dgsEditSetMaxLength",true),
		getMaxLength = dgsOOP.genOOPFnc("dgsEditGetMaxLength"),
		setReadOnly = dgsOOP.genOOPFnc("dgsEditSetReadOnly",true),
		getReadOnly = dgsOOP.genOOPFnc("dgsEditGetReadOnly"),
		setMasked = dgsOOP.genOOPFnc("dgsEditSetMasked",true),
		getMasked = dgsOOP.genOOPFnc("dgsEditGetMasked"),
		setUnderlined = dgsOOP.genOOPFnc("dgsEditSetUnderlined",true),
		getUnderlined = dgsOOP.genOOPFnc("dgsEditGetUnderlined"),
		setHorizontalAlign = dgsOOP.genOOPFnc("dgsEditSetHorizontalAlign",true),
		getHorizontalAlign = dgsOOP.genOOPFnc("dgsEditGetHorizontalAlign"),
		setVerticalAlign = dgsOOP.genOOPFnc("dgsEditSetVerticalAlign",true),
		getVerticalAlign = dgsOOP.genOOPFnc("dgsEditGetVerticalAlign"),
		setAlignment = dgsOOP.genOOPFnc("dgsEditSetAlignment ",true),
		getAlignment = dgsOOP.genOOPFnc("dgsEditGetAlignment "),
		insertText = dgsOOP.genOOPFnc("dgsEditInsertText",true),
		deleteText = dgsOOP.genOOPFnc("dgsEditDeleteText",true),
		getPartOfText = dgsOOP.genOOPFnc("dgsEditGetPartOfText"),
		clearText = dgsOOP.genOOPFnc("dgsEditClearText",true),
		replaceText = dgsOOP.genOOPFnc("dgsEditReplaceText",true),
		setTypingSound = dgsOOP.genOOPFnc("dgsEditSetTypingSound",true),
		getTypingSound = dgsOOP.genOOPFnc("dgsEditGetTypingSound"),
		setPlaceHolder = dgsOOP.genOOPFnc("dgsEditSetPlaceHolder",true),
		getPlaceHolder = dgsOOP.genOOPFnc("dgsEditGetPlaceHolder"),
		setAutoComplete = dgsOOP.genOOPFnc("dgsEditSetAutoComplete",true),
		getAutoComplete = dgsOOP.genOOPFnc("dgsEditGetAutoComplete"),
		addAutoComplete = dgsOOP.genOOPFnc("dgsEditAddAutoComplete",true),
		removeAutoComplete = dgsOOP.genOOPFnc("dgsEditRemoveAutoComplete",true),
	};
}

--------------------------External
class {
	extends = "dgs2D";
	type = "dgsExternal";
	dgsType = "dgs-dxexternal";
	preInstantiate = function(parent,...)
		return call(dgsOOP.dgsRes,"dgsCreateExternal",...)
	end;
	public = {
	};
}

--------------------------GridList
class {
	extends = "dgs2D";
	type = "dgsGridList";
	dgsType = "dgs-dxgridlist";
	preInstantiate = function(parent,x,y,w,h,rlt,...)
		return call(dgsOOP.dgsRes,"dgsCreateGridList",x,y,w,h,rlt,parent.dgsElement,...)
	end;
	public = {
		getScrollBar = dgsOOP.genOOPFnc("dgsGridListGetScrollBar"),
		setScrollPosition = dgsOOP.genOOPFnc("dgsGridListSetScrollPosition",true),
		getScrollPosition = dgsOOP.genOOPFnc("dgsGridListGetScrollPosition"),
		setHorizontalScrollPosition = dgsOOP.genOOPFnc("dgsGridListSetHorizontalScrollPosition",true),
		getHorizontalScrollPosition = dgsOOP.genOOPFnc("dgsGridListGetHorizontalScrollPosition"),
		setVerticalScrollPosition = dgsOOP.genOOPFnc("dgsGridListSetVerticalScrollPosition",true),
		getVerticalScrollPosition = dgsOOP.genOOPFnc("dgsGridListGetVerticalScrollPosition"),
		resetScrollBarPosition = dgsOOP.genOOPFnc("dgsGridListResetScrollBarPosition",true),
		setColumnRelative = dgsOOP.genOOPFnc("dgsGridListSetColumnRelative",true),
		getColumnRelative = dgsOOP.genOOPFnc("dgsGridListGetColumnRelative"),
		addColumn = dgsOOP.genOOPFnc("dgsGridListAddColumn"),
		getColumnCount = dgsOOP.genOOPFnc("dgsGridListGetColumnCount"),
		removeColumn = dgsOOP.genOOPFnc("dgsGridListRemoveColumn",true),
		getColumnAllWidth = dgsOOP.genOOPFnc("dgsGridListGetColumnAllWidth"),
		getColumnHeight = dgsOOP.genOOPFnc("dgsGridListGetColumnHeight"),
		setColumnHeight = dgsOOP.genOOPFnc("dgsGridListSetColumnHeight",true),
		getColumnWidth = dgsOOP.genOOPFnc("dgsGridListGetColumnWidth"),
		setColumnWidth = dgsOOP.genOOPFnc("dgsGridListSetColumnWidth",true),
		autoSizeColumn = dgsOOP.genOOPFnc("dgsGridListAutoSizeColumn",true),
		getColumnTitle = dgsOOP.genOOPFnc("dgsGridListGetColumnTitle"),
		setColumnTitle = dgsOOP.genOOPFnc("dgsGridListSetColumnTitle",true),
		getColumnFont = dgsOOP.genOOPFnc("dgsGridListGetColumnFont"),
		setColumnFont = dgsOOP.genOOPFnc("dgsGridListSetColumnFont",true),
		addRow = dgsOOP.genOOPFnc("dgsGridListAddRow"),
		insertRowAfter = dgsOOP.genOOPFnc("dgsGridListInsertRowAfter"),
		removeRow = dgsOOP.genOOPFnc("dgsGridListRemoveRow",true),
		clearRow = dgsOOP.genOOPFnc("dgsGridListClearRow",true),
		clearColumn = dgsOOP.genOOPFnc("dgsGridListClearColumn",true),
		clear = dgsOOP.genOOPFnc("dgsGridListClear",true),
		getRowCount = dgsOOP.genOOPFnc("dgsGridListGetRowCount"),
		setItemText = dgsOOP.genOOPFnc("dgsGridListSetItemText",true),
		getItemText = dgsOOP.genOOPFnc("dgsGridListGetItemText"),
		getSelectedItem = dgsOOP.genOOPFnc("dgsGridListGetSelectedItem"),
		setSelectedItem = dgsOOP.genOOPFnc("dgsGridListSetSelectedItem",true),
		setItemColor = dgsOOP.genOOPFnc("dgsGridListSetItemColor",true),
		getItemColor = dgsOOP.genOOPFnc("dgsGridListGetItemColor"),
		setItemData = dgsOOP.genOOPFnc("dgsGridListSetItemData",true),
		getItemData = dgsOOP.genOOPFnc("dgsGridListGetItemData"),
		setItemImage = dgsOOP.genOOPFnc("dgsGridListSetItemImage",true),
		getItemImage = dgsOOP.genOOPFnc("dgsGridListGetItemImage"),
		removeItemImage = dgsOOP.genOOPFnc("dgsGridListRemoveItemImage",true),
		getRowBackGroundImage = dgsOOP.genOOPFnc("dgsGridListGetRowBackGroundImage"),
		setRowBackGroundImage = dgsOOP.genOOPFnc("dgsGridListSetRowBackGroundImage",true),
		getRowBackGroundColor = dgsOOP.genOOPFnc("dgsGridListGetRowBackGroundColor"),
		setRowBackGroundColor = dgsOOP.genOOPFnc("dgsGridListSetRowBackGroundColor",true),
		setRowAsSection = dgsOOP.genOOPFnc("dgsGridListSetRowAsSection",true),
		selectItem = dgsOOP.genOOPFnc("dgsGridListSelectItem",true),
		itemIsSelected = dgsOOP.genOOPFnc("dgsGridListItemIsSelected"),
		setMultiSelectionEnabled = dgsOOP.genOOPFnc("dgsGridListSetMultiSelectionEnabled",true),
		getMultiSelectionEnabled = dgsOOP.genOOPFnc("dgsGridListGetMultiSelectionEnabled"),
		setSelectionMode = dgsOOP.genOOPFnc("dgsGridListSetSelectionMode",true),
		getSelectionMode = dgsOOP.genOOPFnc("dgsGridListGetSelectionMode"),
		setSelectedItems = dgsOOP.genOOPFnc("dgsGridListSetSelectedItems",true),
		getSelectedItems = dgsOOP.genOOPFnc("dgsGridListGetSelectedItems"),
		getSelectedCount = dgsOOP.genOOPFnc("dgsGridListGetSelectedCount"),
		setSortFunction = dgsOOP.genOOPFnc("dgsGridListSetSortFunction",true),
		setAutoSortEnabled = dgsOOP.genOOPFnc("dgsGridListSetAutoSortEnabled",true),
		getAutoSortEnabled = dgsOOP.genOOPFnc("dgsGridListGetAutoSortEnabled"),
		setSortEnabled = dgsOOP.genOOPFnc("dgsGridListSetSortEnabled",true),
		getSortEnabled = dgsOOP.genOOPFnc("dgsGridListGetSortEnabled"),
		setSortColumn = dgsOOP.genOOPFnc("dgsGridListSetSortColumn",true),
		getSortColumn = dgsOOP.genOOPFnc("dgsGridListGetSortColumn"),
		getEnterColumn = dgsOOP.genOOPFnc("dgsGridListGetEnterColumn"),
		sort = dgsOOP.genOOPFnc("dgsGridListSort",true),
		setNavigationEnabled = dgsOOP.genOOPFnc("dgsGridListSetNavigationEnabled",true),
		getNavigationEnabled = dgsOOP.genOOPFnc("dgsGridListGetNavigationEnabled"),
	};
}

--------------------------Image
class {
	extends = "dgs2D";
	type = "dgsImage";
	dgsType = "dgs-dximage";
	preInstantiate = function(parent,x,y,w,h,image,rlt,...)
		return call(dgsOOP.dgsRes,"dgsCreateImage",x,y,w,h,image,rlt,parent.dgsElement,...)
	end;
	public = {
		setImage = dgsOOP.genOOPFnc("dgsImageSetImage",true),
		getImage = dgsOOP.genOOPFnc("dgsImageGetImage"),
		setUVSize = dgsOOP.genOOPFnc("dgsImageSetUVSize",true),
		getUVSize = dgsOOP.genOOPFnc("dgsImageGetUVSize"),
		setUVPosition = dgsOOP.genOOPFnc("dgsImageSetUVPosition",true),
		getUVPosition = dgsOOP.genOOPFnc("dgsImageGetUVPosition"),
	};
}

--------------------------Label
class {
	extends = "dgs2D";
	type = "dgsLabel";
	dgsType = "dgs-dxlabel";
	preInstantiate = function(parent,x,y,w,h,text,rlt,...)
		return call(dgsOOP.dgsRes,"dgsCreateLabel",x,y,w,h,text,rlt,parent.dgsElement,...)
	end;
	public = {
		setColor = dgsOOP.genOOPFnc("dgsLabelSetColor",true),
		getColor = dgsOOP.genOOPFnc("dgsLabelGetColor"),
		setHorizontalAlign = dgsOOP.genOOPFnc("dgsLabelSetHorizontalAlign",true),
		getHorizontalAlign = dgsOOP.genOOPFnc("dgsLabelGetHorizontalAlign"),
		setVerticalAlign = dgsOOP.genOOPFnc("dgsLabelSetVerticalAlign",true),
		getVerticalAlign = dgsOOP.genOOPFnc("dgsLabelGetVerticalAlign"),
		getTextExtent = dgsOOP.genOOPFnc("dgsLabelGetTextExtent"),
		getFontHeight = dgsOOP.genOOPFnc("dgsLabelGetFontHeight"),
	};
}

--------------------------Memo
class {
	extends = "dgs2D";
	type = "dgsMemo";
	dgsType = "dgs-dxmemo";
	preInstantiate = function(parent,x,y,w,h,text,rlt,...)
		return call(dgsOOP.dgsRes,"dgsCreateMemo",x,y,w,h,text,rlt,parent.dgsElement,...)
	end;
	public = {
		moveCaret = dgsOOP.genOOPFnc("dgsMemoMoveCaret",true),
		seekPosition = dgsOOP.genOOPFnc("dgsMemoSeekPosition"),
		getScrollBar = dgsOOP.genOOPFnc("dgsMemoGetScrollBar"),
		setScrollPosition = dgsOOP.genOOPFnc("dgsMemoSetScrollPosition",true),
		getScrollPosition = dgsOOP.genOOPFnc("dgsMemoGetScrollPosition"),
		setHorizontalScrollPosition = dgsOOP.genOOPFnc("dgsMemoSetHorizontalScrollPosition",true),
		getHorizontalScrollPosition = dgsOOP.genOOPFnc("dgsMemoGetHorizontalScrollPosition"),
		setVerticalScrollPosition = dgsOOP.genOOPFnc("dgsMemoSetVerticalScrollPosition",true),
		getVerticalScrollPosition = dgsOOP.genOOPFnc("dgsMemoGetVerticalScrollPosition"),
		setCaretPosition = dgsOOP.genOOPFnc("dgsMemoSetCaretPosition",true),
		getCaretPosition = dgsOOP.genOOPFnc("dgsMemoGetCaretPosition"),
		setCaretStyle = dgsOOP.genOOPFnc("dgsMemoSetCaretStyle",true),
		getCaretStyle = dgsOOP.genOOPFnc("dgsMemoGetCaretStyle"),
		setReadOnly = dgsOOP.genOOPFnc("dgsMemoSetReadOnly",true),
		getReadOnly = dgsOOP.genOOPFnc("dgsMemoGetReadOnly"),
		getPartOfText = dgsOOP.genOOPFnc("dgsMemoGetPartOfText"),
		deleteText = dgsOOP.genOOPFnc("dgsMemoDeleteText",true),
		insertText = dgsOOP.genOOPFnc("dgsMemoInsertText",true),
		appendText = dgsOOP.genOOPFnc("dgsMemoAppendText",true),
		clearText = dgsOOP.genOOPFnc("dgsMemoClearText",true),
		getTypingSound = dgsOOP.genOOPFnc("dgsMemoGetTypingSound"),
		setTypingSound = dgsOOP.genOOPFnc("dgsMemoSetTypingSound",true),
		getLineCount = dgsOOP.genOOPFnc("dgsMemoGetLineCount"),
		setWordWrapState = dgsOOP.genOOPFnc("dgsMemoSetWordWrapState",true),
		getWordWrapState = dgsOOP.genOOPFnc("dgsMemoGetWordWrapState"),
		setScrollBarState = dgsOOP.genOOPFnc("dgsMemoSetScrollBarState",true),
		getScrollBarState = dgsOOP.genOOPFnc("dgsMemoGetScrollBarState"),
	};
}

--------------------------ProgressBar
class {
	extends = "dgs2D";
	type = "dgsProgressBar";
	dgsType = "dgs-dxprogressbar";
	preInstantiate = function(parent,x,y,w,h,rlt,...)
		return call(dgsOOP.dgsRes,"dgsCreateProgressBar",x,y,w,h,rlt,parent.dgsElement,...)
	end;
	public = {
		getProgress = dgsOOP.genOOPFnc("dgsProgressBarGetProgress"),
		setProgress = dgsOOP.genOOPFnc("dgsProgressBarSetProgress",true),
		getMode = dgsOOP.genOOPFnc("dgsProgressBarGetMode"),
		setMode = dgsOOP.genOOPFnc("dgsProgressBarSetMode",true),
		getVerticalSide = dgsOOP.genOOPFnc("dgsProgressBarGetVerticalSide"),
		setVerticalSide = dgsOOP.genOOPFnc("dgsProgressBarSetVerticalSide",true),
		getHorizontalSide = dgsOOP.genOOPFnc("dgsProgressBarGetHorizontalSide"),
		setHorizontalSide = dgsOOP.genOOPFnc("dgsProgressBarSetHorizontalSide",true),
		getStyle = dgsOOP.genOOPFnc("dgsProgressBarGetStyle"),
		setStyle = dgsOOP.genOOPFnc("dgsProgressBarSetStyle",true),
		getStyleProperties = dgsOOP.genOOPFnc("dgsProgressBarGetStyleProperties"),
		setStyleProperty = dgsOOP.genOOPFnc("dgsProgressBarSetStyleProperty",true),
		getStyleProperty = dgsOOP.genOOPFnc("dgsProgressBarGetStyleProperty"),
	};
}

--------------------------RadioButton
class {
	extends = "dgs2D";
	type = "dgsRadioButton";
	dgsType = "dgs-dxradiobutton";
	preInstantiate = function(parent,x,y,w,h,text,rlt,...)
		return call(dgsOOP.dgsRes,"dgsCreateRadioButton",x,y,w,h,text,rlt,parent.dgsElement,...)
	end;
	public = {
		getSelected = dgsOOP.genOOPFnc("dgsRadioButtonGetSelected"),
		setSelected = dgsOOP.genOOPFnc("dgsRadioButtonSetSelected",true),
		getHorizontalAlign = dgsOOP.genOOPFnc("dgsRadioButtonGetHorizontalAlign"),
		setHorizontalAlign = dgsOOP.genOOPFnc("dgsRadioButtonSetHorizontalAlign",true),
		getVerticalAlign = dgsOOP.genOOPFnc("dgsRadioButtonGetVerticalAlign"),
		setVerticalAlign = dgsOOP.genOOPFnc("dgsRadioButtonSetVerticalAlign",true),
	};
}

--------------------------ScrollBar
class {
	extends = "dgs2D";
	type = "dgsScrollBar";
	dgsType = "dgs-dxscrollbar";
	preInstantiate = function(parent,x,y,w,h,voh,rlt,...)
		return call(dgsOOP.dgsRes,"dgsCreateScrollBar",x,y,w,h,voh,rlt,parent.dgsElement,...)
	end;
	public = {
		setScrollPosition = dgsOOP.genOOPFnc("dgsScrollBarSetScrollPosition",true),
		getScrollPosition = dgsOOP.genOOPFnc("dgsScrollBarGetScrollPosition"),
		setCursorLength = dgsOOP.genOOPFnc("dgsScrollBarSetCursorLength",true),
		getCursorLength = dgsOOP.genOOPFnc("dgsScrollBarGetCursorLength"),
		setLocked = dgsOOP.genOOPFnc("dgsScrollBarSetLocked",true),
		getLocked = dgsOOP.genOOPFnc("dgsScrollBarGetLocked"),
		setGrades = dgsOOP.genOOPFnc("dgsScrollBarSetGrades",true),
		getGrades = dgsOOP.genOOPFnc("dgsScrollBarGetGrades"),
	};
}

--------------------------ScrollPane
class {
	extends = "dgs2D";
	type = "dgsScrollPane";
	dgsType = "dgs-dxscrollpane";
	preInstantiate = function(parent,x,y,w,h,rlt,...)
		return call(dgsOOP.dgsRes,"dgsCreateScrollPane",x,y,w,h,rlt,parent.dgsElement,...)
	end;
	public = {
		getScrollBar = dgsOOP.genOOPFnc("dgsScrollPaneGetScrollBar"),
		setScrollPosition = dgsOOP.genOOPFnc("dgsScrollPaneSetScrollPosition",true),
		getScrollPosition = dgsOOP.genOOPFnc("dgsScrollPaneGetScrollPosition"),
		setHorizontalScrollPosition = dgsOOP.genOOPFnc("dgsScrollPaneSetHorizontalScrollPosition",true),
		getHorizontalScrollPosition = dgsOOP.genOOPFnc("dgsScrollPaneGetHorizontalScrollPosition"),
		setVerticalScrollPosition = dgsOOP.genOOPFnc("dgsScrollPaneSetVerticalScrollPosition",true),
		getVerticalScrollPosition = dgsOOP.genOOPFnc("dgsScrollPaneGetVerticalScrollPosition"),
		setScrollBarState = dgsOOP.genOOPFnc("dgsScrollPaneSetScrollBarState",true),
		getScrollBarState = dgsOOP.genOOPFnc("dgsScrollPaneGetScrollBarState"),
	};
}

--------------------------Selector
class {
	extends = "dgs2D";
	type = "dgsSelector";
	dgsType = "dgs-dxselector";
	preInstantiate = function(parent,x,y,w,h,rlt,...)
		return call(dgsOOP.dgsRes,"dgsCreateSelector",x,y,w,h,rlt,parent.dgsElement,...)
	end;
	public = {
		--[[setColor = dgsOOP.genOOPFnc("dgsLabelSetColor",true),
		getColor = dgsOOP.genOOPFnc("dgsLabelGetColor"),
		setHorizontalAlign = dgsOOP.genOOPFnc("dgsLabelSetHorizontalAlign",true),
		getHorizontalAlign = dgsOOP.genOOPFnc("dgsLabelGetHorizontalAlign"),
		setVerticalAlign = dgsOOP.genOOPFnc("dgsLabelSetVerticalAlign",true),
		getVerticalAlign = dgsOOP.genOOPFnc("dgsLabelGetVerticalAlign"),
		getTextExtent = dgsOOP.genOOPFnc("dgsLabelGetTextExtent"),
		getFontHeight = dgsOOP.genOOPFnc("dgsLabelGetFontHeight"),]]
	};
}

--------------------------SwitchButton
class {
	extends = "dgs2D";
	type = "dgsSwitchButton";
	dgsType = "dgs-dxswitchbutton";
	preInstantiate = function(parent,x,y,w,h,textOn,textOff,state,rlt,...)
		return call(dgsOOP.dgsRes,"dgsCreateSwitchButton",x,y,w,h,textOn,textOff,state,rlt,parent.dgsElement,...)
	end;
	public = {
		setState = dgsOOP.genOOPFnc("dgsSwitchButtonSetState",true),
		getState = dgsOOP.genOOPFnc("dgsSwitchButtonGetState"),
		setText = dgsOOP.genOOPFnc("dgsSwitchButtonSetText",true),
		getText = dgsOOP.genOOPFnc("dgsSwitchButtonGetText"),
	};
}

--------------------------Tab
class {
	extends = "dgs2D";
	type = "dgsTab";
	dgsType = "dgs-dxtab";
	preInstantiate = function(parent,text,...)
		return call(dgsOOP.dgsRes,"dgsCreateTab",text,parent.dgsElement,...)
	end;
	public = {
		delete = dgsOOP.genOOPFnc("dgsDeleteTab"),
	};
}

--------------------------TabPanel
class {
	extends = "dgs2D";
	type = "dgsTabPanel";
	dgsType = "dgs-dxtabpanel";
	preInstantiate = function(parent,x,y,w,h,rlt,...)
		return call(dgsOOP.dgsRes,"dgsCreateTabPanel",x,y,w,h,rlt,parent.dgsElement,...)
	end;
	public = {
		getSelectedTab = dgsOOP.genOOPFnc("dgsGetSelectedTab"),
		setSelectedTab = dgsOOP.genOOPFnc("dgsSetSelectedTab",true),
		getTabFromID = dgsOOP.genOOPFnc("dgsTabPanelGetTabFromID"),
		moveTab = dgsOOP.genOOPFnc("dgsTabPanelMoveTab",true),
		getTabID = dgsOOP.genOOPFnc("dgsTabPanelGetTabID"),
		dgsTab = function(...) return dgsOOP.dgsTab(...) end,
	};
}

--------------------------Window
class {
	extends = "dgs2D";
	type = "dgsWindow";
	dgsType = "dgs-dxwindow";
	preInstantiate = function(parent,...)
		return call(dgsOOP.dgsRes,"dgsCreateWindow",...)
	end;
	public = {
		setSizable = dgsOOP.genOOPFnc("dgsWindowSetSizable",true),
		setMovable = dgsOOP.genOOPFnc("dgsWindowSetMovable",true),
		getSizable = dgsOOP.genOOPFnc("dgsWindowGetSizable"),
		getMovable = dgsOOP.genOOPFnc("dgsWindowGetMovable"),
		close = dgsOOP.genOOPFnc("dgsCloseWindow"),
		setCloseButtonEnabled = dgsOOP.genOOPFnc("dgsWindowSetCloseButtonEnabled",true),
		getCloseButtonEnabled = dgsOOP.genOOPFnc("dgsWindowGetCloseButtonEnabled"),
		setCloseButtonSize = dgsOOP.genOOPFnc("dgsWindowSetCloseButtonSize",true),
		getCloseButtonSize = dgsOOP.genOOPFnc("dgsWindowGetCloseButtonSize"),
		getCloseButton = dgsOOP.genOOPFnc("dgsWindowGetCloseButton"),
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
	extends = "dgsRoot";
	type = "dgs3D";
	public = {
		__index=function(self,key)
			if key == "children" then
				return self:getChildren()
			elseif key == "position" then
				return dgsOOP.generateInterface(self.dgsElement,dgsOOP.position3D)
			end
			return call(dgsOOP.dgsRes,"dgsGetProperty",self.dgsElement,key)
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
			return call(dgsOOP.dgsRes,"dgsSetProperty",self.dgsElement,key,value) and self or false
		end
	};
}

class {
	extends = "dgs3D";
	type = "dgs3DInterface";
	dgsType="dgs-dx3dinterface";
	preInstantiate = function(parent,...)
		return call(dgsOOP.dgsRes,"dgsCreate3DInterface",...)
	end;
	public = {
		getBlendMode = dgsOOP.genOOPFnc("dgs3DInterfaceGetBlendMode"),
		setBlendMode = dgsOOP.genOOPFnc("dgs3DInterfaceSetBlendMode",true),
		getPosition = dgsOOP.genOOPFnc("dgs3DInterfaceGetPosition"),
		setPosition = dgsOOP.genOOPFnc("dgs3DInterfaceSetPosition",true),
		getSize = dgsOOP.genOOPFnc("dgs3DInterfaceGetSize"),
		setSize = dgsOOP.genOOPFnc("dgs3DInterfaceSetSize",true),
		getResolution = dgsOOP.genOOPFnc("dgs3DInterfaceGetResolution"),
		setResolution = dgsOOP.genOOPFnc("dgs3DInterfaceSetResolution",true),
		attachToElement = dgsOOP.genOOPFnc("dgs3DInterfaceAttachToElement",true),
		isAttached = dgsOOP.genOOPFnc("dgs3DInterfaceIsAttached",true),
		getResolution = dgsOOP.genOOPFnc("dgs3DInterfaceGetResolution"),
		setResolution = dgsOOP.genOOPFnc("dgs3DInterfaceSetResolution",true),
		detachFromElement = dgsOOP.genOOPFnc("dgs3DInterfaceDetachFromElement",true),
		setAttachedOffsets = dgsOOP.genOOPFnc("dgs3DInterfaceSetAttachedOffsets",true),
		getAttachedOffsets = dgsOOP.genOOPFnc("dgs3DInterfaceGetAttachedOffsets"),
		setRotation = dgsOOP.genOOPFnc("dgs3DInterfaceSetRotation",true),
		getRotation = dgsOOP.genOOPFnc("dgs3DInterfaceGetRotation"),
		setFaceTo = dgsOOP.genOOPFnc("dgs3DInterfaceSetFaceTo",true),
		getFaceTo = dgsOOP.genOOPFnc("dgs3DInterfaceGetFaceTo"),
	};
}

class {
	extends = "dgs3D";
	type = "dgs3DText";
	dgsType="dgs-dx3dtext";
	preInstantiate = function(parent,...)
		return call(dgsOOP.dgsRes,"dgsCreate3DText",...)
	end;
	public = {
		getDimension = dgsOOP.genOOPFnc("dgs3DTextGetDimension"),
		setDimension = dgsOOP.genOOPFnc("dgs3DTextSetDimension",true),
		getInterior = dgsOOP.genOOPFnc("dgs3DTextGetInterior"),
		setInterior = dgsOOP.genOOPFnc("dgs3DTextSetInterior",true),
		attachToElement = dgsOOP.genOOPFnc("dgs3DTextAttachToElement",true),
		detachFromElement = dgsOOP.genOOPFnc("dgs3DTextDetachFromElement",true),
		isAttached = dgsOOP.genOOPFnc("dgs3DTextIsAttached"),
		setAttachedOffsets = dgsOOP.genOOPFnc("dgs3DTextSetAttachedOffsets",true),
		getAttachedOffsets = dgsOOP.genOOPFnc("dgs3DTextGetAttachedOffsets"),
		setPosition = dgsOOP.genOOPFnc("dgs3DTextSetPosition",true),
		getPosition = dgsOOP.genOOPFnc("dgs3DTextGetPosition"),
	};
}

dgsRootInstance = dgsOOP.dgsRoot()
end