function dgsCreateBrowser(x,y,sx,sy,relative,parent,isLocal,transparent,browserw,browserh,color)
	assert(type(x) == "number","Bad argument @dgsCreateBrowser at argument 1, expect number got "..type(x))
	assert(type(y) == "number","Bad argument @dgsCreateBrowser at argument 2, expect number got "..type(y))
	assert(type(sx) == "number","Bad argument @dgsCreateBrowser at argument 3, expect number got "..type(sx))
	assert(type(sy) == "number","Bad argument @dgsCreateBrowser at argument 4, expect number got "..type(sy))
	local browser = createBrowser(1,1,isLocal and true or false,transparent and true or false)
	assert(isElement(browser),"Bad argument @dgsCreateBrowser, can't create browser with 'createBrowser' !")
	dgsSetType(browser,"dgs-dxbrowser")
	dgsSetParent(browser,parent,true,true)
	dgsSetData(browser,"renderBuffer",{})
	dgsSetData(browser,"color",color or tocolor(255,255,255,255))
	dgsSetData(browser,"transparent",transparent and true or false)
	dgsSetData(browser,"isLocal",isLocal or false)
	dgsSetData(browser,"requestCommand",{})
	calculateGuiPositionSize(browser,x,y,relative,sx,sy,relative,true)
	local size = dgsElementData[browser].absSize
	resizeBrowser(browser,browserw or size[1],browserh or size[2])
	dgsSetData(browser,"browserSize",{browserw or size[1],browserh or size[2]})
	triggerEvent("onDgsCreate",browser,sourceResource)
	addEventHandler("onDgsMouseMove",browser,function(x,y)
		local size = dgsElementData[source].absSize
		local brosize = dgsElementData[source].browserSize
		local startX,startY = dgsGetPosition(source,false,true)
		injectBrowserMouseMove(source,(x-startX)/size[1]*brosize[1],(y-startY)/size[2]*brosize[2])
	end,false)
	addEventHandler("onDgsMouseWheel",browser,function(upOrDown)
		injectBrowserMouseWheel(source,upOrDown*40,0)
	end,false)
	addEventHandler("onDgsMouseClick",browser,function(button,state)
		focusBrowser(source)
		if state == "down" then
			injectBrowserMouseDown(source, button)
		else
			injectBrowserMouseUp(source, button)
		end
	end,false)
	return browser
end

----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxbrowser"] = function(source,x,y,w,h,mx,my,cx,cy,enabled,eleData,parentAlpha,isPostGUI,rndtgt)
	local color = applyColorAlpha(eleData.color,parentAlpha)
	dxDrawImage(x,y,w,h,source,0,0,0,color,isPostGUI)
	return rndtgt
end