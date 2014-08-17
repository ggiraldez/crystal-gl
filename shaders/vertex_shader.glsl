#version 330 core

// vertex input data
layout(location = 0) in vec3 vertexPosition_modelspace;
layout(location = 1) in vec2 vertexUV;

// output values for fragment shader
out vec2 UV;

// model/view/projection matrix
uniform mat4 MVP;

void main() {
  gl_Position = MVP * vec4(vertexPosition_modelspace, 1);

  UV = vertexUV;
}
