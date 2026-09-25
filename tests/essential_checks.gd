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
	print("ESSENTIAL CHECKS: ","PASS" if failed==0 else "FAIL")
	quit(1 if failed else 0)
