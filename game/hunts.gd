class_name RealmHunts
extends RefCounted

static func state(m) -> Dictionary:
	if not m.s.has("hunts"): m.s.hunts = {"active":{},"history":[]}
	return m.s.hunts

static func begin(m, enemy: String):
	var s = state(m)
	if not s.active.is_empty(): return
	s.active = {"enemy":enemy,"started":int(m.s.time),"ended":int(m.s.time),"result":"Underway","wins":0,"gold":0,"xp":0,"fragments":0,"meals":0,"potions":0,"loot":{},"equipment":{},"ending_hp":int(m.s.hp)}

static func equipment(m, id: String, quality: int):
	var active = state(m).active
	if active.is_empty(): return
	if not active.has("equipment"): active.equipment = {}
	var key = id+"|"+str(quality)
	active.equipment[key] = int(active.equipment.get(key,0))+1

static func supplies(m, field: String):
	var s = state(m)
	if not s.active.is_empty(): s.active[field] += 1

static func victory(m, enemy: Dictionary, before_gains: Dictionary, before_gold: int):
	var s = state(m)
	if s.active.is_empty(): return
	s.active.wins += 1
	s.active.gold += int(m.s.gold)-before_gold
	s.active.xp += int(enemy.xp)
	s.active.fragments += int(enemy.get("fragments",1))
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
		if entry.has("equipment"):
			if not entry.equipment is Dictionary: return false
			for key in entry.equipment:
				if not key is String: return false
				var parts = key.split("|")
				if parts.size()!=2 or not data.items.has(parts[0]) or data.items[parts[0]].category!="equipment": return false
				if not parts[1].is_valid_int() or int(parts[1])<0 or int(parts[1])>7 or not RealmChronicle.number(entry.equipment[key]): return false
	return true
