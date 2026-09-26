extends "res://tests/capture.gd"

func capture():
	root.size = Vector2i(480,960)
	var scene = PreviewApp.new()
	root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.set_process(false)
	scene.mode = "play"
	var m = scene.model
	var uid = m.add_gear("copper_sword",3)
	scene.item_dialog(uid)
	await snap("gear-compare-0.15")
	var buttons = scene.dialog_footer.get_children().filter(func(node): return node is Button)
	buttons[0].emit_signal("pressed")
	assert(m.s.equipped.weapon==uid and scene.dialog!=null)
	scene.toast_label.hide()
	await snap("gear-equipped-0.15")
	var tool = m.add_gear("copper_pick",1)
	scene.item_dialog(tool)
	await snap("tool-compare-0.15")
	m.command({"type":"queue","id":"hunt_ash_rat","target":1})
	scene.item_dialog(tool)
	buttons = scene.dialog_footer.get_children().filter(func(node): return node is Button)
	assert(buttons[0].disabled)
	await snap("gear-combat-lock-0.15")
	scene.U.scale = 1.3
	scene.item_dialog(uid)
	await snap("gear-large-text-0.15")
	print("UI: equip updates the same dialog; combat disables gear changes.")
	quit()
