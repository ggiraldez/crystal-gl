require "glfw"
require "glew"
require "gl"

abstract class GlfwApp
  def initialize(@width = 1024, @height = 768)
    unless GLFW.init
      raise "Failed to initialize GLFW"
    end

    GLFW.window_hint GLFW::SAMPLES, 4
    GLFW.window_hint GLFW::CONTEXT_VERSION_MAJOR, 3
    GLFW.window_hint GLFW::CONTEXT_VERSION_MINOR, 3
    GLFW.window_hint GLFW::OPENGL_FORWARD_COMPAT, 1
    GLFW.window_hint GLFW::OPENGL_PROFILE, GLFW::OPENGL_CORE_PROFILE

    @window = GLFW.create_window @width, @height, "Crystal OpenGL", nil, nil

    raise "Failed to open GLFW window" if @window.null?

    GLFW.set_current_context @window

    GLEW.experimental = LibGL::TRUE
    unless GLEW.init == GLEW::OK
      raise "Failed to initialize GLEW"
    end
    check_error "after GLEW initialization (ignore on OSX)"

    GLFW.set_input_mode @window, GLFW::STICKY_KEYS, 1
    GLFW.set_input_mode @window, GLFW::CURSOR, GLFW::CURSOR_DISABLED

    puts "OpenGL version: " + GL.version
    puts "OpenGL extensions: " + GL.extensions.join(", ")
  end

  def run
    frames = 0
    start = last_time = GLFW.get_time

    while true
      GLFW.poll_events
      if GLFW.get_key(@window, GLFW::KEY_ESCAPE) == GLFW::PRESS &&
         GLFW.window_should_close(@window)
        break
      end

      current_time = GLFW.get_time
      delta_time = current_time - last_time

      process_inputs delta_time
      render_frame delta_time

      frames += 1
      last_time = current_time

      # Swap buffers and do the GLFW events bookkeeping
      GLFW.swap_buffers @window
    end

    delta_t = GLFW.get_time - start
    puts "#{frames} in #{delta_t} secs"
    puts "FPS: #{frames / delta_t}"

    terminate
  end

  def terminate
    cleanup
    GLFW.terminate
  end

  abstract def process_inputs(delta_time)
  abstract def render_frame(delta_time)
  abstract def cleanup
end
