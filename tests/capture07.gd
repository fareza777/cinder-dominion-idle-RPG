extends "res://tests/capture.gd"

func capture():
	root.size = Vector2i(480,960)
	var scene = PreviewApp.new()
	root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.set_process(false)
	scene.mode = "play"
	scene.experience.menu()
	await snap("main-menu-0.7")
	scene.experience.clear()
	scene.mode = "play"
	await snap("fresh-refuge-0.7")
	var m = scene.model
	m.s.tutorial = true
	m.s.beacon = true
	m.s.experience.welcome_done = true
	m.s.gold = 2000
	m.s.bag.scrap = 100
	m.s.bag.iron_ingot = 100
	m.s.bag.cooked_minnow = 100
	m.s.xp.smithing = 9025
	m.s.xp.might = 750
	for part in ["sword","shield","helm","chest","gloves","boots"]: m.gain("iron_"+part,1,3)
	m.command({"type":"equip_best"})
	m.s.kills.wilds_5 = 1
	m.s.kills.marsh_5 = 1
	var views = preload("res://ui/armory.gd").new(scene)
	scene.last_objective = m.objective().key
	scene.set_page("village")
	await snap("returning-refuge-0.7")
	views.workshop(str(m.s.equipped.weapon))
	await snap("workshop-0.7")
	var buttons = scene.dialog_footer.get_children().filter(func(node): return node is Button)
	buttons[0].emit_signal("pressed")
	assert(m.gear(str(m.s.equipped.weapon)).q==4)
	assert(m.s.gold==1640 and m.count("iron_ingot")==88 and m.count("scrap")==85)
	print("UI: workshop refinement upgrades equipped piece with exact costs.")
	scene.toast_label.hide()
	m.command({"type":"loadout_save","id":"journey"})
	m.command({"type":"stance","id":"guard"})
	m.command({"type":"loadout_save","id":"guardian"})
	views.loadouts()
	await snap("loadouts-0.7")
	scene.dismiss()
	m.command({"type":"queue","id":"hunt_marsh_1","target":2})
	scene.set_page("explore")
	m.advance(6200)
	scene.refresh()
	await snap("sanctum-battle-0.7")
	m.advance(180000)
	views.hunt_reports()
	await snap("hunt-report-0.7")
	scene.dismiss()
	m.s.hp = 1
	m.s.bag.cooked_minnow = 0
	m.command({"type":"queue","id":"hunt_crown_1","target":1})
	m.advance(6000)
	views.hunt_reports()
	await snap("defeat-report-0.7")
	m.s.hp = 100
	m.s.bag.cooked_minnow = 100
	m.command({"type":"queue","id":"hunt_crown_1","target":2})
	scene.dismiss()
	scene.set_page("explore")
	m.advance(6300)
	m.s.settings.motion = false
	scene.refresh()
	await snap("reduced-motion-battle-0.7")
	m.command({"type":"clear"})
	scene.U.scale = 1.3
	scene.build_shell()
	scene.set_page("village")
	views.workshop(str(m.s.equipped.weapon))
	await snap("large-text-workshop-0.7")
	m.s.settings.music = 0.0
	scene.music = AudioStreamPlayer.new()
	scene.music.set_script(preload("res://ui/audio_director.gd"))
	scene.music.app = scene
	scene.add_child(scene.music)
	await create_timer(.1).timeout
	assert(scene.music.mood=="hearth" and scene.music.volume_db<=-80)
	m.command({"type":"queue","id":"hunt_wilds_1","target":2})
	await create_timer(.3).timeout
	assert(scene.music.mood=="wilds")
	scene.paused = true
	await process_frame
	await process_frame
	assert(scene.music.stream_paused)
	print("Audio: regional transition, mute setting and background pause verified silently.")
	print("0.7 integrated UI captures complete.")
	quit()
