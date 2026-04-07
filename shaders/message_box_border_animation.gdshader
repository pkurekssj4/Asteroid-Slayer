shader_type canvas_item;

uniform float time_speed : hint_range(0.0, 5.0, 0.1) = 0.5;   // prędkość animacji
uniform float wave_freq : hint_range(0.1, 10.0, 0.1) = 3.0;   // częstotliwość fali
uniform float wave_amp  : hint_range(0.0, 1.0, 0.01) = 0.5;   // amplituda fali
uniform float alpha_channel : hint_range(0.0, 1.0, 0.01) = 1.0; // alfa
uniform float phase;

// Kolory graniczne (łatwo zmienić w edytorze)
uniform vec3 color_light = vec3(1.0, 1, 5);   // biały
uniform vec3 color_mid   = vec3(0.15, 0.3, 0.3);   // jasny niebieski
uniform vec3 color_dark  = vec3(0.1, 0.2, 0.3);   // ciemny niebieski

void fragment() {
    vec2 uv = UV;

    // fala sinusoidalna (oscyluje od -1 do 1)
    float wave = sin(uv.y * wave_freq + phase * time_speed) * wave_amp;

    // mapujemy wave -> [0..1]
    float t = (wave + 1.0) * 0.5;

    // mixowanie: biały -> jasny niebieski -> ciemny niebieski
    vec3 rgb;
    if (t < 0.5) {
        rgb = mix(color_light, color_mid, t * 2.0);
    } else {
        rgb = mix(color_mid, color_dark, (t - 0.5) * 2.0);
    }

    // finalny kolor z alfą tekstury
    COLOR = vec4(rgb, texture(TEXTURE, uv).a * alpha_channel);
}