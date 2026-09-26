extends "res://tests/capture.gd"

func capture():
	root.size = Vector2i(480,960)
	var scene = PreviewApp.new()
	root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.set_process(false)
	scene.mode = "play"
	scene.experience.welcome()
	await snap("action-first-welcome-0.18")
	var buttons = scene.dialog_footer.get_children().filter(func(node): return node is Button)
	buttons[0].emit_signal("pressed")
	await snap("action-first-mining-0.18")
	buttons = scene.dialog_footer.get_children().filter(func(node): return node is Button)
	buttons[0].emit_signal("pressed")
	assert(scene.model.s.queue[0].id=="mine_copper" and scene.model.s.queue[0].target==4)
	scene.model.advance(30000)
	assert(scene.model.count("copper_ore")==4 and scene.model.objective().key=="ingots")
	scene.set_page("village")
	scene.toast_label.hide()
	await snap("action-first-refuge-0.18")
	scene.experience.guide()
	await snap("action-first-goals-0.18")
	scene.dismiss()
	scene.skill = ""
	scene.set_page("skills")
	await snap("action-first-skills-0.18")
	scene.set_page("explore")
	await snap("action-first-explore-0.18")
	scene.activity_dialog("hunt_ash_rat",1)
	await snap("action-first-hunt-0.18")
	scene.progress_dialog()
	await snap("action-first-progress-0.18")
	scene.model.s.tutorial = true
	preload("res://ui/relic_farm.gd").new(scene).open("fang")
	await snap("action-first-relic-0.18")
	scene.U.scale = 1.3
	scene.experience.welcome()
	await snap("action-first-large-text-0.18")
	print("UI: first-task CTA opens mining; Begin queues four ore and advances the next objective.")
	quit()

