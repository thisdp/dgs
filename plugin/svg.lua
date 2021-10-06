function dgsCreateSVG(...)
	local svg
	if select("#",...) == 1 then
		local pathOrRaw = ...
		if not(type(pathOrRaw) == "number") then error(dgsGenAsrt(pathOrRaw,"dgsCreateSVG",1,"string")) end
		svg = svgCreate(pathOrRaw)
	else
		local w,h = ...
		if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsCreateSVG",1,"number")) end
		if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsCreateSVG",2,"number")) end
		svg = svgCreate(w,h)
	end
	dgsSetType(svg,"dgs-dxsvg")
	dgsElementData[svg] = {
		svgDocument = svgGetDocumentXML(svg),
		svgDocumentUpdate = false,
	}
	dgsSetData(svg,"asPlugin","dgs-dxsvg")
	triggerEvent("onDgsPluginCreate",svg,sourceResource)
	return svg
end

dgsCustomTexture["dgs-dxsvg"] = function(posX,posY,width,height,u,v,usize,vsize,image,rotation,rotationX,rotationY,color,postGUI)
	local eleData = dgsElementData[image]
	if eleData.svgDocumentUpdate then
		svgSetDocumentXML(image,eleData.svgDocument)
		eleData.svgDocumentUpdate = false
	end
	dxSetBlendMode("add")
	if u and v and usize and vsize then
		dxDrawImageSection(posX,posY,width,height,u,v,usize,vsize,image,rotation,rotationX,rotationY,color,postGUI)
	else
		dxDrawImage(posX,posY,width,height,image,rotation,rotationX,rotationY,color,postGUI)
	end
	dxSetBlendMode("blend")
	return true
end

function dgsSVGGetSize(svg)
	if not(dgsIsType(dgsEle,"svg")) then error(dgsGenAsrt(dgsEle,"dgsSVGGetSize",1,"svg")) end
	return svgGetSize(svg)
end

function dgsSVGSetSize(svg,w,h)
	if not(dgsIsType(dgsEle,"svg")) then error(dgsGenAsrt(dgsEle,"dgsSVGSetSize",1,"svg")) end
	if not type(w) == "number" then error(dgsGenAsrt(w,"dgsSVGSetSize",2,"number")) end
	if not type(h) == "number" then error(dgsGenAsrt(h,"dgsSVGSetSize",3,"number")) end
	return svgSetSize(svg,w,h)
end

function toStyle(t)
	local style = ""
	for k,v in pairs(t) do
		style = style..k..":"..v..";"
	end
	return style
end

function fromStyle(s)
	local t = split(s,";")
	local nTab = {}
	for i=1,#t do
		local pair = split(t[i],":")
		if #pair == 2 then
			nTab[pair[1]] = pair[2]
		end
	end
	return nTab
end

function dgsSVGGetElementStyle(element)
	local style = xmlNodeGetAttribute(element,"style") or ""
	return fromStyle(style)
end

function dgsSVGSetElementStyle(element,styleTable)
	return xmlNodeSetAttribute(element,"style",toStyle(styleTable))
end

function dgsSVGCreateRect(svg,x,y,width,height,parent,rx,ry)
	if not(dgsIsType(svg,"svg")) then error(dgsGenAsrt(svg,"dgsSVGCreateRect",1,"svg")) end
	local newRect = xmlCreateChild(parent or dgsElementData[svg].svgDocument,"rect")
	xmlNodeSetAttribute(newRect,"x",x)
	xmlNodeSetAttribute(newRect,"y",y)
	xmlNodeSetAttribute(newRect,"width",width)
	xmlNodeSetAttribute(newRect,"height",height)
	xmlNodeSetAttribute(newRect,"rx",rx or 0)
	xmlNodeSetAttribute(newRect,"ry",ry or 0)
	dgsElementData[svg].svgDocumentUpdate = true
	return newRect
end

function dgsSVGCreateCircle()

end

function dgsSVGCreateEllipse()

end

function dgsSVGCreateLine()

end

function dgsSVGCreatePolygon()

end

function dgsSVGCreatePath()

end

function dgsSVGCreateText()

end

function dgsSVGSetElementID()

end

function dgsSVGGetElementID()

end

function dgsSVGGetElementByID()

end

function dgsSVGGetElementsByType()

end

