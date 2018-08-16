addEvent("onClientDgsDxMouseLeave",true)
addEvent("onClientDgsDxMouseEnter",true)
addEvent("onClientDgsDxMouseClick",true)
addEvent("onClientDgsDxMouseDoubleClick",true)
addEvent("onClientDgsDxWindowClose",true)
addEvent("onClientDgsDxGUIPositionChange",true)
addEvent("onClientDgsDxGUISizeChange",true)
addEvent("onClientDgsDxGUITextChange",true)
addEvent("onClientDgsDxScrollBarScrollPositionChange",true)
addEvent("onClientDgsDxGUIDestroy",true)
addEvent("onClientDgsDxGridListSelect",true)
addEvent("onClientDgsDxGridListItemDoubleClick",true)
addEvent("onClientDgsDxProgressBarChange",true)
addEvent("onClientDgsDxGUICreate",true)
addEvent("onClientDgsDxGUIPreCreate",true)
addEvent("onClientDgsDxPreRender",true)
addEvent("onClientDgsDxRender",true)
addEvent("onClientDgsDxFocus",true)
addEvent("onClientDgsDxBlur",true)
addEvent("onClientDgsDxGUICursorMove",true)
addEvent("onClientDgsDxTabPanelTabSelect",true)
addEvent("onClientDgsDxRadioButtonChange",true)
addEvent("onClientDgsDxCheckBoxChange",true)
addEvent("onClientDgsDxComboBoxSelect",true)
addEvent("onClientDgsDxComboBoxStateChange",true)
addEvent("onClientDgsDxEditPreSwitch",true)
addEvent("onClientDgsDxEditSwitched",true)
transfer = {}
transfer["onDgsMouseLeave"] = 	"onClientDgsDxMouseLeave"
transfer["onDgsMouseEnter"] = 	"onClientDgsDxMouseEnter"
transfer["onDgsMouseClick"] = 	"onClientDgsDxMouseClick"
transfer["onDgsMouseDoubleClick"] = 	"onClientDgsDxMouseDoubleClick"
transfer["onDgsPositionChange"] = 	"onClientDgsDxGUIPositionChange"
transfer["onDgsSizeChange"] = 	"onClientDgsDxGUISizeChange"
transfer["onDgsTextChange"] = 	"onClientDgsDxGUITextChange"
transfer["onDgsScrollBarScrollPositionChange"] = 	"onClientDgsDxScrollBarScrollPositionChange"
transfer["onDgsDestroy"] = 	"onClientDgsDxGUIDestroy"
transfer["onDgsGridListSelect"] = 	"onClientDgsDxGridListSelect"
transfer["onDgsGridListItemDoubleClick"] = 	"onClientDgsDxGridListItemDoubleClick"
transfer["onDgsProgressBarChange"] = 	"onClientDgsDxProgressBarChange"
transfer["onDgsCreate"] = 	"onClientDgsDxGUICreate"
transfer["onDgsPreCreate"] = 	"onClientDgsDxGUIPreCreate"
transfer["onDgsPreRender"] = 	"onClientDgsDxPreRender"
transfer["onDgsRender"] = 	"onClientDgsDxRender"
transfer["onDgsFocus"] = 	"onClientDgsDxFocus"
transfer["onDgsBlur"] = 	"onClientDgsDxBlur"
transfer["onDgsCursorMove"] = 	"onClientDgsDxGUICursorMove"
transfer["onDgsTabPanelTabSelect"] = 	"onClientDgsDxTabPanelTabSelect"
transfer["onDgsRadioButtonChange"] = 	"onClientDgsDxRadioButtonChange"
transfer["onDgsCheckBoxChange"] = 	"onClientDgsDxCheckBoxChange"
transfer["onDgsComboBoxSelect"] = 	"onClientDgsDxComboBoxSelect"
transfer["onDgsComboBoxStateChange"] = 	"onClientDgsDxComboBoxStateChange"
transfer["onDgsEditPreSwitch"] = 	"onClientDgsDxEditPreSwitch"
transfer["onDgsEditSwitched"] = 	"onClientDgsDxEditSwitched"
function eventTransfer(...)
	if transfer[eventName] then
		if isElement(source) then
			triggerEvent(transfer[eventName],source,...)
		end
	end
end
addEventHandler("onDgsMouseLeave",root,eventTransfer)
addEventHandler("onDgsMouseEnter",root,eventTransfer)
addEventHandler("onDgsMouseClick",root,eventTransfer)
addEventHandler("onDgsMouseDoubleClick",root,eventTransfer)
addEventHandler("onDgsWindowClose",root,eventTransfer)
addEventHandler("onDgsPositionChange",root,eventTransfer)
addEventHandler("onDgsSizeChange",root,eventTransfer)
addEventHandler("onDgsTextChange",root,eventTransfer)
addEventHandler("onDgsScrollBarScrollPositionChange",root,eventTransfer)
addEventHandler("onDgsDestroy",root,eventTransfer)
addEventHandler("onDgsGridListSelect",root,eventTransfer)
addEventHandler("onDgsGridListItemDoubleClick",root,eventTransfer)
addEventHandler("onDgsProgressBarChange",root,eventTransfer)
addEventHandler("onDgsCreate",root,eventTransfer)
addEventHandler("onDgsPreCreate",root,eventTransfer)
addEventHandler("onDgsPreRender",root,eventTransfer)
addEventHandler("onDgsRender",root,eventTransfer)
addEventHandler("onDgsFocus",root,eventTransfer)
addEventHandler("onDgsBlur",root,eventTransfer)
addEventHandler("onDgsCursorMove",root,eventTransfer)
addEventHandler("onDgsTabPanelTabSelect",root,eventTransfer)
addEventHandler("onDgsRadioButtonChange",root,eventTransfer)
addEventHandler("onDgsCheckBoxChange",root,eventTransfer)
addEventHandler("onDgsComboBoxSelect",root,eventTransfer)
addEventHandler("onDgsComboBoxStateChange",root,eventTransfer)
addEventHandler("onDgsEditPreSwitch",root,eventTransfer)
addEventHandler("onDgsEditSwitched",root,eventTransfer)
dgsDxGUIGetProperty	=	dgsGetProperty
dgsDxGUISetProperty	=	dgsSetProperty
dgsDxGUIGetProperties	=	dgsGetProperties
dgsDxGUISetProperties	=	dgsSetProperties
dgsDxGUIGetVisible	=	dgsGetVisible
dgsDxGUISetVisible	=	dgsSetVisible
dgsDxGUIGetEnabled	=	dgsGetEnabled
dgsDxGUISetEnabled	=	dgsSetEnabled
dgsDxGUIGetSide	=	dgsGetSide
dgsDxGUISetSide	=	dgsSetSide
dgsDxGUIGetAlpha	=	dgsGetAlpha
dgsDxGUISetAlpha	=	dgsSetAlpha
dgsDxGUIGetFont	=	dgsGetFont
dgsDxGUISetFont	=	dgsSetFont
dgsDxGUISetText	=	dgsSetText
dgsDxGUIGetText	=	dgsGetText
dgsDxGUICreateFont	=	dgsCreateFont
dgsDxGUIBringToFront	=	dgsBringToFront
dgsDxCreateWindow	=	dgsCreateWindow
dgsDxWindowSetSizable	=	dgsWindowSetSizable
dgsDxWindowSetMovable	=	dgsWindowSetMovable
dgsDxGUICloseWindow	=	dgsCloseWindow
dgsDxWindowSetCloseButtonEnabled	=	dgsWindowSetCloseButtonEnabled
dgsDxWindowGetCloseButtonEnabled	=	dgsWindowGetCloseButtonEnabled
dgsDxCreateScrollPane	=	dgsCreateScrollPane
dgsDxScrollPaneGetScrollBar	=	dgsScrollPaneGetScrollBar
dgsDxCreateRadioButton	=	dgsCreateRadioButton
dgsDxRadioButtonGetSelected	=	dgsRadioButtonGetSelected
dgsDxRadioButtonSetSelected	=	dgsRadioButtonSetSelected
dgsDxCreateCheckBox	=	dgsCreateCheckBox
dgsDxCheckBoxGetSelected	=	dgsCheckBoxGetSelected
dgsDxCheckBoxSetSelected	=	dgsCheckBoxSetSelected
dgsDxCreateComboBox	=	dgsCreateComboBox
dgsDxComboBoxAddItem	=	dgsComboBoxAddItem
dgsDxComboBoxRemoveItem	=	dgsComboBoxRemoveItem
dgsDxComboBoxSetItemText	=	dgsComboBoxSetItemText
dgsDxComboBoxGetItemText	=	dgsComboBoxGetItemText
dgsDxComboBoxClear	=	dgsComboBoxClear
dgsDxComboBoxSetSelectedItem	=	dgsComboBoxSetSelectedItem
dgsDxComboBoxGetSelectedItem	=	dgsComboBoxGetSelectedItem
dgsDxComboBoxSetItemColor	=	dgsComboBoxSetItemColor
dgsDxComboBoxGetItemColor	=	dgsComboBoxGetItemColor
dgsDxComboBoxSetState	=	dgsComboBoxSetState
dgsDxComboBoxGetState	=	dgsComboBoxGetState
dgsDxComboBoxSetBoxHeight	=	dgsComboBoxSetBoxHeight
dgsDxComboBoxGetBoxHeight	=	dgsComboBoxGetBoxHeight
dgsDxComboBoxGetScrollBar	=	dgsComboBoxGetScrollBar
dgsDxCreateButton	=	dgsCreateButton
dgsDxCreateCmd	=	dgsCreateCmd
dgsDxCmdSetMode	=	dgsCmdSetMode
dgsDxEventCmdSetPreName	=	dgsEventCmdSetPreName
dgsDxCmdGetEdit	=	dgsCmdGetEdit
dgsDxCmdAddEventToWhiteList	=	dgsCmdAddEventToWhiteList
dgsDxCmdRemoveEventFromWhiteList	=	dgsCmdRemoveEventFromWhiteList
dgsDxCmdRemoveAllEvents	=	dgsCmdRemoveAllEvents
dgsDxCmdIsInWhiteList	=	dgsCmdIsInWhiteList
dgsDxCmdAddCommandHandler	=	dgsCmdAddCommandHandler
dgsDxCmdRemoveCommandHandler	=	dgsCmdRemoveCommandHandler
dgsDxCmdClearText	=	dgsCmdClearText
dgsDxCreateEdit	=	dgsCreateEdit
dgsDxEditMoveCaret	=	dgsEditMoveCaret
dgsDxEditGetCaretPosition	=	dgsEditGetCaretPosition
dgsDxEditSetCaretPosition	=	dgsEditSetCaretPosition
dgsDxEditGetCaretStyle	=	dgsEditGetCaretStyle
dgsDxEditSetCaretStyle	=	dgsEditSetCaretStyle
dgsDxEditSetWhiteList	=	dgsEditSetWhiteList
dgsDxEditGetMaxLength	=	dgsEditGetMaxLength
dgsDxEditSetMaxLength	=	dgsEditSetMaxLength
dgsDxEditSetReadOnly	=	dgsEditSetReadOnly
dgsDxEditGetReadOnly	=	dgsEditGetReadOnly
dgsDxEditSetMasked	=	dgsEditSetMasked
dgsDxEditGetMasked	=	dgsEditGetMasked
dgsDxCreateMemo	=	dgsCreateMemo
dgsDxMemoMoveCaret	=	dgsMemoMoveCaret
dgsDxMemoSeekPosition	=	dgsMemoSeekPosition
dgsDxMemoSetCaretPosition	=	dgsMemoSetCaretPosition
dgsDxMemoGetCaretPosition	=	dgsMemoGetCaretPosition
dgsDxMemoSetCaretStyle	=	dgsMemoSetCaretStyle
dgsDxMemoGetCaretStyle	=	dgsMemoGetCaretStyle
dgsDxMemoSetReadOnly	=	dgsMemoSetReadOnly
dgsDxMemoGetReadOnly	=	dgsMemoGetReadOnly
dgsDxMemoGetPartOfText	=	dgsMemoGetPartOfText
dgsDxMemoDeleteText	=	dgsMemoDeleteText
dgsDxMemoInsertText	=	dgsMemoInsertText
dgsDxMemoGetScrollBar	=	dgsMemoGetScrollBar
dgsDxCreateImage	=	dgsCreateImage
dgsDxImageSetImage	=	dgsImageSetImage
dgsDxImageGetImage	=	dgsImageGetImage
dgsDxImageSetImageSize	=	dgsImageSetImageSize
dgsDxImageGetImageSize	=	dgsImageGetImageSize
dgsDxImageSetImagePosition	=	dgsImageSetImagePosition
dgsDxImageGetImagePosition	=	dgsImageGetImagePosition
dgsDxCreateProgressBar	=	dgsCreateProgressBar
dgsDxProgressBarGetProgress	=	dgsProgressBarGetProgress
dgsDxProgressBarSetProgress	=	dgsProgressBarSetProgress
dgsDxProgressBarGetMode	=	dgsProgressBarGetMode
dgsDxProgressBarSetMode	=	dgsProgressBarSetMode
dgsDxProgressBarGetUpDownDistance	=	dgsProgressBarGetUpDownDistance
dgsDxProgressBarSetUpDownDistance	=	dgsProgressBarSetUpDownDistance
dgsDxProgressBarGetLeftRightDistance	=	dgsProgressBarGetLeftRightDistance
dgsDxProgressBarSetLeftRightDistance	=	dgsProgressBarSetLeftRightDistance
dgsDxCreateLabel	=	dgsCreateLabel
dgsDxLabelGetColor	=	dgsLabelGetColor
dgsDxLabelSetColor	=	dgsLabelSetColor
dgsDxLabelSetHorizontalAlign	=	dgsLabelSetHorizontalAlign
dgsDxLabelSetVerticalAlign	=	dgsLabelSetVerticalAlign
dgsDxLabelGetHorizontalAlign	=	dgsLabelGetHorizontalAlign
dgsDxLabelGetVerticalAlign	=	dgsLabelGetVerticalAlign
dgsDxCreateTabPanel	=	dgsCreateTabPanel
dgsDxCreateTab	=	dgsCreateTab
dgsDxTabPanelGetTabFromID	=	dgsTabPanelGetTabFromID
dgsDxTabPanelMoveTab	=	dgsTabPanelMoveTab
dgsDxTabPanelGetTabID	=	dgsTabPanelGetTabID
dgsDxDeleteTab	=	dgsDeleteTab
dgsDxCreateScrollBar	=	dgsCreateScrollBar
dgsDxScrollBarSetScrollBarPosition	=	dgsScrollBarSetScrollBarPosition
dgsDxScrollBarGetScrollBarPosition	=	dgsScrollBarGetScrollBarPosition
dgsDxScrollBarSetColor	=	dgsScrollBarSetColor
dgsDxCreateGridList	=	dgsCreateGridList
dgsDxScrollPaneGetScrollBar	=	dgsScrollPaneGetScrollBar
dgsDxGridListResetScrollBarPosition	=	dgsGridListResetScrollBarPosition
dgsDxGridListSetColumnRelative	=	dgsGridListSetColumnRelative
dgsDxGridListGetColumnRelative	=	dgsGridListGetColumnRelative
dgsDxGridListAddColumn	=	dgsGridListAddColumn
dgsDxGridListGetColumnCount	=	dgsGridListGetColumnCount
dgsDxGridListRemoveColumn	=	dgsGridListRemoveColumn
dgsDxGridListGetColumnAllLength	=	dgsGridListGetColumnAllLength
dgsDxGridListGetColumnLength	=	dgsGridListGetColumnLength
dgsDxGridListGetColumnTitle	=	dgsGridListGetColumnTitle
dgsDxGridListSetColumnTitle	=	dgsGridListSetColumnTitle
dgsDxGridListAddRow	=	dgsGridListAddRow
dgsDxGridListRemoveRow	=	dgsGridListRemoveRow
dgsDxGridListClearRow	=	dgsGridListClearRow
dgsDxGridListGetRowCount	=	dgsGridListGetRowCount
dgsDxGridListSetItemText	=	dgsGridListSetItemText
dgsDxGridListGetItemText	=	dgsGridListGetItemText
dgsDxGridListGetSelectedItem	=	dgsGridListGetSelectedItem
dgsDxGridListSetSelectedItem	=	dgsGridListSetSelectedItem
dgsDxGridListSetItemColor	=	dgsGridListSetItemColor
dgsDxGridListGetItemColor	=	dgsGridListGetItemColor
dgsDxGridListGetRowBackGroundImage	=	dgsGridListGetRowBackGroundImage
dgsDxGridListSetRowBackGroundImage	=	dgsGridListSetRowBackGroundImage
dgsDxGridListSetRowBackGroundColor	=	dgsGridListSetRowBackGroundColor
dgsDxGridListGetRowBackGroundColor	=	dgsGridListGetRowBackGroundColor
dgsDxGridListGetItemData	=	dgsGridListGetItemData
dgsDxGridListSetItemData	=	dgsGridListSetItemData
dgsDxGridListSetRowAsSection	=	dgsGridListSetRowAsSection
dgsDxCreateEDA	=	dgsCreateEDA
dgsDxEDASetDebugModeEnabled	=	dgsEDASetDebugModeEnabled
dgsDxEDAGetDebugModeEnabled	=	dgsEDAGetDebugModeEnabled
dgsDxGridListGetItemImage	=	dgsGridListGetItemImage
dgsDxGridListSetItemImage	=	dgsGridListSetItemImage
dgsDxGridListRemoveItemImage	=	dgsGridListRemoveItemImage
dgsDxGetMouseEnterGUI	=	dgsGetMouseEnterGUI



-----------------------------old Property

oldPropertyNameTable = {
	textcolor="textColor",
	textsize="textSize",
	rowtextcolor="rowTextColor",
	rowtextsize="rowTextSize",
	columntextcolor="columnTextColor",
	columntextsize="columnTextSize",
	listtextcolor="itemTextColor",
	listtextsize="itemTextSize",
	selectcolor="selectColor",
	cursorStyle="caretStyle",
	cursorThick="caretThick",
	cursorOffset="caretOffset",
	cursorposXY="caretPos",
	cursorpos="caretPos",
	buttonsize="buttonSize",
	tabheight="tabHeight",
	tabmaxwidth="tabMaxWidth",
	tabminwidth="tabMinWidth",
	tabsidesize="tabSideSize",
	tabgapsize="tabGapSize",
	defbackground="bgColor",
	bgcolor="bgColor",
	bgimage="bgImage",
	bgimg="bgImage",
	tabimage="tabImage",
	tabcolor="tabColor",
	imagepos="imageUVPos",
	imagesize="imageUVSize",
	titimage="titleImage",
	titnamecolor="titleTextColor",
	titcolor="titleColor",
	titlesize="titleHeight",
	sidesize="borderSize",
	scrollmultiplier="scrollMultiplier",
	barimg="barImage",
	barmode="barMode",
	barcolor="barColor",
	barsize="barSize",
	selectfrom="selectFrom",
	ignoreTitleSize="ignoreTitle",
}
--[[
function preFunction(res,fnc,aclAllow,filename,line,dxgui,property)
	if fnc == "dgsGetProperties" or fnc == "dgsSetProperties" then
		for k,v in pairs(property) do
			if oldPropertyNameTable[k] then
				outputDebugString("[DGS]"..resName.."/"..filename..":"..line..": @"..fnc.." Property '"..k.."' will be no longer supported, use '"..oldPropertyNameTable[k].."' instead",2)
			end
		end
	elseif fnc == "dgsGetProperty" or fnc == "dgsSetProperty" then
		local resName = getResourceName(res)
		if oldPropertyNameTable[property] then
			outputDebugString("[DGS]"..resName.."/"..filename..":"..line..": @"..fnc.." Property '"..property.."' will be no longer supported, use '"..oldPropertyNameTable[property].."' instead",2)
		end
	end
end
addDebugHook( "preFunction", preFunction )]]
