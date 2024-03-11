extends RichTextLabel

# TODO: Unspaghettify

var _colors = {
	"&0": "#000000",
	"&1": "#0000AA",
	"&2": "#00AA00",
	"&3": "#00AAAA",
	"&4": "#AA0000",
	"&5": "#AA00AA",
	"&6": "#FFAA00",
	"&7": "#AAAAAA",
	"&8": "#555555",
	"&9": "#5555FF",
	"&a": "#55FF55",
	"&b": "#55FFFF",
	"&c": "#FF5555",
	"&d": "#FF55FF",
	"&e": "#FFFF55",
	"&f": "#FFFFFF"
}

func add_chat_message(message: String) -> void:
	# Escape bbcode
	message = message.replace("[", "[lb]")

	for c in _colors.keys():
		message = message.replace(c, "[color=%s]" % _colors[c])

	var _regex = RegEx.new()
	_regex.compile(r'\[color=')
	for i in range(_regex.search_all(message).size()):
		message += "[/color]"

	add_message(message)

func add_message(message: String) -> void:
	text += message + "\n"
