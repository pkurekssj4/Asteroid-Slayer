shader_type canvas_item;

uniform float wave_strength : hint_range(0.0,10.0) = 0.3;
uniform float wave_freq : hint_range(0.0,200.0) = 25.0;
uniform float speed : hint_range(0.0,10.0) = 0.6;
uniform float phase;

void fragment() {
    vec2 uv = UV;

    // falowanie UV w czasie
    float wave = sin((uv.y + phase * speed) * wave_freq) * wave_strength;
    uv.x += wave * 0.025; // poziome zniekształcenie
    uv.y += wave * 0.025; // opcjonalne pionowe

    vec4 tex = texture(TEXTURE, uv);

    // nie zmieniamy koloru – zachowuje kolor z emitera
    COLOR = tex;
}