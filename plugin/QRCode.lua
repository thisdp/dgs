dgsLogLuaMemory()
dgsRegisterPluginType("dgs-dxqrcode")
QRCodeQueue = {}
function dgsRequestQRCode(str,w,h)
	local w,h = w or 128,h or 128
	local encodedStr = urlEncode(str)
	local QRCode = dxCreateEmptyTexture(w,h,sourceResource)
	dgsSetData(QRCode,"asPlugin","dgs-dxqrcode")
	dgsSetData(QRCode,"data",{str,encodedStr})
	dgsSetData(QRCode,"loaded",false)
	local index = math.seekEmpty(QRCodeQueue)
	QRCodeQueue[index] = QRCode
	triggerServerEvent("DGSI_RequestQRCode",resourceRoot,encodedStr,w,h,index)
	dgsTriggerEvent("onDgsPluginCreate",QRCode,sourceResource)
	return QRCode
end

function dgsGetQRCodeLoaded(QRCode)
	if not(dgsGetPluginType(QRCode) == "dgs-dxqrcode") then error(dgsGenAsrt(QRCode,"dgsGetQRCodeLoaded",1,"dgs-dxqrcode")) end
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
	dgsTriggerEvent("onDgsQRCodeLoad",QRCode,isSuccess)
end)