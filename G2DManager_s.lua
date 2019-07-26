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
	{"-s","	","Start Convert"},
	{"-sel","Resource Name","Clear selections and select other resources (Support Pattern Match)"},
	{"-l","	","List all selected resources"},
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
					self.result[#self.result+1] = {self.buffer,token or singleCharType[self.buffer] or "undefined"}
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
		if ls.current == "\r" or ls.current == "\n" then
			--do nothing..
		elseif ls.current == "-" then 	--check operator or comment
			if ls:checknext("-") then	--comment
				ls:next()				--skip two -
				ls:next()
				if ls:checkcurrent("[") and ls:checknext("[") then	--long comment
					ls:next()	--skip 1 [ , anther one gives the reader as start
					readlongstring(ls,"long comment")
				else												--short comment
					repeat
						if ls:checkcurrent("\r\n") then break end
						ls:save()
					until(not ls:next())
					ls:finish("short comment")
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
					if not ls:checknext(isLetter,true) and not ls:checknext(isDigital) then break end
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
--[[
local file = fileOpen("client.lua")
local str = fileRead(file,fileGetSize(file))
fileClose(file)
local ls = LexState(str)
DGSLLex(ls)
local oFile = fileCreate("result.txt")
for k,v in ipairs(ls.result) do
	fileWrite(oFile,tostring(k),"	",v[1],"	",v[2],"\n")
end
fileClose(oFile)
]]