texture sourceTexture;
float4 color = float4(1,1,1,1);
bool textureLoad = false;
bool textureRotated = false;
float4 isRelative = 1;
float4 radius = 0.2;
float borderSoft = 0.01;
bool colorOverwritten = true;
float borderThickness = 0.2;
float radiusMultipler = 0.95;

SamplerState tSampler{
	Texture = sourceTexture;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
};

float4 rndRect(float2 tex: TEXCOORD0, float4 _color : COLOR0):COLOR0{
	float4 result = textureLoad?tex2D(tSampler,textureRotated?tex.yx:tex)*color:color;
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
	alp = clamp(alp,0,1);
	float2 newborderThickness = borderThickness*dd*100;
	tex_bk = tex_bk+tex_bk*newborderThickness;
	dx = ddx(tex_bk);
	dy = ddy(tex_bk);
	dd = float2(length(float2(dx.x,dy.x)),length(float2(dx.y,dy.y)));
	a = dd.x/dd.y;
	center = 0.5*float2(1/(a<=1?a:1),a<=1?1:a);
	aA = borderSoft*100;
	if(a<=1){
		tex_bk.x /= a;
		aA *= dd.y;
		nRadius = float4(isRelative.x==1?radius.x/2:radius.x*dd.y,isRelative.y==1?radius.y/2:radius.y*dd.y,isRelative.z==1?radius.z/2:radius.z*dd.y,isRelative.w==1?radius.w/2:radius.w*dd.y);
	}
	else{
		tex_bk.y *= a;
		aA *= dd.x;
		nRadius = float4(isRelative.x==1?radius.x/2:radius.x*dd.x,isRelative.y==1?radius.y/2:radius.y*dd.x,isRelative.z==1?radius.z/2:radius.z*dd.x,isRelative.w==1?radius.w/2:radius.w*dd.x);
	}
	fixedPos = (tex_bk-center*(newborderThickness+1));
	float4 nRadiusHalf = nRadius;
	nRadiusHalf.x -= newborderThickness.x/2;
	nRadiusHalf.y -= newborderThickness.y/2;
	nRadiusHalf.z -= newborderThickness.x/2;
	nRadiusHalf.w -= newborderThickness.y/2;
	corner[0] = center-nRadiusHalf.x;
	corner[1] = center-nRadiusHalf.y;
	corner[2] = center-nRadiusHalf.z;
	corner[3] = center-nRadiusHalf.w;
	//LTCorner
	float nAlp = 0;
	if(-fixedPos.x >= corner[0].x && -fixedPos.y >= corner[0].y && -fixedPos.x >= 0){
		float dis = distance(-fixedPos,corner[0]);
		nAlp = (dis-nRadiusHalf.x+aA)/aA;
	}
	//RTCorner
	if(fixedPos.x >= corner[1].x && -fixedPos.y >= corner[1].y && fixedPos.x >= 0){
		float dis = distance(float2(fixedPos.x,-fixedPos.y),corner[1]);
		nAlp = (dis-nRadiusHalf.y+aA)/aA;
	}
	//RBCorner
	if(fixedPos.x >= corner[2].x && fixedPos.y >= corner[2].y && fixedPos.y >= 0){
		float dis = distance(float2(fixedPos.x,fixedPos.y),corner[2]);
		nAlp = (dis-nRadiusHalf.z+aA)/aA;
	}
	//LBCorner
	if(-fixedPos.x >= corner[3].x && fixedPos.y >= corner[3].y && fixedPos.y >= 0 && -fixedPos.x >= 0){
		float dis = distance(float2(-fixedPos.x,fixedPos.y),corner[3]);
		nAlp = (dis-nRadiusHalf.w+aA)/aA;
	}
	if (fixedPos.y <= 0 && -fixedPos.x <= corner[0].x && fixedPos.x <= corner[1].x && (nRadiusHalf[0] || nRadiusHalf[1])){
		nAlp = 1-(fixedPos.y+center.y)/aA;
	}else if (fixedPos.y >= 0 && -fixedPos.x <= corner[3].x && fixedPos.x <= corner[2].x && (nRadiusHalf[2] || nRadiusHalf[3])){
		nAlp = 1-(-fixedPos.y+center.y)/aA;
	}else if (fixedPos.x <= 0 && -fixedPos.y <= corner[0].y && fixedPos.y <= corner[3].y && (nRadiusHalf[0] || nRadiusHalf[3])){
		nAlp = 1-(fixedPos.x+center.x)/aA;
	}else if (fixedPos.x >= 0 && -fixedPos.y <= corner[1].y && fixedPos.y <= corner[2].y && (nRadiusHalf[1] || nRadiusHalf[2])){
		nAlp = 1-(-fixedPos.x+center.x)/aA;
	}
	alp *= clamp(nAlp,0,1);
	result.rgb = colorOverwritten?result.rgb:_color.rgb;
	result.a *= _color.a*alp;
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