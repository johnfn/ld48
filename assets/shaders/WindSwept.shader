shader_type canvas_item; 

// Color parameters
uniform float white;
uniform float red;

// Windswept parameters
uniform float wind_magnitude = 0.0; // HOW DOES THIS GET A NONZERO VALUE LOL GABBY HELP
uniform vec2 global_xy = vec2(0,0);


void fragment() {
  // Color flashing on hit
	vec4 texture_color = texture(TEXTURE, UV);
	if (white > 0.0) {
			COLOR = vec4(mix(texture_color.rgb, vec3(1,1,1), white), texture_color.a);
	} else if (red > 0.0) {
			COLOR = vec4(mix(texture_color.rgb, vec3(1,0,0), red), texture_color.a);
	} else {
			COLOR = texture(TEXTURE,UV);
	}
}

void vertex() {
   	// Windswept effect
 	float seeded_time = TIME + global_xy.x+global_xy.y;
 	vec2 impact = vec2(1,0);
 	vec2 size = vec2(1./TEXTURE_PIXEL_SIZE.x, 1./TEXTURE_PIXEL_SIZE.y);
 	vec2 offset_vertex = VERTEX + vec2(size.x/2.0, size.y/2.0);
  float timescale = 1.0;
 	vec2 vertex_uv = vec2(offset_vertex.y*TEXTURE_PIXEL_SIZE.x, offset_vertex.y * TEXTURE_PIXEL_SIZE.y);
 	float dist_from_center = sqrt(pow(vertex_uv.x,2) + pow(vertex_uv.y,2));
 	float dist_from_floor = 1.0 - vertex_uv.y;
 	float displacement = sin(timescale*seeded_time - dist_from_center)*10.0;
 	vec2 displacement_dir = vertex_uv - impact;
    
 	VERTEX += wind_magnitude * dist_from_floor * displacement * displacement_dir;
}

