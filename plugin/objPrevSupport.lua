dgsLogLuaMemory()
dgsRegisterPluginType("dgs-dxobjectpreviewhandle")
-- To use dgs Object Preview support, you need to install Object Preview resource. Download Link https://community.multitheftauto.com/index.php?p=resources&s=details&id=11836
-- !!Make sure that resource Object Preview is already running before using the following functions.!!
objPrevResourceName = ""
objPrevResStatus = {
	name="",
	res=false,
	valid=false
}
objPrevHandles = {}
function onObjPrevStop()
	outputDebugString("[DGS]Object Preview has been stopped, DGS Object Preview Support has been shutdown.",2)
	objPrevResStatus.valid = false
	objPrevResStatus.res = false
	removeEventHandler("onClientResourceStop",getResourceRootElement(res),onObjPrevStop)
end

function onObjPrevStart(res)
	if objPrevResStatus.name == "" then	return end
	if getResourceName(res) == objPrevResStatus.name then
		objPrevResStatus.res = res
		objPrevResStatus.valid = true
		outputDebugString("[DGS]Object Preview has been started.",3)
		addEventHandler("onClientResourceStop",getResourceRootElement(res),onObjPrevStop)
	end
end
addEventHandler("onClientResourceStart",root,onObjPrevStart)

function dgsLocateObjectPreviewResource(name)
	if not(type(name) == "string") then error(dgsGenAsrt(name,"dgsLocateObjectPreviewResource",1,"string")) end
	objPrevResStatus.res = getResourceFromName(name)
	if not(objPrevResStatus.res) then error(dgsGenAsrt(name,"dgsLocateObjectPreviewResource",1,_,_,_,"resource "..name.." is not running or doesn't exist")) end
	objPrevResStatus.name = name
	if not(getResourceState(objPrevResStatus.res) == "running") then error(dgsGenAsrt(name,"dgsLocateObjectPreviewResource",1,_,_,_,"resource "..name.." is not running, please start it")) end
	objPrevResStatus.valid = true
	removeEventHandler("onClientResourceStop",getResourceRootElement(objPrevResStatus.res),onObjPrevStop)
	addEventHandler("onClientResourceStop",getResourceRootElement(objPrevResStatus.res),onObjPrevStop)
end

function dgsCreateObjectPreviewHandle(objEle,rX,rY,rZ)
	if not(objPrevResStatus.name ~= "") then error(dgsGenAsrt(objEle,"dgsCreateObjectPreviewHandle",_,_,_,_,"couldn't find Object Preview resource, please locate it")) end
	if not(isElement(objEle)) then error(dgsGenAsrt(objEle,"dgsCreateObjectPreviewHandle",1,"element")) end
	local OP = exports[objPrevResStatus.name]
	local objPrevEle = OP:createObjectPreview(objEle,rX,rY,rZ,0,0,100,100,false,false,true)
	OP:setAlpha(objPrevEle,0)
	dgsSetData(objPrevEle,"asPlugin","dgs-dxobjectpreviewhandle")
	dgsSetData(objEle,"SOVelement",objPrevEle)
	dgsSetData(objPrevEle,"renderElement",objEle)
	objPrevHandles[getElementID(objPrevEle)] = objPrevEle
	dgsAddEventHandler("onClientElementDestroy",objEle,"destroyObjectPreviewWhenTargetElementDestroy",false)
	dgsAddEventHandler("onClientElementDestroy",objPrevEle,"destroyObjectPreviewWhenOPElementDestroy",false)
	dgsTriggerEvent("onDgsPluginCreate",objPrevEle,sourceResource)
	return objPrevEle
end

function destroyObjectPreviewWhenTargetElementDestroy()
	local OP = exports[objPrevResStatus.name]
	local objPrevEle = dgsElementData[source].SOVelement
	objPrevHandles[getElementID(objPrevEle)] = nil
	OP:destroyObjectPreview(objPrevEle)
	dgsElementData[objPrevEle] = nil
	dgsElementData[source] = nil
end

function destroyObjectPreviewWhenOPElementDestroy()
	local objectPreview = getResourceFromName(objPrevResourceName)
	if objectPreview and getResourceState(objectPreview) == "running" then
		local OP = exports[objPrevResStatus.name]
		OP:destroyObjectPreview(source)
	end
	objPrevHandles[getElementID(source)] = nil
	local objEle = dgsElementData[source].renderElement
	dgsRemoveEventHandler("onClientElementDestroy",objEle,"destroyObjectPreviewWhenTargetElementDestroy")
	dgsElementData[objEle] = nil
	dgsElementData[source] = nil
end

function dgsObjectPreviewGetHandleByID(id)
	return objPrevHandles[id] or false
end

function dgsAttachObjectPreviewToImage(objPrev,dgsImage)
	if not(dgsGetPluginType(objPrev) == "dgs-dxobjectpreviewhandle") then error(dgsGenAsrt(objPrev,"dgsAttachObjectPreviewToImage",1,"dgs-dxobjectpreviewhandle")) end
	if not(dgsGetType(dgsImage) == "dgs-dximage") then error(dgsGenAsrt(dgsImage,"dgsAttachObjectPreviewToImage",2,"dgs-dximage")) end
	dgsSetProperty(dgsImage,"SOVelement",objPrev)
	local OP = exports[objPrevResStatus.name]
	OP:setAlpha(objPrev,254)
	dgsSetProperty(dgsImage,"functionRunBefore",true)
	dgsImageSetImage(dgsImage,OP:getRenderTarget())
	dgsSetProperty(dgsImage,"functions",[[
		if objPrevResStatus.valid then
			local objPrevEle = dgsElementData[self].SOVelement
			if dgsElementData[objPrevEle] then
				dgsImageSetUVPosition(self,renderArguments[1],renderArguments[2],false)
				dgsImageSetUVSize(self,renderArguments[3],renderArguments[4],false)
				exports[objPrevResStatus.name]:setProjection(objPrevEle,renderArguments[1],renderArguments[2],renderArguments[3],renderArguments[4])
			end
		elseif dgsElementData[self].image then
			dgsImageSetImage(self,nil)
		end
	]])
	addEventHandler("onDgsDestroy",dgsImage,function()
		dgsRemoveObjectPreviewFromImage(source)
	end,false)
end

function dgsRemoveObjectPreviewFromImage(dgsImage)
	if not(dgsGetType(dgsImage) == "dgs-dximage") then error(dgsGenAsrt(dgsImage,"dgsRemoveObjectPreviewFromImage",1,"dgs-dximage")) end
	local objPrev = dgsElementData[dgsImage].SOVelement
	local OP = exports[objPrevResStatus.name]
	if isElement(objPrev) then OP:setAlpha(objPrev,0) end
	dgsSetProperty(dgsImage,"functionRunBefore",false)
	dgsSetProperty(dgsImage,"functions",nil)
	dgsImageSetImage(dgsImage,nil)
	dgsImageSetUVPosition(dgsImage)
	dgsImageSetUVSize(dgsImage)
	dgsSetProperty(dgsImage,"SOVelement",nil)
end

function dgsConfigureObjectPreview()
	return [[
	objectPreview._drawRenderTarget = objectPreview.drawRenderTarget
	function objectPreview.drawRenderTarget(self)
		local resName = "]]..getResourceName(getThisResource())..[["
		local dgsRes = getResourceFromName(resName)
		if dgsRes then
			if getResourceState(dgsRes) == "running" then
				local objPrevEle = exports[resName]:dgsObjectPreviewGetHandleByID(self.renID)
				if objPrevEle then
					return false
				end
			end
		end
	end]]
end