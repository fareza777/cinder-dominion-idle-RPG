extends "res://tests/capture.gd"

func capture():
	root.size = Vector2i(480,960)
	var scene = PreviewApp.new()
	root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.set_process(false)
	scene.mode = "play"
	var views = preload("res://ui/trials.gd").new(scene)
	views.show_trial()
	await snap("trial-locked-0.8")
	var m = scene.model
	m.s.beacon = true
	m.s.tutorial = true
	m.s.kills.wilds_5 = 1
	m.s.kills.marsh_5 = 1
	m.s.bag.cooked_minnow = 1000
	for part in ["sword","shield","helm","chest","gloves","boots"]: m.gain("iron_"+part,1,5)
	m.command({"type":"equip_best"})
	views.show_trial()
	await snap("trial-ready-0.8")
	var buttons = scene.dialog_footer.get_children().filter(func(node): return node is Button)
	buttons[0].emit_signal("pressed")
	await snap("trial-preparation-0.8")
	buttons = scene.dialog_footer.get_children().filter(func(node): return node is Button)
	buttons[0].emit_signal("pressed")
	assert(m.s.fight.enemy=="trial_wilds")
	print("UI: trial preparation starts the correct single fight.")
	scene.toast_label.hide()
	m.s.fight.hp = 220
	m.advance(2000)
	scene.set_page("explore")
	scene.refresh()
	await snap("trial-phase-two-0.8")
	m.advance(600000)
	views.show_trial()
	await snap("trial-cleared-0.8")
	scene.hunt_reports_dialog()
	await snap("trial-rewards-0.8")
	scene.U.scale = 1.3
	views.show_trial("trial_marsh")
	await snap("trial-large-text-0.8")
	quit()
