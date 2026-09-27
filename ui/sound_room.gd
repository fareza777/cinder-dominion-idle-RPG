extends RefCounted
const U = preload("res://ui/style.gd")
const TRACKS = {"hearth":"Cinderwatch · Stronghold","wilds":"Beyond the Walls · Battle","sanctum":"Sunken Bells · Sanctum","crown":"The Hollow Crown · Bosses"}
var app
func _init(owner): app = owner
func open():
	var v = app.modal("Music & sound")
	v.add_child(U.para("Original score",24,U.GOLD))
	v.add_child(U.para("Choose a track. Normal game music returns when you close this panel.",14))
	if float(app.model.s.settings.music)<=0: v.add_child(U.para("Music is muted. Raise Music volume in Settings to listen.",14,U.GOLD))
	app.dynamic(v,func(): return "Now playing: "+TRACKS.get(app.music.mood,"Loading") if is_instance_valid(app.music) else "Audio unavailable",14,U.GREEN)
	for id in TRACKS:
		var button = U.button(TRACKS[id],func():
			if is_instance_valid(app.music): app.music.preview(id,app.dialog))
		button.set_meta("preview_track",id)
		v.add_child(button)
	v.add_child(U.para("Sound effects",22,U.GOLD))
	if float(app.model.s.settings.sfx)<=0: v.add_child(U.para("Sound effects are muted in Settings.",14,U.GOLD))
	for cue in [["strike","Sword strike"],["forge","The forge"],["equip","Equip gear"],["guide","Guidance"],["victory","Victory"]]:
		v.add_child(U.button(cue[1],func(): app.play_cue(cue[0])))
	app.modal_action("Back to Settings",app.settings_dialog)
