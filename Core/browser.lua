dgsLogLuaMemory()
dgsRegisterType("dgs-dxbrowser","dgsBasic","dgsType2D")
dgsRegisterProperties("dgs-dxbrowser",{
	color = 				{	PArg.Color		},
	isTransparent = 		{	PArg.Bool		},
	isLocal = 				{	PArg.Bool		},
})
--Dx Functions
local dxDrawImage = dxDrawImage
--DGS Functions
local dgsSetType = dgsSetType
local dgsSetParent = dgsSetParent
local dgsGetPosition = dgsGetPosition
local calculateGuiPositionSize = calculateGuiPositionSize
local applyColorAlpha = applyColorAlpha
--Browser Functions
local injectBrowserMouseMove = injectBrowserMouseMove
local injectBrowserMouseDown = injectBrowserMouseDown
local injectBrowserMouseUp = injectBrowserMouseUp
local resizeBrowser = resizeBrowser
local createBrowser = createBrowser
local focusBrowser = focusBrowser
--Utilities
local isElement = isElement
local addEventHandler = addEventHandler
local assert = assert
local type = type

DGSI_RegisterMaterialType("dgs-dxbrowser","texture")

function dgsCreateBrowser(...)
	local sRes = sourceResource or resource
	local x,y,w,h,relative,parent,isLocal,isTransparent,resX,resY,color
	if select("#",...) == 1 and type(select(1,...)) == "table" then
		local argTable = ...
		x = argTable.x or argTable[1]
		y = argTable.y or argTable[2]
		w = argTable.width or argTable.w or argTable[3]
		h = argTable.height or argTable.h or argTable[4]
		relative = argTable.relative or argTable.relative or argTable[5]
		parent = argTable.parent or argTable.p or argTable[6]
		isLocal = argTable.isLocal or argTable[7]
		isTransparent = argTable.isTransparent or argTable[8]
		resX = argTable.resolutionX or argTable.resX or argTable[9]
		resY = argTable.resolutionY or argTable.resY or argTable[10]
		color = argTable.color or argTable[11]
	else
		x,y,w,h,relative,parent,isLocal,isTransparent,resX,resY,color = ...
	end
	if not(type(x) == "number") then error(dgsGenAsrt(x,"dgsCreateBrowser",1,"number")) end
	if not(type(y) == "number") then error(dgsGenAsrt(y,"dgsCreateBrowser",2,"number")) end
	if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsCreateBrowser",3,"number")) end
	if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsCreateBrowser",4,"number")) end
	local browser = createBrowser(1,1,isLocal and true or false,isTransparent and true or false)
	if not isElement(browser) then error(dgsGenAsrt(browser,"dgsCreateBrowser",_,_,_,_,"Failed to create remote browser (createBrowser returns false)!")) end
	dgsSetType(browser,"dgs-dxbrowser")
	dgsElementData[browser] = {
		renderBuffer = {},
		color = color or white,
		isTransparent = isTransparent and true or false,
		isLocal = isLocal and true or false,
		requestCommand = {},
	}
	dgsSetParent(browser,parent,true,true)
	calculateGuiPositionSize(browser,x,y,relative,w,h,relative,true)
	local size = dgsElementData[browser].absSize
	resizeBrowser(browser,resX or size[1],resY or size[2])
	dgsElementData[browser].browserSize = {resX or size[1],resY or size[2]}
	onDGSElementCreate(browser,sRes)
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
dgsRenderer["dgs-dxbrowser"] = function(source,x,y,w,h,mx,my,cx,cy,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt)
	if MouseData.hit == source and MouseData.focused == source then
		MouseData.topScrollable = source
	end
	local color = applyColorAlpha(eleData.color,parentAlpha)
	dxDrawImage(x,y,w,h,source,0,0,0,color,isPostGUI)
	return rndtgt,false,mx,my,0,0
end