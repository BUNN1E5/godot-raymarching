extends MeshInstance3D
class_name SDFBuffer
const MAX_OBJ_COUNT : int = 16;
const MAX_OBJ_FLOAT_COUNT : int = 27;

static var singleton : SDFBuffer

@export var obj_buffer : Array[SDFObject];
@export var index_stack : Array[int];
#var light_buffer : Array[SDFObject];

var obj_texture : ImageTexture;
var obj_image : Image;

var material : Material;

func write_data_to_texture():
	obj_buffer.resize(MAX_OBJ_COUNT); #We have a max defined objects
	var float_array : PackedFloat32Array;
	float_array.resize(MAX_OBJ_COUNT * MAX_OBJ_FLOAT_COUNT);
	var obj_count = 0;
	for i in range(0, len(obj_buffer)):
		if(obj_buffer[i] == null):
			continue;
		if(obj_count > MAX_OBJ_COUNT): #HOW DID THIS HAPPEN!?
			break; #Not exiting here wont break it, but it does keep us from doing unneeded work
		var fa : PackedFloat32Array = obj_buffer[i].to_float_array();
		for j in range(MAX_OBJ_FLOAT_COUNT):
			float_array[obj_count * MAX_OBJ_FLOAT_COUNT + j] = fa[j]
		obj_count+=1;
	material.set("shader_parameter/_objectBuffer", float_array);
	return;

func _ready():
	for i in range(MAX_OBJ_COUNT-1, -1, -1):
		index_stack.push_back(i);
	singleton = self;
	material = self.get_active_material(0);
	return;

func _process(_delta):
	write_data_to_texture();
	return;
	
static func add_obj(obj : SDFObject):
	var index = singleton.index_stack.pop_back();
	singleton.obj_buffer[index] = obj;
	return index; #index of last item


static func remove_obj(index : int):
	singleton.obj_buffer[index] = null;
	singleton.index_stack.push_back(index);
	singleton.index_stack.sort_custom(func(a, b): return a > b);
	return
