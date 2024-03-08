extends Node3D

@export var maxPitchDeg: float = 89
@export var minPitchDeg: float = -89
@export var maxZoom: float = 200.0
@export var minZoom: float = 4.0
@export var defaultZoom: float = 20.0
@export var zoomStep: float = 2.0
@export var zoomYStep: float = 0.15
@export var verticalSensitivity: float = 0.002
@export var horizontalSensitivity: float = 0.002
@export var camYOffset: float = 4.0
@export var camLerpSpeed: float = 16.0
@export var camTarget: Node

@onready var _springArm = $SpringArm3D
var _curZoom: float = defaultZoom
var _curYOffset: float = camYOffset


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event) -> void:
	if event is InputEventMouseMotion:
		# rotate the rig around the target
		rotation.y -= event.relative.x * horizontalSensitivity
		rotation.y = wrapf(rotation.y,0.0,TAU)
		
		rotation.x -= event.relative.y * verticalSensitivity
		rotation.x = clamp(rotation.x, deg_to_rad(minPitchDeg), deg_to_rad(maxPitchDeg))
		
	if event is InputEventMouseButton:
		# change zoom level on mouse wheel rotation
		# this could be refactored to be based on an input action as well
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP and _curZoom > minZoom:
				_curZoom -= zoomStep
				camYOffset -= zoomYStep
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and _curZoom < maxZoom:
				_curZoom += zoomStep
				camYOffset += zoomYStep


func _physics_process(delta) -> void:
	# zoom the camera accordingly
	_springArm.spring_length = lerp(_springArm.spring_length, _curZoom, delta * camLerpSpeed)
	
	# set the position of the rig to follow the target
	_curYOffset = lerp(_curYOffset, camYOffset, delta * camLerpSpeed)
	set_position(camTarget.global_transform.origin + Vector3(0,_curYOffset,0))
