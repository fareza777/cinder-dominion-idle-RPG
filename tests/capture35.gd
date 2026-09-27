extends "res://tests/capture31.gd"

func check_width(node: Node, width: float):
	if node is Button and node.is_visible_in_tree(): assert(node.get_global_rect().end.x<=width+1,"Button outside phone: "+node.text)
	for child in node.get_children(): check_width(child,width)

func capture():
	root.size = Vector2i(480,960)
	var scene = PreviewApp.new()
	root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.set_process(false)
	scene.experience.splash()
	await snap("brand-splash-0.35")
	scene.experience.menu()
	await snap("brand-menu-0.35")
	assert(button_text(scene.experience.front,"New game")!=null)
	scene.experience.about()
	await snap("brand-about-0.35")
	scene.dismiss()
	scene.experience.clear()
	scene.mode = "play"
	scene.set_page("village")
	await snap("brand-stronghold-0.35")
	assert(button_text(scene,"Stronghold")!=null)
	# Branding must keep the original desktop save-directory key.
	assert(ProjectSettings.get_setting("application/config/name")=="Ashen Covenant")
	assert(OS.get_user_data_dir().ends_with("Ashen Covenant"))
	root.size = Vector2i(360,800)
	scene.U.scale = 1.3
	scene.build_shell()
	scene.set_page("village")
	await snap("brand-stronghold-narrow-0.35")
	check_width(scene,scene.size.x)
	var nav = button_text(scene,"Stronghold")
	assert(nav.size.x>=nav.get_theme_font("font").get_string_size(nav.text,HORIZONTAL_ALIGNMENT_LEFT,-1,nav.get_theme_font_size("font_size")).x+12)
	scene.has_campaign = true
	scene.experience.menu()
	await snap("brand-menu-narrow-0.35")
	check_width(scene.experience.front,scene.size.x)
	assert(button_text(scene.experience.front,"Continue journey  →")!=null)
	print("BRAND 35 PASS: splash, menu, about, header, stronghold nav, narrow large-text bounds, legacy user directory")
	scene.queue_free()
	await process_frame
	quit()
