extends PanelContainer

var item_accent = Color(0,0,0,0)
var metal: Texture2D

func _ready():
	metal = load("res://assets/art/blackened-iron-0.48.png")
	mouse_filter = Control.MOUSE_FILTER_PASS
	resized.connect(queue_redraw)
	queue_redraw()

func _draw():
	if metal==null or size.x<24 or size.y<24: return
	# Keep the existing nine-slice ornament uncovered. Material stays behind text.
	var area = Rect2(Vector2(12,12),size-Vector2(24,24))
	draw_texture_rect(metal,area,false,Color(1,1,1,.38))
	if item_accent.a>0:
		var center = Vector2(size.x*.5,50)
		for i in range(12,0,-1):
			draw_circle(center,minf(size.x*.35,48)*i/12.0,Color(item_accent,.012))
