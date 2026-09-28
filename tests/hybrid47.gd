extends "res://tests/capture31.gd"

func shot(name):
	await create_timer(.7).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/qa/screenshots/hybrid-"+name+"-0.47.png")

func capture():
	root.size=Vector2i(360,800)
	var scene=PreviewApp.new();root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);scene.set_process(false)
	scene.U.scale=1.0
	scene.model.s=preload("res://tests/balance43.gd").build("warden",true).s.duplicate(true)
	for id in scene.model.data.enemies:scene.model.s.kills[id]=1
	scene.model.s.gold=1234567;scene.model.s.tutorial=true;scene.model.s.beacon=true
	scene.model.s.experience.coach_active=false
	scene.has_campaign=true
	scene.experience.menu();await shot("menu")
	scene.experience.clear();scene.mode="play"
	for page in ["village","explore","skills","inventory","character"]:
		scene.set_page(page);scene.toast_label.hide();await shot(page)
	# Click through the new tabs and direct item tile.
	button_text(scene.body,"Build").pressed.emit()
	assert(scene.hero_tab=="build")
	button_text(scene.body,"Legacy").pressed.emit()
	assert(scene.hero_tab=="legacy")
	button_text(scene.body,"Equipment").pressed.emit()
	assert(scene.hero_tab=="equipment")
	scene.set_page("inventory")
	await create_timer(.1).timeout
	var tile=find_tooltip(scene.body,scene.model.name_of(scene.model.s.gear[0].id))
	assert(tile!=null)
	scene.scroller.ensure_control_visible(tile)
	await process_frame
	await click_at(tile.get_global_rect().get_center())
	assert(is_instance_valid(scene.dialog))
	scene.dismiss()
	button_text(scene.body,"Filter").pressed.emit()
	assert(button_text(scene.body,"Find").is_visible_in_tree())
	scene.scroller.scroll_vertical=150
	await process_frame
	var remembered=scene.scroller.scroll_vertical
	scene.set_page("village");await process_frame
	scene.set_page("inventory");await process_frame;await process_frame
	assert(scene.scroller.scroll_vertical==remembered)
	scene.activity_dialog("hunt_frontier_2_5",1);await shot("hunt")
	scene.dismiss();scene.model.command({"type":"queue","id":"hunt_frontier_2_5","target":10})
	scene.set_page("explore");await shot("battle")
	scene.queue_dialog();await shot("queue")
	scene.model.command({"type":"clear"})
	scene.merchant_dialog();await shot("merchant")
	var chronicle=preload("res://ui/chronicle.gd").new(scene)
	chronicle.talents();await shot("talents")
	button_text(scene.dialog,"Guard").pressed.emit()
	assert(chronicle.talent_branch=="guard")
	scene.dialog.find_child("RouteNode_1",true,false).pressed.emit()
	assert(chronicle.chosen_talent=="endurance")
	chronicle.relics();await shot("relics")
	scene.settings_dialog();await shot("settings")
	for tab in ["Audio","Save","About","Display"]:
		button_text(scene.dialog,tab).pressed.emit()
	scene.story_dialog();await shot("story")
	preload("res://ui/frontiers.gd").new(scene).open(2);await shot("world")
	scene.dialog.find_child("RouteNode_0",true,false).pressed.emit()
	assert(button_text(scene.dialog,"Prepare hunt")!=null)
	scene.dismiss()
	scene.U.scale=1.3
	scene.refresh_shell()
	for page in ["village","character","inventory","skills"]:
		scene.set_page(page);scene.toast_label.hide();await shot(page+"-large")
		assert(scene.body.size.x<=scene.scroller.size.x+1,"Horizontal page overflow: "+page)
	scene.settings_dialog();await shot("settings-large")
	scene.experience.menu();await shot("menu-large")
	print("HYBRID47 PASS: 21 phone captures; tabs, pointer item opening, filters, scroll memory, talent selection, frontier selection, settings categories.")
	quit()

func find_tooltip(node:Node,value:String):
	if node is Button and node.tooltip_text==value:return node
	for child in node.get_children():
		var found=find_tooltip(child,value)
		if found!=null:return found
	return null
