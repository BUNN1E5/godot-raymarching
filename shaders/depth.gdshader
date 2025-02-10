shader_type spatial;
render_mode unshaded;
render_mode cull_disabled;

// Uniform for the depth texture.
uniform sampler2D depth_tex : hint_depth_texture;
uniform sampler2D normal_roughness_texture : hint_normal_roughness_texture, repeat_disable, filter_nearest;

void vertex() {
    // Remap from [0,1] to [-1,1]
    vec3 pos = VERTEX * 2.;
	pos.z = 1.0;
    // Set the clip space position.
    POSITION = vec4(pos.xyz, 1.0);
}

void fragment() {
    // Compute UVs from screen-space coordinates.
    float depth = texture(depth_tex, SCREEN_UV).r;
	vec4 normal = texture(normal_roughness_texture, SCREEN_UV);
    ALBEDO = vec3(depth);
}
