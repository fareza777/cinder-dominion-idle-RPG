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
	var state = RealmChronicle.state(m)
	var farm = preload("res://ui/relic_farm.gd").new(scene)
	farm.open("fang")
	await snap("relic-farm-target-0.17")
	state.fragments.fang = 5
	farm.open("fang")
	await snap("relic-farm-ready-0.17")
	var buttons = scene.dialog_footer.get_children().filter(func(node): return node is Button)
	buttons[0].emit_signal("pressed")
	scene.toast_label.hide()
	assert(state.relics.fang==1 and state.fragments.fang==0 and state.relic=="fang")
	await snap("relic-farm-upgraded-0.17")
	state.relics.fang = 9
	farm.open("fang")
	await snap("relic-farm-long-goal-0.17")
	state.relics.fang = 10
	farm.open("fang")
	await snap("relic-farm-maximum-0.17")
	scene.U.scale = 1.3
	farm.open("fang")
	await snap("relic-farm-large-text-0.17")
	print("UI: upgrade spends exact fragments, equips the first relic and refreshes the next goal.")
	quit()
