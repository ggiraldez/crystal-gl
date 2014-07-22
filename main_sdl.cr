require "sdl_ext"
require "gl"
require "glm"
require "glew"
require "utils"

SDL.init

info = SDL.get_video_info
pixel_format = info->vfmt

raise "Cannot get video info" if info.nil?

puts "Flags: " + info->flags.to_s(2)
puts "Video memory: " + info->video_mem.to_s
puts "Palette: " + (pixel_format->palette.nil?.to_s ? "NO" : "YES")
puts "BPP: " + pixel_format->bits_per_pixel.to_s
puts "Screen dimensions: " + info->current_w.to_s + "x" + info->current_h.to_s

width = 1024
height = 768
bpp = pixel_format->bits_per_pixel

SDL.gl_set_attribute(LibSDL::GLAttribute::GL_RED_SIZE, 5)
SDL.gl_set_attribute(LibSDL::GLAttribute::GL_GREEN_SIZE, 5)
SDL.gl_set_attribute(LibSDL::GLAttribute::GL_BLUE_SIZE, 5)
SDL.gl_set_attribute(LibSDL::GLAttribute::GL_DEPTH_SIZE, 16)
SDL.gl_set_attribute(LibSDL::GLAttribute::GL_DOUBLEBUFFER, 1)

flags = LibSDL::OPENGL

surface = SDL.set_video_mode(width, height, bpp.to_i32, flags)

raise "Cannot set video mode" if surface.nil?

GLEW.experimental = LibGL::TRUE
unless GLEW.init == GLEW::OK
  puts "Failed to initialize GLEW"
  exit 1
end
check_error "after GLEW initialization"

puts "OpenGL version: " + GL.version

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
check_error "after creating VAO"
LibGL.bind_vertex_array vertex_array_id

check_error "after configuring VAO"

# Create, bind and set the VBO (vertex buffer object) data
LibGL.gen_buffers 1, out vertex_buffer
LibGL.bind_buffer LibGL::ARRAY_BUFFER, vertex_buffer
LibGL.buffer_data LibGL::ARRAY_BUFFER, vertex_buffer_data.length * sizeof(Float32), (vertex_buffer_data.buffer as Void*), LibGL::STATIC_DRAW

check_error "after configuring VBO"

# Enable and configure the attribute 0 for the shader program
LibGL.enable_vertex_attrib_array 0_u32
#LibGL.bind_buffer LibGL::ARRAY_BUFFER, vertex_buffer
LibGL.vertex_attrib_pointer 0_u32, 3, LibGL::FLOAT, LibGL::FALSE, 0, nil

check_error "after configuring VBO and VAO"

# Use the shader program
program.use

check_error "after program use"

# Setup ModelViewProjection matrix
projection = GLM.perspective 45.0, 4.0/3.0, 0.1, 100.0
view = GLM.look_at GLM.vec3(4,3,3), GLM.vec3(0,0,0), GLM.vec3(0,1,0)
model = GLM::Mat4.identity
mvp = projection * view * model

#puts "Projection"
#dump_mat4 projection
#puts "View"
#dump_mat4 view
#puts "MVP"
#dump_mat4 mvp

# Send the matrix to the shader program
program.set_uniform_matrix_4f "MVP", false, mvp

check_error "after set MVP uniform"

frames = 0
start = SDL.ticks
running = true

while running
  SDL.poll_events do |event|
    if event.type == LibSDL::QUIT || (event.type == LibSDL::KEYDOWN)
      running = false
    end
  end

  # Clear the scene
  GL.clear_color background_color
  GL.clear

  # Draw the vertices
  LibGL.draw_arrays LibGL::TRIANGLES, 0, 3
   
  check_error "after render"

  SDL.gl_swap_buffers

  frames += 1
end

# Disable the shader program attribute
LibGL.disable_vertex_attrib_array 0_u32

ms = SDL.ticks - start
puts "#{frames} in #{ms} ms"
puts "FPS: #{frames / (ms * 0.001)}"

SDL.quit

