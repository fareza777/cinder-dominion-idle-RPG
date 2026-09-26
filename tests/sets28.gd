extends SceneTree
func equip_set(m, metal: String):
	for part in ["gloves","boots"]:
		m.gain(metal+"_"+part,1,1)
		for gear in m.s.gear:
			if gear.id==metal+"_"+part: m.s.equipped[m.data.items[gear.id].slot] = gear.uid

func _init():
	var m = RealmModel.new()
	for skill in m.data.skills: m.s.xp[skill] = 245025
	m.s.tutorial = true
	m.s.beacon = true
	var enemy = m.data.enemies.apex_marsh_2
	var ordinary = RealmCombat.move(m,enemy,1,20).damage
	var special = RealmCombat.move(m,enemy,3,20).damage
	var healing = RealmCombat.move(m,enemy,3,20).heal
	equip_set(m,"steel")
	assert(RealmCombat.move(m,enemy,1,20).damage==ordinary)
	assert(RealmCombat.move(m,enemy,3,20).damage<special)
	equip_set(m,"moonsteel")
	assert(RealmCombat.move(m,enemy,3,20).heal<healing and not RealmGearSets.active(m,"steel"))
	var basic = RealmCombat.player_damage(m,enemy,1)
	var fourth = RealmCombat.player_damage(m,enemy,4)
	equip_set(m,"dusksteel")
	assert(RealmCombat.player_damage(m,enemy,1)==basic and RealmCombat.player_damage(m,enemy,4)>fourth)
	var food = RealmCombat.food_heal(m,"cooked_minnow")
	equip_set(m,"dawnsteel")
	assert(RealmCombat.food_heal(m,"cooked_minnow")==food+8)
	m.s.equipped.erase("feet")
	assert(not RealmGearSets.active(m,"dawnsteel"))
	# Tools and weapons never complete an armor set.
	for part in ["sword","pick"]:
		m.gain("dawnsteel_"+part,1,1)
		for g in m.s.gear:
			if g.id=="dawnsteel_"+part: m.s.equipped[m.data.items[g.id].slot] = g.uid
	assert(RealmGearSets.counts(m).dawnsteel==1)
	equip_set(m,"dawnsteel")
	m.command({"type":"loadout_save","id":"journey"})
	var before = m.s.duplicate(true)
	assert(RealmBuildCompare.preview(m,"journey","ash_rat").error=="" and m.s==before)
	var store = RealmSave.new()
	assert(not store.decode(store.encode(m.s),m.data).is_empty())
	print("SETS: threshold, slot exclusions, four effects, switching, read-only loadout forecast and save validation PASS")
	# Small actual encounter sweep; no claim of complete balance coverage.
	for metal in RealmGearSets.ALL:
		var fighter = RealmModel.new()
		for skill in fighter.data.skills: fighter.s.xp[skill] = 245025
		fighter.s.tutorial = true
		fighter.s.beacon = true
		fighter.s.kills.apex_marsh_1 = 1
		for part in ["sword","shield","helm","chest","gloves","boots"]: fighter.gain("dawnsteel_"+part,1,3)
		fighter.command({"type":"equip_best"})
		equip_set(fighter,metal)
		fighter.s.bag.cooked_dawnsteel_fish = 500
		fighter.s.settings.food = "cooked_dawnsteel_fish"
		var f = RealmCombat.forecast(fighter,"apex_marsh_2")
		fighter.command({"type":"queue","id":"hunt_apex_marsh_2","target":1})
		var copy = RealmModel.new()
		copy.s = store.decode(store.encode(fighter.s),copy.data)
		fighter.advance(600000)
		for i in range(60): copy.advance(10000)
		assert(store.decode(store.encode(fighter.s),fighter.data)==store.decode(store.encode(copy.s),copy.data))
		print("BUILD ",metal," forecast_seconds=",f.seconds," meals=",f.meals," wins=",fighter.s.kills.get("apex_marsh_2",0)," food_spent=",500-fighter.count("cooked_dawnsteel_fish"))
	quit()
