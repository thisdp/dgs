texture sourceTexture;
float4 color = float4(1,1,1,1);
float4 borderColor = float4(1,1,1,1);
bool textureLoad = false;
bool textureRotated = false;
float4 isRelative = 1;
float4 radius = 0.2;
float borderSoft = 0.02;
bool colorOverwritten = true;
float2 borderThickness = 0.2;
float radiusMultipler = 0.95;
float4 UV = float4(0,0,1,1);

SamplerState tSampler{
	Texture = sourceTexture;
};

float4 rndRect(float2 tex: TEXCOORD0, float4 _color : COLOR0):COLOR0{
	float4 result = borderColor;
	float alp = 1;
	float2 tempTex = tex;
	tempTex = (tempTex*UV.zw+UV.xy)%1;
	float2 tex_bk = tempTex;
	float2 dx = ddx(tempTex);
	float2 dy = ddy(tempTex);
	float2 dd = float2(length(float2(dx.x,dy.x)),length(float2(dx.y,dy.y)));
	float a = dd.x/dd.y;
	float2 center = 0.5*float2(1/(a<=1?a:1),a<=1?1:a);
	float4 nRadius;
	float aA = borderSoft*100;
	if(a<=1){
		tempTex.x /= a;
		aA *= dd.y;
		nRadius = float4(isRelative.x==1?radius.x/2:radius.x*dd.y,isRelative.y==1?radius.y/2:radius.y*dd.y,isRelative.z==1?radius.z/2:radius.z*dd.y,isRelative.w==1?radius.w/2:radius.w*dd.y);
	}else{
		tempTex.y *= a;
		aA *= dd.x;
		nRadius = float4(isRelative.x==1?radius.x/2:radius.x*dd.x,isRelative.y==1?radius.y/2:radius.y*dd.x,isRelative.z==1?radius.z/2:radius.z*dd.x,isRelative.w==1?radius.w/2:radius.w*dd.x);
	}
	float2 fixedPos = tempTex-center;
	float2 corner[] = {center-nRadius.x,center-nRadius.y,center-nRadius.z,center-nRadius.w};
	bool leftTopSideX = fixedPos.x <= -corner[0].x;
	bool leftTopSideY = fixedPos.y <= -corner[0].y;
	
	bool rightTopSideX = fixedPos.x >= corner[1].x;
	bool rightTopSideY = fixedPos.y <= -corner[1].y;
	
	bool rightBottomSideX = fixedPos.x >= corner[2].x;
	bool rightBottomSideY = fixedPos.y >= corner[2].y;
	
	bool leftBottomSideX = fixedPos.x <= -corner[3].x;
	bool leftBottomSideY = fixedPos.y >= corner[3].y;
	
	if(leftTopSideX && leftTopSideY){					//LTCorner
		float dis = distance(-fixedPos,corner[0]);
		alp *= saturate(1-(dis-nRadius.x+aA)/aA);
	}
	if(rightTopSideX && rightTopSideY){			//RTCorner
		float dis = distance(float2(fixedPos.x,-fixedPos.y),corner[1]);
		alp *= saturate(1-(dis-nRadius.y+aA)/aA);
	}
	if(rightBottomSideX && rightBottomSideY){		//RBCorner
		float dis = distance(float2(fixedPos.x,fixedPos.y),corner[2]);
		alp *= saturate(1-(dis-nRadius.z+aA)/aA);
	}
	if(leftBottomSideX && leftBottomSideY){		//LBCorner
		float dis = distance(float2(-fixedPos.x,fixedPos.y),corner[3]);
		alp *= saturate(1-(dis-nRadius.w+aA)/aA);
	}
	if(fixedPos.x <= 0){
		if(fixedPos.y <= 0){
			if (!leftTopSideX && (nRadius[0] || nRadius[1]))
				alp *= saturate((fixedPos.y+center.y)/aA);
			if (!leftTopSideY && (nRadius[0] || nRadius[3]))
				alp *= saturate((fixedPos.x+center.x)/aA);
		}else{
			if (!leftBottomSideX && (nRadius[2] || nRadius[3]))
				alp *= saturate((-fixedPos.y+center.y)/aA);
			if (!leftBottomSideY && (nRadius[0] || nRadius[3]))
				alp *= saturate((fixedPos.x+center.x)/aA);
		}
	}else{
		if(fixedPos.y <= 0){
			if (!rightTopSideX && (nRadius[0] || nRadius[1]))
				alp *= saturate((fixedPos.y+center.y)/aA);
			if (!rightTopSideY && (nRadius[1] || nRadius[2]))
				alp *= saturate((-fixedPos.x+center.x)/aA);
		}else{
			if (!rightBottomSideX && (nRadius[2] || nRadius[3]))
				alp *= saturate((-fixedPos.y+center.y)/aA);
			if (!rightBottomSideY && (nRadius[1] || nRadius[2]))
				alp *= saturate((-fixedPos.x+center.x)/aA);
		}
	}
	alp = saturate(alp);
	float nAlp = 1;
	if(borderThickness[0] > 0 && borderThickness[1] > 0){
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
		nRadiusHalf.xz -= newborderThickness.x/2;
		nRadiusHalf.yw -= newborderThickness.y/2;
		corner[0] = center-nRadiusHalf.x;
		corner[1] = center-nRadiusHalf.y;
		corner[2] = center-nRadiusHalf.z;
		corner[3] = center-nRadiusHalf.w;
		
		leftTopSideX = fixedPos.x <= -corner[0].x;
		leftTopSideY = fixedPos.y <= -corner[0].y;
		
		rightTopSideX = fixedPos.x >= corner[1].x;
		rightTopSideY = fixedPos.y <= -corner[1].y;
		
		rightBottomSideX = fixedPos.x >= corner[2].x;
		rightBottomSideY = fixedPos.y >= corner[2].y;
		
		leftBottomSideX = fixedPos.x <= -corner[3].x;
		leftBottomSideY = fixedPos.y >= corner[3].y;
		

		if(leftTopSideX && leftTopSideY){					//LTCorner
			float dis = distance(-fixedPos,corner[0]);
			nAlp *= saturate(1-(dis-nRadiusHalf.x+aA)/aA);
		}
		if(rightTopSideX && rightTopSideY){			//RTCorner
			float dis = distance(float2(fixedPos.x,-fixedPos.y),corner[1]);
			nAlp *= saturate(1-(dis-nRadiusHalf.y+aA)/aA);
		}
		if(rightBottomSideX && rightBottomSideY){		//RBCorner
			float dis = distance(float2(fixedPos.x,fixedPos.y),corner[2]);
			nAlp *= saturate(1-(dis-nRadiusHalf.z+aA)/aA);
		}
		if(leftBottomSideX && leftBottomSideY){		//LBCorner
			float dis = distance(float2(-fixedPos.x,fixedPos.y),corner[3]);
			nAlp *= saturate(1-(dis-nRadiusHalf.w+aA)/aA);
		}
		if(fixedPos.x <= 0){
			if(fixedPos.y <= 0){
				if (!leftTopSideX)
					nAlp *= saturate((fixedPos.y+center.y)/aA);
				if (!leftTopSideY)
					nAlp *= saturate((fixedPos.x+center.x)/aA);
			}else{
				if (!leftBottomSideX)
					nAlp *= saturate((-fixedPos.y+center.y)/aA);
				if (!leftBottomSideY)
					nAlp *= saturate((fixedPos.x+center.x)/aA);
			}
		}else{
			if(fixedPos.y <= 0){
				if (!rightTopSideX)
					nAlp *= saturate((fixedPos.y+center.y)/aA);
				if (!rightTopSideY)
					nAlp *= saturate((-fixedPos.x+center.x)/aA);
			}else{
				if (!rightBottomSideX)
					nAlp *= saturate((-fixedPos.y+center.y)/aA);
				if (!rightBottomSideY)
					nAlp *= saturate((-fixedPos.x+center.x)/aA);
			}
		}
	}
	nAlp = 1-saturate(nAlp);
	result += (color-result)*(1-clamp(nAlp,0,1));
	result.rgb = colorOverwritten?result.rgb:_color.rgb;
	result.a *= _color.a*alp;
	result *= textureLoad?tex2D(tSampler,textureRotated?tex_bk.yx:tex_bk):1;
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