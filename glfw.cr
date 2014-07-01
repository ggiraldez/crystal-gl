lib GLFW("glfw3")
  type Window : Void*
  type Monitor : Void*

  SAMPLES = 0x0002100D_i32

  CONTEXT_VERSION_MAJOR = 0x00022002_i32
  CONTEXT_VERSION_MINOR = 0x00022003_i32

  OPENGL_FORWARD_COMPAT = 0x00022006_i32
  OPENGL_PROFILE = 0x00022008_i32
  OPENGL_CORE_PROFILE = 0x00032001_i32

  STICKY_KEYS = 0x00033002

  RELEASE = 0
  PRESS = 1
  REPEAT = 2

  KEY_ESCAPE = 256

  fun init = glfwInit() : Int32
  fun window_hint = glfwWindowHint(target : Int32, hint : Int32) : Void
  fun terminate = glfwTerminate() : Void

  fun create_window = glfwCreateWindow(width : Int32, height : Int32, title : UInt8*, monitor : Monitor, share : Window) : Window
  fun set_current_context = glfwMakeContextCurrent(window : Window) : Void
  fun get_current_context = glfwGetCurrentContext() : Window

  fun set_input_mode = glfwSetInputMode(window : Window, mode : Int32, value : Int32) : Void
  fun swap_buffers = glfwSwapBuffers(window : Window) : Void
  fun poll_events = glfwPollEvents() : Void
  fun get_key = glfwGetKey(window : Window, key : Int32) : Int32
  fun window_should_close = glfwWindowShouldClose(window : Window) : Int32
end


