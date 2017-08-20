cmdBaseWhiteList = {}
eventHandlers = {}

function dgsDxCreateCmd(x,y,sx,sy,relative,parent,scalex,scaley,hangju,bgimg,bgcolor)
	assert(tonumber(x),"@dgsDxCreateCmd argument 1,expect number got "..type(x))
	assert(tonumber(y),"@dgsDxCreateCmd argument 2,expect number got "..type(y))
	assert(tonumber(sx),"@dgsDxCreateCmd argument 3,expect number got "..type(sx))
	assert(tonumber(sy),"@dgsDxCreateCmd argument 4,expect number got "..type(sy))
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"@dgsDxCreateCmd argument 6,expect dgs-dxgui got "..dgsGetType(parent))
	end
	local cmd = createElement("dgs-dxcmd")
	scalex,scaley = tonumber(scalex) or 1,tonumber(scaley) or 1
	dgsSetType(cmd,"dgs-dxcmd")
	dgsSetData(cmd,"textsize",{scalex,scaley})
	dgsSetData(cmd,"bgimg",bgimg)
	dgsSetData(cmd,"hangju",tonumber(hangju) or 20)
	dgsSetData(cmd,"bgcolor",bgcolor or tocolor(0,0,0,150))
	dgsSetData(cmd,"texts",{})
	dgsSetData(cmd,"preName","")
	dgsSetData(cmd,"startRow",0)
	dgsSetData(cmd,"font",dsm)
	dgsSetData(cmd,"whitelist",cmdBaseWhiteList)
	dgsSetData(cmd,"cmdType","function")
	local tabl = {}
	tabl[0] = ""
	dgsSetData(cmd,"cmdHistory",tabl)
	dgsSetData(cmd,"cmdCurrentHistory",0)
	if isElement(parent) then
		dgsSetParent(cmd,parent)
	else
		table.insert(MaxFatherTable,cmd)
	end
	insertResourceDxGUI(sourceResource,cmd)
	triggerEvent("onClientDgsDxGUIPreCreate",cmd)
	calculateGuiPositionSize(cmd,x,y,relative or false,sx,sy,relative or false,true)
	triggerEvent("onClientDgsDxGUICreate",cmd)
	local sx,sy = dgsGetSize(cmd,false)
	local edit = dgsDxCreateEdit(0,sy-scaley*20,sx,scaley*20,"",false,cmd,tocolor(0,0,0,255),scalex,scaley)
	dgsSetData(cmd,"cmdEdit",edit)
	dgsSetData(edit,"cursorStyle",1)
	dgsSetData(edit,"cursorThick",1.2)
	dgsSetData(edit,"mycmd",cmd)
	return cmd
end

function dgsDxCmdSetMode(cmd,mode,output)
	assert(dgsGetType(cmd) == "dgs-dxcmd","@dgsDxCmdSetMode argument 1,expect dgs-dxcmd got "..(dgsGetType(cmd) or type(cmd)))
	assert(type(mode) == "string","@dgsDxCMDSetMode argument 2, expect string got "..type(mode))
	if mode == "function" or mode == "event" then
		triggerEvent("onCMDModePreChange",cmd,mode)
		if not wasEventCancelled() then
			dgsSetData(cmd,"cmdType","event")
			if output then
				outputCmdMessage(cmd,"[Mode]Current Mode is ‘"..(mode == "function" and "Function" or "Event").." CMD’")
			end
			return true
		end
	end
	return false
end

function dgsDxCmdAddEventToWhiteList(cmd,rules)
	assert(dgsGetType(cmd) == "dgs-dxcmd" or cmd == "all","@dgsDxCmdAddEventToWhiteList argument 1,expect dgs-dxcmd or string('all') got "..(dgsGetType(cmd) or type(cmd)))
	assert(type(rules) == "table","@dgsDxCmdAddEventToWhiteList argument 2,expect table got "..type(rules))
	if cmd == "all" then
		for k,v in pairs(getElementsByType("dgs-dxcmd")) do
			local oldrule = dgsGetData(v,"whitelist")
			local newrule = table.merger(oldrule,rules)
			if newrule then
				dgsSetData(v,"whitelist",newrule)
			end
		end
		cmdBaseWhiteList = table.merger(cmdBaseWhiteList,rules)
	else
		local oldrule = dgsGetData(cmd,"whitelist")
		local newrule = table.merger(oldrule,rules)
		if newrule then
			dgsSetData(cmd,"whitelist",newrule)
		end
	end
end

function dgsDxCmdRemoveEventFromWhiteList(cmd,rules)
	assert(dgsGetType(cmd) == "dgs-dxcmd" or cmd == "all","@dgsDxCmdRemoveEventFromWhiteList argument 1,expect dgs-dxcmd or string('all') got "..(dgsGetType(cmd) or type(cmd)))
	assert(type(rules) == "table","@dgsDxCmdAddEventToWhiteList argument 2,expect table got "..type(rules))
	if cmd == "all" then
		for k,v in pairs(getElementsByType("dgs-dxcmd")) do
			local oldrule = dgsGetData(v,"whitelist")
			local newrule = table.complement(oldrule,rules)
			if newrule then
				dgsSetData(v,"whitelist",newrule)
			end
		end
		cmdBaseWhiteList = table.complement(cmdBaseWhiteList,rules)
	else
		local oldrule = dgsGetData(cmd,"whitelist")
		local newrule = table.complement(oldrule,rules)
		if newrule then
			dgsSetData(cmd,"whitelist",newrule)
		end
	end
end

function dgsDxCmdRemoveAllEvents(cmd)
	assert(dgsGetType(cmd) == "dgs-dxcmd" or cmd == "all","@dgsDxCmdRemoveAllEvents argument 1,expect dgs-dxcmd or string('all') got "..(dgsGetType(cmd) or type(cmd)))
	if cmd == "all" then
		cmdBaseWhiteList = {}
		for k,v in pairs(getElementsByType("dgs-dxcmd")) do
			dgsSetData(v,"whitelist",{})
		end
	else
		dgsSetData(cmd,"whitelist",{})
	end
end

function dgsDxCmdIsInWhiteList(cmd,rule)
	assert(dgsGetType(cmd) == "dgs-dxcmd" or cmd == "all","@dgsDxCmdIsInWhiteList argument 1,expect dgs-dxcmd or string('all') got "..(dgsGetType(cmd) or type(cmd)))
	assert(type(rule) == "string","@dgsDxCmdIsInWhiteList argument 2,expect string got "..type(rule))
	if table.find(preinstallWhiteList,rule) then
		return true
	else
		if cmd == "all" then
			if table.find(cmdBaseWhiteList,rule) then
				return true
			end
		else
			local wtlist = dgsGetData(cmd,"whitelist")
			if table.find(wtlist,rule) then
				return true
			end
		end
	end
	return false
end

function outputCmdMessage(cmd,str)
	local texts = dgsGetData(cmd,"texts")
	table.insert(texts,1,dgsGetChars(str))
end

function receiveCmdEditInput(cmd,str)
	if dgsGetType(cmd) == "dgs-dxcmd" then
		local history = dgsGetData(cmd,"cmdHistory")
		if history[1] ~= str then
			table.insert(history,1,str)
			dgsSetData(cmd,"cmdHistory",history)
		end
		executeCmdCommand(cmd,unpack(split(str," ")))
	end
end

function dgsGetChars(str,max)
	tabl = {}
	local strCode = utfCode(str)
	table.insert(tabl,utfChar(strCode))
	local number = 0
	max = max or 500
	while strCode ~= 0 and number <= max do
		str = utfSub(str,utfLen(utfChar(strCode))+1,utfLen(str))
		strCode = utfCode(str)
		if strCode == 0 then
			break
		end
		table.insert(tabl,utfChar(strCode))
		number = number+1
	end
	return tabl
end

function dgsGetCmdEdit(cmd)
	if dgsGetType(cmd) == "dgs-dxcmd" then
		return dgsGetData(cmd,"cmdEdit")
	end
	return false
end

function configCMD(source)
	local dxedit = dgsGetData(source,"cmdEdit")
	local scalex,scaley = unpack(dgsGetData(source,"textsize"))
	local sx,sy = dgsGetSize(source,false)
	dgsSetPosition(dxedit,0,sy-scaley*20,false)
	dgsSetSize(dxedit,sx,scaley*20,false)
end

function dgsAddCommandHandler(str,func)
	eventHandlers[str] = eventHandlers[str] or {}
	assert(type(str) == "string","bad argument 'addEventHandler' at 1 ,expect string got "..type(str))
	assert(type(func) == "function","bad argument 'addEventHandler' at 2 ,expect function got "..type(func))
	return table.insert(eventHandlers[str],func)
end

function dgsRemoveCommandHandler(str,func)
	eventHandlers[str] = eventHandlers[str] or {}
	assert(type(str) == "string","bad argument 'addEventHandler' at 1 ,expect string got "..type(str))
	assert(type(func) == "function","bad argument 'addEventHandler' at 2 ,expect function got "..type(func))
	local id = table.find(eventHandlers[str],func)
	if id then
		return table.remove(eventHandlers[str],id)
	end
	return true
end

function executeCmdCommand(cmd,str,...)
	local arg = {...}
	local ifound = false
	local cmdType = dgsGetData(cmd,"cmdType")
	if cmdType == "function" then
		for k,v in pairs(eventHandlers[str] or {}) do
			if type(v) == "function" then
				ifound = true
				v(cmd,unpack(arg))
			end
		end
		if not ifound then
			outputCmdMessage(cmd,"Coundn't Find Such Command:"..str)
		end
	elseif cmdType == "event" then
		if dgsDxCmdIsInWhiteList(cmd,dgsGetData(cmd,"preName")..str) then
			ifound = true
			triggerEvent(dgsGetData(cmd,"preName")..str,cmd,...)
		end
		if not ifound then
			outputCmdMessage(cmd,"Access Dined When Calling Event:"..str)
		end
	end
end

function dgsDxEventCmdSetPreName(cmd,preName)
    assert(dgsGetType(cmd) == "dgs-dxcmd","@dgsDxEventCmdSetPreName argument 1,expect dgs-dxcmd got "..(dgsGetType(cmd) or type(cmd)))
    assert(type(preName) == "string","@dgsDxEventCmdSetPreName argument 2,expect string got "..type(preName))
    return dgsSetData(cmd,"preName",preName)
end