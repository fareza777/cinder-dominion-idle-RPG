extends RefCounted

const U = preload("res://ui/style.gd")
const C = preload("res://game/chronicle.gd")
var app
var m

func _init(owner):
	app = owner
	m = owner.model

func locked(v: Node) -> bool:
	if m.s.tutorial: return false
	v.add_child(U.para("First, learn the essentials: gather → craft → equip → hunt. Complete First Supplies to open this system.",17,U.TEXT))
	v.add_child(U.button("Show my next step",app.guide_dialog,true))
	return true

func home(parent: Node):
	var card = U.card(parent,16,U.GOLD.darkened(.35))
	card.add_child(U.label("RECOMMENDED ACTION",10,U.GOLD))
	app.dynamic(card,func(): return C.focus(m).title,24,U.TEXT)
	app.dynamic(card,func(): return C.focus(m).why,14)
	var action = U.button("Continue",act,true)
	card.add_child(action)
	var ref = weakref(action)
	app.update_callbacks.append(func():
		var b = ref.get_ref()
		if is_instance_valid(b): b.text = {"story":"Start next objective  →","queue":"View active plan  →","talents":"Choose my talents  →","relics":"Awaken relic  →","equip":"Equip best gear  →","plan":"Review supply plan  →","journal":"Collect field supplies  →","runes":"Review inscription  →"}[C.focus(m).kind])
	card.add_child(U.button("Progress & farming",roadmap))
	var latest = U.button("Review latest hunt",app.hunt_reports_dialog)
	card.add_child(latest)
	var latest_ref = weakref(latest)
	app.update_callbacks.append(func():
		var button = latest_ref.get_ref()
		if not is_instance_valid(button): return
		var history = RealmHunts.state(m).history
		button.visible = not history.is_empty()
		if not history.is_empty(): button.text = "Latest hunt · "+str(history[0].result)+" →")
	latest.visible = not RealmHunts.state(m).history.is_empty()


func services(parent: Node):
	parent.add_child(U.label("REFUGE SERVICES",10,U.GOLD))
	var row = U.row(7)
	parent.add_child(row)
	for entry in [["journey","Journey"],["armory","Armory"],["supplies","Supplies"]]:
		var b = U.button(entry[1],func(): station(entry[0]))
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(b)
	if m.s.tutorial:
		app.dynamic(parent,func(): return "%d bounty · %d field · %d contract rewards ready" % [C.ready_bounties(m),RealmRuneforge.ready(m),RealmProgression.ready_count(m)],12,U.GOLD)
	parent.add_child(U.button("Story journal · %d / 7 chapters" % RealmStory.count(m),app.story_dialog))
	parent.add_child(U.button("Leave a work order before you go",app.work_orders_dialog))

func station(kind: String):
	var names = {"journey":"Journey","armory":"Equipment & build","supplies":"Food & materials"}
	var v = app.modal(names[kind])
	var entries = []
	match kind:
		"journey":
			v.add_child(U.para("Follow your next goal or choose a farming target.",24,U.TEXT))
			entries = [["Story journal","Read unlocked chapters and see what opens next.",app.story_dialog],["Progress & farming","What to do next, what to farm and how to use it.",app.progress_dialog],["Guardian trials","Three optional challenges beyond regional tier five.",app.trials_dialog],["Journey guide","Your next objective and the path beyond it.",app.guide_dialog],["World map","Story routes, regional guardians and expedition tiers.",app.world_dialog],["Field journal","Guardian tactics and one-time regional rewards.",app.journal_dialog],["Hunt reports","Victories, supplies spent and rewards from recent orders.",app.hunt_reports_dialog],["Bounty board","Small goals that carry over when you are away.",app.bounties_dialog]]
		"armory":
			v.add_child(U.para("Make every piece of your build count.",24,U.TEXT))
			entries = [["Equipment bag","Compare and equip the gear you already own.",func():
				app.dismiss()
				app.set_page("inventory")],["Ember Workshop","Guaranteed equipment refinement, from Fine to Legendary.",app.workshop_dialog],["Complete loadouts","Save equipment, talents, style, rune and supplies together.",app.loadouts_dialog],["Talents","Choose where to spend earned melee experience.",app.talents_dialog],["Relics","Awaken a collection and choose its active bonus.",app.relics_dialog],["Runeforge","Upgrade and equip a rune for a specific combat effect.",app.runeforge_dialog]]
		"supplies":
			v.add_child(U.para("Prepare food and materials for your next task.",24,U.TEXT))
			entries = [["Work orders","Plan gathering and crafting for your time away.",app.work_orders_dialog],["Food & survival","Choose cooked food and understand automatic healing.",app.experience.survival],["Merchant","Buy tools and vials with gold earned on the road.",app.merchant_dialog],["Refuge contracts","Collect milestone supplies you have earned.",app.contracts_dialog],["Rebuild Cinderwatch","Improve the forge, gates and resting hearth.",app.refuge_dialog]]
	for entry in entries:
		var card = U.card(v,12)
		card.add_child(U.para(entry[1],13))
		card.add_child(U.button(entry[0]+"  →",entry[2]))

func act():
	var focus = C.focus(m)
	match focus.kind:
		"queue": app.queue_dialog()
		"story": app.experience.act_on_goal()
		"talents": talents()
		"relics": relics()
		"runes": preload("res://ui/runeforge.gd").new(app).forge(focus.id)
		"journal":
			for region in C.REGIONS:
				var found = false
				for target in RealmRuneforge.MILESTONES:
					if RealmRuneforge.victories(m,region)>=target and region+"_"+str(target) not in RealmRuneforge.state(m).claimed: found = true
				if found:
					preload("res://ui/runeforge.gd").new(app).journal(region)
					break
		"plan": app.planner_dialog(focus.id,int(focus.amount))
		"equip":
			if app.send({"type":"equip_best"}): app.toast("Upgrades equipped. Your next recommendation is ready.")

func roadmap():
	app.progress_dialog()

func talents():
	var v = app.modal("Talents · shape your build")
	if locked(v): return
	var state = C.state(m)
	app.dynamic(v,func(): return "%d points available · %d / 10 earned" % [C.points_free(m),C.points_earned(m)],18,U.GOLD)
	var xp = int(m.s.xp.bladecraft+m.s.xp.might+m.s.xp.warding)
	v.add_child(U.para("Earn one point per 250 melee XP. Every victory trains your hero. Spend up to 10 points across 15 possible ranks; reset for free outside combat. Your build cannot maximize every path at once.",14))
	if C.points_earned(m)<10:
		v.add_child(U.progress(xp%250,250,U.GOLD,6))
		app.dynamic(v,func(): return "%d XP until the next point" % (250-int(m.s.xp.bladecraft+m.s.xp.might+m.s.xp.warding)%250),13,U.GREEN)
	for id in C.TALENTS:
		var d = C.TALENTS[id]
		var card = U.card(v,14)
		card.add_child(U.label(d.name,25,U.TEXT,true))
		card.add_child(U.para(d.detail,14))
		card.add_child(U.progress(state.talents[id],5,U.GOLD,5))
		card.add_child(U.label("RANK %d / 5" % int(state.talents[id]),11,U.GOLD))
		var button = U.button("Spend 1 point",func():
			if app.send({"type":"talent","id":id}): talents(),true)
		button.disabled = C.points_free(m)<1 or state.talents[id]>=5 or not m.s.fight.is_empty()
		card.add_child(button)
		var ref = weakref(button)
		app.dialog_callbacks.append(func():
			var b = ref.get_ref()
			if is_instance_valid(b): b.disabled = C.points_free(m)<1 or state.talents[id]>=5 or not m.s.fight.is_empty())
	v.add_child(U.button("Reset talents · free",func():
		if app.send({"type":"talent_reset"}): talents()))
	if not m.s.fight.is_empty(): v.add_child(U.para("Retreat before changing talents.",13,U.RED))

func relics():
	var v = app.modal("Relics of the valley")
	if locked(v): return
	v.add_child(U.para("Every victory guarantees fragments of one relic. Awaken and upgrade each collection up to rank 10. One relic can be equipped; switch freely outside combat.",15))
	var state = C.state(m)
	for id in C.RELICS:
		var d = C.RELICS[id]
		var rank = int(state.relics[id])
		var card = U.card(v,15,Color(d.color).darkened(.4))
		var row = U.row(12)
		card.add_child(row)
		row.add_child(U.icon(d.icon,68))
		var details = U.column(4)
		row.add_child(details)
		details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		details.add_child(U.para(d.name,25,Color(d.color)))
		details.add_child(U.para("RANK %d / 10%s" % [rank," · EQUIPPED" if state.relic==id else ""],11,U.GOLD))
		card.add_child(U.para(d.detail,14,U.TEXT))
		card.add_child(U.para("TARGET FARM\n"+d.source,13))
		app.dynamic(card,func(): return "%d fragments owned" % int(state.fragments[id]),14,Color(d.color))
		if rank<10:
			var cost = C.relic_cost(rank)
			card.add_child(U.progress(state.fragments[id],cost,Color(d.color),5))
			var button = U.button(("Awaken" if rank==0 else "Upgrade")+" · %d fragments" % cost,func():
				if app.send({"type":"relic_upgrade","id":id}): relics(),true)
			button.disabled = state.fragments[id]<cost or not m.s.fight.is_empty()
			card.add_child(button)
			var ref = weakref(button)
			app.dialog_callbacks.append(func():
				var b = ref.get_ref()
				if is_instance_valid(b): b.disabled = state.fragments[id]<cost or not m.s.fight.is_empty())
		if rank>0 and state.relic!=id: card.add_child(U.button("Equip "+d.name,func():
			if app.send({"type":"relic_equip","id":id}): relics()))
		card.add_child(U.button("Find a hunting ground",func(): farms(id)))

func farms(relic: String):
	var d = C.RELICS[relic]
	var v = app.modal(d.name+" · hunting grounds")
	var state = C.state(m)
	var rank = int(state.relics[relic])
	var missing = maxi(0,C.relic_cost(rank)-int(state.fragments[relic])) if rank<10 else 0
	v.add_child(U.para("%d fragments to the next rank" % missing if rank<10 else "This relic is fully awakened.",22,U.TEXT))
	v.add_child(U.para("Choose a route for your current build. Safer hunts appear first, then the estimated fragment yield. Estimates vary with misses, healing and your remaining supplies.",14))
	var choices = RealmCombat.farms(m,relic)
	if choices.is_empty(): v.add_child(U.para("No hunting grounds are open yet. Follow the main journey to reach "+d.source+".",15,U.GOLD))
	for i in range(choices.size()):
		var choice = choices[i]
		var enemy = m.data.enemies[choice.id]
		var forecast = choice.forecast
		var card = U.card(v,14,U.GOLD.darkened(.4) if i==0 else U.LINE)
		var row = U.row(10)
		card.add_child(row)
		row.add_child(U.enemy_portrait(enemy,Vector2(64,82)))
		var description = U.column(4)
		description.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(description)
		description.add_child(U.para(m.local_name(enemy),19,U.TEXT))
		description.add_child(U.para("%d fragments per victory" % int(choice.fragments),12,U.GOLD))
		card.add_child(U.para(m.encounter_advice(choice.id),13,U.RED if forecast.risk else U.GREEN))
		card.add_child(U.para("Estimated %.1f fragments / minute" % float(forecast.fragments_per_minute),13,U.GOLD))
		if enemy.has("region"): card.add_child(U.para(RealmCombat.mechanic(enemy),12))
		var wins = clampi(ceili(float(missing)/int(choice.fragments)),1,100) if missing>0 else 10
		card.add_child(U.button("Plan %d %s" % [wins,"victory" if wins==1 else "victories"],func(): app.activity_dialog("hunt_"+choice.id,wins),i==0 and not forecast.risk))
	app.modal_action("Return to relics",relics)

func bounties():
	C.sync_day(m,app.now_ms())
	var v = app.modal("The bounty board")
	if locked(v): return
	app.persist()
	var state = C.state(m)
	var relic = C.bounty_relic(m)
	v.add_child(U.para("Cinderwatch has work for willing hands.",23,U.TEXT))
	v.add_child(U.para("Complete three tasks through normal play. Unfinished tasks carry over. After all rewards are claimed, a new board opens on a later UTC day. No streak to lose.",14))
	v.add_child(U.para("PAYMENT INCLUDES · "+C.RELICS[relic].name.to_upper(),11,U.GOLD))
	for id in C.BOUNTIES:
		var d = C.BOUNTIES[id]
		var claimed = id in state.daily.claimed
		var card = U.card(v,14)
		card.add_child(U.para(d.name+(" · CLAIMED" if claimed else ""),20,U.TEXT))
		card.add_child(U.para(d.detail,14))
		app.dynamic(card,func(): return "%d / %d" % [C.bounty_value(m,id),int(d.target)],13,U.GOLD)
		card.add_child(U.para("+%d gold · +5 meals · +5 %s fragments" % [int(d.gold),C.RELICS[relic].name],13,U.GREEN))
		if claimed: continue
		var button = U.button("Claim reward",func():
			if app.send({"type":"bounty_claim","id":id}): bounties(),true)
		button.disabled = C.bounty_value(m,id)<d.target
		card.add_child(button)
		var ref = weakref(button)
		app.dialog_callbacks.append(func():
			var b = ref.get_ref()
			if is_instance_valid(b): b.disabled = C.bounty_value(m,id)<d.target)
		if id=="gather": card.add_child(U.button("Gather copper · preview task",func(): app.activity_dialog("mine_copper",maxi(1,30-C.bounty_value(m,id)))))
		elif id=="craft": card.add_child(U.button("Cook meals · supply planner",func(): app.planner_dialog("craft_cooked_minnow",maxi(1,10-C.bounty_value(m,id)))))
		else: card.add_child(U.button("Hunt Ash Rats · preview task",func(): app.activity_dialog("hunt_ash_rat",maxi(1,8-C.bounty_value(m,id)))))
	if state.daily.claimed.size()==3: v.add_child(U.para("Board complete. Come back after the next UTC day begins for a fresh board. Your expeditions and farming remain available now.",15,U.GOLD))

func world(selected: String = "wilds"):
	var v = app.modal("Beyond the last refuge")
	var art = TextureRect.new()
	art.texture = load("res://assets/art/world-map.png") if ResourceLoader.exists("res://assets/art/world-map.png") else load("res://assets/art/cinderwatch.png")
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var map = Control.new()
	map.custom_minimum_size.y = 245
	map.clip_contents = true
	v.add_child(map)
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	map.add_child(art)
	for pin in [["wilds","I",Vector2(.24,.26)],["marsh","II",Vector2(.65,.57)],["crown","III",Vector2(.84,.19)]]:
		var button = U.button(pin[1],func(): world(pin[0]),selected==pin[0])
		map.add_child(button)
		button.anchor_left = pin[2].x
		button.anchor_top = pin[2].y
		button.offset_left = -19
		button.offset_top = -19
		button.custom_minimum_size = Vector2(38,38)
		button.tooltip_text = C.REGIONS[pin[0]].name
	var tabs = U.row(5)
	v.add_child(tabs)
	for tab in [["wilds","I · Wilds"],["marsh","II · Sanctum"],["crown","III · Crown"]]:
		var button = U.button(tab[1],func(): world(tab[0]),selected==tab[0])
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tabs.add_child(button)
	v.add_child(U.para("Beyond the walls, the valley waits.",23,U.TEXT))
	if not m.s.beacon:
		v.add_child(U.para("Restore Cinderwatch's beacon by defeating the Bellkeeper to begin expeditions. Your next story objective is: "+m.objective().title,15,U.GOLD))
		v.add_child(U.button("Continue Chapter I",app.guide_dialog,true))
	v.add_child(U.para("Clear a tier once to open the next. Repeat cleared tiers for guaranteed fragments and a 5% chance of iron equipment. Each guardian has a different third-strike ability.",14))
	v.add_child(U.button("Guardian trials · beyond tier five",app.trials_dialog))
	v.add_child(U.button("Field journal · learn this guardian",func(): preload("res://ui/runeforge.gd").new(app).journal(selected)))
	for region in C.REGIONS:
		if region!=selected: continue
		var d = C.REGIONS[region]
		var card = U.card(v,14,Color(d.color).darkened(.45))
		card.add_child(U.label(d.name,29,Color(d.color),true))
		card.add_child(U.para(d.detail,14))
		for tier in range(1,6):
			var id = "%s_%d" % [region,tier]
			var enemy = m.data.enemies[id]
			var why = m.available(id)
			var cleared = int(m.s.kills.get(id,0))>0
			var b = U.button("%s Tier %d · %d fragments / win" % ["✓" if cleared else "○",tier,int(enemy.fragments)],func(): app.activity_dialog("hunt_"+id,1),why=="" and not cleared)
			b.disabled = why!=""
			card.add_child(b)
			var ref = weakref(b)
			app.dialog_callbacks.append(func():
				var button = ref.get_ref()
				if is_instance_valid(button):
					button.disabled = m.available(id)!=""
					button.text = "%s Tier %d · %d fragments / win" % ["✓" if int(m.s.kills.get(id,0))>0 else "○",tier,int(enemy.fragments)])
			if why!="" and (tier==1 or m.available("%s_%d" % [region,tier-1])==""): app.dynamic(card,func(): return m.available(id),12)
		card.add_child(U.para("First clear: +10 meals and scraps per tier. Tier 5 also awards a Rare Iron Sword.",12,U.GOLD))
