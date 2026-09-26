extends "res://tests/capture.gd"

func capture():
	root.size = Vector2i(480,960)
	var scene = PreviewApp.new()
	root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.set_process(false)
	scene.mode = "play"
	await snap("refuge-clear-goal-0.10")
	var guide = preload("res://ui/progress_guide.gd").new(scene)
	guide.open()
	await snap("next-step-0.10")
	var buttons = scene.dialog_footer.get_children().filter(func(node): return node is Button)
	buttons[0].emit_signal("pressed")
	buttons = scene.dialog_footer.get_children().filter(func(node): return node is Button)
	buttons[0].emit_signal("pressed")
	assert(scene.model.s.queue[0].id=="mine_copper" and scene.model.s.queue[0].target==4)
	print("UI: next-step guide opens and starts the exact first objective.")
	scene.toast_label.hide()
	guide.open("farm")
	await snap("farming-guide-0.10")
	guide.open("upgrade")
	await snap("upgrade-guide-0.10")
	scene.U.scale = 1.3
	guide.open()
	await snap("next-step-large-0.10")
	quit()
