extends Control

signal heightmap_saved(path)

onready var texture_viewport := $TextureViewportContainer/Viewport
onready var texture_rect := $TextureViewportContainer/Viewport/TextureRect
onready var plane_mesh := $TerrainViewportContainer/Viewport/TerrainMesh
onready var sea_mesh := $TerrainViewportContainer/Viewport/SeaMesh

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
onready var slider_terrain_scale := $GridContainer/HSlider_TerrainScale
onready var slider_sealevel := $GridContainer/HSlider_Sealevel

onready var display_warping_1 := $GridContainer/Label_Warping_1_Value
onready var display_warping_2 := $GridContainer/Label_Warping_2_Value
onready var display_xshape := $GridContainer/Label_XShape_Value
onready var display_depth := $GridContainer/Label_Depth_Value
onready var display_min_range := $GridContainer/Label_Min_Range_Value
onready var display_max_range := $GridContainer/Label_Max_Range_Value
onready var display_root_offset_x := $GridContainer/Label_RootOffset_X_Value
onready var display_root_offset_y := $GridContainer/Label_RootOffset_Y_Value
onready var display_warp_offset_1_x := $GridContainer/Label_WarpOffset_X_1_Value
onready var display_warp_offset_1_y := $GridContainer/Label_WarpOffset_Y_1_Value
onready var display_warp_offset_2_x := $GridContainer/Label_WarpOffset_X_2_Value
onready var display_warp_offset_2_y := $GridContainer/Label_WarpOffset_Y_2_Value
onready var display_terrain_scale := $GridContainer/Label_TerrainScale_Value
onready var display_sealevel := $GridContainer/Label_Sealevel_Value

onready var debounce_timer := $GridContainer/DebounceTimer
onready var rotation_player := $TerrainViewportContainer/Viewport/AnimationPlayer
onready var file_dialog := $FileDialog

var rotation_speed = -0.1;

func _ready() -> void:
	rotation_player.play("rotate", -1, rotation_speed)
	_update_value_displays()
	_update_texture_shader_uniforms()
	_update_terrain_init_shader_uniforms()


func _update_terrain_init_shader_uniforms() -> void:
	texture_viewport.set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")

	var texture : Texture = texture_viewport.get_texture()
	plane_mesh.material_override.set_shader_param("height_map", texture)
	plane_mesh.material_override.set_shader_param("surface_map", texture)
	_update_terrain_shader_uniforms()
	_update_sea_height()

func _update_terrain_shader_uniforms() -> void:
	plane_mesh.material_override.set_shader_param("height_scale", slider_terrain_scale.value)

func _update_sea_height() -> void:
	sea_mesh.translation.y = slider_sealevel.value

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

func _update_value_displays() -> void:
	display_warping_1.text       = "%5.2f" % slider_warping_1.value
	display_warping_2.text       = "%5.2f" % slider_warping_2.value
	display_xshape.text          = "%5.2f" % slider_xshape.value
	display_depth.text           = "%5.2f" % slider_depth.value
	display_min_range.text       = "%5.2f" % slider_min_range.value
	display_max_range.text       = "%5.2f" % slider_max_range.value
	display_root_offset_x.text   = "%5.2f" % slider_root_offset_x.value
	display_root_offset_y.text   = "%5.2f" % slider_root_offset_y.value
	display_warp_offset_1_x.text = "%5.2f" % slider_warp_offset_1_x.value
	display_warp_offset_1_y.text = "%5.2f" % slider_warp_offset_1_y.value
	display_warp_offset_2_x.text = "%5.2f" % slider_warp_offset_2_x.value
	display_warp_offset_2_y.text = "%5.2f" % slider_warp_offset_2_y.value
	display_terrain_scale.text   = "%5.2f" % slider_terrain_scale.value
	display_sealevel.text        = "%5.2f" % slider_sealevel.value

func _get_time_based_filename() -> String:
	var filename = "terrain_"
	filename += Time.get_date_string_from_system().replace("-", "")
	filename += Time.get_time_string_from_system().replace(":", "")
	filename += ".png"
	return filename


func _on_HSlider_value_changed(_value: float) -> void:
	if debounce_timer.is_stopped():
		_update_value_displays()
		_update_texture_shader_uniforms()
		debounce_timer.start()

func _on_HSlider_terrain_value_changed(_value: float) -> void:
	if debounce_timer.is_stopped():
		_update_value_displays()
		_update_terrain_shader_uniforms()
		debounce_timer.start()

func _on_HSlider_sea_changed(_value: float) -> void:
	_update_value_displays()
	_update_sea_height()

func _on_Button_pressed() -> void:
	file_dialog.current_file = _get_time_based_filename() 
	file_dialog.show()

func _on_FileDialog_file_selected(path):
	texture_viewport.set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	yield(VisualServer, "frame_post_draw")
	var img = texture_viewport.get_texture().get_data()
	img.flip_y()
	img.save_png(path)
	emit_signal("heightmap_saved", path)
	
	
	
