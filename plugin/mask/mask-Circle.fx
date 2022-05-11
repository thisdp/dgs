texture sourceTexture;
float borderSoft = 0.02;
float radius = 0.5;
float3 offset = float3(0,0,1);
float3 scale = float3(1,1,1);

SamplerState sourceSampler{
	Texture = sourceTexture;
};

float4 maskCircle(float2 tex:TEXCOORD0,float4 color:COLOR0):COLOR0{
	float2 dxy = float2(length(ddx(tex)),length(ddy(tex)));
	float2 texOffset = offset.z ? offset.xy : offset.xy*dxy;
	float2 texScale = scale.z ? scale.xy : scale.xy*dxy;
	float4 sampledTexture = tex2D(sourceSampler,(tex+texOffset)/texScale);
	float nBorderSoft = borderSoft*sqrt(dxy.x*dxy.y)*100;
	sampledTexture.a *= saturate((1-distance(tex,0.5)-radius-borderSoft)/nBorderSoft);
	return sampledTexture*color;
}

technique maskTech{
	pass P0	{
		SeparateAlphaBlendEnable = true;
		SrcBlendAlpha = One;
		DestBlendAlpha = InvSrcAlpha;
		PixelShader = compile ps_2_a maskCircle();
	}
}