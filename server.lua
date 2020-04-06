addEvent("DGSI_RequestQRCode",true)
addEvent("DGSI_RequestIP",true)
addEvent("DGSI_RequestRemoteImage",true)
addEvent("DGSI_RequestAboutData",true)
addEventHandler("DGSI_RequestQRCode",root,function(str,w,h,id)
	fetchRemote("https://api.qrserver.com/v1/create-qr-code/?size="..w.."x"..h.."&data="..str,{},function(data,info,player,id)
		triggerClientEvent(player,"DGSI_ReceiveQRCode",player,data,info.success,id)
	end,{client,id})
end)

addEventHandler("DGSI_RequestRemoteImage",root,function(website,id)
	fetchRemote(website,{},function(data,info,player,id)
		triggerClientEvent(player,"DGSI_ReceiveRemoteImage",player,data,info,id)
	end,{client,id})
end)

function getMyIP()
	triggerClientEvent(source,"DGSI_ReceiveIP",source,getPlayerIP(source))
end
addEventHandler("DGSI_RequestIP",root,getMyIP)

setElementData(root,"DGS-ResName",getResourceName(getThisResource()))

-----------About DGS
addEventHandler("DGSI_RequestAboutData",root,function(player)
    fetchRemote("https://raw.githubusercontent.com/thisdp/dgs/master/README.md",{},function(data,info,player)
		triggerClientEvent(player,"DGSI_SendAboutData",player,data)
	end,{player})
end)