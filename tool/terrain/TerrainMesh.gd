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
onready var debounce_timer := $GridContainer/DebounceTimer

func _ready() -> void:
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


func _on_HSlider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		_update_texture_shader_uniforms()


func _on_HSlider_value_changed(_value: float) -> void:
	if debounce_timer.is_stopped():
		_update_texture_shader_uniforms()
		debounce_timer.start()
