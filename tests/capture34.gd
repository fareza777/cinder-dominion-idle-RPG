extends "res://tests/capture31.gd"

func check_bounds(node, width: float):
	if node is Button and node.is_visible_in_tree():
		assert(node.get_global_rect().end.x<=width+1,"Button exceeds phone width: "+node.text)
	for child in node.get_children(): check_bounds(child,width)

func capture():
	root.size = Vector2i(480,960)
	var scene = PreviewApp.new()
	root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.set_process(false)
	scene.mode = "play"
	scene.ads = preload("res://services/admob.gd").new()
	scene.ads.app = scene
	scene.add_child(scene.ads)
	scene.model.s = preload("res://tests/balance34.gd").build("warden","max").s.duplicate(true)
	scene.model.s.experience.welcome_done = true
	scene.set_page("village")
	scene.toast_label.hide()
	var hub = preload("res://ui/endgame.gd").new(scene)
	for page_name in ["open","locations","forge","builds","routes","depths","contracts","assistance"]:
		hub.call(page_name)
		await snap("endgame-"+page_name+"-0.34")
		check_bounds(scene.dialog,scene.size.x)
	# Real button dispatch: choosing a route and tracking a relic.
	hub.routes()
	await process_frame
	await click_at(button_text(scene.dialog,"Choose route").get_global_rect().get_center())
	assert(RealmEndgame.route(scene.model)=="safe")
	hub.forge()
	await process_frame
	await click_at(button_text(scene.dialog,"Track relic").get_global_rect().get_center())
	assert(RealmEndgame.state(scene.model).target=="relic_0")
	scene.U.scale = 1.3
	root.size = Vector2i(360,800)
	for page_name in ["locations","builds","depths","assistance"]:
		hub.call(page_name)
		await snap("endgame-"+page_name+"-narrow-0.34")
		check_bounds(scene.dialog,scene.size.x)
	scene.dismiss()
	scene.U.scale = 1.0
	root.size = Vector2i(480,960)
	scene.model.command({"type":"queue","id":"hunt_secret_0","target":1})
	scene.model.advance(8000)
	scene.set_page("explore")
	await snap("superboss-battle-0.34")
	print("UI 34 PASS: eight pages, four narrow large-text layouts, actual route/target clicks and superboss battle")
	scene.queue_free()
	await process_frame
	quit()
