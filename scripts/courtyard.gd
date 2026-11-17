extends Node3D
## Original modular courtyard. All collision sits on layer 1; water is root-owned.

const BOAT = preload("res://assets/models/paper_boat.glb")
const POTS = [preload("res://assets/models/clay_pot_1.glb"),preload("res://assets/models/clay_pot_2.glb"),preload("res://assets/models/clay_pot_3.glb")]
const FERN = preload("res://assets/models/fern.glb")
const POTHOS = preload("res://assets/models/pothos.glb")
const CHAIR = preload("res://assets/models/rattan_chair.glb")
const CHAIN = preload("res://assets/models/rain_chain.glb")
const HIBISCUS = preload("res://assets/models/hibiscus.glb")
var wood: ShaderMaterial
var wood_light: ShaderMaterial
var concrete: StandardMaterial3D
var moss: StandardMaterial3D
var brass: StandardMaterial3D
var plant_pivots: Array[Node3D] = []
var _time := 0.0
var _material_cache: Dictionary = {}

func _ready() -> void:
	wood=_wood_material(Color("594333"))
	wood_light=_wood_material(Color("79604b"))
	concrete=_material(Color("817d69"),.79)
	moss=_material(Color("3b5132"),.94)
	brass=_material(Color("6a7559"),.48)
	_floor_and_shell()
	_architecture()
	_planters()
	_chair_and_chain()
	_small_details()
	_batch_static_boxes()

func _wood_material(c: Color) -> ShaderMaterial:
	var mat=ShaderMaterial.new()
	mat.shader=preload("res://assets/materials/wood.gdshader")
	mat.set_shader_parameter("wood_color",c)
	return mat

func _material(c: Color, roughness: float) -> StandardMaterial3D:
	var key=c.to_html()+str(roughness)
	if _material_cache.has(key): return _material_cache[key]
	var mat=StandardMaterial3D.new()
	mat.albedo_color=c
	mat.roughness=roughness
	_material_cache[key]=mat
	return mat

func _box(pos: Vector3,size: Vector3,mat: Material,collide: bool=false) -> MeshInstance3D:
	var item=MeshInstance3D.new()
	var mesh=BoxMesh.new()
	mesh.size=size
	item.mesh=mesh
	item.material_override=mat
	item.position=pos
	item.set_meta("batch_static_box",true)
	add_child(item)
	if collide: _box_collision(pos,size)
	return item

func _box_collision(pos: Vector3,size: Vector3) -> void:
	var body=StaticBody3D.new()
	body.collision_layer=1
	body.collision_mask=0
	var shape=CollisionShape3D.new()
	var box=BoxShape3D.new()
	box.size=size
	shape.shape=box
	body.add_child(shape)
	body.position=pos
	add_child(body)

func _round_collision(pos: Vector3,r: float,height: float=1.0) -> void:
	var body=StaticBody3D.new()
	body.collision_layer=1
	body.collision_mask=0
	var shape=CollisionShape3D.new()
	var cylinder=CylinderShape3D.new()
	cylinder.radius=r
	cylinder.height=height
	shape.shape=cylinder
	body.add_child(shape)
	body.position=pos+Vector3(0,height*.5,0)
	add_child(body)

func _floor_and_shell() -> void:
	var tile=ShaderMaterial.new()
	tile.shader=preload("res://assets/materials/tiles.gdshader")
	var plane=MeshInstance3D.new()
	var surface=PlaneMesh.new()
	surface.size=Vector2(8.0,12.0)
	plane.mesh=surface
	plane.material_override=tile
	plane.position.y=-.041
	add_child(plane)
	var wall=ShaderMaterial.new()
	wall.shader=preload("res://assets/materials/plaster.gdshader")
	_box(Vector3(0,1.2,-6.09),Vector3(8.35,2.5,.18),wall,true)
	_box(Vector3(-4.09,.60,0),Vector3(.18,1.3,12),wall,true)
	_box(Vector3(4.09,.60,0),Vector3(.18,1.3,12),wall,true)
	# A low front parapet keeps follow-camera sightlines open.
	_box(Vector3(0,.035,6.06),Vector3(8.3,.15,.15),concrete,true)
	for x in [-3.9,3.9]:
		_box(Vector3(x,.025,0),Vector3(.19,.13,12),concrete,true)
		_box(Vector3(x,.10,0),Vector3(.23,.06,12),wood_light)
	_box(Vector3(0,.035,-5.9),Vector3(8,.13,.18),concrete,true)
	# Plaster base and thin moss line ground the damp courtyard.
	for x in [-3.985,3.985]:
		_box(Vector3(x,.18,0),Vector3(.025,.21,12),moss)
	_box(Vector3(0,.15,-5.985),Vector3(8,.20,.025),moss)
	for x in [-3.35,-1.65,.05,1.75,3.45]:
		_box(Vector3(x,1.26,-5.96),Vector3(.09,2.48,.09),wood)
	_box(Vector3(0,2.43,-5.96),Vector3(8.3,.15,.23),wood)

func _architecture() -> void:
	# Starting timber step is raised above the boat, without a waterline obstruction.
	# Open recess at the front edge reveals the handmade boat beneath its shelter.
	# First full board begins behind the bow, so the camera can see the player.
	for i in range(4):
		_box(Vector3(-2.73,.156,5.14+i*.15),Vector3(2.15,.055,.139),wood_light if i%3==0 else wood)
	for x in [-3.43,-2.03]:
		_box(Vector3(x,.156,4.84),Vector3(.75,.055,.79),wood)
	for x in [-3.72,-1.74]:
		for z in [4.70,5.49]:
			_box(Vector3(x,.065,z),Vector3(.09,.19,.09),wood,true)
	# Fine grain lines and nail heads make the nearby step tactile.
	for i in range(20):
		var x=-3.65+float(i)*.095
		_box(Vector3(x,.186,5.10),Vector3(.002,.001,.95),wood_light)
	for x in [-3.63,-1.82]:
		for z in [4.60,5.58]:_box(Vector3(x,.187,z),Vector3(.017,.003,.017),brass)
	# A recognizable shuttered window behind the sunny destination.
	_window(Vector3(2.05,1.3,-5.87),0.0,1.7,1.2)
	# Side window gives the chair passage a reflected architectural landmark.
	_window(Vector3(3.93,1.10,2.8),-PI*.5,1.55,1.08)
	# Terracotta coping along rear wall; individual caps with seams.
	for i in range(28):
		_box(Vector3(-3.94+i*.29,2.50,-6.03),Vector3(.278,.07,.32),_material(Color("965a40"),.75))

func _window(pos: Vector3,yaw: float,width: float,height: float) -> void:
	var pivot=Node3D.new()
	add_child(pivot)
	pivot.position=pos
	pivot.rotation.y=yaw
	var glass=_material(Color("243e36"),.21)
	var p=MeshInstance3D.new()
	var b=BoxMesh.new()
	b.size=Vector3(width,height,.035)
	p.mesh=b
	p.material_override=glass
	pivot.add_child(p)
	# Global helper with local-to-window transform keeps geometry explicit.
	for dx in [-width*.5,width*.5]: _window_piece(pivot,Vector3(dx,0,.027),Vector3(.07,height+.15,.07),wood)
	for dy in [-height*.5,height*.5]: _window_piece(pivot,Vector3(0,dy,.027),Vector3(width+.16,.07,.09),wood)
	_window_piece(pivot,Vector3(0,0,.04),Vector3(.04,height,.06),wood_light)
	for dx in [-width*.25,width*.25]:
		for i in range(11):
			var slat=_window_piece(pivot,Vector3(dx,-height*.45+i*height*.09,.075),Vector3(width*.45,.057,.035),wood_light if i%4==0 else wood)
			slat.rotation.x=-.22
	_window_piece(pivot,Vector3(0,-height*.5-.06,.09),Vector3(width+.25,.08,.22),wood_light)

func _window_piece(pivot: Node3D,pos: Vector3,size: Vector3,mat: Material) -> MeshInstance3D:
	var item=MeshInstance3D.new()
	var box=BoxMesh.new()
	box.size=size
	item.mesh=box
	item.material_override=mat
	item.set_meta("batch_static_box",true)
	pivot.add_child(item)
	item.position=pos
	return item

func _batch_static_boxes() -> void:
	# Step boards, window slats and masonry share immutable primitive geometry.
	# Batch by material while all simple gameplay colliders remain independent.
	var groups: Dictionary = {}
	_collect_static_boxes(self,groups)
	var unit_box=BoxMesh.new()
	unit_box.size=Vector3.ONE
	for group in groups.values():
		var items: Array = group["items"]
		var instances=MultiMesh.new()
		instances.transform_format=MultiMesh.TRANSFORM_3D
		instances.mesh=unit_box
		instances.instance_count=items.size()
		for i in range(items.size()):
			var item: MeshInstance3D = items[i]
			var relative=global_transform.affine_inverse()*item.global_transform
			var size: Vector3 = item.mesh.size
			relative.basis=relative.basis*Basis.from_scale(size)
			instances.set_instance_transform(i,relative)
			item.visible=false
			item.queue_free()
		var batch=MultiMeshInstance3D.new()
		batch.name="StaticBatch"
		batch.multimesh=instances
		batch.material_override=group["material"]
		add_child(batch)

func _collect_static_boxes(node: Node,groups: Dictionary) -> void:
	for child in node.get_children():
		if child is MeshInstance3D and child.has_meta("batch_static_box"):
			var key=child.material_override.get_instance_id()
			if not groups.has(key): groups[key]={"material":child.material_override,"items":[]}
			groups[key]["items"].append(child)
		_collect_static_boxes(child,groups)

func _pot(pos: Vector3,r: float,kind: int,plant: PackedScene=FERN) -> void:
	var p=POTS[kind%3].instantiate() as Node3D
	p.position=pos
	p.scale=Vector3.ONE*(r/.5)
	add_child(p)
	_weather_clay(p)
	_round_collision(pos,r+.025,1.0)
	var heights=[.72,.90,.46]
	var foliage=plant.instantiate() as Node3D
	foliage.position=pos+Vector3(0,heights[kind%3]*(r/.5)-.09,0)
	foliage.scale=Vector3.ONE*(r/.5)
	foliage.rotation.y=pos.x*2.4+pos.z
	add_child(foliage)
	plant_pivots.append(foliage)

func _weather_clay(node: Node) -> void:
	if node is MeshInstance3D:
		for i in range(node.mesh.get_surface_count()):
			var original=node.mesh.surface_get_material(i)
			if original is StandardMaterial3D and original.albedo_color.r > .25:
				var mat=ShaderMaterial.new()
				mat.shader=preload("res://assets/materials/clay.gdshader")
				mat.set_shader_parameter("clay_color",original.albedo_color)
				node.set_surface_override_material(i,mat)
	for child in node.get_children(): _weather_clay(child)

func _planters() -> void:
	# Main obstacles follow the reference: broad channels remain freely traversable.
	_pot(Vector3(-.10,0,4.65),.58,0)
	_pot(Vector3(.10,0,2.65),.48,2,POTHOS)
	_pot(Vector3(-.30,0,1.05),.65,0)
	_pot(Vector3(-.55,0,-1.35),.55,1)
	_pot(Vector3(-2.95,0,-.45),.45,0,POTHOS)
	_pot(Vector3(1.15,0,-3.05),.40,2,POTHOS)
	_pot(Vector3(-2.0,0,-4.6),.65,1,HIBISCUS)
	# Smaller edge pots provide scale without narrowing the intended passages.
	_pot(Vector3(-3.35,0,2.6),.30,1,POTHOS)
	_pot(Vector3(3.40,0,-.6),.32,0,POTHOS)
	_pot(Vector3(-3.50,0,-3.5),.24,2)
	_pot(Vector3(3.25,0,-5.25),.25,0,HIBISCUS)
	_pot(Vector3(.05,0,-5.35),.23,2,POTHOS)
	# Trailing foliage above the north wall catches sun and frames the final pool.
	for i in range(5):
		var hanging=POTHOS.instantiate() as Node3D
		hanging.position=Vector3(-3.7+i*1.7,2.1,-5.8)
		hanging.rotation.z=PI
		hanging.scale=Vector3.ONE*.65
		add_child(hanging)

func _chair_and_chain() -> void:
	var chair=CHAIR.instantiate() as Node3D
	chair.position=Vector3(3.02,0,2.88)
	chair.rotation.y=.1
	chair.scale=Vector3.ONE*1.25
	add_child(chair)
	for x in [-.388,.388]:
		for z in [-.375,.375]:_round_collision(chair.position+Vector3(x,0,z),.04,.61)
	var chain=CHAIN.instantiate() as Node3D
	chain.position=Vector3(-3.6,0,-1.55)
	add_child(chain)
	# Downpipe and roof gutter are separate from navigation collision.
	_box(Vector3(-3.8,1.96,-1.55),Vector3(.38,.09,.11),brass)
	_box(Vector3(-3.93,1.17,-1.55),Vector3(.08,1.6,.08),brass)

func _small_details() -> void:
	# A few chipped pavers just above water soften the exact courtyard perimeter.
	for i in range(12):
		var z=-5.45+i*.87
		var slab=_box(Vector3(-3.71,.01,z),Vector3(.28,.07,.36),concrete)
		slab.rotation.y=sin(i*7.2)*.08
	# Warm sunlit sill and simple brick reveal at destination.
	for i in range(9):
		_box(Vector3(.85+i*.29,.035,-5.68),Vector3(.278,.1,.26),_material(Color("9a6046"),.63))
	# Original ceramic saucers; low-profile visual detail with safe simplified contact.
	for p in [Vector3(-3.46,.004,3.7),Vector3(3.49,.004,-4.4)]:
		var dish=MeshInstance3D.new()
		var mesh=CylinderMesh.new()
		mesh.top_radius=.19
		mesh.bottom_radius=.17
		mesh.height=.025
		dish.mesh=mesh
		dish.material_override=_material(Color("a9674a"),.45)
		dish.position=p
		add_child(dish)
		_round_collision(p,.19,.06)

func _process(delta: float) -> void:
	_time+=delta
	for i in range(plant_pivots.size()):
		plant_pivots[i].rotation.z=sin(_time*.45+i*2.2)*.009
