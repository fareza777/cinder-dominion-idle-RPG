class_name RealmEquipmentSlots
extends RefCounted

const NAMES = {"weapon":"Weapon","shield":"Shield","head":"Head","body":"Chest","hands":"Hands","feet":"Feet","necklace":"Necklace","belt":"Belt","ring_left":"Left ring","ring_right":"Right ring","axe":"Axe","pick":"Pickaxe","rod":"Fishing rod"}

static func accepts(slot: String, family: String) -> bool:
	return slot in NAMES and (family=="ring" if slot in ["ring_left","ring_right"] else family==slot)

static func target(m, uid: String) -> String:
	var item = m.gear(uid)
	if item.is_empty(): return ""
	var family = str(m.data.items[item.id].slot)
	if family!="ring": return family
	for slot in ["ring_left","ring_right"]:
		if m.s.equipped.get(slot,"")==uid: return slot
	for slot in ["ring_left","ring_right"]:
		if not m.s.equipped.has(slot): return slot
	var left = m.gear(str(m.s.equipped.ring_left))
	var right = m.gear(str(m.s.equipped.ring_right))
	return "ring_right" if m.gear_score(right)<m.gear_score(left) else "ring_left"

static func place(slots: Dictionary, uid: String, slot: String):
	for key in slots.keys():
		if slots[key]==uid: slots.erase(key)
	slots[slot] = uid

static func valid(slots: Dictionary, items: Dictionary, data: Dictionary) -> bool:
	var seen = []
	for slot in slots:
		var uid = slots[slot]
		if not uid is String or uid in seen or not items.has(uid): return false
		if not accepts(str(slot),str(data.items[items[uid].id].slot)): return false
		seen.append(uid)
	return true

static func equip_best(m):
	var candidates = m.s.gear.duplicate()
	candidates.sort_custom(func(a,b): return m.gear_score(a)>m.gear_score(b))
	var result = {}
	for g in candidates:
		var family = str(m.data.items[g.id].slot)
		var positions = ["ring_left","ring_right"] if family=="ring" else [family]
		for slot in positions:
			if not result.has(slot):
				result[slot] = g.uid
				break
	m.s.equipped = result
