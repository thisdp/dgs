texture sourceTexture;
bool invertAlpha = false;

SamplerState sourceSampler{
	Texture = sourceTexture;
};

float4 maskColorInverter(float2 tex:TEXCOORD0,float4 color:COLOR0):COLOR0{
	float4 sampledTexture = tex2D(sourceSampler,tex);
	float4 invertedColor = 0;
	if(invertAlpha){
		invertedColor = 1-sampledTexture;
	}else{
		invertedColor.rgb = 1-sampledTexture.rgb;
		invertedColor.a = sampledTexture.a;
	}
	return invertedColor*color;
}

technique maskTech{
	pass P0	{
		//Solve Render Issues
		SeparateAlphaBlendEnable = true;
		SrcBlendAlpha = One;
		DestBlendAlpha = InvSrcAlpha;
		PixelShader = compile ps_2_0 maskColorInverter();
	}
}