dgsExportedFunctionName = {}
dgsResName = getResourceName(getThisResource())
local metafile = xmlLoadFile("meta.xml")
local nodes = xmlNodeGetChildren(metafile)
for k,v in ipairs(nodes) do
	if xmlNodeGetName(v) == "export" then
		local func = xmlNodeGetAttribute(v,"function")
		local typ = xmlNodeGetAttribute(v,"type")
		if typ == "client" or typ == "shared" then
			dgsExportedFunctionName[func] = func
		end
	end
end

function dgsGetExportedFunctionName(name)
	if name then
		return dgsExportedFunctionName[name]
	else
		return dgsExportedFunctionName
	end
end

function dgsImportFunction(name,nameAs)
	if not name then
		local allCode = ""
		for k,v in pairs(dgsExportedFunctionName) do
			allCode = allCode.."\n "..k.." = exports."..dgsResName.."."..k..";"
		end
		return allCode
	else
		assert(dgsExportedFunctionName[name],"Bad Argument @dgsImportFunction at argument 1, the function is undefined")
		nameAs = nameAs or name
		return nameAs.." = exports."..dgsResName.."."..name..";"
	end
end