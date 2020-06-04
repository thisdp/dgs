dgsOOP = {}
dgsResName = getResourceName(getThisResource())
function dgsImportOOPClass(polluteGlobal)
	local predefinedObj = ""
	for k,v in pairs(dgsOOP) do
		predefinedObj = predefinedObj..[[
		
		dgsOOP["]]..k..[["] = {]]..v..[[}
		]]
	end
	return [[
	--Check Error Message Above
	if globalDGSOOP then return end
	if not dgsImportFunction then
		loadstring(exports["]]..dgsResName..[["]:dgsImportFunction())()
	end
	local call = call
	local dgsOOP = {}
	globalDGSOOP = dgsOOP
	dgsOOP.dgsName = "]]..dgsResName..[["
	dgsOOP.dgsRes = getResourceFromName(dgsOOP.dgsName)
	dgsRoot = getResourceRootElement(dgsOOP.dgsRes)
	dgsOOP.dgsClass = {}
	dgsOOP.eventHandler = {}
	dgsOOP.transfromEventName = function(eventName,isReverse)
		return isReverse and (eventName:sub(3,3):lower()..eventName:sub(4)) or ("on"..eventName:sub(1,1):upper()..eventName:sub(2))
	end
	dgsOOP.tableCopy = function(t)
		local nt = {}
		for k,v in pairs(t) do nt[k] = v end
		return nt
	end
	dgsOOP.genOOPFnc = function(pop,isChain)
		if isChain then
			return function(self,...) return call(dgsOOP.dgsRes,pop,self.dgsElement,...) and self or false end
		else
			return function(self,...) return dgsGetClass(call(dgsOOP.dgsRes,pop,self.dgsElement,...)) end
		end
	end

	dgsOOP.genOOPFncNonObj = function(pop,isChain)
		return function(self,...) return dgsGetClass(call(dgsOOP.dgsRes,pop,...)) end
	end
	
	dgsOOP.dgsClassGen = {}
	setmetatable(dgsOOP.dgsClassGen,{
		__call=function(self,dgsElement,meta)
			local t = {"DGS OOP: Bad usage"}
			local newmeta = dgsOOP.tableCopy(meta)
			newmeta.dgsElement = dgsElement
			setmetatable(t,newmeta)
			t()
			return t
		end,
	})
	
	dgsOOP.PositionTable = {
		__isAvailable = true,
		__index=function(self,key)
			local meta = getmetatable(self)
			if not meta.__isAvailable or not isElement(meta.dgsElement) then
				meta.__isAvailable = false
				return false
			end
			if key == "relative" then
				return dgsGetProperty(meta.dgsElement,"relative")[1]
			elseif key == "x" then
				local pos = dgsGetProperty(meta.dgsElement,"relative")[1] and dgsGetProperty(meta.dgsElement,"rltPos") or dgsGetProperty(meta.dgsElement,"absPos")
				return pos[1]
			elseif key == "y" then
				local pos = dgsGetProperty(meta.dgsElement,"relative")[1] and dgsGetProperty(meta.dgsElement,"rltPos") or dgsGetProperty(meta.dgsElement,"absPos")
				return pos[2]
			elseif key == "vector" then
				local pos = dgsGetProperty(meta.dgsElement,"relative")[1] and dgsGetProperty(meta.dgsElement,"rltPos") or dgsGetProperty(meta.dgsElement,"absPos")
				return Vector2(pos)
			end
		end,
		__newindex=function(self,key,value)
			local meta = getmetatable(self)
			if not meta.__isAvailable or not isElement(meta.dgsElement) then
				meta.__isAvailable = false
				return false
			end
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
	
	dgsOOP.SizeTable = {
		__isAvailable = true,
		__index=function(self,key)
			local meta = getmetatable(self)
			if not meta.__isAvailable or not isElement(meta.dgsElement) then
				meta.__isAvailable = false
				return false
			end
			if key == "relative" then
				return dgsGetProperty(meta.dgsElement,"relative")[2]
			elseif key == "w" or key == "width" then
				local size = dgsGetProperty(meta.dgsElement,"relative")[2] and dgsGetProperty(meta.dgsElement,"rltSize") or dgsGetProperty(meta.dgsElement,"absSize")
				return size[1]
			elseif key == "h" or key == "height" then
				local size = dgsGetProperty(meta.dgsElement,"relative")[2] and dgsGetProperty(meta.dgsElement,"rltSize") or dgsGetProperty(meta.dgsElement,"absSize")
				return size[2]
			elseif key == "vector" then
				local size = dgsGetProperty(meta.dgsElement,"relative")[2] and dgsGetProperty(meta.dgsElement,"rltSize") or dgsGetProperty(meta.dgsElement,"absSize")
				return Vector2(size)
			end
		end,
		__newindex=function(self,key,value)
			local meta = getmetatable(self)
			if not meta.__isAvailable or not isElement(meta.dgsElement) then
				meta.__isAvailable = false
				return false
			end
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
	
	dgsOOP.AccessTable = {
		__index=function(self,key)
			if key == "parent" then
				local parent = call(dgsOOP.dgsRes,"dgsGetParent",self.dgsElement,key)
				return parent and dgsGetClass(parent) or false
			elseif key == "children" then
				return self:getChildren()
			elseif key == "size" then
				return dgsOOP.dgsClassGen(self.dgsElement,dgsOOP.SizeTable)
			elseif key == "position" then
				return dgsOOP.dgsClassGen(self.dgsElement,dgsOOP.PositionTable)
			end
			return call(dgsOOP.dgsRes,"dgsGetProperty",self.dgsElement,key)
		end,
		__newindex=function(self,key,value)
			if key == "parent" then
				local targetEle
				if type(value) == "table" then
					targetEle = value.dgsElement
				end
				return call(dgsOOP.dgsRes,"dgsSetParent",self.dgsElement,targetEle)
			elseif key == "size" then
				return dgsOOP.dgsClassGen(self.dgsElement,dgsOOP.SizeTable)
			elseif key == "position" then
				return dgsOOP.dgsClassGen(self.dgsElement,dgsOOP.PositionTable)
			end
			return call(dgsOOP.dgsRes,"dgsSetProperty",self.dgsElement,key,value) and self or false
		end,
		__metatable=true
	}

	dgsOOP.NoParent = {
		dgsWindow = function(self,...) return dgsGetClass(call(dgsOOP.dgsRes,"dgsCreateWindow",...)) end,
		dgs3DInterface = function(self,...) return dgsGetClass(call(dgsOOP.dgsRes,"dgsCreate3DInterface",...)) end,
		dgs3DText = function(self,...) return dgsGetClass(call(dgsOOP.dgsRes,"dgsCreate3DText",...)) end,
	}

	dgsOOP.HaveParent = {
		dgsBrowser = function(self,x,y,w,h,relative,...) return dgsGetClass(call(dgsOOP.dgsRes,"dgsCreateBrowser",x,y,w,h,relative,self.dgsElement,...)) end,
		dgsButton = function(self,x,y,w,h,text,relative,...) return dgsGetClass(call(dgsOOP.dgsRes,"dgsCreateButton",x,y,w,h,text,relative,self.dgsElement,...)) end,
		dgsCheckBox = function(self,x,y,w,h,text,state,relative,...) return dgsGetClass(call(dgsOOP.dgsRes,"dgsCreateCheckBox",x,y,w,h,text,state,relative,self.dgsElement,...)) end,
		dgsComboBox = function(self,x,y,w,h,text,relative,...) return dgsGetClass(call(dgsOOP.dgsRes,"dgsCreateComboBox",x,y,w,h,text,relative,self.dgsElement,...)) end,
		dgsCustomRenderer = function(self,customFnc) return dgsGetClass(call(dgsOOP.dgsRes,"dgsCreateCustomRenderer",customFnc)) end,
		dgsDetectArea = function(self,x,y,w,h,relative,...) return dgsGetClass(call(dgsOOP.dgsRes,"dgsCreateDetectArea",x,y,w,h,text,relative,self.dgsElement,...)) end,
		dgsEdit = function(self,x,y,w,h,text,relative,...) return dgsGetClass(call(dgsOOP.dgsRes,"dgsCreateEdit",x,y,w,h,text,relative,self.dgsElement,...)) end,
		dgsGridList = function(self,x,y,w,h,relative,...) return dgsGetClass(call(dgsOOP.dgsRes,"dgsCreateGridList",x,y,w,h,relative,self.dgsElement,...)) end,
		dgsImage = function(self,x,y,w,h,image,relative,...) return dgsGetClass(call(dgsOOP.dgsRes,"dgsCreateImage",x,y,w,h,image,relative,self.dgsElement,...)) end,
		dgsLabel = function(self,x,y,w,h,text,relative,...) return dgsGetClass(call(dgsOOP.dgsRes,"dgsCreateLabel",x,y,w,h,text,relative,self.dgsElement,...)) end,
		dgsMemo = function(self,x,y,w,h,text,relative,...) return dgsGetClass(call(dgsOOP.dgsRes,"dgsCreateMemo",x,y,w,h,text,relative,self.dgsElement,...)) end,
		dgsProgressBar = function(self,x,y,w,h,relative,...) return dgsGetClass(call(dgsOOP.dgsRes,"dgsCreateProgressBar",x,y,w,h,relative,self.dgsElement,...)) end,
		dgsRadioButton = function(self,x,y,w,h,text,relative,...) return dgsGetClass(call(dgsOOP.dgsRes,"dgsCreateRadioButton",x,y,w,h,text,relative,self.dgsElement,...)) end,
		dgsScrollBar = function(self,x,y,w,h,voh,relative,...) return dgsGetClass(call(dgsOOP.dgsRes,"dgsCreateScrollBar",x,y,w,h,voh,relative,self.dgsElement,...)) end,
		dgsScrollPane = function(self,x,y,w,h,relative,...) return dgsGetClass(call(dgsOOP.dgsRes,"dgsCreateScrollPane",x,y,w,h,relative,self.dgsElement,...)) end,
		dgsSwitchButton = function(self,x,y,w,h,textOn,textOff,state,relative,...) return dgsGetClass(call(dgsOOP.dgsRes,"dgsCreateSwitchButton",x,y,w,h,textOn,textOff,state,relative,self.dgsElement,...)) end,
		dgsTabPanel = function(self,x,y,w,h,relative,...) return dgsGetClass(call(dgsOOP.dgsRes,"dgsCreateTabPanel",x,y,w,h,relative,self.dgsElement,...)) end,
	}

	]]..predefinedObj..[[
	
	function dgsGetClass(dgsElement,...)
		local typ = type(dgsElement)
		if typ ~= "table" and typ ~= "userdata" then return dgsElement end
		if typ == "table" then 
			local t = {}
			for i=1,#dgsElement do
				t[i] = dgsGetClass(dgsElement[i])
			end
			return t
		end
		if not isElement(dgsElement) then return false end
		local originalClass = dgsOOP.dgsClass[dgsElement]
		if originalClass and originalClass.dgsElement == dgsElement then
			return originalClass
		end
		local nTab = {
			dgsElement = dgsElement,
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
			destroy = function(self,...) return destroyElement(self.dgsElement) end,
			isElement = function(self) return isElement(self.dgsElement) end,
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
			on = function(self,eventName,theFnc,p)
				local eventName = dgsOOP.transfromEventName(eventName)
				removeEventHandler(eventName,self.dgsElement,theFnc)
				dgsOOP.eventHandler[eventName] = dgsOOP.eventHandler[eventName] or {}
				dgsOOP.eventHandler[eventName][self.dgsElement] = dgsOOP.eventHandler[eventName][self.dgsElement] or {}
				local eventFncEnv = {}
				setmetatable(eventFncEnv,{__index = _G,__newindex = _G})
				setfenv(theFnc,eventFncEnv)
				local function callBack(...)
					local s = dgsGetClass(source)
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
			attach = dgsOOP.genOOPFnc("dgsAttachElements",true),
			detach = dgsOOP.genOOPFnc("dgsDetachElements",true),
			isAttached = dgsOOP.genOOPFnc("dgsElementIsAttached"),
		}
		for k,v in pairs(dgsOOP.HaveParent) do nTab[k]=v end
		local dgsType = call(dgsOOP.dgsRes,"dgsGetType",dgsElement)
		for k,v in pairs(dgsOOP[dgsType] or {}) do nTab[k] = v end
		setmetatable(nTab,dgsOOP.AccessTable)
		dgsOOP.dgsClass[dgsElement] = nTab
		return nTab
	end

	DGSClass = {
		getClass = function(self,dgsElement) return dgsGetClass(dgsElement) end,
		isStyleAvailable = dgsOOP.genOOPFncNonObj("dgsIsStyleAvailable"),
		getLoadedStyleList = dgsOOP.genOOPFncNonObj("dgsGetLoadedStyleList"),
		setCurrentStyle = dgsOOP.genOOPFncNonObj("dgsSetCurrentStyle"),
		getCurrentStyle = dgsOOP.genOOPFncNonObj("dgsGetCurrentStyle"),
		getScreenSize = function(self) return guiGetScreenSize() end,
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
	}
	for k,v in pairs(dgsOOP.NoParent) do
		DGSClass[k] = v
	]]..(polluteGlobal and [[
		_G[k] = function(...) return DGSClass[k](DGSClass,...) end
	]] or "")..[[
	end
	for k,v in pairs(dgsOOP.HaveParent) do
		DGSClass[k] = v
	]]..(polluteGlobal and [[
		_G[k] = function(...) return DGSClass[k](DGSClass,...) end
	]] or "")..[[
	end
	dgsRootObject = dgsGetClass(dgsRoot)
	resourceRootObject = dgsGetClass(resourceRoot)
	rootObject = dgsGetClass(root)
]]
end

