require "sdl_gl_app"
require "scene"

class TestApp < SDLGLApp
  def initialize
    super

    @scene = Scene.new
    @scene.setup
  end

  def render_frame
    @scene.render
  end

  def cleanup
    @scene.cleanup
  end
end

begin
  TestApp.new.run
rescue ex
  puts "FATAL ERROR: #{ex}"
end
