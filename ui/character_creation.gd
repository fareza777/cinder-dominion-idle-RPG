extends RefCounted
const U = preload("res://ui/style.gd")
var app
var chosen = "warden"
var player_name = ""
var adopting = false
func _init(owner): app = owner
func open(keep_progress: bool = false):
	adopting = keep_progress
	var v = app.modal("Choose your character",false)
	var tabs = U.row(5)
	v.add_child(tabs)
	for id in RealmCharacters.ALL:
		var b = U.button(RealmCharacters.ALL[id].name,func():
			chosen = id
			open(adopting),chosen==id)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tabs.add_child(b)
	var c = RealmCharacters.ALL[chosen]
	var art = TextureRect.new()
	art.texture = U.atlas_tile("res://assets/art/heroes-0.32.png",c.tile,3,1)
	art.custom_minimum_size.y = 225
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	v.add_child(art)
	v.add_child(U.para(c.name+" · "+c.role,21,U.GOLD))
	v.add_child(U.para(c.trade,15,U.TEXT))
	v.add_child(U.para(c.skill+" · unlocks at Bladecraft Lv.5\n"+c.detail,14))
	v.add_child(U.para("Your name",15,U.TEXT))
	var entry = LineEdit.new()
	entry.name = "HeroName"
	entry.max_length = 24
	entry.placeholder_text = "2–24 characters"
	entry.text = player_name
	entry.custom_minimum_size.y = 48
	v.add_child(entry)
	var note = U.para("Choose once for this journey. All three characters are free."+(" Your existing progress stays intact." if adopting else ""),12)
	v.add_child(note)
	var begin = app.modal_action("Keep progress & choose" if adopting else "Begin journey",func():
		if not RealmCharacters.valid_name(player_name.strip_edges()): return
		if adopting:
			if app.send({"type":"hero_create","id":chosen,"name":player_name.strip_edges()}):
				app.dismiss()
				app.set_page("character")
		else: app.experience.commit_new_game(chosen,player_name.strip_edges()))
	begin.disabled = not RealmCharacters.valid_name(player_name.strip_edges())
	entry.text_changed.connect(func(value):
		player_name = value
		begin.disabled = not RealmCharacters.valid_name(value.strip_edges()))
