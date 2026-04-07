shader_type canvas_item;

uniform float phase : hint_range(0.0, 5.0) = 1.0;

vec3 hsv_to_rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
    // UV 0–1
    vec2 uv = UV;

    // Kierunek 135° (lewo-dół -> prawo-góra)
    vec2 dir = normalize(vec2(-10.0, -1.0));

    // Projekcja UV na kierunek
    float gradient = dot(uv, dir);

    // Animacja przesuwania
    gradient += phase;

    // Hue 0–1
    float hue = fract(gradient);

    // HSV → RGB (pełna saturacja i jasność)
    vec3 color = hsv_to_rgb(vec3(hue, 1.0, 1.0));

    COLOR = vec4(color, 1.0);
}