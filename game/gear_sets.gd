class_name RealmGearSets
extends RefCounted

const ALL = {
	"steel":{"name":"Ironwatch","effect":"Take 15% less damage from every third enemy attack."},
	"moonsteel":{"name":"Stillwater","effect":"Reduce enemy healing by 20%. Multiplies with your rune."},
	"dusksteel":{"name":"Nightfall","effect":"Your fourth attack deals 15% more damage."},
	"dawnsteel":{"name":"Daybreak","effect":"Cooked food restores 8 additional HP."},"rime":{"name": "Winterwatch", "effect": "Fourth hits apply Chill; +6% damage against chilled enemies."},"briar":{"name": "Thornward", "effect": "Fourth hits apply Poison; +6% damage against poisoned enemies."},"cinder":{"name": "Kindled Iron", "effect": "Fourth hits apply Burn; +6% damage against burning enemies."},"hush":{"name": "Tidekeeper", "effect": "Meals restore 8% more HP; fourth hits grant Regeneration."},"gloam":{"name": "Nightstalker", "effect": "Fourth hits apply Bleed; +6% damage against bleeding enemies."},"star":{"name": "Last Light", "effect": "Deal 12% more damage below 30% enemy HP; take 5% more direct damage."}}
const SLOTS = ["shield","head","body","hands","feet"]

static func metal(id: String) -> String:
	var prefix = id.get_slice("_",0)
	return prefix if ALL.has(prefix) else ""

static func counts(m) -> Dictionary:
	var out = {}
	for id in ALL:out[id]=0
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
