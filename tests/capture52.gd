extends "res://tests/journey_click51.gd"

func press(app,phrase: String):
	await process_frame
	await process_frame
	var button=find_button(app,phrase)
	assert(button!=null,"Missing button: "+phrase)
	var parent=button.get_parent()
	while parent!=null and not parent is ScrollContainer:parent=parent.get_parent()
	if parent!=null:parent.ensure_control_visible(button)
	await process_frame
	await process_frame
	print("POINTER52 ",phrase," disabled=",button.disabled," rect=",button.get_global_rect())
	await click_at(button.get_global_rect().get_center())
	await process_frame

func capture():
	root.size=Vector2i(412,892)
	var app=PreviewApp.new();root.add_child(app)
	app.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);app.set_process(false);app.mode="play"
	app.model.s.experience.coach_active=false
	app.set_page("explore")
	await snap("world-fresh-0.52")
	await press(app,"Enter location")
	assert(app.explore_location=="outskirts")
	await snap("outskirts-0.52")
	await press(app,"Hunt & gather loot")
	assert(is_instance_valid(app.dialog))
	await snap("hunt-prepare-0.52")
	app.dismiss()
	app.model.s=preload("res://tests/overhaul51.gd").prepared().s
	app.seen_levels.clear()
	app.model.s.experience.coach_active=false
	app.explore_location="realm_0";app.set_page("explore")
	await snap("realm-0.52")
	app.model.command({"type":"queue","id":"hunt_realm_0_0","target":1})
	app.set_page("explore");await snap("realm-battle-0.52")
	app.model.command({"type":"clear"})
	app.explore_location="";app.set_page("explore")
	await snap("world-open-0.52")
	app.skill="runecarving";app.set_page("skills")
	await snap("runecarving-0.52")
	await press(app,"Set activity")
	assert(is_instance_valid(app.dialog))
	await snap("seal-recipe-0.52");app.dismiss()
	for page in ["village","skills","inventory","character"]:
		app.skill="";app.set_page(page);await snap(page+"-0.52")
	var uid=app.model.s.equipped.weapon
	preload("res://ui/fusion.gd").new(app).open(uid)
	await snap("fusion-0.52")
	app.dismiss()
	root.size=Vector2i(360,800);app.model.s.settings.font=1.3;preload("res://ui/style.gd").scale=1.3
	for view in ["explore","skills","inventory","character"]:
		app.explore_location="realm_0";app.skill="runecarving";app.set_page(view)
		await snap(view+"-large-0.52")
	preload("res://ui/fusion.gd").new(app).open(uid)
	await snap("fusion-large-0.52")
	app.dismiss()
	var target=app.model.add_gear("copper_sword",1,true)
	app.model.gear(target).count=3
	preload("res://ui/fusion.gd").new(app).open(target)
	await press(app.dialog,"Fuse into Uncommon")
	print("FUSION52 q=",app.model.gear(target).q," reason=",RealmFusion.reason(app.model,target)," error=",app.model.error)
	await snap("fusion-success-0.52")
	if app.model.gear(target).q!=2:quit(1);return
	print("PHONE52: real-pointer location entry, hunt preparation and skill recipe; page captures at normal and 130% text.")
	quit()
