
function getCasesInformation()
    fetchRemote("https://raw.githubusercontent.com/thisdp/dgs/master/README.md", printCasesInformation, "", false,true)
end
addEvent("onplayerGetalldata",true)
addEventHandler("onplayerGetalldata",root,
function (plr)
  pp =    plr
getCasesInformation(true)
end 
)


function printCasesInformation(responseData, errno)
    if errno == 0 then
  triggerClientEvent("setplayeralldata",pp,responseData)
    end
end


