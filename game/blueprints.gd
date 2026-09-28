class_name RealmBlueprints
extends RefCounted

const DROP_CHANCE = .0001
const STOCK_CHANCE = .01

static func item(id: String) -> String:
	return "blueprint_"+id

static func learned(m, id: String) -> bool:
	if id not in RealmLegacyFinds.GEAR: return true
	# Retain recipes the player actually crafted/owned before this update.
	return int(m.s.gains.get(item(id),0))>0 or m.count(item(id))>0 or m.count(id)>0 or int(m.s.gains.get(id,0))>0 or int(m.s.mastery.get("craft_"+id,0))>0

static func reason(m, activity: Dictionary) -> String:
	if activity.output in RealmLegacyFinds.GEAR:
		return "" if learned(m,activity.output) else "Discover this masterwork's blueprint first."
	if activity.has("blueprint") and int(m.s.kills.get(activity.blueprint,0))<1:
		return "Defeat its optional guardian to learn this blueprint."
	return ""

static func drop(m, enemy_id: String) -> String:
	var candidates = []
	for id in RealmLegacyFinds.GEAR:
		if m.data.activities["craft_"+id].blueprint==enemy_id and not learned(m,id): candidates.append(id)
	if candidates.is_empty(): return ""
	var random = RandomNumberGenerator.new()
	random.state = int(m.s.get("blueprint_rng",str(m.rng.state)))
	var roll = random.randf()
	m.s.blueprint_rng=str(random.state)
	if roll>=DROP_CHANCE: return ""
	var found=item(candidates[0])
	m.gain(found,1)
	m.note("Blueprint discovered: "+m.name_of(candidates[0])+". A new masterwork can be forged.")
	return found

static func candidates(m, source: String) -> Array:
	return RealmLegacyFinds.GEAR.filter(func(id): return m.data.activities["craft_"+id].blueprint==source and not learned(m,id))

static func offers() -> Array:
	var out = []
	for i in range(RealmLegacyFinds.GEAR.size()):
		out.append({"id":item(RealmLegacyFinds.GEAR[i]),"qty":1,"price":(20+i*10)*RealmEconomy.PLATINUM,"quality":1})
	return out
