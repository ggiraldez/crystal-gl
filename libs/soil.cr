require "lib_gl"

@[Link("SOIL")]
{% if flag?(:darwin) %}
  @[Link(framework: "CoreFoundation")] ifdef darwin
{% end %}
lib SOIL
  LOAD_AUTO = 0
  LOAD_L    = 1
  LOAD_LA   = 2
  LOAD_RGB  = 3
  LOAD_RGBA = 4

  CREATE_NEW_ID = 0_u32

  FLAG_POWER_OF_TWO      =   1_u32
  FLAG_MIPMAPS           =   2_u32
  FLAG_TEXTURE_REPEATS   =   4_u32
  FLAG_MULTIPLY_ALPHA    =   8_u32
  FLAG_INVERT_Y          =  16_u32
  FLAG_COMPRESS_TO_DXT   =  32_u32
  FLAG_DDS_LOAD_DIRECT   =  64_u32
  FLAG_NTSC_SAFE_RGB     = 128_u32
  FLAG_CoCg_Y            = 256_u32
  FLAG_TEXTURE_RECTANGLE = 512_u32

  fun load_texture = SOIL_load_OGL_texture(filename : UInt8*, force_channels : Int32, reuse_texture_ID : UInt32, flags : UInt32) : UInt32

  fun load_image = SOIL_load_image(filename : UInt8*, width : Int32*, height : Int32*, channels : Int32*, force_channels : Int32) : UInt8*
  fun free_image_data = SOIL_free_image_data(data : UInt8*) : Void
  fun last_result = SOIL_last_result : UInt8*
end
