cmdBaseWhiteList = {}
eventHandlers = {}

function dgsCreateCmd(x,y,w,h,relative,parent)
	if not(type(x) == "number") then error(dgsGenAsrt(x,"dgsCreateCmd",1,"number")) end
	if not(type(y) == "number") then error(dgsGenAsrt(y,"dgsCreateCmd",2,"number")) end
	if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsCreateCmd",3,"number")) end
	if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsCreateCmd",4,"number")) end
	local cmdMemo = dgsCreateMemo(x,y,w,h,"",relative,parent)
	dgsMemoSetReadOnly(cmdMemo,true)
	dgsSetData(cmdMemo,"asPlugin","dgs-dxcmd")
	dgsSetData(cmdMemo,"readOnlyCaretShow",true)
	dgsSetData(cmdMemo,"textSize",{1.3,1.3})
	dgsMemoSetWordWrapState(cmdMemo,true)
	dgsSetData(cmdMemo,"bgColor",tocolor(0,0,0,180))
	dgsSetData(cmdMemo,"textColor",tocolor(255,255,255,255))
	dgsSetData(cmdMemo,"caretColor",tocolor(255,255,255,255))
	dgsSetFont(cmdMemo,"arial")
	dgsSetData(cmdMemo,"leading",tonumber(leading) or 20)
	dgsSetData(cmdMemo,"preName","")
	dgsSetData(cmdMemo,"whitelist",cmdBaseWhiteList)
	dgsSetData(cmdMemo,"cmdType","function")
	dgsSetData(cmdMemo,"cmdHistory",{[0]=""})
	dgsSetData(cmdMemo,"cmdCurrentHistory",0)
	local sx,sy = dgsGetSize(cmdMemo,false)
	local edit = dgsCreateEdit(0,-20,sx,20,"",false,cmdMemo,tocolor(255,255,255,255))
	dgsSetData(edit,"textSize",{1.3,1.3})
	dgsSetFont(edit,"arial")
	addEventHandler("onDgsEditAccepted",edit,function()
		local cmd = dgsElementData[source].mycmd
		if dgsGetPluginType(cmd) == "dgs-dxcmd" then
			local text = dgsElementData[source].text
			dgsEditClearText(source)
			if text ~= "" then
				receiveCmdEditInput(cmd,text)
			end
		end
	end,false)
	for k,v in pairs(eventHandlers) do
		dgsEditAddAutoComplete(edit,k,false)
	end
	dgsSetPositionAlignment(edit,_,"bottom")
	dgsSetData(cmdMemo,"cmdEdit",edit)
	dgsSetData(cmdMemo,"hitoutofparent",true)
	dgsSetData(edit,"cursorStyle",1)
	dgsSetData(edit,"cursorThick",1.2)
	dgsSetData(edit,"mycmd",cmdMemo)
	addEventHandler("onDgsTextChange",edit,function()
		local text = dgsElementData[source].text
		local parent = dgsElementData[source].mycmd
		if isElement(parent) then
			if dgsGetPluginType(parent) == "dgs-dxcmd" then
				local hisid = dgsElementData[parent].cmdCurrentHistory
				local history = dgsElementData[parent].cmdHistory
				if history[hisid] ~= text then
					dgsSetData(parent,"cmdCurrentHistory",0)
				end
			end
		end
	end,false)
	triggerEvent("onDgsPluginCreate",cmdMemo,sourceResource)
	return cmdMemo
end

function dgsCmdSetMode(cmd,mode,output)
	if not(dgsGetPluginType(cmd) == "dgs-dxcmd") then error(dgsGenAsrt(cmd,"dgsCmdSetMode",1,"plugin dgs-dxcmd")) end
	if not(type(mode) == "string") then error(dgsGenAsrt(mode,"dgsCmdSetMode",2,"plugin string")) end
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

function dgsCmdClearText(cmd)
	if not(dgsGetPluginType(cmd) == "dgs-dxcmd") then error(dgsGenAsrt(cmd,"dgsCmdClearText",1,"plugin dgs-dxcmd")) end
	dgsSetData(cmd,"texts",{})
end

function dgsCmdAddEventToWhiteList(cmd,rules)
	if not(dgsGetPluginType(cmd) == "dgs-dxcmd") then error(dgsGenAsrt(cmd,"dgsCmdAddEventToWhiteList",1,"plugin dgs-dxcmd")) end
	if not(type(rules) == "table") then error(dgsGenAsrt(rules,"dgsCmdAddEventToWhiteList",2,"table")) end
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

function dgsCmdRemoveEventFromWhiteList(cmd,rules)
	if not(dgsGetPluginType(cmd) == "dgs-dxcmd") then error(dgsGenAsrt(cmd,"dgsCmdRemoveEventFromWhiteList",1,"plugin dgs-dxcmd")) end
	if not(type(rules) == "table") then error(dgsGenAsrt(rules,"dgsCmdRemoveEventFromWhiteList",2,"table")) end
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

function dgsCmdRemoveAllEvents(cmd)
	if not(dgsGetPluginType(cmd) == "dgs-dxcmd" or cmd == "all") then error(dgsGenAsrt(cmd,"dgsCmdRemoveAllEvents",1,"plugin dgs-dxcmd/string","all")) end
	if cmd == "all" then
		cmdBaseWhiteList = {}
		for k,v in pairs(getElementsByType("dgs-dxcmd")) do
			dgsSetData(v,"whitelist",{})
		end
	else
		dgsSetData(cmd,"whitelist",{})
	end
end

function dgsCmdIsInWhiteList(cmd,rule)
	if not(dgsGetPluginType(cmd) == "dgs-dxcmd" or cmd == "all") then error(dgsGenAsrt(cmd,"dgsCmdIsInWhiteList",1,"plugin dgs-dxcmd/string","all")) end
	if not(type(rule) == "string") then error(dgsGenAsrt(rule,"dgsCmdIsInWhiteList",2,"string")) end
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
	if not(dgsGetPluginType(cmd) == "dgs-dxcmd") then error(dgsGenAsrt(cmd,"outputCmdMessage",1,"plugin dgs-dxcmd")) end
	dgsMemoAppendText(cmd,str.."\n",true)
	local textTable = dgsElementData[cmd].text
	local toLine = #textTable
	local toIndex = utf8.len(textTable[toLine][0])
	dgsMemoSetCaretPosition(cmd,toIndex,toLine)
end

function receiveCmdEditInput(cmd,str)
	if dgsGetPluginType(cmd) == "dgs-dxcmd" then
		local history = dgsGetData(cmd,"cmdHistory")
		if history[1] ~= str then
			table.insert(history,1,str)
			dgsSetData(cmd,"cmdHistory",history)
		end
		executeCmdCommand(cmd,unpack(split(str," ")))
	end
end

function dgsCmdGetEdit(cmd)
	if dgsGetPluginType(cmd) == "dgs-dxcmd" then
		return dgsElementData[cmd].cmdEdit
	end
	return false
end

function configCMD(source)
	local dxedit = dgsElementData[source].cmdEdit
	local scalex,scaley = unpack(dgsGetData(source,"textSize"))
	local sx,sy = dgsGetSize(source,false)
	dgsSetPosition(dxedit,0,sy-scaley*20,false)
	dgsSetSize(dxedit,sx,scaley*20,false)
end

function dgsCmdAddCommandHandler(str,func)
	eventHandlers[str] = eventHandlers[str] or {}
	if not(type(str) == "string") then error(dgsGenAsrt(str,"dgsCmdAddCommandHandler",1,"string")) end
	if not(type(func) == "function") then error(dgsGenAsrt(func,"dgsCmdAddCommandHandler",2,"function")) end
	return table.insert(eventHandlers[str],func)
end

function dgsCmdRemoveCommandHandler(str,func)
	eventHandlers[str] = eventHandlers[str] or {}
	if not(type(str) == "string") then error(dgsGenAsrt(str,"dgsCmdRemoveCommandHandler",1,"string")) end
	if not(type(func) == "function") then error(dgsGenAsrt(func,"dgsCmdRemoveCommandHandler",2,"function")) end
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
		outputCmdMessage(cmd,"Execute: "..str)
		for k,v in pairs(eventHandlers[str] or {}) do
			if type(v) == "function" then
				ifound = true
				v(cmd,unpack(arg))
				break
			end
		end
		if not ifound then
			outputCmdMessage(cmd,"Coundn't Find Command:"..str)
		end
	elseif cmdType == "event" then
		outputCmdMessage(cmd,"Trigger: "..str)
		if dgsCmdIsInWhiteList(cmd,dgsGetData(cmd,"preName")..str) then
			ifound = true
			triggerEvent(dgsGetData(cmd,"preName")..str,cmd,...)
		end
		if not ifound then
			outputCmdMessage(cmd,"Access Denied When Calling Event:"..str)
		end
	end
end

function dgsEventCmdSetPreName(cmd,preName)
	if not(dgsGetPluginType(cmd) == "dgs-dxcmd") then error(dgsGenAsrt(cmd,"dgsEventCmdSetPreName",1,"plugin dgs-dxcmd")) end
	if not(type(preName) == "string") then error(dgsGenAsrt(preName,"dgsEventCmdSetPreName",1,"string")) end
    return dgsSetData(cmd,"preName",preName)
end
