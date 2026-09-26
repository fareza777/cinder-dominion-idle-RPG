extends "res://tests/capture.gd"

func capture():
	root.size = Vector2i(480,960)
	var scene = PreviewApp.new()
	root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.set_process(false)
	scene.mode = "play"
	var m = scene.model
	var save = RealmSave.new()
	m.s.experience.welcome_done = true
	m.s.wall = 1000
	m.command({"type":"queue","id":"mine_copper","target":100})
	var report = save.resume(m,601000)
	scene.offline_dialog(report)
	await snap("return-progress-0.16")
	m.command({"type":"queue","id":"craft_iron_ingot","target":5})
	m.s.wall = 601000
	report = save.resume(m,1201000)
	scene.offline_dialog(report)
	await snap("return-blocked-0.16")
	var buttons = scene.dialog_footer.get_children().filter(func(node): return node is Button)
	buttons[0].emit_signal("pressed")
	assert(m.s.report.is_empty() and scene.dialog!=null)
	await snap("return-queue-action-0.16")
	m.command({"type":"clear"})
	m.s.wall = 1201000
	report = save.resume(m,1201000+RealmModel.MAX_OFFLINE*2)
	scene.offline_dialog(report)
	await snap("return-capped-idle-0.16")
	scene.U.scale = 1.3
	scene.offline_dialog(report)
	await snap("return-large-text-0.16")
	print("UI: return report routes blocked work to Queue and clears acknowledged report.")
	quit()
