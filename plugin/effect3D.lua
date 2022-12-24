dgsLogLuaMemory()
dgsRegisterPluginType("dgs-dxeffect3d")
local effect3DShader

function dgsCreateEffect3D(rotFactor)
	local effect3d = dxCreateShader(effect3DShader)
	dgsSetData(effect3d,"asPlugin","dgs-dxeffect3d")
	dgsSetData(effect3d,"rotFactor",rotFactor or 2)
	dgsSetData(effect3d,"alwaysEnable",false)
	dgsSetData(effect3d,"applyToScrollPane",nil)
	dgsTriggerEvent("onDgsPluginCreate",effect3d,sourceResource)
	return effect3d
end

function dgsEffect3DApplyToScrollPane(effect3d,scrollpane)
	if not(dgsGetPluginType(effect3d) == "dgs-dxeffect3d") then error(dgsGenAsrt(effect3d,"dgsEffect3DApplyToScrollPane",1,"plugin dgs-dxeffect3d")) end
	if not(dgsGetType(scrollpane) == "dgs-dxscrollpane") then error(dgsGenAsrt(scrollpane,"dgsEffect3DApplyToScrollPane",2,"dgs-dxscrollpane")) end
	dgsEffect3DRemoveFromScrollPane(effect3d)
	dgsSetData(effect3d,"applyToScrollPane",scrollpane)
	dgsSetData(scrollpane,"filter",{effect3d,0,0,0,0,0})
	dgsSetData(scrollpane,"enableFullEnterLeaveCheck",true)
	dgsSetData(scrollpane,"renderEventCall",true)
	addEventHandler("onDgsElementRender",scrollpane,dgsEffect3DMouseMoveCheck,true)
end

function dgsEffect3DMouseMoveCheck()
	local filter = dgsElementData[source].filter
	if not isElement(filter[1]) then 
		removeEventHandler("onDgsElementRender",source,dgsEffect3DMouseMoveCheck)
		dgsEffect3DRemoveFromScrollPane(source)
	end
	local alwaysEnable = dgsElementData[ filter[1] ].alwaysEnable
	if not isCursorShowing() then return false end
	if dgsIsMouseWithinGUI(source) or alwaysEnable then
		local x,y = dgsGetCursorPosition()
		local spx,spy = dgsGetPosition(source,false,true)
		local w,h = dgsElementData[source].absSize[1],dgsElementData[source].absSize[2]
		local rotFactor = dgsElementData[filter[1]].rotFactor
		local dx,dy = (spx+w/2)-x,(spy+h/2)-y
		local dx,dy = -dx/w*rotFactor,dy/h*rotFactor
		filter[2] = dx
		filter[3] = dy
	end
end

function dgsEffect3DSetRotationFactor(effect3d,rotFactor)
	if not(dgsGetPluginType(effect3d) == "dgs-dxeffect3d") then error(dgsGenAsrt(rectShader,"dgsEffect3DSetRotationFactor",1,"plugin dgs-dxeffect3d")) end
	assert(type(rotFactor) == "number","Bad argument @dgsEffect3DSetRotationFactor at argument 2, expect number got "..type(rotFactor))
	return dgsSetData(effect3d,"rotFactor",rotFactor)
end

function dgsEffect3DGetRotationFactor(effect3d)
	if not(dgsGetPluginType(effect3d) == "dgs-dxeffect3d") then error(dgsGenAsrt(rectShader,"dgsEffect3DGetRotationFactor",1,"plugin dgs-dxeffect3d")) end
	return dgsElementData[effect3d].rotFactor
end

function dgsEffect3DSetAlwaysEnabled(effect3d,state)
	if not(dgsGetPluginType(effect3d) == "dgs-dxeffect3d") then error(dgsGenAsrt(rectShader,"dgsEffect3DSetAlwaysEnabled",1,"plugin dgs-dxeffect3d")) end
	assert(type(state) == "boolean","Bad argument @dgsEffect3DSetAlwaysEnabled at argument 2, expect boolean got "..type(state))
	return dgsSetData(effect3d,"alwaysEnable",state)
end

function dgsEffect3DGetAlwaysEnabled(effect3d)
	if not(dgsGetPluginType(effect3d) == "dgs-dxeffect3d") then error(dgsGenAsrt(rectShader,"dgsEffect3DGetAlwaysEnabled",1,"plugin dgs-dxeffect3d")) end
	return dgsElementData[effect3d].alwaysEnable
end
	
function dgsEffect3DRemoveFromScrollPane(effect3d)
	if dgsGetPluginType(effect3d) == "dgs-dxeffect3d" then
		local sp = dgsElementData[effect3d].applyToScrollPane
		if dgsGetType(sp) == "dgs-dxscrollpane" then
			dgsSetData(sp,"renderEventCall",false)
			removeEventHandler("onDgsElementRender",sp,dgsEffect3DMouseMoveCheck)
			dgsSetData(sp,"filter",nil)
		end
		dgsSetData(sp,"enableFullEnterLeaveCheck",false)
		return dgsSetData(effect3d,"applyToScrollPane",nil)
	elseif dgsGetType(effect3d) == "dgs-dxscrollpane" then
		local sp = effect3d
		local filter = dgsElementData[sp].filter
		if filter then
			local effect3d = filter[1]
			dgsSetData(sp,"renderEventCall",false)
			removeEventHandler("onDgsElementRender",sp,dgsEffect3DMouseMoveCheck)
			if isElement(effect3d) then
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
