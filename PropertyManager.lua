local tostring = tostring
local tonumber = tonumber
dgsElementData = {[resourceRoot] = {}}		----The Global BuiltIn DGS Element Data Table

function dgsGetData(element,key)
	return dgsElementData[element] and dgsElementData[element][key] or false
end

function dgsSetData(element,key,value,nocheck)
	local dgsType,key = dgsGetType(element),tostring(key)
	if isElement(element) and dgsType then
		dgsElementData[element] = dgsElementData[element] or {}
		local oldValue = dgsElementData[element][key]
		if oldValue ~= value then
			dgsElementData[element][key] = value
			if not nocheck then
				if dgsType == "dgs-dxscrollbar" then
					if key == "length" then
						local w,h = dgsGetSize(element,false)
						local isHorizontal = dgsElementData[element].isHorizontal
						if (value[2] and value[1]*(isHorizontal and w-h*2 or h-w*2) or value[1]) < dgsElementData[element].minLength then
							dgsElementData[element].length = {dgsElementData[element].minLength,false}
						end
					elseif key == "position" then
						if not dgsElementData[element].locked then
							if oldValue and oldValue ~= value then
								local grades = dgsElementData[element].grades
								if grades then
									local currentGrade = math.floor(value/100*grades+0.5)
									dgsSetData(element,"currentGrade",currentGrade)
									dgsElementData[element][key] = currentGrade/grades*100
									triggerEvent("onDgsElementScroll",element,element,dgsElementData[element][key],oldValue)
								else
									triggerEvent("onDgsElementScroll",element,element,value,oldValue)
								end
							end
						else
							dgsElementData[element][key] = oldValue
						end
					elseif key == "grades" then
						if value then
							local pos = dgsElementData[element].position
							local currentGrade = math.floor(pos/100*value+0.5)
							dgsSetData(element,"currentGrade",currentGrade)
						else
							dgsSetData(element,"currentGrade",false)
						end
					end
				elseif dgsType == "dgs-dxgridlist" then
					if key == "columnHeight" or key == "mode" or key== "scrollBarThick" or key== "leading" then
						configGridList(element)
					elseif key == "rowData" then
						if dgsElementData[element].autoSort then
							dgsElementData[element].nextRenderSort = true
						end
					elseif key == "rowMoveOffset" then
						dgsGridListUpdateRowMoveOffset(element)
					end
				elseif dgsType == "dgs-dxscrollpane" then
					if key == "scrollBarThick" or key == "scrollBarState" or key == "scrollBarOffset" or key == "scrollBarLength" then
						configScrollPane(element)
					end
				elseif dgsType == "dgs-dxswitchbutton" then
					if key == "state" then
						triggerEvent("onDgsSwitchButtonStateChange",element,value,oldValue)
					end
				elseif dgsType == "dgs-dxcombobox" then
					if key == "scrollBarThick" then
						assert(type(value) == "number","Bad argument 'dgsSetData' at 3,expect number got"..type(value))
						local scrollbar = dgsElementData[element].scrollbar
						configComboBox(element)
					elseif key == "listState" then
						triggerEvent("onDgsComboBoxStateChange",element,value == 1 and true or false)
					end
				elseif dgsType == "dgs-dxtabpanel" then
					if key == "selected" then
						local old,new = oldValue,value
						local tabs = dgsElementData[element].tabs
						triggerEvent("onDgsTabPanelTabSelect",element,new,old,tabs[new],tabs[old])
						if isElement(tabs[new]) then
							triggerEvent("onDgsTabSelect",tabs[new],new,old,tabs[new],tabs[old])
						end
					elseif key == "tabPadding" then
						local width = dgsElementData[element].absSize[1]
						local change = value[2] and value[1]*width or value[1]
						local old = oldValue[2] and oldValue[1]*width or oldValue[1]
						local tabs = dgsElementData[element].tabs
						dgsSetData(element,"tabLengthAll",dgsElementData[element].tabLengthAll+(change-old)*#tabs*2)
					elseif key == "tabGapSize" then
						local width = dgsElementData[element].absSize[1]
						local change = value[2] and value[1]*width or value[1]
						local old = oldValue[2] and oldValue[1]*width or oldValue[1]
						local tabs = dgsElementData[element].tabs
						dgsSetData(element,"tabLengthAll",dgsElementData[element].tabLengthAll+(change-old)*math.max((#tabs-1),1))
					end
				elseif dgsType == "dgs-dxtab" then
					if key == "text" then
						if type(value) == "table" then
							dgsElementData[element]._translationText = value
							value = dgsTranslate(element,value,sourceResource)
						else
							dgsElementData[element]._translationText = nil
						end
						local tabpanel = dgsElementData[element].parent
						local w = dgsElementData[tabpanel].absSize[1]
						local t_minWid = dgsElementData[tabpanel].tabMinWidth
						local t_maxWid = dgsElementData[tabpanel].tabMaxWidth
						local minwidth = t_minWid[2] and t_minWid[1]*w or t_minWid[1]
						local maxwidth = t_maxWid[2] and t_maxWid[1]*w or t_maxWid[1]
						dgsElementData[element].text = tostring(value)
						dgsSetData(element,"width",math.restrict(dxGetTextWidth(tostring(value),dgsElementData[element].textSize[1],dgsElementData[element].font or dgsElementData[tabpanel].font),minwidth,maxwidth))
						
						return triggerEvent("onDgsTextChange",element)
					elseif key == "width" then
						local tabpanel = dgsElementData[element].parent
						dgsSetData(tabpanel,"tabLengthAll",dgsElementData[tabpanel].tabLengthAll+(value-oldValue))
					end
				elseif dgsType == "dgs-dxedit" then
					if key == "text" then
						local txtSize = dgsElementData[element].textSize
						local success = handleDxEditText(element,value)
						return success
					elseif key == "textSize" then
						dgsElementData[element].textFontLen = dxGetTextWidth(dgsElementData[element].text,value[1],dgsElementData[element].font)
					elseif key == "font" then
						local txtSize = dgsElementData[element].textSize
						dgsElementData[element].textFontLen = dxGetTextWidth(dgsElementData[element].text,txtSize[1],dgsElementData[element].font)
					elseif key == "padding" then
						configEdit(element)
					end
				elseif dgsType == "dgs-dxmemo" then
					if key == "text" then
						return handleDxMemoText(element,value)
					elseif key == "scrollBarThick" then
						configMemo(element)
					elseif key == "textSize" then
						dgsMemoRebuildTextTable(element)
					elseif key == "font" then
						dgsMemoRebuildTextTable(element)
					elseif key == "wordWrap" then
						if value then
							dgsMemoRebuildWordWrapMapTable(element)
						end
					end
				elseif dgsType == "dgs-dxprogressbar" then
					if key == "progress" then
						triggerEvent("onDgsProgressBarChange",element,value,oldValue)
					end
				elseif dgsType == "dgs-dx3dinterface" then
					if key == "size" then
						local temprt = dgsElementData[element].renderTarget
						if isElement(temprt) then
							destroyElement(temprt)
						end
						local renderTarget = dxCreateRenderTarget(value[1],value[2],true)
						dgsSetData(element,"renderTarget",renderTarget)
					end
				elseif dgsType == "dgs-dximage" then
					if key == "UVSize" then
						local sx,sy,relative = value[1],value[2],value[3]
						if not sx and not sy then
							dgsElementData[element].renderBuffer.UVSize = {}
						else
							local texture = dgsElementData[element].image
							if isElement(texture) and getElementType(texture) ~= "shader" then
								local mx,my = dxGetMaterialSize(texture)
								local sx,sy = tonumber(sx),tonumber(sy)
								local sx,sy = relative and (sx or 1)*mx or (sx or mx),relative and (sy or 1)*my or (sy or my)
								dgsElementData[element].renderBuffer.UVSize = {sx,sy}
							end
						end
					elseif key == "UVPos" then
						local x,y,relative = value[1],value[2],value[3]
						if not x and not y then
							dgsElementData[element].renderBuffer.UVPos = {}
						else
							local texture = dgsElementData[element].image
							if isElement(texture) and getElementType(texture) ~= "shader" then
								local x,y,relative = value[1],value[2],value[3]
								local mx,my = dxGetMaterialSize(texture)
								local x,y = tonumber(x),tonumber(y)
								local x,y = relative and (x or 0)*mx or (x or mx),relative and (y or 0)*my or (y or my)
								dgsElementData[element].renderBuffer.UVPos = {x,y}
							end
						end
					elseif key == "image" then
						local imgType = dgsGetType(value)
						if isElement(value) and imgType ~= "shader" and imgType ~= "dgs-dxcustomrenderer" then
							local UVPos,UVSize = dgsElementData[element].UVPos or {0,0,true},dgsElementData[element].UVSize or {1,1,true}
							local x,y,relative = UVPos[1],UVPos[2],UVPos[3]
							local sx,sy,relative = UVSize[1],UVSize[2],UVSize[3]
							local mx,my = dxGetMaterialSize(value)
							local x,y = tonumber(x),tonumber(y)
							local sx,sy = tonumber(sx),tonumber(sy)
							local x,y = relative and (x or 0)*mx or (x or mx),relative and (y or 0)*my or (y or my)
							local sx,sy = relative and (sx or 1)*mx or (sx or mx),relative and (sy or 1)*my or (sy or my)
							dgsElementData[element].renderBuffer.UVPos = {x,y}
							dgsElementData[element].renderBuffer.UVSize = {sx,sy}
						end
					end
				end
				if key == "text" then
					if type(value) == "table" then
						dgsElementData[element]._translationText = value
						value = dgsTranslate(element,value,sourceResource)
					else
						dgsElementData[element]._translationText = nil
					end
					dgsElementData[element].text = tostring(value)
					triggerEvent("onDgsTextChange",element)
				elseif key == "caption" then
					if type(value) == "table" then
						dgsElementData[element]._translationText = value
						value = dgsTranslate(element,value,sourceResource)
					else
						dgsElementData[element]._translationText = nil
					end
					dgsElementData[element].caption = tostring(value)
				elseif key == "ignoreParentTitle" then
					configPosSize(element,false,true)
					if dgsType == "dgs-dxscrollpane" then
						configScrollPane(element)
					end
				elseif key == "ignoreTitle" then
					local children = dgsGetChildren(element)
					for i=1,#children do
						if not dgsElementData[children[i]].ignoreParentTitle then
							configPosSize(children[i],false,true)
							if dgsElementType[children[i]] == "dgs-dxscrollpane" then
								configScrollPane(children[i])
							end
						end
					end
				end
			end
		end
		return true
	end
	return false
end

compatibility = {
	["dgs-dxscrollbar"] = {
		image = "arrowImage/cursorImage/troughImage",
	},
	["dgs-dxswitchbutton"] = {
		textColor_t = "textColorOn",
		textColor_f = "textColorOff",
		image_t = "imageOn",
		image_f = "imageOff",
		textColor_t = "textColorOn",
		textColor_f = "textColorOff",
	},
	["dgs-dxcheckbox"] = {
		textImageSpace = "textPadding",
	},
	["dgs-dxradiobutton"] = {
		textImageSpace = "textPadding",
	}
}

function checkCompatibility(dxgui,key)
	local eleTyp = dgsGetType(dxgui)
	if compatibility[eleTyp] then
		for k,v in pairs(compatibility[eleTyp]) do
			if key == k then
				if not getElementData(localPlayer,"DGS-DEBUG-C") then
					outputDebugString("Deprecated property '"..k.."' @dgsSetProperty with "..eleTyp..", run it again with command /debugdgs c",2)
					return true
				else
					outputDebugString("Found deprecated property '"..k.."' @dgsSetProperty with "..eleTyp..", replace with "..v,2)
					return false
				end
			end
		end
	end
	return true
end

function dgsSetProperty(dxgui,key,value,...)
	local isTable = type(dxgui) == "table"
	assert(dgsIsDxElement(dxgui) or isTable,"Bad argument @dgsSetProperty at argument 1, expect a dgs-dxgui element/table got "..dgsGetType(dxgui))
	if isTable then
		if key == "functions" then
			local fnc = loadstring(value)
			assert(fnc,"Bad argument @dgsSetProperty at argument 2, failed to load function")
			value = {fnc,{...}}
		end
		for k,v in ipairs(dxgui) do
			assert(checkCompatibility(v,key),"DGS Compatibility Check")
			if key == "textColor" then
				assert(tonumber(value),"Bad argument @dgsSetProperty at argument 3, expect a number got "..type(value))
			elseif key == "text" then
				if dgsElementType[v] == "dgs-dxmemo" then
					return handleDxMemoText(v,value)
				elseif dgsElementType[v] == "dgs-dxedit" then
					return handleDxEditText(v,value)
				end
			elseif key == "absPos" then
				dgsSetPosition(v,value[1],value[2],false)
			elseif key == "rltPos" then
				dgsSetPosition(v,value[1],value[2],true)
			elseif key == "absSize" then
				dgsSetSize(v,value[1],value[2],false)
			elseif key == "rltSize" then
				dgsSetSize(v,value[1],value[2],true)
			end
			dgsSetData(v,tostring(key),value)
		end
		return true
	else
		assert(checkCompatibility(dxgui,key),"DGS Compatibility Check")
		if key == "functions" then
			if value then
				local fnc
				if type(value) == "function" then
					fnc = value
				else
					fnc = loadstring(value)
				end
				assert(fnc,"Bad argument @dgsSetProperty at argument 2, failed to load function")
				value = {fnc,{...}}
			end
		elseif key == "textColor" then
			assert(tonumber(value),"Bad argument @dgsSetProperty at argument 3, expect a number got "..type(value))
		elseif key == "text" then
			if dgsElementType[dxgui] == "dgs-dxmemo" then
				return handleDxMemoText(dxgui,value)
			elseif dgsElementType[dxgui] == "dgs-dxedit" then
				return handleDxEditText(dxgui,value)
			end
		elseif key == "absPos" then
			dgsSetPosition(dxgui,value[1],value[2],false)
		elseif key == "rltPos" then
			dgsSetPosition(dxgui,value[1],value[2],true)
		elseif key == "absSize" then
			dgsSetSize(dxgui,value[1],value[2],false)
		elseif key == "rltSize" then
			dgsSetSize(dxgui,value[1],value[2],true)
		end
		return dgsSetData(dxgui,tostring(key),value)
	end
end

function dgsGetProperty(dxgui,key)
	assert(dgsIsDxElement(dxgui),"Bad argument @dgsGetProperty at argument 1, expect a dgs-dxgui element got "..dgsGetType(dxgui))
	if not dgsElementData[dxgui] then return false end
	return dgsElementData[dxgui][key]
end

function dgsSetProperties(dxgui,theTable,additionArg)
	local isTable = type(dxgui) == "table"
	assert(dgsIsDxElement(dxgui) or isTable,"Bad argument @dgsSetProperties at argument 1, expect a dgs-dxgui element got "..dgsGetType(dxgui))
	assert(type(theTable)=="table","Bad argument @dgsSetProperties at argument 2, expect a table got "..type(theTable))
	assert((additionArg and type(additionArg)=="table") or additionArg == nil,"Bad argument @dgsSetProperties at argument 3, expect a table or nil/none got "..type(additionArg))
	if isTable then
		local success = true
		for k,v in ipairs(dxgui) do
			local dgsType = dgsElementType[v]
			for key,value in pairs(theTable) do
				local skip = false
				if key == "functions" and type(value) == "string" then
					value = {loadstring(value),additionArg.functions or {}}
				elseif key == "textColor" then
					if not tonumber(value) then
						assert(false,"Bad argument @dgsSetProperties at argument 2 with property 'textColor', expect a number got "..type(value))
					end
				elseif key == "text" then
					if dgsType == "dgs-dxtab" then
						local tabpanel = dgsElementData[v].parent
						local minW,maxW = dgsElementData[tabpanel].tabMinWidth,dgsElementData[tabpanel].tabMaxWidth
						local wid = math.restrict(dxGetTextWidth(value,dgsElementData[v].textSize[1],dgsElementData[v].font or dgsElementData[tabpanel].font),minW,maxW)
						local owid = dgsElementData[tab].width
						dgsSetData(tabpanel,"tabLengthAll",dgsElementData[tabpanel].tabLengthAll-owid+wid)
						dgsSetData(v,"width",wid)
					elseif dgsType == "dgs-dxmemo" then
						success = success and handleDxMemoText(v,value)
						skip = true
					elseif dgsType == "dgs-dxedit" then
						success = success and handleDxEditText(v,value)
						skip = true
					end
				elseif key == "absPos" then
					dgsSetPosition(v,value[1],value[2],false)
				elseif key == "rltPos" then
					dgsSetPosition(v,value[1],value[2],true)
				elseif key == "absSize" then
					dgsSetSize(v,value[1],value[2],false)
				elseif key == "rltSize" then
					dgsSetSize(v,value[1],value[2],true)
				end
				if not skip then
					success = success and dgsSetData(v,tostring(key),value)
				end
			end
		end
		return success
	else
		local success = true
		local dgsType = dgsElementType[dxgui]
		for key,value in pairs(theTable) do
			local skip = false
			if key == "functions" then
				value = {loadstring(value),additionArg.functions or {}}
			elseif key == "textColor" then
				if not tonumber(value) then
					assert(false,"Bad argument @dgsSetProperties at argument 2 with property 'textColor', expect a number got "..type(value))
				end
			elseif key == "text" then
				if dgsType == "dgs-dxtab" then
					local tabpanel = dgsElementData[dxgui].parent
					local minW,maxW = dgsElementData[tabpanel].tabMinWidth,dgsElementData[tabpanel].tabMaxWidth
					local wid = math.restrict(dxGetTextWidth(value,dgsElementData[dxgui].textSize[1],dgsElementData[dxgui].font or dgsElementData[tabpanel].font),minW,maxW)
					local owid = dgsElementData[tab].width
					dgsSetData(tabpanel,"tabLengthAll",dgsElementData[tabpanel].tabLengthAll-owid+wid)
					dgsSetData(dxgui,"width",wid)
				elseif dgsType == "dgs-dxmemo" then
					success = success and handleDxMemoText(dxgui,value)
					skip = true	
				elseif dgsType == "dgs-dxedit" then
					success = success and handleDxEditText(dxgui,value)
					skip = true
				end
			elseif key == "absPos" then
				dgsSetPosition(dxgui,value[1],value[2],false)
			elseif key == "rltPos" then
				dgsSetPosition(dxgui,value[1],value[2],true)
			elseif key == "absSize" then
				dgsSetSize(dxgui,value[1],value[2],false)
			elseif key == "rltSize" then
				dgsSetSize(dxgui,value[1],value[2],true)
			end
			if not skip then
				success = success and dgsSetData(dxgui,tostring(key),value)
			end
		end
		return success
	end
end

function dgsGetProperties(dxgui,properties)
	assert(dgsIsDxElement(dxgui),"Bad argument @dgsGetProperties at argument 1, expect a dgs-dxgui element got "..dgsGetType(dxgui))
	assert(not properties or type(properties) == "table","Bad argument @dgsGetProperties at argument 2, expect none or table got "..type(properties))
	if not dgsElementData[dxgui] then return false end
	if not properties then
		return dgsElementData[dxgui]
	else
		local data = {}
		for k,key in ipairs(properties) do
			data[key] = dgsElementData[dxgui][key]
		end
		return data
	end
end

function dgsSetPropertyInherit(dxgui,key,value,...)
	local isTable = type(dxgui) == "table"
	assert(dgsIsDxElement(dxgui) or isTable,"Bad argument @dgsSetPropertyInherit at argument 1, expect a dgs-dxgui element/table got "..dgsGetType(dxgui))
	if isTable then
		for k,v in ipairs(dxgui) do
			if key == "functions" then
				local fnc = loadstring(value)
				assert(fnc,"Bad argument @dgsSetPropertyInherit at argument 2, failed to load function")
				value = {fnc,{...}}
			elseif key == "textColor" then
				assert(tonumber(value),"Bad argument @dgsSetPropertyInherit at argument 3, expect a number got "..type(value))
			elseif key == "text" then
				if dgsElementType[v] == "dgs-dxmemo" then
					return handleDxMemoText(v,value)
				elseif dgsElementType[v] == "dgs-dxedit" then
					return handleDxEditText(v,value)
				end
			elseif key == "absPos" then
				dgsSetPosition(v,value[1],value[2],false)
			elseif key == "rltPos" then
				dgsSetPosition(v,value[1],value[2],true)
			elseif key == "absSize" then
				dgsSetSize(v,value[1],value[2],false)
			elseif key == "rltSize" then
				dgsSetSize(v,value[1],value[2],true)
			end
			dgsSetData(v,tostring(key),value)
			for index,child in ipairs(dgsGetChildren(v)) do
				dgsSetPropertyInherit(child,key,value,...)
			end
		end
		return true
	else
		if key == "functions" then
			local fnc = loadstring(value)
			assert(fnc,"Bad argument @dgsSetPropertyInherit at argument 2, failed to load function")
			value = {fnc,{...}}
		elseif key == "textColor" then
			assert(tonumber(value),"Bad argument @dgsSetPropertyInherit at argument 3, expect a number got "..type(value))
		elseif key == "text" then
			if dgsElementType[dxgui] == "dgs-dxmemo" then
				return handleDxMemoText(dxgui,value)
			elseif dgsElementType[dxgui] == "dgs-dxedit" then
				return handleDxEditText(dxgui,value)
			end
		elseif key == "absPos" then
			dgsSetPosition(dxgui,value[1],value[2],false)
		elseif key == "rltPos" then
			dgsSetPosition(dxgui,value[1],value[2],true)
		elseif key == "absSize" then
			dgsSetSize(dxgui,value[1],value[2],false)
		elseif key == "rltSize" then
			dgsSetSize(dxgui,value[1],value[2],true)
		end
		dgsSetData(dxgui,tostring(key),value)
		for index,child in ipairs(dgsGetChildren(dxgui)) do
			dgsSetPropertyInherit(child,key,value,...)
		end
	end
end
