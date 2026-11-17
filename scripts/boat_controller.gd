extends CharacterBody3D
## Kinematic water-plane controller. Cosmetic movement never rotates its collider.

signal recovered(position: Vector3)
signal contact(speed: float)

const Tuning = preload("res://scripts/tuning.gd")
const Flow = preload("res://scripts/current_field.gd")

var camera: Camera3D
var enabled: bool = false
var gusting: bool = false
var drive_input: Vector2 = Vector2.ZERO
var current_velocity: Vector3 = Vector3.ZERO
var safe_position: Vector3 = Tuning.START
var reduced_motion: bool = false
var distance_travelled: float = 0.0
var recovery_count: int = 0

var _visual: Node3D
var _time: float = 0.0
var _safe_timer: float = 0.0
var _blocked_time: float = 0.0
var _blocked_anchor: Vector3
var _blocked_direction: Vector3 = Vector3.ZERO
var _tried_escape: bool = false
var _right: Vector3 = Vector3.RIGHT
var _forward: Vector3 = Vector3.FORWARD
var _last_heading: float = 0.0
var _contact_cooldown: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
	up_direction = Vector3.UP
	max_slides = 6
	safe_margin = 0.002
	collision_layer = 2
	collision_mask = 1
	if get_node_or_null("CollisionShape3D") == null:
		var collider: CollisionShape3D = CollisionShape3D.new()
		collider.name = "CollisionShape3D"
		var sphere: SphereShape3D = SphereShape3D.new()
		sphere.radius = Tuning.CONTACT_RADIUS
		collider.shape = sphere
		collider.position.y = 0.035
		add_child(collider)
	_visual = get_node_or_null("VisualPivot") as Node3D
	safe_position = global_position
	_blocked_anchor = global_position

func _physics_process(delta: float) -> void:
	_time += delta
	_contact_cooldown = maxf(0.0, _contact_cooldown - delta)
	if not enabled:
		drive_input = Vector2.ZERO
		gusting = false
		velocity = Vector3.ZERO
		_animate(delta)
		return
	drive_input = Input.get_vector("move_left", "move_right", "move_forward", "move_back", 0.18)
	gusting = Input.is_action_pressed("gust") and drive_input.length_squared() > 0.01
	_update_camera_basis()
	var desired_direction: Vector3 = (_right * drive_input.x - _forward * drive_input.y).limit_length(1.0)
	var speed: float = Tuning.GUST_SPEED if gusting else Tuning.CRUISE_SPEED
	current_velocity = Flow.sample(global_position)
	var target_velocity: Vector3 = desired_direction * speed + current_velocity
	var response: float = Tuning.GUST_RESPONSE if gusting else Tuning.STEER_RESPONSE
	if drive_input.length_squared() < 0.001:
		response = Tuning.COAST_RESPONSE
	elif velocity.dot(desired_direction) < -0.015:
		response = Tuning.BRAKE_RESPONSE
	velocity = velocity.lerp(target_velocity, 1.0 - exp(-delta / response))
	velocity.y = 0.0
	var previous: Vector3 = global_position
	var incident_speed: float = velocity.length()
	move_and_slide()
	global_position.y = Tuning.WATER_HEIGHT
	velocity.y = 0.0
	var travelled: float = global_position.distance_to(previous)
	distance_travelled += travelled
	if get_slide_collision_count() > 0 and _contact_cooldown <= 0.0 and incident_speed > 0.035:
		contact.emit(incident_speed)
		_contact_cooldown = 0.75
	_update_recovery(delta, desired_direction, travelled)
	_animate(delta)

func _update_camera_basis() -> void:
	if not is_instance_valid(camera):
		return
	var next_right: Vector3 = camera.global_basis.x
	var next_forward: Vector3 = -camera.global_basis.z
	next_right.y = 0.0
	next_forward.y = 0.0
	if next_right.length_squared() > 0.01:
		_right = next_right.normalized()
	if next_forward.length_squared() > 0.01:
		_forward = next_forward.normalized()

func _update_recovery(delta: float, desired_direction: Vector3, travelled: float) -> void:
	if absf(global_position.x) > 3.91 or absf(global_position.z) > 5.91 or not global_position.is_finite():
		recover()
		return
	_safe_timer += delta
	if _safe_timer > 0.7 and get_slide_collision_count() == 0 and travelled > 0.0001 and _has_clearance():
		safe_position = global_position
		_safe_timer = 0.0
	# One sustained intentional push against an edge is not a stuck state.
	# Only recover after multiple attempted escape directions with no travel.
	if drive_input.length() > 0.4 and travelled < 0.00007:
		if _blocked_time < 0.01:
			_blocked_anchor = global_position
			_blocked_direction = desired_direction
		elif _blocked_direction.dot(desired_direction) < 0.35:
			_tried_escape = true
		_blocked_time += delta
		if _blocked_time > 7.0 and _tried_escape and global_position.distance_to(_blocked_anchor) < 0.04:
			recover()
	else:
		_blocked_time = maxf(0.0, _blocked_time - delta * 3.0)
		if _blocked_time <= 0.01:
			_tried_escape = false

func _has_clearance() -> bool:
	if absf(global_position.x) > 3.68 or absf(global_position.z) > 5.68:
		return false
	var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var origin: Vector3 = global_position + Vector3(0.0, 0.04, 0.0)
	for index in range(8):
		var angle: float = float(index) * TAU / 8.0
		var end: Vector3 = origin + Vector3(cos(angle), 0.0, sin(angle)) * 0.14
		var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, end, 1, [get_rid()])
		if not space.intersect_ray(query).is_empty():
			return false
	return true

func _animate(delta: float) -> void:
	if not is_instance_valid(_visual):
		_visual = get_node_or_null("VisualPivot") as Node3D
	if not is_instance_valid(_visual):
		return
	var strength: float = 0.18 if reduced_motion else 1.0
	var planar_speed: float = velocity.length()
	var heading: float = _last_heading
	if planar_speed > 0.008:
		heading = atan2(-velocity.x, -velocity.z)
	var turn: float = angle_difference(_visual.rotation.y, heading)
	_visual.rotation.y = lerp_angle(_visual.rotation.y, heading, 1.0 - exp(-delta * 7.5))
	_last_heading = heading
	var bank: float = clampf(-turn * planar_speed * 0.75, -0.085, 0.085) * strength
	_visual.rotation.z = lerpf(_visual.rotation.z, bank + sin(_time * 2.4) * 0.011 * strength, 1.0 - exp(-delta * 5.0))
	var flutter: float = sin(_time * 20.0) * 0.006 if gusting else 0.0
	_visual.rotation.x = (sin(_time * 3.1) * 0.009 + flutter) * strength
	_visual.position.y = (sin(_time * 2.7) * 0.0018 + sin(_time * 4.9) * 0.0007) * strength

func reset_to(position: Vector3) -> void:
	global_position = Vector3(position.x, Tuning.WATER_HEIGHT, position.z)
	safe_position = global_position
	velocity = Vector3.ZERO
	current_velocity = Vector3.ZERO
	drive_input = Vector2.ZERO
	gusting = false
	distance_travelled = 0.0
	_blocked_time = 0.0
	_safe_timer = 0.0
	_tried_escape = false
	_last_heading = 0.0
	_time = 0.0
	if is_instance_valid(_visual):
		_visual.transform = Transform3D.IDENTITY

func recover() -> void:
	var destination: Vector3 = safe_position
	if not destination.is_finite():
		destination = Tuning.START
	global_position = Vector3(destination.x, Tuning.WATER_HEIGHT, destination.z)
	velocity = Vector3.ZERO
	_blocked_time = 0.0
	_tried_escape = false
	recovery_count += 1
	recovered.emit(global_position)
	print("Boat recovered to open water: ", global_position)
