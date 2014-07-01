require "lib_gl"

lib GLEW("glew")
  OK = 0

  $experimental = glewExperimental : LibGL::Boolean

  fun init = glewInit() : Int32
end

