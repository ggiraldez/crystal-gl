require "lib_gl"

macro gl_checked(call)
  value = {{call}}
  raise "OpenGL call failed: " + {{call.stringify}} if LibGL.get_error != LibGL::NO_ERROR
  value
end

module GL
  def self.last_error
    @@last_error = LibGL.get_error
    @@last_error = nil if @@last_error == LibGL::NO_ERROR
    @@last_error
  end

  def self.last_error_message
    case @@last_error
    when nil
      nil
    when LibGL::NO_ERROR
      nil
    when LibGL::INVALID_ENUM
      "INVALID_ENUM"
    when LibGL::INVALID_VALUE
      "INVALID_VALUE"
    when LibGL::INVALID_OPERATION
      "INVALID_OPERATION"
    when LibGL::STACK_OVERFLOW
      "STACK_OVERFLOW"
    when LibGL::STACK_UNDERFLOW
      "STACK_UNDERFLOW"
    when LibGL::OUT_OF_MEMORY
      "OUT_OF_MEMORY"
    else
      "UNKNOWN"
    end
  end

  def self.version
    String.new(LibGL.get_string(LibGL::VERSION))
  end

  def self.extensions
    LibGL.get_integerv(LibGL::NUM_EXTENSIONS, out n)
    extensions = [] of String
    0.upto(n - 1) do |i|
      extensions << String.new(LibGL.get_stringi(LibGL::EXTENSIONS, i.to_u32))
    end
    extensions
  end

  def self.clear_color(color)
    case color.size
    when 4
      clear_color color[0], color[1], color[2], color[3]
    when 3
      clear_color color[0], color[1], color[2], 0
    else
      raise "Invalid color specified. Needs 3 or 4 values"
    end
  end

  def self.clear_color(red, green, blue, alpha)
    LibGL.clear_color red.to_f32, green.to_f32, blue.to_f32, alpha.to_f32
  end

  def self.clear
    LibGL.clear LibGL::COLOR_BUFFER_BIT
  end

  def self.to_boolean(value)
    if value
      LibGL::TRUE
    else
      LibGL::FALSE
    end
  end

  class Shader
    def self.vertex(source = nil)
      shader = new LibGL::VERTEX_SHADER
      shader.with_source(source) if source
      shader
    end

    def self.fragment(source = nil)
      shader = new LibGL::FRAGMENT_SHADER
      shader.with_source(source) if source
      shader
    end

    def initialize(type : UInt32)
      @type = type
      @shader_id = LibGL.create_shader(@type)
    end

    def shader_id
      @shader_id
    end

    def with_source(source : String)
      p = source.to_unsafe
      LibGL.shader_source @shader_id, 1, pointerof(p), nil
      self
    end

    def compile
      LibGL.compile_shader @shader_id

      LibGL.get_shader_iv @shader_id, LibGL::COMPILE_STATUS, out result
      LibGL.get_shader_iv @shader_id, LibGL::INFO_LOG_LENGTH, out info_log_length
      info_log = String.new(info_log_length) do |buffer|
        LibGL.get_shader_info_log @shader_id, info_log_length, nil, buffer
        {info_log_length, info_log_length}
      end
      raise "Error compiling shader: #{info_log}" unless result

      self
    end

    def delete
      LibGL.delete_shader @shader_id
    end
  end

  class ShaderProgram
    def initialize
      @program_id = LibGL.create_program
    end

    def program_id
      @program_id
    end

    def attach(shader)
      LibGL.attach_shader @program_id, shader.shader_id
      self
    end

    def link
      LibGL.link_program @program_id

      LibGL.get_program_iv @program_id, LibGL::LINK_STATUS, out result
      LibGL.get_program_iv @program_id, LibGL::INFO_LOG_LENGTH, out info_log_length
      info_log = String.new(info_log_length) do |buffer|
        LibGL.get_program_info_log @program_id, info_log_length, nil, buffer
        {info_log_length, info_log_length}
      end
      raise "Error linking shader program: #{info_log}" unless result

      self
    end

    def use
      LibGL.use_program @program_id
      self
    end

    def set_uniform_matrix_4f(name, transpose, data)
      location = LibGL.get_uniform_location @program_id, name
      LibGL.uniform_matrix_4fv location, 1, GL.to_boolean(transpose), data
    end
  end
end
