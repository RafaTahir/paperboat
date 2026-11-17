extends Node3D
## Session composition; menus pause the simulation without losing the journey.
const BoatController=preload("res://scripts/boat_controller.gd")
const CameraRig=preload("res://scripts/camera_rig.gd")
const Courtyard=preload("res://scripts/courtyard.gd")
const WaterDetails=preload("res://scripts/water_details.gd")
const RainUI=preload("res://scripts/ui_controller.gd")
const AudioDirector=preload("res://scripts/audio_director.gd")
const Tuning=preload("res://scripts/tuning.gd")
var boat
var rig
var companion:Node3D
var water
var ui
var audio
var state:String="START"
var time:float=0.0
var arrival_time:float=0.0
var moved:bool=false
var gust_used:bool=false
var chapters:Dictionary={}
var bump_cooldown:float=0.0
var companion_heading:float=0.0
var _telemetry_tick:float=0.0

func _ready() -> void:
	_setup_input()
	_setup_light()
	var courtyard=Courtyard.new()
	courtyard.name="Courtyard"
	add_child(courtyard)
	boat=BoatController.new()
	boat.name="Boat"
	boat.position=Tuning.START
	var pivot=Node3D.new()
	pivot.name="VisualPivot"
	boat.add_child(pivot)
	pivot.add_child(_boat_mesh(false))
	add_child(boat)
	boat.contact.connect(func(_speed): audio.play_bump())
	boat.recovered.connect(func(_pos): ui.say("A little room to drift."); water.ripple(boat.position))
	companion=Node3D.new()
	companion.name="WaitingBoat"
	companion.position=Tuning.DESTINATION
	companion.add_child(_boat_mesh(true))
	add_child(companion)
	rig=CameraRig.new()
	rig.name="CameraRig"
	rig.target=boat
	add_child(rig)
	boat.camera=rig.camera
	water=WaterDetails.new()
	water.name="WaterAndDetails"
	water.boat=boat
	add_child(water)
	audio=AudioDirector.new()
	audio.name="Audio"
	add_child(audio)
	water.brushed.connect(func(): audio.play_brush())
	ui=RainUI.new()
	ui.name="UI"
	add_child(ui)
	ui.begin_requested.connect(_begin)
	ui.pause_requested.connect(_pause)
	ui.resume_requested.connect(_resume)
	ui.restart_requested.connect(_restart)
	ui.drift_requested.connect(func(): rig.reveal=0.0)
	ui.recovery_requested.connect(func(): boat.recover(); _resume())
	ui.destination_requested.connect(func(): _resume(); rig.show_destination(); ui.say("Follow the light to the timber window.",6.0))
	ui.settings_changed.connect(_settings)
	_settings()
	# Start composition is a still, readable courtyard view, not a gameplay rail.
	rig.reveal=.18
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.afterRainReady=true; window.dispatchEvent(new Event('afterrainready'));",true)
	print("AFTER_RAIN_READY engine=4.6.3 build=1.0")

func _setup_input() -> void:
	var bindings={"move_left":[KEY_A,KEY_LEFT],"move_right":[KEY_D,KEY_RIGHT],"move_forward":[KEY_W,KEY_UP],"move_back":[KEY_S,KEY_DOWN],"gust":[KEY_SPACE],"pause":[KEY_ESCAPE,KEY_P]}
	for action in bindings:
		if not InputMap.has_action(action): InputMap.add_action(action,.18)
		for key in bindings[action]:
			var event=InputEventKey.new()
			event.physical_keycode=key
			InputMap.action_add_event(action,event)
	for action in ["move_left","move_right","move_forward","move_back"]:
		var event=InputEventJoypadMotion.new()
		event.axis=JOY_AXIS_LEFT_X if action in ["move_left","move_right"] else JOY_AXIS_LEFT_Y
		event.axis_value=-1.0 if action in ["move_left","move_forward"] else 1.0
		InputMap.action_add_event(action,event)
	for binding in [["gust",JOY_BUTTON_A],["pause",JOY_BUTTON_START]]:
		var e=InputEventJoypadButton.new()
		e.button_index=binding[1]
		InputMap.action_add_event(binding[0],e)

func _setup_light() -> void:
	var world=WorldEnvironment.new()
	var env=Environment.new()
	env.background_mode=Environment.BG_COLOR
	env.background_color=Color("91b0a7")
	env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color=Color("a2c3c1")
	env.ambient_light_energy=.48
	env.ambient_light_sky_contribution=0.0
	env.reflected_light_source=2
	var sky=Sky.new()
	var sky_mat=ProceduralSkyMaterial.new()
	sky_mat.sky_top_color=Color("779eaa")
	sky_mat.sky_horizon_color=Color("f2dcb1")
	sky_mat.ground_bottom_color=Color("435653")
	sky_mat.ground_horizon_color=Color("d5b78b")
	sky.sky_material=sky_mat
	env.sky=sky
	env.tonemap_mode=Environment.TONE_MAPPER_FILMIC
	world.environment=env
	add_child(world)
	var sun=DirectionalLight3D.new()
	sun.name="LateAfternoon"
	sun.rotation_degrees=Vector3(-47,-38,0)
	sun.light_color=Color("ffe4bc")
	sun.light_energy=1.0
	sun.shadow_enabled=true
	sun.directional_shadow_mode=DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
	sun.directional_shadow_max_distance=24
	sun.shadow_bias=.04
	sun.shadow_normal_bias=.5
	add_child(sun)
	var warm=OmniLight3D.new()
	warm.position=Vector3(2.4,1.2,-4.8)
	warm.omni_range=3.0
	warm.light_color=Color("ffd496")
	warm.light_energy=.65
	add_child(warm)
	var reflection=ReflectionProbe.new()
	reflection.position=Vector3(0,1,0)
	reflection.size=Vector3(8,5,12)
	reflection.intensity=.65
	reflection.max_distance=18
	add_child(reflection)

func _boat_mesh(is_companion:bool) -> Node3D:
	var mesh=load("res://assets/models/paper_boat.glb").instantiate()
	mesh.scale=Vector3.ONE*1.12
	mesh.rotation.y=.22 if is_companion else -.3
	return mesh

func _begin() -> void:
	state="EXPLORE"
	boat.enabled=true
	rig.reveal=0
	ui.hide_menu()
	audio.begin()
	_settings()
	ui.say("A little breeze. A long way home.",5.0)
	print("JOURNEY_BEGIN")

func _pause() -> void:
	if state=="START" or get_tree().paused: return
	ui.show_menu("pause")
	get_tree().paused=true

func _resume() -> void:
	get_tree().paused=false
	ui.hide_menu()

func _restart() -> void:
	get_tree().paused=false
	state="EXPLORE"
	time=0
	arrival_time=0
	chapters.clear()
	moved=false
	gust_used=false
	boat.reset_to(Tuning.START)
	boat.enabled=true
	companion.position=Tuning.DESTINATION
	companion.rotation=Vector3.ZERO
	rig.reset_immediate()
	water.reset_details()
	ui.reset_ui()
	ui.hide_menu()
	audio.reset_audio()
	audio.begin()
	_settings()
	print("JOURNEY_RESTART")

func _settings() -> void:
	boat.reduced_motion=ui.reduced_motion
	rig.reduced_motion=ui.reduced_motion
	audio.set_levels(ui.music_level,ui.effects_level,ui.muted)
	get_viewport().scaling_3d_scale=.65 if ui.low_quality else .85

func _notification(what:int) -> void:
	if what==NOTIFICATION_APPLICATION_FOCUS_OUT and is_instance_valid(ui): _pause()

func _unhandled_input(event:InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if get_tree().paused: _resume()
		else: _pause()
		get_viewport().set_input_as_handled()
	if event is InputEventKey and event.pressed and event.keycode==KEY_H and state!="START":
		rig.show_destination()
		ui.say("The matching boat waits in the sunny pool.")
	if event is InputEventKey and event.pressed and event.keycode==KEY_F3:
		print("PLAY_CHECK state=",state," pos=",boat.position," speed=",boat.velocity.length()," fps=",Engine.get_frames_per_second()," draws=",Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)," recoveries=",boat.recovery_count)

func _process(delta:float) -> void:
	_telemetry_tick+=delta
	if OS.has_feature("web") and _telemetry_tick>.5:
		_telemetry_tick=0
		var snapshot={"state":state,"position":[boat.position.x,boat.position.z],"speed":boat.velocity.length(),"fps":Engine.get_frames_per_second(),"elapsed":time,"recoveries":boat.recovery_count,"companion":[companion.position.x,companion.position.z]}
		JavaScriptBridge.eval("window.afterRainState="+JSON.stringify(snapshot),true)
	if state=="START": return
	time+=delta
	bump_cooldown=maxf(0,bump_cooldown-delta)
	var pos:Vector3=boat.global_position
	var speed:float=boat.velocity.length()
	if speed>.04: moved=true
	if boat.gusting: gust_used=true
	if moved and gust_used: ui.hint.modulate.a=move_toward(ui.hint.modulate.a,0,delta*.16)
	var progress=clampf((4.6-pos.z)/9.2,0.0,1.0)
	audio.update_mix(speed,boat.gusting,progress,pos,delta)
	_chapter("chair",Vector3(3.0,0,2.9),.62,"Under the rattan","The rain sounds different in here.")
	_chapter("current",Vector3(-.6,0,.1),1.4,"A borrowed breeze","Ride the current, or make your own way.")
	_chapter("runoff",Vector3(-2.3,0,-1.7),.7,"Where the rain gathers","A breeze will carry you across.")
	_chapter("hibiscus",Vector3(.2,0,-3.55),.65,"A pocket of petals","Small things make room for you.")
	_chapter("sunny",Vector3(1.9,0,-4.15),1.0,"The sunny pool","The same little stars. Drift close and say hello.")
	if state=="EXPLORE" and pos.distance_to(companion.position)<.18 and boat.drive_input.length()>.08 and speed>.014:
		_arrive()
	if state in ["TOGETHER","LINGER"]:
		arrival_time+=delta
		var trailing:Vector3=pos+Vector3(.22,0,.12)
		# Companion has no blocking collider; it follows a soft separated drift.
		var separation:Vector3=companion.position-pos
		separation.y=0
		if separation.length()<.17: trailing=pos+separation.normalized()*.23
		companion.position=companion.position.lerp(trailing,1.0-exp(-delta*.7))
		companion.position.y=sin(time*2.1)*.002
		companion.rotation.y=lerp_angle(companion.rotation.y,boat.get_node("VisualPivot").rotation.y+.18,delta*.6)
		if arrival_time>14 and state=="TOGETHER":
			state="LINGER"
			ui.show_ending()
			print("JOURNEY_LINGER steering_available=true")
	else:
		companion.position.y=sin(time*1.7)*.002
		companion.rotation.y=sin(time*.18)*.12

func _chapter(id:String,where:Vector3,radius:float,title:String,line:String) -> void:
	if chapters.has(id) or state!="EXPLORE": return
	if boat.position.distance_to(where)<radius:
		chapters[id]=true
		ui.chapter.text=title
		ui.say(line,5.5)
		print("DISCOVERY ",id)

func _arrive() -> void:
	state="TOGETHER"
	arrival_time=0
	rig.reveal=1.0
	audio.arrive()
	water.ripple(boat.position,3.5)
	ui.chapter.text="Together"
	ui.say("Some journeys end with a beginning.",7.0)
	print("JOURNEY_COMPLETE elapsed=",snappedf(time,.1)," distance=",snappedf(boat.distance_travelled,.1))

