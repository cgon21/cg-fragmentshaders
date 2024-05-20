#version 300 es
precision mediump float;

// Input
in vec2 model_uv;

// Uniforms
uniform sampler2D image;

// Output
out vec4 FragColor;

void main() {
    // High Contrast
    // Scale RGB away from 50% bright
    // Makes bright colors brighter and dim colors dimmer

    // Color
    vec4 color = texture(image, model_uv);

    // Apply high contrast transformation (scale RGB away from 50% bright)
    color.rgb = (color.rgb - 0.5) * 2.0 + 0.5;

    // Set the final color
    FragColor = color;
}
