extends SceneTree
const Audit = preload("res://tests/balance34.gd")
func _init():
	var results = []
	for character in RealmCharacters.ALL:
		for target in ["secret_0","secret_6","hollow_depth"]:
			var m = Audit.build(character,"max",41)
			for family in ["necklace","belt","ring","ring"]:
				var uid = m.add_gear("dawnsteel_"+family,3)
				m.command({"type":"equip","id":uid})
			var c = RealmChronicle.state(m)
			c.relics.fang = 40
			for key in ["technique","hunter","endurance","resolve","recovery"]: c.talents[key] = 10
			if target=="hollow_depth":
				RealmEndgame.state(m).depth.active = true
				RealmEndgame.state(m).depth.floor = 50
			var outcome = Audit.fight(m,target)
			outcome.merge({"class":character,"enemy":target,"cards":0})
			results.append(outcome)
	var f = FileAccess.open("res://build/balance41.json",FileAccess.WRITE)
	f.store_string(JSON.stringify(results,"  "))
	print("BALANCE41: ",results.size()," encounters; ",results.filter(func(r): return r.win).size()," wins. Full results in build/balance41.json")
	quit()
