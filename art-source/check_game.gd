extends SceneTree
## Focused deterministic integration checks. Excluded from normal game imports.
## Run from project root: godot --headless --fixed-fps 60 --path . --script art-source/check_game.gd
## These checks exercise input and state, not browser graphics, sound or subjective feel.

const Tuning = preload("res://scripts/tuning.gd")
var game: Node3D
var failures: int = 0
var checks: int = 0
var traversed_metres: float = 0.0
var route_seconds: float = 0.0
var discoveries: Dictionary = {}

func _initialize() -> void:
	call_deferred("run")

func expect(condition: bool, message: String) -> void:
	checks += 1
	if condition:
		print("CHECK PASS: ", message)
	else:
		failures += 1
		printerr("CHECK FAIL: ", message)

func frames(count: int) -> void:
	for frame_index in range(count):
		await physics_frame

func release_input() -> void:
	for action in ["move_left", "move_right", "move_forward", "move_back", "gust"]:
		Input.action_release(action)

func steer(direction: Vector3, gust: bool) -> void:
	var camera: Camera3D = game.rig.camera
	var right: Vector3 = camera.global_basis.x
	var forward: Vector3 = -camera.global_basis.z
	right.y = 0.0
	forward.y = 0.0
	right = right.normalized()
	forward = forward.normalized()
	var x: float = direction.dot(right)
	var y: float = -direction.dot(forward)
	release_input()
	if x < 0.0: Input.action_press("move_left", -x)
	if x > 0.0: Input.action_press("move_right", x)
	if y < 0.0: Input.action_press("move_forward", -y)
	if y > 0.0: Input.action_press("move_back", y)
	if gust: Input.action_press("gust")

func navigate(where: Vector3, label: String, gust: bool = true, max_seconds: float = 35.0, tolerance: float = 0.12) -> bool:
	var start: Vector3 = game.boat.global_position
	var max_frames: int = ceili(max_seconds * 60.0)
	var tick: int = 0
	while game.boat.global_position.distance_to(where) > tolerance and tick < max_frames:
		var delta: Vector3 = where - game.boat.global_position
		delta.y = 0.0
		steer(delta.normalized(), gust)
		await physics_frame
		tick += 1
	release_input()
	var distance: float = game.boat.global_position.distance_to(where)
	var succeeded: bool = distance <= tolerance
	expect(succeeded, "navigate " + label + " via input; residual=" + str(snappedf(distance, 0.001)) + "m; ticks=" + str(tick))
	if not succeeded:
		printerr("Navigation blocked from ", start, " to ", where, "; actual ", game.boat.global_position)
	return succeeded

func full_route() -> void:
	# This complete sequence never changes boat position or velocity directly.
	# Waypoints are measurement targets, not runtime navigation rails.
	var waypoints: Array = [
		[Vector3(-1.2, 0.0, 4.0), "B: opening turn"],
		[Vector3(1.1, 0.0, 3.1), "C: planter passage"],
		[Vector3(2.5, 0.0, 3.55), "chair south opening"],
		[Vector3(3.02, 0.0, 3.55), "chair centerline approach"],
		[Vector3(3.02, 0.0, 2.88), "chair shelter discovery"],
		[Vector3(3.02, 0.0, 2.1), "chair north opening"],
		[Vector3(2.6, 0.0, 1.7), "D: chair rejoin"],
		[Vector3(1.2, 0.0, 0.3), "E: curved current entry"],
		[Vector3(-1.5, 0.0, 0.1), "F: sweep around central planter"],
		[Vector3(-2.3, 0.0, -1.7), "G: runoff crossing"],
		[Vector3(-0.8, 0.0, -2.7), "H: fern passage"],
		[Vector3(-0.6, 0.0, -3.5), "hibiscus pocket opening"],
		[Vector3(0.2, 0.0, -3.55), "hibiscus discovery"],
		[Vector3(0.8, 0.0, -1.5), "I: hibiscus rejoin"],
		[Vector3(2.5, 0.0, -2.4), "J: last sheltered turn"],
		[Vector3(1.4, 0.0, -3.5), "K: sunny opening"],
		[Vector3(2.1, 0.0, -4.6), "L: companion nudge"]
	]
	for point in waypoints:
		if not await navigate(point[0], point[1]):
			return
	traversed_metres = game.boat.distance_travelled
	route_seconds = game.time
	discoveries = game.chapters.duplicate()
	expect(game.boat.recovery_count == 0, "complete route and both detours need no recovery")
	expect(game.chapters.has("chair") and game.chapters.has("hibiscus"), "both optional discoveries are accessible and reconnect")
	expect(game.chapters.has("current") and game.chapters.has("runoff") and game.chapters.has("sunny"), "all main route discovery regions reached")
	expect(game.state == "TOGETHER", "full input traversal reaches deliberate companion contact")

func arrival_case(start: Vector3, direction: Vector3, gust: bool, label: String) -> void:
	release_input()
	game._restart()
	await frames(2)
	# Arrival-only setup. This reposition is explicitly separate from full traversal.
	game.boat.reset_to(start)
	game.rig.reset_immediate()
	await frames(12)
	expect(game.state == "EXPLORE", label + ": standing in arrival area without input does not finish")
	steer(direction, gust)
	var tick: int = 0
	while game.state == "EXPLORE" and tick < 300:
		await physics_frame
		tick += 1
	release_input()
	expect(game.state == "TOGETHER", label + ": input nudge accepted within five seconds")
	expect(game.boat.enabled, label + ": steering remains enabled")

func run() -> void:
	var scene: PackedScene = load("res://scenes/main.tscn")
	game = scene.instantiate()
	root.add_child(game)
	current_scene = game
	await frames(3)
	expect(game.state == "START" and not game.boat.enabled, "resources ready with simulation awaiting Begin")
	game._begin()
	await frames(3)
	expect(game.state == "EXPLORE" and game.boat.enabled, "Begin enables exploration")
	if not OS.get_cmdline_user_args().has("--arrival-only"):
		await full_route()
	if game.state == "TOGETHER":
		var reveal_start: Vector3 = game.boat.global_position
		steer(Vector3(0.0, 0.0, 1.0), false)
		await frames(100)
		release_input()
		expect(game.boat.global_position.distance_to(reveal_start) > 0.13, "player can steer during camera rise")
		await frames(850)
		expect(game.state == "LINGER" and game.boat.enabled, "reveal reaches linger while retaining steering")
		var arrival_before: float = game.arrival_time
		await frames(30)
		expect(game.arrival_time > arrival_before, "ending remains one-shot instead of restarting on contact")
	# Restart must reset all actual state used by the experience.
	release_input()
	game._restart()
	await frames(1)
	expect(game.state == "EXPLORE" and game.chapters.is_empty() and game.arrival_time == 0.0, "restart clears chapters and arrival state")
	expect(game.boat.position.distance_to(Tuning.START) < 0.01 and game.boat.velocity.length() < 0.01, "restart restores player position and velocity")
	expect(game.companion.position.distance_to(Tuning.DESTINATION) < 0.01 and game.rig.reveal == 0.0 and not game.ui.ending.visible, "restart restores companion, camera target and ending UI")
	var petals_reset: bool = true
	for item in game.water.petals:
		if item.node.position.distance_to(item.origin) > 0.01:
			petals_reset = false
	expect(petals_reset, "restart returns floating details to original positions")
	# Input-free proximity remains deliberately incomplete, even within nudge radius.
	game.boat.reset_to(Tuning.DESTINATION + Vector3(0.0, 0.0, 0.12))
	await frames(120)
	expect(game.state == "EXPLORE", "close companion proximity alone does not complete")
	await arrival_case(Tuning.DESTINATION + Vector3(0.0, 0.0, 0.30), Vector3.FORWARD, false, "slow south approach after restart")
	await arrival_case(Tuning.DESTINATION + Vector3(-0.32, 0.0, 0.0), Vector3.RIGHT, true, "gust west approach")
	# Pause verification covers simulation state rather than only the visible panel.
	release_input()
	var paused_position: Vector3 = game.boat.global_position
	var paused_time: float = game.time
	game._pause()
	await frames(60)
	expect(paused and game.boat.global_position.distance_to(paused_position) < 0.0001 and is_equal_approx(game.time, paused_time), "pause freezes progression and physical movement")
	game._resume()
	await frames(2)
	expect(not paused and not game.ui.panel.visible, "Resume closes pause and returns simulation")
	print("INTEGRATION_RESULT checks=", checks, " failures=", failures, " full_route_seconds=", snappedf(route_seconds, 0.1), " full_route_metres=", snappedf(traversed_metres, 0.1), " chapters=", discoveries)
	release_input()
	current_scene = null
	game.queue_free()
	game = null
	await process_frame
	await process_frame
	quit(1 if failures > 0 else 0)
