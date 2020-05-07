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
	assert(type(name) == "string","Bad argument @dgsLocateObjectPreviewResource at argument 1, expect a string got "..dgsGetType(name))
	objPrevResStatus.res = getResourceFromName(name)
	assert(objPrevResStatus.res,"Bad argument @dgsLocateObjectPreviewResource at argument 1, resource "..name.." is not running or doesn't exist")
	objPrevResStatus.name = name
	assert(getResourceState(objPrevResStatus.res) == "running","Bad argument @dgsLocateObjectPreviewResource at argument 1, resource "..name.." is not running, please start it")
	objPrevResStatus.valid = true
	removeEventHandler("onClientResourceStop",getResourceRootElement(objPrevResStatus.res),onObjPrevStop)
	addEventHandler("onClientResourceStop",getResourceRootElement(objPrevResStatus.res),onObjPrevStop)
end

function dgsCreateObjectPreviewHandle(objEle,rX,rY,rZ)
	assert(objPrevResStatus.name ~= "","Bad argument @dgsCreateObjectPreviewHandle, couldn't find Object Preview resource, please locate it")
	local objType = dgsGetType(objEle)
	assert(isElement(objEle), "Bad argument @dgsCreateObjectPreviewHandle at argument 1, expected element got "..objType)
	local OP = exports[objPrevResStatus.name]
	local objPrevEle = OP:createObjectPreview(objEle,rX,rY,rZ,0,0,100,100)
	OP:setAlpha(objPrevEle,0)
	dgsSetData(objPrevEle,"asPlugin","dgs-dxobjectpreviewhandle")
	dgsSetData(objEle,"SOVelement",objPrevEle)
	dgsSetData(objPrevEle,"renderElement",objEle)
	objPrevHandles[getElementID(objPrevEle)] = objPrevEle
	addEventHandler("onClientElementDestroy",objEle,function()
		local objPrevEle = dgsElementData[source].SOVelement
		objPrevHandles[getElementID(objPrevEle)] = nil
		OP:destroyObjectPreview(objPrevEle)
		dgsElementData[objPrevEle] = nil
		dgsElementData[source] = nil
	end,false)
	addEventHandler("onClientElementDestroy",objPrevEle,function()
		local objEle = dgsElementData[source].renderElement
		objPrevHandles[getElementID(source)] = nil
		dgsElementData[objEle] = nil
		dgsElementData[source] = nil
	end,false)
	triggerEvent("onDgsPluginCreate",objPrevEle,sourceResource)
	return objPrevEle
end

function dgsObjectPreviewGetHandleByID(id)
	return objPrevHandles[id] or false
end

function dgsAttachObjectPreviewToImage(objPrev,dgsImage)
	assert(dgsGetPluginType(objPrev) == "dgs-dxobjectpreviewhandle","Bad argument @dgsAddObjectPreviewSupport at argument 1, expect a dgs-dxobjectpreviewhandle got "..dgsGetPluginType(objPrev))
	assert(dgsGetType(dgsImage) == "dgs-dximage","Bad argument @dgsAddObjectPreviewSupport at argument 2, expect a dgs-dximage got "..dgsGetType(dgsImage))
	dgsSetProperty(dgsImage,"SOVelement",objPrev)
	local OP = exports[objPrevResStatus.name]
	OP:setAlpha(objPrev,254)
	dgsSetProperty(dgsImage,"functionRunBefore",true)
	dgsImageSetImage(dgsImage,OP:getRenderTarget())
	local function fnc()
		if objPrevResStatus.valid then
			local objPrevEle = dgsElementData[self].SOVelement
			if dgsElementData[objPrevEle] then
				local resName = objPrevResStatus.name
				local OP = exports[resName]
				dgsImageSetUVPosition(self,renderArguments[1],renderArguments[2],false)
				dgsImageSetUVSize(self,renderArguments[3],renderArguments[4],false)
				OP:setProjection(objPrevEle,renderArguments[1],renderArguments[2],renderArguments[3],renderArguments[4])
			end
		elseif dgsElementData[self].image then
			dgsImageSetImage(self,nil)
		end
	end
	dgsSetProperty(dgsImage,"functions",fnc)
	addEventHandler("onDgsDestroy",dgsImage,function()
		dgsRemoveObjectPreviewFromImage(source)
	end,false)
end

function dgsRemoveObjectPreviewFromImage(dgsImage)
	assert(dgsGetType(dgsImage) == "dgs-dximage","Bad argument @dgsRemoveObjectPreviewFromImage at argument 1, expect a dgs-dximage got "..dgsGetType(dgsImage))
	local objPrev = dgsElementData[dgsImage].SOVelement
	local OP = exports[objPrevResStatus.name]
	if isElement(objPrev) then
		OP:setAlpha(objPrev,0)
	end
	dgsSetProperty(dgsImage,"functionRunBefore",false)
	dgsSetProperty(dgsImage,"functions",nil)
	dgsImageSetImage(dgsImage,nil)
	dgsImageSetUVPosition(dgsImage)
	dgsImageSetUVSize(dgsImage)
	dgsSetProperty(dgsImage,"SOVelement",nil)
end

function dgsConfigureObjectPreview()
	return [[objectPreview._drawRenderTarget = objectPreview.drawRenderTarget
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
			--return self:_drawRenderTarget()
		end]]
end