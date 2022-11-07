extends Control

signal slices_saved(slices_path)

const layers : int = 256
const slice_depth : float = 1.0 / float(layers)

var workspace_path: String
var terrain_workspace : TextureArray
var slice_layer : int = 0
var flood_layer : int = 0
var save_layer : int = 0
var flood_repeat_hash : String = ""

onready var open_heightmap := $OpenHeightMapDialog

onready var slice_texture := $SlicingViewportContainer/Viewport/TextureRect
onready var slice_viewport := $SlicingViewportContainer/Viewport
onready var slice_timer := $SlicingViewportContainer/SliceTimer

onready var flood_texture := $FloodingViewportContainer/Viewport/TextureRect
onready var flood_viewport := $FloodingViewportContainer/Viewport
onready var flood_timer := $FloodingViewportContainer/FloodTimer

onready var save_bar := $SaveProgressBar
onready var save_timer := $SaveProgressBar/SaveTimer

func _ready() -> void:
	# If we're not the root scene, let the caller hit begin_flood directly
	# If we are the root scene, for dev/debug, pick a height map to load
	var root_node := get_tree().root
	if get_parent() == root_node: 
		_open_dialog()

func _open_dialog() -> void:
	open_heightmap.show()
	open_heightmap.invalidate()

func _setup_image_array() -> void:
	terrain_workspace = TextureArray.new()
	terrain_workspace.create(slice_viewport.size.x, slice_viewport.size.y, layers, Image.FORMAT_RGBA8)
	
func begin_flood(path: String) -> void:
	_setup_slicing(path)

### SLICING ###

func _setup_slicing(path: String) -> void:
	workspace_path = path.replace(".png", "")
	_setup_image_array()
	var img := Image.new()
	var err := img.load(path)
	if err != OK:
		_open_dialog()
		return
	img.flip_y()
	var texture := ImageTexture.new()
	texture.create_from_image(img)
	slice_texture.texture = texture
	slice_texture.material.set_shader_param("slice_height", slice_depth * float(slice_layer))
	slice_timer.start()

func _slice_step():
	slice_viewport.set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	yield(VisualServer, "frame_post_draw")
	var img : Image = slice_viewport.get_texture().get_data()
	terrain_workspace.set_layer_data(img, slice_layer)
	
	if slice_layer == 0:
		_setup_flooding()
	
	slice_layer += 1
	if slice_layer >= layers:
		slice_timer.stop()
		return
	
	slice_texture.material.set_shader_param("slice_height", slice_depth * float(slice_layer))

### FLOODING ###

func _hash_image(img : Image) -> String:
	var ctx = HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(img.get_data())
	var res = ctx.finish()
	return res.hex_encode()

func _setup_flooding() -> void:
	var texture := ImageTexture.new()
	texture.create_from_image(terrain_workspace.get_layer_data(flood_layer))
	flood_texture.texture = texture
	flood_texture.material.set_shader_param("last_layer", texture)
	flood_timer.start()

func _flood_step() -> void:
	# Skip this if we've caught up to available inputs
	if flood_layer >= slice_layer:
		return
	
	flood_viewport.set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	yield(VisualServer, "frame_post_draw")
	var img : Image = flood_viewport.get_texture().get_data()
	var hash_code := _hash_image(img)
	if hash_code == flood_repeat_hash:
		# store this result in the terrain workspace
		terrain_workspace.set_layer_data(img, flood_layer)
		var flood_last_layer := ImageTexture.new()
		flood_last_layer.create_from_image(img)
		flood_texture.material.set_shader_param("last_layer", flood_last_layer)

		if flood_layer == 0:
			_setup_saving()

		# If last layer, stop the timer and move to the next stage
		flood_layer += 1
		if flood_layer >= layers:
			flood_timer.stop()
			return

		# Setup the next layer by overwriting the img we just saved
		img = terrain_workspace.get_layer_data(flood_layer)

	# Setup the next iteration on this layer
	flood_repeat_hash = hash_code
	var texture = ImageTexture.new()
	texture.create_from_image(img)
	flood_texture.texture = texture

### SAVING ###

func _make_sure_directory_exists(dir_path: String) -> void:
	var directory = Directory.new()
	if not directory.dir_exists(dir_path):
		var parent_path = dir_path.get_base_dir()
		var new_file = dir_path.get_file()
		directory.open(parent_path)
		directory.make_dir(new_file)

func _setup_saving() -> void:
	_make_sure_directory_exists(workspace_path)
	save_bar.max_value = layers
	save_timer.start()

func _save_step() -> void:
	if save_layer >= flood_layer:
		return
	var image_filename = workspace_path + "/%04d.png" % save_layer
	var image := terrain_workspace.get_layer_data(save_layer)
	image.flip_y()
	var _err := image.save_png(image_filename)
	
	save_layer += 1
	if save_layer >= layers:
		save_timer.stop()
		emit_signal("slices_saved", workspace_path)
		return
	save_bar.value = save_layer


func _on_OpenHeightMapDialog_file_selected(path: String) -> void:
	_setup_slicing(path)

func _on_SliceTimer_timeout() -> void:
	_slice_step()

func _on_FloodTimer_timeout():
	_flood_step()

func _on_SaveTimer_timeout():
	_save_step()
