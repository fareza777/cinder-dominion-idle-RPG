class_name RealmRuneforge
extends RefCounted

const RUNES = {
	"thorn":{"name":"Thornscript","region":"wilds","relic":"fang","color":"b7bf91","lore":"A living branch, written in stone. Its edge remembers the gaps in every suit of armor."},
	"tide":{"name":"Stillwater","region":"marsh","relic":"heart","color":"83bcb8","lore":"Silence held beneath a silver ripple. Even the drowned must pause to draw breath."},
	"bell":{"name":"Dirge","region":"crown","relic":"ward","color":"d295aa","lore":"The last note of a broken bell. It lends your blade its fury, and leaves you open in return."},"rime":{"name": "Rimewake", "region": "wilds", "relic": "fang", "color": "a7c8d0", "lore": "An inscription recovered along the Far Marches.", "proc": "chill", "gate": "march_0_4"},"cinder":{"name": "Cinderseal", "region": "marsh", "relic": "heart", "color": "bdad83", "lore": "An inscription recovered along the Far Marches.", "proc": "burn", "gate": "march_1_4"},"venom":{"name": "Briarscript", "region": "crown", "relic": "ward", "color": "a3bb96", "lore": "An inscription recovered along the Far Marches.", "proc": "poison", "gate": "march_2_4"},"gore":{"name": "Red Thread", "region": "wilds", "relic": "fang", "color": "a7c8d0", "lore": "An inscription recovered along the Far Marches.", "proc": "bleed", "gate": "march_3_4"},"shelter":{"name": "Wardstone", "region": "marsh", "relic": "heart", "color": "bdad83", "lore": "An inscription recovered along the Far Marches.", "proc": "barrier", "gate": "march_4_4"},"renewal":{"name": "Hearthmark", "region": "crown", "relic": "ward", "color": "a3bb96", "lore": "An inscription recovered along the Far Marches.", "proc": "regeneration", "gate": "march_5_4"},"fracture":{"name": "Faultline", "region": "wilds", "relic": "fang", "color": "a7c8d0", "lore": "An inscription recovered along the Far Marches.", "proc": "armor_break", "gate": "march_0_4"},"hush":{"name": "Quietus", "region": "marsh", "relic": "heart", "color": "bdad83", "lore": "An inscription recovered along the Far Marches.", "proc": "weaken", "gate": "march_1_4"},"storm":{"name": "Stormglass", "region": "crown", "relic": "ward", "color": "a3bb96", "lore": "An inscription recovered along the Far Marches.", "proc": "shock", "gate": "march_2_4"}}
const MILESTONES = [5,20,50]
const TITLES = ["Trailbreaker","Guardian Hunter","Keeper of the March"]

static func state(m) -> Dictionary:
	if not m.s.has("runeforge"): m.s.runeforge = {"ranks":{"thorn":0,"tide":0,"bell":0},"equipped":"","claimed":[]}
	for id in RUNES:
		if not m.s.runeforge.ranks.has(id):m.s.runeforge.ranks[id]=0
	return m.s.runeforge

static func victories(m, region: String) -> int:
	var total = 0
	for id in m.data.enemies:
		if m.data.enemies[id].get("region","")==region:
			total += int(m.s.kills.get(id,0))
	return total

static func active_rank(m, id: String) -> int:
	var s = state(m)
	return int(s.ranks[id]) if s.equipped==id else 0

static func effect(id: String, rank: int) -> String:
	var r = clampi(rank,1,3)
	if RUNES[id].has("proc"):return "Every fourth hit applies %s at potency %d. Only your equipped rune is active." % [RUNES[id].proc.replace("_"," ").capitalize(),r*2]
	match id:
		"thorn": return "Every fourth attack ignores %d%% of enemy armor. Applies to your style skill if it hits." % (r*25)
		"tide": return "Reduces enemy healing by %d%%. Especially useful against the Drowned Oracle; it does not increase your own healing." % (r*25)
	return "Every fourth attack deals %d%% more damage after your style bonus. You take 10%% more damage on every enemy hit." % [20,35,50][r-1]

static func cost(rank: int, id: String = "thorn") -> Dictionary:
	var r = clampi(rank,0,2)
	if RUNES[id].has("proc"):return {"fragments":[300,900,1800][r],"scrap":[50,100,200][r],"gold":[250000,1000000,3000000][r]}
	return {"fragments":[20,60,140][r],"scrap":[3,8,16][r],"gold":[50,150,350][r]}

static func forge_reason(m, id: String) -> String:
	if not RUNES.has(id): return "Unknown rune."
	if not m.s.beacon: return "Restore the beacon to open the Runeforge."
	if not m.s.fight.is_empty(): return "Retreat before changing your rune."
	var rank = int(state(m).ranks[id])
	if rank>=3: return "This rune is fully inscribed."
	if victories(m,RUNES[id].region)<1: return "Defeat a guardian in "+RealmChronicle.REGIONS[RUNES[id].region].name+" to discover this inscription."
	if RUNES[id].has("gate") and m.s.kills.get(RUNES[id].gate,0)<1:return "Discover this inscription by defeating "+m.local_name(m.data.enemies[RUNES[id].gate])+"."
	var c = cost(rank,id)
	if RealmChronicle.state(m).fragments[RUNES[id].relic]<c.fragments or m.count("scrap")<c.scrap or m.s.gold<c.gold: return "Gather the missing fragments, scraps and coins shown below."
	return ""

static func reward(index: int) -> Dictionary:
	return {"fragments":[10,25,60][index],"scrap":[2,5,10][index],"gold":[40,120,300][index]}

static func ready(m) -> int:
	var total = 0
	if not m.s.beacon: return 0
	for region in RealmChronicle.REGIONS:
		for target in MILESTONES:
			if victories(m,region)>=target and region+"_"+str(target) not in state(m).claimed: total += 1
	return total

static func command(m, cmd: Dictionary) -> String:
	if not m.s.beacon: return "Restore the beacon to unlock the Runeforge and expedition records."
	var s = state(m)
	var id = str(cmd.get("id",""))
	match str(cmd.type):
		"rune_forge":
			var why = forge_reason(m,id)
			if why!="": return why
			var c = cost(int(s.ranks[id]),id)
			RealmChronicle.state(m).fragments[RUNES[id].relic] -= c.fragments
			m.s.gold -= c.gold
			m.spend("scrap",c.scrap)
			s.ranks[id] += 1
			m.note("%s inscribed at rank %d. Equip it at the Runeforge." % [RUNES[id].name,int(s.ranks[id])])
		"rune_equip":
			if not m.s.fight.is_empty(): return "Retreat before changing your rune."
			if id!="" and (not RUNES.has(id) or s.ranks[id]<1): return "Inscribe this rune before equipping it."
			s.equipped = id
		"research_claim":
			if id not in RealmChronicle.REGIONS: return "Unknown region."
			var index = MILESTONES.find(int(cmd.get("target",0)))
			if index<0: return "Unknown field record."
			var key = id+"_"+str(MILESTONES[index])
			if key in s.claimed: return "This field reward has already been claimed."
			if victories(m,id)<MILESTONES[index]: return "Win more battles in this region to complete the record."
			var payout = reward(index)
			s.claimed.append(key)
			m.s.gold += payout.gold
			m.gain("scrap",payout.scrap)
			RealmChronicle.state(m).fragments[RealmChronicle.REGIONS[id].relic] += payout.fragments
			m.note("%s · %s recorded. Field supplies received." % [RealmChronicle.REGIONS[id].name,TITLES[index]])
		_: return "Unknown Runeforge action."
	return ""

static func valid(s) -> bool:
	if not s is Dictionary or not s.get("ranks") is Dictionary or not s.get("claimed") is Array: return false
	for id in RUNES:
		if not RealmChronicle.number(s.ranks.get(id,0),3): return false
	if s.get("equipped",null)!="" and s.get("equipped",null) not in RUNES: return false
	if s.equipped!="" and s.ranks.get(s.equipped,0)<1: return false
	var allowed = []
	for region in RealmChronicle.REGIONS:
		for target in MILESTONES: allowed.append(region+"_"+str(target))
	var seen = []
	for key in s.claimed:
		if key not in allowed or key in seen: return false
		seen.append(key)
	return true
