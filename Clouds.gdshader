shader_type canvas_item;

uniform float scale = 0.1;
uniform int octaves = 5;
uniform vec2 speed = vec2(1.5,1.5);
uniform int pixelSize = 256;

const vec4 highlight = vec4(1,1,1,1);
const vec4 mid_value = vec4(1,1,1,0.5);
const vec4 low_value = vec4(1,1,1,0.1);

// Code for the fractal brownian motion with 2d noise texture
// https://godotshaders.com/snippet/fractal-brownian-motion-fbm/
float random(vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) *
            43758.5453123);
}

float noise(vec2 uv) {
    vec2 uv_index = floor(uv);
    vec2 uv_fract = fract(uv);

    // Four corners in 2D of a tile
    float a = random(uv_index);
    float b = random(uv_index + vec2(1.0, 0.0));
    float c = random(uv_index + vec2(0.0, 1.0));
    float d = random(uv_index + vec2(1.0, 1.0));

    vec2 blur = smoothstep(0.0, 1.0, uv_fract);

    return mix(a, b, blur.x) +
            (c - a) * blur.y * (1.0 - blur.x) +
            (d - b) * blur.x * blur.y;
}

float fbm(vec2 uv) {
//    int octaves = 100;
    float amplitude = 0.5;
    float frequency = scale;
	float value = 0.0;
	
    for(int i = 0; i < octaves; i++) {
        value += amplitude * noise(frequency * uv);
        amplitude *= 0.5;
        frequency *= 2.0;
    }
    return value;
}


vec4 evaluate(vec2 uv){
	float tex = fbm(uv);
	vec4 col = vec4(0);
	if (tex > 0.7){
		col = highlight;
	} else if(tex > 0.65){
		col = mid_value;
	} else if(tex > 0.63){
		col = low_value;
	} else {
		col = vec4(0);
	}
	
	
	return col;
}





void fragment(){
	vec2 uv;
	
	ivec2 size = textureSize(SCREEN_TEXTURE,0);
	int xRes = size.x;
	int yRes = size.y;
	
	float xFactor = float(xRes) / float(pixelSize);
	float yFactor = float(yRes) / float(pixelSize);
	
	float grid_uv_x = round(UV.x * xFactor) / xFactor;
	float grid_uv_y = round(UV.y * yFactor) / yFactor;
	vec2 gridUV = vec2(grid_uv_x,grid_uv_y);
	uv.x = gridUV.x + (TIME * speed.x); // positive towards left
	uv.y = gridUV.y + (TIME * speed.y) ; // positive towards top
    
	COLOR = evaluate(uv);
}


