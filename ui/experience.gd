extends RefCounted

const U = preload("res://ui/style.gd")
const Brand = preload("res://ui/brand.gd")
const STORE_URL = "" # Set only after a real public listing exists.
const VERSION = "0.40.0"
var app
var front: Control
var cinematic_page = 0
var cinematic_replay = false

func _init(owner):
	app = owner

func clear():
	if is_instance_valid(front):
		if front.get_parent()==app: app.remove_child(front)
		front.queue_free()
	front = null

func screen() -> VBoxContainer:
	app.dismiss()
	clear()
	front = Control.new()
	front.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	front.z_index = 5
	app.add_child(front)
	var art = TextureRect.new()
	art.texture = load("res://assets/art/cinderwatch.png")
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	front.add_child(art)
	if app.model.s.settings.motion:
		art.pivot_offset = app.size*.5
		art.create_tween().tween_property(art,"scale",Vector2(1.1,1.1),14.0).set_trans(Tween.TRANS_SINE)
	var shade = ColorRect.new()
	shade.color = Color(.025,.04,.055,.78)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	front.add_child(shade)
	var sparks = Control.new()
	sparks.set_script(load("res://ui/atmosphere.gd"))
	sparks.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sparks.motion = app.model.s.settings.motion
	sparks.mouse_filter = Control.MOUSE_FILTER_IGNORE
	front.add_child(sparks)
	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left","right"]: margin.add_theme_constant_override("margin_"+side,28)
	for side in ["top","bottom"]: margin.add_theme_constant_override("margin_"+side,48)
	front.add_child(margin)
	var scroll = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	margin.add_child(scroll)
	var v = U.column(16)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(v)
	if app.model.s.settings.motion:
		v.modulate.a = 0
		v.create_tween().tween_property(v,"modulate:a",1.0,.6)
	return v

func gap(parent, height):
	var empty = Control.new()
	empty.custom_minimum_size.y = height
	parent.add_child(empty)

func title(parent, value, size=42):
	var label = U.para(value,size,U.TEXT)
	label.add_theme_font_override("font",U.title_font)
	parent.add_child(label)

func splash():
	app.mode = "boot"
	var v = screen()
	gap(v,90)
	v.add_child(Brand.emblem(Vector2(0,220)))
	title(v,Brand.SHORT,34)
	v.get_child(v.get_child_count()-1).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var genre = U.label("IDLE RPG",16,U.GOLD)
	genre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(genre)
	var tagline = U.para("Hunt. Forge. Rise.",16,U.TEXT)
	tagline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(tagline)
	v.add_child(U.progress(1,1,U.GOLD,2))
	app.get_tree().create_timer(1.6).timeout.connect(func():
		if app.mode=="boot": menu())

func menu():
	if app.mode=="play": app.persist()
	app.mode = "menu"
	var v = screen()
	v.add_theme_constant_override("separation",10)
	v.add_child(Brand.emblem(Vector2(0,144)))
	title(v,"CINDER\nDOMINION",50)
	v.get_child(v.get_child_count()-1).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var genre = U.label("DARK FANTASY · IDLE RPG",12,U.GOLD)
	genre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(genre)
	var tagline = U.para("Hunt. Forge. Rise.",17,U.TEXT)
	tagline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(tagline)
	gap(v,8)
	if app.has_campaign:
		var card = U.card(v,14,U.GOLD.darkened(.6))
		card.add_child(U.label("YOUR JOURNEY",10,U.GOLD))
		card.add_child(U.para(app.model.objective().title,19,U.TEXT))
		card.add_child(U.para("Cinderwatch  ·  %d gold  ·  %d queued activities" % [int(app.model.s.gold),app.model.s.queue.size()],12))
		v.add_child(U.button("Continue journey  →",app.enter_world,true))
	v.add_child(U.button("New game",new_game,not app.has_campaign))
	v.add_child(U.button("How to play",handbook))
	v.add_child(U.button("Settings",app.settings_dialog))
	if app.save_blocked:
		v.add_child(U.para("Your saved progress could not be loaded. Import a backup from Settings. Existing files have been preserved.",13,U.RED))
	gap(v,12)
	v.add_child(U.para("FREE TO PLAY\nBuild "+VERSION+" · Adventure preview",11,U.MUTED))
	v.add_child(U.button("Exit game",func():
		app.persist()
		app.get_tree().quit()))

func new_game():
	if not app.has_campaign and not app.save_blocked:
		begin_new_game()
		return
	var v = app.modal("Begin a new journey?")
	v.add_child(U.para("This replaces your current journey. A separate backup of the current progress will be saved on this device before starting.",17,U.TEXT))
	v.add_child(U.para("Equipment, skill levels, gold and quest progress start over. Display and audio preferences are kept.",14))
	v.add_child(U.button("Keep my current journey",app.dismiss,true))
	v.add_child(U.button("Back up progress & start new",begin_new_game))

func begin_new_game():
	preload("res://ui/character_creation.gd").new(app).open()

func commit_new_game(hero_id: String, hero_name: String):
	if hero_id not in RealmCharacters.ALL or not RealmCharacters.valid_name(hero_name): return
	if app.has_campaign:
		app.persist()
		DirAccess.make_dir_recursive_absolute("user://archives")
		var path = "user://archives/before-new-game-%d-%d.json" % [app.now_ms(),Time.get_ticks_usec()]
		var backup = FileAccess.open(path,FileAccess.WRITE)
		if backup==null:
			app.toast("Could not create a backup. Your current journey has not been replaced.")
			return
		backup.store_string(app.saves.encode(app.model.s))
		backup.flush()
		backup.close()
		if app.saves.decode(FileAccess.get_file_as_string(path),app.model.data).is_empty():
			app.toast("Backup verification failed. Your current journey is unchanged.")
			return
	var previous = app.model.s.duplicate(true)
	var settings = app.model.s.settings.duplicate(true)
	app.model.fresh(int(Time.get_unix_time_from_system()))
	app.model.command({"type":"hero_create","id":hero_id,"name":hero_name})
	for key in ["locale","font","motion","battery","music","sfx"]: app.model.s.settings[key] = settings[key]
	app.model.s.wall = app.now_ms()
	if not app.saves.write_state(app.model.s,app.model.data):
		app.model.s = previous
		app.toast("Could not save the new journey. Check device storage and try again.")
		return
	app.has_campaign = true
	app.save_blocked = false
	app.skill = ""
	app.filter = "all"
	app.search_text = ""
	app.last_objective = ""
	app.enter_world()

func intro(replay=false):
	if app.mode=="play": app.persist()
	app.mode = "intro"
	cinematic_replay = replay
	cinematic_page = 0
	intro_scene()

func intro_scene():
	var scenes = [
		["I · THE LONG NIGHT","When the bells rang,\nthe fires went out.","No one remembers which bell rang first. By dawn, the roads were empty, and every hearth in the valley had gone cold.",7],
		["II · THE LAST STRONGHOLD","Cinderwatch\nstill stands.","At Cinderwatch, someone kept a fire alive. Now strangers share its warmth, mend the walls, and wait for the roads to open.",0],
		["III · YOUR COVENANT","Take up the ember.","You came here looking for shelter. Tomorrow, you will take a blade beyond the walls. Somewhere in the dark, the Bellkeeper is still ringing.",0]
	]
	var scene = scenes[cinematic_page]
	var v = screen()
	var top = U.row()
	v.add_child(top)
	top.add_child(U.label(scene[0],10,U.GOLD))
	top.add_child(U.spacer())
	top.add_child(U.button("Skip intro",finish_intro))
	gap(v,38)
	var portrait = TextureRect.new()
	var atlas = AtlasTexture.new()
	atlas.atlas = load("res://assets/art/cinematic.png")
	var panel_height = atlas.atlas.get_height()/3.0
	atlas.region = Rect2(0,cinematic_page*panel_height,atlas.atlas.get_width(),panel_height)
	atlas.filter_clip = true
	portrait.texture = atlas
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	portrait.custom_minimum_size = Vector2(200,260)
	v.add_child(portrait)
	if app.model.s.settings.motion:
		portrait.modulate.a = .1
		portrait.create_tween().tween_property(portrait,"modulate:a",1.0,1.8)
	title(v,scene[1],38)
	v.add_child(U.para(scene[2],17,U.TEXT))
	gap(v,18)
	v.add_child(U.label("%02d / 03   —   THE LAST EMBER" % (cinematic_page+1),10,U.GOLD))
	v.add_child(U.button("Enter Cinderwatch  →" if cinematic_page==2 else "Continue  →",func():
		if cinematic_page==2: finish_intro()
		else:
			cinematic_page += 1
			intro_scene(),true))
	if cinematic_page>0: v.add_child(U.button("Previous scene",func():
		cinematic_page -= 1
		intro_scene()))

func finish_intro():
	if cinematic_replay: menu()
	else:
		# A new journey has no active tasks; reading the intro is not offline play.
		app.model.s.wall = app.now_ms()
		app.enter_world()

func welcome(_index=0):
	app.ensure_coach()
	var v = app.modal("Learn by playing",false)
	v.add_child(U.icon("copper_sword",88))
	title(v,"Your first sword. Your first hunt.",28)
	v.add_child(U.para("Follow the gold highlight. Each step shows exactly where to tap.",17,U.TEXT))
	v.add_child(U.para("Gather → Forge → Equip → Hunt",16,U.GOLD))
	app.modal_action("Show me the way",start_guidance)
	v.add_child(U.button("Explore on my own",func():
		app.model.s.experience.welcome_done = true
		app.model.s.experience.coach_active = false
		app.persist()
		app.dismiss()))

func start_guidance():
	app.ensure_coach()
	app.model.s.experience.welcome_done = true
	app.model.s.experience.coach_active = true
	app.persist()
	app.dismiss()
	app.play_cue("guide")

func guide():
	var o = app.model.objective()
	var v = app.modal("Objectives")
	app.dialog.set_meta("journey_guide",true)
	title(v,o.title,28)
	app.dynamic(v,func(): return "%d / %d" % [mini(int(app.model.objective().current),int(o.goal)),int(o.goal)],18,U.GOLD)
	var bar = U.progress(o.current,o.goal,U.GOLD,7)
	v.add_child(bar)
	app.dialog_callbacks.append(func():
		if is_instance_valid(bar): bar.value = mini(int(app.model.objective().current),int(o.goal)))
	if not app.model.s.queue.is_empty():
		v.add_child(U.button("View active queue",app.queue_dialog))
	v.add_child(U.label("MILESTONES",11,U.GOLD))
	for step in RealmJourney.steps(app.model):
		var done = step.current>=step.goal
		v.add_child(U.para(("✓  " if done else "○  ")+step.title,14,U.GREEN if done else U.MUTED))
		if not done: break
	v.add_child(U.button("Farm & upgrade",app.progress_dialog))
	v.add_child(U.button("How to play",handbook))
	var next = app.modal_action(o.action,act_on_goal)
	next.set_meta("coach_target","goal_action")
	if int(o.index)<=6: v.add_child(U.button("Turn on step-by-step guidance",start_guidance))

func act_on_goal():
	var o = app.model.objective()
	app.dismiss()
	if o.kind=="equip":
		app.set_page("inventory")
		for g in app.model.s.gear:
			if g.id=="copper_sword":
				app.item_dialog(g.uid)
				return
		app.sources_dialog("copper_sword")
	elif o.kind=="complete": app.world_dialog()
	elif o.kind=="level":
		app.skill = "smithing"
		app.set_page("skills")
		app.planner_dialog("craft_copper_ingot",clampi(RealmJourney.smithing_batch(app.model),1,100))
	else:
		var a = app.model.data.activities[o.activity]
		if a.kind=="combat": app.set_page("explore")
		else:
			app.skill = a.skill
			app.set_page("skills")
		app.activity_dialog(o.activity,maxi(1,int(o.goal)-int(o.current)))

func survival():
	var v = app.modal("Food & survival")
	v.add_child(U.para("1. Catch raw minnows in Skills → Fishing.\n\n2. Cook them in Skills → Cooking. Raw food cannot heal you.\n\n3. In Bag, choose Auto-heal on the cooked food you want to use.\n\n4. In Hero, check the selected food and healing threshold.\n\n5. Equip armor before tougher fights. Retreat stops the entire queue. HP recovers outside combat.",17,U.TEXT))
	app.dynamic(v,func(): return "Selected: %s ×%d · heals %d HP · used at %d%% HP" % [app.model.name_of(app.model.s.settings.food),app.model.count(app.model.s.settings.food),RealmCombat.food_heal(app.model,app.model.s.settings.food),int(app.model.s.settings.threshold*100)],15,U.GOLD)
	v.add_child(U.button("Go fishing",func():
		app.dismiss()
		app.skill = "fishing"
		app.set_page("skills")))
	v.add_child(U.button("Open cooking",func():
		app.dismiss()
		app.skill = "cooking"
		app.set_page("skills")))

func handbook():
	var v = app.modal("How to play")
	for section in [
		["01 · Follow the Journey","Your goal is to restore the beacon by defeating the Bellkeeper. The Journey guide breaks this into 12 objectives and remains available at the top of every game screen."],
		["02 · Gather and craft","Open Skills. Gather ore, wood and fish; smelt ore, forge equipment and cook food. Use Plan materials & craft automatically to preview and queue a complete supply chain, including missing raw materials."],
		["03 · Equip your upgrades","Crafted gear goes to Bag. Open an item and choose Equip item. Crafting alone does not improve your stats. Lock or favorite items you want to keep."],
		["04 · Fight automatically","Open Explore, choose an unlocked enemy and a number of fights. Each victory brings gold, loot and melee XP. Plan a longer hunt to estimate time and supplies, or try one fight first. Return after this fight finishes the current battle and cancels the rest of your queue. Selected cooked food heals you automatically while available."],
		["05 · Plan your time","Queue holds up to 20 tasks. Only the first runs. Tasks wait when ingredients or levels are missing. Sources shows how to get materials; Queue lets you cancel blocked tasks."],
		["06 · Return to your rewards","Your saved queue continues for up to 24 hours while away. You receive a report when you return. Leave a task running before you go; an empty queue earns no gathering or combat rewards."],
		["07 · Build your stronghold","Stronghold contracts reward milestones with gold, food and scraps. Claim completed contracts, then Rebuild Cinderwatch to improve production speed, armor and recovery. Hero and Explore let you choose Vanguard, Warden or Reaver before a hunt."],
		["08 · Grow beyond Chapter I","After First Supplies, earn talent points from melee XP and awaken relics with guaranteed fragments. Unfinished bounties carry over without streak loss. After the Bellkeeper, the World map opens 15 expedition tiers with stronger foes, iron loot and targeted relic farms."],
		["09 · Make a dependable upgrade","After First Supplies, visit Stronghold → Armory → Ember Workshop. Spend ingots, scraps and gold to refine one copper or iron piece by one quality step. Refinement is guaranteed, up to Legendary. Higher qualities require more Smithing experience. Equipped slots and saved builds follow the improved piece."],
		["10 · Keep more than one answer","In Hero, save a complete loadout with your gear, fighting style, talents, relic, rune, food, potion and healing threshold. Apply it outside combat. Loadouts do not create supplies: check your pack before a long hunt."],
		["11 · Read the road","Hunt reports record completed, recalled and defeated hunting orders, including time away. Gold, loot and fragments are already delivered. Review food consumption, refine your gear or adjust your build before returning."],
		["12 · Find your way around","Stronghold: your objective, Journey, Armory and Supplies. Explore: enemies and combat. Skills: gathering and crafting. Bag: equipment and supplies. Hero: build choices and Settings. The Journey guide remains at the top of every screen."]
	]:
		v.add_child(U.para(section[0],20,U.GOLD))
		v.add_child(U.para(section[1],16,U.TEXT))
	if app.mode=="play": v.add_child(U.button("Show my next objective",guide,true))

func archives():
	var v = app.modal("Previous journeys")
	v.add_child(U.para("Starting a New Game creates a separate backup here. Choose a journey to review before replacing current progress.",15))
	if not DirAccess.dir_exists_absolute("user://archives"):
		v.add_child(U.para("No previous journeys yet. Export a backup from Settings whenever you want to keep a separate copy.",15))
		return
	var files = DirAccess.get_files_at("user://archives")
	files.sort()
	files.reverse()
	for file in files:
		if not file.ends_with(".json"): continue
		var path = "user://archives/"+file
		var when = Time.get_datetime_string_from_unix_time(FileAccess.get_modified_time(path)).replace("T"," ")
		v.add_child(U.button("Journey saved "+when,func():
			var state = app.saves.decode(FileAccess.get_file_as_string(path),app.model.data)
			if state.is_empty(): app.toast("This backup could not be read. Current progress is unchanged.")
			else: app.confirm_restore(state)))

func about():
	var v = app.modal("About Cinder Dominion")
	title(v,"Keep the last fire burning.",30)
	v.add_child(U.para("Cinder Dominion: Idle RPG is an independent dark fantasy idle RPG about gathering, crafting and preparing for the battles ahead.\n\nVersion "+VERSION+" · Adventure preview\nChapter I + 3 expedition regions · 15 expedition tiers + 3 guardian trials\n7 optional guardians + Hollow Depths\n5 playable characters · class skills · customizable attributes\n\nFree to play. No purchases are active in this preview. Settings includes optional Android test ads. Cosmetics and content expansions are planned for future releases.",16,U.TEXT))
	v.add_child(U.para("Art generated for this project with OpenAI image generation. Original synthesized audio. Fonts: Manrope and Cormorant Garamond. Built with Godot.",14))
	v.add_child(U.button("Credits & open-source licenses",licenses))
	v.add_child(U.button("Replay cinematic intro",func(): intro(true)))

func licenses():
	var v = app.modal("Credits & licenses")
	for path in ["res://assets/GODOT-LICENSE.txt","res://assets/fonts/manrope-OFL.txt","res://assets/fonts/cormorantgaramond-OFL.txt","res://assets/GODOT-COPYRIGHT.txt","res://addons/admob/LICENSE"]:
		v.add_child(U.para(FileAccess.get_file_as_string(path),12))

func share():
	var v = app.modal("Share Cinder Dominion")
	var message = "I'm playing Cinder Dominion: Idle RPG. Hunt rare enemies, forge powerful gear and explore the dark. Free to play."
	if STORE_URL!="": message += "\n"+STORE_URL
	else: message += "\nCurrently in private preview; a public download link is not available yet."
	v.add_child(U.para(message,17,U.TEXT))
	v.add_child(U.para("Review the message, then choose how to share it. Nothing is sent automatically.",13))
	if OS.get_name()=="Android": v.add_child(U.button("Choose an app to share…",func(): share_native(message),true))
	v.add_child(U.button("Copy message",func():
		DisplayServer.clipboard_set(message)
		app.toast("Share message copied.")))

func share_native(message: String):
	if not Engine.has_singleton("AndroidRuntime") or not Engine.has_singleton("JavaClassWrapper"):
		DisplayServer.clipboard_set(message)
		app.toast("Share message copied. Paste it into your preferred app.")
		return
	var wrapper = Engine.get_singleton("JavaClassWrapper")
	var intent_class = wrapper.wrap("android.content.Intent")
	var intent = intent_class.Intent()
	intent.setAction("android.intent.action.SEND")
	intent.setType("text/plain")
	intent.putExtra("android.intent.extra.TEXT",message)
	var chooser = intent_class.createChooser(intent,"Share Cinder Dominion")
	Engine.get_singleton("AndroidRuntime").getActivity().startActivity(chooser)
	if wrapper.get_exception()!=null:
		DisplayServer.clipboard_set(message)
		app.toast("Sharing is unavailable here. The message was copied instead.")

func rate():
	var v = app.modal("Rate Cinder Dominion")
	if STORE_URL=="":
		v.add_child(U.para("Thank you for playing.",26,U.GOLD))
		v.add_child(U.para("This preview is not published on Google Play yet, so store ratings are not available. Once the public listing is live, this button will open the official page.",17,U.TEXT))
		v.add_child(U.para("For this build, share your playtest feedback with the person who gave you the APK. Useful feedback includes what you expected, what happened, and a screenshot.",15))
	else: v.add_child(U.button("Open Google Play",func(): OS.shell_open(STORE_URL),true))
