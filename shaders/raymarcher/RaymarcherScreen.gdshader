shader_type canvas_item;


#include "res://shaders/raymarcher/Raymarcher.gdshaderinc"

//uniform mat4 camera_position;

void fragment() {
		//Get the objects encoded in the texture

	//Raymarching stuff

    vec2 uv = UV * 2.0 - 1.0;
	//ro = Ray Origin || rd = ray direction
	vec3 camera_position = vec3(0,0,-5.);
	vec3 ro = camera_position;
	vec3 rd = vec3(uv.xy, 1);
	vec2 t = raymarch(ro, rd);



	vec3 pos = ro + t.x*rd;

	vec3 nor = calcNormal(pos);

	vec3 col = nor;//vec3(t.x);

	float light = (1.-(t.x/100.))*0.02 + diffusedPoint(pos, vec3(0, 2, 1), nor);
	col *= light;
	//END Raymarching stuff
	float a = 1.;
	if(t.x < 0. && t.y < 0.)
		a = 0.;

	COLOR = vec4((col* .2).xyz, a);
}
