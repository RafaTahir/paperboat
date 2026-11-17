"""Original AFTER THE RAIN mesh kit. Run with Blender --background --python this-file.
Metres; Blender +Y bow exports to Godot -Z; Z-up converts to Y-up.
No downloaded meshes or textures. All polygons/materials authored here.
"""
import bpy, math, random, os
from mathutils import Vector
random.seed(71219)
ROOT=os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT=os.path.join(ROOT,'assets','models')
os.makedirs(OUT,exist_ok=True)

def material(name,color,rough=.6,metal=0):
    m=bpy.data.materials.new(name); m.diffuse_color=(*color,1);m.use_nodes=True
    b=m.node_tree.nodes.get('Principled BSDF');b.inputs['Base Color'].default_value=(*color,1);b.inputs['Roughness'].default_value=rough;b.inputs['Metallic'].default_value=metal
    return m
paper=material('Ivory handmade paper',(.86,.825,.70),.82)
fold=material('Fold shade',(.64,.65,.58),.86)
blue=material('Blue pencil',(.12,.27,.38),.95)
clay=material('Weathered terracotta',(.42,.17,.085),.62)
rim=material('Warm worn clay lip',(.55,.255,.13),.6)
soil=material('Damp earth',(.065,.060,.035),.95)
leaf=material('Fern jade',(.045,.125,.060),.79)
leaflight=material('Fern sunward',(.095,.185,.075),.78)
stem=material('Leaf stem',(.08,.135,.038),.86)
rattan=material('Honey rattan',(.42,.265,.11),.62)
dark=material('Woven rattan shade',(.24,.14,.065),.73)
metal=material('Weathered copper',(.23,.20,.12),.4,.68)
pink=material('Hibiscus vermilion',(.65,.065,.08),.66)

def clear():
    bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)

def mesh(name,verts,faces,mat):
    me=bpy.data.meshes.new(name);me.from_pydata(verts,[],faces);me.update()
    o=bpy.data.objects.new(name,me);bpy.context.collection.objects.link(o);o.data.materials.append(mat)
    return o

def cylinder_between(a,b,r,mat,n=8):
    a,b=Vector(a),Vector(b);d=b-a
    bpy.ops.mesh.primitive_cylinder_add(vertices=n,radius=r,depth=d.length,location=(a+b)/2)
    o=bpy.context.object;o.rotation_euler=d.to_track_quat('Z','Y').to_euler();o.data.materials.append(mat)
    return o

def path(points,r,mat):
    # Polygonal curves keep the GLB self-contained and deliberately modest.
    for a,b in zip(points,points[1:]):cylinder_between(a,b,r,mat)

def lathe(name,profile,mat,segments=40):
    verts=[(r*math.cos(j*2*math.pi/segments),r*math.sin(j*2*math.pi/segments),z) for r,z in profile for j in range(segments)]
    faces=[]
    for k in range(len(profile)-1):
      for j in range(segments):
        a=k*segments+j;b=k*segments+(j+1)%segments;faces.append((a,b,b+segments,a+segments))
    o=mesh(name,verts,faces,mat)
    for p in o.data.polygons:p.use_smooth=True
    return o

def join_materials():
    # Merge all meshes sharing a material into one draw surface per asset.
    by={}
    for o in list(bpy.context.scene.objects):
      if o.type=='MESH':by.setdefault(o.data.materials[0].name if o.data.materials else '',[]).append(o)
    for objs in by.values():
      bpy.ops.object.select_all(action='DESELECT')
      for o in objs:o.select_set(True)
      bpy.context.view_layer.objects.active=objs[0];bpy.ops.object.join()

def save(name):
    join_materials()
    bpy.ops.object.select_all(action='SELECT');bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    bpy.ops.wm.save_as_mainfile(filepath=os.path.join(ROOT,'art-source',name+'.blend'))
    # Runtime props have no internal animation. A single mesh node retains one
    # surface per material and avoids needless per-object scene traversal.
    # Apply each mesh's modifiers before joining so paper thickness survives.
    for obj in list(bpy.context.scene.objects):
      if obj.type!='MESH':continue
      bpy.context.view_layer.objects.active=obj
      for modifier in list(obj.modifiers):bpy.ops.object.modifier_apply(modifier=modifier.name)
    bpy.ops.object.select_all(action='DESELECT')
    objects=[o for o in bpy.context.scene.objects if o.type=='MESH']
    for obj in objects:obj.select_set(True)
    bpy.context.view_layer.objects.active=objects[0]
    if len(objects)>1:bpy.ops.object.join()
    bpy.context.object.name=name
    bpy.ops.object.transform_apply(location=True,rotation=True,scale=True)
    bpy.ops.export_scene.gltf(filepath=os.path.join(OUT,name+'.glb'),export_format='GLB',export_yup=True,export_apply=True,export_materials='EXPORT',export_cameras=False,export_lights=False)

clear()
# The real origami form: pinched diamond hull, inner troughs and raised folded ridge.
verts=[(0,.09,.025),(.044,0,.029),(0,-.09,.027),(-.044,0,.029),(0,.055,-.007),(0,-.055,-.007),(0,.052,.025),(0,-.052,.025),(0,.0,.078),(.014,0,.017),(-.014,0,.017)]
faces=[(0,4,1),(1,4,5,2),(2,5,3),(3,5,4,0),(0,1,6),(1,2,7),(2,3,7),(3,0,6),(6,9,8),(9,7,8),(7,10,8),(10,6,8),(6,1,9),(9,1,7),(7,3,10),(10,3,6)]
o=mesh('Hand folded paper boat',verts,faces,paper)
o.data.materials.append(fold)
for i in [8,11,14]:o.data.polygons[i].material_index=1
sol=o.modifiers.new('Paper thickness','SOLIDIFY');sol.thickness=.0003
# Slightly uneven blue stars lie on the outward hull plane.
def hull_point(t,z,side):
    # Outer hull side at y=t has x proportional to fold height.
    return (side*(.044*(1-abs(t)/.09)*(z+.007)/.036+.00024),t,z)
for side in [-1,1]:
  for cy,cz,size in [(-.008,.018,.008),(.032,.018,.0048),(-.038,.017,.0035)]:
    points=[]
    for k in [0,2,4,1,3,0]:
      a=math.pi*.5+k*math.tau/5
      points.append(hull_point(cy+math.cos(a)*size,cz+math.sin(a)*size*.66,side))
    path(points,.00022,blue)
save('paper_boat')

for idx,(radius,height,bulge) in enumerate([(.5,.72,.07),(.5,.9,.14),(.5,.46,.02)]):
  clear()
  profile=[(.31,0),(.32,.035),(.37,.12),(.43+bulge,height*.45),(.49,height*.8),(.50,height-.06),(.505,height-.05),(.535,height-.04),(.535,height+.0),(.49,height+.015),(.465,height-.025),(.465,height-.08),(.42,height-.15)]
  lathe('Thrown clay body',profile,clay)
  lathe('Rolled clay rim',[(.497,height-.065),(.537,height-.055),(.545,height-.02),(.535,height+.009),(.50,height+.022),(.476,height+.008)],rim)
  lathe('Damp earth',[(0,height-.11),(.46,height-.11)],soil)
  # Thin ceramic bands and fine handmade wear, original geometry.
  for z in [height*.18,height*.71]:
    rr=.31+(.5-.31)*min(1,z/height*1.5)
    lathe('Faint thrown band',[(rr+.003,z),(rr+.003,z+.009)],rim,40)
  save('clay_pot_'+str(idx+1))

clear()
# Fern fronds as gently curved midribs carrying tapered leaflet pairs.
for i in range(13):
  a=i*math.tau/13+random.uniform(-.12,.12);L=random.uniform(.48,.80)
  pts=[]
  for j in range(17):
    t=j/16;rr=L*t;z=.11+.47*math.sin(t*math.pi*.75)-.16*t*t
    pts.append(Vector((math.cos(a)*rr,math.sin(a)*rr,z)))
  path(pts,.003,stem)
  for j in range(2,16):
    t=j/16;w=.115*math.sin(t*math.pi)*random.uniform(.8,1.2)
    for side in [-1,1]:
      p=pts[j];cross=Vector((-math.sin(a)*side,math.cos(a)*side,.18));forward=Vector((math.cos(a),math.sin(a),-.18))
      tip=p+cross*w+forward*w*.5
      mid=p+cross*w*.45+forward*w*.1+Vector((0,0,.022))
      vv=[p,mid+forward*.018,tip,mid-forward*.018]
      mesh('Fern leaflet',vv,[(0,1,2),(0,2,3)],leaflight if (i+j)%4==0 else leaf)
save('fern')

clear()
# Heart shaped tropical leaves, folded at the midrib; solid double-sided surfaces.
for i in range(15):
  a=i*2.4;L=random.uniform(.24,.53);base=Vector((0,0,random.uniform(0,.13)))
  end=Vector((math.cos(a)*L,math.sin(a)*L,random.uniform(.25,.7)))
  path([base,end],.007,stem)
  direction=Vector((math.cos(a),math.sin(a),-.3));side=Vector((-math.sin(a),math.cos(a),0))
  tip=end+direction*.23;bottom=end-direction*.05
  vv=[bottom,end+side*.12+direction*.02,end+side*.10+direction*.16,tip,end-side*.10+direction*.16,end-side*.12+direction*.02,end+Vector((0,0,.045))]
  mesh('Pothos leaf',vv,[(6,j,(j+1)%6) for j in range(6)],leaflight if i%3==0 else leaf)
  path([bottom,end+Vector((0,0,.046)),tip],.0017,stem)
save('pothos')

clear()
# Rattan chair at human furniture scale. Passage between four legs is open.
for x in [-.31,.31]:
  for y in [-.30,.30]:cylinder_between((x,y,0),(x*.9,y*.92,.48),.028,rattan,12)
for x in [-.3,.3]:
  path([(x,-.28,.48),(x,.30,.48),(x*.93,.40,.82),(x*.75,.36,1.03)],.029,rattan)
  path([(x,-.30,.48),(x,-.31,.68),(x*.95,.16,.70),(x*.95,.34,.77)],.025,rattan)
for y in [-.30,.30]:cylinder_between((-.31,y,.48),(.31,y,.48),.027,rattan,12)
# Curved cane back perimeter and woven strips, correct readable silhouette.
back=[]
for j in range(25):
  a=math.pi*j/24;back.append((-.29*math.cos(a),.35+.08*math.sin(a),.68+.38*math.sin(a)))
path(back,.025,rattan)
for x in [j*.031 for j in range(-9,10)]:
  top=.68+.36*math.sqrt(max(0,1-(x/.29)**2))
  cylinder_between((x,.365,.66),(x,.39,top),.005,rattan,6)
for z in [j*.028+.67 for j in range(12)]:
  width=.29*math.sqrt(max(0,1-((z-.68)/.38)**2))
  cylinder_between((-width,.395,z),(width,.395,z),.0045,dark,6)
for j in range(-9,10):
  x=j*.03;cylinder_between((x,-.28,.477),(x,.3,.477),.006,rattan,6)
  y=j*.03;cylinder_between((-.29,y,.484),(.29,y,.484),.0045,dark,6)
save('rattan_chair')

clear()
# Rain chain of linked weathered copper cups.
for i in range(16):
  z=i*.12+.08
  lathe('Rain cup',[(.014,z),(.037,z+.055),(.039,z+.061),(.036,z+.064),(.013,z+.013)],metal,12)
  cylinder_between((0,0,z),(0,0,z+.14),.003,metal,6)
save('rain_chain')

clear()
# Small hibiscus bush: branching stems, heart leaves and five-petal flowers.
for i in range(9):
  a=i*2.4;end=Vector((math.cos(a)*.4,math.sin(a)*.4,.5+random.random()*.5))
  cylinder_between((0,0,0),end,.014,stem)
  for k in range(4):
    p=end*(.45+k*.14);aa=a+k*2;side=Vector((math.cos(aa),math.sin(aa),.1))*.15
    mesh('Hibiscus leaf',[p,p+side*.4+Vector((0,0,.05)),p+side,p+side*.4-Vector((0,0,.03))],[(0,1,2),(0,2,3)],leaf)
  if i%2==0:
    for k in range(5):
      aa=k*math.tau/5;dir=Vector((math.cos(aa),math.sin(aa),.12));cross=Vector((-math.sin(aa),math.cos(aa),0))
      mesh('Hibiscus petal',[end,end+dir*.10+cross*.04,end+dir*.14,end+dir*.10-cross*.04],[(0,1,2),(0,2,3)],pink)
    cylinder_between(end,end+Vector((0,0,.09)),.004,rattan,6)
save('hibiscus')
print('AFTER THE RAIN original asset kit complete')
