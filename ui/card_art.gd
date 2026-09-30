extends Control

const U=preload("res://ui/style.gd")
var card_id=""
func _ready():
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
func _draw():
	if card_id=="" or size.x<12 or size.y<12:return
	var d=RealmCards.definitions()[card_id]
	var color=accent(d.rarity)
	var h=size.y-4;var w=minf(size.x-4,h*.74)
	var rect=Rect2((size.x-w)/2,2,w,h)
	draw_style_box(U.frame(Color("10171b"),color.darkened(.35),"panel",0),rect)
	var inset=maxf(4,w*.06)
	var inner=rect.grow(-inset)
	var e=U.enemy_catalog[d.enemy]
	var scenery=load("res://ui/world.gd").art(int(e.get("realm",0)))
	draw_texture_rect(scenery,inner,false,Color(1,1,1,.28))
	draw_rect(inner,Color(U.INK,.45))
	draw_rect(inner,Color(color,.36),false,1,true)
	for corner in [inner.position,Vector2(inner.end.x,inner.position.y),inner.end,Vector2(inner.position.x,inner.end.y)]:
		var sx=1 if corner.x<rect.get_center().x else -1
		var sy=1 if corner.y<rect.get_center().y else -1
		var arm=minf(17,w*.13)
		draw_polyline(PackedVector2Array([corner+Vector2(0,sy*arm),corner,corner+Vector2(sx*arm,0)]),color,1.5,true)
		var center=corner+Vector2(sx*4,sy*4)
		draw_colored_polygon(PackedVector2Array([center+Vector2(0,-2),center+Vector2(2,0),center+Vector2(0,2),center+Vector2(-2,0)]),color)
	var portrait=inner.grow(-maxf(3,w*.025))
	var label_height=7
	portrait.position.y+=label_height;portrait.size.y-=label_height+12
	if e.has("realm"):
		var actor=load("res://ui/enemy_actor.gd")
		var bounds=actor.measured(d.enemy)[0]
		var extent=Vector2(bounds.rect[2],bounds.rect[3])
		var factor=minf(portrait.size.x/extent.x,portrait.size.y/extent.y)
		portrait.position.y-=(portrait.size.y-extent.y*factor)/2
		load("res://ui/sprite_bounds.gd").draw(self,actor.frames(d.enemy)[0].atlas,bounds,"enemy_"+d.enemy+"0",portrait,extent,Color.WHITE)
	else:
		var texture=U.enemy_texture(e)
		var fit=texture.get_size()*minf(portrait.size.x/texture.get_width(),portrait.size.y/texture.get_height())
		draw_texture_rect(texture,Rect2(portrait.get_center()-fit/2,fit),false)
	var cx=rect.get_center().x;var y=inner.end.y-4
	draw_line(Vector2(cx-w*.20,y),Vector2(cx-7,y),Color(color,.6),1,true)
	draw_line(Vector2(cx+7,y),Vector2(cx+w*.20,y),Color(color,.6),1,true)
	draw_colored_polygon(PackedVector2Array([Vector2(cx,y-4),Vector2(cx+3,y),Vector2(cx,y+4),Vector2(cx-3,y)]),color)

static func accent(rarity: String) -> Color:
	return {"Rare":U.QUALITY[3],"Epic":U.QUALITY[4],"Legendary":U.QUALITY[5],"Mythic":U.QUALITY[6]}.get(rarity,U.GOLD)
