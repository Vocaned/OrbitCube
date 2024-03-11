extends Node

var _NetworkParser: NetworkParser
var _GZIPParser: StreamPeerGZIP
var _world: World

var _thread
var _chat

func _ready() -> void:
	create_gzip_parser()
	if not _NetworkParser:
		_NetworkParser = NetworkParser.new()
	if not _world:
		_world = World.new()
		_world._camera_rig = %CameraRig
		add_child(_world)

func connect_to_server(ip: String, port: int) -> void:
	if not _chat:
		_chat = %Chat

	_thread = Thread.new()
	_thread.start(func():
		var err = _NetworkParser.connect_to_host(ip, port)
		assert(err == OK, "Could not connect to server. %s" % error_string(err))

		while _NetworkParser.get_status() != StreamPeerTCP.STATUS_CONNECTED:
			_NetworkParser.poll()

		send_identification("username", "asd")

		while true:
			if _NetworkParser.get_available_bytes() < 1:
				continue
			var packet_type = _NetworkParser.get_u8()
			_chat.add_message.call_deferred("recv %02x" % packet_type)
			parse_recv_packet(packet_type)	
	)


func create_gzip_parser() -> void:
	if _GZIPParser:
		_GZIPParser.clear()
	else:
		_GZIPParser = StreamPeerGZIP.new()
	
	_GZIPParser.big_endian = true
	_GZIPParser.start_decompression(false, 100 * 1000 * 1000) # Just allocate 100MB of memory to the buffer for now. TODO: make dynamic


func parse_recv_packet(packet_type: int) -> void:
	match packet_type:
		0x00:
			recv_identification()
		0x01:
			# Ping
			return
		0x02:
			# Level Initialize
			create_gzip_parser()
		0x03:
			recv_chunk()
		0x04:
			_chat.add_message.call_deferred("World finalized")
			recv_finalize()
			_world.initialize(_chat)
		0x06:
			# Set block
			_NetworkParser.get_data(7)
		0x07:
			# Spawn player
			_NetworkParser.get_data(73)
		0x08:
			# Set pos and ori
			_NetworkParser.get_data(9)
		0x09:
			# Pos and ori update
			_NetworkParser.get_data(6)
		0x0a:
			# Pos update
			_NetworkParser.get_data(4)
		0x0b:
			# Ori update
			_NetworkParser.get_data(3)
		0x0c:
			# Despawn player
			_NetworkParser.get_8()
		0x0d:
			# Message
			var _player_id = _NetworkParser.get_8()
			var message = _NetworkParser.get_mc_string()
			_chat.add_chat_message.call_deferred(message)
		0x0e:
			# Disconnect player
			var message = _NetworkParser.get_mc_string()
			_chat.add_message.call_deferred("Disconnected: %s" % message)
		0x0f:
			# Update user type
			_NetworkParser.get_8()
		_:
			_chat.add_message.call_deferred("Unknown packet type %X" % packet_type)


func send_identification(username: String, mppass: String) -> void:
	_NetworkParser.put_u8(0x00) # Player Identification
	_NetworkParser.put_u8(0x07) # Protocol Version
	_NetworkParser.put_mc_string(username) # Username
	_NetworkParser.put_mc_string(mppass) # MPPass
	_NetworkParser.put_u8(0x00) # CPE byte


func send_block(xyz: Vector3i, mode: int, block: int) -> void:
	_NetworkParser.put_u8(0x05) # Set block
	_NetworkParser.put_u16(xyz.x)
	_NetworkParser.put_u16(xyz.y)
	_NetworkParser.put_u16(xyz.z)
	_NetworkParser.put_u8(mode)
	_NetworkParser.put_u8(block)


func send_location(xyz: Vector3, yaw: int, pitch: int) -> void:
	_NetworkParser.put_u8(0x08) # Position and Orientation
	_NetworkParser.put_u8(0xFF) # Player
	_NetworkParser.put_half_float(xyz.x)
	_NetworkParser.put_half_float(xyz.y)
	_NetworkParser.put_half_float(xyz.z)
	_NetworkParser.put_u8(yaw)
	_NetworkParser.put_u8(pitch)


func send_message(message: String) -> void:
	_NetworkParser.put_u8(0x0d) # Message
	_NetworkParser.put_8(0xff) # Player
	_NetworkParser.put_mc_string(message)


func recv_identification() -> void:
	print("Protocol version: %X" % _NetworkParser.get_u8())
	print("Server name: %s" % _NetworkParser.get_mc_string())
	print("Server motd: %s" % _NetworkParser.get_mc_string())
	print("User type: %X" % _NetworkParser.get_u8())


func recv_chunk() -> void:
	var _length = _NetworkParser.get_u16()
	var res = _NetworkParser.get_data(1024)
	_NetworkParser.get_u8()
	print("Chunk length: %d" % _length)
	if res[1].size() > _length:
		res[1].resize(_length)
	print("Chunk size: %d" % res[1].size())
	var _err = _GZIPParser.put_data(res[1])
	assert(_err == OK, "Failed to add data to gzip buffer. %s" % error_string(_err))


func recv_finalize() -> void:
	_world.world_size = Vector3i(
		_NetworkParser.get_u16(),
		_NetworkParser.get_u16(),
		_NetworkParser.get_u16()
	)

	#var _err = _GZIPParser.finish()
	#assert(_err == OK, "Failed to decompress gzip. %s" % error_string(_err))
	var _length = _GZIPParser.get_32()
	print("Data length %d" % _length)
	var res = _GZIPParser.get_data(_GZIPParser.get_available_bytes())
	assert(res[0] == OK, "Failed to read decompressed data. %s" % error_string(res[0]))

	_world.world_blocks = Array(res[1])
