require "gl"
require "glm"
require "./utils"
require "soil"

require "./models/cube"

class Scene
  property! :position
  property! :horizontal_angle
  property! :vertical_angle
  property! :fov

  def initialize
    @background_color = [0, 0, 0.4]

    gl_checked LibGL.gen_vertex_arrays 1, out @vertex_array_id

    LibGL.gen_buffers 1, out @vertex_buffer
    LibGL.gen_buffers 1, out @uv_buffer

    @program = load_shaders
    @model = Cube.new

    @texture = load_texture

    @position = GLM.vec3(0,0,5)
    @horizontal_angle = 3.14_f32
    @vertical_angle = 0_f32
    @fov = 45_f32
    @scene_ratio = 4.0/3.0
  end

  def direction
    GLM.vec3(Math.cos(@vertical_angle) * Math.sin(@horizontal_angle),
             Math.sin(@vertical_angle),
             Math.cos(@vertical_angle) * Math.cos(@horizontal_angle))
  end

  def right
    GLM.vec3(Math.sin(@horizontal_angle - Math::PI / 2),
             0,
             Math.cos(@horizontal_angle - Math::PI / 2))
  end

  def mvp
    dir = direction
    up = right.cross(dir)

    # Setup ModelViewProjection matrix
    projection = GLM.perspective @fov, @scene_ratio, 0.1, 100.0
    view = GLM.look_at @position, @position + dir, up
    model = GLM::Mat4.identity
    projection * view * model
  end

  def setup
    # Bind the VAO (vertex array object)
    gl_checked LibGL.bind_vertex_array @vertex_array_id

    # Bind and set the VBO (vertex buffer object) data
    LibGL.bind_buffer LibGL::ARRAY_BUFFER, @vertex_buffer
    LibGL.buffer_data LibGL::ARRAY_BUFFER, @model.vertices.size * sizeof(Float32), (@model.vertices.to_unsafe as Pointer(Void)), LibGL::STATIC_DRAW

    # Load the UV data into the uv_buffer
    LibGL.bind_buffer LibGL::ARRAY_BUFFER, @uv_buffer
    LibGL.buffer_data LibGL::ARRAY_BUFFER, @model.uv.size * sizeof(Float32), (@model.uv.to_unsafe as Pointer(Void)), LibGL::STATIC_DRAW

    # Enable and configure the attribute 0 for each vertex position
    LibGL.enable_vertex_attrib_array 0_u32
    LibGL.bind_buffer LibGL::ARRAY_BUFFER, @vertex_buffer
    LibGL.vertex_attrib_pointer 0_u32, 3, LibGL::FLOAT, LibGL::FALSE, 0, nil

    # Enable and configure the attribute 1 for each uv coordinate
    LibGL.enable_vertex_attrib_array 1_u32
    LibGL.bind_buffer LibGL::ARRAY_BUFFER, @uv_buffer
    gl_checked LibGL.vertex_attrib_pointer 1_u32, 2, LibGL::FLOAT, LibGL::FALSE, 0, nil

    LibGL.enable LibGL::DEPTH_TEST
    LibGL.depth_func LibGL::LESS
  end

  def render
    # Clear the scene
    GL.clear_color @background_color
    LibGL.clear LibGL::COLOR_BUFFER_BIT | LibGL::DEPTH_BUFFER_BIT

    # Use the shader program
    @program.use

    # Send the matrix to the shader program
    gl_checked @program.set_uniform_matrix_4f "MVP", false, mvp

    # Draw the vertices
    gl_checked LibGL.draw_arrays LibGL::TRIANGLES, 0, @model.vertices.size
  end

  def cleanup
    # Disable the shader program attribute
    LibGL.disable_vertex_attrib_array 0_u32
  end

  def load_shaders
    vertex_shader_code = File.read("shaders/vertex_shader.glsl")
    fragment_shader_code = File.read("shaders/fragment_shader.glsl")

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

  def load_texture
    image_data = SOIL.load_image("textures/crystal.png", out width, out height, out channels, SOIL::LOAD_RGB)
    LibGL.gen_textures 1, out tex_id
    LibGL.bind_texture LibGL::TEXTURE_2D, tex_id
    LibGL.tex_image_2d LibGL::TEXTURE_2D, 0, LibGL::RGB, width, height, 0, LibGL::RGB, LibGL::UNSIGNED_BYTE, image_data as Void*
    LibGL.tex_parameteri LibGL::TEXTURE_2D, LibGL::TEXTURE_MAG_FILTER, LibGL::LINEAR
    LibGL.tex_parameteri LibGL::TEXTURE_2D, LibGL::TEXTURE_MIN_FILTER, LibGL::LINEAR_MIPMAP_LINEAR
    LibGL.generate_mipmap LibGL::TEXTURE_2D
    SOIL.free_image_data image_data

    SOIL.load_texture("textures/crystal.png",
                      SOIL::LOAD_AUTO,
                      SOIL::CREATE_NEW_ID,
                      0_u32)

    puts "Loaded texture #{tex_id}"

    tex_id
  end
end

