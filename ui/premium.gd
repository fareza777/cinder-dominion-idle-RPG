extends RefCounted
const U = preload("res://ui/style.gd")

static func art(index: int) -> Texture2D:
	var tile = U.atlas_tile("res://assets/art/locations-0.47.png",index,4,3)
	tile.region = tile.region.grow(-7)
	return tile

static func destination(parent: Node, title: String, index: int, action: Callable, height: int = 100):
	var panel = U.scenic(parent,art(index),"",title,height)
	var hit = Button.new()
	hit.flat = true
	hit.tooltip_text = title
	hit.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	hit.pressed.connect(action)
	panel.add_child(hit)
	hit.add_theme_stylebox_override("normal",StyleBoxEmpty.new())
	hit.add_theme_stylebox_override("hover",U.box(Color(0,0,0,.10),U.GOLD,2,0))
	hit.add_theme_stylebox_override("pressed",U.box(Color(0,0,0,.22),U.GOLD,2,0))
	hit.add_theme_stylebox_override("focus",U.box(Color(0,0,0,0),U.GOLD,2,0))
	return panel

static func tabs(parent: Node, entries: Array, selected: String, callback: Callable):
	var row = U.row(4)
	parent.add_child(row)
	for entry in entries:
		var b = U.button(entry[1],func(): callback.call(entry[0]))
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.custom_minimum_size.x = 0
		b.add_theme_stylebox_override("normal",U.navigation(entry[0]==selected))
		b.add_theme_color_override("font_color",U.GOLD if entry[0]==selected else U.MUTED)
		row.add_child(b)

static func item_tile(parent: Node, id: String, title: String, note: String, color: Color, action: Callable):
	var panel = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel",U.frame(U.PANEL,color.darkened(.48),"panel",14))
	parent.add_child(panel)
	var words = U.column(5)
	words.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(words)
	words.add_child(U.icon(id,72))
	words.add_child(U.para(title,16,U.TEXT))
	words.add_child(U.para(note,13,color))
	var hit = Button.new()
	hit.flat = true
	hit.tooltip_text = title
	hit.add_theme_stylebox_override("normal",StyleBoxEmpty.new())
	hit.add_theme_stylebox_override("hover",U.box(Color(0,0,0,.08),color,2,0))
	hit.add_theme_stylebox_override("pressed",U.box(Color(0,0,0,.2),color,2,0))
	hit.pressed.connect(action)
	panel.add_child(hit)
	return panel
