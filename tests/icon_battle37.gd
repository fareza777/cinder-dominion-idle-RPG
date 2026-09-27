extends "res://tests/capture31.gd"

func capture():
	root.size = Vector2i(480,960)
	var scene = PreviewApp.new()
	root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.set_process(false)
	scene.mode = "play"
	for character in RealmCharacters.ALL:
		scene.model.fresh(37)
		scene.model.command({"type":"hero_create","id":character,"name":character.capitalize()})
		scene.model.command({"type":"queue","id":"hunt_ash_rat","target":2})
		scene.set_page("explore")
		await process_frame
		await process_frame
		var stage = battle_stage(scene)
		stage.set_process(false)
		stage.effects_enabled = false
		assert(stage.poses.size()==4)
		assert(stage.poses[0].region!=stage.poses[2].region,"Distinct idle and attack frames")
		stage._process(0)
		stage.floating.clear()
		stage.attacks = {"hero":0.0,"enemy":0.0}
		stage.impacts = {"hero":0.0,"enemy":0.0}
		stage.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		var w = minf(126,(stage.size.x-64)/2)
		var at = stage.global_position
		var enemy_rect = Rect2i(at+Vector2(stage.size.x-16-w+12,57),Vector2(w-24,123))
		var hero_rect = Rect2i(at+Vector2(24,52),Vector2(w-16,134))
		var before = root.get_texture().get_image()
		stage.elapsed += .4
		stage.attacks.hero = .24
		stage.attacks.enemy = .24
		stage.arrival = .6
		stage.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		var after = root.get_texture().get_image()
		assert(before.get_region(enemy_rect).get_data()==after.get_region(enemy_rect).get_data(),"Enemy art must remain stationary: "+character)
		assert(before.get_region(hero_rect).get_data()!=after.get_region(hero_rect).get_data(),"Hero sprite must change pose: "+character)
		stage.effects_enabled = true
		stage.class_effects = [stage.FX.from_event(m_for(scene),{"side":"hero" if character in ["warden","apothecary"] else "enemy","text":"+6 HP" if character=="apothecary" else "12","kind":"hit","skill":character})]
		stage.class_effects[0].life = .45
		stage.queue_redraw()
		await snap("icon-battle-"+character+"-0.37")
		if character=="warden":
			DirAccess.make_dir_recursive_absolute("res://build/hero-sprite37-frames")
			stage.class_effects.clear()
			for index in range(80):
				scene.model.advance(50)
				stage._process(.05)
				scene.refresh()
				await process_frame
				await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png("res://build/hero-sprite37-frames/frame-%04d.png" % index)
		stage.effects_enabled = false
		scene.model.s.settings.motion = false
		stage.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		before = root.get_texture().get_image()
		stage.elapsed += .5
		stage.attacks.hero = .05
		stage.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		after = root.get_texture().get_image()
		assert(before.get_region(hero_rect).get_data()==after.get_region(hero_rect).get_data(),"Reduced motion keeps hero still")
	root.size = Vector2i(360,800)
	scene.U.scale = 1.3
	scene.model.s.settings.motion = true
	scene.build_shell()
	scene.set_page("explore")
	await process_frame
	await process_frame
	var narrow = battle_stage(scene)
	narrow.set_process(false)
	narrow.class_effects = [narrow.FX.from_event(scene.model,{"side":"hero","text":"+6 HP","kind":"hit","skill":"apothecary"})]
	narrow.class_effects[0].life = .45
	narrow.queue_redraw()
	await snap("icon-battle-narrow-0.37")
	assert(narrow.get_global_rect().end.x<=scene.size.x)
	print("ICON BATTLE 37 PASS: all five heroes move; enemy art remains identical; reduced motion keeps sprites still")
	scene.queue_free()
	await process_frame
	quit()

func battle_stage(node):
	if node.get_script()==preload("res://ui/battle_stage.gd"): return node
	for child in node.get_children():
		var found = battle_stage(child)
		if found!=null: return found
	return null

func m_for(scene):
	return scene.model
