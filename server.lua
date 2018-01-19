function getMyIP()
	triggerClientEvent(source,"giveIPBack",source,getPlayerIP(source))
end
addEvent("getMyIP",true)
addEventHandler("getMyIP",root,getMyIP)
