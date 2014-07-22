require "gl"

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


