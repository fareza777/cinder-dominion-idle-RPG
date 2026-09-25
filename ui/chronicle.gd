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
	card.add_child(U.label("YOUR NEXT MOVE",10,U.GOLD))
	app.dynamic(card,func(): return C.focus(m).title,24,U.TEXT)
	app.dynamic(card,func(): return C.focus(m).why,14)
	var action = U.button("Continue",act,true)
	card.add_child(action)
	var ref = weakref(action)
	app.update_callbacks.append(func():
		var b = ref.get_ref()
		if is_instance_valid(b): b.text = {"story":"Start next objective  →","queue":"View active plan  →","talents":"Choose my talents  →","relics":"Awaken relic  →","equip":"Equip best gear  →","plan":"Review supply plan  →"}[C.focus(m).kind])
	card.add_child(U.button("See my progression roadmap",roadmap))
	if m.s.tutorial:
		var board = U.card(parent,12)
		app.dynamic(board,func(): return "%d talent points · %d bounty rewards ready" % [C.points_free(m),C.ready_bounties(m)],14,U.GOLD)
		var row = U.row(6)
		board.add_child(row)
		for entry in [["Bounties",bounties],["Relics",relics],["World map",world]]:
			var b = U.button(entry[0],entry[1])
			b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(b)
		board.add_child(U.button("Leave work for the refuge",app.work_orders_dialog))

func act():
	var focus = C.focus(m)
	match focus.kind:
		"queue": app.queue_dialog()
		"story": app.experience.act_on_goal()
		"talents": talents()
		"relics": relics()
		"plan": app.planner_dialog(focus.id,int(focus.amount))
		"equip":
			if app.send({"type":"equip_best"}): app.toast("Upgrades equipped. Your next recommendation is ready.")

func roadmap():
	var v = app.modal("Your path through the ashes")
	v.add_child(U.para("From a worn blade to the far side of the valley.",20,U.TEXT))
	var stages = [
		["01","First Supplies","Gather 4 ore → smelt 2 ingots → gather 1 log → forge and equip a sword → defeat 3 rats.","Unlock: talents, relics, bounties and the graveyard.",m.s.tutorial],
		["02","Prepare to survive","Cook food. Fill armor slots. Hunt each enemy 5 times to open the next route. Spend earned talent points and awaken a relic.","Bring home: materials, stronger gear, gold and relic fragments.",int(m.s.kills.get("ember_wraith",0))>=5],
		["03","Restore the beacon","Train Smithing to 10. Forge iron gear when its materials are unlocked. Defeat the Bellkeeper with food and your chosen build.","Unlock: three expedition regions and 15 difficulty tiers.",m.s.beacon],
		["04","Explore the three realms","Clear each tier once to open the next. Repeat a tier to target its relic fragments and iron equipment drops.","Bring home: 30 relic ranks, 15 talent ranks and rare iron gear.",C.next_expedition(m)==""]]
	for stage in stages:
		var c = U.card(v,14,U.GREEN if stage[4] else U.LINE)
		c.add_child(U.para(stage[0]+"  "+stage[1]+(" · COMPLETE" if stage[4] else ""),20,U.GOLD))
		c.add_child(U.para(stage[2],14,U.TEXT))
		c.add_child(U.para(stage[3],13))
	v.add_child(U.para("RETURNING LOOP\nCollect offline progress → claim finished bounties → improve one part of your build → choose a farm or attempt the next tier → queue supplies before leaving.",15,U.GREEN))
	v.add_child(U.button("Take my next step",act,true))

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
		card.add_child(U.button("Farm fragments · preview hunt",func(): app.activity_dialog("hunt_"+d.enemy,10)))

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
	v.add_child(U.para("Clear a tier once to open the next. Repeat cleared tiers for guaranteed fragments and a 5% chance of iron equipment. Every third enemy strike is empowered.",14))
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
