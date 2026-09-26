extends "res://tests/capture31.gd"

func capture():
	root.size = Vector2i(480,960)
	var scene = PreviewApp.new()
	root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.set_process(false)
	scene.mode = "play"
	var m = scene.model
	preload("res://ui/bestiary.gd").new(scene).open()
	await snap("discovery-start-0.32")
	assert(button_text(scene.dialog,"Plan this hunt")!=null)
	scene.dismiss()
	for id in RealmCharacters.ALL:
		m.fresh(42)
		var creator = preload("res://ui/character_creation.gd").new(scene)
		creator.chosen = id
		creator.open(true)
		assert(button_text(scene.dialog,"Keep progress & choose").disabled)
		var entry = scene.dialog.find_child("HeroName",true,false)
		entry.text = "Rowan"
		entry.emit_signal("text_changed","Rowan")
		await snap("creation-"+id+"-0.32")
		await click_at(button_text(scene.dialog,"Keep progress & choose").get_global_rect().get_center())
		assert(RealmCharacters.id(m)==id and RealmCharacters.hero_name(m)=="Rowan")
		scene.toast_label.hide()
		await snap("equipment-"+id+"-0.32")
		assert(m.command({"type":"queue","id":"mine_copper","target":4}))
		m.advance(1300)
		scene.set_page("village")
		scene.toast_label.hide()
		await snap("footer-"+id+"-0.32")
		assert(scene.find_child("WorkStage",true,false).character_id==id)
		m.command({"type":"clear"})
	preload("res://ui/character_stats.gd").new(scene).open()
	button_text(scene.dialog,"Add point").emit_signal("pressed")
	assert(RealmCharacters.allocated(m,"might")==1)
	await snap("attributes-0.32")
	scene.dismiss()
	preload("res://ui/ad_settings.gd").new(scene).open()
	var gold_before = m.s.gold
	button_text(scene.dialog,"Watch test ad · +5 selected meals").emit_signal("pressed")
	assert(scene.ads.status.contains("Android") and m.s.gold==gold_before)
	await snap("ad-settings-0.32")
	scene.dismiss()
	scene.U.scale = 1.3
	root.size = Vector2i(360,800)
	var creator = preload("res://ui/character_creation.gd").new(scene)
	creator.chosen = "ranger"
	creator.player_name = "Rowan"
	creator.open()
	await snap("creation-narrow-0.32")
	scene.dismiss()
	scene.set_page("character")
	await snap("equipment-narrow-0.32")
	print("UI 32 PASS: discovery, three actual selections, corresponding hero/work art, stat allocation, non-Android ad failure and narrow layouts")
	quit()
