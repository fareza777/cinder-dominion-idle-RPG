extends StyleBox

var base: StyleBox
var inset = 8.0
var metal = preload("res://assets/art/blackened-iron-0.48.png")

func _draw(canvas: RID, rect: Rect2):
	if base==null: return
	base.draw(canvas,rect)
	var inner = rect.grow(-inset)
	if inner.size.x>0 and inner.size.y>0:
		RenderingServer.canvas_item_add_texture_rect(canvas,inner,metal.get_rid(),false,Color(1,1,1,.38))
