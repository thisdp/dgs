float random( float2 p )
{
    float2 K1 = float2(
        23.14069263277926, // e^pi (Gelfond's constant)
         2.665144142690225 // 2^sqrt(2) (Gelfondâ€“Schneider constant)
    );
    return frac( cos( dot(p,K1) ) * 12345.6789 );
}

float4 poop(float2 tex:TEXCOORD0,float4 color:COLOR0):COLOR0
{
	color.rgb = random(tex);
	return color;
}

technique nSlice
{
	pass p0
	{
		PixelShader = compile ps_2_0 poop();
	}
}