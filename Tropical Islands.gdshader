shader_type canvas_item;

uniform float scale = 0.1;
uniform int octaves = 10;
uniform vec2 speed = vec2(1,1);
uniform int pixelSize = 256;

// colors from @cmzw_ 's tweet
// https://twitter.com/cmzw_/status/1608396756362080256
const vec3 mountain = vec3(72., 95., 77.);
const vec3 hill = vec3(88., 139., 92.);
const vec3 high_ground = vec3(169., 152., 70.);
const vec3 mid_ground = vec3(195., 170., 102.);
const vec3 low_ground = vec3(246., 210., 144.);
const vec3 coast = vec3(55., 81., 114.);
const vec3 shallow = vec3(28., 66., 85.);
const vec3 deep = vec3(29., 45., 68.);
const vec3 ocean = vec3(33., 55., 79.);

vec3 normalize_rgb(vec3 color){
	vec3 OldMin = vec3(0.);
	vec3 NewMin = vec3(0.);
	vec3 NewMax = vec3(1.);
	vec3 OldMax = vec3(255.);
	return (((color - OldMin) * (NewMax - NewMin)) / (OldMax - OldMin)) + NewMin;
}

////////////////////////////////////////////////////////////////
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
////////////////////////////////////////////////

vec4 evaluate(vec2 uv){
	float tex = fbm(uv);
	vec3 col = vec3(0);
	if (tex > 0.7){
		col = normalize_rgb(mountain);
	} else if(tex > 0.65){
		col = normalize_rgb(hill);
	} else if(tex > 0.6){
		col = normalize_rgb(high_ground);
	} else if(tex > 0.5){
		 col = normalize_rgb(mid_ground);
	} else if(tex > 0.45){
		col = normalize_rgb(low_ground);
	} else if(tex > 0.35){
		col = normalize_rgb(coast);
	
	} else if(tex > 0.3){
		col = normalize_rgb(deep);
	}
	else if(tex > 0.01){
		col = normalize_rgb(ocean);
	} else {
		col = vec3(0);
	}
	
	
	
	return vec4(col,1.);
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


