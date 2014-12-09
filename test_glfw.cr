require "./glfw_app"
require "./scene"

class TestApp < GlfwApp
  def initialize
    super

    @speed = 3_f32
    @mouse_speed = 0.05_f32

    @scene = Scene.new
    @scene.setup

    GLFW.get_cursor_pos @window, out @last_xpos, out @last_ypos
  end

  def process_inputs(delta_time)
    # process cursor position
    GLFW.get_cursor_pos @window, out xpos, out ypos

    @scene.horizontal_angle += @mouse_speed * delta_time * (@last_xpos - xpos)
    @scene.vertical_angle += @mouse_speed * delta_time * (@last_ypos - ypos)

    @last_xpos = xpos
    @last_ypos = ypos

    # process keys
    if GLFW.get_key(@window, GLFW::KEY_W) == GLFW::PRESS
      @scene.position += @scene.direction * delta_time * @speed
    end
    if GLFW.get_key(@window, GLFW::KEY_S) == GLFW::PRESS
      @scene.position -= @scene.direction * delta_time * @speed
    end
    if GLFW.get_key(@window, GLFW::KEY_A) == GLFW::PRESS
      @scene.position -= @scene.right * delta_time * @speed
    end
    if GLFW.get_key(@window, GLFW::KEY_D) == GLFW::PRESS
      @scene.position += @scene.right * delta_time * @speed
    end
  end

  def render_frame(delta_time)
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

