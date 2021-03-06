local loadstring = loadstring
---Speed UP
local utf8Sub = utf8.sub
local utf8Find = utf8.find
local utf8Len = utf8.len
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

local EOF = ""

function isLetter(letter,isIdentifier)
	return (letter >= 'a' and letter <= 'z') or (letter >= 'A' and letter <= 'Z') or (isIdentifier and letter == '_') and true or false
end

local digital = {["0"]=0,["1"]=1,["2"]=2,["3"]=3,["4"]=4,["5"]=5,["6"]=6,["7"]=7,["8"]=8,["9"]=9}
local digitalHex = {A="A",B="B",C="C",D="D",E="E",F="F",a="a",b="b",c="c",d="d",e="e",f="f"}

local function isSpace(letter)
	return letter == " " or letter == "\t"
end

local function isDigital(letter,isHex)
	return digital[letter] or (isHex and digitalHex[letter]) or false
end

local transfer = {
	a = "\\a",
	b = "\\b",
	f = "\\f",
	n = "\\n",
	r = "\\r",
	t = "\\t",
	v = "\\v",
}

local function readstring(ls,terminal)
	ls:saveline()
	while(ls:next() ~= terminal) do
		if ls.current == EOF or ls.current == "\r" or ls.current == "\n" then
			ls:throw("unfinished short string")
			return false
		elseif ls.current == "\\" then
			ls:next()						--skip "\"
			if transfer[ls.current] then
				ls:save(transfer[ls.current])
			elseif ls.current == "\r" or ls.current == "\n" then
				if ls.current == "\r" then
					ls:save("\\r")
					ls:next()
				end
				if ls.current == "\n" then
					ls:save("\\n")
				end
			elseif ls.current == "\\" then
				ls:save("\\\\")
			elseif isDigital(ls.current) then
				local i = 1
				local c = ""
				repeat
					c = c..ls.current
				until(ls:next() and (not isDigital(ls.current) or i >= 3))
				if c > "255" then
					ls:throw("escape sequence too large")
					return false
				end
				ls.save(c:char())
			else
				ls:save("\\")
				ls:save()
			end
		else
			ls:save()
		end
	end
	ls:finish("short string")
	return true
end

local function readlongstring(ls,isComment)
	ls:saveline()
	while(ls:next()) do
		if ls.current == EOF then
			ls:throw("unfinished long string")
			return false
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
	return true
end

local function readnumber(ls)
	ls:saveline()
	local isHex
	if ls.current == "0" and ls:checksamenext("Xx") then
		ls:save()	--save 0
		ls:next()	--next
		ls:save()	--save x
		ls:next()	--next
		isHex = true
		if not isDigital(ls.current,isHex) then
			ls:throw("malformed number (1)")
			return false
		end
	end
	repeat
		if not isDigital(ls.current,isHex) then break end
		ls:save()
	until(not ls:next())
	if not isHex and ls:checkcurrent("Ee") then
		ls:save()
		ls:next()
		if ls:checkcurrent("+-") then
			ls:save()
			ls:next()
		end
	elseif ls:checkcurrent(".") then
		ls:save()
		ls:next()
	elseif not isLetter(ls.current) then
		ls:finish("number")
		return true
	end
	if not isDigital(ls.current,isHex) then
		ls:throw("malformed number (2)")
		return false
	end
	repeat
		ls:save()
		if not ls:checksamenext(isDigital,isHex) then break end
	until(not ls:next())
	if ls.current == "e" then
		ls:next()
		if isLetter(ls.current,true) or ls:checkcurrent(".") then
			ls:throw("malformed number (3) "..ls.current)
			return false
		end
		repeat
			ls:save()
			if not ls:checknext(isDigital,isHex) then break end
		until(not ls:next())
	elseif isLetter(ls.current,true) or ls:checkcurrent(".") then
		ls:throw("malformed number (3) "..ls.current)
		return false
	end
	ls:finish("number")
	return true
end

function createLuaLexer(luaVer,onThrow)
	if luaVer == "5.1" then
		return
		{
		initialized=false,
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
		textLength=0,
		readText=false,
		errorData = false,
		init=function(self,readText)
			self.buffer=""
			self.line=1
			self.prevLine=1
			self.prevIndex=0
			self.token=""
			self.index=0
			self.checkindex=0
			self.lineIndex=0
			self.current=""
			self.result={}
			self.textLength=utf8Len(readText)
			self.readText=readText
			self.errorData = false
			self.initialized = true
		end,
		next=function(self)
			self.index = self.index+1
			self.lineIndex = self.lineIndex+1
			self.current = utf8Sub(self.readText,self.index,self.index)
			if self.current == "\n" then
				self.line = self.line+1
				self.lineIndex=1
			end
			self.checkindex = self.index
			return self.current ~= EOF and self.current or false
		end,
		outputnext=function(self)
			return utf8Sub(self.readText,self.index+1,self.index+1)
		end,
		checknext=function(self,target,...)
			self.checkindex = self.checkindex+1
			local nextStr = utf8Sub(self.readText,self.checkindex,self.checkindex)
			local targetType = type(target)
			if targetType == "string" then
				local findResult = utf8Find(target,nextStr,1,true)
				return findResult and true or false
			elseif targetType == "function" then
				return target(nextStr,...)
			end
			return false
		end,
		checksamenext=function(self,target,...)
			local nextStr = utf8Sub(self.readText,self.checkindex+1,self.checkindex+1)
			local targetType = type(target)
			if targetType == "string" then
				local findResult = utf8Find(target,nextStr,1,true)
				return findResult and true or false
			elseif targetType == "function" then
				return target(nextStr,...)
			end
			return false
		end,
		checkcurrent=function(self,target,...)
			if self.current == EOF then return false end
			local targetType = type(target)
			if targetType == "string" then
				local findResult = utf8Find(target,self.current,1,true)
				return findResult and true or false
			elseif targetType == "function" then
				return target(self.current,...)
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
		end,
		throw=function(self,err)
			errorData = err
			if onThrow then
				onThrow(self.line,self.index,err)
			end
		end,
		start=function(ls)
			if not ls.initialized then throw("No script loaded") return false end
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
							if not readlongstring(ls,"long comment") then return false end
						else												--short comment
							if ls:checkcurrent("\r\n") then
								ls:finish("short comment")
							else
								local nnext
								repeat
									if ls:checknext("\r\n") then
										ls:save()
										break
									end
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
						if not readlongstring(ls) then return false end
					else
						ls:save()
						ls:finish("separator")
					end
				elseif ls.current == "'" or ls.current == '"' then
					if not readstring(ls,ls.current) then return false end
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
					if ls:checknext(".") then
						ls:save()
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
							if not readnumber(ls) then return false end
						else
							ls:save()
							ls:finish("operator")
						end
					end
				else
					if isSpace(ls.current) then
						ls:save()
						ls:finish("space")
					elseif isDigital(ls.current) then
						if not readnumber(ls) then return false end
					elseif isLetter(ls.current,true) then
						repeat
							ls:save()
							if (not ls:checksamenext(isLetter,true)) and (not ls:checksamenext(isDigital)) then break end
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
		end}
	else

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
