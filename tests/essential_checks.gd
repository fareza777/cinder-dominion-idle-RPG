extends SceneTree

var failed = 0
func check(ok: bool, label: String):
	if not ok:
		failed += 1
		push_error(label)
	else: print("PASS ",label)

func _init():
	var m = RealmModel.new()
	check(m.data.items.size()==40,"40 item definitions")
	m.command({"type":"queue","id":"mine_copper","target":4})
	m.advance(12000)
	check(m.count("copper_ore")==4,"gather four ore")
	m.command({"type":"queue","id":"craft_copper_ingot","target":2})
	m.advance(6000)
	check(m.count("copper_ore")==0 and m.count("copper_ingot")==2,"craft consumes once")
	m.command({"type":"queue","id":"craft_copper_sword","target":1})
	check(m.count("copper_ingot")==2,"missing ingredient cannot partially debit")
	m.command({"type":"clear"})
	var a = RealmModel.new()
	a.command({"type":"queue","id":"hunt_ash_rat","target":100})
	var b = RealmModel.new()
	b.s = a.s.duplicate(true)
	a.advance(60000)
	for i in range(60): b.advance(1000)
	check(a.s==b.s,"combat offline/chunks agree")
	var store = RealmSave.new()
	m.s.wall = 1790000000000
	check(store.valid(m.s,m.data),"valid current timestamp")
	var restored = store.decode(store.encode(m.s),m.data)
	check(not restored.is_empty() and restored.rng==m.s.rng,"save roundtrip retains RNG")
	var bad = m.s.duplicate(true)
	bad.bag.copper_ore = -1
	check(store.decode(store.encode(bad),m.data).is_empty(),"reject corrupted negative inventory")
	var once = RealmModel.new()
	var buy = {"type":"buy","id":"empty_vial","amount":1,"cid":"same"}
	once.command(buy)
	once.command(buy)
	check(once.count("empty_vial")==1 and once.s.gold==18,"duplicate command is idempotent")
	var guided = RealmModel.new()
	check(guided.s.settings.locale=="en" and guided.objective().key=="ore","English default with concrete first objective")
	for activity in [["mine_copper",4,12000],["craft_copper_ingot",2,6000],["cut_ash",1,3000],["craft_copper_sword",1,5000]]:
		guided.command({"type":"queue","id":activity[0],"target":activity[1]})
		guided.advance(activity[2])
	check(guided.objective().key=="equip","guided crafts lead to explicit equip step")
	for g in guided.s.gear:
		if g.id=="copper_sword": guided.command({"type":"equip","id":g.uid})
	guided.command({"type":"queue","id":"hunt_ash_rat","target":3})
	guided.advance(90000)
	check(guided.s.tutorial and guided.objective().key=="thralls","tutorial continues toward enemy unlocks, not straight to boss")
	var old_save = guided.s.duplicate(true)
	old_save.erase("experience")
	old_save.erase("chronicle")
	old_save.erase("progression")
	check(not store.decode(store.encode(old_save),guided.data).is_empty(),"0.1 saves remain readable")
	var planned = RealmModel.new()
	var chain = RealmProgression.plan(planned,"craft_copper_sword",1)
	check(chain.error=="" and chain.steps.size()==4 and planned.s.queue.is_empty(),"planner previews dependencies without spending stock")
	planned.command({"type":"plan","id":"craft_copper_sword","amount":1})
	planned.advance(26000)
	check(planned.s.gains.get("copper_sword",0)==1 and planned.count("copper_ore")==0 and planned.count("copper_ingot")==0 and planned.s.queue.is_empty(),"planned sword gathers and crafts with exact input accounting")
	planned.s.gains.copper_ore = 20
	planned.command({"type":"claim","id":"ore"})
	var gold_after = planned.s.gold
	var duplicate = planned.command({"type":"claim","id":"ore"})
	planned.command({"type":"upgrade","id":"forge"})
	check(not duplicate and planned.s.gold==gold_after-40 and planned.progression().upgrades.forge==1 and not store.decode(store.encode(planned.s),planned.data).is_empty(),"contract pays once and purchased upgrade survives save validation")
	var guarded = RealmModel.new()
	guarded.command({"type":"stance","id":"guard"})
	guarded.command({"type":"queue","id":"hunt_ash_rat","target":100})
	var chunked = RealmModel.new()
	chunked.s = guarded.s.duplicate(true)
	guarded.advance(180000)
	for i in range(180): chunked.advance(1000)
	check(guarded.s==chunked.s and guarded.stats().armor==5,"Warden skills remain deterministic online and offline")
	var legacy = RealmModel.new()
	legacy.s.tutorial = true
	legacy.s.xp.might = 500
	legacy.command({"type":"talent","id":"power"})
	RealmChronicle.state(legacy).fragments.fang = 5
	legacy.command({"type":"relic_upgrade","id":"fang"})
	check(legacy.stats().attack==7 and RealmChronicle.state(legacy).fragments.fang==0 and RealmChronicle.points_free(legacy)==1,"talent and equipped relic change combat stats with exact cost")
	RealmChronicle.sync_day(legacy,20000*86400000)
	legacy.s.mastery.mine_copper = 30
	legacy.command({"type":"bounty_claim","id":"gather"})
	var paid = legacy.s.gold
	var repeated = legacy.command({"type":"bounty_claim","id":"gather"})
	RealmChronicle.sync_day(legacy,20001*86400000)
	check(not repeated and legacy.s.gold==paid and legacy.s.chronicle.daily.day==20000,"bounty cannot double-pay and unfinished board carries over")
	legacy.s.mastery.craft_copper_ingot = 10
	legacy.s.kills.ash_rat = 8
	legacy.command({"type":"bounty_claim","id":"craft"})
	legacy.command({"type":"bounty_claim","id":"hunt"})
	RealmChronicle.sync_day(legacy,20001*86400000)
	check(legacy.s.chronicle.daily.day==20001 and RealmChronicle.bounty_value(legacy,"gather")==0 and not store.decode(store.encode(legacy.s),legacy.data).is_empty(),"completed bounty rotates once with fresh baseline and valid legacy state")
	var expedition = RealmModel.new()
	expedition.s.beacon = true
	expedition.s.tutorial = true
	for part in ["sword","shield","helm","chest","gloves","boots"]: expedition.gain("iron_"+part,1,3)
	expedition.command({"type":"equip_best"})
	expedition.s.bag.cooked_minnow = 100
	expedition.command({"type":"queue","id":"hunt_wilds_1","target":2})
	var twin = RealmModel.new()
	twin.s = expedition.s.duplicate(true)
	expedition.advance(300000)
	for i in range(300): twin.advance(1000)
	check(expedition.s==twin.s and expedition.s.kills.get("wilds_1",0)==2 and expedition.count("scrap")==6 and expedition.available("wilds_2")=="" and expedition.available("marsh_1")!="","expedition rewards first clear once, gates tiers, and matches offline simulation")
	var order = RealmModel.new()
	var preview = RealmProgression.order_plan(order,"forge",1)
	order.command({"type":"work_order","id":"forge","batches":1})
	order.advance(5000000)
	check(preview.steps.size()==2 and order.count("copper_ingot")==500 and order.count("copper_ore")==0 and order.s.xp.smithing==4000 and order.s.queue.is_empty(),"long work order gathers inputs, earns XP and finishes while offline")
	var wild = RealmCombat.move(expedition,expedition.data.enemies.wilds_1,3,20)
	var plain = RealmCombat.move(expedition,expedition.data.enemies.wilds_1,1,20)
	var oracle = RealmCombat.move(expedition,expedition.data.enemies.marsh_1,3,20)
	var crown = RealmCombat.move(expedition,expedition.data.enemies.crown_1,3,20)
	check(wild.damage>plain.damage and oracle.heal==8 and crown.damage>RealmCombat.move(expedition,expedition.data.enemies.crown_1,1,20).damage,"guardians have distinct armor-piercing, recovery and burst attacks")
	check(RealmCombat.forecast(expedition,"wilds_1").fragments_per_minute>RealmCombat.forecast(expedition,"ash_rat").fragments_per_minute,"unlocked expedition improves predicted relic yield over starter rats")
	var healer = RealmModel.new()
	healer.s.tutorial = true
	RealmChronicle.state(healer).relics.heart = 2
	healer.s.chronicle.relic = "heart"
	healer.s.hp = 30
	healer.command({"type":"queue","id":"hunt_ash_rat","target":1})
	healer.s.fight.enemy_at = 1
	healer.advance(1)
	check(RealmCombat.food_heal(healer,"cooked_minnow")==26 and healer.s.hp>=55 and healer.count("cooked_minnow")==4,"displayed relic healing matches food consumed in combat")
	var marsh = RealmModel.new()
	marsh.s = expedition.s.duplicate(true)
	marsh.command({"type":"clear"})
	marsh.s.kills.wilds_5 = 1
	marsh.s.hp = 100
	marsh.s.bag.cooked_minnow = 100
	marsh.command({"type":"queue","id":"hunt_marsh_1","target":3})
	var marsh_chunks = RealmModel.new()
	marsh_chunks.s = marsh.s.duplicate(true)
	marsh.advance(180000)
	for i in range(180): marsh_chunks.advance(1000)
	check(marsh.s==marsh_chunks.s,"Oracle healing stays deterministic during offline combat")
	print("ESSENTIAL CHECKS: ","PASS" if failed==0 else "FAIL")
	quit(1 if failed else 0)
