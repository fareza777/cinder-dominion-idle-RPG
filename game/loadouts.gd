class_name RealmLoadouts
extends RefCounted

const NAMES = {"journey":"Wayfarer","guardian":"Gatewarden","hunter":"Oathbreaker"}

static func state(m) -> Dictionary:
	if not m.s.has("loadouts"): m.s.loadouts = {}
	return m.s.loadouts

static func snapshot(m) -> Dictionary:
	return {"gear":m.s.equipped.duplicate(true),"stance":m.progression().stance,"doctrine":m.s.get("doctrine","none"),"talents":RealmChronicle.state(m).talents.duplicate(true),"relic":RealmChronicle.state(m).relic,"rune":RealmRuneforge.state(m).equipped,"food":m.s.settings.food,"potion":m.s.settings.potion,"threshold":m.s.settings.threshold}

static func valid(build, data: Dictionary, items: Dictionary) -> bool:
	if not build is Dictionary or not build.get("gear") is Dictionary or not build.get("talents") is Dictionary: return false
	if build.get("stance","") not in RealmProgression.STANCES: return false
	if build.get("doctrine","none") not in RealmDoctrines.ALL: return false
	if build.get("relic",null) not in ["","fang","ward","heart"] or build.get("rune",null) not in ["","thorn","tide","bell"]: return false
	var total = 0
	for id in RealmChronicle.TALENTS:
		if not RealmChronicle.number(build.talents.get(id,-1),5): return false
		total += int(build.talents[id])
	if total>10: return false
	for slot in build.gear:
		if not items.has(build.gear[slot]) or data.items[items[build.gear[slot]].id].slot!=slot: return false
	for field in ["food","potion"]:
		var id = build.get(field,null)
		if field=="potion" and id=="": continue
		if not id is String or not data.items.has(id) or data.items[id].category!=field: return false
	var threshold = build.get("threshold",null)
	return typeof(threshold) in [TYPE_INT,TYPE_FLOAT] and is_finite(float(threshold)) and threshold>=.1 and threshold<=.9

static func command(m, cmd: Dictionary) -> String:
	var id = str(cmd.get("id",""))
	if id not in NAMES: return "Choose one of the three loadout slots."
	var saved = state(m)
	if str(cmd.type)=="loadout_save":
		saved[id] = snapshot(m)
		return ""
	if not m.s.fight.is_empty(): return "Retreat before changing your build."
	if not saved.has(id): return "Save a build in this slot first."
	var build = saved[id]
	var items = {}
	for g in m.s.gear: items[g.uid] = g
	if not valid(build,m.data,items): return "This build references unavailable equipment or settings. Save it again."
	if build.get("doctrine","none")!="none" and m.level("bladecraft")<25: return "Reach Bladecraft Lv.25 before applying this training."
	var talent_total = 0
	for rank in build.talents.values(): talent_total += int(rank)
	if talent_total>RealmChronicle.points_earned(m): return "Earn more talent points before applying this build."
	if build.relic!="" and RealmChronicle.state(m).relics[build.relic]<1: return "Awaken this build's relic first."
	if build.rune!="" and RealmRuneforge.state(m).ranks[build.rune]<1: return "Inscribe this build's rune first."
	m.s.equipped = build.gear.duplicate(true)
	m.progression().stance = build.stance
	m.s.doctrine = build.get("doctrine","none")
	RealmChronicle.state(m).talents = build.talents.duplicate(true)
	RealmChronicle.state(m).relic = build.relic
	RealmRuneforge.state(m).equipped = build.rune
	for field in ["food","potion","threshold"]: m.s.settings[field] = build[field]
	m.s.settings.potion_policy = "auto" if build.potion!="" else "off"
	return ""
