#include "res://shaders/raymarcher/SDFShapes.gdshaderinc"
#include "res://shaders/raymarcher/SDFOperations.gdshaderinc"
#include "res://shaders/raymarcher/SDFLights.gdshaderinc"
#include "res://shaders/raymarcher/RaymarchSceneData.gdshaderinc"
#include "res://shaders/raymarcher/SceneDataHelper.gdshaderinc"


Ray map(in vec3 p){
	Ray r;
	r.dist = MAX_DIST;

	SDFObject obj;
	obj.object_type = SHAPE_BOX;
	float t = TIME/1.;
	obj.transform = mat4(
		vec4(sin(t),0,cos(t),0),
		vec4(0,1,0,0),
		vec4(-cos(t),0,sin(t),0),
		vec4(0.,0.,0.,1)
	);
		//obj.transform = mat4(
		//vec4(1.,0.,0.,0.),
		//vec4(0.,1.,0.,0.),
		//vec4(0.,0.,1.,0.),
		//vec4(0.,0.,0.,1.)
	//);
	obj.params[0] = 0.5;
	obj.params[1] = 0.5;
	obj.params[2] = 0.5;

	obj.params[3] = .5;
	obj.params[4] = .5;
	obj.params[5] = .5;

	//for(int i = 0; i < MAX_OBJECT_COUNT; i++){
		////r.dist = opSmoothUnion(
			////sdSphere(p + vec3(-1.5, 10. * float(i)/float(MAX_OBJECT_COUNT) * sin(TIME + float(i)),
			////10. * float(i)/float(MAX_OBJECT_COUNT) * cos(TIME + float(i))), .5), r.dist, .1);
		//r.dist = opSmoothUnion(
			//sdSphere(p + vec3(-1.5, 10. * float(i)/float(MAX_OBJECT_COUNT) * sin(TIME + float(i)),
			//10. * float(i)/float(MAX_OBJECT_COUNT) * cos(TIME + float(i))), .5), r.dist, 6. * abs(sin(TIME/2.)));
		////r.dist = opUnion(
			////sdSphere(p + vec3(-1.5, 10. * float(i)/float(MAX_OBJECT_COUNT) * sin(TIME + float(i)),
			////10. * float(i)/float(MAX_OBJECT_COUNT) * cos(TIME + float(i))), .5), r.dist);
	//}
	r.dist = opUnion(r.dist, sdBox(p + vec3(0., -5.,1.), vec3(.5,.5,.5)));
	//r.dist = opUnion(opOnion(sdTorus(p + vec3(0.,-5.,0.), vec2(5., 5.)), .2),r.dist);
	//r.dist = opSubtraction(sdPlane(p, vec3(-.5, -1., 0), 5.), r.dist);
	r.dist = opUnion(r.dist, sdSphere(p + vec3(-5., -5.,sin(20.*TIME)), 1.));

	r.dist = opSmoothUnion(r.dist, sdSphere(p  + vec3(0., -5.,0.), .5), .25);
	r.dist = opUnion(opDisplace(sdSphere(p + vec3(-10.,-5.,0.), 2.),
								(sin(sin(TIME/10.)*p.x)*(sin(cos(TIME/4.)*p.y))*sin(1.*p.z))),
	 r.dist);

	//p - s*round(p/s)
	r.dist = opUnion(r.dist,
				opDisplace(
					ObjectTypeToSDF(
						opTransform(
							opRepetition(p, vec3(2.,0.,2.)),
							obj.transform
						),
						obj
					),
					(sin(sin(TIME/10.)*p.x)*(sin(cos(TIME/4.)*p.y))*sin(1.*p.z))
				)
			);

	r.dist = opUnion(sdPlane(p, vec3(0., 1., 0), 20.), r.dist);
	return r;
}

//P is the sample point of the ray
float map(in vec3 p, in SDFObject[MAX_OBJECT_COUNT] obj_buffer){
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

//vec2 calcUV(in vec3 pos, in vec3 normal, in mat4 transform){
	//vec3 n = normalize(normal);
	//// Generate UVs for each principal axis.
	//vec2 uv_x = vec2(pos.y, pos.z);
	//vec2 uv_y = vec2(pos.x, pos.z);
	//vec2 uv_z = vec2(pos.x, pos.y);
//
	//// Blend the UVs based on the absolute normal values.
	//return (abs(n.x) * uv_x + abs(n.y) * uv_y + abs(n.z) * uv_z) /
	          //(abs(n.x) + abs(n.y) + abs(n.z));
//}

// https://iquilezles.org/articles/normalsSDF
vec3 calcNormal( in vec3 pos){
    vec2 e = vec2(1.0,-1.0)*0.5773;
    const float eps = 0.0005;
    return normalize( e.xyy*map( pos + e.xyy*eps ).dist +
					  e.yyx*map( pos + e.yyx*eps ).dist +
					  e.yxy*map( pos + e.yxy*eps ).dist +
					  e.xxx*map( pos + e.xxx*eps ).dist );
}

vec2 calcUV(in vec3 pos, in mat4 object_transform){
	// Transform hit position from world space to object (local) space.
	vec3 localPos = (inverse(object_transform) * vec4(pos, 1.0)).xyz;

	// Now use localPos for UV mapping.
	// For triplanar mapping in local space:
	vec3 n_local = normalize(calcNormal(localPos));
	vec2 uv_x = vec2(localPos.y, localPos.z);
	vec2 uv_y = vec2(localPos.x, localPos.z);
	vec2 uv_z = vec2(localPos.x, localPos.y);
	return (abs(n_local.x) * uv_x + abs(n_local.y) * uv_y + abs(n_local.z) * uv_z) /
	          (abs(n_local.x) + abs(n_local.y) + abs(n_local.z));
}
//segment tracing

//This tutorial a huge help here!
//https://www.youtube.com/watch?v=khblXafu7iA
Ray raymarch(vec3 ro, vec3 rd){
	Ray r;
	r.dist = 0.;
	r.iterations = 0;
	r.exit_early = false;

	//SDFObject obj_buff[MAX_OBJECT_COUNT];

    for( int i=0; i < ITERATIONS; i++ ){
		r.iterations = i;
        vec3 pos = ro + rd * r.dist; //position along ray
        float d = map(pos).dist; //current dist to scene
		r.dist += d;
		if(d < EPSILON * r.dist) break; //early stop
		if(r.dist > MAX_DIST) {
			r.exit_early = true;
			return r;
		}
    }
	return r;
}