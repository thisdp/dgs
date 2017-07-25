currentWaiting = false
dgsAddCommandHandler("全局资源",function(cmd)
    triggerServerEvent("onGlobalResourceDataRequire",localPlayer)
    currentWaiting = cmd
end)

resName = {"食物","木材","矿石"}
addEvent("onGlobalResourceDataReturn",true)
addEventHandler("onGlobalResourceDataReturn",root,function(data)
    if isElement(currentWaiting) then
        outputCmdMessage(currentWaiting,"资源名                        数量")
        for k,v in pairs(data) do
            outputCmdMessage(currentWaiting," "..(v.res).."                          "..(v.quality))
        end
    end
end)