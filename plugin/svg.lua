dgsLogLuaMemory()
dgsRegisterPluginType("dgs-dxsvg")
local dxDrawImageSection = __dxDrawImageSection
local dxDrawImage = __dxDrawImage

local dgsSVGXMLRef = {}
setmetatable(dgsSVGXMLRef,{__mode="k"})

function dgsCreateSVG(...)
	local svg
	if select('#',...) == 3 then
		local w,h,pathOrRaw = ...
		if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsCreateSVG",1,"number")) end
		if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsCreateSVG",2,"number")) end
		if not(type(pathOrRaw) == "string") then error(dgsGenAsrt(pathOrRaw,"dgsCreateSVG",3,"string")) end
		svg = svgCreate(w,h,pathOrRaw)
	else
		local w,h = ...
		if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsCreateSVG",1,"number")) end
		if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsCreateSVG",2,"number")) end
		svg = svgCreate(w,h)
	end
	dgsElementData[svg] = {
		svgDocument = svgGetDocumentXML(svg),
		svgDocumentUpdate = false,
	}
	dgsSVGXMLRef[dgsElementData[svg].svgDocument] = svg
	dgsSetData(svg,"asPlugin","dgs-dxsvg")
	dgsTriggerEvent("onDgsPluginCreate",svg,sourceResource)
	return svg
end

function dgsSVGGetDocument(svg)
	if not(dgsIsType(svg,"svg")) then error(dgsGenAsrt(svg,"dgsSVGGetDocument",1,"svg")) end
	return dgsElementData[svg] and dgsElementData[svg].svgDocument or svgGetDocumentXML(svg)
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

function dgsSVGMarkUpdate(ele)
	if not dgsGetPluginType(ele) == "dgs-dxsvg" then return false end
	local cnt = 0
	while true do
		cnt = cnt+1
		if cnt >= 50 then return false end
		local name = xmlNodeGetName(ele)
		if name == "svg" then
			if dgsSVGXMLRef[ele] then
				dgsElementData[dgsSVGXMLRef[ele]].svgDocumentUpdate = true
				return true
			else
				return false
			end
		end
		ele = xmlNodeGetParent(ele)
	end
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

function dgsSVGNodeGetElementStyle(element)
	local style = xmlNodeGetAttribute(element,"style") or ""
	return fromStyle(style)
end

function dgsSVGNodeSetElementStyle(element,styleTable)
	return xmlNodeSetAttribute(element,"style",toStyle(styleTable))
end

SVGNodeCreation = {
	rect = function(svgDocument,...)
		local argCount = select("#",...)
		local x,y,width,height = 0,0,0,0
		if argCount == 2 then
			width,height = ...
			x,y = 0,0
		elseif argCount == 4 then
			x,y,width,height = ...
		end
		local newRect = xmlCreateChild(svgDocument,"rect")
		xmlNodeSetAttribute(newRect,"x",x)
		xmlNodeSetAttribute(newRect,"y",y)
		xmlNodeSetAttribute(newRect,"width",width)
		xmlNodeSetAttribute(newRect,"height",height)
		dgsSVGMarkUpdate(svgDocument)
		return newRect
	end,
	circle = function(svgDocument,...)
		local cx,cy,r = ...
		local newCircle = xmlCreateChild(svgDocument,"circle")
		xmlNodeSetAttribute(newCircle,"cx",cx)
		xmlNodeSetAttribute(newCircle,"cy",cy)
		xmlNodeSetAttribute(newCircle,"r",r)
		dgsSVGMarkUpdate(svgDocument)
		return newCircle
	end,
	ellipse = function(svgDocument,...)
		local argCount = select("#",...)
		local newEllipse = xmlCreateChild(svgDocument,"ellipse")
		if argCount == 2 then
			local rx,ry = ...
			xmlNodeSetAttribute(newEllipse,"rx",rx)
			xmlNodeSetAttribute(newEllipse,"ry",ry)
		elseif argCount == 4 then
			local cx,cy,rx,ry = ...
			xmlNodeSetAttribute(newEllipse,"cx",cx)
			xmlNodeSetAttribute(newEllipse,"cy",cy)
			xmlNodeSetAttribute(newEllipse,"rx",rx)
			xmlNodeSetAttribute(newEllipse,"ry",ry)
		end
		dgsSVGMarkUpdate(svgDocument)
		return newEllipse
	end,
	line = function(svgDocument,...)
		local x1,y1,x2,y2 = ...
		local newLine = xmlCreateChild(svgDocument,"line")
		xmlNodeSetAttribute(newLine,"x1",x1)
		xmlNodeSetAttribute(newLine,"y1",y1)
		xmlNodeSetAttribute(newLine,"x2",x2)
		xmlNodeSetAttribute(newLine,"y2",y2)
		dgsSVGMarkUpdate(svgDocument)
		return newLine
	end,
	polygon = function(svgDocument,...)
		local points = svgSetPoints(...)
		local newPolygon = xmlCreateChild(svgDocument,"polygon")
		xmlNodeSetAttribute(newPolygon,"points",points)
		dgsSVGMarkUpdate(svgDocument)
		return newPolygon
	end,
	polyline = function(svgDocument,...)
		local points = svgSetPoints(...)
		local newPolyline = xmlCreateChild(svgDocument,"polyline")
		xmlNodeSetAttribute(newPolyline,"points",points)
		dgsSVGMarkUpdate(svgDocument)
		return newPolyline
	end,
	path = function(svgDocument,...)
		local path = svgSetPath(...)
		local newPath = xmlCreateChild(svgDocument,"path")
		xmlNodeSetAttribute(newPath,"d",path)
		dgsSVGMarkUpdate(svgDocument)
		return newPath
	end,
	text = function(svgDocument,...)
		local argCount = select("#",...)
		local newText = xmlCreateChild(svgDocument,"text")
		if argCount == 1 then
			xmlNodeSetValue(newText,...)
		elseif argCount == 3 then
			local text,x,y = ...
			xmlNodeSetAttribute(newText,"x",x)
			xmlNodeSetAttribute(newText,"y",y)
			xmlNodeSetValue(newText,text)
		end
		dgsSVGMarkUpdate(svgDocument)
		return newText
	end,
	tspan = function(svgDocument,...)
		local argCount = select("#",...)
		local newtSpan = xmlCreateChild(svgDocument,"tspan")
		if argCount == 1 then
			xmlNodeSetValue(newtSpan,...)
		elseif argCount == 3 then
			local text,dx,dy = ...
			xmlNodeSetAttribute(newtSpan,"dx",dx)
			xmlNodeSetAttribute(newtSpan,"dy",dy)
			xmlNodeSetValue(newtSpan,text)
		end
		dgsSVGMarkUpdate(svgDocument)
		return newtSpan
	end,
	defs = function(svgDocument,...)
		local newDef = xmlCreateChild(svgDocument,"defs")
		dgsSVGMarkUpdate(svgDocument)
		return newDef
	end,
	g = function(svgDocument,id)
		local newG = xmlCreateChild(svgDocument,"g")
		xmlNodeSetAttribute(newG,"id",id)
		dgsSVGMarkUpdate(svgDocument)
		return newG
	end,
	use = function(svgDocument,...)
		local newUse = xmlCreateChild(svgDocument,"use")
		local useID,x,y = ...
		local href = svgSetHRef(useID)
		xmlNodeSetAttribute(newUse,"xlink:href",href)
		if x and y then
			xmlNodeSetAttribute(newUse,"x",x)
			xmlNodeSetAttribute(newUse,"y",y)
		end
		dgsSVGMarkUpdate(svgDocument)
		return newUse
	end,
}

function dgsSVGNodeSetAttribute(svgEle,attr,...)
	local svgType = xmlNodeGetName(svgEle)
	local handleFunction = SVGElementAttribute[svgType] and SVGElementAttribute[svgType][attr] or SVGElementAttribute.default[attr]
	local result = ...
	if handleFunction and handleFunction.set then
		if select("#",...) ~= 1 or type(result) ~= "string" then	
			result = handleFunction.set(...)
		end
	end
	xmlNodeSetAttribute(svgEle,attr,result)
	dgsSVGMarkUpdate(svgEle)
	return true
end

function dgsSVGNodeSetAttributes(svgEle,attributeWithData)
	if type(svgEle) == "table" then
		for i=1,#svgEle do dgsSVGNodeSetAttributes(svgEle[i],attributeWithData) end
	end
	local svgType = xmlNodeGetName(svgEle)
	for attr,data in pairs(attributeWithData) do
		local handleFunction = SVGElementAttribute[svgType] and SVGElementAttribute[svgType][attr] or SVGElementAttribute.default[attr]
		result = data
		if handleFunction and handleFunction.set then
			if type(data) == "table" then
				result = handleFunction.set(unpack(data))
			else
				result = handleFunction.set(data)
			end
		end
		xmlNodeSetAttribute(svgEle,attr,result)
	end
	dgsSVGMarkUpdate(svgEle)
	return true
end

function dgsSVGNodeGetAttribute(svgEle,attr,...)
	local svgType = xmlNodeGetName(svgEle)
	local handleFunction = SVGElementAttribute[svgType] and SVGElementAttribute[svgType][attr] or SVGElementAttribute.default[attr]
	local result = xmlNodeGetAttribute(svgEle,attr)
	if handleFunction and handleFunction.get and result then
		result = handleFunction.get(result,...)
	end
	return result
end

function dgsSVGNodeGetAttributes(svgEle,attributes)
	local svgType = xmlNodeGetName(svgEle)
	local ret = {}
	if not attributes then
		local attrs = xmlNodeGetAttributes(svgEle)
		for attr,result in pairs(attrs) do
			local handleFunction = SVGElementAttribute[svgType] and SVGElementAttribute[svgType][attr] or SVGElementAttribute.default[attr]
			if handleFunction and handleFunction.get and result then
				ret[attr] = handleFunction.get(result)
			end
		end
	else
		for i,attr in ipairs(attributes) do
			local result = xmlNodeGetAttribute(svgEle,attr)
			local handleFunction = SVGElementAttribute[svgType] and SVGElementAttribute[svgType][attr] or SVGElementAttribute.default[attr]
			if handleFunction and handleFunction.get and result then
				ret[attr] = handleFunction.get(result)
			end
		end
	end
	return ret
end

function dgsSVGCreateNode(svgDoc,eleType,...)
	if SVGNodeCreation[eleType] then
		return SVGNodeCreation[eleType](svgDoc,...)
	end
	return false
end

dgsSVGDestroyNode = xmlDestroyNode

function dgsSVGCopyNodeContent(svgNode,xmlNode)
	xmlNodeSetValue(xmlNode,xmlNodeGetValue(svgNode))
	for k,v in pairs(xmlNodeGetAttributes(svgNode)) do
		xmlNodeSetAttribute(xmlNode,k,v)
	end
	local svgChildren = xmlNodeGetChildren(svgNode)
	for i=1,#svgChildren do
		local xmlChild = xmlCreateChild(xmlNode,xmlNodeGetName(svgChildren[i]))
		dgsSVGCopyNodeContent(svgChildren[i],xmlChild)
	end
end

function dgsSVGGetRawDocument(svgDoc)
	local svgDocType = dgsGetType(svgDoc)
	if svgDocType == "xml-node" then
		local fName = "tmpSVG"..getTickCount()..".xml"
		local f = xmlCreateFile(fName,xmlNodeGetName(svgDoc))
		dgsSVGCopyNodeContent(svgDoc,f)
		xmlSaveFile(f)
		local f = fileOpen(fName)
		local content = fileRead(f,fileGetSize(f))
		fileClose(f)
		fileDelete(fName)
		return content
	elseif svgDocType == "svg" then
		return dgsSVGGetRawDocument(dgsElementData[svgDoc] and dgsElementData[svgDoc].svgDocument or svgGetDocumentXML(svgDoc))
	end
	return false
end

------SVG Util
svgGetColor = function(value,retType)
	if not value then value = "#ffffff" end
	retType = retType or "raw"
	local retType = string.lower(retType)
	if retType == "raw" then return value end
	local value = string.gsub(value,"%s+"," ")
	if string.sub(value,1,1) == "#" then
		if retType == "rgb" then
			return {getColorFromString(value)}
		elseif retType == "number" then
			return tonumber("0x"..string.sub(value,2))
		end
	elseif string.sub(value,1,3) == "rgb" then
		local r,g,b = string.match(value,"(%d+),(%d+),(%d+)")
		if retType == "rgb" then
			return {r,g,b}
		elseif retType == "number" then
			return r*0x10000+g*0x100+b
		end
	end
	return value
end

svgSetColor = function(...)
	local arguments = select("#",...)
	if arguments == 1 then
		local color = ...
		if type(color) == "number" then
			return string.format("#%.6x",color%0x1000000)
		end
		if tonumber("0x"..color) then
			return string.format("#%.6x",color)
		else
			return color
		end
	elseif arguments == 3 then
		return string.format("#%.2x%.2x%.2x",...)
	end
	return nil
end

svgSetHRef = function(ref)
	if string.sub(ref,1,1) ~= "#" then
		return "#"..ref
	end
	return ref
end

svgGetHRef = function(value,retType)
	retType = retType or "raw"
	local retType = string.lower(retType)
	if retType == "raw" then return value end
	return string.sub(value,2)
end

svgGetCoordinate = function(value,retType)
	retType = retType or "raw"
	local retType = string.lower(retType)
	if retType == "raw" then return value end
	local value = string.gsub(value,"%s+"," ")
	local coord = string.match(value,"(%d+)")
	return coord
end

svgSetPoints = function(...)
	local argCount = select("#",...)
	if argCount == 1 then
		local points = ...
		if type(points) == "string" then
			return points
		elseif type(points) == "table" and #points%2 == 0 then -- Even number
			local pointsTmp = {}
			for i=1,#points,2 do
				pointsTmp[#pointsTmp+1] = points[i]..","..points[i+1]
			end
			return table.concat(pointsTmp," ")
		end
	elseif argCount%2 == 0 then -- There should be scripter's mistake if the count of arguments is an odd number..
		local points = {...}
		local pointsTmp = {}
		for i=1,argCount,2 do
			pointsTmp[#pointsTmp+1] = points[i]..","..points[i+1]
		end
		return table.concat(pointsTmp," ")
	elseif argCount == 0 then
		return ""
	end
	return ...
end

svgGetPoints = function(value,retType)
	retType = retType or "raw"
	local retType = string.lower(retType)
	if retType == "raw" then return value end
	if retType == "table" then
		local points = {}
		for x,y in string.gmatch(value,"(%d+)%D+(%d+)") do
			points[#points+1] = x
			points[#points+1] = y
		end
		return points
	end
	return value
end

local svgPathParaCount = {m=2,l=2,h=1,v=1,c=6,s=4,q=4,t=2,a=7,z=0}
svgGetPath = function(value,retType)
	retType = retType or "raw"
	local retType = string.lower(retType)
	if retType == "raw" then return value end
	if retType == "table" then
		local cmds = {index = 0}
		repeat
			cmds.index = cmds.index+1
			_,cmds.index = string.find(value,"%a",cmds.index)
			if cmds.index then
				local cmd = string.sub(value,cmds.index,cmds.index)
				local lCMD = cmd:lower()
				local parameters = {}
				if svgPathParaCount[lCMD] > 0 then
					parameters = {string.match(value,"[%s%;%,]*(%-?%d*%.?%d+)"..string.rep("[%s%;%,]+(%-?%d*%.?%d+)",svgPathParaCount[lCMD]-1),cmds.index)}
				end
				table.insert(parameters,1,cmd)
				cmds[#cmds+1] = parameters
			end
		until(not cmds.index)
		return cmds
	end
	return value
end

svgSetPath = function(path)
	local pathType = type(path)
	if pathType == "string" then
		return path
	elseif pathType == "table" then
		local pathData = "" 
		for i=1,#path do
			pathData = pathData..table.concat(path[i]," ").." "
		end
		return pathData
	end
	return nil
end

svgToStyle = function(t)
	local style = ""
	for k,v in pairs(t) do
		style = style..k..":"..v..";"
	end
	return style
end

svgFromStyle = function(s)
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

SVGElementAttribute = {
	svg = {
		viewBox = {
			get = function(value)
				return split(string.gsub(value,"%s+"," ")," ")
			end,
			set = function(...)
				if select("#",...) == 4 then
					local x,y,w,h = ...
					return x.." "..y.." "..w.." "..h
				else
					return ...
				end
			end,
		},
	},
	default = {
		accumulate = nil,
		fill = {
			get = svgGetColor,
			set = svgSetColor,
		},
		stroke = {
			get = svgGetColor,
			set = svgSetColor,
		},
		["stroke-width"] = {
			get = svgGetCoordinate,
		},
		["xlink:href"] = {
			get = svgGetHRef,
			set = svgSetHRef,
		},
	},
	polygon = {
		points = {
			get = svgGetPoints,
			set = svgSetPoints,
		}
	},
	polyline = {
		points = {
			get = svgGetPoints,
			set = svgSetPoints,
		}
	},
	path = {
		d = {
			get = svgGetPath,
			set = svgSetPath,
		}
	},
}