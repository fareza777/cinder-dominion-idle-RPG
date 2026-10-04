extends "res://tests/capture.gd"
var viewport: SubViewport
var app
const OUT="res://build/store-capture"

func draw_capture(name: String):
	app.refresh()
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	viewport.get_texture().get_image().save_png(OUT+"/"+name+".png")

func disable_stage_process(node: Node):
	if node.get_script()==preload("res://ui/battle_stage.gd"):node.set_process(false)
	for child in node.get_children():disable_stage_process(child)

func advance_stage(node: Node,delta: float):
	if node.get_script()==preload("res://ui/battle_stage.gd"):node._process(delta)
	for child in node.get_children():advance_stage(child,delta)

func find_heading(node: Node,text: String):
	if node is Label and node.text==text:return node
	for child in node.get_children():
		var found=find_heading(child,text)
		if found!=null:return found
	return null

func preset():
	app.model.s=preload("res://tests/progression54.gd").prepared().s
	app.model.s.hero.name="The Emberkeeper"
	for skill in app.model.s.xp:app.model.s.xp[skill]=RealmEconomy.threshold(112,skill)
	app.model.s.experience.welcome_done=true
	app.model.s.experience.coach_active=false
	app.model.s.settings.locale="en"
	app.model.s.settings.motion=true
	for id in RealmCards.definitions():app.model.s.bag[id]=0
	app.model.s.bag.card_ash_rat=2
	app.model.s.bag.card_hollow_hound=1
	app.model.s.bag.card_grave_thrall=1
	app.last_objective="";app.seen_levels.clear();app.seen_chapters=-1
	app.toast_label.hide()

func capture():
	DirAccess.make_dir_recursive_absolute(OUT+"/battle")
	viewport=SubViewport.new();viewport.size=Vector2i(1080,2160)
	viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	app=PreviewApp.new();viewport.add_child(app)
	app.size=Vector2(480,960);app.scale=Vector2(2.25,2.25)
	app.set_process(false);app.mode="play"
	preset()
	app.model.s.kills.erase("realm_0_9")
	app.explore_location="realm_0"
	app.model.command({"type":"queue","id":"hunt_realm_0_9","target":4})
	app.model.advance(3500)
	app.set_page("explore");app.refresh()
	await process_frame;await process_frame
	app.scroller.scroll_vertical=0
	disable_stage_process(app)
	for i in range(0 if "screens-only" in OS.get_cmdline_user_args() else 240):
		app.model.advance(34 if i%3==0 else 33)
		advance_stage(app,1.0/30)
		app.refresh()
		await process_frame
		await RenderingServer.frame_post_draw
		var img=viewport.get_texture().get_image()
		if i==76:
			img.save_png(OUT+"/01-battle.png")
			app.scroller.scroll_vertical=130
			await draw_capture("01b-battle-focus")
			app.scroller.scroll_vertical=0
		if "battle-still" in OS.get_cmdline_user_args() and i==76:
			print("STORE focused battle screenshot captured.");quit();return
		img.resize(720,1440,Image.INTERPOLATE_LANCZOS)
		img.save_jpg(OUT+"/battle/frame-%04d.jpg" % i,.94)
	if "battle-only" in OS.get_cmdline_user_args():
		print("STORE battle capture refreshed with complete location heading.")
		quit();return
	app.model.command({"type":"clear"});app.dismiss();preset()
	app.set_page("skills")
	var uid=str(app.model.s.equipped.weapon)
	app.model.gear(uid).count=60
	preload("res://ui/fusion.gd").new(app).open(uid)
	await draw_capture("02-forge")
	app.dismiss();app.set_page("character")
	await draw_capture("05-hero")
	preload("res://ui/cards.gd").new(app).collection()
	await draw_capture("03-cards")
	app.dismiss();app.skill="";app.profession_group="gather";app.set_page("skills")
	await draw_capture("04-skills")
	app.profession_group="craft";app.set_page("skills");await draw_capture("04b-crafting")
	app.explore_location="";app.set_page("explore")
	await draw_capture("06-world")
	var heading=find_heading(app,"Drowned Cathedral")
	assert(heading!=null)
	var region_card=heading.get_parent().get_parent().get_parent()
	app.scroller.scroll_vertical+=int((region_card.global_position.y-app.scroller.global_position.y)/app.scale.y)-8
	await draw_capture("06b-realms")
	app.set_page("village")
	assert(app.model.command({"type":"voyage_start","id":"journey_7","path":"vault"}))
	app.model.advance(1800000)
	preload("res://ui/voyages.gd").new(app).open()
	await draw_capture("07-journey")
	app.dismiss();app.model.command({"type":"voyage_recall"});app.model.command({"type":"voyage_claim"})
	app.set_page("character");app.relics_dialog();await draw_capture("08-relics")
	app.talents_dialog();await draw_capture("08b-talents")
	app.dismiss();app.set_page("village");await draw_capture("stronghold")
	var file=FileAccess.open(OUT+"/capture-info.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"build":"0.55.1","screenshots":"1080x2160","battle":"720x1440, 240 frames, 30fps; model and stage advance 1/30s; no campaign save writes","fixture":"prepared progressed hero, actual game UI; no new gameplay claims"},"\t"))
	print("STORE CAPTURE complete: actual UI screenshots and eight seconds of game-rendered battle.")
	quit()
