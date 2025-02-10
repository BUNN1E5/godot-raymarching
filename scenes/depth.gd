@tool
extends ColorRect

@export var target_camera: Camera3D

func _ready():
	if not target_camera:
		print("Please assign a target camera.")
		return
	
	# Create and assign a ShaderMaterial that displays the depth texture.
	var shader_code := """
		shader_type canvas_item;
		render_mode unshaded;
		
		// The uniform is marked as a depth texture.
		uniform sampler2D depth_tex : hint_depth_texture;
		
		void fragment() {
			// Compute UVs based on screen coordinates.
			vec2 uv = FRAGCOORD.xy / VIEWPORT_SIZE;
			// Sample the depth texture.
			float d = texture(depth_tex, uv).r;
			// Output depth as grayscale.
			COLOR = vec4(vec3(d), 1.0);
		}
	"""
	var shader := Shader.new()
	shader.code = shader_code
	var mat := ShaderMaterial.new()
	mat.shader = shader
	material = mat
	
	# Ensure this node covers the entire viewport.
	rect_min_size = get_viewport_rect().size

func _process(delta):
	# In tool mode, update the shader parameter every frame.
	if target_camera:
		var vp = target_camera.get_viewport()
		if vp:
			# Assign the camera's viewport texture to the depth_tex uniform.
			material.set_shader_param("depth_tex", vp.get_texture())
