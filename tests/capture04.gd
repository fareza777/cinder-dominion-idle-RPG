extends "res://tests/capture.gd"

func capture():
	root.size = Vector2i(480,960)
	var scene = PreviewApp.new()
	root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.mode = "play"
	scene.set_page("village")
	await snap("first-step-0.4")
	var m = scene.model
	m.s.tutorial = true
	m.s.beacon = true
	m.s.experience.welcome_done = true
	m.s.xp.might = 750
	m.s.xp.smithing = 2025
	m.s.gains = {"copper_ore":30,"copper_ingot":15,"ash_log":1,"copper_sword":1}
	for id in ["ash_rat","grave_thrall","cinder_bandit","chapel_guard","ember_wraith","bellkeeper"]: m.s.kills[id] = 5
	for part in ["sword","shield","helm","chest","gloves","boots"]: m.gain("iron_"+part,1,3)
	m.command({"type":"equip_best"})
	m.s.bag.cooked_minnow = 100
	RealmChronicle.sync_day(m,scene.now_ms())
	m.s.chronicle.fragments = {"fang":30,"ward":15,"heart":5}
	scene.last_objective = m.objective().key
	scene.set_page("village")
	scene.toast_label.hide()
	await snap("returning-hub-0.4")
	scene.world_dialog()
	await snap("world-map-0.4")
	scene.talents_dialog()
	await snap("talents-0.4")
	scene.relics_dialog()
	await snap("relics-0.4")
	scene.bounties_dialog()
	await snap("bounties-0.4")
	scene.work_orders_dialog()
	await snap("work-orders-0.4")
	scene.settings_dialog()
	await snap("settings-english-0.4")
	scene.dismiss()
	m.command({"type":"queue","id":"hunt_wilds_1","target":3})
	scene.set_page("explore")
	await snap("expedition-combat-0.4")
	scene.U.scale = 1.3
	scene.build_shell()
	scene.set_page("village")
	await snap("large-text-hub-0.4")
	print("0.4 key screens captured.")
	quit()
