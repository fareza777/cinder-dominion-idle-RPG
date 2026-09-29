class_name RealmWorkshop
extends RefCounted

static func eligible(m, g: Dictionary) -> bool:
	return not g.is_empty() and str(g.id).get_slice("_",0) in ["copper","iron","steel","moonsteel","dusksteel","dawnsteel","rime","briar","cinder","hush","gloam","star"] and m.data.items[g.id].slot in ["weapon","shield","head","body","hands","feet","necklace","belt","ring"]

static func cost(g: Dictionary) -> Dictionary:
	var q = clampi(int(g.q),1,4)-1
	var metal = str(g.id).get_slice("_",0)
	var base = {"steel":25,"moonsteel":45,"dusksteel":65,"dawnsteel":85,"rime":65,"briar":72,"cinder":79,"hush":86,"gloam":93,"star":100}.get(metal,0)
	var multiplier = {"copper":1,"iron":3,"steel":30,"moonsteel":150,"dusksteel":500,"dawnsteel":2000,"rime":1200,"briar":1800,"cinder":2500,"hush":3500,"gloam":5000,"star":7000}.get(metal,1)
	return {"gold":maxi(5000000 if q==3 else 0,[40,120,360,900][q]*multiplier),"scrap":[2,6,15,35][q]*(1+int(base/20)),"ingots":[2,5,12,25][q],"level":mini(100,maxi(90 if q==3 else [3,6,12,20][q],base+[0,3,7,15][q])),"metal":metal+"_ingot","vault_material":20 if q==3 else 0}

static func preview(m, uid: String, enemy: String) -> Dictionary:
	var g = m.gear(uid)
	if not eligible(m,g) or int(g.q)>=5 or not m.data.enemies.has(enemy): return {}
	var baseline = RealmModel.new()
	baseline.s = m.s.duplicate(true)
	var proposed = RealmModel.new()
	proposed.s = m.s.duplicate(true)
	proposed.gear(uid).q = int(g.q)+1
	var slot = RealmEquipmentSlots.target(m,uid)
	RealmEquipmentSlots.place(proposed.s.equipped,uid,slot)
	return {"equipped":m.s.equipped.get(slot,"")==uid,"before":baseline.stats(),"after":proposed.stats(),
		"hunt_before":RealmCombat.forecast(baseline,enemy),"hunt_after":RealmCombat.forecast(proposed,enemy)}

static func reason(m, uid: String) -> String:
	var g = m.gear(uid)
	if not eligible(m,g): return "Only forged metal combat equipment can be refined."
	if not m.s.tutorial: return "Complete First Supplies to open the workshop."
	if not m.s.fight.is_empty(): return "Retreat before refining your equipment."
	if g.q==4 and RealmArtisan.tier(m,"hammer")<4:return "Select the Blackstar Hammer before refining Legendary equipment."
	if g.q>=5: return "This piece has reached Legendary quality."
	var c = cost(g)
	if m.count("journey_material_11")<c.vault_material:return "Secure 20 Starless Reliquary materials before refining Legendary equipment."
	if m.level("smithing")<c.level: return "Reach Smithing level %d to refine this quality." % int(c.level)
	if m.s.gold<c.gold or m.count("scrap")<c.scrap or m.count(c.metal)<c.ingots: return "Gather the coins, ingots and scraps shown in the recipe."
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
	if c.vault_material>0:m.spend("journey_material_11",c.vault_material)
	if g.count==1: m.s.gear.erase(g)
	else: g.count -= 1
	var new_uid = m.add_gear(item_id,quality,m.s.get("card_sockets",{}).has(uid) or m.s.get("gear_attunements",{}).has(uid) or RealmArtisan.has_traits(g))
	if m.s.get("gear_attunements",{}).has(uid):
		m.s.gear_attunements[new_uid]=m.s.gear_attunements[uid]
		if new_uid!=uid:m.s.gear_attunements.erase(uid)
	if m.s.get("card_sockets",{}).has(uid):
		var card = m.s.card_sockets[uid]
		m.s.card_sockets.erase(uid)
		m.s.card_sockets[new_uid] = card
	var upgraded = m.gear(new_uid)
	RealmArtisan.copy_traits(g,upgraded)
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
