extends "res://tests/capture.gd"

func capture():
	root.size = Vector2i(480,960)
	var scene = PreviewApp.new()
	root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.set_process(false)
	scene.mode = "play"
	scene.runeforge_dialog()
	await snap("runeforge-locked-0.6")
	var m = scene.model
	m.s.tutorial = true
	m.s.beacon = true
	m.s.kills.wilds_1 = 5
	m.s.kills.wilds_5 = 1
	m.s.kills.marsh_1 = 20
	m.s.kills.marsh_5 = 1
	m.s.gold = 900
	m.s.bag.scrap = 80
	m.s.bag.cooked_minnow = 100
	RealmChronicle.state(m).fragments = {"fang":400,"heart":400,"ward":400}
	for part in ["sword","shield","helm","chest","gloves","boots"]: m.gain("iron_"+part,1,3)
	m.command({"type":"equip_best"})
	scene.last_objective = m.objective().key
	scene.runeforge_dialog()
	await snap("runeforge-0.6")
	scene.dialog_footer.get_child(0).emit_signal("pressed")
	assert(m.s.runeforge.ranks.thorn==1 and m.s.gold==850)
	scene.dialog_footer.get_child(1).emit_signal("pressed")
	assert(m.s.runeforge.equipped=="thorn")
	print("UI: inscribe and equip actions apply rune and exact gold cost.")
	await snap("rune-equipped-0.6")
	var views = preload("res://ui/runeforge.gd").new(scene)
	scene.toast_label.hide()
	views.journal("marsh")
	await snap("field-journal-0.6")
	scene.dialog_footer.get_child(0).emit_signal("pressed")
	assert("marsh_5" in m.s.runeforge.claimed)
	print("UI: pinned field-reward action claims the completed record.")
	scene.toast_label.hide()
	m.s.runeforge.ranks.tide = 3
	m.command({"type":"rune_equip","id":"tide"})
	scene.activity_dialog("hunt_marsh_1",5)
	await snap("rune-preparation-0.6")
	scene.U.scale = 1.3
	scene.build_shell()
	scene.set_page("character")
	views.forge("bell")
	await snap("runeforge-large-text-0.6")
	print("0.6 focused UI captures complete.")
	quit()
