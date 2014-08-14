require "sdl"

lib LibSDL
  enum GLAttribute
    GL_RED_SIZE = 0
    GL_GREEN_SIZE = 1
    GL_BLUE_SIZE = 2
    GL_ALPHA_SIZE = 3
    GL_BUFFER_SIZE = 4
    GL_DOUBLEBUFFER = 5
    GL_DEPTH_SIZE = 6
    GL_STENCIL_SIZE = 7
    GL_ACCUM_RED_SIZE = 8
    GL_ACCUM_GREEN_SIZE = 9
    GL_ACCUM_BLUE_SIZE = 10
    GL_ACCUM_ALPHA_SIZE = 11
    GL_STEREO = 12
    GL_MULTISAMPLEBUFFERS = 13
    GL_MULTISAMPLESAMPLES = 14
    GL_ACCELERATED_VISUAL = 15
    GL_SWAP_CONTROL = 16
  end

  struct Palette
    ncolors : Int32
    colors : Color* 
  end

  struct PixelFormat
    palette : Palette*
    bits_per_pixel : UInt8
    bytes_per_pixel : UInt8
    rloss, gloss, bloss, aloss : UInt8
    rshift, gshift, bshift, ashift : UInt8
    rmask, gmask, bmask, amask : UInt32
    colorkey : UInt32
    alpha : UInt8
  end

  struct VideoInfo
    flags : UInt32  # hw_available:1
                    # wm_available:1
                    # unused:6
                    # unused:1
                    # blit_hw:1
                    # blit_hw_CC:1
                    # blit_hw_A:1
                    # blit_sw:1
                    # blit_sw_CC:1
                    # blit_sw_A:1
                    # blit_fill:1
                    # unused:16
    video_mem : UInt32
    vfmt : PixelFormat*
    current_w : Int32
    current_h : Int32
  end

  fun get_video_info = SDL_GetVideoInfo() : VideoInfo*
  fun gl_set_attribute = SDL_GL_SetAttribute(attribute : GLAttribute, value : Int32)
  fun gl_swap_buffers = SDL_GL_SwapBuffers() : Void
end

module SDL
  def self.get_video_info
    LibSDL.get_video_info
  end

  def self.gl_set_attribute(attribute, value)
    LibSDL.gl_set_attribute(attribute, value)
  end

  def self.gl_swap_buffers
    LibSDL.gl_swap_buffers
  end
end


