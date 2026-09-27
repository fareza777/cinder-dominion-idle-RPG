extends SceneTree
const Audit = preload("res://tests/balance34.gd")
func _init():
	var results = []
	for character in RealmCharacters.ALL:
		for index in [2,4,6]:
			var best = {}
			for stance in ["balanced","reaver","guard"]:
				for path in [0,1]:
					for sockets in [["shelter","fracture"],["shelter","echo"]]:
						var m = Audit.build(character,"max")
						# Only relics from earlier guardians; no circular unlock dependency.
						for i in range(1,index):
							var item = "relic_%d" % i
							var uid = m.add_gear(item,3 if index>2 else 1)
							m.s.equipped[m.data.items[item].slot] = uid
						if index==6: RealmEndgame.state(m).route = "safe"
						m.s.path_choice = path
						m.s.sockets = sockets.duplicate()
						for id in sockets: m.s.bag["socket_"+id] = 1
						m.progression().stance = stance
						var result = Audit.fight(m,"secret_%d" % index)
						result.merge({"class":character,"enemy":"secret_%d" % index,"stance":stance,"path":path,"sockets":sockets,"route":RealmEndgame.route(m)})
						if best.is_empty() or (result.win and not best.win) or (result.win==best.win and result.seconds<best.seconds): best = result
			results.append(best)
			# Verify the chosen counter with two additional deterministic RNG streams.
			if best.win:
				for seed_value in [7,2026]:
					var m = Audit.build(character,"max",seed_value)
					for i in range(1,index):
						var item = "relic_%d" % i
						m.s.equipped[m.data.items[item].slot] = m.add_gear(item,3 if index>2 else 1)
					m.s.path_choice = best.path
					m.s.sockets = best.sockets.duplicate()
					for id in m.s.sockets: m.s.bag["socket_"+id] = 1
					m.progression().stance = best.stance
					RealmEndgame.state(m).route = best.route
					var checked = Audit.fight(m,"secret_%d" % index)
					checked.merge({"class":character,"enemy":"secret_%d" % index,"seed":seed_value,"route":best.route})
					results.append(checked)
	var file = FileAccess.open("res://build/counters34.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(results,"  "))
	print("COUNTERS 34: ",JSON.stringify(results))
	quit()
