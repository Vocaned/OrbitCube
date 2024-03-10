extends StreamPeerTCP
class_name NetworkParser

func _init() -> void:
    big_endian = true

func put_mc_string(value: String) -> void:
    var buffer = value.to_ascii_buffer()
    buffer.resize(64)
    put_data(buffer)

func put_half_float(value: float) -> void:
    var buffer = PackedByteArray()
    buffer.encode_half(0, value)
    put_data(buffer)

func get_mc_string() -> String:
    var buffer = get_data(64)
    return PackedByteArray(buffer).get_string_from_ascii()
