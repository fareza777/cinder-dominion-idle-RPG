class_name RealmLegacyFinds
extends RefCounted

const CHANCE = .0001
const GEAR = ["heirloom_blade","heirloom_aegis","heirloom_pendant","heirloom_helm","heirloom_cuirass","heirloom_gauntlets","heirloom_boots","heirloom_belt","heirloom_ember_ring","heirloom_glass_ring"]

static func drop(m, enemy: Dictionary) -> String:
	var id = str(enemy.get("rare_material",""))
	if id=="": return ""
	var random = RandomNumberGenerator.new()
	random.state = int(m.s.get("legacy_rng","194729"))
	var found = random.randf()<float(enemy.get("rare_chance",CHANCE))
	m.s.legacy_rng = str(random.state)
	if not found: return ""
	m.gain(id,1)
	m.note("Rare material found: "+m.name_of(id)+". Used in a late-game masterwork.")
	return id

static func description(m, enemy: Dictionary) -> String:
	var id = str(enemy.get("rare_material",""))
	return "" if id=="" else m.name_of(id)+" · Masterwork material"
