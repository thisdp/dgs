cmdBaseWhiteList = {}
eventHandlers = {}

function dgsCreateCmd(x,y,sx,sy,relative,parent)
	assert(tonumber(x),"Bad argument @dgsCreateCmd at argument 1, expect number [ got "..type(x).." ]")
	assert(tonumber(y),"Bad argument @dgsCreateCmd at argument 2, expect number [ got "..type(y).." ]")
	assert(tonumber(sx),"Bad argument @dgsCreateCmd at argument 3, expect number [ got "..type(sx).." ]")
	assert(tonumber(sy),"Bad argument @dgsCreateCmd at argument 4, expect number [ got "..type(sy).." ]")
	local cmdMemo = dgsCreateMemo(x,y,sx,sy,"",relative,parent)
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
	local edit = dgsCreateEdit(0,0,sx,20,"",false,cmdMemo,tocolor(255,255,255,255))
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
	dgsSetSide(edit,"bottom","tob")
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
	assert(dgsGetPluginType(cmd) == "dgs-dxcmd","Bad argument @dgsCmdSetMode at argument 1, expect plugin dgs-dxcmd [ got "..dgsGetPluginType(cmd).." ]")
	assert(type(mode) == "string","Bad argument @dgsCMDSetMode at argument 2, expect string [ got "..type(mode).." ]")
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
	assert(dgsGetPluginType(cmd) == "dgs-dxcmd","Bad argument @dgsCmdSetMode at argument 1, expect plugin dgs-dxcmd [ got "..dgsGetPluginType(cmd).." ]")
	dgsSetData(cmd,"texts",{})
end

function dgsCmdAddEventToWhiteList(cmd,rules)
	assert(dgsGetPluginType(cmd) == "dgs-dxcmd" or cmd == "all","Bad argument @dgsCmdAddEventToWhiteList at argument 1, expect plugin dgs-dxcmd or string('all') [ got "..dgsGetPluginType(cmd).." ]")
	assert(type(rules) == "table","Bad argument @dgsCmdAddEventToWhiteList at argument 2, expect table [ got "..type(rules).." ]")
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
	assert(dgsGetPluginType(cmd) == "dgs-dxcmd" or cmd == "all","Bad argument @dgsCmdRemoveEventFromWhiteList at argument 1, expect plugin dgs-dxcmd or string('all') [ got "..dgsGetPluginType(cmd).." ]")
	assert(type(rules) == "table","Bad argument @dgsCmdAddEventToWhiteList at argument 2, expect table [ got "..type(rules).." ]")
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
	assert(dgsGetPluginType(cmd) == "dgs-dxcmd" or cmd == "all","Bad argument @dgsCmdRemoveAllEvents at argument 1, expect plugin dgs-dxcmd or string('all') [ got "..dgsGetPluginType(cmd).." ]")
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
	assert(dgsGetPluginType(cmd) == "dgs-dxcmd" or cmd == "all","Bad argument @dgsCmdIsInWhiteList at argument 1, expect plugin dgs-dxcmd or string('all') [ got "..dgsGetPluginType(cmd).." ]")
	assert(type(rule) == "string","Bad argument @dgsCmdIsInWhiteList at argument 2, expect string [ got "..type(rule).." ]")
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
	assert(dgsGetPluginType(cmd) == "dgs-dxcmd","Bad argument @outputCmdMessage at argument 1, expect plugin dgs-dxcmd [ got "..dgsGetPluginType(cmd).." ]")
	dgsMemoAppendText(cmd,str.."\n",true)
	local textTable = dgsElementData[cmd].text
	dgsMemoSetCaretPosition(cmd,textTable[#textTable][-1])
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
	assert(type(str) == "string","bad argument @addEventHandler at argument 1, expect string [ got "..type(str).." ]")
	assert(type(func) == "function","bad argument @addEventHandler at argument 2, expect function [ got "..type(func).." ]")
	return table.insert(eventHandlers[str],func)
end

function dgsCmdRemoveCommandHandler(str,func)
	eventHandlers[str] = eventHandlers[str] or {}
	assert(type(str) == "string","bad argument @addEventHandler at argument 1, expect string [ got "..type(str).." ]")
	assert(type(func) == "function","bad argument @addEventHandler at argument 2, expect function [ got "..type(func).." ]")
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
			outputCmdMessage(cmd,"Access Dined When Calling Event:"..str)
		end
	end
end

function dgsEventCmdSetPreName(cmd,preName)
    assert(dgsGetPluginType(cmd) == "dgs-dxcmd","Bad argument @dgsEventCmdSetPreName at argument 1, expect plugin dgs-dxcmd [ got "..dgsGetPluginType(cmd).." ]")
    assert(type(preName) == "string","Bad argument @dgsEventCmdSetPreName at argument 2, expect string [ got "..type(preName).." ]")
    return dgsSetData(cmd,"preName",preName)
end
