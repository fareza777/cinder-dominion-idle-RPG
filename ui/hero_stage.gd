extends Control

const U = preload("res://ui/style.gd")
const SLOTS = ["head","weapon","hands","body","shield","feet"]
const ANCHORS = [Vector2(.50,.20),Vector2(.38,.56),Vector2(.36,.62),Vector2(.52,.39),Vector2(.65,.55),Vector2(.54,.84)]
var app
var equipment
var portrait: Texture2D
var buttons: Array[Button] = []
var icons: Array[TextureRect] = []
var marks: Array[Label] = []
var signature = ""
var elapsed = 0.0
var clock = 0.0

func _ready():
	name = "HeroEquipment"
	custom_minimum_size.y = 488
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_PASS
	portrait = RealmCharacters.portrait(app.model)
	for slot in SLOTS:
		var b = U.button("",func(): equipment.open_slot(slot))
		b.name = "Slot_"+slot
		b.custom_minimum_size = Vector2(78,96)
		b.tooltip_text = equipment.NAMES[slot]+" · choose equipment"
		add_child(b)
		buttons.append(b)
		var words = U.column(2)
		words.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(words)
		words.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		words.offset_left = 6
		words.offset_right = -6
		words.offset_top = 6
		words.offset_bottom = -6
		var label = U.label(equipment.NAMES[slot],12,U.GOLD)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		words.add_child(label)
		var icon = U.icon("",40)
		words.add_child(icon)
		icons.append(icon)
		var mark = U.label("Empty",10,U.MUTED)
		mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		words.add_child(mark)
		marks.append(mark)
	_process(0)

func _process(delta):
	if not is_visible_in_tree(): return
	var next = JSON.stringify(app.model.s.equipped)+str(app.model.s.gear.size())
	if signature!=next:
		signature = next
		for i in range(SLOTS.size()):
			var g = app.model.gear(str(app.model.s.equipped.get(SLOTS[i],"")))
			var color = U.LINE if g.is_empty() else U.QUALITY[int(g.q)]
			buttons[i].add_theme_stylebox_override("normal",U.box(Color("111a20"),color,6,6))
			marks[i].text = "Empty" if g.is_empty() else "Equipped"
			marks[i].modulate = U.MUTED if g.is_empty() else U.GOLD
			if not g.is_empty():
				var image = U.icon(g.id,40)
				icons[i].texture = image.texture
				icons[i].modulate = Color.WHITE
				image.free()
				buttons[i].tooltip_text = equipment.NAMES[SLOTS[i]]+" · "+app.model.name_of(g.id)
			else:
				for id in app.model.data.items:
					if app.model.data.items[id].get("slot","")==SLOTS[i]:
						var image = U.icon(id,40)
						icons[i].texture = image.texture
						icons[i].modulate = Color(.65,.65,.65,.28)
						image.free()
						break
	var width = clampf(size.x*.21,78,94)
	var height = 92+maxf(0,U.scale-1)*36
	for i in range(buttons.size()):
		buttons[i].position = Vector2(8 if i<3 else size.x-width-8,26+(i%3)*145)
		buttons[i].size = Vector2(width,height)
	if app.model.s.settings.motion and not app.paused: elapsed += delta
	clock += delta
	if clock>=(1.0/15 if app.model.s.settings.battery else 1.0/30):
		clock = 0
		if get_global_rect().intersects(get_viewport_rect()): queue_redraw()

func _draw():
	if portrait==null: return
	draw_rect(Rect2(Vector2.ZERO,size),Color("0b1116"))
	var width = size.y*portrait.get_width()/portrait.get_height()
	draw_texture_rect(portrait,Rect2((size.x-width)/2,0,width,size.y),false)
	for i in range(buttons.size()):
		var from = buttons[i].position+Vector2(buttons[i].size.x if i<3 else 0,buttons[i].size.y*.5)
		var to = Vector2(size.x*ANCHORS[i].x,size.y*ANCHORS[i].y)
		var elbow = Vector2(lerpf(from.x,to.x,.5),from.y)
		draw_polyline(PackedVector2Array([from,elbow,to]),Color(U.GOLD,.55),1,true)
		draw_circle(to,2,U.GOLD)
	if app.model.s.settings.motion:
		for i in range(12):
			var p = fposmod(elapsed*.07+i*.137,1)
			draw_circle(Vector2(size.x*(.20+fposmod(i*.173,.6)),size.y*(1-p)),1,Color(U.GOLD,sin(p*PI)*.35))
	draw_rect(Rect2(Vector2.ZERO,size),U.GOLD.darkened(.55),false,1)
