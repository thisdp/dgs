texture sourceTexture;
float borderSoft = 0.05;
float radius = 0.5;
float3 offset = float3(0.3,0,1);
float3 scale = float3(1.5,1,1);

SamplerState sourceSampler
{
	Texture = sourceTexture;
};

float4 maskCircle(float2 tex:TEXCOORD0,float4 _color:COLOR0):COLOR0
{
	float2 dxy = float2(ddx(tex.x),ddy(tex.y));
	float2 texOffset = offset.z ? offset.xy : offset.xy*dxy;
	float2 texScale = scale.z ? scale.xy : scale.xy*dxy;
	float4 sampledTexture = tex2D(sourceSampler,(tex+texOffset)/texScale);
	float nBorderSoft = borderSoft*sqrt(dxy.x*dxy.y)*100;
	sampledTexture.a *= (1-distance(tex,0.5)-radius-borderSoft)/nBorderSoft;
	return sampledTexture;
}

technique maskTech
{
	pass P0
	{
		PixelShader = compile ps_2_a maskCircle();
	}
}