dgsResName = getResourceName(getThisResource())
function dgsImportOOPClass()
	return [[
	--Check Error Message Above
	if not dgsOOPHead then
		local getResourceRootElement = getResourceRootElement
		local call = call
		local getResourceFromName = getResourceFromName
		dgsOOPHead = {}
		dgsOOPHead.dgsName = "]]..dgsResName..[["
		dgsOOPHead.dgsRes = getResourceFromName(dgsOOPHead.dgsName)
		dgsRoot = getResourceRootElement(dgsOOPHead.dgsRes)
		dgsOOPHead.dgsRoot = dgsRoot
		dgsOOPHead.dgsClass = {}
		
		dgsOOPHead.AccessTable = {
			__index=function(self,key)
				return call(dgsOOPHead.dgsRes,"dgsGetProperty",self.dgsElement,key)
			end,
			__newindex=function(self,key,value)
				return call(dgsOOPHead.dgsRes,"dgsSetProperty",self.dgsElement,key,value)
			end,
			__metatable=true
		}

		dgsOOPHead.NoParent = {
			createWindow = function(self,...)
				local dxgui = call(dgsOOPHead.dgsRes,"dgsCreateWindow",...)
				local dxguiTable = createTableForElement(dxgui)
				return dxguiTable
			end,
			create3DInterface = function(self,...)
				local dxgui = call(dgsOOPHead.dgsRes,"dgsCreate3DInterface",...)
				local dxguiTable = createTableForElement(dxgui)
				return dxguiTable
			end,
		}

		dgsOOPHead.HaveParent = {
			createButton = function(self,x,y,w,h,text,relative,...)
				local dxgui = call(dgsOOPHead.dgsRes,"dgsCreateButton",x,y,w,h,text,relative,self.dgsElement,...)
				local dxguiTable = createTableForElement(dxgui)
				return dxguiTable
			end,
			createBrowser = function(self,x,y,w,h,relative,...)
				local dxgui = call(dgsOOPHead.dgsRes,"dgsCreateBrowser",x,y,w,h,relative,self.dgsElement,...)
				local dxguiTable = createTableForElement(dxgui)
				return dxguiTable
			end,
			createCheckBox = function(self,x,y,w,h,text,state,relative,...)
				local dxgui = call(dgsOOPHead.dgsRes,"dgsCreateCheckBox",x,y,w,h,text,state,relative,self.dgsElement,...)
				local dxguiTable = createTableForElement(dxgui)
				return dxguiTable
			end,
			createRadioButton = function(self,x,y,w,h,text,state,relative,...)
				local dxgui = call(dgsOOPHead.dgsRes,"dgsCreateRadioButton",x,y,w,h,text,state,relative,self.dgsElement,...)
				local dxguiTable = createTableForElement(dxgui)
				return dxguiTable
			end,
			createComboBox = function(self,x,y,w,h,caption,relative,...)
				local dxgui = call(dgsOOPHead.dgsRes,"dgsCreateComboBox",x,y,w,h,caption,relative,self.dgsElement,...)
				local dxguiTable = createTableForElement(dxgui)
				return dxguiTable
			end,
			createEdit = function(self,x,y,w,h,text,relative,...)
				local dxgui = call(dgsOOPHead.dgsRes,"dgsCreateEdit",x,y,w,h,text,relative,self.dgsElement,...)
				local dxguiTable = createTableForElement(dxgui)
				return dxguiTable
			end,
			createDetectArea = function(self,x,y,w,h,relative,...)
				local dxgui = call(dgsOOPHead.dgsRes,"dgsCreateDetectArea",x,y,w,h,relative,self.dgsElement,...)
				local dxguiTable = createTableForElement(dxgui)
				return dxguiTable
			end,
			createGridList = function(self,x,y,w,h,relative,...)
				local dxgui = call(dgsOOPHead.dgsRes,"dgsCreateGridList",x,y,w,h,relative,self.dgsElement,...)
				local dxguiTable = createTableForElement(dxgui)
				return dxguiTable
			end,
			createImage = function(self,x,y,w,h,image,relative,...)
				local dxgui = call(dgsOOPHead.dgsRes,"dgsCreateImage",x,y,w,h,image,relative,self.dgsElement,...)
				local dxguiTable = createTableForElement(dxgui)
				return dxguiTable
			end,
			createMemo = function(self,x,y,w,h,text,relative,...)
				local dxgui = call(dgsOOPHead.dgsRes,"dgsCreateMemo",x,y,w,h,text,relative,self.dgsElement,...)
				local dxguiTable = createTableForElement(dxgui)
				return dxguiTable
			end,
			createLabel = function(self,x,y,w,h,text,relative,...)
				local dxgui = call(dgsOOPHead.dgsRes,"dgsCreateLabel",x,y,w,h,text,relative,self.dgsElement,...)
				local dxguiTable = createTableForElement(dxgui)
				return dxguiTable
			end,
			createProgressBar = function(self,x,y,w,h,relative,...)
				local dxgui = call(dgsOOPHead.dgsRes,"dgsCreateProgressBar",x,y,w,h,relative,self.dgsElement,...)
				local dxguiTable = createTableForElement(dxgui)
				return dxguiTable
			end,
			createScrollBar = function(self,x,y,w,h,voh,relative,...)
				local dxgui = call(dgsOOPHead.dgsRes,"dgsCreateScrollBar",x,y,w,h,voh,relative,self.dgsElement,...)
				local dxguiTable = createTableForElement(dxgui)
				return dxguiTable
			end,
			createScrollPane = function(self,x,y,w,h,relative,...)
				local dxgui = call(dgsOOPHead.dgsRes,"dgsCreateScrollPane",x,y,w,h,relative,self.dgsElement,...)
				local dxguiTable = createTableForElement(dxgui)
				return dxguiTable
			end,
			createTabPanel = function(self,x,y,w,h,relative,...)
				local dxgui = call(dgsOOPHead.dgsRes,"dgsCreateTabPanel",x,y,w,h,relative,self.dgsElement,...)
				local dxguiTable = createTableForElement(dxgui)
				return dxguiTable
			end,
			createArrowList = function(self,x,y,w,h,relative,...)
				local dxgui = call(dgsOOPHead.dgsRes,"dgsCreateArrowList",x,y,w,h,relative,self.dgsElement,...)
				local dxguiTable = createTableForElement(dxgui)
				return dxguiTable
			end,
		}

		function createTableForElement(dgsElement)
			local originalClass = dgsOOPHead.dgsClass[dgsElement]
			if originalClass then
				if originalClass.dgsElement == dgsElement then
					return originalClass
				end
			end
			local newTable = {
				dgsElement = dgsElement,
				getPosition = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGetPosition",self.dgsElement,...)
				end,
				setPosition = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsSetPosition",self.dgsElement,...)
				end,
				getParent = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGetParent",self.dgsElement,...)
				end,
				setParent = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsSetParent",self.dgsElement,...)
				end,
				getChild = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGetChild",self.dgsElement,...)
				end,
				getChildren = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGetChildren",self.dgsElement,...)
				end,
				getSize = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGetSize",self.dgsElement,...)
				end,
				setSize = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsSetSize",self.dgsElement,...)
				end,
				getType = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGetType",self.dgsElement,...)
				end,
				setLayer = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsSetLayer",self.dgsElement,...)
				end,
				getLayer = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsSetLayer",self.dgsElement,...)
				end,
				setCurrentLayerIndex = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsSetCurrentLayerIndex",self.dgsElement,...)
				end,
				getCurrentLayerIndex = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGetCurrentLayerIndex",self.dgsElement,...)
				end,
				getProperty = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGetProperty",self.dgsElement,...)
				end,
				setProperty = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsSetProperty",self.dgsElement,...)
				end,
				getProperties = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGetProperties",self.dgsElement,...)
				end,
				setProperties = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsSetProperties",self.dgsElement,...)
				end,
				getVisible = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGetVisible",self.dgsElement,...)
				end,
				setVisible = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGetVisible",self.dgsElement,...)
				end,
				getEnabled = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGetEnabled",self.dgsElement,...)
				end,
				setEnabled = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsSetEnabled",self.dgsElement,...)
				end,
				getSide = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGetSide",self.dgsElement,...)
				end,
				setSide = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsSetSide",self.dgsElement,...)
				end,
				getAlpha = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGetAlpha",self.dgsElement,...)
				end,
				setAlpha = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsSetAlpha",self.dgsElement,...)
				end,
				getFont = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGetFont",self.dgsElement,...)
				end,
				setFont = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsSetFont",self.dgsElement,...)
				end,
				getText = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGetText",self.dgsElement,...)
				end,
				setText = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsSetText",self.dgsElement,...)
				end,
				bringToFront = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsBringToFront",self.dgsElement,...)
				end,
				simulateClick = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsSimulateClick",self.dgsElement,...)
				end,
				animTo = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsAnimTo",self.dgsElement,...)
				end,
				isAniming = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsIsAniming",self.dgsElement,...)
				end,
				stopAniming = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsStopAniming",self.dgsElement,...)
				end,
				moveTo = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsMoveTo",self.dgsElement,...)
				end,
				isMoving = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsIsMoving",self.dgsElement,...)
				end,
				stopMoving = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsStopMoving",self.dgsElement,...)
				end,
				sizeTo = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsSizeTo",self.dgsElement,...)
				end,
				isSizing = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsIsSizing",self.dgsElement,...)
				end,
				stopSizing = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsStopSizing",self.dgsElement,...)
				end,
				alphaTo = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsAlphaTo",self.dgsElement,...)
				end,
				isAlphaing = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsIsAlphaing",self.dgsElement,...)
				end,
				stopAlphaing = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsStopAlphaing",self.dgsElement,...)
				end,
				destroy = function(self,...)
					return destroyElement(self.dgsElement)
				end,
				addEventHandler = function(self,eventName,fnc,...)
					return addEventHandler(eventName,self.dgsElement,fnc,...)
				end,
				removeEventHandler = function(self,eventName,fnc,...)
					return removeEventHandler(eventName,self.dgsElement,fnc,...)
				end,
				isElement = function(self)
					return isElement(self.dgsElement)
				end,
				getElement = function(self)
					return self.dgsElement
				end,
			}
			for k,v in pairs(dgsOOPHead.HaveParent) do
				newTable[k]=v
			end
			
			local dgsType = call(dgsOOPHead.dgsRes,"dgsGetType",dgsElement)
			if dgsType == "dgs-dxwindow" then
				newTable.setSizable = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsWindowSetSizable",self.dgsElement,...)
				end
				newTable.setMovable = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsWindowSetMovable",self.dgsElement,...)
				end
				newTable.close = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsCloseWindow",self.dgsElement,...)
				end
				newTable.setCloseButtonEnabled = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsWindowSetCloseButtonEnabled",self.dgsElement,...)
				end
				newTable.getCloseButtonEnabled = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsWindowGetCloseButtonEnabled",self.dgsElement,...)
				end
				newTable.getCloseButton = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsWindowGetCloseButton",self.dgsElement,...)
				end
			elseif dgsType == "dgs-dxarrowlist" then
				newTable.addItem = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsArrowListAddItem",self.dgsElement,...)
				end
				newTable.removeItem = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsArrowListRemoveItem",self.dgsElement,...)
				end
				newTable.setItemText = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsArrowListSetItemText",self.dgsElement,...)
				end
				newTable.getItemText = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsArrowListGetItemText",self.dgsElement,...)
				end
				newTable.setItemValue = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsArrowListSetItemValue",self.dgsElement,...)
				end
				newTable.getItemValue = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsArrowListGetItemValue",self.dgsElement,...)
				end
				newTable.setItemRange = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsArrowListSetItemRange",self.dgsElement,...)
				end
				newTable.getItemRange = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsArrowListGetItemRange",self.dgsElement,...)
				end
				newTable.setItemTranslationTable = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsArrowListSetItemTranslationTable",self.dgsElement,...)
				end
				newTable.getItemTranslationTable = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsArrowListGetItemTranslationTable",self.dgsElement,...)
				end
				newTable.setItemStep = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsArrowListSetItemStep",self.dgsElement,...)
				end
				newTable.getItemStep = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsArrowListGetItemStep",self.dgsElement,...)
				end
				newTable.getItemTranslatedValue = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsArrowListGetItemTranslatedValue",self.dgsElement,...)
				end
				newTable.clear = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsArrowListClear",self.dgsElement,...)
				end
			elseif dgsType == "dgs-dxcheckbox" then
				newTable.getSelected = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsCheckBoxGetSelected",self.dgsElement,...)
				end
				newTable.setSelected = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsCheckBoxSetSelected",self.dgsElement,...)
				end
			elseif dgsType == "dgs-dxradiobutton" then
				newTable.getSelected = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsRadioButtonGetSelected",self.dgsElement,...)
				end
				newTable.setSelected = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsRadioButtonSetSelected",self.dgsElement,...)
				end
			elseif dgsType == "dgs-dxcombobox" then
				newTable.addItem = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsComboBoxAddItem",self.dgsElement,...)
				end
				newTable.removeItem = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsComboBoxRemoveItem",self.dgsElement,...)
				end
				newTable.setItemText = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsComboBoxSetItemText",self.dgsElement,...)
				end
				newTable.getItemText = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsComboBoxGetItemText",self.dgsElement,...)
				end
				newTable.clear = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsComboBoxClear",self.dgsElement,...)
				end
				newTable.setSelectedItem = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsComboBoxSetSelectedItem",self.dgsElement,...)
				end
				newTable.getSelectedItem = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsComboBoxGetSelectedItem",self.dgsElement,...)
				end
				newTable.setItemColor = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsComboBoxSetItemColor",self.dgsElement,...)
				end
				newTable.getItemColor = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsComboBoxGetItemColor",self.dgsElement,...)
				end
				newTable.getState = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsComboBoxGetState",self.dgsElement,...)
				end
				newTable.setState = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsComboBoxSetState",self.dgsElement,...)
				end
				newTable.getBoxHeight = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsComboBoxGetBoxHeight",self.dgsElement,...)
				end
				newTable.setBoxHeight = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsComboBoxSetBoxHeight",self.dgsElement,...)
				end
				newTable.getScrollBar = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsComboBoxGetScrollBar",self.dgsElement,...)
				end
				newTable.setScrollPosition = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsComboBoxSetScrollPosition",self.dgsElement,...)
				end
				newTable.getScrollPosition = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsComboBoxGetScrollPosition",self.dgsElement,...)
				end
				newTable.setCaptionText = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsComboBoxSetCaptionText",self.dgsElement,...)
				end
				newTable.getCaptionText = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsComboBoxGetCaptionText",self.dgsElement,...)
				end
			elseif dgsType == "dgs-dxedit" then
				newTable.moveCaret = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsEditMoveCaret",self.dgsElement,...)
				end
				newTable.getCaretPosition = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsEditGetCaretPosition",self.dgsElement,...)
				end
				newTable.setCaretPosition = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsEditSetCaretPosition",self.dgsElement,...)
				end
				newTable.setCaretStyle = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsEditSetCaretStyle",self.dgsElement,...)
				end
				newTable.getCaretStyle = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsEditGetCaretStyle",self.dgsElement,...)
				end
				newTable.setWhiteList = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsEditSetWhiteList",self.dgsElement,...)
				end
				newTable.getMaxLength = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsEditGetMaxLength",self.dgsElement,...)
				end
				newTable.setMaxLength = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsEditSetMaxLength",self.dgsElement,...)
				end
				newTable.setReadOnly = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsEditSetReadOnly",self.dgsElement,...)
				end
				newTable.getReadOnly = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsEditGetReadOnly",self.dgsElement,...)
				end
				newTable.setMasked = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsEditSetMasked",self.dgsElement,...)
				end
				newTable.getMasked = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsEditGetMasked",self.dgsElement,...)
				end
			elseif dgsType == "dgs-dxeda" then
				newTable.setDebugModeEnabled = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsEDASetDebugModeEnabled",self.dgsElement,...)
				end
				newTable.getDebugModeEnabled = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsEDAGetDebugModeEnabled",self.dgsElement,...)
				end
			elseif dgsType == "dgs-dxdetectarea" then
				newTable.setFunction = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsDetectAreaSetFunction",self.dgsElement,...)
				end
			elseif dgsType == "dgs-dxgridlist" then
				newTable.getScrollBar = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListGetScrollBar",self.dgsElement,...)
				end
				newTable.setScrollPosition = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListSetScrollPosition",self.dgsElement,...)
				end
				newTable.getScrollPosition = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListGetScrollPosition",self.dgsElement,...)
				end
				newTable.resetScrollBarPosition = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListResetScrollBarPosition",self.dgsElement,...)
				end
				newTable.setColumnRelative = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListSetColumnRelative",self.dgsElement,...)
				end
				newTable.getColumnRelative = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListGetColumnRelative",self.dgsElement,...)
				end
				newTable.addColumn = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListAddColumn",self.dgsElement,...)
				end
				newTable.getColumnCount = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListGetColumnCount",self.dgsElement,...)
				end
				newTable.removeColumn = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListRemoveColumn",self.dgsElement,...)
				end
				newTable.getColumnAllWidth = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListGetColumnAllWidth",self.dgsElement,...)
				end
				newTable.getColumnWidth = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListGetColumnWidth",self.dgsElement,...)
				end
				newTable.setColumnWidth = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListSetColumnWidth",self.dgsElement,...)
				end
				newTable.getColumnTitle = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListGetColumnTitle",self.dgsElement,...)
				end
				newTable.setColumnTitle = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListSetColumnTitle",self.dgsElement,...)
				end
				newTable.addRow = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListAddRow",self.dgsElement,...)
				end
				newTable.removeRow = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListRemoveRow",self.dgsElement,...)
				end
				newTable.clearRow = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListClearRow",self.dgsElement,...)
				end
				newTable.clearColumn = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListClearColumn",self.dgsElement,...)
				end
				newTable.clear = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListClear",self.dgsElement,...)
				end
				newTable.getRowCount = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListGetRowCount",self.dgsElement,...)
				end
				newTable.setItemText = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListGetRowCount",self.dgsElement,...)
				end
				newTable.getItemText = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListGetItemText",self.dgsElement,...)
				end
				newTable.getSelectedItem = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListGetSelectedItem",self.dgsElement,...)
				end
				newTable.setSelectedItem = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListSetSelectedItem",self.dgsElement,...)
				end
				newTable.setItemColor = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListSetItemColor",self.dgsElement,...)
				end
				newTable.getItemColor = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListGetItemColor",self.dgsElement,...)
				end
				newTable.setItemData = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListSetItemData",self.dgsElement,...)
				end
				newTable.getItemData = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListGetItemData",self.dgsElement,...)
				end
				newTable.setItemImage = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListSetItemImage",self.dgsElement,...)
				end
				newTable.getItemImage = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListGetItemImage",self.dgsElement,...)
				end
				newTable.removeItemImage = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListRemoveItemImage",self.dgsElement,...)
				end
				newTable.getRowBackGroundImage = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListGetRowBackGroundImage",self.dgsElement,...)
				end
				newTable.setRowBackGroundImage = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListSetRowBackGroundImage",self.dgsElement,...)
				end
				newTable.setRowBackGroundColor = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListSetRowBackGroundColor",self.dgsElement,...)
				end
				newTable.getRowBackGroundColor = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListGetRowBackGroundColor",self.dgsElement,...)
				end
				newTable.setRowAsSection = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListSetRowAsSection",self.dgsElement,...)
				end
				newTable.selectItem = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListSelectItem",self.dgsElement,...)
				end
				newTable.itemIsSelected = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListItemIsSelected",self.dgsElement,...)
				end
				newTable.setMultiSelectionEnabled = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListSetMultiSelectionEnabled",self.dgsElement,...)
				end
				newTable.getMultiSelectionEnabled = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListGetMultiSelectionEnabled",self.dgsElement,...)
				end
				newTable.setSelectionMode = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListSetSelectionMode",self.dgsElement,...)
				end
				newTable.getSelectionMode = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListGetSelectionMode",self.dgsElement,...)
				end
				newTable.getSelectedItems = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListGetSelectedItems",self.dgsElement,...)
				end
				newTable.setSelectedItems = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListSetSelectedItems",self.dgsElement,...)
				end
				newTable.setSortFunction = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListSetSortFunction",self.dgsElement,...)
				end
				newTable.setAutoSortEnabled = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListSetAutoSortEnabled",self.dgsElement,...)
				end
				newTable.getAutoSortEnabled = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListGetAutoSortEnabled",self.dgsElement,...)
				end
				newTable.setSortEnabled = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListSetSortEnabled",self.dgsElement,...)
				end
				newTable.getSortEnabled = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListGetSortEnabled",self.dgsElement,...)
				end
				newTable.setSortColumn = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListSetSortColumn",self.dgsElement,...)
				end
				newTable.getSortColumn = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListGetSortColumn",self.dgsElement,...)
				end
				newTable.getEnterColumn = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListGetEnterColumn",self.dgsElement,...)
				end
				newTable.sort = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGridListSort",self.dgsElement,...)
				end
			elseif dgsType == "dgs-dximage" then
				newTable.setImage = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsImageSetImage",self.dgsElement,...)
				end
				newTable.getImage = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsImageGetImage",self.dgsElement,...)
				end
				newTable.setImageSize = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsImageSetImageSize",self.dgsElement,...)
				end
				newTable.getImageSize = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsImageGetImageSize",self.dgsElement,...)
				end
				newTable.setImagePosition = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsImageSetImagePosition",self.dgsElement,...)
				end
				newTable.getImagePosition = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsImageGetImagePosition",self.dgsElement,...)
				end
			elseif dgsType == "dgs-dxmemo" then
				newTable.moveCaret = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsMemoMoveCaret",self.dgsElement,...)
				end
				newTable.seekPosition = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsMemoSeekPosition",self.dgsElement,...)
				end
				newTable.getScrollBar = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsMemoGetScrollBar",self.dgsElement,...)
				end
				newTable.setScrollPosition = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsMemoSetScrollPosition",self.dgsElement,...)
				end
				newTable.getScrollPosition = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsMemoGetScrollPosition",self.dgsElement,...)
				end
				newTable.setCaretPosition = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsMemoSetCaretPosition",self.dgsElement,...)
				end
				newTable.getCaretPosition = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsMemoGetCaretPosition",self.dgsElement,...)
				end
				newTable.setCaretStyle = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsMemoSetCaretStyle",self.dgsElement,...)
				end
				newTable.getCaretStyle = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsMemoGetCaretStyle",self.dgsElement,...)
				end
				newTable.setReadOnly = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsMemoSetReadOnly",self.dgsElement,...)
				end
				newTable.getReadOnly = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsMemoGetReadOnly",self.dgsElement,...)
				end
				newTable.getPartOfText = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsMemoGetPartOfText",self.dgsElement,...)
				end
				newTable.deleteText = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsMemoDeleteText",self.dgsElement,...)
				end
				newTable.insertText = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsMemoInsertText",self.dgsElement,...)
				end
				newTable.clearText = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsMemoClearText",self.dgsElement,...)
				end
			elseif dgsType == "dgs-dxlabel" then
				newTable.setColor = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsLabelSetColor",self.dgsElement,...)
				end
				newTable.getColor = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsLabelGetColor",self.dgsElement,...)
				end
				newTable.setHorizontalAlign = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsLabelSetHorizontalAlign",self.dgsElement,...)
				end
				newTable.getHorizontalAlign = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsLabelGetHorizontalAlign",self.dgsElement,...)
				end
				newTable.setVerticalAlign = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsLabelSetVerticalAlign",self.dgsElement,...)
				end
				newTable.getVerticalAlign = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsLabelGetVerticalAlign",self.dgsElement,...)
				end
			elseif dgsType == "dgs-dxprogressbar" then
				newTable.getProgress = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsProgressBarGetProgress",self.dgsElement,...)
				end
				newTable.setProgress = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsProgressBarSetProgress",self.dgsElement,...)
				end
				newTable.getMode = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsProgressBarGetMode",self.dgsElement,...)
				end
				newTable.setMode = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsProgressBarSetMode",self.dgsElement,...)
				end
				newTable.getVerticalSide = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsProgressBarGetVerticalSide",self.dgsElement,...)
				end
				newTable.setVerticalSide = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsProgressBarSetVerticalSide",self.dgsElement,...)
				end
				newTable.getHorizontalSide = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsProgressBarGetHorizontalSide",self.dgsElement,...)
				end
				newTable.setHorizontalSide = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsProgressBarSetHorizontalSide",self.dgsElement,...)
				end
			elseif dgsType == "dgs-dxscrollbar" then
				newTable.setScrollPosition = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsScrollBarSetScrollPosition",self.dgsElement,...)
				end
				newTable.getScrollPosition = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsScrollBarGetScrollPosition",self.dgsElement,...)
				end
				newTable.setScrollSize = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsScrollBarSetScrollSize",self.dgsElement,...)
				end
				newTable.getScrollSize = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsScrollBarGetScrollSize",self.dgsElement,...)
				end
			elseif dgsType == "dgs-dxscrollpane" then
				newTable.getScrollBar = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsScrollPaneGetScrollBar",self.dgsElement,...)
				end
				newTable.setScrollPosition = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsScrollPaneSetScrollPosition",self.dgsElement,...)
				end
				newTable.getScrollPosition = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsScrollPaneGetScrollPosition",self.dgsElement,...)
				end
				newTable.setScrollBarState = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsScrollPaneSetScrollBarState",self.dgsElement,...)
				end
				newTable.getScrollBarState = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsScrollPaneGetScrollBarState",self.dgsElement,...)
				end
			elseif dgsType == "dgs-dxtabpanel" then
				newTable.getSelectedTab = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsGetSelectedTab",self.dgsElement,...)
				end
				newTable.setSelectedTab = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsSetSelectedTab",self.dgsElement,...)
				end
				newTable.getTabFromID = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsTabPanelGetTabFromID",self.dgsElement,...)
				end
				newTable.moveTab = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsTabPanelMoveTab",self.dgsElement,...)
				end
				newTable.getTabID = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsTabPanelGetTabID",self.dgsElement,...)
				end
				newTable.createTab = function(self,text,...)
					local dxgui = call(dgsOOPHead.dgsRes,"dgsCreateTab",text,self.dgsElement,...)
					return createTableForElement(dxgui)
				end
			elseif dgsType == "dgs-dxtab" then
				newTable.deleteTab = function(self,...)
					return call(dgsOOPHead.dgsRes,"dgsDeleteTab",self.dgsElement,...)
				end
			end
			setmetatable(newTable,dgsOOPHead.AccessTable)
			
			dgsOOPHead.dgsClass[dgsElement] = newTable
			return newTable
		end

		DGSClass = {
			getClass = function(self,dgsElement)
				return createTableForElement(dgsElement)
			end
		}
		for k,v in pairs(dgsOOPHead.NoParent) do
			DGSClass[k] = v
		end
		for k,v in pairs(dgsOOPHead.HaveParent) do
			DGSClass[k] = v
		end
	end
	]]
end

