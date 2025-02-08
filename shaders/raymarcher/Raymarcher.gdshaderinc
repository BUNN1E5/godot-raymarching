#include "res://shaders/raymarcher/SDFShapes.gdshaderinc"
#include "res://shaders/raymarcher/SDFOperations.gdshaderinc"
#include "res://shaders/raymarcher/SDFLights.gdshaderinc"
#include "res://shaders/raymarcher/RaymarchSceneData.gdshaderinc"
#include "res://shaders/raymarcher/SceneDataHelper.gdshaderinc"


float map(in vec3 p){
	float f = 0.;

	mat4 m = mat4(
		vec4(sin(TIME),0,cos(TIME),0),
		vec4(0,1,0,0),
		vec4(-cos(TIME),0,sin(TIME),0),
		vec4(0,0,0,1)
	);

	//p = opTransform(p, m);
	f = opSmoothUnion(sdBoxFrame(p, vec3(1., 1., 1.), .05), f, .5);
	f = sdBox(p + vec3(0., sin(TIME), cos(TIME)), vec3(.5,0.5,0.5));
	f = min(sdSphere(p + vec3(1.5, 0., 0.), .5), f);
	f = min(sdSphere(p + vec3(-1.5, sin(TIME), cos(TIME)), .5), f);
	for(int i = 0; i < MAX_OBJECT_COUNT; i++){
		f = opSmoothUnion(
			sdSphere(p + vec3(-1.5, 10. * float(i)/float(MAX_OBJECT_COUNT) * sin(TIME + float(i)),
			10. * float(i)/float(MAX_OBJECT_COUNT) * cos(TIME + float(i))), .5), f, .1);
	}
	return f;
}

//P is the sample point of the ray
float map(in vec3 p, in sdf_object[MAX_OBJECT_COUNT] obj_buffer){
	float f = MAX_DIST;
	for(int i = 0; i < MAX_OBJECT_COUNT; i++){
		//since we sort before we send to the gpu
		//Once we hit out first invalid object
		//We can safely ignore anthing after it
		if(obj_buffer[i].object_type == 0) break;
		f = min(sdSphere(opTransform(p, obj_buffer[i].transform), 1), f);
	}
	return f;
}

//Found this here : https://www.shadertoy.com/view/4dj3Dw
vec4 tex3D( in vec3 pos, in vec3 normal, sampler2D sampler ){
	return 	texture( sampler, pos.yz - 0.5)*abs(normal.x)+
			texture( sampler, pos.xz - 0.5)*abs(normal.y)+
			texture( sampler, pos.xy - 0.5)*abs(normal.z);
}

//Found this here : https://www.shadertoy.com/view/4dj3Dw
//vec4 tex3D( in vec3 pos, in vec3 normal, sampler2D sampler ){
	//return 	texture( sampler, pos.yz)*abs(normal.x)+
			//texture( sampler, pos.xz)*abs(normal.y)+
			//texture( sampler, pos.xy)*abs(normal.z);
//}

// https://iquilezles.org/articles/normalsSDF
vec3 calcNormal( in vec3 pos)
{
    vec2 e = vec2(1.0,-1.0)*0.5773;
    const float eps = 0.0005;
    return normalize( e.xyy*map( pos + e.xyy*eps ) +
					  e.yyx*map( pos + e.yyx*eps ) +
					  e.yxy*map( pos + e.yxy*eps ) +
					  e.xxx*map( pos + e.xxx*eps ) );
}

//This tutorial a huge help here!
//https://www.youtube.com/watch?v=khblXafu7iA

vec2 raymarch(vec3 ro, vec3 rd){
    float t = 0.0;
	float ep = epsilon;
	int i0;

	sdf_object obj_buff[MAX_OBJECT_COUNT];


    for( int i=0; i < ITERATIONS; i++ ){
		i0=i;
        vec3 pos = ro + rd * t; //position along ray
        float d = map(pos); //current dist to scene
		t += d;
		ep = epsilon * t;
		if (d < ep) break; //early stop
		if(t > MAX_DIST) return vec2(-1,-1);
    }
	return vec2(t, float(i0));
}