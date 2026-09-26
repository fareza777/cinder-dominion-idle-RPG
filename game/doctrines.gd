class_name RealmDoctrines
extends RefCounted

const ALL = {
	"none":{"name":"Standard training","detail":"No additional trade-off.","outgoing":1.0,"incoming":1.0,"pierce":0.0},
	"precision":{"name":"Measured Strike","detail":"Every fourth attack ignores 50% armor. All attacks deal 10% less damage.","outgoing":0.9,"incoming":1.0,"pierce":0.5},
	"bastion":{"name":"Iron Resolve","detail":"Take 15% less damage. Deal 10% less damage.","outgoing":0.9,"incoming":0.85,"pierce":0.0},
	"blood":{"name":"Blood Oath","detail":"Deal 15% more damage. Take 15% more damage.","outgoing":1.15,"incoming":1.15,"pierce":0.0}}

static func active(m) -> Dictionary:
	return ALL.get(str(m.s.get("doctrine","none")),ALL.none)

static func command(m, id: String) -> String:
	if not ALL.has(id): return "Unknown combat training."
	if not m.s.fight.is_empty(): return "Retreat before changing combat training."
	if id!="none" and m.level("bladecraft")<25: return "Reach Bladecraft Lv.25 to choose advanced training."
	m.s.doctrine = id
	return ""
