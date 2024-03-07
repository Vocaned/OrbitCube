extends Node

const TEXTURE_SHEET_WIDTH = 16
const TEXTURE_TILE_SIZE = 1.0 / TEXTURE_SHEET_WIDTH

var _world_width = 64
var _world_length = 64
var _world_height = 64
var _world_blocks = {}


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
		printerr("Tried to put a block outside of the world's bounds.")
		return
	_world_blocks[block_pos.x + _world_width * (block_pos.z * _world_length + block_pos.y)] = block_id


func _ready() -> void:
	var _thread = Thread.new()
	_thread.start(_generate_chunk_mesh)


func _generate_chunk_mesh() -> void:
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
	mi.material_override = preload("res://placeholder_material.tres")
	add_child.call_deferred(mi)


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
	# This method only supports square texture sheets.
	var row = block_id / TEXTURE_SHEET_WIDTH
	var col = block_id % TEXTURE_SHEET_WIDTH

	return [
		# Godot 4 has a weird bug where there are seams at the edge
		# of the textures. Adding a margin of 0.01 "fixes" it.
		TEXTURE_TILE_SIZE * Vector2(col + 0.01, row + 0.01),
		TEXTURE_TILE_SIZE * Vector2(col + 0.01, row + 0.99),
		TEXTURE_TILE_SIZE * Vector2(col + 0.99, row + 0.01),
		TEXTURE_TILE_SIZE * Vector2(col + 0.99, row + 0.99),
	]
