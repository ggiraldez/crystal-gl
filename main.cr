require "gl"
require "glfw"
require "glew"
require "glm"

# Utility functions

def check_error(where="")
  if error = GL.last_error
    puts "GL error at #{where}: 0x#{error.to_s(16)} (#{GL.last_error_message})"
  end
end

def dump_mat4(m)
  0.upto(3) { |i|
    s = String.new_with_capacity(50) do |buffer|
      C.sprintf(buffer, "%6.3f  %6.3f  %6.3f  %6.3f", m[i,0].to_f64, m[i,1].to_f64, m[i,2].to_f64, m[i,3].to_f64)
    end
    puts s
  }
end

# Framework initialization (GLFW & GLEW)

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
 
window = GLFW.create_window 1024, 768, "Crystal OpenGL", nil, nil

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


# Actual OpenGL code starts here
 
def load_shaders
  vertex_shader_code = File.read("vertex_shader.glsl")
  fragment_shader_code = File.read("fragment_shader.glsl")

  vertex_shader = GL::Shader.vertex(vertex_shader_code).compile
  fragment_shader = GL::Shader.fragment(fragment_shader_code).compile

  program = GL::ShaderProgram.new
  program.attach vertex_shader
  program.attach fragment_shader
  program.link

  vertex_shader.delete
  fragment_shader.delete

  program
end

program = load_shaders


# This is just data

background_color = [0, 0, 0.4]

vertex_buffer_data = [-1, -1, 0,
                       1, -1, 0,
                       0,  1, 0].map {|x| x.to_f32}

# Create and bind the VAO (vertex array object)
LibGL.gen_vertex_arrays 1, out vertex_array_id
LibGL.bind_vertex_array vertex_array_id

# Create, bind and set the VBO (vertex buffer object) data
LibGL.gen_buffers 1, out vertex_buffer
LibGL.bind_buffer LibGL::ARRAY_BUFFER, vertex_buffer
LibGL.buffer_data LibGL::ARRAY_BUFFER, vertex_buffer_data.length * sizeof(Float32), (vertex_buffer_data.buffer as Void*), LibGL::STATIC_DRAW

# Enable and configure the attribute 0 for the shader program
LibGL.enable_vertex_attrib_array 0_u32
#LibGL.bind_buffer LibGL::ARRAY_BUFFER, vertex_buffer
LibGL.vertex_attrib_pointer 0_u32, 3, LibGL::FLOAT, LibGL::FALSE, 0, nil

# Use the shader program
program.use

# Setup ModelViewProjection matrix
projection = GLM.perspective 45.0, 4.0/3.0, 0.1, 100.0
view = GLM.look_at GLM.vec3(4,3,3), GLM.vec3(0,0,0), GLM.vec3(0,1,0)
model = GLM::Mat4.identity
mvp = projection * view * model

puts "Projection"
dump_mat4 projection
puts "View"
dump_mat4 view
puts "MVP"
dump_mat4 mvp

# Send the matrix to the shader program
program.set_uniform_matrix_4f "MVP", false, mvp.buffer

check_error "after set MVP uniform"

while true
  # Clear the scene
  GL.clear_color background_color
  GL.clear

  # Draw the vertices
  LibGL.draw_arrays LibGL::TRIANGLES, 0, 3
   
  check_error "after render"

  # Swap buffers and do the GLFW events bookkeeping
  GLFW.swap_buffers window
  GLFW.poll_events
  if GLFW.get_key(window, GLFW::KEY_ESCAPE) == GLFW::PRESS && 
     GLFW.window_should_close(window)
    break
  end
end

# Disable the shader program attribute
LibGL.disable_vertex_attrib_array 0_u32

# Deinitialize GLFW
GLFW.terminate

