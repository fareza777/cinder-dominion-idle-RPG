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
		root.get_texture().get_image().save_png("res://docs/qa/screenshots/iron-cards-"+page+"-0.48.png")
	await click_at(scene.find_child("inventory",true,false).get_global_rect().get_center())
	assert(scene.page=="inventory")
	var button = find_tooltip(scene.body,scene.model.name_of(scene.model.s.gear[0].id))
	assert(button!=null)
	scene.scroller.ensure_control_visible(button)
	await process_frame
	await click_at(button.get_global_rect().get_center())
	assert(is_instance_valid(scene.dialog))
	scene.dismiss()
	scene.U.scale=1.3
	scene.refresh_shell()
	scene.set_page("inventory");scene.toast_label.hide()
	await create_timer(.3).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/qa/screenshots/iron-cards-large-0.48.png")
	await click_at(scene.find_child("character",true,false).get_global_rect().get_center())
	assert(scene.page=="character")
	print("IRON CARDS48 PASS: four phone captures (100% and 130% text); background ignores pointer input; navigation works.")
	quit()

func find_tooltip(node:Node,value:String):
	if node is Button and node.tooltip_text==value:return node
	for child in node.get_children():
		var found=find_tooltip(child,value)
		if found!=null:return found
	return null
