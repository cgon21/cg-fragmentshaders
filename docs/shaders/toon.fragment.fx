#version 300 es
precision mediump float;

// Input
in vec2 model_uv;

// Uniforms
uniform sampler2D image;

// Output
out vec4 FragColor;

void main() {
    // Color
    vec4 color = texture(image, model_uv);

    // Round each color component to one of 5 levels (0.0, 0.25, 0.5, 0.75, 1.0)
    // Rounding can be done by multiplying by 4.0, then rounding, then dividing by 4.0
    color.r = floor(color.r * 4.0) / 4.0;
    color.g = floor(color.g * 4.0) / 4.0;
    color.b = floor(color.b * 4.0) / 4.0;

    // Set the final color
    FragColor = color;
}
