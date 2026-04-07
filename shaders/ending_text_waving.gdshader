shader_type canvas_item;

uniform float time_speed : hint_range(0.0, 2.0, 0.1) = 1; // prędkość animacji
uniform float wave_amp : hint_range(0.0, 30.0, 0.1) = 3.0;   // amplituda falowania
uniform float wave_freq : hint_range(0.0, 10.0, 0.1) = 5.0;   // częstotliwość falowania
uniform float alpha_channel : hint_range(0.0, 1.0, 0.01) = 1.0; // kontrola alfa z kodu
uniform float phase;

void fragment() {
    vec2 uv = UV;

    // RAINBOW: przesuwamy kolory HSV -> RGB
    float hue = mod(phase * time_speed + uv.y, 1.0); // zmiana barwy po czasie
    vec3 rgb = vec3(0.0);

    // konwersja HSV -> RGB (hue, 1, 1)
    float c = 1.0;
    float h = hue * 6.0;
    float x = c * (1.0 - abs(mod(h, 2.0) - 1.0));

    if (0.0 <= h && h < 1.0) rgb = vec3(c, x, 0.0);
    else if (1.0 <= h && h < 2.0) rgb = vec3(x, c, 0.0);
    else if (2.0 <= h && h < 3.0) rgb = vec3(0.0, c, x);
    else if (3.0 <= h && h < 4.0) rgb = vec3(0.0, x, c);
    else if (4.0 <= h && h < 5.0) rgb = vec3(x, 0.0, c);
    else if (5.0 <= h && h < 6.0) rgb = vec3(c, 0.0, x);

    COLOR = vec4(rgb, texture(TEXTURE, uv).a * alpha_channel);
}

void vertex() {
    // efekt falowania w pionie
    VERTEX.y += sin((UV.y + phase * time_speed) * wave_freq) * wave_amp;
}