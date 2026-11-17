extends Node3D
## Fixed-yaw, elevated follow view. Movement basis remains stable through reveals.

const Tuning = preload("res://scripts/tuning.gd")

var target: Node3D
var reduced_motion: bool = false
var reveal: float = 0.0
var camera: Camera3D

var _focus: Vector3 = Tuning.START
var _lookahead: Vector3 = Vector3.ZERO
var _reveal_blend: float = 0.0
var _destination_cue: float = 0.0
var _initialized: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	camera = Camera3D.new()
	camera.name = "Camera3D"
	camera.fov = Tuning.CAMERA_FOV
	camera.near = 0.04
	camera.far = 55.0
	add_child(camera)
	camera.current = true
	reset_immediate()

func _process(delta: float) -> void:
	if not is_instance_valid(target) or not is_instance_valid(camera):
		return
	if not _initialized:
		reset_immediate()
	var target_velocity: Vector3 = Vector3.ZERO
	if target is CharacterBody3D:
		target_velocity = (target as CharacterBody3D).velocity
	var desired_look: Vector3 = target_velocity * 1.8
	desired_look = desired_look.limit_length(Tuning.CAMERA_LOOKAHEAD)
	if reduced_motion:
		desired_look = Vector3.ZERO
	_lookahead = _lookahead.lerp(desired_look, 1.0 - exp(-delta * 2.2))
	var response: float = 0.55 if reduced_motion else Tuning.CAMERA_FOLLOW_RESPONSE
	_focus = _focus.lerp(target.global_position, 1.0 - exp(-delta / response))
	_reveal_blend = move_toward(_reveal_blend, clampf(reveal, 0.0, 1.0), delta / 12.0)
	_destination_cue = move_toward(_destination_cue, 0.0, delta * 0.2)
	_place_camera()

func _place_camera() -> void:
	var follow_focus: Vector3 = _focus + _lookahead + Vector3(0.0, 0.025, -0.2)
	# A short destination cue changes composition, never camera yaw.
	if _destination_cue > 0.0 and not reduced_motion:
		follow_focus = follow_focus.lerp(Tuning.DESTINATION, _destination_cue * 0.12)
	var normal_position: Vector3 = follow_focus + Tuning.CAMERA_OFFSET
	var reveal_weight: float = smoothstep(0.0, 1.0, _reveal_blend)
	if reduced_motion:
		camera.global_position = normal_position + Vector3(0.0, 0.22, 0.18) * reveal_weight
		camera.look_at(follow_focus, Vector3.UP)
		return
	# The high endpoint frames the full 8 x 12 m courtyard with a fixed yaw.
	var high_focus: Vector3 = Vector3(0.0, 0.0, -0.15)
	var high_position: Vector3 = Vector3(0.0, 11.8, 9.6)
	var focus: Vector3 = follow_focus.lerp(high_focus, reveal_weight)
	camera.global_position = normal_position.lerp(high_position, reveal_weight)
	camera.look_at(focus, Vector3.UP)

func reset_immediate() -> void:
	if is_instance_valid(target):
		_focus = target.global_position
	else:
		_focus = Tuning.START
	_lookahead = Vector3.ZERO
	_reveal_blend = 0.0
	_destination_cue = 0.0
	reveal = 0.0
	_initialized = true
	if is_instance_valid(camera):
		_place_camera()

func show_destination(amount: float = 1.0) -> void:
	_destination_cue = clampf(amount, 0.0, 1.0)
