extends Control

const U = preload("res://ui/style.gd")
const Pages = preload("res://ui/pages.gd")
const Brand = preload("res://ui/brand.gd")
var model = RealmModel.new()
var saves = RealmSave.new()
var page = "village"
var skill = ""
var show_locked_recipes = false
var filter = "all"
var search_text = ""
var inventory_sort = 0
var inventory_slot = "all"
var inventory_page = 0
var body: VBoxContainer
var scroller: ScrollContainer
var hp_label: Label
var wallet: VBoxContainer
var activity_label: Label
var activity_sub: Label
var activity_progress: ProgressBar
var toast_label: Label
var dialog: Control
var dialog_footer: VBoxContainer
var hud: VBoxContainer
var pulse = 0.0
var save_timer = 0.0
var ui_timer = 0.0
var fraction_ms = 0.0
var paused = false
var recovering = false
var recovery_cancelled = false
var save_blocked = false
var update_callbacks: Array[Callable] = []
var dialog_callbacks: Array[Callable] = []
var pages
var music: AudioStreamPlayer
var coach: Control
var ads: Node
var banner_space: Control
var effect: AudioStreamPlayer
var experience
var mode = "play"
var has_campaign = false
var last_objective = ""
var objective_label: Label
var rebuild_pending = false
var last_back_ms = -1000
var last_hunt_audio = -1
var seen_levels = {}
var seen_chapters = -1

func _ready():
	DisplayServer.window_set_title(Brand.TITLE)
	get_tree().auto_accept_quit = false
	get_tree().quit_on_go_back = false
	var loaded = saves.read_state(model.data)
	if not loaded.is_empty():
		model.s = loaded
		has_campaign = true
		if not model.s.has("experience"):
			model.s.experience = {"version":2,"welcome_done":false}
			model.s.settings.locale = "en"
	elif saves.message!="": save_blocked = true
	if not has_campaign:
		var prefs = ConfigFile.new()
		if prefs.load("user://preferences.cfg")==OK:
			for key in ["locale","font","motion","battery","music","sfx"]:
				model.s.settings[key] = prefs.get_value("preferences",key,model.s.settings[key])
	model.s.settings.locale = "en"
	U.setup(model.data)
	U.scale = float(model.s.settings.font)
	pages = Pages.new(self)
	experience = preload("res://ui/experience.gd").new(self)
	mode = "boot"
	build_shell()
	set_page("village")
	if save_blocked: call_deferred("toast",saves.message)
	Engine.max_fps = 30 if model.s.settings.battery else 60
	if ResourceLoader.exists("res://assets/audio/hearth.ogg"):
		music = AudioStreamPlayer.new()
		music.set_script(preload("res://ui/audio_director.gd"))
		music.app = self
		music.volume_db = linear_to_db(float(model.s.settings.music))
		add_child(music)
	effect = AudioStreamPlayer.new()
	effect.stream = load("res://assets/audio/action.wav")
	add_child(effect)
	for i in range(3): effect.add_child(AudioStreamPlayer.new())
	ensure_coach()
	experience.splash()

func tr2(_id_text: String, en_text: String) -> String:
	return en_text

func now_ms() -> int:
	return int(Time.get_unix_time_from_system()*1000)

func persist():
	var prefs = ConfigFile.new()
	for key in ["locale","font","motion","battery","music","sfx"]: prefs.set_value("preferences",key,model.s.settings[key])
	prefs.save("user://preferences.cfg")
	if save_blocked or not has_campaign: return
	var old_wall = model.s.wall
	if mode=="play": model.s.wall = now_ms()
	if not saves.write_state(model.s,model.data):
		model.s.wall = old_wall
		if is_instance_valid(toast_label): toast(saves.message)

func _notification(what):
	if not is_node_ready(): return
	if what==NOTIFICATION_APPLICATION_PAUSED:
		if recovering: recovery_cancelled = true
		persist()
		paused = true
		if is_instance_valid(music): music.stream_paused = true
		if is_instance_valid(effect):
			effect.stop()
			for voice in effect.get_children(): voice.stop()
	elif what==NOTIFICATION_APPLICATION_RESUMED and paused:
		paused = false
		fraction_ms = 0
		if recovering: return
		if mode=="play":
			var report = await recover_progress()
			persist()
			if report.elapsed>30000: offline_dialog(report)
	elif what==NOTIFICATION_WM_CLOSE_REQUEST:
		persist()
		get_tree().quit()
	elif what==NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().quit_on_go_back = false
		call_deferred("navigate_back")

func navigate_back():
	if recovering: return
	var ticks = Time.get_ticks_msec()
	if ticks-last_back_ms<300: return
	last_back_ms = ticks
	if is_instance_valid(dialog): dismiss()
	elif mode=="intro": experience.finish_intro()
	elif mode=="play": experience.menu()
	else:
		var v = modal("Leave Cinderwatch?")
		v.add_child(U.para("Your journey is saved on this device. Queued activities continue for up to 24 hours while you are away.",16,U.TEXT))
		v.add_child(U.button("Keep playing",dismiss,true))
		v.add_child(U.button("Save & exit",func():
			persist()
			get_tree().quit()))

func enter_world():
	seen_levels.clear()
	seen_chapters = -1
	if not has_campaign: return
	experience.clear()
	dismiss()
	var report = await recover_progress()
	RealmChronicle.sync_day(model,now_ms())
	mode = "play"
	paused = false
	fraction_ms = 0
	build_shell()
	set_page("village")
	last_objective = model.objective().key
	persist()
	if report.elapsed>30000 and (model.s.experience.welcome_done or report.xp>0 or report.gold>0): offline_dialog(report)
	elif not model.s.experience.welcome_done: experience.welcome()

func recover_progress() -> Dictionary:
	recovering = true
	get_viewport().gui_release_focus()
	var previous_mode = mode
	mode = "recovering"
	var overlay = ColorRect.new()
	overlay.color = Color("0d1318")
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.z_index = 100
	add_child(overlay)
	var center = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)
	var content = U.column(16)
	content.custom_minimum_size.x = 260
	center.add_child(content)
	content.add_child(U.para("While you were away",24,U.GOLD))
	var label = U.para("Gathering your progress…",15,U.TEXT)
	content.add_child(label)
	var meter = U.progress(0,100,U.GOLD,8)
	content.add_child(meter)
	await get_tree().process_frame
	var report = {}
	while report.is_empty():
		while paused: await get_tree().process_frame
		recovery_cancelled = false
		report = await saves.resume_async(model,now_ms(),get_tree(),func(amount):
			meter.value = amount*100
			label.text = "Updating your journey · %d%%" % int(amount*100),func(): return recovery_cancelled)
	overlay.queue_free()
	recovering = false
	mode = previous_mode
	return report

func _input(event):
	if recovering and event is InputEventKey: get_viewport().set_input_as_handled()

func refresh_shell():
	var previous_mode = mode
	build_shell()
	set_page(page)
	if previous_mode!="play": experience.menu()

func story_dialog():
	preload("res://ui/story.gd").new(self).open()

func progress_dialog():
	preload("res://ui/progress_guide.gd").new(self).open()

func ensure_coach():
	if is_instance_valid(coach): return
	coach = preload("res://ui/onboarding_focus.gd").new()
	coach.app = self
	add_child(coach)

func ensure_ads():
	if is_instance_valid(ads): return
	ads = preload("res://services/admob.gd").new()
	ads.app = self
	add_child(ads)

func guide_dialog():
	experience.guide()

func _process(delta):
	if paused or mode!="play": return
	fraction_ms += delta*1000
	var ms = int(fraction_ms)
	fraction_ms -= ms
	model.advance(ms)
	var hunt_history = RealmHunts.state(model).history
	if hunt_history.is_empty(): last_hunt_audio = -1
	if not hunt_history.is_empty() and int(hunt_history[0].ended)!=last_hunt_audio:
		last_hunt_audio = int(hunt_history[0].ended)
		if int(model.s.time)-last_hunt_audio<1000 and hunt_history[0].result in ["Completed","Defeated"]: play_cue("victory" if hunt_history[0].result=="Completed" else "defeat")
	save_timer += delta
	ui_timer += delta
	if save_timer>=15:
		save_timer = 0
		RealmChronicle.sync_day(model,now_ms())
		persist()
	if ui_timer>=.15:
		ui_timer = 0
		refresh()

func build_shell():
	U.motion = bool(model.s.settings.motion)
	theme = Theme.new()
	theme.default_font = U.body_font
	theme.default_font_size = int(15*U.scale)
	U.apply_theme(theme)
	for child in get_children():
		if child!=music and child!=effect and child!=coach and child!=ads:
			remove_child(child)
			child.queue_free()
	dialog = null
	dialog_footer = null
	var bg = ColorRect.new()
	bg.color = U.INK
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if OS.get_name()=="Android":
		var safe = DisplayServer.get_display_safe_area()
		var screen = DisplayServer.screen_get_size()
		var ratio = 480.0/maxf(1,screen.x)
		margin.add_theme_constant_override("margin_top",int(safe.position.y*ratio))
		margin.add_theme_constant_override("margin_bottom",maxi(0,int((screen.y-safe.end.y)*ratio)))
	add_child(margin)
	var layout = U.column(0)
	margin.add_child(layout)
	var header = PanelContainer.new()
	header.add_theme_stylebox_override("panel",U.box(Color("10181e"),U.LINE,0,16))
	layout.add_child(header)
	var hr = U.row(12)
	header.add_child(hr)
	hr.add_child(Brand.emblem(Vector2(48,48)))
	var title = U.column(0)
	hr.add_child(title)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	title.add_child(U.para(Brand.SHORT,15,U.TEXT))
	title.add_child(U.label("IDLE RPG",10,U.GOLD))
	var menu_button = U.button("☰",func(): experience.menu())
	menu_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hr.add_child(menu_button)
	var counters = U.column(2)
	hr.add_child(counters)
	wallet = preload("res://ui/currency.gd").new()
	wallet.setup(func(): preload("res://ui/economy.gd").new(self).open())
	hp_label = U.label("",12,U.MUTED)
	counters.add_child(wallet)
	counters.add_child(hp_label)
	var journey_bar = PanelContainer.new()
	journey_bar.add_theme_stylebox_override("panel",U.box(Color("202a2c"),U.LINE,0,12))
	layout.add_child(journey_bar)
	var journey_row = U.row(10)
	journey_bar.add_child(journey_row)
	var journey_words = U.column(3)
	journey_words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	journey_row.add_child(journey_words)
	journey_words.add_child(U.label("YOUR NEXT STEP",9,U.GOLD))
	objective_label = U.para("",14,U.TEXT)
	journey_words.add_child(objective_label)
	var goals = U.button("Goals",guide_dialog)
	goals.set_meta("coach_target","goals")
	journey_row.add_child(goals)
	scroller = ScrollContainer.new()
	scroller.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroller.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	layout.add_child(scroller)
	var inset = MarginContainer.new()
	inset.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inset.add_theme_constant_override("margin_left",18)
	inset.add_theme_constant_override("margin_right",18)
	inset.add_theme_constant_override("margin_top",18)
	inset.add_theme_constant_override("margin_bottom",24)
	scroller.add_child(inset)
	body = U.column(16)
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inset.add_child(body)
	var footer = PanelContainer.new()
	footer.add_theme_stylebox_override("panel",U.box(Color("182128"),U.LINE,0,12))
	layout.add_child(footer)
	var footer_col = U.column(5)
	footer.add_child(footer_col)
	var fr = U.row(8)
	footer_col.add_child(fr)
	var work_thumbnail = preload("res://ui/work_stage.gd").new()
	work_thumbnail.model = model
	fr.add_child(work_thumbnail)
	var ft = U.column(3)
	ft.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fr.add_child(ft)
	activity_label = U.label("",14,U.TEXT)
	activity_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	ft.add_child(activity_label)
	activity_sub = U.label("",11,U.MUTED)
	activity_sub.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	ft.add_child(activity_sub)
	fr.add_child(U.button(tr2("Antrean","Queue"),queue_dialog))
	activity_progress = U.progress(0,1,U.GOLD,3)
	footer_col.add_child(activity_progress)
	footer.set_meta("coach_target","running")
	var nav = U.row(2)
	var nav_panel = PanelContainer.new()
	nav_panel.add_theme_stylebox_override("panel",U.box(Color("0e151a"),U.LINE,0,6))
	nav_panel.add_child(nav)
	layout.add_child(nav_panel)
	for entry in [["village","Desa","Stronghold"],["explore","Jelajah","Explore"],["skills","Keahlian","Skills"],["inventory","Tas","Bag"],["character","Karakter","Hero"]]:
		var key = entry[0]
		var b = U.button(tr2(entry[1],entry[2]),func(): set_page(key))
		b.name = key
		b.custom_minimum_size.y = 55
		b.custom_minimum_size.x = 0
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.add_theme_font_size_override("font_size",int(12*U.scale))
		b.add_theme_stylebox_override("normal",U.navigation(key==page))
		nav.add_child(b)
	hud = layout
	banner_space = Control.new()
	banner_space.hide()
	layout.add_child(banner_space)
	toast_label = U.label("",14,U.TEXT)
	toast_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	toast_label.add_theme_stylebox_override("normal",U.box(Color("38423b"),U.GOLD,8,14))
	toast_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	toast_label.offset_left = -215
	toast_label.offset_right = 215
	toast_label.offset_top = -215
	toast_label.offset_bottom = -145
	toast_label.visible = false
	toast_label.z_index = 20
	add_child(toast_label)

func set_page(next: String, retain_scroll: bool = false):
	var old_scroll = scroller.scroll_vertical if is_instance_valid(scroller) else 0
	page = next
	update_callbacks.clear()
	for child in body.get_children():
		body.remove_child(child)
		child.queue_free()
	match page:
		"village": pages.village(body)
		"explore": pages.explore(body)
		"skills": pages.skills(body)
		"inventory": pages.inventory(body)
		"character": pages.character(body)
	var nav = hud.get_child(hud.get_child_count()-2).get_child(0)
	for b in nav.get_children():
		b.add_theme_stylebox_override("normal",U.navigation(b.name==page))
		b.add_theme_color_override("font_color",U.GOLD if b.name==page else U.MUTED)
	scroller.set_deferred("scroll_vertical",old_scroll if retain_scroll else 0)
	refresh()

func dynamic(parent: Node, fn: Callable, size: int = 15, color: Color = U.TEXT) -> Label:
	var l = U.para(str(fn.call()),size,color)
	parent.add_child(l)
	var target = weakref(l)
	var callback = func():
		var live = target.get_ref()
		if is_instance_valid(live): live.text = RealmEconomy.text_value(str(fn.call()))
	if is_instance_valid(dialog) and dialog.is_ancestor_of(parent): dialog_callbacks.append(callback)
	else: update_callbacks.append(callback)
	return l

func refresh():
	if not is_instance_valid(wallet): return
	if model.s.tutorial and RealmChronicle.state(model).daily.day<0: RealmChronicle.sync_day(model,now_ms())
	wallet.update_amount(int(model.s.gold))
	hp_label.text = "%d / 100 HP" % int(model.s.hp)
	var objective = model.objective()
	if is_instance_valid(objective_label): objective_label.text = "%s · %d/%d" % [objective.title,mini(int(objective.current),int(objective.goal)),int(objective.goal)]
	if last_objective!="" and last_objective!=objective.key:
		last_objective = objective.key
		toast("Objective complete! Next: "+objective.title)
		if is_instance_valid(dialog) and dialog.get_meta("journey_guide",false): experience.call_deferred("guide")
		if not is_instance_valid(dialog) and not rebuild_pending and mode=="play":
			rebuild_pending = true
			call_deferred("refresh_objective_page")
	else: last_objective = objective.key
	if model.s.queue.is_empty():
		activity_label.text = tr2("Api menantikan langkahmu","No task running")
		activity_sub.text = tr2("Pilih aktivitas · progres offline hingga 24 jam","Choose work or a hunt before you leave")
		activity_progress.value = 0
	else:
		var step = model.s.queue[0]
		activity_label.text = model.activity_name(step.id)
		var progress_value = model.level(model.data.activities[step.id].skill) if step.kind=="level" else int(step.output if step.kind=="output" else step.done)
		var unit = "level" if step.kind=="level" else ("items" if step.kind=="output" else "cycles")
		activity_sub.text = "%d / %d %s · %d queued" % [progress_value,int(step.target),unit,model.s.queue.size()]
		var fraction = 0.0
		if not model.s.active.is_empty():
			var act = model.s.active
			fraction = float(model.s.time-act.started)/maxf(1,act.due-act.started)
		elif not model.s.fight.is_empty(): fraction = 1-float(model.s.fight.hp)/float(model.data.enemies[model.s.fight.enemy].hp)
		else: activity_sub.text = model.requirement(step.id)
		activity_progress.max_value = 1
		activity_progress.value = fraction
	var changes = []
	for id in model.data.skills:
		var current = model.level(id)
		if seen_levels.has(id) and current>int(seen_levels[id]):
			var unlocked = RealmStory.unlocks(model,id,int(seen_levels[id]),current)
			var line = model.local_name(model.data.skills[id])+" reached level "+str(current)
			if not unlocked.is_empty(): line += " · Unlocked: "+str(unlocked[0])+(" and %d more" % (unlocked.size()-1) if unlocked.size()>1 else "")
			changes.append(line)
		seen_levels[id] = current
	var chapters = RealmStory.count(model)
	if not changes.is_empty():
		toast("\n".join(changes.slice(0,3))+("\n%d more skills leveled up." % (changes.size()-3) if changes.size()>3 else ""))
		play_cue("reward")
	if not changes.is_empty() and page=="skills" and not is_instance_valid(dialog) and not rebuild_pending:
		rebuild_pending = true
		call_deferred("refresh_objective_page")
	seen_chapters = chapters
	for callback in update_callbacks+dialog_callbacks: callback.call()

func refresh_objective_page():
	rebuild_pending = false
	if mode=="play": set_page(page,true)

func send(cmd: Dictionary, rebuild: bool = true) -> bool:
	cmd.cid = "%d-%d" % [Time.get_ticks_usec(),model.s.processed.size()]
	var accepted = model.command(cmd)
	if accepted:
		var action = str(cmd.get("type",""))
		if action!="setting": play_cue("forge" if action in ["refine","rune_forge"] else ("equip" if action in ["equip","equip_best","rune_equip","relic_equip","loadout_load"] else ("reward" if action in ["claim","bounty_claim","research_claim"] else "action")))
		persist()
		if rebuild: set_page(page,true)
	else: toast(model.error)
	refresh()
	return accepted

func toast(text: String):
	if not is_instance_valid(toast_label): return
	toast_label.text = text
	toast_label.show()
	var expected = text
	get_tree().create_timer(4).timeout.connect(func():
		if is_instance_valid(toast_label) and toast_label.text==expected: toast_label.hide())

func play_cue(name: String):
	if not is_instance_valid(effect) or paused or float(model.s.settings.sfx)<=0: return
	var path = "res://assets/audio/"+name+".wav"
	if not ResourceLoader.exists(path): path = "res://assets/audio/action.wav"
	var voice = effect
	if effect.playing:
		for candidate in effect.get_children():
			if not candidate.playing:
				voice = candidate
				break
	voice.stream = load(path)
	voice.pitch_scale = randf_range(.97,1.03) if name in ["strike","hurt","forge"] else 1.0
	voice.volume_db = linear_to_db(float(model.s.settings.sfx))
	voice.play()

func dismiss():
	dialog_callbacks.clear()
	if is_instance_valid(dialog):
		remove_child(dialog)
		dialog.queue_free()
	dialog = null

func modal(title: String, dim_background: bool = true) -> VBoxContainer:
	dismiss()
	if is_instance_valid(toast_label): toast_label.hide()
	dialog = Control.new()
	dialog.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dialog.z_index = 10
	add_child(dialog)
	var shade = ColorRect.new()
	shade.color = Color(0,0,0,0 if not dim_background or model.s.experience.get("coach_active",false) else .78)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dialog.add_child(shade)
	var p = PanelContainer.new()
	p.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	p.offset_left = 20
	p.offset_right = -20
	p.offset_top = 100
	p.offset_bottom = -80
	var panel_style = U.box(U.INK,U.LINE,12,18)
	p.add_theme_stylebox_override("panel",panel_style)
	dialog.add_child(p)
	var root = U.column(14)
	p.add_child(root)
	var header = U.row()
	root.add_child(header)
	var name_label = U.para(title,27,U.TEXT)
	name_label.add_theme_font_override("font",U.title_font)
	header.add_child(name_label)
	header.add_child(U.button("×",dismiss))
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)
	var content = U.column(14)
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(content)
	dialog_footer = U.column(8)
	root.add_child(dialog_footer)
	dialog_footer.hide()
	if model.s.settings.motion:
		p.modulate.a = 0
		p.create_tween().tween_property(p,"modulate:a",1.0,.18).set_trans(Tween.TRANS_SINE)
	return content

func modal_action(label: String, callback: Callable, primary: bool = true) -> Button:
	dialog_footer.show()
	var button = U.button(label,callback,primary)
	dialog_footer.add_child(button)
	return button

func work_orders_dialog():
	preload("res://ui/gameplay.gd").new(self).work_orders()

func runeforge_dialog():
	preload("res://ui/runeforge.gd").new(self).forge()

func journal_dialog():
	preload("res://ui/runeforge.gd").new(self).journal()

func workshop_dialog():
	preload("res://ui/armory.gd").new(self).workshop()

func loadouts_dialog():
	preload("res://ui/armory.gd").new(self).loadouts()

func hunt_reports_dialog():
	preload("res://ui/armory.gd").new(self).hunt_reports()

func hunt_plan_dialog(id: String, minutes: int = 15):
	preload("res://ui/hunt_plan.gd").new(self).show_plan(id,minutes)

func finish_hunt_dialog():
	var v = modal("One last fight")
	v.add_child(U.para("Finish this battle, then return to Cinderwatch.",24,U.TEXT))
	v.add_child(U.para("Your current battle continues normally, including the risk of defeat. All remaining fights and waiting tasks will be cancelled. Rewards already earned stay with you.",16))
	modal_action("Finish this fight & stop",func():
		if send({"type":"finish_hunt"}):
			dismiss()
			toast("One last fight, then home."))

func trials_dialog():
	preload("res://ui/trials.gd").new(self).show_trial()

func world_dialog():
	preload("res://ui/chronicle.gd").new(self).world()

func talents_dialog():
	preload("res://ui/chronicle.gd").new(self).talents()

func relics_dialog():
	preload("res://ui/chronicle.gd").new(self).relics()

func bounties_dialog():
	preload("res://ui/chronicle.gd").new(self).bounties()

func planner_dialog(id: String, amount: int = 1):
	preload("res://ui/gameplay.gd").new(self).planner(id,amount)

func tactics_dialog():
	preload("res://ui/gameplay.gd").new(self).tactics()

func contracts_dialog():
	preload("res://ui/gameplay.gd").new(self).contracts()

func refuge_dialog():
	preload("res://ui/gameplay.gd").new(self).refuge()

func activity_dialog(id: String, recommended: int = 0):
	var a = model.data.activities[id]
	var v = modal(model.activity_name(id))
	dialog.set_meta("coach_activity",id)
	if a.kind!="combat":
		v.add_child(U.icon(a.output,92))
		v.add_child(U.para("%s · Lv.%d · %.1fs · +%d XP" % [model.local_name(model.data.skills[a.skill]),int(a.level),model.duration(a)/1000.0,int(a.xp)]))
		var mastery = U.disclosure(v,"crafting mastery")
		mastery.add_child(U.para("%d completions. At 250: +1 output every 10 cycles. At 1,000: every 5 cycles. Materials and food only." % int(model.s.mastery.get(id,0)),13))
		for key in a.inputs:
			var r = U.row()
			v.add_child(r)
			r.add_child(U.icon(key,34))
			r.add_child(U.para("%s   %d / %d" % [model.name_of(key),model.count(key),int(a.inputs[key])]))
			r.add_child(U.button(tr2("Cari","Find"),func(): sources_dialog(key)))
	else:
		var e = RealmEndgame.enemy(model,model.data.enemies[a.enemy])
		var encounter = U.row(16)
		v.add_child(encounter)
		encounter.add_child(U.enemy_portrait(e,Vector2(76,100)))
		var introduction = U.column(8)
		introduction.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		encounter.add_child(introduction)
		introduction.add_child(U.para("%d HP · %d ATK · %d DEF" % [int(e.hp),int(e.attack),int(e.armor)],13,U.GOLD))
		introduction.add_child(U.para(model.encounter_advice(a.enemy),14,U.TEXT))
		v.add_child(U.para("%s · %d melee XP / win" % [RealmEconomy.money(RealmHuntMastery.battle_gold(model,e)),RealmEconomy.hunt_xp(model,e)],15,U.GOLD))
		v.add_child(U.para("Food: %s ×%d · heal at %d%% HP" % [model.name_of(model.s.settings.food),model.count(model.s.settings.food),int(model.s.settings.threshold*100)],14,U.GREEN if model.count(model.s.settings.food)>0 else U.RED))
		var intel = U.disclosure(v,"enemy & loot details")
		intel.add_child(U.para(RealmCombat.mechanic(e),14,U.TEXT))
		if model.data.enemies[a.enemy].has("status"): intel.add_child(U.para(RealmAfflictions.element(model.data.enemies[a.enemy])+" · "+str(model.data.enemies[a.enemy].status).replace("_"," ").capitalize(),13,U.RED))
		if e.get("trial",false): intel.add_child(U.para("Phase II · "+RealmTrials.phase_text(e),14,U.RED))
		intel.add_child(U.para("%s ×%d / win" % [model.name_of(e.drop),int(e.qty)],14,U.GREEN))
		var fragment_id = RealmChronicle.fragments_for(e)
		intel.add_child(U.para("%d %s fragments / win" % [RealmHuntMastery.fragments(model,e),RealmChronicle.RELICS[fragment_id].name],14,U.GREEN))
		if e.has("rare_material"): intel.add_child(U.para(RealmLegacyFinds.description(model,e),14,U.GOLD))
		var card_id = "card_"+a.enemy
		intel.add_child(U.button("View monster card",func(): preload("res://ui/cards.gd").new(self).detail(card_id)))
		if e.has("region") and int(model.s.kills.get(e.id,0))==0:
			if e.get("trial",false): intel.add_child(U.para("First clear: Epic %s · 120 bonus fragments · 15 scraps · 20 grilled minnows." % model.name_of(e.trial_reward),13,U.GOLD))
			else: intel.add_child(U.para("First clear: +10 meals and %d scraps.%s" % [5+int(e.tier)," Tier 5 also grants a Rare Iron Sword." if int(e.tier)==5 else ""],13,U.GOLD))
		intel.add_child(U.para(RealmEconomy.experience_note(model,e),14))
		intel.add_child(U.para("Estimates exclude timed effects and card triggers. Bring spare food.",12))
		intel.add_child(U.button("Mastery · "+RealmHuntMastery.NAMES[RealmHuntMastery.rank(model,a.enemy)],func(): preload("res://ui/hunt_mastery.gd").new(self).detail(a.enemy)))
		v.add_child(U.button("Plan a longer hunt",func(): hunt_plan_dialog(a.enemy)))
	if a.kind!="combat":
		v.add_child(U.para("Makes 1 "+model.name_of(a.output)+" per cycle",14,U.GREEN))
	if a.kind!="combat" and not a.inputs.is_empty() and model.requirement(id)=="":
		v.add_child(U.button("Gather & craft",func(): planner_dialog(id,maxi(1,mini(100,recommended))),true))
	var reason = model.requirement(id)
	if reason!="":
		if model.s.active.get("id","")==id:
			v.add_child(U.para("Current cycle supplied. More materials are needed for another cycle.",14,U.GOLD))
		else: v.add_child(U.para("Missing materials" if reason.begins_with("Need ") else reason,14,U.RED))
	if recommended>0:
		var unit = ("fight" if recommended==1 else "fights") if a.kind=="combat" else ("cycle" if recommended==1 else "cycles")
		var suggested = modal_action("Begin · %d %s" % [recommended,unit],func(): enqueue_activity(id,recommended))
		suggested.set_meta("coach_target","begin")
		suggested.disabled = reason!="" or not model.s.queue.is_empty()
	else:
		var begin = modal_action("Begin one fight" if a.kind=="combat" else "Begin one cycle",func(): enqueue_activity(id,1))
		begin.disabled = reason!=""
	if not model.s.queue.is_empty() and recommended>0:
		for button in dialog_footer.get_children(): button.hide()
		modal_action("Manage existing queue",queue_dialog).set_meta("coach_target","manage_queue")
	elif reason!="" and a.kind!="combat":
		for button in dialog_footer.get_children(): button.hide()
		modal_action("Plan missing materials",func(): planner_dialog(id,maxi(1,mini(100,recommended)))).set_meta("coach_target","materials")
	v.add_child(U.label("QUICK START",11,U.GOLD))
	var targets = U.row(6)
	v.add_child(targets)
	for number in [1,10,50,100]:
		var b = U.button("%d×" % number,func(): enqueue_activity(id,number))
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		targets.add_child(b)
	var advanced = U.column(12)
	v.add_child(U.button("Custom target",func(): advanced.visible = not advanced.visible))
	v.add_child(advanced)
	advanced.hide()
	advanced.add_child(U.para("Set a count, output goal or skill level.",13))
	var amount = SpinBox.new()
	amount.min_value = 1
	amount.max_value = 1000000
	amount.value = recommended if recommended>0 else 10
	amount.custom_minimum_size.y = 48
	amount.add_theme_font_size_override("font_size",18)
	advanced.add_child(amount)
	var kind = OptionButton.new()
	for text in [tr2("Jumlah siklus","Cycle count"),tr2("Jumlah hasil baru","New output count"),tr2("Level skill tujuan","Target skill level")]: kind.add_item(text)
	kind.custom_minimum_size.y = 48
	advanced.add_child(kind)
	var skip = CheckButton.new()
	skip.text = tr2("Lewati jika bahan tidak tersedia","Skip when requirements are missing")
	skip.add_theme_font_size_override("font_size",13)
	advanced.add_child(skip)
	advanced.add_child(U.button(tr2("Tambahkan ke antrean","Add to queue"),func():
		enqueue_activity(id,int(amount.value),["cycles","output","level"][kind.selected],skip.button_pressed),true))

func enqueue_activity(id: String, target: int, kind: String = "cycles", skip: bool = false):
	if send({"type":"queue","id":id,"target":target,"kind":kind,"skip":skip}):
		dismiss()
		toast("Task queued")

func sources_dialog(id: String):
	var v = modal(tr2("Sumber: ","Sources: ")+model.name_of(id))
	if id.begins_with("keepsake_"):
		for enemy in model.data.enemies.values():
			if enemy.get("rare_material","")==id: v.add_child(U.para("Used to craft masterwork equipment.",15,U.GOLD))
	for aid in model.sources(id):
		var a = model.data.activities[aid]
		v.add_child(U.button(model.activity_name(aid)+" · "+model.local_name(model.data.skills[a.skill]),func(): activity_dialog(aid)))
	if model.data.merchant.has(id): v.add_child(U.button(tr2("Beli di pedagang desa","Buy from the village merchant"),merchant_dialog))

func queue_dialog():
	preload("res://ui/queue_review.gd").new(self).open()

func merchant_dialog():
	preload("res://ui/merchant.gd").new(self).open()

func item_dialog(uid: String):
	preload("res://ui/equipment_detail.gd").new(self).open(uid)

func salvage_dialog(ids: Array):
	var v = modal(tr2("Konfirmasi peleburan","Confirm salvage"))
	var total = 0
	for uid in ids:
		var g = model.gear(uid)
		if g.is_empty(): continue
		total += int(g.count)*[1,1,2,4,6,8,12,16][int(g.q)]
		v.add_child(U.para("%s ×%d" % [model.name_of(g.id),int(g.count)]))
	v.add_child(U.label("→ %d %s" % [total,tr2("serpihan logam","metal scraps")],19,U.GOLD))
	v.add_child(U.para(tr2("Perlengkapan dalam daftar akan dilebur permanen.","The listed equipment will be permanently salvaged.")))
	v.add_child(U.button(tr2("Lebur item di atas","Salvage listed items"),func():
		send({"type":"salvage","ids":ids})
		dismiss(),true))

func offline_dialog(report: Dictionary):
	preload("res://ui/return_report.gd").new(self).open(report)

func settings_dialog():
	var v = modal(tr2("Pengaturan","Settings"))
	for cfg in [["motion","Animasi lingkungan","Ambient animation"],["battery","Hemat baterai · 30 FPS","Battery saver · 30 FPS"]]:
		var b = CheckButton.new()
		b.text = tr2(cfg[1],cfg[2])
		b.button_pressed = bool(model.s.settings[cfg[0]])
		b.custom_minimum_size.y = 48
		v.add_child(b)
		b.toggled.connect(func(value):
			send({"type":"setting","id":cfg[0],"value":value},false)
			Engine.max_fps = 30 if model.s.settings.battery else 60
			refresh_shell()
			settings_dialog())
	v.add_child(U.label(tr2("Ukuran teks","Text size"),16))
	var fonts = U.row()
	v.add_child(fonts)
	for size_value in [1.0,1.15,1.3]:
		fonts.add_child(U.button("%d%%" % roundi(size_value*100),func():
			send({"type":"setting","id":"font","value":size_value},false)
			U.scale = size_value
			refresh_shell()
			settings_dialog()))
	v.add_child(U.para("Language · English",13))
	for key in ["music","sfx"]:
		v.add_child(U.label(tr2("Musik" if key=="music" else "Efek suara","Music" if key=="music" else "Sound effects"),15))
		var slider = HSlider.new()
		slider.min_value = 0
		slider.max_value = 1
		slider.step = .05
		slider.value = float(model.s.settings[key])
		slider.custom_minimum_size.y = 40
		v.add_child(slider)
		slider.value_changed.connect(func(value):
			model.s.settings[key] = value
			if key=="sfx" and is_instance_valid(effect):
				effect.volume_db = linear_to_db(maxf(.00001,value))
				for voice in effect.get_children(): voice.volume_db = effect.volume_db
			persist())
	v.add_child(U.button("Music & sound preview",func(): preload("res://ui/sound_room.gd").new(self).open()))
	v.add_child(U.button("AdMob · test ads",func(): preload("res://ui/ad_settings.gd").new(self).open()))
	v.add_child(U.label("PROGRESS & BACKUPS",11,U.GOLD))
	if has_campaign: v.add_child(U.button(tr2("Ekspor cadangan save","Export save backup"),export_save))
	v.add_child(U.button(tr2("Impor cadangan save","Import save backup"),import_save))
	v.add_child(U.button("Restore a previous journey",experience.archives))
	v.add_child(U.label("HELP & COMMUNITY",11,U.GOLD))
	v.add_child(U.button("How to play",experience.handbook))
	if mode=="play": v.add_child(U.button("Replay beginner tips",experience.welcome))
	v.add_child(U.button("About Cinder Dominion",experience.about))
	v.add_child(U.button("Share",experience.share))
	v.add_child(U.button("Rate",experience.rate))
	v.add_child(U.button("Return to main menu",experience.menu))
	v.add_child(U.para("Version "+experience.VERSION+" · Adventure preview",12))

func export_save():
	var fd = FileDialog.new()
	fd.access = FileDialog.ACCESS_FILESYSTEM
	fd.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	fd.use_native_dialog = true
	fd.current_file = "ashen-covenant-backup.json"
	fd.add_filter("*.json","Save backup")
	add_child(fd)
	fd.file_selected.connect(func(path):
		var f = FileAccess.open(path,FileAccess.WRITE)
		if f!=null:
			f.store_string(saves.encode(model.s))
			f.close()
			toast(tr2("Cadangan berhasil diekspor","Backup exported"))
		else: toast(tr2("Tidak dapat menulis cadangan","Cannot write backup"))
		fd.queue_free())
	fd.canceled.connect(fd.queue_free)
	fd.popup_centered_ratio(.85)

func import_save():
	var fd = FileDialog.new()
	fd.access = FileDialog.ACCESS_FILESYSTEM
	fd.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	fd.use_native_dialog = true
	fd.add_filter("*.json","Save backup")
	add_child(fd)
	fd.file_selected.connect(func(path):
		var f = FileAccess.open(path,FileAccess.READ)
		if f==null or f.get_length()>RealmSave.LIMIT:
			toast(tr2("Cadangan terlalu besar atau tidak terbaca","Backup is too large or unreadable"))
			fd.queue_free()
			return
		var incoming = saves.decode(f.get_as_text(),model.data)
		fd.queue_free()
		if incoming.is_empty():
			toast(tr2("Save tidak valid; progresmu tetap aman","Invalid save; your progress is unchanged"))
			return
		confirm_restore(incoming))
	fd.canceled.connect(fd.queue_free)
	fd.popup_centered_ratio(.85)

func confirm_restore(incoming: Dictionary):
	var v = modal("Restore this journey?")
	v.add_child(U.para("This will replace current progress with the selected backup. Your current save is written first and retained in the rotating save backups.",16,U.TEXT))
	v.add_child(U.para("Backup: %d gold · Smithing level %d" % [int(incoming.gold),1+int(sqrt(float(incoming.xp.smithing)/25.0))],15,U.GOLD))
	v.add_child(U.button("Cancel",dismiss))
	v.add_child(U.button("Restore selected journey",func():
		persist()
		incoming.wall = now_ms()
		incoming.settings.locale = "en"
		if not incoming.has("experience"):
			incoming.experience = {"version":2,"welcome_done":false}
			incoming.settings.locale = "en"
		if saves.write_state(incoming,model.data):
			model.s = incoming
			has_campaign = true
			save_blocked = false
			Engine.max_fps = 30 if model.s.settings.battery else 60
			if is_instance_valid(music): music.volume_db = linear_to_db(float(model.s.settings.music))
			U.scale = float(model.s.settings.font)
			enter_world()
		else: toast("Import failed. Current progress is unchanged."),true))
