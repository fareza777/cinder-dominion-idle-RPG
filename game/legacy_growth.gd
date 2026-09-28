class_name RealmLegacyGrowth
extends RefCounted

const ADVANCED = ["technique","hunter","endurance","recovery","resolve","bounty"]
const GATES = ["bellkeeper","wilds_5","marsh_5","crown_5","secret_6"]
const REGIONS = {"fang":"wilds","heart":"marsh","ward":"crown"}
const CORES = {"fang":"core_4","heart":"core_0","ward":"core_6"}
const GUARDIANS = {"fang":"secret_4","heart":"secret_0","ward":"secret_6"}

static func level(xp: Dictionary) -> int:
	return RealmEconomy.level(xp.bladecraft)

static func earned(s: Dictionary) -> int:
	var initial = mini(10,int((s.xp.bladecraft+s.xp.might+s.xp.warding)/250))
	var cap = 10
	for enemy in GATES:
		if int(s.kills.get(enemy,0))==0: break
		cap += 10
	return mini(cap,initial+maxi(0,int((level(s.xp)-20)*50/80)))

static func limit(id: String) -> int: return 10 if id in ADVANCED else 5
static func rank(m, id: String) -> int: return int(RealmChronicle.state(m).talents.get(id,0))

static func rank_gate(id: String, rank_value: int, xp: Dictionary, kills: Dictionary) -> bool:
	if id not in ADVANCED or rank_value==0: return true
	var stage = int((rank_value-1)/3)
	return level(xp)>=[25,50,75,100][stage] and int(kills.get(["bellkeeper","wilds_5","crown_5","secret_6"][stage],0))>0

static func talent_reason(m, id: String) -> String:
	if id not in RealmChronicle.TALENTS: return "Unknown talent."
	var current = rank(m,id)
	if current>=limit(id): return "Maximum rank reached."
	if not rank_gate(id,current+1,m.s.xp,m.s.kills):
		var stage = int(current/3)
		return "Requires Bladecraft Lv.%d and victory over %s." % [[25,50,75,100][stage],m.local_name(m.data.enemies[["bellkeeper","wilds_5","crown_5","secret_6"][stage]])]
	if RealmChronicle.points_free(m)<1: return "Earn your next talent point through levels and boss milestones."
	return ""

static func next_point(m) -> String:
	if earned(m.s)>=60: return "All 60 points earned. Choose your strengths; the full tree costs 75 points."
	for enemy in GATES:
		if int(m.s.kills.get(enemy,0))==0:
			var probe = m.s.duplicate(true)
			for skill in probe.xp: probe.xp[skill] = RealmEconomy.threshold(100,skill)
			if earned(m.s)>=earned(probe): return "Next milestone: defeat "+m.local_name(m.data.enemies[enemy])+"."
	if earned(m.s)<10: return "The first 10 points cost 250 combined melee XP each."
	var next_level = level(m.s.xp)+1
	while next_level<=100:
		var probe = m.s.duplicate(true)
		probe.xp.bladecraft = RealmEconomy.threshold(next_level)
		if earned(probe)>earned(m.s): return "Next point at Bladecraft Lv.%d. Boss milestones unlock later points." % next_level
		next_level += 1
	return "Defeat the next milestone boss to unlock more points."

static func relic_base(rank_value: int, unit: int) -> int:
	return mini(10,rank_value)*unit

static func ascended(m, id: String) -> int:
	var c = RealmChronicle.state(m)
	return maxi(0,int(c.relics[id])-10) if c.relic==id else 0

static func essence(enemy: Dictionary) -> int:
	if not enemy.boss: return 0
	if enemy.get("secret",false) or enemy.get("depth",false) or enemy.has("art_tile") or enemy.has("frontier"): return 3
	if enemy.get("trial",false): return 2
	return 1 if int(enemy.get("tier",0))>=3 else 0

static func essence_cost(rank_value: int) -> int: return 0 if rank_value<10 else 2+(rank_value-10)*2

static func relic_reason(m, id: String, resources: bool = true) -> String:
	var c = RealmChronicle.state(m)
	var r = int(c.relics[id])
	if r>=40: return "Maximum rank reached."
	if r>=10:
		var stage = mini(2,int(r/10)-1)
		var enemy = [REGIONS[id]+"_5","trial_"+REGIONS[id],GUARDIANS[id]][stage]
		if level(m.s.xp)<[50,75,100][stage] or int(m.s.kills.get(enemy,0))<1:
			return "Requires Bladecraft Lv.%d and victory over %s." % [[50,75,100][stage],m.local_name(m.data.enemies[enemy])]
	if resources:
		if m.s.gold<RealmEconomy.relic_fee(r): return "Ascension requires "+RealmEconomy.money(RealmEconomy.relic_fee(r))+" as well as hunting materials."
		if int(c.fragments[id])<RealmChronicle.relic_cost(r): return "Gather more relic fragments."
		if m.count("essence_"+id)<essence_cost(r): return "Gather %d %s Essence from regional Tier 3–5, Trial, Apex or guardian hunts." % [essence_cost(r)-m.count("essence_"+id),RealmChronicle.RELICS[id].name]
		if r>=30 and m.count(CORES[id])<1: return "Requires 1 "+m.name_of(CORES[id])+" from "+m.local_name(m.data.enemies[GUARDIANS[id]])+"."
	return ""

static func relic_effect(id: String, r: int) -> String:
	var extra = maxi(0,r-10)
	match id:
		"fang": return "+%d attack; +%.1f%% special-attack damage." % [relic_base(r,2),extra*.3]
		"ward": return "+%d armor; %.1f%% less boss damage." % [relic_base(r,2),extra*.3]
	return "+%d meal healing; +%d additional healing from ascension." % [relic_base(r,3),int(extra/5)]

static func outgoing(m, enemy: Dictionary, swing: int, damage: int) -> int:
	var bonus = rank(m,"hunter")*.005 if enemy.boss else 0.0
	if swing%4==0: bonus += rank(m,"technique")*.005+ascended(m,"fang")*.003
	return maxi(1,int(damage*(1.0+bonus)))

static func incoming(m, enemy: Dictionary, strike: int, damage: int) -> int:
	var reduction = rank(m,"resolve")*.005 if strike%3==0 else 0.0
	if enemy.boss: reduction += rank(m,"endurance")*.004+ascended(m,"ward")*.003
	return maxi(1,ceili(damage*(1.0-reduction)))
