extends RefCounted
const U=preload("res://ui/style.gd")
static var roster={}
static var cached={}
static func definition(id: String) -> Dictionary:
 if roster.is_empty():roster=JSON.parse_string(FileAccess.get_file_as_string("res://data/battle_actors.json"))
 return roster.get(id,{})
static func frames(id: String) -> Array:
 if cached.has(id):return cached[id]
 var d=definition(id)
 if d.is_empty():return []
 var result=[];var sheet=U.asset("res://assets/art/enemy-actors-%d-0.51.png" % int(d.sheet))
 for pose in range(2):
  var index=int(d.tile)+pose;var t=AtlasTexture.new();t.atlas=sheet;t.filter_clip=true
  t.region=Rect2((index%4)*sheet.get_width()/4.0,int(index/4)*sheet.get_height()/6.0,sheet.get_width()/4.0,sheet.get_height()/6.0)
  result.append(t)
 cached[id]=result
 return result
static func draw(canvas: CanvasItem,id: String,pose: int,area: Rect2,tint: Color = Color.WHITE):
 var pair=frames(id)
 if pair.is_empty():return
 canvas.draw_texture_rect(pair[clampi(pose,0,1)],area,false,tint)
