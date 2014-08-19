require "sdl_ext"
require "gl"
require "glew"
require "utils"

class SdlGlApp
  def initialize(@width = 1024, @height = 768)
    SDL.init

    info = SDL.get_video_info
    pixel_format = info.value.vfmt

    raise "Cannot get video info" if info.nil?

    puts "Flags: " + info.value.flags.to_s(2)
    puts "Video memory: " + info.value.video_mem.to_s
    puts "Palette: " + (pixel_format.value.palette.nil?.to_s ? "NO" : "YES")
    puts "BPP: " + pixel_format.value.bits_per_pixel.to_s
    puts "Screen dimensions: " + info.value.current_w.to_s + "x" + info.value.current_h.to_s

    bpp = pixel_format.value.bits_per_pixel

    SDL.gl_set_attribute(LibSDL::GLAttribute::GL_RED_SIZE, 5)
    SDL.gl_set_attribute(LibSDL::GLAttribute::GL_GREEN_SIZE, 5)
    SDL.gl_set_attribute(LibSDL::GLAttribute::GL_BLUE_SIZE, 5)
    SDL.gl_set_attribute(LibSDL::GLAttribute::GL_DEPTH_SIZE, 16)
    SDL.gl_set_attribute(LibSDL::GLAttribute::GL_DOUBLEBUFFER, 1)

    flags = LibSDL::OPENGL

    @window = SDL.set_video_mode(@width, @height, bpp.to_i32, flags)

    raise "Cannot set video mode" if @window.nil?

    GLEW.experimental = LibGL::TRUE
    unless GLEW.init == GLEW::OK
      raise "Failed to initialize GLEW"
    end
    check_error "after GLEW initialization"

    puts "OpenGL version: " + GL.version
  end

  def run
    frames = 0
    start = SDL.ticks
    running = true

    while running
      SDL.poll_events do |event|
        if event.type == LibSDL::QUIT || (event.type == LibSDL::KEYDOWN)
          running = false
        end
      end

      render_frame

      SDL.gl_swap_buffers

      frames += 1
    end

    ms = SDL.ticks - start
    puts "#{frames} in #{ms} ms"
    puts "FPS: #{frames / (ms * 0.001)}"

    terminate
  end

  def terminate
    cleanup
    SDL.quit
  end

  abstract def render_frame
  abstract def cleanup
end

