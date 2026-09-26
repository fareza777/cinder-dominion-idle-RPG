extends "res://tests/capture.gd"

func capture():
	root.size = Vector2i(480,960)
	var scene = PreviewApp.new()
	root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.set_process(false)
	scene.mode = "play"
	var m = scene.model
	scene.experience.menu()
	await snap("menu-polish-0.13")
	scene.experience.clear()
	scene.mode = "play"
	scene.set_page("inventory")
	await snap("inventory-icons-0.13")
	scene.set_page("village")
	await snap("refuge-polish-0.13")

	var journal = preload("res://ui/story.gd").new(scene)
	journal.open(0)
	await snap("story-opening-0.13")
	journal.open(2)
	await snap("story-locked-0.13")
	m.s.tutorial = true
	m.s.beacon = true
	journal.open(2)
	await snap("story-beacon-0.13")
	scene.dismiss()
	scene.skill = "smithing"
	scene.set_page("skills")
	scene.toast_label.hide()
	await snap("level-roadmap-0.13")
	scene.refresh()
	m.s.xp.smithing = 2025
	scene.refresh()
	assert(scene.toast_label.text.contains("Smithing reached level 10"))
	await snap("level-up-0.13")
	scene.toast_label.hide()
	m.s.kills.marsh_5 = 1
	m.s.bag.cooked_minnow = 500
	m.command({"type":"queue","id":"hunt_trial_marsh","target":1})
	scene.set_page("explore")
	await process_frame
	m.combat_event("Drowned hymn","hero","cast")
	await snap("guardian-cast-0.13")
	m.s.settings.motion = false
	scene.U.motion = false
	journal.open(1)
	scene.toast_label.hide()
	await snap("story-reduced-motion-0.13")
	scene.U.scale = 1.3
	journal.open(1)
	scene.toast_label.hide()
	await snap("story-large-text-0.13")
	print("UI: story states, level-up feedback and guardian cast render; milestone toast verified.")
	quit()
