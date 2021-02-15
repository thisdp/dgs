local JS = {
	clearelement = "clearMedia()",
	playelement = "playMedia()",
	pauseelement = "pauseMedia()",
	stopelement = "stopMedia()",
	setFullScreen = "setFullScreen(REP1)",
	setFilled = "setFilled(REP1)",
	setSize = "setSize(REP1,REP2)",
	setLooped = "setLooped(REP1)",
	setTime = "setCurrentTime(REP1)",
	setSpeed = "setSpeed(REP1)",
}
addEvent("onDgsMediaPlay",true)
addEvent("onDgsMediaPause",true)
addEvent("onDgsMediaStop",true)
addEvent("onDgsMediaLoaded",true)
addEvent("onDgsMediaTimeUpdate",true)
addEvent("onDgsMediaBrowserReturn",true)

--Media Element won't be rendered by DGS render, so it should be set into other dgs element(Such as dgs-dximage).
--Media Element is "cef"(browser element), but if you want to manage it well, please use the functions dgs offered.
function dgsCreateMediaBrowser(w,h,transparent)
	if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsCreateMediaBrowser",1,"number")) end
	if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsCreateMediaBrowser",2,"number")) end
	local media = createBrowser(w,h,true,transparent and true or false)
	dgsSetType(media,"dgs-dxmedia")
	dgsSetData(media,"asPlugin","dgs-dxmedia")
	dgsSetData(media,"size",{w,h})
	dgsSetData(media,"sourcePath",false)
	dgsSetData(media,"fullscreen",false)
	dgsSetData(media,"filled",true)
	dgsSetData(media,"looped",false)
	dgsSetData(media,"speed",1)
	dgsSetData(media,"functionBuffer",{})
	dgsElementData[media].duration = false
	dgsElementData[media].current = false
	triggerEvent("onDgsPluginCreate",media,sourceResource)
	addEventHandler("onClientBrowserCreated",media,function()
		loadBrowserURL(source,"http://mta/"..getResourceName(getThisResource()).."/html/media.html")
	end,false)
	addEventHandler("onClientBrowserDocumentReady",media,function()
		dgsSetData(source,"started",true)
		for k,v in ipairs(dgsElementData[source].functionBuffer) do
			v[0](unpack(v))
		end
	end,false)
	return media
end

DGSMediaType = {
	AUDIO="audio",
	VIDEO="video",
	IMAGE="img",
}
function dgsMediaLoadMedia(media,path,theType,sourceRes)
	if not(dgsGetType(media) == "dgs-dxmedia") then error(dgsGenAsrt(media,"dgsMediaLoadMedia",1,"plugin dgs-dxmedia")) end
	if not(type(path) == "string") then error(dgsGenAsrt(path,"dgsMediaLoadMedia",2,"string")) end
	local sR = sourceResource or sourceRes or getThisResource()
	local name = getResourceName(sR)
	if not path:find(":") then
		local firstOne = path:sub(1,1)
		if firstOne == "/" then
			path = path:sub(2)
		end
		path = ":"..name.."/"..path
	end
	if not(fileExists(path)) then error(dgsGenAsrt(path,"dgsMediaLoadMedia",2,_,_,"file doesn't exist("..path..")")) end
	if not(type(theType) == "string") then error(dgsGenAsrt(theType,"dgsMediaLoadMedia",3,"string")) end
	local theType = theType:upper()
	if not(DGSMediaType[theType]) then error(dgsGenAsrt(theType,"dgsMediaLoadMedia",3,"string","Audio/Video/Image","unsupported type")) end
	if not dgsElementData[media].started then
		local buffer = dgsElementData[media].functionBuffer
		table.insert(buffer,{[0]=dgsMediaLoadMedia,media,path,theType,sR})
	else
		dgsMediaClearMedia(media)
		dgsSetData(media,"sourcePath",path)
		local size = dgsElementData[media].size
		local filled = dgsElementData[media].filled
		local str = ""
		if DGSMediaType[theType] == "img" then
			str = [[
				var element = document.createElement("]]..DGSMediaType[theType]..[[");
				element.id = "element";
				element.src = "http://mta/]] ..path:sub(2).. [[";
				element.width = ]]..size[1]..[[;
				element.height = ]]..size[2]..[[;
				document.body.appendChild(element);
				createListener(element);
				mta.triggerEvent("onDgsMediaLoaded")
			]]
		else
			str = [[
				var element = document.createElement("]]..DGSMediaType[theType]..[[");
				element.id = "element";
				element.width = ]]..size[1]..[[;
				element.height = ]]..size[2]..[[;
				createListener(element);
				document.body.appendChild(element);
				var source = document.createElement("source");
				source.src = "http://mta/]] ..path:sub(2).. [[";
				element.appendChild(source);
				mta.triggerEvent("onDgsMediaLoaded")
			]]
		end
		local executed = executeBrowserJavascript(media,str)
		dgsMediaSetFullScreen(media,dgsElementData[media].fullscreen)
		dgsMediaSetFilled(media,dgsElementData[media].filled)
		dgsMediaSetLooped(media,dgsElementData[media].looped)
		return executed
	end
end

addEventHandler("onDgsMediaLoaded",resourceRoot,function(duration)
	if dgsElementType[source] == "dgs-dxmedia" and duration then
		dgsElementData[source].duration = duration
	end
end)

addEventHandler("onDgsMediaTimeUpdate",resourceRoot,function(current)
	if dgsElementType[source] == "dgs-dxmedia" and current then
		dgsElementData[source].current = current
	end
end)

function dgsMediaGetMediaPath(media)
	if not(dgsGetType(media) == "dgs-dxmedia") then error(dgsGenAsrt(media,"dgsMediaGetMediaPath",1,"plugin dgs-dxmedia")) end
	return dgsSetData(media,"sourcePath",path)
end

function dgsMediaClearMedia(media)
	if not(dgsGetType(media) == "dgs-dxmedia") then error(dgsGenAsrt(media,"dgsMediaClearMedia",1,"plugin dgs-dxmedia")) end
	if not dgsElementData[media].started then
		local buffer = dgsElementData[media].functionBuffer
		table.insert(buffer,{[0]=dgsMediaClearMedia,media})
	else
		dgsSetData(media,"sourcePath",false)
		dgsElementData[media].duration = false
		return executeBrowserJavascript(media,JS.clearelement)
	end
end

function dgsMediaPlay(media)
	if not(dgsGetType(media) == "dgs-dxmedia") then error(dgsGenAsrt(media,"dgsMediaPlay",1,"plugin dgs-dxmedia")) end
	if not dgsElementData[media].started then
		local buffer = dgsElementData[media].functionBuffer
		table.insert(buffer,{[0]=dgsMediaPlay,media})
	else
		if not(dgsElementData[media].sourcePath) then error(dgsGenAsrt(media,"dgsMediaPlay",_,_,_,_,"no media source loaded in dgs-dxmedia")) end
		return executeBrowserJavascript(media,JS.playelement)
	end
end

function dgsMediaPause(media)
	if not(dgsGetType(media) == "dgs-dxmedia") then error(dgsGenAsrt(media,"dgsMediaPause",1,"plugin dgs-dxmedia")) end
	if not dgsElementData[media].started then
		local buffer = dgsElementData[media].functionBuffer
		table.insert(buffer,{[0]=dgsMediaPause,media})
	else
		if not(dgsElementData[media].sourcePath) then error(dgsGenAsrt(media,"dgsMediaPause",_,_,_,_,"no media source loaded in dgs-dxmedia")) end
		return executeBrowserJavascript(media,JS.pauseelement)
	end
end

function dgsMediaStop(media)
	if not(dgsGetType(media) == "dgs-dxmedia") then error(dgsGenAsrt(media,"dgsMediaStop",1,"plugin dgs-dxmedia")) end
	if not dgsElementData[media].started then
		local buffer = dgsElementData[media].functionBuffer
		table.insert(buffer,{[0]=dgsMediaStop,media})
	else
		if not(dgsElementData[media].sourcePath) then error(dgsGenAsrt(media,"dgsMediaStop",_,_,_,_,"no media source loaded in dgs-dxmedia")) end
		return executeBrowserJavascript(media,JS.stopelement)
	end
end

function dgsMediaSetSpeed(media,speed)
	if not(dgsGetType(media) == "dgs-dxmedia") then error(dgsGenAsrt(media,"dgsMediaSetSpeed",1,"plugin dgs-dxmedia")) end
	if not dgsElementData[media].started then
		local buffer = dgsElementData[media].functionBuffer
		table.insert(buffer,{[0]=dgsMediaSetSpeed,media,speed})
	else
		if not(dgsElementData[media].sourcePath) then error(dgsGenAsrt(media,"dgsMediaSetSpeed",_,_,_,_,"no media source loaded in dgs-dxmedia")) end
		local str = JS.setSpeed:gsub("REP1",tostring(speed))
		dgsSetData(media,"speed",speed)
		return executeBrowserJavascript(media,str)
	end
end

function dgsMediaGetSpeed(media,speed)
	if not(dgsGetType(media) == "dgs-dxmedia") then error(dgsGenAsrt(media,"dgsMediaGetSpeed",1,"plugin dgs-dxmedia")) end
	return dgsElementData[media].speed
end

function dgsMediaSetFullScreen(media,state)
	if not(dgsGetType(media) == "dgs-dxmedia") then error(dgsGenAsrt(media,"dgsMediaSetFullScreen",1,"plugin dgs-dxmedia")) end
	if not dgsElementData[media].started then
		local buffer = dgsElementData[media].functionBuffer
		table.insert(buffer,{[0]=dgsMediaSetFullScreen,media,state})
	else
		if not(dgsElementData[media].sourcePath) then error(dgsGenAsrt(media,"dgsMediaSetFullScreen",_,_,_,_,"no media source loaded in dgs-dxmedia")) end
		local str = JS.setFullScreen:gsub("REP1",tostring(state))
		dgsSetData(media,"fullscreen",state)
		return executeBrowserJavascript(media,str)
	end
end

function dgsMediaGetFullScreen(media)
	if not(dgsGetType(media) == "dgs-dxmedia") then error(dgsGenAsrt(media,"dgsMediaGetFullScreen",1,"plugin dgs-dxmedia")) end
	return dgsElementData[media].fullscreen
end

function dgsMediaSetFilled(media,state)
	if not(dgsGetType(media) == "dgs-dxmedia") then error(dgsGenAsrt(media,"dgsMediaSetFilled",1,"plugin dgs-dxmedia")) end
	if not dgsElementData[media].started then
		local buffer = dgsElementData[media].functionBuffer
		table.insert(buffer,{[0]=dgsMediaSetFilled,media,state})
	else
		if not(dgsElementData[media].sourcePath) then error(dgsGenAsrt(media,"dgsMediaSetFilled",_,_,_,_,"no media source loaded in dgs-dxmedia")) end
		local str = JS.setFilled:gsub("REP1",tostring(state))
		dgsSetData(media,"filled",state)
		return executeBrowserJavascript(media,str)
	end
end

function dgsMediaGetFilled(media)
	if not(dgsGetType(media) == "dgs-dxmedia") then error(dgsGenAsrt(media,"dgsMediaGetFilled",1,"plugin dgs-dxmedia")) end
	return dgsElementData[media].filled
end

function dgsMediaGetLooped(media)
	if not(dgsGetType(media) == "dgs-dxmedia") then error(dgsGenAsrt(media,"dgsMediaGetLooped",1,"plugin dgs-dxmedia")) end
	return dgsElementData[media].loop
end

function dgsMediaSetLooped(media,state)
	if not(dgsGetType(media) == "dgs-dxmedia") then error(dgsGenAsrt(media,"dgsMediaSetLooped",1,"plugin dgs-dxmedia")) end
	if not dgsElementData[media].started then
		local buffer = dgsElementData[media].functionBuffer
		table.insert(buffer,{[0]=dgsMediaSetLooped,media,state})
	else
		if not(dgsElementData[media].sourcePath) then error(dgsGenAsrt(media,"dgsMediaSetLooped",_,_,_,_,"no media source loaded in dgs-dxmedia")) end
		local str = JS.setLooped:gsub("REP1",tostring(state))
		dgsSetData(media,"looped",state)
		return executeBrowserJavascript(media,str)
	end
end

function dgsMediaSetSize(media,w,h)
	if not(dgsGetType(media) == "dgs-dxmedia") then error(dgsGenAsrt(media,"dgsMediaSetSize",1,"plugin dgs-dxmedia")) end
	if not(type(w) == "number" and w > 0) then error(dgsGenAsrt(w,"dgsMediaSetSize",2,"number",">0")) end
	if not(type(h) == "number" and h > 0) then error(dgsGenAsrt(h,"dgsMediaSetSize",3,"number",">0")) end
	if not dgsElementData[media].started then
		local buffer = dgsElementData[media].functionBuffer
		table.insert(buffer,{[0]=dgsMediaSetSize,media,w,h})
	else
		resizeBrowser(media,w,h)
		local str = JS.setSize
		local str = str:gsub("REP1",w)
		local str = str:gsub("REP2",h)
		dgsSetData(media,"size",{w,h})
		return executeBrowserJavascript(media,str)
	end
end

function dgsMediaGetDuration(media)
	if not(dgsGetType(media) == "dgs-dxmedia") then error(dgsGenAsrt(media,"dgsMediaGetDuration",1,"plugin dgs-dxmedia")) end
	return dgsElementData[media].duration
end

function dgsMediaGetCurrentPosition(media)
	if not(dgsGetType(media) == "dgs-dxmedia") then error(dgsGenAsrt(media,"dgsMediaGetCurrentPosition",1,"plugin dgs-dxmedia")) end
	return dgsElementData[media].current
end

function dgsMediaSetCurrentPosition(media,position) --Failed to Set current position ( CEF doesn't load the video buffer )
	if not(dgsGetType(media) == "dgs-dxmedia") then error(dgsGenAsrt(media,"dgsMediaSetCurrentPosition",1,"plugin dgs-dxmedia")) end
	if not(type(position) == "number" and position > 0) then error(dgsGenAsrt(position,"dgsMediaSetCurrentPosition",2,"number",">0")) end
	if not dgsElementData[media].started then
		local buffer = dgsElementData[media].functionBuffer
		table.insert(buffer,{[0]=dgsMediaSetCurrentPosition,media,position})
	else
		if not(dgsElementData[media].sourcePath) then error(dgsGenAsrt(media,"dgsMediaSetCurrentPosition",_,_,_,_,"no media source loaded in dgs-dxmedia")) end
		local str = JS.setTime
		local str = str:gsub("REP1",position)
		return executeBrowserJavascript(media,str)
	end
end