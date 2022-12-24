dgsLogLuaMemory()
dgsRegisterPluginType("dgs-dxcolorpicker")
dgsRegisterPluginType("dgs-dxcomponentselector")
addEvent("onDgsColorPickerChange",true)
addEvent("onDgsColorPickerComponentSelectorChange",true)

function dgsCreateColorPicker(style,...)
	if not(type(style) == "string") then error(dgsGenAsrt(style,"dgsCreateColorPicker",1,"string")) end
	local args = {...}
	local mainElement
	if style == "HSVRing" then
		local x,y,w,h,relative,parent = args[1],args[2],args[3],args[4],args[5],args[6]
		local HSVRing = dxCreateShader("plugin/ColorPicker/HSVRing.fx")
		local HSVRingImg = dgsCreateImage(x,y,w,h,HSVRing,relative or false,parent)
		dgsSetData(HSVRingImg,"asPlugin","dgs-dxcolorpicker")
		local HSVRingSel = dxCreateShader("plugin/ColorPicker/HSVRingSel.fx")	--The triangle
		local HSVRingSelImg = dgsCreateImage(0.1,0.1,0.8,0.8,HSVRingSel,true,HSVRingImg)
		dgsSetEnabled(HSVRingSelImg,false)
		local PickCircle = dxCreateShader("plugin/ColorPicker/PickCircle.fx")
		local PickCircleImg = dgsCreateImage(0,0,0.06,0.06,PickCircle,true,HSVRingSelImg)
		dgsSetEnabled(PickCircleImg,false)
		dgsSetData(HSVRingImg,"cp_shaders",{HSVRing,HSVRingSel,PickCircle})
		dgsSetData(HSVRingImg,"cp_images",{HSVRingImg,HSVRingSelImg,PickCircleImg})
		dgsAddEventHandler("onDgsMouseDrag",HSVRingImg,"HSVRingChange",false)
		dgsAddEventHandler("onDgsMouseClickDown",HSVRingImg,"HSVRingChange",false)
		dgsAttachToAutoDestroy(HSVRing,HSVRingImg,-1)
		dgsAttachToAutoDestroy(HSVRingSel,HSVRingImg,-2)
		dgsAttachToAutoDestroy(PickCircle,HSVRingImg,-3)
		mainElement = HSVRingImg
	elseif style == "HSLSquare" then
		local x,y,w,h,relative,parent = args[1],args[2],args[3],args[4],args[5],args[6]
		local HSLSquare = dxCreateShader("plugin/ColorPicker/HSLSquare.fx")
		local HSLSquareImg = dgsCreateImage(x,y,w,h,HSLSquare,relative or false,parent)
		dgsSetData(HSLSquareImg,"asPlugin","dgs-dxcolorpicker")
		local PickCircle = dxCreateShader("plugin/ColorPicker/PickCircle.fx")
		local PickCircleImg = dgsCreateImage(0,0,0.06,0.06,PickCircle,true,HSLSquareImg)
		dgsSetEnabled(PickCircleImg,false)
		dgsSetData(HSLSquareImg,"cp_shaders",{HSLSquare,PickCircle})
		dgsSetData(HSLSquareImg,"cp_images",{HSLSquareImg,PickCircleImg})
		dgsAddEventHandler("onDgsMouseDrag",HSLSquareImg,"HSLSquareChange",false)
		dgsAddEventHandler("onDgsMouseClickDown",HSLSquareImg,"HSLSquareChange",false)
		dgsAttachToAutoDestroy(HSLSquare,HSLSquareImg,-1)
		dgsAttachToAutoDestroy(PickCircle,HSLSquareImg,-2)
		mainElement = HSLSquareImg
	elseif style == "HSDisk" then
		local x,y,w,h,relative,parent = args[1],args[2],args[3],args[4],args[5],args[6]
		local HSDisk = dxCreateShader("plugin/ColorPicker/HSDisk.fx")
		local HSDiskImg = dgsCreateImage(x,y,w,h,HSDisk,relative or false,parent)
		dgsSetData(HSDiskImg,"asPlugin","dgs-dxcolorpicker")
		local PickCircle = dxCreateShader("plugin/ColorPicker/PickCircle.fx")
		local PickCircleImg = dgsCreateImage(0,0,0.06,0.06,PickCircle,true,HSDiskImg)
		dgsSetEnabled(PickCircleImg,false)
		dgsSetData(HSDiskImg,"cp_shaders",{HSDisk,PickCircle})
		dgsSetData(HSDiskImg,"cp_images",{HSDiskImg,PickCircleImg})
		dgsAddEventHandler("onDgsMouseDrag",HSDiskImg,"HSDiskChange",false)
		dgsAddEventHandler("onDgsMouseClickDown",HSDiskImg,"HSDiskChange",false)
		dgsAttachToAutoDestroy(HSDisk,HSDiskImg,-1)
		dgsAttachToAutoDestroy(PickCircle,HSDiskImg,-2)
		mainElement = HSDiskImg
	elseif style == "HLDisk" then
		local x,y,w,h,relative,parent = args[1],args[2],args[3],args[4],args[5],args[6]
		local HLDisk = dxCreateShader("plugin/ColorPicker/HLDisk.fx")
		local HLDiskImg = dgsCreateImage(x,y,w,h,HLDisk,relative or false,parent)
		dgsSetData(HLDiskImg,"asPlugin","dgs-dxcolorpicker")
		local PickCircle = dxCreateShader("plugin/ColorPicker/PickCircle.fx")
		local PickCircleImg = dgsCreateImage(0,0,0.06,0.06,PickCircle,true,HLDiskImg)
		dgsSetEnabled(PickCircleImg,false)
		dgsSetData(HLDiskImg,"cp_shaders",{HLDisk,PickCircle})
		dgsSetData(HLDiskImg,"cp_images",{HLDiskImg,PickCircleImg})
		dgsAddEventHandler("onDgsMouseDrag",HLDiskImg,"HLDiskChange",false)
		dgsAddEventHandler("onDgsMouseClickDown",HLDiskImg,"HLDiskChange",false)
		dgsAttachToAutoDestroy(HLDisk,HLDiskImg,-1)
		dgsAttachToAutoDestroy(PickCircle,HLDiskImg,-2)
		mainElement = HLDiskImg
	else
		assert(false,"Bad argument @dgsCreateColorPicker at argument 1, unsupported type "..style)
	end
	if mainElement then
		dgsSetData(mainElement,"componentSelectors",{})
		dgsSetData(mainElement,"style",style)
		dgsColorPickerSetColor(mainElement,0,0,255,255)
		dgsTriggerEvent("onDgsPluginCreate",mainElement,sourceResource)
		return mainElement
	end
	return false
end

function dgsColorPickerCreateComponentSelector(x,y,w,h,voh,relative,parent,thickness,offset)
	local selector,cs
	thickness = thickness or 2
	offset = offset or 4
	if voh then
		cs = dgsCreateImage(x,y,w,h,_,relative,parent)
		selector = dgsCreateImage(0,-offset,thickness,h+offset*2,_,false,cs)
	else
		cs = dgsCreateImage(x,y,w,h,_,relative,parent)
		selector = dgsCreateImage(-offset,0,w+offset*2,thickness,_,false,cs)
	end
	dgsSetEnabled(selector,false)
	dgsSetData(cs,"thickness",thickness)
	dgsSetData(cs,"offset",offset)
	dgsSetData(cs,"asPlugin","dgs-dxcomponentselector")
	dgsSetData(cs,"voh",voh)
	dgsSetData(cs,"cp_images",{cs,selector})
	dgsSetData(cs,"value",0)	--0~100
	dgsSetData(cs,"isReversed",false)
	dgsAddEventHandler("onDgsMouseDrag",cs,"dgsColorPickerComponentChange",false)
	dgsAddEventHandler("onDgsMouseClickDown",cs,"dgsColorPickerComponentChange",false)
	dgsAddEventHandler("onDgsSizeChange",cs,"ComponentResize",false)
	return cs
end

function dgsComponentSelectorSetCursorThickness(cs,thickness)
	if not(dgsGetPluginType(cs) == "dgs-dxcomponentselector") then error(dgsGenAsrt(cs,"dgsComponentSelectorSetCursorThickness",1,"plugin dgs-dxcomponentselector")) end
	return dgsSetData(cs,"thickness",thickness)
end

function dgsComponentSelectorGetCursorThickness(cs)
	if not(dgsGetPluginType(cs) == "dgs-dxcomponentselector") then error(dgsGenAsrt(cs,"dgsComponentSelectorGetCursorThickness",1,"plugin dgs-dxcomponentselector")) end
	return dgsElementData[cs].thickness
end

function dgsColorPickerSetComponentSelectorMask(cs,maskTexture)
	if not(dgsGetPluginType(cs) == "dgs-dxcomponentselector") then error(dgsGenAsrt(cs,"dgsColorPickerSetComponentSelectorMask",1,"plugin dgs-dxcomponentselector")) end
	local shader = dgsElementData[cs].shader
	if maskTexture then
		if shader then
			dxSetShaderValue(shader,"maskTexture",maskTexture)
			dxSetShaderValue(shader,"useMaskTexture",true)
		end
		return dgsSetData(cs,"maskTexture",maskTexture)
	else
		if shader then
			dxSetShaderValue(shader,"maskTexture",nil)
			dxSetShaderValue(shader,"useMaskTexture",false)
		end
		return dgsSetData(cs,"maskTexture",nil)
	end
end

function dgsColorPickerGetComponentSelectorMask(cs)
	if not(dgsGetPluginType(cs) == "dgs-dxcomponentselector") then error(dgsGenAsrt(cs,"dgsColorPickerGetComponentSelectorMask",1,"plugin dgs-dxcomponentselector")) end
	return dgsElementData[cs].maskTexture or false
end

function ComponentResize()
	local thickness = dgsElementData[source].thickness
	local offset =  dgsElementData[source].offset
	local voh = dgsElementData[source].voh
	local value = dgsElementData[source].value
	local absSize = dgsElementData[source].absSize
	local images = dgsElementData[source].cp_images
	local position
	if voh then
		position = value*absSize[1]/100
		dgsSetPosition(images[2],position-thickness/2,-offset,false)
	else
		position = value*absSize[2]/100
		dgsSetPosition(images[2],-offset,position-thickness/2,false)
	end
end

function dgsColorPickerComponentChange()
	local cx,cy = dgsGetCursorPosition(source)
	local absSize = dgsElementData[source].absSize
	local voh = dgsElementData[source].voh
	local absSize = dgsElementData[source].absSize
	local position
	if voh then
		position = cx/absSize[1]*100
	else
		position = cy/absSize[2]*100
	end
	local isReversed = dgsElementData[source].isReversed
	position = isReversed and 100-position or position
	dgsColorPickerSetComponentSelectorValue(source,position)
end

function dgsColorPickerGetComponentSelectorValue(cs)
	if not(dgsGetPluginType(cs) == "dgs-dxcomponentselector") then error(dgsGenAsrt(cs,"dgsColorPickerGetComponentSelectorValue",1,"plugin dgs-dxcomponentselector")) end
	return dgsElementData[cs].value
end

function dgsColorPickerSetComponentSelectorValue(cs,value)
	if not(dgsGetPluginType(cs) == "dgs-dxcomponentselector") then error(dgsGenAsrt(cs,"dgsColorPickerSetComponentSelectorValue",1,"plugin dgs-dxcomponentselector")) end
	if not(type(value) == "number") then error(dgsGenAsrt(value,"dgsColorPickerSetComponentSelectorValue",2,"number")) end
	local thickness = dgsElementData[cs].thickness
	local offset =  dgsElementData[cs].offset
	local voh = dgsElementData[cs].voh
	local oldV = dgsElementData[cs].value
	local value = math.clamp(value,0,100)
	dgsSetData(cs,"value",value)
	local absSize = dgsElementData[cs].absSize
	local images = dgsElementData[cs].cp_images
	local isReversed = dgsElementData[cs].isReversed
	value = isReversed and 100-value or value
	if voh then
		dgsSetPosition(images[2],value*absSize[1]/100-thickness/2,-offset,false)
	else
		dgsSetPosition(images[2],-offset,value*absSize[2]/100-thickness/2,false)
	end
	dgsTriggerEvent("onDgsColorPickerComponentSelectorChange",cs,value,oldV)
end

AvailableColorType = {
	RGB={R={1,255},G={2,255},B={3,255}},
	HSL={H={1,360},S={2,100},L={3,100}},
	HSV={H={1,360},S={2,100},V={3,100}},
}
ColorAttributeOrder = {
	RGB={"R","G","B"},
	HSL={"H","S","L"},
	HSV={"H","S","V"},
}

updateSelectorOnColorChange_ComponentSelector = function()
	local source = source
	if dgsElementData[source].setCool then return end
	local cp = dgsElementData[source].bindColorPicker
	if not isElement(cp) then return dgsUnbindFromColorPicker(source) end
	local colorType = dgsElementData[source].colorType
	local colorAttribute = dgsElementData[source].colorAttribute
	if colorAttribute == "A" then
		dgsElementData[source].setCool = true
		dgsColorPickerSetComponentSelectorValue(source,dgsElementData[cp].A/255*100)
		local shader = dgsElementData[source].shader
		local R,G,B = dgsColorPickerGetColor(cp,"RGB")
		dxSetShaderValue(shader,"currentColor",{R/255,G/255,B/255,1})
		dgsElementData[source].setCool = false
		return
	end
	local attrID = AvailableColorType[colorType][colorAttribute][1]
	dgsElementData[source].setCool = true
	local val = dgsElementData[cp][colorType][attrID]/AvailableColorType[colorType][colorAttribute][2]*100
	dgsColorPickerSetComponentSelectorValue(source,val)
	dgsElementData[source].setCool = false
	local shader = dgsElementData[source].shader
	local X,Y,Z = dgsColorPickerGetColor(cp,colorType)
	local ScaleX = AvailableColorType[colorType][ColorAttributeOrder[colorType][1]][2]
	local ScaleY = AvailableColorType[colorType][ColorAttributeOrder[colorType][2]][2]
	local ScaleZ = AvailableColorType[colorType][ColorAttributeOrder[colorType][3]][2]
	dxSetShaderValue(shader,colorType,{X/ScaleX,Y/ScaleY,Z/ScaleZ,1})
end

updateColorOnSelectorChange_ComponentSelector = function()
	local source = source
	if dgsElementData[source].setCool then return end
	local cp = dgsElementData[source].bindColorPicker
	if not isElement(cp) then return dgsUnbindFromColorPicker(source) end
	local colorType = dgsElementData[source].colorType
	local colorAttribute = dgsElementData[source].colorAttribute
	local value = dgsColorPickerGetComponentSelectorValue(source)/100
	if value then
		if colorAttribute == "A" then
			dgsElementData[source].setCool = true
			dgsColorPickerSetColor(cp,_,_,_,value*255,colorType)
			dgsElementData[source].setCool = false
			return
		end
		value = AvailableColorType[colorType][colorAttribute][2]*value
		dgsElementData[source].setCool = true
		if colorType == "RGB" then
			local RGB = {R=nil,G=nil,B=nil}
			RGB[colorAttribute] = value
			dgsColorPickerSetColor(cp,RGB.R,RGB.G,RGB.B,_,colorType)
		elseif colorType == "HSL" then
			local HSL = {H=nil,S=nil,L=nil}
			HSL[colorAttribute] = value
			dgsColorPickerSetColor(cp,HSL.H,HSL.S,HSL.L,_,colorType)
		elseif colorType == "HSV" then
			local HSV = {H=nil,S=nil,V=nil}
			HSV[colorAttribute] = value
			dgsColorPickerSetColor(cp,HSV.H,HSV.S,HSV.V,_,colorType)
		end
		dgsElementData[source].setCool = false
	end
end

updateSelectorOnColorChange_ScrollBar = function()
	local source = source
	if dgsElementData[source].setCool then return end
	local cp = dgsElementData[source].bindColorPicker
	if not isElement(cp) then return dgsUnbindFromColorPicker(source) end
	local colorType = dgsElementData[source].colorType
	local colorAttribute = dgsElementData[source].colorAttribute
	if colorAttribute == "A" then
		dgsElementData[source].setCool = true
		dgsScrollBarSetScrollPosition(source,dgsElementData[cp].A/255*100)
		dgsElementData[source].setCool = false
		return
	end
	local attrID = AvailableColorType[colorType][colorAttribute][1]
	dgsElementData[source].setCool = true
	local val = dgsElementData[cp][colorType][attrID]/AvailableColorType[colorType][colorAttribute][2]*100
	dgsScrollBarSetScrollPosition(source,val)
	dgsElementData[source].setCool = false
end

updateColorOnSelectorChange_ScrollBar = function()
	local source = source
	if dgsElementData[source].setCool then return end
	local cp = dgsElementData[source].bindColorPicker
	if not isElement(cp) then return dgsUnbindFromColorPicker(source) end
	local colorType = dgsElementData[source].colorType
	local colorAttribute = dgsElementData[source].colorAttribute
	local value = dgsScrollBarGetScrollPosition(source)/100
	if value then
		if colorAttribute == "A" then
			dgsElementData[source].setCool = true
			dgsColorPickerSetColor(cp,_,_,_,value,colorType)
			dgsElementData[source].setCool = false
			return
		end
		dgsElementData[source].setCool = true
		value = AvailableColorType[colorType][colorAttribute][2]*value
		if colorType == "RGB" then
			local RGB = {R=nil,G=nil,B=nil}
			RGB[colorAttribute] = value
			dgsColorPickerSetColor(cp,RGB.R,RGB.G,RGB.B,_,colorType)
		elseif colorType == "HSL" then
			local HSL = {H=nil,S=nil,L=nil}
			HSL[colorAttribute] = value
			dgsColorPickerSetColor(cp,HSL.H,HSL.S,HSL.L,_,colorType)
		elseif colorType == "HSV" then
			local HSV = {H=nil,S=nil,V=nil}
			HSV[colorAttribute] = value
			dgsColorPickerSetColor(cp,HSV.H,HSV.S,HSV.V,_,colorType)
		end
		dgsElementData[source].setCool = false
	end
end

updateSelectorOnColorChange_EditLabel = function()
	local source = source
	if dgsElementData[source].setCool then return end
	local cp = dgsElementData[source].bindColorPicker
	if not isElement(cp) then return dgsUnbindFromColorPicker(source) end
	local colorType = dgsElementData[source].colorType
	local colorAttribute = dgsElementData[source].colorAttribute
	if colorAttribute == "A" then
		dgsElementData[source].setCool = true
		dgsSetText(source,tostring(math.floor(dgsElementData[cp].A)))
		dgsElementData[source].setCool = false
		return
	end
	dgsElementData[source].setCool = true
	if colorType == "#RGBAHEX" then
		local RGBA = "#"
		for i=1,#colorAttribute do
			local colorAttr = colorAttribute:sub(i,i)
			if colorAttr == "A" then
				RGBA = RGBA..string.format("%02X",tostring(math.floor(dgsElementData[cp]["A"])))
			else
				local attrID = AvailableColorType["RGB"][colorAttr][1]
				RGBA = RGBA..string.format("%02X",tostring(math.floor(dgsElementData[cp]["RGB"][attrID])))
			end
		end
		dgsSetText(source,RGBA)
	elseif colorType == "RGBAHEX" then
		local RGBA = ""
		for i=1,#colorAttribute do
			local colorAttr = colorAttribute:sub(i,i)
			if colorAttr == "A" then
				RGBA = RGBA..string.format("%02X",tostring(math.floor(dgsElementData[cp]["A"])))
			else
				local attrID = AvailableColorType["RGB"][colorAttr][1]
				RGBA = RGBA..string.format("%02X",tostring(math.floor(dgsElementData[cp]["RGB"][attrID])))
			end
		end
		dgsSetText(source,RGBA)
	else
		local attrID = AvailableColorType[colorType][colorAttribute][1]
		dgsSetText(source,tostring(math.floor(dgsElementData[cp][colorType][attrID])))
	end
	dgsElementData[source].setCool = false
end
		
updateColorOnSelectorChange_EditLabel = function()
	local source = source
	if dgsElementData[source].setCool then return end
	local cp = dgsElementData[source].bindColorPicker
	if not isElement(cp) then return dgsUnbindFromColorPicker(source) end
	local colorType = dgsElementData[source].colorType
	local colorAttribute = dgsElementData[source].colorAttribute
	local colorValue = dgsGetProperty(source,changeProperty or "text")
	local value = tonumber(colorValue)
	if value then
		if colorAttribute == "A" then
			dgsElementData[source].setCool = true
			dgsColorPickerSetColor(cp,_,_,_,value,colorType)
			dgsElementData[source].setCool = false
			return
		end
		dgsElementData[source].setCool = true
		if colorType == "RGB" then
			local RGB = {R=nil,G=nil,B=nil}
			RGB[colorAttribute] = value
			dgsColorPickerSetColor(cp,RGB.R,RGB.G,RGB.B,_,colorType)
		elseif colorType == "HSL" then
			local HSL = {H=nil,S=nil,L=nil}
			HSL[colorAttribute] = value
			dgsColorPickerSetColor(cp,HSL.H,HSL.S,HSL.L,_,colorType)
		elseif colorType == "HSV" then
			local HSV = {H=nil,S=nil,V=nil}
			HSV[colorAttribute] = value
			dgsColorPickerSetColor(cp,HSV.H,HSV.S,HSV.V,_,colorType)
		end
		dgsElementData[source].setCool = false
	else
		if colorType == "#RGBAHEX" then
			local colorAttrLen = #colorAttribute
			if colorValue:sub(1,1) == "#" and #colorValue == colorAttrLen*2+1 then
				local RGB = {R=nil,G=nil,B=nil,A=nil}
				for i=1,colorAttrLen do
					RGB[colorAttribute:sub(i,i)] = tonumber(colorValue:sub(i*2,i*2+1),16)
				end
				dgsColorPickerSetColor(cp,RGB.R,RGB.G,RGB.B,RGB.A,"RGB")
			end
		elseif colorType == "RGBAHEX" then
			local colorAttrLen = #colorAttribute
			if #colorValue == colorAttrLen*2 then
				local RGB = {R=nil,G=nil,B=nil,A=nil}
				for i=1,colorAttrLen do
					RGB[colorAttribute:sub(i,i)] = tonumber(colorValue:sub(i*2-1,i*2),16)
				end
				dgsColorPickerSetColor(cp,RGB.R,RGB.G,RGB.B,RGB.A,"RGB")
			end
		end
	end
end

function dgsBindToColorPicker(cs,colorPicker,colorType,colorAttribute,staticMode,isReversed)
	if not(dgsIsType(cs)) then error(dgsGenAsrt(cs,"dgsBindToColorPicker",1,"dgs-dxgui")) end
	if not(dgsGetPluginType(colorPicker) == "dgs-dxcolorpicker") then error(dgsGenAsrt(colorPicker,"dgsBindToColorPicker",2,"plugin dgs-dxcolorpicker")) end
	if colorAttribute ~= "A" and colorType ~= "#RGBAHEX" and colorType ~= "RGBAHEX"  then
		if not(AvailableColorType[colorType]) then error(dgsGenAsrt(colorType,"dgsBindToColorPicker",3,"string","RGB/HSL/HSV/#RGBAHEX/RGBAHEX")) end
		if not(AvailableColorType[colorType][colorAttribute]) then error(dgsGenAsrt(colorAttribute,"dgsBindToColorPicker",4,"string",table.concat(ColorAttributeOrder[colorType],"/"))) end
	end
	local targetPlugin = dgsGetPluginType(cs)
	local lastColorPicker = dgsElementData[cs].bindColorPicker
	if lastColorPicker then
		dgsUnbindFromColorPicker(cs)
	end
	local componentSelectors = dgsElementData[colorPicker].componentSelectors
	componentSelectors[cs] = true
	dgsSetData(cs,"bindColorPicker",colorPicker)
	dgsSetData(cs,"isReversed",isReversed)
	dgsSetData(cs,"colorType",colorType)
	dgsSetData(cs,"colorAttribute",colorAttribute)
	if targetPlugin == "dgs-dxcomponentselector" then
		local shader = dgsElementData[cs].shader
		if isElement(shader) then destroyElement(shader) end
		if colorAttribute == "A" then
			local ALPComponent = dxCreateShader("plugin/ColorPicker/ALPComponent.fx")
			dgsSetData(cs,"shader",ALPComponent)
			dgsImageSetImage(cs,ALPComponent)
			dxSetShaderValue(ALPComponent,"vertical",dgsElementData[cs].voh)
			dxSetShaderValue(ALPComponent,"isReversed",isReversed and true or false)
		elseif colorType == "RGB" then
			local RGBComponent = dxCreateShader("plugin/ColorPicker/RGBComponent.fx")
			dgsSetData(cs,"shader",RGBComponent)
			local colorID = AvailableColorType[colorType][colorAttribute][1]
			local RGBCHG = {0,0,0}
			RGBCHG[colorID] = 1
			dgsImageSetImage(cs,RGBComponent)
			dxSetShaderValue(RGBComponent,"RGB_Chg",RGBCHG)
			dxSetShaderValue(RGBComponent,"vertical",dgsElementData[cs].voh)
			dxSetShaderValue(RGBComponent,"isReversed",isReversed and true or false)
			if staticMode then
				dxSetShaderValue(RGBComponent,"StaticMode",{0,0,0})
			else
				dxSetShaderValue(RGBComponent,"StaticMode",{1,1,1})
			end
		elseif colorType == "HSL" then
			local HSLComponent = dxCreateShader("plugin/ColorPicker/HSLComponent.fx")
			dgsSetData(cs,"shader",HSLComponent)
			dgsImageSetImage(cs,HSLComponent)
			local colorID = AvailableColorType[colorType][colorAttribute][1]
			local HSLCHG = {0,0,0}
			HSLCHG[colorID] = 1
			dxSetShaderValue(HSLComponent,"HSL_Chg",HSLCHG)
			dxSetShaderValue(HSLComponent,"vertical",dgsElementData[cs].voh)
			dxSetShaderValue(HSLComponent,"isReversed",isReversed and true or false)
			if staticMode then
				dxSetShaderValue(HSLComponent,"StaticMode",{1,0,0})
			else
				dxSetShaderValue(HSLComponent,"StaticMode",{1,1,1})
			end
		elseif colorType == "HSV" then
			local HSVComponent = dxCreateShader("plugin/ColorPicker/HSVComponent.fx")
			dgsSetData(cs,"shader",HSVComponent)
			dgsImageSetImage(cs,HSVComponent)
			local colorID = AvailableColorType[colorType][colorAttribute][1]
			local HSVCHG = {0,0,0}
			HSVCHG[colorID] = 1
			dxSetShaderValue(HSVComponent,"HSV_Chg",HSVCHG)
			dxSetShaderValue(HSVComponent,"vertical",dgsElementData[cs].voh)
			dxSetShaderValue(HSVComponent,"isReversed",isReversed and true or false)
			if staticMode then
				dxSetShaderValue(HSVComponent,"StaticMode",{1,0,0})
			else
				dxSetShaderValue(HSVComponent,"StaticMode",{1,1,1})
			end
		end
		
		if dgsElementData[cs].maskTexture then
			dxSetShaderValue(shader,"maskTexture",maskTexture)
			dxSetShaderValue(shader,"useMaskTexture",true)
		end
		dgsAddEventHandler("onDgsColorPickerComponentSelectorChange",cs,"updateColorOnSelectorChange_ComponentSelector",false)
		source = cs
		updateSelectorOnColorChange_ComponentSelector()
	elseif targetPlugin == "dgs-dxscrollbar" then
		dgsAddEventHandler("onDgsElementScroll",cs,"updateColorOnSelectorChange_ScrollBar",false)
		source = cs
		updateSelectorOnColorChange_ScrollBar()
	elseif targetPlugin == "dgs-dxlabel" or targetPlugin == "dgs-dxedit" then
		dgsAddEventHandler("onDgsTextChange",cs,"updateColorOnSelectorChange_EditLabel",false)
		source = cs
		updateSelectorOnColorChange_EditLabel()
	else
		assert(false,"Bad argument at argument 1, unsupported type "..targetPlugin)
	end
	return true
end

function dgsUnbindFromColorPicker(cs)
	if not(dgsIsType(cs)) then error(dgsGenAsrt(cs,"dgsUnbindFromColorPicker",1,"dgs-dxgui")) end
	local bound = dgsElementData[cs].bindColorPicker
	local shader = dgsElementData[cs].shader
	if isElement(shader) then
		destroyElement(shader)
		dgsElementData[cs].shader = nil
	end
	dgsSetData(cs,"colorType",nil)
	dgsSetData(cs,"colorAttribute",nil)
	if bound then
		local targetPlugin = dgsGetPluginType(cs)
		if targetPlugin == "dgs-dxcomponentselector" then
			dgsRemoveEventHandler("onDgsColorPickerComponentSelectorChange",cs,"updateColorOnSelectorChange_ComponentSelector")
		elseif targetPlugin == "dgs-dxscrollbar" then
			dgsRemoveEventHandler("onDgsElementScroll",cs,"updateColorOnSelectorChange_ScrollBar")
		elseif targetPlugin == "dgs-dxlabel" or targetPlugin == "dgs-dxedit" then
			dgsRemoveEventHandler("onDgsTextChange",cs,"updateColorOnSelectorChange_EditLabel")
		end
		dgsElementData[cs].bindColorPicker = nil
		local componentSelectors = dgsElementData[bound].componentSelectors
		componentSelectors[cs] = nil
		return true
	end
	return false
end

function dgsColorPickerUpdate(cp)
	local shaders = dgsElementData[cp].cp_shaders
	local images = dgsElementData[cp].cp_images
	local style = dgsElementData[cp].style
	if style == "HSVRing" then
		dxSetShaderValue(shaders[2],"Hue",dgsElementData[cp].HSV[1]/360)
		local pAbsSize = dgsElementData[ images[2] ].absSize
		local absSize = dgsElementData[ images[3] ].absSize
		local x,y = dgsProjectHSVToXY(dgsElementData[cp].HSV[1],dgsElementData[cp].HSV[2],dgsElementData[cp].HSV[3])
		local x,y = x-absSize[1]/pAbsSize[1]/2,y-absSize[2]/pAbsSize[2]/2
		dgsSetPosition(images[3],x,y,true)
	elseif style == "HSLSquare" then
		local pAbsSize = dgsElementData[ images[1] ].absSize
		local absSize = dgsElementData[ images[2] ].absSize
		local x,y = HSLToXY(dgsElementData[cp].HSL[1],dgsElementData[cp].HSL[2])
		local x,y = x-absSize[1]/pAbsSize[1]/2,y-absSize[2]/pAbsSize[2]/2
		dgsSetPosition(images[2],x,y,true)
	elseif style == "HSDisk" then
		dxSetShaderValue(shaders[2],"Hue",dgsElementData[cp].HSL[1]/360)
		local pAbsSize = dgsElementData[ images[1] ].absSize
		local absSize = dgsElementData[ images[2] ].absSize
		local x,y = HSToRR(dgsElementData[cp].HSL[1],dgsElementData[cp].HSL[2])
		local x,y = x-absSize[1]/pAbsSize[1]/2,y-absSize[2]/pAbsSize[2]/2
		dgsSetPosition(images[2],x,y,true)
	elseif style == "HLDisk" then
		dxSetShaderValue(shaders[2],"Hue",dgsElementData[cp].HSL[1]/360)
		local pAbsSize = dgsElementData[ images[1] ].absSize
		local absSize = dgsElementData[ images[2] ].absSize
		local x,y = HLToRR(dgsElementData[cp].HSL[1],dgsElementData[cp].HSL[3])
		local x,y = x-absSize[1]/pAbsSize[1]/2,y-absSize[2]/pAbsSize[2]/2
		dgsSetPosition(images[2],x,y,true)
	end
end

function dgsColorPickerSetColor(cp,...)
	if not(dgsGetPluginType(cp) == "dgs-dxcolorpicker") then error(dgsGenAsrt(cp,"dgsColorPickerSetColor",1,"plugin dgs-dxcolorpicker")) end
	local args = {...}
	local newColorRGB,newColorHSL,newColorHSV
	args[5] = args[5] or "RGB"
	if args[5] == "HSL" then
		local color = dgsElementData[cp].HSL
		local h,s,l = args[1] or color[1] or 360,args[2] or color[2] or 100,args[3] or color[3] or 100
		h = math.clamp(h,0,360)
		s = math.clamp(s,0,100)
		l = math.clamp(l,0,100)
		newColorRGB = {HSL2RGB(h,s,l)}
		newColorHSL = {h,s,l}
		newColorHSV = {HSL2HSV(h,s,l)}
	elseif args[5] == "HSV" then
		local color = dgsElementData[cp].HSV
		local h,s,v = args[1] or color[1] or 360,args[2] or color[2] or 100,args[3] or color[3] or 100
		h = math.clamp(h,0,360)
		s = math.clamp(s,0,100)
		v = math.clamp(v,0,100)
		newColorRGB = {HSV2RGB(h,s,v)}
		newColorHSV = {h,s,v}
		newColorHSL = {HSV2HSL(h,s,v)}
	elseif args[5] == "RGB" then
		local color = dgsElementData[cp].RGB
		local r,g,b = args[1] or color[1] or 255,args[2] or color[2] or 255,args[3] or color[3] or 255
		r = math.clamp(r,0,255)
		g = math.clamp(g,0,255)
		b = math.clamp(b,0,255)
		newColorRGB = {r,g,b}
		newColorHSL = {RGB2HSL(r,g,b)}
		newColorHSV = {HSL2HSV(newColorHSL[1],newColorHSL[2],newColorHSL[3])}
	end
	local componentSelectors = dgsElementData[cp].componentSelectors
	local oldRGB = dgsElementData[cp].RGB
	local oldHSL = dgsElementData[cp].HSL
	local oldHSV = dgsElementData[cp].HSV
	local oldAlp = dgsElementData[cp].A
	newA = args[4] or dgsElementData[cp].A or 255
	dgsSetData(cp,"HSL",newColorHSL)
	dgsSetData(cp,"HSV",newColorHSV)
	dgsSetData(cp,"RGB",newColorRGB)
	dgsSetData(cp,"A",newA)
	dgsTriggerEvent("onDgsColorPickerChange",cp,oldRGB,oldHSL,oldHSV,oldAlp)
	for cs,_ in pairs(componentSelectors) do
		if not isElement(cs) then componentSelectors[cs] = nil end
		local csType = dgsGetPluginType(cs)
		if csType == "dgs-dxcomponentselector" then
			source = cs
			updateSelectorOnColorChange_ComponentSelector()
		elseif csType == "dgs-dxscrollbar" then
			source = cs
			updateSelectorOnColorChange_ScrollBar()
		elseif csType == "dgs-dxedit" or csType == "dgs-dxlabel" then
			source = cs
			updateSelectorOnColorChange_EditLabel()
		end
	end
	dgsColorPickerUpdate(cp)
end

function dgsColorPickerGetColor(cp,mode)
	if not(dgsGetPluginType(cp) == "dgs-dxcolorpicker") then error(dgsGenAsrt(cp,"dgsColorPickerGetColor",1,"plugin dgs-dxcolorpicker")) end
	mode = mode or "RGB"
	local COLOR = dgsElementData[cp][mode] or {}
	local A = dgsElementData[cp].A or false
	COLOR[1] = COLOR[1] and COLOR[1]-COLOR[1]%1 or false
	COLOR[2] = COLOR[2] and COLOR[2]-COLOR[2]%1 or false
	COLOR[3] = COLOR[3] and COLOR[3]-COLOR[3]%1 or false
	A = A and A-A%1 or false
	return COLOR[1],COLOR[2],COLOR[3],A
end

---------------------HSLSquare Color Picker
function HSLSquareChange()
	local cx,cy = dgsGetCursorPosition(source)
	local absSize = dgsElementData[source].absSize
	local H,S = XYToHSL(cx/absSize[1],cy/absSize[2])
	dgsColorPickerSetColor(source,H,S,_,_,"HSL")
end

function HSLToXY(H,S)
	return H/360,1-S/100
end

function XYToHSL(X,Y)
	local H,S = X*360,Y*100
	return H-H%1,100-(S-S%1)
end
---------------------HSVRing Color Picker
function HSVRingChange()
	local cx,cy = dgsGetCursorPosition()
	if eventName == "onDgsMouseClickDown" then
		local rot,CenDisX,CenDisY = dgsFindRotationByCenter(source,cx,cy,90)
		local clickRadius = (CenDisX^2+CenDisY^2)^0.5
		dgsSetData(source,"clickRadius",clickRadius)
		if clickRadius >= 0.4 and clickRadius <= 0.5 then
			dgsColorPickerSetColor(source,rot,_,_,_,"HSV")
		elseif clickRadius< 0.4 then
			local HSV = dgsElementData[source].HSV
			local S,V = dgsProjectHXYToSV(HSV[1],CenDisX,CenDisY)
			dgsColorPickerSetColor(source,_,S,V,_,"HSV")
		end
	else
		local clickRadius = dgsElementData[source].clickRadius or 1
		if clickRadius >= 0.4 and clickRadius <= 0.5 then
			local rot = dgsFindRotationByCenter(source,cx,cy,90)
			dgsColorPickerSetColor(source,rot,_,_,_,"HSL")
		elseif clickRadius< 0.4 then
			local rot,CenDisX,CenDisY = dgsFindRotationByCenter(source,cx,cy,90)
			local HSV = dgsElementData[source].HSV
			local S,V = dgsProjectHXYToSV(HSV[1],CenDisX,CenDisY)
			dgsColorPickerSetColor(source,_,S,V,_,"HSV")
		end
	end
end

function dgsProjectHSVToXY(H,S,V)
	local H = math.rad(H+180)
	local S,V = S/100,V/100
	y = (6*V-3-3*V*S)/2/math.sqrt(3)/2
	x = (1-3*V*S)/2/2
	local rotedi = {math.cos(H),math.sin(H)}
	local rotedj = {math.cos(H-math.rad(90)),math.sin(H-math.rad(90))}
	local x,y = x*rotedi[1]+y*rotedi[2],x*rotedj[1]+y*rotedj[2]
	return x+0.5,y+0.5
end

function dgsProjectHXYToSV(H,x,y)
	local H = math.rad(H+180)
	local rotedi = {math.cos(H-math.rad(90)),math.sin(H-math.rad(90))}
	local rotedj = {math.cos(H),math.sin(H)}
	local x,y = x*rotedi[1]+y*rotedi[2],x*rotedj[1]+y*rotedj[2]
	x,y = x/0.4,y/0.4
	local S,V = (1-2*y)/(math.sqrt(3)*x-y+2)*100,(math.sqrt(3)*x-y+2)/3*100
	return S-S%1,V-V%1
end


---------------------HSDisk Color Picker
function HSDiskChange()
	local cx,cy = dgsGetCursorPosition()
	local rot,CenDisX,CenDisY = dgsFindRotationByCenter(source,cx,cy,90)
	local clickRadius = (CenDisX^2+CenDisY^2)^0.5*2
	clickRadius = clickRadius<=1 and clickRadius or 1
	dgsColorPickerSetColor(source,rot,clickRadius*100,_,_,"HSL")
end

function HSToRR(H,S)
	local H = math.rad(H)
	local S = S/100/2
	local x,y = math.cos(H)*S,math.sin(H)*S
	return x+0.5,y+0.5
end

---------------------HLDisk Color Picker
function HLDiskChange()
	local cx,cy = dgsGetCursorPosition()
	local rot,CenDisX,CenDisY = dgsFindRotationByCenter(source,cx,cy,90)
	local clickRadius = (CenDisX^2+CenDisY^2)^0.5
	clickRadius = clickRadius <= 0.5 and clickRadius or 0.5
	dgsColorPickerSetColor(source,rot,_,(1-clickRadius)*100,_,"HSL")
end

function HLToRR(H,L)
	local H = math.rad(H)
	local L = 0.5-L/100/2
	local x,y = math.cos(H)*L*2,math.sin(H)*L*2
	return x+0.5,y+0.5
end

----Output Functions
function dgsHSLToHSV(H,S,L,A)
	local _H,_S,_V = HSL2HSV(H,S,L)
	return _H,_S,_V,A
end

function dgsHSVToHSL(H,S,V,A)
	local _H,_S,_L = HSV2HSL(H,S,V)
	return _H,_S,_L,A
end

function dgsHSLToRGB(H,S,L,A)
	local R,G,B = HSL2RGB(H,S,L)
	return R,G,B,A
end

function dgsHSVToRGB(H,S,V,A)
	local R,G,B = HSV2RGB(H,S,V)
	return R,G,B,A
end

function dgsRGBToHSL(R,G,B,A)
	local H,S,L = RGB2HSV(R,G,B)
	return H,S,L,A
end

function dgsRGBToHSV(R,G,B,A)
	local H,S,V = RGB2HSV(R,G,B)
	return H,S,V,A
end