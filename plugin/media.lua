local javaScript = {}
javaScript.clearelement = "clearMedia()"
javaScript.playelement = "playMedia()"
javaScript.pauseelement = "pauseMedia()"
javaScript.stopelement = "stopMedia()"
setDevelopmentMode(true,true)
addEvent("onDgsMediaPlay",true)
addEvent("onDgsMediaPause",true)
addEvent("onDgsMediaPlay",true)
--Media Element won't be rendered by DGS render, so it should be set into other dgs element(Such as dgs-dximage).
--Media Element is "cef"(browser element), but if you want to manage it well, please use the functions dgs offered.
function dgsCreateMedia(w,h)
	assert(type(w) == "number","Bad argument @dgsCreateMedia at argument 1, expect number got "..type(w))
	assert(type(h) == "number","Bad argument @dgsCreateMedia at argument 2, expect number got "..type(h))
	local browser = guiCreateBrowser(100,100,w,h,true,false,false)
	local media = guiGetBrowser(browser)
	dgsSetType(media,"dgs-dxmedia")
	dgsSetData(media,"size",{w,h})
	dgsSetData(media,"sourcePath",false)
	dgsSetData(media,"functionBuffer",{})
	insertResourceDxGUI(sourceResource,media)
	triggerEvent("onClientDgsDxGUIPreCreate",media)
	triggerEvent("onClientDgsDxGUICreate",media)
	return media
end

addEventHandler("onClientBrowserCreated",resourceRoot,function()
	if dgsGetType(source) == "dgs-dxmedia" then
		loadBrowserURL(source,"http://mta/"..getResourceName(getThisResource()).."/media.html")
		toggleBrowserDevTools(source,true)
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

function dgsMediaLoadMedia(media,path,theType,loop,autoplay)
	assert(dgsGetType(media) == "dgs-dxmedia","Bad argument @dgsMediaLoadMedia at argument 1, expect dgs-dxmedia got "..dgsGetType(media))
	assert(type(path) == "string","Bad argument @dgsMediaLoadMedia at argument 2, expect string got "..type(path))
	assert(fileExists(path),"Bad argument @dgsMediaLoadMedia at argument 2, file doesn't exist("..path..")")
	assert(theType == "VIDEO" or theType == "AUDIO","Bad argument @dgsMediaLoadMedia at argument 3, expect string('VIDEO' or 'AUDIO') got "..tostring(theType))
	loop = tostring(loop and true or false)
	autoplay = tostring(autoplay == false and false or true)
	if not dgsElementData[media].started then
		local buffer = dgsElementData[media].functionBuffer
		table.insert(buffer,{[0]=dgsMediaLoadMedia,media,path,theType,loop,autoplay})
	else
		dgsMediaClearMedia(media)
		dgsSetData(media,"sourcePath",path)
		local size = dgsElementData[media].size
		local str = [[
			var element = document.createElement("]]..theType..[[");
			element.id = "element";
			element.width = ]]..size[1]..[[;
			element.height = ]]..size[2]..[[;
			element.loop = ]]..loop..[[;
			element.autoplay = ]]..autoplay..[[;
			document.body.appendChild(element);
			var source = document.createElement("source");
			source.src = getRootPath_dc()+"/]]..path..[[";
			element.appendChild(source);
		]]
		return executeBrowserJavascript(media,str)
	end
end

function dgsMediaGetMediaPath(media)
	return dgsSetData(media,"sourcePath",path)
end

function dgsMediaClearMedia(media)
	assert(dgsGetType(media) == "dgs-dxmedia","Bad argument @dgsMediaClearMedia at argument 1, expect dgs-dxmedia got "..dgsGetType(media))
	if not dgsElementData[media].started then
		local buffer = dgsElementData[media].functionBuffer
		table.insert(buffer,{[0]=dgsMediaClearMedia,media})
	else
		dgsSetData(media,"sourcePath",false)
		return executeBrowserJavascript(media,javaScript.clearelement)
	end
end

function dgsMediaPlay(media)
	assert(dgsGetType(media) == "dgs-dxmedia","Bad argument @dgsMediaPlay at argument 1, expect dgs-dxmedia got "..dgsGetType(media))
	if not dgsElementData[media].started then
		local buffer = dgsElementData[media].functionBuffer
		table.insert(buffer,{[0]=dgsMediaPlay,media})
	else
		assert(dgsElementData[media].sourcePath,"Bad argument @dgsMediaPlay, no media source loaded in dgs-dxmedia")
		return executeBrowserJavascript(media,javaScript.playelement)
	end
end

function dgsMediaPause(media)
	assert(dgsGetType(media) == "dgs-dxmedia","Bad argument @dgsMediaPause at argument 1, expect dgs-dxmedia got "..dgsGetType(media))
	if not dgsElementData[media].started then
		local buffer = dgsElementData[media].functionBuffer
		table.insert(buffer,{[0]=dgsMediaPause,media})
	else
		assert(dgsElementData[media].sourcePath,"Bad argument @dgsMediaPause, no media source loaded in dgs-dxmedia")
		return executeBrowserJavascript(media,javaScript.pauseelement)
	end
end

function dgsMediaStop(media)
	assert(dgsGetType(media) == "dgs-dxmedia","Bad argument @dgsMediaStop at argument 1, expect dgs-dxmedia got "..dgsGetType(media))
	if not dgsElementData[media].started then
		local buffer = dgsElementData[media].functionBuffer
		table.insert(buffer,{[0]=dgsMediaStop,media})
	else
		assert(dgsElementData[media].sourcePath,"Bad argument @dgsMediaStop, no media source loaded in dgs-dxmedia")
		return executeBrowserJavascript(media,javaScript.stopelement)
	end
end