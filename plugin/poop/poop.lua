function dgsCreatePoop(Type)
	local crap
	if Type == "noise" then
		crap = dxCreateShader("plugin/poop/poop.fx")
	end
	if isElement(crap) then
		dgsSetData(crap,"asPlugin","dgs-dxpoop")
		return crap
	end
	return false
end
