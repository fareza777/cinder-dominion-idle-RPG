extends Control
const U = preload("res://ui/style.gd")
var entries: Array = []
var selected = 0
var changed: Callable
var buttons: Array[Button] = []
var points: Array[Vector2] = []
var backdrop: Texture2D

func _ready():
	custom_minimum_size.y = 260 if entries.size()>3 else 112
	mouse_filter = Control.MOUSE_FILTER_PASS
	for i in range(entries.size()):
		var entry = entries[i]
		var b = U.button(str(i+1),func(): changed.call(i))
		b.name = "RouteNode_"+str(i)
		b.text = str(i+1)
		b.disabled = entry.get("locked",false)
		b.tooltip_text = entry.title
		b.custom_minimum_size = Vector2(48,48)
		var style = StyleBoxFlat.new()
		style.bg_color = Color("24313a") if i==selected else Color("101b23")
		style.border_color = U.GOLD if i==selected or entry.get("done",false) else U.LINE
		style.set_border_width_all(2 if i==selected else 1)
		style.set_corner_radius_all(24)
		for state in ["normal","disabled","hover","pressed","focus"]: b.add_theme_stylebox_override(state,style)
		add_child(b)
		buttons.append(b)
	resized.connect(arrange)
	arrange()

func arrange():
	points.clear()
	for i in range(buttons.size()):
		var p: Vector2
		if entries.size()<=3: p=Vector2(size.x*(i+.5)/entries.size(),38)
		else: p=Vector2(size.x*([.22,.72,.62,.27,.40,.79][i]),35+i*38)
		points.append(p)
		buttons[i].position=p-Vector2(24,24)
		buttons[i].size=Vector2(48,48)
	queue_redraw()

func _draw():
	if backdrop!=null:
		draw_texture_rect(backdrop,Rect2(Vector2.ZERO,size),false,Color(.38,.43,.48))
	for i in range(1,points.size()):
		draw_line(points[i-1],points[i],Color(U.GOLD,.65) if entries[i-1].get("done",false) else Color(U.MUTED,.35),2,true)
	if entries.size()<=3:
		for i in range(points.size()):
			draw_string(U.body_font,Vector2(points[i].x-40,89),str(entries[i].get("rank","")),HORIZONTAL_ALIGNMENT_CENTER,80,int(14*U.scale),U.GOLD)
