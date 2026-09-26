extends "res://tests/capture.gd"
func capture():
	root.size = Vector2i(480,960)
	var scene = PreviewApp.new()
	root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.set_process(false)
	scene.mode = "play"
	var m = scene.model
	var paths = preload("res://ui/ascension.gd").new(scene)
	paths.open()
	await snap("ascension-next-training-0.26")
	assert(paths.next_step(0).id=="mining")
	m.s.xp.mining = 14400
	scene.refresh()
	assert(paths.next_step(0).id=="woodcutting")
	m.s.xp.woodcutting = 14400
	m.s.xp.smithing = 14400
	scene.refresh()
	assert(scene.dialog_footer.get_children()[0].text=="Plan Steel Sword")
	await snap("ascension-next-craft-0.26")
	scene.dialog_footer.get_children()[0].emit_signal("pressed")
	scene.dialog_footer.get_children()[0].emit_signal("pressed")
	assert(paths.next_step(0).kind=="queue")
	paths.open()
	scene.toast_label.hide()
	await snap("ascension-next-work-0.26")
	m.advance(300000)
	scene.refresh()
	assert(paths.next_step(0).kind=="equip")
	await snap("ascension-next-equip-0.26")
	scene.dialog_footer.get_children()[0].emit_signal("pressed")
	scene.dialog_footer.get_children()[0].emit_signal("pressed")
	assert(paths.next_step(0).kind=="journey")
	m.s.beacon = true
	m.s.kills.trial_wilds = 1
	assert(paths.next_step(0).kind=="hunts")
	m.gain("dawnsteel_sword",1,3)
	m.command({"type":"equip_best"})
	assert(paths.next_step(0).kind=="hunts")
	scene.U.scale = 1.3
	root.size = Vector2i(360,800)
	paths.open(3)
	scene.toast_label.hide()
	await snap("ascension-next-narrow-0.26")
	print("UI: live training/craft/work/equip/hunt actions verified; stronger equipped weapon does not trigger a downgrade.")
	quit()
