texture sTexColor;

technique dxDrawPrimitive3Dfx
{
  pass P0
  {
    ZEnable = true;
    ZWriteEnable = true;
	ZFunc = LessEqual;
    FogEnable = false;
	Texture[0] = sTexColor;
  }
}

// Fallback
technique fallback
{
  pass P0
  {
    // Just draw normally
  }
}
