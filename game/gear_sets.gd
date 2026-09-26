class_name RealmGearSets
extends RefCounted

const ALL = {
	"steel":{"name":"Ironwatch","effect":"Take 15% less damage from every third enemy attack."},
	"moonsteel":{"name":"Stillwater","effect":"Reduce enemy healing by 20%. Multiplies with your rune."},
	"dusksteel":{"name":"Nightfall","effect":"Your fourth attack deals 15% more damage."},
	"dawnsteel":{"name":"Daybreak","effect":"Cooked food restores 8 additional HP."}}
const SLOTS = ["shield","head","body","hands","feet"]

static func metal(id: String) -> String:
	var prefix = id.get_slice("_",0)
	return prefix if ALL.has(prefix) else ""

static func counts(m) -> Dictionary:
	var out = {"steel":0,"moonsteel":0,"dusksteel":0,"dawnsteel":0}
	for slot in SLOTS:
		var item = m.gear(str(m.s.equipped.get(slot,"")))
		if item.is_empty(): continue
		var id = metal(item.id)
		if id!="": out[id] += 1
	return out

static func active(m, id: String) -> bool:
	return counts(m).get(id,0)>=2

static func summary(m) -> String:
	var parts: Array[String] = []
	var equipped = counts(m)
	for id in ALL:
		if equipped[id]>=2: parts.append(ALL[id].name)
	return " + ".join(parts) if not parts.is_empty() else "No armor set active"
