//The base of this is shamelessly stolen from https://iquilezles.org/
//Wonderful website detailing a lot of shader programming stuff by Inigo Quilez
shader_type spatial;
render_mode cull_disabled;
render_mode unshaded;

uniform sampler2D _mainTex;
uniform sampler2D _skybox;
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;
#include "res://shaders/raymarcher/Raymarcher.gdshaderinc"

void fragment() {
	//get linear depth
	//So we dont actually do this cause for some reason
	//When we read the depth texture it stops writing to the normal buffer??
	//float depth_raw = texture(depth_texture, SCREEN_UV, 0.0).r;
    //vec4 upos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, depth_raw,1.0);
    //vec3 pixel_position = upos.xyz/upos.w;
    //float linear_depth = length(pixel_position);

	//Raymarching stuff
    vec2 uv = (FRAGCOORD.xy * 2. - VIEWPORT_SIZE.xy) / VIEWPORT_SIZE.y;
	//ro = Ray Origin || rd = ray direction
	vec3 ro = CAMERA_POSITION_WORLD;
	vec3 rd = normalize((INV_VIEW_MATRIX * vec4(VERTEX, 1)).xyz - ro);
	Ray r = raymarch(ro, rd);

	vec3 pos = ro + r.dist * rd;

	vec3 nor = normalize(calcNormal(pos));
	//vec2 local_uv = calcUV(pos, r.hit.transform);
	//vec3 col = vec3(local_uv.xy, 1.);//vec3(t.x);
	vec3 col = vec3((1.-r.dist/MAX_DIST) * float(r.iterations)/float(ITERATIONS));
	//vec3 col = nor;


	float light = (1.-(r.dist/100.))*0.02 + diffusedPoint(pos, vec3(0, 2, 1), nor);
	//col *= light;
	//END Raymarching stuff

	//write to depth texture
	//stolen from here : https://godotshaders.com/shader/raymarching-with-depth-writting/


	// Depth calculation, this makes possible for other meshes intersect
	// properly with the geometry
	vec4 ndc = PROJECTION_MATRIX * VIEW_MATRIX * vec4(pos, 1.);
	float depth = (ndc.z / ndc.w);
	//ALPHA = 1. - float(r.exit_early);
	NORMAL = nor;
	ALBEDO = vec3(1.) * col;
	DEPTH = depth;
}
