extends SceneTree

class PreviewApp extends "res://ui/main.gd":
	func _ready():
		save_blocked = true
		model.fresh(42)
		U.setup(model.data)
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
	print("UI screenshots captured.")
	quit()
