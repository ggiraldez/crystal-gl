# FIXME: propose moving these into Crystal std-library
struct Float32
  def self.zero
    0_f32
  end
  def self.one
    1_f32
  end
end
struct Float64
  def self.zero
    0_f64
  end
  def self.one
    1_f64
  end
end


module GLM
  def self.deg_to_rad(d)
    d / 180.0 * Math::PI
  end

  struct TVec3(T)
    @buffer :: T*

    def self.zero
      new T.zero, T.zero, T.zero
    end

    def initialize(x, y, z)
      @buffer = Pointer(T).malloc(3)
      @buffer[0] = x
      @buffer[1] = y
      @buffer[2] = z
    end

    def [](i : Int32)
      raise IndexOutOfBounds.new if i >= 3 || i < 0
      @buffer[i]
    end

    def []=(i : Int32, value)
      raise IndexOutOfBounds.new if i >= 3 || i < 0
      @buffer[i] = value
    end

    def x
      @buffer[0]
    end

    def x=(value)
      @buffer[0] = value
    end

    def y
      @buffer[1]
    end

    def y=(value)
      @buffer[1] = value
    end

    def z
      @buffer[2]
    end

    def z=(value)
      @buffer[2] = value
    end

    def +(v : TVec3(T))
      TVec3(T).new(x + v.x, y + v.y, z + v.z)
    end

    def -(v : TVec3(T))
      TVec3(T).new(x - v.x, y - v.y, z - v.z)
    end

    def *(a : T)
      TVec3(T).new(x * a, y * a, z * a)
    end

    def /(a : T)
      TVec3(T).new(x / a, y / a, z / a)
    end

    def length
      Math.sqrt(x * x + y * y + z * z)
    end

    def normalize
      self / length
    end

    def cross(v : TVec3(T))
      TVec3(T).new(y * v.z - v.y * z,
                   z * v.x - v.z * x,
                   x * v.y - v.x * y)
    end

    def dot(v : TVec3(T))
      x * v.x + y * v.y + z * v.z
    end
  end

  struct TMat4(T)
    @buffer :: T*

    def self.zero
      TMat4(T).new { T.zero }
    end

    def self.identity
      m = zero
      m[0] = m[5] = m[10] = m[15] = T.one
      m
    end

    def self.new(&block : Int32 -> T)
      m = TMat4(T).new
      p = m.buffer
      0.upto(15) { |i|
        p[i] = yield i
      }
      m
    end

    def self.new_with_row_col(&block : (Int32, Int32) -> T)
      m = TMat4(T).new
      p = m.buffer
      0.upto(3) { |i|
        0.upto(3) { |j|
          p[i + 4*j] = yield i, j
        }
      }
      m
    end

    def initialize
      @buffer = Pointer(T).malloc(16)
    end

    def ==(m : TMat4(T))
      0.upto(15) { |i|
        return false if @buffer[i] != m.buffer[i]
      }
      return true
    end

    def !=(m : TMat4(T))
      !(self == m)
    end

    def *(v)
      m = TMat4(T).new
      0.upto(15) { |i|
        m.buffer[i] = @buffer[i] * v
      }
      m
    end

    def *(m : TMat4(T))
      r = TMat4(T).new_with_row_col { |i, j|
        p1 = @buffer + i
        p2 = m.buffer + 4*j
        p1[0] * p2[0] + p1[4] * p2[1] + p1[8] * p2[2] + p1[12] * p2[3]
      }
      r
    end

    def buffer
      @buffer
    end

    def to_unsafe
      @buffer
    end

    def [](i)
      raise IndexOutOfBounds.new if i < 0 || i >= 16
      @buffer[i]
    end

    def [](row, col)
      self[row + col*4]
    end

    def []=(i, value : T)
      raise IndexOutOfBounds.new if i < 0 || i >= 16
      @buffer[i] = value
    end

    def []=(row, col, value : T)
      self[row + col*4] = value
    end
  end

  alias Mat4 = TMat4(Float32)
  alias Vec3 = TVec3(Float32)

  def self.vec3(x, y, z)
    Vec3.new x.to_f32, y.to_f32, z.to_f32
  end

  # OpenGL utility constructors

  def self.perspective(fov_y, aspect, near, far)
    raise ArgumentError.new if aspect == 0 || near == far
    rad = GLM.deg_to_rad(fov_y)
    tan_half_fov = Math.tan(rad / 2)

    m = Mat4.zero
    m[0,0] = 1 / (aspect * tan_half_fov).to_f32
    m[1,1] = 1 / tan_half_fov.to_f32
    m[2,2] = -(far + near).to_f32 / (far - near).to_f32
    m[3,2] = -1_f32
    m[2,3] = -(2_f32 * far * near) / (far - near)
    m
  end

  def self.look_at(eye : Vec3, center : Vec3, up : Vec3)
    f = (center - eye).normalize
    s = f.cross(up).normalize
    u = s.cross(f)

    m = Mat4.identity
    m[0,0] = s.x
    m[0,1] = s.y
    m[0,2] = s.z
    m[1,0] = u.x
    m[1,1] = u.y
    m[1,2] = u.z
    m[2,0] = -f.x
    m[2,1] = -f.y
    m[2,2] = -f.z
    m[0,3] = -s.dot(eye)
    m[1,3] = -u.dot(eye)
    m[2,3] = f.dot(eye)
    m
  end
end

