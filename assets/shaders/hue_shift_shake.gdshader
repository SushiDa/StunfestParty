shader_type canvas_item;

uniform float shift_amount: hint_range(0.0, 360.0, 1.0) = 0.0;

uniform bool shaking       = false;
uniform float amplitude    = 1.0;
uniform float noise_scale  = 20.0;
uniform float noise_speed  = 20.0;
float hash(vec2 p) {
  return fract(sin(dot(p, vec2(127.1,311.7))) * 43758.5453123);
}

float noise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  float a = hash(i + vec2(0.0,0.0));
  float b = hash(i + vec2(1.0,0.0));
  float c = hash(i + vec2(0.0,1.0));
  float d = hash(i + vec2(1.0,1.0));
  vec2 u = f*f*(3.0-2.0*f);
  return mix(a, b, u.x) +
  (c - a) * u.y * (1.0 - u.x) +
  (d - b) * u.x * u.y;
}
// Convert RGB color to HSV color space
// Input: vec3 with components in range [0, 1]
// Output: vec3 with h in [0, 360], s and v in [0, 1]
vec3 rgb2hsv(vec3 rgb) {
	float r = rgb.r;
	float g = rgb.g;
	float b = rgb.b;
	
	float max_val = max(r, max(g, b));
	float min_val = min(r, min(g, b));
	float delta = max_val - min_val;
	
	float h = 0.0;
	float s = 0.0;
	float v = max_val;
	
	if (delta > 0.0001) {
		s = delta / max_val;
		
		if (abs(r - max_val) < 0.0001)      h = (g - b) / delta;
		else if (abs(g - max_val) < 0.0001) h = 2.0 + (b - r) / delta;
		else                                h = 4.0 + (r - g) / delta;
		
		h *= 60.0;
		if (h < 0.0) h += 360.0;
	}
	
	return vec3(h, s, v);
}

// Convert HSV color to RGB color space
// Input: vec3 with h in [0, 360], s and v in [0, 1]
// Output: vec3 with components in range [0, 1]
vec3 hsv2rgb(vec3 hsv) {
	float h = hsv.x;
	float s = hsv.y;
	float v = hsv.z;
	
	float c = v * s;
	float x = c * (1.0 - abs(mod(h / 60.0, 2.0) - 1.0));
	float m = v - c;
	
	vec3 rgb;
	
	if (h < 60.0)       rgb = vec3(c, x, 0.0);
	else if (h < 120.0) rgb = vec3(x, c, 0.0);
	else if (h < 180.0) rgb = vec3(0.0, c, x);
	else if (h < 240.0) rgb = vec3(0.0, x, c);
	else if (h < 300.0) rgb = vec3(x, 0.0, c);
	else                rgb = vec3(c, 0.0, x);
	
	rgb += m;
	return rgb;
}

void fragment() {
	
	
	if (shaking) {
	    vec2 uv = UV;
	    vec4 orig = texture(TEXTURE, uv);
	    if (orig.a <= 0.0) {
	      discard;
	    }

	    // Generate two noise values to construct a random direction.
	    float nx = noise(uv * noise_scale + vec2(TIME * noise_speed, 0.0));
	    float ny = noise(uv * noise_scale + vec2(0.0, TIME * noise_speed));
	    // Map [0,1] to [-1,1]
	    vec2 rand_dir = normalize(vec2(nx * 2.0 - 1.0, ny * 2.0 - 1.0));

	    // Use another noise value to determine the jitter amplitude sign.
	    float n = noise(uv * noise_scale + vec2(TIME * noise_speed));
	    float off = (n * 2.0 - 1.0) * amplitude;

	    // Offset along a random direction
	    vec2 uv2 = uv + rand_dir * off * TEXTURE_PIXEL_SIZE;
	    COLOR = texture(TEXTURE, uv2);
	}
	
	vec3 hsv_color = rgb2hsv(COLOR.rgb);
	hsv_color.x = mod(hsv_color.x + shift_amount, 360.0);
	COLOR.rgb = hsv2rgb(hsv_color);
}
