extends "res://tests/capture31.gd"

func capture():
	root.size = Vector2i(480,960)
	var scene = PreviewApp.new()
	root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.set_process(false)
	scene.mode = "play"
	var m = scene.model
	for id in RealmCharacters.ALL:
		m.fresh(42)
		scene.set_page("character")
		var creator = preload("res://ui/character_creation.gd").new(scene)
		creator.chosen = id
		creator.player_name = "Ash Walker"
		creator.open(true)
		await snap("creation-"+id+"-0.33")
		await click_at(button_text(scene.dialog,"Keep progress & choose").get_global_rect().get_center())
		assert(RealmCharacters.id(m)==id)
		scene.toast_label.hide()
		await snap("hero-"+id+"-0.33")
		assert(m.command({"type":"queue","id":"mine_copper","target":4}))
		m.advance(1300)
		scene.set_page("village")
		await snap("footer-"+id+"-0.33")
		assert(scene.find_child("WorkStage",true,false).frames.size()==24)
		m.command({"type":"clear"})
	preload("res://ui/character_stats.gd").new(scene).open()
	await snap("remedy-0.33")
	scene.dismiss()
	scene.U.scale = 1.3
	root.size = Vector2i(360,800)
	var creator = preload("res://ui/character_creation.gd").new(scene)
	creator.chosen = "apothecary"
	creator.player_name = "Ash Walker"
	creator.open()
	await snap("creation-narrow-0.33")
	for id in RealmCharacters.ALL:
		var choice = button_text(scene.dialog,RealmCharacters.ALL[id].name)
		assert(choice!=null and choice.get_global_rect().end.x<=scene.size.x)
	scene.dismiss()
	scene.set_page("character")
	await snap("hero-narrow-0.33")
	print("UI 33 PASS: five actual selections, portraits, 24-frame work atlases, new skill screen and narrow selector bounds")
	scene.queue_free()
	await process_frame
	quit()
