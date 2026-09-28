class_name RealmUI
extends RefCounted

const INK = Color("0d1318")
const PANEL = Color("171f25")
const LINE = Color("303b40")
const TEXT = Color("ede8dd")
const MUTED = Color("abb4b5")
const GOLD = Color("d9b477")
const GREEN = Color("9eb9a1")
const RED = Color("dd938d")
const QUALITY = [Color("929a9f"),Color("b9c0bd"),Color("9fbca2"),Color("91b5db"),Color("b69bce"),Color("dbb777"),Color("dd9184"),Color("ead9a5")]
static var body_font: Font
static var title_font: Font
static var portraits: Texture2D
static var items_texture: Texture2D
static var item_ids: Array = []
static var item_catalog = {}
static var scale = 1.0
static var motion = true

static func setup(data: Dictionary):
	body_font = load("res://assets/fonts/manrope-readable.ttf")
	title_font = load("res://assets/fonts/cormorantgaramond-readable.ttf")
	if ResourceLoader.exists("res://assets/art/portraits.png"): portraits = load("res://assets/art/portraits.png")
	if ResourceLoader.exists("res://assets/art/items.png"): items_texture = load("res://assets/art/items.png")
	item_ids = data.items.keys()
	item_catalog = data.items

static var frame_cache: Dictionary = {}

static func box(color: Color = PANEL, border: Color = LINE, radius: int = 10, padding: int = 14) -> StyleBox:
	# Tiny meters and transparent focus outlines keep crisp geometry.
	if radius<=3 or color.a<0.1:
		var flat = StyleBoxFlat.new()
		flat.bg_color = color
		flat.border_color = border
		flat.set_border_width_all(1 if color.a>0 else 2)
		flat.set_corner_radius_all(2)
		flat.set_content_margin_all(padding)
		return flat
	return frame(color,border,"panel" if radius>=10 else "button",padding)

static func frame(color: Color, border: Color, kind: String, padding: int) -> StyleBoxTexture:
	var key = color.to_html()+border.to_html()+kind
	if not frame_cache.has(key):
		var svg = FileAccess.get_file_as_string("res://assets/ui/"+kind+"-frame.svg.txt")
		var edge = border.lerp(Color("8c7050"),.12)
		var colors = {"BASE":color,"TOP":color.lightened(.055),"BOTTOM":color.darkened(.3),"EDGE":edge,"LIGHT":edge.lightened(.24),"DARK":edge.darkened(.45)}
		for token in colors: svg = svg.replace("{"+token+"}","#"+colors[token].to_html(false))
		var img = Image.new()
		if img.load_svg_from_string(svg)==OK: frame_cache[key] = ImageTexture.create_from_image(img)
	var style = StyleBoxTexture.new()
	style.texture = frame_cache.get(key)
	for side in [SIDE_LEFT,SIDE_TOP,SIDE_RIGHT,SIDE_BOTTOM]:
		style.set_texture_margin(side,24 if kind=="panel" else 12)
		style.set_content_margin(side,padding)
	return style

static func apply_theme(theme: Theme):
	for type in ["LineEdit","TextEdit"]:
		theme.set_stylebox("normal",type,frame(Color("10171b"),Color("75644e"),"input",12))
		theme.set_stylebox("focus",type,box(Color(0,0,0,0),GOLD,2,12))
		theme.set_stylebox("read_only",type,frame(INK,LINE,"input",12))
		theme.set_color("font_color",type,TEXT)
		theme.set_color("font_placeholder_color",type,MUTED)
		theme.set_color("caret_color",type,GOLD)
		theme.set_color("selection_color",type,Color("665138"))
	for type in ["OptionButton","Button"]:
		for state in ["normal","hover","pressed","disabled"]:
			var style = frame(Color("20282b") if state!="pressed" else INK,GOLD if state=="hover" else LINE,"button",12)
			if type=="OptionButton": style.content_margin_right = 34
			theme.set_stylebox(state,type,style)
		theme.set_stylebox("focus",type,box(Color(0,0,0,0),GOLD,2,2))
		for state in ["font_color","font_hover_color","font_pressed_color"]: theme.set_color(state,type,TEXT)
		theme.set_color("font_disabled_color",type,MUTED.darkened(.25))
	theme.set_stylebox("panel","PopupMenu",frame(INK,GOLD.darkened(.4),"panel",16))
	theme.set_stylebox("hover","PopupMenu",frame(PANEL,GOLD,"button",8))
	theme.set_color("font_color","PopupMenu",TEXT)
	theme.set_color("font_hover_color","PopupMenu",GOLD)
	theme.set_constant("v_separation","PopupMenu",14)
	for state in ["on","off"]:
		for suffix in ["","_disabled","_mirrored","_disabled_mirrored"]:
			theme.set_icon(("checked" if state=="on" else "unchecked")+suffix,"CheckButton",load("res://assets/ui/"+state+".svg"))
	theme.set_color("font_color","CheckButton",TEXT)
	theme.set_constant("h_separation","CheckButton",12)
	for type in ["HSlider","VSlider"]:
		theme.set_stylebox("slider",type,box(INK,Color("6a5943"),2,3))
		theme.set_stylebox("grabber_area",type,box(GOLD.darkened(.35),GOLD.darkened(.15),2,3))
		theme.set_stylebox("grabber_area_highlight",type,box(GOLD.darkened(.15),GOLD,2,3))
		for icon_name in ["grabber","grabber_highlight","grabber_disabled"]: theme.set_icon(icon_name,type,load("res://assets/ui/slider-gem.svg"))
	for type in ["VScrollBar","HScrollBar"]:
		theme.set_stylebox("scroll",type,box(INK,INK,2,3))
		for state in ["grabber","grabber_highlight","grabber_pressed"]: theme.set_stylebox(state,type,box(GOLD.darkened(.4),GOLD.darkened(.3),2,3))

static func label(text: String, size: int = 16, color: Color = TEXT, serif: bool = false) -> Label:
	var l = Label.new()
	l.text = RealmEconomy.text_value(text)
	l.add_theme_font_override("font",title_font if serif else body_font)
	l.add_theme_font_size_override("font_size",int(size*scale))
	l.add_theme_color_override("font_color",color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

static func para(text: String, size: int = 15, color: Color = MUTED) -> Label:
	var l = label(text,size,color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return l

static func row(separation: int = 10) -> HBoxContainer:
	var h = HBoxContainer.new()
	h.mouse_filter = Control.MOUSE_FILTER_PASS
	h.add_theme_constant_override("separation",separation)
	return h

static func column(separation: int = 10) -> VBoxContainer:
	var v = VBoxContainer.new()
	v.mouse_filter = Control.MOUSE_FILTER_PASS
	v.add_theme_constant_override("separation",separation)
	return v

static func spacer() -> Control:
	var c = Control.new()
	c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return c

static func card(parent: Node, padding: int = 16, border: Color = LINE) -> VBoxContainer:
	var p = PanelContainer.new()
	p.mouse_filter = Control.MOUSE_FILTER_PASS
	p.add_theme_stylebox_override("panel",box(PANEL,border,10,padding))
	parent.add_child(p)
	var v = column(10)
	p.add_child(v)
	return v

static func button(text: String, callback: Callable, primary: bool = false) -> Button:
	var b = Button.new()
	b.mouse_filter = Control.MOUSE_FILTER_PASS
	b.text = RealmEconomy.text_value(text)
	b.autowrap_mode = TextServer.AUTOWRAP_WORD
	b.custom_minimum_size.y = 48
	b.custom_minimum_size.x = clampf(body_font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,int(15*scale)).x+40,52,156)
	b.add_theme_font_override("font",body_font)
	b.add_theme_font_size_override("font_size",int(15*scale))
	b.add_theme_color_override("font_color",TEXT)
	b.add_theme_color_override("font_hover_color",GOLD)
	b.add_theme_color_override("font_pressed_color",GOLD)
	b.add_theme_color_override("font_disabled_color",Color("737e84"))
	b.add_theme_stylebox_override("normal",frame(Color("493620"),GOLD,"button",12) if primary else frame(Color("182126"),LINE,"action",12))
	b.add_theme_stylebox_override("hover",box(Color("60462a") if primary else Color("2c353a"),GOLD,6,12))
	b.add_theme_stylebox_override("pressed",box(Color("302519") if primary else Color("111a21"),GOLD,6,12))
	b.add_theme_stylebox_override("disabled",box(Color("182027"),LINE,6,10))
	b.add_theme_stylebox_override("focus",box(Color(0,0,0,0),GOLD,6,2))
	var reference = weakref(b)
	b.button_down.connect(func():
		var button = reference.get_ref()
		if is_instance_valid(button) and motion: button.modulate = Color(.88,.88,.88))
	b.button_up.connect(func():
		var button = reference.get_ref()
		if is_instance_valid(button): button.modulate = Color.WHITE)
	b.mouse_exited.connect(func():
		var button = reference.get_ref()
		if is_instance_valid(button): button.modulate = Color.WHITE)
	b.pressed.connect(callback)
	return b

static func progress(value: float, maximum: float, tint: Color = GOLD, height: int = 5) -> ProgressBar:
	var p = ProgressBar.new()
	p.max_value = maxf(1,maximum)
	p.value = value
	p.show_percentage = false
	p.custom_minimum_size.y = height
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_theme_stylebox_override("background",box(Color("273137"),Color("273137"),3,0))
	p.add_theme_stylebox_override("fill",box(tint,tint,3,0))
	return p

static func portrait(index: int, dimensions: Vector2) -> TextureRect:
	var t = TextureRect.new()
	t.custom_minimum_size = dimensions
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if portraits!=null:
		var a = AtlasTexture.new()
		a.atlas = portraits
		a.filter_clip = true
		var w = portraits.get_width()/4.0
		var h = portraits.get_height()/2.0
		a.region = Rect2((index%4)*w,int(index/4)*h,w,h)
		t.texture = a
	return t

static func enemy_texture(enemy: Dictionary) -> Texture2D:
	if enemy.has("frontier_tile"): return frontier_texture(int(enemy.frontier_tile))
	if enemy.has("secret_tile"): return atlas_tile("res://assets/art/superbosses-0.34.png",int(enemy.secret_tile),3,3)
	if enemy.has("art_tile"): return atlas_tile("res://assets/art/ascension-enemies-0.25.png",int(enemy.art_tile),3,3)
	if enemy.has("region") and ResourceLoader.exists("res://assets/art/expedition-guardians.png"):
		var texture = load("res://assets/art/expedition-guardians.png")
		var atlas = AtlasTexture.new()
		atlas.atlas = texture
		atlas.filter_clip = true
		var index = ["wilds","marsh","crown"].find(enemy.region)
		atlas.region = Rect2(index*texture.get_width()/3.0,0,texture.get_width()/3.0,texture.get_height())
		return atlas
	var atlas = AtlasTexture.new()
	atlas.atlas = portraits
	atlas.filter_clip = true
	var index = int(enemy.get("portrait",0))
	atlas.region = Rect2((index%4)*portraits.get_width()/4.0,int(index/4)*portraits.get_height()/2.0,portraits.get_width()/4.0,portraits.get_height()/2.0)
	return atlas

static func enemy_portrait(enemy: Dictionary, dimensions: Vector2) -> TextureRect:
	var t = TextureRect.new()
	t.custom_minimum_size = dimensions
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	t.texture = enemy_texture(enemy)
	return t

static func frontier_texture(tile: int) -> Texture2D:
	var texture = AtlasTexture.new()
	texture.atlas = load("res://assets/art/frontier-enemies-0.43.png")
	var ys = [0,341,654,1024]
	var row = int(tile/6)
	texture.region = Rect2(tile%6*256+4,ys[row]+4,248,ys[row+1]-ys[row]-8)
	texture.filter_clip = true
	return texture

static func icon(id: String, dimension: int = 52) -> TextureRect:
	var t = TextureRect.new()
	t.custom_minimum_size = Vector2(dimension,dimension)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var data = item_catalog.get(id,{})
	if data.has("frontier_card_tile"):
		t.texture = frontier_texture(int(data.frontier_card_tile))
		return t
	for spec in [["material_tile","rare-materials-0.43",7,6],["legacy_tile","legacy-masterworks-0.43",5,2],["masterwork_tile","masterworks-0.43",4,2],["frontier_material_tile","frontier-materials-0.43",6,3],["frontier_card_tile","frontier-enemies-0.43",6,3]]:
		if data.has(spec[0]):
			var path = "res://assets/art/"+spec[1]+".png"
			if ResourceLoader.exists(path): t.texture = atlas_tile(path,int(data[spec[0]]),spec[2],spec[3])
			return t
	if data.has("card_tile"):
		var tile = int(data.card_tile)
		var xs = [0,156,310,465,619,775,938,1106]
		var ys = [0,218,431,662,898,1140,1422]
		var col = tile%7
		var row = int(tile/7)
		var texture = AtlasTexture.new()
		texture.atlas = load("res://assets/art/monster-cards-0.41.png")
		texture.filter_clip = true
		texture.region = Rect2(xs[col]+12,ys[row]+5,xs[col+1]-xs[col]-24,ys[row+1]-ys[row]-10)
		t.texture = texture
		return t
	if data.get("slot","") in ["ring","necklace","belt"]:
		t.texture = load("res://assets/ui/accessory-"+str(data.slot)+".svg")
		return t
	if data.has("art_tile"):
		t.texture = atlas_tile("res://assets/art/ascension-items-0.25.png",int(data.art_tile),4,4)
		return t
	var index = item_ids.find(str(data.get("icon_alias",id)))
	if index>=0 and index<40 and items_texture!=null:
		var a = AtlasTexture.new()
		a.atlas = items_texture
		a.filter_clip = true
		var w = items_texture.get_width()/8.0
		# Painted rows have unequal margins; use their observed atlas boundaries.
		var row_index = int(index/8)
		var tops = [0,190,380,570,765]
		var heights = [185,190,185,190,259]
		a.region = Rect2((index%8)*w,tops[row_index],w,heights[row_index])
		t.texture = a
	return t

static func stat(parent: Node, value: String, title: String, color: Color = TEXT):
	var v = column(3)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(v)
	v.add_child(label(value,25,color,true))
	v.add_child(label(title,11,MUTED))

static func atlas_tile(path: String, index: int, cols: int, rows: int) -> AtlasTexture:
	var texture = load(path)
	var atlas = AtlasTexture.new()
	atlas.atlas = texture
	atlas.filter_clip = true
	var cell = Vector2(texture.get_width()/float(cols),texture.get_height()/float(rows))
	atlas.region = Rect2(Vector2(index%cols,int(index/cols))*cell,cell)
	return atlas

static func scenic(parent: Node, texture: Texture2D, eyebrow: String, title: String, height: int = 184) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.name = "ScenicHeader"
	panel.custom_minimum_size.y = height
	panel.clip_contents = true
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel",box(Color(0,0,0,0),Color(0,0,0,0),0,16))
	parent.add_child(panel)
	var art = TextureRect.new()
	art.texture = texture
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(art)
	var gradient = Gradient.new()
	gradient.offsets = PackedFloat32Array([0,.35,1])
	gradient.colors = PackedColorArray([Color(INK,0),Color(INK,.3),Color(INK,.98)])
	var texture_gradient = GradientTexture2D.new()
	texture_gradient.gradient = gradient
	texture_gradient.fill_from = Vector2(.5,0)
	texture_gradient.fill_to = Vector2(.5,1)
	var veil = TextureRect.new()
	veil.texture = texture_gradient
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(veil)
	var words = column(3)
	words.alignment = BoxContainer.ALIGNMENT_END
	panel.add_child(words)
	words.add_child(para(eyebrow,10,GOLD))
	var heading = para(title,34,TEXT)
	heading.add_theme_font_override("font",title_font)
	words.add_child(heading)
	return panel

static func section(parent: Node, title: String):
	var line = row(12)
	parent.add_child(line)
	line.add_child(label(title,11,GOLD))
	var rule = HSeparator.new()
	rule.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rule.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var style = StyleBoxLine.new()
	style.color = LINE
	style.thickness = 1
	rule.add_theme_stylebox_override("separator",style)
	line.add_child(rule)

static func navigation(active: bool) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color("172027") if active else Color("0e151a")
	style.border_color = GOLD if active else Color("0e151a")
	style.border_width_top = 2
	style.set_content_margin_all(6)
	return style
