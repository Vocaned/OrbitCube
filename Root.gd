extends Node3D


func _ready():
	$NetworkManager.connect_to_server("127.0.0.1", 25565)
