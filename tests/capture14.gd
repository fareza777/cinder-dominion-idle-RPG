extends "res://tests/capture.gd"

func capture():
	root.size = Vector2i(480,960)
	var scene = PreviewApp.new()
	root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.set_process(false)
	scene.mode = "play"
	var m = scene.model
	var queue = preload("res://ui/queue_review.gd").new(scene)
	queue.open()
	await snap("queue-empty-0.14")
	m.command({"type":"queue","id":"craft_copper_ingot","target":5})
	m.command({"type":"queue","id":"cut_ash","target":2})
	queue.open()
	await snap("queue-blocked-0.14")
	queue.prepare()
	await snap("queue-repair-plan-0.14")
	var buttons = scene.dialog_footer.get_children().filter(func(node): return node is Button)
	buttons[0].emit_signal("pressed")
	assert(m.s.active.id=="mine_copper" and m.s.queue.size()==3 and m.s.queue[1].id=="craft_copper_ingot")
	await snap("queue-resumed-0.14")
	scene.U.scale = 1.3
	queue.open()
	await snap("queue-large-text-0.14")
	print("UI: repair button inserts gathering and preserves the crafting and waiting tasks.")
	quit()
