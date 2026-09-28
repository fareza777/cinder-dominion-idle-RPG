class_name RealmChronicle
extends RefCounted

const TALENTS = {
	"power":{"name":"Blade of Dawn","detail":"+1 attack per rank. Finish fights sooner."},
	"guard":{"name":"Last Bastion","detail":"+1 armor per rank. Spend less food on long hunts."},
	"fortune":{"name":"Wayfarer's Fortune","detail":"+2 gold per victory per rank. Fund stronghold upgrades."},
	"technique":{"name": "Measured Strike", "detail": "Special attacks deal 0.5% more damage per rank."},
	"hunter":{"name": "Giant's Bane", "detail": "Deal 0.5% more damage to bosses per rank."},
	"endurance":{"name": "Hold Fast", "detail": "Take 0.4% less boss damage per rank."},
	"recovery":{"name": "Field Medicine", "detail": "Meals restore 1 extra HP for every 2 ranks."},
	"resolve":{"name": "Steady Guard", "detail": "Every third incoming strike deals 0.5% less damage per rank."},
	"bounty":{"name": "Seasoned Hunter", "detail": "Earn 1% more battle gold per rank. Does not affect rare drops."}}
const RELICS = {
	"fang":{"name":"Ashfang","detail":"+2 attack per rank through rank 10. Ascension improves special attacks.","source":"Ash Rats, Hollow Hounds, Cinder Bandits; Ashen Wilds","enemy":"ash_rat","icon":"copper_sword","color":"d9b477"},
	"ward":{"name":"Hollow Aegis","detail":"+2 armor per rank through rank 10. Ascension reduces boss damage.","source":"Grave Thralls, Chapel Guards, Bellkeeper; Obsidian Crown","enemy":"grave_thrall","icon":"iron_shield","color":"91b5db"},
	"heart":{"name":"Emberheart","detail":"Meals restore +3 HP per rank through rank 10, then +1 HP every 5 ranks.","source":"Ember Wraiths; Drowned Sanctum","enemy":"ember_wraith","icon":"fury_draught","color":"dd938d"}}
const REGIONS = {
	"wilds":{"name":"Ashen Wilds","detail":"The old watch still walks beneath the dead canopy. Defeat its sentinel for Ashfang fragments.","color":"b7bf91","relic":"fang"},
	"marsh":{"name":"Drowned Sanctum","detail":"The cloisters sank, but their oracle never left. Seek Emberheart fragments in the ruins.","color":"83bcb8","relic":"heart"},
	"crown":{"name":"Obsidian Crown","detail":"Beyond the ridge, the second bell is still ringing. Defeat its keeper for Hollow Aegis fragments.","color":"d295aa","relic":"ward"}}
const BOUNTIES = {
	"gather":{"name":"Supply the Stronghold","target":30,"detail":"Complete 30 gathering cycles of any kind.","gold":25},
	"craft":{"name":"Keep the Forges Warm","target":10,"detail":"Cook, smelt or forge 10 items.","gold":35},
	"hunt":{"name":"Hold the Line","target":8,"detail":"Win 8 battles against any enemies.","gold":45}}

static func state(m) -> Dictionary:
	if not m.s.has("chronicle"):
		m.s.chronicle = {"talents":{"power":0,"guard":0,"fortune":0},"relics":{"fang":0,"ward":0,"heart":0},"fragments":{"fang":0,"ward":0,"heart":0},"relic":"","day_seen":0,"daily":{"day":-1,"baseline":{"gather":0,"craft":0,"hunt":0},"claimed":[]}}
	return m.s.chronicle

static func points_earned(m) -> int:
	return RealmLegacyGrowth.earned(m.s)

static func points_free(m) -> int:
	var spent = 0
	for rank in state(m).talents.values(): spent += int(rank)
	return points_earned(m)-spent

static func relic_cost(rank: int) -> int:
	return 5*(rank+1)*(rank+1)

static func fragments_for(enemy: Dictionary) -> String:
	if enemy.has("relic"): return enemy.relic
	if enemy.id in ["ash_rat","hollow_hound","cinder_bandit"]: return "fang"
	if enemy.id=="ember_wraith": return "heart"
	return "ward"

static func totals(m) -> Dictionary:
	var counts = {"gather":0,"craft":0,"hunt":0}
	for aid in m.s.mastery:
		var kind = m.data.activities[aid].kind
		if kind in ["gather","craft"]: counts[kind] += int(m.s.mastery[aid])
	for n in m.s.kills.values(): counts.hunt += int(n)
	return counts

# Unfinished goals carry over. Only a completed board rotates on a later UTC day.
static func sync_day(m, now_ms: int):
	if not m.s.tutorial: return
	var c = state(m)
	var day = maxi(int(c.day_seen),int(now_ms/86400000))
	c.day_seen = day
	if c.daily.day<0 or (c.daily.claimed.size()==3 and day>c.daily.day):
		c.daily = {"day":day,"baseline":totals(m),"claimed":[]}

static func bounty_value(m, id: String) -> int:
	if state(m).daily.day<0: return 0
	return mini(int(BOUNTIES[id].target),maxi(0,int(totals(m)[id])-int(state(m).daily.baseline[id])))

static func ready_bounties(m) -> int:
	var count = 0
	for id in BOUNTIES:
		if id not in state(m).daily.claimed and bounty_value(m,id)>=BOUNTIES[id].target: count += 1
	return count

static func bounty_relic(m) -> String:
	return ["fang","ward","heart"][maxi(0,int(state(m).daily.day))%3]

static func bounty_reward(m, id: String) -> Dictionary:
	var tier = 0
	var food = "cooked_minnow"
	for metal in ["steel","moonsteel","dusksteel","dawnsteel"]:
		var recipe = m.data.activities["craft_cooked_"+metal+"_fish"]
		if m.level("cooking")>=recipe.level and m.level("fishing")>=recipe.level-5 and m.level("woodcutting")>=recipe.level-5:
			tier += 1
			food = recipe.output
	return {"gold":int(BOUNTIES[id].gold)*(tier+1),"food":food,"fragments":5*(tier+1)}

static func command(m, cmd: Dictionary) -> String:
	if not m.s.tutorial: return "Complete First Supplies to unlock your legacy. Follow the Journey guide."
	var c = state(m)
	var id = str(cmd.get("id",""))
	match str(cmd.type):
		"talent":
			if not m.s.fight.is_empty(): return "Retreat before changing your build."
			var why = RealmLegacyGrowth.talent_reason(m,id)
			if why!="": return why
			c.talents[id] = int(c.talents.get(id,0))+1
		"talent_reset":
			if not m.s.fight.is_empty(): return "Retreat before resetting talents."
			for key in TALENTS: c.talents[key] = 0
		"relic_upgrade":
			if not m.s.fight.is_empty(): return "Retreat before upgrading your relic."
			if not RELICS.has(id): return "Unknown relic"
			var rank = int(c.relics[id])
			var why = RealmLegacyGrowth.relic_reason(m,id)
			if why!="": return why
			var cost = relic_cost(rank)
			if c.fragments[id]<cost: return "Collect %d more fragments from the listed hunts." % (cost-int(c.fragments[id]))
			c.fragments[id] -= cost
			if rank>=10: m.spend("essence_"+id,RealmLegacyGrowth.essence_cost(rank))
			if rank>=30: m.spend(RealmLegacyGrowth.CORES[id],1)
			c.relics[id] += 1
			if c.relic=="": c.relic = id
			m.note("%s awakened to rank %d" % [RELICS[id].name,rank+1])
		"relic_equip":
			if not m.s.fight.is_empty(): return "Retreat before switching relics."
			if not RELICS.has(id) or c.relics[id]<1: return "Awaken this relic first."
			c.relic = id
		"bounty_claim":
			if not BOUNTIES.has(id) or id in c.daily.claimed or bounty_value(m,id)<BOUNTIES[id].target: return "Finish an unclaimed bounty before collecting its reward."
			c.daily.claimed.append(id)
			var reward = bounty_reward(m,id)
			m.s.gold += reward.gold
			m.gain(reward.food,5)
			c.fragments[bounty_relic(m)] += reward.fragments
			m.note("Bounty complete: "+BOUNTIES[id].name)
		_: return "Unknown legacy action"
	return ""

static func next_expedition(m) -> String:
	for region in REGIONS:
		for tier in range(1,6):
			var id = "%s_%d" % [region,tier]
			if int(m.s.kills.get(id,0))==0: return id
	return ""

static func focus(m) -> Dictionary:
	if not m.s.queue.is_empty():
		if m.s.active.is_empty() and m.s.fight.is_empty(): return {"title":"Your queue is blocked","why":"Rest, then resume hunting in Explore or Queue." if RealmStamina.state(m).paused else m.requirement(m.s.queue[0].id),"kind":"queue","id":"","amount":1}
		return {"title":"Your task is running","why":"Your orders continue while you are away, for up to 24 hours. Review the queue to see what will be ready when you return.","kind":"queue","id":"","amount":1}
	var o = m.objective()
	if not m.s.tutorial: return {"title":o.title,"why":o.detail,"kind":"story","id":"","amount":1}
	if points_free(m)>0: return {"title":"Spend your talent points","why":"Choose more damage, more armor or more gold. Reset freely outside combat.","kind":"talents","id":"","amount":1}
	for relic in RELICS:
		if state(m).relics[relic]==0 and state(m).fragments[relic]>=5: return {"title":"Awaken "+RELICS[relic].name,"why":RELICS[relic].detail,"kind":"relics","id":"","amount":1}
	for g in m.s.gear:
		var equipped = m.gear(str(m.s.equipped.get(RealmEquipmentSlots.target(m,g.uid),"")))
		if equipped.is_empty() or m.gear_score(g)>m.gear_score(equipped): return {"title":"Equip your stronger gear","why":"Your bag contains an upgrade. Crafting alone does not improve your combat stats.","kind":"equip","id":"","amount":1}
	if m.count(m.s.settings.food)<15: return {"title":"Prepare food for your next hunt","why":"Aim for 15 cooked meals. Food heals automatically during battle; raw ingredients cannot heal you.","kind":"plan","id":"craft_"+str(m.s.settings.food),"amount":15-m.count(m.s.settings.food)}
	if RealmRuneforge.ready(m)>0: return {"title":"Claim your field record rewards","why":"Completed regional hunts have fragments, scraps and gold ready to collect. Put them toward your next rune or relic.","kind":"journal","id":"","amount":1}
	if m.s.beacon:
		for id in RealmRuneforge.RUNES:
			if RealmRuneforge.state(m).ranks[id]==0 and RealmRuneforge.forge_reason(m,id)=="": return {"title":"Inscribe "+RealmRuneforge.RUNES[id].name,"why":"You have discovered this rune and gathered its materials. Review its effect before choosing between a rune and a relic upgrade.","kind":"runes","id":id,"amount":1}
	for pair in [["shield","copper_shield"],["hands","copper_gloves"],["feet","copper_boots"],["head","copper_helm"],["body","copper_chest"]]:
		var a = m.data.activities["craft_"+pair[1]]
		var g = m.gear(str(m.s.equipped.get(pair[0],"")))
		if (g.is_empty() or g.id=="worn_shield") and m.level("smithing")>=int(a.level): return {"title":"Forge "+m.name_of(pair[1]),"why":"Fill your armor slots to reduce incoming damage and stretch your food supplies.","kind":"plan","id":a.id,"amount":1}
	if o.key=="smith": return {"title":"Reach Smithing level 10","why":"Smelt %d more copper ingots in total. Plan up to 100 at a time; repeat if needed. The planner includes missing ore." % RealmJourney.smithing_batch(m),"kind":"plan","id":"craft_copper_ingot","amount":clampi(RealmJourney.smithing_batch(m),1,100)}
	return {"title":o.title,"why":o.detail,"kind":"story","id":"","amount":1}

static func number(v, maximum: int = 1000000000000) -> bool:
	return typeof(v) in [TYPE_INT,TYPE_FLOAT] and is_finite(float(v)) and v>=0 and v<=maximum and floor(float(v))==float(v)

static func valid(c, xp: Dictionary, kills: Dictionary = {}) -> bool:
	if not c is Dictionary: return false
	for field in ["talents","relics","fragments","daily"]:
		if not c.get(field) is Dictionary: return false
	for key in c.talents:
		if key not in TALENTS: return false
	for key in ["power","guard","fortune"]:
		if not c.talents.has(key): return false
	var spent = 0
	for id in TALENTS:
		if not number(c.talents.get(id,0),RealmLegacyGrowth.limit(id)): return false
		if not RealmLegacyGrowth.rank_gate(id,int(c.talents.get(id,0)),xp,kills): return false
		spent += int(c.talents.get(id,0))
	if spent>RealmLegacyGrowth.earned({"xp":xp,"kills":kills}): return false
	for id in RELICS:
		if not number(c.relics.get(id,-1),40) or not number(c.fragments.get(id,-1)): return false
		var r = int(c.relics[id])
		if r>10:
			var stage = mini(2,int((r-1)/10)-1)
			var enemy = [RealmLegacyGrowth.REGIONS[id]+"_5","trial_"+RealmLegacyGrowth.REGIONS[id],RealmLegacyGrowth.GUARDIANS[id]][stage]
			if RealmLegacyGrowth.level(xp)<[50,75,100][stage] or int(kills.get(enemy,0))<1: return false
	if c.get("relic",null) not in ["","fang","ward","heart"]: return false
	if c.relic!="" and c.relics[c.relic]<1: return false
	if not number(c.get("day_seen",-1)): return false
	var d = c.daily
	if typeof(d.get("day")) not in [TYPE_INT,TYPE_FLOAT]: return false
	if not number(d.day+1) or d.day>c.day_seen or not d.get("baseline") is Dictionary or not d.get("claimed") is Array: return false
	var seen = []
	for id in d.claimed:
		if id not in BOUNTIES or id in seen: return false
		seen.append(id)
	for id in BOUNTIES:
		if not number(d.baseline.get(id,-1)): return false
	return true
