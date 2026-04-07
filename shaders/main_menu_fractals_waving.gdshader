shader_type canvas_item;

uniform float amplitude_x = 300.0;
uniform float frequency_x = 20.0;
uniform float speed_x = 0.1;

uniform float amplitude_y = 100.0;
uniform float frequency_y = 10.0;
uniform float speed_y = 0.2;

uniform float u_time = 0.0;

void fragment() {
    float wave_x = sin(UV.y * frequency_x + u_time * speed_x) * amplitude_x * TEXTURE_PIXEL_SIZE.x;
    float wave_y = cos(UV.x * frequency_y + u_time * speed_y) * amplitude_y * TEXTURE_PIXEL_SIZE.y;

    vec2 uv = UV + vec2(wave_x, wave_y);
    COLOR = texture(TEXTURE, uv);
    COLOR.a *= 0.2; // ← przezroczystość 30%
}