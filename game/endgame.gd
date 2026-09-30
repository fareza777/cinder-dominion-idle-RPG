class_name RealmEndgame
extends RefCounted

const IDS = ["secret_0","secret_1","secret_2","secret_3","secret_4","secret_5","secret_6","march_guard_0","march_guard_1","march_guard_2","march_guard_3","march_guard_4"]
const ROUTES = {"safe":"Take 12% less damage; gain 20% less gold and XP.","resource":"Standard danger and rewards.","elite":"Take 20% more damage; gain 25% more coins and XP.","mastery":"Standard danger; gain 20% more XP and 20% less gold."}
const CONTRACTS = {"gather":["Gather supplies",60],"craft":["Keep the forge working",25],"hunt":["Complete hunts",12],"frontline":["Frontline commission",6],"elite":["Defeat optional guardians",3],"depth":["Clear Depths rooms",3]}

static func defaults() -> Dictionary:
	return {"route":"resource","target":"","depth":{"active":false,"floor":1,"best":0,"stash":0,"risk":"steady"},"board":{"day":-1,"selected":[],"claimed":[],"baseline":{}},"week":-1,"weekly_claimed":false,"weekly_enemy":"","weekly_base":0,"rooms":0}

static func state(m) -> Dictionary:
	if not m.s.has("endgame"): m.s.endgame = defaults()
	return m.s.endgame

static func route(m) -> String: return m.s.get("endgame",{}).get("route","resource")

static func available(m, id: String) -> String:
	var e = m.data.enemies[id]
	if not m.s.beacon or int(m.s.kills.get(e.unlock,0))<1: return "Uncharted · clear the preceding challenge to reveal this location."
	if id=="hollow_depth" and not state(m).depth.active: return "Enter the Hollow Depths from Optional expeditions."
	return ""

static func enemy(m, original: Dictionary) -> Dictionary:
	var e = original.duplicate(true)
	if e.get("depth",false):
		var d = state(m).depth
		var floor_index = maxi(0,int(d.floor)-1) if d.active else 0
		e.hp = int(e.hp*(1+floor_index*.22))
		e.attack = int(e.attack*(1+floor_index*.065))
		e.armor = int(e.armor+floor_index*2)
		e.pressure = int(e.pressure)+int(floor_index/3)
		if d.risk=="perilous": e.attack = int(e.attack*1.2)
		e.name = "Hollow Sentinel · Depth %d" % d.floor
		e.en = e.name
		var variant=int(floor_index)%4
		e.status=["burn","chill","bleed","weaken"][variant]
		e.special_name=["Cinder Sweep","Winter Grasp","Rending Chain","Hollow Toll"][variant]
		if variant==0:e.attack=int(e.attack*1.08)
		elif variant==1:e.armor=int(e.armor*1.15)
		elif variant==2:e.interval=int(e.interval*.92)
		else:e.special_heal=.005
		if int(d.floor)%5==0:e.hp=int(e.hp*1.2);e.pressure+=2
	return e

static func move(m, e: Dictionary, strike: int, damage: int, phase: bool) -> int:
	# Unavoidable pressure keeps armor stacking from trivializing optional endgame.
	if e.get("secret",false) or e.get("depth",false) or (e.has("frontier") or e.has("march") or e.has("realm")):
		if phase: damage = ceili(damage*1.18)
		if strike%3==0: damage += int(e.pressure)*(2 if phase else 1)
		# Fixed escalation after sustained exposure, independent of player gear.
		damage = ceili(damage*(1+minf(1.5,int(strike/15)*.12)))
	if route(m)=="safe": damage = ceili(damage*.88)
	elif route(m)=="elite": damage = ceili(damage*1.2)
	return maxi(1,damage)

static func totals(m) -> Dictionary:
	var result = RealmChronicle.totals(m)
	result.elite = 0
	for id in IDS: result.elite += int(m.s.kills.get(id,0))
	result.depth = int(state(m).rooms)
	result.frontline=int(m.s.kills.get(state(m).board.get("target",""),0))
	return result

static func proven_hunts(m) -> Array:
	var out=m.data.enemies.keys().filter(func(id):return m.s.kills.get(id,0)>0 and not m.data.enemies[id].get("depth",false))
	out.sort_custom(func(a,b):return m.data.enemies[a].gold>m.data.enemies[b].gold)
	return out

static func reward_scale(m) -> int:
	var value=0
	for id in m.s.kills:
		if m.s.kills[id]>0 and not m.data.enemies[id].get("depth",false):value=maxi(value,int(m.data.enemies[id].gold))
	return value

static func contract_reward(m,id: String) -> Dictionary:
	var weight={"gather":.5,"craft":.6,"hunt":.75,"frontline":2.0,"elite":1.5,"depth":1.2}.get(id,.5)
	var out={"gold":maxi(50+5*m.level("bladecraft"),int(reward_scale(m)*weight)),"scrap":5,"material":"","amount":0}
	var target=state(m).board.get("target","")
	if id=="frontline" and m.data.enemies.has(target):out.material=m.data.enemies[target].drop;out.amount=8
	return out

static func weekly_pool() -> Array:
	var out=IDS.duplicate()
	for r in range(7):out.append("realm_%d_9" % r)
	return out

static func weekly_reward(m) -> Dictionary:
	var id=state(m).weekly_enemy
	var realm=int(m.data.enemies.get(id,{}).get("realm",-1))
	return {"gold":int(m.data.enemies.get(id,{}).get("gold",0))*3,"seals":3+maxi(0,realm+1),"shards":5+maxi(0,realm+1)*3}

static func victory(m, e: Dictionary):
	if e.get("secret",false):
		m.gain("dread_token",2)
		if int(m.s.kills.get(e.id,0))==0:
			m.gain(e.drop,2)
			m.note("Blueprint learned: %s. Forge its unfinished component, then complete the relic." % m.name_of("relic_"+str(int(e.secret_tile))))
		# Pity alternative: a named relic is always purchasable after eight wins.
		if m.rng.randf()<.08:
			m.gain("relic_"+str(int(e.secret_tile)),1,1)
			RealmHunts.equipment(m,"relic_"+str(int(e.secret_tile)),1)
			m.note("Unique relic found: "+m.name_of("relic_"+str(int(e.secret_tile))))
	if e.get("depth",false):
		var d = state(m).depth
		d.stash += (3 if d.risk=="perilous" else 2)+int(d.floor/5)
		d.best = maxi(int(d.best),int(d.floor))
		if int(d.floor)%5==0:d.checkpoint=int(d.floor)
		d.floor = mini(1000,int(d.floor)+1)
		state(m).rooms += 1
		m.note("Depth cleared. Bank %d Hollow Shards or continue into greater danger." % d.stash)

static func defeat(m):
	if not m.s.has("endgame"): return
	var d = state(m).depth
	if d.active:
		d.active = false
		d.stash = 0
		m.note("Expedition ended. Only unbanked Hollow Shards were lost.")

static func target_status(m) -> Dictionary:
	var id = str(state(m).target)
	if id=="": return {}
	if m.count(id)>0: return {"text":"Target obtained · open your equipment bag","activity":"","item":id,"done":true}
	var index = int(id.trim_prefix("relic_"))
	var boss = "secret_%d" % index
	if int(m.s.kills.get(boss,0))==0:
		return {"text":"Discover the location and defeat its guardian to learn the blueprint.","activity":"hunt_"+boss,"item":id,"done":false}
	var recipe = m.data.activities["craft_"+id]
	var missing = []
	for key in recipe.inputs:
		if m.count(key)<recipe.inputs[key]: missing.append("%s %d/%d" % [m.name_of(key),m.count(key),recipe.inputs[key]])
	return {"text":"Ready to forge" if missing.is_empty() else " · ".join(missing),"activity":"craft_"+id,"item":id,"done":false}

static func command(m, cmd) -> String:
	var s = state(m)
	var id = str(cmd.get("id",""))
	match cmd.type:
		"end_route":
			if not m.s.fight.is_empty(): return "Finish your hunt before changing routes."
			if id not in ROUTES: return "Unknown route."
			s.route = id
		"end_target":
			if id!="" and id not in ["relic_0","relic_1","relic_2","relic_3","relic_4","relic_5","relic_6"]: return "Choose a relic target."
			s.target = id
		"end_trade":
			if id not in ["relic_0","relic_1","relic_2","relic_3","relic_4","relic_5","relic_6"]: return "Unknown relic."
			var boss = "secret_"+id.trim_prefix("relic_")
			if m.s.kills.get(boss,0)<8: return "Defeat this guardian eight times to unlock its guaranteed relic."
			if m.count("dread_token")<16: return "Collect 16 Dread Seals."
			m.spend("dread_token",16)
			m.gain(id,1,1)
		"end_temper":
			if not m.s.fight.is_empty(): return "Finish your hunt before tempering equipment."
			var g = m.gear(id)
			if g.is_empty() or not g.id.begins_with("relic_") or g.q>=3: return "Choose a unique relic below Rare quality."
			var merge = m.s.gear.any(func(other): return other.id==g.id and int(other.q)==int(g.q)+1)
			if g.count>1 and m.s.gear.size()>=1000 and not merge: return "Make room in your equipment bag before splitting this stack."
			var cost = 10*(int(g.q)+1)
			var fee = RealmEconomy.temper_fee(int(g.q))
			if m.s.gold<fee: return "Tempering requires "+RealmEconomy.money(fee)+" plus seals and shards."
			if m.count("dread_token")<cost or m.count("depth_shard")<cost: return "Gather %d Dread Seals and Hollow Shards." % cost
			m.s.gold -= fee
			m.spend("dread_token",cost)
			m.spend("depth_shard",cost)
			# Upgrade a single piece, preserving references and flags.
			var old_uid = g.uid
			var item = g.id
			var quality = int(g.q)+1
			var locked = g.locked
			var favorite = g.favorite
			if g.count==1: m.s.gear.erase(g)
			else: g.count -= 1
			var uid = m.add_gear(item,quality,m.s.get("card_sockets",{}).has(old_uid) or m.s.get("gear_attunements",{}).has(old_uid) or RealmArtisan.has_traits(g))
			if m.s.get("gear_attunements",{}).has(old_uid):
				m.s.gear_attunements[uid]=m.s.gear_attunements[old_uid]
				if uid!=old_uid:m.s.gear_attunements.erase(old_uid)
			if m.s.get("card_sockets",{}).has(old_uid):
				var card = m.s.card_sockets[old_uid]
				m.s.card_sockets.erase(old_uid)
				m.s.card_sockets[uid] = card
			RealmArtisan.copy_traits(g,m.gear(uid))
			m.gear(uid).locked = m.gear(uid).locked or locked
			m.gear(uid).favorite = m.gear(uid).favorite or favorite
			var references = [m.s.equipped]+m.s.presets.values()
			for build in RealmLoadouts.state(m).values(): references.append(build.gear)
			for slots in references:
				for slot in slots:
					if slots[slot]==old_uid: slots[slot] = uid
		"end_depth":
			if int(m.s.kills.get("secret_2",0))<1: return "Defeat the Hollow Forgemaster to find the Depths."
			if not m.s.queue.is_empty(): return "Finish or clear your queue first."
			if id not in ["steady","perilous"]: return "Choose an expedition risk."
			if not s.depth.active:
				s.depth.active = true
				s.depth.floor = mini(1000,int(s.depth.get("checkpoint",0))+1)
				s.depth.stash = 0
			if id not in ["steady","perilous"]: return "Choose an expedition risk."
			s.depth.risk = id
			return "" if m.command({"type":"queue","id":"hunt_hollow_depth","target":1}) else m.error
		"end_bank":
			if not m.s.fight.is_empty(): return "Finish or retreat from the current room first."
			if m.s.queue.any(func(step): return step.id=="hunt_hollow_depth"): return "Clear the queued expedition before banking."
			m.gain("depth_shard",int(s.depth.stash))
			s.depth.stash = 0
			s.depth.active = false
		"end_contract":
			if id not in CONTRACTS: return "Unknown contract."
			var b = s.board
			var day = int(maxi(int(m.s.wall),0)/86400000)
			if b.selected.size()==3 and b.claimed.size()==3 and day>int(b.day): s.board = {"day":day,"selected":[],"claimed":[],"baseline":{}}; b = s.board
			if id in b.selected: return "This contract is already selected."
			if b.selected.size()>=3: return "Complete this board. A new board opens on a later day."
			if id in ["elite","depth"] and m.s.kills.get("secret_0",0)<1: return "Discover an optional guardian first."
			if id=="frontline":
				var known=proven_hunts(m)
				if known.is_empty():return "Win a hunt to receive a frontline commission."
				b.target=known[day%mini(3,known.size())]
			b.day = maxi(day,int(b.day))
			b.selected.append(id)
			b.baseline[id] = totals(m)[id]
		"end_claim":
			var b = s.board
			if id not in b.selected or id in b.claimed or totals(m)[id]-b.baseline[id]<CONTRACTS[id][1]: return "Complete the selected contract first."
			b.claimed.append(id)
			var reward=contract_reward(m,id)
			m.s.gold+=reward.gold;m.gain("scrap",reward.scrap)
			if reward.material!="":m.gain(reward.material,reward.amount)
		"end_week":
			var week = int(maxi(int(m.s.wall),0)/604800000)
			if s.weekly_enemy!="" and not s.weekly_claimed: return "Complete your current weekly challenge first."
			if week<=int(s.week): return "The next challenge opens next week."
			var options = weekly_pool().filter(func(key): return int(m.s.kills.get(key,0))>0)
			if options.is_empty(): return "Defeat an optional guardian first."
			s.week = week
			s.weekly_claimed = false
			s.weekly_enemy = options[week%options.size()]
			s.weekly_base = int(m.s.kills.get(s.weekly_enemy,0))
		"end_week_claim":
			if s.weekly_enemy=="" or s.weekly_claimed or int(m.s.kills.get(s.weekly_enemy,0))-int(s.weekly_base)<3: return "Win three hunts against your weekly target."
			s.weekly_claimed = true
			var reward=weekly_reward(m)
			m.s.gold+=reward.gold;m.gain("dread_token",reward.seals);m.gain("depth_shard",reward.shards)
	return ""

static func valid(value, data) -> bool:
	if not value is Dictionary: return false
	for key in defaults():
		if not value.has(key): return false
	if value.route not in ROUTES or not value.target is String: return false
	if value.target!="" and (not data.items.has(value.target) or not value.target.begins_with("relic_")): return false
	var d = value.depth
	if not d is Dictionary or not d.get("active") is bool or d.get("risk","") not in ["steady","perilous"]: return false
	for key in ["floor","best","stash"]:
		if not RealmSave.counter(d.get(key,-1)): return false
	if not RealmSave.counter(d.get("checkpoint",0)) or d.get("checkpoint",0)>d.best or int(d.get("checkpoint",0))%5!=0:return false
	if d.floor<1 or d.floor>1000 or d.best>1000: return false
	var b = value.board
	if not b is Dictionary or not b.get("selected") is Array or not b.get("claimed") is Array or not b.get("baseline") is Dictionary: return false
	if typeof(b.get("day")) not in [TYPE_INT,TYPE_FLOAT] or typeof(value.week) not in [TYPE_INT,TYPE_FLOAT]: return false
	if not RealmSave.counter(float(b.get("day",-2))+1) or b.selected.size()>3: return false
	var seen = []
	if b.has("target") and (not b.target is String or not data.enemies.has(b.target) or data.enemies[b.target].get("depth",false)):return false
	if "frontline" in b.selected and not b.has("target"):return false
	for id in b.selected:
		if id not in CONTRACTS or id in seen or not RealmSave.counter(b.baseline.get(id,-1)): return false
		seen.append(id)
	seen = []
	for id in b.claimed:
		if id not in b.selected or id in seen: return false
		seen.append(id)
	return RealmSave.counter(value.rooms) and RealmSave.counter(float(value.week)+1) and value.weekly_claimed is bool and (value.weekly_enemy=="" or value.weekly_enemy in weekly_pool()) and RealmSave.counter(value.weekly_base)
