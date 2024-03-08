extends Node

var _cur_httprequest: HTTPRequest = null

var _world_width = 64
var _world_length = 64
var _world_height = 64
var _world_blocks = {}

var _world_material = PlaceholderMaterial.new()


func get_world_block(block_pos: Vector3i) -> int:
	if block_pos.x < 0 or block_pos.x >= _world_width \
	or block_pos.y < 0 or block_pos.y >= _world_height \
	or block_pos.z < 0 or block_pos.z >= _world_length:
		return -1
	return _world_blocks.get(block_pos.x + _world_width * (block_pos.z * _world_length + block_pos.y), 0)


func set_world_block(block_pos: Vector3i, block_id: int) -> void:
	if block_pos.x < 0 or block_pos.x >= _world_width \
	or block_pos.y < 0 or block_pos.y >= _world_height \
	or block_pos.z < 0 or block_pos.z >= _world_length:
		push_error("Tried to put a block outside of the world's bounds.")
		return
	_world_blocks[block_pos.x + _world_width * (block_pos.z * _world_length + block_pos.y)] = block_id


func _ready() -> void:
	var _thread1 = Thread.new()
	_thread1.start(_create_world_material)

	var _thread2 = Thread.new()
	_thread2.start(_generate_world_mesh)


func _create_world_material() -> void:
	# Use default texture pack
	_load_texpack("res://classicube.zip")

	# GET custom texture pack
	#var http_request = HTTPRequest.new()
	#add_child.call_deferred(http_request)
	#_cur_httprequest = http_request
	#http_request.request_completed.connect(_handle_texpack_loaded)
	#http_request.tree_entered.connect(_create_texpack_request)


func _create_texpack_request() -> void:
	var error = _cur_httprequest.request("https://classicube.net/static/default.zip")
	if error != OK:
		push_error("An error occurred in the HTTP request.")
		return


func _handle_texpack_loaded(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	_cur_httprequest.queue_free()

	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Texturepack couldn't be downloaded. %d." % response_code)
		return
	
	var tempfile = FileAccess.open("user://tmp_texpack.zip", FileAccess.WRITE)
	if not tempfile:
		push_error("Error trying to create a temp file. %s" % error_string(FileAccess.get_open_error()))
		return
	tempfile.store_buffer(body)
	tempfile.flush()

	_load_texpack("user://tmp_texpack.zip")


func _load_texpack(path: String) -> void:
	var terrain_buffer = Utils.read_file_from_zip(path, "terrain.png")
	var terrain_image = Image.new()
	var result = terrain_image.load_png_from_buffer(terrain_buffer)
	if result != OK:
		push_error("Texturepack's terrain.png couldn't be loaded. %s" % error_string(result))
		return
	
	var terrain_texture = ImageTexture.create_from_image(terrain_image)
	var terrain_material = StandardMaterial3D.new()
	terrain_material.albedo_texture = terrain_texture
	terrain_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	_world_material = terrain_material

	print("Textures finished loading.")

	# Change the mesh material in case that thread finished before this one
	for child in get_children():
		if child is MeshInstance3D:
			child.material_override = _world_material

func _generate_world_mesh() -> void:
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for x in range(64):
		for y in range(32):
			for z in range(64):
				set_world_block(Vector3i(x, y, z), 1)

	for x in range(64):
		for y in range(32):
			for z in range(64):
				var _pos = Vector3i(x, y, z)
				_draw_block_mesh(surface_tool, _pos, get_world_block(_pos))

	surface_tool.generate_normals()
	surface_tool.generate_tangents()
	surface_tool.index()
	var mi = MeshInstance3D.new()
	mi.mesh = surface_tool.commit()
	mi.material_override = _world_material
	add_child.call_deferred(mi)

	print("World finished loading.")


func _draw_block_mesh(surface_tool: SurfaceTool, block_pos: Vector3i, block_id: int) -> void:
	if block_id == 0:
		return

	var verts = calculate_block_verts(block_pos)
	var uvs = calculate_block_uvs(block_id)
	var top_uvs = uvs
	var bottom_uvs = uvs

	if get_world_block(block_pos + Vector3i.LEFT) <= 0:
		_draw_block_face(surface_tool, [verts[2], verts[0], verts[3], verts[1]], uvs)
	if get_world_block(block_pos + Vector3i.RIGHT) <= 0:
		_draw_block_face(surface_tool, [verts[7], verts[5], verts[6], verts[4]], uvs)
	if get_world_block(block_pos + Vector3i.FORWARD) <= 0:
		_draw_block_face(surface_tool, [verts[6], verts[4], verts[2], verts[0]], uvs)
	if get_world_block(block_pos + Vector3i.BACK) <= 0:
		_draw_block_face(surface_tool, [verts[3], verts[1], verts[7], verts[5]], uvs)
	if get_world_block(block_pos + Vector3i.DOWN) <= 0:
		_draw_block_face(surface_tool, [verts[4], verts[5], verts[0], verts[1]], uvs)
	if get_world_block(block_pos + Vector3i.UP) <= 0:
		_draw_block_face(surface_tool, [verts[2], verts[3], verts[6], verts[7]], uvs)


func _draw_block_face(surface_tool: SurfaceTool, verts: Array[Vector3], uvs: Array[Vector2]):
	surface_tool.set_uv(uvs[1]); surface_tool.add_vertex(verts[1])
	surface_tool.set_uv(uvs[2]); surface_tool.add_vertex(verts[2])
	surface_tool.set_uv(uvs[3]); surface_tool.add_vertex(verts[3])

	surface_tool.set_uv(uvs[2]); surface_tool.add_vertex(verts[2])
	surface_tool.set_uv(uvs[1]); surface_tool.add_vertex(verts[1])
	surface_tool.set_uv(uvs[0]); surface_tool.add_vertex(verts[0])


func calculate_block_verts(block_pos: Vector3i) -> Array[Vector3]:
	return [
		Vector3(block_pos.x, block_pos.y, block_pos.z),
		Vector3(block_pos.x, block_pos.y, block_pos.z + 1),
		Vector3(block_pos.x, block_pos.y + 1, block_pos.z),
		Vector3(block_pos.x, block_pos.y + 1, block_pos.z + 1),
		Vector3(block_pos.x + 1, block_pos.y, block_pos.z),
		Vector3(block_pos.x + 1, block_pos.y, block_pos.z + 1),
		Vector3(block_pos.x + 1, block_pos.y + 1, block_pos.z),
		Vector3(block_pos.x + 1, block_pos.y + 1, block_pos.z + 1),
	]


func calculate_block_uvs(block_id: int) -> Array[Vector2]:
	var row = floori(block_id / 16.0)
	var col = block_id % 16

	return [
		# Godot 4 has a weird bug where there are seams at the edge
		# of the textures. Adding a margin of 0.01 "fixes" it.
		1.0 / 16.0 * Vector2(col + 0.01, row + 0.01),
		1.0 / 16.0 * Vector2(col + 0.01, row + 0.99),
		1.0 / 16.0 * Vector2(col + 0.99, row + 0.01),
		1.0 / 16.0 * Vector2(col + 0.99, row + 0.99),
	]
