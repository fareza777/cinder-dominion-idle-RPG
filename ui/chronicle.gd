extends RefCounted

const U = preload("res://ui/style.gd")
const C = preload("res://game/chronicle.gd")
var app
var m
var talent_branch = "power"
var chosen_talent = "power"
var chosen_relic = "fang"

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
	U.section(card,"RECOMMENDED NEXT")
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
	U.section(parent,"STRONGHOLD SERVICES")
	var p = preload("res://ui/premium.gd")
	p.destination(parent,"Forge",0,app.workshop_dialog,150)
	p.destination(parent,"Merchant",1,app.merchant_dialog,150)
	p.destination(parent,"Journey",2,app.world_dialog,150)
	var row = U.row(7)
	parent.add_child(row)
	for entry in [["journey","Journey"],["armory","Armory"],["supplies","Supplies"]]:
		var b = U.button(entry[1],func(): station(entry[0]))
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(b)
	if m.s.tutorial:
		app.dynamic(parent,func(): return "%d bounty · %d field · %d contract rewards ready" % [C.ready_bounties(m),RealmRuneforge.ready(m),RealmProgression.ready_count(m)],12,U.GOLD)
	if m.s.beacon: parent.add_child(U.button("Beyond the beacon",func(): preload("res://ui/endgame.gd").new(app).open()))
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
			entries = [["Work orders","Plan gathering and crafting for your time away.",app.work_orders_dialog],["Food & survival","Choose cooked food and understand automatic healing.",app.experience.survival],["Merchant","Browse rotating stock, buy supplies and sell spare equipment.",app.merchant_dialog],["Stronghold contracts","Collect milestone supplies you have earned.",app.contracts_dialog],["Rebuild Cinderwatch","Improve the forge, gates and resting hearth.",app.refuge_dialog]]
	for entry in entries:
		v.add_child(U.button(entry[0]+"  →",entry[2]))
	if kind=="armory": v.add_child(U.button("Masterwork blueprints",func(): preload("res://ui/masterworks.gd").new(app).open()))

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
	var v = app.modal("Talents")
	if locked(v): return
	var state = C.state(m)
	v.add_child(U.para("%d points available · %d / 60 earned" % [C.points_free(m),C.points_earned(m)],18,U.GOLD))
	v.add_child(U.para(RealmLegacyGrowth.next_point(m),14))
	var branches = {"power":["power","technique","hunter"],"guard":["guard","endurance","resolve"],"fortune":["fortune","recovery","bounty"]}
	preload("res://ui/premium.gd").tabs(v,[["power","Power"],["guard","Guard"],["fortune","Hunt"]],talent_branch,func(key):
		talent_branch=key
		chosen_talent=branches[key][0]
		talents())
	var path = preload("res://ui/route_view.gd").new()
	for key in branches[talent_branch]:
		path.entries.append({"title":C.TALENTS[key].name,"rank":"%d / %d" % [int(state.talents.get(key,0)),RealmLegacyGrowth.limit(key)],"done":int(state.talents.get(key,0))>=RealmLegacyGrowth.limit(key)})
	path.selected=branches[talent_branch].find(chosen_talent)
	path.changed=func(index):
		chosen_talent=branches[talent_branch][index]
		talents()
	v.add_child(path)
	for id in [chosen_talent]:
		var d = C.TALENTS[id]
		var rank = int(state.talents.get(id,0))
		var maximum = RealmLegacyGrowth.limit(id)
		var card = U.card(v,14)
		card.add_child(U.para(d.name,23,U.TEXT))
		card.add_child(U.para(d.detail,14))
		card.add_child(U.progress(rank,maximum,U.GOLD,5))
		card.add_child(U.label("RANK %d / %d" % [rank,maximum],11,U.GOLD))
		var why = RealmLegacyGrowth.talent_reason(m,id)
		if why!="": card.add_child(U.para(why,13))
		var button = U.button("Spend 1 point",func():
			if app.send({"type":"talent","id":id}): talents(),true)
		button.disabled = why!="" or not m.s.fight.is_empty()
		card.add_child(button)
		var ref = weakref(button)
		app.dialog_callbacks.append(func():
			var b = ref.get_ref()
			if is_instance_valid(b): b.disabled = RealmLegacyGrowth.talent_reason(m,id)!="" or not m.s.fight.is_empty())
	v.add_child(U.button("Reset talents · free",func():
		if app.send({"type":"talent_reset"}): talents()))
	if not m.s.fight.is_empty(): v.add_child(U.para("Retreat before changing talents.",13,U.RED))

func relics():
	var v = app.modal("Relics of the valley")
	if locked(v): return
	v.add_child(U.para("One active relic · four ascensions · 40 ranks each",15))
	v.add_child(U.para("Ranks 1–10 keep their original bonuses. Later ranks add smaller specialist effects and require essence from stronger hunts.",13))
	var state = C.state(m)
	U.scenic(v,preload("res://ui/premium.gd").art(3),"","Relic altar",125)
	var choices = []
	for key in C.RELICS: choices.append([key,C.RELICS[key].name])
	preload("res://ui/premium.gd").tabs(v,choices,chosen_relic,func(key):
		chosen_relic=key
		relics())
	for id in [chosen_relic]:
		var d = C.RELICS[id]
		var rank = int(state.relics[id])
		var card = U.card(v,15,Color(d.color).darkened(.4))
		var row = U.row(12)
		card.add_child(row)
		row.add_child(U.icon(d.icon,60))
		var details = U.column(4)
		row.add_child(details)
		details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		details.add_child(U.para(d.name,24,Color(d.color)))
		details.add_child(U.para("RANK %d / 40%s" % [rank," · EQUIPPED" if state.relic==id else ""],12,U.GOLD))
		card.add_child(U.para(RealmLegacyGrowth.relic_effect(id,rank),14,U.TEXT))
		if rank<40:
			card.add_child(U.para("Next: "+RealmLegacyGrowth.relic_effect(id,rank+1),13,U.GOLD))
			var cost = C.relic_cost(rank)
			if rank>=10: card.add_child(U.para("Ascension fee: "+RealmEconomy.money(RealmEconomy.relic_fee(rank)),14,U.GOLD))
			card.add_child(U.para("Fragments: %d / %d" % [state.fragments[id],cost],14))
			if rank>=10: card.add_child(U.para("Essence: %d / %d" % [m.count("essence_"+id),RealmLegacyGrowth.essence_cost(rank)],14))
			if rank>=30: card.add_child(U.para("%s: %d / 1" % [m.name_of(RealmLegacyGrowth.CORES[id]),m.count(RealmLegacyGrowth.CORES[id])],14))
			var why = RealmLegacyGrowth.relic_reason(m,id)
			if why!="": card.add_child(U.para(why,13))
			var button = U.button("Awaken" if rank==0 else "Upgrade to rank %d" % (rank+1),func():
				if app.send({"type":"relic_upgrade","id":id}): relics(),true)
			button.disabled = why!="" or not m.s.fight.is_empty()
			card.add_child(button)
			var ref = weakref(button)
			app.dialog_callbacks.append(func():
				var b = ref.get_ref()
				if is_instance_valid(b): b.disabled = RealmLegacyGrowth.relic_reason(m,id)!="" or not m.s.fight.is_empty())
		if rank>0 and state.relic!=id: card.add_child(U.button("Equip "+d.name,func():
			if app.send({"type":"relic_equip","id":id}): relics()))
		card.add_child(U.button("Find fragments & essence",func(): farms(id)))

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
	var v = app.modal("Beyond the walls")
	v.add_child(U.button("Beyond the Sovereign · three new regions",func(): preload("res://ui/frontiers.gd").new(app).open()))
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
	v.add_child(U.para("Clear each tier to open the next. Return for fragments and equipment.",14))
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
			if not RealmDiscovery.visible(m,id): continue
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
