extends Control

onready var init_tool := $TerrainInitTool
onready var flood_tool := $TerrainFloodTool


func _on_TerrainInitTool_heightmap_saved(path: String) -> void:
	init_tool.hide()
	flood_tool.show()
	flood_tool.begin_flood(path)
