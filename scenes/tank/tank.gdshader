shader_type canvas_item;

uniform float fill_level : hint_range(0.0, 1.0);
uniform float time : hint_range(0.0, 1000.0); // Pass from script

void fragment() {
    vec2 uv = UV;

    // Vertical wavy distortion for shimmer
    float wave_distort = sin(uv.x * 10.0 + time * 3.0) * 0.01;
    uv.y += wave_distort;

    // Waterline waving parameters
    float wave_amplitude = 0.015;
    float wave_frequency = 30.0;
    float wave_speed = 1.0;
    float waterline_wave = sin(uv.x * wave_frequency + time * wave_speed) * wave_amplitude;

    // Smooth fill edge with moving waterline
    float edge_width = 0.03;
    float fill_cutoff = 1.0 - fill_level + waterline_wave;
    float fill_alpha = smoothstep(fill_cutoff - edge_width, fill_cutoff, uv.y);

    // Discard fully transparent pixels (optional)
    if (fill_alpha < 0.01) {
        discard;
    }

    // Rotate gradient sampling by 180 degrees (flip both uv.x and uv.y)
    vec2 rotated_uv = vec2(1.0 - uv.y, 1.0 - uv.x);
    vec4 base_color = texture(TEXTURE, rotated_uv);

    // Bubble effect
    float bubble_seed = dot(uv * 100.0, vec2(12.9898, 78.233));
    float noise = fract(sin(bubble_seed) * 43758.5453);
    float bubble_mask = step(0.985, noise); // Sparse bubbles
    vec4 bubble_color = vec4(base_color.rgb, bubble_mask * 0.15);

    // Multiply color alpha by fill_alpha for smooth edge
    COLOR = vec4(base_color.rgb, base_color.a * fill_alpha) + bubble_color * fill_alpha;
}
