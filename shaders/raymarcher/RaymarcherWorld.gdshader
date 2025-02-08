//The base of this is shamelessly stolen from https://iquilezles.org/
//Wonderful website detailing a lot of shader programming stuff by Inigo Quilez
shader_type spatial;
render_mode unshaded;
render_mode depth_draw_never;
render_mode cull_disabled;
//shader_type canvas_item;

uniform sampler2D _mainTex;

#include "res://shaders/raymarcher/Raymarcher.gdshaderinc"

void fragment() {
	//Get the objects encoded in the texture

	//Raymarching stuff
    vec2 uv = (FRAGCOORD.xy * 2. - VIEWPORT_SIZE.xy) / VIEWPORT_SIZE.y;
	//ro = Ray Origin || rd = ray direction
	vec3 ro = CAMERA_POSITION_WORLD;
	vec3 rd = normalize((INV_VIEW_MATRIX * vec4(VERTEX, 1)).xyz - ro);
	vec2 t = raymarch(ro, rd);

	vec3 pos = ro + t.x*rd;

	vec3 nor = calcNormal(pos);
	vec4 local_uv = tex3D(pos, nor, _mainTex);
	vec3 col = local_uv.xyz;//vec3(t.x);


	float light = (1.-(t.x/100.))*0.02 + diffusedPoint(pos, vec3(0, 2, 1), nor);
	//col *= light;
	//END Raymarching stuff

	if(t.x < 0. && t.y < 0.)
		ALPHA = 0.;
	//write to depth texture
	//stolen from here : https://godotshaders.com/shader/raymarching-with-depth-writting/
	vec4 ndc = PROJECTION_MATRIX * VIEW_MATRIX * vec4(pos, 1.);
	DEPTH = (ndc.z / ndc.w) * .5f + .5f;
	ALBEDO = vec3((col* .2));
	//ALBEDO = vec3((nor* .2));
	//ALBEDO = texture(_mainTex, nor.xy).rgb;
}
