extends "res://tests/capture.gd"

func capture():
	root.size = Vector2i(480,960)
	var scene = PreviewApp.new()
	root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.set_process(false)
	scene.mode = "play"
	var m = scene.model
	m.s.tutorial = true
	m.s.bag.cooked_minnow = 100
	m.s.kills.ash_rat = 24
	var mastery = preload("res://ui/hunt_mastery.gd").new(scene)
	mastery.open()
	await snap("mastery-list-0.20")
	mastery.detail("ash_rat")
	await snap("mastery-next-0.20")
	var buttons = scene.dialog_footer.get_children().filter(func(node): return node is Button)
	buttons[0].emit_signal("pressed")
	await snap("mastery-hunt-0.20")
	buttons = scene.dialog_footer.get_children().filter(func(node): return node is Button)
	buttons[0].emit_signal("pressed")
	assert(m.s.queue[0].id=="hunt_ash_rat" and m.s.queue[0].target==1)
	m.advance(30000)
	assert(m.s.kills.ash_rat==25 and RealmHuntMastery.rank(m,"ash_rat")==2)
	mastery.detail("ash_rat")
	scene.toast_label.hide()
	await snap("mastery-earned-0.20")
	m.s.kills.ash_rat = 24
	RealmChronicle.state(m).fragments.fang = 0
	preload("res://ui/relic_farm.gd").new(scene).open("fang")
	await snap("mastery-fragment-target-0.20")
	m.s.kills.ash_rat = 150
	mastery.detail("ash_rat")
	await snap("mastery-maximum-0.20")
	scene.U.scale = 1.3
	mastery.detail("ash_rat")
	await snap("mastery-large-text-0.20")
	print("UI: milestone CTA queues exactly one fight; victory unlocks Studied and refreshes bonuses.")
	quit()
