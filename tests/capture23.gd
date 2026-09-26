extends "res://tests/capture.gd"

func capture():
	root.size = Vector2i(480,960)
	var scene = PreviewApp.new()
	root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.set_process(false)
	scene.mode = "play"
	var m = scene.model
	m.s.gains.copper_ore = 4
	scene.experience.start_guidance()
	scene.experience.act_on_goal()
	await snap("guide-missing-materials-0.23")
	assert(scene.coach.visible)
	scene.coach.target_in(scene.dialog,"materials").emit_signal("pressed")
	await snap("guide-material-plan-0.23")
	assert(scene.coach.visible)
	scene.coach.target_in(scene.dialog,"plan").emit_signal("pressed")
	scene.toast_label.hide()
	await snap("guide-preparing-0.23")
	assert(scene.coach.instruction.text.begins_with("Earlier tasks"))
	m.advance(60000)
	assert(m.s.gains.copper_ingot==2 and m.objective().key=="wood")
	m.fresh(42)
	m.s.gains.copper_ore = 4
	m.s.bag.copper_ore = 2
	scene.experience.start_guidance()
	m.command({"type":"queue","id":"craft_copper_ingot","target":1})
	m.advance(1)
	assert(not m.s.active.is_empty() and m.requirement("craft_copper_ingot")!="")
	scene.refresh()
	scene.toast_label.hide()
	await snap("guide-reserved-materials-0.23")
	assert(scene.coach.instruction.text.begins_with("Working automatically"))
	scene.experience.act_on_goal()
	scene.U.scale = 1.3
	root.size = Vector2i(360,800)
	await snap("guide-existing-queue-0.23")
	assert(scene.coach.visible)
	scene.coach.target_in(scene.dialog,"manage_queue").emit_signal("pressed")
	assert(m.s.queue.size()==1)
	print("UI: missing-material plan completes actual goal; reserved materials stay running; existing queue preserved and accessible.")
	quit()
