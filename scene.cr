require "gl"
require "glm"
require "utils"

require "models/triangle"
require "models/cube"

class Scene
  def initialize
    @background_color = [0, 0, 0.4]

    LibGL.gen_vertex_arrays 1, out @vertex_array_id
    LibGL.gen_buffers 1, out @vertex_buffer

    @program = load_shaders
    @model = Cube.new
  end

  def mvp
    # Setup ModelViewProjection matrix
    projection = GLM.perspective 45.0, 4.0/3.0, 0.1, 100.0
    view = GLM.look_at GLM.vec3(4,3,3), GLM.vec3(0,0,0), GLM.vec3(0,1,0)
    model = GLM::Mat4.identity
    mvp = projection * view * model

    # puts "Projection"
    # dump_mat4 projection
    # puts "View"
    # dump_mat4 view
    # puts "MVP"
    # dump_mat4 mvp

    mvp
  end

  def setup
    # Create and bind the VAO (vertex array object)
    LibGL.bind_vertex_array @vertex_array_id

    # Create, bind and set the VBO (vertex buffer object) data
    LibGL.bind_buffer LibGL::ARRAY_BUFFER, @vertex_buffer
    LibGL.buffer_data LibGL::ARRAY_BUFFER, @model.vertices.length * sizeof(Float32), (@model.vertices.buffer as Void*), LibGL::STATIC_DRAW

    # Enable and configure the attribute 0 for the shader program
    LibGL.enable_vertex_attrib_array 0_u32
    #LibGL.bind_buffer LibGL::ARRAY_BUFFER, vertex_buffer
    LibGL.vertex_attrib_pointer 0_u32, 3, LibGL::FLOAT, LibGL::FALSE, 0, nil

    # Use the shader program
    @program.use

    # Send the matrix to the shader program
    @program.set_uniform_matrix_4f "MVP", false, mvp

    check_error "after set MVP uniform"
  end

  def render
    # Clear the scene
    GL.clear_color @background_color
    GL.clear

    # Draw the vertices
    LibGL.draw_arrays LibGL::TRIANGLES, 0, @model.vertices.length
     
    check_error "after render"
  end

  def cleanup
    # Disable the shader program attribute
    LibGL.disable_vertex_attrib_array 0_u32
  end

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
end

