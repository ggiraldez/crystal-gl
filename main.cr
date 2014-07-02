require "gl"
require "glfw"
require "glew"

def check_error(where="")
  error = GL.last_error
  if error
    puts "GL error at #{where}: 0x#{error.to_s(16)} (#{GL.last_error_message})"
  end
end

unless GLFW.init
  puts "Failed to initialize GLFW"
  exit 1
else
  puts "GLFW initialization successful"
end

GLFW.window_hint GLFW::SAMPLES, 4
GLFW.window_hint GLFW::CONTEXT_VERSION_MAJOR, 3
GLFW.window_hint GLFW::CONTEXT_VERSION_MINOR, 3
GLFW.window_hint GLFW::OPENGL_FORWARD_COMPAT, 1
GLFW.window_hint GLFW::OPENGL_PROFILE, GLFW::OPENGL_CORE_PROFILE
 
window = GLFW.create_window 1024, 768, "Tutorial 01", nil, nil

unless window
  puts "Failed to open GLFW window"
  GLFW.terminate
  exit 1
end

GLFW.set_current_context window

GLEW.experimental = LibGL::TRUE
unless GLEW.init == GLEW::OK
  puts "Failed to initialize GLEW"
  GLFW.terminate
  exit 1
end
check_error "after GLEW initialization"

GLFW.set_input_mode window, GLFW::STICKY_KEYS, 1
 
LibGL.gen_vertex_arrays 1, out vertex_array_id
LibGL.bind_vertex_array vertex_array_id

vertex_buffer_data = [-1, -1, 0,
                       1, -1, 0,
                       0,  1, 0].map {|x| x.to_f32}

LibGL.gen_buffers 1, out vertex_buffer
LibGL.bind_buffer LibGL::ARRAY_BUFFER, vertex_buffer
LibGL.buffer_data LibGL::ARRAY_BUFFER, vertex_buffer_data.length * sizeof(Float32), (vertex_buffer_data.buffer as Void*), LibGL::STATIC_DRAW

check_error "after initialization"

def load_shaders
  vertex_shader_id = LibGL.create_shader(LibGL::VERTEX_SHADER)
  fragment_shader_id = LibGL.create_shader(LibGL::FRAGMENT_SHADER)
  check_error "after shader creation"

  vertex_shader_code = File.read("vertex_shader.glsl")
  fragment_shader_code = File.read("fragment_shader.glsl")

  p = vertex_shader_code.cstr
  LibGL.shader_source vertex_shader_id, 1, pointerof(p), nil
  LibGL.compile_shader vertex_shader_id

  LibGL.get_shader_iv vertex_shader_id, LibGL::COMPILE_STATUS, out result
  LibGL.get_shader_iv vertex_shader_id, LibGL::INFO_LOG_LENGTH, out info_log_length
  info_log = String.new_with_length(info_log_length) do |buffer|
    LibGL.get_shader_info_log vertex_shader_id, info_log_length, nil, buffer
  end
  check_error "after vertex shader compilation"

  puts "Vertex shader compilation #{result ? "OK" : "ERROR: " + info_log}"

  p = fragment_shader_code.cstr
  LibGL.shader_source fragment_shader_id, 1, pointerof(p), nil
  LibGL.compile_shader fragment_shader_id

  LibGL.get_shader_iv fragment_shader_id, LibGL::COMPILE_STATUS, out result
  LibGL.get_shader_iv fragment_shader_id, LibGL::INFO_LOG_LENGTH, out info_log_length
  info_log = String.new_with_length(info_log_length) do |buffer|
    LibGL.get_shader_info_log fragment_shader_id, info_log_length, nil, buffer
  end
  check_error "after fragment shader compilation"

  puts "Fragment shader compilation #{result ? "OK" : "ERROR: " + info_log}"

  program_id = LibGL.create_program
  LibGL.attach_shader program_id, vertex_shader_id
  LibGL.attach_shader program_id, fragment_shader_id
  LibGL.link_program program_id

  check_error "after program linking"

  LibGL.get_program_iv program_id, LibGL::LINK_STATUS, out result
  LibGL.get_program_iv program_id, LibGL::INFO_LOG_LENGTH, out info_log_length
  info_log = String.new_with_length(info_log_length) do |buffer|
    LibGL.get_program_info_log program_id, info_log_length, nil, buffer
  end

  puts "Program link #{result ? "OK" : "ERROR: " + info_log}"

  check_error "after checking link status"

  LibGL.delete_shader vertex_shader_id
  LibGL.delete_shader fragment_shader_id

  check_error "after deleting shaders"

  return program_id
end

program_id = load_shaders

while true
  LibGL.clear_color 0_f32, 0_f32, 0.4_f32, 0_f32
  LibGL.clear LibGL::COLOR_BUFFER_BIT

  LibGL.use_program program_id

  LibGL.enable_vertex_attrib_array 0_u32
  LibGL.bind_buffer LibGL::ARRAY_BUFFER, vertex_buffer
  LibGL.vertex_attrib_pointer 0_u32, 3, LibGL::FLOAT, LibGL::FALSE, 0, nil

  LibGL.draw_arrays LibGL::TRIANGLES, 0, 3
   
  LibGL.disable_vertex_attrib_array 0_u32

  check_error "after render"

  GLFW.swap_buffers window
  GLFW.poll_events

  if GLFW.get_key(window, GLFW::KEY_ESCAPE) == GLFW::PRESS && 
     GLFW.window_should_close(window)
    break
  end
end

GLFW.terminate

