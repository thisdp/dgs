QRCodeQueue = {}
function dgsRequestQRCode(str,w,h)
	local w,h = w or 128,h or 128
	local encodedStr = urlEncode(str)
	local QRCode = dxCreateTexture(w,h,"argb")
	dgsSetData(QRCode,"asPlugin","dgs-dxqrcode")
	dgsSetData(QRCode,"data",{str,encodedStr})
	dgsSetData(QRCode,"loaded",false)
	local index = math.seekEmpty(QRCodeQueue)
	QRCodeQueue[index] = QRCode
	triggerServerEvent("DGSI_RequestQRCode",resourceRoot,encodedStr,w,h,index)
	triggerEvent("onDgsPluginCreate",QRCode,sourceResource)
	return QRCode
end

function dgsGetQRCodeLoaded(QRCode)
	assert(dgsGetPluginType(QRCode) == "dgs-dxqrcode","Bad argument @dgsGetQRCodeLoaded at argument 1, expect dgs-dxqrcode "..dgsGetPluginType(QRCode))
	return dgsElementData[QRCode].loaded
end

addEventHandler("DGSI_ReceiveQRCode",resourceRoot,function(data,isSuccess,index)
	local QRCode = QRCodeQueue[index]
	QRCodeQueue[index] = nil
	if isSuccess and isElement(QRCode) then
		local tmp = dxCreateTexture(data)
		local pixels = dxGetTexturePixels(tmp)
		destroyElement(tmp)
		dxSetTexturePixels(QRCode,pixels)
		dgsSetData(QRCode,"loaded",true)
	end
	triggerEvent("onDgsQRCodeLoad",QRCode,isSuccess)
end)