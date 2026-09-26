extends "res://tests/capture.gd"

func capture():
	root.size = Vector2i(480,960)
	var scene = PreviewApp.new()
	root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.set_process(false)
	scene.mode = "play"
	var m = scene.model
	m.s.tutorial = true
	m.s.bag.cooked_minnow = 100
	m.s.kills.ash_rat = 24
	var mastery = preload("res://ui/hunt_mastery.gd").new(scene)
	mastery.detail("ash_rat")
	var original = scene.dialog
	var action = scene.dialog_footer.get_children()[0]
	assert(action.text=="Hunt · 1 fight")
	await snap("mastery-live-before-0.21")
	m.command({"type":"queue","id":"hunt_ash_rat","target":1})
	m.advance(30000)
	scene.refresh()
	assert(m.s.kills.ash_rat==25)
	assert(scene.dialog==original)
	assert(action.text=="Hunt · 50 fights")
	assert(has_text(scene.dialog,"Per win: %d gold · 2 fragments" % RealmHuntMastery.gold(m,m.data.enemies.ash_rat)))
	await snap("mastery-live-earned-0.21")
	action.emit_signal("pressed")
	scene.dialog_footer.get_children()[0].emit_signal("pressed")
	assert(m.s.queue[0].target==50)
	m.command({"type":"clear"})
	scene.toast_label.hide()
	mastery.open()
	original = scene.dialog
	m.s.kills.ash_rat = 74
	scene.refresh()
	assert(scene.dialog==original and has_text(scene.dialog,"1 win to Veteran"))
	await snap("mastery-live-list-0.21")
	m.s.kills.ash_rat = 149
	mastery.detail("ash_rat")
	m.s.kills.ash_rat = 150
	scene.refresh()
	assert(has_text(scene.dialog,"All ranks earned"))
	assert(scene.dialog_footer.get_children()[0].text=="Hunt · 25 fights")
	await snap("mastery-live-maximum-0.21")
	scene.U.scale = 1.3
	root.size = Vector2i(360,800)
	mastery.detail("ash_rat")
	await snap("mastery-live-narrow-0.21")
	scene.dismiss()
	assert(scene.dialog_callbacks.is_empty())
	print("UI: live victory updates same dialog, reward and 50-fight action; collection, maximum, narrow text and cleanup checked.")
	quit()

func has_text(node: Node, text: String) -> bool:
	if node is Label and node.text==text: return true
	for child in node.get_children():
		if has_text(child,text): return true
	return false
