#include "res://shaders/raymarcher/RaymarchSceneData.gdshaderinc"
#include "res://shaders/raymarcher/SDFShapes.gdshaderinc"
#include "res://shaders/raymarcher/SDFOperations.gdshaderinc"

float sdf_object_type(vec3 p, sdf_object obj){
	switch (obj.object_type){
		case sphere:
			return sdSphere(p, 1.);
	}
	return 0.;
}

sdf_object[MAX_OBJECT_COUNT] float_array_to_sdf_object_array(float[MAX_OBJECT_COUNT * sizeof_sdf_object] buff){
	sdf_object objs[MAX_OBJECT_COUNT];
	for(int i = 0; i < MAX_OBJECT_COUNT; i++){
		sdf_object obj;

		//all references to obj_index must use obj_index++
		//so we keep proper could of our curr index in the object
		int obj_index = 0;

	    int remap = i * sizeof_sdf_object;
	    obj.object_type = int(buff[remap+obj_index++]);  // Convert back to int
		if(obj.object_type == 0)
			continue; //exit early if we arent a valid object

		// Read transform matrix
	    for (int i = 0; i < 16; i++) {
	        obj.transform[i/4][i%4] = buff[remap+obj_index++];
	    }

		// Read operations (1 pixel)
	    obj.operation[0] = int(buff[remap+obj_index++]);
	    obj.operation[1] = int(buff[remap+obj_index++]);
	    obj.operation[2] = int(buff[remap+obj_index++]);
	    obj.operation[3] = int(buff[remap+obj_index++]);

		// Read texture IDs (1 pixel)
	    obj.main_texture_id = int(buff[remap+obj_index++]);
	    obj.normal_texture_id = int(buff[remap+obj_index++]);

		objs[i] = obj;
	}
	return objs;
}