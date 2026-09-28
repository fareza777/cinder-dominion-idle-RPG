class_name RealmCards
extends RefCounted

static var catalog: Dictionary = {}
static func definitions() -> Dictionary:
	if catalog.is_empty(): catalog = JSON.parse_string(FileAccess.get_file_as_string("res://data/cards.json"))
	return catalog

static func sockets(m) -> Dictionary:
	if not m.s.has("card_sockets"): m.s.card_sockets = {}
	return m.s.card_sockets

static func active(m) -> Array:
	var result = []
	for uid in m.s.equipped.values():
		var id = m.s.get("card_sockets",{}).get(uid,"")
		if id!="" and id not in result and fits_card(m,str(uid),id): result.append(id)
	return result

static func bonus(m, key: String) -> float:
	var result = 0.0
	for id in active(m): result += float(definitions()[id].get(key,0))
	return minf(.30,result)

static func conditional_damage(m) -> float:
	var result = 0.0
	for effect in ["burn","bleed","poison","chill"]:
		if RealmAfflictions.has(m,"enemy",effect): result += bonus(m,"vs_"+effect)
	return minf(.15,result)

static func resistance(m, effect: String) -> float:
	var value = 0.0
	for id in active(m):
		if definitions()[id].get("resist","")==effect: value += .25
	return minf(.75,value)

static func drop(m, enemy: String) -> String:
	var id = "card_"+enemy
	var random = RandomNumberGenerator.new()
	random.state = int(m.s.get("card_rng","8675309"))
	var found = random.randf()<float(definitions()[id].chance)
	m.s.card_rng = str(random.state)
	if not found: return ""
	m.gain(id,1)
	m.note("Rare discovery: "+m.name_of(id)+". Open Monster Cards to inspect it.")
	return id

static func fits(m, uid: String) -> bool:
	var g = m.gear(uid)
	return not g.is_empty() and m.data.items[g.id].slot not in ["axe","pick","rod"]

static func allowed(id: String, slot: String) -> bool:
	return definitions().has(id) and slot in definitions()[id].get("slots",[])

static func fits_card(m, uid: String, id: String) -> bool:
	var g = m.gear(uid)
	return not g.is_empty() and allowed(id,str(m.data.items[g.id].slot))

static func slot_text(id: String) -> String:
	var names = []
	for slot in definitions()[id].slots:
		names.append("Ring" if slot=="ring" else RealmEquipmentSlots.NAMES[slot])
	return "Fits: "+" / ".join(names)

# Called only after structural validation. Returning an old card is not new loot.
static func migrate(s: Dictionary, data: Dictionary):
	if int(s.get("card_slot_revision",0))>=1: return
	var attached=s.get("card_sockets",{})
	var returned=0
	for uid in attached.keys():
		for g in s.gear:
			if g.uid==uid and not allowed(attached[uid],str(data.items[g.id].slot)):
				var id=str(attached[uid])
				s.bag[id]=int(s.bag.get(id,0))+1
				attached.erase(uid)
				returned+=1
	if returned>0:
		s.log.push_front("Card slots updated: %d incompatible cards returned safely to your Bag." % returned)
		if s.log.size()>20:s.log.resize(20)
	s.card_slot_revision=1

static func command(m, cmd: Dictionary) -> String:
	if not m.s.fight.is_empty(): return "Finish or leave combat before changing cards."
	var uid = str(cmd.get("uid",""))
	if not fits(m,uid): return "Choose combat equipment in your bag. Tools cannot hold cards."
	var attached = m.s.get("card_sockets",{})
	if cmd.type=="card_remove":
		if not attached.has(uid): return "This item has no card."
		if m.count("card_extractor")<1: return "Craft a Card Extractor at Smithing Lv.20. The card is preserved."
		m.spend("card_extractor",1)
		m.gain(attached[uid],1)
		attached.erase(uid)
		return ""
	var id = str(cmd.get("id",""))
	if not definitions().has(id) or m.count(id)<1: return "You do not own this card."
	if not fits_card(m,uid,id): return slot_text(id)+". Choose compatible equipment."
	if attached.has(uid): return "Remove the current card first."
	var g = m.gear(uid)
	if g.count>1:
		if m.s.gear.size()>=1000: return "Make room in your equipment bag first."
		var remainder = g.duplicate(true)
		remainder.uid = "eq_%d" % int(m.s.next_uid)
		m.s.next_uid += 1
		remainder.count -= 1
		g.count = 1
		m.s.gear.append(remainder)
	m.spend(id,1)
	attached[uid] = id
	m.s.card_sockets=attached
	return ""

static func sell_price(id: String) -> int:
	return {"Rare":20000,"Epic":50000,"Legendary":100000,"Mythic":250000}[definitions()[id].rarity]

static func description(id: String) -> String: return str(definitions()[id].detail)

static func valid(s: Dictionary, items: Dictionary) -> bool:
	if s.has("card_slot_revision") and s.card_slot_revision!=1: return false
	if s.has("card_material_credit") and (not RealmSave.counter(s.card_material_credit) or s.card_material_credit>=10000): return false
	if s.has("card_rng") and (not s.card_rng is String or not s.card_rng.is_valid_int()): return false
	if not s.has("card_sockets"): return true
	if not s.card_sockets is Dictionary: return false
	for uid in s.card_sockets:
		if not items.has(uid) or not definitions().has(s.card_sockets[uid]): return false
		if items[uid].count!=1: return false
	return true
