texture sourceTexture;
texture maskTexture;

SamplerState sourceSampler{
	Texture = sourceTexture;
};

SamplerState maskSampler{
	Texture = maskTexture;
};

float4 texMask(float2 tex:TEXCOORD0,float4 color:COLOR0):COLOR0{
	float4 sourceColor = tex2D(sourceSampler,tex);
    float4 maskColor = tex2D(maskSampler,tex);
	sourceColor.a = (maskColor.r+maskColor.g+maskColor.b)/3.0f;
	return sourceColor*color;
}

technique texMaskTech{
	pass P0	{
		//Solve Render Issues
		SeparateAlphaBlendEnable = true;
		SrcBlendAlpha = One;
		DestBlendAlpha = InvSrcAlpha;
		PixelShader = compile ps_2_0 texMask();
	}
}