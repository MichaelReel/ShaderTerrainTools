extends Control

onready var texture_viewport := $TextureViewportContainer/Viewport
onready var texture_rect := $TextureViewportContainer/Viewport/TextureRect
onready var plane_mesh := $TerrainViewportContainer/Viewport/TerrainMesh

onready var slider_warping_1 := $GridContainer/HSlider_Warping_1
onready var slider_warping_2 := $GridContainer/HSlider_Warping_2
onready var slider_xshape := $GridContainer/HSlider_XShape
onready var slider_depth := $GridContainer/HSlider_Depth
onready var slider_min_range := $GridContainer/HSlider_Min_Range
onready var slider_max_range := $GridContainer/HSlider_Max_Range
onready var slider_root_offset_x := $GridContainer/HSlider_RootOffset_X
onready var slider_root_offset_y := $GridContainer/HSlider_RootOffset_Y
onready var slider_warp_offset_1_x := $GridContainer/HSlider_WarpOffset_X_1
onready var slider_warp_offset_1_y := $GridContainer/HSlider_WarpOffset_Y_1
onready var slider_warp_offset_2_x := $GridContainer/HSlider_WarpOffset_X_2
onready var slider_warp_offset_2_y := $GridContainer/HSlider_WarpOffset_Y_2
onready var debounce_timer := $GridContainer/DebounceTimer

onready var rotation_player := $TerrainViewportContainer/Viewport/AnimationPlayer

var rotation_speed = -0.1;

func _ready() -> void:
	rotation_player.play("rotate", -1, rotation_speed)
	_update_texture_shader_uniforms()
	_update_terrain_shader_uniforms()


func _update_terrain_shader_uniforms() -> void:
	texture_viewport.set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")

	var texture : Texture = texture_viewport.get_texture()
	plane_mesh.material_override.set_shader_param("height_map", texture)
	plane_mesh.material_override.set_shader_param("surface_map", texture)


func _update_texture_shader_uniforms() -> void:
	texture_rect.material.set_shader_param("warping_1", slider_warping_1.value)
	texture_rect.material.set_shader_param("warping_2", slider_warping_2.value)
	texture_rect.material.set_shader_param("x_shape", slider_xshape.value)
	texture_rect.material.set_shader_param("depth", slider_depth.value)
	texture_rect.material.set_shader_param("min_range", slider_min_range.value)
	texture_rect.material.set_shader_param("max_range", slider_max_range.value)
	var root_offset = Vector2(slider_root_offset_x.value, slider_root_offset_y.value)
	var warp_offset_1 = Vector2(slider_warp_offset_1_x.value, slider_warp_offset_1_y.value)
	var warp_offset_2 = Vector2(slider_warp_offset_2_x.value, slider_warp_offset_2_y.value)
	texture_rect.material.set_shader_param("root_offset", root_offset)
	texture_rect.material.set_shader_param("warp_offset_1", warp_offset_1)
	texture_rect.material.set_shader_param("warp_offset_2", warp_offset_2)

# uniform vec2 root_offset = vec2(0.0, 0.0);
# uniform vec2 warp_offset_1 = vec2(0.0, 0.3);
# uniform vec2 warp_offset_2 = vec2(5.2, 1.3);


func _on_HSlider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		_update_texture_shader_uniforms()


func _on_HSlider_value_changed(_value: float) -> void:
	if debounce_timer.is_stopped():
		_update_texture_shader_uniforms()
		debounce_timer.start()
