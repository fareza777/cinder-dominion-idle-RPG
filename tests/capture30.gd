extends "res://tests/capture24.gd"

func capture():
	root.size = Vector2i(480,960)
	var scene = PreviewApp.new()
	root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.set_process(false)
	scene.mode = "play"
	scene.experience.welcome()
	await snap("onboarding-welcome-0.30")
	assert(scene.dialog.get_child(0).color.a==0)
	scene.experience.start_guidance()
	scene.refresh_shell()
	await snap("onboarding-start-0.30")
	await click_at(scene.find_child("inventory",true,false).get_global_rect().get_center())
	assert(scene.page=="village")
	for expected in ["ore","ingots","wood","sword","equip","rats"]:
		assert(scene.model.objective().key==expected)
		await click_at(scene.coach.target_in(scene,"goals").get_global_rect().get_center())
		await create_timer(.2).timeout
		await click_at(scene.coach.target_in(scene.dialog,"goal_action").get_global_rect().get_center())
		await create_timer(.2).timeout
		if expected=="ore": await snap("onboarding-begin-0.30")
		var target = "equip" if expected=="equip" else "begin"
		await click_at(scene.coach.target_in(scene.dialog,target).get_global_rect().get_center())
		await create_timer(.2).timeout
		if expected!="equip": scene.model.advance(180000)
		scene.refresh()
		scene.toast_label.hide()
		await create_timer(.2).timeout
	assert(scene.model.objective().index>6)
	# Real sessions preserve the coach across shell rebuilds (new game/settings).
	scene.refresh_shell()
	await create_timer(.3).timeout
	await snap("onboarding-complete-0.30")
	await click_at(scene.coach.leave.get_global_rect().get_center())
	if scene.model.s.experience.coach_active:
		push_error("REGRESSION: completion pointer tap did not dismiss onboarding")
		quit(1)
		return
	assert(not scene.coach.visible)
	await click_at(scene.find_child("inventory",true,false).get_global_rect().get_center())
	assert(scene.page=="inventory")
	assert(not scene.saves.decode(scene.saves.encode(scene.model.s),scene.model.data).experience.coach_active)
	scene.model.s.experience.coach_active = true
	scene.U.scale = 1.3
	root.size = Vector2i(360,800)
	scene.refresh_shell()
	await snap("onboarding-complete-narrow-0.30")
	await click_at(scene.coach.leave.get_global_rect().get_center())
	assert(not scene.model.s.experience.coach_active)
	scene.model.fresh(42)
	scene.last_objective = ""
	scene.set_page("village")
	scene.experience.start_guidance()
	scene.refresh_shell()
	await snap("onboarding-narrow-0.30")
	await click_at(scene.coach.leave.get_global_rect().get_center())
	assert(not scene.model.s.experience.coach_active)
	print("Onboarding real-pointer six-step walkthrough, shell rebuild, completion, restored navigation, saved dismissal and narrow Skip PASS")
	quit()
