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
static var scale = 1.0

static func setup(data: Dictionary):
	body_font = load("res://assets/fonts/manrope-readable.ttf")
	title_font = load("res://assets/fonts/cormorantgaramond-readable.ttf")
	if ResourceLoader.exists("res://assets/art/portraits.png"): portraits = load("res://assets/art/portraits.png")
	if ResourceLoader.exists("res://assets/art/items.png"): items_texture = load("res://assets/art/items.png")
	item_ids = data.items.keys()

static func box(color: Color = PANEL, border: Color = LINE, radius: int = 10, padding: int = 14) -> StyleBoxFlat:
	var b = StyleBoxFlat.new()
	b.bg_color = color
	b.border_color = border
	b.set_border_width_all(1)
	b.set_corner_radius_all(radius)
	b.content_margin_left = padding
	b.content_margin_right = padding
	b.content_margin_top = padding
	b.content_margin_bottom = padding
	return b

static func label(text: String, size: int = 16, color: Color = TEXT, serif: bool = false) -> Label:
	var l = Label.new()
	l.text = text
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
	b.text = text
	b.custom_minimum_size.y = 48
	b.add_theme_font_override("font",body_font)
	b.add_theme_font_size_override("font_size",int(15*scale))
	b.add_theme_color_override("font_color",INK if primary else TEXT)
	b.add_theme_color_override("font_hover_color",INK if primary else GOLD)
	b.add_theme_color_override("font_pressed_color",INK if primary else GOLD)
	b.add_theme_color_override("font_disabled_color",Color("737e84"))
	b.add_theme_stylebox_override("normal",box(GOLD if primary else Color("202a31"),GOLD if primary else LINE,6,10))
	b.add_theme_stylebox_override("hover",box(GOLD.lightened(.12) if primary else Color("2c353a"),GOLD,6,10))
	b.add_theme_stylebox_override("pressed",box(GOLD.darkened(.12) if primary else Color("111a21"),GOLD,6,10))
	b.add_theme_stylebox_override("disabled",box(Color("182027"),LINE,6,10))
	b.add_theme_stylebox_override("focus",box(Color(0,0,0,0),GOLD,6,2))
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

static func icon(id: String, dimension: int = 52) -> TextureRect:
	var t = TextureRect.new()
	t.custom_minimum_size = Vector2(dimension,dimension)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var index = item_ids.find(id)
	if index>=0 and items_texture!=null:
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
