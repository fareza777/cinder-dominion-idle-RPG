extends "res://tests/capture24.gd"

func button_text(node: Node, text: String):
	if node is Button and node.text==text: return node
	for child in node.get_children():
		var found = button_text(child,text)
		if found!=null: return found
	return null

func capture():
	root.size = Vector2i(480,960)
	var scene = PreviewApp.new()
	root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.set_process(false)
	scene.mode = "play"
	var m = scene.model
	for skill in m.data.skills: m.s.xp[skill] = 245025
	for skill in preload("res://ui/work_stage.gd").SKILLS:
		m.command({"type":"clear"})
		var id = ""
		for key in m.data.activities:
			if m.data.activities[key].skill==skill:
				id = key
				break
		var a = m.data.activities[id]
		for input in a.inputs: m.gain(input,int(a.inputs[input])*5)
		assert(m.command({"type":"queue","id":id,"target":3}))
		scene.set_page("village")
		scene.toast_label.hide()
		await process_frame
		await process_frame
		var stage = scene.find_child("WorkStage",true,false)
		assert(stage!=null and stage.visible and stage.frame==0)
		m.advance(int(mini(2400,m.s.active.due-m.s.time)*.57))
		await process_frame
		await process_frame
		assert(stage.frame==2 and stage.skill_index==stage.SKILLS.find(skill))
		await snap("work-"+skill+"-0.31")
		var time_before = m.s.time
		m.s.settings.motion = false
		await process_frame
		await process_frame
		assert(stage.frame==0 and m.s.time==time_before)
		m.s.settings.motion = true
	# Queue switches between skill scenes without reopening it manually.
	m.command({"type":"clear"})
	m.command({"type":"queue","id":"mine_copper","target":1})
	m.command({"type":"queue","id":"cut_ash","target":2})
	scene.queue_dialog()
	await process_frame
	m.advance(int(m.s.active.due-m.s.time))
	scene.refresh()
	await create_timer(.3).timeout
	assert(scene.find_child("WorkStage",true,false).activity_id=="cut_ash")
	await snap("work-queue-0.31")
	m.command({"type":"clear"})
	scene.refresh()
	await create_timer(.3).timeout
	assert(button_text(scene.dialog,"View my next objective")!=null)
	scene.dismiss()
	m.s.bag.erase("copper_ingot")
	m.command({"type":"queue","id":"craft_copper_sword","target":2})
	scene.set_page("skills")
	await snap("work-waiting-0.31")
	var waiting = scene.find_child("WorkStage",true,false)
	assert(not waiting.running and waiting.frame==0)
	m.advance(1000)
	await process_frame
	assert(waiting.frame==0)
	m.command({"type":"clear"})
	var equipment = preload("res://ui/hero_equipment.gd").new(scene)
	equipment.open_slot("head")
	await snap("hero-empty-slot-0.31")
	assert(button_text(scene.dialog,"Explore gear paths")!=null)
	equipment.open_slot("pick")
	assert(button_text(scene.dialog,"Inspect equipped item")!=null)
	scene.dismiss()
	# Equipment: slot -> compare -> actual equip action -> refreshed anatomy slots.
	m.gain("copper_sword",1,2)
	scene.set_page("character")
	scene.toast_label.hide()
	await snap("hero-empty-0.31")
	await click_at(scene.find_child("Slot_weapon",true,false).get_global_rect().get_center())
	await create_timer(.2).timeout
	button_text(scene.dialog,"Compare & equip").emit_signal("pressed")
	await create_timer(.2).timeout
	await click_at(button_text(scene.dialog,"Equip item").get_global_rect().get_center())
	assert(m.gear(m.s.equipped.weapon).id=="copper_sword")
	scene.dismiss()
	for part in ["helm","chest","gloves","boots","shield"]:
		var id = "dawnsteel_"+part
		assert(m.data.items.has(id))
		m.gain(id,1,3)
		for gear in m.s.gear:
			if gear.id==id: assert(m.command({"type":"equip","id":gear.uid}))
	scene.set_page("character")
	scene.toast_label.hide()
	await snap("hero-equipped-0.31")
	var hero = scene.find_child("HeroEquipment",true,false)
	for icon in hero.icons: assert(icon.texture!=null)
	await click_at(scene.find_child("Slot_body",true,false).get_global_rect().get_center())
	await snap("hero-slot-0.31")
	scene.dismiss()
	m.command({"type":"queue","id":"hunt_ash_rat","target":2})
	scene.queue_dialog()
	await snap("work-battle-0.31")
	assert(scene.find_child("WorkStage",true,false).combat)
	preload("res://ui/hero_equipment.gd").new(scene).open_slot("weapon")
	button_text(scene.dialog,"Inspect equipped item").emit_signal("pressed")
	assert(button_text(scene.dialog,"Already equipped").disabled)
	scene.dismiss()
	m.command({"type":"clear"})
	scene.U.scale = 1.3
	root.size = Vector2i(360,800)
	scene.set_page("character")
	await snap("hero-narrow-0.31")
	m.command({"type":"queue","id":"mine_copper","target":3})
	scene.dismiss()
	scene.set_page("village")
	await snap("footer-narrow-0.31")
	scene.queue_dialog()
	await snap("work-narrow-0.31")
	assert(not scene.saves.decode(scene.saves.encode(m.s),m.data).is_empty())
	print("UI 31 PASS: six footer thumbnails driven by simulation time, reduced motion, queue handoff/empty/waiting, actual equip, six icons, combat thumbnail/lock, save roundtrip and narrow layouts")
	quit()
