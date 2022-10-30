extends Control

const layers : int = 16 # 256
const slice_depth : float = 1.0 / float(layers)

var terrain_workspace : TextureArray
var terrain_layer : int = 0
var flood_repeat_hash : String = ""

onready var slice_viewport := $SliceViewport
onready var slice_texture := $SliceViewport/TextureRect
onready var slice_timer := $SliceTimer
onready var slice_display := $DisplaySlice

onready var flood_viewport := $FloodViewport
onready var flood_texture := $FloodViewport/TextureRect
onready var flood_timer := $FloodTimer
onready var flood_display := $DisplayFlood

onready var debug_texture := $Debug/Viewport/TextureRect
onready var debug_timer := $Debug/DebugTimer
onready var debug_display := $Debug/DisplayDebug


func _ready() -> void:
	_setup_slicing()

func _setup_slicing() -> void:
	terrain_workspace = TextureArray.new()
	terrain_workspace.create(slice_viewport.size.x, slice_viewport.size.y, 256, Image.FORMAT_RGBA8)
	slice_texture.material.set_shader_param("slice_height", slice_depth * float(terrain_layer))
	slice_timer.start()

func _on_SliceTimer_timeout()-> void:
	slice_viewport.set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	yield(VisualServer, "frame_post_draw")
	var img : Image = slice_viewport.get_texture().get_data()
	terrain_workspace.set_layer_data(img, terrain_layer)
	
	terrain_layer += 1
	if terrain_layer >= layers:
		slice_timer.stop()
#		_setup_debug()
		_setup_flooding()
		return
	
	slice_texture.material.set_shader_param("slice_height", slice_depth * float(terrain_layer))

func _hash_image(img : Image) -> String:
	var ctx = HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(img.get_data())
	var res = ctx.finish()
	return res.hex_encode()
	
func _setup_flooding() -> void:
	terrain_layer = 0
	var texture := ImageTexture.new()
	texture.create_from_image(terrain_workspace.get_layer_data(terrain_layer))
	flood_texture.texture = texture
	flood_timer.start()
	slice_display.visible = false
	flood_display.visible = true
	print("starting flood")

func _on_FloodTimer_timeout() -> void:
	flood_viewport.set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	yield(VisualServer, "frame_post_draw")
	var img : Image = flood_viewport.get_texture().get_data()
	var hash_code := _hash_image(img)
	if hash_code == flood_repeat_hash:
		# store this result in the terrain workspace
		terrain_workspace.set_layer_data(img, terrain_layer)
		
		# If last layer, stop the timer and move to the next stage
		terrain_layer += 1
		if terrain_layer >= layers:
			flood_timer.stop()
			_setup_debug()
			return
		
		# Setup the next layer by overwriting the img we just saved
		print("starting flood layer " + str(terrain_layer))
		img = terrain_workspace.get_layer_data(terrain_layer)
	
	# Setup the next iteration on this layer
	flood_repeat_hash = hash_code
	var texture = ImageTexture.new()
	texture.create_from_image(img)
	flood_texture.texture = texture
	
func _setup_debug() -> void:
	terrain_layer = 0
	debug_timer.start()
	slice_display.visible = false
	flood_display.visible = false
	debug_display.visible = true

func _on_DebugTimer_timeout() -> void:
	var img := terrain_workspace.get_layer_data(terrain_layer)
	var texture := ImageTexture.new()
	texture.create_from_image(img)
	debug_texture.texture = texture
	terrain_layer += 1
	if terrain_layer >= layers:
		debug_timer.stop()
		return
	
