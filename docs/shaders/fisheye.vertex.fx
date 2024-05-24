#version 300 es
precision highp float;

// Attributes
in vec3 position;
in vec2 uv;

// Output
out vec2 model_uv;

void main() {
    // Pass UV coordinate onto the fragment shader
    model_uv = uv;

    // Don't transform - expecting a fullscreen quad in 2D screen-space 
    gl_Position = vec4(position, 1.0);
}
