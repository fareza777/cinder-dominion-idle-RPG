extends "res://tests/capture.gd"

func capture():
	root.size = Vector2i(480,960)
	var scene = PreviewApp.new()
	root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.set_process(false)
	scene.mode = "play"
	var m = scene.model
	scene.hunt_plan_dialog("ash_rat",5)
	await snap("hunt-plan-0.9")
	var buttons = scene.dialog_footer.get_children().filter(func(node): return node is Button)
	buttons[0].emit_signal("pressed")
	assert(m.s.fight.enemy=="ash_rat")
	scene.finish_hunt_dialog()
	await snap("return-after-fight-0.9")
	buttons = scene.dialog_footer.get_children().filter(func(node): return node is Button)
	buttons[0].emit_signal("pressed")
	assert(m.s.queue[0].target==1)
	m.advance(60000)
	m.s.beacon = true
	m.s.kills.wilds_5 = 1
	m.s.bag.cooked_minnow = 100
	m.command({"type":"queue","id":"hunt_trial_wilds","target":1})
	scene.set_page("explore")
	scene.toast_label.hide()
	await process_frame
	m.s.fight.hp = 235
	m.advance(2000)
	await create_timer(.12).timeout
	scene.refresh()
	await snap("guardian-awakening-0.9")
	m.combat_event("MISS","hero")
	await create_timer(.12).timeout
	await snap("combat-dodge-0.9")
	m.s.settings.motion = false
	m.combat_event("+20 HP","hero")
	await create_timer(.12).timeout
	await snap("combat-reduced-motion-0.9")
	scene.hunt_plan_dialog("trial_crown",30)
	await snap("hunt-risk-0.9")
	scene.dismiss()
	scene.experience.intro(true)
	await snap("intro-narrative-0.9")
	print("UI: duration plan starts intended hunt; return action limits it to one fight.")
	quit()
