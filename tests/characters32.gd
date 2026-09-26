extends SceneTree

func _init():
	var store = RealmSave.new()
	var old = RealmModel.new()
	assert(RealmDiscovery.enemies(old)==["ash_rat"])
	assert(not store.decode(store.encode(old.s),old.data).is_empty())
	for bad in ["", " ","A","bad\nname","<hero>","-''-"]:
		assert(not RealmCharacters.valid_name(bad))
	assert(RealmCharacters.valid_name("Éowyn 7"))
	for id in RealmCharacters.ALL:
		var m = RealmModel.new()
		var original_gold = m.s.gold
		assert(m.command({"type":"hero_create","id":id,"name":"Test Hero"}))
		assert(m.s.gold==original_gold)
		assert(not m.command({"type":"hero_create","id":"warden","name":"Overwrite"}))
		assert(RealmCharacters.points(m)==3)
		for i in range(3): assert(m.command({"type":"attribute_add","id":"might"}))
		assert(not m.command({"type":"attribute_add","id":"might"}))
		assert(m.command({"type":"attribute_reset"}))
		assert(RealmCharacters.points(m)==3 and RealmCharacters.rank(m)==0)
		m.s.xp.bladecraft = 400
		assert(RealmCharacters.rank(m)==1)
		var neutral = RealmModel.new()
		neutral.s = m.s.duplicate(true)
		neutral.s.erase("hero")
		var enemy = m.data.enemies.bellkeeper
		if id=="warden": assert(RealmCombat.move(m,enemy,3,15).damage<RealmCombat.move(neutral,enemy,3,15).damage)
		if id=="ranger": assert(RealmCombat.player_damage(m,enemy,4)>RealmCombat.player_damage(neutral,enemy,4))
		if id=="arcanist": assert(RealmCombat.player_damage(m,enemy,4)>=RealmCombat.player_damage(neutral,enemy,4))
		assert(not store.decode(store.encode(m.s),m.data).is_empty())
		var forged = m.s.duplicate(true)
		forged.hero.attributes.might = 22
		assert(not store.valid(forged,m.data))
		assert(m.command({"type":"queue","id":"hunt_ash_rat","target":3}))
		assert(not m.command({"type":"attribute_add","id":"resolve"}))
		var whole = RealmModel.new()
		whole.s = m.s.duplicate(true)
		whole.advance(120000)
		for i in range(120): m.advance(1000)
		assert(store.decode(store.encode(m.s),m.data)==store.decode(store.encode(whole.s),whole.data))
		m.s.tutorial = true
		assert("grave_thrall" in RealmDiscovery.enemies(m))
		assert("cinder_bandit" not in RealmDiscovery.enemies(m))
		m.s.kills.grave_thrall = 5
		assert("cinder_bandit" in RealmDiscovery.enemies(m))
		assert("chapel_guard" not in RealmDiscovery.enemies(m))
	print("CHARACTERS 32 PASS: legacy saves, names, three class effects, points/locks, save validation, combat chunk equivalence and progressive discovery")
	quit()
