const int sizeof_sdf_object = 28;

struct SDFObject {
    int object_type;    	// 1 floats 	0
	float[7] params;	// 7 floats 	1-8 (not yet)
	mat4 transform;     	// 16 floats	1-17
    int[4] operation;   	// 4 floats  	18-21
    vec4 color;         	// 4 floats 	22-25
    int main_texture_id;	// 1 floats 	26
    int normal_texture_id;	// 1 floats 	27
};

struct Ray{
	float dist;
	int iterations;
	SDFObject hit;
	bool exit_early;
};

const int sizeof_light_object = 9;
struct LightObject {
	int light_type;
	mat4 transform;
};

//on the bottom cause order matters
const int MAX_OBJECT_COUNT = 16;
const int ITERATIONS = 256;
const float MAX_DIST = 200.;
const float EPSILON = .005;
uniform float[MAX_OBJECT_COUNT * sizeof_sdf_object] _objectBuffer;