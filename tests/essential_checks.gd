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
	check(not store.decode(store.encode(old_save),guided.data).is_empty(),"0.1 saves remain readable")
	print("ESSENTIAL CHECKS: ","PASS" if failed==0 else "FAIL")
	quit(1 if failed else 0)
