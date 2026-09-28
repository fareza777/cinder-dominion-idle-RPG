extends SceneTree

class AuditModel extends RealmModel:
	var lowest_before_meal = 100
	var peak_hit = 0
	func combat_event(message: String, side: String, kind: String = "hit", skill: String = ""):
		super.combat_event(message,side,kind,skill)
		if side=="hero" and message.begins_with("−"):
			lowest_before_meal = mini(lowest_before_meal,maxi(0,int(s.hp)))
			peak_hit = maxi(peak_hit,int(message.trim_prefix("−").get_slice(" ",0)))

static func build(character: String, tier: String, seed_value: int = 42):
	var m = AuditModel.new()
	m.fresh(seed_value)
	m.command({"type":"hero_create","id":character,"name":"Audit Hero"})
	m.s.tutorial = true
	m.s.beacon = true
	for skill in m.data.skills: m.s.xp[skill] = 245025
	for id in m.data.enemies: m.s.kills[id] = 5
	m.s.gear = m.s.gear.filter(func(g): return m.data.items[g.id].slot in ["pick","axe","rod"])
	for slot in ["weapon","shield","head","body","hands","feet"]: m.s.equipped.erase(slot)
	for part in ["sword","shield","helm","chest","gloves","boots"]:
		var id = ("dusksteel_" if tier=="under" else "dawnsteel_")+part
		var uid = m.add_gear(id,1 if tier=="under" else (3 if tier=="prepared" else 5))
		m.s.equipped[m.data.items[id].slot] = uid
	if tier=="unique":
		for i in [1,2,3,4,5]:
			var id = "relic_%d" % i
			var uid = m.add_gear(id,3)
			m.s.equipped[m.data.items[id].slot] = uid
	var c = RealmChronicle.state(m)
	c.talents = {"power":5,"guard":5,"fortune":0}
	c.relics = {"fang":10,"ward":10,"heart":10}
	c.relic = "fang"
	RealmRuneforge.state(m).ranks = {"thorn":3,"tide":3,"bell":3}
	RealmRuneforge.state(m).equipped = "thorn"
	m.progression().stance = "reaver"
	m.progression().upgrades.ward = 3
	m.s.doctrine = "bastion"
	m.s.hero.attributes = {"might":10,"resolve":8,"focus":4}
	m.s.settings.food = "cooked_dawnsteel_fish"
	m.s.settings.threshold = .9
	m.s.bag.cooked_dawnsteel_fish = 10000
	if tier in ["max","unique"]:
		m.s.path_choice = {"warden":1,"ranger":0,"arcanist":0,"reaver":0,"apothecary":1}.get(character,0)
		m.s.sockets = ["ember","fracture"]
		for id in m.s.sockets: m.s.bag["socket_"+id] = 1
	return m

static func fight(m, id: String) -> Dictionary:
	var wins = int(m.s.kills.get(id,0))
	var before = int(m.count(m.s.settings.food))
	var forecast = RealmCombat.forecast(m,id)
	var start = int(m.s.time)
	var low = 100
	if not m.command({"type":"queue","id":"hunt_"+id,"target":1}): return {"error":m.error}
	while not m.s.queue.is_empty() and int(m.s.time)-start<3600000:
		m.advance(1000)
		low = mini(low,int(m.s.hp))
	return {"win":int(m.s.kills.get(id,0))>wins,"seconds":(int(m.s.time)-start)/1000,"meals":before-m.count(m.s.settings.food),"lowest_hp":m.lowest_before_meal,"peak_hit":m.peak_hit,"forecast_burst":forecast.burst,"forecast_risk":forecast.risk,"attack":m.stats().attack,"armor":m.stats().armor}

func _init():
	var results = []
	for character in RealmCharacters.ALL:
		for tier in ["under","prepared","max","unique"]:
			for i in range(7):
				var m = build(character,tier)
				var id = "secret_%d" % i
				var result = fight(m,id)
				result.merge({"class":character,"build":tier,"enemy":id})
				results.append(result)
	for character in RealmCharacters.ALL:
		for floor_value in [1,5,10,20,50]:
			var m = build(character,"unique")
			var d = RealmEndgame.state(m).depth
			d.active = true
			d.floor = floor_value
			var result = fight(m,"hollow_depth")
			result.merge({"class":character,"build":"unique","enemy":"depth_%d" % floor_value})
			results.append(result)
	# Campaign samples retain actual level, gear and supplies for the chosen stage.
	for stage in [["ash_rat",1,"copper",1,"cooked_minnow"],["bellkeeper",20,"iron",2,"cooked_trout"],["wilds_5",35,"iron",3,"cooked_trout"],["apex_wilds_1",45,"steel",3,"cooked_steel_fish"],["apex_marsh_2",70,"dusksteel",3,"cooked_dusksteel_fish"],["apex_crown_3",100,"dawnsteel",3,"cooked_dawnsteel_fish"]]:
		for character in RealmCharacters.ALL:
			var m = build(character,"prepared")
			for skill in m.data.skills: m.s.xp[skill] = 25*(stage[1]-1)*(stage[1]-1)
			m.s.hero.attributes = {"might":0,"resolve":0,"focus":0}
			RealmChronicle.state(m).talents = {"power":0,"guard":0,"fortune":0}
			RealmChronicle.state(m).relic = ""
			RealmRuneforge.state(m).equipped = ""
			m.s.doctrine = "none"
			m.progression().stance = "balanced"
			m.progression().upgrades.ward = 0
			for part in ["sword","shield","helm","chest","gloves","boots"]:
				var id = stage[2]+"_"+part
				var uid = m.add_gear(id,stage[3])
				m.s.equipped[m.data.items[id].slot] = uid
			m.s.settings.food = stage[4] if m.data.items.has(stage[4]) else "cooked_minnow"
			m.s.bag[m.s.settings.food] = 1000
			var result = fight(m,stage[0])
			result.merge({"class":character,"build":"campaign_%d" % stage[1],"enemy":stage[0]})
			results.append(result)
	var file = FileAccess.open("res://build/balance34.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(results,"  "))
	print("BALANCE 34: ",results.size()," measured fights written")
	quit()
