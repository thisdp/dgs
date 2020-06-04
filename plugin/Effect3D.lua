local effect3DShader

function dgsCreateEffect3D(rotFactor)
	local shader = dxCreateShader(effect3DShader)
	dgsSetData(shader,"asPlugin","dgs-dxeffect3d")
	dgsSetData(shader,"rotFactor",rotFactor or 2)
	dgsSetData(shader,"applyToScrollPane",nil)
	addEventHandler("onClientElementDestroy",shader,function()
		dgsEffect3DRemoveFromScrollPane(source)
	end,false)
	triggerEvent("onDgsPluginCreate",shader,sourceResource)
	return shader
end

function dgsEffect3DApplyToScrollPane(effect3d,scrollpane)
	assert(dgsGetPluginType(effect3d) == "dgs-dxeffect3d","Bad argument @dgsEffect3DApplyToScrollPane at argument 1, expect a dgs-dxeffect3d got "..dgsGetPluginType(effect3d))
	assert(dgsGetType(scrollpane) == "dgs-dxscrollpane","Bad argument @dgsEffect3DApplyToScrollPane at argument 2, expect a dgs-dxscrollpane got "..dgsGetType(scrollpane))
	dgsEffect3DRemoveFromScrollPane(effect3d)
	dgsSetData(effect3d,"applyToScrollPane",scrollpane)
	dgsSetData(scrollpane,"filter",{effect3d,0,0,0})
	dgsSetData(scrollpane,"enableFullEnterLeaveCheck",true)
	local function mouseMoveCheck()
		if not isElement(source) then
			removeEventHandler("onClientRender",root,mouseMoveCheck)
			return
		end
		local x,y = dgsGetCursorPosition()
		local spx,spy = dgsGetPosition(source,false,true)
		local w,h = dgsElementData[source].absSize[1],dgsElementData[source].absSize[2]
        local filter = dgsElementData[source].filter
		local rotFactor = dgsElementData[filter[1]].rotFactor
		local dx,dy = (spx+w/2)-x,(spy+h/2)-y
		local dx,dy = -dx/w*rotFactor,dy/h*rotFactor
		dgsSetData(source,"filter",{effect3d,dx,dy,0,0,0})
	end
	local newEnv = {source=scrollpane,mouseMoveCheck=mouseMoveCheck}
	setmetatable(newEnv,{__index=_G})
	setfenv(mouseMoveCheck,newEnv)
	
	function mouseEnterLeave()
		if eventName == "onDgsElementEnter" then
			addEventHandler("onClientRender",root,mouseMoveCheck)
		else
			removeEventHandler("onClientRender",root,mouseMoveCheck)
		end
	end
	addEventHandler("onDgsElementEnter",scrollpane,mouseEnterLeave,false)
	addEventHandler("onDgsElementLeave",scrollpane,mouseEnterLeave,false)
	dgsSetData(effect3d,"mouseMoveCheck",mouseMoveCheck)
	dgsSetData(effect3d,"mouseEnterLeaveCheck",mouseEnterLeave)
end

function dgsEffect3DRemoveFromScrollPane(effect3d)
	if dgsGetPluginType(effect3d) == "dgs-dxeffect3d" then
		local sp = dgsElementData[effect3d].applyToScrollPane
		if dgsGetType(sp) == "dgs-dxscrollpane" then
			removeEventHandler("onDgsElementEnter",sp,dgsElementData[effect3d].mouseEnterLeaveCheck)
			removeEventHandler("onDgsElementLeave",sp,dgsElementData[effect3d].mouseEnterLeaveCheck)
			removeEventHandler("onClientRender",root,dgsElementData[effect3d].mouseMoveCheck)
			dgsSetData(sp,"filter",nil)
		end
		dgsSetData(sp,"enableFullEnterLeaveCheck",false)
		return dgsSetData(effect3d,"applyToScrollPane",nil)
	elseif dgsGetType(effect3d) == "dgs-dxscrollpane" then
		local sp = effect3d
		local filter = dgsElementData[sp].filter
		if filter then
			local effect3d = filter[1]
			if isElement(effect3d) then
				removeEventHandler("onDgsElementEnter",sp,dgsElementData[effect3d].mouseEnterLeaveCheck)
				removeEventHandler("onDgsElementLeave",sp,dgsElementData[effect3d].mouseEnterLeaveCheck)
				removeEventHandler("onClientRender",root,dgsElementData[effect3d].mouseMoveCheck)
				dgsSetData(effect3d,"applyToScrollPane",nil)
			end
		end
		dgsSetData(sp,"enableFullEnterLeaveCheck",false)
		return dgsSetData(sp,"filter",nil)
	end
	return false
end

----------------Shader
effect3DShader = [[
texture sourceTexture;

technique effect3D {
	pass p0 {
		Texture[0] = sourceTexture;
	}
}
]]