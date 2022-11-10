extends Control


onready var analysis_viewport := $AnalysisViewportContainer/Viewport
onready var analysis_texture := $AnalysisViewportContainer/Viewport/TextureRect
onready var open_heightmap := $TerrainFilesDialog

var heightmap_texture : ImageTexture
var terrain_workspace : TextureArray

func _ready() -> void:
	# If we're not the root scene, let the caller hit begin_flood directly
	# If we are the root scene, for dev/debug, pick a height map to load
	var root_node := get_tree().root
	if get_parent() == root_node: 
		_open_dialog()

func _open_dialog() -> void:
	open_heightmap.show()
	open_heightmap.invalidate()

func _open_files_for_surfacing(heightmap_path: String) -> void:
	# Check the selected heightmap file exists
	# and load the heightmap
	var height_img := Image.new()
	var err := height_img.load(heightmap_path)
	if err != OK:
		printerr("height map is not a valid image: %s" % heightmap_path)
		_open_dialog()
		return
	height_img.flip_y()
	heightmap_texture = ImageTexture.new()
	heightmap_texture.create_from_image(height_img)
	
	# Check there is at least 0000.png in the slice folder
	# And grab the max file name to determine the layer count
	var workspace_path = heightmap_path.replace(".png", "")
	var directory = Directory.new();
	var layers := 0
	while directory.file_exists("%s/%04d.png" % [workspace_path, layers]):
		layers += 1
	if layers == 0:
		printerr("height map is not accompanied by a valid slices directory: %s" % workspace_path)
		_open_dialog()
		return
	
	# Load the slices into the terrain workspace
	var new_terrain_workspace := TextureArray.new()
	new_terrain_workspace.create(heightmap_texture.size.x, heightmap_texture.size.y, layers, Image.FORMAT_RGBA8)
	# Check each the textures are the same size as the heightmap
	for i in range(layers):
		var slice_file = "%s/%04d.png" % [workspace_path, i]
		var slice_img := Image.new()
		err = slice_img.load(slice_file)
		if err != OK:
			printerr("error loading the slice image: %s" % slice_file)
			_open_dialog()
			return
		slice_img.flip_y()
		var slice_texture := ImageTexture.new()
		slice_texture.create_from_image(slice_img)
		new_terrain_workspace.set_layer_data(slice_img, i)
	
	terrain_workspace = new_terrain_workspace

### ANALYSIS ###

func _setup_analysis() -> void:
	analysis_texture.texture = heightmap_texture
	analysis_texture.material.set_shader_param("layers", terrain_workspace)
	analysis_texture.material.set_shader_param("layer_count", terrain_workspace.get_depth())


func _on_TerrainFilesDialog_file_selected(path: String) -> void:
	_open_files_for_surfacing(path)
	_setup_analysis()

