require "sdl_gl_app"
require "scene"

class TestApp < SdlGlApp
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

TestApp.new.run

