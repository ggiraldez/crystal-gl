require "spec"
require "glm"

describe "GLM" do
  describe "Vec3" do
    it "returns the length of a vector" do
      v = GLM.vec3 1,2,3
      v.length.should eq(Math.sqrt(14).to_f32)
    end

    it "normalizes a vector" do
      v = GLM.vec3 1,1,1
      w = v.normalize
      a = 1/Math.sqrt(3).to_f32
      [w.x, w.y, w.z].should eq([a,a,a])
    end

    it "computes the dot product" do
      v1 = GLM.vec3 1,2,3
      v2 = GLM.vec3 4,5,6
      v1.dot(v2).should eq(4+10+18)
    end

    it "calculates the cross product" do
      v1 = GLM.vec3 1,0,0
      v2 = GLM.vec3 0,1,0
      v3 = v1.cross(v2)
      [v3.x, v3.y, v3.z].should eq([0,0,1])
      v4 = v2.cross(v1)
      [v4.x, v4.y, v4.z].should eq([0,0,-1])
    end
  end

  describe "Mat4" do
    it "constructs a zero matrix" do
      m = GLM::Mat4.new
      0.upto(15) do |i|
        m[i].should eq(0)
      end
    end

    it "constructs the identity matrix" do
      m = GLM::Mat4.identity
      0.upto(15) do |i|
        m[i].should eq(i % 5 == 0 ? 1 : 0)
      end
    end

    it "constructs with a block with one param" do
      m = GLM::Mat4.new { |i| i.to_f32 }
      0.upto(15) do |i|
        m[i].should eq(i)
      end
    end

    it "constructs with a block with two params" do
      m = GLM::Mat4.new_with_row_col { |i,j| i.to_f32 }
      0.upto(15) do |i|
        m[i].should eq(i % 4)
      end
    end

    it "stores the values in column-major order" do
      m = GLM::Mat4.new_with_row_col { |i,j| i.to_f32 }
      m[2].should eq(2)
      m[8].should eq(0)

      m = GLM::Mat4.new { |i| i.to_f32 }
      m[2,0].should eq(2)
      m[0,2].should eq(8)
    end

    it "should compare for equality" do
      m1 = GLM::Mat4.identity
      m2 = GLM::Mat4.identity
      m3 = GLM::Mat4.new
      (m1 == m2).should be_true
      (m1 != m2).should be_false
      (m1 == m3).should be_false
      (m1 != m3).should be_true
    end

    it "should multiply by scalar" do
      m = GLM::Mat4.identity * 5
      0.upto(15) do |i|
        m[i].should eq(i % 5 == 0 ? 5 : 0)
      end
    end

    it "multiplication should have a neutral" do
      m1 = GLM::Mat4.identity
      m2 = GLM::Mat4.new { |i| i.to_f32 }
      ((m1 * m2) == m2).should eq(true)
      ((m2 * m1) == m2).should eq(true)
    end
  end
end
