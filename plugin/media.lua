local javaScript = {}
javaScript.clearelement = "clearMedia()"
javaScript.playelement = "playMedia()"
javaScript.pauseelement = "pauseMedia()"
javaScript.stopelement = "stopMedia()"
javaScript.fullscreen = "mediaFullScreen(REP1)"
javaScript.setFill = "mediaFill(REP1)"
javaScript.setSize = "resizeMedia(REP1,REP2)"
javaScript.setLoop = "mediaLoop(REP1)"
javaScript.setTime = "mediaSetCurrentTime(REP1)"
--setDevelopmentMode(true,true)
addEvent("onDgsMediaPlay",true)
addEvent("onDgsMediaPause",true)
addEvent("onDgsMediaStop",true)
addEvent("onDgsMediaLoaded",true)
addEvent("onDgsMediaTimeUpdate",true)

addEvent("onDgsMediaBrowserReturn",true)
--[[
1: failed to create listner
]]

--Media Element won't be rendered by DGS render, so it should be set into other dgs element(Such as dgs-dximage).
--Media Element is "cef"(browser element), but if you want to manage it well, please use the functions dgs offered.
function dgsCreateMediaBrowser(w,h,transparent)
	assert(type(w) == "number","Bad argument @dgsCreateMediaBrowser at argument 1, expect number got "..type(w))
	assert(type(h) == "number","Bad argument @dgsCreateMediaBrowser at argument 2, expect number got "..type(h))
	local media = createBrowser(w,h,true,transparent and true or false)
	dgsSetType(media,"dgs-dxmedia")
	dgsSetData(media,"asPlugin","dgs-dxmedia")
	dgsSetData(media,"size",{w,h})
	dgsSetData(media,"sourcePath",false)
	dgsSetData(media,"fullscreen",false)
	dgsSetData(media,"filled",true)
	dgsSetData(media,"looped",false)
	dgsSetData(media,"functionBuffer",{})
	dgsElementData[media].duration = false
	dgsElementData[media].current = false
	triggerEvent("onDgsPluginCreate",media,sourceResource)
	return media
end

addEventHandler("onClientBrowserCreated",resourceRoot,function()
	if dgsGetType(source) == "dgs-dxmedia" then
		loadBrowserURL(source,"http://mta/"..getResourceName(getThisResource()).."/html/media.html")
	end
end)

addEventHandler("onClientBrowserDocumentReady",resourceRoot,function()
	if dgsGetType(source) == "dgs-dxmedia" then
		dgsSetData(source,"started",true)
		for k,v in ipairs(dgsElementData[source].functionBuffer) do
			v[0](unpack(v))
		end
	end
end)

DGSMediaType = {
AUDIO="audio",
VIDEO="video",
IMAGE="img",
}
function dgsMediaLoadMedia(media,path,theType,sourceRes)
	assert(dgsGetType(media) == "dgs-dxmedia","Bad argument @dgsMediaLoadMedia at argument 1, expect plugin dgs-dxmedia got "..dgsGetType(media))
	assert(type(path) == "string","Bad argument @dgsMediaLoadMedia at argument 2, expect string got "..type(path))
	local sR = sourceResource or sourceRes or getThisResource()
	local name = getResourceName(sR)
	if not path:find(":") then
		local firstOne = path:sub(1,1)
		if firstOne == "/" then
			path = path:sub(2)
		end
		path = ":"..name.."/"..path
	end
	assert(fileExists(path),"Bad argument @dgsMediaLoadMedia at argument 2, file doesn't exist("..path..")")
	assert(type(theType) == "string","Bad argument @dgsMediaLoadMedia at argument 3, expect string got "..type(theType))
	local theType = string.upper(theType)
	assert(DGSMediaType[theType],"Bad argument @dgsMediaLoadMedia at argument 3, couldn't find such media type '"..theType.."'")
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
	return dgsSetData(media,"sourcePath",path)
end

function dgsMediaClearMedia(media)
	assert(dgsGetType(media) == "dgs-dxmedia","Bad argument @dgsMediaClearMedia at argument 1, expect plugin dgs-dxmedia got "..dgsGetType(media))
	if not dgsElementData[media].started then
		local buffer = dgsElementData[media].functionBuffer
		table.insert(buffer,{[0]=dgsMediaClearMedia,media})
	else
		dgsSetData(media,"sourcePath",false)
		dgsElementData[media].duration = false
		return executeBrowserJavascript(media,javaScript.clearelement)
	end
end

function dgsMediaPlay(media)
	assert(dgsGetType(media) == "dgs-dxmedia","Bad argument @dgsMediaPlay at argument 1, expect plugin dgs-dxmedia got "..dgsGetType(media))
	if not dgsElementData[media].started then
		local buffer = dgsElementData[media].functionBuffer
		table.insert(buffer,{[0]=dgsMediaPlay,media})
	else
		assert(dgsElementData[media].sourcePath,"Bad argument @dgsMediaPlay, no media source loaded in dgs-dxmedia")
		return executeBrowserJavascript(media,javaScript.playelement)
	end
end

function dgsMediaPause(media)
	assert(dgsGetType(media) == "dgs-dxmedia","Bad argument @dgsMediaPause at argument 1, expect plugin dgs-dxmedia got "..dgsGetType(media))
	if not dgsElementData[media].started then
		local buffer = dgsElementData[media].functionBuffer
		table.insert(buffer,{[0]=dgsMediaPause,media})
	else
		assert(dgsElementData[media].sourcePath,"Bad argument @dgsMediaPause, no media source loaded in dgs-dxmedia")
		return executeBrowserJavascript(media,javaScript.pauseelement)
	end
end

function dgsMediaStop(media)
	assert(dgsGetType(media) == "dgs-dxmedia","Bad argument @dgsMediaStop at argument 1, expect plugin dgs-dxmedia got "..dgsGetType(media))
	if not dgsElementData[media].started then
		local buffer = dgsElementData[media].functionBuffer
		table.insert(buffer,{[0]=dgsMediaStop,media})
	else
		assert(dgsElementData[media].sourcePath,"Bad argument @dgsMediaStop, no media source loaded in dgs-dxmedia")
		return executeBrowserJavascript(media,javaScript.stopelement)
	end
end

function dgsMediaSetFullScreen(media,state)
	assert(dgsGetType(media) == "dgs-dxmedia","Bad argument @dgsMediaSetFullScreen at argument 1, expect plugin dgs-dxmedia got "..dgsGetType(media))
	if not dgsElementData[media].started then
		local buffer = dgsElementData[media].functionBuffer
		table.insert(buffer,{[0]=dgsMediaSetFullScreen,media,state})
	else
		assert(dgsElementData[media].sourcePath,"Bad argument @dgsMediaSetFullScreen, no media source loaded in dgs-dxmedia")
		local str = string.gsub(javaScript.fullscreen,"REP1",tostring(state))
		dgsSetData(media,"fullscreen",state)
		return executeBrowserJavascript(media,str)
	end
end

function dgsMediaGetFullScreen(media)
	assert(dgsGetType(media) == "dgs-dxmedia","Bad argument @dgsMediaGetFullScreen at argument 1, expect plugin dgs-dxmedia got "..dgsGetType(media))
	return dgsElementData[media].fullscreen
end

function dgsMediaSetFilled(media,state)
	assert(dgsGetType(media) == "dgs-dxmedia","Bad argument @dgsMediaSetFilled at argument 1, expect plugin dgs-dxmedia got "..dgsGetType(media))
	if not dgsElementData[media].started then
		local buffer = dgsElementData[media].functionBuffer
		table.insert(buffer,{[0]=dgsMediaSetFilled,media,state})
	else
		assert(dgsElementData[media].sourcePath,"Bad argument @dgsMediaSetFilled, no media source loaded in dgs-dxmedia")
		local str = string.gsub(javaScript.setFill,"REP1",tostring(state))
		dgsSetData(media,"filled",state)
		return executeBrowserJavascript(media,str)
	end
end

function dgsMediaGetFilled(media)
	assert(dgsGetType(media) == "dgs-dxmedia","Bad argument @dgsMediaGetFilled at argument 1, expect plugin dgs-dxmedia got "..dgsGetType(media))
	return dgsElementData[media].filled
end

function dgsMediaGetLooped(media)
	assert(dgsGetType(media) == "dgs-dxmedia","Bad argument @dgsMediaGetLooped at argument 1, expect plugin dgs-dxmedia got "..dgsGetType(media))
	return dgsElementData[media].loop
end

function dgsMediaSetLooped(media,state)
	assert(dgsGetType(media) == "dgs-dxmedia","Bad argument @dgsMediaSetLooped at argument 1, expect plugin dgs-dxmedia got "..dgsGetType(media))
	if not dgsElementData[media].started then
		local buffer = dgsElementData[media].functionBuffer
		table.insert(buffer,{[0]=dgsMediaSetLooped,media,state})
	else
		assert(dgsElementData[media].sourcePath,"Bad argument @dgsMediaSetLooped, no media source loaded in dgs-dxmedia")
		local str = string.gsub(javaScript.setLoop,"REP1",tostring(state))
		dgsSetData(media,"looped",state)
		return executeBrowserJavascript(media,str)
	end
end

function dgsMediaSetSize(media,w,h)
	assert(dgsGetType(media) == "dgs-dxmedia","Bad argument @dgsMediaSetSize at argument 1, expect plugin dgs-dxmedia got "..dgsGetType(media))
	assert(type(w) == "number" and w > 0,"Bad argument @dgsMediaSetSize at argument 2, expect number ( > 0 ) got "..type(w).."("..tostring(w)..")")
	assert(type(h) == "number" and h > 0,"Bad argument @dgsMediaSetSize at argument 3, expect number ( > 0 ) got "..type(h).."("..tostring(h)..")")
	if not dgsElementData[media].started then
		local buffer = dgsElementData[media].functionBuffer
		table.insert(buffer,{[0]=dgsMediaSetSize,media,w,h})
	else
		resizeBrowser(media,w,h)
		local str = javaScript.setSize
		local str = str:gsub("REP1",w)
		local str = str:gsub("REP2",h)
		dgsSetData(media,"size",{w,h})
		return executeBrowserJavascript(media,str)
	end
end

function dgsMediaGetDuration(media)
	assert(dgsGetType(media) == "dgs-dxmedia","Bad argument @dgsMediaGetDuration at argument 1, expect plugin dgs-dxmedia got "..dgsGetType(media))
	return dgsElementData[media].duration
end

function dgsMediaGetCurrentPosition(media)
	assert(dgsGetType(media) == "dgs-dxmedia","Bad argument @dgsMediaGetCurrentPosition at argument 1, expect plugin dgs-dxmedia got "..dgsGetType(media))
	return dgsElementData[media].current
end

function dgsMediaSetCurrentPosition(media,position) --Failed to Set current position ( IDK Why it will go back to 0 !)
	assert(dgsGetType(media) == "dgs-dxmedia","Bad argument @dgsMediaSetCurrentPosition at argument 1, expect plugin dgs-dxmedia got "..dgsGetType(media))
	assert(type(position) == "number" and position >= 0,"Bad argument @dgsMediaSetCurrentPosition at argument 2, expect number ( >= 0 ) got "..type(position).."("..tostring(position)..")")
	if not dgsElementData[media].started then
		local buffer = dgsElementData[media].functionBuffer
		table.insert(buffer,{[0]=dgsMediaSetCurrentPosition,media,position})
	else
		assert(dgsElementData[media].sourcePath,"Bad argument @dgsMediaSetCurrentPosition, no media source loaded in dgs-dxmedia")
		local str = javaScript.setTime
		local str = str:gsub("REP1",position)
		return executeBrowserJavascript(media,str)
	end
end
