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
	m.s.gold = 150
	m.s.xp.smithing = 1000
	var uid = m.add_gear("copper_sword",2)
	m.command({"type":"equip","id":uid})
	var views = preload("res://ui/armory.gd").new(scene)
	views.workshop(uid,"ash_rat")
	await snap("upgrade-preview-0.12")
	m.s.gold = 1000
	m.s.bag.copper_ingot = 100
	m.s.bag.scrap = 100
	views.workshop(uid,"ash_rat")
	var buttons = scene.dialog_footer.get_children().filter(func(node): return node is Button)
	buttons[0].emit_signal("pressed")
	assert(m.gear(str(m.s.equipped.weapon)).q==3)
	await snap("upgrade-complete-0.12")
	scene.toast_label.hide()
	var bag_uid = m.add_gear("copper_shield",1)
	views.workshop(bag_uid,"ash_rat")
	await snap("upgrade-bag-item-0.12")
	scene.U.scale = 1.3
	views.workshop(bag_uid,"ash_rat")
	await snap("upgrade-large-text-0.12")
	print("UI: preview and actual refinement work; equipped and bagged items are distinguished.")
	quit()
