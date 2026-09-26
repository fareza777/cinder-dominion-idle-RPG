class_name RealmWorkshop
extends RefCounted

static func eligible(m, g: Dictionary) -> bool:
	return not g.is_empty() and (str(g.id).begins_with("copper_") or str(g.id).begins_with("iron_")) and m.data.items[g.id].slot in ["weapon","shield","head","body","hands","feet"]

static func cost(g: Dictionary) -> Dictionary:
	var q = clampi(int(g.q),1,4)-1
	return {"gold":[40,120,360,900][q],"scrap":[2,6,15,35][q],"ingots":[2,5,12,25][q],"level":[3,6,12,20][q],"metal":"iron_ingot" if str(g.id).begins_with("iron_") else "copper_ingot"}

static func reason(m, uid: String) -> String:
	var g = m.gear(uid)
	if not eligible(m,g): return "Only copper and iron combat equipment can be refined."
	if not m.s.tutorial: return "Complete First Supplies to open the workshop."
	if not m.s.fight.is_empty(): return "Retreat before refining your equipment."
	if g.q>=5: return "This piece has reached Legendary quality."
	var c = cost(g)
	if m.level("smithing")<c.level: return "Reach Smithing level %d to refine this quality." % int(c.level)
	if m.s.gold<c.gold or m.count("scrap")<c.scrap or m.count(c.metal)<c.ingots: return "Gather the gold, ingots and scraps shown in the recipe."
	var merge = false
	for other in m.s.gear:
		if other.id==g.id and int(other.q)==int(g.q)+1: merge = true
	if g.count>1 and m.s.gear.size()>=1000 and not merge: return "Make room in your equipment bag before splitting this stack."
	return ""

static func command(m, uid: String) -> String:
	var why = reason(m,uid)
	if why!="": return why
	var g = m.gear(uid)
	var c = cost(g)
	var item_id = str(g.id)
	var quality = int(g.q)+1
	var locked = bool(g.locked)
	var favorite = bool(g.favorite)
	m.s.gold -= int(c.gold)
	m.spend("scrap",int(c.scrap))
	m.spend(c.metal,int(c.ingots))
	if g.count==1: m.s.gear.erase(g)
	else: g.count -= 1
	var new_uid = m.add_gear(item_id,quality)
	var upgraded = m.gear(new_uid)
	upgraded.locked = upgraded.locked or locked
	upgraded.favorite = upgraded.favorite or favorite
	var references = [m.s.equipped]+m.s.presets.values()
	for build in RealmLoadouts.state(m).values(): references.append(build.gear)
	for slots in references:
		for slot in slots:
			if slots[slot]==uid: slots[slot] = new_uid
	m.last_forged = new_uid
	m.note("Refined %s to %s. One piece improved; saved builds follow the upgraded piece." % [m.name_of(item_id),m.data.rarities[quality]])
	return ""
