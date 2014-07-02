require "lib_gl"

module GL
  def self.last_error
    @last_error = LibGL.get_error
    @last_error = nil if @last_error == LibGL::NO_ERROR
  end

  def self.last_error_message
    case @last_error
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

  class Shader
    def initialize(type)

    end
  end
end

