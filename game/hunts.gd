class_name RealmHunts
extends RefCounted

static func state(m) -> Dictionary:
	if not m.s.has("hunts"): m.s.hunts = {"active":{},"history":[]}
	return m.s.hunts

static func begin(m, enemy: String):
	var s = state(m)
	if not s.active.is_empty(): return
	s.active = {"enemy":enemy,"started":int(m.s.time),"ended":int(m.s.time),"result":"Underway","wins":0,"gold":0,"xp":0,"fragments":0,"meals":0,"potions":0,"loot":{},"equipment":{},"consumed":{},"ending_hp":int(m.s.hp)}

static func equipment(m, id: String, quality: int):
	var active = state(m).active
	if active.is_empty(): return
	if not active.has("equipment"): active.equipment = {}
	var key = id+"|"+str(quality)
	active.equipment[key] = int(active.equipment.get(key,0))+1

static func supplies(m, field: String, item: String = ""):
	var s = state(m)
	if not s.active.is_empty():
		s.active[field] += 1
		# Legacy in-progress reports keep their untracked history honest.
		if s.active.has("consumed") and item!="":
			s.active.consumed[item] = int(s.active.consumed.get(item,0))+1

static func victory(m, enemy: Dictionary, before_gains: Dictionary, before_gold: int, fragments: int):
	var s = state(m)
	if s.active.is_empty(): return
	s.active.wins += 1
	s.active.gold += int(m.s.gold)-before_gold
	var xp = int(enemy.xp)
	if RealmEndgame.route(m)=="safe": xp = int(xp*.8)
	elif RealmEndgame.route(m)=="mastery": xp = int(xp*1.2)
	elif RealmEndgame.route(m)=="elite": xp = int(xp*1.25)
	s.active.xp += xp
	s.active.fragments += fragments
	for id in m.s.gains:
		var amount = int(m.s.gains[id])-int(before_gains.get(id,0))
		if amount>0: s.active.loot[id] = int(s.active.loot.get(id,0))+amount

static func finish(m, result: String):
	var s = state(m)
	if s.active.is_empty(): return
	s.active.ended = int(m.s.time)
	s.active.ending_hp = int(m.s.hp)
	s.active.result = result
	s.history.push_front(s.active.duplicate(true))
	if s.history.size()>12: s.history.resize(12)
	s.active = {}

static func valid(h, data: Dictionary) -> bool:
	if not h is Dictionary or not h.get("active") is Dictionary or not h.get("history") is Array or h.history.size()>12: return false
	var entries = h.history.duplicate()
	if not h.active.is_empty(): entries.append(h.active)
	for entry in entries:
		if not entry is Dictionary or not data.enemies.has(entry.get("enemy","")) or not entry.get("loot") is Dictionary: return false
		if entry.get("result","") not in ["Underway","Completed","Recalled","Defeated"]: return false
		for field in ["started","ended","wins","gold","xp","fragments","meals","potions","ending_hp"]:
			if not RealmChronicle.number(entry.get(field,-1),9000000000000000): return false
		if entry.ending_hp>100 or entry.ended<entry.started: return false
		for id in entry.loot:
			if not data.items.has(id) or not RealmChronicle.number(entry.loot[id]): return false
		if entry.has("consumed"):
			if not entry.consumed is Dictionary: return false
			var meals = 0
			var potions = 0
			for id in entry.consumed:
				if not data.items.has(id) or not RealmChronicle.number(entry.consumed[id]): return false
				if data.items[id].category=="food": meals += int(entry.consumed[id])
				elif data.items[id].category=="potion": potions += int(entry.consumed[id])
				else: return false
			if meals!=int(entry.meals) or potions!=int(entry.potions): return false
		if entry.has("equipment"):
			if not entry.equipment is Dictionary: return false
			for key in entry.equipment:
				if not key is String: return false
				var parts = key.split("|")
				if parts.size()!=2 or not data.items.has(parts[0]) or data.items[parts[0]].category!="equipment": return false
				if not parts[1].is_valid_int() or int(parts[1])<0 or int(parts[1])>7 or not RealmChronicle.number(entry.equipment[key]): return false
	return true
