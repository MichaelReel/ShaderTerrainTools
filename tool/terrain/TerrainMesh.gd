extends Control

onready var viewport := $TextureViewportContainer/Viewport
onready var plane_mesh := $TerrainViewportContainer/Viewport/TerrainMesh

func _ready():
	# Clear the viewport.
	viewport.set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)

	# Let two frames pass to make sure the viewport is captured.
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")

	# Retrieve the texture and set it to the viewport quad.
	var texture : Texture = viewport.get_texture()
	plane_mesh.material_override.set_shader_param("height_map", texture)
	plane_mesh.material_override.set_shader_param("surface_map", texture)
