texture gTexture;

technique effect3D
{
	pass p0
	{
		Texture[0] = gTexture;
	}
}