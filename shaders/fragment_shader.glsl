#version 330 core

// input from vertex shader
in vec2 UV;

// output color value
out vec3 color;

// the texture sampler
uniform sampler2D textureSampler;

void main() {
  color = texture(textureSampler, UV).rgb;
}

