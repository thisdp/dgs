#define PI 3.1415926535897932384626433832795
texture sourceTexture;
float4 color = float4(1,1,1,1);
bool textureLoad = false;
float textureRot = 0;
float2 textureRotCenter = float2(0.5,0.5);
float4 isRelative = 1;
float4 radius = 0.2;
float borderSoft = 0.01;
bool colorOverwritten = true;

SamplerState tSampler{
	Texture = sourceTexture;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
};

float4 rndRect(float2 tex: TEXCOORD0, float4 _color : COLOR0):COLOR0{
	float thetaCos = cos(-textureRot/180.0*PI);
	float thetaSin = sin(-textureRot/180.0*PI);
	float2x2 rot = float4(thetaCos,-thetaSin,thetaSin,thetaCos);
	float2 rotedTex = mul(tex-textureRotCenter,rot)+textureRotCenter;
	float4 result = colorOverwritten?color:_color;
	if(textureLoad) result *= tex2D(tSampler,rotedTex);
	float alp = 1;
	float2 tex_bk = tex;
	float2 dx = ddx(tex);
	float2 dy = ddy(tex);
	float2 dd = float2(length(float2(dx.x,dy.x)),length(float2(dx.y,dy.y)));
	float a = dd.x/dd.y;
	float2 center = 0.5*float2(1/(a<=1?a:1),a<=1?1:a);
	float4 nRadius;
	float aA = borderSoft*100;
	if(a<=1){
		tex.x /= a;
		aA *= dd.y;
		nRadius = float4(isRelative.x==1?radius.x/2:radius.x*dd.y,isRelative.y==1?radius.y/2:radius.y*dd.y,isRelative.z==1?radius.z/2:radius.z*dd.y,isRelative.w==1?radius.w/2:radius.w*dd.y);
	}else{
		tex.y *= a;
		aA *= dd.x;
		nRadius = float4(isRelative.x==1?radius.x/2:radius.x*dd.x,isRelative.y==1?radius.y/2:radius.y*dd.x,isRelative.z==1?radius.z/2:radius.z*dd.x,isRelative.w==1?radius.w/2:radius.w*dd.x);
	}

	float2 fixedPos = tex-center;
	float2 corner[] = {center-nRadius.x,center-nRadius.y,center-nRadius.z,center-nRadius.w};
	//LTCorner
	if(-fixedPos.x >= corner[0].x && -fixedPos.y >= corner[0].y && -fixedPos.x >= 0 ){
		float dis = distance(-fixedPos,corner[0]);
		alp = 1-(dis-nRadius.x+aA)/aA;
	}
	//RTCorner
	if(fixedPos.x >= corner[1].x && -fixedPos.y >= corner[1].y && fixedPos.x >= 0 ){
		float dis = distance(float2(fixedPos.x,-fixedPos.y),corner[1]);
		alp = 1-(dis-nRadius.y+aA)/aA;
	}
	//RBCorner
	if(fixedPos.x >= corner[2].x && fixedPos.y >= corner[2].y && fixedPos.y >= 0){
		float dis = distance(float2(fixedPos.x,fixedPos.y),corner[2]);
		alp = 1-(dis-nRadius.z+aA)/aA;
	}
	//LBCorner
	if(-fixedPos.x >= corner[3].x && fixedPos.y >= corner[3].y && fixedPos.y >= 0 && -fixedPos.x >= 0){
		float dis = distance(float2(-fixedPos.x,fixedPos.y),corner[3]);
		alp = 1-(dis-nRadius.w+aA)/aA;
	}
	if (fixedPos.y <= 0 && -fixedPos.x <= corner[0].x && fixedPos.x <= corner[1].x && (nRadius[0] || nRadius[1])){
		alp = (fixedPos.y+center.y)/aA;
	}else if (fixedPos.y >= 0 && -fixedPos.x <= corner[3].x && fixedPos.x <= corner[2].x && (nRadius[2] || nRadius[3])){
		alp = (-fixedPos.y+center.y)/aA;
	}else if (fixedPos.x <= 0 && -fixedPos.y <= corner[0].y && fixedPos.y <= corner[3].y && (nRadius[0] || nRadius[3])){
		alp = (fixedPos.x+center.x)/aA;
	}else if (fixedPos.x >= 0 && -fixedPos.y <= corner[1].y && fixedPos.y <= corner[2].y && (nRadius[1] || nRadius[2])){
		alp = (-fixedPos.x+center.x)/aA;
	}
	result.a *= clamp(alp,0,1);
	return result;
}

technique rndRectTech{
	pass P0{
		//Solve Render Issues
		SeparateAlphaBlendEnable = true;
		SrcBlendAlpha = One;
		DestBlendAlpha = InvSrcAlpha;
		PixelShader = compile ps_2_a rndRect();
	}
}