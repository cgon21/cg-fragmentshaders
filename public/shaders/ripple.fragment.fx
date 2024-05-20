#version 300 es
precision mediump float;

// Input
in vec2 model_uv;

// Uniforms
uniform sampler2D image;
uniform float time;

// Output
out vec4 FragColor;

void main() {
    // Scale and translate the texture coordinate such that it is in the range [-1.0, 1.0]
    // Multiply by 2, then subtract 1
    vec2 uv = model_uv * 2.0 - 1.0;

    // Calculate radius = magnitude of texture coordinate
    float radius = length(uv);

    // Calculate a texture coordinate offset = texture_coordinate * (sin(radius * 30.0 - time * 5.0) + 0.5) / 60.0
    vec2 offset = uv * (sin(radius * 30.0 - time * 5.0) + 0.5) / 60.0;

    // Calculate final texture coordinate = original_texture_coordinate + texture_coordinate_offset
    vec2 final_uv = model_uv + offset;

    // Fetch the color from the texture
    FragColor = texture(image, final_uv);
}
