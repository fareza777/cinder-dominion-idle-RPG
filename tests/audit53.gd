extends "res://tests/capture52.gd"
var suffix="before"
func photo(label: String):
	await create_timer(.75).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://build/audit53/"+label+"-"+suffix+".png")
func capture():
	DirAccess.make_dir_recursive_absolute("res://build/audit53")
	if "after" in OS.get_cmdline_user_args():suffix="after"
	root.size=Vector2i(412,892)
	var app=PreviewApp.new();root.add_child(app);app.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	app.set_process(false);app.mode="play";app.model.s.experience.coach_active=false
	app.experience.splash();await photo("01-splash");app.experience.menu();await photo("02-menu")
	app.experience.intro(true);await photo("03-intro");app.experience.clear();app.mode="play"
	app.experience.welcome();await photo("04-welcome");app.experience.clear();app.dismiss()
	app.model.s=preload("res://tests/overhaul51.gd").prepared().s;app.seen_levels.clear();app.model.s.experience.coach_active=false
	for skill in app.model.s.xp:app.model.s.xp[skill]=RealmEconomy.threshold(130,skill)
	for page in ["village","explore","skills","inventory","character"]:
		app.set_page(page);await photo("main-"+page)
	for tab in ["build","legacy"]:
		app.hero_tab=tab;app.set_page("character");await photo("hero-"+tab)
	for group in ["craft","arcane"]:
		app.profession_group=group;app.set_page("skills");await photo("skills-"+group)
	app.skill="runecarving";app.set_page("skills");await photo("skill-recipes")
	app.explore_location="realm_0";app.set_page("explore");await photo("local-hunts")
	var calls={"merchant":app.merchant_dialog,"journeys":func():preload("res://ui/voyages.gd").new(app).open(),"queue":app.queue_dialog,"talents":app.talents_dialog,"relics":app.relics_dialog,"runes":app.runeforge_dialog,"bestiary":func():preload("res://ui/bestiary.gd").new(app).open(),"cards":func():preload("res://ui/cards.gd").new(app).collection(),"masterworks":func():preload("res://ui/masterworks.gd").new(app).open(),"forge":func():preload("res://ui/fusion.gd").new(app).open(app.model.s.equipped.weapon),"story":app.story_dialog,"contracts":app.contracts_dialog,"depths":func():preload("res://ui/endgame.gd").new(app).depths(),"orders":app.work_orders_dialog,"about":app.experience.about}
	for key in calls:
		calls[key].call();await photo("dialog-"+key);app.dismiss()
	for section in ["display","audio","save","about"]:
		app.settings_dialog(section);await photo("settings-"+section);app.dismiss()
	root.size=Vector2i(360,800);app.model.s.settings.font=1.3;preload("res://ui/style.gd").scale=1.3
	for page in ["village","explore","skills","inventory","character"]:
		app.skill="";app.explore_location="";app.hero_tab="equipment";app.set_page(page);await photo("large-"+page)
	for key in ["journeys","forge","cards","bestiary"]:
		calls[key].call();await photo("large-"+key);app.dismiss()
	print("AUDIT53 captures ",suffix," complete")
	quit()
