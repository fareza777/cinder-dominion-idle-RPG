extends "res://tests/capture.gd"

func capture():
	root.size = Vector2i(480,960)
	var scene = PreviewApp.new()
	root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.set_process(false)
	scene.mode = "play"
	scene.model.s.tutorial = true
	scene.set_page("village")
	await snap("forged-refuge-0.19")
	scene.set_page("inventory")
	await snap("forged-bag-0.19")
	scene.activity_dialog("mine_copper",4)
	await snap("forged-activity-0.19")
	for node in scene.dialog.find_children("*","Button",true,false):
		if node.text.begins_with("Advanced target"): node.emit_signal("pressed")
	await snap("forged-count-input-0.19")
	var buttons = scene.dialog_footer.get_children().filter(func(node): return node is Button)
	buttons[0].emit_signal("pressed")
	assert(scene.model.s.queue[0].id=="mine_copper")
	scene.settings_dialog()
	scene.toast_label.hide()
	await snap("forged-settings-0.19")
	scene.dismiss()
	scene.set_page("skills")
	await snap("forged-skills-0.19")
	scene.activity_dialog("hunt_ash_rat",1)
	await snap("forged-hunt-0.19")
	scene.U.scale = 1.3
	scene.build_shell()
	scene.settings_dialog()
	await snap("forged-large-settings-0.19")
	scene.dismiss()
	scene.set_page("inventory")
	await snap("forged-large-bag-0.19")
	print("UI: themed activity button still queues mining correctly.")
	quit()
