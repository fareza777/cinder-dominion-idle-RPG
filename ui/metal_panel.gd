extends PanelContainer

var item_accent = Color(0,0,0,0)

func _ready():
	mouse_filter = Control.MOUSE_FILTER_PASS
	resized.connect(queue_redraw)
	queue_redraw()

func _draw():
	# The shared style draws the material. Item cards add only their quiet tint.
	if size.x<24 or size.y<24: return
	if item_accent.a>0:
		var center = Vector2(size.x*.5,50)
		for i in range(12,0,-1):
			draw_circle(center,minf(size.x*.35,48)*i/12.0,Color(item_accent,.012))
