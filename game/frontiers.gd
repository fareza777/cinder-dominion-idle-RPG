class_name RealmFrontiers
extends RefCounted

const REGIONS = ["The Pale Observatory","The Iron Sepulcher","The Ember Rift"]
const STORIES = ["The Unlit Sovereign's fall reveals a road to an abandoned observatory. Silence its sentries and reach the Eclipse Regent.","Beyond the observatory, chains still move beneath a sealed burial city. Break the procession and confront the Burial King.","The final road descends into the Ember Rift. Defeat its wardens and confront the source of the valley's fire."]
const QUESTS = ["Open the approach","Break the inner guard","Defeat the region's ruler"]

static func available(m, id: String) -> String:
	var previous = str(m.data.enemies[id].unlock)
	return "" if int(m.s.kills.get(previous,0))>0 else "Defeat "+m.local_name(m.data.enemies[previous])+" to open this route."

static func reward(region: int, stage: int) -> int: return (region+1)*[100000,250000,750000][stage]
static func claim(m, region: int, stage: int) -> String:
	if region<0 or region>2 or stage<0 or stage>2: return "Choose a frontier objective."
	var id = "%d_%d" % [region,stage]
	var claimed = m.s.get("frontier_claimed",[])
	if id in claimed: return "This reward was already claimed."
	if int(m.s.kills.get("frontier_%d_%d" % [region,stage*2+1],0))<1: return "Complete both encounters in this objective first."
	claimed.append(id)
	m.s.frontier_claimed = claimed
	m.s.gold += reward(region,stage)
	m.gain("depth_shard",5*(stage+1))
	m.note("Frontier objective complete · "+RealmEconomy.money(reward(region,stage))+" and Hollow Shards claimed.")
	return ""

static func valid(s: Dictionary) -> bool:
	var claims = s.get("frontier_claimed",[])
	if not claims is Array or claims.size()>9: return false
	var seen = []
	for id in claims:
		if not id is String or id in seen: return false
		var known = false
		for r in range(3):
			for stage in range(3):
				if id=="%d_%d" % [r,stage]:
					known = int(s.kills.get("frontier_%d_%d" % [r,stage*2+1],0))>0
		if not known: return false
		seen.append(id)
	return true
