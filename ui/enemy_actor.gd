extends RefCounted
const U=preload("res://ui/style.gd")
static var roster={}
static var cached={}
static var bounds={}
static func measured(id: String) -> Array:
 if bounds.is_empty():bounds=JSON.parse_string(FileAccess.get_file_as_string("res://data/battle_frame_bounds.json"))
 var d=definition(id)
 return bounds[str(int(d.sheet))].slice(int(d.tile),int(d.tile)+2)
static func definition(id: String) -> Dictionary:
 if roster.is_empty():roster=JSON.parse_string(FileAccess.get_file_as_string("res://data/battle_actors.json"))
 return roster.get(id,{})
static func frames(id: String) -> Array:
 if cached.has(id):return cached[id]
 var d=definition(id)
 if d.is_empty():return []
 var result=[];var sheet=U.asset(d.get("path","res://assets/art/enemy-actors-%d-0.51.png" % int(d.sheet)))
 for pose in range(2):
  var index=int(d.tile)+pose;var t=AtlasTexture.new();t.atlas=sheet;t.filter_clip=true
  var b=measured(id)[pose].rect
  t.region=Rect2(b[0],b[1],b[2],b[3])
  result.append(t)
 cached[id]=result
 return result
static func draw(canvas: CanvasItem,id: String,pose: int,area: Rect2,tint: Color = Color.WHITE):
 var pair=frames(id)
 if pair.is_empty():return
 var b=measured(id);var renderer=preload("res://ui/sprite_bounds.gd")
 renderer.draw(canvas,pair[0].atlas,b[clampi(pose,0,1)],"enemy_"+id+str(pose),area,renderer.extent(b),tint)
