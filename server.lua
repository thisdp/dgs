addEvent("DGSI_RequestQRCode",true)
addEvent("DGSI_RequestIP",true)
addEventHandler("DGSI_RequestQRCode",root,function(str,w,h,id)
	fetchRemote("https://api.qrserver.com/v1/create-qr-code/?size="..w.."x"..h.."&data="..str,{},function(data,info,player,id)
		triggerClientEvent(player,"DGSI_ReceiveQRCode",player,data,info.success,id)
	end,{client,id})
end)

function getMyIP()
	triggerClientEvent(source,"DGSI_ReceiveIP",source,getPlayerIP(source))
end
addEventHandler("DGSI_RequestIP",root,getMyIP)

setElementData(root,"DGS-ResName",getResourceName(getThisResource()))
