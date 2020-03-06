texture textureRef;

technique remoteImage
{
	Pass P0
	{
		Texture[0] = textureRef;
	}
}
