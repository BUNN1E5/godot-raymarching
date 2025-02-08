@tool
extends Node3D
class_name SDFObject

@export var is_rending : bool = false;
@export var id : int = -1;

@export var object_type : SDFObjectType = SDFObjectType.sphere;
@export var color : Color;

var aabb : AABB
var vis_notifier_rid : RID

var gizmo_plugin : EditorNode3DGizmoPlugin;

enum SDFObjectType{
	sphere = 1,
	box = 2,
	boxFrame = 3,
	torus = 4,
	cappedTorus = 5,
	cone = 6,
	cylinder = 7,
	plane = 8,
	capsule = 9,
	objectTypeRange = 9 #set it to the max VALUE so that we never set it to something invalid
}

func _ready():
	color = Color.from_hsv(randf(), 1, 1, 1)
	vis_notifier_rid = RenderingServer.visibility_notifier_create()
	RenderingServer.visibility_notifier_set_callbacks(	vis_notifier_rid,
														_on_screen_entered(),
														_on_screen_exited())
	return

func _process(_delta):
	return;

func to_float_array():
	#we should return a PackFloat32Array with a size of 27 floats (right now)
	var float_array : PackedFloat32Array;
	
	#Pixel 0 is objectType
	float_array.append(object_type);
	
	#4x4 = 16 floats 1-17 is the transform
	for i in range(3):
		for j in range(3):
			float_array.append(self.global_transform.basis[i][j]); #[i][j0,j1,j2,0]
		float_array.append(0);
	for i in range(3):
		float_array.append(self.global_transform.origin[i]);
	float_array.append(1); #Alpha Value, this needs to be 1 cause Identity
	#Done with transform
	
	#floats 18-21 are operations
	for i in range(4):
		float_array.append(0);
		
	#floats 22-25 are colors
	float_array.append_array([color.r, color.g, color.b, color.a]);
	
	#TODO :: Replace with getting the proper tex_ids
	float_array.append(0); #main_texture_id		float 26
	float_array.append(0); #normal_texture_id	float 27
	
	return float_array;


func _on_screen_entered():
	is_rending = true;
	id = SDFBuffer.add_obj(self);
	#print(SDFObjectType.keys()[object_type] + " entered changing ID from -1 to " + str(id))
	#tmp
	
	return;

func _on_screen_exited():
	is_rending = false;
	SDFBuffer.remove_obj(id);
	#print(SDFObjectType.keys()[object_type] + " left changing ID from " + str(id) + " to -1")
	id = -1;
	return;
