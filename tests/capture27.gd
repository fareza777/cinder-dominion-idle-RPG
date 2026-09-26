extends "res://tests/capture.gd"
func capture():
	root.size = Vector2i(480,960)
	var scene = PreviewApp.new()
	root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.set_process(false)
	scene.mode = "play"
	var m = scene.model
	if "--training-only" in OS.get_cmdline_user_args():
		m.s.xp.bladecraft = 245025
		preload("res://ui/gameplay.gd").new(scene).advanced_training()
		await snap("audit-training-0.27")
		quit()
		return
	m.command({"type":"upgrade_goal","id":"steel_sword"})
	scene.set_page("village")
	await snap("audit-target-home-0.27")
	preload("res://ui/upgrade_goal.gd").new(scene).open()
	await snap("audit-target-training-0.27")
	for skill in m.data.skills: m.s.xp[skill] = 245025
	for skill in m.data.skills: scene.seen_levels[skill] = 100
	scene.toast_label.hide()
	m.s.tutorial = true
	m.s.beacon = true
	m.s.settings.food = "cooked_dawnsteel_fish"
	preload("res://ui/gameplay.gd").new(scene).work_orders("dawnsteel")
	await snap("audit-tier-work-0.27")
	preload("res://ui/gameplay.gd").new(scene).advanced_training()
	await snap("audit-training-0.27")
	assert(m.command({"type":"doctrine","id":"blood"}))
	assert(m.command({"type":"loadout_save","id":"journey"}))
	m.command({"type":"doctrine","id":"none"})
	assert(m.command({"type":"loadout_load","id":"journey"}))
	assert(m.s.doctrine=="blood")
	for part in ["sword","shield","helm","chest","gloves","boots"]: m.gain("dawnsteel_"+part,1,3)
	m.command({"type":"equip_best"})
	m.s.bag.cooked_dawnsteel_fish = 100
	scene.dismiss()
	m.command({"type":"queue","id":"hunt_wilds_1","target":20})
	m.advance(1750)
	scene.set_page("explore")
	await snap("audit-battle-0.27")
	m.command({"type":"clear"})
	m.s.kills.apex_crown_2 = 1
	scene.hunt_plan_dialog("apex_crown_3")
	await snap("audit-readiness-0.27")
	scene.dismiss()
	for item in m.data.items:
		if m.data.items[item].category=="equipment": m.gain(item,1,2)
	scene.inventory_sort = 2
	scene.filter = "equipment"
	scene.set_page("inventory")
	await snap("audit-inventory-0.27")
	scene.U.scale = 1.3
	root.size = Vector2i(360,800)
	preload("res://ui/upgrade_goal.gd").new(scene).open()
	await snap("audit-target-narrow-0.27")
	scene.dismiss()
	preload("res://ui/ascension.gd").new(scene).open(3)
	await snap("audit-ascension-narrow-0.27")
	scene.U.scale = 1.0
	root.size = Vector2i(480,960)
	preload("res://ui/bestiary.gd").new(scene).open("crown")
	await snap("audit-bestiary-0.27")
	scene.bounties_dialog()
	await snap("audit-bounties-0.27")
	scene.dismiss()
	m.command({"type":"queue","id":"mine_copper","target":100000})
	m.s.wall = scene.now_ms()-86400000
	scene.call_deferred("recover_progress")
	await snap("audit-recovery-0.27")
	while scene.recovering: await process_frame
	for id in ["hearth","wilds","sanctum","crown"]:
		var audio = load("res://assets/audio/"+id+".ogg")
		assert(audio is AudioStreamOggVorbis and absf(audio.get_length()-64)<.1)
	print("UI 27: tracked goal, work orders, training/loadout, battle poses, hunt readiness, inventory pages, narrow text and four music durations PASS")
	quit()
