class_name RealmHuntMastery
extends RefCounted

const TARGETS = [10,25,75,150]
const NAMES = ["Unstudied","Tracked","Studied","Veteran","Mastered"]

static func rank_for(wins: int) -> int:
	var rank = 0
	for target in TARGETS:
		if wins>=target: rank += 1
	return rank

static func rank(m, id: String) -> int:
	return rank_for(int(m.s.kills.get(id,0)))

static func fragments(m, enemy: Dictionary, wins: int = -1) -> int:
	var r = rank(m,enemy.id) if wins<0 else rank_for(wins)
	return int(enemy.get("fragments",1))+int(r/2)

static func gold(m, enemy: Dictionary, wins: int = -1) -> int:
	var r = rank(m,enemy.id) if wins<0 else rank_for(wins)
	return int(int(enemy.gold)*(1.0+int(RealmChronicle.state(m).talents.fortune)*.02+r*.02+RealmLegacyGrowth.rank(m,"bounty")*.01+RealmCards.bonus(m,"gold")))

static func battle_gold(m, enemy: Dictionary, wins: int = -1) -> int:
	var multiplier = .8 if RealmEndgame.route(m) in ["safe","mastery"] else (1.25 if RealmEndgame.route(m)=="elite" else 1.0)
	return int(gold(m,enemy,wins)*multiplier)

# Reward rates change after each milestone victory, starting on the following fight.
# Split at the four thresholds rather than iterating over a possibly large order.
static func rewards(m, enemy: Dictionary, count: int) -> Dictionary:
	var wins = int(m.s.kills.get(enemy.id,0))
	var left = maxi(0,count)
	var result = {"gold":0,"fragments":0}
	while left>0:
		var r = rank_for(wins)
		var batch = left if r==4 else mini(left,TARGETS[r]-wins)
		result.gold += batch*battle_gold(m,enemy,wins)
		result.fragments += batch*fragments(m,enemy,wins)
		wins += batch
		left -= batch
	return result

static func summary(m, id: String) -> String:
	var r = rank(m,id)
	return "%s · +%d ATK · +%d%% coins · +%d fragments" % [NAMES[r],r,r*2,int(r/2)]

static func wins_for_fragments(m, enemy: Dictionary, missing: int) -> int:
	var low = 0
	var high = ceili(float(maxi(0,missing))/fragments(m,enemy))
	while low<high:
		var mid = int((low+high)/2)
		if rewards(m,enemy,mid).fragments>=missing: high = mid
		else: low = mid+1
	return low
