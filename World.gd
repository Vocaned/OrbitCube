extends Node
class_name World

var world_size: Vector3i
var world_blocks: Array

var _cur_httprequest: HTTPRequest = null
var _default_mesh
var _camera_rig

var _world_material = PlaceholderMaterial.new()

var _blockdefs = {}

var _thread1
var _thread2

var _chat

func _new_block(id: int, sprite: bool, top: int, side: int, bottom: int, drawtype: int, fullbright: bool, min: Vector3i, max: Vector3i, name: String) -> void:
	_blockdefs[id] = {
		"sprite": sprite,
		"top": top,
		"side": side,
		"bottom": bottom,
		"drawtype": drawtype,
		"fullbright": fullbright,
		"min": min,
		"max": max,
		"name": name
	}


func _ready() -> void:
	_default_mesh = MeshInstance3D.new()
	_default_mesh.mesh = BoxMesh.new()

	# Create default blocks
	_new_block(0,  false,  0,  0,  0, 4, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Air')
	_new_block(1,  false,  1,  1,  1, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Stone')
	_new_block(2,  false,  0,  3,  2, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Grass')
	_new_block(3,  false,  2,  2,  2, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Dirt')
	_new_block(4,  false, 16, 16, 16, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Cobblestone')
	_new_block(5,  false,  4,  4,  4, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Wood')
	_new_block(6,   true, 15, 15, 15, 1, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Sapling')
	_new_block(7,  false, 17, 17, 17, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Bedrock')
	_new_block(8,  false, 14, 14, 14, 3, false, Vector3i(0, 0, 0), Vector3i(16, 15, 16), 'Water')
	_new_block(9,  false, 14, 14, 14, 3, false, Vector3i(0, 0, 0), Vector3i(16, 15, 16), 'Still Water')
	_new_block(10, false, 30, 30, 30, 0,  true, Vector3i(0, 0, 0), Vector3i(16, 15, 16), 'Lava')
	_new_block(11, false, 30, 30, 30, 0,  true, Vector3i(0, 0, 0), Vector3i(16, 15, 16), 'Still Lava')
	_new_block(12, false, 18, 18, 18, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Sand')
	_new_block(13, false, 19, 19, 19, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Gravel')
	_new_block(14, false, 32, 32, 32, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Gold Ore')
	_new_block(15, false, 33, 33, 33, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Iron Ore')
	_new_block(16, false, 34, 34, 34, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Coal Ore')
	_new_block(17, false, 21, 20, 21, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Log')
	_new_block(18, false, 22, 22, 22, 2, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Leaves')
	_new_block(19, false, 48, 48, 48, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Sponge')
	_new_block(20, false, 49, 49, 49, 1, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Glass')
	_new_block(21, false, 64, 64, 64, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Red')
	_new_block(22, false, 65, 65, 65, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Orange')
	_new_block(23, false, 66, 66, 66, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Yellow')
	_new_block(24, false, 67, 67, 67, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Lime')
	_new_block(25, false, 68, 68, 68, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Green')
	_new_block(26, false, 69, 69, 69, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Teal')
	_new_block(27, false, 70, 70, 70, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Aqua')
	_new_block(28, false, 71, 71, 71, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Cyan')
	_new_block(29, false, 72, 72, 72, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Blue')
	_new_block(30, false, 73, 73, 73, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Indigo')
	_new_block(31, false, 74, 74, 74, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Violet')
	_new_block(32, false, 75, 75, 75, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Magenta')
	_new_block(33, false, 76, 76, 76, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Pink')
	_new_block(34, false, 77, 77, 77, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Black')
	_new_block(35, false, 78, 78, 78, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Gray')
	_new_block(36, false, 79, 79, 79, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'White')
	_new_block(37,  true, 13, 13, 13, 1, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Dandelion')
	_new_block(38,  true, 12, 12, 12, 1, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Rose')
	_new_block(39,  true, 29, 29, 29, 1, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Brown Mushroom')
	_new_block(40,  true, 28, 28, 28, 1, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Red Mushroom')
	_new_block(41, false, 24, 40, 56, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Gold')
	_new_block(42, false, 23, 39, 55, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Iron')
	_new_block(43, false,  6,  5,  6, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Double Slab')
	_new_block(44, false,  6,  5,  6, 0, false, Vector3i(0, 0, 0), Vector3i(16,  8, 16), 'Slab')
	_new_block(45, false,  7,  7,  7, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Brick')
	_new_block(46, false,  9,  8, 10, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'TNT')
	_new_block(47, false,  4, 35,  4, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Bookshelf')
	_new_block(48, false, 36, 36, 36, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Mossy Rocks')
	_new_block(49, false, 37, 37, 37, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Obsidian')
	_new_block(50, false, 16, 16, 16, 0, false, Vector3i(0, 0, 0), Vector3i(16,  8, 16), 'Cobblestone Slab')
	_new_block(51,  true, 11, 11, 11, 1, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Rope')
	_new_block(52, false, 25, 41, 57, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Sandstone')
	_new_block(53, false, 50, 50, 50, 0, false, Vector3i(0, 0, 0), Vector3i(16,  2, 16), 'Snow')
	_new_block(54,  true, 38, 38, 38, 1, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Fire')
	_new_block(55, false, 80, 80, 80, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Light Pink')
	_new_block(56, false, 81, 81, 81, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Forest Green')
	_new_block(57, false, 82, 82, 82, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Brown')
	_new_block(58, false, 83, 83, 83, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Deep Blue')
	_new_block(59, false, 84, 84, 84, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Turquoise')
	_new_block(60, false, 51, 51, 51, 3, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Ice')
	_new_block(61, false, 54, 54, 54, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Ceramic Tile')
	_new_block(62, false, 86, 86, 86, 0,  true, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Magma')
	_new_block(63, false, 26, 42, 58, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Pillar')
	_new_block(64, false, 53, 53, 53, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Crate')
	_new_block(65, false, 52, 52, 52, 0, false, Vector3i(0, 0, 0), Vector3i(16, 16, 16), 'Stone Brick')


func initialize(chat: Node) -> void:
	_chat = chat

	assert(world_size and world_blocks,"Could not initialize, world data missing.")
	assert(world_blocks.size() == (world_size.x * world_size.y * world_size.z), "Could not initialize, world data doesn't match world's size.")

	_chat.add_message.call_deferred("initializing world")

	_thread1 = Thread.new()
	_thread1.start(_create_world_material)

	_thread2 = Thread.new()
	_thread2.start(_generate_world_mesh)


func get_world_block(block_pos: Vector3i) -> int:
	if block_pos.x < 0 or block_pos.x >= world_size.x \
	or block_pos.y < 0 or block_pos.y >= world_size.y \
	or block_pos.z < 0 or block_pos.z >= world_size.z:
		return -1
	var index = block_pos.x + world_size.x * (block_pos.z + block_pos.y * world_size.z)
	return world_blocks[index]


func set_world_block(block_pos: Vector3i, block_id: int) -> void:
	if block_pos.x < 0 or block_pos.x >= world_size.x \
	or block_pos.y < 0 or block_pos.y >= world_size.y \
	or block_pos.z < 0 or block_pos.z >= world_size.z:
		push_error("Tried to put a block outside of the world's bounds.")
		return
	world_blocks[block_pos.x + world_size.x * (block_pos.z + block_pos.y * world_size.z)] = block_id


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

	_chat.add_message.call_deferred("Textures finished loading.")

	# Change the mesh material in case that thread finished before this one
	_update_mesh_material.call_deferred()


func _update_mesh_material() -> void:
	for child in get_children():
		if child is MeshInstance3D and child != _default_mesh:
			child.material_override = _world_material


func _generate_world_mesh() -> void:
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for x in range(world_size.x):
		for y in range(world_size.y):
			for z in range(world_size.z):
				var _pos = Vector3i(x, y, z)
				_draw_block_mesh(surface_tool, _pos, get_world_block(_pos))

	surface_tool.generate_normals()
	surface_tool.generate_tangents()
	surface_tool.index()
	var mi = MeshInstance3D.new()
	mi.mesh = surface_tool.commit()
	mi.material_override = _world_material
	add_child.call_deferred(mi)

	if _default_mesh:
		_default_mesh.queue_free()

	_camera_rig.set_camera_target.call_deferred(mi, 100)

	_chat.add_message.call_deferred("World finished loading.")


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
	var texture = _blockdefs[block_id]["side"]

	var row = floori(texture / 16.0)
	var col = texture % 16

	return [
		# Godot 4 has a weird bug where there are seams at the edge
		# of the textures. Adding a margin of 0.01 "fixes" it.
		1.0 / 16.0 * Vector2(col + 0.01, row + 0.01),
		1.0 / 16.0 * Vector2(col + 0.01, row + 0.99),
		1.0 / 16.0 * Vector2(col + 0.99, row + 0.01),
		1.0 / 16.0 * Vector2(col + 0.99, row + 0.99),
	]
