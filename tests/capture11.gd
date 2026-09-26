extends "res://tests/capture.gd"

func capture():
	root.size = Vector2i(480,960)
	var scene = PreviewApp.new()
	root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.set_process(false)
	scene.mode = "play"
	var m = scene.model
	scene.hunt_reports_dialog()
	await snap("hunt-empty-0.11")
	m.s.tutorial = true
	m.s.beacon = true
	m.s.kills.wilds_5 = 1
	m.s.bag.cooked_minnow = 1000
	m.s.settings.threshold = .8
	for part in ["sword","shield","helm","chest","gloves","boots"]: m.gain("iron_"+part,1,5)
	m.command({"type":"equip_best"})
	for count in [2,3]:
		m.command({"type":"queue","id":"hunt_trial_wilds","target":count})
		m.advance(300000)
	scene.hunt_reports_dialog()
	await snap("hunt-comparison-0.11")
	var restock = find_restock(scene.dialog)
	assert(restock!=null)
	restock.emit_signal("pressed")
	await snap("hunt-restock-plan-0.11")
	scene.hunt_reports_dialog()

	var buttons = scene.dialog_footer.get_children().filter(func(node): return node is Button)
	buttons[0].emit_signal("pressed")
	await snap("hunt-repeat-plan-0.11")
	assert(scene.dialog!=null)
	m.s.hp = 1
	m.s.bag.cooked_minnow = 0
	m.s.kills.crown_5 = 1
	m.command({"type":"queue","id":"hunt_trial_crown","target":1})
	m.advance(3000)
	scene.hunt_reports_dialog()
	await snap("hunt-defeat-0.11")
	m.s.hunts.history[0].erase("consumed")
	scene.hunt_reports_dialog()
	await snap("hunt-legacy-0.11")
	scene.U.scale = 1.3
	scene.hunt_reports_dialog()
	await snap("hunt-large-text-0.11")
	print("UI: populated report opens repeat planning; empty, comparison, defeat and legacy states render.")
	quit()

func find_restock(node):
	if node is Button and node.text.begins_with("Plan ") and " more " in node.text: return node
	for child in node.get_children():
		var found = find_restock(child)
		if found!=null: return found
	return null
