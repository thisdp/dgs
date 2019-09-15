G2DActivation = false
G2D = {}
G2D.backup = true
G2D.select = {}
addCommandHandler("dgs",function(player,command,arg)
	local account = getPlayerAccount(player)
	if account then
		local accn = getAccountName(account)
		if accn == "Console" then
			if arg == "g2d" then
				G2DActivation = not G2DActivation
				if G2DActivation then
					outputDebugString("[DGS-G2D] Initializing ...")
					outputDebugString("[DGS-G2D] Scanning Resources ...")
					outputDebugString("[DGS-G2D] Welcome To G2D ( GUI To DGS Command Line )")
				else
					outputDebugString("[DGS-G2D] Stopping ... ")
					outputDebugString("[DGS-G2D] Good Bye! Have a good time with scripts!")
				end
			end
		end
	end
end)

G2DHelp = {
	--Options,Extra,Argument,Comment
	{"-add","Resource Name","Retain selections and select other resources (Support Pattern Match)"},
	{"-bk","	","Toggle backup (Be careful)"},
	{"-c","	","Clear selections"},
	{"-h","	","G2D Help"},
	{"-sel","Resource Name","Clear selections and select other resources (Support Pattern Match)"},
	{"-l","	","List all selected resources"},
	{"-e","	","Start to convert"},
	{"-q","	","Stop converting process"},
}

function table.len(tab)
	local cnt = 0
	for k,v in pairs(tab) do
		cnt = cnt+1
	end
	return cnt
end

addCommandHandler("g2d",function(player,command,...)
	local account = getPlayerAccount(player)
	if account then
		local accn = getAccountName(account)
		if accn == "Console" then
			local args = {...}
			if args[1] == "-sel" then
				if args[2] and args[2] ~= "" then
					G2D.select = {}
					for k,v in ipairs(getResources()) do
						local resN = getResourceName(v)
						if string.match(resN,args[2]) then
							G2D.select[resN] = v
						end
					end
					outputDebugString("[DGS-G2D] Selected "..table.len(G2D.select).." resources, to see the selections, use -l")
				else
					outputDebugString("[DGS-G2D] Selected 0 resources, to see the selections, use -l")
				end
			elseif args[1] == "-add" then
				if args[2] and args[2] ~= "" then
					for k,v in ipairs(getResources()) do
						local resN = getResourceName(v)
						if string.match(resN,args[2]) then
							G2D.select[resN] = v
						end
					end
					outputDebugString("[DGS-G2D] Selected "..table.len(G2D.select).." resources, to see the selections, use -l")
				else
					outputDebugString("[DGS-G2D] Selected 0 resources, to see the selections, use -l")
				end
			elseif args[1] == "-l" then
				outputDebugString("[DGS-G2D] There are "..table.len(G2D.select).." resources selected:")
				for k,v in pairs(G2D.select) do
					outputDebugString(k)
				end
			elseif args[1] == "-c" then
				G2D.select = {}
				outputDebugString("[DGS-G2D] Selections cleared!")
			elseif args[1] == "-bk" then
				G2D.backup = not G2D.backup
				outputDebugString(G2D.backup and "[DGS-G2D] Backup is enabled" or "[DGS-G2D] Backup is disabled, all operations will be irreversible!")
			elseif args[1] == "-e" then
				if not G2D.Process then
					print("[DGS-G2D] Scanning files...")
					local process = {}
					for resN,res in pairs(G2D.select) do
						local xml = xmlLoadFile(":"..resN.."/meta.xml")
						for k,v in pairs(xmlNodeGetChildren(xml)) do
							if xmlNodeGetName(v) == "script" and xmlNodeGetAttribute(v,"type") == "client" then
								local path = xmlNodeGetAttribute(v,"src")
								table.insert(process,":"..resN.."/"..path)
							end
						end
					end
					print("[DGS-G2D] "..#process.." files to be converted")
					G2D.Process = true
					G2DStart(process)
				else
					print("[DGS-G2D] G2D is running!")
				end
			elseif args[1] == "-q" then
				if G2D.Process then
					
					print("[DGS-G2D] G2D process terminated!")
					G2D.Process = false
				else
					print("[DGS-G2D] G2D is not running!")
				end
			else
				outputDebugString("[DGS-G2D] Command help")
				outputDebugString("Option		Arguments		Comment")
				for i=1,#G2DHelp do
					local items = G2DHelp[i]
					outputDebugString(items[1].."		"..items[2].."		"..items[3])
				end
			end
		end
	end
end)

local keyword = {
	["and"] = 1,
	["break"] = 2,
	["do"] = 3,
	["else"] = 4,
	["elseif"] = 5,
	["end"] = 6,
	["false"] = 7,
	["for"] = 8,
	["function"] = 9,
	["if"] = 10,
	["in"] = 11,
	["local"] = 12,
	["nil"] = 13,
	["not"] = 14,
	["or"] = 15,
	["repeat"] = 16,
	["return"] = 17,
	["then"] = 18,
	["true"] = 19,
	["until"] = 20,
	["while"] = 21,
}

local singleCharType = {
	["+"]="operator",
	["-"]="operator",
	["*"]="operator",
	["/"]="operator",
	["%"]="operator",
	["^"]="operator",
	["#"]="operator",
	[":"]="operator",
	["\\"]="operator",
	[","]="separator",
	[";"]="separator",
	["["]="separator",
	["]"]="separator",
	["{"]="separator",
	["}"]="separator",
	["("]="separator",
	[")"]="separator",
}

local filter = {
	" ","\v","\t","\r","\n",
}

local FRI = {} --Filter Reverse Index

for i=1,#filter do
	FRI[filter[i]] = i
end

local function isLetter(letter,isIdentifier)
	return (letter >= 'a' and letter <= 'z') or (letter >= 'A' and letter <= 'Z') or (isIdentifier and letter == '_')
end

local digital = {}
local digitalHex = {A="A",B="B",C="C",D="D",E="E",F="F",a="a",b="b",c="c",d="d",e="e",f="f"}
for i=0,9 do
	digital[""..i..""]=i
end

local function isSpace(letter)
	return letter == " " or letter == "	"
end

local function isDigital(letter,isHex)
	if isHex then
		return digital[letter] or digitalHex[letter]
	else
		return digital[letter]
	end
end

local transfer = {
a = "\a",
b = "\b",
f = "\f",
n = "\n",
r = "\r",
t = "\t",
v = "\v",
}
LexState = {}

setmetatable(LexState,{
	__call = function(self,readText)
			return {
				buffer="",
				line=1,
				prevLine=1,
				prevIndex=0,
				token="",
				index=0,
				checkindex=0,
				lineIndex=0,
				current="",
				result={},
				textLength=#readText,
				readText=readText,
				next=function(self)
					self.index = self.index+1
					self.lineIndex = self.lineIndex+1
					self.current = self.readText:sub(self.index,self.index)
					if self.current == "\n" then
						self.line = self.line+1
						self.lineIndex=1
					end
					self.checkindex = self.index
					return self.current
				end,
				checknext=function(self,target,...)
					self.checkindex = self.checkindex+1
					local nextStr = self.readText:sub(self.checkindex,self.checkindex)
					local targetType = type(target)
					if targetType == "string" then
						for i=1,#target do
							if target:sub(i,i) == nextStr then
								return true
							end
						end
					elseif targetType == "function" then
						return target(nextStr,...)
					end
					return false
				end,
				checksamenext=function(self,target,...)
					local nextStr = self.readText:sub(self.checkindex,self.checkindex)
					local targetType = type(target)
					if targetType == "string" then
						for i=1,#target do
							if target:sub(i,i) == nextStr then
								return true
							end
						end
					elseif targetType == "function" then
						return target(nextStr,...)
					end
					return false
				end,
				checkcurrent=function(self,target)
					for i=1,#target do
						if target:sub(i,i) == self.current then
							return true
						end
					end
					return false
				end,
				save=function(self,c)
					self.buffer = self.buffer..(c or self.current)
				end,
				resetbuffer=function(self)
					self.buffer = ""
				end,
				saveline=function(self)
					self.prevIndex = self.lineIndex
					self.prevLine = self.line
				end,
				finish=function(self,token)
					self.prevIndex = self.index
					self.prevLine = self.line
					self.result[#self.result+1] = {self.buffer,token or singleCharType[self.buffer] or "undefined",self.line}
					self.buffer = ""
				end
			}
	end
})

local function throw(ls,err)
	assert(false,"[Line:"..ls.prevLine..",Index:"..ls.prevIndex.."]"..err)
end

local function readstring(ls,terminal)
	ls:saveline()
	while(ls:next() ~= terminal) do
		if ls.current == "" or ls.current == "\r" or ls.current == "\n" then
			throw(ls,"unfinished short string")
		elseif ls.current == "\\" then
			ls:next()						--skip "\"
			if transfer[ls.current] then
				ls:save(transfer[ls.current])
			elseif ls.current == "\r" or ls.current == "\n" then
				if ls.current == "\r" then
					ls:save()
					ls:next()
				end
				if ls.current == "\n" then
					ls:save()
				end
			elseif isDigital(ls.current) then
				local i = 1
				local c = ""
				repeat
					c = c..ls.current
				until(ls:next() and (not isDigital(ls.current) or i >= 3))
				if c > "255" then
					throw(ls,"escape sequence too large")
				end
				ls.save(c:char())
			else
				ls:save()
			end
		else
			ls:save()
		end
	end
	ls:finish("short string")
end

local function readlongstring(ls,isComment)
	ls:saveline()
	while(ls:next()) do
		if ls.current == "" then
			throw(ls,"unfinished long string")
		elseif ls.current == "]" then
			if ls:checknext("]") then
				ls:next()	--skip the second ]
				ls:finish(isComment or "long string")
				break
			else
				ls:save()
			end
		else
			ls:save()
		end
	end
end

local function readnumber(ls)
	ls:saveline()
	local isHex
	if ls.current == "0" and ls:checknext("Xx") then
		ls:save()	--save 0
		ls:next()	--next
		ls:save()	--save x
		ls:next()	--next
		isHex = true
		if not isDigital(ls.current,isHex) then
			throw(ls,"malformed number")
		end
	end
	repeat
		ls:save()
		if not ls:checknext(isDigital,isHex) then break end
	until(not ls:next())
	if not isHex and ls:checkcurrent("Ee") then
		ls:save()
		ls:next()
		if ls:checkcurrent("+-") then
			ls:save()
			ls:next()
		end
	elseif ls.current == "." then
		ls:save()
		ls:next()
	else
		ls:finish("number")
		return
	end
	if not isDigital(ls.current,isHex) then
		throw(ls,"malformed number")
	end
	repeat
		ls:save()
		if not ls:checknext(isDigital,isHex) then break end
	until(not ls:next())
	--until(ls:next() and not isDigital(ls.current,isHex))
	if not isLetter(ls.current,true) and ls.current ~= "." then
		throw(ls,"malformed number")
	end
	ls:finish("number")
end

local function DGSLLex(ls)
	ls:next()
	while(ls.index <= ls.textLength) do
		if ls.current == "\r" then
			ls:save()
			ls:finish("space")
		elseif ls.current == "\n" then
			ls:save()
			ls:finish("space")
		elseif ls.current == "\t" then
			ls:save()
			ls:finish("space")
		elseif ls.current == "-" then 	--check operator or comment
			if ls:checknext("-") then	--comment
				ls:next()				--skip two -
				ls:next()
				if ls:checkcurrent("[") and ls:checknext("[") then	--long comment
					ls:next()	--skip 1 [ , anther one gives the reader as start
					readlongstring(ls,"long comment")
				else												--short comment
					if ls:checkcurrent("\r\n") then
						ls:finish("short comment")
					else
						repeat
							if ls:checknext("\r\n") then ls:save() break end
							ls:save()
						until(not ls:next())
						ls:finish("short comment")
					end
				end
			else						--operator
				ls:save()
				ls:finish("operator")
			end
		elseif ls.current == "[" then
			if ls:checknext("[") then
				ls:next()	--skip 1 [
				readlongstring(ls)
			else
				ls:save()
				ls:finish("separator")
			end
		elseif ls.current == "'" or ls.current == '"' then
			readstring(ls,ls.current)
		elseif ls.current == "=" then
			ls:save()
			if ls:checknext("=") then
				ls:next()
				ls:save()
				ls:finish("operator")
			else
				ls:finish("operator")
			end
		elseif ls.current == "<" then
			ls:save()
			if ls:checknext("=") then
				ls:next()
				ls:save()
				ls:finish("operator")
			else
				ls:finish("operator")
			end
		elseif ls.current == ">" then
			ls:save()
			if ls:checknext("=") then
				ls:next()
				ls:save()
				ls:finish("operator")
			else
				ls:finish("operator")
			end
		elseif ls.current == "~" then
			ls:save()
			if ls:checknext("=") then
				ls:next()
				ls:save()
				ls:finish("operator")
			else
				ls:finish("operator")
			end
		elseif ls.current == "." then
			ls:save()
			if ls:checknext(".") then
				ls:next()
				ls:save()
				if ls:checknext(".") then
					ls:next()
					ls:save()
					ls:finish("operator")
				else
					ls:finish("operator")
				end
			else
				if ls:checknext(isDigital) then
					readnumber(ls)
				else
					ls:finish("operator")
				end
			end
		else
			if isSpace(ls.current) then
				ls:save()
				ls:finish("space")
			elseif isDigital(ls.current) then
				readnumber(ls)
			elseif isLetter(ls.current,true) then
				repeat
					ls:save()
					if (not ls:checknext(isLetter,true)) and (not ls:checksamenext(isDigital)) then break end
				until(not ls:next())
				if keyword[ls.buffer] then
					ls:finish("keyword")
				else
					ls:finish("identifier")
				end
			else
				ls:save()
				ls:finish()
			end
		end
		ls:next()
	end
end

OPRS = {"ADD","SUB","MUL","DIV","MOD","POW","CONCAT","LT","GT","NE","EQ","LE","GE","AND","OR","NOBINOPR","NOT","MINUS","LEN","NOUNOPR"}
OPR = {}
for i=1,#OPRS do
	OPR[OPRS[i]] = i
end

TKOPRTransf = {
["~"]=OPR.NOT,
["-"]=OPR.MINUS,
["#"]=OPR.LEN,
["+"]=OPR.ADD,
["-"]=OPR.SUB,
["*"]=OPR.MUL,
["/"]=OPR.DIV,
["%"]=OPR.MOD,
["^"]=OPR.POW,
[".."]=OPR.CONCAT,
["<"]=OPR.LT,
[">"]=OPR.GT,
["~="]=OPR.NE,
["=="]=OPR.EQ,
["<="]=OPR.LE,
[">="]=OPR.GE,
["and"]=OPR.AND,
["or"]=OPR.OR,
}

function getUNOPR(op)
	return TKOPRTransf[op] or OPR.NOUNOPR
end

function getBINOPR(op)
	return TKOPRTransf[op] or OPR.NOBINOPR
end

AnalyzerState = {}

setmetatable(AnalyzerState,{
	__call = function(self,lexResult)
			return {
				tokenIndex=0,
				separatorDepth = 0,
				blockDepth = 0,
				lexResult=lexResult,
				externalFunction = {},
				replacedFunction = {},
				replacedEvent = {},
				executeProcess = function(self)
					local GUIFnc = self.replacedFunction[1]
					local DGSFnc = self.replacedFunction[2]
					
					local GUIEvt = self.replacedEvent[1]
					local DGSEvt = self.replacedEvent[2]
					local resLen = #self.lexResult
					while(true) do
						local arguments = {}
						local argument = {}
						local item = self:getNext()
						if not item then break end
						if item[2] == "identifier" and GUIFnc then
							if item[1] == GUIFnc[1] then	-- matched, get into the process
								self.lexResult[self.tokenIndex][1] = DGSFnc[1]
								local enterArgs = false
								while(true) do
									local continue = false
									item = self:getNext()
									if not item then break end
									--if item[2] ~= "space" then
										if item[2] == "separator" then
											if item[1] == "(" then
												enterArgs = true
												self.separatorDepth = self.separatorDepth + 1
												if self.separatorDepth == 1 then
													continue = true
												end
											elseif item[1] == ")" then
												self.separatorDepth = self.separatorDepth - 1
												if self.separatorDepth == 0 then
													table.insert(arguments,argument)
													argument = {}
													continue = true
												end
											elseif self.separatorDepth == 1 and item[1] == "," then
												table.insert(arguments,argument)
												argument = {}
												continue = true
											end
										end
										if self.separatorDepth == 0 and enterArgs then
											break
										end
									--end
									if self.separatorDepth >= 1 and not continue and enterArgs then
										table.insert(argument,self.tokenIndex)
									end
								end
							end
						elseif item[2] == "short string" and DGSEvt then
							if item[1] == GUIEvt[1] then
								self.lexResult[self.tokenIndex][1] = DGSEvt[1]
							end
						end
					end
				end,
				getNext = function(self,dontSkipSpace)
					self.tokenIndex = self.tokenIndex+1
					if self.lexResult[self.tokenIndex][2] == "space" and not dontSkipSpace then
						return self:getNext()
					end
					return self.lexResult[self.tokenIndex]
				end,
				getCurrent = function(self)
					return self.lexResult[self.tokenIndex]
				end,
				removeCurrent = function(self)
					table.remove(self.lexResult,self.tokenIndex)
					return self.tokenIndex
				end,
				insertCurrent = function(self,insert)
					table.insert(self.lexResult,self.tokenIndex,insert)
				end,
				set = function(self,repFnc)
					self.replacedFunction = repFnc
					self.tokenIndex=0
					self.separatorDepth = 0
				end,
				generateFile = function(self)
					local file = fileCreate("tmp.txt")
					local newtab = {}
					local isDGSDef = false
					for i=1,#self.lexResult do
						if self.lexResult[i][2] == "short comment" then
							newtab[i] = "--"..self.lexResult[i][1]
						elseif self.lexResult[i][2] == "long comment" then
							newtab[i] = "--[["..self.lexResult[i][1].."]]"
						elseif self.lexResult[i][2] == "short string" then 
							newtab[i] = "\""..self.lexResult[i][1].."\""
						elseif self.lexResult[i][2] == "long string" then
							newtab[i] = "[["..self.lexResult[i][1].."]]"
						else
							if newtab[i][1] == "__DGSDef" then
								isDGSDef = true
							end
							newtab[i] = self.lexResult[i][1]
						end
					end
					if not isDGSDef then
						table.insert(newtab,Hooker)
					end
					fileWrite(file,table.concat(newtab))
					fileClose(file)
				end,
			}
	end
})

convertFunctionTable = {
	{{"guiBringToFront"},{"dgsBringToFront"}},
	{{"guiCreateFont"},{"dgsCreateFont"}},
	{{"guiBlur"},{"dgsBlur"}},
	{{"guiFocus"},{"dgsFocus"}},
	{{"guiGetAlpha"},{"dgsGetAlpha"}},
	{{"guiGetEnabled"},{"dgsGetEnabled"}},
	{{"guiGetFont"},{"dgsGetFont"}},
	{{"guiGetInputEnabled"},{"dgsGetInputEnabled"}},
	{{"guiGetInputMode"},{"dgsGetInputMode"}},
	{{"guiGetPosition"},{"dgsGetPosition"}},
	{{"guiGetProperties"},{"dgsGetProperties"}},
	{{"guiGetProperty"},{"dgsGetProperty"}},
	{{"guiGetScreenSize"},{"dgsGetScreenSize"}},
	{{"guiGetSize"},{"dgsGetSize"}},
	{{"guiGetText"},{"dgsGetText"}},
	{{"guiGetVisible"},{"dgsGetVisible"}},
	{{"guiMoveToBack"},{"dgsMoveToBack"}},
	{{"guiSetAlpha"},{"dgsSetAlpha"}},
	{{"guiSetEnabled"},{"dgsSetEnabled"}},
	{{"guiSetFont"},{"dgsSetFont"}},
	{{"guiSetInputEnabled"},{"dgsSetInputEnabled"}},
	{{"guiSetInputMode"},{"dgsSetInputMode"}},
	{{"guiSetPosition"},{"dgsSetPosition"}},
	{{"guiSetProperty"},{"dgsSetProperty"}},
	{{"guiSetSize"},{"dgsSetSize"}},
	{{"guiSetText"},{"dgsSetText"}},
	{{"guiSetVisible"},{"dgsSetVisible"}},
	{{"guiCreateBrowser"},{"dgsCreateBrowser"}},
	{{"guiCreateButton"},{"dgsCreateButton"}},
	{{"guiCheckBoxGetSelected"},{"dgsCheckBoxGetSelected"}},
	{{"guiCheckBoxSetSelected"},{"dgsCheckBoxSetSelected"}},
	{{"guiCreateCheckBox"},{"dgsCreateCheckBox"}},
	{{"guiCreateComboBox"},{"dgsCreateComboBox"}},
	{{"guiComboBoxAddItem"},{"dgsComboBoxAddItem"}},
	{{"guiComboBoxClear"},{"dgsComboBoxClear"}},
	{{"guiComboBoxGetItemCount"},{"dgsComboBoxGetItemCount"}},
	{{"guiComboBoxGetItemText"},{"dgsComboBoxGetItemText"}},
	{{"guiComboBoxGetSelected"},{"dgsComboBoxGetSelected"}},
	{{"guiComboBoxIsOpen"},{"dgsComboBoxGetState"}},
	{{"guiComboBoxRemoveItem"},{"dgsComboBoxRemoveItem"}},
	{{"guiComboBoxSetItemText"},{"dgsComboBoxSetItemText"}},
	{{"guiComboBoxSetOpen"},{"dgsComboBoxSetState"}},
	{{"guiComboBoxSetSelected"},{"dgsComboBoxSetSelected"}},
	{{"guiCreateEdit"},{"dgsCreateEdit"}},
	{{"guiEditGetCaretIndex"},{"dgsEditGetCaretPosition"}},
	{{"guiEditGetMaxLength"},{"dgsEditGetMaxLength"}},
	{{"guiEditIsMasked"},{"dgsEditGetMasked"}},
	{{"guiEditIsReadOnly"},{"dgsEditGetReadOnly"}},
	{{"guiEditSetCaretIndex"},{"dgsEditSetCaretPosition"}},
	{{"guiEditSetMasked"},{"dgsEditSetMasked"}},
	{{"guiEditSetMaxLength"},{"dgsEditSetMaxLength"}},
	{{"guiEditSetReadOnly"},{"dgsEditSetReadOnly"}},
	{{"guiCreateGridList"},{"dgsCreateGridList"}},
	{{"guiGridListAddColumn"},{"dgsGridListAddColumn"}},
	{{"guiGridListAddRow"},{"dgsGridListAddRow"}},
	{{"guiGridListAutoSizeColumn"},{"dgsGridListAutoSizeColumn"}},
	{{"guiGridListClear"},{"dgsGridListClear"}},
	{{"guiGridListGetColumnCount"},{"dgsGridListGetColumnCount"}},
	{{"guiGridListGetColumnTitle"},{"dgsGridListGetColumnTitle"}},
	{{"guiGridListGetColumnWidth"},{"dgsGridListGetColumnWidth"}},
	{{"guiGridListGetItemColor"},{"dgsGridListGetItemColor"}},
	{{"guiGridListGetItemData"},{"dgsGridListGetItemData"}},
	{{"guiGridListGetItemText"},{"dgsGridListGetItemText"}},
	{{"guiGridListGetRowCount"},{"dgsGridListGetRowCount"}},
	{{"guiGridListGetSelectedCount"},{"dgsGridListGetSelectedCount"}},
	{{"guiGridListGetSelectedItem"},{"dgsGridListGetSelectedItem"}},
	{{"guiGridListGetSelectedItems"},{"dgsGridListGetSelectedItems"}},
	{{"guiGridListGetSelectionMode"},{"dgsGridListGetSelectionMode"}},
	{{"guiGridListIsSortingEnabled"},{"dgsGridListGetSortEnabled"}},
	{{"guiGridListRemoveColumn"},{"dgsGridListRemoveColumn"}},
	{{"guiGridListRemoveRow"},{"dgsGridListRemoveRow"}},
	{{"guiGridListSetColumnTitle"},{"dgsGridListSetColumnTitle"}},
	{{"guiGridListSetColumnWidth"},{"dgsGridListSetColumnWidth"}},
	{{"guiGridListSetItemColor"},{"dgsGridListSetItemColor"}},
	{{"guiGridListSetItemData"},{"dgsGridListSetItemData"}},
	{{"guiGridListSetItemText"},{"dgsGridListSetItemText"}},
	{{"guiGridListSetScrollBars"},{"dgsGridListSetScrollBarState"}},
	{{"guiGridListSetSelectedItem"},{"dgsGridListSetSelectedItem"}},
	{{"guiGridListSetSelectionMode"},{"dgsGridListSetSelectionMode"}},
	{{"guiGridListSetSortingEnabled"},{"dgsGridListSetSortEnabled"}},
	{{"guiCreateMemo"},{"dgsCreateMemo"}},
	{{"guiMemoGetCaretIndex"},{"dgsMemoGetCaretIndex"}},
	{{"guiMemoIsReadOnly"},{"dgsMemoIsReadOnly"}},
	{{"guiMemoSetCaretIndex"},{"dgsMemoSetCaretIndex"}},
	{{"guiMemoSetReadOnly"},{"dgsMemoSetReadOnly"}},
	{{"guiCreateProgressBar"},{"dgsCreateProgressBar"}},
	{{"guiProgressBarGetProgress"},{"dgsProgressBarGetProgress"}},
	{{"guiProgressBarSetProgress"},{"dgsProgressBarSetProgress"}},
	{{"guiCreateRadioButton"},{"dgsCreateRadioButton"}},
	{{"guiRadioButtonGetSelected"},{"dgsRadioButtonGetSelected"}},
	{{"guiRadioButtonSetSelected"},{"dgsRadioButtonSetSelected"}},
	{{"guiCreateScrollBar"},{"dgsCreateScrollBar"}},
	{{"guiScrollBarGetScrollPosition"},{"dgsScrollBarGetScrollPosition"}},
	{{"guiScrollBarSetScrollPosition"},{"dgsScrollBarSetScrollPosition"}},
	{{"guiCreateScrollPane"},{"dgsCreateScrollPane"}},
	{{"guiScrollPaneSetScrollBars"},{"dgsScrollPaneSetScrollBarState"}},
	{{"guiCreateStaticImage"},{"dgsCreateImage"}},
	{{"guiStaticImageGetNativeSize"},{"dgsImageGetNativeSize"}},
	{{"guiStaticImageLoadImage"},{"dgsImageSetImage"}},
	{{"guiCreateTabPanel"},{"dgsCreateTabPanel"}},
	{{"guiGetSelectedTab"},{"dgsGetSelectedTab"}},
	{{"guiSetSelectedTab"},{"dgsSetSelectedTab"}},
	{{"guiCreateTab"},{"dgsCreateTab"}},
	{{"guiDeleteTab"},{"dgsDeleteTab"}},
	{{"guiCreateLabel"},{"dgsCreateLabel"}},
	{{"guiLabelGetColor"},{"dgsLabelGetColor"}},
	{{"guiLabelGetFontHeight"},{"dgsLabelGetFontHeight"}},
	{{"guiLabelGetTextExtent"},{"dgsLabelGetTextExtent"}},
	{{"guiLabelSetColor"},{"dgsLabelSetColor"}},
	{{"guiLabelSetHorizontalAlign"},{"dgsLabelSetHorizontalAlign"}},
	{{"guiLabelSetVerticalAlign"},{"dgsLabelSetVerticalAlign"}},
	{{"guiCreateWindow"},{"dgsCreateWindow"}},
	{{"guiWindowIsMovable"},{"dgsWindowGetMovable"}},
	{{"guiWindowIsSizable"},{"dgsWindowGetSizable"}},
	{{"guiWindowSetMovable"},{"dgsWindowSetMovable"}},
	{{"guiWindowSetSizable"},{"dgsWindowSetSizable"}},
	{{"guiGridListGetHorizontalScrollPosition"},{"dgsGridListGetHorizontalScrollPosition"}},
	{{"guiGridListSetHorizontalScrollPosition"},{"dgsGridListSetHorizontalScrollPosition"}},
	{{"guiGridListGetVerticalScrollPosition"},{"dgsGridListGetVerticalScrollPosition"}},
	{{"guiGridListSetVerticalScrollPosition"},{"dgsGridListSetVerticalScrollPosition"}},
	{{"guiMemoGetVerticalScrollPosition"},{"dgsMemoGetVerticalScrollPosition"}},
	{{"guiMemoSetVerticalScrollPosition"},{"dgsMemoSetVerticalScrollPosition"}},
	{{"guiScrollPaneGetHorizontalScrollPosition"},{"dgsScrollPaneGetHorizontalScrollPosition"}},
	{{"guiScrollPaneGetVerticalScrollPosition"},{"dgsScrollPaneGetVerticalScrollPosition"}},
	{{"guiScrollPaneSetHorizontalScrollPosition"},{"dgsScrollPaneSetHorizontalScrollPosition"}},
	{{"guiScrollPaneSetVerticalScrollPosition"},{"dgsScrollPaneSetVerticalScrollPosition"}},
	{{"guiGridListInsertRowAfter"},{"dgsGridListInsertRowAfter"}},
	{{"guiGetBrowser"},{"dgsGetBrowser"}},
}

Hooker = [[
--G2D Converted
if not __DGSDef then
	addEvent("onDgsEditAccepted-C",true)
	addEvent("onDgsTextChange-C",true)
	addEvent("onDgsComboBoxSelect-C",true)
	addEvent("onDgsTabSelect-C",true)
	function fncTrans(...)
		triggerEvent(eventName.."-C",source,source,...)
	end
	addEventHandler("onDgsEditAccepted",root,fncTrans)
	addEventHandler("onDgsTextChange",root,fncTrans)
	addEventHandler("onDgsComboBoxSelect",root,fncTrans)
	addEventHandler("onDgsTabSelect",root,fncTrans)
	loadstring(exports.dgs:dgsImportFunction())()
	__DGSDef = true
end
]]

converEventTable = {
	{{"onClientGUIAccepted",			},{"onDgsEditAccepted-C"}},
	{{"onClientGUIBlur",				},{"onDgsBlur"}},
	{{"onClientGUIChanged",				},{"onDgsTextChange-C"}},
	{{"onClientGUIClick",				},{"onDgsMouseClickUp"}},
	{{"onClientGUIComboBoxAccepted",	},{"onDgsComboBoxSelect-C"}},
	{{"onClientGUIDoubleClick",			},{"onDgsMouseDoubleClick"}},
	{{"onClientGUIFocus",				},{"onDgsFocus"}},
	{{"onClientGUIMouseDown",			},{"onDgsMouseDown"}},
	{{"onClientGUIMouseUp",				},{"onDgsMouseUp"}},
	{{"onClientGUIMove",				},{"onDgsElementMove"}},
	{{"onClientGUIScroll",				},{"onDgsElementScroll"}},
	{{"onClientGUISize",				},{"onDgsElementSize"}},
	{{"onClientGUITabSwitched",			},{"onDgsTabSelect-C"}},
	{{"onClientMouseEnter",				},{"onDgsMouseEnter"}},
	{{"onClientMouseLeave",				},{"onDgsMouseLeave"}},
	{{"onClientMouseMove",				},{"onDgsMouseMove"}},
	{{"onClientMouseWheel",				},{"onDgsMouseWheel"}},
}


function showProgress(progress)
	print("[G2D]Progress "..string.format("%.2f",progress).."%")
end

G2DRunningData = {
	File=false,
	Timer= false
}

function G2DStart(fileNames)
	print("[G2D] Start coroutine")
	local cor = coroutine.create(processFile)
	print(coroutine.resume(cor,cor,fileNames))
	
end

function processFile(cor,files,index)
	local k,filename = next(files,index)
	if not k then return print("[G2D] Process Complete") end
	print("[G2D] Starting to process file '"..filename.."'")
	local file = fileOpen(filename)
	local str = fileRead(file,fileGetSize(file))
	fileClose(file)
	local ls = LexState(str)
	DGSLLex(ls)
	local az = AnalyzerState(ls.result)
	local convTabCnt = #convertFunctionTable
	local tick = getTickCount()
	for i=1,convTabCnt do
		az:set(convertFunctionTable[i])
		az:executeProcess()
		if getTickCount()-tick >= 95 then
			showProgress((i-1)/convTabCnt*100)
			setTimer(function(cor)
				coroutine.resume(cor)
			end,25,1,cor)
			coroutine.yield(filename)
		end
	end
	showProgress(100)
	print("[G2D] Generating file...")
	az:generateFile()
	print("[G2D] Saved to file")
	return processFile(cor,files,k)
end
