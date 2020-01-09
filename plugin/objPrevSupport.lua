-- To use dgs Object Preview support, you need to install Object Preview resource. Download Link https://community.multitheftauto.com/index.php?p=resources&s=details&id=11836
-- !!Make sure that resource Object Preview is already running before using the following functions.!!
objPrevResourceName = ""
objPrevAttached = {}

function dgsLocateObjectPreviewResource(name)
	assert(type(name) == "string","Bad argument @dgsLocateObjectPreviewResource at argument 1, expect a string got "..dgsGetType(name))
	local res = getResourceFromName(name)
	assert(res,"Bad argument @dgsLocateObjectPreviewResource at argument 1, couldn't find such resource "..name)
	assert(getResourceState(res) == "running","Bad argument @dgsLocateObjectPreviewResource at argument 1, resource "..name.." is not running, please start it")
	addEventHandler("onClientResourceStop",getResourceRootElement(res),function()
		outputDebugString("Object Preview has been stopped, DGS Object Preview Support has been shutdown.",2)
	end)
end


function dgsAttachObjectPreviewToImage(objPrev,dgsImage)
	assert(dgsGetType(objPrev) == "SOVelement","Bad argument @dgsAddObjectPreviewSupport at argument 1, expect a SOVelement (from object preview) got "..dgsGetType(objPrev))
	assert(dgsGetType(dgsImage) == "dgs-dximage","Bad argument @dgsAddObjectPreviewSupport at argument 2, expect a dgs-dximage got "..dgsGetType(dgsImage))
	local fnc = [[
	
	]]
end