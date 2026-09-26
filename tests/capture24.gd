extends "res://tests/capture.gd"
func click_at(point: Vector2):
	var e = InputEventMouseButton.new()
	e.position = point
	e.button_index = MOUSE_BUTTON_LEFT
	e.pressed = true
	root.push_input(e,true)
	e = e.duplicate()
	e.pressed = false
	root.push_input(e,true)
	await process_frame
func capture():
	root.size = Vector2i(480,960)
	var scene = PreviewApp.new()
	root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.set_process(false)
	scene.mode = "play"
	scene.experience.start_guidance()
	await snap("focus-tap-0.24")
	var nav = scene.find_child("inventory",true,false)
	await click_at(nav.get_global_rect().get_center())
	assert(scene.page=="village")
	await click_at(scene.coach.target_in(scene,"goals").get_global_rect().get_center())
	assert(is_instance_valid(scene.dialog))
	await process_frame
	await click_at(scene.coach.target_in(scene.dialog,"goal_action").get_global_rect().get_center())
	await snap("focus-begin-0.24")
	await click_at(scene.coach.target_in(scene.dialog,"begin").get_global_rect().get_center())
	assert(scene.model.s.queue[0].target==4)
	await process_frame
	await click_at(scene.coach.leave.get_global_rect().get_center())
	assert(not scene.model.s.experience.coach_active)
	scene.dismiss()
	scene.toast_label.hide()
	scene.music = preload("res://ui/audio_director.gd").new()
	scene.music.app = scene
	scene.add_child(scene.music)
	preload("res://ui/sound_room.gd").new(scene).open()
	scene.music.preview("crown",scene.dialog)
	await create_timer(2.3).timeout
	scene.refresh()
	assert(scene.music.mood=="crown")
	await snap("sound-room-0.24")
	scene.U.scale = 1.3
	root.size = Vector2i(360,800)
	preload("res://ui/sound_room.gd").new(scene).open()
	await snap("sound-room-narrow-0.24")
	scene.dismiss()
	await create_timer(2.3).timeout
	assert(scene.music.preview_mood=="" and scene.music.mood=="hearth")
	print("UI: dimmed input blocked, highlighted Goals/action/Begin accept actual pointer events, Skip exits; music preview returns to automatic mood.")
	quit()
