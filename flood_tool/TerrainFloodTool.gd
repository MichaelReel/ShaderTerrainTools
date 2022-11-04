extends Control


onready var open_heightmap := $OpenHeightMapDialog
onready var terrain_texure := $TerrainViewportContainer/Viewport/TextureRect


func _ready() -> void:
	# If we're not the root scene, let the caller hit begin_flood directly
	# If we are the root scene, then pick a height map to load
	var root_node := get_tree().root
	if get_parent() == root_node: 
		_open_dialog()

func _open_dialog() -> void:
	open_heightmap.show()
	open_heightmap.invalidate()

func begin_flood(path: String) -> void:
	var img := Image.new()
	var err := img.load(path)
	if err != OK:
		_open_dialog()
		return
	img.flip_y()
	var texture := ImageTexture.new()
	texture.create_from_image(img)
	terrain_texure.texture = texture
	
	

func _on_OpenHeightMapDialog_file_selected(path: String) -> void:
	begin_flood(path)
