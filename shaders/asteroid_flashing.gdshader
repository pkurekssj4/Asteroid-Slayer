shader_type canvas_item;

uniform float frequency = 10.0;
uniform float wave_speed = 0.0;
uniform float wave_amplitude = 0.0;
uniform vec4 custom_color = vec4(0.0, 0.0, 0.0, 0.0);
uniform float phase;

void fragment() {
    float wave_x = sin(UV.y * frequency + phase * wave_speed) * wave_amplitude;
    float wave_y = cos(UV.x * frequency + phase * wave_speed) * wave_amplitude;
    vec2 uv = UV + vec2(wave_x, wave_y);
    COLOR = texture(TEXTURE, uv) * custom_color;
}