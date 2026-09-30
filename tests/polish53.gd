extends "res://tests/audit53.gd"
func capture():
	suffix="final"
	root.size=Vector2i(412,892)
	var app=PreviewApp.new();root.add_child(app);app.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	app.set_process(false);app.mode="play";app.model.s.experience.coach_active=false
	preload("res://ui/character_creation.gd").new(app).open();await photo("creation");app.dismiss();app.experience.clear()
	app.model.s=preload("res://tests/overhaul51.gd").prepared().s;app.seen_levels.clear();app.model.s.experience.coach_active=false
	app.workshop_dialog();await photo("forge-hub")
	await press(app.dialog,"Refine equipment");assert(find_button(app.dialog,"Refine equipment")==null);app.dismiss()
	app.workshop_dialog();await press(app.dialog,"Star Blade");assert(find_button(app.dialog,"Fuse into")!=null);app.dismiss()
	app.skill="";app.set_page("skills");await press(app,"Tools & equipment");await photo("profession-services")
	await press(app.dialog,"Rarity forge");assert(find_button(app.dialog,"Refine equipment")!=null);app.dismiss()
	app.world_dialog();assert(app.page=="explore" and app.explore_location=="")
	await press(app,"Enter location");assert(app.explore_location=="outskirts")
	var cards=preload("res://ui/cards.gd").new(app)
	cards.collection();await photo("cards-framed");app.dismiss()
	cards.detail("card_ash_rat");await photo("rat-card-framed");app.dismiss()
	cards.collection_filter="realm_6";cards.collection();await photo("realm-cards")
	assert(find_button(app.dialog,"Firmament Scavenger")!=null)
	await press(app.dialog,"Firmament Scavenger");assert(find_button(app.dialog,"Choose equipment")!=null);await photo("realm-card-detail");app.dismiss()
	preload("res://ui/bestiary.gd").new(app).open("realm_5");await photo("realm-bestiary");app.dismiss()
	for n in [0,9]:
		app.model.command({"type":"queue","id":"hunt_realm_0_%d" % n,"target":1})
		app.explore_location="realm_0";app.set_page("explore");await photo("battle-"+str(n))
		app.model.command({"type":"clear"})
	root.size=Vector2i(360,800);app.model.s.settings.font=1.3;preload("res://ui/style.gd").scale=1.3
	cards.collection_filter="realm_6";cards.collection();await photo("large-realm-cards");app.dismiss()
	app.workshop_dialog();await photo("large-forge-hub");app.dismiss()
	app.skill="runecarving";app.set_page("skills");await photo("large-recipes")
	app.set_page("inventory");await photo("large-bag-framed")
	app.set_page("village");await photo("large-stronghold")
	print("POLISH53: pointer Forge/refinement/fusion, profession services, location entry and card detail passed; 15 focused captures.")
	quit()
