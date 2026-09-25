extends "res://tests/capture.gd"

func capture():
	root.size = Vector2i(480,960)
	var scene = PreviewApp.new()
	root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.set_process(false)
	scene.mode = "play"
	scene.activity_dialog("mine_copper",4)
	await snap("first-order-0.5")
	scene.dialog_footer.get_child(0).emit_signal("pressed")
	scene.model.advance(12000)
	scene.refresh()
	assert(scene.model.count("copper_ore")==4)
	print("UI: first objective button queues and completes four ore.")
	scene.planner_dialog("craft_copper_sword",1)
	await snap("crafting-plan-0.5")
	var m = scene.model
	m.s.tutorial = true
	m.s.beacon = true
	m.s.xp.might = 750
	m.s.experience.welcome_done = true
	for part in ["sword","shield","helm","chest","gloves","boots"]: m.gain("iron_"+part,1,3)
	m.command({"type":"equip_best"})
	m.s.bag.cooked_minnow = 100
	m.s.kills.wilds_5 = 1
	m.s.kills.marsh_5 = 1
	scene.last_objective = m.objective().key
	scene.toast_label.hide()
	scene.work_orders_dialog()
	await snap("work-orders-0.5")
	preload("res://ui/chronicle.gd").new(scene).farms("fang")
	await snap("hunting-grounds-0.5")
	scene.activity_dialog("hunt_marsh_1",1)
	await snap("oracle-preview-0.5")
	scene.dialog_footer.get_child(0).emit_signal("pressed")
	scene.set_page("explore")
	m.advance(8400)
	scene.refresh()
	await snap("oracle-combat-0.5")
	m.command({"type":"clear"})
	scene.U.scale = 1.3
	scene.build_shell()
	scene.set_page("village")
	scene.planner_dialog("craft_copper_ingot",10)
	await snap("large-text-action-0.5")
	print("0.5 focused UI review captured.")
	quit()
