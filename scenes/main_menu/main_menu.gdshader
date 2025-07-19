shader_type canvas_item;

uniform float time_speed = 0.25;
uniform float wave_strength = 0.03;
uniform float wave_scale = 7.0;
uniform float noise_scale = 8.0;
uniform float noise_strength = 0.08;
uniform vec4 base_color : source_color = vec4(1.0, 0.9, 0.3, 1.0); // golden yellow base

// Simplex-like noise function from IQ (improved smooth noise)
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1,311.7)))*43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);

    // Four corners in 2D of a tile
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    vec2 u = f*f*(3.0-2.0*f);

    return mix(a, b, u.x) + (c - a)* u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void fragment() {
    vec2 uv = UV;

    // Layered waves for organic liquid movement
    float wave1 = sin((uv.y + TIME * time_speed) * wave_scale);
    float wave2 = cos((uv.x * 1.3 + TIME * time_speed * 1.5) * wave_scale * 0.7);
    float wave3 = sin((uv.y * 1.5 - TIME * time_speed * 0.9) * wave_scale * 1.2);

    float wave_movement = wave1 + wave2 * 0.7 + wave3 * 0.5;

    // Apply wave displacement (subtle, on UVs for noise sampling)
    vec2 noise_uv = uv * noise_scale + vec2(wave_movement * 0.1, wave_movement * 0.1);

    // Get smooth noise for color variation
    float n = noise(noise_uv);

    // Base color with noise-based dark spots (simulate pee stains)
    vec3 color = base_color.rgb;

    // Darken spots softly
    color -= n * noise_strength;

    // Add subtle hue shift on waves for richness
    float hue_shift = 0.05 * sin(TIME * 2.0 + uv.x * 10.0);
    color.r += hue_shift;
    color.g -= hue_shift * 0.5;

    // Clamp color nicely
    color = clamp(color, vec3(0.0), vec3(1.0));

    COLOR = vec4(color, base_color.a);
}
