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
		local allCode = [[
		--Check Error Message Above

		if not dgsImportHead then
			local getResourceRootElement = getResourceRootElement
			local call = call
			local getResourceFromName = getResourceFromName
			local tostring = tostring
			local outputDebugString = outputDebugString
			local DGSCallMT = {}
			dgsImportHead = {}
			dgsImportHead.dgsName = "]]..dgsResName..[["
			dgsImportHead.dgsResource = getResourceFromName(dgsImportHead.dgsName)
			dgsRoot = getResourceRootElement(dgsImportHead.dgsResource)

			function DGSCallMT:__index(k)
				if type(k) ~= 'string' then k = tostring(k) end
				self[k] = function(...)
					assert(dgsImportHead,"DGS import data is missing or DGS is not running, please reimport dgs functions("..getResourceName(getThisResource())..")")
					if type(dgsImportHead.dgsResource) == 'userdata' and getResourceRootElement(dgsImportHead.dgsResource) then
						return call(dgsImportHead.dgsResource, k, ...)
					else
						dgsImportHead = nil
						return nil
					end
				end
				return self[k]
			end
			DGS = setmetatable({}, DGSCallMT)
			
			function unloadDGSFunction()
				
			end
		end
		]]
		for k,v in pairs(dgsExportedFunctionName) do
			allCode = allCode.."\n "..k.." = DGS."..k..";"
		end
		return allCode
	else
		assert(dgsExportedFunctionName[name],"Bad Argument @dgsImportFunction at argument 1, the function is undefined")
		nameAs = nameAs or name
		return nameAs.." = DGS."..name..";"
	end
end
