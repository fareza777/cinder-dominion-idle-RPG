extends RefCounted

# Measured alpha bounds + UV meshes exclude neighboring atlas figures.
static var meshes={}
static func draw(canvas: CanvasItem,texture: Texture2D,frame: Dictionary,key: String,area: Rect2,extent: Vector2,tint: Color):
 var source=frame.rect
 var factor=minf(area.size.x/extent.x,area.size.y/extent.y)
 var position=Vector2(area.get_center().x-float(source[2])*factor/2,area.end.y-float(source[3])*factor)
 if not meshes.has(key):
  var vertices=PackedVector3Array();var uv=PackedVector2Array();var indices=PackedInt32Array()
  for p in frame.pieces:
   var base=vertices.size()
   for point in [Vector2(p[0],p[1]),Vector2(p[0]+p[2],p[1]),Vector2(p[0]+p[2],p[1]+p[3]),Vector2(p[0],p[1]+p[3])]:
    vertices.append(Vector3(point.x-source[0],point.y-source[1],0))
    uv.append(point/texture.get_size())
   for offset in [0,1,2,0,2,3]:indices.append(base+offset)
  var arrays=[];arrays.resize(Mesh.ARRAY_MAX)
  arrays[Mesh.ARRAY_VERTEX]=vertices;arrays[Mesh.ARRAY_TEX_UV]=uv;arrays[Mesh.ARRAY_INDEX]=indices
  var mesh=ArrayMesh.new();mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays);meshes[key]=mesh
 canvas.draw_mesh(meshes[key],texture,Transform2D(Vector2(factor,0),Vector2(0,factor),position),tint)

static func extent(frames: Array) -> Vector2:
 var result=Vector2.ONE
 for frame in frames:result=result.max(Vector2(frame.rect[2],frame.rect[3]))
 return result
