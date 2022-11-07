extends Control

onready var init_tool := $TerrainInitTool
onready var flood_tool := $TerrainFloodTool
onready var surface_tool := $TerrainSurfaceTool


func _on_TerrainInitTool_heightmap_saved(path: String) -> void:
	init_tool.hide()
	flood_tool.show()
	flood_tool.begin_flood(path)

func _on_TerrainFloodTool_slices_saved(slices_path):
	flood_tool.hide()
	surface_tool.show()
	surface_tool.begin_surfacing(init_tool.heightmap_texture, flood_tool.terrain_workspace)

