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
	card.add_child(U.label("NEXT",10,U.GOLD))
	app.dynamic(card,func(): return C.focus(m).title,24,U.TEXT)
	var action = U.button("Continue",act,true)
	card.add_child(action)
	var ref = weakref(action)
	app.update_callbacks.append(func():
		var b = ref.get_ref()
		if is_instance_valid(b): b.text = {"story":m.objective().action,"queue":"Queue","talents":"Talents","relics":"Relics","equip":"Equip best gear  →","plan":"Prepare supplies","journal":"Collect field supplies  →","runes":"Review inscription  →"}[C.focus(m).kind])
	card.add_child(U.button("Farm & upgrade",roadmap))
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
	parent.add_child(U.button("Work orders",app.work_orders_dialog))
	parent.add_child(U.button("Bestiary · drops & tactics",func(): preload("res://ui/bestiary.gd").new(app).open()))

func station(kind: String):
	var names = {"journey":"Journey","armory":"Equipment & build","supplies":"Food & materials"}
	var v = app.modal(names[kind])
	var entries = []
	match kind:
		"journey":
			entries = [["Hunt mastery","",func(): preload("res://ui/hunt_mastery.gd").new(app).open()],["Story journal","Read unlocked chapters and see what opens next.",app.story_dialog],["Farm & upgrade","What to do next, what to farm and how to use it.",app.progress_dialog],["Guardian trials","Three optional challenges beyond regional tier five.",app.trials_dialog],["Journey guide","Your next objective and the path beyond it.",app.guide_dialog],["World map","Story routes, regional guardians and expedition tiers.",app.world_dialog],["Field journal","Guardian tactics and one-time regional rewards.",app.journal_dialog],["Hunt reports","Victories, supplies spent and rewards from recent orders.",app.hunt_reports_dialog],["Bounty board","Small goals that carry over when you are away.",app.bounties_dialog]]
		"armory":
			entries = [["Equipment bag","Compare and equip the gear you already own.",func():
				app.dismiss()
				app.set_page("inventory")],["Ember Workshop","Guaranteed equipment refinement, from Fine to Legendary.",app.workshop_dialog],["Complete loadouts","Save equipment, talents, style, rune and supplies together.",app.loadouts_dialog],["Talents","Choose where to spend earned melee experience.",app.talents_dialog],["Relics","Awaken a collection and choose its active bonus.",app.relics_dialog],["Runeforge","Upgrade and equip a rune for a specific combat effect.",app.runeforge_dialog]]
		"supplies":
			entries = [["Work orders","Plan gathering and crafting for your time away.",app.work_orders_dialog],["Food & survival","Choose cooked food and understand automatic healing.",app.experience.survival],["Merchant","Buy tools and vials with gold earned on the road.",app.merchant_dialog],["Refuge contracts","Collect milestone supplies you have earned.",app.contracts_dialog],["Rebuild Cinderwatch","Improve the forge, gates and resting hearth.",app.refuge_dialog]]
	for entry in entries:
		var card = U.card(v,12)
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
	v.add_child(U.para("250 melee XP = 1 point · 10 points maximum",14))
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
	v.add_child(U.para("1 relic equipped · 10 ranks each",15))
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
		var unit = 3 if id=="heart" else 2
		var benefit = "food healing" if id=="heart" else ("attack" if id=="fang" else "armor")
		card.add_child(U.para("While equipped: +%d %s%s" % [rank*unit,benefit," → +%d at the next rank" % ((rank+1)*unit) if rank<10 else " · maximum rank"],14,U.GOLD))
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
	preload("res://ui/relic_farm.gd").new(app).open(relic)

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
		if claimed:
			card.add_child(U.para("Reward collected",13,U.GREEN))
			continue
		app.dynamic(card,func():
			var reward = C.bounty_reward(m,id)
			return "+%d gold · 5 %s · %d %s fragments" % [reward.gold,m.name_of(reward.food),reward.fragments,C.RELICS[relic].name],13,U.GREEN)
		var button = U.button("Claim reward",func():
			if app.send({"type":"bounty_claim","id":id}): bounties(),true)
		button.disabled = C.bounty_value(m,id)<d.target
		card.add_child(button)
		var ref = weakref(button)
		app.dialog_callbacks.append(func():
			var b = ref.get_ref()
			if is_instance_valid(b): b.disabled = C.bounty_value(m,id)<d.target)
		if id=="gather":
			var activity = "mine_copper"
			for aid in m.data.activities:
				var a = m.data.activities[aid]
				if a.kind=="gather" and a.skill=="mining" and a.level<=m.level("mining") and a.level>m.data.activities[activity].level: activity = aid
			card.add_child(U.button("Gather "+m.name_of(m.data.activities[activity].output),func(): app.activity_dialog(activity,maxi(1,30-C.bounty_value(m,id)))))
		elif id=="craft": card.add_child(U.button("Cook meals · supply planner",func(): app.planner_dialog("craft_"+str(C.bounty_reward(m,id).food),maxi(1,10-C.bounty_value(m,id)))))
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
