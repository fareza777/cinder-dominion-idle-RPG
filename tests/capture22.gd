extends "res://tests/capture.gd"

func capture():
	root.size = Vector2i(480,960)
	var scene = PreviewApp.new()
	root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.set_process(false)
	scene.mode = "play"
	var m = scene.model
	scene.experience.welcome()
	await snap("guided-welcome-0.22")
	scene.dialog_footer.get_children()[0].emit_signal("pressed")
	await snap("guided-goals-0.22")
	assert(scene.coach.visible)
	assert(m.s.experience.coach_active)
	assert(not scene.saves.decode(scene.saves.encode(m.s),m.data).is_empty())
	for expected in ["ore","ingots","wood","sword","equip","rats"]:
		assert(m.objective().key==expected)
		var goals = scene.coach.target_in(scene,"goals")
		goals.emit_signal("pressed")
		await process_frame
		if expected=="ore": await snap("guided-task-0.22")
		scene.coach.target_in(scene.dialog,"goal_action").emit_signal("pressed")
		await process_frame
		if expected=="equip":
			await snap("guided-equip-0.22")
			scene.coach.target_in(scene.dialog,"equip").emit_signal("pressed")
			await process_frame
			await process_frame
		else:
			if expected=="ore": await snap("guided-begin-0.22")
			scene.coach.target_in(scene.dialog,"begin").emit_signal("pressed")
			if expected=="ore": await snap("guided-working-0.22")
			m.advance(180000)
		scene.refresh()
		scene.toast_label.hide()
		await process_frame
		await process_frame
	assert(m.s.tutorial and m.s.kills.ash_rat>=3)
	await snap("guided-complete-0.22")
	scene.coach.leave.emit_signal("pressed")
	assert(not m.s.experience.coach_active)
	m.fresh(42)
	scene.last_objective = ""
	scene.set_page("village")
	scene.experience.start_guidance()
	scene.U.scale = 1.3
	scene.refresh_shell()
	scene.toast_label.hide()
	root.size = Vector2i(360,800)
	await snap("guided-narrow-0.22")
	scene.coach.target_in(scene,"goals").emit_signal("pressed")
	scene.coach.target_in(scene.dialog,"goal_action").emit_signal("pressed")
	await snap("guided-narrow-begin-0.22")
	scene.coach.finish()
	scene.dismiss()
	var music = preload("res://ui/audio_director.gd").new()
	music.app = scene
	scene.music = music
	scene.add_child(music)
	await create_timer(.2).timeout
	assert(music.mood=="hearth")
	for track in music.tracks.values(): assert(track.loop_mode==AudioStreamWAV.LOOP_FORWARD)
	m.s.fight = {"enemy":"ash_rat"}
	await create_timer(2.4).timeout
	assert(music.mood=="wilds")
	m.s.settings.music = 0
	await create_timer(.1).timeout
	for voice in music.voices: assert(voice.volume_db<=-79)
	scene.paused = true
	await create_timer(.1).timeout
	assert(music.voices[music.active].stream_paused)
	print("UI: six real guided tasks completed; skip, restart, save round-trip, narrow layout, music loop/mute/pause verified.")
	quit()
