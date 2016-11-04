class Triangle
  @@vertices = [
    -1_f32, -1_f32, 0_f32,
    1_f32, -1_f32, 0_f32,
    0_f32, 1_f32, 0_f32,
  ]

  def vertices
    @@vertices
  end
end
