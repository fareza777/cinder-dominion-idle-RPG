extends "res://tests/capture31.gd"
func capture():
	root.size=Vector2i(360,800)
	var scene=PreviewApp.new();root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);scene.set_process(false)
	scene.U.scale=1.0
	scene.model.s=preload("res://tests/balance43.gd").build("warden",true).s.duplicate(true)
	for id in scene.model.data.enemies:scene.model.s.kills[id]=1
	scene.model.s.gold=1234567;scene.model.s.tutorial=true;scene.model.s.beacon=true
	scene.model.s.experience.coach_active=false
	scene.has_campaign=true;scene.mode="play"
	var floor=scene.get_node("FortressFloor")
	assert(floor.mouse_filter==Control.MOUSE_FILTER_IGNORE and floor.texture!=null)
	for page in ["village","inventory","character"]:
		scene.set_page(page);scene.toast_label.hide()
		await create_timer(.3).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://docs/qa/screenshots/floor-"+page+"-0.48.png")
	await click_at(scene.find_child("inventory",true,false).get_global_rect().get_center())
	assert(scene.page=="inventory")
	print("FLOOR48 PASS: three phone captures; background ignores pointer input; navigation works.")
	quit()
