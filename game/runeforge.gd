class_name RealmRuneforge
extends RefCounted

const RUNES = {
	"thorn":{"name":"Thornscript","region":"wilds","relic":"fang","color":"b7bf91","lore":"A living branch, written in stone. Its edge remembers the gaps in every suit of armor."},
	"tide":{"name":"Stillwater","region":"marsh","relic":"heart","color":"83bcb8","lore":"Silence held beneath a silver ripple. Even the drowned must pause to draw breath."},
	"bell":{"name":"Dirge","region":"crown","relic":"ward","color":"d295aa","lore":"The last note of a broken bell. It lends your blade its fury, and leaves you open in return."}}
const MILESTONES = [5,20,50]
const TITLES = ["Trailbreaker","Guardian Hunter","Keeper of the March"]

static func state(m) -> Dictionary:
	if not m.s.has("runeforge"): m.s.runeforge = {"ranks":{"thorn":0,"tide":0,"bell":0},"equipped":"","claimed":[]}
	return m.s.runeforge

static func victories(m, region: String) -> int:
	var total = 0
	for tier in range(1,6): total += int(m.s.kills.get(region+"_"+str(tier),0))
	return total

static func active_rank(m, id: String) -> int:
	var s = state(m)
	return int(s.ranks[id]) if s.equipped==id else 0

static func effect(id: String, rank: int) -> String:
	var r = clampi(rank,1,3)
	match id:
		"thorn": return "Every fourth attack ignores %d%% of enemy armor. Applies to your style skill if it hits." % (r*25)
		"tide": return "Reduces enemy healing by %d%%. Especially useful against the Drowned Oracle; it does not increase your own healing." % (r*25)
	return "Every fourth attack deals %d%% more damage after your style bonus. You take 10%% more damage on every enemy hit." % [20,35,50][r-1]

static func cost(rank: int) -> Dictionary:
	var r = clampi(rank,0,2)
	return {"fragments":[20,60,140][r],"scrap":[3,8,16][r],"gold":[50,150,350][r]}

static func forge_reason(m, id: String) -> String:
	if not RUNES.has(id): return "Unknown rune."
	if not m.s.beacon: return "Restore the beacon to open the Runeforge."
	if not m.s.fight.is_empty(): return "Retreat before changing your rune."
	var rank = int(state(m).ranks[id])
	if rank>=3: return "This rune is fully inscribed."
	if victories(m,RUNES[id].region)<1: return "Defeat a guardian in "+RealmChronicle.REGIONS[RUNES[id].region].name+" to discover this inscription."
	var c = cost(rank)
	if RealmChronicle.state(m).fragments[RUNES[id].relic]<c.fragments or m.count("scrap")<c.scrap or m.s.gold<c.gold: return "Gather the missing fragments, scraps and gold shown below."
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
			var c = cost(int(s.ranks[id]))
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
		if not RealmChronicle.number(s.ranks.get(id,-1),3): return false
	if s.get("equipped",null) not in ["","thorn","tide","bell"]: return false
	if s.equipped!="" and s.ranks[s.equipped]<1: return false
	var allowed = []
	for region in RealmChronicle.REGIONS:
		for target in MILESTONES: allowed.append(region+"_"+str(target))
	var seen = []
	for key in s.claimed:
		if key not in allowed or key in seen: return false
		seen.append(key)
	return true
