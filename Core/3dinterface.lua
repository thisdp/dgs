

function dgsCreate3DInterface(x,y,z,w,h,color,faceX,faceY,faceZ)
	assert(tonumber(x),"Bad argument @dgsCreate3DInterface at argument 1, expect number got "..type(x))
	assert(tonumber(y),"Bad argument @dgsCreate3DInterface at argument 2, expect number got "..type(y))
	assert(tonumber(y),"Bad argument @dgsCreate3DInterface at argument 3, expect number got "..type(z))
	assert(tonumber(sx),"Bad argument @dgsCreate3DInterface at argument 4, expect number got "..type(w))
	assert(tonumber(sy),"Bad argument @dgsCreate3DInterface at argument 45 expect number got "..type(h))
	local interface = createElement("dgs-dx3dinterface")
	dgsSetType(interface,"dgs-dx3dinterface")
	dgsSetData(interface,"position",{x,y,z})
	dgsSetData(interface,"faceTo",{faceX,faceY,faceZ})
	dgsSetData(interface,"size",{w,h})
	triggerEvent("onDgsCreate",interface)
	return interface
end