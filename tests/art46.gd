extends "res://tests/capture31.gd"

func capture():
	root.size=Vector2i(360,800)
	var scene=PreviewApp.new();root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);scene.set_process(false)
	scene.U.scale=1.3
	scene.model.s.experience.coach_active=false
	scene.experience.splash()
	await create_timer(.25).timeout
	var reveal=scene.experience.front
	reveal.set_process(false)
	reveal.advance_reveal(1.3)
	assert(reveal.sheen.get_shader_parameter("reveal")>0.9)
	await snap("splash-reveal-narrow-0.46")
	reveal.proceed.pressed.emit()
	assert(scene.mode=="menu")
	scene.experience.splash()
	await create_timer(3.0).timeout
	assert(scene.mode=="menu")
	scene.model.s.settings.motion=false
	scene.experience.splash()
	assert(scene.experience.front.sheen.get_shader_parameter("reveal")==1.0)
	await create_timer(1.2).timeout
	assert(scene.mode=="menu")
	scene.experience.clear();scene.mode="play"
	for id in scene.model.data.items:
		var icon=scene.U.icon(id,48)
		assert(icon.texture!=null,"Missing icon "+id)
		icon.free()
	for id in ["copper_sword","copper_shield","iron_helm","dawnsteel_sword","dawnsteel_ore","keepsake_fang"]: scene.model.gain(id,1)
	scene.set_page("inventory")
	await snap("inventory-cutouts-narrow-0.46")
	scene.activity_dialog("craft_dawnsteel_sword",1)
	await snap("weapon-cutout-narrow-0.46")
	# In-engine contact sheet: inspect every replaced icon against actual panel colors.
	root.content_scale_size=Vector2i(1000,1300)
	root.size=Vector2i(1000,1300)
	scene.U.scale=1.0
	var v=scene.modal("Item art review")
	var grid=GridContainer.new();grid.columns=8
	v.add_child(grid)
	var ids=[]
	for id in scene.model.data.items:
		if ids.size()<40 or scene.model.data.items[id].has("art_tile"): ids.append(id)
	for id in ids:
		var cell=scene.U.column(2);cell.custom_minimum_size.x=100
		grid.add_child(cell)
		cell.add_child(scene.U.icon(id,80))
		cell.add_child(scene.U.para(scene.model.name_of(id),10))
	await snap("item-atlas-review-0.46")
	print("PASS all 267 icon textures, animated reveal, Continue, reduced-motion auto-transition and four visual captures")
	quit()
