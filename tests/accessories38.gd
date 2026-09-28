extends "res://tests/capture31.gd"

func capture():
	var m = RealmModel.new()
	var save = RealmSave.new()
	assert(not save.decode(save.encode(m.s),m.data).is_empty(),"Legacy state without accessory slots remains valid")
	var first = m.add_gear("steel_ring",1)
	var second = m.add_gear("steel_ring",1)
	assert(first!=second,"Two rings have distinct identities")
	assert(m.command({"type":"equip","id":first,"slot":"ring_left"}))
	assert(m.command({"type":"equip","id":second,"slot":"ring_right"}))
	var before = m.s.duplicate(true)
	var preview = RealmEquipmentPreview.compare(m,first,"ring_right")
	assert(m.s==before,"Comparison does not mutate inventory")
	assert(m.command({"type":"equip","id":first,"slot":"ring_right"}))
	assert(not m.s.equipped.has("ring_left"),"Moving a ring cannot duplicate it")
	assert(m.stats()==preview.after,"Preview includes removal from the other hand")
	assert(not m.command({"type":"equip","id":first,"slot":"necklace"}))
	assert(m.command({"type":"equip_best"}))
	assert(m.s.equipped.ring_left!=m.s.equipped.ring_right)
	assert(m.command({"type":"loadout_save","id":"journey"}))
	assert(m.command({"type":"preset_save","id":"Accessories"}))
	assert(not save.decode(save.encode(m.s),m.data).is_empty())
	var invalid = m.s.duplicate(true)
	invalid.equipped.ring_right = invalid.equipped.ring_left
	assert(not save.valid(invalid,m.data),"Reject duplicate gear across slots")
	invalid = m.s.duplicate(true)
	invalid.loadouts.journey.gear.ring_right = invalid.loadouts.journey.gear.ring_left
	assert(not save.valid(invalid,m.data),"Reject duplicate gear in saved loadouts")
	assert(m.command({"type":"loadout_load","id":"journey"}))
	m.s.xp.smithing = 25*29*29
	m.gain("steel_ingot",12)
	assert(m.command({"type":"queue","id":"craft_steel_necklace","target":1}))
	m.advance(30000)
	assert(m.s.gear.any(func(g): return g.id=="steel_necklace"),"Accessory recipe completes")
	m.s.tutorial = true
	m.s.xp.smithing = 245025
	m.s.gold = 10000
	m.gain("scrap",100)
	m.gain("steel_ingot",100)
	assert(RealmWorkshop.command(m,first)=="")
	var upgraded = m.last_forged
	assert(upgraded!=second and m.s.loadouts.journey.gear.ring_left==upgraded)
	assert(not save.decode(save.encode(m.s),m.data).is_empty(),"Refinement preserves both ring identities and saved references")
	first = upgraded
	print("PASS accessory ownership, legacy save, loadout, preview, refinement and crafting checks")
	root.size = Vector2i(480,960)
	var scene = PreviewApp.new()
	root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.set_process(false)
	scene.mode = "play"
	scene.model.s = m.s.duplicate(true)
	scene.model.command({"type":"hero_create","id":"warden","name":"Aldren"})
	for family in ["necklace","belt","ring"]:
		scene.model.add_gear("dawnsteel_"+family,2)
	scene.model.command({"type":"equip_best"})
	scene.set_page("character")
	scene.toast_label.hide()
	await snap("accessories-hero-0.38")
	var stage = scene.find_child("HeroEquipment",true,false)
	assert(stage.buttons.size()==10)
	for i in range(stage.buttons.size()):
		for j in range(i): assert(not stage.buttons[i].get_rect().intersects(stage.buttons[j].get_rect()))
	preload("res://ui/equipment_detail.gd").new(scene).open(first,"ring_right")
	await snap("accessories-ring-0.38")
	scene.dismiss()
	scene.U.scale = 1.3
	root.size = Vector2i(360,800)
	scene.set_page("character")
	scene.toast_label.hide()
	await snap("accessories-narrow-0.38")
	stage = scene.find_child("HeroEquipment",true,false)
	for i in range(stage.buttons.size()):
		assert(stage.buttons[i].get_rect().end.x<=stage.size.x)
		for j in range(i): assert(not stage.buttons[i].get_rect().intersects(stage.buttons[j].get_rect()))
	preload("res://ui/hero_equipment.gd").new(scene).open_slot("ring_right")
	await snap("accessories-selection-narrow-0.38")
	print("PASS accessory phone layouts and ring selection")
	quit()
