extends Node3D
## Bounded pooled ripples, curved path wake and current-driven petals.
const Flow = preload("res://scripts/current_field.gd")
var boat: Node3D
var petals: Array = []
var rings: Array = []
var elapsed: float = 0.0
var emission_time: float = 0.0
var ring_index: int = 0
var brush_cooldown: float = 0.0
signal brushed

func _ready() -> void:
	var water = MeshInstance3D.new()
	var plane = PlaneMesh.new()
	plane.size=Vector2(8,12)
	water.mesh=plane
	var material=ShaderMaterial.new()
	material.shader=preload("res://assets/materials/water.gdshader")
	water.material_override=material
	water.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(water)
	var rng=RandomNumberGenerator.new()
	rng.seed=17062026
	for i in range(100):
		var p=MeshInstance3D.new()
		var mesh=SphereMesh.new()
		mesh.radius=0.014 if i>0 else 0.038
		mesh.height=0.006 if i>0 else 0.009
		mesh.radial_segments=8
		mesh.rings=3
		p.mesh=mesh
		p.scale=Vector3(1.0,1.0,1.8)
		var mat=StandardMaterial3D.new()
		mat.albedo_color=Color("cb6066") if i%3 else Color("e4b0a0")
		if i==0: mat.albedo_color=Color("997335")
		mat.roughness=0.7
		p.material_override=mat
		p.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(p)
		var initial=Vector3(rng.randf_range(-3.5,3.5),0.009,rng.randf_range(-5.5,5.0))
		if i<20: initial=Vector3(rng.randf_range(-.3,.9),0.009,rng.randf_range(-3.8,-3.2))
		if i==0: initial=Vector3(-1.8,0.009,4.25)
		p.position=initial
		p.rotation.y=rng.randf()*TAU
		petals.append({"node":p,"origin":initial,"velocity":Vector3.ZERO})
	for i in range(64):
		var ring=MeshInstance3D.new()
		var torus=TorusMesh.new()
		torus.inner_radius=.046
		torus.outer_radius=.048
		torus.rings=24
		torus.ring_segments=4
		ring.mesh=torus
		var mat=StandardMaterial3D.new()
		mat.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color=Color(.79,.89,.81,.0)
		mat.no_depth_test=false
		ring.material_override=mat
		ring.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(ring)
		ring.visible=false
		rings.append({"node":ring,"age":5.0,"life":2.0})

func ripple(pos: Vector3, life: float = 2.4) -> void:
	var item=rings[ring_index]
	ring_index=(ring_index+1)%rings.size()
	item.age=0.0
	item.life=life
	item.node.position=Vector3(pos.x,.013,pos.z)
	item.node.scale=Vector3.ONE
	item.node.visible=true

func reset_details() -> void:
	for item in petals:
		item.node.position=item.origin
		item.velocity=Vector3.ZERO
	for item in rings: item.node.visible=false; item.age=5.0

func _physics_process(delta: float) -> void:
	elapsed+=delta
	brush_cooldown=maxf(0.0,brush_cooldown-delta)
	for item in rings:
		if item.age>=item.life: continue
		item.age+=delta
		var amount=item.age/item.life
		item.node.scale=Vector3(1.0+amount*3.0,1.0,1.0+amount*2.0)
		item.node.material_override.albedo_color.a=(1.0-amount)*.32
		if amount>=1.0: item.node.hide()
	if not is_instance_valid(boat): return
	var speed=boat.velocity.length()
	emission_time+=delta
	if speed>.025 and emission_time>.13:
		emission_time=0
		ripple(boat.global_position-boat.velocity.normalized()*.035,1.5)
	for item in petals:
		var p:Node3D=item.node
		var toward=p.position-boat.global_position
		toward.y=0
		var distance=toward.length()
		var desired=Flow.sample(p.position)*.8
		if distance<.21 and distance>.002:
			desired+=toward.normalized()*(.21-distance)*.8+boat.velocity*.25
			if speed>.03 and brush_cooldown<=0:
				brushed.emit()
				brush_cooldown=2.0
		item.velocity=item.velocity.lerp(desired,1.0-exp(-delta*2.0))
		p.position+=item.velocity*delta
		p.rotation.y+=delta*(.06+desired.length())
		p.position.y=.009+sin(elapsed*1.6+p.position.x*3.0)*.001
		if absf(p.position.x)>3.8 or absf(p.position.z)>5.8: p.position=item.origin
