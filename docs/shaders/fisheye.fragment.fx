#version 300 es
precision mediump float;

// Input
in vec2 model_uv;

// Uniforms
uniform sampler2D image;

// Output
out vec4 FragColor;

void main() {
    // In order to accomplish a barrel distortion, implement the following equations:
    // Scale and translate the texture coordinate such that it is in the range [-1.0, 1.0]
    // Multiply by 2, then subtract 1
    vec2 uv = model_uv * 2.0 - 1.0;

    // Calculate 𝜽 = arctan(texture_coordinate_y, texture_coordinate_x)
    float theta = atan(uv.y, uv.x);

    // Calculate radius = magnitude of texture coordinate, raised to the power of 1.5
    float radius = pow(length(uv), 1.5);

    // Calculate fish eye texture coordinate = (radius * cos(𝜽),  radius * sin(𝜽))
    vec2 fishEyeUV = vec2(radius * cos(theta), radius * sin(theta));

    // Re-scale final texture coordinate in range [0.0, 1.0]
    // Final texture coordinate = 0.5 * (fish eye texture coordinate + 1.0)
    fishEyeUV = 0.5 * (fishEyeUV + 1.0);

    // Fetch the color from the texture
    FragColor = texture(image, fishEyeUV);
}
