float4x2 vertices = {
    0,0,
    0,0,
    0,0,
    0,0,
};
float4 color = float4(1,1,1,1);
float borderSoft = 0.01;
float4 UV = float4(0,0,1,1);
float4 isRelative = 0;
float textureRot = 0;
float rotation = 0;
float2 textureRotCenter = float2(0.5,0.5);
bool colorOverwritten = true;
texture sourceTexture;

SamplerState tSampler{
	Texture = sourceTexture;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
};

float pToLine(float2 p, float2 startPoint, float2 dir){
    return ((p.x - startPoint.x) * dir.y - (p.y - startPoint.y) * dir.x)/length(dir);
}

float cross2d(float2 a, float2 b){
    return a.x*b.y-a.y*b.x;
}

#define x1 1-saturate(pToLine(tempTex,nVertices[0],d1)/nBorderSoft)
#define x2 1-saturate(pToLine(tempTex,nVertices[1],d2)/nBorderSoft)
#define x3 1-saturate(pToLine(tempTex,nVertices[2],d3)/nBorderSoft)
#define x4 1-saturate(pToLine(tempTex,nVertices[3],d4)/nBorderSoft)

float4 checkPointInQuad(float2 tex:TEXCOORD0,float4 _color:COLOR0):COLOR0{
	float2 tempTex = (tex*UV.zw+UV.xy)%1;
	float tRotation = -radians(rotation);
	float thetaCosTex,thetaSinTex;
	sincos(tRotation,thetaSinTex,thetaCosTex);
	float2x2 rotTex = float4(thetaCosTex,-thetaSinTex,thetaSinTex,thetaCosTex);
	tempTex = mul(tempTex-0.5,rotTex)+0.5;

    float tTexRotation = -radians(textureRot);
	float thetaCos,thetaSin;
	sincos(tTexRotation,thetaSin,thetaCos);
	float2x2 rot = float4(thetaCos,-thetaSin,thetaSin,thetaCos);
	float2 rotedTex = mul(tempTex-textureRotCenter,rot)+textureRotCenter;
    float4 result = colorOverwritten?color:_color;
	result *= tex2D(tSampler,rotedTex);

    float2 dx = ddx(tempTex);
	float2 dy = ddy(tempTex);
	float2 dd = float2(length(float2(dx.x,dy.x)),length(float2(dx.y,dy.y)));
	float a = dd.x/dd.y;
	float nBorderSoft = borderSoft*100;
    float4x2 nVertices = vertices;
    if(a<=1){
		tempTex.x /= a;
        nVertices[0].x /= a;
        nVertices[1].x /= a;
        nVertices[2].x /= a;
        nVertices[3].x /= a;
		nBorderSoft *= dd.y;
	}else{
		tempTex.y *= a;
        nVertices[0].y *= a;
        nVertices[1].y *= a;
        nVertices[2].y *= a;
        nVertices[3].y *= a;
		nBorderSoft *= dd.x;
	}
    nVertices[0] = isRelative.x==1?nVertices[0]:nVertices[0]*dd;
    nVertices[1] = isRelative.y==1?nVertices[1]:nVertices[1]*dd;
    nVertices[2] = isRelative.z==1?nVertices[2]:nVertices[2]*dd;
    nVertices[3] = isRelative.w==1?nVertices[3]:nVertices[3]*dd;
    float2 d1 = nVertices[1] - nVertices[0];
    float2 d2 = nVertices[2] - nVertices[1];
    float2 d3 = nVertices[3] - nVertices[2];
    float2 d4 = nVertices[0] - nVertices[3];
    float4 s = {
        cross2d(d1,-d2) < 0 ? min(x1,x2) : max(x1,x2),
        cross2d(d2,-d3) < 0 ? min(x2,x3) : max(x2,x3),
        cross2d(d3,-d4) < 0 ? min(x3,x4) : max(x3,x4),
        cross2d(d4,-d1) < 0 ? min(x4,x1) : max(x4,x1),
    };
    result.a *= saturate(max(s.x*s.z,s.y*s.w));
    return result;
}

technique quadTechnique{
    pass p0{
        //Solve Render Issues
        SeparateAlphaBlendEnable = true;
        SrcBlendAlpha = One;
        DestBlendAlpha = InvSrcAlpha;
        PixelShader = compile ps_2_a checkPointInQuad();
    }
}