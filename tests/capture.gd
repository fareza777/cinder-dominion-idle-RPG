extends SceneTree

class PreviewApp extends "res://ui/main.gd":
	func persist():
		pass
	func _notification(_what):
		pass
	func _ready():
		save_blocked = false
		model.fresh(42)
		U.setup(model.data)
		experience = preload("res://ui/experience.gd").new(self)
		pages = Pages.new(self)
		build_shell()
		set_page("village")

func _init():
	call_deferred("capture")

func capture():
	root.size = Vector2i(480,960)
	var scene = PreviewApp.new()
	root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	DirAccess.make_dir_recursive_absolute("res://docs/qa/screenshots")
	for page in ["village","skills","inventory","character","explore"]:
		scene.set_page(page)
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://docs/qa/screenshots/"+page+".png")
	scene.model.command({"type":"queue","id":"hunt_ash_rat","target":100})
	scene.set_page("explore")
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/qa/screenshots/combat.png")
	scene.model.command({"type":"clear"})
	scene.planner_dialog("craft_copper_sword",1)
	await snap("supply-planner-0.3")
	scene.tactics_dialog()
	await snap("fighting-styles-0.3")
	scene.contracts_dialog()
	await snap("contracts-0.3")
	scene.refuge_dialog()
	await snap("refuge-upgrades-0.3")
	scene.dismiss()
	scene.model.fresh(42)
	scene.mode = "menu"
	scene.experience.menu()
	await snap("menu")
	scene.experience.splash()
	await snap("splash")
	scene.experience.intro(false)
	await snap("intro")
	scene.experience.cinematic_page = 2
	scene.experience.intro_scene()
	await snap("intro-oath")
	scene.experience.clear()
	scene.mode = "play"
	scene.set_page("village")
	scene.experience.welcome()
	await snap("onboarding")
	scene.experience.guide()
	await snap("guide")
	scene.activity_dialog("mine_copper",4)
	await snap("guided-activity")
	scene.settings_dialog()
	await snap("settings")
	scene.dismiss()
	scene.has_campaign = true
	scene.experience.menu()
	await snap("continue-menu")
	scene.U.scale = 1.3
	scene.refresh_shell()
	scene.experience.guide()
	await snap("large-text-guide")
	print("UI screenshots captured.")
	quit()

func snap(name: String):
	await create_timer(.7).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/qa/screenshots/"+name+".png")
