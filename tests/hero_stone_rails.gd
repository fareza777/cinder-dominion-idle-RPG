extends "res://tests/capture31.gd"
func capture():
	root.size=Vector2i(360,800)
	var scene=PreviewApp.new();root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);scene.set_process(false)
	scene.model.s=preload("res://tests/balance43.gd").build("warden",true).s.duplicate(true)
	scene.model.s.experience.coach_active=false
	scene.mode="play"
	for scale in [1.0,1.3]:
		scene.U.scale=scale
		scene.refresh_shell();scene.set_page("character");scene.toast_label.hide()
		var stage=scene.find_child("HeroEquipment",true,false)
		stage.rail_texture=load("res://assets/art/fortress-floor-0.48.png")
		stage.queue_redraw()
		await create_timer(.3).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://docs/qa/screenshots/hero-stone-rails-%d.png" % int(scale*100))
		var slot=scene.find_child("Slot_weapon",true,false)
		await click_at(slot.get_global_rect().get_center())
		assert(is_instance_valid(scene.dialog))
		scene.dismiss()
	print("HERO STONE RAILS PASS: normal/large captures and real-pointer weapon slot opening")
	quit()
