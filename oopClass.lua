dgsResName = getResourceName(getThisResource())
function dgsImportOOPClass(polluteGlobal)
	local syntaxSugar = " and self or false"
	local str = [[
	--Check Error Message Above
	if not dgsOOP then
		local call = call
		dgsOOP = {}
		dgsOOP.dgsName = "]]..dgsResName..[["
		dgsOOP.dgsRes = getResourceFromName(dgsOOP.dgsName)
		dgsRoot = getResourceRootElement(dgsOOP.dgsRes)
		dgsOOP.dgsRoot = dgsRoot
		dgsOOP.dgsClass = {}
		dgsOOP.transfromEventName = function(eventName,isReverse)
			if isReverse then
				local head = eventName:sub(3,3):lower()
				return head..eventName:sub(4)
			else
				local head = eventName:sub(1,1):upper()
				return "on"..head..eventName:sub(2)
			end
		end
		dgsOOP.tableCopy = function(t)
			local nt = {}
			for k,v in pairs(t) do
				nt[k] = v
			end
			return nt
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
					local rlt = dgsGetProperty(meta.dgsElement,"relative")[1]
					local pos = rlt and dgsGetProperty(meta.dgsElement,"rltPos") or dgsGetProperty(meta.dgsElement,"absPos")
					return pos[1]
				elseif key == "y" then
					local rlt = dgsGetProperty(meta.dgsElement,"relative")[1]
					local pos = rlt and dgsGetProperty(meta.dgsElement,"rltPos") or dgsGetProperty(meta.dgsElement,"absPos")
					return pos[2]
				elseif key == "vector" then
					local rlt = dgsGetProperty(meta.dgsElement,"relative")[1]
					local pos = rlt and dgsGetProperty(meta.dgsElement,"rltPos") or dgsGetProperty(meta.dgsElement,"absPos")
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
					local rlt = dgsGetProperty(meta.dgsElement,"relative")[2]
					local size = rlt and dgsGetProperty(meta.dgsElement,"rltSize") or dgsGetProperty(meta.dgsElement,"absSize")
					return size[1]
				elseif key == "h" or key == "height" then
					local rlt = dgsGetProperty(meta.dgsElement,"relative")[2]
					local size = rlt and dgsGetProperty(meta.dgsElement,"rltSize") or dgsGetProperty(meta.dgsElement,"absSize")
					return size[2]
				elseif key == "vector" then
					local rlt = dgsGetProperty(meta.dgsElement,"relative")[2]
					local size = rlt and dgsGetProperty(meta.dgsElement,"rltSize") or dgsGetProperty(meta.dgsElement,"absSize")
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
				elseif key == "x" then
					local rlt = dgsGetProperty(meta.dgsElement,"relative")
					return dgsSetSize(meta.dgsElement,value,_,rlt[2])
				elseif key == "y" then
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
				return call(dgsOOP.dgsRes,"dgsSetProperty",self.dgsElement,key,value) #SyntaxSugar#
			end,
			__metatable=true
		}

		dgsOOP.NoParent = {
			dgsWindow = function(self,...)
				local dxgui = call(dgsOOP.dgsRes,"dgsCreateWindow",...)
				return dgsGetClass(dxgui)
			end,
			dgs3DInterface = function(self,...)
				local dxgui = call(dgsOOP.dgsRes,"dgsCreate3DInterface",...)
				return dgsGetClass(dxgui)
			end,
			dgs3DText = function(self,...)
				local dxgui = call(dgsOOP.dgsRes,"dgsCreate3DText",...)
				return dgsGetClass(dxgui)
			end,
		}

		dgsOOP.HaveParent = {
			dgsBrowser = function(self,x,y,w,h,relative,...)
				local dxgui = call(dgsOOP.dgsRes,"dgsCreateBrowser",x,y,w,h,relative,self.dgsElement,...)
				return dgsGetClass(dxgui)
			end,
			dgsButton = function(self,x,y,w,h,text,relative,...)
				local dxgui = call(dgsOOP.dgsRes,"dgsCreateButton",x,y,w,h,text,relative,self.dgsElement,...)
				return dgsGetClass(dxgui)
			end,
			dgsCheckBox = function(self,x,y,w,h,text,state,relative,...)
				local dxgui = call(dgsOOP.dgsRes,"dgsCreateCheckBox",x,y,w,h,text,state,relative,self.dgsElement,...)
				return dgsGetClass(dxgui)
			end,
			dgsComboBox = function(self,x,y,w,h,text,relative,...)
				local dxgui = call(dgsOOP.dgsRes,"dgsCreateComboBox",x,y,w,h,text,relative,self.dgsElement,...)
				return dgsGetClass(dxgui)
			end,
			dgsCustomRenderer = function(self,customFnc)
				local dxgui = call(dgsOOP.dgsRes,"dgsCreateCustomRenderer",customFnc)
				return dgsGetClass(dxgui)
			end,
			dgsDetectArea = function(self,x,y,w,h,relative,...)
				local dxgui = call(dgsOOP.dgsRes,"dgsCreateDetectArea",x,y,w,h,text,relative,self.dgsElement,...)
				return dgsGetClass(dxgui)
			end,
			dgsEdit = function(self,x,y,w,h,text,relative,...)
				local dxgui = call(dgsOOP.dgsRes,"dgsCreateEdit",x,y,w,h,text,relative,self.dgsElement,...)
				return dgsGetClass(dxgui)
			end,
			dgsGridList = function(self,x,y,w,h,relative,...)
				local dxgui = call(dgsOOP.dgsRes,"dgsCreateGridList",x,y,w,h,relative,self.dgsElement,...)
				return dgsGetClass(dxgui)
			end,
			dgsImage = function(self,x,y,w,h,image,relative,...)
				local dxgui = call(dgsOOP.dgsRes,"dgsCreateImage",x,y,w,h,image,relative,self.dgsElement,...)
				return dgsGetClass(dxgui)
			end,
			dgsLabel = function(self,x,y,w,h,text,relative,...)
				local dxgui = call(dgsOOP.dgsRes,"dgsCreateLabel",x,y,w,h,text,relative,self.dgsElement,...)
				return dgsGetClass(dxgui)
			end,
			dgsMemo = function(self,x,y,w,h,text,relative,...)
				local dxgui = call(dgsOOP.dgsRes,"dgsCreateMemo",x,y,w,h,text,relative,self.dgsElement,...)
				return dgsGetClass(dxgui)
			end,
			dgsProgressBar = function(self,x,y,w,h,relative,...)
				local dxgui = call(dgsOOP.dgsRes,"dgsCreateProgressBar",x,y,w,h,relative,self.dgsElement,...)
				return dgsGetClass(dxgui)
			end,
			dgsRadioButton = function(self,x,y,w,h,text,relative,...)
				local dxgui = call(dgsOOP.dgsRes,"dgsCreateRadioButton",x,y,w,h,text,relative,self.dgsElement,...)
				return dgsGetClass(dxgui)
			end,
			dgsScrollBar = function(self,x,y,w,h,voh,relative,...)
				local dxgui = call(dgsOOP.dgsRes,"dgsCreateScrollBar",x,y,w,h,voh,relative,self.dgsElement,...)
				return dgsGetClass(dxgui)
			end,
			dgsScrollPane = function(self,x,y,w,h,relative,...)
				local dxgui = call(dgsOOP.dgsRes,"dgsCreateScrollPane",x,y,w,h,relative,self.dgsElement,...)
				return dgsGetClass(dxgui)
			end,
			dgsSwitchButton = function(self,x,y,w,h,textOn,textOff,state,relative,...)
				local dxgui = call(dgsOOP.dgsRes,"dgsCreateSwitchButton",x,y,w,h,textOn,textOff,state,relative,self.dgsElement,...)
				return dgsGetClass(dxgui)
			end,
			dgsTabPanel = function(self,x,y,w,h,relative,...)
				local dxgui = call(dgsOOP.dgsRes,"dgsCreateTabPanel",x,y,w,h,relative,self.dgsElement,...)
				return dgsGetClass(dxgui)
			end,
		}

		function dgsGetClass(dgsElement)
			if type(dgsElement) == "table" then 
				local t = {}
				for i=1,#dgsElement do
					t[i] = dgsGetClass(dgsElement[i])
				end
				return t
			end
			if not isElement(dgsElement) then return false end
			local originalClass = dgsOOP.dgsClass[dgsElement]
			if originalClass then
				if originalClass.dgsElement == dgsElement then
					return originalClass
				end
			end
			local nTab = {
				dgsElement = dgsElement,
				getPosition = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGetPosition",self.dgsElement,...)
				end,
				setPosition = function(self,...)
					return call(dgsOOP.dgsRes,"dgsSetPosition",self.dgsElement,...) #SyntaxSugar#
				end,
				getParent = function(self,...)
					return dgsGetClass(call(dgsOOP.dgsRes,"dgsGetParent",self.dgsElement,...))
				end,
				setParent = function(self,parent,nocheck)
					if type(parent) == "table" and isElement(parent.dgsElement) then
						parent = parent.dgsElement
					end
					return call(dgsOOP.dgsRes,"dgsSetParent",self.dgsElement,parent,nocheck) #SyntaxSugar#
				end,
				getChild = function(self,...)
					return dgsGetClass(call(dgsOOP.dgsRes,"dgsGetChild",self.dgsElement,...))
				end,
				getChildren = function(self,...)
					local children = call(dgsOOP.dgsRes,"dgsGetChildren",self.dgsElement,...)
					local newChildren = {}
					for i=1,#children do
						newChildren[i] = dgsGetClass(children[i])
					end
					return newChildren
				end,
				getSize = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGetSize",self.dgsElement,...)
				end,
				setSize = function(self,...)
					return call(dgsOOP.dgsRes,"dgsSetSize",self.dgsElement,...) #SyntaxSugar#
				end,
				getType = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGetType",self.dgsElement,...)
				end,
				setLayer = function(self,...)
					return call(dgsOOP.dgsRes,"dgsSetLayer",self.dgsElement,...) #SyntaxSugar#
				end,
				getLayer = function(self,...)
					return call(dgsOOP.dgsRes,"dgsSetLayer",self.dgsElement,...)
				end,
				setCurrentLayerIndex = function(self,...)
					return call(dgsOOP.dgsRes,"dgsSetCurrentLayerIndex",self.dgsElement,...) #SyntaxSugar#
				end,
				getCurrentLayerIndex = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGetCurrentLayerIndex",self.dgsElement,...)
				end,
				getProperty = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGetProperty",self.dgsElement,...)
				end,
				setProperty = function(self,...)
					return call(dgsOOP.dgsRes,"dgsSetProperty",self.dgsElement,...) #SyntaxSugar#
				end,
				getProperties = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGetProperties",self.dgsElement,...)
				end,
				setProperties = function(self,...)
					return call(dgsOOP.dgsRes,"dgsSetProperties",self.dgsElement,...) #SyntaxSugar#
				end,
				getVisible = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGetVisible",self.dgsElement,...)
				end,
				setVisible = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGetVisible",self.dgsElement,...) #SyntaxSugar#
				end,
				getEnabled = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGetEnabled",self.dgsElement,...)
				end,
				setEnabled = function(self,...)
					return call(dgsOOP.dgsRes,"dgsSetEnabled",self.dgsElement,...) #SyntaxSugar#
				end,
				blur = function(self,...)
					return call(dgsOOP.dgsRes,"dgsBlur",self.dgsElement,...) #SyntaxSugar#
				end,
				focus = function(self,...)
					return call(dgsOOP.dgsRes,"dgsFocus",self.dgsElement,...) #SyntaxSugar#
				end,
				getSide = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGetSide",self.dgsElement,...)
				end,
				setSide = function(self,...)
					return call(dgsOOP.dgsRes,"dgsSetSide",self.dgsElement,...) #SyntaxSugar#
				end,
				getAlpha = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGetAlpha",self.dgsElement,...)
				end,
				setAlpha = function(self,...)
					return call(dgsOOP.dgsRes,"dgsSetAlpha",self.dgsElement,...) #SyntaxSugar#
				end,
				getFont = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGetFont",self.dgsElement,...)
				end,
				setFont = function(self,...)
					return call(dgsOOP.dgsRes,"dgsSetFont",self.dgsElement,...) #SyntaxSugar#
				end,
				getText = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGetText",self.dgsElement,...)
				end,
				setText = function(self,...)
					return call(dgsOOP.dgsRes,"dgsSetText",self.dgsElement,...) #SyntaxSugar#
				end,
				bringToFront = function(self,...)
					return call(dgsOOP.dgsRes,"dgsBringToFront",self.dgsElement,...) #SyntaxSugar#
				end,
				moveToBack = function(self,...)
					return call(dgsOOP.dgsRes,"dgsMoveToBack",self.dgsElement,...) #SyntaxSugar#
				end,
				simulateClick = function(self,...)
					return call(dgsOOP.dgsRes,"dgsSimulateClick",self.dgsElement,...) #SyntaxSugar#
				end,
				animTo = function(self,...)
					return call(dgsOOP.dgsRes,"dgsAnimTo",self.dgsElement,...) #SyntaxSugar#
				end,
				isAniming = function(self,...)
					return call(dgsOOP.dgsRes,"dgsIsAniming",self.dgsElement,...)
				end,
				stopAniming = function(self,...)
					return call(dgsOOP.dgsRes,"dgsStopAniming",self.dgsElement,...) #SyntaxSugar#
				end,
				moveTo = function(self,...)
					return call(dgsOOP.dgsRes,"dgsMoveTo",self.dgsElement,...) #SyntaxSugar#
				end,
				isMoving = function(self,...)
					return call(dgsOOP.dgsRes,"dgsIsMoving",self.dgsElement,...)
				end,
				stopMoving = function(self,...)
					return call(dgsOOP.dgsRes,"dgsStopMoving",self.dgsElement,...) #SyntaxSugar#
				end,
				sizeTo = function(self,...)
					return call(dgsOOP.dgsRes,"dgsSizeTo",self.dgsElement,...) #SyntaxSugar#
				end,
				isSizing = function(self,...)
					return call(dgsOOP.dgsRes,"dgsIsSizing",self.dgsElement,...)
				end,
				stopSizing = function(self,...)
					return call(dgsOOP.dgsRes,"dgsStopSizing",self.dgsElement,...) #SyntaxSugar#
				end,
				alphaTo = function(self,...)
					return call(dgsOOP.dgsRes,"dgsAlphaTo",self.dgsElement,...) #SyntaxSugar#
				end,
				isAlphaing = function(self,...)
					return call(dgsOOP.dgsRes,"dgsIsAlphaing",self.dgsElement,...)
				end,
				stopAlphaing = function(self,...)
					return call(dgsOOP.dgsRes,"dgsStopAlphaing",self.dgsElement,...) #SyntaxSugar#
				end,
				getPostGUI = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGetPostGUI",self.dgsElement,...)
				end,
				setPostGUI = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGetPostGUI",self.dgsElement,...) #SyntaxSugar#
				end,
				center = function(self,...)
					return call(dgsOOP.dgsRes,"dgsCenterElement",self.dgsElement,...) #SyntaxSugar#
				end,
				destroy = function(self,...)
					return destroyElement(self.dgsElement)
				end,
				isElement = function(self)
					return isElement(self.dgsElement)
				end,
				getElement = function(self)
					return self.dgsElement
				end,
				addMoveHandler = function(self,...)
					return call(dgsOOP.dgsRes,"dgsAddMoveHandler",self.dgsElement,...) #SyntaxSugar#
				end,
				removeMoveHandler = function(self,...)
					return call(dgsOOP.dgsRes,"dgsRemoveMoveHandler",self.dgsElement,...) #SyntaxSugar#
				end,
				isMoveHandled = function(self,...)
					return call(dgsOOP.dgsRes,"dgsIsMoveHandled",self.dgsElement,...)
				end,
				addSizeHandler = function(self,...)
					return call(dgsOOP.dgsRes,"dgsAddSizeHandler",self.dgsElement,...) #SyntaxSugar#
				end,
				removeSizeHandler = function(self,...)
					return call(dgsOOP.dgsRes,"dgsRemoveSizeHandler",self.dgsElement,...) #SyntaxSugar#
				end,
				isSizeHandled = function(self,...)
					return call(dgsOOP.dgsRes,"dgsIsSizeHandled",self.dgsElement,...)
				end,
				attachToTranslation = function(self,...)
					return call(dgsOOP.dgsRes,"dgsAttachToTranslation",self.dgsElement,...) #SyntaxSugar#
				end,
				detachFromTranslation = function(self,...)
					return call(dgsOOP.dgsRes,"dgsDetachFromTranslation",self.dgsElement,...) #SyntaxSugar#
				end,
				getTranslationName = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGetTranslationName",self.dgsElement,...)
				end,
				on = function(self,eventName,theFnc)
					local eventName = dgsOOP.transfromEventName(eventName)
					removeEventHandler(eventName,self.dgsElement,theFnc)
					local newfenv = {self=self}
					setmetatable(newfenv,{__index = _G})
					setfenv(theFnc,newfenv)
					return addEventHandler(eventName,self.dgsElement,theFnc,false) #SyntaxSugar#
				end,
				removeOn = function(self,eventName,theFnc)
					local eventName = dgsOOP.transfromEventName(eventName)
					return removeEventHandler(eventName,self.dgsElement,theFnc) #SyntaxSugar#
				end,
				attach = function(self,...)
					return call(dgsOOP.dgsRes,"dgsAttachElements",self.dgsElement,...) #SyntaxSugar#
				end,
				detach = function(self,...)
					return call(dgsOOP.dgsRes,"dgsDetachElements",self.dgsElement,...) #SyntaxSugar#
				end,
				isAttached = function(self,...)
					return call(dgsOOP.dgsRes,"dgsElementIsAttached",self.dgsElement,...)
				end,
			}
			for k,v in pairs(dgsOOP.HaveParent) do
				nTab[k]=v
			end
			
			local dgsType = call(dgsOOP.dgsRes,"dgsGetType",dgsElement)
			if dgsType == "dgs-dxwindow" then
				nTab.setSizable = function(self,...)
					return call(dgsOOP.dgsRes,"dgsWindowSetSizable",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.setMovable = function(self,...)
					return call(dgsOOP.dgsRes,"dgsWindowSetMovable",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getSizable = function(self,...)
					return call(dgsOOP.dgsRes,"dgsWindowGetSizable",self.dgsElement,...)
				end
				nTab.getMovable = function(self,...)
					return call(dgsOOP.dgsRes,"dgsWindowGetMovable",self.dgsElement,...)
				end
				nTab.close = function(self,...)
					return call(dgsOOP.dgsRes,"dgsCloseWindow",self.dgsElement,...)
				end
				nTab.setCloseButtonEnabled = function(self,...)
					return call(dgsOOP.dgsRes,"dgsWindowSetCloseButtonEnabled",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getCloseButtonEnabled = function(self,...)
					return call(dgsOOP.dgsRes,"dgsWindowGetCloseButtonEnabled",self.dgsElement,...)
				end
				nTab.setCloseButtonSize = function(self,...)
					return call(dgsOOP.dgsRes,"dgsWindowSetCloseButtonSize",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getCloseButtonSize = function(self,...)
					return call(dgsOOP.dgsRes,"dgsWindowGetCloseButtonSize",self.dgsElement,...)
				end
				nTab.getCloseButton = function(self,...)
					return dgsGetClass(call(dgsOOP.dgsRes,"dgsWindowGetCloseButton",self.dgsElement,...))
				end
			elseif dgsType == "dgs-dx3dinterface" then
				nTab.getBlendMode = function(self,...)
					return call(dgsOOP.dgsRes,"dgs3DInterfaceGetBlendMode",self.dgsElement,...)
				end
				nTab.setBlendMode = function(self,...)
					return call(dgsOOP.dgsRes,"dgs3DInterfaceSetBlendMode",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getPosition = function(self,...)
					return call(dgsOOP.dgsRes,"dgs3DInterfaceGetPosition",self.dgsElement,...)
				end
				nTab.setPosition = function(self,...)
					return call(dgsOOP.dgsRes,"dgs3DInterfaceSetPosition",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getSize = function(self,...)
					return call(dgsOOP.dgsRes,"dgs3DInterfaceGetSize",self.dgsElement,...)
				end
				nTab.setSize = function(self,...)
					return call(dgsOOP.dgsRes,"dgs3DInterfaceSetSize",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getResolution = function(self,...)
					return call(dgsOOP.dgsRes,"dgs3DInterfaceGetResolution",self.dgsElement,...)
				end
				nTab.setResolution = function(self,...)
					return call(dgsOOP.dgsRes,"dgs3DInterfaceSetResolution",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.attachToElement = function(self,...)
					return call(dgsOOP.dgsRes,"dgs3DInterfaceAttachToElement",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.isAttached = function(self,...)
					return call(dgsOOP.dgsRes,"dgs3DInterfaceIsAttached",self.dgsElement,...)
				end
				nTab.detachFromElement = function(self,...)
					return call(dgsOOP.dgsRes,"dgs3DInterfaceDetachFromElement",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.setAttachedOffsets = function(self,...)
					return call(dgsOOP.dgsRes,"dgs3DInterfaceSetAttachedOffsets",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getAttachedOffsets = function(self,...)
					return call(dgsOOP.dgsRes,"dgs3DInterfaceGetAttachedOffsets",self.dgsElement,...)
				end
				nTab.setRotation = function(self,...)
					return call(dgsOOP.dgsRes,"dgs3DInterfaceSetRotation",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getRotation = function(self,...)
					return call(dgsOOP.dgsRes,"dgs3DInterfaceGetRotation",self.dgsElement,...)
				end
				nTab.setFaceTo = function(self,...)
					return call(dgsOOP.dgsRes,"dgs3DInterfaceSetFaceTo",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getFaceTo = function(self,...)
					return call(dgsOOP.dgsRes,"dgs3DInterfaceGetFaceTo",self.dgsElement,...)
				end
			elseif dgsType == "dgs-dxcheckbox" then
				nTab.getSelected = function(self,...)
					return call(dgsOOP.dgsRes,"dgsCheckBoxGetSelected",self.dgsElement,...)
				end
				nTab.setSelected = function(self,...)
					return call(dgsOOP.dgsRes,"dgsCheckBoxSetSelected",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getHorizontalAlign = function(self,...)
					return call(dgsOOP.dgsRes,"dgsCheckBoxGetHorizontalAlign",self.dgsElement,...)
				end
				nTab.setHorizontalAlign = function(self,...)
					return call(dgsOOP.dgsRes,"dgsCheckBoxSetHorizontalAlign",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getVerticalAlign = function(self,...)
					return call(dgsOOP.dgsRes,"dgsCheckBoxGetVerticalAlign",self.dgsElement,...)
				end
				nTab.setVerticalAlign = function(self,...)
					return call(dgsOOP.dgsRes,"dgsCheckBoxSetVerticalAlign",self.dgsElement,...) #SyntaxSugar#
				end
			elseif dgsType == "dgs-dxcustomrenderer" then
				nTab.setFunction = function(self,...)
					return call(dgsOOP.dgsRes,"dgsCustomRendererSetFunction",self.dgsElement,...) #SyntaxSugar#
				end
			elseif dgsType == "dgs-dxdetectarea" then
				nTab.setFunction = function(self,...)
					return call(dgsOOP.dgsRes,"dgsDetectAreaSetFunction",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.setDebugModeEnabled = function(self,...)
					return call(dgsOOP.dgsRes,"dgsDetectAreaSetDebugModeEnabled",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getDebugModeEnabled = function(self,...)
					return call(dgsOOP.dgsRes,"dgsDetectAreaGetDebugModeEnabled",self.dgsElement,...)
				end
			elseif dgsType == "dgs-dxradiobutton" then
				nTab.getSelected = function(self,...)
					return call(dgsOOP.dgsRes,"dgsRadioButtonGetSelected",self.dgsElement,...)
				end
				nTab.setSelected = function(self,...)
					return call(dgsOOP.dgsRes,"dgsRadioButtonSetSelected",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getHorizontalAlign = function(self,...)
					return call(dgsOOP.dgsRes,"dgsRadioButtonGetHorizontalAlign",self.dgsElement,...)
				end
				nTab.setHorizontalAlign = function(self,...)
					return call(dgsOOP.dgsRes,"dgsRadioButtonSetHorizontalAlign",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getVerticalAlign = function(self,...)
					return call(dgsOOP.dgsRes,"dgsRadioButtonGetVerticalAlign",self.dgsElement,...)
				end
				nTab.setVerticalAlign = function(self,...)
					return call(dgsOOP.dgsRes,"dgsRadioButtonSetVerticalAlign",self.dgsElement,...) #SyntaxSugar#
				end
			elseif dgsType == "dgs-dxcombobox" then
				nTab.addItem = function(self,...)
					return call(dgsOOP.dgsRes,"dgsComboBoxAddItem",self.dgsElement,...)
				end
				nTab.removeItem = function(self,...)
					return call(dgsOOP.dgsRes,"dgsComboBoxRemoveItem",self.dgsElement,...)
				end
				nTab.setItemText = function(self,...)
					return call(dgsOOP.dgsRes,"dgsComboBoxSetItemText",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getItemText = function(self,...)
					return call(dgsOOP.dgsRes,"dgsComboBoxGetItemText",self.dgsElement,...)
				end
				nTab.clear = function(self,...)
					return call(dgsOOP.dgsRes,"dgsComboBoxClear",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.setSelectedItem = function(self,...)
					return call(dgsOOP.dgsRes,"dgsComboBoxSetSelectedItem",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getSelectedItem = function(self,...)
					return call(dgsOOP.dgsRes,"dgsComboBoxGetSelectedItem",self.dgsElement,...)
				end
				nTab.setItemColor = function(self,...)
					return call(dgsOOP.dgsRes,"dgsComboBoxSetItemColor",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getItemColor = function(self,...)
					return call(dgsOOP.dgsRes,"dgsComboBoxGetItemColor",self.dgsElement,...)
				end
				nTab.getState = function(self,...)
					return call(dgsOOP.dgsRes,"dgsComboBoxGetState",self.dgsElement,...)
				end
				nTab.setState = function(self,...)
					return call(dgsOOP.dgsRes,"dgsComboBoxSetState",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getItemCount = function(self,...)
					return call(dgsOOP.dgsRes,"dgsComboBoxGetItemCount",self.dgsElement,...)
				end
				nTab.getBoxHeight = function(self,...)
					return call(dgsOOP.dgsRes,"dgsComboBoxGetBoxHeight",self.dgsElement,...)
				end
				nTab.setBoxHeight = function(self,...)
					return call(dgsOOP.dgsRes,"dgsComboBoxSetBoxHeight",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getScrollBar = function(self,...)
					return dgsGetClass(call(dgsOOP.dgsRes,"dgsComboBoxGetScrollBar",self.dgsElement,...))
				end
				nTab.setScrollPosition = function(self,...)
					return call(dgsOOP.dgsRes,"dgsComboBoxSetScrollPosition",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getScrollPosition = function(self,...)
					return call(dgsOOP.dgsRes,"dgsComboBoxGetScrollPosition",self.dgsElement,...)
				end
				nTab.setCaptionText = function(self,...)
					return call(dgsOOP.dgsRes,"dgsComboBoxSetCaptionText",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getCaptionText = function(self,...)
					return call(dgsOOP.dgsRes,"dgsComboBoxGetCaptionText",self.dgsElement,...)
				end
				nTab.setEditEnabled = function(self,...)
					return call(dgsOOP.dgsRes,"dgsComboBoxSetEditEnabled",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getEditEnabled = function(self,...)
					return call(dgsOOP.dgsRes,"dgsComboBoxGetEditEnabled",self.dgsElement,...)
				end
				nTab.getText = function(self,...)
					return call(dgsOOP.dgsRes,"dgsComboBoxGetText",self.dgsElement,...)
				end
			elseif dgsType == "dgs-dxedit" then
				nTab.moveCaret = function(self,...)
					return call(dgsOOP.dgsRes,"dgsEditMoveCaret",self.dgsElement,...)
				end
				nTab.getCaretPosition = function(self,...)
					return call(dgsOOP.dgsRes,"dgsEditGetCaretPosition",self.dgsElement,...)
				end
				nTab.setCaretPosition = function(self,...)
					return call(dgsOOP.dgsRes,"dgsEditSetCaretPosition",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.setCaretStyle = function(self,...)
					return call(dgsOOP.dgsRes,"dgsEditSetCaretStyle",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getCaretStyle = function(self,...)
					return call(dgsOOP.dgsRes,"dgsEditGetCaretStyle",self.dgsElement,...)
				end
				nTab.setWhiteList = function(self,...)
					return call(dgsOOP.dgsRes,"dgsEditSetWhiteList",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getMaxLength = function(self,...)
					return call(dgsOOP.dgsRes,"dgsEditGetMaxLength",self.dgsElement,...)
				end
				nTab.setMaxLength = function(self,...)
					return call(dgsOOP.dgsRes,"dgsEditSetMaxLength",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.setReadOnly = function(self,...)
					return call(dgsOOP.dgsRes,"dgsEditSetReadOnly",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getReadOnly = function(self,...)
					return call(dgsOOP.dgsRes,"dgsEditGetReadOnly",self.dgsElement,...)
				end
				nTab.setMasked = function(self,...)
					return call(dgsOOP.dgsRes,"dgsEditSetMasked",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getMasked = function(self,...)
					return call(dgsOOP.dgsRes,"dgsEditGetMasked",self.dgsElement,...)
				end
				nTab.setUnderlined = function(self,...)
					return call(dgsOOP.dgsRes,"dgsEditSetUnderlined",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getUnderlined = function(self,...)
					return call(dgsOOP.dgsRes,"dgsEditGetUnderlined",self.dgsElement,...)
				end
				nTab.setHorizontalAlign = function(self,...)
					return call(dgsOOP.dgsRes,"dgsEditSetHorizontalAlign",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getHorizontalAlign = function(self,...)
					return call(dgsOOP.dgsRes,"dgsEditGetHorizontalAlign",self.dgsElement,...)
				end
				nTab.setVerticalAlign = function(self,...)
					return call(dgsOOP.dgsRes,"dgsEditSetVerticalAlign",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getVerticalAlign = function(self,...)
					return call(dgsOOP.dgsRes,"dgsEditGetVerticalAlign",self.dgsElement,...)
				end
				nTab.setAlignment = function(self,...)
					return call(dgsOOP.dgsRes,"dgsEditSetAlignment ",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getAlignment = function(self,...)
					return call(dgsOOP.dgsRes,"dgsEditGetAlignment ",self.dgsElement,...)
				end
				nTab.insertText = function(self,...)
					return call(dgsOOP.dgsRes,"dgsEditInsertText",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.deleteText = function(self,...)
					return call(dgsOOP.dgsRes,"dgsEditDeleteText",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getPartOfText = function(self,...)
					return call(dgsOOP.dgsRes,"dgsEditGetPartOfText",self.dgsElement,...)
				end
				nTab.clearText = function(self,...)
					return call(dgsOOP.dgsRes,"dgsEditClearText",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.replaceText = function(self,...)
					return call(dgsOOP.dgsRes,"dgsEditReplaceText",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getTypingSound = function(self,...)
					return call(dgsOOP.dgsRes,"dgsEditGetTypingSound",self.dgsElement,...)
				end
				nTab.setTypingSound = function(self,...)
					return call(dgsOOP.dgsRes,"dgsEditSetTypingSound",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getPlaceHolder = function(self,...)
					return call(dgsOOP.dgsRes,"dgsEditGetPlaceHolder",self.dgsElement,...)
				end
				nTab.setPlaceHolder = function(self,...)
					return call(dgsOOP.dgsRes,"dgsEditSetPlaceHolder",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.setAutoComplete = function(self,...)
					return call(dgsOOP.dgsRes,"dgsEditSetAutoComplete",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getAutoComplete = function(self,...)
					return call(dgsOOP.dgsRes,"dgsEditGetAutoComplete",self.dgsElement,...)
				end
				nTab.addAutoComplete = function(self,...)
					return call(dgsOOP.dgsRes,"dgsEditAddAutoComplete",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.removeAutoComplete = function(self,...)
					return call(dgsOOP.dgsRes,"dgsEditRemoveAutoComplete",self.dgsElement,...) #SyntaxSugar#
				end
			elseif dgsType == "dgs-dxeda" then
				nTab.setDebugModeEnabled = function(self,...)
					return call(dgsOOP.dgsRes,"dgsEDASetDebugModeEnabled",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getDebugModeEnabled = function(self,...)
					return call(dgsOOP.dgsRes,"dgsEDAGetDebugModeEnabled",self.dgsElement,...)
				end
			elseif dgsType == "dgs-dxgridlist" then
				nTab.getScrollBar = function(self,...)
					return dgsGetClass(call(dgsOOP.dgsRes,"dgsGridListGetScrollBar",self.dgsElement,...))
				end
				nTab.setScrollPosition = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListSetScrollPosition",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getScrollPosition = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListGetScrollPosition",self.dgsElement,...)
				end
				nTab.setHorizontalScrollPosition = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListSetHorizontalScrollPosition",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getHorizontalScrollPosition = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListGetHorizontalScrollPosition",self.dgsElement,...)
				end
				nTab.setVerticalScrollPosition = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListSetVerticalScrollPosition",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getVerticalScrollPosition = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListGetVerticalScrollPosition",self.dgsElement,...)
				end
				nTab.resetScrollBarPosition = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListResetScrollBarPosition",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.setColumnRelative = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListSetColumnRelative",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getColumnRelative = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListGetColumnRelative",self.dgsElement,...)
				end
				nTab.addColumn = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListAddColumn",self.dgsElement,...)
				end
				nTab.getColumnCount = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListGetColumnCount",self.dgsElement,...)
				end
				nTab.removeColumn = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListRemoveColumn",self.dgsElement,...)
				end
				nTab.getColumnAllWidth = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListGetColumnAllWidth",self.dgsElement,...)
				end
				nTab.getColumnHeight = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListGetColumnHeight",self.dgsElement,...)
				end
				nTab.setColumnHeight = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListSetColumnHeight",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getColumnWidth = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListGetColumnWidth",self.dgsElement,...)
				end
				nTab.setColumnWidth = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListSetColumnWidth",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.autoSizeColumn = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListAutoSizeColumn",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getColumnTitle = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListGetColumnTitle",self.dgsElement,...)
				end
				nTab.setColumnTitle = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListSetColumnTitle",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getColumnFont = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListGetColumnFont",self.dgsElement,...)
				end
				nTab.setColumnFont = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListSetColumnFont",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.addRow = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListAddRow",self.dgsElement,...)
				end
				nTab.insertRowAfter = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListInsertRowAfter",self.dgsElement,...)
				end
				nTab.removeRow = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListRemoveRow",self.dgsElement,...)
				end
				nTab.clearRow = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListClearRow",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.clearColumn = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListClearColumn",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.clear = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListClear",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getRowCount = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListGetRowCount",self.dgsElement,...)
				end
				nTab.setItemText = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListGetRowCount",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getItemText = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListGetItemText",self.dgsElement,...)
				end
				nTab.getSelectedItem = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListGetSelectedItem",self.dgsElement,...)
				end
				nTab.setSelectedItem = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListSetSelectedItem",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.setItemColor = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListSetItemColor",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getItemColor = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListGetItemColor",self.dgsElement,...)
				end
				nTab.setItemData = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListSetItemData",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getItemData = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListGetItemData",self.dgsElement,...)
				end
				nTab.setItemImage = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListSetItemImage",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getItemImage = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListGetItemImage",self.dgsElement,...)
				end
				nTab.removeItemImage = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListRemoveItemImage",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getRowBackGroundImage = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListGetRowBackGroundImage",self.dgsElement,...)
				end
				nTab.setRowBackGroundImage = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListSetRowBackGroundImage",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.setRowBackGroundColor = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListSetRowBackGroundColor",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getRowBackGroundColor = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListGetRowBackGroundColor",self.dgsElement,...)
				end
				nTab.setRowAsSection = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListSetRowAsSection",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.selectItem = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListSelectItem",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.itemIsSelected = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListItemIsSelected",self.dgsElement,...)
				end
				nTab.setMultiSelectionEnabled = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListSetMultiSelectionEnabled",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getMultiSelectionEnabled = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListGetMultiSelectionEnabled",self.dgsElement,...)
				end
				nTab.setSelectionMode = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListSetSelectionMode",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getSelectionMode = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListGetSelectionMode",self.dgsElement,...)
				end
				nTab.getSelectedItems = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListGetSelectedItems",self.dgsElement,...)
				end
				nTab.setSelectedItems = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListSetSelectedItems",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getSelectedCount = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListGetSelectedCount",self.dgsElement,...)
				end
				nTab.setSortFunction = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListSetSortFunction",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.setAutoSortEnabled = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListSetAutoSortEnabled",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getAutoSortEnabled = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListGetAutoSortEnabled",self.dgsElement,...)
				end
				nTab.setSortEnabled = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListSetSortEnabled",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getSortEnabled = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListGetSortEnabled",self.dgsElement,...)
				end
				nTab.setSortColumn = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListSetSortColumn",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getSortColumn = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListGetSortColumn",self.dgsElement,...)
				end
				nTab.getEnterColumn = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListGetEnterColumn",self.dgsElement,...)
				end
				nTab.sort = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListSort",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.setNavigationEnabled = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListSetNavigationEnabled",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getNavigationEnabled = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGridListGetNavigationEnabled",self.dgsElement,...)
				end
			elseif dgsType == "dgs-dximage" then
				nTab.setImage = function(self,...)
					return call(dgsOOP.dgsRes,"dgsImageSetImage",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getImage = function(self,...)
					return call(dgsOOP.dgsRes,"dgsImageGetImage",self.dgsElement,...)
				end
				nTab.setUVSize = function(self,...)
					return call(dgsOOP.dgsRes,"dgsImageSetUVSize",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getUVSize = function(self,...)
					return call(dgsOOP.dgsRes,"dgsImageGetUVSize",self.dgsElement,...)
				end
				nTab.setUVPosition = function(self,...)
					return call(dgsOOP.dgsRes,"dgsImageSetUVPosition",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getUVPosition = function(self,...)
					return call(dgsOOP.dgsRes,"dgsImageGetUVPosition",self.dgsElement,...)
				end
			elseif dgsType == "dgs-dxmemo" then
				nTab.moveCaret = function(self,...)
					return call(dgsOOP.dgsRes,"dgsMemoMoveCaret",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.seekPosition = function(self,...)
					return call(dgsOOP.dgsRes,"dgsMemoSeekPosition",self.dgsElement,...)
				end
				nTab.getScrollBar = function(self,...)
					return dgsGetClass(call(dgsOOP.dgsRes,"dgsMemoGetScrollBar",self.dgsElement,...))
				end
				nTab.setScrollPosition = function(self,...)
					return call(dgsOOP.dgsRes,"dgsMemoSetScrollPosition",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getScrollPosition = function(self,...)
					return call(dgsOOP.dgsRes,"dgsMemoGetScrollPosition",self.dgsElement,...)
				end
				nTab.setHorizontalScrollPosition = function(self,...)
					return call(dgsOOP.dgsRes,"dgsMemoSetHorizontalScrollPosition",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getHorizontalScrollPosition = function(self,...)
					return call(dgsOOP.dgsRes,"dgsMemoGetHorizontalScrollPosition",self.dgsElement,...)
				end
				nTab.setVerticalScrollPosition = function(self,...)
					return call(dgsOOP.dgsRes,"dgsMemoSetVerticalScrollPosition",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getVerticalScrollPosition = function(self,...)
					return call(dgsOOP.dgsRes,"dgsMemoGetVerticalScrollPosition",self.dgsElement,...)
				end
				nTab.setCaretPosition = function(self,...)
					return call(dgsOOP.dgsRes,"dgsMemoSetCaretPosition",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getCaretPosition = function(self,...)
					return call(dgsOOP.dgsRes,"dgsMemoGetCaretPosition",self.dgsElement,...)
				end
				nTab.setCaretStyle = function(self,...)
					return call(dgsOOP.dgsRes,"dgsMemoSetCaretStyle",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getCaretStyle = function(self,...)
					return call(dgsOOP.dgsRes,"dgsMemoGetCaretStyle",self.dgsElement,...)
				end
				nTab.setReadOnly = function(self,...)
					return call(dgsOOP.dgsRes,"dgsMemoSetReadOnly",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getReadOnly = function(self,...)
					return call(dgsOOP.dgsRes,"dgsMemoGetReadOnly",self.dgsElement,...)
				end
				nTab.getPartOfText = function(self,...)
					return call(dgsOOP.dgsRes,"dgsMemoGetPartOfText",self.dgsElement,...)
				end
				nTab.deleteText = function(self,...)
					return call(dgsOOP.dgsRes,"dgsMemoDeleteText",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.insertText = function(self,...)
					return call(dgsOOP.dgsRes,"dgsMemoInsertText",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.appendText = function(self,...)
					return call(dgsOOP.dgsRes,"dgsMemoAppendText",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.clearText = function(self,...)
					return call(dgsOOP.dgsRes,"dgsMemoClearText",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getTypingSound = function(self,...)
					return call(dgsOOP.dgsRes,"dgsMemoGetTypingSound",self.dgsElement,...)
				end
				nTab.setTypingSound = function(self,...)
					return call(dgsOOP.dgsRes,"dgsMemoSetTypingSound",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getLineCount = function(self,...)
					return call(dgsOOP.dgsRes,"dgsMemoGetLineCount",self.dgsElement,...)
				end
				nTab.setWordWrapState = function(self,...)
					return call(dgsOOP.dgsRes,"dgsMemoSetWordWrapState",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getWordWrapState = function(self,...)
					return call(dgsOOP.dgsRes,"dgsMemoGetWordWrapState",self.dgsElement,...)
				end
				nTab.setScrollBarState = function(self,...)
					return call(dgsOOP.dgsRes,"dgsMemoSetScrollBarState",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getScrollBarState = function(self,...)
					return call(dgsOOP.dgsRes,"dgsMemoGetScrollBarState",self.dgsElement,...)
				end
			elseif dgsType == "dgs-dxlabel" then
				nTab.setColor = function(self,...)
					return call(dgsOOP.dgsRes,"dgsLabelSetColor",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getColor = function(self,...)
					return call(dgsOOP.dgsRes,"dgsLabelGetColor",self.dgsElement,...)
				end
				nTab.setHorizontalAlign = function(self,...)
					return call(dgsOOP.dgsRes,"dgsLabelSetHorizontalAlign",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getHorizontalAlign = function(self,...)
					return call(dgsOOP.dgsRes,"dgsLabelGetHorizontalAlign",self.dgsElement,...)
				end
				nTab.setVerticalAlign = function(self,...)
					return call(dgsOOP.dgsRes,"dgsLabelSetVerticalAlign",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getVerticalAlign = function(self,...)
					return call(dgsOOP.dgsRes,"dgsLabelGetVerticalAlign",self.dgsElement,...)
				end
				nTab.getTextExtent = function(self,...)
					return call(dgsOOP.dgsRes,"dgsLabelGetTextExtent",self.dgsElement,...)
				end
				nTab.getFontHeight = function(self,...)
					return call(dgsOOP.dgsRes,"dgsLabelGetFontHeight",self.dgsElement,...)
				end
			elseif dgsType == "dgs-dxprogressbar" then
				nTab.getProgress = function(self,...)
					return call(dgsOOP.dgsRes,"dgsProgressBarGetProgress",self.dgsElement,...)
				end
				nTab.setProgress = function(self,...)
					return call(dgsOOP.dgsRes,"dgsProgressBarSetProgress",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getMode = function(self,...)
					return call(dgsOOP.dgsRes,"dgsProgressBarGetMode",self.dgsElement,...)
				end
				nTab.setMode = function(self,...)
					return call(dgsOOP.dgsRes,"dgsProgressBarSetMode",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getVerticalSide = function(self,...)
					return call(dgsOOP.dgsRes,"dgsProgressBarGetVerticalSide",self.dgsElement,...)
				end
				nTab.setVerticalSide = function(self,...)
					return call(dgsOOP.dgsRes,"dgsProgressBarSetVerticalSide",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getHorizontalSide = function(self,...)
					return call(dgsOOP.dgsRes,"dgsProgressBarGetHorizontalSide",self.dgsElement,...)
				end
				nTab.setHorizontalSide = function(self,...)
					return call(dgsOOP.dgsRes,"dgsProgressBarSetHorizontalSide",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getStyle = function(self,...)
					return call(dgsOOP.dgsRes,"dgsProgressBarGetStyle",self.dgsElement,...)
				end
				nTab.setStyle = function(self,...)
					return call(dgsOOP.dgsRes,"dgsProgressBarSetStyle",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getStyleProperties = function(self,...)
					return call(dgsOOP.dgsRes,"dgsProgressBarGetStyleProperties",self.dgsElement,...)
				end
				nTab.setStyleProperty = function(self,...)
					return call(dgsOOP.dgsRes,"dgsProgressBarSetStyleProperty",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getStyleProperty = function(self,...)
					return call(dgsOOP.dgsRes,"dgsProgressBarGetStyleProperty",self.dgsElement,...)
				end
			elseif dgsType == "dgs-dxscrollbar" then
				nTab.setScrollPosition = function(self,...)
					return call(dgsOOP.dgsRes,"dgsScrollBarSetScrollPosition",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getScrollPosition = function(self,...)
					return call(dgsOOP.dgsRes,"dgsScrollBarGetScrollPosition",self.dgsElement,...)
				end
				nTab.setCursorLength = function(self,...)
					return call(dgsOOP.dgsRes,"dgsScrollBarSetCursorLength",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getCursorLength = function(self,...)
					return call(dgsOOP.dgsRes,"dgsScrollBarGetCursorLength",self.dgsElement,...)
				end
				nTab.setLocked = function(self,...)
					return call(dgsOOP.dgsRes,"dgsScrollBarSetLocked",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getLocked = function(self,...)
					return call(dgsOOP.dgsRes,"dgsScrollBarGetLocked",self.dgsElement,...)
				end
				nTab.setGrades = function(self,...)
					return call(dgsOOP.dgsRes,"dgsScrollBarSetGrades",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getGrades = function(self,...)
					return call(dgsOOP.dgsRes,"dgsScrollBarGetGrades",self.dgsElement,...)
				end
			elseif dgsType == "dgs-dxscrollpane" then
				nTab.getScrollBar = function(self,...)
					return dgsGetClass(call(dgsOOP.dgsRes,"dgsScrollPaneGetScrollBar",self.dgsElement,...))
				end
				nTab.setScrollPosition = function(self,...)
					return call(dgsOOP.dgsRes,"dgsScrollPaneSetScrollPosition",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getScrollPosition = function(self,...)
					return call(dgsOOP.dgsRes,"dgsScrollPaneGetScrollPosition",self.dgsElement,...)
				end
				nTab.setHorizontalScrollPosition = function(self,...)
					return call(dgsOOP.dgsRes,"dgsScrollPaneSetHorizontalScrollPosition",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getHorizontalScrollPosition = function(self,...)
					return call(dgsOOP.dgsRes,"dgsScrollPaneGetHorizontalScrollPosition",self.dgsElement,...)
				end
				nTab.setVerticalScrollPosition = function(self,...)
					return call(dgsOOP.dgsRes,"dgsScrollPaneSetVerticalScrollPosition",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getVerticalScrollPosition = function(self,...)
					return call(dgsOOP.dgsRes,"dgsScrollPaneGetVerticalScrollPosition",self.dgsElement,...)
				end
				nTab.setScrollBarState = function(self,...)
					return call(dgsOOP.dgsRes,"dgsScrollPaneSetScrollBarState",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getScrollBarState = function(self,...)
					return call(dgsOOP.dgsRes,"dgsScrollPaneGetScrollBarState",self.dgsElement,...)
				end
			elseif dgsType == "dgs-dxswitchbutton" then
				nTab.getState = function(self,...)
					return call(dgsOOP.dgsRes,"dgsSwitchButtonGetState",self.dgsElement,...)
				end
				nTab.setState = function(self,...)
					return call(dgsOOP.dgsRes,"dgsSwitchButtonSetState",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.setText = function(self,...)
					return call(dgsOOP.dgsRes,"dgsSwitchButtonSetText",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getText = function(self,...)
					return call(dgsOOP.dgsRes,"dgsSwitchButtonGetText",self.dgsElement,...)
				end
			elseif dgsType == "dgs-dxtabpanel" then
				nTab.getSelectedTab = function(self,...)
					return call(dgsOOP.dgsRes,"dgsGetSelectedTab",self.dgsElement,...)
				end
				nTab.setSelectedTab = function(self,...)
					return call(dgsOOP.dgsRes,"dgsSetSelectedTab",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getTabFromID = function(self,...)
					return call(dgsOOP.dgsRes,"dgsTabPanelGetTabFromID",self.dgsElement,...)
				end
				nTab.moveTab = function(self,...)
					return call(dgsOOP.dgsRes,"dgsTabPanelMoveTab",self.dgsElement,...) #SyntaxSugar#
				end
				nTab.getTabID = function(self,...)
					return call(dgsOOP.dgsRes,"dgsTabPanelGetTabID",self.dgsElement,...)
				end
				nTab.dgsTab = function(self,text,...)
					local dxgui = call(dgsOOP.dgsRes,"dgsCreateTab",text,self.dgsElement,...)
					return dgsGetClass(dxgui)
				end
			elseif dgsType == "dgs-dxtab" then
				nTab.delete = function(self,...)
					return call(dgsOOP.dgsRes,"dgsDeleteTab",self.dgsElement,...)
				end
			end
			setmetatable(nTab,dgsOOP.AccessTable)
			
			dgsOOP.dgsClass[dgsElement] = nTab
			return nTab
		end

		DGSClass = {
			getClass = function(self,dgsElement)
				return dgsGetClass(dgsElement)
			end,
			isStyleAvailable = function(self,...)
				return call(dgsOOP.dgsRes,"dgsIsStyleAvailable",...)
			end,
			getLoadedStyleList = function(self,...)
				return call(dgsOOP.dgsRes,"dgsGetLoadedStyleList",...)
			end,
			setCurrentStyle = function(self,...)
				return call(dgsOOP.dgsRes,"dgsSetCurrentStyle",...) #SyntaxSugar#
			end,
			getCurrentStyle = function(self,...)
				return call(dgsOOP.dgsRes,"dgsGetCurrentStyle",...)
			end,
			getScreenSize = function(self)
				return guiGetScreenSize()
			end,
			setInputEnabled = function(self,...)
				return guiSetInputEnabled(...) #SyntaxSugar#
			end,
			getInputEnabled = function(self,...)
				return guiGetInputEnabled(...)
			end,
			setInputMode = function(self,...)
				return guiSetInputMode(...) #SyntaxSugar#
			end,
			getInputMode = function(self,...)
				return guiGetInputMode(...)
			end,
			setRenderSetting = function(self,...)
				return call(dgsOOP.dgsRes,"dgsSetRenderSetting",...) #SyntaxSugar#
			end,
			getRenderSetting = function(self,...)
				return call(dgsOOP.dgsRes,"dgsGetRenderSetting",...)
			end,
			getLayerElements = function(self,...)
				local elements = call(dgsOOP.dgsRes,"dgsGetLayerElements",...)
				local newElements = {}
				for i=1,#elements do
					newElements[i] = dgsGetClass(elements[i])
				end
				return newElements
			end,
			addEasingFunction = function(self,...)
				return call(dgsOOP.dgsRes,"dgsAddEasingFunction",...) #SyntaxSugar#
			end,
			easingFunctionExists = function(self,...)
				return call(dgsOOP.dgsRes,"dgsEasingFunctionExists",...)
			end,
			removeEasingFunction = function(self,...)
				return call(dgsOOP.dgsRes,"dgsRemoveEasingFunction",...) #SyntaxSugar#
			end,
			getSystemFont = function(self,...)
				return call(dgsOOP.dgsRes,"dgsGetSystemFont",...)
			end,
			setSystemFont = function(self,...)
				return call(dgsOOP.dgsRes,"dgsSetSystemFont",...) #SyntaxSugar#
			end,
			translationTableExists = function(self,...)
				return call(dgsOOP.dgsRes,"dgsTranslationTableExists",...)
			end,
			setTranslationTable = function(self,...)
				return call(dgsOOP.dgsRes,"dgsSetTranslationTable",...) #SyntaxSugar#
			end,
			setAttachTranslation = function(self,...)
				return call(dgsOOP.dgsRes,"dgsSetAttachTranslation",...) #SyntaxSugar#
			end,
			setDoubleClickInterval = function(self,...)
				return call(dgsOOP.dgsRes,"dgsSetDoubleClickInterval",...) #SyntaxSugar#
			end,
			getDoubleClickInterval = function(self,...)
				return call(dgsOOP.dgsRes,"dgsGetDoubleClickInterval",...)
			end,
			RGBToHSV = function(self,...)
				return call(dgsOOP.dgsRes,"dgsRGBToHSV",...)
			end,
			RGBToHSL = function(self,...)
				return call(dgsOOP.dgsRes,"dgsRGBToHSL",...)
			end,
			HSLToRGB = function(self,...)
				return call(dgsOOP.dgsRes,"dgsHSLToRGB",...)
			end,
			HSVToRGB = function(self,...)
				return call(dgsOOP.dgsRes,"dgsHSVToRGB",...)
			end,
			HSVToHSL = function(self,...)
				return call(dgsOOP.dgsRes,"dgsHSVToHSL",...)
			end,
			HSLToHSV = function(self,...)
				return call(dgsOOP.dgsRes,"dgsHSLToHSV",...)
			end,
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
	end
	]]
	return utf8.gsub(str,"#SyntaxSugar#",syntaxSugar)
end

