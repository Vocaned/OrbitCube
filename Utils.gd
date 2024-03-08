extends Node

func read_file_from_zip(zip_path: String, filename: String) -> PackedByteArray:
	var reader = ZIPReader.new()
	var err = reader.open(zip_path)
	if err != OK:
		push_error("Could not open %s. %s" % [zip_path, error_string(err)])
		return PackedByteArray()
	if not reader.file_exists(filename):
		push_error("Filename %s does not exist in %s." % [filename, zip_path])
	var res = reader.read_file(filename)
	reader.close()
	return res
