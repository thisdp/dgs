texture sourceTexture;
float2 gdX = float2(1/3.0,2/3.0);	//Grid X
float2 gdY = float2(1/3.0,2/3.0);	//Grid Y
float2 tR = float2(32,32);	//Texture Resolution
float2 rR = float2(32,32);	//Render Image Resolution

sampler2D Sampler = sampler_state{
	Texture		= sourceTexture;
	MinFilter	= None;
	MagFilter	= None;
	MipFilter	= None;
	AddressU	= Wrap;
	AddressV	= Wrap;
};

float map(float v,float a,float b,float c,float d) {
	return (v-a)/(b-a)*(d-c)+c;
}

float4 nineSlice(float2 tex:TEXCOORD0,float4 color:COLOR0):COLOR0{
	float2 P = 0;
	float2 t = tex*rR;
	float horz = rR.x*(t.x>tR.x*gdX[0]);
	float vect = rR.y*(t.y>tR.y*gdY[0]);
	if(rR.x/2-abs(rR.x/2-t.x)<tR.x*gdX[0])	{
		if(t.y<tR.y*gdY[0])
			P = float2(map(t.x,horz,horz+tR.x*gdX[0],0,gdX[0]),map(t.y,0,tR.y*gdY[0],0,gdY[0]));
		else if(rR.y-t.y<tR.y*(1-gdY[1]))
			P = float2(map(t.x,horz,horz+tR.x*gdX[0],0,gdX[0]),map(t.y,vect+tR.y*gdY[1],vect+tR.y,gdY[1],1));
		else
			P = float2(map(t.x,horz,horz+tR.x*gdX[0],0,gdX[0]),map(t.y,tR.y*gdY[0],rR.y-tR.y*(1-gdY[1]),gdY[0],gdY[1]));
	}
	else if(rR.y/2-abs(rR.y/2-t.y)<tR.y*gdY.x)
		P = float2(map(t.x,tR.x*gdX[0],rR.x-tR.x*(1-gdX[1]),gdX[0],gdX[1]),map(t.y,vect,vect+tR.y*gdY[0],0,gdY[0]));
	else
		P = float2(map(t.x,tR.x*gdX[0],rR.x-tR.x*(1-gdX[1]),gdX[0],gdX[1]),map(t.y,tR.y*gdY[0],rR.y-tR.y*(1-gdY[1]),gdY[0],gdY[1]));
	color *= tex2D(Sampler,P);
	return color;
}

technique nSlice{
	pass p0{
		PixelShader = compile ps_2_0 nineSlice();
	}
}