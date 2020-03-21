




       wind = dgs:dgsCreateWindow(430, 188, 722, 395, "DGS", false,tocolor(255,0,0),false,false,tocolor(0,0,255),false,tocolor(0,255,0))
    dgsWindowSetSizable(wind, false)
     dgsSetVisible(wind,false)

        button11 = dgsCreateButton(198, 330, 264, 42, "close", false,wind,tocolor(255,0,0),false,false,false,false,false,tocolor(0,0,255),tocolor(150,50,100))
       Memo22 = dgsCreateMemo(22, 45, 676, 272, "", false,wind,tocolor(50,255,50))    



       dgsSetAlpha(wind,0)





 addEvent("setplayeralldata",true)
 addEventHandler("setplayeralldata",root,
 function (Data)
    dgsSetText(Memo22,""..Data.."")
 end 
 )

 function open ()
    if dgsGetVisible(wind) == false then 
     dgsSetVisible(wind,true)
    dgsWindowSetSizable(wind, true)
  showCursor(true)
  dgsAlphaTo(wind,1,false,"Linear",2000)
  dgsMoveTo(wind,300,190,false,false,"Linear",2000)
  triggerServerEvent("onplayerGetalldata",localPlayer,localPlayer)
    else 
        dgsAlphaTo(wind,0,false,"Linear",2000)
      dgsMoveTo(wind,430,188,false,false,"Linear",2000)
        setTimer( function ()
           dgsSetVisible(wind,false)
           dgsWindowSetSizable(wind, false)
            showCursor(false)
            end,3000,1)
    end
end
addCommandHandler ("aboutdgs", open )



function onclik ()
    if source == button11 then
       dgsAlphaTo(wind,0,false,"Linear",2000)
        dgsMoveTo(wind,430,188,false,false,"Linear",2000)
        setTimer( function ()
            dgsSetVisible(wind,false)
            dgsWindowSetSizable(wind, false)
            showCursor(false)
            end,3000,1)
    end
end
addEventHandler("onDgsMouseClick",root, onclik )
