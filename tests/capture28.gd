extends "res://tests/capture.gd"
func capture():
	root.size = Vector2i(480,960)
	var scene = PreviewApp.new()
	root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.set_process(false)
	scene.mode = "play"
	var m = scene.model
	for skill in m.data.skills:
		m.s.xp[skill] = 245025
		scene.seen_levels[skill] = 100
	m.s.tutorial = true
	m.s.beacon = true
	m.s.kills.apex_marsh_1 = 1
	for metal in ["dawnsteel","moonsteel"]:
		for part in ["sword","shield","helm","chest","gloves","boots"]: m.gain(metal+"_"+part,1,3)
	m.command({"type":"equip_best"})
	m.s.bag.cooked_dawnsteel_fish = 200
	m.s.settings.food = "cooked_dawnsteel_fish"
	m.command({"type":"loadout_save","id":"journey"})
	var uid = ""
	for g in m.s.gear:
		if g.id in ["moonsteel_gloves","moonsteel_boots"]:
			m.command({"type":"equip","id":g.uid})
			uid = g.uid
	m.command({"type":"loadout_save","id":"guardian"})
	preload("res://ui/gear_sets.gd").new(scene).open()
	await snap("sets-overview-0.28")
	scene.item_dialog(uid)
	await snap("sets-item-0.28")
	var compare = preload("res://ui/build_compare.gd").new(scene)
	compare.open("apex_marsh_2")
	await snap("sets-compare-0.28")
	await process_frame
	for scroll in scene.dialog.find_children("*","ScrollContainer",true,false): scroll.scroll_vertical = 370
	await snap("sets-loadouts-0.28")
	scene.U.scale = 1.3
	root.size = Vector2i(360,800)
	compare.open("apex_marsh_2")
	await snap("sets-compare-narrow-0.28")
	preload("res://ui/gear_sets.gd").new(scene).open()
	await snap("sets-overview-narrow-0.28")
	print("UI 28: armor sets, equipment set comparison and hunt/loadout comparison captured at phone sizes")
	quit()
